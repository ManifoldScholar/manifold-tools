# frozen_string_literal: true

module Interactions
  module Git
    class Tag < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'
      object :version, class: 'Models::Version'

      def execute
        say "Tagging #{project.name}: #{version}", project
        if options.noop
          whisper '...skipping tagging due to --noop flag', project
        elsif project.git.tags.any? { |t| t.name == version.value }
          say "[#{project_name}] tag #{version.value} already exists", project
        else
          project.git.add_tag version, annotate: true, message: version.to_s
        end
      rescue ::Git::GitExecuteError => e
        errors.add('git:tag', e)
      end
    end
  end
end
