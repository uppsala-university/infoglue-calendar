<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Categories" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<portlet:renderURL var="createCategoryUrl">
	<portlet:param name="action" value="CreateCategory!input"/>
</portlet:renderURL>

<portlet:renderURL var="viewListUrl">
	<portlet:param name="action" value="ViewCategoryList"/>
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
        <a href="<c:out value="${createCategoryUrl}"/>" title="<ww:property value="this.getLabel('labels.internal.category.addCategory.title')"/>"><ww:property value="this.getLabel('labels.internal.category.addCategory')"/></a>
    </div>	
</nav>

<div class="mainCol">
    <div class="row clearfix columnlabelarea">
        <div class="columnMedium"><p><ww:property value="this.getLabel('labels.internal.category.name')"/></p></div>
        <div class="columnLong"><p><ww:property value="this.getLabel('labels.internal.category.description')"/></p></div>
    </div>
    
    <ww:iterator value="categories" status="rowstatus">
    
        <ww:set name="categoryId" value="id" scope="page"/>
        <ww:set name="category" value="top"/>
        <ww:set name="category" value="top" scope="page"/>
        <ww:set name="languageCode" value="this.getLanguageCode()"/>
        <ww:set name="name" value="#category.getLocalizedName(#languageCode, 'sv')"/>
        
        <portlet:renderURL var="categoryUrl">
            <portlet:param name="action" value="ViewCategory"/>
            <portlet:param name="categoryId" value='<%= pageContext.getAttribute("categoryId").toString() %>'/>
        </portlet:renderURL>
        
        <portlet:actionURL var="deleteUrl">
            <portlet:param name="action" value="DeleteCategory"/>
            <portlet:param name="deleteCategoryId" value='<%= pageContext.getAttribute("categoryId").toString() %>'/>
        </portlet:actionURL>
            
        <div class="row clearfix">
			<a href="<c:out value="${categoryUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.title', #name)"/>">
				<div class="columnMedium">
					<p class="portletHeadline"><ww:property value="#name"/> (<ww:property value="internalName"/>)</p>
				</div>
				<div class="columnLong">
					<p><ww:property value="description"/></p>
				</div>
			</a>
            <div class="columnEnd">
            	<ww:set name="deleteConfirm" value="this.getVisualFormatter().escapeExtendedHTML(this.getParameterizedLabel('labels.internal.general.list.delete.confirm', #name))" />
                <a href="javascript:submitDelete('<c:out value="${deleteUrl}"/>', '<ww:property value="#deleteConfirm"/>');" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.delete.title', #name)"/>" class="delete"></a>
                <a href="<c:out value="${categoryUrl}"/>" title="<ww:property value="this.getParameterizedLabel('labels.internal.general.list.edit.title', #name)"/>" class="edit"></a>
            </div>
        </div>
        
    </ww:iterator>
    
    <ww:if test="categories == null || categories.size() == 0">
        <div class="row clearfix">
            <div class="columnLong"><p class="portletHeadline"><ww:property value="this.getLabel('labels.internal.applicationNoItemsFound')"/></a></p></div>
            <div class="columnMedium"></div>
            <div class="columnEnd"></div>
        </div>
    </ww:if>
</div>

    
<%@ include file="adminFooter.jsp" %>
