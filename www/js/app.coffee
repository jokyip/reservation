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
		url: "/file"
		abstract: true
		controller: 'AppCtrl'
		templateUrl: "templates/menu.html"
		
	$stateProvider.state 'app.search',
		url: "/search"
		views:
			'menuContent':
				templateUrl: "templates/search.html"
	
	$stateProvider.state 'app.permission',
		url: "/permission"
		views:
			'menuContent':
				templateUrl: "templates/permission/list.html"
				controller: "AclCtrl"

	$stateProvider.state 'app.file',
		url: "/file?path"
		views:
			'menuContent':
				templateUrl: "templates/file/list.html"
				controller: 'FileCtrl'
	
	# Resource
	$stateProvider.state 'app.resource',
		url: "/resource"
		views:
			'menuContent':
				templateUrl: "templates/resource/list.html"
				controller: 'ResourceListCtrl'
				
	# Reservation
	$stateProvider.state 'app.myreservation',
		url: "/myreservation"
		views:
			'menuContent':
				templateUrl: "templates/reservation/mylist.html"
				controller: 'MyReservationListCtrl'	
				
	$stateProvider.state 'app.reservation',
		url: "/reservation"
		views:
			'menuContent':
				templateUrl: "templates/reservation/list.html"
				controller: 'ReservationListCtrl'							
							
		
	$urlRouterProvider.otherwise('/file/reservation')