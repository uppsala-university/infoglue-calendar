<portlet:renderURL var="createEventUrl">
	<portlet:param name="action" value="ViewCalendarList!choose"/>
</portlet:renderURL>
<portlet:renderURL var="viewLinkedPublishedEventsUrl">
	<portlet:param name="action" value="ViewLinkedPublishedEventList"/>
</portlet:renderURL>
<portlet:renderURL var="viewPublishedEventsUrl">
	<portlet:param name="action" value="ViewPublishedEventList"/>
</portlet:renderURL>
<portlet:renderURL var="viewWaitingEventsUrl">
	<portlet:param name="action" value="ViewWaitingEventList"/>
</portlet:renderURL>
<portlet:renderURL var="viewEventSubscriptionListUrl">
	<portlet:param name="action" value="ViewEventSubscriptionList"/>
</portlet:renderURL>
<portlet:renderURL var="viewEventSearchFormUrl">
	<portlet:param name="action" value="ViewEventSearch!input"/>
</portlet:renderURL>
	
<div class="subfunctionarea leftCol">
	
	<calendar:hasRole id="calendarAdministrator" roleName="CalendarAdministrator"/>
	<calendar:hasRole id="calendarOwner" roleName="CalendarOwner"/>
	<calendar:hasRole id="eventPublisher" roleName="EventPublisher"/>

    <ul class="subMenu">

        <li class="first">	
    		<a href="<c:out value="${viewEventsUrl}"/>" <c:if test="${activeNavItem == 'Events'}">class="current"</c:if>><ww:property value="this.getLabel('labels.internal.applicationHome')"/></a>    
		</li>    

        <li>	
        <a id="newEventLink" href="<c:out value="${createEventUrl}"/>" <c:if test="${activeEventSubNavItem == 'NewEvent'}">class="current"</c:if>><ww:property value="this.getLabel('labels.internal.event.addEvent')"/></a> 
        </li>

        <c:if test="${calendarOwner == true}">    
            <li>
                <a href="<c:out value="${viewLinkedPublishedEventsUrl}"/>" <c:if test="${activeEventSubNavItem == 'LinkedPublishedEvents'}">class="current"</c:if>><ww:property value="this.getLabel('labels.internal.applicationLinkedPublishedEvents')"/></a>
            </li>
    
            <li>
                <a href="<c:out value="${viewPublishedEventsUrl}"/>" <c:if test="${activeEventSubNavItem == 'PublishedEvents'}">class="current"</c:if>><ww:property value="this.getLabel('labels.internal.applicationPublishedComingEvents')"/></a>
            </li>
    
            <li>
                <a href="<c:out value="${viewWaitingEventsUrl}"/>" <c:if test="${activeEventSubNavItem == 'WaitingEvents'}">class="current"</c:if>><ww:property value="this.getLabel('labels.internal.applicationWaitingEvents')"/></a>
            </li>
        </c:if>

        <li>
        <a href="<c:out value="${viewMyWorkingEventsUrl}"/>" <c:if test="${activeEventSubNavItem == 'MyWorkingEvents'}">class="current"</c:if>><ww:property value="this.getLabel('labels.internal.applicationMyWorkingEvents')"/></a>
        </li>

        <c:if test="${calendarOwner == true}">
            <li>
                <a href="<c:out value="${viewEntrySearchUrl}"/>" <c:if test="${activeEventSubNavItem == 'EntrySearch'}">class="current"</c:if>><ww:property value="this.getLabel('labels.internal.applicationSearchEntries')"/></a>
            </li>
            <li>
                <a href="<c:out value="${viewEventSubscriptionListUrl}"/>" <c:if test="${activeEventSubNavItem == 'EventSubscriptions'}">class="current"</c:if>><ww:property value="this.getLabel('labels.internal.applicationEventSubscriptions')"/></a>
            </li>
            <li>
                <a href="<c:out value="${viewEventSearchFormUrl}"/>" <c:if test="${activeEventSubNavItem == 'EventSearch'}">class="current"</c:if>><ww:property value="this.getLabel('labels.internal.applicationSearchEvents')"/></a>
            </li>
        </c:if>	
    </ul>
</div>