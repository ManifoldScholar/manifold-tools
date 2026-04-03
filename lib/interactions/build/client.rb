# frozen_string_literal: true

require 'tty-command'

module Interactions
  module Build
    class Client < Interactions::BaseInteraction
      object :environment, class: 'Models::Environment'
      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'
      delegate :projects, to: :environment
      delegate :manifold_source, to: :projects

      def execute
        say 'Building Manifold client', manifold_source
        if options.noop
          whisper '...skipping manifold client build due to --noop flag', manifold_source
        else
          manifold_source.build_client
        end
      end
    end
  end
end
