module Interactions
  module Git
    class Tag < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :project, class: "Models::Projects::Base"
      object :version, class: "Models::Version"

      def execute
        say "Tagging #{project.name}: #{version}", project
        unless options.noop
          unless project.git.tags.any? { |t| t.name === version.value }
            project.git.add_tag version, annotate: true, message: version.to_s
          else
            say "[#{project_name}] tag #{version.value} already exists", project
          end
        else
          whisper "...skipping tagging due to --noop flag", project
        end
      rescue ::Git::GitExecuteError => e
        errors.add("git:tag", e)
      end


    end
  end
end
