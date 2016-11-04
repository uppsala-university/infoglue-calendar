<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="EventTypes" scope="page"/>
<c:set var="activeSubNavItem" value="NewEventTypeCategoryAttribute" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>
 
<portlet:renderURL var="createAttributeCategoryUrl">
	<portlet:param name="action" value="CreateEventTypeCategoryAttribute!input"/>
	<calendar:evalParam name="eventTypeId" value="${param.eventTypeId}"/>
</portlet:renderURL>

<nav class="subfunctionarea clearfix">
	<div class="subfunctionarea-content">
        <a href="<c:out value="${createAttributeCategoryUrl}"/>" <c:if test="${activeSubNavItem == 'NewEventTypeCategoryAttribute'}">class="current"</c:if> title="<ww:property value="this.getLabel('labels.internal.eventType.category.add.title')"/>"><ww:property value="this.getLabel('labels.internal.eventType.addAvailableCategory')"/></a>
    </div>
</nav>
 
<div class="mainCol">
    <div class="portlet_margin">
        
        <portlet:actionURL var="createEventTypeCategoryAttributeActionUrl">
            <portlet:param name="action" value="CreateEventTypeCategoryAttribute"/>
        </portlet:actionURL>
        
        <form name="inputForm" method="POST" action="<c:out value="${createEventTypeCategoryAttributeActionUrl}"/>">
            <input type="hidden" name="eventTypeId" value="<ww:property value="eventTypeId"/>">
    
            <calendar:textField label="labels.internal.eventTypeCategoryAttribute.internalName" name="'internalName'" value="eventTypeCategoryAttribute.internalName" cssClass="longtextfield"/>
            <calendar:textField label="labels.internal.eventTypeCategoryAttribute.name" name="'name'" value="eventTypeCategoryAttribute.name" cssClass="longtextfield"/>
            <calendar:selectField label="labels.internal.eventTypeCategoryAttribute.BaseCategory" name="categoryId" multiple="false" value="categories" cssClass="listBox"/>
            <div style="height:10px"></div>
            <input type="submit" value="<ww:property value="this.getLabel('labels.internal.eventTypeCategoryAttribute.createButton')"/>" class="button">
            <input type="button" onclick="history.back();" value="<ww:property value="this.getLabel('labels.internal.applicationCancel')"/>" class="button">
        </form>
    </div>
</div>

<div style="clear:both"></div>

<%@ include file="adminFooter.jsp" %>
