angular.module('calendarApp', [])
  .controller('MonthController', function($scope, $http) {
    // unchanging
    $scope.months = [];
    for (var i = 1; i <= 12; i++) {
      $scope.months.push(i);
    }

    // changing
    $scope.calendars = null;
    $scope.selectedCalendar = 'default';
    $scope.year = 2016;
    $scope.month = 8;
    $scope.days = [];

    $http
      .get('/api/v0/en/calendars')
      .success(function (data) {
        $scope.calendars = data;
        $scope.selectedCalendar = data[0];
      });

    this.loadMonth = function () {
      $http
        .get('/api/v0/en/calendars/' + $scope.selectedCalendar + '/' + $scope.year + '/' + $scope.month)
        .success(function (data) {
          $scope.days = data;
        });
    };

    $scope.$watch('[selectedCalendar, year, month]', this.loadMonth);
  });
