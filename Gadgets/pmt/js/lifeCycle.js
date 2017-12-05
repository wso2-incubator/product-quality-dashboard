var dataSet = [];
var statesIds = [];
var patchDetails = [];
var SUPPORT_JIRA_PATH = "https://support.wso2.com/jira/browse/";

function loadStackQueuedGraph(){
    var start = "";
    var end = "";
    if(startDate === ''){
        start = firstdate;
        end = today;
    }else{
        start = startDate;
        end = endDate;
    }

    var states = [];
    var products = [];
    var counts = [];
    var stateTransitionData = [];
    var averageData = [];
    patchDetails = [];
    var finalAverageCountsOfStatesTransition = [];
    var movementAverage = [];
    var finalMovementAverage = [];
    statesIds = [];

    $.ajax({
        type: "GET",
        async:false,
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-lifecycle-stack/'+start+'/'+end,
        success: function(jsonResponse){
            states = jsonResponse.category;
            products = jsonResponse.products;
            counts = jsonResponse.counts;
            stateTransitionData = jsonResponse.stateCounts;
            averageData = jsonResponse.averageSummary;
            patchDetails = jsonResponse.patchDetails;
            movementAverage = jsonResponse.mainSumamry;
            statesIds = jsonResponse.statesIds;

        }
    });

    //load data to json for feed high charts to create stack graph
    var chart = [];
    for(var z=0;z<states.length;z++){
        var json={name:"x",data:2016};
        json.name = states[z];
        json.data = counts[z];
        chart.push(json)
    }

    //generating product contain dropdown
    document.getElementById('lcProduct').innerHTML = "";
    for (var x = 0; x < products.length+1; x++) {
        if(x === 0){
            document.getElementById('lcProduct').innerHTML += "<option  id='lifeCycleProduct"+x+"' class='list-group-item' style='cursor: pointer; cursor: hand;font-size:1vw;' value='all'>All Products</option>";
        }else{
            document.getElementById('lcProduct').innerHTML += "<option  id='lifeCycleProduct"+x+"' class='list-group-item' style='cursor: pointer; cursor: hand;font-size:1vw;' value='"+products[x-1]+"'>"
                + products[x-1] +
                "</option>";
        }

    }

    //creating final average array by division
    for(var a=0; a<averageData.length;a++){
        if(parseInt(averageData[a][1]) === 0){
            finalAverageCountsOfStatesTransition[a] = 0;
        }else{
            finalAverageCountsOfStatesTransition[a] = Math.round(parseInt(averageData[a][0])/parseInt(averageData[a][1]));
        }

    }
    for(var b=0; b<movementAverage.length;b++){
        if(parseInt(movementAverage[b][1]) === 0){
            finalMovementAverage[b] = 0;
        }else{
            finalMovementAverage[b] = Math.round(parseInt(movementAverage[b][0])/parseInt(movementAverage[b][1]));
        }

    }
    // console.log(averageData);
    // console.log(movementAverage);
    document.getElementById('lcDetailDate').innerHTML = start+' to '+end;
    document.getElementById('selectedState').innerHTML = "";
    document.getElementById('noteOfStateGraph').style.display = 'block';
    document.getElementById('resetButton').style.display = "none";
    document.getElementById('resetButtonStates').style.display = "none";

    drawStackChart(products,chart);
    generateStateTransitionGraph(stateTransitionData,finalAverageCountsOfStatesTransition,finalMovementAverage);
    loadPatchDetailsToTable(patchDetails);
}

function drawStackChart(products,chartData){
    if(startDate === ""){
        defaultTitle = "Patch States of Products from "+firstdate+' to '+today;
    }else{
        defaultTitle = "Patch States of Products from "+startDate+' to '+endDate;
    }
    Highcharts.chart('lifeCycle', {
        chart: {
            type: 'column'
        },
        title: {
            text: defaultTitle
        },
        xAxis: {
            categories: products
        },
        yAxis: {
            min: 0,
            title: {
                text: 'Total Patch Count'
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
            y: 49,
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
                stacking: 'normal',
                dataLabels: {
                    enabled: true,
                    formatter: function(){
                        var val = this.y;
                        if (val < 1) {
                            return '';
                        }
                        return val;
                    },
                    color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
                },
                treshold: 1
            }
        },
        series: chartData
    });
}

function selectProductByMenu(val){
    document.getElementById('currentStateLegend').style.display = 'none';

    var start = "";
    var end = "";
    if(startDate === ''){
        start = firstdate;
        end = today;
    }else{
        start = startDate;
        end = endDate;
    }
    var stateTransitionData = [];
    var averageData = [];
    patchDetails = [];
    var finalAverageCountsOfStatesTransition = [];
    var movementAverage = [];
    var finalMovementAverage = [];
    statesIds = [];

    $.ajax({
        type: "GET",
        async:false,
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-lifecycle-states/'+val+'/'+start+'/'+end,
        success: function(jsonResponse){
            stateTransitionData = jsonResponse.stateCounts;
            averageData = jsonResponse.averageDates;
            patchDetails = jsonResponse.patchDetails;
            movementAverage = jsonResponse.mainSumamry;
            statesIds = jsonResponse.statesIds;
        }
    });

   for(var a=0; a<averageData.length;a++){
       if(parseInt(averageData[a][1]) === 0){
           finalAverageCountsOfStatesTransition[a] = 0;
       }else{
           finalAverageCountsOfStatesTransition[a] = Math.round(parseInt(averageData[a][0])/parseInt(averageData[a][1]));
       }

   }
   for(var b=0; b<movementAverage.length;b++){
        if(parseInt(movementAverage[b][1]) === 0){
            finalMovementAverage[b] = 0;
        }else{
            finalMovementAverage[b] = Math.round(parseInt(movementAverage[b][0])/parseInt(movementAverage[b][1]));
        }

    }
    // console.log(averageData);
    // console.log(finalAverageCountsOfStatesTransition);
    document.getElementById('lcDetailDate').innerHTML = start+' to '+end;
    document.getElementById('selectedState').innerHTML = "";
    document.getElementById('noteOfStateGraph').style.display = 'block';
    document.getElementById('resetButton').style.display = "none";
    document.getElementById('resetButtonStates').style.display = "none";
    generateStateTransitionGraph(stateTransitionData,finalAverageCountsOfStatesTransition,finalMovementAverage);
    loadPatchDetailsToTable(patchDetails);
}

function generateStateTransitionGraph(dataArray,averageCounts,movementAverage){
    Highcharts.chart('stateGraph', {
        chart: {
            backgroundColor: 'white',
            events: {
                load: function () {

                    // Draw the flow chart
                    var ren = this.renderer,
                        colors = Highcharts.getOptions().colors,
                        rightArrow = ['M', 0, 0, 'L', 100, 0, 'L', 95, 5, 'M', 100, 0, 'L', 95, -5],
                        leftArrow = ['M', 100, 0, 'L', 0, 0, 'L', 5, 5, 'M', 0, 0, 'L', 5, -5];



                    // Separator, Yet to start from In progress
                    ren.path(['M', 200, 40, 'L', 200, 330])
                        .attr({
                            'stroke-width': 2,
                            stroke: 'silver',
                            dashstyle: 'dash'
                        })
                        .add();

                    // Separator, In progress from Released
                    ren.path(['M', 775, 40, 'L', 775, 330])
                        .attr({
                            'stroke-width': 2,
                            stroke: 'silver',
                            dashstyle: 'dash'
                        })
                        .add();

                    // Headers
                    ren.label('Yet to Start', 60, 30)
                        .css({
                            fontWeight: 'bold'
                        })
                        .add();
                    ren.label(' In Progress', 440, 30)
                        .css({
                            fontWeight: 'bold'
                        })
                        .add();
                    ren.label('Released', 1100, 30)
                        .css({
                            fontWeight: 'bold'
                        })
                        .add();

                    // footers
                    ren.label('(Average '+movementAverage[0]+' Day(s) spent)', 130,320)
                        .css({
                            fontWeight: 'bold'
                        })
                        .add();
                    ren.label('(Average '+movementAverage[1]+' Day(s) spent)', 700,320)
                        .css({
                            fontWeight: 'bold'
                        })
                        .add();

                    // Queued label
                    ren.label('Queued State  <br/> <span style="text-align: center;">Count '+dataArray[0]+'</span>', 10, 82)
                        .attr({
                            fill: colors[0],
                            stroke: 'white',
                            'stroke-width': 2,
                            padding: 16,
                            r: 10
                        })
                        .css({
                            color: 'white',
                            width: '100px',
                            textAlign:'center',
                            cursor: 'pointer'
                        })
                        .on('click', function() {
                            whenStateOnClick(0);
                        })
                        .add()
                        .shadow(true);

                    ren.label('Pre QA State  <br/> <span style="text-align: center;">Count '+dataArray[1]+'</span>', 220, 82)
                        .attr({
                            fill: colors[1],
                            stroke: 'white',
                            'stroke-width': 2,
                            padding: 16,
                            r: 10
                        })
                        .css({
                            color: 'white',
                            width: '100px',
                            textAlign:'center',
                            cursor: 'pointer'
                        })
                         .on('click', function() {
                            whenStateOnClick(1);
                        })
                        .add();

                    ren.label('Developing State <br/> <span style="text-align: center;">Count '+dataArray[2]+'</span>', 430, 82)
                        .attr({
                            fill: colors[1],
                            stroke: 'white',
                            'stroke-width': 2,
                            padding: 16,
                            r: 10
                        })
                        .css({
                            color: 'white',
                            width: '100px',
                            textAlign:'center',
                            cursor: 'pointer'
                        })
                         .on('click', function() {
                            whenStateOnClick(2);
                        })
                        .add();

                    ren.label('QA State  <br/> <span style="text-align: center;">Count '+dataArray[3]+'</span>', 660, 82)
                        .attr({
                            fill: colors[1],
                            stroke: 'white',
                            'stroke-width': 2,
                            padding: 16,
                            r: 10
                        })
                        .css({
                            color: 'white',
                            width: '100px',
                            textAlign:'center',
                            cursor: 'pointer'
                        })
                         .on('click', function() {
                            whenStateOnClick(3);
                        })
                        .add();

                    // Arrow from Queued to Pre QA
                    ren.path(rightArrow)
                        .attr({
                            'stroke-width': 2,
                            stroke: colors[3]
                        })
                        .translate(115, 105)
                        .add();

                    ren.label('Average '+averageCounts[0]+' Day(s)', 125, 87)
                        .css({
                            fontSize: '10px',
                            color: colors[3]
                        })
                        .add();

                    // Arrow from Pre QA to Developing
                    ren.path(rightArrow)
                        .attr({
                            'stroke-width': 2,
                            stroke: colors[3]
                        })
                        .translate(325, 105)
                        .add();

                    ren.label('Average '+averageCounts[1]+' Day(s)', 335, 87)
                        .css({
                            fontSize: '10px',
                            color: colors[3]
                        })
                        .add();

                    // Arrow from Developing to Testing
                    ren.path(rightArrow)
                        .attr({
                            'stroke-width': 2,
                            stroke: colors[3]
                        })
                        .translate(555, 105)
                        .add();

                    ren.label('Average '+averageCounts[2]+' Day(s)', 565, 87)
                        .css({
                            fontSize: '10px',
                            color: colors[3]
                        })
                        .add();

                    // Arrow to On Hold state
                    ren.path(['M', 345, 180, 'L', 345, 245, 'L', 340, 240, 'M', 345, 245, 'L', 350, 240])
                        .attr({
                            'stroke-width': 2,
                            stroke: colors[3]
                        })
                        .add();

                    //On hold state
                    ren.label('Regression State  <br/> <span style="text-align: center;">Count '+dataArray[8]+'</span>', 290, 250)
                        .attr({
                            fill: colors[3],
                            stroke: 'white',
                            'stroke-width': 2,
                            padding: 16,
                            r: 10
                        })
                        .css({
                            color: 'white',
                            width: '100px',
                            textAlign:'center',
                            cursor: 'pointer'
                        })
                         .on('click', function() {
                            whenStateOnClick(8);
                        })
                        .add();

                    // Arrow to On Hold state
                    ren.path(['M', 575, 180, 'L', 575, 245, 'L', 580, 240, 'M', 575, 245, 'L', 570, 240])
                        .attr({
                            'stroke-width': 2,
                            stroke: colors[3]
                        })
                        .add();

                    //Broken State
                    ren.label('Broken State   <br/> <span style="text-align: center;">Count '+dataArray[7]+'</span>', 525, 250)
                        .attr({
                            fill: colors[7],
                            stroke: 'white',
                            'stroke-width': 2,
                            padding: 16,
                            r: 10
                        })
                        .css({
                            color: 'white',
                            width: '100px',
                            textAlign:'center',
                            cursor: 'pointer'
                        })
                         .on('click', function() {
                            whenStateOnClick(7);
                        })
                        .add();

                    // Released NIPS label
                    ren.label('Released NIPS <br/> <span style="text-align: center;">Count '+dataArray[4]+'</span>', 870, 80)
                        .attr({
                            fill: '#7AC29A',
                            stroke: 'white',
                            'stroke-width': 2,
                            padding: 16,
                            r: 10
                        })
                        .css({
                            color: 'white',
                            width: '100px',
                            textAlign:'center',
                            cursor: 'pointer'
                        })
                        .add()
                         .on('click', function() {
                            whenStateOnClick(4);
                        })
                        .shadow(true);

                    // Arrow from Testing to Released NIPS
                    ren.path(rightArrow)
                        .attr({
                            'stroke-width': 2,
                            stroke: '#7AC29A'
                        })
                        .translate(765, 105)
                        .add();

                    ren.label('Average '+averageCounts[3]+' Day(s)', 777, 87)
                        .css({
                            color:'#7AC29A',
                            fontSize: '10px'
                        })
                        .add();

                    //Released NA label
                    ren.label('Released NA<br/> <span style="text-align: center;">Count '+dataArray[5]+'</span>', 1100, 80)
                        .attr({
                            fill: '#7AC29A',
                            stroke: 'white',
                            'stroke-width': 2,
                            padding: 16,
                            r: 10
                        })
                        .css({
                            color: 'white',
                            width: '100px',
                            textAlign:'center',
                            cursor: 'pointer'
                        })
                         .on('click', function() {
                            whenStateOnClick(5);
                        })
                        .add()
                        .shadow(true);

                    // Arrow from Released NIPS to Released NA
                    ren.path(rightArrow)
                        .attr({
                            'stroke-width': 2,
                            stroke: '#7AC29A'
                        })
                        .translate(995, 105)
                        .add();

                    ren.label('Average '+averageCounts[4]+' Day(s)', 1002, 87)
                        .css({
                            color:'#7AC29A',
                            fontSize: '10px'
                        })
                        .add();

                    //Released  label
                    ren.label('Released State <br/> <span style="text-align: center;">Count '+dataArray[6]+'</span>', 1330, 80)
                        .attr({
                            fill: '#7AC29A',
                            stroke: 'white',
                            'stroke-width': 2,
                            padding: 16,
                            r: 10
                        })
                        .css({
                            color: 'white',
                            width: '100px',
                            textAlign:'center',
                            cursor: 'pointer'
                        })
                         .on('click', function() {
                            whenStateOnClick(6);
                        })
                        .add()
                        .shadow(true);

                    // Arrow from Released NIPS to Released NA
                    ren.path(rightArrow)
                        .attr({
                            'stroke-width': 2,
                            stroke: '#7AC29A'
                        })
                        .translate(1225, 105)
                        .add();

                    ren.label('Average '+averageCounts[5]+' Day(s)', 1222, 87)
                        .css({
                            color:'#7AC29A',
                            fontSize: '10px'
                        })
                        .add();


                }
            }
        },
        title: {
            text: '',
            style: {
                color: 'black'
            }
        }
    });
}

function loadPatchDetailsToTable(patchDetails){
    $('#patchDetailsLC').DataTable().destroy();

    //create new array of patches states at that moment
    var arrayOfStatesAtThatGivenTime = [];

    for(var z = 0; z<patchDetails.length;z++){
        arrayOfStatesAtThatGivenTime[z] = "Unknown";
    }

    for(var t=0;t<statesIds.length;t++){
        if(statesIds[t].length != 0){
            for(var z=0;z<statesIds[t].length;z++){
                for(var i=0;i<patchDetails.length;i++){
                    if(t === 0 && patchDetails[i].ID === statesIds[t][z][0] &&  patchDetails[i].eID === statesIds[t][z][1]){
                        arrayOfStatesAtThatGivenTime[i] = "Queued";
                        break;
                    }
                    if(t === 1 && patchDetails[i].ID === statesIds[t][z][0] &&  patchDetails[i].eID === statesIds[t][z][1]){
                        arrayOfStatesAtThatGivenTime[i] = "PreQADevelopment";
                        break;
                    }
                    if(t === 2 && patchDetails[i].ID === statesIds[t][z][0] &&  patchDetails[i].eID === statesIds[t][z][1]){
                        arrayOfStatesAtThatGivenTime[i] = "Development";
                        break;
                    }
                    if(t === 3 && patchDetails[i].ID === statesIds[t][z][0] &&  patchDetails[i].eID === statesIds[t][z][1]){
                        arrayOfStatesAtThatGivenTime[i] = "ReadyForQA";
                        break;
                    }
                    if(t === 4 && patchDetails[i].ID === statesIds[t][z][0] &&  patchDetails[i].eID === statesIds[t][z][1]){
                        arrayOfStatesAtThatGivenTime[i] = "ReleasedNotInPublicSVN";
                        break;
                    }
                    if(t === 5 && patchDetails[i].ID === statesIds[t][z][0] &&  patchDetails[i].eID === statesIds[t][z][1]){
                        arrayOfStatesAtThatGivenTime[i] = "ReleasedNotAutomated";
                        break;
                    }
                    if(t === 6 && patchDetails[i].ID === statesIds[t][z][0] &&  patchDetails[i].eID === statesIds[t][z][1]){
                        arrayOfStatesAtThatGivenTime[i] = "Released";
                        break;
                    }
                    if(t === 7 && patchDetails[i].ID === statesIds[t][z][0] &&  patchDetails[i].eID === statesIds[t][z][1]){
                        arrayOfStatesAtThatGivenTime[i] = "Broken";
                        break;
                    }
                    if(t === 8 && patchDetails[i].ID === statesIds[t][z][0] &&  patchDetails[i].eID === statesIds[t][z][1]){
                        arrayOfStatesAtThatGivenTime[i] = "Regression";
                        break;
                    }
                }
            }
        }

    }

    //create dataset to feed datatable
    dataSet = [];
    for (var x=0;x<patchDetails.length;x++){
        if(patchDetails[x].LC_STATE === null){
            patchDetails[x].LC_STATE = "Queued";
        }
        if(patchDetails[x].PRE_QA_STARTED_ON === null){
            patchDetails[x].PRE_QA_STARTED_ON = "-";
        }else{
            patchDetails[x].PRE_QA_STARTED_ON = patchDetails[x].PRE_QA_STARTED_ON.split(" ")[0];
        }
        if(patchDetails[x].DEVELOPMENT_STARTED_ON === null){
            patchDetails[x].DEVELOPMENT_STARTED_ON = "-";
        }else{
            patchDetails[x].DEVELOPMENT_STARTED_ON = patchDetails[x].DEVELOPMENT_STARTED_ON.split(" ")[0];
        }
        if(patchDetails[x].QA_STARTED_ON === null){
            patchDetails[x].QA_STARTED_ON = "-";
        }else{
            patchDetails[x].QA_STARTED_ON = patchDetails[x].QA_STARTED_ON.split(" ")[0];
        }
        if(patchDetails[x].RELEASED_NOT_IN_PUBLIC_SVN_ON === null){
            patchDetails[x].RELEASED_NOT_IN_PUBLIC_SVN_ON = "-";
        }else{
            patchDetails[x].RELEASED_NOT_IN_PUBLIC_SVN_ON = patchDetails[x].RELEASED_NOT_IN_PUBLIC_SVN_ON.split(" ")[0];
        }
        if(patchDetails[x].RELEASED_NOT_AUTOMATED_ON === null){
            patchDetails[x].RELEASED_NOT_AUTOMATED_ON = "-";
        }else{
            patchDetails[x].RELEASED_NOT_AUTOMATED_ON = patchDetails[x].RELEASED_NOT_AUTOMATED_ON.split(" ")[0];
        }
        if(patchDetails[x].RELEASED_ON === null){
            patchDetails[x].RELEASED_ON = "-";
        }else{
            patchDetails[x].RELEASED_ON = patchDetails[x].RELEASED_ON.split(" ")[0];
        }
        if(patchDetails[x].BROKEN_ON === null){
            patchDetails[x].BROKEN_ON = "-";
        }else{
            patchDetails[x].BROKEN_ON = patchDetails[x].BROKEN_ON.split(" ")[0];
        }
        if(patchDetails[x].REGRESSION_ON === null){
            patchDetails[x].REGRESSION_ON = "-";
        }else{
            patchDetails[x].REGRESSION_ON = patchDetails[x].REGRESSION_ON.split(" ")[0];
        }
        var el = [
            patchDetails[x].ID,
            patchDetails[x].PRODUCT_NAME,
            patchDetails[x].SUPPORT_JIRA.split('browse/')[1],
            patchDetails[x].LC_STATE,
            arrayOfStatesAtThatGivenTime[x],
            patchDetails[x].REPORT_DATE,
            patchDetails[x].PRE_QA_STARTED_ON,
            patchDetails[x].DEVELOPMENT_STARTED_ON,
            patchDetails[x].QA_STARTED_ON,
            patchDetails[x].RELEASED_NOT_IN_PUBLIC_SVN_ON,
            patchDetails[x].RELEASED_NOT_AUTOMATED_ON,
            patchDetails[x].RELEASED_ON,
            patchDetails[x].BROKEN_ON,
            patchDetails[x].REGRESSION_ON,
            patchDetails[x].eID
        ];

        dataSet[x] = el;
    }


    $('#patchDetailsLC').DataTable({
        data: dataSet,
        columns: [
            { title: "Patch ID" },
            { title: "Product Name" },
            { title: "JIRA ID" },
            { title: "Current State" },
            { title: "State at that Moment" },
            { title: "Queued On" },
            { title: "Pre QA On" },
            { title: "Dev Started" },
            { title: "QA Started" },
            { title: "Released NIPS" },
            { title: "Released NS" },
            { title: "Released On" },
            { title: "Broken On" },
            { title: "Regression On" },
            { title: "ETA ID" }
        ],
        "aoColumnDefs": [
            { "sClass": "column-2", "aTargets": [ 1 ] },
            { "sClass": "column-12", "aTargets": [ 14 ] },
            { "render": function(data, type, row, meta){data = '<a href="' +SUPPORT_JIRA_PATH + data + '" target="_blank">' + data + '</a>';return data;}, "aTargets": [ 2 ] }

        ]
    });

    //click on the patch detail table and get a specific ID
    $('#patchDetailsLC tbody').on('click', 'tr', function () {
        var data = $('#patchDetailsLC').DataTable().row( this ).data();
        $("#patchDetailsLC tbody tr").removeClass('row_selected');
        $(this).addClass('row_selected');
        getSpecificPatchLifeCycle(data[0],data[14]);
    } );
}

function getSpecificPatchLifeCycle(patchID,eID){
    // console.log(eID);
    var stateTransitionData = [];
    var patchDetails = [];

    $.ajax({
        type: "GET",
        async:false,
        url: 'https://'+BALLERINA_URL+'/pmt-dashboard-serives/load-lifecycle-states-patch/'+patchID+'/'+eID,
        success: function(jsonResponse){
            stateTransitionData = jsonResponse.dateCounts;
            patchDetails = jsonResponse.patchDetails;
        }
    });

    if(patchDetails[0].LC_STATE === null){
        patchDetails[0].LC_STATE = "Queued";
    }
    if(patchDetails[0].PRE_QA_STARTED_ON === null){
        patchDetails[0].PRE_QA_STARTED_ON = "-";
    }else{
        patchDetails[0].PRE_QA_STARTED_ON = patchDetails[0].PRE_QA_STARTED_ON.split(" ")[0];
    }
    if(patchDetails[0].DEVELOPMENT_STARTED_ON === null){
        patchDetails[0].DEVELOPMENT_STARTED_ON = "-";
    }else{
        patchDetails[0].DEVELOPMENT_STARTED_ON = patchDetails[0].DEVELOPMENT_STARTED_ON.split(" ")[0];
    }
    if(patchDetails[0].QA_STARTED_ON === null){
        patchDetails[0].QA_STARTED_ON = "-";
    }else{
        patchDetails[0].QA_STARTED_ON = patchDetails[0].QA_STARTED_ON.split(" ")[0];
    }
    if(patchDetails[0].RELEASED_NOT_IN_PUBLIC_SVN_ON === null){
        patchDetails[0].RELEASED_NOT_IN_PUBLIC_SVN_ON = "-";
    }else{
        patchDetails[0].RELEASED_NOT_IN_PUBLIC_SVN_ON = patchDetails[0].RELEASED_NOT_IN_PUBLIC_SVN_ON.split(" ")[0];
    }
    if(patchDetails[0].RELEASED_NOT_AUTOMATED_ON === null){
        patchDetails[0].RELEASED_NOT_AUTOMATED_ON = "-";
    }else{
        patchDetails[0].RELEASED_NOT_AUTOMATED_ON = patchDetails[0].RELEASED_NOT_AUTOMATED_ON.split(" ")[0];
    }
    if(patchDetails[0].RELEASED_ON === null){
        patchDetails[0].RELEASED_ON = "-";
    }else{
        patchDetails[0].RELEASED_ON = patchDetails[0].RELEASED_ON.split(" ")[0];
    }
    if(patchDetails[0].BROKEN_ON === null){
        patchDetails[0].BROKEN_ON = "-";
    }else{
        patchDetails[0].BROKEN_ON = patchDetails[0].BROKEN_ON.split(" ")[0];
    }
    if(patchDetails[0].REGRESSION_ON === null){
        patchDetails[0].REGRESSION_ON = "-";
    }else{
        patchDetails[0].REGRESSION_ON = patchDetails[0].REGRESSION_ON.split(" ")[0];
    }

    // console.log(patchDetails[0]);
    document.getElementById('currentStateLegend').style.display = 'block';
    document.getElementById('noteOfStateGraph').style.display = 'none';
    document.getElementById('resetButton').style.display = "block";
    document.getElementById('resetButtonStates').style.display = "block";
    generatePatchStateTransitionGraph(stateTransitionData,patchDetails[0]);
}

function generatePatchStateTransitionGraph(averageCounts,patchDetails){
    var currentState = patchDetails.LC_STATE;

    Highcharts.chart('stateGraph', {
        chart: {
            backgroundColor: 'white',
            events: {
                load: function () {

                    // Draw the flow chart
                    var ren = this.renderer,
                        colors = Highcharts.getOptions().colors,
                        rightArrow = ['M', 0, 0, 'L', 100, 0, 'L', 95, 5, 'M', 100, 0, 'L', 95, -5],
                        leftArrow = ['M', 100, 0, 'L', 0, 0, 'L', 5, 5, 'M', 0, 0, 'L', 5, -5];



                    // Separator, Yet to start from In progress
                    ren.path(['M', 200, 40, 'L', 200, 330])
                        .attr({
                            'stroke-width': 2,
                            stroke: 'silver',
                            dashstyle: 'dash'
                        })
                        .add();

                    // Separator, In progress from Released
                    ren.path(['M', 775, 40, 'L', 775, 330])
                        .attr({
                            'stroke-width': 2,
                            stroke: 'silver',
                            dashstyle: 'dash'
                        })
                        .add();

                    // Headers
                    ren.label('Yet to Start', 60, 40)
                        .css({
                            fontWeight: 'bold'
                        })
                        .add();
                    ren.label('In Progress', 440, 40)
                        .css({
                            fontWeight: 'bold'
                        })
                        .add();
                    ren.label('Released', 1100, 40)
                        .css({
                            fontWeight: 'bold'
                        })
                        .add();

                    // Queued label
                    if(currentState === 'Queued'){
                        ren.label('Queued State  <br/> <span style="text-align: center;">'+patchDetails.REPORT_DATE+'</span>', 10, 82)
                            .attr({
                                fill: 'red',
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add()
                            .shadow(true);
                    }else{
                        ren.label('Queued State  <br/> <span style="text-align: center;">'+patchDetails.REPORT_DATE+'</span>', 10, 82)
                            .attr({
                                fill: colors[0],
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add()
                            .shadow(true);
                    }

                    if(currentState === 'PreQADevelopment'){
                        ren.label('Pre QA State  <br/> <span style="text-align: center;">'+patchDetails.PRE_QA_STARTED_ON+'</span>', 220, 82)
                            .attr({
                                fill: 'red',
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add();
                    }else{
                        ren.label('Pre QA State  <br/> <span style="text-align: center;">'+patchDetails.PRE_QA_STARTED_ON+'</span>', 220, 82)
                            .attr({
                                fill: colors[1],
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add();
                    }


                    if(currentState === 'Development'){
                        ren.label('Developing State <br/> <span style="text-align: center;">'+patchDetails.DEVELOPMENT_STARTED_ON+'</span>', 430, 82)
                            .attr({
                                fill:'red',
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add();
                    }else{
                        ren.label('Developing State <br/> <span style="text-align: center;">'+patchDetails.DEVELOPMENT_STARTED_ON+'</span>', 430, 82)
                            .attr({
                                fill: colors[1],
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add();
                    }


                    if(currentState === 'ReadyForQA' || currentState === 'testing' || currentState === 'staging'){
                        ren.label('QA State  <br/> <span style="text-align: center;">'+patchDetails.QA_STARTED_ON+'</span>', 660, 82)
                            .attr({
                                fill: 'red',
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add();
                    }else{
                        ren.label('QA State  <br/> <span style="text-align: center;">'+patchDetails.QA_STARTED_ON+'</span>', 660, 82)
                            .attr({
                                fill: colors[1],
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add();
                    }


                    // Arrow from Queued to Pre QA
                    ren.path(rightArrow)
                        .attr({
                            'stroke-width': 2,
                            stroke: colors[3]
                        })
                        .translate(115, 105)
                        .add();

                    ren.label('Takes '+averageCounts[0]+' Day(s)', 125, 87)
                        .css({
                            fontSize: '10px',
                            color: colors[3]
                        })
                        .add();

                    // Arrow from Pre QA to Developing
                    ren.path(rightArrow)
                        .attr({
                            'stroke-width': 2,
                            stroke: colors[3]
                        })
                        .translate(325, 105)
                        .add();

                    ren.label('Takes '+averageCounts[1]+' Day(s)', 335, 87)
                        .css({
                            fontSize: '10px',
                            color: colors[3]
                        })
                        .add();

                    // Arrow from Developing to Testing
                    ren.path(rightArrow)
                        .attr({
                            'stroke-width': 2,
                            stroke: colors[3]
                        })
                        .translate(555, 105)
                        .add();

                    ren.label('Takes '+averageCounts[2]+' Day(s)', 565, 87)
                        .css({
                            fontSize: '10px',
                            color: colors[3]
                        })
                        .add();

                    // Arrow to On Hold state
                    ren.path(['M', 345, 180, 'L', 345, 245, 'L', 340, 240, 'M', 345, 245, 'L', 350, 240])
                        .attr({
                            'stroke-width': 2,
                            stroke: colors[3]
                        })
                        .add();

                    //On hold state
                    if(currentState === 'Regression'){
                        ren.label('Regression State  <br/> <span style="text-align: center;">'+patchDetails.REGRESSION_ON+'</span>', 290, 250)
                            .attr({
                                fill: 'red',
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add();
                    }else{
                        ren.label('Regression State  <br/> <span style="text-align: center;">'+patchDetails.REGRESSION_ON+'</span>', 290, 250)
                            .attr({
                                fill: colors[3],
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add();
                    }


                    // Arrow to On Hold state
                    ren.path(['M', 575, 180, 'L', 575, 245, 'L', 580, 240, 'M', 575, 245, 'L', 570, 240])
                        .attr({
                            'stroke-width': 2,
                            stroke: colors[3]
                        })
                        .add();

                    //Broken State
                    if(currentState === 'Broken' || currentState === 'OnHold'){
                        ren.label('Broken State   <br/> <span style="text-align: center;">'+patchDetails.BROKEN_ON+'</span>', 525, 250)
                            .attr({
                                fill:'red',
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add();
                    }else{
                        ren.label('Broken State   <br/> <span style="text-align: center;">'+patchDetails.BROKEN_ON+'</span>', 525, 250)
                            .attr({
                                fill: colors[7],
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add();
                    }


                    // Released NIPS label
                    if(currentState === 'ReleasedNotInPublicSVN'){
                        ren.label('Released NIPS <br/> <span style="text-align: center;">'+patchDetails.RELEASED_NOT_IN_PUBLIC_SVN_ON+'</span>', 870, 80)
                            .attr({
                                fill: 'red',
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add()
                            .shadow(true);
                    }else{
                        ren.label('Released NIPS <br/> <span style="text-align: center;">'+patchDetails.RELEASED_NOT_IN_PUBLIC_SVN_ON+'</span>', 870, 80)
                            .attr({
                                fill: '#7AC29A',
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add()
                            .shadow(true);
                    }


                    // Arrow from Testing to Released NIPS
                    ren.path(rightArrow)
                        .attr({
                            'stroke-width': 2,
                            stroke: '#7AC29A'
                        })
                        .translate(765, 105)
                        .add();

                    ren.label('Takes '+averageCounts[3]+' Day(s)', 777, 87)
                        .css({
                            color:'#7AC29A',
                            fontSize: '10px'
                        })
                        .add();

                    //Released NA label
                    if(currentState === 'ReleasedNotAutomated'){
                        ren.label('Released NA<br/> <span style="text-align: center;">'+patchDetails.RELEASED_NOT_AUTOMATED_ON+'</span>', 1100, 80)
                            .attr({
                                fill: 'red',
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add()
                            .shadow(true);
                    }else{
                        ren.label('Released NA<br/> <span style="text-align: center;">'+patchDetails.RELEASED_NOT_AUTOMATED_ON+'</span>', 1100, 80)
                            .attr({
                                fill: '#7AC29A',
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add()
                            .shadow(true);
                    }


                    // Arrow from Released NIPS to Released NA
                    ren.path(rightArrow)
                        .attr({
                            'stroke-width': 2,
                            stroke: '#7AC29A'
                        })
                        .translate(995, 105)
                        .add();

                    ren.label('Takes '+averageCounts[4]+' Day(s)', 1012, 87)
                        .css({
                            color:'#7AC29A',
                            fontSize: '10px'
                        })
                        .add();

                    //Released  label
                    if(currentState === 'Released'){
                        ren.label('Released State <br/> <span style="text-align: center;">'+patchDetails.RELEASED_ON+'</span>', 1330, 80)
                            .attr({
                                fill: 'red',
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add()
                            .shadow(true);
                    }else{
                        ren.label('Released State <br/> <span style="text-align: center;">'+patchDetails.RELEASED_ON+'</span>', 1330, 80)
                            .attr({
                                fill: '#7AC29A',
                                stroke: 'white',
                                'stroke-width': 2,
                                padding: 16,
                                r: 10
                            })
                            .css({
                                color: 'white',
                                width: '100px',
                                textAlign:'center'
                            })
                            .add()
                            .shadow(true);
                    }


                    // Arrow from Released NIPS to Released NA
                    ren.path(rightArrow)
                        .attr({
                            'stroke-width': 2,
                            stroke: '#7AC29A'
                        })
                        .translate(1225, 105)
                        .add();

                    ren.label('Takes '+averageCounts[5]+' Day(s)', 1242, 87)
                        .css({
                            color:'#7AC29A',
                            fontSize: '10px'
                        })
                        .add();


                }
            }
        },
        title: {
            text: '',
            style: {
                color: 'black'
            }
        }
    });
}

function whenStateOnClick(index){
    var patchStates = ["Queued","PreQADevelopment","Development","ReadyForQA","ReleasedNotInPublicSVN","ReleasedNotAutomated","Released","Broken","Regression"];
    var stateIdsIndex = index;
    var selectedStateIds = statesIds[stateIdsIndex];

    //fetch only details of selected state patches
    var selectedStateDetails = [];
    for(var t=0; t<selectedStateIds.length;t++){
        for(var s=0; s<patchDetails.length;s++){
            if(selectedStateIds[t][0] === patchDetails[s].ID && selectedStateIds[t][1] === patchDetails[s].eID ){
                selectedStateDetails.push(patchDetails[s]);
            }
        }
    }

    $('#patchDetailsLC').DataTable().destroy();

    //create dataset to feed datatable
    dataSet = [];
    var arrayOfStatesAtThatGivenTimeString = patchStates[stateIdsIndex];
    document.getElementById('selectedState').innerHTML = "in "+arrayOfStatesAtThatGivenTimeString+" State";
    document.getElementById('resetButton').style.display = "block";
    document.getElementById('resetButtonStates').style.display = "block";

    for (var x=0;x<selectedStateDetails.length;x++){
        if(selectedStateDetails[x].LC_STATE === null){
            selectedStateDetails[x].LC_STATE = "Queued";
        }
        if(selectedStateDetails[x].PRE_QA_STARTED_ON === null){
            selectedStateDetails[x].PRE_QA_STARTED_ON = "-";
        }else{
            selectedStateDetails[x].PRE_QA_STARTED_ON = selectedStateDetails[x].PRE_QA_STARTED_ON.split(" ")[0];
        }
        if(selectedStateDetails[x].DEVELOPMENT_STARTED_ON === null){
            selectedStateDetails[x].DEVELOPMENT_STARTED_ON = "-";
        }else{
            selectedStateDetails[x].DEVELOPMENT_STARTED_ON = selectedStateDetails[x].DEVELOPMENT_STARTED_ON.split(" ")[0];
        }
        if(selectedStateDetails[x].QA_STARTED_ON === null){
            selectedStateDetails[x].QA_STARTED_ON = "-";
        }else{
            selectedStateDetails[x].QA_STARTED_ON = selectedStateDetails[x].QA_STARTED_ON.split(" ")[0];
        }
        if(selectedStateDetails[x].RELEASED_NOT_IN_PUBLIC_SVN_ON === null){
            selectedStateDetails[x].RELEASED_NOT_IN_PUBLIC_SVN_ON = "-";
        }else{
            selectedStateDetails[x].RELEASED_NOT_IN_PUBLIC_SVN_ON = selectedStateDetails[x].RELEASED_NOT_IN_PUBLIC_SVN_ON.split(" ")[0];
        }
        if(selectedStateDetails[x].RELEASED_NOT_AUTOMATED_ON === null){
            selectedStateDetails[x].RELEASED_NOT_AUTOMATED_ON = "-";
        }else{
            selectedStateDetails[x].RELEASED_NOT_AUTOMATED_ON = selectedStateDetails[x].RELEASED_NOT_AUTOMATED_ON.split(" ")[0];
        }
        if(selectedStateDetails[x].RELEASED_ON === null){
            selectedStateDetails[x].RELEASED_ON = "-";
        }else{
            selectedStateDetails[x].RELEASED_ON = selectedStateDetails[x].RELEASED_ON.split(" ")[0];
        }
        if(selectedStateDetails[x].BROKEN_ON === null){
            selectedStateDetails[x].BROKEN_ON = "-";
        }else{
            selectedStateDetails[x].BROKEN_ON = selectedStateDetails[x].BROKEN_ON.split(" ")[0];
        }
        if(selectedStateDetails[x].REGRESSION_ON === null){
            selectedStateDetails[x].REGRESSION_ON = "-";
        }else{
            selectedStateDetails[x].REGRESSION_ON = selectedStateDetails[x].REGRESSION_ON.split(" ")[0];
        }
        var el = [
            selectedStateDetails[x].ID,
            selectedStateDetails[x].PRODUCT_NAME,
            selectedStateDetails[x].SUPPORT_JIRA.split('browse/')[1],
            selectedStateDetails[x].LC_STATE,
            arrayOfStatesAtThatGivenTimeString,
            selectedStateDetails[x].REPORT_DATE,
            selectedStateDetails[x].PRE_QA_STARTED_ON,
            selectedStateDetails[x].DEVELOPMENT_STARTED_ON,
            selectedStateDetails[x].QA_STARTED_ON,
            selectedStateDetails[x].RELEASED_NOT_IN_PUBLIC_SVN_ON,
            selectedStateDetails[x].RELEASED_NOT_AUTOMATED_ON,
            selectedStateDetails[x].RELEASED_ON,
            selectedStateDetails[x].BROKEN_ON,
            selectedStateDetails[x].REGRESSION_ON,
            selectedStateDetails[x].eID
        ];

        dataSet[x] = el;
    }


    $('#patchDetailsLC').DataTable({
        data: dataSet,
        columns: [
            { title: "Patch ID" },
            { title: "Product Name" },
            { title: "JIRA ID" },
            { title: "Current State" },
            { title: "State at that Moment" },
            { title: "Queued On" },
            { title: "Pre QA On" },
            { title: "Dev Started" },
            { title: "QA Started" },
            { title: "Released NIPS" },
            { title: "Released NS" },
            { title: "Released On" },
            { title: "Broken On" },
            { title: "Regression On" },
            { title: "ETA ID" }
        ],
        "aoColumnDefs": [
            { "sClass": "column-2", "aTargets": [ 1 ] },
            { "sClass": "column-12", "aTargets": [ 14 ] },
            { "render": function(data, type, row, meta){data = '<a href="' +SUPPORT_JIRA_PATH + data + '" target="_blank">' + data + '</a>';return data;}, "aTargets": [ 2 ] }
        ]
    });

    //click on the patch detail table and get a specific ID
    $('#patchDetailsLC tbody').on('click', 'tr', function () {
        var data = $('#patchDetailsLC').DataTable().row( this ).data();
        $("#patchDetailsLC tbody tr").removeClass('row_selected');
        $(this).addClass('row_selected');
        getSpecificPatchLifeCycle(data[0],data[14]);
    } );


}