  

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

              document.getElementById("year1").innerHTML="";
              document.getElementById("year2").innerHTML="";  
              var jsonArrayLength=data[0].length;

              for (i = 0; i < jsonArrayLength; i++) {
                
                   document.getElementById("year1").innerHTML+=" <option value="+data[0][i].Year+">"+data[0][i].Year+"</option>"
                   document.getElementById("year2").innerHTML+=" <option value="+data[0][i].Year+">"+data[0][i].Year+"</option>"
              }
              
            }
          })

var cy = (new Date()).getFullYear()
var y1 =  cy - 1;
var y2 =  cy - 2;

document.getElementById('year1').value=y1;
document.getElementById('year2').value=y2;

console.log(y1);
console.log(y2);

$.ajax({
        type: "POST",
        data: JSON.stringify({"TOKEN":"7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8"}),
        dataType: 'json',
        url:'https://'+url+":"+port+'/'+ serviceName + '/getAccProductAreas',
        success: function(data){
              
              var jsonArrayLength=data.length;

              for (i = 0; i < jsonArrayLength; i++) {
                
                
                document.getElementById("product").innerHTML+=" <option value='"+data[i]+"'>"+data[i]+"</option>"
                   
                   
                
            }

            
        }
        
        
    });

createChart();

$('.changeGraph').change(function(){
        createChart();
});

       
var serviceName = "salesForceCustomerDetailsServices";
function createChart(){
    
    var year1 = $('#year1').val();
    var year2 = $('#year2').val();
    var type=  $('#type').val();
    var category= $('#category').val();
    var product= $('#product').val();;
    var link="";
    var key="";
    var initialval=0;
    var yAxisLabale="";
    var jsonWonArray=[];
    var jsonLostArray=[];
    

    if(type=="bymonth"){
        
        link='https://'+url+":"+port+'/'+ serviceName +'/bymonthlogos/'+year1+'/'+year2+'/'+product;
        key="m";
        xAxisLabale="Month";
        initialval=1;
    }else if(type=="byquater"){
        
        link='https://'+url+":"+port+'/'+ serviceName +'/byquarterlogos/'+year1+'/'+year2+'/'+product;
        key="q";
        xAxisLabale="Quater";
        initialval=1;
    }else if(type=="byyear"){
        
        link='https://'+url+":"+port+'/'+ serviceName +'/byyearlogos/'+year1+'/'+year2+'/'+product;
        key="q";
        key="y";
        xAxisLabale="Year";
        year="";
      
    }



       
   
        var json ={}
        $.ajax({

            
            type: "POST",
            data: JSON.stringify({"TOKEN":"7FjLWmCKdvD8cs>jd])_Jw4N3_XaEZkk25r&*NM)ewqz:BkFfLf-(8"}),
            dataType: 'json',
            url:link,
            async:false,
            success: function(data){
              
                  var jsonArrayLength=data[0].length;
                  for (i = 0; i < jsonArrayLength; i++) {
                        
                            jsonWonArray[i]=data[0][i][key];
                            jsonLostArray[i]=data[1][i][key];

                  }
              

              json=data;
              console.log(data);
            }
          })

        Highcharts.chart('container', {
          chart: {
              type: 'column',
              //height: '80%',


          },
          title: {
              text: 'New Logos'
          },
          xAxis: {
                title: {
                    text: xAxisLabale
                }
          },
          yAxis: {
              min: 0,
              title: {
                  text: 'Number of new logos'
              },
              stackLabels: {
                  enabled: true,
                  style: {
                      fontWeight: 'bold',
                      color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
                  }
              }
          },
          legend: {
              align: 'right',
              x: -30,
              verticalAlign: 'top',
              y: 25,
              floating: true,
              backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
              borderColor: '#CCC',
              borderWidth: 1,
              shadow: false
          },
          tooltip: {
              headerFormat: '<b>{point.x}</b><br/>',
              pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
          },
          plotOptions: {
              column: {
                  //stacking: 'normal',
                  dataLabels: {
                      enabled: true,
                      color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
                  }
              },
              series: {
                        pointStart:1
              }
          },
          series: [{
              name: year1,
              data: jsonWonArray
          }, {
              name: year2,
              data: jsonLostArray
          }]
      
        });


       


        


}
