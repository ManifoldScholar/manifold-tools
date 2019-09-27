module Models::Projects
  class Config
    include Enumerable
    include Models::Concerns::UsesEnvironment

    def initialize(**options)
      super

      @projects = {}.with_indifferent_access
      @projects[:manifold_docs] = Models::Projects::ManifoldDocs.new manifold_docs_path, manifold_docs_repo
      @projects[:manifold_source] = Models::Projects::ManifoldSource.new manifold_source_path, manifold_source_repo
      @projects[:manifold_omnibus] = Models::Projects::ManifoldOmnibus.new manifold_omnibus_path, manifold_omnibus_repo
    end

    def each
      return enum_for(__method__) unless block_given?

      @projects.each_value do |project|
        yield project, project.name
      end

      return self
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

    attr_lazy_reader :manifold_docs_path do
      File.expand_path env_fetch(:docs, :path)
    end

    attr_lazy_reader :manifold_docs_repo do
      File.expand_path env_fetch(:docs, :name)
    end

    attr_lazy_reader :manifold_omnibus_path do
      File.expand_path env_fetch(:omnibus, :path)
    end

    attr_lazy_reader :manifold_source_path do
      File.expand_path env_fetch(:repo, :path)
    end

    attr_lazy_reader :manifold_omnibus_repo do
      env_fetch(:omnibus, :name)
    end

    attr_lazy_reader :manifold_source_repo do
      env_fetch(:repo, :name)
    end

  end
end
