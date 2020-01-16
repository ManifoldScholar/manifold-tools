require "google/cloud/storage"

module Interactions
  module Command
    class Publish < BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      string :version
      delegate :projects, to: :environment
      delegate :manifold_omnibus, to: :projects
      delegate :manifold_docker, to: :projects
      delegate :manifold_docs_deploy, to: :projects

      attr_reader :version

      def execute

        # Define the version and branch
        celebrate "Let's publish #{version}"
        version = Models::Version.new projects.manifold_source.manifold_version_file_current_value
        staging_branch = "build/#{version}"

        # Move each repo into the correct state.
        projects.each do |project|
          compose(Interactions::Project::Prepare, inputs.merge(project: project, version: version))
        end

        # Publish the packages and docker images
        compose(Interactions::Publish::Omnibus, inputs.merge(version: version))
        compose(Interactions::Publish::Docker, inputs.merge(version: version))
        compose(Interactions::Publish::Documentation, inputs.merge(version: version))

        # Update documentation
        compose(Interactions::Publish::Documentation, inputs.merge(version: version))

        # Open PRs for the various projects
        projects.each do |project|
          compose(Interactions::Project::OpenPr, inputs.merge(project: project, version: version))
        end

        # Approve PRS
        urls = pr_urls(staging_branch)
        if urls.count.positive?
          say "Ok, time to approve some PRs"
          urls.each do |url|
            warn url
          end
          say "Go and accept all of those pull requests"
          say "Be sure to rebase the PR on master rather than merge it."
          prompt.keypress("When you've accepted all the PRs, press any key to continue")
        end

        # Deploy the documentation
        say "Now we deploy the documentation."
        if prompt.yes? "Deploy docs?"
          manifold_docs_deploy.gem_install_bundler("1.17.2")
          manifold_docs_deploy.bundle_install
          manifold_docs_deploy.deploy
        end

        # Tag repositories
        say "Great, the repos are all good to go. Time to tag this release."
        return unless prompt.yes? "Ready to tag?"
        projects.each do |project|
          if project.tagged?(version)
            warn "This project has already been tagged at #{version}", project
            warn "Skipping. You'll have to manually fix this."
            next
          end
          say "Returning to master", project
          project.git.branch("master").checkout()
          compose(Git::Fetch, inputs.merge(project: project))
          project.hard_reset("origin/master")
          compose(Git::Tag, inputs.merge(project: project, version: version))
          compose(Git::Push, inputs.merge(project: project, branch: "master"))
        end

      end

      private

      def pr_urls(branch)
        urls = []
        say "Looking for open PRs"
        projects.each do |project|
          url = project.pr_url_for_branch(branch)
          urls << url unless url.blank?
        end
        urls
      end

    end
  end
end
