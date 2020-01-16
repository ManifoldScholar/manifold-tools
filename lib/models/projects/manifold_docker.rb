# frozen_string_literal: true

module Models
  module Projects
    class ManifoldDocker < Base
      def cmd(printer = :pretty)
        TTY::Command.new(printer: printer)
      end

      def build(no_overwrite = false)
        Dir.chdir(@path) do
          cmd.run("./exe/manifold_docker build #{no_overwrite ? '--no_overwrite' : ''}")
        end
      end

      def push(version, credentials)
        Dir.chdir(@path) do
          cmd.run("./exe/manifold_docker push #{version}  --password=#{credentials['password']} --username=#{credentials['username']}")
        end
      end

      def exists?(version)
        Dir.chdir(@path) do
          out, err = cmd(:null).run("./exe/manifold_docker check #{version}")
          return JSON.parse(out)
        end
      end

      def clean(version)
        Dir.chdir(@path) do
          out, err = cmd.run("./exe/manifold_docker clean #{version}")
        end
      end

      def missing_packages(version)
        Dir.chdir(@path) do
          out, err = cmd(:null).run("./exe/manifold_docker check #{version} --list-missing")
          return JSON.parse(out)
        end
      end
    end
  end
end
