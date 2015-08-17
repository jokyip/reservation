env = require './env.coffee'

AppCtrl = ($rootScope, $scope, $http, platform, authService, model) ->	
	# set authorization header once mobile authentication completed
	fulfill = (data) ->
		if data?
			$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
			authService.loginConfirmed()
	
	$scope.$on 'event:auth-forbidden', ->
		platform.auth().then fulfill, alert
	$scope.$on 'event:auth-loginRequired', ->
		platform.auth().then fulfill, alert
	
MenuCtrl = ($scope) ->
	$scope.env = env
	$scope.navigator = navigator
				
FileCtrl = ($rootScope, $scope, $stateParams, $location, $ionicModal, model) ->
	class FileView
	
		events:
			'change:folder':	'cd'
			'new:folder':		'md'
		
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@model = opts.model
			
		home: ->
			$location.url("file/file/")
		
		cd: (folder = null) ->
			if _.isEmpty folder or _.isNull folder or _.isUndefined folder
				model.User.me()
					.then (user) =>
						@model.path = "#{user.username}/"
						@loadMore()
					.catch alert
			else
				@model.path = folder
				@loadMore()
			
		md: (folder = 'New Folder/') ->
			folder = new model.File path: "#{@model.path}#{folder}"
			folder.$save()
				.then =>
					@model.add folder
				.catch alert
				
		# read next page of files under current path
		loadMore: ->
			@model.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
			return @
		
		# update properties of specified file
		edit: ->
			$ionicModal.fromTemplateUrl('templates/file/edit.html', scope: $scope).then (modal) =>
				$scope.model.newname = $scope.model.name
				$scope.modal = modal
				$scope.modal.show()
				
		remove: (file) ->
			@model.remove(file)
			
		upload: (files) ->
			_.each files, (local) =>
				remote = (_.findWhere @model.models, name: local.name) || new model.File path: "#{@model.path}#{local.name}"
				remote.$save {file: local}
					.then =>
						@model.add remote
					.catch alert

	if _.isUndefined $scope.model
		$scope.model = new model.File path: $stateParams.path
		$scope.model.$fetch()
	$scope.controller = new FileView(model: $scope.model)
		
	$scope.$watchCollection 'files', (newfiles, oldfiles) ->
		if newfiles?.length? and newfiles?.length != oldfiles?length
			$scope.controller.upload newfiles
		
	$scope.$watchCollection 'model.tags', (newtags, oldtags) ->
		if newtags?.length != oldtags?.length
			$scope.model.$save().catch alert
			
	###
	$scope.$watch 'model.path', (newpath, oldpath) ->
		if newpath != oldpath
			$scope.controller.cd(newpath)
	###

SelectCtrl = ($scope, $ionicModal) ->
	class SelectView
		select: (@name, @model, @collection) ->
			$ionicModal.fromTemplateUrl('templates/permission/select.html', scope: $scope).then (modal) =>
				@modal = modal
				@modal.show()
				
		ok: ->
			$scope.$emit @name, @model 
			@modal.remove()
			
		cancel: ->
			_.extend @model, @model.previousAttributes
			@modal.remove()
			
	$scope.controller = new SelectView()
	
MultiSelectCtrl = ($scope, $ionicModal) ->
	class MultiSelectView
		# model: array of selected values
		select: (@name, @model, @collection) ->
			$ionicModal.fromTemplateUrl('templates/permission/multiselect.html', scope: $scope).then (modal) =>
				@modal = modal
				@modal.show()
		
		selected: (value) ->
			_.contains @model, value
			
		ok: ->
			@model = _.map $(@modal.$el).find('input:checked'), (el) ->
				el.name
			$scope.$emit @name, @model
			@modal.remove()
			
		cancel: ->
			_.extend @model, @model.previousAttributes
			@modal.remove()
			
	$scope.controller = new MultiSelectView()
	
PermissionCtrl = ($rootScope, $scope, $ionicModal, model) ->
	class PermissionView
		modelEvents:
			userGrp:	'update'
			fileGrp:	'update'
			action:		'update'
		
		constructor: (opts = {}) ->
			@model = opts.model
			
			_.each @modelEvents, (handler, event) =>
				$scope.$on event, @[handler]
			
		update: (event, value) =>
			@model[event.name] = value
			
		save: ->
			@model.$save().catch alert
										
	$scope.controller = new PermissionView model: $scope.model
		
AclCtrl = ($rootScope, $scope, model) ->
	class AclView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@collection = opts.collection
			
			$scope.userGrps = new model.UserGrps()
			$scope.userGrps.$fetch()
			
			$scope.fileGrps = new model.FileGrps()
			$scope.fileGrps.$fetch()
			
			$scope.actions = new model.Collection(['read', 'write'])
				
		loadMore: ->
			@collection.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
				
		add: ->
			@collection.add new model.Permission
				userGrp:	''
				fileGrp:	''
				action:		[]
				
		remove: (perm) ->
			@collection.remove perm
	
	$scope.collection = new model.Acl()
	$scope.collection.$fetch()
	$scope.controller = new AclView collection: $scope.collection

LocationCtrl = ($rootScope, $scope, $ionicModal, model, $stateParams, $state, $ionicNavBarDelegate) ->
	class LocationView		
		constructor: (opts = {}) ->
			@model = opts.model
			
			_.each @modelEvents, (handler, event) =>
				$scope.$on event, @[handler]
				
		edit: ->
			$state.transitionTo 'app.locationCreate', { model: $scope.model }, { reload: true }
						
		ok: ->
			$scope.model.$save({name: $scope.model.name}).then =>
				$state.transitionTo 'app.location', {}, { reload: true }
						
		cancel: ->
			_.extend @model, @model.previousAttributes
			$scope.modal.hide();

	if $stateParams.model
		$scope.model = $stateParams.model
	$scope.controller = new LocationView model: $scope.model
	
	$ionicNavBarDelegate.showBackButton true
	
LocationListCtrl = ($rootScope, $scope, model, $state) ->
	class LocationListView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@collection = opts.collection
			
		create: ->
			$state.transitionTo 'app.locationCreate', { model: new model.Location }, { reload: true }	
				
		loadMore: ->
			@collection.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
				
		remove: (perm) ->
			@collection.remove perm
	
	$scope.collection = new model.LocationList()
	$scope.collection.$fetch()
	$scope.controller = new LocationListView collection: $scope.collection

ResourceCtrl = ($rootScope, $scope, $ionicModal, model, $stateParams, $state, $ionicNavBarDelegate) ->
	class ResourceView		
		constructor: (opts = {}) ->
			@model = opts.model
			
			_.each @modelEvents, (handler, event) =>
				$scope.$on event, @[handler]
			
			$scope.locationList = new model.LocationList()
			$scope.locationList.$fetch()
				
			$scope.$on 'selectedLocation', (event, item) ->
				$scope.model.location = item
				
		edit: ->
			$state.transitionTo 'app.resourceEdit', { model: $scope.model }, { reload: true }
						
		ok: ->
			$scope.model.$save().then =>
				$state.transitionTo 'app.resource', {}, { reload: true }
						
		cancel: ->
			_.extend @model, @model.previousAttributes
			$scope.modal.hide();

	if $stateParams.model
		$scope.model = $stateParams.model
	$scope.controller = new ResourceView model: $scope.model
	
	$ionicNavBarDelegate.showBackButton true
	
ResourceListCtrl = ($rootScope, $scope, model, $state) ->
	class ResourceListView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@collection = opts.collection
			
		create: ->
			$state.transitionTo 'app.resourceCreate', { model: new model.Resource }, { reload: true }	
				
		loadMore: ->
			@collection.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
				
		remove: (perm) ->
			@collection.remove perm
	
	$scope.collection = new model.ResourceList()
	$scope.collection.$fetch()
	$scope.controller = new ResourceListView collection: $scope.collection
	
	
ReservationCtrl = ($rootScope, $scope, $ionicModal, $filter, model, $stateParams, $state, $ionicNavBarDelegate) ->
	class ReservationView		
		constructor: (opts = {}) ->
			@model = opts.model
			
			_.each @modelEvents, (handler, event) =>
				$scope.$on event, @[handler]
				
			$scope.$on 'modal.removed', ->					    		
	    		$scope.$parent.controller.collection.$fetch()
	    		$scope.$parent.model?.$fetch()

			$scope.resourceList = new model.ResourceList()
			$scope.resourceList.$fetch()		
			
			$scope.timeslot = [
				{ value:'09:00 - 11:00' },
			    { value:'11:00 - 13:00' },
			    { value:'13:00 - 14:00' },
			    { value:'14:00 - 16:00' },
			    { value:'16:00 - 18:00' }
			];

		getAvailableTimeslot: ->
			$scope.model.time = ''
			reservationList = new model.ReservationList()
			reservationList.$fetch({params: {date: $scope.model.date, resource: $scope.model.resource._id}}).then ->
				$scope.$apply ->
					_.each $scope.timeslot, (obj) =>
						@reservation = _.findWhere reservationList.models, {time: "#{obj.value}"}
						if @reservation
							obj.disabled = true
							obj.reservedBy = '[ Reserved by ' + @reservation.createdBy.username + ' ]'
						else
							obj.disabled = false
							obj.reservedBy = ''
				
		ok: ->
			$scope.model.$save().then =>
				$state.transitionTo 'app.reservation', { date: $scope.model.date }, { reload: true }
						
		cancel: ->
			_.extend @model, @model?.previousAttributes
			$state.go 'app.reservation',{},{reload: true}
	
	$scope.model = new model.Reservation
	$scope.model.resource = $stateParams.resource
	$scope.model.date = $stateParams.date
	$scope.currentDate = $stateParams.date
	$scope.controller = new ReservationView collection: $scope.model
	$scope.controller.getAvailableTimeslot().then =>
		$scope.model.time = $stateParams.time
	
	$scope.datePickerCallback = (val) ->
		if val
			$scope.model.date = val
			$scope.controller.getAvailableTimeslot()
		return
		
	$scope.$on 'selectedResource', (event, item) ->
		$scope.model.resource = item
		$scope.controller.getAvailableTimeslot()	    	
		
	$ionicNavBarDelegate.showBackButton true
	
MyReservationListCtrl = ($rootScope, $scope, model, $state) ->
	class MyReservationListView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@collection = opts.collection
			
		create: ->
			$state.transitionTo 'app.reservationCreate', { date: new Date }, { reload: true }	
				
		loadMore: ->
			@collection.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
				
		remove: (perm) ->
			@collection.remove perm
					
	$scope.collection = new model.MyReservationList()
	$scope.collection.$fetch()
	$scope.controller = new MyReservationListView collection: $scope.collection
	
ReservationListCtrl = ($rootScope, $scope, model, $filter, $stateParams, $state, $ionicNavBarDelegate) ->
	class ReservationListView		
		constructor: (opts = {}) ->
			@collection = opts.collection
			@currentDate = opts.currentDate
			
			_.each @modelEvents, (handler, event) =>
				$scope.$on event, @[handler]
	
			$scope.toggleGroup = (group) ->
				if $scope.isGroupShown(group)
					$scope.shownGroup = null
				else
					$scope.shownGroup = group	
			
			$scope.isGroupShown = (group) ->
				return $scope.shownGroup == group
			
			_.each @collection.models, (resource) =>
				resource.timeslot = [
					{ value:'09:00 - 11:00' },
				    { value:'11:00 - 13:00' },
				    { value:'13:00 - 14:00' },
				    { value:'14:00 - 16:00' },
				    { value:'16:00 - 18:00' }
				]
			
			@currentDate.setHours(0)
			@currentDate.setMinutes(0)
			@currentDate.setSeconds(0)
			@currentDate.setMilliseconds(0)
			@getAvailableTimeslot(@currentDate)
			
		edit: (resource, date, time) ->
			$state.go 'app.reservationCreate', { resource: resource, date: date, time: time }	
				
		getAvailableTimeslot: (date) ->
			_.each @collection.models, (resource) =>
				resource.available = resource.timeslot.length				
				reservationList = new model.ReservationList()
				reservationList.$fetch({params: {date: date, resource: resource._id}}).then ->
					$scope.$apply ->
						_.each resource.timeslot, (obj) =>
							obj.date = date
							@reservation = _.findWhere reservationList.models, {time: "#{obj.value}"}
							if @reservation
								obj.disabled = true
								obj.reservedBy = '[ Reserved by ' + @reservation.createdBy.username + ' ]'
								--resource.available
							else
								obj.disabled = false
								obj.reservedBy = ''
	
	currDate = new Date	
	if $stateParams.date
		currDate = $stateParams.date
	$scope.currentDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
																													
	$scope.collection = new model.ResourceList()
	$scope.collection.$fetch().then =>
		$scope.controller = new ReservationListView collection: $scope.collection, currentDate: $scope.currentDate
		
	$scope.datePickerCallback = (val) ->
		if val
			$scope.currentDate = new Date($filter('date')(val, 'MMM dd yyyy UTC'))
			$scope.controller.getAvailableTimeslot(val)
		return
	
	$ionicNavBarDelegate.showBackButton false

config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]	
angular.module('starter.controller').controller 'AppCtrl', ['$rootScope', '$scope', '$http', 'platform', 'authService', 'model', AppCtrl]
angular.module('starter.controller').controller 'MenuCtrl', ['$scope', MenuCtrl]
angular.module('starter.controller').controller 'FileCtrl', ['$rootScope', '$scope', '$stateParams', '$location', '$ionicModal', 'model', FileCtrl]
angular.module('starter.controller').controller 'PermissionCtrl', ['$rootScope', '$scope', '$ionicModal', 'model', PermissionCtrl]
angular.module('starter.controller').controller 'AclCtrl', ['$rootScope', '$scope', 'model', AclCtrl]
angular.module('starter.controller').controller 'SelectCtrl', ['$scope', '$ionicModal', SelectCtrl]
angular.module('starter.controller').controller 'MultiSelectCtrl', ['$scope', '$ionicModal', MultiSelectCtrl]
angular.module('starter.controller').controller 'LocationCtrl', ['$rootScope', '$scope', '$ionicModal', 'model', '$stateParams', '$state', '$ionicNavBarDelegate', LocationCtrl]
angular.module('starter.controller').controller 'LocationListCtrl', ['$rootScope', '$scope', 'model', '$state', LocationListCtrl]
angular.module('starter.controller').controller 'ResourceCtrl', ['$rootScope', '$scope', '$ionicModal', 'model', '$stateParams', '$state', '$ionicNavBarDelegate', ResourceCtrl]
angular.module('starter.controller').controller 'ResourceListCtrl', ['$rootScope', '$scope', 'model', '$state', ResourceListCtrl]
angular.module('starter.controller').controller 'ReservationCtrl', ['$rootScope', '$scope', '$ionicModal', '$filter', 'model', '$stateParams', '$state', '$ionicNavBarDelegate', ReservationCtrl]
angular.module('starter.controller').controller 'MyReservationListCtrl', ['$rootScope', '$scope', 'model', '$state', MyReservationListCtrl]
angular.module('starter.controller').controller 'ReservationListCtrl', ['$rootScope', '$scope', 'model', '$filter', '$stateParams', '$state', '$ionicNavBarDelegate', ReservationListCtrl]