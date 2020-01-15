require "tty-command"

module Interactions
  module Package
    class Docker < Base
      object :environment, class: 'Models::Environment'
      object :version, class: 'Models::Version'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      boolean :with_confirmation, default: true
      boolean :with_checks, default: true
      delegate :projects, to: :environment
      delegate :manifold_docker, to: :projects

      private

      def build
        say "Rsyncing Manifold source into manifold-docker directory"
        manifold_docker.rsync_manifold_src
        manifold_docker.build(options[:no_overwrite])
      end

      def prepare
        say "Installing omnibus gem dependencies"
        manifold_docker.gem_install_bundler("1.17.2")
        manifold_docker.bundle_install
      end

      def package_exists?(platform, version)
        manifold_docker.exists?(version)
      end

      def package_name(platform, version)
        "Manifold docker images #{version.to_s}"
      end

      def destroy_package(platform, version)
        manifold_docker.clean(version)
      end

      def valid_platforms
        [platform]
      end

      def interaction_key
        [:package_docker]
      end

      def platform
        "docker"
      end

    end
  end
end