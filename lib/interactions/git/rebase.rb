# frozen_string_literal: true

module Interactions
  module Git
    class Rebase < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'
      string :branch

      def execute
        say "Rebasing onto #{branch}", project
        if options.noop
          whisper '...skipping hard_reset due to --noop flag', project
        else
          project.rebase(branch)
        end
      rescue ::Git::GitExecuteError => e
        errors.add('git:hard_reset', e)
      end
    end
  end
end
