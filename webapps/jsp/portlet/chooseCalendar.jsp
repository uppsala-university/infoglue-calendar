<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Events" scope="page"/>
<c:set var="activeEventSubNavItem" value="NewEvent" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<%@ include file="eventSubFunctionMenu.jsp" %>

<div class="mainCol">
    <div class="portlet_margin">
        <p class="instruction"><ww:property value="this.getLabel('labels.internal.application.chooseCalendarIntro')"/></p>
    </div>
    
    <div class="columnlabelarea row clearfix">
        <div class="columnLong"><p><ww:property value="this.getLabel('labels.internal.calendar.nameMyCalendars')"/></p></div>
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.calendar.description')"/></p></div>
    </div>
    
    <ww:set name="foundMyCalendars" value="false"/>
    
    <ww:iterator value="calendars" status="rowstatus">
            
        <ww:set name="calendarId" value="id" scope="page"/>
        <portlet:renderURL var="createEventUrl">
            <portlet:param name="action" value="CreateEvent!input"/>
            <portlet:param name="calendarId" value='<%= pageContext.getAttribute("calendarId").toString() %>'/>
        </portlet:renderURL>
        
        <ww:if test="this.getIsCalendarAdministrator(top)">
            <ww:set name="foundMyCalendars" value="true" scope="page"/>
        
			<div class="row clearfix">
            
				<a href="<c:out value="${createEventUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.title', name)"/>">
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
        
        </ww:if>
            
    </ww:iterator>
    
    <ww:if test="#foundMyCalendars == false">
        <div class="row clearfix">
            <div class="columnLong"><p class="portletHeadline"><ww:property value="this.getLabel('labels.internal.applicationNoItemsFound')"/></a></p></div>
            <div class="columnMedium"></div>
            <div class="columnEnd"></div>
        </div>
    </ww:if>
    
    
    <div class="columnlabelarea row clearfix">
        <div class="columnLong"><p><ww:property value="this.getLabel('labels.internal.calendar.name')"/></p></div>
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.calendar.description')"/></p></div>
    </div>
    
    <ww:set name="foundCalendars" value="false"/>
                    
    <ww:iterator value="calendars" status="rowstatus">
            
        <ww:set name="calendarId" value="id" scope="page"/>
        <portlet:renderURL var="createEventUrl">
            <portlet:param name="action" value="CreateEvent!input"/>
            <portlet:param name="calendarId" value='<%= pageContext.getAttribute("calendarId").toString() %>'/>
        </portlet:renderURL>
        
        <ww:if test="!this.getIsCalendarAdministrator(top)">
        
            <ww:set name="foundCalendars" value="true"/>
            
			<div class="row clearfix">
				<a href="<c:out value="${createEventUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.title', name)"/>">
					<div class="columnLong">
						<p class="portletHeadline"><ww:property value="name"/></p>
					</div>
					<div class="columnMedium">
						<p><ww:property value="description"/></p>
					</div>
				</a>
				<div class="columnEnd">
				</div>
            </div>
        
        </ww:if>
            
    </ww:iterator>
    
    
    <ww:if test="#foundCalendars == false">
        <div class="row clearfix">
            <div class="columnLong">
				<p class="portletHeadline"><ww:property value="this.getLabel('labels.internal.applicationNoItemsFound')"/></a></p><
			/div>
            <div class="columnMedium"></div>
            <div class="columnEnd"></div>
        </div>
    </ww:if>
</div>

<%@ include file="adminFooter.jsp" %>
