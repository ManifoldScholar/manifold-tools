require "tty-command"

module Interactions
  module Publish
    class Docker < Base

      private

      def publish
        say "Begin publishing..."

        publish_docker_images
      end

      def publish_docker_images
        cmd = TTY::Command.new(printer: :pretty)

        exe = "docker login -u #{environment.fetch(:docker, :username)} -p #{environment.fetch(:docker, :password)}"
        out, err = cmd.run(exe)

        image_names.each do |image|
          name = versioned_image(image, version)

          puts "Checking if image exists..."
          exe = "docker pull #{name}  > /dev/null && echo \"present\" || echo \"absent\""
          out, err = cmd.run(exe)
          if out.strip == "absent" || (!options[:no_overwrite] && !prompt.no?("Image already exists. Overwrite?"))
            puts "Pushing image #{name}"
            exe = "docker push #{name}"
            out, err = cmd.run(exe)
          end
        end
      end

      def image_names
        dirs = Pathname.new(File.join(project.path, "dockerfiles")).children.select { |c| c.directory? }
        images = dirs.map { |d| File.basename(d) }
        images.rotate(images.find_index("manifold_api_base"))
      end

      def versioned_image(image, the_version = default_version)
        "manifoldscholar/#{image}:#{the_version}"
      end

      def interaction_key
        [:publish_docker]
      end

      def project
        projects.manifold_docker
      end

    end
  end
end