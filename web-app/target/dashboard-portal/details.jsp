<%--Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.--%>

<%--WSO2 Inc. licenses this file to you under the Apache License,--%>
<%--Version 2.0 (the "License"); you may not use this file except--%>
<%--in compliance with the License.--%>
<%--You may obtain a copy of the License at--%>

<%--http://www.apache.org/licenses/LICENSE-2.0--%>

<%--Unless required by applicable law or agreed to in writing,--%>
<%--software distributed under the License is distributed on an--%>
<%--"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY--%>
<%--KIND, either express or implied. See the License for the--%>
<%--specific language governing permissions and limitations--%>
<%--under the License.--%>


<%@page import="org.apache.http.HttpResponse" %>
<%@page import="org.apache.http.client.methods.HttpPost" %>
<%@ page import="org.apache.http.conn.ssl.SSLConnectionSocketFactory" %>
<%@ page import="org.apache.http.conn.ssl.SSLContextBuilder" %>
<%@ page import="org.apache.http.conn.ssl.TrustSelfSignedStrategy" %>
<%@ page import="org.apache.http.entity.ContentType" %>
<%@ page import="org.apache.http.entity.StringEntity" %>
<%@ page import="org.apache.http.impl.client.CloseableHttpClient" %>
<%@ page import="org.apache.http.impl.client.HttpClients" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.net.URI" %>
<%@ page import="java.net.URISyntaxException" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.util.Date" %>
<%@include file="includes/authenticate.jsp" %>
<%
    String deviceType="weatherstation";
    String id = request.getParameter("id");
    if (id == null) {
        //  response.sendRedirect("devices.jsp");
        return;
    }

    String cookie = request.getHeader("Cookie");

    URI invokerURI = null;
    try {
        invokerURI = new URL(request.getScheme(),
                request.getServerName(),
                request.getServerPort(), request.getContextPath() + "/invoker/execute").toURI();
    } catch (URISyntaxException e) {
        e.printStackTrace();
    }
    HttpPost invokerEndpoint = new HttpPost(invokerURI);
    invokerEndpoint.setHeader("Cookie", cookie);

    StringEntity entity = new StringEntity("uri=/devices/"+deviceType+"/" + id + "&method=get",
            ContentType.APPLICATION_FORM_URLENCODED);
    invokerEndpoint.setEntity(entity);

    SSLContextBuilder builder = new SSLContextBuilder();
    try {
        builder.loadTrustMaterial(null, new TrustSelfSignedStrategy());
    } catch (Exception e) {
        e.printStackTrace();
    }
    SSLConnectionSocketFactory sslsf = null;
    try {
        sslsf = new SSLConnectionSocketFactory(builder.build());
    } catch (Exception e) {
        e.printStackTrace();
    }

    CloseableHttpClient client = HttpClients.custom().setSSLSocketFactory(
            sslsf).build();
    HttpResponse invokerResponse = client.execute(invokerEndpoint);

    if (invokerResponse.getStatusLine().getStatusCode() == 401) {
        return;
    }

    BufferedReader rd = new BufferedReader(new InputStreamReader(invokerResponse.getEntity().getContent()));

    StringBuilder result = new StringBuilder();
    String line;
    while ((line = rd.readLine()) != null) {
        result.append(line);
    }

    JSONObject device = new JSONObject(result.toString());
    JSONObject enrolmentInfo = device.getJSONObject("enrolmentInfo");
    JSONObject lat = (JSONObject) device.getJSONArray("properties").get(0);
    JSONObject lon = (JSONObject) device.getJSONArray("properties").get(1);

%>

<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <title>Dashboard</title>
    <meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0' name='viewport'/>
    <meta name="viewport" content="width=device-width"/>
    <!-- Bootstrap core CSS     -->
    <link href="css/bootstrap.min.css" rel="stylesheet"/>
    <!--  Material Dashboard CSS    -->
    <link href="css/material-dashboard.css?v=1.2.0" rel="stylesheet"/>
    <!-- For the date range picker in hisorical tab     -->
    <link href="css/daterangepicker.css" rel="stylesheet"/>
    <!--     Fonts and icons     -->
    <link href="http://maxcdn.bootstrapcdn.com/font-awesome/latest/css/font-awesome.min.css" rel="stylesheet">
    <link href='http://fonts.googleapis.com/css?family=Roboto:400,700,300|Material+Icons' rel='stylesheet'
          type='text/css'>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.2.0/dist/leaflet.css"
          integrity="sha512-M2wvCLH6DSRazYeZRIm1JnYyh22purTM+FDB5CsyxtQJYeKq83arPe5wgbNmcFXGqiSH2XR8dT/fJISVA1r/zQ=="
          crossorigin=""/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="css/updates.css" rel="stylesheet"/>

    <link href="css/simple-sidebar.css" rel="stylesheet">
</head>

<body>
<div id="wrapper" class="toggled">
    <div id="sidebar-wrapper" class="sidebar" data-color="purple" data-image="images/sidebar-1.jpg">
        <!--
    Tip 1: You can change the color of the sidebar using: data-color="purple | blue | green | orange | red"

    Tip 2: you can also add an image using data-image tag
-->
        <div class="logo list-inline">
            <a href="./devices.jsp" class="simple-text">
                <strong>Device</strong>Portal
            </a>
        </div>
        <div class="sidebar-wrapper">

            <ul class="nav">
                <li class="active" id="realtimeTab">
                    <a href="#realtime" data-toggle="tab">
                        <i class="material-icons">access_alarms</i> Realtime
                        <div class="ripple-container"></div>
                    </a>
                </li>
                <li class="" id="historicalTab">
                    <a href="#historical" data-toggle="tab">
                        <i class="material-icons">history</i> Historical
                        <div class="ripple-container"></div>
                    </a>
                </li>
            </ul>
            <%@ include file="pages/details-page-Segments/deviceDetailsCard.jsp" %>
            <%@ include file="pages/details-page-Segments/mapSegment.jsp" %>

            <div style=" margin-top: 120px; margin-left: 100px;">
                <%@ include file="pages/details-page-Segments/footerWSO2.jsp" %>
            </div>
        </div>


    </div>
    <div id="page-content-wrapper" class="main-panel" style="padding-top: 2px;">
        <%@ include file="pages/details-page-Segments/navBar.jsp" %>

        <div class="content" style="padding-top: 2px;">
            <div id="daterangebar" style="margin-left:35%;margin-top: -4px">
                <div class="menubutton">
                    <h4 style="margin-top: -4px"><strong id="dateR" style=" font-size: 20px;">Date-range</strong></h4>
                </div>
                <div class="menubutton" style="width: 440px;margin-top: -4px;">
                    <h4><input type="text" name="dateRange" id="dateRange" style="padding-left: 15px; font-size: 20px;"
                               value="01/01/2018 1:30 PM - 01/01/2018 2:00 PM"
                               class="form-control"/></h4></div>

            </div>
            <div class="container-fluid">
                <div class="tab-content">
                    <div id="realtime" class="tab-pane fade in active">
                        <%@ include file="pages/details-page-Segments/realTimeCardSegment.jsp" %>
                        <%@ include file="pages/details-page-Segments/realTimeChartSegment.jsp" %>
                    </div>
                    <div id="historical" class="tab-pane fade">
                        <%@ include file="pages/details-page-Segments/historicalChartsegment.jsp" %>
                    </div>


                </div>
            </div>
        </div>


    </div>
</div>
</body>
<!--   Core JS Files   -->
<script src="js/jquery-3.2.1.min.js" type="text/javascript"></script>
<script src="js/bootstrap.min.js" type="text/javascript"></script>
<script src="js/material.min.js" type="text/javascript"></script>
<!--  Charts Plugin -->
<script src="js/chartist.min.js"></script>
<!--  Dynamic Elements plugin -->
<script src="js/arrive.min.js"></script>
<!--  PerfectScrollbar Library -->
<script src="js/perfect-scrollbar.jquery.min.js"></script>
<!--  Notifications Plugin    -->
<script src="js/bootstrap-notify.js"></script>
<!-- Material Dashboard javascript methods -->
<script src="js/material-dashboard.js?v=1.2.0"></script>
<script src="js/realtime-analytics.js"></script>
<script src="js/bootstrap-datepicker.js" type="text/javascript"></script>
<script src="js/moment.min.js" type="text/javascript"></script>
<script src="js/daterangepicker.js" type="text/javascript"></script>
<script src="js/historical-analytics.js"></script>
<script src="pages/details-page-scripts/functions.js"></script>
<script src="pages/details-page-scripts/cssFunctions.js"></script>
<script type="text/javascript">
    var deviceType="weatherstation";
    var lastKnown = {};

    $(document).ready(function () {
        $(document).ready(function () {
            var wsStatsEndpoint = "<%=pageContext.getServletContext().getInitParameter("websocketEndpoint")%>/secured-websocket/iot.per.device.stream.carbon.super."+deviceType+"/1.0.0?"
                + "deviceId=<%=id%>&deviceType="+deviceType+"&websocketToken=<%=request.getSession(false).getAttribute(LoginController.ATTR_ACCESS_TOKEN)%>";
            realtimeGraphRefresh(wsStatsEndpoint);

            var wsAlertEndpoint = "<%=pageContext.getServletContext().getInitParameter("websocketEndpoint")%>/secured-websocket/iot.per.device.stream.carbon.super."+deviceType+".alert/1.0.0?"
                + "deviceId=<%=id%>&deviceType="+deviceType+"&websocketToken=<%=request.getSession(false).getAttribute(LoginController.ATTR_ACCESS_TOKEN)%>";
            displayAlerts(wsAlertEndpoint);
        });
    });

    //set device card details
    document.getElementById("devName").innerHTML = "<%=device.getString("name")%>";
    document.getElementById("devDetails").innerHTML = "Owned by " + "<%=enrolmentInfo.getString("owner")%>" + " and enrolled on " + "<%=new Date(enrolmentInfo.getLong("dateOfEnrolment")).toString()%>";

    //refresh graphs on click
    document.getElementById("realtimeTab").addEventListener("click", realtimeGraphRefresh());
    document.getElementById("historicalTab").addEventListener("click", historyGraphRefresh);

    //fix the issue of charts not rendering in historical tab
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        $(e.currentTarget.hash).find('.ct-chart').each(function (el, tab) {
            tab.__chartist__.update();
        });
    });


    var lastKnownSuccess = function (data) {
        var record = JSON.parse(data).records[0];

        if (record) {
            lastKnown = record;
            var sinceText = timeDifference(new Date(), new Date(record.timestamp), false) + " ago";
            var temperature = record.values.tempf;
            temperature = ((temperature - 32) * 5) / 9;
            var humidity = record.values.humidity;
            var windDir = record.values.winddir;
            var windSpeed = record.values.windspeedmph;
            updateStatusCards(sinceText, temperature, humidity, windDir, windSpeed);
        } else {
            //temperature status
            $("#temperature").html("Unknown");
            $("#temperature_status_alert").parent().remove();

            //humidity status
            $("#humidity").html("Unknown");
            $("#humidity_status_alert").parent().remove();

            //wind direction status
            $("#wind_status").html("Unknown");
            $("#wind_status_alert").parent().remove();

            //wind speeed status
            $("#windspeed_status").html("Unknown");
            $("#windspeed_status_alert").parent().remove();
        }
    };
    $.ajax({
        type: "POST",
        url: "invoker/execute",
        data: {
            "uri": "/events/last-known/"+deviceType+"/<%=id%>",
            "method": "get"
        },
        success: lastKnownSuccess
    });

    $(function () {
        $('#dateRange').daterangepicker({
            timePicker: true,
            timePickerIncrement: 30,
            locale: {
                format: 'DD/MM/YYYY h:mm A'
            },
            ranges: {
                'Today': [moment().startOf('day'), moment()],
                'Yesterday': [moment().subtract(1, 'days').startOf('day'),
                    moment().subtract(1, 'days').endOf('day')],
                'Last 7 Days': [moment().subtract(6, 'days'), moment()],
                'Last 30 Days': [moment().subtract(29, 'days'), moment()],
                'This Month': [moment().startOf('month'), moment().endOf('month')],
                'Last Month': [moment().subtract(1, 'month').startOf('month'),
                    moment().subtract(1, 'month').endOf('month')]
            }
        }, datePickerCallback);

    });

    function datePickerCallback(startD, endD) {
        var eventsSuccess = function (data) {
            var records = JSON.parse(data);
            analyticsHistory.redrawGraphs(records);
        };

        var index = 0;
        var length = 50;

        $.ajax({
            type: "POST",
            url: "invoker/execute",
            data: {
                "uri": "/events/"+deviceType+"/<%=id%>?offset=" + index + "&limit=" + length + "&from=" + new Date(
                    startD.format('YYYY-MM-DD H:mm:ss')).getTime() + "&to=" + new Date(
                    endD.format('YYYY-MM-DD H:mm:ss')).getTime(),
                "method": "get"
            },
            success: eventsSuccess
        });
    }

</script>

</html>