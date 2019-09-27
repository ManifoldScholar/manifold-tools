require "active_interaction"
require "json"

module Interactions
  class PublishDocumentation < ActiveInteraction::Base

    object :environment, class: 'Models::Environment'

    delegate :projects, to: :environment
    delegate :name, to: :project, prefix: true
    delegate :manifold_docs, to: :projects
    delegate :git, to: :manifold_docs

    def execute

      manifest = Net::HTTP.get(URI.parse(environment.fetch(:documentation, :manifest_url)))
      parsed = JSON.parse(manifest)
      pretty_manifest = JSON.pretty_generate(parsed)
      manifold_docs.manifest_file.write pretty_manifest

      if git.status.changed?(manifold_docs.manifest_file_relative_path)
        git.add manifold_docs.manifest_file_relative_path
        git.commit "[C] Update package manifest data"
        puts "[#{manifold_docs.name}] pushing to git"
        git.push('origin', 'master', tags: true)
      end
    end
  end
end
