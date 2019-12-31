module Interactions
  module Git

    class HardReset < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :project, class: "Models::Projects::Base"
      string :branch

      def execute
        say "Hard reseting to #{branch}", project
        unless options.noop
          project.hard_reset(branch)
        else
          whisper "...skipping hard_reset due to --noop flag", project
        end
      rescue ::Git::GitExecuteError => e
        errors.add("git:hard_reset", e)
      end
    end
  end
end
