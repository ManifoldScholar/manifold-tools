module Interactions
  module Check
    class ProjectTagged < Interactions::BaseInteraction

      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :project, class: "Models::Projects::Base"
      object :version, class: "Models::Version"

      delegate :name, to: :project, prefix: true

      def execute
        if project.tagged?(version)
          say "Already tagged with #{version.to_s}", project
          true
        else
          say "Not yet tagged with #{version.to_s}", project
          false
        end
      end

    end
  end
end
