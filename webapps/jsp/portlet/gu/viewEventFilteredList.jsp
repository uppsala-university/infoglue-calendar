<%@ taglib uri="webwork" prefix="ww" %>
<%@ taglib uri="http://java.sun.com/portlet" prefix="portlet"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="calendar" prefix="calendar" %>

<%@ page import="com.opensymphony.xwork.util.OgnlValueStack" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.GregorianCalendar" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Locale" %>
<%@ page import="org.infoglue.common.util.VisualFormatter" %>

<portlet:defineObjects/>

<ww:set name="locale" value="this.getLocale()"/>
<ww:set name="languageCode" value="this.getLanguageCode()"/>
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

<%
	VisualFormatter vf = new VisualFormatter();
	OgnlValueStack stack = (OgnlValueStack)request.getAttribute("webwork.valueStack");
	Locale locale = (Locale)stack.findValue("locale");
%>

<script type="text/javascript">
	 function toggle_visibility(id, a_id) {
       var e = document.getElementById(id);
       var ae = document.getElementById(a_id);
       if(e.style.display != 'none') {
           e.style.display = 'none';
            ae.innerHTML = '<img src="http://clamator.its.uu.se/uploader/67/show.png" />';
       }
       else {
           e.style.display = 'block';
           ae.innerHTML = '<img src="http://clamator.its.uu.se/uploader/67/hide.png" />';
       }
    }
</script>


<div class="calendar">   

	<ww:set name="detailUrl" value="#attr.detailUrl"/>
	<ww:if test="#detailUrl.indexOf('?') > -1">
		<c:set var="delim" value="&"/>
	</ww:if>
	<ww:else>
		<c:set var="delim" value="?"/>
	</ww:else>
	
	<%--
	<ww:set name="currentPageUrl" value="#attr.currentPageUrl"/>
	<ww:if test="#currentPageUrl.indexOf('?') > -1">
		<c:set var="currentPageDelim" value="&"/>
	</ww:if>
	<ww:else>
		<c:set var="currentPageDelim" value="?"/>
	</ww:else>
	--%>

	<%
		int currentMonth = -1;
		String month, firstLetterMonth, monthRemaining;
	%>
	<ww:iterator value="events" status="rowstatus">
		<%
		GregorianCalendar cal = (GregorianCalendar)stack.findValue("top.startDateTime");

		if( cal.get(Calendar.MONTH)+1 != currentMonth ) {
			month = vf.formatDate(cal.getTime(), locale, "MMMM");
			firstLetterMonth = month.substring(0,1);
			monthRemaining = month.substring(1);
			month = firstLetterMonth.toUpperCase()+monthRemaining;
			
			out.write("<p class=\"month\">" + month + " " + cal.get(Calendar.YEAR) + "</p>");
			currentMonth = (cal.get(Calendar.MONTH)+1);
		}

		%>
		<ww:set name="event" value="top"/>
		<ww:set name="eventVersion" value="this.getEventVersion('#event')"/>
		<ww:set name="eventVersion" value="this.getEventVersion('#event')" scope="page"/>
		<ww:set name="eventId" value="id" scope="page"/>
		
		<portlet:renderURL var="eventDetailUrl">
			<portlet:param name="action" value="ViewEvent!publicGU"/>
			<portlet:param name="eventId" value='<%= pageContext.getAttribute("eventId").toString() %>'/>
		</portlet:renderURL>
	        
	    <ww:iterator value="top.owningCalendar.eventType.categoryAttributes">
			<ww:if test="top.name == 'Evenemangstyp' || top.name == 'Eventtyp'">
				<ww:set name="selectedCategories" value="this.getEventCategories('#event', top)"/>
				<ww:iterator value="#selectedCategories" status="rowstatus">
					<ww:set name="visibleCategoryName" value="top.getLocalizedName(#languageCode, 'sv')"/>
				</ww:iterator>
			</ww:if>
   		</ww:iterator>
   		                 
		<!-- Record Start -->
		<div class="vevent">
			
			
			<ww:set name="startDate" value="this.formatDate(top.startDateTime.getTime(), 'yyyy-MM-dd HH:mm')"/>
			<c:set var="startDateFormatted"><ww:property value="#startDate"/></c:set>
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
			<p class="date_time">
			<span class="dtstart">
				<!-- tid -->
				<abbr class="value" title="<c:out value="${isoStartDate}"/>"><ww:property value="this.formatDate(top.startDateTime.getTime(), #shortDateFormat)"/></abbr>
				<ww:set name="startDay" value="this.formatDate(top.startDateTime.getTime(), 'yyyy-MM-dd')"/>
				<ww:set name="endDay" value="this.formatDate(top.endDateTime.getTime(), 'yyyy-MM-dd')"/>

				<ww:if test="this.formatDate(top.startDateTime.time, 'HH:mm') != '12:34'">
					<ww:property value="this.getLabel('labels.public.event.klockLabel')"/>
					<span class="value"><ww:property value="this.formatDate(top.startDateTime.getTime(), #timeFormat)"/></span>
				</ww:if>

			</span>
			
			<ww:if test="#startDay != #endDay">
				&ndash;
				<span class="dtend">
					<abbr class="value" title="<ww:property value='this.formatDate(top.endDateTime.getTime(), "yyyy-MM-dd HH:mm")' />"> <ww:property value="this.formatDate(top.endDateTime.getTime(), #shortDateFormat)"/></abbr>
					<ww:if test="this.formatDate(top.endDateTime.time, 'HH:mm') != '23:59'">
						<ww:property value="this.getLabel('labels.public.event.klockLabel')"/>
						<span class="value"><ww:property value="this.formatDate(top.endDateTime.getTime(), #timeFormat)"/></span>
	
					</ww:if>
				</span>
			</ww:if>
			<ww:elseif test="this.formatDate(top.endDateTime.time, 'HH:mm') != '23:59'">
				&ndash;
				<span class ="dtend">
					<span class="value">
						<ww:property value="this.formatDate(top.endDateTime.getTime(), #timeFormat)"/>
					</span>
				</span>
			</ww:elseif>

			</p>
			<h3 class="summary">
				<a class="url uid summary" href="<ww:property value="#attr.detailUrl"/><c:out value="${delim}"/>eventId=<ww:property value="top.id"/>"><ww:property value="#eventVersion.name"/></a>
			</h3>
			
			<div class="description">
				<ww:property value="#eventVersion.shortDescription"/>
			</div>
			
				<a class="url uid show" id="longDescriptionId<ww:property value="top.id"/>A" href="javascript: toggle_visibility('longDescriptionId<ww:property value="top.id"/>', 'longDescriptionId<ww:property value="top.id"/>A');"><img src="http://clamator.its.uu.se/uploader/67/show.png" /></a>
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
						
						<!-- F�rel�sare -->
						<ww:if test="#eventVersion.lecturer != null && #eventVersion.lecturer != ''">
							<li>
								<ww:property value="this.getLabel('labels.public.event.lecturerLabel')"/>: <ww:property value="#eventVersion.lecturer"/>
							</li> 
						</ww:if>
						
						<!-- Webbsida -->
						<ww:if test="#eventVersion.eventUrl != null && #eventVersion.eventUrl != ''">
							<li><a class="url uid webpage" href="<ww:property value="#eventVersion.eventUrl"/>"><ww:property value="this.getLabel('labels.public.event.eventUrl')"/></a></li>
						</ww:if>
						
						<!--  Arrang�r -->
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
					<ww:if test="#attr.showExtrasBox != 'false'">
						<div class="articleFeatures">
							<div class="sharing">
								<a class="a2a_dd" href="http://www.addtoany.com/share_save">
								<img src="<ww:property value="#attr.shareButtonImage"/>" class="shareButton shareButtonCalendarSmall" alt="Share/Bookmark"/></a>
							</div>
						</div>
					</ww:if>
					--%>					
				</div>
			<%-- 
			</ww:if>
			--%>



		</div>
		<!-- Record End -->
	</ww:iterator>

	<ww:if test="events == null || events.size() == 0">
		<p><ww:property value="this.getLabel('labels.public.event.noFilteredMatchesLabel')"/></p>
	</ww:if>
	
</div>
<!-- Calendar End -->  
