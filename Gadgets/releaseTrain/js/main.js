  
  var url="digitalops.services.wso2.com";
  var port="9092";
  // create a handlebars template
  var source   = document.getElementById('item-template').innerHTML;
  var template = Handlebars.compile(document.getElementById('item-template').innerHTML);

  // DOM element where the Timeline will be attached
  var container = document.getElementById('visualization');


  var Data1={}; //all
  var Data2={}; //apim
  var Data3={}; //analytics
  var Data4={}; //cloud
  var Data5={}; //integration
  var Data6={}; //iot
  var Data7={}; //is
  var Data8={}; //other


  var f1=0; //flag for all
  var f2=0; //flag for apim
  var f3=0; //flag for analytics
  var f4=0; //flag for cloud
  var f5=0; //flag for integration
  var f6=0; //flag for iot
  var f7=0; //flag for is
  var f8=0; //flag for other


  // get the initial data to the time line
  $.ajax({
      url:"https://"+url+":"+port+"/base/getAllReleases",
      async:false,
      success: function(data){
        Data1=data;  
        //console.log(Data1);
      }
  });


  //draw the timeline depending on the product area
  $(document).ready(function () {
    $('input[type=radio][name=optradio]').change(function() {

        if ($('input[name=optradio]:checked').val() == 'All') {
            
            $('#featureTable').hide();
            drawTimeLine(Data1,template);
        }
        else if (this.value == 'API Manager') {
            $('#featureTable').hide();
            getData(f2,"apim");
            drawTimeLine(Data2,template);
        }
        else if (this.value == 'Analytics') {
            $('#featureTable').hide();
            getData(f3,"analytics");
            drawTimeLine(Data3,template);
        }
        else if (this.value == 'Cloud') {
            $('#featureTable').hide();
            getData(f4,"cloud");
            drawTimeLine(Data4,template);
        }
        else if (this.value == 'Integration') {
            $('#featureTable').hide();
            getData(f5,"integration");
            drawTimeLine(Data5,template);
        }
        else if (this.value == 'IOT') {
            $('#featureTable').hide();
            getData(f6,"iot");
            drawTimeLine(Data6,template);
        }else if (this.value == 'IS') {
            $('#featureTable').hide();
            getData(f7,"identity");
            drawTimeLine(Data7,template);
        }else if (this.value == 'Other') {
            $('#featureTable').hide();
            getData(f8,"other");
            drawTimeLine(Data8,template);

        }
    });
  });


  // hide the summary and feature table
  $('#storySummary').hide();
  $('#featureSummary').hide();

  

  // Create a Timeline
  var timeline = new vis.Timeline(container);

  // by this function call, initial timeline items will be displayed
  drawTimeLine(Data1,template);

  //draw the timeline
  function drawTimeLine(Data,template){
      var now = moment().minutes(0).seconds(0).milliseconds(0);
   
      // Configuration for the Timeline
      var options = {
        
        template: template,
        zoomable:false,
        timeAxis: {scale: 'day', step:1 },
        //height:"277px",
        height:"550px",
        //orientation: {axis: 'both'}

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

      
      // by clicking on today button time line will redraw the data.
      document.getElementById('toggleRollingMode').onclick = function () { 
        

        options = {
        
          start: now.clone().add(-28, 'days'),
          end: now.clone().add(28, 'days'),
          template: template,
          zoomable:false,
          timeAxis: {scale: 'day', step:1 },
          //height:"277px",
          height:"550px",
          //orientation: {axis: 'both'}

        };

        timeline.setOptions(options);
      };

      
      // Create a DataSet (allows two way data-binding)
      var items = new vis.DataSet(Data);

      
      timeline.setOptions(options);
      timeline.setItems(items);    
  };

  // today button logic
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

  
  
