<%@page import="java.text.MessageFormat"%>
<%@page import="org.infoglue.calendar.actions.CalendarAbstractAction"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Events" scope="page"/>
<c:set var="activeEventSubNavItem" value="LinkedPublishedEvents" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<%@ include file="eventSubFunctionMenu.jsp" %>

<script type="text/javascript">
<!--
	function toggleDiv(id)
	{
		element = document.getElementById(id);
		if(element.style.display == "none")
			element.style.display = "block";
		else
			element.style.display = "none";
	}
-->
</script>

<div class="mainCol">
    <div class="row clearfix columnlabelarea">
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.event.name')"/></p></div>
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.event.description')"/></p></div>
        <div class="columnShort"><p><ww:property value="this.getLabel('labels.internal.event.calendars')"/></p></div>
        <div class="columnDate"><p><ww:property value="this.getLabel('labels.internal.event.startDate')"/></p></div>
        <div class="columnEnd"><p><a href="javascript:toggleDiv('columnFilterArea');"><ww:property value="this.getLabel('labels.internal.event.filterEventListToggle')"/></a></p></div>
    </div>
    
    <portlet:renderURL var="filterUrl">
        <portlet:param name="action" value="ViewLinkedPublishedEventList"/>
    </portlet:renderURL>
    
    <ww:if test="categoryId == null">
    <div id="columnFilterArea" class="columnlabelarea" style="display:none;">
    </ww:if>
    <ww:else>
    <div id="columnFilterArea" class="columnlabelarea" style="display:block;">
    </ww:else>
		<form action="<c:out value="${filterUrl}"/>" method="POST">
			<div class="columnMedium"><p><calendar:selectField label="labels.internal.calendar.eventType" name="'categoryId'" headerItem="labels.internal.search.input.eventTypeDefault" multiple="false" value="categoriesList" selectedValue="categoryId" cssClass="listBox"/></p></div>
			<div class="columnMedium"><p>&nbsp;</p></div>
			<div class="columnShort"><p>&nbsp;</p></div>
			<div class="columnDate"><p>&nbsp;</p></div>
			<div class="columnEnd"><p>&nbsp;</p><input type="submit" value="<ww:property value="this.getLabel('labels.internal.event.filterEventListSubmit')"/>"/></div>
			<div class="clear"></div>
		</form>
    </div>
    
    <ww:set name="filterCategoryId" value="categoryId" scope="page"/>
    
    <ww:set name="languageCode" value="this.getLanguageCode()"/>
    <ww:set name="events" value="events" scope="page"/>
    <calendar:setToList id="eventList" set="${events}"/>
    
    <c:set var="eventsItems" value="${eventList}"/>
    <ww:if test="events != null && events.size() > 0">
        <ww:set name="numberOfItems" value="numberOfItems" scope="page"/>
        <%
			try
			{
				String numberOfItems = (String)pageContext.getAttribute("numberOfItems");
				pageContext.setAttribute("numberOfItems", Integer.parseInt(numberOfItems));
			}
			catch (Exception ex)
			{
				pageContext.setAttribute("numberOfItems", 50);
			}
        %>
        <c:set var="currentSlot" value="${param.currentSlot}"/>
        <c:if test="${currentSlot == null}">
            <c:set var="currentSlot" value="1"/>
        </c:if>
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
        
        <portlet:renderURL var="deleteUrl">
            <portlet:param name="action" value="ViewCalendarList!chooseDeleteLink"/>
            <calendar:evalParam name="eventId" value="${eventId}"/>
        </portlet:renderURL>
            
        <div class="row clearfix">
			<div class="columnMedium">
				<p class="portletHeadline">
					<a href="<c:out value="${eventUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.title', #eventVersion.name)"/>">            
						<ww:property value="#eventVersion.name"/><ww:if test="#eventVersion == null"><ww:property value="#event.id"/></ww:if>
					</a>
				</p>
			</div>
			<div class="columnMedium">
				<p class="eventDescription"><ww:property value="#eventVersion.shortDescription"/>&nbsp;</p>
			</div>
			<div class="columnShort">
				<p><ww:property value="this.getLabel('labels.internal.event.owningCalendar')"/>: <br><ww:property value="owningCalendar.name"/></p>
				<c:set var="linkedCalendars" value=""/>
				<ww:iterator value="calendars" status="calendarStatus">
					<ww:if test="id != owningCalendar.id">
						<c:set var="linkedCalendars"><c:out value="${linkedCalendars}"/><c:if test="${not empty linkedCalendars}">, </c:if><ww:property value="name"/></c:set>
					</ww:if>
				</ww:iterator>
				<p><ww:property value="this.getLabel('labels.internal.event.linkedCalendars')"/>: <br><c:out value="${linkedCalendars}"/></p>
			</div>
			<div class="columnDate">
				<p style="white-space: nowrap;"><ww:property value="this.formatDate(startDateTime.time, 'yyyy-MM-dd')"/></p>
			</div>
            <div class="columnEnd">
                <a href="<c:out value="${deleteUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.delete.title', #eventVersion.name)"/>" class="delete"></a>
            </div>
            <div class="clear"></div>
        </div>
    
    </ww:iterator>
    
    <ww:if test="events != null && events.size() > 0">
        <br/>

		<c:set var="currentSlot" value="${currentSlot}" scope="request" />
		<c:set var="lastSlot" value="${lastSlot}" scope="request" />
		<c:set var="filterCategoryId" value="${filterCategoryId}" scope="request" />
		<c:set var="indices" value="${indices}" scope="request" />
		<c:set var="urlAction" value="ViewLinkedPublishedEventList" scope="request" />
		<jsp:include page="includes/pagination.jsp" />

    </ww:if>
    <ww:else>
    
        <ww:if test="events == null || events.size() == 0">
            <div class="row clearfix">
                <div class="columnLong"><p class="portletHeadline"><ww:property value="this.getLabel('labels.internal.applicationNoItemsFound')"/></a></p></div>
                <div class="columnMedium"></div>
                <div class="columnEnd"></div>
            </div>
        </ww:if>    
    </ww:else>

</div>

<%@ include file="adminFooter.jsp" %>