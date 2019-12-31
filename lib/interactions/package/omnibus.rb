require "tty-command"

module Interactions
  module Package
    class Omnibus < Base
      object :environment, class: 'Models::Environment'
      object :version, class: 'Models::Version'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      boolean :with_confirmation, default: true
      boolean :with_checks, default: true
      string :platform

      delegate :projects, to: :environment
      delegate :manifold_omnibus, to: :projects

      private

      def build
        say "Installing omnibus gem dependencies"
        manifold_omnibus.bundle_install
        say "Rsyncing Manifold source into manifold-omnibus directory"
        manifold_omnibus.rsync_manifold_src
        say "Bringing up the builder"
        manifold_omnibus.machine_up("#{platform}-builder")
        manifold_omnibus.build(platform)
        manifold_omnibus.machine_down("#{platform}-builder")
      end

      def package_exists?(platform, version)
        manifold_omnibus.package_exists?(platform, version)
      end

      def destroy_package(platform, version)
        manifold_omnibus.destroy_package(platform, @version)
      end

      def package_name(platform, version)
        "#{platform}/#{manifold_omnibus.generate_package_filename(platform, @version)}"
      end

      def valid_platforms
        manifold_omnibus.valid_platforms
      end

      def interaction_key
        :package_omnibus
      end


    end
  end
end
