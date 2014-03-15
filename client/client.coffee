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

newTournamentDialogMarkup = """
<div id="new-tournament-dialog" class="new-tournament-dialog">
	<form class="form-horizontal" role="form">
		<div class="form-group">
			<label for="new-tournament-date" class="col-sm-2 control-label">Datum</label>
			<div class="col-sm-10">
			  <input type="date" class="form-control date-picker" id="new-tournament-date" data-date-format="yyyy-mm-dd" placeholder="2014-03-14" disabled>
			</div>
		</div>
		<div class="form-group">
			<label for="new-tournament-alias" class="col-sm-2 control-label">Alias</label>
			<div class="col-sm-10">
			  <input type="text" class="form-control" id="new-tournament-alias" placeholder="Alias">
			</div>
		</div>
		<div class="form-group">
			<div class="col-sm-4">
				<button type="submit" id="create-new-tournament" class="btn btn-primary">Skapa</button>
			</div>
			<div class="col-sm-offset-6 col-sm-4">
				<button type="submit" id="new-tournament-close-button" class="btn btn-default">Stäng</button>
			</div>
		</div>
	</form>
</div>
"""

closeNewTournamentDialog = ->
	dialog = document.getElementById("new-tournament-dialog")
	dialog.parentNode.removeChild(dialog)
	newTournamentDialogOpen = false

eventMap = {
	'click .icon-calendar': (event) ->
		$('.date-picker').datepicker('show')
	'click #new-tournament': ->
		if not newTournamentDialogOpen
			newTournament = document.getElementById("new-tournament")
			newTournament.parentNode.innerHTML = newTournament.parentNode.innerHTML + newTournamentDialogMarkup
			newTournamentDialogOpen = true
	'click #create-new-tournament': ->
		date = new Date(document.getElementById("new-tournament-date").value)
		formattedDate = date.getDate().toString() + "/" + (date.getMonth() + 1).toString()
		alias = document.getElementById("new-tournament-alias").value
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
	'keypress .score-input': (event) ->
		if event.which == 13
			id = event.target.id
			Scores.update({_id: id}, {$set: {score: parseInt(event.target.value)}})
			recalcTotal player._id for player in Players.find({}).fetch()
}


Template.leaderboard.events = eventMap
#		onRender: (date) ->
#			return date.valueOf() < now.valueOf() ? 'disabled' : ''
Template.leaderboard.rendered = ->
	$('.date-picker').datepicker({format: 'yyyy-mm-dd'})


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

