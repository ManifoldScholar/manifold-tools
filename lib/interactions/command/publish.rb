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

      attr_reader :version

      def execute
        celebrate "Let's publish #{version}"
        version = Models::Version.new projects.manifold_source.manifold_version_file_current_value

        # Publish the packages and docker images
        compose(Interactions::Publish::Omnibus, inputs.merge(version: version))
        compose(Interactions::Publish::Docker, inputs.merge(version: version))

        # Open PRs for the various projects
        projects.each do |project|
          tag = version.to_s
          staging_branch = "build/#{version}"
          in_staging_branch = project.in_branch?(staging_branch)
          dirty = project.working_tree_dirty?
          msg = "[F] Release #{version}"
          raise "Not in staging branch" unless in_staging_branch
          compose(Git::Commit, inputs.merge(project: project, message: msg)) if dirty
          compose(Git::Push, inputs.merge(project: project, branch: staging_branch))
          if project.pr_exists?(msg)
            warn "PR already exists for #{msg}"
            warn "Not opening a new PR."
          else
            project.open_pull_request(msg)
          end
        end

      end

    end
  end
end
