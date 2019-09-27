# frozen_string_literal: true

require_relative '../command'

module Manifold
  module Tools
    module Commands
      class Build < Manifold::Tools::Command

        def execute(input: $stdin, output: $stdout)
          outcome = result = ::Interactions::ReleaseNewVersion.run(environment: Models::Environment.new, options: @options)
          success_msg = "Build request submitted to Jenkins."
          report(outcome, success_msg)
        end
      end
    end
  end
end
