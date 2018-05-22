package org.infoglue.calendar.controllers;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
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
import net.fortuna.ical4j.model.PropertyFactoryRegistry;
import net.fortuna.ical4j.model.PropertyList;
import net.fortuna.ical4j.model.TimeZone;
import net.fortuna.ical4j.model.TimeZoneRegistry;
import net.fortuna.ical4j.model.TimeZoneRegistryFactory;
import net.fortuna.ical4j.model.component.CalendarComponent;
import net.fortuna.ical4j.model.component.VEvent;
import net.fortuna.ical4j.model.component.VTimeZone;
import net.fortuna.ical4j.model.property.CalScale;
import net.fortuna.ical4j.model.property.Description;
import net.fortuna.ical4j.model.property.DtEnd;
import net.fortuna.ical4j.model.property.DtStart;
import net.fortuna.ical4j.model.property.Name;
import net.fortuna.ical4j.model.property.ProdId;
import net.fortuna.ical4j.model.property.Summary;
import net.fortuna.ical4j.model.property.TzId;
import net.fortuna.ical4j.model.property.Uid;
import net.fortuna.ical4j.model.property.Url;
import net.fortuna.ical4j.model.property.Version;
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
	private static final String EUROPE_STOCKHOLM_TIMEZONE = "Europe/Stockholm";
	private static Log log = LogFactory.getLog(ICalendarController.class);
	private static final SimpleDateFormat DATE_FORMATTER = new SimpleDateFormat("yyyyMMdd'T'HHmmss");

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
		Set<EventVersion> versions = event.getVersions();
		Iterator<EventVersion> versionsIterator = versions.iterator();
		EventVersion eventVersion = null;
		EventVersion eventVersionCandidate = null;
		while(versionsIterator.hasNext())
		{
			eventVersionCandidate = versionsIterator.next();
			if(eventVersionCandidate.getLanguage().getId().equals(language.getId()))
			{
				eventVersion = eventVersionCandidate;
				break;
			}
		}
		if(eventVersion == null && eventVersionCandidate != null)
			eventVersion = eventVersionCandidate;

		ICalendar iCal = new ICalendar();
		iCal.icalEventCollection = new LinkedList<ICalendarVEvent>();
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
			Iterator<Location> locationsIterator = event.getLocations().iterator();
			while(locationsIterator.hasNext())
			{
				Location location = locationsIterator.next();
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

	public void getICalendar(Event event, Language language, String file)
	{
		String iCalendar;
		Writer out = null;
		try {
			iCalendar = getICalendarOutput(event, language.getIsoCode(), null);
			out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "UTF-8"));
			out.append(iCalendar);
		} catch (Exception e) {
			log.error("Could not create iCalendar file for event " + event.getId(), e);
		} finally {
			if (out != null) {
				try {
					out.close();
				} catch (IOException ioe) {
					// Ignore
				}
			}
		}
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
				events.add(convertVEventToEvent((VEvent) component, language));
			}
		}

		return events;
	}

	/**
	 * Creates an iCalendar representation in String form of a calendar event.
	 */
	public String getICalendarOutput(Event event, String languageCode, String defaultDetailUrl) throws Exception, IOException {
		List<Event> events = new LinkedList<Event>();
		events.add(event);
		
		return getICalendarOutput(events, null, languageCode, defaultDetailUrl);
	}
		
	/**
	 * Creates an iCalendar representation in String form of a list of calendar events.
	 */
	public String getICalendarOutput(List<Event> events, String calendarName, String languageCode, String defaultDetailUrl) throws Exception, IOException {
		System.setProperty("net.fortuna.ical4j.timezone.update.enabled", "false");


		
		// Create the iCalendar
		net.fortuna.ical4j.model.Calendar iCal = new net.fortuna.ical4j.model.Calendar();
		iCal.getProperties().add(new ProdId("-//Uppsala University//Infoglue Calendar//EN"));
		iCal.getProperties().add(Version.VERSION_2_0);
		iCal.getProperties().add(CalScale.GREGORIAN);
		
		// Set name
		if (calendarName != null) {
			PropertyFactoryRegistry propertyFactoryRegistry = new PropertyFactoryRegistry();
			Property name = propertyFactoryRegistry.createProperty("X-WR-CALNAME");
			name.setValue(calendarName);
			iCal.getProperties().add(name);
		}
		
		// Set timezone
		try {
			TimeZoneRegistry registry = TimeZoneRegistryFactory.getInstance().createRegistry();
			iCal.getComponents().add(registry.getTimeZone(EUROPE_STOCKHOLM_TIMEZONE).getVTimeZone());
		} catch (Exception e) {
			log.error("Couldn't add timezone", e);
		}

		// Convert events to iCalendar vEvents and add them to the calendar
		List<VEvent> vEvents = convertEventsToVevents(events, languageCode, defaultDetailUrl);
		for (VEvent vEvent : vEvents) {
			iCal.getComponents().add(vEvent);
		}

		// Write iCalendar to a String
		CalendarOutputter outputter = new CalendarOutputter();
		StringWriter writer = new StringWriter();
		outputter.output(iCal, writer);

		return writer.toString();
	}

	/**
	 * Convert a list of calendar events to a list of iCalendar vEvents.
	 */
	protected List<VEvent> convertEventsToVevents(List<Event> events, String languageCode, String defaultDetailUrl) throws Exception {
		List<VEvent> results = new LinkedList<VEvent>(); 

		for (Event event : events) {
			results.add(convertEventToVEvent(event, languageCode, defaultDetailUrl));
		}

		return results;
	}

	/**
	 * Convert an event from an ICS file to an Infoglue Calendar event.
	 * Not all fields are covered, but more than enough to use the event 
	 * in a list.
	 */
	protected Event convertVEventToEvent(VEvent vEvent, Language language) {
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
	 * Convert an event from an Infoglue Calendar event to iCalendar vEvent.
	 * Not all fields are covered.
	 */
	protected VEvent convertEventToVEvent(Event event, String languageCode, String defaultDetailUrl) {
		VEvent vEvent = new VEvent();
		PropertyList<Property> properties = vEvent.getProperties();

		// TimeZone
		TzId timeZoneId = new TzId(EUROPE_STOCKHOLM_TIMEZONE);
		properties.add(timeZoneId);

		// Location
		// Create a list of locations
		Set<String> locations = new HashSet<String>();		
		@SuppressWarnings("unchecked")
		Set<Location> locationSet = event.getLocations();
		for (Location location : locationSet) {
			locations.add(location.getLocalizedName(languageCode, "sv"));
		}
		if (event.getAlternativeLocation() != null) {
			locations.add(event.getAlternativeLocation());
		}
		if (event.getCustomLocation() != null) {
			locations.add(event.getCustomLocation());
		}

		// Event url
		String eventUrl = event.getEventUrl();

		if ((eventUrl == null || eventUrl.length() == 0) && defaultDetailUrl != null) {
			eventUrl = defaultDetailUrl.replaceAll("\\{eventId\\}", "" + event.getId());
		}

		if (eventUrl != null) {
			try {
				properties.add(new Url(new URI(eventUrl)));
			} catch (URISyntaxException use) {
				log.error("Invalid event url: " + eventUrl, use);
			}
		}

		// Create a map from language codes to event versions
		@SuppressWarnings("unchecked")
		Set<EventVersion> eventVersions = event.getVersions();
		Map<String, EventVersion> languageVersions = new HashMap<String, EventVersion>();
		if (eventVersions != null) {
			for (EventVersion eventVersion : eventVersions) {
				languageVersions.put(eventVersion.getLanguage().getIsoCode(), eventVersion);
			}
		}

		if (languageVersions.size() > 0) {
			// Get the version matching the current language
			EventVersion eventVersion = languageVersions.get(languageCode);

			// If we didn't find a matching version, get any other language version
			if (eventVersion == null) {
				String existingLanguageCode = languageVersions.keySet().iterator().next();
				eventVersion = languageVersions.get(existingLanguageCode);
			}
			
			// HTML description / X-ALT-DESC
			String longDescription = eventVersion.getLongDescription();
			if (longDescription == null || longDescription.length() == 0) {
				longDescription = eventVersion.getDecoratedLongDescription();
			}
			if (longDescription != null && longDescription.length() > 0) {
				try {
					PropertyFactoryRegistry propertyFactoryRegistry = new PropertyFactoryRegistry();
					// From Wikipedia: X-ALT-DESC - Used to include HTML markup in an event's description. Standard DESCRIPTION tag should contain non-HTML version.
					Property htmlDescription = propertyFactoryRegistry.createProperty("X-ALT-DESC");
					htmlDescription.setValue(longDescription);
					properties.add(htmlDescription);
				} catch (Exception e) {
					log.error("Could not add long description " + eventVersion.getLongDescription(), e);
				} 
			}

			// Description
			String shortDescription = eventVersion.getShortDescription();
			if (shortDescription == null || shortDescription.length() == 0) {
				shortDescription = eventVersion.getDecoratedShortDescription();
				if (shortDescription == null) {
					shortDescription = "";
				}
			}
			if (eventUrl != null) {
				if (shortDescription.length() > 0) {
					shortDescription += "\n\n";
				}
				shortDescription += eventUrl;
			}
			properties.add(new Description(shortDescription));

			// Summary 
			if (eventVersion.getName() != null) {
				properties.add(new Summary(eventVersion.getName()));
			}
			
			// Location, add alternative location
			if (eventVersion.getAlternativeLocation() != null) {
				locations.add(eventVersion.getAlternativeLocation());
			}

			// Location, add custom location
			if (eventVersion.getCustomLocation() != null) {
				locations.add(eventVersion.getCustomLocation());
			}			
		}

		// Location
		// Get rid of empty locations
		Set<String> nonEmptyLocations = new HashSet<String>();		
		for (String location : locations) {
			if (location != null && location.length() > 0) {
				nonEmptyLocations.add(location);
			}
		}
		// Create comma-separated string of locations
		String locationName = "";
		for (Iterator<String> iterator = nonEmptyLocations.iterator(); iterator.hasNext();) {
			String location = iterator.next();
			locationName += location + (iterator.hasNext() ? ", " : "");
		}
		net.fortuna.ical4j.model.property.Location location = new net.fortuna.ical4j.model.property.Location(locationName);
		properties.add(location);
		
		// DtStart
		String startDateTimeString = "?";
		java.util.Calendar startCalendar = event.getStartDateTime();
		boolean hideTime = true;
		if (startCalendar != null) {
			hideTime = startCalendar.get(java.util.Calendar.HOUR_OF_DAY) == 12 && startCalendar.get(java.util.Calendar.MINUTE) == 34;
			if (hideTime) {
				properties.add(new DtStart(new net.fortuna.ical4j.model.Date(startCalendar)));
			} else {
				properties.add(new DtStart(new net.fortuna.ical4j.model.DateTime(startCalendar.getTime())));
			}
			startDateTimeString = DATE_FORMATTER.format(event.getStartDateTime().getTime());
		}

		// DtEnd
		java.util.Calendar endCalendar = event.getEndDateTime();
		if (endCalendar != null) {
			if (hideTime) {
				properties.add(new DtEnd(new net.fortuna.ical4j.model.Date(endCalendar)));
			} else {
				properties.add(new DtEnd(new net.fortuna.ical4j.model.DateTime(endCalendar.getTime())));
			}
		}

		// Name
		if (event.getName() != null) {
			properties.add(new Name(event.getName()));
		}

		// UID
		properties.add(new Uid(startDateTimeString + "-" + event.getId() + "@uu.se"));

		return vEvent;
	}
}