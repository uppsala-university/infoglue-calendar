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

			<ww:set name="pushUrl" value="this.getLabel('labels.internal.searchIndex.indexToPushUrl')" scope="page"/>
			<ww:set name="eventPageUrl" value="this.getLabel('labels.internal.searchIndex.eventPageUrl')" scope="page"/>
			<%-- This part tries to push the event to the search index, the parameters are stored in labels --%>
			<% 		
				IndexDocument doc = new IndexDocument();
				StringBuilder sb = new StringBuilder();
				String eventId = (String) request.getParameter("eventId");
				String pushUrl = (String) pageContext.getAttribute("pushUrl");
				String eventPageUrl = (String) pageContext.getAttribute("eventPageUrl");
				IndexReply iReply = null;
				if (pushUrl == null || pushUrl.equalsIgnoreCase("")) {
					pushUrl = "http://inquisitor.its.uu.se:8080/is/rest/uu_web/documents";
				}
				if (eventPageUrl == null || eventPageUrl.equalsIgnoreCase("")) {
					eventPageUrl = "http://kalendarium.uu.se/Evenemang?eventId=";
				}
				if (eventId != null && !eventId.equalsIgnoreCase("")) {
					String url = eventPageUrl + eventId;
						
					doc.setTitle(url);
					doc.setUrl(url);
					doc.setContent(url);
					HttpClientIndexer indexer = new HttpClientIndexer(pushUrl);
					/*Sending the actual document to the service*/
					iReply = indexer.indexDocument(doc);
				}

				if(iReply.isReplyOK()) {
				%>
					<h1><ww:property value="this.getLabel('labels.internal.event.eventPublishedText')"/></h1>
					<p>
						<a href="<c:out value="${homeActionUrl}"/>"><ww:property value="this.getLabel('labels.internal.event.eventSubmittedHome')"/></a>	
						<ww:set name="eventId" value="eventId" scope="page"/>
					</p>
				<%
				} else {
				%>
					<h1><ww:property value="this.getLabel('labels.internal.searchIndex.indexFailed')"/><%= eventId %></h1>
					<p>
						<a href="<c:out value="${homeActionUrl}"/>"><ww:property value="this.getLabel('labels.internal.event.eventSubmittedHome')"/></a>
					</p>
				<%
				}
			%>
    </div>
</div>

<%@ include file="adminFooter.jsp" %>
