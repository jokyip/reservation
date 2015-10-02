module = angular.module('starter', ['ionic', 'starter.controller', 'http-auth-interceptor', 'ngTagEditor', 'ActiveRecord', 'angularFileUpload', 'ngTouch', 'ionic-datepicker', 'ngFancySelect'])

module.run ($rootScope, platform, $ionicPlatform, $location, $http, authService) ->
	$ionicPlatform.ready ->
		if (window.cordova && window.cordova.plugins.Keyboard)
			cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
		if (window.StatusBar)
			StatusBar.styleDefault()
		
	# set authorization header once browser authentication completed
	if $location.url().match /access_token/
			data = $.deparam $location.url().split("/")[1]
			$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
			authService.loginConfirmed()
			
	# set authorization header once mobile authentication completed
	fulfill = (data) ->
		if data?
			$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
			authService.loginConfirmed()
	
	$rootScope.$on 'event:auth-forbidden', ->
		platform.auth().then fulfill, alert
	$rootScope.$on 'event:auth-loginRequired', ->
		platform.auth().then fulfill, alert
		
module.config ($stateProvider, $urlRouterProvider) ->
	$stateProvider.state 'app',
		url: ""
		abstract: true
		templateUrl: "templates/menu.html"

	# Timeslot
	$stateProvider.state 'app.timeslot',
		url: "/timeslot"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/timeslot/list.html"
				controller: 'TimeslotListCtrl'
		resolve:
			cliModel: 'model'	
			collection: (cliModel) ->
				ret = new cliModel.TimeslotList()
				ret.$fetch()		
				
	$stateProvider.state 'app.timeslotCreate',
		url: "/timeslot/create"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/timeslot/create.html"
				controller: 'TimeslotCtrl'
		resolve:
			cliModel: 'model'	
			model: (cliModel) ->
				ret = new cliModel.Timeslot()
				
	$stateProvider.state 'app.timeslotEdit',
		url: "/timeslot/edit/:id"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/timeslot/edit.html"
				controller: 'TimeslotCtrl'
		resolve:
			id: ($stateParams) ->
				$stateParams.id
			cliModel: 'model'	
			model: (cliModel, id) ->
				ret = new cliModel.Timeslot({_id: id})
				ret.$fetch()			
				
	$stateProvider.state 'app.timeslotRead',
		url: "/timeslot/read/:id"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/timeslot/read.html"
				controller: 'TimeslotCtrl'
		resolve:
			id: ($stateParams) ->
				$stateParams.id
			cliModel: 'model'
			model: (cliModel, id) ->
				ret = new cliModel.Timeslot({_id: id})
				ret.$fetch()

	# Location
	$stateProvider.state 'app.location',
		url: "/location"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/location/list.html"
				controller: 'LocationListCtrl'
		resolve:
			cliModel: 'model'	
			collection: (cliModel) ->
				ret = new cliModel.LocationList()
				ret.$fetch()		
				
	$stateProvider.state 'app.locationCreate',
		url: "/location/create"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/location/create.html"
				controller: 'LocationCtrl'
		resolve:
			cliModel: 'model'	
			model: (cliModel) ->
				ret = new cliModel.Location()
				
	$stateProvider.state 'app.locationEdit',
		url: "/location/edit/:id"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/location/edit.html"
				controller: 'LocationCtrl'
		resolve:
			id: ($stateParams) ->
				$stateParams.id
			cliModel: 'model'	
			model: (cliModel, id) ->
				ret = new cliModel.Location({_id: id})
				ret.$fetch()			
				
	$stateProvider.state 'app.locationRead',
		url: "/location/read/:id"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/location/read.html"
				controller: 'LocationCtrl'
		resolve:
			id: ($stateParams) ->
				$stateParams.id
			cliModel: 'model'
			model: (cliModel, id) ->
				ret = new cliModel.Location({_id: id})
				ret.$fetch()

	# Resource
	$stateProvider.state 'app.resource',
		url: "/resource"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/resource/list.html"
				controller: 'ResourceListCtrl'
		resolve:
			cliModel: 'model'	
			collection: (cliModel) ->
				ret = new cliModel.ResourceList()
				ret.$fetch()		
				
	$stateProvider.state 'app.resourceCreate',
		url: "/resource/create"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/resource/create.html"
				controller: 'ResourceCtrl'
		resolve:
			cliModel: 'model'	
			model: (cliModel) ->
				ret = new cliModel.Resource()
			locationList: (cliModel) ->
				ret = new cliModel.LocationList()
				ret.$fetch()		
				
	$stateProvider.state 'app.resourceEdit',
		url: "/resource/edit/:id"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/resource/edit.html"
				controller: 'ResourceCtrl'
		resolve:
			id: ($stateParams) ->
				$stateParams.id
			cliModel: 'model'	
			model: (cliModel, id) ->
				ret = new cliModel.Resource({_id: id})
				ret.$fetch()
			locationList: (cliModel) ->
				ret = new cliModel.LocationList()
				ret.$fetch()			
				
	$stateProvider.state 'app.resourceRead',
		url: "/resource/read/:id"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/resource/read.html"
				controller: 'ResourceCtrl'
		resolve:
			id: ($stateParams) ->
				$stateParams.id
			cliModel: 'model'
			model: (cliModel, id) ->
				ret = new cliModel.Resource({_id: id})
				ret.$fetch()
			locationList: ->
				[]											
				
	# Reservation
	$stateProvider.state 'app.myreservation',
		url: "/myreservation"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/reservation/mylist.html"
				controller: 'MyReservationListCtrl'
		resolve:
			cliModel: 'model'	
			collection: (cliModel) ->
				ret = new cliModel.MyReservationList()
				ret.$fetch()		
				
	$stateProvider.state 'app.reservation',
		url: "/reservation?date"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/reservation/list.html"
				controller: 'ReservationListCtrl'
		resolve:
			cliModel: 'model'
			timeslotList: (cliModel) ->
				ret = new cliModel.TimeslotList()
				ret.$fetch()
			resourceList: (cliModel) ->
				ret = new cliModel.ResourceList()
				ret.$fetch()
			user: (cliModel) ->
				cliModel.User.me()				
			inputDate: ($stateParams) ->
				ret = $stateParams.date
				if !ret
					ret = new Date
					ret.setHours(0,0,0,0)
				return ret			
				
	$stateProvider.state 'app.reservationByResource',
		url: "/reservationByResource?resource"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/reservation/listByResource.html"
				controller: 'ReservationByResourceListCtrl'
		resolve:
			cliModel: 'model'	
			timeslotList: (cliModel) ->
				ret = new cliModel.TimeslotList()
				ret.$fetch()
			resourceList: (cliModel) ->
				ret = new cliModel.ResourceList()
				ret.$fetch()
			resource: (cliModel, $stateParams) ->
				if $stateParams.resource
					ret = new cliModel.Resource({_id: $stateParams.resource})
					ret.$fetch()
											
				
	$stateProvider.state 'app.reservationCreate',
		url: "/reservation/create?resource&date&time&source"
		cache: false		
		views:
			'menuContent':
				templateUrl: "templates/reservation/create.html"
				controller: 'ReservationCtrl'
		resolve:
			cliModel: 'model'
			resource: ($stateParams, cliModel) ->
				ret = new cliModel.Resource()
				if $stateParams.resource
					ret = new cliModel.Resource _id: $stateParams.resource
					ret.$fetch()						
			date: ($stateParams) ->
				ret = $stateParams.date
				if !ret
					ret = new Date
					ret.setHours(0,0,0,0)
					return ret.getTime()
				return ret										
			time: ($stateParams, cliModel) ->
				ret = new cliModel.Timeslot()
				if $stateParams.time
					ret = new cliModel.Timeslot _id: $stateParams.time
					ret.$fetch()	
			timeslotList: (cliModel) ->
				ret = new cliModel.TimeslotList()
				ret.$fetch()
			resourceList: (cliModel) ->
				ret = new cliModel.ResourceList()
				ret.$fetch()	
			model: (cliModel, resource, date, time) ->
				new cliModel.Reservation resource: resource, date: date, time: time
			source: ($stateParams) ->
				$stateParams.source								
							
		
	$urlRouterProvider.otherwise('/reservation')