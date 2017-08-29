<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Home" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<%@ include file="eventSubFunctionMenu.jsp" %>

<portlet:renderURL var="homeActionUrl">
	<portlet:param name="action" value="ViewCalendarAdministration"/>
</portlet:renderURL>

<portlet:renderURL var="createNewEventActionUrl">
	<portlet:param name="action" value="ViewCalendarList!choose"/>
</portlet:renderURL>

<portlet:renderURL var="viewWaitingEventListActionUrl">
	<portlet:param name="action" value="ViewWaitingEventList"/>
</portlet:renderURL>

<div class="mainCol">
    <div class="portlet_margin no-subfunctionarea">
        <h1><ww:property value="this.getLabel('labels.internal.event.eventSubmitted')"/></h1>
        <p><ww:property value="this.getLabel('labels.internal.event.eventSubmittedText')"/></p>
        <p>
           <ww:property value="this.getLabel('labels.internal.event.eventOwnerText')"/>
           <a href="<c:out value='${viewWaitingEventListActionUrl}'/>"><ww:property value="this.getLabel('labels.internal.myWorkingEvents.subHeader')"/></a>.
        </p>
        <ul class="linkList" >
            <li class="link1"><a href="<c:out value="${createNewEventActionUrl}"/>"><ww:property value="this.getLabel('labels.internal.event.addEvent')"/></a></li>
            <li class="link2"><a href="<ww:property value="t	his.getLabel('labels.internal.event.eventSubmittedUULink')"/>"><ww:property value="this.getLabel('labels.internal.event.eventSubmittedUUStart')"/></a></li>
            <li class="link3"><a href="<c:out value="${homeActionUrl}"/>"><ww:property value="this.getLabel('labels.internal.event.eventSubmittedHome')"/></a></li>
        </ul>
    </div>
</div>

<%@ include file="adminFooter.jsp" %>
