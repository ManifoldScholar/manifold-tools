# frozen_string_literal: true

module Interactions
  module Command
    class Build < BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      string :version

      delegate :projects, to: :environment

      attr_accessor :version

      def execute
        sem_version = Models::Version.new(version)

        # Move each repo into the correct state.
        projects.each do |project|
          compose(Interactions::Project::Prepare, inputs.merge(project: project, version: sem_version))
        end

        # Do the packaging.
        projects.manifold_omnibus.gem_install_bundler('1.17.2')
        projects.manifold_omnibus.bundle_install

        compose(Interactions::Package::Omnibus, inputs.merge(platform: 'ubuntu16', version: sem_version, with_confirmation: false, skip_prepare: true))
        compose(Interactions::Package::Omnibus, inputs.merge(platform: 'ubuntu18', version: sem_version, with_confirmation: false, skip_prepare: true))
        compose(Interactions::Package::Omnibus, inputs.merge(platform: 'centos7', version: sem_version, with_confirmation: false, skip_prepare: true))
        compose(Interactions::Package::Docker, inputs.merge(version: sem_version, with_confirmation: false))

        say 'Build complete'
      end
    end
  end
end
