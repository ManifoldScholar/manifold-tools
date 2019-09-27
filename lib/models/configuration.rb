require "tty-config"
require 'active_support/core_ext/module/delegation'

module Models

  class Configuration

    CONFIG_FILENAME = ".manifold-tools"
    CONFIG_EXTNAME = ".yml"

    def initialize
      @config = TTY::Config.new
      @config.filename = CONFIG_FILENAME
      @config.extname = CONFIG_EXTNAME
      @config.append_path Dir.pwd
      @config.append_path Dir.home
      @config.read if @config.exist?
    end

    def write_location
      File.join(Dir.home, "#{CONFIG_FILENAME}#{CONFIG_EXTNAME}")
    end

    def write(*args)
      if config.exist?
        @config.write(*args, force: true)
      else
        @config.write(write_location)
      end
    end

    delegate :set, :fetch, :read, :exist?, to: :config

    private

    attr_reader :config

  end

end