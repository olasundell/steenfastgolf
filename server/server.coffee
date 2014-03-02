TL = TLog.getLogger(TLog.LOGLEVEL_INFO, true, true)

Meteor.startup ->
	# code to run on server at startup
	PlayerResults = new Meteor.Collection("playerResults")
	PlayerResults.remove {}
	data = [
		{
			name: "Kniv-Lasse"
			scores: []
		}
		{
			name: "Stenis"
			scores: []
		}
		{
			name: "Lill-Klas"
			scores: []
		}
		{
			name: "Ubbe Järnrör"
			scores: []
		}
		{
			name: "Henke-sänke"
			scores: []
		}
		{
			name: "Korvlirarn"
			scores: []
		}
		{
			name: "Lusse Lusk"
			scores: []
		}
		{
			name: "Fantomen"
			scores: []
		}
		{
			name: "Dryparn"
			scores: []
		}
		{
			name: "Skrotis"
			scores: []
		}
		{
			name: "Pelle med gamen"
			scores: []
		}
		{
			name: "Krokarn"
			scores: []
		}
		{
			name: "Krökis"
			scores: []
		}
		{
			name: "Öl-Östen"
			scores: []
		}
		{
			name: "Tur-turken"
			scores: []
		}
		{
			name: "Clara med K"
			scores: []
		}
		{
			name: "Supersnippan"
			scores: []
		}
	]
	date = new Date(2014, 2, 1)
	formattedDate = date.getDate().toString() + "/" + (date.getMonth() + 1).toString()
	date2 = new Date(2014, 2, 8)
	formattedDate2 = date2.getDate().toString() + "/" + (date2.getMonth() + 1).toString()
	date3 = new Date(2014, 2, 13)
	formattedDate3 = date3.getDate().toString() + "/" + (date3.getMonth() + 1).toString()
	dates = [
		[
			date
			formattedDate
		]
		[
			date2
			formattedDate2
		]
		[
			date3
			formattedDate3
		]
	]
	max = 90
	min = 65
	i = 0

	while i < dates.length
		j = 0

		while j < data.length
			score = Math.floor(Math.random() * (max - min + 1)) + min
			data[j].scores.push
				date: dates[i][0]
				formattedDate: dates[i][1]
				score: score

			j++
		i++
	i = 0

	while i < data.length
		TL.debug data[i]
		TL.debug PlayerResults.insert(data[i])
		i++

	Meteor.publish "publishedResults", ->
		return PlayerResults.find({})

	return
