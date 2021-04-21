# frozen_string_literal: true

require 'attr_lazy'
require 'git'
require 'tty-command'
require 'pastel'

module Models
  module Projects
    # @abstract
    class Base
      def initialize(path, repo, **options)
        @path = Pathname.new(path)
        @repo = repo
        @options = options.with_indifferent_access
      end

      def chdir
        Dir.chdir @path do
          yield @path if block_given?
        end
      end

      attr_lazy_reader :manifold_version_file do
        path.join 'MANIFOLD_VERSION'
      end

      def manifold_version_relative_path
        manifold_version_file.relative_path_from(path).to_s
      end

      def manifold_version_file_current_value
        return nil unless File.exist? manifold_version_file

        File.read manifold_version_file
      end

      attr_lazy_reader :name do
        self.class.name.demodulize.underscore.inquiry
      end

      delegate :manifold_source?, :manifold_omnibus?, to: :name

      attr_reader :path
      attr_reader :repo
      attr_reader :options

      def current_tag
        Dir.chdir(@path.to_s) do
          cmd = TTY::Command.new(printer: :null)
          out, err = cmd.run("git describe --exact-match --tags $(git log -n1 --pretty='%h')")
          return !out.empty?
        end
      end

      attr_lazy_reader :git do
        Git.open @path.to_s
      end

      attr_lazy_reader :index do
        git.index
      end

      attr_lazy_reader :repository do
        git.repo
      end

      attr_lazy_reader :versions do
        fetch_versions
      end

      def tag_date(tag)
        return '' if tag == 'unreleased'

        Dir.chdir(@path.to_s) do
          result = `git rev-parse #{tag} | xargs git cat-file -p | egrep '^tagger' | cut -f2 -d '>'`
          unless result.blank?
            timestamp, offset = result.split(' ')
            return Time.at(timestamp.to_i).to_datetime
          end
          result = `git log -1 --format=%ai #{tag}`
          return Date.parse(result) unless result.blank?

          return null
        end
      end

      def in_master_branch?
        in_branch?('master')
      end

      def in_branch?(branch)
        git.current_branch == branch
      end

      def not_in_branch?(branch)
        !in_branch?(branch)
      end

      def tagged?(version)
        git.tag(version.to_s)
        true
      rescue ::Git::GitTagNameDoesNotExist
        false
      end

      def clone
        Dir.mkdir(@path) unless File.directory?(@path)
        Git.clone("git@github.com:#{@repo}.git", '.', path: @path)
      end

      def cloned?
        File.directory?(@path) && File.directory?(File.join(@path, '.git'))
      end

      def working_tree_dirty?
        Dir.chdir(@path.to_s)  do
          cmd = TTY::Command.new(printer: :null)
          out, err = cmd.run('git status --porcelain')
          return !out.empty?
        end
      end

      def clean_build_branches
        Dir.chdir(@path.to_s) do
          cmd = TTY::Command.new
          result = cmd.run!("git branch |  sed 's/^* //' | grep \"build/\"")
          if result.out
            branches = result.out.split(/\n+/)
            branches.each do |branch|
              cmd.run("git branch -D #{branch}")
            end
          end
        end
      end

      def branch?(branch)
        Dir.chdir(@path.to_s) do
          cmd = TTY::Command.new(printer: :null)
          out, err = cmd.run("git show-ref refs/heads/#{branch}")
          return out.present?
        end
      rescue TTY::Command::ExitError
        false
      end

      def stash
        Dir.chdir(@path.to_s) do
          cmd = TTY::Command.new
          out, err = cmd.run('git stash --include-untracked')
          return !out.empty?
        end
      end

      def prune_local_tags
        Dir.chdir(@path.to_s) do
          cmd = TTY::Command.new
          out, err = cmd.run('git fetch --prune origin +refs/tags/*:refs/tags/*')
          return !out.empty?
        end
      end

      def hard_reset(branch)
        Dir.chdir(@path.to_s) do
          cmd = TTY::Command.new
          out, err = cmd.run("git reset --hard #{remotify_branch(branch)}")
          return !out.empty?
        end
      end

      def last_commit_message(branch)
        Dir.chdir(@path.to_s) do
          cmd = TTY::Command.new
          out, err = cmd.run("git log -n 1 #{remotify_branch(branch)} --pretty=\"format:%s\"")
          return out
        end
      rescue TTY::Command::ExitError
        nil
      end

      def rebase(branch)
        Dir.chdir(@path.to_s) do
          cmd = TTY::Command.new
          out, err = cmd.run("git rebase #{remotify_branch(branch)}")
          return !out.empty?
        end
      end

      def remotify_branch(branch)
        return branch if branch.start_with? 'origin'

        "origin/#{branch}"
      end

      def open_pr_for_branch?(branch)
        open_prs.key?(branch)
      end

      def pr_url_for_branch(branch)
        open_prs[branch]
      end

      def open_prs
        Dir.chdir(@path.to_s) do
          cmd = TTY::Command.new(printer: :null)
          res, err = cmd.run('hub pr list -f "%H|%U,"')
          prs = res.split(',')
          out = {}
          prs.each do |pr|
            branch, url = pr.split('|')
            out[branch] = url
          end
          return out
        end
      end

      def open_pull_request(message, base: "master")
        Dir.chdir(@path.to_s) do
          cmd = TTY::Command.new
          out, err = cmd.run("hub pull-request -m \"#{message}\" -b #{base}")
          return !out.empty?
        end
      end

      def describe(commit)
        git.describe(commit, contains: true)
      rescue Git::GitExecuteError
        nil
      end

      def bundle_install
        Dir.chdir(@path) do
          return cmd(:quiet).run('bundle install')
        end
      end

      def gem_install_bundler(version)
        Dir.chdir(@path) do
          return cmd(:quiet).run("gem install bundler:#{version}")
        end
      end

      def reload
        @versions = fetch_versions
      end

      def manifold_source_path
        @options[:manifold_source_path]
      end

      def rsync_manifold_src
        raise 'manifold_source_path not set' unless manifold_source_path

        Dir.chdir(@path) do
          cmd = TTY::Command.new(printer: :pretty)
          cmd.run("rsync -av --exclude '.git' --exclude 'client/node_modules' --progress --delete #{manifold_source_path}/ #{File.join(@path, 'manifold-src')}")
        end
      end

      def count_commits_ahead(head, base)
        Dir.chdir(@path) do
          cmd = TTY::Command.new(printer: :null)
          out, err = cmd.run("git rev-list --count #{base}..#{head}")
          return out.to_i
        end
      end

      def count_commits_behind(head, base)
        count_commits_ahead(base, head)
      end

      def amend_commit(message)
        Dir.chdir(@path)  do
          cmd = TTY::Command.new(printer: :null)
          out, err = cmd.run("git commit --amend --allow-empty -m \"#{message}\"")
        end
      end

      def project_ruby_command(*args, in_directory: @path)
        # out, err, status = Open3.capture3(project_ruby_env, *args, chdir: in_directory)
        status = nil
        data = {:out => [], :err => []}
        Open3.popen3(project_ruby_env, *args, chdir: in_directory) do |stdin, stdout, stderr, thread|
          { :out => stdout, :err => stderr }.each do |key, stream|
            Thread.new do
              until (raw_line = stream.gets).nil? do
                data[key].push raw_line
                print_message raw_line
              end
            end
          end
          status = thread.value # Process::Status object returned.
          thread.join # don't exit until the external process is done
        end

        unless status.success?
          warn err

          raise "Failed to run #{args * " "}"
        end

        data[:out].join("\n")

      end

      def project_ruby_env
        {}.tap do |h|
          h["BUNDLE_GEMFILE"] = project_gemfile
          h["RBENV_VERSION"] = project_ruby_version
        end
      end

      def project_gemfile
        @project_gemfile ||= File.join(@path, "Gemfile")
      end

      def project_ruby_version
        @project_ruby_version ||= File.join(@path, ".ruby-version").read rescue RUBY_VERSION
      end

      private

      def pastel
        @pastel ||= Pastel.new
      end

      def interaction_name
        @interaction_name ||= self.class.name.split('::').last
      end

      def interaction_badge
        pastel.dim("[#{interaction_name.rjust(13)}] ")
      end

      def print_message(msg)
        puts interaction_badge + msg
      end

      def fetch_versions
        git.tags.map(&:name).grep(/\Av/).map { |version| Models::Version.new version }.sort
      end
    end
  end
end
