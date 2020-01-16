require "tty-command"

module Interactions
  module Publish
    class Omnibus < Base

      private

      def publish
        say "Begin publishing..."

        storage_changed = publish_to_google_cloud_storage
        publish_packages_manifest if storage_changed || options["regenerate_manifest"]
      end

      def publish_to_google_cloud_storage
        storage_changed = false
        project.valid_platforms.each do |platform|

          # Skip missing packages
          unless project.package_exists? platform, version
            say "Package for #{platform} is missing. Skipping."
            next
          end

          from = project.package_path(platform, version)
          to = storage_path(platform)
          metadata_from = project.metadata_path(platform, version)
          metadata_to = metadata_storage_path(platform)

          do_upload = false

          if storage_package_exists?(platform)
            say "Package #{to} exists in google cloud storage."
            unless options[:no_overwrite]
              do_upload = true unless prompt.no? "Do you want to overwrite it?"
            end
          else
            do_upload = true
          end

          if do_upload
            say "Uploading #{from} to #{bucket_name}://#{to}"
            say "Be patient. Grab some tea. This could take a bit."
            bucket.create_file from, to
            say "Uploading #{metadata_from} to #{bucket_name}://#{metadata_to}"
            bucket.create_file metadata_from, metadata_to
            stored_package = storage_package(platform)
            stored_metadata = storage_metadata(platform)
            say "Setting package ACL to public"
            stored_package.acl.public!
            say "Setting package metadata ACL to public"
            stored_metadata.acl.public!
            storage_changed = true
          end

        end
        return storage_changed
      end

      def publish_packages_manifest
        say "Publishing packages manifest to google cloud storage..."
        files = bucket.files
        manifest = {}
        files.each do |file|
          full = file.name
          comp = File.basename full        # => "xyz.mp4"
          extn = File.extname  full        # => ".mp4"
          name = File.basename full, extn  # => "xyz"
          path = File.dirname  full        # => "/path/to"
          if comp.end_with? "metadata.json"
            say "Found metadata at #{full}. Parsing metadata."
            metadata_pointer = file.download
            metadata_pointer.rewind
            metadata = JSON.parse(metadata_pointer.read)
            manifest[path] = {} unless manifest.key? path
            details = {
                "build_version" => metadata["version"],
                "build_git_revision" => metadata["version_manifest"]["build_git_revision"],
                "basename" => metadata["basename"],
                "sha1" => metadata["sha1"],
                "sha256" => metadata["sha256"],
                "sha512" => metadata["sha512"],
                "platform" => metadata["platform"],
                "platform_version" => metadata["platform_version"],
                "arch" => metadata["arch"],
                "url" => file.url.sub(".metadata.json", "")
            }
            manifest[path][metadata["version"]] = details
          end
        end
        json =  JSON.generate(manifest)
        file = bucket.file "manifest.json"
        if file && file.exists?
          say "Manifest exists. Deleting."
          file.delete
        end
        say "Writing new manifest file."
        manifest_file = bucket.create_file StringIO.new(json), "manifest.json"
        manifest_file.acl.public!
        celebrate "Packages manifest file has been successfully updated."

      end

      def storage
        config = environment.fetch(:google_storage)
        storage = Google::Cloud::Storage.new(
            project_id: environment.fetch(:google_storage, :project_id),
            credentials: environment.fetch(:google_storage, :credentials)
        )
      end

      def storage_package(platform)
        bucket.file storage_path(platform)
      end

      def storage_metadata(platform)
        bucket.file metadata_storage_path(platform)
      end

      def storage_package_exists?(platform)
        file = storage_package(platform)
        return file && file.exists?
      end

      def storage_path(platform)
        "#{platform}/#{filename(platform)}"
      end

      def metadata_storage_path(platform)
        "#{storage_path(platform)}.metadata.json"
      end

      def filename(platform)
        project.generate_package_filename(platform, version)
      end

      def bucket_name
        environment.fetch(:google_storage, :bucket)
      end

      def bucket
        storage.bucket bucket_name
      end

      def interaction_key
        [:publish_omnibus]
      end

      def project
        projects.manifold_omnibus
      end

    end
  end
end