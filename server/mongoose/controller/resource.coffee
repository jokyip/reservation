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
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
	
		model.Resource.find({}, null, opts).populate('location createdBy').sort({name: 'asc'}).exec (err, resource) ->
			if err
				return error res, err
			model.Resource.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: resource}
			
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
		model.Resource.findById(id).populate('location createdBy').exec (err, resource) ->
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