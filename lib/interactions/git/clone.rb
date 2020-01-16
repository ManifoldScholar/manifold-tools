# frozen_string_literal: true

module Interactions
  module Git
    class Clone < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'

      def execute
        if options.noop
          whisper '...skipping clone due to --noop flag', project
        else
          return say 'Skipping clone: repository already exists', project if project.cloned?

          say "Cloning #{project.repo} into #{project.path}", project
          project.clone

        end
      end
    end
  end
end
