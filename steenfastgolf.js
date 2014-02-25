if (Meteor.isClient) {
    Tournaments = new Meteor.Collection("tournament");
    Players = new Meteor.Collection("player");
    Results = new Meteor.Collection("result");

    Template.leaderboard.players = function () {
//        return Results.find({});
        var players = Players.find({}, {fields: {name: 1}}).sort(function(a, b) { return a._id - b._id;});

        return players;
    };

    Handlebars.registerHelper("findResults", function(player_id) {
        return Results.find({player_id: player_id});
    });

    Template.leaderboard.tournaments = function () {
        return Tournaments.find({}, {fields: {formatted_date: 1, datetime: 1}}, {sort: {datetime: 1}});
    };

//    var DateFormats = {
//        short: "DD/MM",
//        long: "yyyy-MM-DD"
//    };

    Handlebars.registerHelper("formatDate", function(datetime, format) {
        return datetime;
//        if (moment) {
//            f = DateFormats[format];
//            return moment(datetime).format("DD/MM");
//            return datetime;
//        }
//        else {
//            return datetime;
//        }
    });

//    Handlebars.registerHelper("formatDate", function(datetime) {
//        return (new Date(datetime)).toString("dd/MM");
////        return datetime.toString('dd/MM');
//    });

//    Template.leaderboard.selected_name = function () {
//        var player = Players.findOne(Session.get("selected_player"));
//        return player && player.name;
//    };
//
//    Template.player.selected = function () {
//        return Session.equals("selected_player", this._id) ? "selected" : '';
//    };
//
//    Template.leaderboard.events({
//        'click input.inc': function () {
//            Players.update(Session.get("selected_player"), {$inc: {score: 5}});
//        }
//    });
//
//    Template.player.events({
//        'click': function () {
//            Session.set("selected_player", this._id);
//        }
//    });
}

if (Meteor.isServer) {
    Meteor.startup(function () {
        // code to run on server at startup
        Tournaments = new Meteor.Collection("tournament");
        Players = new Meteor.Collection("player");
        Results = new Meteor.Collection("result");

        Tournaments.remove({});
        Players.remove({});
        Results.remove({});

        var ids = [];
        var names = ["Kniv-Lasse", "Stenis", "Lill-Klas", "Ubbe Järnrör", "Henke-sänke", "Korvlirarn", "Lusse Lusk",
            "Fantomen", "Dryparn", "Skrotis", "Pelle med gamen", "Krokarn", "Krökis", "Öl-Östen", "Tur-turken",
            "Clara med K", "Supersnippan"];

//        _.each(names, function(doc) {   Players.insert(doc); })

        for (var i = 0; i < names.length; i++) {
            ids.push(Players.insert({name: names[i]}));
        }

        var tournament_ids = [];

        var date = new Date(2014, 2, 1);
        var formattedDate = date.getDate().toString() + "/" + (date.getMonth() + 1).toString();
        var date2 = new Date(2014, 2, 8);
        var formattedDate2 = date2.getDate().toString() + "/" + (date2.getMonth() + 1).toString();
        var date3 = new Date(2014, 2, 13);
        var formattedDate3 = date3.getDate().toString() + "/" + (date3.getMonth() + 1).toString();

        tournament_ids.push(Tournaments.insert({datetime: date, formatted_date: formattedDate}));
        tournament_ids.push(Tournaments.insert({datetime: date2, formatted_date: formattedDate2}));
        tournament_ids.push(Tournaments.insert({datetime: date3, formatted_date: formattedDate3}));

        var max = 90;
        var min = 65;

        for (var i = 0 ; i < tournament_ids.length ; i++) {
            for (var j = 0 ; j < ids.length ; j++) {
                Results.insert({score: Math.floor(Math.random() * (max - min + 1)) + min,
                    player_id: ids[j],
                    tournament_id: tournament_ids[i]});
            }
        }
    });
}

