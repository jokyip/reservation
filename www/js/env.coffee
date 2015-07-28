module.exports =
	isMobile: ->
		/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
	isNative: ->
		/^file/i.test(document.URL)
	platform: ->
		if @isNative() then 'mobile' else 'browser'
	authUrl:	'https://mppsrc.ogcio.hksarg'
	imUrl: () ->
		"https://mppsrc.ogcio.hksarg/im"
	serverUrl: (path = @path) ->
		"https://mppsrc.ogcio.hksarg/#{path}"
	path: 'file'		
	oauth2: ->
		authUrl: "#{@authUrl}/org/oauth2/authorize/"
		opts:
			response_type:	"token"
			scope:			"https://mppsrc.ogcio.hksarg/org/users https://mppsrc.ogcio.hksarg/file https://mppsrc.ogcio.hksarg/xmpp"
			client_id:		if @isNative() then 'fileappPRD' else 'resourceDEVAuth'
			redirectUrl:	if @isNative() then 'http://localhost/callback' else 'http://localhost:3000/file/'