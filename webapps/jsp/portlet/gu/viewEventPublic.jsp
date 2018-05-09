<%@ taglib uri="webwork" prefix="ww" %>
<%@ taglib uri="http://java.sun.com/portlet" prefix="portlet"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="calendar" prefix="calendar" %>

<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<portlet:defineObjects/>

<ww:set name="event" value="event"/>
<ww:set name="event" value="event" scope="page"/>
<ww:set name="eventVersion" value="this.getEventVersion('#event')"/>
<ww:set name="eventVersion" value="this.getEventVersion('#event')" scope="page"/>
<ww:set name="languageCode" value="this.getLanguageCode()"/>
<ww:if test="#languageCode == 'en'">
	<ww:set name="dateFormat" value="'M/d/yyyy'"/>
	<ww:set name="timeFormat" value="'h:mm aaa'"/>
</ww:if>
<ww:else>
	<ww:set name="dateFormat" value="'yyyy-MM-dd'"/>
	<ww:set name="timeFormat" value="'HH:mm'"/>
</ww:else>

<ww:set name="startDate" value="this.formatDate(event.startDateTime.time, #dateFormat)"/>
<ww:set name="endDate" value="this.formatDate(event.endDateTime.time, #dateFormat)"/>

<ww:if test="#attr.xmlRequest != 'true'">
	
	<%-- Determine if this is a disputation --%>
	<ww:set name="isDisputation" value="false"/>
	<ww:iterator value="event.owningCalendar.eventType.categoryAttributes">
		<ww:if test="top.name == 'Evenemangstyp' || top.name == 'Eventtyp'">
			<ww:set name="selectedCategories" value="this.getEventCategories(top)"/>
			<ww:iterator value="#selectedCategories">
				<ww:set name="isDisputation" value="#isDisputation or top.getInternalName() == 'Disputation'"/>
			</ww:iterator>
		</ww:if>
	</ww:iterator>
	<c:set var="isDisputation"><ww:property value="#isDisputation"/></c:set>
	<!-- Calendar start -->
	<div class="vevent"> 	
		<h1 class="summary"><ww:property value="#eventVersion.name"/></h1>
			<ww:if test="this.getICalUrl() != null">
				<a class="btn" href="<ww:property value='this.getICalUrl()'/>"/><ww:property value="this.getLabel('labels.internal.event.addToCalendar')"/></a>
			</ww:if>

		<div class="size2of3 unit">
			<ul class="calinfo">

				<li class="dtstartend">
					<!-- tid -->
					<ww:property value="this.getLabel('labels.public.event.dateLabel')"/>: <ww:property value="this.getFormattedStartEndDateTime(event)"/>
				</li>
				<c:set var="location">
					<li><!-- location -->
						<ww:property value="this.getLabel('labels.public.event.locationLabel')"/>:
						<span class="location">
							<ww:if test="#eventVersion.alternativeLocation != null && #eventVersion.alternativeLocation != ''">
								<ww:property value="#eventVersion.alternativeLocation"/>		
								<c:set var="locationExists" value="true"/>
							</ww:if>
							<ww:else>
								<ww:iterator value="event.locations">
									<ww:set name="location" value="top"/>
									<ww:property value="#location.getLocalizedName(#languageCode, 'sv')"/>		
									<c:set var="locationExists" value="true"/>
								</ww:iterator>
							</ww:else>
							<ww:if test="#eventVersion.customLocation != null && #eventVersion.customLocation != ''">
								<ww:property value="#eventVersion.customLocation"/>
								<c:set var="locationExists" value="true"/>
							</ww:if>
						</span>
					</li>
				</c:set>
				
				<c:if test="${locationExists}">
					<c:out value="${location}" escapeXml="false"/> 
				</c:if>

				<ww:if test="#eventVersion.lecturer != null && #eventVersion.lecturer != ''">
					<li>
						<c:choose>
							<c:when test="${isDisputation}">
								<ww:property value="this.getLabel('labels.public.event.doctoralStudentLabel')"/>:
							</c:when>
							<c:otherwise>
								<ww:property value="this.getLabel('labels.public.event.lecturerLabel')"/>:
							</c:otherwise>
						</c:choose>
						
						<ww:property value="#eventVersion.lecturer"/>
					</li> 
				</ww:if>
				
				<ww:if test="#eventVersion.eventUrl != null && #eventVersion.eventUrl != ''">
					<li>
						<a class="url uid webPage" href="<ww:property value="#eventVersion.eventUrl"/>">
						<c:choose>
							<c:when test="${isDisputation}">
								<ww:property value="this.getLabel('labels.public.event.aboutTheDisputationUrl')"/>
							</c:when>
							<c:otherwise>
								<ww:property value="this.getLabel('labels.public.event.eventUrl')"/>
							</c:otherwise>
						</c:choose>
						
						</a>
					</li>
				</ww:if>
		
				<ww:if test="#eventVersion.organizerName != null && #eventVersion.organizerName != ''">
					<li><!-- organizer name -->
						<ww:property value="this.getLabel('labels.public.event.organizerLabel')"/>:
						<span class="organizer">
							<ww:property value="#eventVersion.organizerName"/>
						</span>
					</li>
				</ww:if>

				<ww:if test="event.lastRegistrationDateTime != null">
					<li><!-- sista registrerings datum -->
						<ww:property value="this.getLabel('labels.public.event.lastRegistrationDateLabel')"/>: 
						<ww:property value="this.formatDate(event.lastRegistrationDateTime.time, #dateFormat)"/> <ww:property value="this.getLabel('labels.public.event.klockLabel')"/>. <ww:property value="this.formatDate(event.lastRegistrationDateTime.time, #timeFormat)"/>.
					</li>
				</ww:if>
				
				<ww:if test="event.price != null && event.price != ''">
					<li><!-- pris -->
						<ww:property value="this.getLabel('labels.public.event.feeLabel')"/>: <ww:property value="event.price"/>
					</li>
				</ww:if>

				<!-- kontaktinformation -->
				<ww:if test="event.contactEmail != null && event.contactEmail != ''">
					<li>
						<ww:if test="event.contactName != null && event.contactName != ''">
							<ww:property value="this.getLabel('labels.public.event.contactPersonLabel')"/>:
							<a href="mailto:<ww:property value="event.contactEmail"/>"><ww:property value="event.contactName"/></a>
						</ww:if>
						<ww:else>
							<ww:property value="this.getLabel('labels.public.event.contactPersonLabel')"/>:
							<a href="mailto:<ww:property value="event.contactEmail"/>"><ww:property value="event.contactEmail"/></a>
						</ww:else>
					</li>
				</ww:if>
				<ww:else>
					<ww:if test="event.contactName != null && event.contactName != ''">
						<li><ww:property value="this.getLabel('labels.public.event.contactPersonLabel')"/>: <ww:property value="event.contactName"/></li>
					</ww:if>
				</ww:else>

				<ww:if test="event.contactPhone != null && event.contactPhone != ''">
					<li><!-- kontakttelefon -->
						<ww:property value="this.getLabel('labels.public.event.phoneLabel')"/>: <ww:property value="event.contactPhone"/>
					</li>
				</ww:if>
				
				<!-- attribut -->
				<ww:set name="count" value="0"/>
				<ww:iterator value="attributes" status="rowstatus">
					<ww:set name="attribute" value="top" scope="page"/>
					<ww:set name="title" value="top.getContentTypeAttribute('title').getContentTypeAttributeParameterValue().getLocalizedValueByLanguageCode('label', currentContentTypeEditorViewLanguageCode)" scope="page"/>
					<ww:set name="attributeName" value="this.concat('attribute_', top.name)"/>
					<ww:set name="attributeValue" value="this.getAttributeValue(event.attributes, top.name)"/>
					<li>
						<calendar:textValue label="${title}" value="#attributeValue"/>
					</li>
					<ww:set name="count" value="#count + 1"/>
				</ww:iterator>
				<ww:if test="event.maximumParticipants != null && event.maximumParticipants != 0">
					<li>
					<ww:property value="this.getLabel('labels.public.event.numberOfSeatsLabel')"/>: <ww:property value="event.maximumParticipants"/> (<ww:property value="this.getLabel('labels.public.event.ofWhichLabel')"/> <ww:property value="event.entries.size()"/> <ww:property value="this.getLabel('labels.public.event.isBookedLabel')"/>)
					</li>
				</ww:if>
				<ww:if test="event.lastRegistrationDateTime != null">
					<li>	
					<ww:if test="event.lastRegistrationDateTime.time.time > now.time.time">
						<ww:set name="eventId" value="eventId" scope="page"/>
						<ww:if test="event.maximumParticipants == null || event.maximumParticipants > event.entries.size()">
							<portlet:renderURL var="createEntryRenderURL" portletMode="view">
								<calendar:evalParam name="action" value="CreateEntry!inputPublicGU"/>
								<calendar:evalParam name="eventId" value="${eventId}"/>
							</portlet:renderURL>
							<a class="url uid signUp" href="<c:out value="${createEntryRenderURL}"/>"><ww:property value="this.getLabel('labels.public.event.signUp')"/></a>
						</ww:if>
						<ww:else>
							<ww:property value="this.getLabel('labels.internal.event.signUpForThisOverbookedEvent')"/><br/>
							<portlet:renderURL var="createEntryRenderURL">
								<calendar:evalParam name="action" value="CreateEntry!inputPublicGU"/>
								<calendar:evalParam name="eventId" value="${eventId}"/>
							</portlet:renderURL>
							<a class="url uid signUp" href="<c:out value="${createEntryRenderURL}"/>"><ww:property value="this.getLabel('labels.public.event.signUp')"/></a>
						</ww:else>
					</ww:if>
					<ww:else>
						<ww:property value="this.getLabel('labels.public.event.registrationExpired')"/>
					</ww:else>
					</li>
				</ww:if>

			<ww:if test="event.owningCalendar.eventType.categoryAttributes.size() > 0">
				<ww:iterator value="event.owningCalendar.eventType.categoryAttributes">
					<ww:if test="top.name == 'Evenemangstyp' || top.name == 'Eventtyp'">
						<ww:set name="showCategoryAttributes" value="true"/>
					</ww:if>
				</ww:iterator>
			</ww:if> 
			<ww:else>
				<ww:set name="showCategoryAttributes" value="false"/>
			</ww:else>
			
			<ww:if test="#showCategoryAttributes == true">
				<li>
					<span class="category">
						<ww:iterator value="event.owningCalendar.eventType.categoryAttributes">
							<ww:if test="top.name == 'Evenemangstyp' || top.name == 'Eventtyp'">
								<ww:set name="selectedCategories" value="this.getEventCategories(top)"/>
								<ww:set name="categoryAttribute" value="top.getInternalName()"/>
								<ww:iterator value="#selectedCategories" status="rowstatus">
									<a class="url uid local" href="<ww:property value="#attr.filteredListUrl"/>?categoryAttribute=<ww:property value="#categoryAttribute"/>&categoryNames=<ww:property value="top.getInternalName()"/>&calendarFilterDisplayName=<ww:property value="top.getLocalizedName(#languageCode, 'sv')"/>">
									<ww:property value="top.getLocalizedName(#languageCode, 'sv')"/></a><ww:if test="!#rowstatus.last">, </ww:if>
								</ww:iterator>
							</ww:if>
						</ww:iterator>
					</span>
				</li>
			</ww:if>
			</ul>

			<ww:if test="#eventVersion.decoratedShortDescription != null && #eventVersion.decoratedShortDescription != ''">
				<p class="description">
					<ww:property value="#eventVersion.decoratedShortDescription"/>
				</p>
			</ww:if>
			<ww:if test="#eventVersion.decoratedLongDescription != null && #eventVersion.decoratedLongDescription != ''">
				<div class="longer_description">
					<ww:property value="#eventVersion.decoratedLongDescription"/>
				</div>
			</ww:if>
			<ww:set name="attachedFiles" value="this.getResourcesWithAssetKey('BifogadFil')"/>
			<ww:if test="#attachedFiles.size() > 0">
				<h2 class="additionInfoHeader"><ww:property value="this.getLabel('labels.public.event.additionalInfoLabel')"/></h2>
					<ul class="is-unstyled">
						<ww:iterator value="#attachedFiles">
							<li>
								<ww:set name="resourceId" value="top.id" scope="page"/>
								<calendar:resourceUrl id="url" resourceId="${resourceId}"/>
								<ww:if test="fileName.indexOf('.pdf') > -1">
									<ww:set name="resourceClass" value="'pdf'"/>
								</ww:if>
								<ww:if test="fileName.indexOf('.doc') > -1">
									<ww:set name="resourceClass" value="'worddoc'"/>
								</ww:if>
								<ww:if test="fileName.indexOf('.xls') > -1">
									<ww:set name="resourceClass" value="'excel'"/>
								</ww:if>
								<ww:if test="fileName.indexOf('.ppt') > -1">
									<ww:set name="resourceClass" value="'ppt'"/>
								</ww:if>
								<a class="url uid <ww:property value="#resourceClass"/>" href="<c:out value="${url}"/>" target="_blank"><ww:property value="shortendFileName"/></a>
							</li>
						</ww:iterator>
					</ul>
			</ww:if>
			
		</div>	<%-- end div size2of3 unit --%>
		
		<ww:set name="puffImage" value="this.getResourceUrl(event, 'DetaljBild')"/>
		<ww:if test="#puffImage != null">
			<div class="size1of3 unit last">
				<img src="<ww:property value='#puffImage'/>" alt="<ww:property value='#eventVersion.name'/>" >
			</div>
		</ww:if>
		
	</div> <%-- end div --%>
</ww:if>
<ww:else>
	<xml>
		<event>
			<title><ww:property value="#eventVersion.name" escape="true"/></title>
			<date><ww:property value="#startDate" escape="true"/></date>
			
			<startDate><ww:property value="#startDate"/></startDate>
			<endDate><ww:property value="#endDate"/></endDate>
			
			<subjects>
				<ww:iterator value="event.owningCalendar.eventType.categoryAttributes">
					<ww:if test="top.name == '�mnesomr�de' || top.name == '�mnesomr�den'">
						<ww:set name="categoryName" value="top.name"/>
						<ww:set name="selectedCategories" value="this.getEventCategories(top)"/>
						<ww:iterator value="#selectedCategories" status="rowstatus">
							<subject><ww:property value="top.getLocalizedName(#languageCode, 'sv')" escape="true"/></subject>
						</ww:iterator>
					</ww:if>
		   		</ww:iterator>
			</subjects>
			<keywords>
		   		<ww:iterator value="event.owningCalendar.eventType.categoryAttributes">
					<ww:if test="top.name == 'Evenemangstyp' || top.name == 'Eventtyp'">
					<ww:set name="selectedCategories" value="this.getEventCategories(top)"/>
					<ww:set name="categoryAttribute" value="top.getInternalName()"/>
					<ww:iterator value="#selectedCategories" status="rowstatus">
						<keyword><ww:property value="top.getLocalizedName(#languageCode, 'sv')" escape="true"/></keyword>
					</ww:iterator>
					</ww:if>
	   			</ww:iterator>
		   	</keywords>
			<short-description>
				<ww:if test="#eventVersion.decoratedShortDescription != null && #eventVersion.decoratedShortDescription != ''">
					<ww:property value="#eventVersion.decoratedShortDescription" escape="true"/>
				</ww:if>
			</short-description>
			<name><ww:if test="event.contactName != null && event.contactName != ''"><ww:property value="event.contactName" escape="true"/></ww:if></name>
			<email><ww:if test="event.contactEmail != null && event.contactEmail != ''"><ww:property value="event.contactEmail" escape="true"/></ww:if></email>
			<organiser>
				<ww:if test="#eventVersion.organizerName != null && #eventVersion.organizerName != ''"><ww:property value="#eventVersion.organizerName" escape="true"/></ww:if>
			</organiser>
			<versions>
				<ww:iterator value="event.entries">
					<version><ww:property value="top.class" escape="true"/></version>
				</ww:iterator>
			</versions>
		</event>
	</xml>
</ww:else>
<!-- Calendar End -->