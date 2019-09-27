require "tty-box"

module Models

  class Notifier

    def self.log(msg)
      puts msg
    end

    def self.error(msg)
      box = TTY::Box.frame(
          width: 70,
          style: {
              fg: :black,
              bg: :red,
              border: {
                  fg: :bright_red,
                  bg: :red,
              }
          },
          height: 3,
          align: :center,
          padding: 0
      ) do
        msg
      end
      print box
    end

    def self.success(msg)
      box = TTY::Box.frame(
          width: 70,
          style: {
              fg: :black,
              bg: :green,
              border: {
                  fg: :bright_green,
                  bg: :green,
              }
          },
          height: 3,
          align: :center,
          padding: 0
      ) do
        msg
      end
      print box
    end

  end

end