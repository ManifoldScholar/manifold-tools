module Interactions
  class UpdateManifoldVersion < ActiveInteraction::Base

    object :environment, class: 'Models::Environment'

    object :project, class: 'Models::Projects::Base'

    object :version, class: 'Models::Version'

    delegate :git, to: :project

    delegate :name, to: :project, prefix: true

    def execute
      update_manifold_version_file! if project.manifold_omnibus?

      puts "[#{project_name}] Adding annotated tag #{version}"

      unless git.tags.any? { |t| t.name === version.value }
        git.add_tag version, annotate: true, message: "Release #{version}"
        puts "[#{project_name}] pushing to git"
        git.push('origin', 'master', tags: true)
      else
        puts "[#{project_name}] tag #{version.value} already exists"
      end

    end

    private

    def update_manifold_version_file!

      unless git.tags.any? { |t| t.name === version.value }
        puts "[#{project_name}] Updating MANIFOLD_VERSION file to read #{version}"

        project.manifold_version_file.write version.to_s

        git.add project.manifold_version_relative_path
        git.commit "[C] Update Manifold to #{version}"
      else
        puts "[#{project_name}] tag #{version.value} already exists"
      end
    end
  end
end
