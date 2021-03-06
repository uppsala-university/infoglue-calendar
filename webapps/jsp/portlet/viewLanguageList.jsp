<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Languages" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<portlet:renderURL var="createLanguageUrl">
	<portlet:param name="action" value="CreateLanguage!input"/>
</portlet:renderURL>

<portlet:renderURL var="viewListUrl">
	<portlet:param name="action" value="ViewLanguageList"/>
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
        <a href="<c:out value="${createLanguageUrl}"/>" title="<ww:property value="this.getLabel('labels.internal.language.addLanguage')"/>"><ww:property value="this.getLabel('labels.internal.language.addLanguage')"/></a>
    </div>	
</nav>

<div class="mainCol">
    <div class="row clearfix columnlabelarea">
        <div class="columnLong"><p><ww:property value="this.getLabel('labels.internal.language.name')"/></p></div>
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.language.isoCode')"/></p></div>
    </div>
    
    <ww:iterator value="languages" status="rowstatus">
    
        <ww:set name="systemLanguageId" value="id" scope="page"/>
        <ww:set name="name" value="name" scope="page"/>
        <portlet:renderURL var="languageUrl">
            <portlet:param name="action" value="ViewLanguage"/>
            <portlet:param name="systemLanguageId" value='<%= pageContext.getAttribute("systemLanguageId").toString() %>'/>
        </portlet:renderURL>
        
        <portlet:actionURL var="deleteLanguageUrl">
            <portlet:param name="action" value="DeleteLanguage"/>
            <portlet:param name="systemLanguageId" value='<%= pageContext.getAttribute("systemLanguageId").toString() %>'/>
        </portlet:actionURL>
    
        <div class="row clearfix">

			<a href="<c:out value="${languageUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.title', name)"/>">
				<div class="columnLong">
					<p class="portletHeadline">
					<ww:property value="name"/>
					</p>
				</div>
				<div class="columnMedium">
					<p><ww:property value="isoCode"/></p>
				</div>
			</a>
			<div class="columnEnd">
            	<ww:set name="deleteConfirm" value="this.getVisualFormatter().escapeExtendedHTML(this.getParameterizedLabel('labels.internal.general.list.delete.confirm', name))" />
                <a href="javascript:submitDelete('<c:out value="${deleteUrl}"/>', '<ww:property value="#deleteConfirm"/>');" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.delete.title', name)"/>" class="delete"></a>
                <a href="<c:out value="${languageUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.edit.title', name)"/>" class="edit"></a>
            </div>
        </div>
    
    </ww:iterator>
    
    <ww:if test="languages == null || languages.size() == 0">
        <div class="row clearfix">
            <div class="columnLong"><p class="portletHeadline"><ww:property value="this.getLabel('labels.internal.applicationNoItemsFound')"/></a></p></div>
            <div class="columnMedium"></div>
            <div class="columnEnd"></div>
        </div>
    </ww:if>
</div>

<%@ include file="adminFooter.jsp" %>
