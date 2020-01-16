# frozen_string_literal: true

require 'thor'
require "zeitwerk"
require 'pry'
require 'active_support'
require 'active_support/core_ext'

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/version.rb")
loader.push_dir("~/src/manifold-tools/lib")
loader.setup

module Manifold
  module Tools
    # Handle the application command line parsing
    # and the dispatch to various command objects
    #
    # @api public
    class Cli < Thor
      # Error raised by this runner
      Error = Class.new(StandardError)

      desc 'version', 'Output the current version of manifold-tools'
      def version
        require_relative 'version'
        puts "v#{Manifold::Tools::VERSION}"
      end
      map %w(--version -v) => :version

      desc 'clean', 'cleans the underlying repositories'
      method_option :help, aliases: '-h', type: :boolean,
                    desc: 'Display usage information'
      def clean(*)
        if options[:help]
          invoke :help, ['pusclean']
        else
          require_relative 'commands/clean'
          Manifold::Tools::Commands::Clean.new(options).execute
        end
      end

      desc 'publish VERSION', 'Commits changes and tags repositories. Pushes repos, uploads packages, and published docs.'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :skip_checks, type: :boolean, default: false, desc: "If true, manifold-tools will not check for missing packages."
      method_option :no_overwrite, type: :boolean, default: false, desc: "If true, existing packages will not be overwritten."
      method_option :regenerate_manifest, type: :boolean, default: false, desc: "If true, the omnibus package manifest will always be regenerated"
      def publish(version)
        if options[:help]
          invoke :help, ['publish']
        else
          require_relative 'commands/publish'
          Manifold::Tools::Commands::Publish.new(version, options).execute
        end
      end

      desc 'package PLATFORM', 'Create all operating system packages'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def package(platform)
        if options[:help]
          invoke :help, ['package']
        else
          require_relative 'commands/package'
          Manifold::Tools::Commands::Package.new(platform, options).execute
        end
      end

      desc 'build', 'Build Manifold and create Docker images and OS packages'
      method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
      method_option :version, type: :string, desc: "The version that you will build. If a tag exists, it will be checked out. If not, repositories will be tagged."
      method_option :branch, type: :string, default: "master", desc: "If you're not building an existing tag, the release will be built from this branch"
      method_option :no_overwrite, type: :boolean, default: false, desc: "If true, existing packages will not be overwritten."
      def build(*)
        if options[:help]
          invoke :help, ['build']
        else
          require_relative 'commands/build'
          Manifold::Tools::Commands::Build.new(options).execute
        end
      end

      desc 'configure', 'Configure manifold-tools.'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def configure(*)
        if options[:help]
          invoke :help, ['configure']
        else
          require_relative 'commands/configure'
          Manifold::Tools::Commands::Configure.new(options).execute
        end
      end

      desc 'changelog', 'Generate the current changelog.'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :refresh, type: :boolean,
                    desc: "Refreshes pull request data from Github"
      def changelog(*)
        if options[:help]
          invoke :help, ['changelog']
        else
          require_relative 'commands/changelog'
          Manifold::Tools::Commands::Changelog.new(options).execute
        end
      end

    end
  end
end
