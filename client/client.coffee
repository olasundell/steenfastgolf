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

Handlebars.registerHelper 'userScores', (pId) ->
	return Scores.find {playerId: pId}

#Handlebars.registerHelper 'averageScore', (pId) ->
#	total = 0
#	num = 0
#	sc = Scores.find({playerId: pId}).fetch()
#
#	TL.debug("Scores are " + sc.toSource())
#
#	while num < sc.length
#		total += sc[num].score
#		num++
#
#	avg = 0
#
#	if num > 0
#		avg = Math.floor(total / num)
#
#	TL.info("About to return average "+avg)
#
#	return avg
