require "active_interaction"
require "tty-prompt"
require "tty-table"

module Interactions
  module Prompt

    class Version < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      delegate :projects, to: :environment

      def execute
        @version = wait_for_version
        say "Going to release #{version}."
        confirmation = options.key?(:version) ? true : wait_for_confirmation
        return bailout unless confirmation
        return version
      end

      attr_reader :version

      private

      def bailout
        errors.add :base, "Okay, bailing early"
        return
      end

      def previous_versions
        @previous_versions ||= projects.map { |project| project.manifold_version_file_current_value }
      end

      def highest_previous_version
        previous_versions.max { |a, b| a.semantic <=> b.semantic }
      end

      def default_next_version
        return highest_previous_version.semantic.major!.to_s if options.major
        return highest_previous_version.semantic.minor!.to_s if options.minor
        highest_previous_version.semantic.patch!.to_s
      end

      def wait_for_version
        provided = options.version
        loop do
          version = try_parsing provided
          break version if version.present?
          provided = prompt.ask("What version do you want to release? ", default: default_next_version)
        end
      end

      def wait_for_confirmation
        prompt.yes? "Does this look correct? "
      end

      def try_parsing(provided_version)
        return nil unless provided_version.present?

        Models::Version.new provided_version
      rescue ArgumentError => e
        warn "Could not parse '#{provided_version}': #{e.message}"

        return nil
      end
    end
  end
end
