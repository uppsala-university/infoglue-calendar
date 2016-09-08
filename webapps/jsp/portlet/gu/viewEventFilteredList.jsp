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


<div class="calendar">   
	<ul class="is-unstyled">

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
				
				out.write("<h2 class=\"is-border-bottom\">" + month + " " + cal.get(Calendar.YEAR) + "</h2>");
				currentMonth = (cal.get(Calendar.MONTH)+1);
			}

			%>
			<ww:set name="event" value="top"/>
			<ww:set name="event" value="event" scope="page"/>
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
			<li class="vevent list-item">
				
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
				<a class="url uid summary" href="<ww:property value='#attr.detailUrl'/><c:out value='${delim}'/>eventId=<ww:property value='top.id'/>">
					<p class="date_time date">
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
						<ww:property value="#eventVersion.name"/>
					</h3>
				</a>
	  
				<div class="description clearfix">
					<ww:set name="detailImage" value="this.getResourceUrl(event, 'DetaljBild')"/>
					<!-- start div if image exists -->
					<ww:if test="#detailImage != null">
						<div class="size3of4 unit">
					</ww:if>

					<ww:property value="#eventVersion.shortDescription"/>

					<ww:if test="#detailImage != null">
						</div><!-- end div size3of4 -->
						<div class="size1of4 unit last">			
							<img src="<ww:property value='#detailImage'/>" alt="<ww:property value='#eventVersion.name'/>">
						</div>
					</ww:if>
				</div>
			</li>
			<%-- 
			</ww:if>
			--%>

			<!-- Record End -->
		</ww:iterator>
	</ul>

	<ww:if test="events == null || events.size() == 0">
		<p><ww:property value="this.getLabel('labels.public.event.noFilteredMatchesLabel')"/></p>
	</ww:if>
</div>
<!-- Calendar End -->  
