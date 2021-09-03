# frozen_string_literal: true

module Models
  module Projects
    class ManifoldDocs < Base
      attr_lazy_reader :manifest_file do
        path.join 'releases.json'
      end

      attr_lazy_reader :current_file do
        path.join 'current.json'
      end

      def manifest_file_relative_path
        manifest_file.relative_path_from(path).to_s
      end
    end
  end
end
