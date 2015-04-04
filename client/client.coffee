TL = TLog.getLogger(TLog.LOGLEVEL_INFO, true, true)
Players = new Meteor.Collection("players")
Tournaments = new Meteor.Collection("tournaments")
Scores = new Meteor.Collection("scores")

Meteor.subscribe "scoresPublish"
Meteor.subscribe "tournamentsPublish"
Meteor.subscribe "playersPublish"

Template.leaderboard.players = Players.find {}, {sort: {totalScore: 1, name: 1}}
Template.leaderboard.tournaments = Tournaments.find {}, {sort: {date: 1}}
Template.leaderboard.scores = Scores.find {}, {sort: {scoreDate: 1}}

oldPlayerName = ""

closeNewTournamentDialog = ->
	dialog = document.getElementById("new-tournament-dialog")
	dialog.parentNode.removeChild(dialog)
	newTournamentDialogOpen = false

removePlayerInputField = (event, newText) ->
	event.target.parentNode.innerHtml = ''
	event.target.parentNode.innerText =
	this.playerNameClicked = false

createNewTournament = ->
	alias = document.getElementById("new-tournament-alias").value
	newTournamentAliasDiv = document.getElementById("new-tournament-alias-div")
	if not alias
		if newTournamentAliasDiv.className.indexOf("has-error") == -1
			newTournamentAliasDiv.className += " has-error"
		return false
	else
		# remove error class if it's there
		if newTournamentAliasDiv.className.indexOf("has-error") != -1
			newTournamentAliasDiv.className.replace(" has-error","")

	date = new Date(document.getElementById("new-tournament-date").value)
	formattedDate = date.getDate().toString() + "/" + (date.getMonth() + 1).toString()
	t_id = Tournaments.insert({date: date, alias: alias, formattedDate: formattedDate})
	players = Players.find({}).fetch()
	Scores.insert({ score: 104, tournamentId: t_id, playerId: player._id, scoreDate: date}) for player in players
	recalcTotal player._id for player in players
	$('.dropdown-toggle').dropdown('toggle')
	return true

updateTournament = (currentId) ->
	newDate = document.getElementById("tournament-date-" + currentId).value
	newAlias = document.getElementById("tournament-alias-" + currentId).value
	Tournaments.update({_id: currentId}, {$set: {date: moment(newDate, 'YYYY-MM-DD'), alias: newAlias, formattedDate: moment(newDate, 'YYYY-MM-DD').format('D/M')}})

eventMap = {
	'click .edit-tournament': (event) ->
		updateTournament(event.target.id.replace("edit-tournament-",""))
	'keypress .change-tournament-alias': (event) ->
		if event.which == 13
			updateTournament(event.target.id.replace("tournament-alias-",""))
	'keypress .change-player-name': (event) ->
		if event.which == 13
			# TODO input validation!
			Players.update({_id: event.target.parentNode.id.replace("player-","")},{$set: {name: event.target.value}})
			removePlayerInputField.call(this, event, event.target.value)
			oldPlayerName = ""
	'keypress #new-tournament-alias': (event) ->
		if event.which == 13
			return createNewTournament()
	'keyup .change-player-name': (event) ->
		if event.which == 27
			removePlayerInputField.call(this, event, oldPlayerName)
			oldPlayerName = ""
	'click .remove-player-button': (event) ->
		# TODO fire yes-no dialog
		Players.remove({_id: event.target.id.replace("remove-player-", "")})
		removePlayerInputField(this, event, oldPlayerName)
		oldPlayerName = ""
	'click .player-name': (event) ->
		if Session.get("playerNameClicked") and Session.get("playerNameClicked") is true
			return false
		oldPlayerName = event.target.innerText
		event.target.innerHTML = '<input type="text" class="change-player-name" autofocus="autofocus" value="' + event.target.innerText + '"/>
		<button type="button" class="btn btn-danger remove-player-button" id="remove-'+event.target.id+'">Ta bort</button>'
		Session.set("playerNameClicked", true)
	'click #new-tournament': ->
		if not newTournamentDialogOpen
			newTournament = document.getElementById("new-tournament")
			newTournament.parentNode.innerHTML = newTournament.parentNode.innerHTML + newTournamentDialogMarkup
			newTournamentDialogOpen = true
	'click #create-new-tournament': ->
		return createNewTournament()
	'click .remove-tournament': (event) ->
		tId = event.target.id.replace("remove-tournament-", "")
		Scores.remove({_id: score._id}) for score in Scores.find({tournamentId: tId}).fetch()
		Tournaments.remove({_id: tId})
		recalcTotal player._id for player in Players.find({}).fetch()
	'keypress #new-player': (event) ->
		if event.which == 13
			newPlayerEL = document.getElementById("new-player")
			newPlayerName = newPlayerEL.value
			if not newPlayerName?
				if newPlayerEL.className.indexOf("has-error") == -1
					newPlayerEL.className += " has-error"

			tournaments = Tournaments.find({})
			t_arr = tournaments.fetch()
			id = Players.insert({name: newPlayerName, totalScore: Math.floor(t_arr.length * 104) })
			Scores.insert({score: 104, tournamentId: tournament._id, playerId: id, scoreDate: tournament.date}) for tournament in t_arr
			newPlayerEL.value = ""
			if newPlayerEL.className.indexOf("has-error") != -1
				newPlayerEL.className.replace(" has-error", "")
	'keypress .score-input': (event) ->
		if event.which == 13
			id = event.target.id
			Scores.update({_id: id}, {$set: {score: parseInt(event.target.value)}})
			recalcTotal player._id for player in Players.find({}).fetch()
}

# Only do stuff if we're logged in.
if Meteor.userId()?
	Template.leaderboard.events = eventMap

	Template.leaderboard.rendered = ->
		$('#new-tournament-date').datetimepicker({
			format: 'YYYY-MM-DD',
			pickTime: false
		});
		$('.date-picker').datetimepicker({
			format: 'YYYY-MM-DD',
			pickTime: false
		});
		Accounts.onLogin( (validate) ->
			Template.leaderboard.events = eventMap
		)
		Meteor.logout( ->
			Template.leaderboard.events = {}
		)
else
	Template.leaderboard.events = {}
	Template.leaderboard.rendered = ->
		Accounts.onLogin( (validate) ->
			Template.leaderboard.events = eventMap
		)
		Meteor.logout( ->
			Template.leaderboard.events = {}
		)

Handlebars.registerHelper 'userScores', (pId) ->
	return Scores.find({playerId: pId}, {sort: {scoreDate: 1}})

Handlebars.registerHelper 'formatDate', (date) ->
	return moment(date).format('YYYY-MM-DD')

Handlebars.registerHelper 'getNow', ->
	return moment().format('YYYY-MM-DD')

#curPath = () ->
#	c=window.location.pathname
#	b=c.slice(0,-1)
#	a=c.slice(-1)
#	if b==""
#		return "/"
#	else if a=="/"
#		return b
#
#	return c
#
#Handlebars.registerHelper('active', (path) ->
#	cp = curPath()
#	TL.info(cp)
#	return cp == path ? 'active' : '';
#)

recalcTotal = (pId) ->
	total = 0
	num = 0
	sc = Scores.find({playerId: pId}).fetch()

	while num < sc.length
		total += sc[num].score
		num++

	Players.update({_id: pId}, {$set: {totalScore: total}})

