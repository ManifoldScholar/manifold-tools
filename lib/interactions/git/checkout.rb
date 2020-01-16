# frozen_string_literal: true

module Interactions
  module Git
    class Checkout < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      object :project, class: 'Models::Projects::Base'
      string :branch, default: nil
      string :tag, defauilt: nil

      def execute
        return unless valid_options?
        return skip if noop?

        say "Checking out #{target_type} #{target}", project

        pproject.checkout_build_branch(target, target_type)
      rescue ::Git::GitExecuteError => e
        errors.add('git:checkout', e)
      end

      private

      def target
        return branch unless branch.blank?
        return tag unless tag.blank?
      end

      def branch?
        branch.present?
      end

      def target_type
        return 'branch' if branch.present?
        return 'tag' if tag.present?
      end

      def valid_options?
        raise 'Git::Checkout needs a branch or a tag' if target.empty?
        raise 'Git::Checkout must be given a branch or a tag, but not both' if branch && tag

        true
      end

      def skip
        whisper '...skipping checkout due to --noop flag', project
      end
    end
  end
end
