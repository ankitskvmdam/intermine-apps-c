mediator = require '../modules/mediator'
FilterGenusView = require './FilterGenusView'

class FilterOrganismView extends Backbone.View

	tagName: "ul"
	className: "expandable"

	templateOff: require '../templates/FilterListItemOffTemplate'

	events: ->
		# "click": "filterAll"
		# "click .expand": "showChildren"
		"click": "describe"

	# Filter our collection
	showChildren: ->
		console.log @options.collection
		content = $(@el).find('ul')
		console.log "content", content

			    # open up the content needed - toggle the slide- if visible, slide up, if not slidedown.
		content.slideToggle 100, () ->
			console.log "sliding"


	describe: ->
		console.log @

	# Exposide the children to the DOM
	filterAll: ->
		console.log "Toggling children."


	initialize: (attr) ->
		# Assume that we're being passed all models of the same genus!
		@options = attr
		console.log "FilterOrganismView initialized", @

		#@model.on('change:enabled', @render)
		
	render: =>

		console.log "FilterOrganismView render called."
		# Group our collection by Genus and build a nested tree
		groups = @options.collection.groupBy (model) ->
			return model.get("genus");

		# Now loop through our genus groups and build a view for each of them
		for group of groups
			console.log "next group", groups[group]
			nextGenus = new FilterGenusView({models: groups[group], genus: group})
			$(@el).append nextGenus.render().$el


		console.log "my el from org view", $(@el)
		@

	moused: ->
		d3.selectAll(".mychart").style("fill", "#808080")
		d3.select("#" + @model.get("name")).style("fill", "white");

	toggleMe: ->
		console.log "clicked"


module.exports = FilterOrganismView