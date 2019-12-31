module Interactions
  module Git
    class Push < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :project, class: "Models::Projects::Base"
      string :branch

      def execute
        say "Pushing #{project.name} #{branch} branch to origin", project
        unless options.noop || options.no_push
          project.git.push('origin', branch, tags: true)
        else
          whisper "...skipping push due to --noop or --no-push flag", project
        end
      rescue ::Git::GitExecuteError => e
        errors.add("git:push", e)
      end


    end
  end
end
