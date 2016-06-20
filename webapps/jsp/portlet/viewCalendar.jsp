<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Calendars" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<ww:set name="calendarId" value="calendar.id" scope="page"/>

<portlet:renderURL var="viewSubscriptionsUrl">
	<portlet:param name="action" value="ViewSubscriptionList"/>
	<portlet:param name="calendarId" value='<%= pageContext.getAttribute("calendarId").toString() %>'/>
</portlet:renderURL>

<div class="subfunctionarea leftCol">
    <span class="left"></span>	
    <span class="right">
        <a href="<c:out value="${viewSubscriptionsUrl}"/>" title="Skapa ny post"><ww:property value="this.getLabel('labels.internal.calendar.viewSubscriptions')"/></a>
    </span>	
    <div class="clear"></div>
</div>

<div class="mainCol">
    <div class="portlet_margin">
	<ww:set name="owningRoles" value="calendar.owningRoles"/>


        <portlet:actionURL var="updateCalendarActionUrl">
            <portlet:param name="action" value="UpdateCalendar"/>
        </portlet:actionURL>
   
        <portlet:renderURL var="viewCalendarUrl">
            <portlet:param name="action" value="ViewCalendar!gui"/>
            <portlet:param name="calendarId" value='<%= pageContext.getAttribute("calendarId").toString() %>'/>
            <portlet:param name="mode" value="day"/>
        </portlet:renderURL>
                
        <form name="inputForm" method="POST" action="<c:out value="${updateCalendarActionUrl}"/>">
            <input type="hidden" name="calendarId" value="<ww:property value="calendar.id"/>">
            
            <calendar:textField label="labels.internal.calendar.name" name="'name'" value="calendar.name" cssClass="longtextfield"/>
            <calendar:textField label="labels.internal.calendar.description" name="'description'" value="calendar.description" cssClass="longtextfield"/>
            <%--<calendar:selectField label="labels.internal.calendar.owner" name="owner" multiple="false" value="infogluePrincipals" selectedValue="calendar.owner" cssClass="listBox"/>--%>
            
            <ww:set name="owningRoles" value="calendar.owningRoles"/>
            <ww:set name="owningGroups" value="calendar.owningGroups"/>
                
            <calendar:selectField label="labels.internal.calendar.roles" name="roles" multiple="true" value="infoglueRoles" selectedValueSet="#owningRoles" cssClass="listBox"/>
            <calendar:selectField label="labels.internal.calendar.groups" name="groups" multiple="true" value="infoglueGroups" selectedValueSet="#owningGroups" cssClass="listBox"/>
           
            <calendar:selectField label="labels.internal.calendar.eventType" name="'eventTypeId'" multiple="false" value="eventTypes" selectedValue="calendar.eventType.id" cssClass="listBox"/>

            <div style="height:10px"></div>
            <input type="submit" value="<ww:property value="this.getLabel('labels.internal.calendar.updateButton')"/>" class="button">
            <input type="button" onclick="history.back();" value="<ww:property value="this.getLabel('labels.internal.applicationCancel')"/>" class="button">
            
        </form>

		<h2><ww:property value="this.getLabel('labels.internal.calendar.eventsWithStatus')"/> <ww:property value="this.getLabel('labels.state.published')"/></h2>
		<table width="65%">
			<th><ww:property value="this.getLabel('labels.internal.calendar.name')"/></th><th><ww:property value="this.getLabel('labels.internal.calendar.id')"/></th>
			<ww:iterator value="allCurrentAndComingPublishedEventVersionList">
				<ww:set name="eventId" value="top.event.id" scope="page"/>
				
				<portlet:renderURL var="eventUrl">
					<portlet:param name="action" value="ViewEvent"/>
					<portlet:param name="eventId" value='<%= pageContext.getAttribute("eventId").toString() %>'/>
				</portlet:renderURL>
				<tr>
					<td><a href="<c:out value="${eventUrl}"/>"><ww:property value="top.name"/></a></td>
	
					
					<td><ww:property value="top.id"/></td>
				</tr>
			</ww:iterator>
		</table>
		<h2><ww:property value="this.getLabel('labels.internal.calendar.eventsWithStatus')"/>  <ww:property value="this.getLabel('labels.state.publish')"/></h2>
		<table width="65%">
			<th><ww:property value="this.getLabel('labels.internal.calendar.name')"/> </th><th><ww:property value="this.getLabel('labels.internal.calendar.id')"/></th>
			<ww:iterator value="allCurrentAndComingPublishEventVersionList">
				<ww:set name="eventId" value="top.event.id" scope="page"/>
				
				<portlet:renderURL var="eventUrl">
					<portlet:param name="action" value="ViewEvent"/>
					<portlet:param name="eventId" value='<%= pageContext.getAttribute("eventId").toString() %>'/>
				</portlet:renderURL>
				<tr>
					<td><a href="<c:out value="${eventUrl}"/>"><ww:property value="top.name"/></a></td>

					<td><ww:property value="top.id"/></td>
				</tr>
			</ww:iterator>
		</table>
		<h2><ww:property value="this.getLabel('labels.internal.calendar.eventsWithStatus')"/>  <ww:property value="this.getLabel('labels.state.working')"/></h2>
		<table width="65%">
			<th><ww:property value="this.getLabel('labels.internal.calendar.name')"/> </th><th><ww:property value="this.getLabel('labels.internal.calendar.id')"/></th>
			<ww:iterator value="allCurrentAndComingWorkingEventVersionList">
				<ww:set name="eventId" value="top.event.id" scope="page"/>
				
				<portlet:renderURL var="eventUrl">
					<portlet:param name="action" value="ViewEvent"/>
					<portlet:param name="eventId" value='<%= pageContext.getAttribute("eventId").toString() %>'/>
				</portlet:renderURL>
				<tr>
					<td><a href="<c:out value="${eventUrl}"/>"><ww:property value="top.name"/></a></td>

					<td><ww:property value="top.id"/></td>
				</tr>
			</ww:iterator>
		</table>
    <%--	
        <portlet:renderURL var="accessRightsActionUrl">
            <portlet:param name="action" value="ViewAccessRights"/>
            <portlet:param name="interceptionPointCategory" value="Calendar"/>
            <portlet:param name="extraParameters" value='<%= pageContext.getAttribute("calendarId").toString() %>'/>
        </portlet:renderURL>
        
        <a href="<c:out value="${accessRightsActionUrl}"/>">Access rights</a>
    --%>
        
    </div>
</div>
<div style="clear:both"></div>

<%@ include file="adminFooter.jsp" %>