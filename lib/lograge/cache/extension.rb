# frozen_string_literal: true

module Lograge
  module Cache
    # Module used to extend Lograge
    module Extension
      # Overrides `Lograge::RequestLogSubscriber#extract_request` do add Cache queries
      def extract_request(event, payload)
        super.merge!(extract_cache_queries)
      end

      # Collects all Cache queries stored in the Thread during request processing
      def extract_cache_queries
        cache_queries = Lograge::Cache.store[:lograge_cache_queries]
        return {} unless cache_queries

        Lograge::Cache.store[:lograge_cache_queries] = nil
        {
          cache_queries: Lograge::Cache.formatter.call(cache_queries),
          cache_count: cache_queries.length
        }
      end
    end
  end
end

module Lograge
  # Log subscriber to replace ActiveRecord's default one
  class CacheLogSubscriber < ActiveSupport::LogSubscriber
    # Every time there's an Cache query, stores it into the Thread.
    # They'll later be access from the RequestLogSubscriber.
    def cache_read(event)
      Lograge::Cache.store[:lograge_cache_queries] ||= []
      Lograge::Cache.store[:lograge_cache_queries] << Lograge::Cache.extract_event.call(event)
    end
  end
end

if defined?(Lograge::RequestLogSubscriber)
  Lograge::RequestLogSubscriber.prepend Lograge::Cache::Extension
else
  Lograge::LogSubscribers::ActionController.prepend Lograge::Cache::Extension
end

Lograge::CacheLogSubscriber.attach_to :active_support
