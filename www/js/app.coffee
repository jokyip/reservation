module = angular.module('starter', ['ionic', 'starter.controller', 'http-auth-interceptor', 'ngTagEditor', 'ActiveRecord', 'angularFileUpload', 'ngTouch', 'ionic-datepicker', 'ngTable'])

module.run ($ionicPlatform, $location, $http, authService) ->
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
		
module.config ($stateProvider, $urlRouterProvider) ->
	$stateProvider.state 'app',
		url: ""
		abstract: true
		controller: 'AppCtrl'
		templateUrl: "templates/menu.html"

	# Resource
	$stateProvider.state 'app.resource',
		url: "/resource"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/resource/list.html"
				controller: 'ResourceListCtrl'
				
	$stateProvider.state 'app.resourceInput',
		url: "/resource/select"
		cache: false
		params: {model: null}
		views:
			'menuContent':
				templateUrl: "templates/resource/select.html"
				controller: 'ResourceCtrl'			
				
	# Reservation
	$stateProvider.state 'app.myreservation',
		url: "/myreservation"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/reservation/mylist.html"
				controller: 'MyReservationListCtrl'
				
	$stateProvider.state 'app.reservation',
		url: "/reservation"
		cache: false
		params: {date: null}
		views:
			'menuContent':
				templateUrl: "templates/reservation/list.html"
				controller: 'ReservationListCtrl'
				
	$stateProvider.state 'app.reservationInput',
		url: "/reservation/select"
		cache: false
		params: {resource: null, date: null, time: null}		
		views:
			'menuContent':
				templateUrl: "templates/reservation/select.html"
				controller: 'ReservationCtrl'										
							
		
	$urlRouterProvider.otherwise('/resource')