package org.infoglue.calendar.controllers;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import net.fortuna.ical4j.data.CalendarBuilder;
import net.fortuna.ical4j.data.CalendarOutputter;
import net.fortuna.ical4j.data.FoldingWriter;
import net.fortuna.ical4j.data.ParserException;
import net.fortuna.ical4j.model.Calendar;
import net.fortuna.ical4j.model.Component;
import net.fortuna.ical4j.model.ComponentList;
import net.fortuna.ical4j.model.DateTime;
import net.fortuna.ical4j.model.Property;
import net.fortuna.ical4j.model.PropertyList;
import net.fortuna.ical4j.model.TimeZone;
import net.fortuna.ical4j.model.TimeZoneRegistry;
import net.fortuna.ical4j.model.TimeZoneRegistryFactory;
import net.fortuna.ical4j.model.component.CalendarComponent;
import net.fortuna.ical4j.model.component.VEvent;
import net.fortuna.ical4j.model.component.VTimeZone;
import net.fortuna.ical4j.model.parameter.Cn;
import net.fortuna.ical4j.model.property.CalScale;
import net.fortuna.ical4j.model.property.Description;
import net.fortuna.ical4j.model.property.DtEnd;
import net.fortuna.ical4j.model.property.DtStart;
import net.fortuna.ical4j.model.property.Name;
import net.fortuna.ical4j.model.property.Organizer;
import net.fortuna.ical4j.model.property.ProdId;
import net.fortuna.ical4j.model.property.Summary;
import net.fortuna.ical4j.model.property.Uid;
import net.fortuna.ical4j.model.property.Url;
import net.fortuna.ical4j.util.Calendars;
import net.fortuna.ical4j.util.UidGenerator;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Session;
import org.infoglue.calendar.entities.Event;
import org.infoglue.calendar.entities.EventVersion;
import org.infoglue.calendar.entities.Language;
import org.infoglue.calendar.entities.Location;
import org.infoglue.calendar.util.ICalendar;
import org.infoglue.calendar.util.ICalendarVEvent;
import org.infoglue.common.util.PropertyHelper;

public class ICalendarController extends BasicController
{
	private static Log log = LogFactory.getLog(ICalendarController.class);
	
	private ICalendarController(){}

	public static final ICalendarController getICalendarController()
	{
		return new ICalendarController();
	}

	/**
	 * This method returns a ICalendar based on it's primary key
	 */

	public String getICalendarUrl(Long id, Session session) throws Exception
	{
		String url = "";

		Event event = EventController.getController().getEvent(id, session);
		Language masterLanguage = LanguageController.getController().getMasterLanguage(session);

		String calendarPath = PropertyHelper.getProperty("calendarsPath");
		String fileName = "event_" + event.getId() + ".vcs";

		getVCalendar(event, masterLanguage, calendarPath + fileName);

		String urlBase = PropertyHelper.getProperty("urlBase");

		url = urlBase + "calendars/" + fileName;

		return url;
	}


	public void getVCalendar(Event event, Language language, String file) throws Exception
	{
		Set versions = event.getVersions();
		Iterator versionsIterator = versions.iterator();
		EventVersion eventVersion = null;
		EventVersion eventVersionCandidate = null;
		while(versionsIterator.hasNext())
		{
			eventVersionCandidate = (EventVersion)versionsIterator.next();
			if(eventVersionCandidate.getLanguage().getId().equals(language.getId()))
			{
				eventVersion = eventVersionCandidate;
				break;
			}
		}
		if(eventVersion == null && eventVersionCandidate != null)
			eventVersion = eventVersionCandidate;

		ICalendar iCal = new ICalendar();
		iCal.icalEventCollection = new LinkedList();
		iCal.setProdId("InfoGlueCalendar");
		iCal.setVersion("1.0");
		// Event Test
		ICalendarVEvent vevent = new ICalendarVEvent();
		Date workDate = new Date();
		vevent.setDateStart(event.getStartDateTime().getTime());
		vevent.setDateEnd(event.getEndDateTime().getTime());
		vevent.setSummary(eventVersion.getName());

		if(eventVersion != null)
			vevent.setDescription(eventVersion.getDescription());
		else
			vevent.setDescription("No description set");

		vevent.setSequence(0);
		vevent.setEventClass("PUBLIC");
		vevent.setTransparency("OPAQUE");
		vevent.setDateStamp(workDate);
		vevent.setCreated(workDate);
		vevent.setLastModified(workDate);
		if(eventVersion != null)
			vevent.setOrganizer(eventVersion.getOrganizerName());
		else
			vevent.setOrganizer("MAILTO:sfg@eurekait.com");
		vevent.setUid("igcal-"+workDate);
		vevent.setPriority(3);

		String locationString = null;
		if(eventVersion.getAlternativeLocation() != null && !eventVersion.getAlternativeLocation().equals(""))
			locationString = eventVersion.getAlternativeLocation() + ", ";
		else 
		{
			Iterator locationsIterator = event.getLocations().iterator();
			while(locationsIterator.hasNext())
			{
				Location location = (Location)locationsIterator.next();
				String localizedName = location.getLocalizedName("en","sv");
				locationString += localizedName + ", ";
			}	
			if(eventVersion.getCustomLocation() != null && !eventVersion.getCustomLocation().equals(""))
				locationString += eventVersion.getCustomLocation();
		}

		vevent.setLocation(locationString);

		iCal.icalEventCollection.add(vevent);

		// Now write to string and view as file.

		//writeUTF8ToFile(new File(file), iCal.getVCalendar(), false);
		writeISO88591ToFile(new File(file), iCal.getVCalendar(), false);
		//writeUTF8ToFile(new File("c:/calendar.vcs"), iCal.getVCalendar(), false);
	}

	public void getICalendar(Event event, Language language, String file) throws Exception
	{
		Set versions = event.getVersions();
		Iterator versionsIterator = versions.iterator();
		EventVersion eventVersion = null;
		EventVersion eventVersionCandidate = null;
		while(versionsIterator.hasNext())
		{
			eventVersionCandidate = (EventVersion)versionsIterator.next();
			if(eventVersionCandidate.getLanguage().getId().equals(language.getId()))
			{
				eventVersion = eventVersionCandidate;
				break;
			}
		}
		if(eventVersion == null && eventVersionCandidate != null)
			eventVersion = eventVersionCandidate;

		String locationString = "";
		if(eventVersion.getAlternativeLocation() != null && !eventVersion.getAlternativeLocation().equals(""))
			locationString = eventVersion.getAlternativeLocation();
		else 
		{
			Iterator locationsIterator = event.getLocations().iterator();
			while(locationsIterator.hasNext())
			{
				Location location = (Location)locationsIterator.next();
				String localizedName = location.getLocalizedName("en","sv");
				if(!locationString.equals("") && !locationString.endsWith(", "))
					locationString += ", ";

				locationString += localizedName;
			}	
			if(eventVersion.getCustomLocation() != null && !eventVersion.getCustomLocation().equals(""))
				if(!locationString.equals("") && !locationString.endsWith(", "))
					locationString += ", ";
			locationString += eventVersion.getCustomLocation();
		}

		try 
		{
			TimeZoneRegistry registry = TimeZoneRegistryFactory.getInstance().createRegistry();
			TimeZone timezone = registry.getTimeZone("Europe/Stockholm");
			VTimeZone tz = timezone.getVTimeZone();

			//Create the event
			DateTime start = new DateTime(event.getStartDateTime().getTime());
			DateTime end = new DateTime(event.getEndDateTime().getTime());
			VEvent meeting = new VEvent(start, end, eventVersion.getName());
			meeting.getProperties().add(tz.getTimeZoneId());
			net.fortuna.ical4j.model.property.Location iCalLocation = new net.fortuna.ical4j.model.property.Location(locationString);
			meeting.getProperties().add(iCalLocation);
			Description iCalDescription = new Description("" + eventVersion.getLongDescription());
			meeting.getProperties().add(iCalDescription);

			//Create a calendar
			Calendar icsCalendar = new Calendar();
			icsCalendar.getProperties().add(new ProdId("-//InfoGlue//InfoGlue Calendar 1.0//EN"));
			icsCalendar.getProperties().add(CalScale.GREGORIAN);

			UidGenerator ug = new UidGenerator("uidGen");
			Uid uid = ug.generateUid();
			icsCalendar.getProperties().add(uid);

			//Add the event and print
			icsCalendar.getComponents().add(meeting);

			Writer out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "ISO-8859-1"));

			CalendarBuilder builder = new CalendarBuilder();
			CalendarOutputter outputter = new CalendarOutputter(false, FoldingWriter.REDUCED_FOLD_LENGTH);
			outputter.setValidating(false);

			outputter.output(icsCalendar, out);

			//out.flush();
			//out.close();

		} 
		catch (Exception e) 
		{
			System.out.println("Error: " + e.getMessage());
		}

		/*
		if(eventVersion != null)
			vevent.setDescription(eventVersion.getDescription());
		else
			vevent.setDescription("No description set");

		vevent.setSequence(0);
		vevent.setEventClass("PUBLIC");
		vevent.setTransparency("OPAQUE");
		vevent.setDateStamp(workDate);
		vevent.setCreated(workDate);
		vevent.setLastModified(workDate);
		if(eventVersion != null)
			vevent.setOrganizer(eventVersion.getOrganizerName());
		else
			vevent.setOrganizer("MAILTO:sfg@eurekait.com");
		vevent.setUid("igcal-"+workDate);
		vevent.setPriority(3);


		vevent.setLocation(locationString);

		iCal.icalEventCollection.add(vevent);

		writeISO88591ToFile(new File(file), iCal.getVCalendar(), false);
		 */
	}

	public synchronized void writeUTF8ToFile(File file, String text, boolean isAppend) throws Exception
	{
		Writer out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "UTF8"));
		out.write(text);
		out.flush();
		out.close();
	}

	public synchronized void writeISO88591ToFile(File file, String text, boolean isAppend) throws Exception
	{
		Writer out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "ISO-8859-1"));
		out.write(text);
		out.flush();
		out.close();
	}
	static java.util.Calendar dateToJavaCalendar(Date date){ 
		java.util.Calendar cal = java.util.Calendar.getInstance();
		cal.setTime(date);
		return cal;
	}
	
	public Set<Event> importEvents(String icsUrl, Language language) throws MalformedURLException, IOException, ParserException {
		Set<Event> events = new HashSet<Event>();
	
		Calendar vCalendar = Calendars.load(new URL(icsUrl));
	
		ComponentList<CalendarComponent> vEvents = vCalendar.getComponents(Component.VEVENT);
	
		for (CalendarComponent component : vEvents) {
			if (component instanceof VEvent) {
				events.add(convertVeventToEvent((VEvent) component, language));
			}
		}
	
		return events;
	}
	
	public List<VEvent> exportEvents(List<Event> events) throws Exception {
		List<VEvent> results = new LinkedList<VEvent>(); 
		
		for (Event event : events) {
			results.add(convertEventToVEvent(event));
		}
		
		return results;
	}

	/**
	 * Convert an event from an ICS file to an Infoglue Calendar event.
	 * Not all fields are covered, but more than enough to use the event 
	 * in a list.
	 */
	protected Event convertVeventToEvent(VEvent vEvent, Language language) {
		Set<EventVersion> eventVersions = new HashSet<EventVersion>();
		EventVersion eventVersion = new EventVersion();
		Event event = new Event();
	
		Set<Location> extraLocations = new HashSet<Location>();
		if (vEvent.getLocation() != null) {
			Location extraLocation = new Location();
			extraLocation.setName(vEvent.getLocation().getValue());
			extraLocations.add(extraLocation);
		}
		event.setLocations(extraLocations);
	
		eventVersion.setLanguage(language);
	
		if (vEvent.getOrganizer() != null) {
			eventVersion.setOrganizerName(vEvent.getOrganizer().getValue());
			event.setOrganizerName(vEvent.getOrganizer().getValue());
		}
	
		if (vEvent.getDescription() != null) {
			eventVersion.setShortDescription(vEvent.getDescription().getValue());
			eventVersion.setDescription(vEvent.getDescription().getValue());   
			event.setDescription(vEvent.getDescription().getValue());
		}
	
		eventVersion.setId(-1L);
	
		if (vEvent.getSummary() != null) {
			eventVersion.setName(vEvent.getSummary().getValue());
		}
	
		eventVersions.add(eventVersion);
	
		if (vEvent.getStartDate() != null) {
			event.setStartDateTime(dateToJavaCalendar(vEvent.getStartDate().getDate()));
		}
		if (vEvent.getEndDate() != null) {
			event.setEndDateTime(dateToJavaCalendar(vEvent.getEndDate().getDate()));
		}

		if (vEvent.getOrganizer() != null) {
			if (vEvent.getOrganizer().getParameter("CN") != null) {
				event.setContactName(vEvent.getOrganizer().getParameter("CN").getValue());
			}
		}

		event.setId(-1L);
		event.setVersions(eventVersions);
	
		if (vEvent.getUrl() != null) {
			event.setEventUrl(vEvent.getUrl().getValue());
		}
	
		if (vEvent.getUid() != null) {
			event.setName(vEvent.getUid().getValue());
		}

		return event;
	}
	
	
	
	/**
	 * Convert an event from  an Infoglue Calendar event to iCal event.
	 * Not all fields are covered.
	 */
	protected VEvent convertEventToVEvent(Event event) {
		VEvent vEvent = new VEvent();
		PropertyList<Property> properties = vEvent.getProperties();
		
		@SuppressWarnings("unchecked")
		Set<Location> locations = event.getLocations();
		if (locations != null && !locations.isEmpty()) {
			Location aLocation = locations.iterator().next();
			net.fortuna.ical4j.model.property.Location location = new net.fortuna.ical4j.model.property.Location(aLocation.getName());
			properties.add(location);
		}

		@SuppressWarnings("unchecked")
		Set<EventVersion> eventVersions = event.getVersions();
		if (eventVersions != null) {
			for (EventVersion eventVersion : eventVersions) {
				PropertyList<Property> versionProperties = new PropertyList<Property>();
				net.fortuna.ical4j.model.parameter.Language icalLanguage = new net.fortuna.ical4j.model.parameter.Language(eventVersion.getLanguage().getIsoCode());
				
				if (eventVersion.getOrganizerName() != null) {
					Organizer organizer = new Organizer();
					organizer.getParameters().add(new Cn(eventVersion.getOrganizerName()));
					versionProperties.add(organizer);
				}
	
				if (eventVersion.getLongDescription() != null) {
					versionProperties.add(new Description(eventVersion.getLongDescription()));
				} else if (eventVersion.getShortDescription() != null) {
					versionProperties.add(new Description(eventVersion.getShortDescription()));
				}
				
				if (eventVersion.getName() != null) {
					versionProperties.add(new Summary(eventVersion.getName()));
				}
				
				for (Property property : versionProperties) {
					// Mark this property with the language of this event version
					property.getParameters().add(icalLanguage);
					// Add this property to the properties of the vEvent
					properties.add(property);
				}
			}
		}

		if (event.getStartDateTime() != null) {
			properties.add(new DtStart(new net.fortuna.ical4j.model.Date(event.getStartDateTime())));
		}

		if (event.getEndDateTime() != null) {
			properties.add(new DtEnd(new net.fortuna.ical4j.model.Date(event.getEndDateTime())));
		}
		
		if (event.getContactName() != null) {
			Organizer organizer = null;
			try {
			if (event.getContactEmail() != null) {
				organizer = new Organizer("MAILTO:" + event.getContactEmail());
			} else if (event.getContactPhone() != null) {
				organizer = new Organizer("TEL:" + event.getContactPhone());
			} 
			} catch (URISyntaxException use) {
				log.error("Could not construct Organizer uri", use);
			}
			
			if (organizer == null) {
				organizer = new Organizer();
			}
				
			organizer.getParameters().add(new Cn(event.getOrganizerName()));
			properties.add(organizer);
		}

		if (event.getEventUrl() != null) {
			try {
				properties.add(new Url(new URI(event.getEventUrl())));
			} catch (URISyntaxException use) {
				log.error("Invalid event url: " + event.getEventUrl(), use);
			}
		}
		
		
		if (event.getName() != null) {
			properties.add(new Name(event.getName()));
		}
		
		return vEvent;
	}
}