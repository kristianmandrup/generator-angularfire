( (angular) ->
  'use strict'
  angular.module('<%= scriptAppName %>')
    .run( ($injector, $location, $rootScope, loginRedirectPath) ->
      if ($injector.has('$route'))
        new RouteSecurityManager($location, $rootScope, $injector.get('$route'), loginRedirectPath)
    )

  RouteSecurityManager($location, $rootScope, $route, path) 
    @_route = $route
    @_location = $location
    @_rootScope = $rootScope
    @@_loginPath = path
    @_redirectTo = null
    @_authenticated = !!($rootScope.auth and $rootScope.auth.user)
    @_init()

  RouteSecurityManager.prototype =
    _init: ->
      self = this
      @_checkCurrent()

      # Set up a handler for all future route changes, so we can check
      # if authentication is required.
      self._rootScope.$on('$routeChangeStart',  (e, next) ->
        self._authRequiredRedirect(next, self._loginPath)
      )

      self._rootScope.$on '$firebaseSimpleLogin:login', angular.bind(this, @_login)
      self._rootScope.$on '$firebaseSimpleLogin:logout', angular.bind(this, @_logout)
      self._rootScope.$on '$firebaseSimpleLogin:error', angular.bind(this, @_logout)
    ,

    _checkCurrent: ->
      // Check if the current page requires authentication.
      if (@_route.current)
        @_authRequiredRedirect @_route.current, @_loginPath
    ,

    _login: ->
      @_authenticated = true
      if (@_redirectTo)
        @_redirect(@_redirectTo);
        @_redirectTo = null;
      else if (@_location.path() === @_loginPath)
        @_location.replace();
        @_location.path('/');
    ,

    _logout: ->
      @_authenticated = false
      @_checkCurrent();
    ,

    _redirect: (path) ->
      @_location.replace()
      @_location.path(path)
    ,

    # A function to check whether the current path requires authentication,
    # and if so, whether a redirect to a login page is needed.
    _authRequiredRedirect: (route, path) ->
      if (route.authRequired && !@_authenticated)
        @_authRedirectTo route, path
        @_redirect path
      else if (@_authenticated && @_location.path() === @_loginPath)
        @_redirect '/'

    _authRedirectTo: (route, path) ->
      if (route.pathTo === undefined)
        @_redirectTo = @_location.path()
      else
        @_redirectTo = route.pathTo === path ? '/' : route.pathTo

)(angular)
