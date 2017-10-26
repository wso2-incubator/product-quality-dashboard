  var url="192.168.56.2";
  var port="9092";
  // create a handlebars template
  var source   = document.getElementById('item-template').innerHTML;
  var template = Handlebars.compile(document.getElementById('item-template').innerHTML);

  // DOM element where the Timeline will be attached
  var container = document.getElementById('visualization');


  var Data1={};
  var Data2={};
  var Data3={};
  var Data4={};
  var Data5={};
  var Data6={};
  var Data7={};
  var Data8={};


  var f1=0;
  var f2=0;
  var f3=0;
  var f4=0;
  var f5=0;
  var f6=0;
  var f7=0;
  var f8=0;


  // get the initial data to the time line
  $.ajax({
      url:"https://"+url+":"+port+"/base/getAllReleases",
      async:false,
      success: function(data){
        Data1=data;  
      }
  });


  $(document).ready(function () {
    $('input[type=radio][name=optradio]').change(function() {

        if ($('input[name=optradio]:checked').val() == 'All') {
            
            $('#featureTable').hide();
            x(Data1,template);
        }
        else if (this.value == 'API Manager') {
            $('#featureTable').hide();
            getData(f2,"apim");
            x(Data2,template);
        }
        else if (this.value == 'Analytics') {
            $('#featureTable').hide();
            getData(f3,"analytics");
            x(Data3,template);
        }
        else if (this.value == 'Cloud') {
            $('#featureTable').hide();
            getData(f4,"cloud");
            x(Data4,template);
        }
        else if (this.value == 'Integration') {
            $('#featureTable').hide();
            getData(f5,"integration");
            x(Data5,template);
        }
        else if (this.value == 'IOT') {
            $('#featureTable').hide();
            getData(f6,"iot");
            x(Data6,template);
        }else if (this.value == 'IS') {
            $('#featureTable').hide();
            getData(f7,"identity");
            x(Data7,template);
        }else if (this.value == 'Other') {
            $('#featureTable').hide();
            getData(f8,"other");
            x(Data8,template);

        }
    });

  });

  $('#storySummary').hide();
  $('#featureSummary').hide();

  

  
  // Create a Timeline
  var timeline = new vis.Timeline(container);

  x(Data1,template);

  function x(Data,template){
      var now = moment().minutes(0).seconds(0).milliseconds(0);
   
      // Configuration for the Timeline
      var options = {
        
        template: template,
        zoomable:false,
        timeAxis: {scale: 'day', step:1 },
        height:"40vh",

      };

      var flagDate=null;
      var start= now.clone().add(-28, 'days');
      var end  =now.clone().add(28, 'days');

      for(var i=Data.length-1;i>=0;i--){
        
            
            var currentLoopDate=new Date(Data[i].start);

            if(start<=currentLoopDate  &&  currentLoopDate<= end){
              
              
              

              options1= jQuery.extend(options, {start:start,end:end});
              break;
            }else if (end<currentLoopDate){

              flagDate=currentLoopDate;
              

            }else if (currentLoopDate<start){
                
            

                if(flagDate==null){

                  
                  
                  
                  start=moment(Data[i].start).add(-28, 'days');
                  end=moment(Data[i].start).add(28, 'days');
                  options1= jQuery.extend(options, {start:start,end:end});
                  break;
                }else{

                  
                  
                  start=moment(flagDate).add(-28, 'days');
                  end=moment(flagDate).add(28, 'days');
                  options1= jQuery.extend(options, {start:start,end:end});
                  break;
                }
            
        }

      }

      

      document.getElementById('toggleRollingMode').onclick = function () { 
        

        options = {
        

        start: now.clone().add(-28, 'days'),
        end: now.clone().add(28, 'days'),

        
        template: template,
        zoomable:false,
        timeAxis: {scale: 'day', step:1 },
        height:"40vh",

      };

      timeline.setOptions(options);
      };

      
      // Create a DataSet (allows two way data-binding)
      var items = new vis.DataSet(Data);

      
      timeline.setOptions(options);
      timeline.setItems(items);
      
  };


  timeline.on('rangechanged', function (properties) {
    
    var now = moment().minutes(0).seconds(0).milliseconds(0);
    var start=moment(properties.start);
    var end=moment(properties.end);
    var duration1 = moment.duration(now.diff(start));
    var duration2 = moment.duration(end.diff(now));
    var days1 = duration1.asDays();
    var days2 = duration2.asDays();

    if(days1<0){
        $(".todayposition").removeClass("today3");
        $(".todayposition").removeClass("today1");
        $(".todayposition").addClass("today2");
        $("#leftArrow").css("display","block");
        $("#rightArrow").css("display","none");
    }else if(days2<0){
        $(".todayposition").removeClass("today3");
        $(".todayposition").removeClass("today2");
        $(".todayposition").addClass("today1");
        $("#leftArrow").css("display","none");
        $("#rightArrow").css("display","block");
    }else{
        $(".todayposition").removeClass("today2");
        $(".todayposition").removeClass("today1");
        $(".todayposition").addClass("today3");
        $("#leftArrow").css("display","none");
        $("#rightArrow").css("display","none");
    }
  

    


  });

  


  $('#featureTable').hide();
  
