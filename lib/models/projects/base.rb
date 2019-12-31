require 'attr_lazy'
require 'git'
require "tty-command"

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
        File.read(manifold_version_file)
      end

      attr_lazy_reader :name do
        self.class.name.demodulize.underscore.inquiry
      end

      delegate :manifold_source?, :manifold_omnibus?, to: :name

      attr_reader :path
      attr_reader :repo
      attr_reader :options

      def current_tag
        Dir.chdir(@path.to_s){
          cmd = TTY::Command.new(printer: :null)
          out, err = cmd.run("git describe --exact-match --tags $(git log -n1 --pretty='%h')")
          return !out.empty?
        }
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
        get_versions
      end

      def tag_date(tag)
        return "" if tag === "unreleased"
        Dir.chdir(@path.to_s){
          result = %x[git rev-parse #{tag} | xargs git cat-file -p | egrep '^tagger' | cut -f2 -d '>']
          unless result.blank?
            timestamp, offset = result.split(" ")
            return Time.at(timestamp.to_i).to_datetime
          end
          result = %x[git log -1 --format=%ai #{tag}]
          unless result.blank?
            return Date.parse(result)
          end
          return null
        }
      end

      def in_master_branch?
        in_branch?("master")
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
        return false
      end

      def clone
        Dir.mkdir(@path) unless File.directory?(@path)
        Git.clone("git@github.com:#{@repo}.git", ".", :path => @path)
      end

      def cloned?
        return File.directory?(@path) && File.directory?(File.join(@path, ".git"))
      end

      def working_tree_dirty?
        Dir.chdir(@path.to_s){
          cmd = TTY::Command.new(printer: :null)
          out, err = cmd.run("git status --porcelain")
          return !out.empty?
        }
      end

      def clean_build_branches
        Dir.chdir(@path.to_s){
          cmd = TTY::Command.new
          result = cmd.run!("git branch |  sed 's/^* //' | grep \"build/\"")
          if result.out
             branches = result.out.split(/\n+/)
             branches.each do |branch|
               cmd.run("git branch -D #{branch}")
             end
          end
        }
      end

      def branch?(branch)
        Dir.chdir(@path.to_s){
          cmd = TTY::Command.new(printer: :null)
          out, err = cmd.run("git show-ref refs/heads/#{branch}")
          return out.present?
        }
      rescue TTY::Command::ExitError
        return false
      end

      def stash
        Dir.chdir(@path.to_s){
          cmd = TTY::Command.new
          out, err = cmd.run("git stash --include-untracked")
          return !out.empty?
        }
      end

      def prune_local_tags
        Dir.chdir(@path.to_s){
          cmd = TTY::Command.new
          out, err = cmd.run("git fetch --prune origin +refs/tags/*:refs/tags/*")
          return !out.empty?
        }
      end

      def hard_reset(branch)
        Dir.chdir(@path.to_s){
          cmd = TTY::Command.new
          out, err = cmd.run("git reset --hard origin/#{branch}")
          return !out.empty?
        }
      end

      def pr_exists?(message)
        Dir.chdir(@path.to_s){
          cmd = TTY::Command.new(printer: :null)
          out, err = cmd.run("hub pr list")
          return out.include?(message)
        }
      end

      def open_pull_request(message)
        Dir.chdir(@path.to_s){
          cmd = TTY::Command.new
          out, err = cmd.run("hub pull-request -m \"#{message}\"")
          return !out.empty?
        }
      end

      def describe(commit)
        git.describe(commit, {:contains=> true})
      rescue Git::GitExecuteError
        return nil
      end

      def reload
        @versions = get_versions
      end

      def manifold_source_path
        @options[:manifold_source_path]
      end

      def rsync_manifold_src
        raise "manifold_source_path not set" unless manifold_source_path
        Dir.chdir(@path){
          cmd = TTY::Command.new(printer: :pretty)
          cmd.run("rsync -av --exclude '.git' --exclude 'client/node_modules' --progress --delete #{manifold_source_path}/ #{File.join(@path, "manifold-src")}")
        }
      end

      def symlink_manifold_src
        raise "manifold_source_path not set" unless manifold_source_path
        unless File.exist?(File.join(@path, "manifold-src"))
          Dir.chdir(@path){
            cmd.run("ln -s #{manifold_source_path} manifold-src")
          }
        end
      end

      private

      def get_versions
        git.tags.map(&:name).grep(/\Av/).map { |version| Models::Version.new version }.sort
      end
    end
  end
end
