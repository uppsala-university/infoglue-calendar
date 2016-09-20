<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/portlet" prefix="portlet"%>
<%@ taglib uri="webwork" prefix="ww" %>
<%@page import="java.text.MessageFormat"%>
<%@page import="org.infoglue.calendar.actions.CalendarAbstractAction"%>

<c:set var="currentSlot" value="${requestScope.currentSlot}"/>
<c:set var="lastSlot" value="${requestScope.lastSlot}" />
<c:set var="filterCategoryId" value="${requestScope.filterCategoryId}" />
<c:set var="indices" value="${requestScope.indices}" />
<c:set var="urlAction" value="${requestScope.urlAction}" />

<ww:set name="thisObject" value="this" scope="page"/>

<%
	String currentSlot = (String)pageContext.getAttribute("currentSlot");
	Integer lastSlot = (Integer)pageContext.getAttribute("lastSlot");
	CalendarAbstractAction caa = (CalendarAbstractAction)pageContext.getAttribute("thisObject");
	
	String paginationLabel = caa.getLabel("labels.internal.event.pagination");
	Object[] arguments = {currentSlot, lastSlot};

	pageContext.setAttribute("paginationLabelFormatted", MessageFormat.format(paginationLabel, arguments));
%>

<p><strong><c:out value="${paginationLabelFormatted}"/></strong>&nbsp;</p>

<!-- slot navigator -->
<c:if test="${lastSlot != 1}">
<c:out value="${ViewPublishedEventList}"/>
    <div class="prev_next">
        <c:if test="${currentSlot gt 1}">
            <c:set var="previousSlotId" value="${currentSlot - 1}"/>
            <portlet:renderURL var="firstUrl">
                <portlet:param name="action" value='<%= pageContext.getAttribute("urlAction").toString() %>'/>
                <portlet:param name="currentSlot" value="1"/>
                <c:if test="${not empty filterCategoryId}">
                    <portlet:param name="categoryId" value='<%= pageContext.getAttribute("filterCategoryId").toString() %>'/>
                </c:if>
            </portlet:renderURL>
            <portlet:renderURL var="previousSlot">
                <portlet:param name="action" value='<%= pageContext.getAttribute("urlAction").toString() %>'/>
                <portlet:param name="currentSlot" value='<%= pageContext.getAttribute("previousSlotId").toString() %>'/>
                <c:if test="${not empty filterCategoryId}">
                    <portlet:param name="categoryId" value='<%= pageContext.getAttribute("filterCategoryId").toString() %>'/>
                </c:if>
            </portlet:renderURL>

            <a href="<c:out value='${firstUrl}'/>" class="number" title="<ww:property value="this.getLabel('labels.internal.event.pagination.firstTitle')"/>"><ww:property value="this.getLabel('labels.internal.event.pagination.first')"/></a>
            <a href="<c:out value='${previousSlot}'/>" title="<ww:property value="this.getLabel('labels.internal.event.pagination.previousTitle')"/>" class="number">&laquo;</a>
        </c:if>
        <c:forEach var="slot" items="${indices}" varStatus="count">
            <c:if test="${slot == currentSlot}">
                <span class="number"><c:out value="${slot}"/></span>
            </c:if>
            <c:if test="${slot != currentSlot}">
                <c:set var="slotId" value="${slot}"/>
                <portlet:renderURL var="url">
                    <portlet:param name="action" value='<%= pageContext.getAttribute("urlAction").toString() %>'/>
                    <portlet:param name="currentSlot" value='<%= pageContext.getAttribute("slotId").toString() %>'/>
                    <c:if test="${not empty filterCategoryId}">
                        <portlet:param name="categoryId" value='<%= pageContext.getAttribute("filterCategoryId").toString() %>'/>
                    </c:if>
                </portlet:renderURL>

                <a href="<c:out value='${url}'/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.event.pagination.pageTitle', #attr.slot)"/>" class="number"><c:out value="${slot}"/></a>
            </c:if>
        </c:forEach>
        <c:if test="${currentSlot lt lastSlot}">
            <c:set var="nextSlotId" value="${currentSlot + 1}"/>
            <portlet:renderURL var="nextSlotUrl">
                <portlet:param name="action" value='<%= pageContext.getAttribute("urlAction").toString() %>'/>
                <portlet:param name="currentSlot" value='<%= pageContext.getAttribute("nextSlotId").toString() %>'/>
                <c:if test="${not empty filterCategoryId}">
                    <portlet:param name="categoryId" value='<%= pageContext.getAttribute("filterCategoryId").toString() %>'/>
                </c:if>
            </portlet:renderURL>

            <a href="<c:out value='${nextSlotUrl}'/>" title="<ww:property value="this.getLabel('labels.internal.event.pagination.nextTitle')"/>" class="number">&raquo;</a>
        </c:if>
    </div>
</c:if>
