env = require './env.coffee'

MenuCtrl = ($scope) ->
	$scope.env = env
	$scope.navigator = navigator


TimeslotCtrl = ($scope, model, $ionicNavBarDelegate, $location) ->
	_.extend $scope,
		model: model
		save: ->			
			$scope.model.$save().then =>
				$location.url "/timeslot"	
		
	$ionicNavBarDelegate.showBackButton true
	
	
TimeslotListCtrl = ($scope, collection, $ionicNavBarDelegate, $location) ->
	_.extend $scope,
		collection: collection
		create: ->
			$location.url "/timeslot/create"			
		read: (id) ->
			$location.url "/timeslot/read/#{id}"						
		edit: (id) ->
			$location.url "/timeslot/edit/#{id}"			
		delete: (obj) ->
			collection.remove obj
		loadMore: ->
			collection.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
	
	$ionicNavBarDelegate.showBackButton false
				

LocationCtrl = ($scope, model, $ionicNavBarDelegate, $location) ->
	_.extend $scope,
		model: model
		save: ->			
			$scope.model.$save().then =>
				$location.url "/location"	
		
	$ionicNavBarDelegate.showBackButton true
	
	
LocationListCtrl = ($scope, collection, $ionicNavBarDelegate, $location) ->
	_.extend $scope,
		collection: collection
		create: ->
			$location.url "/location/create"			
		read: (id) ->
			$location.url "/location/read/#{id}"						
		edit: (id) ->
			$location.url "/location/edit/#{id}"			
		delete: (obj) ->
			collection.remove obj
		loadMore: ->
			collection.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
	
	$ionicNavBarDelegate.showBackButton false
	

ResourceCtrl = ($scope, model, locationList, $ionicNavBarDelegate, $location) ->
	_.extend $scope,
		model: model
		locationList: locationList
		save: ->			
			$scope.model.$save().then =>
				$location.url "/resource"
				
	modelEvents = 
		'Select Location':	'location'
		'UC Facility'	:	'ucFacility'
		'Admin Acceptance' : 'adminAccept'
		
	_.each modelEvents, (modelField, event) =>
		$scope.$on event, (event, item) =>
			$scope.model[modelEvents[event.name]] = item	
		
	$ionicNavBarDelegate.showBackButton true
	
	
ResourceListCtrl = ($scope, collection, $ionicNavBarDelegate, $location) ->
	_.extend $scope,
		collection: collection
		create: ->
			$location.url "/resource/create"			
		read: (id) ->
			$location.url "/resource/read/#{id}"						
		edit: (id) ->
			$location.url "/resource/edit/#{id}"			
		delete: (obj) ->
			collection.remove obj
		loadMore: ->
			collection.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
	
	$ionicNavBarDelegate.showBackButton false	
	
ReservationCtrl = ($scope, cliModel, model, resourceList, timeslotList, $filter, $ionicNavBarDelegate, $location) ->
	_.extend $scope,
		model: model
		resourceList: resourceList
		timeslotList: timeslotList
		save: ->			
			$scope.model.$save().then =>
				$location.url "/resevation"
		datepickerObject: { 
			inputDate: new Date($filter('date')(model.date, 'MMM dd yyyy UTC')),
			callback: (val) ->
				$scope.datePickerCallback(val) }								
		datePickerCallback: (val) ->
			if val
				today = new Date(val)
				today.setHours(0,0,0,0)
				$scope.datepickerObject.inputDate = new Date($filter('date')(today, 'MMM dd yyyy UTC'))
				$scope.model.date = $scope.datepickerObject.inputDate
				$scope.getAvailableTimeslot()						
		getAvailableTimeslot: ->
			reservationList = new cliModel.ReservationList
			reservationList.$fetch({params: {date: $scope.model.date.getTime(), resource: $scope.model.resource?._id}}).then ->
				$scope.$apply ->	
					_.each timeslotList.models, (obj) =>
						obj.date = $scope.model.date.getTime()
						@reservation = _.findWhere reservationList.models, {time: "#{obj._id}"}
						if @reservation
							obj.disabled = true
							obj.reservedBy = '[ Reserved by ' + @reservation.createdBy.username + ' ]'
						else
							obj.disabled = false
							obj.reservedBy = ''	
	
	$scope.$on 'selectedResource', (event, item) ->
		$scope.model.resource = item
		$scope.getAvailableTimeslot()
	
	if !$scope.model.resource
		$scope.model.resource = resourceList.models[0] 
	$scope.model.date = new Date($filter('date')(model.date, 'MMM dd yyyy UTC'))	 	
	$scope.getAvailableTimeslot()	
	$ionicNavBarDelegate.showBackButton true
	
MyReservationListCtrl = ($scope, collection, $ionicNavBarDelegate, $location) ->
	_.extend $scope,
		collection: collection
		create: ->
			$location.url "/reservation/create"
		delete: (obj) ->
			collection.remove obj	
		loadMore: ->
			collection.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
	
	$ionicNavBarDelegate.showBackButton false

	
ReservationListCtrl = ($scope, cliModel, locationList, resourceList, timeslotList, inputDate, $filter, $ionicNavBarDelegate, $location) ->
	_.extend $scope,
		locationList: locationList
		resourceList: resourceList
		isGroupShown: (group) ->
			return $scope.shownGroup == group
		toggleGroup: (group) ->
			if $scope.isGroupShown(group)
				$scope.shownGroup = null
			else
				$scope.shownGroup = group
		datepickerObject: { 
			inputDate: new Date,
			callback: (val) ->
				$scope.datePickerCallback(val) }						
		datePickerCallback: (val) ->
			if val
				today = new Date(val)
				today.setHours(0,0,0,0)				
				$scope.datepickerObject.inputDate = new Date($filter('date')(today, 'MMM dd yyyy UTC'))
				$scope.getAvailableTimeslot()
		getAvailableTimeslot: ->
			_.each $scope.resourceList.models, (resource) =>
				resource.available = resource.timeslot.length
				reservationList = new cliModel.ReservationList
				reservationList.$fetch({params: {date: $scope.datepickerObject.inputDate.getTime(), resource: resource._id}}).then ->
					$scope.$apply ->
						_.each resource.timeslot.models, (obj) =>
							obj.date = $scope.datepickerObject.inputDate.getTime()
							@reservation = _.findWhere reservationList.models, {time: "#{obj._id}"}
							if @reservation
								obj.disabled = true
								obj.reservedBy = '[ Reserved by ' + @reservation.createdBy.username + ' ]'
								--resource.available
							else
								obj.disabled = false
								obj.reservedBy = ''		
		create: (resource, date, time) ->			
			$location.url "/reservation/create"
			$location.search "resource", resource
			$location.search "date", date
			$location.search "time", time
			
	$scope.$on 'Select Location', (event, item) ->
		$scope.locationFilter = ''
		if item._id
			$scope.locationFilter = item.name		
			
	$scope.$on 'Select Resource', (event, item) ->
		$scope.resourceFilter = ''
		if item._id
			$scope.resourceFilter = item.name				
	
	$scope.selectLocationList = [new cliModel.Location name: '-- All Locations --']
	_.each $scope.locationList.models, (location) =>
		$scope.selectLocationList.push location	
	$scope.selectResourceList = [new cliModel.Resource name: '-- All Resources --']
	_.each $scope.resourceList.models, (resource) =>
		resource.timeslot = angular.copy(timeslotList)
		$scope.selectResourceList.push resource
	$scope.datepickerObject.inputDate = new Date($filter('date')(inputDate, 'MMM dd yyyy UTC'))		
	$scope.getAvailableTimeslot()				
	$ionicNavBarDelegate.showBackButton false
	

config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]
angular.module('starter.controller').controller 'MenuCtrl', ['$scope', MenuCtrl]
angular.module('starter.controller').controller 'TimeslotCtrl', ['$scope', 'model', '$ionicNavBarDelegate', '$location', TimeslotCtrl]
angular.module('starter.controller').controller 'TimeslotListCtrl', ['$scope', 'collection', '$ionicNavBarDelegate', '$location', TimeslotListCtrl]
angular.module('starter.controller').controller 'LocationCtrl', ['$scope', 'model', '$ionicNavBarDelegate', '$location', LocationCtrl]
angular.module('starter.controller').controller 'LocationListCtrl', ['$scope', 'collection', '$ionicNavBarDelegate', '$location', LocationListCtrl]
angular.module('starter.controller').controller 'ResourceCtrl', ['$scope', 'model', 'locationList', '$ionicNavBarDelegate', '$location', ResourceCtrl]
angular.module('starter.controller').controller 'ResourceListCtrl', ['$scope', 'collection', '$ionicNavBarDelegate', '$location', ResourceListCtrl]
angular.module('starter.controller').controller 'ReservationCtrl', ['$scope', 'cliModel', 'model', 'resourceList', 'timeslotList', '$filter', '$ionicNavBarDelegate', '$location', ReservationCtrl]
angular.module('starter.controller').controller 'MyReservationListCtrl', ['$scope', 'collection', '$ionicNavBarDelegate', '$location', MyReservationListCtrl]
angular.module('starter.controller').controller 'ReservationListCtrl', ['$scope', 'cliModel', 'locationList', 'resourceList', 'timeslotList', 'inputDate', '$filter', '$ionicNavBarDelegate', '$location', ReservationListCtrl]