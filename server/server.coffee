TL = TLog.getLogger(TLog.LOGLEVEL_INFO, true, true)

Meteor.startup ->
	# code to run on server at startup
	Players = new Meteor.Collection("players")
	Players.remove {}
	Tournaments = new Meteor.Collection("tournaments")
	Tournaments.remove {}
	Scores = new Meteor.Collection("scores")
	Scores.remove {}

	playerData = [ { name: "Kniv-Lasse" }, { name: "Stenis" }, { name: "Lill-Klas" }, { name: "Ubbe Järnrör" },
		{ name: "Henke-sänke" }, { name: "Korvlirarn" }, { name: "Lusse Lusk" }, { name: "Fantomen" },
		{ name: "Dryparn" }, { name: "Skrotis" }, { name: "Pelle med gamen" }, { name: "Krokarn" },
		{ name: "Krökis" }, { name: "Öl-Östen" }, { name: "Tur-turken" }, { name: "Clara med K" },
		{ name: "Supersnippan" } ]



	date = new Date(2014, 2, 1)
	formattedDate = date.getDate().toString() + "/" + (date.getMonth() + 1).toString()
	date2 = new Date(2014, 2, 8)
	formattedDate2 = date2.getDate().toString() + "/" + (date2.getMonth() + 1).toString()
	date3 = new Date(2014, 2, 13)
	formattedDate3 = date3.getDate().toString() + "/" + (date3.getMonth() + 1).toString()
	dates = [ { date: date, formattedDate: formattedDate }, { date: date2, formattedDate: formattedDate2 },
		{ date: date3, formattedDate: formattedDate3 } ]

	t_ids = []
	p_ids = []

	i = 0
	while i < dates.length
		t_ids.push(Tournaments.insert(dates[i]))
		TL.debug("Just inserted tournament " + dates[i] + " return id is "+t_ids[i])
		i++

	i = 0
	while i < playerData.length
		p_ids.push(Players.insert(playerData[i]))
		TL.debug("Just inserted player " + playerData[i] + " return id is "+p_ids[i])
		i++

	max = 90
	min = 65
	i = 0

	while i < t_ids.length
		j = 0

		while j < p_ids.length
			score = Math.floor(Math.random() * (max - min + 1)) + min
			s = { score: score, tournamentId: t_ids[i], playerId: p_ids[j] }
			rid = Scores.insert(s)
			TL.debug("Just inserted score " + s + ", return id is "+ rid)

			j++
		i++
	i = 0

	Meteor.publish "playersPublish", ->
		return Players.find({})

	Meteor.publish "tournamentsPublish", ->
		return Tournaments.find({})

	Meteor.publish "scoresPublish", ->
		return Scores.find({})

#	Meteor.publish "averageScore", (pId) ->
#		sub = this
#		db = MongoInternals.defaultRemoteCollectionDriver().mongo.db
#
#		pipeline = [
#			{ $match: doSomethingWith(args) },
#			{ $group: {
#				_id: whatWeAreGroupingWith(args),
#				count: { $sum: 1 }
#			}}
#		]
#
#		db.collection("scores").aggregate(
#			pipeline,
#			Meteor.bindEnvironment(
#				(err, result) ->
#					_.each(result, (e) ->
#						sub.added("scores", Random.id(), {
#							key: e._id.somethingOfInterest,
#							count: e.count
#						})
#					)
#					sub.ready()
#				(error) ->
#					Meteor._debug("Error doing aggregation: " + error)
#			)
#		)

	return
