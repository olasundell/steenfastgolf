TL = TLog.getLogger(TLog.LOGLEVEL_INFO, true, true)

initDb = (Players, Tournaments, Scores) ->
	Players.remove {}
	Tournaments.remove {}
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
	dates = [ { alias: "Pebble Beach", date: date, formattedDate: formattedDate }, { alias: "St Andrews", date: date2, formattedDate: formattedDate2 },
		{ alias: "Kungsängen", date: date3, formattedDate: formattedDate3 } ]

	t_ids = []
	p_ids = []

	i = 0
	while i < dates.length
		t_ids.push(Tournaments.insert(dates[i]))
		TL.debug("Just inserted tournament " + dates[i] + " return id is "+t_ids[i])
		i++

	i = 0
	while i < playerData.length
		playerData[i].totalScore = 0
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
			s = { score: score, tournamentId: t_ids[i], playerId: p_ids[j], scoreDate: dates[i].date}
			rid = Scores.insert(s)
			TL.debug("Just inserted score " + s + ", return id is "+ rid)
			recalcTotal p_ids[j], Scores, Players

			j++
		i++

	return

recalcTotal = (pId, Scores, Players) ->
	total = 0
	num = 0
	sc = Scores.find({playerId: pId}).fetch()

	while num < sc.length
		total += sc[num].score
		num++

	Players.update({_id: pId}, {$set: {totalScore: total}})

recalcAverage = (pId, Scores, Players) ->
	total = 0
	num = 0
	sc = Scores.find({playerId: pId}).fetch()

	while num < sc.length
		total += sc[num].score
		num++

	avg = 0

	if num > 0
		avg = Math.floor(total / num)

	Players.update({_id: pId}, {$set: {averageScore: avg}})


Meteor.startup ->
	# code to run on server at startup
	Players = new Meteor.Collection("players")
	Tournaments = new Meteor.Collection("tournaments")
	Scores = new Meteor.Collection("scores")

	initDbNow = false

	if initDbNow
		initDb(Players, Tournaments, Scores)

#	Players.remove {}
#	Tournaments.remove {}
#	Scores.remove {}

	Accounts.config({forbidClientAccountCreation: true})

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

