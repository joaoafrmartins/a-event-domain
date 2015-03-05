{ EventEmitter } = require 'events'

class A extends EventEmitter

  constructor: () ->

    super

    @on "event", (event) =>

      @received = event

class B extends EventEmitter

  constructor: () ->

    super

    @on "throw", (message) ->

      @emit "error", new Error message


class C extends EventEmitter

  constructor: (@callback) ->

    super

    @callback.bind @

    @on "domain-enabled", () =>

      @enabled = true

      @callback()

    @on "domain-disabled", () =>

      @disabled = true

      @callback()

module.exports =

  "A": A

  "B": B

  "C": C
