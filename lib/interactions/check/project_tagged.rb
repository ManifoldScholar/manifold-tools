# frozen_string_literal: true

module Interactions
  module Check
    class ProjectTagged < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'
      object :version, class: 'Models::Version'

      delegate :name, to: :project, prefix: true

      def execute
        if project.tagged?(version)
          say "Already tagged with #{version}", project
          true
        else
          say "Not yet tagged with #{version}", project
          false
        end
      end
    end
  end
end
