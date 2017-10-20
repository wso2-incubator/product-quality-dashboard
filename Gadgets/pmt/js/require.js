$(function() {

    var start = moment().subtract(29, 'days');
    var end = moment();

    function cb(start, end) {
        $('.config-demo span').html(start.format('YYYY MMMM, D') + ' - ' + end.format('YYYY MMMM, D'));
    }

    $('.config-demo').daterangepicker({
        startDate: moment().subtract(30, 'days'),
        endDate: end,
        ranges: {
            'Today': [moment(), moment()],
            'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
            'Last 7 Days': [moment().subtract(6, 'days'), moment()],
            'Last 30 Days': [moment().subtract(30, 'days'), moment()],
            'Last 365 Days': [moment().subtract(365, 'days'), moment()],
            'This Month': [moment().startOf('month'), moment().endOf('month')],
            'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')],
            'Last Year': [moment().subtract(1, 'year').startOf('year'), moment().subtract(1, 'year').endOf('year')]
        },locale: {
            format: 'YYYY-MM-DD'
        }

    }, cb);

    cb(start, end);

});
