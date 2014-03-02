TL = TLog.getLogger(TLog.LOGLEVEL_INFO, true, true)
PlayerResults = new Meteor.Collection("playerResults")
Meteor.subscribe("publishedResults")

TL.info "foobar"

Template.leaderboard.players = PlayerResults.find({})

Template.leaderboard.tournaments = PlayerResults.find({}).distinct("scores.formattedDate", true)
TL.info PlayerResults
