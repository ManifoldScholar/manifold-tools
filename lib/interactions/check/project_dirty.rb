# frozen_string_literal: true

module Interactions
  module Check
    class ProjectDirty < Interactions::BaseInteraction
      DIRTY_CHECK = 'Is the working tree dirty?'
      DIRTY_ERROR = 'Working tree is dirty'
      PROMPT_STASH = 'The %s tree is dirty. Would you like me to stash changes?'

      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'

      delegate :projects, to: :environment
      delegate :name, to: :project, prefix: true

      def execute
        add_dirty_error && return if dirty?
        say 'Working tree is not dirty.', project
        dirty?
      end

      private

      def dirty?
        dirty = project.working_tree_dirty?
        return dirty? if dirty && prompt_to_stash && stash

        dirty
      end

      def stash
        compose Interactions::Git::Stash, inputs
        # TODO: we really need to make the release branch look like master (after fetching master)
      end

      def add_dirty_error
        errors.add(project_name, DIRTY_ERROR)
      end

      def prompt_to_stash
        prompt.yes?(format(PROMPT_STASH, project.name))
      end
    end
  end
end
