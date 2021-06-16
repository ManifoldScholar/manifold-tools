# frozen_string_literal: true

module Models
  module Projects
    class Config
      include Enumerable
      include Models::Concerns::UsesEnvironment

      def initialize(**options)
        super

        @projects = {}.with_indifferent_access
        @projects[:manifold_docs] = Models::Projects::ManifoldDocs.new manifold_docs_path, manifold_docs_repo
        @projects[:manifold_source] = Models::Projects::ManifoldSource.new manifold_source_path, manifold_source_repo
        @projects[:manifold_omnibus] = Models::Projects::ManifoldOmnibus.new manifold_omnibus_path, manifold_omnibus_repo, manifold_source_path: manifold_source_path
        @projects[:manifold_docker] = Models::Projects::ManifoldDocker.new manifold_docker_path, manifold_docker_repo, manifold_source_path: manifold_source_path
        @projects[:manifold_docker_compose] = Models::Projects::ManifoldDockerCompose.new manifold_docker_compose_path, manifold_docker_compose_repo
      end

      def each
        return enum_for(__method__) unless block_given?

        @projects.each_value do |project|
          yield project, project.name
        end

        self
      end

      def manifold_docs
        @projects.fetch __method__
      end

      def manifold_source
        @projects.fetch __method__
      end

      def manifold_omnibus
        @projects.fetch __method__
      end

      def manifold_docker
        @projects.fetch __method__
      end

      def manifold_docker_compose
        @projects.fetch __method__
      end

      attr_lazy_reader :manifold_docs_path do
        File.join(env.repositories_path, 'manifold-docs')
      end

      attr_lazy_reader :manifold_omnibus_path do
        File.join(env.repositories_path, 'manifold-omnibus')
      end

      attr_lazy_reader :manifold_docker_path do
        File.join(env.repositories_path, 'manifold-docker')
      end

      attr_lazy_reader :manifold_docker_compose_path do
        File.join(env.repositories_path, 'manifold-docker-compose')
      end

      attr_lazy_reader :manifold_source_path do
        File.join(env.repositories_path, 'manifold-src')
      end

      attr_lazy_reader :manifold_docs_repo do
        env_fetch(:docs, :name)
      end

      attr_lazy_reader :manifold_docker_repo do
        env_fetch(:docker, :name)
      end

      attr_lazy_reader :manifold_docker_compose_repo do
        env_fetch(:docker_compose, :name)
      end

      attr_lazy_reader :manifold_omnibus_repo do
        env_fetch(:omnibus, :name)
      end

      attr_lazy_reader :manifold_source_repo do
        env_fetch(:repo, :name)
      end
    end
  end
end
