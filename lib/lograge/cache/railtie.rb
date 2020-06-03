# frozen_string_literal: true

require 'rails/railtie'
require 'active_support/ordered_options'

module Lograge
  module Cache
    # Railtie to automatically setup in Rails
    class Railtie < Rails::Railtie
      # To ensure that configuration is not nil when initialise Lograge::Cache.setup
      config.lograge_cache = ActiveSupport::OrderedOptions.new

      config.after_initialize do |app|
        Lograge::Cache.setup(app.config.lograge_cache)
      end
    end
  end
end
