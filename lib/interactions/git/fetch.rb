module Interactions
  module Git
    class Fetch < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :project, class: "Models::Projects::Base"

      def execute
        say "Fetching from origin", project
        unless options.noop
          project.git.fetch
        else
          whisper "...skipping fetch due to --noop flag", project
        end
      rescue ::Git::GitExecuteError => e
        errors.add("git:fetch", e)
      end
    end
  end
end
