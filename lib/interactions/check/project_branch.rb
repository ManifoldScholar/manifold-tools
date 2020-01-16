# frozen_string_literal: true

require 'tty-command'

module Interactions
  module Check
    class ProjectBranch < Interactions::BaseInteraction
      BRANCH_CHECK = 'Are we in the %s branch?'
      BRANCH_ERROR = 'Not in %s branch'
      PROMPT_SWITCH_BRANCH = '%s is not in the %s branch. May I switch to %s'

      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'
      string :branch

      delegate :projects, to: :environment
      delegate :name, to: :project, prefix: true

      def execute
        add_wrong_branch_error && return unless correct_branch?
        say "Correct branch: #{branch}", project
      end

      private

      def correct_branch?
        in_wrong_branch = project.not_in_branch?(branch)
        return correct_branch? if in_wrong_branch && prompt_checkout && checkout

        !in_wrong_branch
      end

      def add_wrong_branch_error
        errors.add(project_name, format(BRANCH_ERROR, branch))
      end

      def checkout
        compose Interactions::Git::Checkout, inputs.merge(branch: branch)
      end

      def prompt_checkout
        prompt.yes?(format(PROMPT_SWITCH_BRANCH, project.name, branch, branch))
      end
    end
  end
end
