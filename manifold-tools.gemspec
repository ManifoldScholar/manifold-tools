# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'manifold/tools/version'

Gem::Specification.new do |spec|
  spec.name          = 'manifold-tools'
  spec.license       = 'MIT'
  spec.version       = Manifold::Tools::VERSION
  spec.authors       = ['Zach Davis']
  spec.email         = ['zach@castironcoding.com']

  spec.summary       = 'Summary goes here'
  spec.description   = 'Description goes here'
  spec.homepage      = 'https://github.com/manifoldScholar/manifold-tools'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/manifoldScholar/manifold-tools'
    spec.metadata['changelog_uri'] = 'https://github.com/manifoldScholar/manifold-tools/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'active_interaction', '~> 3.0'
  spec.add_dependency 'activesupport', ">= 6.0.3.1"
  spec.add_dependency 'attr_lazy_reader'
  spec.add_dependency 'awesome_print'
  spec.add_dependency 'cleanroom'
  spec.add_dependency 'commander'
  spec.add_dependency 'dotenv'
  spec.add_dependency 'dux'
  spec.add_dependency 'faraday-http-cache'
  spec.add_dependency 'git'
  spec.add_dependency 'google-cloud'
  spec.add_dependency 'google-cloud-storage'
  spec.add_dependency 'jenkins_api_client'
  spec.add_dependency 'octokit'
  spec.add_dependency 'oj'
  spec.add_dependency 'pastel', '~> 0'
  spec.add_dependency 'pry'
  spec.add_dependency 'ptools'
  spec.add_dependency 'rubocop'
  spec.add_dependency 'semantic'
  spec.add_dependency 'thor', '~> 0.20.0'
  spec.add_dependency "tty-box", "~> 0"
  spec.add_dependency "tty-color", "~> 0"
  spec.add_dependency "tty-command", "~> 0"
  spec.add_dependency "tty-config", "~> 0"
  spec.add_dependency "tty-cursor", "~> 0"
  spec.add_dependency "tty-editor", "~> 0"
  spec.add_dependency "tty-file", "~> 0"
  spec.add_dependency "tty-font", "~> 0"
  spec.add_dependency "tty-logger", "~> 0"
  spec.add_dependency "tty-markdown", "~> 0"
  spec.add_dependency "tty-pager", "~> 0"
  spec.add_dependency "tty-pie", "~> 0"
  spec.add_dependency "tty-platform", "~> 0"
  spec.add_dependency "tty-progressbar", "~> 0"
  spec.add_dependency "tty-prompt", "~> 0"
  spec.add_dependency "tty-screen", "~> 0"
  spec.add_dependency "tty-spinner", "~> 0"
  spec.add_dependency "tty-table", "~> 0"
  spec.add_dependency "tty-tree", "~> 0"
  spec.add_dependency "tty-which", "~> 0"
  spec.add_dependency 'zeitwerk', '~> 2.2.0'
  spec.add_dependency "kramdown", ">= 2.3.1"

  spec.add_development_dependency 'bundler', '~> 2.2.17'
  spec.add_development_dependency 'pry', '~> 0.12.2'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
