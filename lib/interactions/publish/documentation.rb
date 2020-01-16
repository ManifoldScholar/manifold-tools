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
        compose(Git::Clone, inputs.merge(project: manifold_docs))
        compose(Git::Fetch, inputs.merge(project: manifold_docs))

      end

    end
  end
end