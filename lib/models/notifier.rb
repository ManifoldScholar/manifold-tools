require "pastel"

module Models

  class Notifier

    def self.pastel
      @pastel ||= Pastel.new
    end

    def self.log(msg)
      puts msg
    end

    def self.error(msg)
      puts self.pastel.red msg
    end

    def self.success(msg)
      puts self.pastel.green msg
    end

  end

end