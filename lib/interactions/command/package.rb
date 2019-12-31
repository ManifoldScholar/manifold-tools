module Interactions
  module Command
    class Package < BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      string :platform

      delegate :projects, to: :environment

      def execute
        version = Models::Version.new projects.manifold_source.manifold_version_file_current_value
        puts version
        if platform == "docker"
          return compose(Interactions::Package::Docker, inputs.merge(version: version))
        end
        compose(Interactions::Package::Omnibus, inputs.merge(version: version))
      end

    end
  end
end
