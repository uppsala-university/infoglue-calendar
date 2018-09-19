<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Event" scope="page"/>


<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<%@ include file="eventSubFunctionMenu.jsp" %>


<ww:set name="event" value="event" scope="page"/>
<ww:set name="eventVersion" value="eventVersion" scope="page"/>
<ww:if test="eventVersion == null">
	<ww:set name="alternativeEventVersion" value="this.getEventVersion()" scope="page"/>
</ww:if>

<ww:set name="eventId" value="event.id" scope="page"/>
<ww:set name="calendarId" value="calendarId" scope="page"/>
<ww:set name="versionLanguageId" value="versionLanguageId" scope="page"/>
<ww:set name="mode" value="mode" scope="page"/>

<portlet:renderURL var="translateEventRenderURL">
	<calendar:evalParam name="action" value="ViewEvent!chooseLanguageForEdit"/>
	<calendar:evalParam name="eventId" value="${eventId}"/>
	<calendar:evalParam name="calendarId" value="${calendarId}"/>
	<portlet:param name="skipLanguageTabs" value="true"/>	
</portlet:renderURL>

<div class="mainCol">
    <div class="portlet_margin">

        <%-- Language --%> 
        <ww:if test="skipLanguageTabs != true">
        
            <ww:if test="event.versions.size() > 1">
                <p>
                    <ww:property value="this.getLabel('labels.internal.application.languageTranslationTabsIntro')"/>
                    <ww:if test="event.versions.size() < availableLanguages.size()">
                        <ww:property value="this.getParameterizedLabel('labels.internal.application.languageTranslationNewVersionText', #attr.translateEventRenderURL)"/>
                    </ww:if>
                </p>
                <ul class="languagesTabs">
                    <ww:iterator value="event.versions" status="rowstatus">
                        <ww:set name="currentLanguageId" value="top.language.id"/>
                        <ww:set name="currentLanguageId" value="top.language.id" scope="page"/>
                        
                        <portlet:renderURL var="viewEventVersionUrl">
                            <portlet:param name="action" value="ViewEvent!edit"/>
                            <calendar:evalParam name="eventId" value="${eventId}"/>
                            <calendar:evalParam name="versionLanguageId" value="${currentLanguageId}"/>
                        </portlet:renderURL>
                            
                        <c:choose>
                            <c:when test="${versionLanguageId == currentLanguageId}">
                                <c:set var="cssClass" value="activeTab"/>
                            </c:when>
                            <c:otherwise>
                                <c:set var="cssClass" value=""/>
                            </c:otherwise>
                        </c:choose>		
                        <li class="<c:out value="${cssClass}"/>">
                            <a href="<c:out value="${viewEventVersionUrl}"/>"><ww:property value="top.language.name"/></a>
                        </li>
                        
                    </ww:iterator>
                </ul>
            </ww:if>
            <ww:else>
                <ww:if test="event.versions.size() < availableLanguages.size()">
                <p>
                    <ww:property value="this.getParameterizedLabel('labels.internal.application.languageTranslationNewVersionText', #attr.translateEventRenderURL)"/>
                </p>
                </ww:if>
            </ww:else>
        </ww:if>	
    
        <%
        Object requestObject = request.getAttribute("javax.portlet.request");
        javax.portlet.PortletRequest renderRequestIG = (javax.portlet.PortletRequest)requestObject;
        String hostName = (String)renderRequestIG.getProperty("host");
        %>		
    
        <portlet:actionURL var="updateEventActionUrl">
            <portlet:param name="action" value="UpdateEvent"/>
        </portlet:actionURL>

        
        <ww:if test="eventCopy == true">
            <span style="color: red"><ww:property value="this.getLabel('labels.internal.event.createEventCopyMessage')"/></span>
        </ww:if>	
        
        <form name="updateForm" class="create-event edit-event" method="POST" action="<c:out value="${updateEventActionUrl}"/>" onsubmit="return validateForm();">
            <input type="hidden" name="eventId" value="<ww:property value="event.id"/>"/>


            <input type="hidden" name="versionLanguageId" value="<ww:property value="versionLanguageId"/>"/>
            <input type="hidden" name="calendarId" value="<ww:property value="event.owningCalendar.id"/>"/>
            <input type="hidden" name="mode" value="<ww:property value="mode"/>"/>

            <input type="hidden" name="publishEventUrl" value="http://<%=hostName%><c:out value="${publishEventUrl}"/>"/>
 			<fieldset>
				<legend class="arrow-up"><ww:property value="this.getLabel('labels.internal.event.baseInfoHeader')"/></legend>  
				<section style="display:block">
					<%-- Event title --%>
					<ww:if test="this.getLabel('labels.internal.event.nameInfo') != 'labels.internal.event.nameInfo'">							
						<a class="inputLink" href="#" onclick="return false;">
							<img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo">
								<ww:property value="this.getLabel('labels.internal.event.nameInfo')"/>
							</p>
						</a>
					</ww:if>
					<ww:if test="eventVersion == null && alternativeEventVersion != null">
						<calendar:textField label="labels.internal.event.name" name="'name'" value="alternativeEventVersion.name" cssClass="longtextfield"/>
					</ww:if>
					<ww:else>
						<calendar:textField label="labels.internal.event.name" name="'name'" value="eventVersion.name" cssClass="longtextfield"/>
					</ww:else>
			
					<input type="hidden" name="title" id="title"/>
										
					<%-- Internal or open --%> 
		            <ww:if test="this.isActiveEventField('isInternal')">
						<calendar:radioButtonField label="labels.internal.event.isInternal" name="'isInternal'" required="true" valueMap="internalEventMap" selectedValue="event.isInternal"/>
					</ww:if>					
					
					<%-- Lecturer --%>   
		            <ww:if test="this.isActiveEventField('lecturer')">
						<ww:if test="eventVersion == null && alternativeEventVersion != null">
							<calendar:textAreaField label="labels.internal.event.lecturer" name="'lecturer'" value="alternativeEventVersion.lecturer" cssClass="smalltextarea"/>
						</ww:if>
						<ww:else>
							<calendar:textAreaField label="labels.internal.event.lecturer" name="'lecturer'" value="eventVersion.lecturer" cssClass="smalltextarea"/>
						</ww:else>
					</ww:if>
					<ww:property value="this.copyDescriptionToNewLanguage"/>
					<ww:property value="event.copyDescriptionToNewLanguage"/>
					<%-- Short description --%>  
					<ww:if test="this.getLabel('labels.internal.event.shortDescriptionInfo') != 'labels.internal.event.shortDescriptionInfo'">												
						<a class="inputLink" href="#" onclick="return false;">
							<img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo">
								<ww:property value="this.getLabel('labels.internal.event.shortDescriptionInfo')"/>
							</p>
						</a>
					</ww:if>
					<calendar:textAreaField label="labels.internal.event.shortDescription" name="'shortDescription'" value="eventVersion.shortDescription" maxLength="400" cssClass="smalltextarea" required="false"/>

					<%-- Description --%>   
					<ww:if test="this.getLabel('labels.internal.event.longDescriptionInfo') != 'labels.internal.event.longDescriptionInfo'">																	
						<a class="inputLink" href="#" onclick="return false;">
							<img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo">
								<ww:property value="this.getLabel('labels.internal.event.longDescriptionInfo')"/>
							</p>
						</a>
					</ww:if>    
					<calendar:textAreaField label="labels.internal.event.longDescription" name="'longDescription'" value="eventVersion.longDescription" cssClass="largetextarea" wysiwygToolbar="longDescription" required="false"/>
				</section>
			</fieldset>

			<fieldset>
				<legend class="arrow-up"><ww:property value="this.getLabel('labels.internal.event.dateHeader')"/></legend>  
				<section style="display:block">
					<ww:if test="this.getLabel('labels.internal.event.dateInfo') != 'labels.internal.event.dateInfo'">		
						<a class="inputLink" href="#" onclick="return false;">
							<img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.dateInfo')"/></p>
						</a>   
					</ww:if>
					
					<div class="fieldrow clearfix">
						<div class="fieldrow-column">
							<label id="labelStartDateTime" for="startDateTime">
								<span class="label-date">
									<ww:property value="this.getLabel('labels.internal.event.startDate')"/>
									<span class="redstar">*</span>
								</span>

								<input readonly id="startDateTime" name="startDateTime" value="<ww:property value="this.formatDate(event.startDateTime.time, 'yyyy-MM-dd')"/>" class="datefield" type="textfield">
								<img src="<%=request.getContextPath()%>/images/calendar.gif" id="trigger_startDateTime" style="border: 0px solid black; cursor: pointer;" title="<ww:property value="this.getLabel('labels.internal.event.datePicker.title')"/>">
								<img src="<%=request.getContextPath()%>/images/delete.gif" style="border: 0px solid black; cursor: pointer;" title="<ww:property value="this.getLabel('labels.internal.event.trash.title')"/>" onclick="document.getElementById('startDateTime').value = '';">			
							</label>

							<label id="startTime" for="startTime">
								<span class="label-time">
									<ww:property value="this.getLabel('labels.internal.event.startTime')"/>
								</span>
								<input name="startTime" value="<ww:if test="this.formatDate(event.startDateTime.time, 'HH:mm') != '12:34'"><ww:property value="this.formatDate(event.startDateTime.time, 'HH:mm')"/></ww:if>" class="hourfield" type="textfield" onblur="completeTime(this);">	
							</label>

							<ww:if test="#fieldErrors.startDateTime != null">
								<p class="errorMessage"><ww:property value="this.getLabel('#fieldErrors.startDateTime.get(0)')"/></p>
							</ww:if>																
						</div>


						<div class="fieldrow-column">
							<label id="labelEndDateTime" for="endDateTime">
								<span class="label-date">
									<ww:property value="this.getLabel('labels.internal.event.endDate')"/>
								</span>
								<input readonly id="endDateTime" name="endDateTime" value="<ww:property value="this.formatDate(event.endDateTime.time, 'yyyy-MM-dd')"/>" class="datefield" type="textfield">
								<img src="<%=request.getContextPath()%>/images/calendar.gif" id="trigger_endDateTime" style="border: 0px solid black; cursor: pointer;" title="<ww:property value="this.getLabel('labels.internal.event.datePicker.title')"/>">
								<img src="<%=request.getContextPath()%>/images/delete.gif" style="border: 0px solid black; cursor: pointer;" title="<ww:property value="this.getLabel('labels.internal.event.trash.title')"/>" onclick="document.getElementById('endDateTime').value = '';">
							</label>
							
							<label id="endTime" for="endTime">
								<span class="label-time">
									<ww:property value="this.getLabel('labels.internal.event.endTime')"/>
								</span>
								<input name="endTime" value="<ww:if test="this.formatDate(event.endDateTime.time, 'HH:mm') != '13:34'"><ww:property value="this.formatDate(event.endDateTime.time, 'HH:mm')"/></ww:if>" class="hourfield" type="textfield" onblur="completeTime(this);">					
							</label>
							
							<ww:if test="#fieldErrors.endDateTime != null">
								<p class="errorMessage"><ww:property value="this.getLabel('#fieldErrors.endDateTime.get(0)')"/></p>
							</ww:if>
						</div>
						
					</div>

					<%-- Location --%>
					<ww:if test="this.getLabel('labels.internal.event.locationInfo') != 'labels.internal.event.locationInfo'">
						<a class="inputLink" href="#" onclick="return false;">
							<img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.locationInfo')"/>
							</p>
						</a>
					</ww:if>
					
					<ww:if test="this.isActiveEventField('locationId')">
						<calendar:selectField label="labels.internal.event.location" name="'locationId'" multiple="true" value="locations" selectedValueSet="event.locations" headerItem="labels.internal.event.locationDefault" cssClass="listBox"/>
					</ww:if>


					<%-- Alternative location --%> 
					<ww:if test="this.isActiveEventField('alternativeLocation')">
						<ww:if test="eventVersion == null && alternativeEventVersion != null">
							<calendar:textField label="labels.internal.event.alternativeLocation" name="'alternativeLocation'" value="alternativeEventVersion.alternativeLocation" cssClass="longtextfield"/>
						</ww:if>
						<ww:else>
							<calendar:textField label="labels.internal.event.alternativeLocation" name="'alternativeLocation'" value="eventVersion.alternativeLocation" cssClass="longtextfield"/>
						</ww:else>
					</ww:if>
					
					<%-- Custom location --%>  
					<ww:if test="this.isActiveEventField('customLocation')">
						<ww:if test="eventVersion == null && alternativeEventVersion != null">
							<calendar:textField label="labels.internal.event.customLocation" name="'customLocation'" value="alternativeEventVersion.customLocation" cssClass="longtextfield"/>

						</ww:if>
						<ww:else>
							<calendar:textField label="labels.internal.event.customLocation" name="'customLocation'" value="eventVersion.customLocation" cssClass="longtextfield"/>
						</ww:else>
					</ww:if>
				</section>
			</fieldset>

			
			<fieldset>
				<legend class="arrow-up"><ww:property value="this.getLabel('labels.internal.event.organizerName')"/></legend>
				<section style="display:block;">				
					<%-- Organizer name --%> 
					<ww:if test="this.getLabel('labels.internal.event.organizerNameInfo') != 'labels.internal.event.organizerNameInfo'">		
						<a class="inputLink" href="#" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.organizerNameInfo')"/>
							</p>
						</a>
					</ww:if>
					 <ww:if test="this.isActiveEventField('organizerName')">
						<ww:if test="eventVersion == null && alternativeEventVersion != null">
							<calendar:textField label="labels.internal.event.organizerName" name="'organizerName'" value="alternativeEventVersion.organizerName" cssClass="longtextfield" required="false"/>
						</ww:if>



						<ww:else>
							<calendar:textField label="labels.internal.event.organizerName" name="'organizerName'" value="eventVersion.organizerName" cssClass="longtextfield" required="false"/>
						</ww:else>
					</ww:if>

					
					<%-- Homepage --%>
					 <ww:if test="this.isActiveEventField('eventUrl')">
						<ww:if test="eventVersion == null && alternativeEventVersion != null">
							<calendar:textField label="labels.internal.event.eventUrl" name="'eventUrl'" value="alternativeEventVersion.eventUrl" cssClass="longtextfield"/>
						</ww:if>
						<ww:else>
							<calendar:textField label="labels.internal.event.eventUrl" name="'eventUrl'" value="eventVersion.eventUrl" cssClass="longtextfield"/>
						</ww:else>
					</ww:if>
					
					<%-- Organized by UU (hidden and always selected)  --%>                    

					<ww:if test="this.isActiveEventField('isOrganizedByGU')">
						<input:hidden name="'isOrganizedByGU'" valueMap="isOrganizedByGUMap" selectedValues="isOrganizedByGU" />
					</ww:if>

					<%-- Contact name --%>  
		            <ww:if test="this.isActiveEventField('contactName')">
						<calendar:textField label="labels.internal.event.contactName" name="'contactName'" value="event.contactName" cssClass="longtextfield" required="true"/>
					</ww:if>

					<%-- Contact email --%>  
					<ww:if test="this.isActiveEventField('contactEmail')">
						<calendar:textField label="labels.internal.event.contactEmail" name="'contactEmail'" value="event.contactEmail" cssClass="longtextfield"/>
					</ww:if>

					<%-- Contact phone --%>   
					<ww:if test="this.isActiveEventField('contactPhone')">
						<calendar:textField label="labels.internal.event.contactPhone" name="'contactPhone'" value="event.contactPhone" cssClass="longtextfield"/>
					</ww:if>

				</section>
			</fieldset>

			<calendar:hasRole id="isCalendarOwner" roleName="CalendarOwner"/>
			<fieldset <c:if test="${!isCalendarOwner}" > style="display:none"</c:if>>
				<legend class="arrow-down"><ww:property value="this.getLabel('labels.internal.event.entryInfo')"/></legend>
				<section style="display:none">
					<p><ww:property value="this.getLabel('labels.internal.event.registrationInfo')"/></p>			
					<%-- Participants --%> 
					<ww:if test="this.getLabel('labels.internal.event.maximumParticipantsInfo') != 'labels.internal.event.maximumParticipantsInfo'">
						<a class="inputLink" href="#" onclick="return false;">
							<img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.maximumParticipantsInfo')"/></p>
						</a>
					</ww:if>

					<calendar:selectField label="labels.internal.event.entryForm" name="'entryFormId'" multiple="false" value="entryFormEventTypes" selectedValue="event.entryFormId" headerItem="Choose entry form" cssClass="listBox"/>
					
					<%-- Participation fee --%> 
					<ww:if test="this.isActiveEventField('price')">
						<calendar:textField label="labels.internal.event.price" name="'price'" value="event.price" cssClass="longtextfield"/>
					</ww:if>					

					<%-- Maximum number of participants --%> 
					<calendar:textField label="labels.internal.event.maximumParticipants" name="'maximumParticipants'" value="event.maximumParticipants" cssClass="longtextfield"/>

					<%-- Participation deadline --%>    
				     <div class="fieldrow">
						<label for="lastRegistrationDateTime">
							<ww:property value="this.getLabel('labels.internal.event.lastRegistrationDate')"/>						
							<input readonly id="lastRegistrationDateTime" name="lastRegistrationDateTime" value="<ww:property value="this.formatDate(event.lastRegistrationDateTime.time, 'yyyy-MM-dd')"/>" class="datefield" type="textfield">
							<img src="<%=request.getContextPath()%>/images/calendar.gif" id="trigger_lastRegistrationDateTime" style="border: 0px solid black; cursor: pointer;" title="<ww:property value="this.getLabel('labels.internal.event.datePicker.title')"/>">
							<img src="<%=request.getContextPath()%>/images/delete.gif" style="border: 0px solid black; cursor: pointer;" title="<ww:property value="this.getLabel('labels.internal.event.trash.title')"/>" onclick="document.getElementById('lastRegistrationDateTime').value = '';">			
							<input name="lastRegistrationTime" value="<ww:property value="this.formatDate(event.lastRegistrationDateTime.time, 'HH:mm')"/>" class="hourfield" type="textfield" onblur="completeTime(this);">
						</label>

						<ww:if test="#fieldErrors.lastRegistrationDateTime != null">
							<p class="errorMessage">
								<ww:property value="this.getLabel('#fieldErrors.lastRegistrationDateTime.get(0)')"/>
							</p>
						</ww:if>
					</div>
				</section>
			</fieldset>

			<fieldset>
				<legend class="arrow-up"><ww:property value="this.getLabel('labels.internal.event.topicFieldsHeader')"/></legend>
				<section style="display:block">
					<ww:if test="this.getLabel('labels.internal.event.topicFieldsInfo') != 'labels.internal.event.topicFieldsInfo'">		
						<a class="inputLink" href="#" onclick="return false;">
							<img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.topicFieldsInfo')"/></p>
						</a>
					</ww:if>
				
					<ww:set name="count" value="0"/>
					<ww:iterator value="attributes" status="rowstatus">
						<ww:set name="attribute" value="top"/>
						<ww:set name="title" value="top.getContentTypeAttribute('title').getContentTypeAttributeParameterValue().getLocalizedValueByLanguageCode('label', currentContentTypeEditorViewLanguageCode)" scope="page"/>
						<ww:set name="attributeName" value="this.concat('attribute_', top.name)"/>
						<ww:if test="#errorEvent != null">
							<ww:set name="attributeValue" value="this.getAttributeValue(#errorEvent.attributes, top.name)"/>


						</ww:if>
						<ww:else>
							<ww:set name="attributeValue" value="this.getAttributeValue(eventVersion.attributes, top.name)"/>
						</ww:else>
						
						<c:set var="required" value="false"/>
						<ww:iterator value="#attribute.validators" status="rowstatus">
							<ww:set name="validator" value="top"/>
							<ww:set name="validatorName" value="#validator.name"/>
							<ww:if test="#validatorName == 'required'">
								<c:set var="required" value="true"/>
							</ww:if>
						</ww:iterator>

			
						<input type="hidden" name="attributeName_<ww:property value="#count"/>" value="attribute_<ww:property value="top.name"/>"/>

			
						<ww:if test="#attribute.inputType == 'textfield'">
							<calendar:textField label="${title}" name="#attributeName" value="#attributeValue" required="${required}" cssClass="longtextfield"/>
						</ww:if>		

						<ww:if test="#attribute.inputType == 'textarea'">
							<calendar:textAreaField label="${title}" name="#attributeName" value="#attributeValue" required="${required}" cssClass="smalltextarea"/>
						</ww:if>		

						<ww:if test="#attribute.inputType == 'select'">
							<ww:set name="attributeValues" value="#attributeValue"/>
							<ww:if test="#attributeValue != null">
								<ww:set name="attributeValues" value="#attributeValue.split(',')"/>
							</ww:if>
							<calendar:selectField label="${title}" name="#attributeName" multiple="true" value="#attribute.contentTypeAttributeParameterValues" selectedValues="#attributeValues" required="${required}" cssClass="listBox"/>
						</ww:if>		

						<ww:if test="#attribute.inputType == 'radiobutton'">
							<calendar:radioButtonField label="${title}" name="#attributeName" valueMap="#attribute.contentTypeAttributeParameterValuesAsMap" selectedValue="#attributeValue" required="${required}"/>
						</ww:if>		

						<ww:if test="#attribute.inputType == 'checkbox'">
							<ww:set name="attributeValues" value="#attributeValue"/>
							<ww:if test="#attributeValue != null">
								<ww:set name="attributeValues" value="#attributeValue.split(',')"/>
							</ww:if>
							<calendar:checkboxField label="${title}" name="#attributeName" valueMap="#attribute.contentTypeAttributeParameterValuesAsMap" selectedValues="#attributeValues" required="${required}"/>
						</ww:if>		

						<ww:if test="#attribute.inputType == 'hidden'">
							<calendar:hiddenField name="#attributeName" value="#attributeValue"/>
						</ww:if>		

						<ww:set name="count" value="#count + 1"/>
					</ww:iterator>


					<ww:iterator value="event.owningCalendar.eventType.categoryAttributes" status="rowstatus">
						<ww:set name="categoryAttribute" value="top" scope="page"/>
						<ww:set name="categoryAttributeIndex" value="#rowstatus.index" scope="page"/>

						<ww:set name="selectedCategories" value="this.getEventCategories(top)"/>
						<c:set var="categoryAttributeName" value="categoryAttribute_${categoryAttribute.id}_categoryId"/>
						<input type="hidden" name="categoryAttributeId_<ww:property value="#rowstatus.index"/>" value="<ww:property value="top.id"/>"/>
						<calendar:selectField label="top.name" name="${categoryAttributeName}" multiple="true" value="top.category.getSortedChildren(languageCode)" selectedValues="getCategoryAttributeValues(top.id)" selectedValueList="#selectedCategories" cssClass="listBox" required="true"/>

					</ww:iterator>
				</section>
			</fieldset>

			
			<div class="confirm">
				<p>
					<input type="checkbox" name="agree" value="agree_terms" tabIndex="100">
					<ww:if test="this.getLabel('labels.internal.event.eventConfirm') == null">
						<ww:property value="this.getLabel('labels.internal.event.confirmMessageEdit')"/>
					</ww:if>
					<ww:property value="this.getLabel('labels.internal.event.eventConfirm')"/>
				</p>


			</div>  
			
            <input type="submit" value="<ww:property value="this.getLabel('labels.internal.event.updateButton')"/>" class="button save">
            
            <portlet:renderURL var="viewEventUrl">
                <portlet:param name="action" value="ViewEvent"/>
                <calendar:evalParam name="eventId" value="${eventId}"/>
                <calendar:evalParam name="calendarId" value="${calendarId}"/>
                <calendar:evalParam name="mode" value="${mode}"/>
            </portlet:renderURL>
        
            <input onclick="document.location.href='<c:out value="${viewEventUrl}"/>';" type="submit" value="<ww:property value="this.getLabel('labels.internal.applicationCancel')"/>" class="button">
    
        </form>		    
    </div>
</div>

<script type="text/javascript">
	<%-- Show and hide fieldset content --%>
	var legends = document.getElementsByTagName("legend");
	
	for(var i=0; i<legends.length; i++) {
		legends[i].addEventListener("click", showHide);
	};
		
	function showHide() {		
		<%-- Update the legend class --%>
		if (this.className == 'arrow-down') { 
			 this.className = 'arrow-up';
		} else {
			this.className = 'arrow-down';  
		};
		
		<%-- Show or hide the div --%>
		var sections = this.parentNode.getElementsByTagName("section");
		var section;

		if(sections.length > 0) {
			var section = sections[0];

			if(section.style.display == "block") {
				section.style.display = "none"
			}
			else {
				section.style.display = "block";
			}
		};
	};

    function validateTimes()
    {
    	var startTime 				= document.inputForm.startTime.value;
    	var endTime 				= document.inputForm.endTime.value;
    	var lastRegistrationTime	= document.inputForm.lastRegistrationTime.value;

    	if (startTime != "" && !validateTime(startTime))
    	{
    		alert("Felaktigt format\n Starttiden måste följa formatet hh:mm");
    		document.inputForm.startTime.focus();
    		return false;
    	}

    	if (endTime != "" && !validateTime(endTime))
    	{
    		alert("Felaktigt format\n Sluttiden måste följa formatet hh:mm");
    		document.inputForm.endTime.focus();
    		return false;
    	}

    	if (lastRegistrationTime != "" && !validateTime(lastRegistrationTime))
    	{
    		document.inputForm.lastRegistrationTime.focus();
    		return false;
    	}
        
    	if (!document.inputForm.agree.checked) 
		{
			document.inputForm.agree.focus();
			alert("<ww:property value="this.getLabel('labels.internal.event.confirmationRequiredMessage')"/>");
			return false;
		}
    	return true;
    }

	function validateTime(aTimeString)
    {
    	var myRegexp 	= /^[0-9]{2}:[0-9]{2}$/;
    	var match 		= myRegexp.test(aTimeString);
    	return match;
    }
	
	function completeTime(textfield)
    {
    	if(textfield.value.length == 2)
    	{
    		textfield.value = textfield.value + ":00";
    	}
    }
	
	<%-- Validate form --%>
    function validateForm() {
    	document.inputForm.title.value = document.inputForm.name.value;
    	return validateTimes();
    }

    Calendar.setup({
        inputField     :    "startDateTime",     <%-- id of the input field --%>
        ifFormat       :    "%Y-%m-%d",      <%-- format of the input field --%>
        button         :    "trigger_startDateTime",  <%-- trigger for the calendar (button ID) --%>
        align          :    "BR",           <%-- alignment (defaults to "Bl") --%>
        singleClick    :    true,
        firstDay  	   : 	1
    });

	<%--  Enable click event on start date time field --%>
    Calendar.setup({
        inputField     :    "startDateTime",      <%-- id of the input field --%>
        ifFormat       :    "%Y-%m-%d",       <%-- format of the input field --%>
        button         :    "startDateTime",   <%-- trigger for the calendar (startDateTime) --%>
        align          :    "BR",            <%-- alignment (defaults to "Bl") --%>
        singleClick    :    true,
        firstDay  	   : 	1
    });

    Calendar.setup({
        inputField     :    "endDateTime",     <%-- id of the input field --%>
        ifFormat       :    "%Y-%m-%d",      <%-- format of the input field --%>
        button         :    "trigger_endDateTime",   <%-- trigger for the calendar (button ID) --%>
        align          :    "BR",            <%-- alignment (defaults to "Bl") --%>
        singleClick    :    true,
        firstDay  	   : 	1
    });

    Calendar.setup({
        inputField     :    "endDateTime",      <%-- id of the input field --%>
        ifFormat       :    "%Y-%m-%d",      <%-- format of the input field --%>
        button         :    "endDateTime",   <%-- trigger for the calendar (button ID) --%>
        align          :    "BR",            <%-- alignment (defaults to "Bl") --%>
        singleClick    :    true,
        firstDay  	   : 	1
    });

	Calendar.setup({
        inputField     :    "lastRegistrationDateTime",     <%-- id of the input field --%>
        ifFormat       :    "%Y-%m-%d",      <%-- format of the input field --%>
        button         :    "trigger_lastRegistrationDateTime",   <%-- trigger for the calendar (button ID) --%>
        align          :    "BR",            <%-- alignment (defaults to "Bl") --%>
        singleClick    :    true,
        firstDay  	   : 	1    
    });

    Calendar.setup({
        inputField     :    "lastRegistrationDateTime",     <%-- id of the input field --%>
        ifFormat       :    "%Y-%m-%d",      <%-- format of the input field --%>
        button         :    "lastRegistrationDateTime",   <%-- trigger for the calendar (button ID) --%>
        align          :    "BR",            <%-- alignment (defaults to "Bl") --%>
        singleClick    :    true,
        firstDay  	   : 	1    
    });
</script>

<%@ include file="adminFooter.jsp" %>