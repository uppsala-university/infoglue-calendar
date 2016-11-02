<%@page import="java.text.MessageFormat"%>
<%@page import="org.infoglue.calendar.actions.CalendarAbstractAction"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Events" scope="page"/>
<c:set var="activeEventSubNavItem" value="MyWorkingEvents" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<%@ include file="eventSubFunctionMenu.jsp" %>

<div class="mainCol">

    <div class="row clearfix columnlabelarea">
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.event.name')"/></p></div>
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.event.description')"/></p></div>
        <div class="columnShort"><p><ww:property value="this.getLabel('labels.internal.event.owningCalendar')"/></p></div>
        <div class="columnDate"><p><ww:property value="this.getLabel('labels.internal.event.startDate')"/></p></div>
    </div>
    
    <ww:set name="languageCode" value="this.getLanguageCode()"/>
    <ww:set name="events" value="events" scope="page"/>
    <calendar:setToList id="eventList" set="${events}"/>
    
    <c:set var="eventsItems" value="${eventList}"/>
    <ww:if test="events != null && events.size() > 0">
        <ww:set name="numberOfItems" value="numberOfItems" scope="page"/>

        <c:set var="currentSlot" value="${param.currentSlot}"/>
        <c:if test="${currentSlot == null}">
            <c:set var="currentSlot" value="1"/>
        </c:if>
        <ww:set name="numberOfItems" value="numberOfItemsPerPage" scope="page" />
        <calendar:slots visibleElementsId="eventsItems" visibleSlotsId="indices" lastSlotId="lastSlot" elements="${eventList}" currentSlot="${currentSlot}" slotSize="${numberOfItems}" slotCount="10"/>
    </ww:if>
    
    <ww:iterator value="#attr.eventsItems" status="rowstatus">
    
        <ww:set name="event" value="top"/>
        <ww:set name="eventVersion" value="this.getMasterEventVersion('#event')"/>
        <ww:set name="eventVersion" value="this.getMasterEventVersion('#event')" scope="page"/>
        <ww:set name="eventId" value="id" scope="page"/>
        <ww:set name="name" value="name" scope="page"/>
    
        <portlet:renderURL var="eventUrl">
            <portlet:param name="action" value="ViewEvent"/>
            <portlet:param name="eventId" value='<%= pageContext.getAttribute("eventId").toString() %>'/>
        </portlet:renderURL>

 		<div class="row clearfix">
			<a href="<c:out value="${eventUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.title', #eventVersion.name)"/>">
				<div class="columnMedium">
	                <p class="portletHeadline">
	                	<ww:property value="#eventVersion.name"/><ww:if test="#eventVersion == null"><ww:property value="#event.id"/></ww:if>
	                </p>
					<p class="row-category">
		                <ww:iterator value="owningCalendar.eventType.categoryAttributes">
		                    <ww:if test="top.name == 'Evenemangstyp' || top.name == 'Eventtyp'">
		                        <ww:set name="selectedCategories" value="this.getEventCategories('#event', top)"/>
		                        <ww:iterator value="#selectedCategories" status="rowstatus">
		                            <ww:property value="top.getLocalizedName(#languageCode, 'sv')"/><ww:if test="!#rowstatus.last">, </ww:if>
		                        </ww:iterator>
		                    </ww:if>
		                </ww:iterator>
	                </p>
	            </div>
	            <div class="columnMedium">
	                <div class="eventDescription"><ww:property value="#eventVersion.shortDescription"/>&nbsp;</div>
	            </div>
	            <div class="columnShort">
	                <p><ww:property value="owningCalendar.name"/>&nbsp;</p>
	            </div>
	            <div class="columnDate">
	                <p style="white-space: nowrap;"><ww:property value="this.formatDate(startDateTime.time, 'yyyy-MM-dd')"/>&nbsp;</p>
	            </div>
			</a>

            <div class="columnEnd">
				<c:set var="cancelViewAction" scope="request">MyWorkingEventlist</c:set>
				<%@ include file="includes/deleteEventAction.jsp" %>
                <a href="<c:out value="${eventUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.edit.title', #eventVersion.name)"/>" class="edit"></a>
            </div>
        </div>
        
    </ww:iterator>
            
    <ww:if test="events != null && events.size() > 0">
        <br/>

		<c:set var="currentSlot" value="${currentSlot}" scope="request" />
		<c:set var="lastSlot" value="${lastSlot}" scope="request" />
		<c:set var="filterCategoryId" value="${filterCategoryId}" scope="request" />
		<c:set var="indices" value="${indices}" scope="request" />
		<c:set var="urlAction" value="ViewMyWorkingEventList" scope="request" />
		<jsp:include page="includes/pagination.jsp" />

    </ww:if>
    <ww:else>
            
        <ww:if test="events == null || events.size() == 0">
            <div class="row clearfix">
                <div class="columnMedium">
					<p class="portletHeadline"><ww:property value="this.getLabel('labels.internal.applicationNoItemsFound')"/></a></p>
				</div>
                <div class="columnMedium">&nbsp;</div>
				<div class="columnShort">&nbsp;</div>
				<div class="columnDate">&nbsp;</div>
                <div class="columnEnd"></div>
            </div>
        </ww:if>
    
    </ww:else>
</div>		


<%@ include file="adminFooter.jsp" %>
