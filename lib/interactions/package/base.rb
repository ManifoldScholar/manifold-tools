require "tty-command"

module Interactions
  module Package
    class Base < Interactions::BaseInteraction

      def execute
        prepare
        say "Packaging for #{platform}"
        if with_checks
          checks_passed = run_checks
        end
        return unless checks_passed && errors.empty?
        confirmed = request_confirmation if with_confirmation
        return if !confirmed && with_confirmation
        build if errors.empty?
      end

      private

      def prepare
      end

      def build
        raise NotImplementedError
      end

      def package_exists?(platform, version)
        raise NotImplementedError
      end

      def package_name(platform, version)
        raise NotImplementedError
      end

      def destroy_package(platform, version)
        raise NotImplementedError
      end

      def valid_platforms
        raise NotImplementedError
      end

      def interaction_key
        raise NotImplementedError
      end

      def run_checks
        return false unless check_versions_match
        return false unless check_valid_platform
        return false unless check_package_exists
        true
      end

      def check_valid_platform
        say "Ensuring requested platform is a platform I can build..."
        valid = valid_platforms.include? platform
        say "#{platform} is a valid platform." if valid
        errors.add(interaction_key, "Aborting build. The requested platform is not valid") unless valid
        valid
      end

      def check_package_exists
        say "Checking if the package already exists..."
        exists = package_exists?(platform, @version)
        if exists
          warn "Package already exists: #{package_name(platform, @version)}"
          if options[:no_overwrite]
            choice = :continue
          else
            choice = prompt.select("We can't proceed with the build unless we delete this package. What would you like to do?") do |menu|
              menu.choice "Skip build and continue.", :continue
              menu.choice "Delete existing package and build.", :delete
              menu.choice "Exit immediately.", :exit
            end
          end
          if choice == :delete
            destroy_package(platform, version)
            return true
          end
          if choice == :exit
            errors.add(interaction_key, "Aborting build. The package already exists.")
            return false
          end
          if choice == :continue
            return false
          end
        else
          say "Package does not exist: #{package_name(platform, @version)}"
          return true
        end
      end

      def check_versions_match
        return true if all_versions_match?
        errors.add(interaction_key, "Aborting build. All MANIFOLD_VERSION files should match")
        false
      end

      def request_confirmation
        say "Ok, we're ready to build #{@version} for #{platform}"
        prompt.yes?('Are you ready to begin the build process?')
      end

      def all_versions_match?
        if options[:development]
          say "Development flag is set to true. Skipping all_versions_match? check"
          return true
        end
        say "Ensuring that all repository versions are equal..."
        versions = projects.map { |p| p.manifold_version_file_current_value }
        match = versions.uniq.count == 1
        say "All repositories at #{versions.first}." if match
        match
      end

    end
  end
end