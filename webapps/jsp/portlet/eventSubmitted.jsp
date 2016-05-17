<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Home" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<%@ include file="eventSubFunctionMenu.jsp" %>

<portlet:renderURL var="homeActionUrl">
	<portlet:param name="action" value="ViewCalendarAdministration"/>
</portlet:renderURL>

<div class="mainCol">
    <div class="portlet_margin">
        <ul class="linkList" >
            <ww:property value="this.getLabel('labels.internal.event.eventSubmittedText')"/>
            <br>
            <li class="link1"><a href="javascript:history.go(-1)"><ww:property value="this.getLabel('labels.internal.event.addEvent')"/> </a> </li>
            <li class="link2"><a href="http://www.uu.se">Till Uppsala universitets webbplats</a>	</li>
            <li class="link3"><a href="<c:out value="${homeActionUrl}"/>"><ww:property value="this.getLabel('labels.internal.event.eventSubmittedHome')"/></a></li>
        </p>
    </div>
</div>
<div style="clear:both;"></div>

<%@ include file="adminFooter.jsp" %>
