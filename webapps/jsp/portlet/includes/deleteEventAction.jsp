<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<%--
	# API
	This file is expected to be included, not called directly. The following variables should be set
	in the pageContext before the file is included.

	 * cancelViewAction
--%>

<c:set var="deleteEventId" scope="page"><ww:property value="#event.id" /></c:set>

<portlet:renderURL var="cancelUrl">
	<portlet:param name="action" value='<%= request.getAttribute("cancelViewAction").toString() %>'/>
</portlet:renderURL>

<portlet:renderURL var="confirmUrl">
	<portlet:param name="action" value="Confirm"/>
</portlet:renderURL>

<portlet:actionURL var="deleteUrl">
	<portlet:param name="action" value='<%= "DeleteEvent" + pageContext.getAttribute("deleteActionTask").toString() %>'/>
	<portlet:param name="eventId" value='<%= pageContext.getAttribute("deleteEventId").toString() %>'/>
</portlet:actionURL>

<c:set var="deleteFunctionName" value="submitDelete_${deleteEventId}"/>
<c:set var="deleteFormName" value="deleteForm_${deleteEventId}"/>

<script type="text/javascript">
	function <c:out value="${deleteFunctionName}()"/>
	{
		document.<c:out value="${deleteFormName}"/>.submit();
	}
</script>

<form name="<c:out value="${deleteFormName}"/>" action="<c:out value="${confirmUrl}"/>" method="post">
	<input type="hidden" name="confirmTitle" value="<ww:property value="this.htmlEncodeValue(this.getLabel('labels.internal.general.list.delete.confirm.header'))"/>"/>
	<input type="hidden" name="confirmMessage" value="<ww:property value="this.htmlEncodeValue(this.getParameterizedLabel('labels.internal.general.list.delete.confirm', #eventVersion.name))"/>"/>
	<input type="hidden" name="okUrl" value="<c:out value="${deleteUrl}"/>"/>
	<input type="hidden" name="cancelUrl" value="<c:out value="${cancelUrl}"/>"/>
</form>

<a href="javascript:<c:out value="${deleteFunctionName}"/>();" title="<ww:property value="this.getVisualFormatter().escapeExtendedHTML(this.getParameterizedLabel('labels.internal.general.list.delete.title', #eventVersion.name))"/>" class="delete"></a>
