# frozen_string_literal: true

require 'pastel'

module Models
  class Notifier
    def self.pastel
      @pastel ||= Pastel.new
    end

    def self.log(msg)
      puts msg
    end

    def self.error(msg)
      puts pastel.red msg
    end

    def self.success(msg)
      puts pastel.green msg
    end
  end
end
