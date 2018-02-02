$(window).on('load', function() {
    initPage();

    var fixedIssesDivTop = $('.fixedIssesDiv').offset().top;
    $('.right-scrolling-body').scroll(function() {
        var currentScroll = $('.right-scrolling-body').scrollTop();
        var scrollTop = $('.right-scrolling-body').offset().top;
        if (currentScroll >= fixedIssesDivTop && currentScroll<=1390) {
            $('.fixedIssesDiv').css({
                position: 'fixed',
                top: scrollTop,
               'box-shadow': '0 2px 5px rgba(0,0,0,0.2),0 2px 5px rgba(0,0,0,0.19)',
               'width':'76.35997313633311vw'

            });
        } else {
            $('.fixedIssesDiv').css({
                position: 'static',
                'box-shadow': '0px 0px 0px',
                width:'auto'
            });
        }
    });window

    var fixedSonarDivTop = $('.fixedSonarDiv').offset().top;

    $('.right-scrolling-body').scroll(function() {
        var currentScroll = $('.right-scrolling-body').scrollTop();
        var scrollTop = $('.right-scrolling-body').offset().top;
        if (currentScroll >= fixedSonarDivTop ) {
            $('.fixedSonarDiv').css({
                position: 'fixed',
                top: scrollTop,
                'box-shadow': '0 2px 5px rgba(0,0,0,0.2),0 2px 5px rgba(0,0,0,0.19)',
                width:'76.35997313633311vw'

            });
        } else {
            $('.fixedSonarDiv').css({
                position: 'static',
                'box-shadow': '0px 0px 0px',
                width:'auto'
            });
        }
    });window

});

$(".right-scrolling-body").scroll(function() {
  $(".daterangepicker").hide();
  $('#issue-calender').blur();
});

$(window).resize(function() {
  $(".daterangepicker").hide();
  $('#issue-calender').blur();
});

$(".right-scrolling-body").scroll(function() {
  $(".daterangepicker").hide();
  $('#sonar-calender').blur();
});

$(window).resize(function() {
  $(".daterangepicker").hide();
  $('#sonar-calender').blur();
});


var start = moment().subtract(29, 'days');
var end = moment();
var startDate = start.format('YYYY-MM-DD');
var endDate = end.format('YYYY-MM-DD');

$(function() {

    function cb(start, end) {
        $('#sonar-calender span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
    }

    $('#sonar-calender').daterangepicker({
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

    function cd(start, end) {
        $('#issue-calender span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
    }

    $('#issue-calender').daterangepicker({
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
    }, cd);

    cd(start, end);

});

$('#dailyBtn').click(function(){
    getIssueTrendLineHistory("day");
});
$('#monthlyBtn').click(function(){
    getIssueTrendLineHistory("Month");
});
$('#quarterlyBtn').click(function(){
    getIssueTrendLineHistory("Quarter");
});
$('#yearlyBtn').click(function(){
    getIssueTrendLineHistory("Year");
});


$('#dailyBtnSonar').click(function(){
    getSonarTrendLineHistory("day");
});
$('#monthlyBtnSonar').click(function(){
    getSonarTrendLineHistory("Month");
});
$('#quarterlyBtnSonar').click(function(){
    getSonarTrendLineHistory("Quarter");
});
$('#yearlyBtnSonar').click(function(){
    getSonarTrendLineHistory("Year");
});

$('#resetView').click(function(){
    resetDashboardView();
});


$('#issue-calender').on('apply.daterangepicker', function(ev, picker) {

    startDate = picker.startDate.format('YYYY-MM-DD');
    endDate = picker.endDate.format('YYYY-MM-DD');
    setIssueDate(startDate, endDate);
    <!--setIssueCalender();-->
    getIssueTrendLineHistory("day");
});
$('#sonar-calender').on('apply.daterangepicker', function(ev, picker) {

    startDate = picker.startDate.format('YYYY-MM-DD');
    endDate = picker.endDate.format('YYYY-MM-DD');
    setSonarDate(startDate, endDate);
    <!--setSonarCalender();-->
    getSonarTrendLineHistory("day");
});