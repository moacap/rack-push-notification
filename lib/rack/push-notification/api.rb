module Rack
  module PushNotification
    class API < Sinatra::Base
      use Rack::PostBodyContentTypeParser
      helpers Sinatra::Param

      disable :raise_errors, :show_exceptions

      before do
        content_type :json
      end

      get '/devices/?' do
        param :q, String
        param :offset, Integer, default: 0
        param :limit, Integer, max: 100, min: 1, default: 25

        @devices = Device.dataset
        @devices = @devices.filter("tsv @@ to_tsquery('english', ?)", "#{params[:q]}:*") if params[:q] and not params[:q].empty?
        
        {
          devices: @devices.limit(params[:limit], params[:offset]),
          total: @devices.count
        }.to_json
      end

      put '/devices/:token/?' do
        param :languages, Array
        param :tags, Array

        @record = Device.new(params)

        if @record.save
          status 201
          @record.to_json
        else
          status 406
          {errors: @record.errors}.to_json
        end
      end

      get '/devices/:token/?' do
        @record = Device.find(token: params[:token])

        if @record
          @record.to_json
        else
          status 404
        end
      end

      delete '/devices/:token/?' do
        @record = Device.find(token: params[:token]) or halt 404

        if @record.destroy
          status 200
        else
          status 406
          {errors: record.errors}.to_json
        end
      end
    end
  end
end
