# frozen_string_literal: true

module Interactions
  module Git
    class HardReset < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'
      string :branch

      def execute
        say "Hard reseting to #{branch}", project
        if options.noop
          whisper '...skipping hard_reset due to --noop flag', project
        else
          project.hard_reset(branch)
        end
      rescue ::Git::GitExecuteError => e
        errors.add('git:hard_reset', e)
      end
    end
  end
end
