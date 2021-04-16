# frozen_string_literal: true

module Models
  module Projects
    class ManifoldDocsDeploy < Base
      def cmd(printer = :pretty)
        TTY::Command.new(printer: printer)
      end

      def deploy
        project_ruby_command "bundle", "exec", "cap", "production", "deploy"
      end
    end
  end
end
