'use strict'
angular.module('angularfire.login', ['firebase', 'angularfire.firebase'])

  .run((simpleLogin) ->
    simpleLogin.init()
  )

  .factory('simpleLogin', ($rootScope, $firebaseSimpleLogin, firebaseRef<% if( usePasswordAuth ) { %>, profileCreator<% } %>, $timeout) ->
    assertAuth() ->
      if ( auth === null ) 
        throw new Error('Must call loginService.init() before using its methods');

    auth = null
    {
      init: ->
        auth = $firebaseSimpleLogin firebaseRef()
      ,

      logout: ->
        assertAuth()
        auth.$logout()
      ,
<% if( useOauth ) %>
      ###
       * @param {string} provider
       * @param {Function} [callback]
       * @returns {*}
      ###
      login: (provider, callback) ->
        assertAuth()
        auth.$login(provider, {rememberMe: true}).then( (user) ->
          if( callback )
            # todo-bug https://github.com/firebase/angularFire/issues/199
            $timeout( ->
              callback(null, user)
            )
        , callback)
      }<% if( usePasswordAuth ) { %>,<% } %>
<% if( usePasswordAuth ) %>
      ###
       * @param {string} email
       * @param {string} pass
       * @param {Function} [callback]
       * @returns {*}
      ###
      loginPassword: (email, pass, callback) ->
        assertAuth()
        auth.$login('password',
          email: email
          password: pass
          rememberMe: true
        ).then( (user) ->
            if( callback )
              # todo-bug https://github.com/firebase/angularFire/issues/199
              $timeout( ->
                callback(null, user)
              )
          , callback)
      ,
      changePassword: (opts) ->
        assertAuth()
        var cb = opts.callback || -> {};
        if ( !opts.oldpass || !opts.newpass )
          $timeout(-> { cb('Please enter a password') })
        else if( opts.newpass !== opts.confirm )
          $timeout( -> { cb('Passwords do not match') })
        else
          auth.$changePassword(opts.email, opts.oldpass, opts.newpass)
            .then( -> { cb(null) }, cb)
        
      ,

      createAccount: (email, pass, callback) ->
        assertAuth()
        auth.$createUser(email, pass).then((user) -> { callback(null, user) }, callback)
      ,

      createProfile: profileCreator
  )

  .factory('profileCreator', (firebaseRef, $timeout) ->
    (id, email, callback) ->
      firstPartOfEmail(email) ->
        ucfirst(email.substr(0, email.indexOf('@'))||'')

      ucfirst (str) ->
        # credits: http://kevin.vanzonneveld.net
        str += ''
        f = str.charAt(0).toUpperCase()
        f + str.substr(1)

      firebaseRef('users/'+id).set({email: email, name: firstPartOfEmail(email)}, (err) 
        # err && console.error(err)
        if ( callback )
          $timeout( ->
            callback(err)
          )
      )
  )
