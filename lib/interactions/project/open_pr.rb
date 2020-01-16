# frozen_string_literal: true

module Interactions
  module Project
    class OpenPr < BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'
      object :version, class: 'Models::Version'

      delegate :projects, to: :environment
      delegate :manifold_source, to: :projects

      def execute
        dirty = project.working_tree_dirty?
        staging_branch = "build/#{version}"

        msg = "[F] Release #{version}"

        if dirty
          say "Committing with message: #{msg}", project
          if msg == project.last_commit_message(staging_branch)
            compose(Git::Commit, inputs.merge(project: project, message: msg, amend: true))
          else
            compose(Git::Commit, inputs.merge(project: project, message: msg))
          end
        end

        if msg == project.last_commit_message('origin/master')
          warn 'Looks like the staging branch has already been merged to master.', project
          warn 'Skipping opening a PR.', project
          return
        end

        compose(Git::Push, inputs.merge(project: project, branch: staging_branch))
        if project.open_pr_for_branch?(staging_branch)
          warn "PR already exists for #{msg}", project
          warn 'Not opening a new PR.', project
        else
          say "Opening a PR for #{msg}", project
          project.open_pull_request(msg)
        end
      end
    end
  end
end
