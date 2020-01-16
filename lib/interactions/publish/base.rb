# frozen_string_literal: true

require 'tty-command'

module Interactions
  module Publish
    class Base < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :version, class: 'Models::Version'
      delegate :projects, to: :environment

      def execute
        check_packages unless options[:skip_checks]
        publish
      end

      private

      def check_packages
        if missing_packages?
          warn "Some packages are missing: #{missing_packages.join(', ')}", project
          return if prompt.no? 'Are you sure you want to proceed?'
        else
          say "Found packages for #{version}", project
        end
      end

      def missing_packages
        @missing_packages ||= project.missing_packages(version)
      end

      def missing_packages?
        !missing_packages.empty?
      end

      def publish
        raise NotImplementedError
      end

      def interaction_key
        raise NotImplementedError
      end
    end
  end
end
