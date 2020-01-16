# frozen_string_literal: true

require 'dbm'

module Models
  class CacheStore
    def initialize
      @db = DBM.new('octokit_cache', 0o666, DBM::WRCREAT)
    end

    def delete(key)
      @db.delete(key)
    end

    def read(key)
      out = Array(Marshal.load(@db[key]))
      out
    rescue StandardError
      []
    end

    def write(key, value)
      @db[key] = Marshal.dump(value)
    end
  end
end
