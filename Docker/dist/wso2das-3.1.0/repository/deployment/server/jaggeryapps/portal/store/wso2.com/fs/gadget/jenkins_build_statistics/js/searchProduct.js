
//search the product by typing in the input field

$('#iconified').on('keyup', function() {
    var input = $(this);
    if(input.val().length === 0) {
        input.addClass('empty');
    } else {
        input.removeClass('empty');
    }
});
function filter(element) {
    var value = $(element).val().toLowerCase();;
    $("#components > a").each(function() {
        var listVal = $(this).text().toLowerCase();
        if (listVal.indexOf(value)>= 0) {
            $(this).show();
        }
        else {
            $(this).hide();
        }
    });
}
