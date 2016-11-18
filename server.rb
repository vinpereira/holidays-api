Dir["lib/*.rb"].sort.each { |file| require(File.dirname(__FILE__) + "/"+ file) }

require 'sinatra'
require "sinatra/namespace"

# DB Setup
Mongoid.load!(File.expand_path('mongoid.yml', './config'), Sinatra::Base.environment)

# Endpoints
get '/' do
  'Welcome to Holidays API!'
end

namespace '/api/v1' do
  before do
    content_type 'application/json'
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end

    def json_params
      begin
        JSON.parse(request.body.read)
      rescue
        halt 400, { message: 'Invalid JSON' }.to_json
      end
    end

    def holiday
      @holiday ||= Holiday.where(id: params[:id]).first
    end

    def halt_if_not_found!
      halt(404, { message: 'Holiday Not Found'}.to_json) unless holiday
    end

    def serialize(holiday)
      HolidaySerializer.new(holiday).to_json
    end
  end

  get '/holidays' do
    holidays = Holiday.all

    [:date, :month, :city, :state, :federal].each do |filter|
      holidays = holidays.send(filter, params[filter]) if params[filter]
    end

    holidays.map { |holiday| HolidaySerializer.new(holiday) }.to_json
  end

  get '/holidays/:id' do |id|
    holiday = Holiday.where(id: id).first
    halt(404, { message: 'Holiday Not Found'}.to_json) unless holiday
    HolidaySerializer.new(holiday).to_json
  end

  post '/holidays' do
    holiday = Holiday.new(json_params)
    halt 422, serialize(holiday) unless holiday.save

    response.headers['Location'] = "#{base_url}/api/v1/holidays/#{holiday.id}"
    status 201
  end

  patch '/holidays/:id' do |id|
    halt_if_not_found!
    halt 422, serialize(holiday) unless holiday.update_attributes(json_params)
    serialize(holiday)
  end

  delete '/holidays/:id' do |id|
    holiday.destroy if holiday
    status 204
  end
end
