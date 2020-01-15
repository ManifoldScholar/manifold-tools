module Interactions
  module Command
    class Build < BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"

      delegate :projects, to: :environment

      attr_accessor :version

      def execute

        # Ensure all repos are present and good to go.
        projects.each do |project|
          compose(Git::Clone, inputs.merge(project: project))
          compose(Git::Fetch, inputs.merge(project: project))
        end

        # Initial checks
        celebrate "Initial checks pass."

        # Prompt for the new version
        version = compose(Prompt::Version, inputs)

        # Move each repo into the correct state.
        projects.each do |project|

          tag = version.to_s
          tag_exists = project.tagged?(tag)
          release_branch = release_branch_for(project)
          release_branch_exists = project.branch?(release_branch)
          staging_branch = "build/#{version}"
          staging_branch_exists = project.branch?(staging_branch)
          in_staging_branch = project.in_branch?(staging_branch)
          dirty = project.working_tree_dirty?

          say "Preparing repository for build", project
          say "Staging branch is #{staging_branch}", project

          # Get in the staging branch
          if staging_branch_exists
            say "Staging branch exists", project
            if in_staging_branch
              say "Already in staging branch", project
            else
              say "Not in staging branch. Checking out staging branch.", project
              project.git.branch(staging_branch).checkout()
            end
          else
            say "Staging branch does not exist. Creating staging branch.", project
            project.git.branch(staging_branch).checkout()
          end

          # Reset it to the correct tag or branch
          if tag_exists
            say "Tag exists. Attempting to reset branch to tag.", project
            # Deal with a dirty repository
            if dirty
              say "The repository is dirty", project
              if options[:development]
                warn "Leaving repository as is, as the development flag is set.", project
              else
                compose(Check::ProjectDirty, inputs.merge(project: project))
              end
            end
            # Checkout
            project.git.reset_hard(tag)
          else
            # Tag does not exist. Reset to the build branch
            if dirty
              say "The repository is dirty", project
              if options[:development]
                warn "Leaving repository as is, as the development flag is set.", project
              else
                if compose(Check::ProjectDirty, inputs.merge(project: project))
                  say "Hard resetting to release branch.", project
                  project.git.reset_hard("origin/#{release_branch}")
                end
              end
            else
              say "The repository is not dirty. Hard resetting to release branch.", project
              project.git.reset_hard("origin/#{release_branch}")
            end
          end

          if project.manifold_version_file_current_value == tag
            # Manifold version file is already correct.
            say "Manifold version file is already current.", project
          else
            say "Manifold version file needs to be updated (currently #{project.manifold_version_file_current_value})", project
            compose(Interactions::Build::VersionFile, inputs.merge(project: project, version: version))
            if project == projects.manifold_source
              say "Project is manifold_source. Building client and changelog.", project
              compose(Interactions::Build::Client, inputs)
              compose(Interactions::Build::Changelog, inputs.merge(unreleased_version: version))
            end
          end
        end

        # Do the packaging.
        projects.manifold_omnibus.gem_install_bundler("1.17.2")
        projects.manifold_omnibus.bundle_install
        compose(Interactions::Package::Omnibus, inputs.merge(platform: "ubuntu16", version: version, with_confirmation: false, skip_prepare: true))
        compose(Interactions::Package::Omnibus, inputs.merge(platform: "ubuntu18", version: version, with_confirmation: false, skip_prepare: true))
        compose(Interactions::Package::Omnibus, inputs.merge(platform: "centos7", version: version, with_confirmation: false, skip_prepare: true))
        compose(Interactions::Package::Docker, inputs.merge(version: version, with_confirmation: false))

        say "Build complete"

      end

      private

      def release_branch_for(project)
        project == projects.manifold_source ? options[:branch] : "master"
      end

    end
  end
end
