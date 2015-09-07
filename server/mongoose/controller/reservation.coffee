env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
_ = require 'underscore'
Promise = require '../../../promise.coffee'
logger = env.log4js.getLogger('reservation.coffee')

error = (res, msg) ->
	res.json 500, error: msg

class Reservation

	@mylist: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			sort: {date: 1, time: 1, purpose: 1, resource: 1}
			
		model.Reservation.find({createdBy: req.user}, null, opts).populate('time resource createdBy').exec (err, reservation) ->
			if err
				return error res, err
			model.Reservation.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: reservation}

	@list: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
	
		model.Reservation.find({date: req.query.date, resource: req.query.resource}, null, opts).populate('resource createdBy').exec (err, reservation) ->
			if err
				return error res, err
			model.Reservation.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: reservation}
			
	@create: (req, res) ->
		data = req.body
		data.createdBy = req.user
		reservation = new model.Reservation data
		reservation.save (err) =>
			if err
				return error res, err
			res.json reservation			
				
	@read: (req, res) ->
		id = req.param('id')
		model.Reservation.findById(id).populate('resource createdBy').exec (err, reservation) ->
			if err or reservation == null
				return error res, if err then err else "reservation not found"
			res.json reservation			
			
	@update: (req, res) ->
		id = req.param('id')
		model.Reservation.findOne({_id: id, __v: req.body.__v}).populate('resource time createdBy').exec (err, reservation) ->
			if err or reservation == null
				return error res, if err then err else "reservation not found"
			
			attrs = _.omit req.body, '_id', '__v', 'dateCreated', 'createdBy', 'lastUpdated', 'updatedBy'
			_.map attrs, (value, key) ->
				reservation[key] = value
			reservation.updatedBy = req.user
			reservation.save (err) ->
				if err
					error res, err
				else res.json reservation				
					
	@delete: (req, res) ->
		id = req.param('id')
		model.Reservation.findOne {_id: id}, (err, reservation) ->		
			if err or reservation == null
				return error res, if err then err else "reservation not found"
			
			reservation.remove (err, reservation) ->
				if err
					error res, err
				else
					res.json {deleted: true}
					
module.exports = 
	Reservation: 		Reservation