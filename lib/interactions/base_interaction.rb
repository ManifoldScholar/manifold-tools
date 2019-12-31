require "active_interaction"
require "pastel"
require "tty-prompt"

module Interactions

  class BaseInteraction < ActiveInteraction::Base

    private

    def pastel
      @pastel ||= Pastel.new
    end

    def interaction_name
      @interaction_name ||= self.class.name.split('::').last
    end

    def interaction_badge
      pastel.dim("[#{interaction_name.rjust(13)}] ")
    end

    def project_badge(project)
      pastel.blue("#{project.name.rjust(16)}: ")
    end

    def print_message(msg)
      badge = "[#{interaction_name.rjust(20)}] "
      puts (interaction_badge + msg)
    end

    def print_table(table)
      rows = table = table.split("\n")
      mapped_rows = rows.map { |row| "#{interaction_badge}#{row}" }
      print mapped_rows.join("\n") + "\n"
    end

    def print_without_interaction(msg)
      puts msg
    end

    def prompt
      @prompt ||= TTY::Prompt.new(prefix: interaction_badge)
    end

    def noop?
      options[:noop] == true
    end

    def print_with_project(msg, project)
      print_message(project_badge(project) + msg)
    end

    def say(msg, project = nil)
      return print_with_project(msg, project) if project
      print_message(msg)
    end

    def whisper(msg, project = nil)
      formatted = pastel.dim(msg)
      return print_with_project(formatted , project) if project
      print_message(formatted )
    end

    def celebrate(msg)
      print_message "\u{1f63C} " + pastel.magenta(msg)
    end

    def warn(msg, project = nil)
      formatted = pastel.yellow(msg)
      return print_with_project(formatted , project) if project
      print_message(formatted )
    end

    # The cursor movement
    #
    # @see http://www.rubydoc.info/gems/tty-cursor
    #
    # @api public
    def cursor
      require 'tty-cursor'
      TTY::Cursor
    end

    # Open a file or text in the user's preferred editor
    #
    # @see http://www.rubydoc.info/gems/tty-editor
    #
    # @api public
    def editor
      require 'tty-editor'
      TTY::Editor
    end

    # File manipulation utility methods
    #
    # @see http://www.rubydoc.info/gems/tty-file
    #
    # @api public
    def generator
      require 'tty-file'
      TTY::File
    end

    # Terminal output paging
    #
    # @see http://www.rubydoc.info/gems/tty-pager
    #
    # @api public
    def pager(**options)
      require 'tty-pager'
      TTY::Pager.new(options)
    end

    # Terminal platform and OS properties
    #
    # @see http://www.rubydoc.info/gems/tty-pager
    #
    # @api public
    def platform
      require 'tty-platform'
      TTY::Platform.new
    end

    # Get terminal screen properties
    #
    # @see http://www.rubydoc.info/gems/tty-screen
    #
    # @api public
    def screen
      require 'tty-screen'
      TTY::Screen
    end

    # The unix which utility
    #
    # @see http://www.rubydoc.info/gems/tty-which
    #
    # @api public
    def which(*args)
      require 'tty-which'
      TTY::Which.which(*args)
    end

    # Check if executable exists
    #
    # @see http://www.rubydoc.info/gems/tty-which
    #
    # @api public
    def exec_exist?(*args)
      require 'tty-which'
      TTY::Which.exist?(*args)
    end

  end
end