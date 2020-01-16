# frozen_string_literal: true

module Interactions
  module Command
    class Package < BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      string :platform

      delegate :projects, to: :environment

      def execute
        version = Models::Version.new projects.manifold_source.manifold_version_file_current_value
        puts version
        return compose(Interactions::Package::Docker, inputs.merge(version: version)) if platform == 'docker'

        compose(Interactions::Package::Omnibus, inputs.merge(version: version))
      end
    end
  end
end
