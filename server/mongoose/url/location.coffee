controller = require "../controller/location.coffee"
middleware = require '../../../middleware.coffee'
 
@include = ->

	@get '/api/locations', middleware.rest.user, ->
		controller.Location.list(@request, @response)
		
	@post '/api/locations', middleware.rest.user, ->
		controller.Location.create(@request, @response) 
		
	@get '/api/locations/:id', middleware.rest.user, ->
		controller.Location.read(@request, @response)
		
	@put '/api/locations/:id', middleware.rest.user, ->
		controller.Location.update(@request, @response)
		
	@del '/api/locations/:id', middleware.rest.user, ->
		controller.Location.delete(@request, @response)