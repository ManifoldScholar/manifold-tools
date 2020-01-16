module Interactions
  module Git

    class Rebase < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :project, class: "Models::Projects::Base"
      string :branch

      def execute
        say "Rebasing onto #{branch}", project
        unless options.noop
          project.rebase(branch)
        else
          whisper "...skipping hard_reset due to --noop flag", project
        end
      rescue ::Git::GitExecuteError => e
        errors.add("git:hard_reset", e)
      end
    end
  end
end
