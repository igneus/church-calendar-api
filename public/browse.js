angular.module('calendarApp', [])
  .controller('MonthController', function($scope, $http) {
    // unchanging
    $scope.baseUri = '/api/v0/en'
    $scope.months = [];
    for (var i = 1; i <= 12; i++) {
      $scope.months.push(i);
    }

    // changing
    var today = new Date();
    $scope.calendars = null;
    $scope.selectedCalendar = 'default';
    $scope.year = today.getFullYear();
    $scope.month = today.getMonth() + 1;
    $scope.days = [];

    $http
      .get($scope.baseUri + '/calendars')
      .success(function (data) {
        $scope.calendars = data;
        $scope.selectedCalendar = data[0];
      });

    var loadMonth = function () {
      $http
        .get($scope.baseUri + '/calendars/' + $scope.selectedCalendar + '/' + $scope.year + '/' + $scope.month)
        .success(function (data) {
          $scope.days = data;
        });
    };

    $scope.$watch('[selectedCalendar, year, month]', loadMonth);

    $scope.previousMonth = function () {
      if ($scope.month > 1) {
        $scope.month--;
      } else {
        $scope.year--;
        $scope.month = 12;
      }
    };
    $scope.nextMonth = function () {
      if ($scope.month < 12) {
        $scope.month++;
      } else {
        $scope.year++;
        $scope.month = 1;
      }
    };
  });
