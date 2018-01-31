//var url="localhost";
var url="digitalops.services.wso2.com";
var port="9092";
var serviceName = "salesForceCustomerDetailsServices"; 
   $.ajax({

            type: "POST",
            data: JSON.stringify({"TOKEN":"7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8"}),
            dataType: 'json',
            url:'https://'+url+":"+port+'/'+ serviceName +'/years',
            
            async:false,
            success: function(data){
              document.getElementById("year").innerHTML="";  
              var jsonArrayLength=data[0].length;

              for (i = 0; i < jsonArrayLength; i++) {
                
                   document.getElementById("year").innerHTML+=" <option value="+data[0][i].Year+">"+data[0][i].Year+"</option>"
              }
              
            }
    })

   var cy = (new Date()).getFullYear()
   var y1 =  cy - 1;
   document.getElementById('year').value=y1;
   

   $.ajax({
        type: "POST",
        data: JSON.stringify({"TOKEN":"7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8"}),
        dataType: 'json',
        url:'https://'+url+":"+port+'/'+ serviceName + '/getOppProductAreas',
        success: function(data){
            document.getElementById("product").innerHTML="";  
              var jsonArrayLength=data.length;

              for (i = 0; i < jsonArrayLength; i++) {
                
                
                document.getElementById("product").innerHTML+=" <option value='"+data[i]+"'>"+data[i]+"</option>"
                   
                   
                
            }

            createChart();
        }
        
        
    });




$('#type').change(function(){
      if($('#type').val() == 'byyear') {
          $('#year').hide(); 
          
      } else {
          $('#year').show(); 
          
      } 
      
      
});





$('.changeGraph').change(function(){
      createChart();
});

var serviceName = "salesForceCustomerDetailsServices";
function createChart(){
       
        var year = $('#year').val();

        var product= $('#product').val();
        var type=  $('#type').val();
        var link="";
        var key="";
        var initialval=0;
        var yAxisLabale="";
        var jsonWonArray=[];
        var jsonLostArray=[];
        

        if(type=="bymonth"){
           
            link='https://'+url+":"+port+'/'+ serviceName +'bymonth/'+product+'/'+year;
            
            key="m";
            xAxisLabale="Month";
            initialval=0;
            categories=['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        }else if(type=="byquarter"){
            
            link='https://'+url+":"+port+'/'+ serviceName +'/byquarter/'+product+'/'+year;
            
            key="q";
            xAxisLabale="Quarter";
            initialval=0;
            categories=['Q1','Q2','Q3','Q4'];
        }else if(type=="byyear"){
            
            link='https://'+url+":"+port+'/'+ serviceName +'/byyear/'+product ;
           
            key="y";
            xAxisLabale="Year";
            year="";
            $("#year").hide();
            categories=[];

        }

        var jsonPost = {"TOKEN":"7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8"};
        
        var json ={}
        $.ajax({

            
            type: "POST",
            data: JSON.stringify(jsonPost),
            dataType: 'json',
            url:link,
            async:false,
            success: function(data){
              
              if(type=="byyear"){
                    jsonWonArray=data[0].won;
                    jsonLostArray=data[1].lost;
                    initialval=data[2].year[0];
              }else{
                  var jsonArrayLength=data[0].length;
                  for (i = 0; i < jsonArrayLength; i++) {
                        
                            jsonWonArray[i]=data[0][i][key];
                            jsonLostArray[i]=data[1][i][key];

                  }
              }

              json=data;
              console.log(jsonWonArray);
            }
        });


        Highcharts.chart('containerTrendChart', {

                title: {
                    text: year
                },

                subtitle: {
                    text: 'Wons/Losts'
                },

                yAxis: {
                    title: {
                        text: 'Number of Opportunities'
                    }
                },
                xAxis: {
                    categories:categories,
                    title: {
                        text: xAxisLabale
                    }
                },
                

                plotOptions: {
                    series: {
                        pointStart:initialval
                    }
                },

                series: [{
                    name: 'WON',
                    data: jsonWonArray

                },
                {
                    name: 'LOST',
                    data: jsonLostArray
                }]

              });   


        


}
