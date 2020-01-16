module Models::Projects
  class ManifoldDocsDeploy < Base

    def cmd(printer = :pretty)
      TTY::Command.new(printer: printer)
    end

    def deploy
      Dir.chdir(@path){
        cmd.run("bundle exec cap production deploy")
      }
    end

  end
end
