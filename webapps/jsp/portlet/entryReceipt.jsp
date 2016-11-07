<%@ taglib uri="webwork" prefix="ww" %>
<%@ taglib uri="http://java.sun.com/portlet" prefix="portlet"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="calendar" prefix="calendar" %>

<portlet:defineObjects/>

<c:set var="activeNavItem" value="Home" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<ww:set name="eventId" value="eventId" scope="page"/>
<portlet:renderURL var="eventUrl">
	<portlet:param name="action" value="ViewEvent"/>
	<portlet:param name="eventId" value='<%= pageContext.getAttribute("eventId").toString() %>'/>
</portlet:renderURL>

<div class="mainCol">
    <div class="portlet_margin no-subfunctionarea">
        <h1>
            <ww:property value="this.getLabel('labels.internal.entry.createNewEntryThankYou')"/>
		</h1>
        <p>
            <ww:property value="this.getLabel('labels.internal.entry.createNewEntryThankYouText')"/>
		</p>
        </p>
            <a href="<c:out value="${eventUrl}"/>"><ww:property value="this.getLabel('labels.internal.event.eventSubmittedHome')"/></a>	
        </p>
    </div>
</div>

<%@ include file="adminFooter.jsp" %>