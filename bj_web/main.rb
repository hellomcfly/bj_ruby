require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

get '/thinkmcfly' do
	"Hellooo? Is anybody home? Think McFly, think!"
end

get '/flux_capicator' do
	erb :flux_template
end

get '/bttf_chars' do
	erb :"/characters/names"
end

get '/bttf_year' do
	erb :bttf_year
end

post '/yearguess' do
	puts params['year']
end