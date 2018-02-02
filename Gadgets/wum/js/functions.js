var lastid= "";
var dataSet; // drawManagerTable() and drawManagerSummaryTable() uses this varable.
var managerTableRowId=0;



function showLoader() {
  $('[data-toggle="loading"]').loading('show');
  var myVar = setTimeout(showPage, 3000);
}

function showPage() {
  $('[data-toggle="loading"]').loading('hide');
  document.getElementById("myDiv").style.display = "block";
}

function changeButtonColor(releaseid){
  
  var id = lastid;
  if(lastid !== ""){
    //first remove the class from the id
    $('#visualization').on('click', '[data-control=userBtn]', function() {
      $(id).css("border-width","1px");   
    });
              
    //then add class for releaseid
    $('#visualization').on('click', '[data-control=userBtn]', function() {
      $('#'+releaseid).css("border-width","7px");
    });

    lastid = '#'+releaseid;
              
  }else{
    //first time add classes for releaseid
    $('#visualization').on('click', '[data-control=userBtn]', function() {
      
      $('#'+releaseid).css("border-width","7px");
      
    });

    lastid = '#'+releaseid;
  }
}

timeline.on('click', function (properties) {

      console.log("hello click");

      if (properties.item==null || properties.event.path[2].className != "cardItem"){
          console.log("hello click inside");
          return;
      }

      var releaseid=properties.event.path[2].attributes[1].nodeValue;  
      changeButtonColor(releaseid);
      
      var cardid=properties.item;
      var data;

      if ($("input[name=optradio]:checked").val()=="All"){
        console.log("hello click inside all");
        //use allData
        data=allData;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="API Manager"){
        //use apimData
        data=apimData;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="Analytics"){
        //use analyticsData
        data=analyticsData;
        drawSummaryTable(data,cardid,releaseid);


      }else if($("input[name=optradio]:checked").val()=="Cloud"){
        //use cloudData
        data=cloudData;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="Integration"){
        //use integrationData
        data=integrationData;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="IOT"){
        //use iotData
        data=iotData;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="IS"){
        //use isData
        data=isData;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="Other"){
        //use otherData
        data=otherData;
        drawSummaryTable(data,cardid,releaseid);
      }
          
      data={};
});//this for click a item in time line

function drawSummaryTable(data,cardid,releaseid){
    $('.todayposition').addClass("hideObject");//for remove the today button
    $('#featureTable').show();
    $('.detailedinfo').empty();
      var instruction = "<div class=well ><p> Click one of the lables in the Release Summary to see more details. </p></div>"
    $('.detailedinfo').append(instruction);

    $('.summary').empty();
    
    
    
    var dataLength=data[cardid-1].labelDataArray.length;
    
    var dataSet={};
    for (var i=0;i<dataLength;i++){
      if (releaseid==data[cardid-1].labelDataArray[i].id){
        dataSet=data[cardid-1].labelDataArray[i];
        console.log(dataSet.details);
        break;
      }
      
    }

    console.log(data[cardid-1].labelDataArray);
    
    var source   = $("#releaseSummary").html();
    var template = Handlebars.compile(source);
    var html    = template(dataSet);
    
    $( ".summary" ).append(  html );
}

function closeTable(id){
  $('.todayposition').removeClass("hideObject");
  $(id).hide();
  $(".managertbl").removeClass("managerTable2");
  $(".managertbl").addClass("managerTable1");
}

var startTs;
var endTs;
$(function() {

  var start = moment().subtract(90, 'days');
  var end = moment();

  // var start = moment().subtract(10, 'days');
  // var end = moment().add(10, 'days');

  function cb(start, end) {
    
    // drawManagerTable($('#productSelect').val(),start.format('YYYY-MM-DD'),end.format('YYYY-MM-DD'));
    $('#reportrange span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
    // $('.config-demo span').html(start.format('YYYY MMMM, D') + ' - ' + end.format('YYYY MMMM, D'));
    var startFormat = start.format("YYYY-MM-DDTHH:mm:ssz");
    var endFormat = end.format("YYYY-MM-DDTHH:mm:ssz");

    startTs = Date.parse(startFormat);
    endTs = Date.parse(endFormat);
    console.log("loadData() called");
    
    loadData();
  }

  $('#reportrange').daterangepicker({
  // $('.config-demo').daterangepicker({
    startDate: start,
    endDate: end,
    opens: "right",
    ranges: {
        'Today': [moment(), moment()],
        'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
        'Last 7 Days': [moment().subtract(6, 'days'), moment()],
        'Last 30 Days': [moment().subtract(29, 'days'), moment()],
        'Last 60 Days': [moment().subtract(59, 'days'), moment()],
        'Last 90 Days': [moment().subtract(89, 'days'), moment()],
        'Last 365 Days': [moment().subtract(364, 'days'), moment()],
        'This Month': [moment().startOf('month'), moment().endOf('month')],
        'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
              }
  }, cb);

   cb(start, end);        
});

function hideSummaryTable(){
  $('#featureTable').css("display","none");
}

function getData(product){

  
  var sendData=[]
  if (product!="all"){
   
    $.ajax({
      url:"https://"+url+":"+port+"/wumReleaseTrainServices/getProductWiseReleases/"+product+"/"+startTs+"/"+endTs,
      async:false,
      success: function(data){
        console.log(data);
        sendData=data;
        
      }
    });
  }else{
    $.ajax({
      url:"https://"+url+":"+port+"/wumReleaseTrainServices/getAllReleases/"+startTs+"/"+endTs,
      async:false,
      success: function(data){
        console.log(data);
        sendData=data;
        
      }
    });
  }

  return sendData;
}

function openIssue(bugUrl){
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








