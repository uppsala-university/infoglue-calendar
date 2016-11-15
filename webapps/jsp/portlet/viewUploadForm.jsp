<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<portlet:actionURL var="createResourceUploadActionUrl">
	<portlet:param name="action" value="CreateResource"/>
</portlet:actionURL>

<div class="mainCol">	
	<div class="portlet_margin">
		<form class="uploadForm" enctype="multipart/form-data" name="inputForm" method="POST" action="<c:out value="${createResourceUploadActionUrl}"/>&eventId=<ww:property value="event.id"/>&languageCode=<ww:property value="this.getLanguageCode()"/>">
			<input type="hidden" name="eventId" value="<ww:property value="event.id"/>"/>

			<ww:if test="assetKeyMapping.size() == 0">
				<p><ww:property value="this.getLabel('labels.event.uploadForm.noAssetKeysAvailable')"/></p>
			</ww:if>
			<ww:else>
				<calendar:selectField label="labels.internal.event.assetKey" name="assetKey" multiple="false" value="assetKeyMapping" cssClass="listBox"/>
				<ww:set name="labelKey" value="AssetUploadMaxFileSize"/>
				<ww:set name="defaultValue" value="this.getSetting(#labelKey, true, false)"/>
				<div class="fieldrow">
					<label for="file"><ww:property value="this.getLabel('labels.internal.event.fileToAttach')"/> (max <ww:property value="this.formatFileSize(this.getMaxUploadSize())"/>):</label><br>
					<input type="file" name="file" id="file" class="button"/>
				</div>
			</ww:else>

			<ww:if test="errorMessage != null">
				<p class="Error uploadError"><ww:property value="errorMessage"/></p>
			</ww:if>

			<ww:if test="assetKeyMapping.size() != 0">
				<input type="submit" value="<ww:property value="this.getLabel('labels.internal.event.updateButton')"/>" class="button">
			</ww:if>
			<input type="button" onclick="history.back();" value="<ww:property value="this.getLabel('labels.internal.applicationCancel')"/>" class="button save">
		</form>
	</div>
</div>

<div style="clear:both"></div>

<%@ include file="adminFooter.jsp" %>

