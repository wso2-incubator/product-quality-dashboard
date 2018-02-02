$(function() {

    var start = moment().subtract(6, 'days');
    var end = moment();

    function cb(start, end) {
        $('.config-demo span').html(start.format('YYYY MMMM, D') + ' - ' + end.format('YYYY MMMM, D'));
    }

    $('.config-demo').daterangepicker({
        startDate: moment().subtract(6, 'days'),
        endDate: end,
        ranges: {
            'Last 7 Days': [moment().subtract(6, 'days'), moment()],
            'Last 30 Days': [moment().subtract(30, 'days'), moment()],
            'This Month': [moment().startOf('month'), moment().endOf('month')],
            'Last 3 Months': [moment().startOf('month').subtract(2, 'month'), moment().endOf('month')]
        },locale: {
            format: 'YYYY-MM-DD'
        }

    }, cb);

    cb(start, end);

});
