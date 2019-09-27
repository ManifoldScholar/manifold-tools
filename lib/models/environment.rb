require 'attr_lazy'

module Models
  class Environment
    def initialize
      @configuration = Configuration.new
    end

    def fetch(*args)
      @configuration.fetch(*args)
    end

    def fetch_all
      @env
    end

    attr_lazy_reader :github do
      Models::Github.new env: self
    end

    attr_lazy_reader :jenkins do
      Models::Jenkins.new env: self
    end

    attr_lazy_reader :projects do
      Models::Projects::Config.new env: self
    end
  end
end
