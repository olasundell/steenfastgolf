TL = TLog.getLogger(TLog.LOGLEVEL_INFO, true, true)
Players = new Meteor.Collection("players")
Tournaments = new Meteor.Collection("tournaments")
Scores = new Meteor.Collection("scores")

Meteor.subscribe "scoresPublish"
Meteor.subscribe "tournamentsPublish"
Meteor.subscribe "playersPublish"

Template.leaderboard.players = Players.find {}, {sort: {totalScore: 1, name: 1}}
Template.leaderboard.tournaments = Tournaments.find {}
Template.leaderboard.scores = Scores.find {}

playerNameClicked = false

closeNewTournamentDialog = ->
	dialog = document.getElementById("new-tournament-dialog")
	dialog.parentNode.removeChild(dialog)
	newTournamentDialogOpen = false

eventMap = {
	'click .edit-tournament': (event) ->
		currentId = event.target.id.replace("edit-tournament-","")
		newDate = document.getElementById("tournament-date-" + currentId).value
		newAlias = document.getElementById("tournament-alias-" + currentId).value
		Tournaments.update({_id: currentId}, {$set: {date: moment(newDate, 'YYYY-MM-DD'), alias: newAlias, formattedDate: moment(newDate, 'YYYY-MM-DD').format('D/M')}})
	'keypress .change-player-name': (event) ->
		if event.which == 13
			# TODO input validation!
			Players.update({_id: event.target.parentNode.id.replace("player-","")},{$set: {name: event.target.value}})
			event.target.parentNode.innerHtml = ''
			event.target.parentNode.innerText = event.target.value
			playerNameClicked = false
	'click .player-name': (event) ->
		if playerNameClicked
			return false
		event.currentTarget.innerHTML = '<input type="text" class="change-player-name" autofocus="autofocus" value="' + event.currentTarget.innerText + '"/>'
		playerNameClicked = true
	'click #new-tournament': ->
		if not newTournamentDialogOpen
			newTournament = document.getElementById("new-tournament")
			newTournament.parentNode.innerHTML = newTournament.parentNode.innerHTML + newTournamentDialogMarkup
			newTournamentDialogOpen = true
	'click #create-new-tournament': ->
		alias = document.getElementById("new-tournament-alias").value
		if not alias
			if document.getElementById("new-tournament-alias-div").className.indexOf("has-error") == -1
				document.getElementById("new-tournament-alias-div").className += " has-error"
			return false
		else
			# remove error class if it's there
			if document.getElementById("new-tournament-alias-div").className.indexOf("has-error") != -1
				document.getElementById("new-tournament-alias-div").className.replace(" has-error","")

		date = new Date(document.getElementById("new-tournament-date").value)
		formattedDate = date.getDate().toString() + "/" + (date.getMonth() + 1).toString()
		t_id = Tournaments.insert({date: date, alias: alias, formattedDate: formattedDate})
		players = Players.find({})
		Scores.insert({ score: 104, tournamentId: t_id, playerId: player._id }) for player in players.fetch()
		$('.dropdown-toggle').dropdown('toggle')
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
			Scores.insert({score: 104, tournamentId: tournament._id, playerId: id}) for tournament in t_arr
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
	return Scores.find {playerId: pId}

Handlebars.registerHelper 'formatDate', (date) ->
	return moment(date).format('YYYY-MM-DD')

recalcTotal = (pId) ->
	total = 0
	num = 0
	sc = Scores.find({playerId: pId}).fetch()

	while num < sc.length
		total += sc[num].score
		num++

	Players.update({_id: pId}, {$set: {totalScore: total}})

