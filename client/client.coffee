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

newTournamentDialogMarkup = '<div id="new-tournament-dialog" class="new-tournament-dialog"><p>Ny omgång</p><a id="close-new-tournament" class="new-tournament-close-button">Stäng</a></div>'

eventMap = {
	'click .new-tournament-close-button': ->
		dialog = document.getElementById("new-tournament-dialog")
		dialog.parentNode.removeChild(dialog)
	'click #new-tournament': ->
		newTournament = document.getElementById("new-tournament")
		newTournament.parentNode.innerHTML = newTournament.parentNode.innerHTML + newTournamentDialogMarkup
}

Template.leaderboard.events = eventMap

Handlebars.registerHelper 'userScores', (pId) ->
	return Scores.find {playerId: pId}
