module.exports =
	isMobile: ->
		/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
	isNative: ->
		/^file/i.test(document.URL)
	platform: ->
		if @isNative() then 'mobile' else 'browser'
	authUrl:	'https://mob.myvnc.com'
	imUrl: () ->
		"https://mppsrc.ogcio.hksarg/im"
	serverUrl: (path = @path) ->
		"https://mob.myvnc.com/#{path}"
	path: 'reservation'		
	oauth2: ->
		authUrl: "#{@authUrl}/org/oauth2/authorize/"
		opts:
			response_type:	"token"
			scope:			"https://mob.myvnc.com/org/users https://mob.myvnc.com/file https://mob.myvnc.com/xmpp"
			client_id:		if @isNative() then 'reservationDEVAuth' else 'reservationDEVAuth'			