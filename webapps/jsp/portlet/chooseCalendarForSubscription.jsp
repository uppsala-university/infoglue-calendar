<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Events" scope="page"/>
<c:set var="activeEventSubNavItem" value="EventSubscriptions" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<%@ include file="eventSubFunctionMenu.jsp" %>

<div class="mainCol">
    <div class="portlet_margin">
        <p class="instruction"><ww:property value="this.getLabel('labels.internal.application.chooseCalendarForSubscriptionIntro')"/></p>
    </div>
    
    <div class="columnlabelarea">
        <div class="columnLong"><p><ww:property value="this.getLabel('labels.internal.calendar.name')"/></p></div>
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.calendar.description')"/></p></div>
        <div class="clear"></div>
    </div>
    
    <ww:iterator value="calendars" status="rowstatus">
        
        <ww:set name="calendarId" value="id" scope="page"/>
        <portlet:actionURL var="createEventSubscriptionUrl">
            <portlet:param name="action" value="CreateEventSubscription"/>
            <portlet:param name="calendarId" value='<%= pageContext.getAttribute("calendarId").toString() %>'/>
        </portlet:actionURL>
        
		<div class="row clearfix">

			<a href="<c:out value="${createEventSubscriptionUrl}"/>" title="<ww:property value="this.getVisualFormatter().escapeExtendedHTML(this.getParameterizedLabel('labels.internal.general.list.select.title', name))"/>">
				<div class="columnLong">
					<p class="portletHeadline">
					<ww:property value="name"/>
					</p>
				</div>
				<div class="columnMedium">
					<p><ww:property value="description"/></p>
				</div>
			</a>
            <div class="columnEnd">
            </div>
        </div>
            
    </ww:iterator>
    
    <ww:if test="calendars == null || calendars.size() == 0">
        <div class="row clearfix">
            <div class="columnLong"><p class="portletHeadline"><ww:property value="this.getLabel('labels.internal.applicationNoItemsFound')"/></a></p></div>
            <div class="columnMedium"></div>
            <div class="columnEnd"></div>
        </div>
    </ww:if>
    
</div>

<%@ include file="adminFooter.jsp" %>
