require "tty-command"

module Models::Projects
  class ManifoldSource < Base

    def update_changelog(contents)
      File.open(File.join(@path, "CHANGELOG.md"), 'w') { |file| file.write(contents) }
    end

    def build_client
      Dir.chdir(File.join(@path, "client").to_s){
        cmd = TTY::Command.new
        cmd.run("yarn install")
        return cmd.run("yarn build")
      }
    end

  end
end
