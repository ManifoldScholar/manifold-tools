# frozen_string_literal: true

module Interactions
  module Git
    class Fetch < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'

      def execute
        say 'Fetching from origin', project
        if options.noop
          whisper '...skipping fetch due to --noop flag', project
        else
          project.git.fetch
        end
      rescue ::Git::GitExecuteError => e
        errors.add('git:fetch', e)
      end
    end
  end
end
