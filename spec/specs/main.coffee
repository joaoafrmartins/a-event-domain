describe 'AEventDomain', () ->

  it 'before', () ->

    kosher.alias 'fixture', kosher.spec.fixtures

    kosher.alias 'instance', new kosher.fixture.domain.A

  describe 'properties', () ->

    it 'before', () ->

      kosher.properties(

        { name: "enabled", type: "boolean", value: false}

      )

    describe 'enabled', () ->

      it 'should add and remove all members from the domain', () ->

        one = new kosher.fixture.emitter.A

        two = new kosher.fixture.emitter.A

        kosher.instance.add one

        kosher.instance.add two

        kosher.instance.options.eventDomain.members.length.should.eql 0

        kosher.instance.enabled = true

        kosher.instance.options.eventDomain.members.length.should.
        not.be.below 2

        kosher.instance.enabled = false

        kosher.instance.options.eventDomain.members.length.should.eql 0

      it 'should emit enabled and disabled events', (done) ->

        total = 0

        enabled = disabled = undefined

        three = new kosher.fixture.emitter.C () ->

          if @enabled and @disabled then done()

        expect(three.enabled).not.to.be.ok

        expect(three.disabled).not.to.be.ok

        kosher.instance.enabled = false

        kosher.instance.add three

        kosher.instance.enabled = true

        kosher.instance.enabled = false

  describe 'methods', () ->

    it 'before', () ->

      kosher.methods(

        "run",

        "error",

        "enable",

        "disable",

        "emit",

        "add",

        "remove",

        "bind",

        "intercept",

        "enter",

        "exit"

      )

    describe 'run', () ->

      it 'should be bound to domain instance', () ->

        kosher.alias 'instance', new kosher.fixture.domain.A

        expect(kosher.instance.options.runMethodCalled).to.eql undefined

        kosher.instance.run()

        kosher.instance.options.runMethodCalled.should.eql 1

      it 'should be wrapped in the domain and handle errors', () ->

        kosher.alias 'instance', new kosher.fixture.domain.B

        kosher.instance.run()

        expect(kosher.instance.options.errorMethodCalled).to.eql 1

    describe 'emit', () ->

      it 'should propagate events emitted to all domain members', () ->

        one = new kosher.fixture.emitter.A

        kosher.instance.add one

        kosher.instance.enabled = true

        result = kosher.instance.emit "event", "from domain"

        expect(result).to.be.ok

        expect(one.received).to.eql "from domain"

    describe 'error', () ->

      it 'should process domain member errors inside run', () ->

        kosher.alias 'instance', new kosher.fixture.domain.C

        error = new kosher.fixture.emitter.B

        expect(kosher.instance.options.errorMethodCalled).not.to.be.ok

        kosher.instance.add error

        kosher.instance.enabled = true

        kosher.instance.run()

        expect(kosher.instance.options.errorMethodCalled).to.eql 1
