# frozen_string_literal: true

module Interactions
  module Command
    class Build < BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      string :version
      string :platform, default: "all"

      delegate :projects, to: :environment

      attr_accessor :version

      def execute
        sem_version = Models::Version.new(version)

        # Move each repo into the correct state.
        projects.each do |project|
          compose(Interactions::Project::Prepare, inputs.merge(project: project, version: sem_version))
        end

        # Do the packaging.
        projects.manifold_omnibus.gem_install_bundler('2.1.4')
        projects.manifold_omnibus.bundle_install

        compose(Interactions::Package::Omnibus, inputs.merge(platform: 'ubuntu22', version: sem_version, with_confirmation: false, skip_prepare: true)) if ubuntu22?
        compose(Interactions::Package::Omnibus, inputs.merge(platform: 'centos9', version: sem_version, with_confirmation: false, skip_prepare: true)) if centos9?
        compose(Interactions::Package::Omnibus, inputs.merge(platform: 'ubuntu20', version: sem_version, with_confirmation: false, skip_prepare: true)) if ubuntu20?
        compose(Interactions::Package::Omnibus, inputs.merge(platform: 'centos8', version: sem_version, with_confirmation: false, skip_prepare: true)) if centos8?
        compose(Interactions::Package::Omnibus, inputs.merge(platform: 'centos7', version: sem_version, with_confirmation: false, skip_prepare: true)) if centos7?

        compose(Interactions::Package::Docker, inputs.merge(version: sem_version, with_confirmation: false)) if docker?

        say 'Build complete'
      end

      private

      def ubuntu22?
        all_platforms? || platform == "ubuntu22"
      end

      def ubuntu20?
        all_platforms? || platform == "ubuntu20"
      end

      def centos9?
        # TODO: Enable centos9 support
        return false
        all_platforms? || platform == "centos9"
      end

      def centos8?
        all_platforms? || platform == "centos8"
      end

      def centos7?
        all_platforms? || platform == "centos7"
      end

      def docker?
        all_platforms? || platform == "docker"
      end

      def all_platforms?
        platform == "all"
      end

    end
  end
end
