require 'rack'
require 'rack/contrib'

require 'sinatra/base'
require 'sinatra/param'

require 'coffee-script'
require 'eco'
require 'sass'
require 'compass'
require 'bootstrap-sass'
require 'sprockets'
require 'sprockets-sass'

require 'sequel'

require 'rack/push-notification/api'
require 'rack/push-notification/admin'
require 'rack/push-notification/version'

Sequel.extension(:pg_array, :migration)

module Rack
  module PushNotification
  end

  def self.PushNotification(options = {})
    klass = Rack::PushNotification.const_set("Device", Class.new(Sequel::Model))
    klass.dataset = :devices

    Sequel::Migrator.run(klass.db, ::File.join(::File.dirname(__FILE__), "push-notification/migrations"))

    klass.class_eval do
      self.strict_param_setting = false
      self.raise_on_save_failure = false

      plugin :json_serializer, naked: true, except: :id 
      plugin :validation_helpers
      plugin :timestamps, force: true
      plugin :schema

      def before_validation
        normalize_token!
      end

      private

      def normalize_token!
        self.token = self.token.strip.gsub(/[<\s>]/, '')
      end
    end

    Rack::Cascade.new([
      ::Rack::PushNotification::API.new, 
      ::Rack::PushNotification::Admin.new
    ])
  end

  module PushNotification
    class << self
      def new(options = {})
        @app ||= ::Rack::PushNotification()
      end

      def call(*args)
        @app ||= ::Rack::PushNotification()
        @app.call(*args)
      end
    end
  end
end
