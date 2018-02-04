 //var url="localhost";
 var url="digitalops.services.wso2.com";
 var port="9092";
 var serviceName = "salesForceCustomerDetailsServices";

$.ajax({
        type: "POST",
        data: JSON.stringify({"TOKEN":"7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8"}),
        dataType: 'json',
        url:'https://'+url+":"+port+'/'+ serviceName + '/getOppLineItemProductAreas',
        success: function(data){
            //document.getElementById("product").innerHTML="";  
              var jsonArrayLength=data.length;

              for (i = 0; i < jsonArrayLength; i++) {
                
                //console.log(data[i]);
                document.getElementById("product").innerHTML+=" <option value='"+data[i]+"'>"+data[i]+"</option>"
                   
                   
                
            }

            
        }
        
        
    });






 $(document).ready(function () {
	$('#product').change(function() {
    var product = $('#product').val();
	  getData(product); 
	});

	getData($('#product').val());

  });

 

function getData(product){
	$.ajax({

            
            type: "POST",
            data: JSON.stringify({"TOKEN":"7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8"}),
            dataType: 'json',
	          url:'https://'+url+":"+port+'/'+ serviceName +'/customer/'+product,
            async:false,
            success: function(data){
            
                  
                  console.log(data);
                  

                  data[0].sort( predicateBy("Arr") );// this is for sort the json by ARR value
                  
                  document.getElementById("tb").innerHTML="";
                  document.getElementById("hd").innerHTML="";
                  
                  if(product!="All"){

                    document.getElementById("tb").innerHTML+="<tr><th>#</th><th>Customer Name</th><th>Product</th><th>ARR</th></tr>"
                    
                    for (i = 0; i < data[0].length; i++) {

                      var number = parseInt(data[0][i].Arr);
		      var options1 = { style: "currency", currency: "USD" };  
		      var arr = number.toLocaleString("en-US",options1);
                            
                      document.getElementById("tb").innerHTML+="<tr><td>"+(i+1)+"</td><td>"+data[0][i].Name+"</td><td>"+data[0][i].Area+"</td><td>"+arr+"</td></tr>"

                    }

                  }else{

                    document.getElementById("tb").innerHTML+="<tr><th>#</th><th>Customer Name</th><th>ARR</th></tr>"

                    for (i = 0; i < data[0].length; i++) {

                      var number = parseInt(data[0][i].Arr);
		      var options1 = { style: "currency", currency: "USD" };  
		      var arr = number.toLocaleString("en-US",options1);

                      
                            
                      document.getElementById("tb").innerHTML+="<tr><td>"+(i+1)+"</td><td>"+data[0][i].Name+"</td><td>"+arr+"</td></tr>"

                    }

                  }

                  
                  document.getElementById("count").innerHTML=data[1];

                  
              

          
            }
  });
}


function predicateBy(prop){
   return function(a,b){
      if( a[prop] < b[prop]){
          return 1;
      }else if( a[prop] > b[prop] ){
          return -1;
      }
      return 0;
   }
}




