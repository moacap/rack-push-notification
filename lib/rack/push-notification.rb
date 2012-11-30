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

require 'rack/push-notification/version'

require 'pp'

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

    app = Class.new(Sinatra::Base) do
      use Rack::PostBodyContentTypeParser
      use Rack::Static, urls: ['/images'], root: ::File.join(::File.dirname(__FILE__), "push-notification/assets")
      helpers Sinatra::Param

      set :assets, Sprockets::Environment.new(::File.join(::File.dirname(__FILE__), "push-notification/assets"))
      set :views, ::File.join(::File.dirname(__FILE__), "push-notification/assets/views")
      settings.assets.append_path "javascripts"
      settings.assets.append_path "stylesheets"

      # disable :raise_errors, :show_exceptions

      before do
        content_type :json
      end

      get '/devices/?' do
        param :q, String, empty: false
        param :offset, Integer, default: 0
        param :limit, Integer, max: 100, min: 1, default: 25

        @devices = klass.dataset
        @devices = @devices.filter("tsv @@ to_tsquery('english', ?)", "#{params[:q]}:*") if params[:q]
        @devices = @devices.limit(params[:limit], params[:offset])
        
        {
          devices: @devices,
          total: klass.dataset.count 
        }.to_json
      end

      put '/devices/:token/?' do
        param :languages, Array
        param :tags, Array

        @record = klass.new(params)
        if @record.save
          status 201
          @record.to_json
        else
          status 406
          {errors: @record.errors}.to_json
        end
      end

      get '/devices/:token/?' do
        @record = klass.find(token: params[:token])
        if @record
          @record.to_json
        else
          status 404
        end
      end

      delete '/devices/:token/?' do
        @record = klass.find(token: params[:token]) or halt 404
        if @record.destroy
          status 200
        else
          status 406
          {errors: record.errors}.to_json
        end
      end

      get "/javascripts/:file.js" do
        content_type "application/javascript"
        settings.assets["#{params[:file]}.js"]
      end

      get "/stylesheets/:file.css" do
        content_type "text/css"
        settings.assets["#{params[:file]}.css"]
      end

      get '*' do
        content_type :html

        haml :index
      end
    end

    return app
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
