# frozen_string_literal: true

module Interactions
  module Project
    class Prepare < BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'
      object :version, class: 'Models::Version'

      delegate :projects, to: :environment
      delegate :manifold_source, to: :projects

      PROMPT_STASH = 'The %s tree is dirty. Would you like me to stash changes?'

      def execute
        cmd = TTY::Command.new(printer: :pretty)

        # Ensure repo is present and good to go.
        compose(Git::Clone, inputs.merge(project: project))
        compose(Git::Fetch, inputs.merge(project: project))

        tag = version.to_s
        tag_exists = project.tagged?(tag)
        release_branch = "origin/#{release_branch_for(project)}"
        release_branch_exists = project.branch?(release_branch)
        staging_branch = "build/#{version}"
        staging_branch_exists = project.branch?(staging_branch)
        in_staging_branch = project.in_branch?(staging_branch)
        remote_staging_branch_exists = project.branch?("origin/#{staging_branch}")
        dirty = project.working_tree_dirty?

        say 'Preparing repository for build', project
        say "Base branch for release is #{release_branch}", project
        say "Staging branch is #{staging_branch}", project
        say "Staging branch #{staging_branch_exists ? 'exists ' : 'does not exist'}.", project
        say "Current branch is #{in_staging_branch ? '' : 'not '}staging branch.", project
        say "Current branch is #{dirty ? '' : 'not '} dirty.", project

        # Give the option to stash if dirty
        prompt_stash unless in_staging_branch || !dirty
        project.git.branch(staging_branch).checkout

        # Compare to release and upstream staging branch and give options as needed.
        compare_against_branch(staging_branch, release_branch)
        compare_against_branch(staging_branch, "origin/#{staging_branch}") if remote_staging_branch_exists

        # Get the version file right.
        if project.manifold_version_file_current_value == tag
          # Manifold version file is already correct.
          say 'Manifold version file is already current.', project
        else
          say "Manifold version file needs to be updated (currently #{project.manifold_version_file_current_value})", project
          compose(Interactions::Build::VersionFile, inputs.merge(project: project, version: version))
          if project == projects.manifold_source
            say 'Project is manifold_source. Building client and changelog.', project
            compose(Interactions::Build::Client, inputs)
            # compose(Interactions::Build::Changelog, inputs.merge(unreleased_version: version, refresh: true))
          end
        end
      end

      private

      def compare_against_branch(staging_branch, other_branch)
        say "Comparing #{staging_branch} to #{other_branch}", project

        ahead = project.count_commits_ahead(staging_branch, other_branch)
        behind = project.count_commits_behind(staging_branch, other_branch)

        if ahead.positive? || ahead.zero?
          word = ahead == 1 ? 'commit' : 'commits'
          say "Staging branch is #{ahead} #{word} ahead of #{other_branch}", project
        end

        return unless behind.positive?

        word = behind == 1 ? 'commit' : 'commits'
        say "Staging branch is #{behind} #{word} behind #{other_branch}", project
        choice = prompt.select('How would you like to handle this?') do |menu|
          menu.choice "Hard reset the branch to #{other_branch}.", :reset
          menu.choice "Rebase the branch to #{other_branch}.", :rebase
          menu.choice 'Do nothing. Release as-is.', :nothing
        end
        hard_reset(other_branch) if choice == :reset
        rebase(other_branch) if choice == :rebase
      end

      def hard_reset(branch)
        compose Interactions::Git::HardReset, inputs.merge(branch: branch)
      end

      def rebase(branch)
        compose Interactions::Git::HardReset, inputs.merge(branch: branch)
      end

      def prompt_stash
        project.working_tree_status
        compose Interactions::Git::Stash, inputs if prompt.yes?(format(PROMPT_STASH, project.name))
      end

      def release_branch_for(project)
        project.name == manifold_source.name ? options[:branch] || 'master' : 'master'
      end
    end
  end
end
