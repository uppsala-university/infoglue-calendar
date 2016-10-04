<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Locations" scope="page"/>
<c:set var="activeSubNavItem" value="NewLocation" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<portlet:renderURL var="createLocationUrl">
	<portlet:param name="action" value="CreateLocation!input"/>
</portlet:renderURL>

<nav class="subfunctionarea clearfix">
	<div class="subfunctionarea-content">
        <a href="<c:out value="${createLocationUrl}"/>" <c:if test="${activeSubNavItem == 'NewLocation'}">class="current"</c:if> title="Skapa ny post"><ww:property value="this.getLabel('labels.internal.location.addLocation')"/></a>
    </div>	
</nav>

<div class="mainCol">
    <div class="portlet_margin">
        <portlet:actionURL var="createLocationActionUrl">
            <portlet:param name="action" value="CreateLocation"/>
        </portlet:actionURL>
        
        <form name="inputForm" method="POST" action="<c:out value="${createLocationActionUrl}"/>">
    
            <calendar:textField label="labels.internal.location.name" name="'name'" value="location.name" cssClass="longtextfield"/>
            <calendar:textField label="labels.internal.location.description" name="'description'" value="location.description" cssClass="longtextfield"/>
        
            <div style="height:10px"></div>
        
            <input type="submit" value="<ww:property value="this.getLabel('labels.internal.location.createButton')"/>" class="button">
            <input type="button" onclick="history.back();" value="<ww:property value="this.getLabel('labels.internal.applicationCancel')"/>" class="button">
        </form>
    </div>
</div>

<div style="clear:both"></div>

<%@ include file="adminFooter.jsp" %>
