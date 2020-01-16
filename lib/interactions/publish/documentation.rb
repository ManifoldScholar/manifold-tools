require "tty-command"

module Interactions
  module Publish
    class Documentation < Interactions::BaseInteraction

      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      object :version, class: 'Models::Version'
      delegate :projects, to: :environment
      delegate :manifold_docs, to: :projects

      def execute
        say "Fetching Omnibus package manifest", manifold_docs
        manifest = Net::HTTP.get(URI.parse("#{environment.manifest_url}?cachebuster=#{Time.now.to_i}"))

        say "Parsing manifest", manifold_docs
        parsed = JSON.parse(manifest)
        pretty_manifest = JSON.pretty_generate(parsed)

        say "Writing manifest file to #{manifold_docs.manifest_file}"
        manifold_docs.manifest_file.write pretty_manifest

        if version.pre?
          say "This is a pre-release version, so we're not updating the current version docs."
        else
          say "This appears to not be a pre-release version. Updating documentation current version"
          current = { "version" => verison.to_s , "os" => "ubuntu18" }
          current_manifest = JSON.pretty_generate(current)
          manifold_docs.current_file.write current_manifest
        end

      end

    end
  end
end