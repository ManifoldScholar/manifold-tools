# frozen_string_literal: true

require 'tty-command'

module Models
  module Projects
    class ManifoldSource < Base
      def update_changelog(contents)
        File.open(File.join(@path, 'CHANGELOG.md'), 'w') { |file| file.write(contents) }
      end

      def build_client
        Dir.chdir(File.join(@path, 'client').to_s)  do
          cmd = TTY::Command.new
          cmd.run('yarn install')
          return cmd.run('yarn build')
        end
      end
    end
  end
end
