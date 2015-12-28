
Meteor.publishComposite 'adminCollectionDoc', (collection, id) ->
	check collection, String
	check id, Match.OneOf(String, Mongo.ObjectID)
	# in the future allow collection read/write per user or other roles
	# collectionRoles = AdminConfig.collections?[collection]?.roles or adminRoles
	if AdminDashboard.isAdmin this.userId
		find: ->
			adminCollectionObject(collection).find(id)
		children: AdminConfig?.collections?[collection]?.children or []
	else
		@ready()

Meteor.publish 'adminUsers', ->
	if AdminDashboard.isAdmin this.userId
		Meteor.users.find()
	else
		@ready()

Meteor.publish 'adminUser', ->
	Meteor.users.find @userId

Meteor.publish 'adminCollectionsCount', ->
	if not AdminDashboard.isAdmin this.userId
		@ready()
		return;
	handles = []
	self = @

	_.each AdminTables, (table, name) ->
		id = new Mongo.ObjectID
		count = 0

		ready = false
		handles.push table.collection.find().observeChanges
			added: ->
				count += 1
				ready and self.changed 'adminCollectionsCount', id, {count: count}
			removed: ->
				count -= 1
				ready and self.changed 'adminCollectionsCount', id, {count: count}
		ready = true

		self.added 'adminCollectionsCount', id, {collection: name, count: count}

	self.onStop ->
		_.each handles, (handle) -> handle.stop()
	self.ready()

Meteor.publish null, ->
	Meteor.roles.find({})
