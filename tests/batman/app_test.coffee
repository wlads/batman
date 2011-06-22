if window?
  window.ASYNC_TEST_DELAY = 120 unless 'onhashchange' of window
  window.location.hash = ""
else
  return

class TestApp extends Batman.App

class TestApp.TestController
  render: -> true
  for k in ['show', 'complex', 'root'] 
    @::[k] = createSpy()

QUnit.module "Batman.App routing"
  setup: ->
    @app = TestApp
    @app.root ->
    @app.route '/404', ->
    @controller = new TestApp.TestController
    @app.startRouting()

  teardown: ->
    @app.stopRouting()
    Batman._routes = []

test "should redirect", 1, ->
  @app.redirect url = "/foo/bar/bleh"
  equal window.location.hash, "#!/foo/bar/bleh"

asyncTest "should match simple routes", 1, ->
  @app.route "/products/:id", @controller.show
  @app.redirect url = "/products/2"
  delay =>
    deepEqual @controller.show.lastCallArguments, [{
      url: url
      id: '2'
    }]

asyncTest "should match splat routes", 1, ->
  @app.route "/*first/fixed/:id/*last", @controller.complex
  @app.redirect url = "/x/y/fixed/10/foo/bar"
  delay =>
    deepEqual @controller.complex.lastCallArguments, [{
      url: url
      first: 'x/y'
      id: '10'
      last: 'foo/bar'
    }]

asyncTest "should match a root route", 1, ->
  Batman._routes = []
  @app.root @controller.root
  @app.redirect "/"
  delay =>
    deepEqual @controller.root.lastCallArguments, [{
      url: '/'
    }]

asyncTest "should start routing for aribtrary routes", 1, ->
  @app.stopRouting()
  window.location.hash = "#!/products/1"
  @app.route "/products/:id", spy = createSpy()
  @app.startRouting()

  delay =>
    ok spy.called

asyncTest "should listen for hashchange events", 2, ->
  @app.route "/orders/:id", spy = createSpy()
  window.location.hash = "#!/orders/1"
  
  setTimeout(->
    equal spy.callCount, 1
    window.location.hash = "#!/orders/2"
  , ASYNC_TEST_DELAY*2)

  setTimeout(->
    equal spy.callCount, 2
    start()
  , ASYNC_TEST_DELAY*4)


QUnit.module "requiring"

QUnit.module "running"