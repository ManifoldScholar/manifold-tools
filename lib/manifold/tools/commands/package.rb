# frozen_string_literal: true

require_relative '../command'

module Manifold
  module Tools
    module Commands
      class Package < Manifold::Tools::Command
        def initialize(platform, options)
          @platform = platform
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          outcome = Interactions::Command::Package.run(environment: Models::Environment.new, options: @options, platform: @platform)
          report(outcome)
        end
      end
    end
  end
end
