<%@page import="java.util.Locale"%>
<%@page import="java.text.MessageFormat"%>
<%@page import="org.infoglue.calendar.actions.CalendarAbstractAction"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Events" scope="page"/>
<c:set var="activeEventSubNavItem" value="PublishedEvents" scope="page"/>

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
    <div class="columnlabelarea">
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.event.name')"/></p></div>
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.event.description')"/></p></div>
        <div class="columnShort"><p><ww:property value="this.getLabel('labels.internal.event.owningCalendar')"/></p></div>
        <div class="columnDate"><p><ww:property value="this.getLabel('labels.internal.event.startDate')"/></p></div>
        <div class="columnEnd"><p><a href="javascript:toggleDiv('columnFilterArea');"><ww:property value="this.getLabel('labels.internal.event.filterEventListToggle')"/></a></p></div>
        <div class="clear"></div>
    </div>
    
    <portlet:renderURL var="filterUrl">
        <portlet:param name="action" value="ViewPublishedEventList"/>
    </portlet:renderURL>
    
    <portlet:renderURL var="viewListUrl">
        <portlet:param name="action" value="ViewPublishedEventList"/>
    </portlet:renderURL>
    
    <portlet:renderURL var="confirmUrl">
        <portlet:param name="action" value="Confirm"/>
    </portlet:renderURL>
    
    <script type="text/javascript">
        function submitDelete(okUrl, confirmMessage)
        {
            //alert("okUrl:" + okUrl);
            document.confirmForm.okUrl.value = okUrl;
            document.confirmForm.confirmMessage.value = confirmMessage;
            document.confirmForm.submit();
        }
    </script>
    <form name="confirmForm" action="<c:out value="${confirmUrl}"/>" method="post">
        <input type="hidden" name="confirmTitle" value="<ww:property value="this.getLabel('labels.internal.general.list.delete.confirm.header')"/>"/>
        <input type="hidden" name="confirmMessage" value="Fixa detta"/>
        <input type="hidden" name="okUrl" value=""/>
        <input type="hidden" name="cancelUrl" value="<c:out value="${viewListUrl}"/>"/>	
    </form>

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
				pageContext.setAttribute("numberOfItems", 10);
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
            
        <portlet:actionURL var="deleteUrl">
            <portlet:param name="action" value="DeleteEvent!published"/>
            <calendar:evalParam name="eventId" value="${eventId}"/>
        </portlet:actionURL>
            
        <ww:if test="#rowstatus.odd == true">
            <div class="oddrow">
        </ww:if>
        <ww:else>
            <div class="evenrow">
        </ww:else>
    
            <div class="columnMedium">
                <p class="portletHeadline"><a href="<c:out value="${eventUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.title', #eventVersion.name)"/>"><ww:property value="#eventVersion.name"/><ww:if test="#eventVersion == null"><ww:property value="#event.id"/></ww:if></a>
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
                <p><ww:property value="owningCalendar.name"/></p>
            </div>
            <div class="columnDate">
                <p style="white-space: nowrap;"><ww:property value="this.formatDate(startDateTime.time, 'yyyy-MM-dd')"/></p>
            </div>
            <div class="columnEnd">
            	<ww:set name="deleteConfirm" value="this.getVisualFormatter().escapeExtendedHTML(this.getParameterizedLabel('labels.internal.general.list.delete.confirm', #eventVersion.name))" />
                <a href="javascript:submitDelete('<c:out value="${deleteUrl}"/>', '<ww:property value="#deleteConfirm"/>');" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.delete.title', #eventVersion.name)"/>" class="delete"></a>
                <a href="<c:out value="${eventUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.edit.title', #eventVersion.name)"/>" class="edit"></a>
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
		<c:set var="urlAction" value="ViewPublishedEventList" scope="request" />
		<jsp:include page="includes/pagination.jsp" />

    </ww:if>
    <ww:else>
    
        <ww:if test="events == null || events.size() == 0">
            <div class="oddrow">
                <div class="columnLong"><p class="portletHeadline"><ww:property value="this.getLabel('labels.internal.applicationNoItemsFound')"/></a></p></div>
                <div class="columnMedium"></div>
                <div class="columnEnd"></div>
                <div class="clear"></div>
            </div>
        </ww:if>
    
    </ww:else>
</div>

<div style="clear:both"></div>

<%@ include file="adminFooter.jsp" %>
