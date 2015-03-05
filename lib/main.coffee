Mixto = require 'mixto'

Domain = require 'domain'

class AEventDomain extends Mixto

  constructor: (@options={}) ->

    super @options

  extended: () ->

    _extended = () =>

      _properties()

      _methods()

    _properties = () =>

      _options = () =>

        @options ?= {}

        @options.eventDomain ?= @eventDomain or Domain.create()

        @options.eventDomainTimeout ?= @eventDomainTimeout or 5000

        @options.eventDomainEnabled ?= @eventDomainEnabled or false

        @options.eventDomainMembers ?= @eventDomainMembers or []

      _enabled = () =>

        enabled = @options.eventDomainEnabled

        Object.defineProperty @, "enabled",

          get: () -> return enabled

          set: (value) ->

            value = !!value

            if enabled is value then return null

            enabled = value

            if enabled then @enable() else @disable()

      _options()

      _enabled()

    _methods = () =>

      _error = () =>

        @error ?= (err) -> console.log err.message, err.stack

        @error = @error.bind @

      _error()

      _run = () =>

        @run ?= () -> throw new Error "run method not implemented"

        run = @run

        @run = (args...) =>

          if domain = @options.eventDomain

            domain.run () =>

              domain.on "error", (err) =>

                @error err

                if timeout = @options.eventDomainTimeout

                  killtimer = setTimeout () ->

                    process.exit 1

                  , timeout

                  killtimer.unref()

              try

                run.apply @, args

              catch err then @emit "error", err

      _run()

      @emit = (args...) =>

        if domain = @options.eventDomain

          res = []

          if domain.members then domain.members.map (member) ->

            res.push member?.emit?.apply member, [].concat args

          res.push domain.emit.apply domain, args

          for e in res then if e then return true

        return false

      @add = (emitter) =>

        domain = @options.eventDomain

        members = @options.eventDomainMembers

        index = members.indexOf(emitter)

        if not ~index then members.push emitter

        if @enabled and domain then domain.add emitter

      @remove = (emitter, dispose=false) =>

        domain = @options.eventDomain

        members = @options.eventDomainMembers

        index = members.indexOf(emitter)

        if ~index and dispose then members.splice index, 1

        if domain then domain.remove emitter

      @bind = (callback) =>

        if domain = @options.eventDomain then domain.bind callback

      @intercept = (callback) =>

        if domain = @options.eventDomain then domain.intercept callback

      @enter = () =>

        if domain = @options.eventDomain then domain.enter()

      @exit = () =>

        if domain = @options.eventDomain then domain.exit()

      @enable = () =>

        if domain = @options.eventDomain

          members = @options.eventDomainMembers or []

          members.map (emitter) =>

            if "enabled" of emitter

              if not emitter.enabled then emitter.enabled = true

            @add emitter

          @emit "domain-enabled", @

      @disable = (dispose=false) =>

        if domain = @options.eventDomain

          @emit "domain-disabled", @

          members = @options.eventDomainMembers or []

          members.map (emitter) =>

            if "enabled" of emitter

              emitter.enabled = false

            @remove emitter, dispose

      @dispose = () =>

        @disable true

        if domain then domain.dispose()

    _extended()

module.exports = AEventDomain
