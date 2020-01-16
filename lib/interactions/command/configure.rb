# frozen_string_literal: true

require 'active_interaction'
require 'tty-prompt'

module Interactions
  module Command
    class Configure < ActiveInteraction::Base
      def execute
        prompt = TTY::Prompt.new

        manifold_repo_name = prompt.ask('What is the name of the Manifold repo?', default: config.fetch(:repo, :name) || 'ManifoldScholar/manifold')
        config.set(:repo, :name, value: manifold_repo_name)

        manifold_docs_name = prompt.ask('What is the name of the Manifold docs repo?', default: config.fetch(:docs, :name) || 'ManifoldScholar/manifold-docs')
        config.set(:docs, :name, value: manifold_docs_name)

        omnibus_repo_name = prompt.ask('What is the name of the Omnibus repo?', default: config.fetch(:omnibus, :name) || 'ManifoldScholar/manifold-omnibus')
        config.set(:omnibus, :name, value: omnibus_repo_name)

        docker_repo_name = prompt.ask('What is the name of the Manifold Docker repo?', default: config.fetch(:docker, :name) || 'ManifoldScholar/manifold-docker-build')
        config.set(:docker, :name, value: docker_repo_name)

        docker_compose_repo_name = prompt.ask('What is the name of the Manifold Docker-Compose repo?', default: config.fetch(:docker_compose, :name) || 'ManifoldScholar/manifold-docker-compose')
        config.set(:docker_compose, :name, value: docker_compose_repo_name)

        docs_deploy_repo = prompt.ask('What is the name of the Manifold Documentation Deploy repo?', default: config.fetch(:docs_deploy, :name) || 'ManifoldScholar/manifold-docs-deploy')
        config.set(:docs_deploy, :name, value: docs_deploy_repo)

        github_access_token = prompt.ask('Enter the Github OAuth access token', default: config.fetch(:github, :token))
        config.set(:github, :token, value: github_access_token)

        google_storage_key = prompt.ask('Enter your google cloud storage project id', default: config.fetch(:google_storage, :project_id))
        config.set(:google_storage, :project_id, value: google_storage_key)

        google_storage_credentials = prompt.ask('Enter the path to your google cloud storage credentials', default: config.fetch(:google_storage, :credentials))
        config.set(:google_storage, :credentials, value: google_storage_credentials)

        google_storage_bucket = prompt.ask('Enter the name of the google cloud storage bucket', default: config.fetch(:google_storage, :bucket) || 'manifold-dist')
        config.set(:google_storage, :bucket, value: google_storage_bucket)

        docker_username = prompt.ask('Enter your docker hub username', default: config.fetch(:docker, :username))
        config.set(:docker, :username, value: docker_username)

        docker_password = prompt.ask('Enter your docker hub password', default: config.fetch(:docker, :password))
        config.set(:docker, :password, value: docker_password)

        config.write
        config
      end

      private

      def config
        @config ||= Models::Configuration.new
      end
    end
  end
end
