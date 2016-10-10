<%@ taglib uri="webwork" prefix="ww" %>
<%@ taglib uri="http://java.sun.com/portlet" prefix="portlet"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="calendar" prefix="calendar" %>

<portlet:defineObjects/>

<!DOCTYPE html>
	<html lang="sv">

		<head>
			<title><ww:property value="this.getLabel('labels.internal.applicationTitle')"/></title>
			<meta charset="utf-8">
			<ww:if test="CSSUrl != null">
				<style type="text/css" media="screen">@import url(<ww:property value="CSSUrl"/>);</style>
			</ww:if>
			<ww:else>
				<style type="text/css" media="screen">@import url(/infoglueCalendar/css/calendarPortlet.css);</style>
			</ww:else>
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			
			<link rel="stylesheet" type="text/css" media="all" href="<%=request.getContextPath()%>/applications/jscalendar/skins/aqua/theme.css" title="aqua" />
			<link rel="stylesheet" type="text/css" media="all" href="<%=request.getContextPath()%>/applications/jscalendar/calendar-system.css" title="system" />

			<script type="text/javascript" src="<%=request.getContextPath()%>/script/dom-drag.js"></script>
			<script type="text/javascript" src="<%=request.getContextPath()%>/script/infoglueCalendar.js"></script>
			<script type="text/javascript" src="<%=request.getContextPath()%>/applications/ckeditor/ckeditor.js"></script>
			
			<script type="text/javascript">
			
				function linkEvent(calendarId)
				{
					document.getElementById("calendarId").value = calendarId;
					document.linkForm.submit();
				}
			
				function createEventFromCopy(action)
				{
					document.updateForm.action = action;
					document.updateForm.submit();
				} 

				function deleteResource(resourceId)
				{
					document.deleteResourceForm.resourceId.value = resourceId;
					document.deleteResourceForm.submit();
				} 
			
				function includeScript(url)
				{
				  document.write('<script type="text/javascript" src="' + url + '"></scr' + 'ipt>'); 
				}

			</script>

		</head>

	<body>

		<script type="text/javascript">
			//alert("Calendar:" + typeof(Calendar));
			if(typeof(Calendar) == 'undefined')
			{
				//alert("No calendar found - let's include it..");
				includeScript("<%=request.getContextPath()%>/applications/jscalendar/calendar.js");
				includeScript("<%=request.getContextPath()%>/applications/jscalendar/lang/calendar-en.js");
				includeScript("<%=request.getContextPath()%>/applications/jscalendar/calendar-setup.js");
			}
		</script>

		<div class="calApp">

			<div class="portlet">

				<portlet:renderURL var="viewCalendarAdministrationUrl">
					<portlet:param name="action" value="ViewCalendarAdministration"/>
				</portlet:renderURL>

				<header class="clearfix">
					<div class="header-content">
						<a href="<c:out value='${viewCalendarAdministrationUrl}'/>" class="left header-content-logo">
							<ww:property value="this.getLabel('labels.internal.header.heading')"/>
						</a>
						<span class="header-content-login right">	
							<ww:property value="this.getParameterizedLabel('labels.internal.header.loggedinUser', this.getPrincipalDisplayName())"/>
							|
							<a href="<ww:property value="logoutUrl"/>"><ww:property value="this.getLabel('labels.internal.header.logout')"/></a>
							<%--
							Request: <c:out value="${request.remoteUser}"/><br/>
							Request: <c:out value="${request.remoteHost}"/><br/>
							<%=request.getContextPath()%><br/>
							Host: <%=request.getRemoteHost()%><br/>
							Class: <%=request.getClass().getName()%><br/>
							Host: <%=request.getRemoteHost()%><br/>
							<%=request.getRemoteUser()%><br/>
							<%=request.isUserInRole("admin")%><br/>
							<%=request.isUserInRole("cmsUser")%><br/>
							<%=request.getUserPrincipal().toString()%><br/>
							RemoteUser: <ww:property value="this.getRequestClass()"/><br/>
							--%>
						</span>
					</div>
				</header>
