QUnit.module 'Batman.HashbangNavigator',
  setup: ->
    @app = Batman
      dispatcher:
        dispatch: @dispatchSpy = createSpy()
    @nav = new Batman.HashbangNavigator(@app)

test "pathFromLocation(window.location) returns the app-relative path", ->
  equal @nav.pathFromLocation(hash: '#!/foo/bar?page=2'), '/foo/bar?page=2'
  equal @nav.pathFromLocation(hash: '#/foo/bar?page=2'), '/'
  equal @nav.pathFromLocation(hash: '#'), '/'
  equal @nav.pathFromLocation(hash: ''), '/'

asyncTest "pushState(stateObject, title, path) sets window.location.hash", ->
  @nav.pushState(null, '', '/foo/bar')
  delay =>
    equal window.location.hash, "#!/foo/bar"

unless IN_NODE #jsdom doesn't like window.location.replace
  asyncTest "replaceState(stateObject, title, path) replaces the current history entry", ->
    window.location.hash = '#!/one'
    window.location.hash = '#!/two'
    @nav.replaceState(null, '', '/three')
    equal window.location.hash, "#!/three"

    window.history.back()

    doWhen (-> window.location.hash is "#!/one"), ->
      equal window.location.hash, "#!/one"
      QUnit.start()

test "handleLocation(window.location) dispatches based on pathFromLocation", ->
  @nav.handleLocation
    pathname: Batman.config.pathPrefix
    search: ''
    hash: '#!/foo/bar?page=2'
  equal @dispatchSpy.callCount, 1
  deepEqual @dispatchSpy.lastCallArguments, ["/foo/bar?page=2"]


test "handleLocation(window.location) handles the real non-hashbang path if present, but only if Batman.config.usePushState is true", ->
  location =
    pathname: @nav.normalizePath(Batman.config.pathPrefix, '/baz')
    search: '?q=buzz'
    hash: '#!/foo/bar?page=2'
    replace: createSpy()
  @nav.handleLocation(location)
  equal location.replace.callCount, 1
  deepEqual location.replace.lastCallArguments, ["#{Batman.config.pathPrefix}#!/baz?q=buzz"]

  Batman.config.usePushState = false
  @nav.handleLocation(location)
  equal location.replace.callCount, 1

test "detectHashChange should trigger handleHashChange on change", ->
  @nav.handleHashChange = createSpy()

  window.location.hash = 'new_hash'
  @nav.detectHashChange()
  equal @nav.handleHashChange.callCount, 1

  # Make sure handleHashChange is not called when hash hasn't changed
  @nav.detectHashChange()
  equal @nav.handleHashChange.callCount, 1

  window.location.hash = 'new_hash_2'
  @nav.detectHashChange()
  equal @nav.handleHashChange.callCount, 2
