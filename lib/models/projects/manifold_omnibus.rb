# frozen_string_literal: true

module Models
  module Projects
    class ManifoldOmnibus < Base
      def cmd(printer = :null)
        TTY::Command.new(printer: printer)
      end

      def pkg_dir_path
        File.join(@path, 'pkg')
      end

      def package_path(platform, version)
        File.join(pkg_dir_path, platform, generate_package_filename(platform, version))
      end

      def metadata_path(platform, version)
        filename = "#{generate_package_filename(platform, version)}.metadata.json"
        File.join(pkg_dir_path, platform, filename)
      end

      def destroy_package(platform, version)
        raise 'invalid platform' unless platform && !platform.empty?
        raise 'invalid version' unless version && !version.to_semantic_string.empty?

        package = package_path(platform, version)
        metadata = metadata_path(platform, version)
        TTY::Command.new.run("rm #{package}") if File.exist?(package)
        TTY::Command.new.run("rm #{metadata}") if File.exist?(metadata)
      end

      def generate_package_filename(platform, version)
        return "manifold_#{version.to_semantic_string.gsub('-', '~')}-1_amd64.deb" if platform.start_with?('ubuntu')
        return "manifold-#{version.to_semantic_string.gsub('-', '~')}-1.el7.x86_64.rpm" if platform.start_with?('centos')

        raise "Not implemented in generate_package_filename for #{platform}"
      end

      def package_exists?(platform, version)
        existing = all_packages
        return false unless existing[platform].is_a? Array

        existing[platform].include? generate_package_filename(platform, version)
      end

      def valid_platforms
        rake_cmd("introspection:platforms").reject { |p| p == "macos" }
      end

      def machine_up(machine)
        return cmd(:quiet).run("vagrant up #{machine}", chdir: @path)
      end

      def machine_down(machine)
        return cmd(:quiet).run("vagrant halt #{machine}", chdir: @path)
      end

      def build(platform)
        rake_cmd "build:#{platform}", printer: :quiet
      end

      def install(platform, version)
        package_file = generate_package_filename(platform, version)

        rake_cmd("install:#{platform}[#{package_file}]", printer: :quiet)
      end

      def missing_packages(version)
        valid_platforms.reject do |platform|
          package_exists? platform, version
        end
      end

      def all_packages
        rake_cmd "packages:list"
      end

      def rake_cmd(*args, printer: :null, output_json: true)
        JSON.parse project_ruby_command("bin/rake", *args)
      end
    end
  end
end
