module Interactions
  module Command
    class Build < BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"

      delegate :projects, to: :environment

      attr_accessor :version

      def execute

        # Prompt for the new version
        version = compose(Prompt::Version, inputs)

        # Move each repo into the correct state.
        projects.each do |project|
          compose(Interactions::Project::Prepare, inputs.merge(project: project, version: version))
        end

        # Do the packaging.
        projects.manifold_omnibus.gem_install_bundler("1.17.2")
        projects.manifold_omnibus.bundle_install
        compose(Interactions::Package::Omnibus, inputs.merge(platform: "ubuntu16", version: version, with_confirmation: false, skip_prepare: true))
        compose(Interactions::Package::Omnibus, inputs.merge(platform: "ubuntu18", version: version, with_confirmation: false, skip_prepare: true))
        compose(Interactions::Package::Omnibus, inputs.merge(platform: "centos7", version: version, with_confirmation: false, skip_prepare: true))
        compose(Interactions::Package::Docker, inputs.merge(version: version, with_confirmation: false))

        say "Build complete"

      end

    end
  end
end
