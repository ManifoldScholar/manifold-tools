# frozen_string_literal: true

require_relative '../command'

module Manifold
  module Tools
    module Commands
      class Build < Manifold::Tools::Command
        def execute(input: $stdin, output: $stdout)
          outcome = Interactions::Command::Build.run(environment: Models::Environment.new, options: @options)
          report(outcome)
        end
      end
    end
  end
end
