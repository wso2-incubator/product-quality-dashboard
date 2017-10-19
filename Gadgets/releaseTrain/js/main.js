  var url="10.100.4.2";
  
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
      url:"https://"+url+":9092/base/getAllReleases",
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
            console.log(Data2);
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
        height:"275px",

      };

      var flagDate=null;
      var start= now.clone().add(-28, 'days');
      var end  =now.clone().add(28, 'days');

      for(var i=Data.length-1;i>=0;i--){
        
            console.log(Data[i].start);
            var currentLoopDate=new Date(Data[i].start);

            if(start<=currentLoopDate  &&  currentLoopDate<= end){
              console.log("if1");
              options1= jQuery.extend(options, {start:start,end:end});
              break;
            }else if (end<currentLoopDate){

              flagDate=currentLoopDate;
              console.log("if2");

            }else if (currentLoopDate<start){
                console.log("if3");
            

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
        height:"275px",

      };

      timeline.setOptions(options);
      };

      
      // Create a DataSet (allows two way data-binding)
      var items = new vis.DataSet(Data);

      
      timeline.setOptions(options);
      timeline.setItems(items);
      
  };

  timeline.on('click', function (properties) {

        console.log(properties);
  });


  $('#featureTable').hide();
  
