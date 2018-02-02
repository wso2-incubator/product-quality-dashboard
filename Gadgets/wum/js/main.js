  //var url="203.94.95.237";
  //var url="10.100.4.2";
  //var url="localhost";
  var url="digitalops.services.wso2.com";
  var port="9092";
  //var port="9096";
  // create a handlebars template
  var source   = document.getElementById('item-template').innerHTML;
  var template = Handlebars.compile(document.getElementById('item-template').innerHTML);

  // DOM element where the Timeline will be attached
  var container = document.getElementById('visualization');


  var allData={}; //all
  var apimData={}; //apim
  var analyticsData={}; //analytics
  var cloudData={}; //cloud
  var integrationData={}; //integration
  var iotData={}; //iot
  var isData={}; //is
  var otherData={}; //other


  var allFlag=0; //flag for all
  var apimFlag=0; //flag for apim
  var analyticsFlag=0; //flag for analytics
  var cloudFlag=0; //flag for cloud
  var integrationFlag=0; //flag for integration
  var iotFlag=0; //flag for iot
  var isFlag=0; //flag for is
  var otherFlag=0; //flag for other


  

var radioValue;
  //draw the timeline depending on the product area
  $(document).ready(function () {
    $('input[type=radio][name=optradio]').change(function() {

        radioValue = $("input[name='optradio']:checked").val();

        if (radioValue == 'All') {
            
            $('#featureTable').hide();
            allData =getData("all");
            drawTimeLine(allData,template);
        }
        else if (radioValue == 'API Manager') {
            $('#featureTable').hide();
            
            apimData=getData("apim");
            drawTimeLine(apimData,template);
        }
        else if (radioValue == 'Analytics') {

            $('#featureTable').hide();
            analyticsData=getData("analytics");
            drawTimeLine(analyticsData,template);
        }
        else if (radioValue == 'Cloud') {

            $('#featureTable').hide();
            cloudData=getData("cloud");
            drawTimeLine(cloudData,template);
        }
        else if (radioValue == 'Integration') {

            $('#featureTable').hide();
            integrationData=getData("integration");
            drawTimeLine(integrationData,template);
        }
        else if (radioValue == 'IOT') {

            $('#featureTable').hide();
            iotData =getData("iot");
            drawTimeLine(iotData,template);
        }else if (radioValue == 'IS') {

            $('#featureTable').hide();
            isData =getData("identity");
            drawTimeLine(isData,template);
        }else if (radioValue == 'Other') {

            $('#featureTable').hide();
            otherData=getData("other");
            drawTimeLine(otherData,template);

        }
    });
  });

  function loadData(){



        radioValue = $("input[name='optradio']:checked").val();

        if (radioValue == 'All') {
            
            $('#featureTable').hide();
            allData =getData("all");
            console.log(allData);

            drawTimeLine(allData,template);
        }
        else if (radioValue == 'API Manager') {
            $('#featureTable').hide();
            
            apimData=getData("apim");
            drawTimeLine(apimData,template);
        }
        else if (radioValue == 'Analytics') {

            $('#featureTable').hide();
            analyticsData=getData("analytics");
            drawTimeLine(analyticsData,template);
        }
        else if (radioValue == 'Cloud') {

            $('#featureTable').hide();
            cloudData=getData("cloud");
            drawTimeLine(cloudData,template);
        }
        else if (radioValue == 'Integration') {

            $('#featureTable').hide();
            integrationData=getData("integration");
            drawTimeLine(integrationData,template);
        }
        else if (radioValue == 'IOT') {

            $('#featureTable').hide();
            iotData =getData("iot");
            drawTimeLine(iotData,template);
        }else if (radioValue == 'IS') {

            $('#featureTable').hide();
            isData =getData("identity");
            drawTimeLine(isData,template);
        }else if (radioValue == 'Other') {

            $('#featureTable').hide();
            otherData=getData("other");
            drawTimeLine(otherData,template);

        }

  }

  // hide the summary and feature table
  $('#storySummary').hide();
  $('#featureSummary').hide();

  
  // Create a Timeline
  var timeline = new vis.Timeline(container);

  
  //draw the timeline
  function drawTimeLine(data,template){
      var now = moment().minutes(0).seconds(0).milliseconds(0);
   
      // Configuration for the Timeline
      var options = {
        
        template: template,
        zoomable:false,
        timeAxis: {scale: 'day', step:1 },
        height:"550px",
        //orientation: {axis: 'top',item:'top'}
        //orientation: {axis: 'both'}

      };

      var flagDate=null;
      var start= now.clone().add(-10, 'days');
      var end  =now.clone().add(10, 'days');

      console.log(start);
      console.log(end);
      console.log(data);
      //this for loop for focus the timeline to a release. other wise time line will be empty.

      if (data.length>0){
        for(var i=data.length-1;i>=0;i--){
          
              
              var currentLoopDate=new Date(data[i].start);
              console.log(currentLoopDate);
        

              if(start<=currentLoopDate  &&  currentLoopDate<= end){
                options1= jQuery.extend(options, {start:start,end:end});
                break;
              }else if (end<currentLoopDate){

                flagDate=currentLoopDate;

              }else if (currentLoopDate<start){
                  
                  if(flagDate==null){
   
                    start=moment(data[i].start).add(-10, 'days');
                    end=moment(data[i].start).add(10, 'days');
                    options1= jQuery.extend(options, {start:start,end:end});
                    break;
                  }else{
                    
                    start=moment(flagDate).add(-10, 'days');
                    end=moment(flagDate).add(10, 'days');
                    options1= jQuery.extend(options, {start:start,end:end});
                    break;
                  }
              
              }
        }
      }else{
        options1= jQuery.extend(options, {start:start,end:end});
      } 

      console.log(start);
      console.log(end);

      
      // by clicking on today button time line will redraw the data.
      document.getElementById('toggleRollingMode').onclick = function () { 
        
        options = {
        
          start: now.clone().add(-10, 'days'),
          end: now.clone().add(10, 'days'),
          template: template,
          zoomable:false,
          timeAxis: {scale: 'day', step:1 },
          height:"550px",
          //orientation: {axis: 'top',item:'top'}
          //orientation: {axis: 'both'}

        };

        timeline.setOptions(options);
      };

      
      // Create a DataSet (allows two way data-binding)
      var items = new vis.DataSet(data);
      console.log("items");
      console.log(data);
      
      timeline.setOptions(options);
      timeline.setItems(items);    
  };

  // today button logic
  timeline.on('rangechanged', function (properties) {
    var now = moment().minutes(0).seconds(0).milliseconds(0);
    var start=moment(properties.start);
    var end=moment(properties.end);
    var firstDuration = moment.duration(now.diff(start)); //(|   |...|)
    var secondDuration = moment.duration(end.diff(now));  //(|...|   |)
    var firstDurationDays = firstDuration.asDays();
    var secondDurationDays = secondDuration.asDays();

    if(firstDurationDays<0){
        $(".todayposition").removeClass("hideTodayButton");
        $(".todayposition").removeClass("todayButtonRightSide");
        $(".todayposition").addClass("todayButtonLeftSide");
        $("#leftArrow").css("display","block");
        $("#rightArrow").css("display","none");
    }else if(secondDurationDays<0){
        $(".todayposition").removeClass("hideTodayButton");
        $(".todayposition").removeClass("todayButtonLeftSide");
        $(".todayposition").addClass("todayButtonRightSide");
        $("#leftArrow").css("display","none");
        $("#rightArrow").css("display","block");
    }else{
        $(".todayposition").removeClass("todayButtonLeftSide");
        $(".todayposition").removeClass("todayButtonRightSide");
        $(".todayposition").addClass("hideTodayButton");
        $("#leftArrow").css("display","none");
        $("#rightArrow").css("display","none");
    }
  
  });


  
  
