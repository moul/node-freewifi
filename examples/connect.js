// Generated by CoffeeScript 1.4.0
(function() {
  var FreeWifi, freewifi;

  FreeWifi = require('..').FreeWifi;

  freewifi = new FreeWifi({
    login: process.argv[2],
    password: process.argv[3]
  });

  freewifi.connect(function(err, res) {
    return console.log(err, res);
  });

}).call(this);
