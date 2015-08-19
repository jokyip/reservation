reservation
========

Web Server with Restful API to provide Reservation function

API
===

```

post api/locations - create locations
get api/locations - get list of locations
get api/locations/:id - get locations with specified id
put api/locations/:id - update locations detail with the specified id
del api/locations/:id - delete locations with the specified id

post api/resources - create resources
get api/resources - get list of resources
get api/resources/:id - get resources with specified id
put api/resources/:id - update resources detail with the specified id
del api/resources/:id - delete resources with the specified id

post api/reservations - create reservations
get api/reservations - get list of reservations
get api/reservations/:id - get reservations with specified id
put api/reservations/:id - update reservations detail with the specified id
del api/reservations/:id - delete reservations with the specified id
```

Browser
=======

```
http://mob.myvnc.com/reservation - site URL
```

Configuration
=============

*   git clone https://github.com/jokyip/reservation.git
*   cd reservation
*   npm install && bower install

Server
------
*   update the following environment variables in start.sh and env.cofffee
    
```
    PORT=3000
```

```
	authServer = 'mob.myvnc.com'
	
	dbUrl:		"mongodb://#{proj}rw:password@localhost/#{proj}"
	oauth2:
		clientID:			"#{proj}Auth"
		clientSecret:		'pass1234'
```

*	create mongo database
*	npm start

Client
------
*   update the following environment variables in www/js/env.coffee

```
	serverUrl: (path = @path) ->
		"https://mob.myvnc.com/#{path}"
```

*	node_modules/.bin/gulp
*	ionic reservation android
*	ionic platform add android
*	ionic run android

