<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Events" scope="page"/>
<c:set var="activeEventSubNavItem" value="NewEvent" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<%@ include file="eventSubFunctionMenu.jsp" %>



<ww:property value="allowedIPs"/>


<div class="mainCol">
	<div class="portlet_margin">

		<portlet:actionURL var="createEventUrl">
			<portlet:param name="action" value="CreateEvent"/>
		</portlet:actionURL>	

		<form id="createEvent" class="create-event" name="inputForm" method="POST" action="<c:out value="${createEventUrl}"/>" onsubmit="return validateForm();">
			<input type="hidden" name="calendarId" value="<ww:property value="calendarId"/>"/>


			<input type="hidden" name="mode" value="<ww:property value='mode'/>"/>
			<input type="hidden" name="date" value="<ww:property value='date'/>"/>
			<input type="hidden" name="time" value="<ww:property value='time'/>"/>
			
			<fieldset>
				<legend class="arrow-up"><ww:property value="this.getLabel('labels.internal.event.baseInfoHeader')"/></legend>  
				<section style="display:block">
				
					<%-- Language --%> 
					<ww:if test="this.getLabel('labels.internal.event.languageInfo') != 'labels.internal.event.languageInfo'">					
						<a class="inputLink" href="#" onclick="return false;" onclick="return false;">
							<img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo">
								<ww:property value="this.getLabel('labels.internal.event.languageInfo')"/>
							</p>
						</a>
					</ww:if>
					<calendar:selectField label="labels.internal.event.language" name="'versionLanguageId'" multiple="false" value="languages" selectedValue="versionLanguageId" required="true" headerItem="Select which language to create the event in" cssClass="listBox" tabIndex="1"/>
										
					<%-- Event title --%>
					<ww:if test="this.getLabel('labels.internal.event.nameInfo') != 'labels.internal.event.nameInfo'">							
						<a class="inputLink" href="#" onclick="return false;">
							<img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo">
								<ww:property value="this.getLabel('labels.internal.event.nameInfo')"/>
							</p>
						</a>
					</ww:if>
					<calendar:textField label="labels.internal.event.name" name="'name'" value="event.name" cssClass="longtextfield" required="true" tabIndex="2"/>
							
					<input type="hidden" name="title" id="title"/>
					
					<%-- Internal or open --%>           		
					<ww:if test="this.isActiveEventField('isInternal')">
						<calendar:radioButtonField label="labels.internal.event.isInternal" name="'isInternal'"  valueMap="internalEventMap" selectedValue="isInternal" tabIndex="3"/>
					</ww:if>
					
					<%-- Lecturer --%>            
					<ww:if test="this.isActiveEventField('lecturer')">
						<calendar:textAreaField label="labels.internal.event.lecturer" name="'lecturer'" value="event.lecturer" cssClass="smalltextarea" tabIndex="4"/>
					</ww:if>
					
					<%-- Short description --%>  
					<ww:if test="this.getLabel('labels.internal.event.shortDescriptionInfo') != 'labels.internal.event.shortDescriptionInfo'">												
						<a class="inputLink" href="#" onclick="return false;">
							<img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo">
								<ww:property value="this.getLabel('labels.internal.event.shortDescriptionInfo')"/>
							</p>
						</a>
					</ww:if>
					<calendar:textAreaField label="labels.internal.event.shortDescription" name="'shortDescription'" maxLength="400" value="event.shortDescription" cssClass="smalltextarea" required="false" tabIndex="5"/>

					<%-- Description --%>   
					<ww:if test="this.getLabel('labels.internal.event.longDescriptionInfo') != 'labels.internal.event.longDescriptionInfo'">																	
						<a class="inputLink" href="#" onclick="return false;">
							<img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo">
								<ww:property value="this.getLabel('labels.internal.event.longDescriptionInfo')"/>
							</p>
						</a>
					</ww:if>
					<calendar:textAreaField label="labels.internal.event.longDescription" name="'longDescription'" value="event.longDescription" cssClass="largetextarea" wysiwygToolbar="longDescription" required="false" tabIndex="6"/>     
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
								<input readonly id="startDateTime" name="startDateTime" value="<ww:property value='startDateTime'/>" class="datefield" type="textfield" tabIndex="7">
								<img src="<%=request.getContextPath()%>/images/calendar.gif" id="trigger_startDateTime" style="border: 0px solid black; cursor: pointer;" title="<ww:property value="this.getLabel('labels.internal.event.datePicker.title')"/>">
								<img src="<%=request.getContextPath()%>/images/delete.gif" style="border: 0px solid black; cursor: pointer;" title="<ww:property value="this.getLabel('labels.internal.event.trash.title')"/>" onclick="document.getElementById('startDateTime').value = '';">
							</label>
							
							<label id="startTime" for="startTime">
								<span class="label-time"><ww:property value="this.getLabel('labels.internal.event.startTime')"/></span>
								<input name="startTime" value="<ww:if test="startTime != '12:34'"><ww:property value="startTime"/></ww:if>" class="hourfield" type="textfield" onblur="completeTime(this);" tabIndex="8">
							</label>
							
							<ww:if test="#fieldErrors.startDateTime != null">
								<span class="errorMessage"><ww:property value="this.getLabel('#fieldErrors.startDateTime.get(0)')"/></span>
							</ww:if>
						</div>
						
						<div class="fieldrow-column">
							<label id="labelEndDateTime" for="endDateTime">
								<span class="label-date">
									<ww:property value="this.getLabel('labels.internal.event.endDate')"/>
								</span>
								<input readonly id="endDateTime" name="endDateTime" value="<ww:property value='endDateTime'/>" class="datefield" type="textfield" tabIndex="9">
								<img src="<%=request.getContextPath()%>/images/calendar.gif" id="trigger_endDateTime" style="border: 0px solid black; cursor: pointer;" title="<ww:property value="this.getLabel('labels.internal.event.datePicker.title')"/>">
								<img src="<%=request.getContextPath()%>/images/delete.gif" style="border: 0px solid black; cursor: pointer;" title="<ww:property value="this.getLabel('labels.internal.event.trash.title')"/>" onclick="document.getElementById('endDateTime').value = '';">
							</label>
							
							<label id="endTime" for="endTime">
								<span class="label-time">
									<ww:property value="this.getLabel('labels.internal.event.endTime')"/>
								</span>
								<input name="endTime" value="<ww:if test="endTime != '13:34'"><ww:property value="endTime"/></ww:if>" class="hourfield" type="textfield" onblur="completeTime(this);" tabIndex="10">
							</label>
							
							<ww:if test="#fieldErrors.endDateTime != null">
								<span class="errorMessage"><ww:property value="this.getLabel('#fieldErrors.endDateTime.get(0)')"/></span>
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
						<calendar:selectField label="labels.internal.event.location" name="'locationId'" multiple="true" value="locations" headerItem="labels.internal.event.locationDefault" cssClass="listBox" tabIndex="11"/>
					</ww:if>
					
					<%-- Alternative location --%>           		
					<ww:if test="this.isActiveEventField('alternativeLocation')">
						<calendar:textField label="labels.internal.event.alternativeLocation" name="'alternativeLocation'" value="event.alternativeLocation" cssClass="longtextfield" tabIndex="12"/>
					</ww:if>
					
					<%-- Custom location --%>             
					<ww:if test="this.isActiveEventField('customLocation')">
						<calendar:textField label="labels.internal.event.customLocation" name="'customLocation'" value="event.customLocation" cssClass="longtextfield" tabIndex="13"/>
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
						<calendar:textField label="labels.internal.event.organizerName" name="'organizerName'" value="event.organizerName" cssClass="longtextfield" required="false" tabIndex="14"/>
					</ww:if>						
						
					<%-- Homepage --%>           
					<ww:if test="this.isActiveEventField('eventUrl')">
						<calendar:textField label="labels.internal.event.eventUrl" name="'eventUrl'" value="event.eventUrl" cssClass="longtextfield" tabIndex="15"/>
					</ww:if>
							
					<%-- Organized by UU (hidden and always selected)  --%>                    
					<ww:if test="this.isActiveEventField('isOrganizedByGU')">
						<input:hidden name="'isOrganizedByGU'" valueMap="isOrganizedByGUMap" selectedValues="isOrganizedByGU" />
					</ww:if>
					
					<%-- Contact name --%>
					<ww:if test="this.getLabel('labels.internal.event.contactNameInfo') != 'labels.internal.event.contactNameInfo'">		
						<a class="inputLink" href="#" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infoicon.png" />
							<p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.contactNameInfo')"/>
							</p>
						</a> 
					</ww:if>
					<ww:if test="this.isActiveEventField('contactName')">
						<calendar:textField label="labels.internal.event.contactName" name="'contactName'" value="event.contactName" cssClass="longtextfield" required="true" tabIndex="17"/>
					</ww:if>

					<%-- Contact email --%>            
					<ww:if test="this.isActiveEventField('contactEmail')">
						<calendar:textField label="labels.internal.event.contactEmail" name="'contactEmail'" value="event.contactEmail" cssClass="longtextfield" tabIndex="18"/>
					</ww:if>

					<%-- Contact phone --%>            
					<ww:if test="this.isActiveEventField('contactPhone')">
						<calendar:textField label="labels.internal.event.contactPhone" name="'contactPhone'" value="event.contactPhone" cssClass="longtextfield" tabIndex="19"/>
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
			
					<calendar:selectField label="labels.internal.event.entryForm" name="'entryFormId'" multiple="false" value="entryFormEventTypes" selectedValue="event.entryFormId" cssClass="listBox" tabIndex="20"/>
					
					<%-- Participation fee --%>            
					<ww:if test="this.isActiveEventField('price')">
						<calendar:textField label="labels.internal.event.price" name="'price'" value="event.price" cssClass="longtextfield" tabIndex="21"/>
					</ww:if>

					<%-- Maximum number of participants --%>            
					<calendar:textField label="labels.internal.event.maximumParticipants" name="'maximumParticipants'" value="event.maximumParticipants" cssClass="longtextfield" tabIndex="22"/>

					<%-- Participation deadline --%>
					<div class="fieldrow">					
						<label for="lastRegistrationDateTime">
							<ww:property value="this.getLabel('labels.internal.event.lastRegistrationDate')"/>
							<input readonly id="lastRegistrationDateTime" name="lastRegistrationDateTime" value="<ww:property value="lastRegistrationDateTime"/>" class="datefield" type="textfield" tabIndex="23">
							<img src="<%=request.getContextPath()%>/images/calendar.gif" id="trigger_lastRegistrationDateTime" style="border: 0px solid black; cursor: pointer;" title="<ww:property value="this.getLabel('labels.internal.event.datePicker.title')"/>">
							<img src="<%=request.getContextPath()%>/images/delete.gif" style="border: 0px solid black; cursor: pointer;" title="<ww:property value="this.getLabel('labels.internal.event.trash.title')"/>" onclick="document.getElementById('lastRegistrationDateTime').value = '';">
							<input name="lastRegistrationTime" value="<ww:property value="lastRegistrationTime"/>" class="hourfield" type="textfield" onblur="completeTime(this);" tabIndex="24">
						</label>

						<ww:if test="#fieldErrors.lastRegistrationDateTime != null">
							<span class="errorMessage">
								<ww:property value="this.getLabel('#fieldErrors.lastRegistrationDateTime.get(0)')"/>
							</span>
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
						<ww:set name="attributeValue" value="this.getAttributeValue(#errorEvent.attributes, top.name)"/>

						<ww:property value="#attributeValue"/>
						
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

					<c:set var="tabCounter" value="25"/>
					<ww:iterator value="calendar.eventType.categoryAttributes" status="rowstatus">
						<ww:set name="categoryAttribute" value="top" scope="page"/>
						<ww:set name="categoryAttributeIndex" value="#rowstatus.index" scope="page"/>
						<input type="hidden" name="categoryAttributeId_<ww:property value="#rowstatus.index"/>" value="<ww:property value="top.id"/>"/>
						<c:set var="categoryAttributeName" value="categoryAttribute_${categoryAttribute.id}_categoryId"/>
						<calendar:selectField label="top.name" name="${categoryAttributeName}" multiple="true" value="top.category.getSortedChildren(languageCode)" selectedValues="getCategoryAttributeValues(top.id)" tabIndex="${tabCounter}" cssClass="listBox" required="true"/>
						<c:set var="tabCounter" value="${tabCounter +1}"/>
					</ww:iterator>
				</section>
			</fieldset>

			<div class="confirm">
				<p>
					<input type="checkbox" name="agree" value="agree_terms" tabIndex="100">
					<ww:if test="this.getLabel('labels.internal.event.eventConfirm') == null">
						<ww:property value="this.getLabel('labels.internal.event.confirmMessage')"/>
					</ww:if>
					<ww:property value="this.getLabel('labels.internal.event.eventConfirm')"/>
				</p>
			</div>            

			<input type="submit" value="<ww:property value="this.getLabel('labels.internal.event.createButton')"/>" class="button submit save" tabIndex="101">
			<input type="button" onclick="history.back();" value="<ww:property value="this.getLabel('labels.internal.applicationCancel')"/>" class="button cancel" tabIndex="102">
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