require 'active_interaction'
require "tty-prompt"

module Interactions

  class Configure < ActiveInteraction::Base


    def execute
      prompt = TTY::Prompt.new

      manifold_repo_name = prompt.ask("What is the name of the Manifold repo?", default: config.fetch(:repo, :name) || "ManifoldScholar/manifold")
      config.set(:repo, :name, value: manifold_repo_name )

      manifold_repo_path = prompt.ask("Where is your Manifold repo located?", default: config.fetch(:repo, :path) || "~/src/manifold")
      config.set(:repo, :path, value: manifold_repo_path )

      manifold_docs_name = prompt.ask("What is the name of the Manifold docs repo?", default: config.fetch(:docs, :name) || "ManifoldScholar/manifold-docs")
      config.set(:docs, :name, value: manifold_docs_name )

      manifold_docs_path = prompt.ask("Where is your Manifold docs repo located?", default: config.fetch(:docs, :path) || "~/src/manifold-docs")
      config.set(:docs, :path, value: manifold_docs_path )

      omnibus_repo_name = prompt.ask("What is the name of the Omnibus repo?", default: config.fetch(:omnibus, :name) || "ManifoldScholar/manifold-omnibus")
      config.set(:omnibus, :name, value: omnibus_repo_name )

      omnibus_repo_name = prompt.ask("Where is your Omnibus repo located?", default: config.fetch(:omnibus, :path) || "~/src/manifold-omnibus")
      config.set(:omnibus, :path, value: omnibus_repo_name )

      github_access_token = prompt.ask("Enter the Github OAuth access token", default: config.fetch(:github, :token))
      config.set(:github, :token, value: github_access_token )

      jenkins_api_url = prompt.ask("Enter the Jenkins API URL", default: config.fetch(:jenkins, :url) || "http://auto:b4919af9f95950c064aebea4d7547439@manifold-jenkins.cicnode.com:8080/job/release")
      config.set(:jenkins, :url, value: jenkins_api_url )

      jenkins_api_token = prompt.ask("Enter the Jenkins API token", default: config.fetch(:jenkins, :token))
      config.set(:jenkins, :token, value: jenkins_api_token )

      manifest_url = prompt.ask("What is the URL of the package manifest", default: config.fetch(:documentation, :manifest_url) || "https://storage.googleapis.com/manifold-dist/manifest.json")
      config.set(:documentation, :manifest_url, value: manifest_url )

      config.write
      config
    end

    private

    def config
      @config ||= Models::Configuration.new
    end

  end

end