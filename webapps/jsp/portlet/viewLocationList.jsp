<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Locations" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<portlet:renderURL var="createLocationUrl">
	<portlet:param name="action" value="CreateLocation!input"/>
</portlet:renderURL>

<portlet:renderURL var="viewListUrl">
	<portlet:param name="action" value="ViewLocationList"/>
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
	<input type="hidden" name="confirmTitle" value="<ww:property value="this.htmlEncodeValue(this.getLabel('labels.internal.general.list.delete.confirm.header'))"/>"/>
	<input type="hidden" name="confirmMessage" value="Fixa detta"/>
	<input type="hidden" name="okUrl" value=""/>
	<input type="hidden" name="cancelUrl" value="<c:out value="${viewListUrl}"/>"/>	
</form>

<nav class="subfunctionarea clearfix">
	<div class="subfunctionarea-content">
		<a href="<c:out value="${createLocationUrl}"/>" title="Skapa ny post"><ww:property value="this.getLabel('labels.internal.location.addLocation')"/></a>
	</div>
</nav>

<div class="mainCol">

    <div class="columnlabelarea row clearfix">
        <div class="columnLong"><p><ww:property value="this.getLabel('labels.internal.location.name')"/></p></div>
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.location.description')"/></p></div>
    </div>
    
    <ww:iterator value="locations" status="rowstatus">
    
        <ww:set name="location" value="top"/>
        <ww:set name="location" value="top" scope="page"/>
        <ww:set name="locationId" value="id" scope="page"/>
        <ww:set name="languageCode" value="this.getLanguageCode()"/>
        <ww:set name="name" value="#location.getLocalizedName(#languageCode, 'sv')"/>
        
        <portlet:renderURL var="locationUrl">
            <portlet:param name="action" value="ViewLocation"/>
            <portlet:param name="locationId" value='<%= pageContext.getAttribute("locationId").toString() %>'/>
        </portlet:renderURL>
        
        <portlet:actionURL var="deleteLocationUrl">
            <portlet:param name="action" value="DeleteLocation"/>
            <portlet:param name="locationId" value='<%= pageContext.getAttribute("locationId").toString() %>'/>
        </portlet:actionURL>
		
		<div class="row clearfix">
			<a href="<c:out value="${locationUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.edit.title', #name)"/>"><ww:property value="#name"/>				<div class="columnLong">
					<p class="portletHeadline"><ww:property value="#name"/></p>
				</div>
				<div class="columnMedium">
					<p><ww:property value="description"/></p>
				</div>
			</a>
			<div class="columnEnd">
				<a href="javascript:submitDelete('<c:out value="${deleteLocationUrl}"/>', '<ww:property value="this.htmlEncodeValue(this.getParameterizedLabel('labels.internal.general.list.delete.confirm', #name))"/>');" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.delete.title', #name)"/>" class="delete"></a>
				<a href="<c:out value="${locationUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.edit.title', #name)"/>" class="edit"></a>
			</div>
		</div>
	
	</ww:iterator>
    
    <ww:if test="locations == null || locations.size() == 0">
        <div class="row clearfix">
            <div class="columnLong"><p class="portletHeadline"><ww:property value="this.getLabel('labels.internal.applicationNoItemsFound')"/></a></p></div>
            <div class="columnMedium"></div>
            <div class="columnEnd"></div>
        </div>
    </ww:if>
</div>

<%@ include file="adminFooter.jsp" %>
