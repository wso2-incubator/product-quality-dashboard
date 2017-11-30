var lastid= "";
var preBgcolor=null;

function showLoader() {
  $('[data-toggle="loading"]').loading('show');
  var myVar = setTimeout(showPage, 3000);
}

function showPage() {
  $('[data-toggle="loading"]').loading('hide');
  document.getElementById("myDiv").style.display = "block";
}

function changeButtonColor(releaseid){
  
  var f = lastid;
  if(lastid !== ""){
    //first remove the class from the id
    $('#visualization').on('click', '[data-control=userBtn]', function() {
                
      
      $(f).css("border-width","1px");
      
        
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

function test(releaseid){

    $('#featureTable').css("display","block");
    changeButtonColor(releaseid);
    

    //call a service to get fixed and reported issue count in github
    

    
    timeline.on('click', function (properties) {

      

      if (properties.item==null){
          return;
      }

          
      var cardid=properties.item;
      var data;

      if ($("input[name=optradio]:checked").val()=="All"){
        //use Data1
        
        data=Data1;
        drawSummaryTable(data,cardid,releaseid);

      }else if($("input[name=optradio]:checked").val()=="API Manager"){
        //use Data2
        
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
  $('.todayposition').addClass("hideObject");//for remove the today button
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
  $('.todayposition').removeClass("hideObject");
  $(id).hide();
  $(".managertbl").removeClass("managerTable2");
  $(".managertbl").addClass("managerTable1");
}

var dataSet; // drawManagerTable() and drawManagerSummaryTable() uses this varable.
function drawManagerTable(product,startDate,endDate){
  
  $('#managerSummary').empty();

  //call the ballerina service http://localhoast:9090/product/startDate/endDate
  //get the json dataSet

  
  


  $.ajax({
      url:"https://"+url+":"+port+"/base/manager/"+product+"/"+startDate+"/"+endDate,
      async:false,
      success: function(data){
        dataSet=data;  
      }
  });
  

  
  var dataSetLength=dataSet.length;



  if(dataSetLength!=0){
    $( '#errormsg' ).addClass("hideObject");
    $('#managerInit').removeClass("hideObject");
    for(var i=0; i<dataSetLength;i++){

      var source   = $("#managerTable").html();
      var template = Handlebars.compile(source);
      var html    = template(dataSet[i]);
      
      $( "#managerSummary" ).append(  html );
    }
  }else{
    $('#managerInit').addClass("hideObject");
    $( '#errormsg' ).removeClass("hideObject");
  } 
}

$(function() {

  var start = moment().subtract(29, 'days');
  var end = moment();

  function cb(start, end) {
    
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
        'Last 60 Days': [moment().subtract(59, 'days'), moment()],
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


  //function call to draw manager Table
  //drawManagerTable($('#productSelect').val(),start.format('YYYY-MM-DD'),end.format('YYYY-MM-DD'));          
});

var managerTableRowId=0;
function drawManagerSummaryTable(data){
  $(".managertbl").removeClass("managerTable1");
  $(".managertbl").addClass("managerTable2");

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
      url:"https://"+url+":"+port+"/base/getProductWiseReleases/"+product,
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
    //console.log("data already there");
  }
}

function showStories(storiesCount,versionId,divId){

    
    changeButton(divId);
    if(versionId==0){
      $(".detailedinfo").empty();
      var html    = "<div class=well ><p> No data to display,Due to can not find a matching Redmine version for this Github version. </p></div>";   
      $( ".detailedinfo" ).append(  html );
    }else{
      $('.detailedinfo').empty();
    
      if (storiesCount==0){
        var note = "<div class=well ><p> No data to display,Due to stroies for this Redmine version is zero. </p></div>";
        $( ".detailedinfo" ).append(  note );
      }else{
        $("#storySubjects").empty();
        var dataSet;
        $.ajax({
          url:"https://"+url+":"+port+"/base/tracker/30"+"/"+versionId,
          async:false,
          success: function(data){
            dataSet=data;  
          }
        });

       
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
}

function showFeatures(featuresCount,versionId,divId){
    changeButton(divId);
    if(versionId==0){
      $(".detailedinfo").empty();
      var html    = "<div class=well ><p> No data to display,Due to can not find a matching Redmine version for this Github version. </p></div>";   
      $( ".detailedinfo" ).append(  html );
    }else{
      $('.detailedinfo').empty();
    
      if (featuresCount==0){
        var note = "<div class=well ><p>  No data to display,Due to features for this Redmine version is zero. </p></div>";
        $( ".detailedinfo" ).append(  note );
      }else{
        $("#featureSubjects").empty();
        var dataSet;
        $.ajax({
          url:"https://"+url+":"+port+"/base/tracker/2"+"/"+versionId,
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

function showFixedIssues(projectId,versionId,gitVersionId,divId){
    changeButton(divId);
    
    if(gitVersionId!=0){
      var dataSet1;
      $.ajax({
          url:"https://"+url+":"+port+"/base/getRepoAndGitVersionByGitId/"+gitVersionId,
          async:false,
          success: function(data){
            dataSet1=data;  
          }
      });

      
      var repoName = dataSet1[0].repoName;
      var versionName = dataSet1[0].gitVersionName;
      var DataSet2=[];
      $.ajax({
          url:"https://"+url+":"+port+"/base/getFixedGitIssues/"+repoName+"?versionName="+versionName,
          async:false,
          success: function(data){
            dataSet2=data;  
          }
      });
      if (dataSet2.length == 0){
        $('.detailedinfo').empty();
        var note = "<div class=well ><p> No data to display, Due to can not find a maching version label in github issues  or issues for this version is zero. </p></div>";
        $( ".detailedinfo" ).append(  note );
      }else {



        $('.detailedinfo').empty();
      
        var html='<table class="table table-bordered table-striped table-hover ">' +
                    '<thead style="background-color: #29313E;color:white">' +
                      '<tr>'+
                        '<th>#</th>' +
                        '<th>Fixed Issues</th>' +
                      '</tr>'+
                    '</thead>' +
                    '<tbody>'

        var rowNumber=0;
        for(i=0;i<dataSet2.length;i++){
          for(j=0;j<dataSet2[i].length;j++){
            rowNumber ++;
            html= html +  '<tr>'+
                          '<td>'+ rowNumber +'</td>' +
                          '<td>'+ 
                            '<a href=' +  dataSet2[i][j].url +'>' + 
                             dataSet2[i][j].title + 
                          '</td>' +
                          '</tr>'
          }
        }
            
          html= html + '</tbody>'+
                       '</table>'
        $( ".detailedinfo" ).append(  html );
      } 
      
    }else{
        var dataSet1;
        $.ajax({
          url:"https://"+url+":"+port+"/base/getRepoAndVersion"+"/"+projectId+"/"+versionId,
          async:false,
          success: function(data){
            dataSet1=data;  
          }
        });

       var versionName =dataSet1.versionName; 
       var repoNames = dataSet1.repoNames;

      

       var dataSet2=[];
       for(i=0;i<repoNames.length;i++){
         var repoName = repoNames[i].repoName;
         
         if ((repoName != "") && (versionName != "")){
           $.ajax({
            url:"https://"+url+":"+port+"/base/getFixedGitIssues/"+repoName+"?versionName="+versionName,
            async:false,
            success: function(data){
              dataSet2=data;  
            }
           });
         }

         if(dataSet2.length > 0){
          break;
         }
         
       }
   
      

      if (dataSet2.length == 0){
        $('.detailedinfo').empty();
        var note = "<div class=well ><p> No data to display, Due to can not find a maching version label in github issues  or issues for this version is zero. </p></div>";
        $( ".detailedinfo" ).append(  note );
      }else {



        $('.detailedinfo').empty();
      
        var html='<table class="table table-bordered table-striped table-hover ">' +
                    '<thead style="background-color: #29313E;color:white">' +
                      '<tr>'+
                        '<th>#</th>' +
                        '<th>Fixed Issues</th>' +
                      '</tr>'+
                    '</thead>' +
                    '<tbody>'

        var rowNumber=0;
        for(i=0;i<dataSet2.length;i++){
          for(j=0;j<dataSet2[i].length;j++){
            rowNumber ++;
            html= html +  '<tr>'+
                          '<td>'+ rowNumber +'</td>' +
                          '<td>'+ 
                            '<a href=' +  dataSet2[i][j].url +'>' + 
                             dataSet2[i][j].title + 
                          '</td>' +
                          '</tr>'
          }
        }
            
          html= html + '</tbody>'+
                       '</table>'
        $( ".detailedinfo" ).append(  html );
      } 
    }
    
       
}

function showReportedIssues(projectId,versionId,gitVersionId,divId,){
    
    changeButton(divId);
    
    if(gitVersionId!=0){//check if it is git then it directly find the issues for this gitVersoinId

      var dataSet1;
      $.ajax({
          url:"https://"+url+":"+port+"/base/getRepoAndGitVersionByGitId/"+gitVersionId,
          async:false,
          success: function(data){
            dataSet1=data;  
          }
      });

      
      var repoName = dataSet1[0].repoName;
      var versionName = dataSet1[0].gitVersionName;
      
      var dataSet2=[];
      $.ajax({
          url:"https://"+url+":"+port+"/base/getReportedGitIssues/"+repoName+"?versionName="+versionName,
          async:false,
          success: function(data){
            dataSet2=data;  
          }
      });

      if (dataSet2.length == 0){
        $('.detailedinfo').empty();
        var note = "<div class=well ><p> No data to display, Due to can not find a maching version label in github issues  or issues for this version is zero. </p></div>";
        $( ".detailedinfo" ).append(  note );
      }else {

        $('.detailedinfo').empty();
      
        var html='<table class="table table-bordered table-striped table-hover ">' +
                    '<thead style="background-color: #29313E;color:white">' +
                      '<tr>'+
                        '<th>#</th>' +
                        '<th>Reported Issues</th>' +
                      '</tr>'+
                    '</thead>' +
                    '<tbody>'

        var rowNumber=0;
        for(i=0;i<dataSet2.length;i++){
          for(j=0;j<dataSet2[i].length;j++){
            rowNumber ++;
            html= html +  '<tr>'+
                          '<td>'+ rowNumber +'</td>' +
                          '<td>'+ 
                            '<a href=' +  dataSet2[i][j].url +'>' + 
                             dataSet2[i][j].title + 
                          '</td>' +
                          '</tr>'
          }
        }
            
          html= html + '</tbody>'+
                       '</table>'
        $( ".detailedinfo" ).append(  html );
    } 
    


      
    }else{

      var dataSet1;
      $.ajax({
        url:"https://"+url+":"+port+"/base/getRepoAndVersion"+"/"+projectId+"/"+versionId,
        async:false,
        success: function(data){
          dataSet1=data;  
        }
      });

     var versionName =dataSet1.versionName; 
     var repoNames = dataSet1.repoNames;

     
     

     var dataSet2=[];
     for(i=0;i<repoNames.length;i++){
       var repoName = repoNames[i].repoName;
       
       if ((repoName != "") && (versionName != "")){
         $.ajax({
          url:"https://"+url+":"+port+"/base/getReportedGitIssues/"+repoName+"?versionName="+versionName,
          async:false,
          success: function(data){
            dataSet2=data;  
          }
         });
       }

       if(dataSet2.length > 0){
        break;
       }
       
     }
 
    

    if (dataSet2.length == 0){
      $('.detailedinfo').empty();
      var note = "<div class=well ><p> No data to display, Due to can not find a maching version label in github issues  or issues for this version is zero. </p></div>";
      $( ".detailedinfo" ).append(  note );
    }else {

      $('.detailedinfo').empty();
    
      var html='<table class="table table-bordered table-striped table-hover ">' +
                  '<thead style="background-color: #29313E;color:white">' +
                    '<tr>'+
                      '<th>#</th>' +
                      '<th>Reported Issues</th>' +
                    '</tr>'+
                  '</thead>' +
                  '<tbody>'

      var rowNumber=0;
      for(i=0;i<dataSet2.length;i++){
        for(j=0;j<dataSet2[i].length;j++){
          rowNumber ++;
          html= html +  '<tr>'+
                        '<td>'+ rowNumber +'</td>' +
                        '<td>'+ 
                          '<a href=' +  dataSet2[i][j].url +'>' + 
                           dataSet2[i][j].title + 
                        '</td>' +
                        '</tr>'
        }
      }
          
        html= html + '</tbody>'+
                     '</table>'
      $( ".detailedinfo" ).append(  html );
    } 
    }
        
}



