<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<c:set var="activeNavItem" value="Events" scope="page"/>
<c:set var="activeEventSubNavItem" value="NewEvent" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>

<%@ include file="eventSubFunctionMenu.jsp" %>

<script type="text/javascript">


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
        
    	if (!document.inputForm.agree.checked) {
              document.inputForm.agree.focus();
               alert("Du m\u00E5ste fylla i kryssrutan f\u00F6r att g\u00E5 vidare");

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

	var state = 'block';
	function showhide(layer_ref) {

		if (state == 'block') {
			state = 'none';
		}
		else {
			state = 'block';
		}
		if (document.all) { //IS IE 4 or 5 (or 6 beta)
			eval( "document.all." + layer_ref + ".style.display = state");
		}
		if (document.layers) { //IS NETSCAPE 4 or below
			document.layers[layer_ref].display = state;
		}
		if (document.getElementById &&!document.all) {
			hza = document.getElementById(layer_ref);
			hza.style.display = state;
		}
	}


    function validateForm() {

      

    	document.inputForm.title.value = document.inputForm.name.value;
    	return validateTimes();
    }

</script>
<ww:property value="allowedIPs"/>

<div class="mainCol">
<div class="portlet_margin">

	<portlet:actionURL var="createEventUrl">
		<portlet:param name="action" value="CreateEvent"/>
	</portlet:actionURL>	

	<form id="createEvent" name="inputForm" method="POST" action="<c:out value="${createEventUrl}"/>" onsubmit="return validateForm();">
		<input type="hidden" name="calendarId" value="<ww:property value="calendarId"/>"/>

  		<input type="hidden" name="mode" value="<ww:property value="mode"/>"/>
		<input type="hidden" name="date" value="<ww:property value="date"/>"/>
		<input type="hidden" name="time" value="<ww:property value="time"/>"/>
        
<fieldset>
	<legend><a href="#" onclick="showhide('divGrundinfo');return false;">Grundinformation</a></legend>  
	<div id="divGrundinfo" style="display: block;">
    
		<div class="columnLeft">
            <%-- språk --%>           
            <a class="inputLink" href="#" onclick="return false;" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infotecken.gif" /><p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.languageInfo')"/></p>
            </a>
            <calendar:selectField label="labels.internal.event.language" name="'versionLanguageId'" multiple="false" value="languages" selectedValue="versionLanguageId" required="true" headerItem="Select which language to create the event in" cssClass="listBox" tabIndex="1"/>
            
            <%--<calendar:hiddenField name="versionLanguageId" value="3"/>--%>
            
    		<%-- evenemangets namn --%>           
            <a class="inputLink" href="#" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infotecken.gif" /><p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.nameInfo')"/></p></a>	
            <calendar:textField label="labels.internal.event.name" name="'name'" value="event.name" cssClass="longtextfield" required="true" tabIndex="2"/>
            		
            <input type="hidden" name="title" id="title"/>
            
            <%-- vem som får delta / målgrupp --%>            		
                    <ww:if test="this.isActiveEventField('isInternal')">
                        <calendar:radioButtonField label="labels.internal.event.isInternal" name="'isInternal'"  valueMap="internalEventMap" selectedValue="isInternal" tabIndex="3"/>
                    </ww:if>
                    
             <%-- föreläsare --%>            
                <ww:if test="this.isActiveEventField('lecturer')">
                    <calendar:textAreaField label="labels.internal.event.lecturer" name="'lecturer'" value="event.lecturer" cssClass="smalltextarea" tabIndex="4"/>
                </ww:if>

        </div>
		
        <div class="columnRight">
        
    	<%-- kort beskrivning --%>            
            <a class="inputLink" href="#" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infotecken.gif" /><p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.shortDescriptionInfo')"/></p></a>
                <calendar:textAreaField label="labels.internal.event.shortDescription" name="'shortDescription'" value="event.shortDescription" cssClass="smalltextarea" wysiwygToolbar="shortDescription" required="false" tabIndex="5"/>
        
        
        <%-- beskrivning --%>            
            <a class="inputLink" href="#" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infotecken.gif" /><p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.longDescriptionInfo')"/></p></a>
                <calendar:textAreaField label="labels.internal.event.longDescription" name="'longDescription'" value="event.longDescription" cssClass="largetextarea" wysiwygToolbar="longDescription" required="false" tabIndex="6"/>     
        
        </div>
        
    </div>
</fieldset>

<fieldset>
	<legend><a href="#" onclick="showhide('divTidPlats');">Tid och plats</a></legend>  
	<div id="divTidPlats" style="display: block;">
    
		<div class="columnLeft">
			 <a class="inputLink" href="#" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infotecken.gif" /><p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.dateInfo')"/></p></a>   
                    <div class="fieldrow">	
				 
                        <label id="labelStartDateTime" for="startDateTime"><ww:property value="this.getLabel('labels.internal.event.startDate')"/></label><span class="redstar">*</span><label id="startTime" for="startTime"><ww:property value="this.getLabel('labels.internal.event.startTime')"/></label>
                        <ww:if test="#fieldErrors.startDateTime != null"><span class="errorMessage"><ww:property value="this.getLabel('#fieldErrors.startDateTime.get(0)')"/></span></ww:if><br />
                        <input readonly id="startDateTime" name="startDateTime" value="<ww:property value="startDateTime"/>" class="datefield" type="textfield" tabIndex="7">
                        <img src="<%=request.getContextPath()%>/images/calendar.gif" id="trigger_startDateTime" style="border: 0px solid black; cursor: pointer;" title="Date selector">
                        <img src="<%=request.getContextPath()%>/images/delete.gif" style="border: 0px solid black; cursor: pointer;" title="Remove value" onclick="document.getElementById('startDateTime').value = '';">
                        <input name="startTime" value="<ww:if test="startTime != '12:34'"><ww:property value="startTime"/></ww:if>" class="hourfield" type="textfield" onblur="completeTime(this);" tabIndex="8">
                    </div>
					         <a class="inputLink" href="#" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infotecken.gif" /><p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.dateInfo')"/></p></a> 
              <div class="fieldrow">
	                      
                        <label id="labelEndDateTime" for="endDateTime"><ww:property value="this.getLabel('labels.internal.event.endDate')"/></label><!--<span class="redstar">*</span>--><label id="endTime" for="endTime"><ww:property value="this.getLabel('labels.internal.event.endTime')"/></label>
                        <ww:if test="#fieldErrors.endDateTime != null"><span class="errorMessage"><ww:property value="this.getLabel('#fieldErrors.endDateTime.get(0)')"/></span></ww:if><br />
                        <input readonly id="endDateTime" name="endDateTime" value="<ww:property value="endDateTime"/>" class="datefield" type="textfield" tabIndex="9">
                        <img src="<%=request.getContextPath()%>/images/calendar.gif" id="trigger_endDateTime" style="border: 0px solid black; cursor: pointer;" title="Date selector">
                        <img src="<%=request.getContextPath()%>/images/delete.gif" style="border: 0px solid black; cursor: pointer;" title="Remove value" onclick="document.getElementById('endDateTime').value = '';">
                        <input name="endTime" value="<ww:if test="endTime != '13:34'"><ww:property value="endTime"/></ww:if>" class="hourfield" type="textfield" onblur="completeTime(this);" tabIndex="10">
                    </div>
            

        </div>
		
        <div class="columnRight">
    	<%-- plats --%>            
			<a class="inputLink" href="#" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infotecken.gif" /><p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.locationInfo')"/></p></a>
            <ww:if test="this.isActiveEventField('locationId')">
                <calendar:selectField label="labels.internal.event.location" name="'locationId'" multiple="true" value="locations" headerItem="Anger annan plats ist&#228;llet nedan" cssClass="listBox" tabIndex="11"/>
            </ww:if>
       	   
            
  	  	<%-- annan plats --%>            		
            <ww:if test="this.isActiveEventField('alternativeLocation')">
                <calendar:textField label="labels.internal.event.alternativeLocation" name="'alternativeLocation'" value="event.alternativeLocation" cssClass="longtextfield" tabIndex="12"/>
            </ww:if>
            
    	<%-- lokal --%>            
            <ww:if test="this.isActiveEventField('customLocation')">
                <calendar:textField label="labels.internal.event.customLocation" name="'customLocation'" value="event.customLocation" cssClass="longtextfield" tabIndex="13"/>
            </ww:if>    
        </div>
        
    </div>
</fieldset>

<fieldset>
	<legend><a href="#" onclick="showhide('divArrangor');return false;"><ww:property value="this.getLabel('labels.internal.event.organizerName')"/></a></legend>  
	<div id="divArrangor" style="display: block;">
    
		<div class="columnLeft">
    	<%-- arrangör --%>            
			<a class="inputLink" href="#" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infotecken.gif" /><p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.organizerNameInfo')"/></p></a>
            <ww:if test="this.isActiveEventField('organizerName')">
                <calendar:textField label="labels.internal.event.organizerName" name="'organizerName'" value="event.organizerName" cssClass="longtextfield" required="false" tabIndex="14"/>
            </ww:if>
            
            
        <%-- hemsida --%>            
        	<ww:if test="this.isActiveEventField('eventUrl')">
                    <calendar:textField label="labels.internal.event.eventUrl" name="'eventUrl'" value="event.eventUrl" cssClass="longtextfield" tabIndex="15"/>
                </ww:if>
                
        <%-- organiserat av UU --%>                    
                <ww:if test="this.isActiveEventField('isOrganizedByGU')">
                    <input:hidden name="'isOrganizedByGU'" valueMap="isOrganizedByGUMap" selectedValues="isOrganizedByGU" />
                </ww:if>
        </div>
		
        <div class="columnRight">
    	<%-- kontaktperson --%>            
            <a class="inputLink" href="#" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infotecken.gif" /><p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.contactNameInfo')"/></p></a>         
            <ww:if test="this.isActiveEventField('contactName')">
                <calendar:textField label="labels.internal.event.contactName" name="'contactName'" value="event.contactName" cssClass="longtextfield" required="true" tabIndex="17"/>
            </ww:if>

        <%-- kontaktperson mail --%>            
                <ww:if test="this.isActiveEventField('contactEmail')">
                    <calendar:textField label="labels.internal.event.contactEmail" name="'contactEmail'" value="event.contactEmail" cssClass="longtextfield" tabIndex="18"/>
                </ww:if>
        
        <%-- kontaktperson telefon --%>            
                <ww:if test="this.isActiveEventField('contactPhone')">
                    <calendar:textField label="labels.internal.event.contactPhone" name="'contactPhone'" value="event.contactPhone" cssClass="longtextfield" tabIndex="19"/>
                </ww:if>

        </div>
        
    </div>
</fieldset>
 
<calendar:hasRole id="isCalendarOwner" roleName="CalendarOwner"/>

<fieldset <c:if test="${!isCalendarOwner}" > style="display:none"</c:if>>
	
	<legend><a href="#" onclick="showhide('anmalningsUppgifter');return false;"><ww:property value="this.getLabel('labels.internal.event.entryInfo')"/></a></legend>  
	
	<div id="anmalningsUppgifter" style="display: none;">
		<p><ww:property value="this.getLabel('labels.internal.event.registrationInfo')"/></p>
		<div class="columnLeft">
			<%-- anmälningsformulär --%>            
			<a class="inputLink" href="#" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infotecken.gif" /><p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.maximumParticipantsInfo')"/></p></a>
	
			<calendar:selectField label="labels.internal.event.entryForm" name="'entryFormId'" multiple="false" value="entryFormEventTypes" selectedValue="event.entryFormId" cssClass="listBox" tabIndex="20"/>
			
			<%-- avgift --%>            
			<ww:if test="this.isActiveEventField('price')">
				<calendar:textField label="labels.internal.event.price" name="'price'" value="event.price" cssClass="longtextfield" tabIndex="21"/>
			</ww:if>
		</div>
		<div class="columnRight">    
			<%-- max antal deltagare --%>            
			<calendar:textField label="labels.internal.event.maximumParticipants" name="'maximumParticipants'" value="event.maximumParticipants" cssClass="longtextfield" tabIndex="22"/>
		
			<%-- sista anmälningsdag och tid --%>            
			<label for="lastRegistrationDateTime"><ww:property value="this.getLabel('labels.internal.event.lastRegistrationDate')"/></label><!--<span class="redstar">*</span>-->
			<ww:if test="#fieldErrors.lastRegistrationDateTime != null"><span class="errorMessage"><ww:property value="this.getLabel('#fieldErrors.lastRegistrationDateTime.get(0)')"/></span></ww:if><br />
			<input readonly id="lastRegistrationDateTime" name="lastRegistrationDateTime" value="<ww:property value="lastRegistrationDateTime"/>" class="datefield" type="textfield" tabIndex="23">
			<img src="<%=request.getContextPath()%>/images/calendar.gif" id="trigger_lastRegistrationDateTime" style="border: 0px solid black; cursor: pointer;" title="Date selector">
			<img src="<%=request.getContextPath()%>/images/delete.gif" style="border: 0px solid black; cursor: pointer;" title="Remove value" onclick="document.getElementById('lastRegistrationDateTime').value = '';">
			<input name="lastRegistrationTime" value="<ww:property value="lastRegistrationTime"/>" class="hourfield" type="textfield" onblur="completeTime(this);" tabIndex="24">
		</div>
	</div>

</fieldset>


<fieldset>
	<legend><a href="#" onclick="showhide('publicering');return false;">Publicering av evenemang</a></legend>  
	<div id="publicering" style="display: block;">

        
	<a class="inputLink" href="#" onclick="return false;"><img class="infocon" src="<%=request.getContextPath()%>/images/infotecken.gif" /><p class="labelInfo"><ww:property value="this.getLabel('labels.internal.event.contactNameInfo')"/></p></a>   
    
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

		<!--<hr>-->
	<c:set var="tabCounter" value="25"/>
		<ww:iterator value="calendar.eventType.categoryAttributes" status="rowstatus">
	
			<ww:set name="categoryAttribute" value="top" scope="page"/>
			<ww:set name="categoryAttributeIndex" value="#rowstatus.index" scope="page"/>
			<input type="hidden" name="categoryAttributeId_<ww:property value="#rowstatus.index"/>" value="<ww:property value="top.id"/>"/>
			<c:set var="categoryAttributeName" value="categoryAttribute_${categoryAttribute.id}_categoryId"/>
			<calendar:selectField label="top.name" name="${categoryAttributeName}" multiple="true" value="top.category.getSortedChildren(languageCode)" selectedValues="getCategoryAttributeValues(top.id)" tabIndex="${tabCounter}" cssClass="listBox" required="true"/>
			<c:set var="tabCounter" value="${tabCounter +1}"/>
		</ww:iterator>
        
		<%--<calendar:selectField label="labels.internal.event.participants" name="participantUserName" multiple="true" value="infogluePrincipals" cssClass="listBox"/>--%>

	</div>

</fieldset>

		<div style="height:10px"></div>
			<div class="confirm">
				<p>
                    <input type="checkbox" name="agree" value="agree_terms" tabIndex="100">

                    <ww:if test="this.getLabel('labels.internal.event.eventConfirm') == null">
                    	Jag har granskat ifyllda uppgifter och vill publicera evenemanget
                    </ww:if>
                    
                    <ww:property value="this.getLabel('labels.internal.event.eventConfirm')"/>
         		</p>
			</div>            

		<input type="submit" value="<ww:property value="this.getLabel('labels.internal.event.createButton')"/>" class="button submit" tabIndex="101">
		<input type="button" onclick="history.back();" value="<ww:property value="this.getLabel('labels.internal.applicationCancel')"/>" class="button cancel" tabIndex="102">
	</form>
</div>
</div>

<div style="clear:both"></div>

<script type="text/javascript">
    Calendar.setup({
        inputField     :    "startDateTime",     // id of the input field
        ifFormat       :    "%Y-%m-%d",      // format of the input field
        button         :    "trigger_startDateTime",  // trigger for the calendar (button ID)
        align          :    "BR",           // alignment (defaults to "Bl")
        singleClick    :    true,
        firstDay  	   : 	1
    });
</script>
<%--  Enable click event on start date time field --%>
<script type="text/javascript">
    Calendar.setup({
        inputField     :    "startDateTime",     // id of the input field
        ifFormat       :    "%Y-%m-%d",      // format of the input field
        button         :    "startDateTime",  // trigger for the calendar (input field)
        align          :    "BR",           // alignment (defaults to "Bl")
        singleClick    :    true,
        firstDay  	   : 	1
    });
</script>

<script type="text/javascript">
    Calendar.setup({
        inputField     :    "endDateTime",     // id of the input field
        ifFormat       :    "%Y-%m-%d",      // format of the input field
        button         :    "trigger_endDateTime",  // trigger for the calendar (button ID)
        align          :    "BR",           // alignment (defaults to "Bl")
        singleClick    :    true,
        firstDay       : 	1
    });
</script>

<%--  Enable click event on start date time field --%>
<script type="text/javascript">
    Calendar.setup({
        inputField     :    "endDateTime",     // id of the input field
        ifFormat       :    "%Y-%m-%d",      // format of the input field
        button         :    "endDateTime",  // trigger for the calendar (input field)
        align          :    "BR",           // alignment (defaults to "Bl")
        singleClick    :    true,
        firstDay       : 	1
    });
</script>

<script type="text/javascript">
    Calendar.setup({
        inputField     :    "lastRegistrationDateTime",     // id of the input field
        ifFormat       :    "%Y-%m-%d",      // format of the input field
        button         :    "trigger_lastRegistrationDateTime",  // trigger for the calendar (button ID)
        align          :    "BR",           // alignment (defaults to "Bl")
        singleClick    :    true,
        firstDay  	   : 	1
    });
</script>

<%--  Enable click event on start date time field --%>
<script type="text/javascript">
    Calendar.setup({
        inputField     :    "lastRegistrationDateTime",     // id of the input field
        ifFormat       :    "%Y-%m-%d",      // format of the input field
        button         :    "lastRegistrationDateTime",  // trigger for the calendar (input field)
        align          :    "BR",           // alignment (defaults to "Bl")
        singleClick    :    true,
        firstDay  	   : 	1
    });
</script>
<%@ include file="adminFooter.jsp" %>