module Interactions
  module Check
    class ProjectDirty < Interactions::BaseInteraction

      DIRTY_CHECK = "Is the working tree dirty?".freeze
      DIRTY_ERROR = "Working tree is dirty".freeze
      PROMPT_STASH = "The %s tree is dirty. Would you like me to stash changes?".freeze

      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :project, class: "Models::Projects::Base"

      delegate :projects, to: :environment
      delegate :name, to: :project, prefix: true

      def execute
        add_dirty_error && return if dirty?
        say "Working tree is not dirty.", project
        dirty?
      end

      private

      def dirty?
        dirty = project.working_tree_dirty?
        return dirty? if dirty && prompt_to_stash && stash
        return dirty
      end

      def stash
        compose Interactions::Git::Stash, inputs
      end

      def add_dirty_error
        errors.add(project_name, DIRTY_ERROR)
      end

      def prompt_to_stash
        prompt.yes?(PROMPT_STASH % [project.name])
      end

    end
  end
end
