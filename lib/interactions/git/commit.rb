module Interactions
  module Git
    class Commit < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :project, class: "Models::Projects::Base"
      string :message

      def execute
        say "Commit changes in #{project.name}: #{message}", project
        unless options.noop
          project.git.add "."
          project.git.commit message
        else
          whisper "...skipping commit due to --noop flag", project
        end
      rescue ::Git::GitExecuteError => e
        errors.add("git:commit", e)
      end

    end
  end
end
