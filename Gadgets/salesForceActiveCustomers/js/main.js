$(document).ready(function () {
  	$('#product').change(function() {
      var product = $('#product').val();
  	  getData(product); 
  	});

	getData($('#product').val());

});

function getData(product){
	$.ajax({     
	    url:'https://localhost:9092/base1/customer/'+product,
            async:false,
            success: function(data){
             
                  document.getElementById("tb").innerHTML="";
                  
                  for (i = 0; i < data.length; i++) {
                        
                             document.getElementById("tb").innerHTML+="<tr><td>"+(i+1)+"</td><td>"+data[i].Name+"</td><td>"+data[i].Product+"</td></tr>"

                  }
                  document.getElementById("count").innerHTML=data.length;                  
            }
      });
}