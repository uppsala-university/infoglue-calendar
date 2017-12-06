<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page import="javax.portlet.PortletURL,
				 java.util.Map,
				 java.util.Iterator,
				 java.util.List,java.lang.String"%>
<%@ page import="se.uu.its.search.client.IndexReply, se.uu.its.search.client.IndexDocument , se.uu.its.search.client.httpclient.HttpClientIndexer"%>

<c:set var="activeNavItem" value="Home" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<portlet:renderURL var="homeActionUrl">
	<portlet:param name="action" value="ViewCalendarAdministration"/>
</portlet:renderURL>

<div class="mainCol">
    <div class="portlet_margin no-subfunctionarea">
		<h1><ww:property value="this.getLabel('labels.internal.event.eventPublishedText')"/></h1>
		<p>
			<a href="<c:out value="${homeActionUrl}"/>"><ww:property value="this.getLabel('labels.internal.event.eventSubmittedHome')"/></a>	
			<ww:set name="eventId" value="eventId" scope="page"/>
		</p>
    </div>
</div>

<%@ include file="adminFooter.jsp" %>
