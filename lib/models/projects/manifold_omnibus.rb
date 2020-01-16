# frozen_string_literal: true

module Models
  module Projects
    class ManifoldOmnibus < Base
      def cmd(printer = :null)
        TTY::Command.new(printer: printer)
      end

      def all_packages
        Dir.chdir(@path) do
          out, err = cmd.run('bundle exec rake packages:list')
          return JSON.parse(out)
        end
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
        return "manifold_#{version.to_semantic_string.gsub!('-', '~')}-1_amd64.deb" if platform.start_with?('ubuntu')
        return "manifold-#{version.to_semantic_string.gsub!('-', '~')}-1.el7.x86_64.rpm" if platform.start_with?('centos')

        raise "Not implemented in generate_package_filename for #{platform}"
      end

      def package_exists?(platform, version)
        existing = all_packages
        return false unless existing[platform].is_a? Array

        existing[platform].include? generate_package_filename(platform, version)
      end

      def valid_platforms
        Dir.chdir(@path) do
          out, err = cmd.run('bundle exec rake introspection:platforms')
          return JSON.parse(out).reject { |p| p == 'macos' }
        end
      end

      def machine_up(machine)
        Dir.chdir(@path) do
          return cmd(:quiet).run("vagrant up #{machine}")
        end
      end

      def machine_down(machine)
        Dir.chdir(@path) do
          return cmd(:quiet).run("vagrant suspend #{machine}")
        end
      end

      def build(platform)
        Dir.chdir(@path) do
          cmd(:quiet).run("bundle exec rake build:#{platform}")
        end
      end

      def install(platform, version)
        Dir.chdir(@path) do
          package_file = generate_package_filename(platform, version)
          cmd(:quiet).run("bundle exec rake install:#{platform}[#{package_file}]")
        end
      end

      def missing_packages(version)
        valid_platforms.reject do |platform|
          package_exists? platform, version
        end
      end
    end
  end
end
