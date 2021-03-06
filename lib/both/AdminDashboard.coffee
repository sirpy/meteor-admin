AdminDashboard =
	schemas: {}
	sidebarItems: []
	collectionItems: []
	alertSuccess: (message)->
		Session.set 'adminSuccess', message
	alertFailure: (message)->
		Session.set 'adminError', message

	isAdmin: (userId)->
		console.log("isAdmin",userId,adminRoles);
		return Roles.userIsInRole userId, adminRoles

  adminRoutes: ['adminDashboard','adminDashboardUsersNew','adminDashboardUsersEdit','adminDashboardView','adminDashboardNew','adminDashboardEdit']
	adminControllerCheckAdmin: (currentRoute) ->
		console.log("AdminDashboard adminControllerCheckAdmin:","for route:",currentRoute.getName(),AdminConfig);
		if Meteor.userId() && not currentRoute.getName().indexOf('adminDashboard') && not AdminConfig?.routePermissions
			return
		if Meteor.userId() && AdminConfig?.routePermissions?(currentRoute.getName())
			return
		if not AdminDashboard.isAdmin Meteor.userId()
			Meteor.call 'adminCheckAdmin'
			if (typeof AdminConfig?.nonAdminRedirectRoute == "string")
			  Router.go AdminConfig.nonAdminRedirectRoute
			else Router.go "/"
		if typeof @.next == 'function'
			@next()

	collectionLabel: (collection)->
		if collection == 'Users'
			'Users'
		else if collection? and typeof AdminConfig.collections[collection].label == 'string'
			AdminConfig.collections[collection].label
		else Session.get 'admin_collection_name'

	addSidebarItem: (title, url, options) ->
		item = title: title
		if _.isObject(url) and typeof options == 'undefined'
			item.options = url
		else
			item.url = url
			item.options = options

		@sidebarItems.push item

	removeSidebarItem: (title) ->
		existing = _.findWhere @sidebarItems, {'title':title}
		if existing
			@sidebarItems = _.without(@sidebarItems, existing)

	extendSidebarItem: (title, urls) ->
		if _.isObject(urls) then urls = [urls]

		existing = _.find @sidebarItems, (item) -> item.title == title
		if existing
			existing.options.urls = _.union existing.options.urls, urls

	addCollectionItem: (fn) ->
		@collectionItems.push fn

	path: (s) ->
		path = '/admin'
		if typeof s == 'string' and s.length > 0
			path += (if s[0] == '/' then '' else '/') + s
		path


AdminDashboard.schemas.newUser = new SimpleSchema
	email:
		type: String
		label: "Email address"
	chooseOwnPassword:
		type: Boolean
		label: 'Let this user choose their own password with an email'
		defaultValue: true
	password:
		type: String
		label: 'Password'
		optional: true
	sendPassword:
		type: Boolean
		label: 'Send this user their password by email'
		optional: true

AdminDashboard.schemas.sendResetPasswordEmail = new SimpleSchema
	_id:
		type: String

AdminDashboard.schemas.changePassword = new SimpleSchema
	_id:
		type: String
	password:
		type: String
