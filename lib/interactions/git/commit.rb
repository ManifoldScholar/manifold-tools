# frozen_string_literal: true

module Interactions
  module Git
    class Commit < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'
      string :message
      boolean :amend, default: false

      def execute
        say "Commit changes in #{project.name}: #{message}", project
        if options.noop
          whisper '...skipping commit due to --noop flag', project
          return
        end
        return amend_commit if amend

        commit
      rescue ::Git::GitExecuteError => e
        errors.add('git:commit', e)
      end

      private

      def amend_commit
        say 'Amending existing commit', project
        project.git.add '.'
        project.amend_commit message
      end

      def commit
        say 'Adding and creating commit', project
        project.git.add '.'
        project.git.commit message
      end
    end
  end
end
