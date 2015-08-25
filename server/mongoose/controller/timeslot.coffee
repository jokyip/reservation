env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
_ = require 'underscore'
Promise = require '../../../promise.coffee'

error = (res, msg) ->
	res.json 500, error: msg

class Timeslot

	@list: (req, res) ->
		model.Timeslot.find().sort({name: 'asc'}).exec (err, timeslot) ->
			if err or timeslot == null
				return error res, if err then err else "timeslot not found"
			res.json timeslot
			
	@create: (req, res) ->
		data = req.body
		data.createdBy = req.user 
		timeslot = new model.Timeslot data
		timeslot.save (err) =>
			if err
				return error res, err
			res.json timeslot			
				
	@read: (req, res) ->
		id = req.param('id')
		model.Timeslot.findById(id).exec (err, timeslot) ->
			if err or timeslot == null
				return error res, if err then err else "timeslot not found"
			res.json timeslot			
			
	@update: (req, res) ->
		id = req.param('id')
		model.Timeslot.findOne {_id: id, __v: req.body.__v}, (err, timeslot) ->
			if err or timeslot == null
				return error res, if err then err else "timeslot not found"
			
			attrs = _.omit req.body, '_id', '__v', 'dateCrated', 'createdBy', 'lastUpdated', 'updatedBy'
			_.map attrs, (value, key) ->
				timeslot[key] = value
			timeslot.updatedBy = req.user
			timeslot.save (err) ->
				if err
					error res, err
				else res.json timeslot				
					
	@delete: (req, res) ->
		id = req.param('id')
		model.Timeslot.findOne {_id: id}, (err, timeslot) ->		
			if err or timeslot == null
				return error res, if err then err else "timeslot not found"
			
			timeslot.remove (err, timeslot) ->
				if err
					error res, err
				else
					res.json {deleted: true}
					
module.exports = 
	Timeslot: 		Timeslot