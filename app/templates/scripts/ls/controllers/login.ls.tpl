'use strict';

angular.module('<%= scriptAppName %>')
  .controller('LoginController', ($scope, simpleLogin<% if( usePasswordAuth ) { %>, $location<% } %>) ->
    $scope.pass = null
    $scope.err = null<% if( usePasswordAuth ) { %>
    $scope.email = null
    $scope.confirm = null
    $scope.createMode = false<% } %><% if( useOauth ) { %>
    $scope.user = null

    $scope.login = (service) ->
      simpleLogin.login(service, (err) ->
        $scope.err = if err then err + '' else null
      )    

    $scope.logout = simpleLogin.logout

<% if( usePasswordAuth ) { %>
    $scope.loginPassword = (cb) ->
      $scope.err = null
      if (!$scope.email)
        $scope.err = 'Please enter an email address'
      else if (!$scope.pass )
        $scope.err = 'Please enter a password'
      else
        simpleLogin.loginPassword($scope.email, $scope.pass, (err, user) ->
          $scope.err = if err then err + '' else null
          if ( !err && cb )
            cb user

        )

    $scope.createAccount = ->
      assertValidLoginAttempt ->
        if ( !$scope.email )
          $scope.err = 'Please enter an email address'
        else if (!$scope.pass )
          $scope.err = 'Please enter a password'
        else if ($scope.pass !== $scope.confirm )
          $scope.err = 'Passwords do not match'
        !$scope.err

      $scope.err = null
      if ( assertValidLoginAttempt() )
        simpleLogin.createAccount($scope.email, $scope.pass, function(err, user)
          if( err )
            $scope.err = if err then err + '' else null;
          else
            # must be logged in before I can write to my profile
            $scope.login( ->
              simpleLogin.createProfile(user.uid, user.email)
              $location.path('/account')
            )
          
        )

  )
