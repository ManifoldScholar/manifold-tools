# frozen_string_literal: true

require 'awesome_print'

module Interactions
  module Build
    class Changelog < BaseInteraction
      object :environment, class: 'Models::Environment'
      boolean :refresh, default: false
      delegate :github, :projects, to: :environment
      delegate :manifold_source, to: :projects
      object :unreleased_version, class: 'Models::Version', default: nil

      array :args, default: proc { [] } do
        string
      end

      object :options, class: 'Thor::CoreExt::HashWithIndifferentAccess'

      def execute
        if options.noop
          whisper '...skipping manifold changelog update due to --noop flag', manifold_source
        else
          update_changelog
          say 'Changelog updated.', manifold_source
        end
      end

     private

      def update_changelog
        buffer = []
        buffer << '# Changelog'

        sorted_pull_requests.each do |version, prs|
          next if version.start_with? 'v0'

          buffer << ''

          next if prs.length === 0

          classified = classify(prs)

          if version === 'unreleased'
            if unreleased_version
              buffer << "## [#{unreleased_version}](https://github.com/ManifoldScholar/manifold/tree/#{unreleased_version}) - #{Time.now.strftime('%m/%d/%y')}"
            else
              buffer << '## Unreleased - TBD'
            end
          else
            buffer << "## [#{version}](https://github.com/ManifoldScholar/manifold/tree/#{version}) - #{date_for_version(version)}"
          end

          classifications.each do |classification|
            unless classified[classification] && !classified[classification].empty?
              next
            end

            buffer << ''
            buffer << "### #{classification.capitalize}"
            buffer << ''
            classified[classification].each do |pr|
              number = "[\##{pr[:attributes][:number]}](#{pr[:attributes][:url]})"
              user = "([#{pr[:attributes][:user_login]}](#{pr[:attributes][:user_url]}))"
              buffer << "- #{pr_title_entry(pr)} #{number} #{user}"
            end
          end
        end

        contents = buffer.join("\n")
        contents += history if history?
        manifold_source.update_changelog contents
      end

      def pr_title_entry(pr)
        raw = pr[:attributes][:title].strip
        raw[0...3] = ''
        CGI.escapeHTML(raw)
      end

      def history?
        File.exist? history_path
      end

      def history_path
        File.join(__dir__, '../../../..', 'HISTORY.md')
      end

      def history
        File.read history_path
      end

      def classifications
        %w[features bugs refactored security accessibility]
      end

      def classify(prs)
        prs.each_with_object('other' => []) do |pr, memo|
          classifications.each do |c|
            if pr[:attributes][:title].start_with? "[#{c[0].upcase}]"
              memo[c] = [] if memo[c].nil?
              memo[c] << pr
            end
          end
        end
      end

      def date_for_version(version)
        return version if version === 'unreleased'

        date = manifold_source.tag_date(version)
        return date.strftime('%m/%d/%y') if date.respond_to? :strftime

        nil
      end

      def cache
        @cache ||= Models::CacheStore.new
      end

      def sorted_pull_requests
        gprs = grouped_pull_requests
        gprs.each do |version, pull_requests|
          next if version === 'unreleased'

          gprs[version] = pull_requests.sort_by { |v| v[:distance] || 0 }
        end
        gprs
      end

      def grouped_pull_requests
        return @grouped_prs if @grouped_prs

        @grouped_prs = Hash[([default_version] + versions).map { |v| [v.to_s, []] }]
        pull_requests.each do |pr|
          next unless pr[:merge_commit_sha]

          description = manifold_source.describe(pr[:merge_commit_sha])
          version = default_version
          if description
            version, distance = description.split(Regexp.union(description_delimiters))
            unless versions.include? Models::Version.new(version)
              next
            end rescue next
          end
          @grouped_prs[version].push(
            distance: distance.to_i,
            attributes: pr
          )
        end
        @grouped_prs
      end

      def default_version
        'unreleased'
      end

      def description_delimiters
        ['~', '^']
      end

      def versions
        @versions ||= manifold_source.versions
      end

      def pull_requests
        key = 'PULL_REQUESTS'
        prs = cache.read(key)
        if !prs || prs.empty? || refresh
          fetched = github.closed_pull_requests.reject { |pr| pr[:merged_at].nil? }
          prs = fetched.map do |pr|
            {
              merged: pr[:merged],
              merged_at: pr[:merged_at],
              closed_at: pr[:closed_at],
              merge_commit_sha: pr[:merge_commit_sha],
              merge_commit_description: manifold_source.describe(pr[:merge_commit_sha]),
              number: pr[:number],
              description: pr[:description],
              url: pr[:html_url],
              state: pr[:state],
              title: pr[:title].strip,
              user_login: pr[:user][:login],
              user_url: pr[:user][:url],
              body: pr[:body]
            }
          end
          cache.write(key, prs)
        end
        prs
      end
   end
  end
end
