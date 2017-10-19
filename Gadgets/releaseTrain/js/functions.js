var lastid= ""; // changeButtonColor() uses this variable 
var dataSet; // drawManagerTable() and drawManagerSummaryTable() uses this varable.

function showLoader() {
  $('[data-toggle="loading"]').loading('show');
  var myVar = setTimeout(showPage, 3000);
}

function showPage() {
  $('[data-toggle="loading"]').loading('hide');
  document.getElementById("myDiv").style.display = "block";
}

function changeButtonColor(releaseid){
  
  console.log("releaseID: "+releaseid);
  var f = lastid;
  if(lastid !== ""){
    
    $('#visualization').on('click', '[data-control=userBtn]', function() {
                
      $(f).css("border-width","1px");
        
    });
              
    
    $('#visualization').on('click', '[data-control=userBtn]', function() {
      
      $('#'+releaseid).css("border-width","7px");
      
    });

    lastid = '#'+releaseid;
              
  }else{
    
    $('#visualization').on('click', '[data-control=userBtn]', function() {
      
      $('#'+releaseid).css("border-width","7px");
      

    });

    lastid = '#'+releaseid;
  }
}

function test(releaseid){

    $('#featureTable').css("display","block");
    changeButtonColor(releaseid);
    
    timeline.on('click', function (properties) {

      console.log(properties);

      if (properties.item==null){
          return;
      }

          
      var cardid=properties.item;
      var data;

      if ($("input[name=optradio]:checked").val()=="All"){
        //use Data1
        console.log("Data1");
        data=Data1;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="API Manager"){
        //use Data2
        console.log("Data2");
        console.log(properties.item);
        console.log(releaseid);
        data=Data2;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="Analytics"){
        //use Data3
        data=Data3;
        drawSummaryTable(data,cardid,releaseid);


      }else if($("input[name=optradio]:checked").val()=="Cloud"){
        //use Data4
        data=Data4;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="Integration"){
        //use Data5
        data=Data5;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="IOT"){
        //use Data6
        data=Data6;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="IS"){
        //use Data7
        data=Data7;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="Other"){
        //use Data8
        data=Data8;
        drawSummaryTable(data,cardid,releaseid);
      }
          
      data={};
      

    });             
}

function drawSummaryTable(data,cardid,releaseid){
  $('#featureTable').show();
  $('.detailedinfo').empty();
    var instruction = "<div class=well ><p> Click one of the lables in the Release Summary to see more details. </p></div>"
  $('.detailedinfo').append(instruction);

  $('.summary').empty();
  
 
  var dataLength=data[cardid-1].releases.length;
  
  var dataSet={};
  for (var i=0;i<dataLength;i++){
    if (releaseid==data[cardid-1].releases[i].id){
      dataSet=data[cardid-1].releases[i];
      
      break;
    }
    
  }

  var source   = $("#releaseSummary").html();
  var template = Handlebars.compile(source);
  var html    = template(dataSet);
  $( ".summary" ).append(  html );
}

function closeTable(id){
  $(id).hide();
}

function drawManagerTable(product,startDate,endDate){
  
  $('#managerSummary').empty();

  $.ajax({
      url:"https://"+url+":9092/base/manager/"+product+"/"+startDate+"/"+endDate,
      async:false,
      success: function(data){
        dataSet=data;  
      }
  });
  
  var dataSetLength=dataSet.length;

  for(var i=0; i<dataSetLength;i++){

    var source   = $("#managerTable").html();
    var template = Handlebars.compile(source);
    var html    = template(dataSet[i]);
    $( "#managerSummary" ).append(  html );
  }
}

$(function() {

  var start = moment().subtract(29, 'days');
  var end = moment();

  function cb(start, end) {
    console.log($('#productSelect').val() + start.format('YYYY-MM-DD') + end.format('YYYY-MM-DD'));
    drawManagerTable($('#productSelect').val(),start.format('YYYY-MM-DD'),end.format('YYYY-MM-DD'));
    $('#reportrange span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
  }

  $('#reportrange').daterangepicker({
    startDate: start,
    endDate: end,
    opens: "right",
    ranges: {
        // 'Today': [moment(), moment()],
        // 'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
        // 'Last 7 Days': [moment().subtract(6, 'days'), moment()],
        'Last 30 Days': [moment().subtract(29, 'days'), moment()],
        'Last 90 Days': [moment().subtract(89, 'days'), moment()],
        'Last 365 Days': [moment().subtract(364, 'days'), moment()],
        'This Month': [moment().startOf('month'), moment().endOf('month')],
        'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
              }
  }, cb);

  $('#productSelect').change(function() {
    
    var drp = $('#reportrange').data('daterangepicker');
    
    start=drp.startDate;
    end=drp.endDate;
    cb(start, end);
  });

  cb(start, end);        
});

var managerTableRowId=0;
function drawManagerSummaryTable(data){
  for (var i=0;i<dataSet.length;i++){
    if (dataSet[i].id==data){
      
      $('#featureTable').css("display","block");
      
      $('.detailedinfo').empty();
        var instruction = "<div class=well ><p> Click one of the lables in the Release Summary to see more details. </p></div>"
      $('.detailedinfo').append(instruction);

      $('.summary').empty();

      var source   = $("#releaseSummary").html();
      var template = Handlebars.compile(source);
      var html    = template(dataSet[i]);
      $( ".summary" ).append(  html );

      $("#"+managerTableRowId).removeClass("rowHighlight");
      $("#"+data).addClass("rowHighlight");

      managerTableRowId=data;

    }
  }
}

function hideSummaryTable(){
  $('#featureTable').css("display","none");
}

function getData(flag,product){

  
  if (flag==0){

    $.ajax({
      url:"https://"+url+":9092/base/getProductWiseReleases/"+product,
      async:false,
      success: function(data){
        if (product=="apim"){
          Data2=data;
          f2=1;
        }else if (product=="analytics"){
          Data3=data;
          f3=1;
        }else if (product=="cloud"){
          Data4=data;
          f4=1;
        }else if (product=="integration"){
          Data5=data;
          f5=1;
        }else if (product=="iot"){
          Data6=data;
          f6=1;
        }else if (product=="identity"){
          Data7=data;
          f7=1;
        }else if (product=="other"){
          Data8=data;
          f8=1;
        } 
      }
    });
  }else{
    console.log("data already there");
  }  
}

function showStories(storiesCount,versionId,divId){

    console.log(divId);
    changeButton(divId);
    $('.detailedinfo').empty();
    
    if (storiesCount==0){
      var note = "<div class=well ><p> Nothing to display </p></div>";
      $( ".detailedinfo" ).append(  note );
    }else{
      $("#storySubjects").empty();
      var dataSet;
      $.ajax({
        url:"https://"+url+":9092/base/tracker/30"+"/"+versionId,
        async:false,
        success: function(data){
          dataSet=data;  
        }
      });

      console.log(dataSet);
      for (var i=0;i<dataSet.length;i++){
        dataSet[i].no=i+1;
        var source   = $("#storyDetailedTable").html();
        var template = Handlebars.compile(source);
        var html    = template(dataSet[i]);
        $( "#storySubjects" ).append(  html );
      }  
        var table= $("#storySummary").html();
        
        $(".detailedinfo").append(table);

    } 
}

function showFeatures(storiesCount,versionId,divId){
    changeButton(divId);
    $('.detailedinfo').empty();
    
    if (storiesCount==0){
      var note = "<div class=well ><p> Nothing to display </p></div>";
      $( ".detailedinfo" ).append(  note );
    }else{
      $("#featureSubjects").empty();
      var dataSet;
      $.ajax({
        url:"https://"+url+":9092/base/tracker/2"+"/"+versionId,
        async:false,
        success: function(data){
          dataSet=data;  
        }
      });

      for (var i=0;i<dataSet.length;i++){
        dataSet[i].no=i+1;
        var source   = $("#featureDetailedTable").html();
        var template = Handlebars.compile(source);
        var html    = template(dataSet[i]);
        
        $( "#featureSubjects" ).append(  html );
      }  
        var table= $("#featureSummary").html();
        
        $(".detailedinfo").append(table);

    }
}

function openIssue(issueId){
    url="https://redmine.wso2.com/issues/"+issueId;
    window.open(url, '_blank');
}

function changeButton(divId){

    var id=["Fixed_Issues","Reported_Issues","Stories","Features"]
    for(var i=0;i<4;i++){
      if (id[i]==divId){
        document.getElementById("moreDetails").innerHTML= "More Details of " +id[i] ;
        $("#"+id[i]).addClass("label");
      }else{
        $("#"+id[i]).removeClass("label");
      }
    }
}

function showFixedIssues(divId){
    changeButton(divId);
    
    $(".detailedinfo").empty();
    
    var html    = "<div class=well ><p> Nothing to display </p></div>";
        
    $( ".detailedinfo" ).append(  html );

    //fixed issues should be display here.
    //fixed issues will be taken from github.
    //we have to use git api calls.
    //that issues will be display in a table
}

function showReportedIssues(divId){
    changeButton(divId);

    $(".detailedinfo").empty();
 	
    var html    = "<div class=well ><p> Nothing to display </p></div>";
        
    $( ".detailedinfo" ).append(  html );
    
    //reported issues should be display here.
    //reported issues will be taken from github.
    //we have to use git api calls.
    //that issues will be display in a table
}

