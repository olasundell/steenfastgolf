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
	<p>Ny omgång</p>
	<ul>
		<li>
			<ul>
				<li><label for="new-tournament-date">Datum</label></li>
				<li class="input-li"><input id="new-tournament-date" value="2014-03-13" name="newTournamentDate" data-provide="datepicker" data-date-format="yyyy-mm-dd" readonly/></li>
			</ul>
		</li>
		<li>
			<ul>
				<li><label for="new-tournament-alias">Alias</label></li>
				<li class="input-li"><input type="text" id="new-tournament-alias" name="newTournamentAlias"/></li>
			</ul>
		</li>
		<li>
			<ul>
				<li><a id="create-new-tournament">Skapa</a></li>
				<li><a id="close-new-tournament" class="new-tournament-close-button">Stäng</a></li>
			</ul>
		</li>
	</ul>
</div>
"""

#newTournamentDialogMarkup = ['<div id="new-tournament-dialog" class="new-tournament-dialog">'
#                             '<p>Ny omgång</p>'
#	'<ul>'
#                             '<p>Datum&nbsp;'
#                             '<input value="2014-03-13" name="newTournamentDate" data-provide="datepicker" data-date-format="yyyy-mm-dd" readonly/>'
#                             '</p>'
#	'<p>Alias&nbsp;'
#                             '<input type="text" name="newTournamentAlias"/>'
#	'</p>'
#	'<a id="create-new-tournament">Skapa</a>'
#                             '<a id="close-new-tournament" class="new-tournament-close-button">Stäng</a>'
#                             '</div>'].join('')

closeNewTournamentDialog = ->
	dialog = document.getElementById("new-tournament-dialog")
	dialog.parentNode.removeChild(dialog)

eventMap = {
	'click .new-tournament-close-button': ->
		closeNewTournamentDialog()
	'click .icon-calendar': (event) ->
		$('.icon-calendar').datepicker('show')
	'click #new-tournament': ->
		newTournament = document.getElementById("new-tournament")
		newTournament.parentNode.innerHTML = newTournament.parentNode.innerHTML + newTournamentDialogMarkup
	'click #create-new-tournament': ->
		date = new Date(document.getElementById("new-tournament-date").value)
		formattedDate = date.getDate().toString() + "/" + (date.getMonth() + 1).toString()
		alias = document.getElementById("new-tournament-alias").value
		t_id = Tournaments.insert({date: date, alias: alias, formattedDate: formattedDate})
		players = Players.find({})
		Scores.insert({ score: 104, tournamentId: t_id, playerId: player._id }) for player in players.fetch()

		closeNewTournamentDialog()
	'keypress #new-player': (event) ->
		if event.which == 13
			tournaments = Tournaments.find({})
			t_arr = tournaments.fetch()
			id = Players.insert({name: document.getElementById("new-player").value, totalScore: Math.floor(t_arr.length * 104) })
			Scores.insert({score: 104, tournamentId: tournament._id, playerId: id}) for tournament in t_arr
	'keypress .score-input': (event) ->
		if event.which == 13
			id = event.target.id
			alert id
			Scores.update({_id: id}, {$set: {score: parseInt(event.target.value)}})
			recalcTotal player._id for player in Players.find({}).fetch()
}


Template.leaderboard.events = eventMap
#		onRender: (date) ->
#			return date.valueOf() < now.valueOf() ? 'disabled' : ''
Template.leaderboard.rendered = ->
	$('.icon-calendar').datepicker({format: 'yyyy-mm-dd'})


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

