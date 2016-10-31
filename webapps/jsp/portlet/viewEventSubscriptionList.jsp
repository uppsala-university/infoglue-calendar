<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Events" scope="page"/>
<c:set var="activeEventSubNavItem" value="EventSubscriptions" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<%@ include file="eventSubFunctionMenu.jsp" %>

<portlet:renderURL var="createSubscriptionUrl">
	<portlet:param name="action" value="CreateEventSubscription!input"/>
</portlet:renderURL>

<portlet:renderURL var="viewListUrl">
	<portlet:param name="action" value="ViewEventSubscriptionList"/>
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
	<input type="hidden" name="confirmTitle" value="Radera - bekr&#228;fta"/>
	<input type="hidden" name="confirmMessage" value="Fixa detta"/>
	<input type="hidden" name="okUrl" value=""/>
	<input type="hidden" name="cancelUrl" value="<c:out value="${viewListUrl}"/>"/>	
</form>



<div class="mainCol">
	<div class="pageAlternative">
			<a href="<c:out value="${createSubscriptionUrl}"/>" title="Skapa ny post"><ww:property value="this.getLabel('labels.internal.subscription.addSubscription')"/></a>
		<div class="clear"></div>
	</div>
    <div class="row clearfix columnlabelarea">
        <div class="columnLong"><p><ww:property value="this.getLabel('labels.internal.subscribedCalendarNames')"/></p></div>
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.calendar.description')"/></p></div>
    </div>
    
    <ww:iterator value="subscribers" status="rowstatus">
    
        <ww:set name="subscriptionId" value="top.id" scope="page"/>
        <ww:set name="name" value="top.calendar.name" scope="page"/>
        
        <portlet:actionURL var="deleteUrl">
            <portlet:param name="action" value="DeleteEventSubscription"/>
            <portlet:param name="subscriptionId" value='<%= pageContext.getAttribute("subscriptionId").toString() %>'/>
        </portlet:actionURL>
        

        <div class="row clearfix">
            <div class="columnLong">
                <p class="portletHeadline"><ww:property value="top.calendar.name"/></p>
            </div>
            <div class="columnMedium">
                <p><ww:property value="top.calendar.description"/></p>
            </div>
            <div class="columnEnd">
                <a href="javascript:submitDelete('<c:out value="${deleteUrl}"/>', '&#196;r du s&#228;ker p&#229; att du vill radera &quot;<ww:property value="#name"/>&quot;');" title="Radera '<ww:property value="top.calendar.name"/>'" class="delete"></a>
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
