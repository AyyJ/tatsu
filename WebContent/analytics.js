function refreshTable1() {

    $.ajax({
        type: 'GET',
        url: 'analytics.jsp',
        dataType: 'text json',
        success: function(response) {

            $('#new-topk-products-outer').css('visibility', 'visible');

            if (response[1].length > 2) {
                $('#new-topk-products-outer').html('<h3>The following products are now included in the top 50 products:</h3><div align="center" id="new-topk-products-inner"></div>');
            }
            else {
                $('#new-topk-products-outer').html('<h3>No new products are included in the top 50.</h3>');
            }

            console.log("length: " + response[1].length);

            var oldTopKProducts = $.parseJSON(response[0]);
            var newTopKProducts = $.parseJSON(response[1]);
            var newTotal = $.parseJSON(response[2]);

            $.each(noLongerTopKProducts, function(index, element) {
                $('.' + element).css('border', '3px solid #f000f0');
            });

            $.each(newTopKProducts, function(key, value) {
                $('#new-topk-products-inner').append(key + ' (' + value + ') ');
            });

            $.each(updatedTotalSales, function(key, value) {
                $('#' + key).html(value);
                $('#' + key).css('color', 'red');
            });
        }
    });

}