#!/usr/bin/env coffee

{FreeWifi} = require '..'

freewifi = new FreeWifi
  login:    process.argv[2]
  password: process.argv[3]

freewifi.connect (err, res) ->
  console.log err, res