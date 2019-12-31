module Interactions
  module Command
    class Clean < BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: "Thor::CoreExt::HashWithIndifferentAccess"
      delegate :projects, to: :environment

      def execute
        prompt.yes? "Are you sure you want to do this? If you have work in the repositories that has not been committed and pushed, you will lose it."
        projects.each do |project|
          project.git.branch("master").checkout
          project.clean_build_branches
          compose(Git::HardReset, inputs.merge(project: project, branch: "master"))
          compose(Git::PruneLocalTags, inputs.merge(project: project))
        end

      end

    end
  end
end
