# Manifold::Tools

The main purpose of this CLI application is to automate the process of releasing a new
version of Manifold. We're not currently releasing it to a gem repository, although we
may in the future.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'manifold-tools'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install manifold-tools

## Usage

The main interface for this tool is at ./exe/manifold-tools.

To get started, run `manifold-tools configure`. You'll be prompted with a series of
questions and configuration will be generated and stored in ~/.manifold-tools.yml.

After configuring the application, there are two primary commands that are used to release
a new version of manifold. First you build the version, then you publish the version.

The tool currently does not ensure that system dependencies are in place. For it to work
correctly, you'll need a number of things:

1. A recent version of Git
2. [Hub](https://github.com/github/hub)
3. A functional version of Vagrant that's compatible with manifold-omnibus
4. VirtualBox (for Vagrant)
5. Working installation of Docker (for manifold-docker-build)

This tool coordinates and tags the following repositories:

https://github.com/ManifoldScholar/manifold/
https://github.com/ManifoldScholar/manifold-omnibus/
https://github.com/ManifoldScholar/manifold-docker-build/
https://github.com/ManifoldScholar/manifold-docker-compose/
https://github.com/ManifoldScholar/manifold-documentation/
https://github.com/ManifoldScholar/manifold-documentation-deploy/

### Building Manifold

Build Manifold with the following command. Update the version to whatever version you want
to build:
```
./exe/manifold-tools build v5.0.0
```

Building will perform the following tasks:

- Validate the version
- If a release branch is specified, the manifold-src repo will be set to that branch
- Open a build branch for each version
- Update the MANIFOLD_VERSION file in each repository
- Build Omnibus packages for ubuntu16, ubuntu18, and centos7
- Build docker images

### Publishing Manifold

Publish Manifold with the following command. Update the version to whatever version you want
to publish:
```
./exe/manifold-tools build v5.0.0
```

Publishing will perform the following tasks:

- Validate the version
- If a release branch is specified, the manifold-src repo will be set to that branch
- Open a build branch for each version
- Update the MANIFOLD_VERSION file in each repository
- Upload Omnibus packages to Google cloud storage
- Push Docker images to Docker hub
- Refresh the package manifest in Google cloud storage
- Commit the package manifest to the documentation repository
- Update the current version in documentation unless the release version is a pre-release.
- Open pull requests for each repository with a release commit
- Prompt the user to accept all pull requests
- Deploy documentation to production
- Tag all relevant repositories

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ManifoldScholar/manifold-tools. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the manifold-tools project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ManifoldScholar/manifold-tools/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2019 Zach Davis. See [MIT License](LICENSE.txt) for further details.
