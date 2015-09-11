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
				

LocationCtrl = ($scope, model, $ionicNavBarDelegate, $location) ->
	_.extend $scope,
		model: model
		save: ->			
			$scope.model.$save().then =>
				$location.url "/location"
	
	
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
	

ResourceCtrl = ($scope, cliModel, model, locationList, $ionicNavBarDelegate, $location) ->
	_.extend $scope,
		model: model
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
	
	$scope.selectLocationList = [new cliModel.Location name: '-- Please select location --', label: '-- Please select location --']
	_.each locationList.models, (location) =>
		location.label = location.name
		$scope.selectLocationList.push location

	cliModel.User.me().then (user) =>
		$scope.me = user
	
	
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
			modalHeaderColor: 'bar-positive',
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
	
MyReservationListCtrl = ($scope, collection, $ionicNavBarDelegate, $location, $ionicModal) ->
	_.extend $scope,
		collection: collection
		create: ->
			$location.url "/reservation/create"
		delete: (obj) ->
			collection.remove obj
		edit: (obj) ->
			$scope.model = obj
			$ionicModal.fromTemplateUrl("templates/reservation/edit.html", scope: $scope)
				.then (modal) ->
					_.extend $scope,
						modal:	modal
						
						close:	->
							modal.remove()
						
						save: ->
							$scope.model.$save().then =>
								$scope.close()
								
					modal.show()		
		loadMore: ->
			collection.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert

	
ReservationListCtrl = ($scope, cliModel, locationList, resourceList, timeslotList, inputDate, $filter, $ionicNavBarDelegate, $location, $ionicModal) ->
	_.extend $scope,
		locationList: locationList
		resourceList: resourceList
		timeslotList: timeslotList
		isGroupShown: (group) ->
			return $scope.shownGroup == group
		toggleGroup: (group) ->
			if $scope.isGroupShown(group)
				$scope.shownGroup = null
			else
				$scope.shownGroup = group
		previousDay: ->
			$scope.datepickerObject.inputDate.setDate($scope.datepickerObject.inputDate.getDate() - 1)
			$scope.getAvailableTimeslot()
		nextDay: ->
			$scope.datepickerObject.inputDate.setDate($scope.datepickerObject.inputDate.getDate() + 1)
			$scope.getAvailableTimeslot()
		datepickerObject: { 
			inputDate: new Date,
			modalHeaderColor: 'bar-positive',
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
								obj.reservedBy = '[ ' + @reservation.createdBy.username + ' ]'
								--resource.available
							else
								obj.disabled = false
								obj.reservedBy = ''		
		create: (resource, date, time) ->			
			$location.url "/reservation/create"
			$location.search "resource", resource
			$location.search "date", date
			$location.search "time", time
		modalViewResource: (resource) ->
			$scope.model = resource	
			$ionicModal.fromTemplateUrl("templates/resource/modal.html", scope: $scope)
				.then (modal) ->
					_.extend $scope,
						modal:	modal						
						close:	->
							modal.remove()
					modal.show()				
			
	$scope.$on 'Select Location', (event, item) ->
		$scope.locationFilter = ''
		$scope.resourceFilter = ''
		if item._id
			$scope.locationFilter = item.name			
		$scope.selectResourceList = [new cliModel.Resource name: '-- All Resources --', label: '-- All Resources --']
		locationList = $filter('filter')($scope.resourceList.models, $scope.locationFilter)
		_.each locationList, (resource) =>
			$scope.selectResourceList.push resource
		angular.element($('#selectResource')).scope().item2 = $scope.selectResourceList[0]	
			
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
	

config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]
angular.module('starter.controller').controller 'MenuCtrl', ['$scope', MenuCtrl]
angular.module('starter.controller').controller 'TimeslotCtrl', ['$scope', 'model', '$ionicNavBarDelegate', '$location', TimeslotCtrl]
angular.module('starter.controller').controller 'TimeslotListCtrl', ['$scope', 'collection', '$ionicNavBarDelegate', '$location', TimeslotListCtrl]
angular.module('starter.controller').controller 'LocationCtrl', ['$scope', 'model', '$ionicNavBarDelegate', '$location', LocationCtrl]
angular.module('starter.controller').controller 'LocationListCtrl', ['$scope', 'collection', '$ionicNavBarDelegate', '$location', LocationListCtrl]
angular.module('starter.controller').controller 'ResourceCtrl', ['$scope', 'cliModel', 'model', 'locationList', '$ionicNavBarDelegate', '$location', ResourceCtrl]
angular.module('starter.controller').controller 'ResourceListCtrl', ['$scope', 'collection', '$ionicNavBarDelegate', '$location', ResourceListCtrl]
angular.module('starter.controller').controller 'ReservationCtrl', ['$scope', 'cliModel', 'model', 'resourceList', 'timeslotList', '$filter', '$ionicNavBarDelegate', '$location', ReservationCtrl]
angular.module('starter.controller').controller 'MyReservationListCtrl', ['$scope', 'collection', '$ionicNavBarDelegate', '$location', '$ionicModal', MyReservationListCtrl]
angular.module('starter.controller').controller 'ReservationListCtrl', ['$scope', 'cliModel', 'locationList', 'resourceList', 'timeslotList', 'inputDate', '$filter', '$ionicNavBarDelegate', '$location', '$ionicModal', ReservationListCtrl]