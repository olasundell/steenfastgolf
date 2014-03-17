TL = TLog.getLogger(TLog.LOGLEVEL_INFO, true, true)
Players = new Meteor.Collection("players")
Tournaments = new Meteor.Collection("tournaments")
Scores = new Meteor.Collection("scores")

Meteor.subscribe "scoresPublish"
Meteor.subscribe "tournamentsPublish"
Meteor.subscribe "playersPublish"

Template.leaderboard.players = Players.find {}, {sort: {totalScore: 1}}
Template.leaderboard.tournaments = Tournaments.find {}
Template.leaderboard.scores = Scores.find {}

closeNewTournamentDialog = ->
	dialog = document.getElementById("new-tournament-dialog")
	dialog.parentNode.removeChild(dialog)
	newTournamentDialogOpen = false

eventMap = {
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
			tournaments = Tournaments.find({})
			t_arr = tournaments.fetch()
			id = Players.insert({name: document.getElementById("new-player").value, totalScore: Math.floor(t_arr.length * 104) })
			Scores.insert({score: 104, tournamentId: tournament._id, playerId: id}) for tournament in t_arr
			document.getElementById("new-player").value = ""
	'keypress .score-input': (event) ->
		if event.which == 13
			id = event.target.id
			Scores.update({_id: id}, {$set: {score: parseInt(event.target.value)}})
			recalcTotal player._id for player in Players.find({}).fetch()
}



#		onRender: (date) ->
#			return date.valueOf() < now.valueOf() ? 'disabled' : ''
Template.leaderboard.events = eventMap
Template.leaderboard.rendered = ->
	$('#new-tournament-date').datetimepicker({
		format: 'YYYY-MM-DD',
		pickTime: false
	});
#	$('.date-picker').datepicker({format: 'yyyy-mm-dd'})


Handlebars.registerHelper 'userScores', (pId) ->
	return Scores.find {playerId: pId}

recalcTotal = (pId) ->
	total = 0
	num = 0
	sc = Scores.find({playerId: pId}).fetch()

	while num < sc.length
		total += sc[num].score
		num++

	Players.update({_id: pId}, {$set: {totalScore: total}})

