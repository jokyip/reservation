module.exports =
	isMobile: ->
		/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
	isNative: ->
		/^file/i.test(document.URL)
	platform: ->
		if @isNative() then 'mobile' else 'browser'
	authUrl:	'https://mob.myvnc.com'
	imUrl: () ->
		"https://mob.myvnc.com/im"
	serverUrl: (path = @path) ->
		"https://mob.myvnc.com/#{path}"
	path: 'reservation'		
	oauth2: ->
		authUrl: "#{@authUrl}/org/oauth2/authorize/"
		opts:
			response_type:	"token"
			scope:			"https://mob.myvnc.com/org/users"
			client_id:		if @isNative() then 'reservationUATAuth' else 'reservationUATAuth'			