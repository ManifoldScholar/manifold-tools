require "active_interaction"
require "tty-prompt"

module Interactions
  module Prompt
    class Dangerous < Interactions::BaseInteraction
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      string :message

      def execute
        prompt.warn("What your about to do could be dangerous.\n#{message}")
        confirmation = prompt.ask("If you are sure you want to do this, type \"manifold\"")
        bailout if confirmation != "manifold"
      end

      private

      def bailout
        errors.add :base, "Exiting. Come back soon."
        return
      end

      def prompt
        @prompt ||= TTY::Prompt.new
      end


    end
  end
end
