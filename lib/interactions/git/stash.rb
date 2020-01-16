# frozen_string_literal: true

module Interactions
  module Git
    class Stash < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'

      def execute
        say 'Stashing changes', project
        if options.noop
          whisper '...skipping stashing due to --noop flag', project
        else
          project.stash
        end
      rescue ::Git::GitExecuteError => e
        errors.add('git:stash', e)
      end
    end
  end
end
