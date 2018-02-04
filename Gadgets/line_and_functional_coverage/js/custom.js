$(window).on('load', function() {
    initPage();
});

$(".right-scrolling-body").scroll(function() {
  $(".daterangepicker").hide();
  $('#coverage-calender').blur();
});

$(window).resize(function() {
  $(".daterangepicker").hide();
  $('#coverage-calender').blur();
});


var start = moment().subtract(29, 'days');
var end = moment();
var startDate = start.format('YYYY-MM-DD');
var endDate = end.format('YYYY-MM-DD');

$(function() {

    function cb(start, end) {
        $('#coverage-calender span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
    }

    $('#coverage-calender').daterangepicker({
        startDate: start,
        endDate: end,
        ranges: {
            <!--'Today': [moment(), moment()],-->
            <!--'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],-->
            'Last 7 Days': [moment().subtract(6, 'days'), moment()],
            'Last 30 Days': [moment().subtract(29, 'days'), moment()],
            'This Month': [moment().startOf('month'), moment().endOf('month')],
            'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
        }
    }, cb);

    cb(start, end);

});


$('#dailyBtn').click(function(){
    getTrendLineHistory("day");
});
$('#monthlyBtn').click(function(){
    getTrendLineHistory("Month");
});
$('#quarterlyBtn').click(function(){
    getTrendLineHistory("Quarter");
});
$('#yearlyBtn').click(function(){
    getTrendLineHistory("Year");
});

$('#resetView').click(function(){
    resetDashboardView();
});

$('#coverage-calender').on('apply.daterangepicker', function(ev, picker) {

    startDate = picker.startDate.format('YYYY-MM-DD');
    endDate = picker.endDate.format('YYYY-MM-DD');
    setSelectionDate(startDate, endDate);
    getTrendLineHistory("day");
});