var baseUrl='https://digitalops.services.wso2.com:9092/';

var currentVersion;
var currentIssueIssueType;
var currentIssueSeverity;
var currentSonarIssueType;
var currentSonarSeverity;

var issueStartDate;
var issueEndDate;
var sonarStartDate;
var sonarEndDate;

var issueHistoryTitle;
var sonarHistoryTitle;

var currentIssueMainChartData;
var currentIssueIssueTypeChartData;
var currentIssueSeverityChartData;
var currentSonarMainChartData;
var currentSonarIssueTypeChartData;
var currentSonarSeverityChartData;

var currentIssueMainChartTitle;
var currentIssueIssueTypeChartTitle;
var currentIssueSeverityChartTitle;
var currentSonarMainChartTitle;
var currentSonarIssueTypeChartTitle;
var currentSonarSeverityChartTitle;

var currentAreaId;
var currentProductId;
var currentComponentId;
var currentCategoryId;

var issueMainChart;
var issueIssuetypeChart;
var issueSeverityChart;
var sonarMainChart;
var sonarIssuetypeChart;
var sonarSeverityChart;

var currentData;
var issueIssueTypeIsSelected;
var issueSeverityIsSelected;
var sonarIssueTypeIsSelected;
var sonarSeverityIsSelected;

var currentIssueIssueType;
var currentIssueSeverity;
var currentSonarIssueType;
var currentSonarSeverity;

var currentCategory;
var sameAreaIsSelected;


function initPage() {
    
    var sidePaneDetails;
    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/issues/all',
        async: false,
        success: function(data){
            sidePaneDetails = data.data.items;
            currentData = data.data;
        }
    });

    issueIssueTypeIsSelected = false;
    issueSeverityIsSelected = false;
    sonarIssueTypeIsSelected = false;
    sonarSeverityIsSelected = false;

    currentIssueIssueType = 0;
    currentIssueSeverity = 0;
    currentSonarIssueType = 0;
    currentSonarSeverity = 0;

    currentCategory = "all";
    currentCategoryId = 0;

    sameAreaIsSelected = 0;

    loadSidePane(sidePaneDetails);

    loadTypeAndSeverityDropdowns();

    initChart();

    initSonarChart();


}

function loadTypeAndSeverityDropdowns() {
    var issueIssueTypes;
    var issueSeverities;
    var sonarIssueTypes;
    var sonarSeverities;
    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/getIssueTypesAndSeverities',
        async: false,
        success: function(data){
            
            issueIssueTypes = data.data.issueIssuetypes;
            issueSeverities = data.data.issueSeverities;
            
            sonarIssueTypes = data.data.sonarIssuetypes;
            sonarSeverities = data.data.sonarSeverities;

        }
    });
    loadTypeAndSeverityDropdownsForIssues(issueIssueTypes, issueSeverities);
    loadTypeAndSeverityDropdownsForSonar(sonarIssueTypes, sonarSeverities);
}

function loadTypeAndSeverityDropdownsForSonar(issueTypes, severities) {

    var selectIssueType = document.getElementById('sonar-issuetype-choice');
    var  totalIssueTypes = issueTypes.length;
    for(var a=0; a<totalIssueTypes; a++) {
        var option1 = document.createElement('option');
        var typeId =  issueTypes[a].id;
        var typeName =  issueTypes[a].type;

        option1.setAttribute("value",typeId);
        option1.setAttribute("style","font-size: 100%");
        option1.appendChild(document.createTextNode(typeName));
        selectIssueType.appendChild(option1);
    }

    selectIssueType.addEventListener('change',function(){
        var e = document.getElementById("sonar-issuetype-choice");
        var selectedSonarType = e.options[e.selectedIndex].value;

        currentSonarIssueType = parseInt(selectedSonarType);

        if(currentSonarIssueType !== 0){
            sonarIssueTypeIsSelected = true;

            for (var i = 0; i < sonarIssuetypeChart.series[0].data.length; i++) {
                sonarIssuetypeChart.series[0].data[i].update({ color: '#a2a3a3' }, true, false);
            }
            sonarIssuetypeChart.get(parseInt(selectedSonarType)).update({ color: '#118983' }, true, false);
            sonarIssuetypeChart.get(parseInt(selectedSonarType)).select();
        }else{
            sonarIssueTypeIsSelected = false;
        }
        selectSonarIssueTypePieChart();
    });


    var selectSeverity = document.getElementById('sonar-severity-choice');
    var  totalSeverities = severities.length;
    for(var i=0; i<totalSeverities; i++) {
        var option = document.createElement('option');
        var id =  severities[i].id;
        var name =  severities[i].severity;

        option.setAttribute("value",id);
        option.appendChild(document.createTextNode(name));
        selectSeverity.appendChild(option);
    }

    selectSeverity.addEventListener('change',function(){
        var e = document.getElementById("sonar-severity-choice");
        var selectedSonarSeverity = e.options[e.selectedIndex].value;

        currentSonarSeverity = parseInt(selectedSonarSeverity);
        if(currentSonarSeverity !== 0){
            sonarSeverityIsSelected = true;
            for (var i = 0; i < sonarSeverityChart.series[0].data.length; i++) {
                
                sonarSeverityChart.series[0].data[i].update({ color: '#a2a3a3' }, true, false);
            }
            sonarSeverityChart.get(parseInt(selectedSonarSeverity)).update({ color: '#118983' }, true, false);
            sonarSeverityChart.get(parseInt(selectedSonarSeverity)).select();
        }else{
            sonarSeverityIsSelected = false;
        }
        selectSonarSeverityPieChart();
    });
}

function loadTypeAndSeverityDropdownsForIssues(issueTypes, severities) {

    var selectIssueType = document.getElementById('issuetype-choice');
    var  totalIssueTypes = issueTypes.length;
    for(var a=0; a<totalIssueTypes; a++) {
        var option1 = document.createElement('option');
        var typeId =  issueTypes[a].pqd_issue_type_id;
        var typeName =  issueTypes[a].pqd_issue_type;

        option1.setAttribute("value",typeId);
        option1.appendChild(document.createTextNode(typeName));
        selectIssueType.appendChild(option1);
    }

    selectIssueType.addEventListener('change',function(){
        var e = document.getElementById("issuetype-choice");
        var selectedType = e.options[e.selectedIndex].value;

        currentIssueIssueType = parseInt(selectedType);

        if(currentIssueIssueType !== 0){
            issueIssueTypeIsSelected = true;

            for (var i = 0; i < issueIssuetypeChart.series[0].data.length; i++) {
                issueIssuetypeChart.series[0].data[i].update({ color: '#a2a3a3' }, true, false);
            }
            issueIssuetypeChart.get(parseInt(selectedType)).update({ color: '#118983' }, true, false);
            issueIssuetypeChart.get(parseInt(selectedType)).select();
        }else{
            issueIssueTypeIsSelected = false;
        }
        selectIssueIssueTypePieChart();
    });


    var selectSeverity = document.getElementById('severity-choice');
    var  totalSeverities = severities.length;
    for(var i=0; i<totalSeverities; i++) {
        var option = document.createElement('option');
        var id =  severities[i].pqd_severity_id;
        var name =  severities[i].pqd_severity;

        option.setAttribute("value",id);
        option.appendChild(document.createTextNode(name));
        selectSeverity.appendChild(option);
    }

    selectSeverity.addEventListener('change',function(){
        var e = document.getElementById("severity-choice");
        var selectedSeverity = e.options[e.selectedIndex].value;

        currentIssueSeverity = parseInt(selectedSeverity);

        if(currentIssueSeverity !== 0){
            issueSeverityIsSelected = true;
            for (var i = 0; i < issueSeverityChart.series[0].data.length; i++) {
                issueSeverityChart.series[0].data[i].update({ color: '#a2a3a3' }, true, false);
            }
            issueSeverityChart.get(parseInt(selectedSeverity)).update({ color: '#118983' }, true, false);
            issueSeverityChart.get(parseInt(selectedSeverity)).select();
        }else{
            issueSeverityIsSelected = false;
        }
        selectIssueSeverityPieChart();
    });
}


function selectIssueIssueTypePieChart() {
    var url = baseUrl+'internal/product-quality/v1.0/github/issues/issuetype/'+currentIssueIssueType+'/severity/'+currentIssueSeverity;

    if (issueSeverityIsSelected === true){
        
        document.getElementById("severity-choice").disabled = true;
        document.getElementById("issueArrow").innerHTML = '<i class="fa fa-long-arrow-left" aria-none="true"></i>';
        
        var refreshBtn = document.getElementById("resetIssueChartsId");
        refreshBtn.style.display = 'initial';
        
    }

    $.ajax({
        type: "GET",
        url: url,
        data:{
            category: currentCategory,
            categoryId: currentCategoryId
        },
        async: false,
        success: function(data){
            currentData = data.data;

        }
    });

    initChart();
}

function selectIssueSeverityPieChart() {

    var url = baseUrl+'internal/product-quality/v1.0/github/issues/issuetype/'+currentIssueIssueType+'/severity/'+currentIssueSeverity;

    if (issueIssueTypeIsSelected === true){
        
        document.getElementById("issuetype-choice").disabled = true;
        document.getElementById("issueArrow").innerHTML = '<i class="fa fa-long-arrow-right" aria-none="true"></i>';
        var refreshBtn = document.getElementById("resetIssueChartsId");
        refreshBtn.style.display = 'initial';
    }

    $.ajax({
        type: "GET",
        url: url,
        data:{
            category: currentCategory,
            categoryId: currentCategoryId
        },
        async: false,
        success: function(data){
            currentData = data.data;
        }
    });
    initChart();
}

function selectSonarIssueTypePieChart() {

    var url = baseUrl+'internal/product-quality/v1.0/sonar/issues/issuetype/'+currentSonarIssueType+'/severity/'+currentSonarSeverity;

    if (sonarSeverityIsSelected === true){
        
        document.getElementById("sonar-severity-choice").disabled = true;
        document.getElementById("sonarArrow").innerHTML = '<i class="fa fa-long-arrow-left" aria-none="true"></i>';
        var refreshBtn = document.getElementById("resetSonarChartsId");
        refreshBtn.style.display = 'initial';
    }


    $.ajax({
        type: "GET",
        url: url,
        data:{
            category: currentCategory,
            categoryId: currentCategoryId
        },
        async: false,
        success: function(data){
            currentData = data.data;
        }
    });
    initSonarChart();
}

function selectSonarSeverityPieChart() {

    var url = baseUrl+'internal/product-quality/v1.0/sonar/issues/issuetype/'+currentSonarIssueType+'/severity/'+currentSonarSeverity;

    if (sonarIssueTypeIsSelected === true){
        
        document.getElementById("sonar-issuetype-choice").disabled = true;
        document.getElementById("sonarArrow").innerHTML = '<i class="fa fa-long-arrow-right" aria-none="true"></i>';
        var refreshBtn = document.getElementById("resetSonarChartsId");
        refreshBtn.style.display = 'initial';
    }

    $.ajax({
        type: "GET",
        url: url,
        data:{
            category: currentCategory,
            categoryId: currentCategoryId
        },
        async: false,
        success: function(data){
            currentData = data.data;
        }
    });
    initSonarChart();
}

function resetSonarCharts() {
    currentSonarIssueType = 0;
    currentSonarSeverity = 0;
    sonarIssueTypeIsSelected = false;
    sonarSeverityIsSelected = false;

    document.getElementById("sonar-issuetype-choice").disabled = false;
    document.getElementById("sonar-severity-choice").disabled = false;
    document.getElementById("sonar-issuetype-choice").selectedIndex = "0";
    document.getElementById("sonar-severity-choice").selectedIndex = "0";

    document.getElementById("sonarArrow").innerHTML = '';
    var refreshBtn = document.getElementById("resetSonarChartsId");
    refreshBtn.style.display = 'none';

    
    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/sonar/issues/issuetype/'+currentSonarIssueType+'/severity/'+currentSonarSeverity,
        async: false,
        data:{
            category: currentCategory,
            categoryId: currentCategoryId
        },
        success: function(data){
            currentData = data.data;
        }
    });

    initSonarChart();
    
}

function resetIssueCharts() {
    currentIssueIssueType = 0;
    currentIssueSeverity = 0;
    issueIssueTypeIsSelected = false;
    issueSeverityIsSelected = false;

    document.getElementById("issuetype-choice").disabled = false;
    document.getElementById("severity-choice").disabled = false;
    document.getElementById("issuetype-choice").selectedIndex = "0";
    document.getElementById("severity-choice").selectedIndex = "0";

    document.getElementById("issueArrow").innerHTML = '';
    var refreshBtn = document.getElementById("resetIssueChartsId");
    refreshBtn.style.display = 'none';

    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/github/issues/issuetype/'+currentIssueIssueType+'/severity/'+currentIssueSeverity,
        async: false,
        data:{
            category: currentCategory,
            categoryId: currentCategoryId
        },
        success: function(data){
            currentData = data.data;
        }
    });

    initChart();
    
}

function loadSidePane(sidePaneDetails) {
    
    var totalProducts = sidePaneDetails.length;

    for (var x = 0; x < totalProducts; x++) {
        document.getElementById('area').innerHTML += "<div class='panel' style='margin-top:0px; margin-bottom:-4px; font-size: 100%;'><button onclick='clickArea("+sidePaneDetails[x].id+")' data-parent='#area' href='#collapseArea"+(sidePaneDetails[x].id)+"' data-toggle='collapse' id='a"+(sidePaneDetails[x].id)+"' class='list-group-item'>"
            + sidePaneDetails[x].name        +
            "<span id='sonarCount"+(parseInt(x)+1)+"' class='badge' style='width:2.7vw; font-size: 0.75vw; background-color:#206898;padding:3px 6px;'></span>" +
            "<span id='issueCount"+(parseInt(x)+1)+"' class='badge' style='width:2.2vw; font-size: 0.75vw; background-color:#FF9933; padding:3px 6px;'></span></button>" +
            "<div id='collapseArea"+(sidePaneDetails[x].id)+"'  style='transition: all .8s ease;' class='panel-collapse collapse' role='tabpanel' aria-labelledby='headingOne'>" +
            "<div class='sidebarInside'>" +
            "<ul id='product"+(sidePaneDetails[x].id)+"' >"+
            ""+
            "</ul>"+
            "</div>" +
            "</div>" +
            "</div>"

        document.getElementById('issueCount'+(parseInt(x)+1)).innerHTML = sidePaneDetails[x].issues;
        document.getElementById('sonarCount'+(parseInt(x)+1)).innerHTML = sidePaneDetails[x].sonar;
    }
}


function resetDashboardView() {
    
    var sidePaneDetails;
    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/issues/all',
        async: false,
        success: function(data){
            
            sidePaneDetails = data.data.items;
            currentData = data.data;
        }
    });
    
    issueIssueTypeIsSelected = false;
    issueSeverityIsSelected = false;
    sonarIssueTypeIsSelected = false;
    sonarSeverityIsSelected = false;

    currentIssueIssueType = 0;
    currentIssueSeverity = 0;
    currentSonarIssueType = 0;
    currentSonarSeverity = 0;

    document.getElementById("sonar-issuetype-choice").disabled = false;
    document.getElementById("sonar-severity-choice").disabled = false;
    document.getElementById("sonar-issuetype-choice").selectedIndex = "0";
    document.getElementById("sonar-severity-choice").selectedIndex = "0";

    document.getElementById("issuetype-choice").disabled = false;
    document.getElementById("severity-choice").disabled = false;
    document.getElementById("issuetype-choice").selectedIndex = "0";
    document.getElementById("severity-choice").selectedIndex = "0";

    document.getElementById("issueArrow").innerHTML = '';
    var refreshBtn = document.getElementById("resetIssueChartsId");
    refreshBtn.style.display = 'none';

    document.getElementById("sonarArrow").innerHTML = '';
    var refreshBtn = document.getElementById("resetSonarChartsId");
    refreshBtn.style.display = 'none';

    currentCategory = "all";
    currentCategoryId = 0;

    sameAreaIsSelected = 0;

    document.getElementById('componentChoice').innerHTML = "&nbsp;";
    document.getElementById('area').innerHTML = "";

    loadSidePane(sidePaneDetails);
    initChart();
    initSonarChart();
}

function clickArea(areaId){
    if(currentAreaId === areaId){
        sameAreaIsSelected = sameAreaIsSelected + 1;

        if(sameAreaIsSelected === 3){
            sameAreaIsSelected = 1;
        }

    }else{
        sameAreaIsSelected = 1;
    }

    currentCategoryId = areaId;
    currentCategory = "area";
    currentAreaId = areaId;

    issueIssueTypeIsSelected = false;
    issueSeverityIsSelected = false;
    sonarIssueTypeIsSelected = false;
    sonarSeverityIsSelected = false;

    currentIssueIssueType = 0;
    currentIssueSeverity = 0;
    currentSonarIssueType = 0;
    currentSonarSeverity = 0;


    
    document.getElementById('componentChoice').innerHTML = "&nbsp;";
    document.getElementById('product'+(areaId)).innerHTML = "";
    document.getElementById("issuetype-choice").disabled = false;
    document.getElementById("severity-choice").disabled = false;
    document.getElementById("sonar-issuetype-choice").disabled = false;
    document.getElementById("sonar-severity-choice").disabled = false;

    document.getElementById("issuetype-choice").selectedIndex = "0";
    document.getElementById("severity-choice").selectedIndex = "0";
    document.getElementById("sonar-issuetype-choice").selectedIndex = "0";
    document.getElementById("sonar-severity-choice").selectedIndex = "0";

    document.getElementById("issueArrow").innerHTML = '';
    var refreshBtn = document.getElementById("resetIssueChartsId");
    refreshBtn.style.display = 'none';

    document.getElementById("sonarArrow").innerHTML = '';
    var refreshBtn = document.getElementById("resetSonarChartsId");
    refreshBtn.style.display = 'none';

    var sidePaneDetails;

    if(sameAreaIsSelected === 2){
        currentCategoryId = 0;
        currentCategory = "all";

        $.ajax({
            type: "GET",
            url: baseUrl+'internal/product-quality/v1.0/issues/all/',
            async: false,
            success: function(data){
                currentData = data.data;
            }
        });
        
    }else{
        $.ajax({
            type: "GET",
            url: baseUrl+'internal/product-quality/v1.0/issues/area/'+ areaId,
            async: false,
            success: function(data){
                
                sidePaneDetails = data.data.items;
                currentData = data.data;
            }
        });
        

        var totalProducts = sidePaneDetails.length;

        for(var y=0;y<totalProducts;y++){
            issuecount = sidePaneDetails[y].issues;
            sonarCount = sidePaneDetails[y].sonar;

            document.getElementById('product'+(areaId)).innerHTML +=
                "<button class='btn-product list-group-item list-group-item-info' onclick='clickProduct("+(sidePaneDetails[y].id)+")' style='width:100%;text-align: left;' id='" + sidePaneDetails[y].id + "'>"+
                sidePaneDetails[y].name +
                "<span id='sonarProductCount"+areaId+(parseInt(y))+"' class='badge' style='min-width:2.7vw; font-size: 0.75vw; background-color:#206898;padding:3px 6px;'></span>" +
                "<span id='issueProductCount"+areaId+(parseInt (y))+"' class='badge' style='min-width:2.2vw; font-size: 0.75vw; background-color:#FF9933; padding:3px 6px;'></span></button>";

            document.getElementById('issueProductCount'+areaId+(parseInt(y))).innerHTML = issuecount;
            document.getElementById('sonarProductCount'+areaId+(parseInt(y))).innerHTML = sonarCount;

        }
    }
    initChart();
    initSonarChart();
}

function clickProduct(productId) {
    

    $('.btn-product').removeClass('btn-product-active').addClass('btn-product-inactive');
    $('#'+productId).removeClass('btn-product-inactive').addClass('btn-product-active');

    
    currentCategoryId = productId;
    currentProductId = productId;
    currentCategory = "product";

    currentIssueIssueType = 0;
    currentIssueSeverity = 0;
    currentSonarIssueType = 0;
    currentSonarSeverity = 0;

    issueIssueTypeIsSelected = false;
    issueSeverityIsSelected = false;
    sonarIssueTypeIsSelected = false;
    sonarSeverityIsSelected = false;

    document.getElementById("issuetype-choice").disabled = false;
    document.getElementById("severity-choice").disabled = false;
    document.getElementById("sonar-issuetype-choice").disabled = false;
    document.getElementById("sonar-severity-choice").disabled = false;

    document.getElementById("issuetype-choice").selectedIndex = "0";
    document.getElementById("severity-choice").selectedIndex = "0";
    document.getElementById("sonar-issuetype-choice").selectedIndex = "0";
    document.getElementById("sonar-severity-choice").selectedIndex = "0";

    document.getElementById("issueArrow").innerHTML = '';
    var refreshBtn = document.getElementById("resetIssueChartsId");
    refreshBtn.style.display = 'none';

    document.getElementById("sonarArrow").innerHTML = '';
    var refreshBtn = document.getElementById("resetSonarChartsId");
    refreshBtn.style.display = 'none';

    var sidePaneDetails;
    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/issues/product/'+productId ,
        async: false,
        success: function(data){
            
            sidePaneDetails = data.data.items;
            currentData = data.data;
        }
    });

    loadComponentDropdown(sidePaneDetails);

    initChart();
    
    initSonarChart();
}


function loadComponentDropdown(sidePaneDetails) {

    document.getElementById('componentChoice').innerHTML = "";
    var item = document.getElementById('componentChoice');
    var div1 = document.createElement('div');
    div1.setAttribute("class","col-xs-2 col-md-2");
    var headingTag = document.createElement("h5");
    var heading = document.createTextNode("Component:");
    headingTag.appendChild(heading);
    div1.appendChild(headingTag);
    item.appendChild(div1);
    
    var div2 = document.createElement('div');
    div2.setAttribute("class","col-xs-3 col-md-3 form-group");
    div2.setAttribute("style","text-align: left;font-size: 0.8vw;margin:0");

    var select = document.createElement('select');
    select.setAttribute("class","form-control");
    select.setAttribute("id","sel1");
    select.setAttribute("style","width:20.1vw;font-size: 0.8vw;");
    

    if(sidePaneDetails.length !== 0){
        var optionAll =  document.createElement('option');
        var all = 0;
        var nameAll =  "All";

        optionAll.setAttribute("value",all);
        optionAll.appendChild(document.createTextNode(nameAll));
        select.appendChild(optionAll);

        var  totalComponents = sidePaneDetails.length;
        for(var a=0; a<totalComponents; a++) {
            var option = document.createElement('option');
            var id =  sidePaneDetails[a].id;
            var name =  sidePaneDetails[a].name;

            option.setAttribute("value",id);
            option.appendChild(document.createTextNode(name));
            select.appendChild(option);
        }
    }
    

    div2.appendChild(select);
    item.appendChild(div2);

    
    select.addEventListener('change',function(){
        var e = document.getElementById("sel1");
        var strUser = e.options[e.selectedIndex].value;
        
        if(parseInt(strUser) > 0){
            loadComponentDetails(parseInt(strUser));
        }else{
            clickProduct(currentProductId);
        }
    });


}

function loadComponentDetails(componentId) {
    
    currentCategoryId = componentId;
    currentCategory = "component";

    currentIssueIssueType = 0;
    currentIssueSeverity = 0;
    currentSonarIssueType = 0;
    currentSonarSeverity = 0;

    issueIssueTypeIsSelected = false;
    issueSeverityIsSelected = false;
    sonarIssueTypeIsSelected = false;
    sonarSeverityIsSelected = false;

    document.getElementById("issuetype-choice").disabled = false;
    document.getElementById("severity-choice").disabled = false;
    document.getElementById("sonar-issuetype-choice").disabled = false;
    document.getElementById("sonar-severity-choice").disabled = false;

    document.getElementById("issuetype-choice").selectedIndex = "0";
    document.getElementById("severity-choice").selectedIndex = "0";
    document.getElementById("sonar-issuetype-choice").selectedIndex = "0";
    document.getElementById("sonar-severity-choice").selectedIndex = "0";

    document.getElementById("issueArrow").innerHTML = '';
    var refreshBtn = document.getElementById("resetIssueChartsId");
    refreshBtn.style.display = 'none';

    document.getElementById("sonarArrow").innerHTML = '';
    var refreshBtn = document.getElementById("resetSonarChartsId");
    refreshBtn.style.display = 'none';


    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/issues/component/' + componentId,
        async: false,
        success: function(data){
            currentData = data.data;
        }
    });

    initChart();
    initSonarChart();
}


function initChart() {
    productData = currentData.items;
    mainSeriesData = [];
    totalMainIssues = 0;

    if (currentCategory !== "component"){

        if(productData.length !== 0){
            for(var i = 0; i < productData.length; i++){
                name = productData[i].name;
                id = productData[i].id;
                y = productData[i].issues;
                totalMainIssues += y;

                mainSeriesData.push({name: name, id:id, y: y});
            }

        }
        currentIssueMainChartTitle = "Total : " + totalMainIssues;
        currentIssueMainChartData = [{
            name: "Product",
            colorByPoint: true, data: mainSeriesData
        }]
        createMainChart();
    }

    if (currentCategory === "component"){

        if(productData.length !== 0){
            for(var i = 0; i < productData.length; i++){
                name = productData[i].name;
                id = productData[i].id;
                y = productData[i].issues;
                totalMainIssues += y;

                if (id === currentCategoryId){
                    mainSeriesData.push({name: name, id:id, y: y, color: '#118983'});
                }else{
                    mainSeriesData.push({name: name, id:id, y: y, color: '#a2a3a3'});
                }
            }

        }
        currentIssueMainChartTitle = "Total : " + totalMainIssues;
        currentIssueMainChartData = [{
            name: "Component",
            colorByPoint: true, data: mainSeriesData
        }]
        createMainChart();
    }

    if(issueIssueTypeIsSelected === false){
        
        issuetypeData = currentData.issueIssuetype;

        issuetypeSeriesData = [];
        totalIssuetypeIssues = 0;

        if(issuetypeData.length !== 0){

            for(var i = 0; i < issuetypeData.length; i++){
                name = issuetypeData[i].name;
                id = issuetypeData[i].id;
                y = issuetypeData[i].issues;
                totalIssuetypeIssues += y;

                issuetypeSeriesData.push({name: name, id:id, y: y});
            }
        }
        currentIssueIssueTypeChartData = [{
            name: "Issue type",
            colorByPoint: true, data: issuetypeSeriesData
        }]

        currentIssueIssueTypeChartTitle = "Total : " + totalIssuetypeIssues;
        createIssueTypeChart();
    }


    if(issueSeverityIsSelected === false){
        severityData = currentData.issueSeverity;

        severitySeriesData = [];
        totalSeverityIssues = 0;

        if(severityData.length !== 0){

            for(var i = 0; i < severityData.length; i++){
                name = severityData[i].name;
                id = severityData[i].id;
                y = severityData[i].issues;
                totalSeverityIssues += y;

                severitySeriesData.push({name: name, id:id, y: y});
            }
        }

        currentIssueSeverityChartData = [{
            name: "Severity",
            colorByPoint: true, data: severitySeriesData
        }]
        currentIssueSeverityChartTitle = "Total : " + totalSeverityIssues;
        createSeverityChart();
    }

    var dateFrom = moment().subtract(29, 'days');
    var dateTo= moment();
    issueStartDate = dateFrom.format('YYYY-MM-DD');
    issueEndDate = dateTo.format('YYYY-MM-DD');
    getIssueTrendLineHistory("day");
    
}

function initSonarChart() {
    productData = currentData.items;
    mainSeriesData = [];
    totalMainIssues = 0;

    if (currentCategory !== "component"){
        if(productData.length !== 0){

            for(var i = 0; i < productData.length; i++){
                name = productData[i].name;
                id = productData[i].id;
                y = productData[i].sonar;
                totalMainIssues += y;

                mainSeriesData.push({name: name, id:id, y: y});
            }
        }


        currentSonarMainChartTitle = "Total : " + totalMainIssues;
        currentSonarMainChartData = [{
            name: "Product",
            colorByPoint: true, data: mainSeriesData
        }]

        createSonarMainChart();

    }

    if (currentCategory === "component"){
        if(productData.length !== 0){

            for(var i = 0; i < productData.length; i++){
                name = productData[i].name;
                id = productData[i].id;
                y = productData[i].sonar;
                totalMainIssues += y;

                if (id === currentCategoryId){
                    mainSeriesData.push({name: name, id:id, y: y, color: '#118983'});
                }else{
                    mainSeriesData.push({name: name, id:id, y: y, color: '#a2a3a3'});
                }
            }

        }
        currentSonarMainChartTitle = "Total : " + totalMainIssues;
        currentSonarMainChartData = [{
            name: "Component",
            colorByPoint: true, data: mainSeriesData
        }]
        createSonarMainChart();
    }


    //set the data for the issuetype chart
    if(sonarIssueTypeIsSelected === false){

        issuetypeData = currentData.sonarIssuetype;
        issuetypeSeriesData = [];
        totalIssuetypeIssues = 0;

        if(issuetypeData.length !== 0){

            for(var i = 0; i < issuetypeData.length; i++){
                
                name = issuetypeData[i].name;

                id = issuetypeData[i].id;

                y = issuetypeData[i].sonar;
                totalIssuetypeIssues += y;

                issuetypeSeriesData.push({name: name, id:id, y: y});
            }

        }

        currentSonarIssueTypeChartData = [{
            name: "Issue type",
            colorByPoint: true, data: issuetypeSeriesData
        }]

        currentSonarIssueTypeChartTitle = "Total : " + totalIssuetypeIssues;
        createSonarIssueTypeChart();
    }


    if(sonarSeverityIsSelected === false){
        severityData = currentData.sonarSeverity;

        severitySeriesData = [];
        totalSeverityIssues = 0;

        if(severityData.length !== 0){
            for(var i = 0; i < severityData.length; i++){
                name = severityData[i].name;
                id = severityData[i].id;
                y = severityData[i].sonar;
                totalSeverityIssues += y;

                severitySeriesData.push({name: name, id:id, y: y});
            }
        }

        currentSonarSeverityChartData = [{
            name: "Severity",
            colorByPoint: true, data: severitySeriesData
        }]
        currentSonarSeverityChartTitle = "Total : " + totalSeverityIssues;
        createSonarSeverityChart();
    }

    
    var dateFrom = moment().subtract(29, 'days');
    var dateTo= moment();
    sonarStartDate = dateFrom.format('YYYY-MM-DD');
    sonarEndDate = dateTo.format('YYYY-MM-DD');
    getSonarTrendLineHistory("day");
    

}


function createMainChart(){
    issueMainChart = Highcharts.chart('main-chart-container', {
        chart: {
            type: 'column'
        },
        title: {
            text: currentIssueMainChartTitle
        },
        credits: {
            enabled: false
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'Total open issues'
            }
        },
        legend: {
                enabled: false
        },
        plotOptions: {
            series: {
                borderWidth: 0,
                dataLabels: {
                    enabled: true,
                    format: '{point.y}'
                },
                allowPointSelect: false,
            }, column: {
                maxPointWidth: 100
            }
        },

        tooltip: {
            headerFormat: '<span style="font-size:0.7387508394895903vw">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b>'
        },

        series: currentIssueMainChartData,

        exporting: {
            enabled: true
        }
    });

}

function createSonarMainChart(){
    sonarMainChart = Highcharts.chart('main-chart-container-sonar', {
        chart: {
            type: 'column'
        },
        title: {
            text: currentSonarMainChartTitle
        },
        credits: {
            enabled: false
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'Total Open Issues'
            }
        },
        legend: {
            enabled: false
        },
        plotOptions: {
            series: {
                borderWidth: 0,
                dataLabels: {
                    enabled: true,
                    format: '{point.y}'
                }
            }, column: {
                maxPointWidth: 100
            }
        },

        tooltip: {
            headerFormat: '<span style="font-size:0.7387508394895903vw">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b>'
        },

        series: currentSonarMainChartData,

        exporting: {
            enabled: true
        }
    });

}

function createIssueTypeChart(){
    this.issueIssuetypeChart = Highcharts.chart('issuetype-chart-container', {
        chart: {
            type: 'pie'
        },
        credits: {
            enabled: false
        },
        title: {
            text: currentIssueIssueTypeChartTitle
        },
        legend: {
            itemWidth: 150
        },
        plotOptions: {
            pie: {
                allowPointSelect: false,
                slicedOffset: 30,
                dataLabels: {
                    enabled: true,
                    format: '{point.y}',
                    distance: 5
                },
                showInLegend: true,
            }
        },
        tooltip: {
            headerFormat: '<span style="font-size:0.7387508394895903vw">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b><br/>'
        },

        series: currentIssueIssueTypeChartData,
        exporting: {
            enabled: true
        }

    });
}

function createSonarIssueTypeChart(){
    this.sonarIssuetypeChart = Highcharts.chart('issuetype-chart-container-sonar', {
        chart: {
            type: 'pie'
        },
        credits: {
            enabled: false
        },
        title: {
            text: currentSonarIssueTypeChartTitle
        },
        legend: {
           itemWidth: 150
        },
        plotOptions: {
            pie: {
                allowPointSelect: false,
                slicedOffset: 30,
                dataLabels: {
                    enabled: true,
                    format: '{point.y}',
                    distance: 5
                },
                showInLegend: true,
            }
        },
        tooltip: {
            headerFormat: '<span style="font-size:0.7387508394895903vw">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b><br/>'
        },

        series: currentSonarIssueTypeChartData,
        exporting: {
            enabled: true
        }

    });
}


function createSeverityChart(){
     this.issueSeverityChart = Highcharts.chart('severity-chart-container', {
        chart: {
            type: 'pie'
        },
        credits: {
            enabled: false
        },
        legend: {
            itemWidth: 150
        },
        title: {
            text: currentIssueSeverityChartTitle
        },
        plotOptions: {
            pie: {
                allowPointSelect: false,
                slicedOffset: 30,
                dataLabels: {
                    enabled: true,
                    format: '{point.y}',
                    distance: 5
                },
                showInLegend: true
            }
        },
        tooltip: {
            headerFormat: '<span style="font-size:0.7387508394895903vw">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b><br/>'
        },

        series: currentIssueSeverityChartData,
        exporting: {
            enabled: true
        }

    });
}

function createSonarSeverityChart(){
    this.sonarSeverityChart = Highcharts.chart('severity-chart-container-sonar', {
        chart: {
            type: 'pie'
        },
        credits: {
            enabled: false
        },
        legend: {
            itemWidth: 150
        },
        title: {
            text: currentSonarSeverityChartTitle
        },
        plotOptions: {
            pie: {
                allowPointSelect: false,
                slicedOffset: 30,
                dataLabels: {
                    enabled: true,
                    format: '{point.y}',
                    distance: 5
                },
                showInLegend: true
            }
        },

        tooltip: {
            headerFormat: '<span style="font-size:0.7387508394895903vw">{series.name}</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b><br/>'
        },

        series: currentSonarSeverityChartData,
        exporting: {
            enabled: true
        }

    });
}

function getIssueTrendLineHistory(period) {
    
    var history;
    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/github/issues/history/'+ currentCategory + '/' + currentCategoryId,
        data:{
            severityId: currentIssueSeverity,
            issuetypeId: currentIssueIssueType,
            dateFrom : this.startDate,
            dateTo : this.endDate,
            period: period
        },
        async: false,
        success: function(data){
           history = data.data;
        }
    });
    
    historySeriesData = [];

    for(var i = 0; i < history.length; i++){
        name = history[i].date;
        y = history[i].count;
        historySeriesData.push({name: name, y: y});
    }
    
    createIssueTrendChart(historySeriesData);
}

function getSonarTrendLineHistory(period) {
    
    var history;
    $.ajax({
        type: "GET",
        url: baseUrl+'internal/product-quality/v1.0/sonar/issues/history/'+ currentCategory + '/' + currentCategoryId,
        data:{
            issuetypeId: currentSonarIssueType,
            severityId: currentSonarSeverity,
            dateFrom : this.startDate,
            dateTo : this.endDate,
            period: period
        },
        async: false,
        success: function(data){
            history = data.data;
        }
    });
    
    historySeriesData = [];

    for(var i = 0; i < history.length; i++){
        time = history[i].date.split("+");
        name = time[0];
        y = history[i].count;
        historySeriesData.push({name: name, y: y});
    }
    
    createSonarTrendChart(historySeriesData);

}


function createIssueTrendChart(data){
    
    Highcharts.chart('trend-chart-container', {
        chart: {
            zoomType: 'x'
        },
        legend: {
            enabled: false
        },
        title: {
            text: ""
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'Number of Issues'
            }
        },
        credits: {
            enabled: false
        },
        plotOptions: {
            series: {
                borderWidth: 0,
                dataLabels: {
                    enabled: true,
                    format: '{point.y}'
                }
            }
        },
        tooltip: {
            headerFormat: '<span style="font-size:0.7387508394895903vw">Issues</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b><br/>'
        },
        series: [{
            type: 'line',
            data: data
        }]

    });

}

function createSonarTrendChart(data){
    
    Highcharts.chart('trend-chart-container-sonar', {
        chart: {
            zoomType: 'x'
        },
        title: {
            text: ""
        },
        credits: {
            enabled: false
        },
        legend: {
                enabled: false
        },
        xAxis: {
            type: 'category'
        },
        yAxis: {
            title: {
                text: 'Number of Issues'
            }
        },
        plotOptions: {
            series: {
                borderWidth: 0,
                dataLabels: {
                    enabled: true,
                    format: '{point.y}'
                }
            }
        },
        tooltip: {
            headerFormat: '<span style="font-size:0.7387508394895903vw">Sonar</span><br>',
            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b><br/>'
        },
        series: [{
            type: 'line',
            data: data
        }]

    });

}

function setIssueDate(start, end) {
    issueStartDate = start;
    issueEndDate = end;
    issueHistoryTitle =  startDate + " - " + endDate;
}

function setSonarDate(start, end) {
    sonarStartDate = start;
    sonarEndDate = end;
    sonarHistoryTitle =  startDate + " - " + endDate;
}






