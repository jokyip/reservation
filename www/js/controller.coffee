env = require './env.coffee'

MenuCtrl = ($scope) ->
	$scope.env = env
	$scope.navigator = navigator


TimeslotCtrl = ($scope, model, $location) ->
	_.extend $scope,
		model: model
		save: ->			
			$scope.model.$save().then =>
				$location.url "/timeslot"
	
	
TimeslotListCtrl = ($scope, collection, $location) ->
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
				

LocationCtrl = ($scope, model, $location) ->
	_.extend $scope,
		model: model
		save: ->			
			$scope.model.$save().then =>
				$location.url "/location"
	
	
LocationListCtrl = ($scope, collection, $location) ->
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
	

ResourceCtrl = ($scope, cliModel, model, locationList, $location) ->
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
	
	
ResourceListCtrl = ($scope, collection, $location) ->
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
	
ReservationCtrl = ($scope, cliModel, model, resourceList, timeslotList, $filter, $location, source) ->
	_.extend $scope,
		model: model
		resourceList: resourceList
		timeslotList: timeslotList
		save: ->			
			$scope.model.$save().then =>
				if source == 'date'
					$location.url "/reservation"
					$location.search "date", $scope.datepickerObject.inputDate.getTime()
				else
					$location.url "/reservationByResource"
					$location.search "resource", $scope.model.resource
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
	
	$scope.$on 'Select Resource', (event, item) ->
		$scope.model.resource = item
		$scope.getAvailableTimeslot()
	
	if !$scope.model.resource
		$scope.model.resource = resourceList.models[0] 
	$scope.model.date = new Date($filter('date')(model.date, 'MMM dd yyyy UTC'))	 	
	$scope.getAvailableTimeslot()
	
MyReservationListCtrl = ($scope, collection, $location, $ionicModal) ->
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

	
ReservationListCtrl = ($scope, cliModel, resourceList, timeslotList, inputDate, $filter, $location, $ionicModal) ->
	_.extend $scope,
		resourceList: resourceList
		timeslotList: timeslotList
		previousDay: ->
			$scope.datepickerObject.inputDate.setDate($scope.datepickerObject.inputDate.getDate() - 1)
			$scope.getAvailableTimeslot()
		nextDay: ->
			$scope.datepickerObject.inputDate.setDate($scope.datepickerObject.inputDate.getDate() + 1)
			$scope.getAvailableTimeslot()
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
				reservationList = new cliModel.ReservationList
				reservationList.$fetch({params: {date: $scope.datepickerObject.inputDate.getTime(), resource: resource._id}}).then ->
					$scope.$apply ->
						_.each resource.timeslot.models, (obj) =>
							obj.date = $scope.datepickerObject.inputDate.getTime()
							@reservation = _.findWhere reservationList.models, {time: "#{obj._id}"}
							if @reservation
								obj.disabled = true
								obj.reservedBy = @reservation.createdBy
							else
								obj.disabled = false
								obj.reservedBy = ''		
		create: (resource, date, time) ->			
			$location.url "/reservation/create"
			$location.search "resource", resource
			$location.search "date", date
			$location.search "time", time
			$location.search "source", "date"
		modalViewResource: (resource) ->
			$scope.model = resource	
			$ionicModal.fromTemplateUrl("templates/resource/modal.html", scope: $scope)
				.then (modal) ->
					_.extend $scope,
						modal:	modal						
						close:	->
							modal.remove()
					modal.show()
		modalViewUser: (user) ->
			$scope.model = user	
			$ionicModal.fromTemplateUrl("templates/user/modal.html", scope: $scope)
				.then (modal) ->
					_.extend $scope,
						modal:	modal						
						close:	->
							modal.remove()
					modal.show()							

	_.each $scope.resourceList.models, (resource) =>
		resource.timeslot = angular.copy(timeslotList)
	$scope.datepickerObject.inputDate = new Date($filter('date')(inputDate, 'MMM dd yyyy UTC'))		
	$scope.getAvailableTimeslot()

	
ReservationByResourceListCtrl = ($scope, cliModel, resourceList, timeslotList, $filter, $location, $ionicModal, resource) ->
	_.extend $scope,
		resource: resource
		resourceList: resourceList
		timeslotList: timeslotList
		getAvailableTimeslot: ->
			_.each $scope.dateList, (dateObj) =>
				reservationList = new cliModel.ReservationList
				reservationList.$fetch({params: {date: dateObj.date, resource: $scope.resource._id}}).then ->
					$scope.$apply ->
						_.each dateObj.timeslot.models, (obj) =>
							@reservation = _.findWhere reservationList.models, {time: "#{obj._id}"}
							if @reservation
								obj.disabled = true
								obj.reservedBy = @reservation.createdBy
							else
								obj.disabled = false
								obj.reservedBy = ''		
		create: (resource, date, time) ->			
			$location.url "/reservation/create"
			$location.search "resource", resource
			$location.search "date", date
			$location.search "time", time
			$location.search "source", "resource"
		getNewList: ->
			$scope.dateList = []
			$scope.endDate = new Date
			$scope.getList()	
		getList: ->
			return new Promise (fulfill, reject) ->
				$scope.startDate = new Date($filter('date')($scope.endDate, 'MMM dd yyyy UTC'))
				$scope.endDate = new Date($filter('date')($scope.startDate, 'MMM dd yyyy UTC'))
				$scope.endDate.setDate($scope.endDate.getDate() + 12)
				previousList = angular.copy($scope.dateList)					
				$scope.dateList = []
				currDate = new Date($scope.startDate)
				while currDate < $scope.endDate
					$scope.dateList.push {date: (new Date(currDate)).getTime(), timeslot: angular.copy(timeslotList)}
					currDate.setDate(currDate.getDate() + 1)
				$scope.getAvailableTimeslot()
				$scope.dateList = previousList.concat($scope.dateList) 
				fulfill @
		loadMore: ->
			$scope.getList($scope.endDate).then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
		modalViewResource: ->
			$scope.model = $scope.resource	
			$ionicModal.fromTemplateUrl("templates/resource/modal.html", scope: $scope)
				.then (modal) ->
					_.extend $scope,
						modal:	modal						
						close:	->
							modal.remove()
					modal.show()
		modalViewUser: (user) ->
			$scope.model = user	
			$ionicModal.fromTemplateUrl("templates/user/modal.html", scope: $scope)
				.then (modal) ->
					_.extend $scope,
						modal:	modal						
						close:	->
							modal.remove()
					modal.show()							

	$scope.$on 'Select Resource', (event, item) ->
		$scope.resource = item
		$scope.getNewList()
	
	if !$scope.resource
		$scope.resource = resourceList.models[0]
	$scope.getNewList()			
	

config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]
angular.module('starter.controller').controller 'MenuCtrl', ['$scope', MenuCtrl]
angular.module('starter.controller').controller 'TimeslotCtrl', ['$scope', 'model', '$location', TimeslotCtrl]
angular.module('starter.controller').controller 'TimeslotListCtrl', ['$scope', 'collection', '$location', TimeslotListCtrl]
angular.module('starter.controller').controller 'LocationCtrl', ['$scope', 'model', '$location', LocationCtrl]
angular.module('starter.controller').controller 'LocationListCtrl', ['$scope', 'collection', '$location', LocationListCtrl]
angular.module('starter.controller').controller 'ResourceCtrl', ['$scope', 'cliModel', 'model', 'locationList', '$location', ResourceCtrl]
angular.module('starter.controller').controller 'ResourceListCtrl', ['$scope', 'collection', '$location', ResourceListCtrl]
angular.module('starter.controller').controller 'ReservationCtrl', ['$scope', 'cliModel', 'model', 'resourceList', 'timeslotList', '$filter', '$location', 'source', ReservationCtrl]
angular.module('starter.controller').controller 'MyReservationListCtrl', ['$scope', 'collection', '$location', '$ionicModal', MyReservationListCtrl]
angular.module('starter.controller').controller 'ReservationListCtrl', ['$scope', 'cliModel', 'resourceList', 'timeslotList', 'inputDate', '$filter', '$location', '$ionicModal', ReservationListCtrl]
angular.module('starter.controller').controller 'ReservationByResourceListCtrl', ['$scope', 'cliModel', 'resourceList', 'timeslotList', '$filter', '$location', '$ionicModal', 'resource', ReservationByResourceListCtrl]