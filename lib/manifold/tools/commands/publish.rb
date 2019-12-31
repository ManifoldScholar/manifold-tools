# frozen_string_literal: true

require_relative '../command'

module Manifold
  module Tools
    module Commands
      class Publish < Manifold::Tools::Command
        def initialize(version, options)
          @version = version
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          outcome = Interactions::Command::Publish.run(environment: Models::Environment.new, options: @options, version: @version)
          report(outcome)
        end
      end
    end
  end
end
