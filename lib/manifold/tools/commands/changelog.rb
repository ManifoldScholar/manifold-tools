# frozen_string_literal: true

require_relative '../command'

module Manifold
  module Tools
    module Commands
      class Changelog < Manifold::Tools::Command

        def execute(input: $stdin, output: $stdout)
          outcome = Interactions::UpdateChangelog.run(environment: Models::Environment.new, options: @options)
          success_msg = "Changelog successfully updated."
          report(outcome, success_msg)
        end
      end
    end
  end
end
