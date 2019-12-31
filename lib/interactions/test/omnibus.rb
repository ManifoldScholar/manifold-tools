require "tty-command"

module Interactions
  module Test
    class Omnibus < Interactions::BaseInteraction

      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      string :platform
      object :version, class: "Models::Version"

      def execute
        say "Bringing up the builder"
        manifold_omnibus.machine_up("#{platform}-installer")
      end

    end
  end
end
