module Interactions
  module Git

    class Stash < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :project, class: "Models::Projects::Base"

      def execute

        say "Stashing changes", project
        unless options.noop
          project.stash
        else
          whisper "...skipping stashing due to --noop flag", project
        end
      rescue ::Git::GitExecuteError => e
        errors.add("git:stash", e)
      end
    end
  end
end
