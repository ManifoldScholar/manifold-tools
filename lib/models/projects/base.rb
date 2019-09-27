require 'attr_lazy'
require 'git'

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

      attr_lazy_reader :name do
        self.class.name.demodulize.underscore.inquiry
      end

      delegate :manifold_source?, :manifold_omnibus?, to: :name

      attr_reader :path
      attr_reader :repo
      attr_reader :options

      def current_version
        versions.first
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

      def describe(commit)
        git.describe(commit, {:contains=> true})
      rescue Git::GitExecuteError
        return nil
      end

      def reload
        @versions = get_versions
      end

      private

      def get_versions
        git.tags.map(&:name).grep(/\Av/).map { |version| Models::Version.new version }.sort
      end
    end
  end
end
