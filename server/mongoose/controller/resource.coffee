env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
_ = require 'underscore'
Promise = require '../../../promise.coffee'

error = (res, msg) ->
	res.json 500, error: msg

class Resource

	@list: (req, res) ->
		model.Resource.find().exec (err, resource) ->
			if err or resource == null
				return error res, if err then err else "resource not found"
			res.json resource
			
	@create: (req, res) ->
		data = req.body
		data.createdBy = req.user 
		resource = new model.Resource data
		resource.save (err) =>
			if err
				return error res, err
			res.json resource			
				
	@read: (req, res) ->
		id = req.param('id')
		model.Resource.findById(id).exec (err, resource) ->
			if err or resource == null
				return error res, if err then err else "resource not found"
			res.json resource			
			
	@update: (req, res) ->
		id = req.param('id')
		model.Resource.findOne {_id: id, __v: req.body.__v}, (err, resource) ->
			if err or resource == null
				return error res, if err then err else "resource not found"
			
			attrs = _.omit req.body, '_id', '__v', 'dateCrated', 'createdBy', 'lastUpdated', 'updatedBy'
			_.map attrs, (value, key) ->
				resource[key] = value
			resource.updatedBy = req.user
			resource.save (err) ->
				if err
					error res, err
				else res.json resource				
					
	@delete: (req, res) ->
		id = req.param('id')
		model.Resource.findOne {_id: id}, (err, resource) ->		
			if err or resource == null
				return error res, if err then err else "resource not found"
			
			resource.remove (err, resource) ->
				if err
					error res, err
				else
					res.json {deleted: true}
					
module.exports = 
	Resource: 		Resource