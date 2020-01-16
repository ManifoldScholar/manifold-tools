# frozen_string_literal: true

module Models
  module Concerns
    module UsesEnvironment
      extend ActiveSupport::Concern

      included do
        delegate :fetch, to: :env, prefix: true
      end

      def initialize(env:, **_other_options)
        @env = env
      end

      attr_reader :env
    end
  end
end
