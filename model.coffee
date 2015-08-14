fs = require 'fs'
_ = require 'underscore'
env = require './env'
path = require 'path'
mongoose = require 'mongoose'
findOrCreate = require 'mongoose-findorcreate'
taggable = require 'mongoose-taggable'
Promise = require './promise.coffee'

mongoose.connect env.db.url, { db: { safe: true }}, (err) ->
  	if err
  		console.log "Mongoose - connection error: #{err}"
  	else console.log "Mongoose - connection OK"

###
	perm = domain:action:obj
### 
PermissionSchema = new mongoose.Schema
	order:		{ type: Number }
	userGrp:	{ type: String, required: true }
	fileGrp:	{ type: String, required: true }
	action:		[ { type: String } ]
	createdBy:	{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }

PermissionSchema.statics =
	ordering_fields: ->
		order: 1, userGrp: 1, fileGrp: 1
		
PermissionSchema.methods =
	implies: (user, file, action) ->
		if not _.contains file.tags @fileGrp
			return false
	
PermissionSchema.plugin(findOrCreate)

Permission = mongoose.model 'Permission', PermissionSchema
			
TagSchema = new mongoose.Schema
	name:			{ type: String, required: true, index: {unique: true} }
	permissions:	[ { type: String } ]
	
TagSchema.plugin(findOrCreate)

Tag = mongoose.model 'Tag', TagSchema
	
UserSchema = new mongoose.Schema
	url:			{ type: String, required: true, index: {unique: true} }
	username:		{ type: String, required: true }
	email:			{ type: String }
	
UserSchema.statics =
	search_fields: ->
		return ['username', 'email']
	ordering_fields: ->
		return ['username', 'email']
	ordering: ->
		return 'username'
	isUser: (oid) ->
		p = @findById(oid).exec()
		p1 = p.then (user) ->
			return user != null
		p1.then null, (err) ->
			return false		
		
UserSchema.methods =
	checkPermission: (perm) ->
		q = @model('Tag').find(name: $in: @tags).exec()
		q.then (perms) ->
			_.some perms, (r) ->
				_.some r.permissions, (p) ->
					p = new Permission(p)
					p.implies perm
	checkPermissions: (perms) ->
		promises = _.map perms, (p) ->
			@checkPermission(p)
		Promise.all(promises).done (permitted) ->
			_.all permitted
			
UserSchema.plugin(findOrCreate)
UserSchema.plugin(taggable)

UserSchema.pre 'save', (next) ->
	@addTag(env.role.all)
	@increment()
	next()
User = mongoose.model 'User', UserSchema

class FileUtil 
	@abspath: (path) ->
		"#{env.app.uploadDir}/#{path}"
			
	@isDir: (path) ->
		/\/$/.test path
		
	@isRealDir: (path) ->
		fs.statSync(FileUtil.abspath(path)).isDirectory()
		
	# ignore exception if path already exists
	@newDir: (path) ->
		try 
			fs.mkdirSync FileUtil.abspath(path), env.app.mode
		catch
			return
	
	@newFile: (path) ->
		fs.openSync FileUtil.abspath(path), 'w', env.app.mode
		
	@rm: (path) ->
		func = if FileUtil.isDir(path) then fs.rmdirSync else fs.unlinkSync 
		func FileUtil.abspath(path)
	
FileSchema = new mongoose.Schema
	path:			{ type: String, index: {unique: true} }
	dir:			{ type: String }
	name:			{ type: String }
	ext:			{ type: String }
	isdir:			{ type: Boolean }
	contentType:	{ type: String }
	size:			{ type: Number }			
	atime:			{ type: Date }
	ctime:			{ type: Date }			
	mtime:			{ type: Date }
	createdBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	updatedBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	
FileSchema.statics =
	search_fields: ->
		return ['name']
	ordering_fields: ->
		return ['path']
	ordering: ->
		return 'path'

FileSchema.methods =
	rename: (newname) ->
		@path = "#{@dirname()}/#{newname}#{if @isDir() then '/' else ''}"
	dirname: ->
		path.dirname @path
	basename: ->
		path.basename @path
	extname: ->
		path.extname @path
	isFile: ->
		not @isDir
	isDir: ->
		FileUtil.isRealDir(@path)
		
FileSchema.plugin(findOrCreate)
FileSchema.plugin(taggable)

FileSchema.path('path').set (newpath) ->
	@oldpath = @path
	return newpath
	
FileSchema.pre 'save', (next) ->
	try
		if @isNew
			func = if FileUtil.isDir(@path) then FileUtil.newDir else FileUtil.newFile
			func @path
		else
			fs.renameSync FileUtil.abspath(@oldpath), FileUtil.abspath(@path)
			 
		@dir = @dirname()
		@name = @basename()
		@ext = @extname()
		@isdir = @isDir()
		if FileUtil.isDir(@path)
			@contentType = 'text/directory'
		@increment()
		
		success = =>
			stat = fs.statSync FileUtil.abspath(@path)
			_.extend @, _.pick(stat, 'size', 'atime', 'ctime', 'mtime')
			next()
			
		if @stream?
			out = fs.createWriteStream FileUtil.abspath(@path), mode: env.app.mode
			@stream.pipe(out)
			out.on 'finish', =>
				success()
		else		
			success()
	catch e
		next(e)

FileSchema.pre 'remove', (next) ->
	try
		FileUtil.rm @path
		next()
	catch e
		next(e)

File = mongoose.model 'File', FileSchema

# Location Schema
LocationSchema = new mongoose.Schema
	name:			{ type: String }
	createdBy:	{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	
LocationSchema.statics =
	ordering_fields: ->
		name: 1	
	
LocationSchema.plugin(findOrCreate)

# function you have to find a location, or to create one if the location doesn't exist
Location = mongoose.model 'Location', LocationSchema	


# Resource Schema
ResourceSchema = new mongoose.Schema
	name:			{ type: String }
	createdBy:	{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	
ResourceSchema.statics =
	ordering_fields: ->
		name: 1	
	
ResourceSchema.plugin(findOrCreate)

# function you have to find a resource, or to create one if the resource doesn't exist
Resource = mongoose.model 'Resource', ResourceSchema	


# Reservation Schema
ReservationSchema = new mongoose.Schema
	resource:		{ type: mongoose.Schema.Types.ObjectId, ref: 'Resource' }
	purpose:		{ type: String }
	date:			{ type: Date }
	time:			{ type: String }
	createdBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }
	
ReservationSchema.statics =
	ordering_fields: ->
		date: 1, time: 1	
	
ReservationSchema.plugin(findOrCreate)

# function you have to find a resource, or to create one if the resource doesn't exist
Reservation = mongoose.model 'Reservation', ReservationSchema

module.exports = 
	Permission:	Permission
	Tag:		Tag
	User: 		User
	FileUtil:	FileUtil
	File: 		File
	Location:	Location
	Resource:	Resource
	Reservation:	Reservation