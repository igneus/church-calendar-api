angular.module('calendarApp', [])
  .controller('MonthController', function($scope, $http) {
    $scope.calendars = null;
    $scope.selectedCalendar = null;

    $http.get('/api/v0/en/calendars')
      .success(function (data) {
        $scope.calendars = data;
        $scope.selectedCalendar = data[0];
      });
  });
