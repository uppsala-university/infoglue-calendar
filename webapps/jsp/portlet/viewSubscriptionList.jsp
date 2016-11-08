<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Calendars" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<ww:set name="calendarId" value="calendarId" scope="page"/>
<portlet:renderURL var="viewListUrl">
	<portlet:param name="action" value="ViewSubscriptionList"/>
	<portlet:param name="calendarId" value='<%= pageContext.getAttribute("calendarId").toString() %>'/>
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
	<input type="hidden" name="confirmTitle" value="<ww:property value="this.htmlEncodeValue(this.getLabel('labels.internal.general.list.delete.confirm.header'))" />"/>
	<input type="hidden" name="confirmMessage" value="Fixa detta"/>
	<input type="hidden" name="okUrl" value=""/>
	<input type="hidden" name="cancelUrl" value="<c:out value="${viewListUrl}"/>"/>	
</form>

<nav class="subfunctionarea clearfix">
	<div class="subfunctionarea-content">
		<a href="<c:out value="${viewSubscriptionsUrl}"/>" title="<ww:property value="this.getLabel('labels.internal.calendar.viewSubscriptions')"/>"><ww:property value="this.getLabel('labels.internal.calendar.viewSubscriptions')"/></a>
	</div>
</nav>

<div class="mainCol">

    <div class="columnlabelarea row clearfix">
        <div class="columnLong"><p><ww:property value="this.getLabel('labels.internal.subscribers')"/></p></div>
    </div>
    
    <ww:iterator value="subscribers" status="rowstatus">
    
        <ww:set name="subscriptionId" value="top.id" scope="page"/>
        <ww:set name="name" value="top.email" scope="page"/>
        
        <portlet:actionURL var="deleteUrl">
            <portlet:param name="action" value="DeleteEventSubscription"/>
            <portlet:param name="subscriptionId" value='<%= pageContext.getAttribute("subscriptionId").toString() %>'/>
        </portlet:actionURL>
        
        <div class="row clearfix">    
            <div class="columnLong">
                <p class="portletHeadline"><ww:property value="top.email"/></p>
            </div>
            <div class="columnEnd">
	            <ww:set name="deleteConfirm" value="this.getVisualFormatter().escapeExtendedHTML(this.getParameterizedLabel('labels.internal.general.list.delete.confirm', top.email))" />
                <a href="javascript:submitDelete('<c:out value="${deleteUrl}"/>', '<ww:property value="#deleteConfirm"/>');" title="<ww:property value="this.getParameterizedLabel('labels.internal.subscription.list.delete.person.title', top.email)"/>" class="delete"></a>
            </div>
        </div>
            
    </ww:iterator>
    
    <ww:if test="subscribers == null || subscribers.size() == 0">
        <div class="row clearfix">
            <div class="columnLong"><p class="portletHeadline"><ww:property value="this.getLabel('labels.internal.applicationNoItemsFound')"/></a></p></div>
            <div class="columnMedium"></div>
            <div class="columnEnd"></div>
        </div>
    </ww:if>
	
</div>


<%@ include file="adminFooter.jsp" %>
