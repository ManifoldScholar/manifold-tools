module Interactions
  module Git
    class Clone < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :project, class: "Models::Projects::Base"

      def execute
        unless options.noop
          return say "Skipping clone: repository already exists", project if project.cloned?
          say "Cloning #{project.repo} into #{project.path}", project
          project.clone

        else
          whisper "...skipping clone due to --noop flag", project
        end
      rescue ::Git::GitExecuteError => e
        # errors.add("git:checkout", e)
      end
    end
  end
end
