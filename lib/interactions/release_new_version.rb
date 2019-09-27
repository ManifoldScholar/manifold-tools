require "active_interaction"
require "tty-prompt"

module Interactions

  class ReleaseNewVersion < ActiveInteraction::Base
    object :environment, class: 'Models::Environment'

    array :args, default: proc { [] } do
      string
    end

    object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"

    delegate :jenkins, :projects, to: :environment

    delegate :build!, to: :jenkins, prefix: true

    delegate :manifold_source, :manifold_omnibus, to: :projects

    def execute
      @version = wait_for_version

      puts "Going to release #{version}, previously tagged versions:\n"

      projects.each do |project|
        puts "\t* #{project.name}: #{project.current_version}"
      end

      print "\n"

      correct = prompt.yes? "Does this look correct? "

      unless correct
        errors.add :base, "Okay, bailing early"

        return
      end


      compose(Interactions::UpdateManifoldVersion,
              project: projects.manifold_source,
              environment: environment,
              version: version)
      compose(Interactions::UpdateManifoldVersion,
              project: projects.manifold_omnibus,
              environment: environment,
              version: version)

      build_with_jenkins = options.jenkins || prompt.yes?("Build on Jenkins? ")

      if build_with_jenkins
        result = jenkins_build! version

        if result != "201"
          errors.add :base, "Got unexpected result from jenkins build: #{result} (expected 201). Check jenkins"

          return
        end
      else
        warn "Skipping jenkins build"
      end

    end

    attr_reader :version

    private

    def wait_for_version
      provided = args.first

      loop do
        version = try_parsing provided

        break version if version.present?


        provided = prompt.ask("Specify the version: ")
      end
    end

    def prompt
      @prompt ||= TTY::Prompt.new
    end

    def try_parsing(provided_version)
      return nil unless provided_version.present?

      Models::Version.new provided_version
    rescue ArgumentError => e
      warn "Could not parse '#{provided_version}': #{e.message}"

      return nil
    end
  end
end
