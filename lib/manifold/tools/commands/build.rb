# frozen_string_literal: true

require_relative '../command'

module Manifold
  module Tools
    module Commands
      class Build < Manifold::Tools::Command

        def initialize(version, platform = "all", options)
          @version = version
          @platform = platform
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          outcome = Interactions::Command::Build.run(environment: Models::Environment.new, version: @version, platform: @platform, options: @options)
          report(outcome)
        end
      end
    end
  end
end
