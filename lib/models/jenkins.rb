# frozen_string_literal: true

require 'jenkins_api_client'

module Models
  class Jenkins
    include Models::Concerns::UsesEnvironment

    BUILD_MANIFOLD_JOB_TASK_NAME = 'omnibus-manifold'
    BUILD_DOCS_JOB_TASK_NAME = 'documentation'

    def build!(version, dry_run: false)
      raise TypeError, "must be a version: #{version.inspect}" unless version.is_a? Models::Version

      params = {
        cause: 'Triggered by manifold release',
        omnibusBuild: dry_run ? 'No' : 'Yes',
        tag: version.to_s,
        token: build_token
      }.stringify_keys

      client.job.build BUILD_MANIFOLD_JOB_TASK_NAME, params
    end

    attr_lazy_reader :client do
      JenkinsApi::Client.new server_url: server_url
    end

    attr_lazy_reader :server_url do
      env_fetch :jenkins, :url
    end

    attr_lazy_reader :build_token do
      env_fetch :jenkins, :token
    end
  end
end
