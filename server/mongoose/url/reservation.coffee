controller = require "../controller/reservation.coffee"
middleware = require '../../../middleware.coffee'
 
@include = ->

	@get '/api/myreservations', middleware.rest.user, ->
		controller.Reservation.mylist(@request, @response)

	@post '/api/reservations', middleware.rest.user, ->
		controller.Reservation.create(@request, @response) 
		
	@get '/api/reservations/:id', middleware.rest.user, ->
		controller.Reservation.read(@request, @response)
		
	@put '/api/reservations/:id', middleware.rest.user, ->
		controller.Reservation.update(@request, @response)
		
	@del '/api/reservations/:id', middleware.rest.user, ->
		controller.Reservation.delete(@request, @response)
		
	@get '/api/reservations', middleware.rest.user, ->
		controller.Reservation.list(@request, @response)