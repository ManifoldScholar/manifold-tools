# frozen_string_literal: true

require 'manifold/tools/version'
require 'open3'
require 'thor'
require 'zeitwerk'
require 'pry'
require 'active_support'
require 'active_support/core_ext'

# Set up Zeitwerk for the application
loader = Zeitwerk::Loader.new
loader.tag = "manifold-tools"

# Push the lib directory - this is the key fix
loader.push_dir("#{File.expand_path('..', __dir__)}")

# Ignore files that shouldn't be autoloaded
loader.ignore("#{File.expand_path('..', __dir__)}/manifold/tools/version.rb")
loader.ignore("#{File.expand_path('..', __dir__)}/manifold/tools/command.rb")
loader.ignore("#{File.expand_path('..', __dir__)}/manifold/tools/commands")

loader.setup

module Manifold
  module Tools
    class Error < StandardError; end
  end
end
