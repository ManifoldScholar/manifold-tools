# frozen_string_literal: true

require 'octokit'
require 'faraday-http-cache'

module Models
  class Github
    include Models::Concerns::UsesEnvironment

    def initialize(env)
      super
      initialize_middleware
      @client ||= initialize_client
    end

    def closed_pull_requests(**options)
      ap 'Fetched closed pull requests from Github...'
      iterate_over_pages!(client.pull_requests(env_fetch(:repo, :name), state: 'closed'), options)
    end

    def pr_merged?(number, **options)
      ap "Checking if PR ##{number} has been merged..."
      client.pull_merged?(env_fetch(:repo, :name), number, options)
    end

    private

    attr_reader :client

    def initialize_client
      Octokit::Client.new(
        access_token: env_fetch(:github, :token)
      )
    end

    def initialize_middleware
      stack = Faraday::RackBuilder.new do |builder|
        builder.use Faraday::HttpCache, serializer: Marshal, shared_cache: false
        builder.use Octokit::Response::RaiseError
        builder.adapter Faraday.default_adapter
      end
      Octokit.middleware = stack
    end

    def iterate_over_pages!(collection, limit: 100)
      last_response = client.last_response
      i = 0
      while last_response.rels[:next] && i < limit
        i += 1
        data = last_response.rels[:next].get.data
        ap "Fetched objects [#{data.first.id}..#{data.last.id}]"
        last_response = last_response.rels[:next].get
        collection.concat data
      end
      collection
    end
  end
end
