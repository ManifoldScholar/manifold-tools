# frozen_string_literal: true

require 'forwardable'

module Manifold
  module Tools
    class Command
      extend Forwardable

      def_delegators :command, :run

      def initialize(options)
        @options = options
      end

      def report(outcome, msg = nil)
        if outcome.valid?
          Models::Notifier.success(msg) if msg
          return
        end
        return Models::Notifier.error("ERROR: Invalid interaction outcome") unless outcome.respond_to? :result
        Models::Notifier.error("ERROR: #{outcome.errors.full_messages}")
      end

      # Execute this command
      #
      # @api public
      def execute(*)
        raise(
          NotImplementedError,
          "#{self.class}##{__method__} must be implemented"
        )
      end

      # The external commands runner
      #
      # @see http://www.rubydoc.info/gems/tty-command
      #
      # @api public
      def command(**options)
        require 'tty-command'
        TTY::Command.new(options)
      end

    end
  end
end
