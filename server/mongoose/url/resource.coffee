controller = require "../controller/resource.coffee"
middleware = require '../../../middleware.coffee'
 
@include = ->

	@get '/api/resources', middleware.rest.user, ->
		controller.Resource.list(@request, @response)
		
	@post '/api/resources', middleware.rest.user, ->
		controller.Resource.create(@request, @response) 
		
	@get '/api/resources/:id', middleware.rest.user, ->
		controller.Resource.read(@request, @response)
		
	@put '/api/resources/:id', middleware.rest.user, ->
		controller.Resource.update(@request, @response)
		
	@del '/api/resources/:id', middleware.rest.user, ->
		controller.Resource.delete(@request, @response)