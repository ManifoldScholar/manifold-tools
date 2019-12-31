# frozen_string_literal: true

require_relative '../command'

module Manifold
  module Tools
    module Commands
      class Configure < Manifold::Tools::Command

        def execute(input: $stdin, output: $stdout)
          outcome = Interactions::Command::Configure.run()
          config = outcome.result
          success_msg = "Settings saved to #{config.write_location}"
          report(outcome, success_msg)
        end
      end
    end
  end
end
