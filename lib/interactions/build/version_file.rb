module Interactions
  module Build
    class VersionFile < Interactions::BaseInteraction
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :project, class: "Models::Projects::Base"
      object :version, class: "Models::Version"

      def execute
        say "Updating MANIFOLD_VERSION file to read #{version}", project
        if options.noop
          whisper "...skipping writing MANIFOLD_VERSION file due to --noop flag", project
        else
          project.manifold_version_file.write version.to_s
        end
      end

    end
  end
end
