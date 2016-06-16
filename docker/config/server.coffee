proj = 'reservation'
agent = require 'https-proxy-agent'

app =
	url:	"https://mob.myvnc.com/reservation"
	
oauth2 =
	url:	'https://mob.myvnc.com'
	
env =
	proj:		proj
	pageSize:	10
	log4js: 	require 'log4js'
	
	role:
		all:	'All Users'
		admin:	'Admin'
	
	db:
		url:		"mongodb://#{proj}_mongo/#{proj}"
	
	app:
		url:		app.url
		path:		"/#{proj}"
		uploadDir:	"#{__dirname}/uploads"
		mode:		parseInt('0700', 8)
		
	oauth2:
		url:				app.url
		authorizationURL:	"#{oauth2.url}/org/oauth2/authorize/"
		tokenURL:			"#{oauth2.url}/org/oauth2/token/"
		profileURL:			"#{oauth2.url}/org/api/users/me/"
		verifyURL:			"#{oauth2.url}/org/oauth2/verify/"
		callbackURL:		"#{app.url}/auth/provider/callback"
		provider:			require 'passport-ttsoon'
		authURL:			"/auth/provider"
		cbURL:				"/auth/provider/callback"
		clientID:			"#{proj}UATAuth"
		clientSecret:		'pass1234'
		scope:				[
			"#{oauth2.url}/org/users"
		]
	
	xmpp:
		url:	'https://mppsrc.ogcio.hksarg/im/api/roster/<%= obj.owner %>'
		
	promise:
		timeout:	50000	# ms
	
env.log4js.configure
	appenders:	[ type: 'console' ]
	
module.exports = env