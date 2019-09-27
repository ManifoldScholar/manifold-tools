module Models::Projects
  class ManifoldSource < Base

    def update_changelog(contents)
      File.open(File.join(@path, "CHANGELOG.md"), 'w') { |file| file.write(contents) }
    end

  end
end
