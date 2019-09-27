# frozen_string_literal: true

require 'thor'
require "zeitwerk"
require 'pry'

loader = Zeitwerk::Loader.for_gem
# loader.log!
loader.ignore("#{__dir__}/version.rb")
loader.push_dir("~/src/manifold-tools/lib")
loader.setup # ready!

module Manifold
  module Tools
    # Handle the application command line parsing
    # and the dispatch to various command objects
    #
    # @api public
    class Cli < Thor
      # Error raised by this runner
      Error = Class.new(StandardError)

      desc 'version', 'manifold-tools version'
      def version
        require_relative 'version'
        puts "v#{Manifold::Tools::VERSION}"
      end
      map %w(--version -v) => :version

      desc 'configure', 'Command description...'
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

      desc 'publish', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def publish(*)
        if options[:help]
          invoke :help, ['publish']
        else
          require_relative 'commands/publish'
          Manifold::Tools::Commands::Publish.new(options).execute
        end
      end

      desc 'build', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def build(*)
        if options[:help]
          invoke :help, ['build']
        else
          require_relative 'commands/build'
          Manifold::Tools::Commands::Build.new(options).execute
        end
      end

      desc 'changelog', 'Command description...'
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
