module Models::Projects
  class ManifoldDocs < Base
    attr_lazy_reader :manifest_file do
      path.join "_data/releases.json"
    end

    def manifest_file_relative_path
      manifest_file.relative_path_from(path).to_s
    end

  end
end
