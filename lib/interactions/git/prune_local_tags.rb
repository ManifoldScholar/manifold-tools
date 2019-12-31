module Interactions
  module Git

    class PruneLocalTags < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :project, class: "Models::Projects::Base"

      def execute

        say "Pruning local tags", project
        unless options.noop
          project.prune_local_tags
        else
          whisper "...skipping pruning local tags due to --noop flag", project
        end
      rescue ::Git::GitExecuteError => e
        errors.add("git:prune_local_tags", e)
      end
    end
  end
end
