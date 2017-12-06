<%@ taglib uri="webwork" prefix="ww" %>
<%@ taglib uri="http://java.sun.com/portlet" prefix="portlet"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="calendar" prefix="calendar" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<portlet:defineObjects/>

<c:catch var="exception1">

<ww:set name="languageCode" value="this.getLanguageCode()"/>
<ww:set name="events" value="events" scope="page"/>
<ww:if test="#languageCode == 'en'">
	<ww:set name="dateFormat" value="'M/d/yyyy'"/>
	<ww:set name="shortDateFormat" value="'MMMM d'"/>
	<ww:set name="timeFormat" value="'h:mm aaa'"/>
</ww:if>
<ww:else>
	<ww:set name="dateFormat" value="'yyyy-MM-dd'"/>
	<ww:set name="shortDateFormat" value="'d MMMM'"/>
	<ww:set name="timeFormat" value="'HH:mm'"/>
</ww:else>
<%-- 
<ww:if test="#attr.filteredListUrl.indexOf('?') > -1">
	<c:set var="currentPageDelim" value="&"/>
</ww:if>
<ww:else>
	<c:set var="currentPageDelim" value="?"/>
</ww:else>
--%>

<script type="text/javascript">
	 function toggle_SlottedVisibility(id, a_id) {
       var e = document.getElementById(id);
       var ae = document.getElementById(a_id);
       if(e.style.display != 'none') {
           e.style.display = 'none';
           ae.innerHTML = '<img src="http://clamator.its.uu.se/uploader/67/show.png">';
       }
       else {
           e.style.display = 'block';
           ae.innerHTML = '<img src="http://clamator.its.uu.se/uploader/67/hide.png">';
       }
    }
</script>

<calendar:setToList id="eventList" set="${events}"/>

<c:set var="eventsItems" value="${eventList}"/>
<ww:if test="events != null && events.size() > 0">
	<ww:set name="numberOfItems" value="numberOfItems" scope="page"/>
	<c:if test="${empty numberOfItems}">
		<c:set var="numberOfItems" value="10"/>
	</c:if>
	<c:set var="currentSlot" value="${param.currentSlot}"/>
	<c:if test="${currentSlot == null}">
		<c:set var="currentSlot" value="1"/>
	</c:if>
	<calendar:slots visibleElementsId="eventsItems" visibleSlotsId="indices" lastSlotId="lastSlot" elements="${eventList}" currentSlot="${currentSlot}" slotSize="${numberOfItems}" slotCount="10"/>
</ww:if>

</c:catch>

<c:if test="${exception1 != null}">
	An error occurred: <c:out value="${exception1}"/>
</c:if>

<c:catch var="exception2">

<H1><ww:property value="this.getLabel('labels.public.calendar.calendarLabel')"/></H1>
<!-- Calendar start -->
<div class="calendar">   
	<ww:if test="#attr.detailUrl.indexOf('?') > -1">
		<c:set var="delim" value="&"/>
	</ww:if>
	<ww:else>
		<c:set var="delim" value="?"/>
	</ww:else>

	<ww:iterator value="#attr.eventsItems" status="rowstatus">
	
		<ww:set name="event" value="top"/>
		<ww:set name="eventId" value="id" scope="page"/>
		<ww:set name="eventVersion" value="this.getEventVersion('#event')"/>
		<ww:set name="eventVersion" value="this.getEventVersion('#event')" scope="page"/>
		
		<portlet:renderURL var="eventDetailUrl">
			<portlet:param name="action" value="ViewEvent!publicGU"/>
			<portlet:param name="eventId" value='<%= pageContext.getAttribute("eventId").toString() %>'/>
		</portlet:renderURL>
		
   		
   		     
		<!-- Record Start -->
		<div class="vevent">
			<ww:set name="startDate" value="this.getFormattedStartEndDateTime(top)"/>
			
			<c:set var="startDateFormatted"><ww:property value="#startDate"/></c:set>
			<h1><c:out value="${startDateFormatted}" /></h1>
			<c:set var="startHourMinute"><ww:property value="this.formatDate(top.startDateTime.getTime(), 'HH:mm')"/></c:set>
			<%
				String startDateString = (String)pageContext.getAttribute("startDateFormatted");
				String startHourMinute = (String)pageContext.getAttribute("startHourMinute");
				startHourMinute = startHourMinute.trim();
				SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm");
				
				Date startDate = df.parse(startDateString);
				if( startHourMinute.compareTo("12:34") != 0 ) {
					df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
				}
				else {
					df = new SimpleDateFormat("yyyy-MM-dd'T'00:00");
				}
				startDateString = df.format(startDate);
				
				pageContext.setAttribute("isoStartDate", startDateString);
			%>
			<p>
			<span class="dtstart">
			 	<!-- tid -->
			 	<abbr class="value" title="<c:out value="${isoStartDate}"/>"><ww:property value="this.formatDate(top.startDateTime.getTime(), #shortDateFormat)"/></abbr>

                                   
                                     <abbr class="value" title="<c:out value="${isoStartDate}"/>"><ww:property value="this.formatDate(event.startDateTime.getTime(), #dateFormat)"/></abbr>
                              
                              
                        </span>
                                    
                                    <ww:set name="startDay" value="this.formatDate(top.startDateTime.getTime(), 'yyyy-MM-dd')"/>
                                    <ww:set name="endDay" value="this.formatDate(top.endDateTime.getTime(), 'yyyy-MM-dd')"/>

                                    
                                    <ww:if test="this.formatDate(top.startDateTime.time, 'HH:mm') != '12:34'">, <ww:property value="this.getLabel('labels.public.event.klockLabel')"/></ww:if>
                                        
					<span class="value"><ww:property value="this.formatDate(top.startDateTime.getTime(), #timeFormat)"/></span>
					
				 	<ww:if test="#startDay != #endDay">
						<ww:if test="this.formatDate(top.endDateTime.time, 'HH:mm') != '23:59'">
						- <span class="dtend"><ww:property value="this.formatDate(top.endDateTime.getTime(), #shortDateFormat)"/></span>
						</ww:if>
					</ww:if>
			 	
			
			</p>

                         <span class="dtend">
                             <ww:property value="this.formatDate(top.endDateTime.getTime(), 'yyyy-MM-dd HH:mm')"/></span>
			<%-- 
			<span class="dtstart" title="<ww:property value="this.formatDate(top.startDateTime.getTime(), #dateFormat)"/>"><ww:property value="this.formatDate(top.startDateTime.getTime(), #dateFormat)"/> 
			--%>
				<%-- 
				<ww:if test="this.formatDate(top.startDateTime.time, 'HH:mm') != '12:34'">
				<ww:property value="this.getLabel('labels.public.event.klockLabel')"/> <ww:property value="this.formatDate(top.startDateTime.getTime(), #timeFormat)"/>
				</ww:if>
			</span>
			--%>
			
			<h3 class="summary"><a href="<ww:property value="#attr.detailUrl"/><c:out value="${delim}"/>eventId=<ww:property value="top.id"/>" title="<ww:property value="#eventVersion.name"/>"><ww:property value="#eventVersion.name"/></a></h3>
			
			<span class="category">
				<ww:iterator value="top.owningCalendar.eventType.categoryAttributes">
					<ww:if test="top.name == 'Evenemangstyp' || top.name == 'Eventtyp'">
						<ww:set name="categoryAttribute" value="top.getInternalName()"/>
						<ww:set name="selectedCategories" value="this.getEventCategories('#event', top)"/>
						<ww:iterator value="#selectedCategories" status="rowstatus">
							<ww:set name="internalName" value="top.getInternalName()"/>
							<%-- 
							<a class="url uid" href="<ww:property value="#attr.filteredListUrl"/>
							<c:out value="${currentPageDelim}"/>categoryAttribute=<ww:property value="#categoryAttribute"/>
							&categoryNames=<ww:property value="top.getInternalName()"/>">
							--%>
							<ww:property value="top.getLocalizedName(#languageCode, 'sv')"/><ww:if test="!#rowstatus.last">, </ww:if>
							<%-- </a> --%>
						</ww:iterator>
					</ww:if>
		   		</ww:iterator>
			</span>
			
			<div class="description">
				<ww:property value="#eventVersion.shortDescription"/><br />
			</div>
			
			<%--
			<a href="<ww:property value="#attr.detailUrl"/><c:out value="${delim}"/>eventId=<ww:property value="top.id"/>" title="<ww:property value="#eventVersion.title"/>"><img src="http://clamator.its.uu.se/uploader/67/show.png"></a>
			
			<ww:if test="#eventVersion.decoratedLongDescription != ''">
				<a class="url uid" id="longDescriptionId<ww:property value="top.id"/>A" href="javascript: toggle_SlottedVisibility('longDescriptionId<ww:property value="top.id"/>', 'longDescriptionId<ww:property value="top.id"/>A');"><img src="http://clamator.its.uu.se/uploader/67/show.png"></a>
				
				<p id="longDescriptionId<ww:property value="top.id"/>" class="longer_description" style="display: none">
					<ww:property value="#eventVersion.decoratedLongDescription"/>
				</p>
			</ww:if>
			--%>
				<a class="url uid show" id="longDescriptionId<ww:property value="top.id"/>A" href="javascript: toggle_SlottedVisibility('longDescriptionId<ww:property value="top.id"/>', 'longDescriptionId<ww:property value="top.id"/>A');"><img src="http://clamator.its.uu.se/uploader/67/show.png"></a>
				<div id="longDescriptionId<ww:property value="top.id"/>" style="display: none">
					<ul>
						<!-- Plats -->
						<c:set var="location">
						<li>
							<ww:property value="this.getLabel('labels.public.event.locationLabel')"/>:
							<span class="location">
							<ww:if test="#eventVersion.alternativeLocation != null && #eventVersion.alternativeLocation != ''">
								<ww:property value="#eventVersion.alternativeLocation"/>		
				      			<c:set var="locationExists" value="true"/>
							</ww:if>
							<ww:else>
				  				<ww:iterator value="top.locations">
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
						
						<!-- Föreläsare -->
						<ww:if test="#eventVersion.lecturer != null && #eventVersion.lecturer != ''">
							<li>
								<ww:property value="this.getLabel('labels.public.event.lecturerLabel')"/>: <ww:property value="#eventVersion.lecturer"/>
							</li> 
						</ww:if>
						
						<!-- Webbsida -->
						<ww:if test="#eventVersion.eventUrl != null && #eventVersion.eventUrl != ''">
							<li><a class="url uid webpage" href="<ww:property value="#eventVersion.eventUrl"/>"><ww:property value="this.getLabel('labels.public.event.eventUrl ')"/></a></li>
						</ww:if>
						
						<!--  Arrangör -->
						<ww:if test="#eventVersion.organizerName != null && #eventVersion.organizerName != ''">
				   			<li><!-- organizer name -->
				   				<ww:property value="this.getLabel('labels.public.event.organizerLabel')"/>: <ww:property value="#eventVersion.organizerName"/>
				   			</li>
						</ww:if>
						
						<!--  Kontaktperson -->
						<ww:if test="top.contactEmail != null && top.contactEmail != ''">
							<li>
							<ww:if test="top.contactName != null && top.contactName != ''">
								<ww:property value="this.getLabel('labels.public.event.contactPersonLabel')"/>:
								<a href="mailto:<ww:property value="top.contactEmail"/>"><ww:property value="top.contactName"/></a>
							</ww:if>
							<ww:else>
								<ww:property value="this.getLabel('labels.public.event.contactPersonLabel')"/>:
								<a href="mailto:<ww:property value="top.contactEmail"/>"><ww:property value="top.contactEmail"/></a>
							</ww:else>
							</li>
						</ww:if>
						<ww:else>
							<ww:if test="top.contactName != null && top.contactName != ''">
								<li><ww:property value="this.getLabel('labels.public.event.contactPersonLabel')"/>: <ww:property value="top.contactName"/></li>
							</ww:if>
						</ww:else>
						
						<!--  Evenemangstyp -->
						<ww:iterator value="top.owningCalendar.eventType.categoryAttributes">
						<ww:if test="top.name == 'Evenemangstyp' || top.name == 'Eventtyp'">
							<li>
							<ww:set name="categoryAttribute" value="top.getInternalName()"/><ww:set name="selectedCategories" value="this.getEventCategories('#event', top)"/>
							<ww:iterator value="#selectedCategories" status="rowstatus">
								<ww:set name="internalName" value="top.getInternalName()"/>
								<ww:property value="top.getLocalizedName(#languageCode, 'sv')"/><ww:if test="!#rowstatus.last">, </ww:if>
							</ww:iterator>
							</li>
						</ww:if>
			   			</ww:iterator>
					</ul>
					<ww:if test="#eventVersion.decoratedLongDescription != ''">
						<div class="longer_description" >
							<ww:property value="#eventVersion.decoratedLongDescription"/>
						</div>
						<br/>
					</ww:if>
					<a href="<ww:property value="#attr.detailUrl"/><c:out value="${delim}"/>eventId=<ww:property value="top.id"/>"><ww:property value="this.getLabel('labels.public.event.toEventLink')"/></a>
			<%-- 
			<p>
			<span class="calFactLabel"><ww:property value="this.getLabel('labels.public.event.locationLabel')"/>:</span>
			<ww:if test="#eventVersion.alternativeLocation != null && #eventVersion.alternativeLocation != ''">
				<ww:property value="#eventVersion.alternativeLocation"/>
			</ww:if>
			<ww:else>
				<ww:iterator value="top.locations" status="rowstatus">
					<ww:property value="top.getLocalizedName(#languageCode,'sv')"/><ww:if test="!#rowstatus.last">, </ww:if>
				</ww:iterator>
			</ww:else>
			<ww:if test="#eventVersion.customLocation != null && #eventVersion.customLocation != ''">
				- <ww:property value="#eventVersion.customLocation"/>
			</ww:if>
			
			<br /></p>
	        <ww:set name="puffImage" value="this.getResourceUrl(event, 'PuffBild')"/>
			<ww:if test="#puffImage != null">
			<img src="<ww:property value="#puffImage"/>" class="img_calendar_event"/>
			</ww:if>
			<p><ww:property value="#eventVersion.shortDescription"/></p>
			<ww:if test="#eventVersion.lecturer != null && #eventVersion.lecturer != ''">
			<p><span class="calFactLabel"><ww:property value="this.getLabel('labels.public.event.lecturerLabel')"/>:</span> <ww:property value="#eventVersion.lecturer"/></p>
			</ww:if>
			--%>
		</div>
		</div>
		<!-- Record End -->
	</ww:iterator>

<ww:if test="events != null && events.size() > 0">
	<br/>
	<p><strong><ww:property value="this.getLabel('labels.public.event.slots.pageLabel')"/> <c:out value="${currentSlot}"/> <ww:property value="this.getLabel('labels.public.event.slots.ofLabel')"/> <c:out value="${lastSlot}"/></strong>&nbsp;</p>                       
	
	<!-- slot navigator -->
	<c:if test="${lastSlot != 1}">
		<div class="prev_next">
			<c:if test="${currentSlot gt 1}">
				<c:set var="previousSlotId" value="${currentSlot - 1}"/>
				<portlet:renderURL var="firstUrl">
					<portlet:param name="action" value="ViewEventList!listSlottedGU"/>
					<portlet:param name="currentSlot" value="1"/>
				</portlet:renderURL>
				<portlet:renderURL var="previousSlot">
					<portlet:param name="action" value="ViewEventList!listSlottedGU"/>
					<portlet:param name="currentSlot" value='<%= pageContext.getAttribute("previousSlotId").toString() %>'/>
				</portlet:renderURL>
				
				<a href="<c:out value='${firstUrl}'/>" class="number" title="<ww:property value="this.getLabel('labels.public.event.slots.firstPageTitle')"/>"><ww:property value="this.getLabel('labels.public.event.slots.firstPageLabel')"/></a>
				<a href="<c:out value='${previousSlot}'/>" title="<ww:property value="this.getLabel('labels.public.event.slots.previousPageTitle')"/>" class="number">&laquo;</a>
			</c:if>
			<c:forEach var="slot" items="${indices}" varStatus="count">
				<c:if test="${slot == currentSlot}">
					<span class="number"><c:out value="${slot}"/></span>
				</c:if>
				<c:if test="${slot != currentSlot}">
					<c:set var="slotId" value="${slot}"/>
					<portlet:renderURL var="url">
						<portlet:param name="action" value="ViewEventList!listSlottedGU"/>
						<portlet:param name="currentSlot" value='<%= pageContext.getAttribute("slotId").toString() %>'/>
					</portlet:renderURL>

					<a href="<c:out value='${url}'/>" title="<ww:property value="this.getLabel('labels.public.event.slots.pageLabel')"/> <c:out value='${slot}'/>" class="number"><c:out value="${slot}"/></a>
				</c:if>
			</c:forEach>
			<c:if test="${currentSlot lt lastSlot}">
				<c:set var="nextSlotId" value="${currentSlot + 1}"/>
				<portlet:renderURL var="nextSlotUrl">
					<portlet:param name="action" value="ViewEventList!listSlottedGU"/>
					<portlet:param name="currentSlot" value='<%= pageContext.getAttribute("nextSlotId").toString() %>'/>
				</portlet:renderURL>
						
				<a href="<c:out value='${nextSlotUrl}'/>" title="<ww:property value="this.getLabel('labels.public.event.slots.nextPageTitle')"/>" class="number">&raquo;</a>
			</c:if>
		</div>
	</c:if>

</ww:if>
<ww:else>
	
	<ww:if test="events == null || events.size() == 0">
		<p><ww:property value="this.getLabel('labels.public.event.slots.noMatchesLabel')"/> <!--"<ww:property value="#visibleCategoryName"/>"--></p>
	</ww:if>

</ww:else>
	
</div>

</c:catch>

<c:if test="${exception2 != null}">
	An error occurred: <c:out value="${exception2}"/>
</c:if>
<!-- Calendar End -->  