# frozen_string_literal: true

require_relative '../command'

module Manifold
  module Tools
    module Commands
      class Publish < Manifold::Tools::Command

        def execute(input: $stdin, output: $stdout)

          outcome = Interactions::PublishDocumentation.run(environment: Models::Environment.new, options: @options)
          success_msg = "Master Branch of documentation deployed; downloads updated"
          report(outcome, success_msg)
        end
      end
    end
  end
end
