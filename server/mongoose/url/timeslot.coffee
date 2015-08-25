controller = require "../controller/timeslot.coffee"
middleware = require '../../../middleware.coffee'
 
@include = ->

	@get '/api/timeslots', middleware.rest.user, ->
		controller.Timeslot.list(@request, @response)
		
	@post '/api/timeslots', middleware.rest.user, ->
		controller.Timeslot.create(@request, @response) 
		
	@get '/api/timeslots/:id', middleware.rest.user, ->
		controller.Timeslot.read(@request, @response)
		
	@put '/api/timeslots/:id', middleware.rest.user, ->
		controller.Timeslot.update(@request, @response)
		
	@del '/api/timeslots/:id', middleware.rest.user, ->
		controller.Timeslot.delete(@request, @response)