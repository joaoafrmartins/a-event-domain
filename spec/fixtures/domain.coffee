kosher.alias 'AEventDomain'

class Domain

  constructor: (@options={}) ->

    kosher.AEventDomain.extend @

class A extends Domain

  run: () ->

    @options.runMethodCalled ?= 0

    @options.runMethodCalled++

  error: (err) ->

    @options.errorMethodCalled ?= 0

    @options.errorMethodCalled++

class B extends A

  run: () ->

    throw new Error "domain error"

class C extends A

  run: () ->

    @emit "throw", "error message"

module.exports = "A": A, "B": B, "C": C
