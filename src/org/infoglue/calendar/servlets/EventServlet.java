package org.infoglue.calendar.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.axis.utils.XMLUtils;
import org.apache.log4j.Logger;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.infoglue.calendar.controllers.EventController;
import org.infoglue.calendar.controllers.ResourceController;
import org.infoglue.calendar.entities.Calendar;
import org.infoglue.calendar.entities.Event;
import org.infoglue.calendar.entities.EventCategory;
import org.infoglue.calendar.entities.EventVersion;
import org.infoglue.calendar.entities.Location;
import org.infoglue.calendar.entities.Resource;
import org.infoglue.common.util.HibernateUtil;
import org.infoglue.common.util.VisualFormatter;

/**
 * Servlet implementation class CalendarServlet
 */

public class EventServlet extends HttpServlet 
{
	private static final long serialVersionUID = 1L;
       
    private final static Logger logger = Logger.getLogger(EventServlet.class.getName());

	private VisualFormatter vf = new VisualFormatter();
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		response.setContentType("text/xml");
		response.setCharacterEncoding("UTF-8");
		StringBuffer sb = new StringBuffer();
		
		sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");

		Session session = HibernateUtil.currentSession();
		Transaction tx = null;

		try 
		{
			tx = session.beginTransaction();
			
			Long eventId = new Long(request.getParameter("eventId"));
			Event event = EventController.getController().getEvent(eventId, session);
			
			sb.append(String.format("<event id=\"%s\" startDate=\"%s\" endDate=\"%s\">" +
                                    "<name><![CDATA[%s]]></name>" +
                                    "<customLocation><![CDATA[%s]]></customLocation>" +
                                    "<alternativeLocation><![CDATA[%s]]></alternativeLocation>" +
                                    "<eventUrl><![CDATA[%s]]></eventUrl>" + 
                                    "<description><![CDATA[%s]]></description>" +
                                    "<shortDescription><![CDATA[%s]]></shortDescription>" +
                                    "<longDescription><![CDATA[%s]]></longDescription>" +
                                    "<attributes><![CDATA[%s]]></attributes>" + 
                                    "<lecturer><![CDATA[%s]]></lecturer>" + 
                                    "<organizerName><![CDATA[%s]]></organizerName>" + 
                                    "<contactEmail><![CDATA[%s]]></contactEmail>" + 
                                    "<contactName><![CDATA[%s]]></contactName>" + 
                                    "<contactPhone><![CDATA[%s]]></contactPhone>" + 
                                    "<internal><![CDATA[%s]]></internal>" + 
                                    "<owningCalendar><![CDATA[%s]]></owningCalendar>" + 
                                    "<price><![CDATA[%s]]></price>" + 
                                    "%s" +
                                    "%s" +
                                    "%s" +
                                    "%s" +
                                    "%s" +
                                    "</event>",
                                    event.getId(),
                                    vf.formatDate(event.getStartDateTime().getTime(), "yyyy-MM-dd HH:mm"), 
                                    vf.formatDate(event.getEndDateTime().getTime(), "yyyy-MM-dd HH:mm"),
                                    emptyIfNull(event.getName()),
                                    emptyIfNull(event.getCustomLocation()),
                                    emptyIfNull(event.getAlternativeLocation()),
                                    emptyIfNull(event.getEventUrl()),
                                    emptyIfNull(event.getDescription()),
                                    emptyIfNull(event.getShortDescription()),
                                    emptyIfNull(event.getLongDescription()),
                                    XMLUtils.xmlEncodeString(emptyIfNull(event.getAttributes())),
                                    emptyIfNull(event.getLecturer()),
                                    emptyIfNull(event.getOrganizerName()),
                                    emptyIfNull(event.getContactEmail()),
                                    emptyIfNull(event.getContactName()),
                                    emptyIfNull(event.getContactPhone()),
                                    event.getIsInternal(),
                                    event.getOwningCalendar().getId(),
                                    emptyIfNull(event.getPrice()),
                                    getVersionsXml(event),
                                    getResourcesXml(event, session),
                                    getLocationsXml(event), 
                                    getEventCategoriesXml(event), 
                                    getCalendarsXml(event)
					));

			tx.commit();
		} catch (NumberFormatException ne) {
			if (tx != null) {
				tx.rollback();
			}
			sb.append("<error message=\"Invalid eventId (" + ne.getMessage() + ")\" type=\"" + ne.getClass().getName() + "\"/>");
		} catch (Exception e) {
			if (tx != null) {
				tx.rollback();
			}
			sb.append("<error message=\"" + e.getMessage() + "\" type=\"" + e.getClass().getName() + "\"/>");
		}
		finally 
		{
			HibernateUtil.closeSession();
		}

		PrintWriter pw = response.getWriter();

		pw.println(sb.toString());
		pw.flush();
		pw.close();
	}

	private String emptyIfNull(String str) {
		return str == null ? "" : str;
	}

	private String getEventCategoriesXml(Event event) {
		Set<EventCategory> categories = event.getEventCategories();
		StringBuffer sb = new StringBuffer();
		sb.append("<categories>");
		for (EventCategory category : categories) {
			sb.append(String.format("<category id=\"%s\" name=\"%s\"/>",
					                category.getId(),
					                emptyIfNull(category.getName())
					));
		}
		sb.append("</categories>");
		return sb.toString();
	}

	public String getCalendarsXml(Event event) {
		Set<Calendar> calendars = event.getCalendars();
		StringBuffer sb = new StringBuffer();
		sb.append("<calendars>");
		for (Calendar calendar : calendars) {
			sb.append(String.format("<calendar id=\"%s\" name=\"%s\"/>",
					                calendar.getId(),
					                emptyIfNull(calendar.getName())
					));
		}
		sb.append("</calendars>");
		return sb.toString();
	}

	public String getLocationsXml(Event event) {
		Set<Location> locations = event.getLocations();
		StringBuffer sb = new StringBuffer();
		sb.append("<locations>");
		for (Location location : locations) {
			sb.append(String.format("<location id=\"%s\" name=\"%s\"/>",
					                location.getId(),
					                emptyIfNull(location.getName())
					));
		}
		sb.append("</locations>");
		return sb.toString();
	}

	public String getResourcesXml(Event event, Session session)
			throws Exception {
		Set<Resource> resources = event.getResources();
		StringBuffer sb = new StringBuffer();
		sb.append("<resources>");
		for (Resource resource : resources) {
			String url = ResourceController.getController().getResourceUrl(resource.getId(), session);
			sb.append(String.format("<resource key=\"%s\" url=\"%s\"/>",
					                emptyIfNull(resource.getAssetKey()),
					                emptyIfNull(url)));
		}
		sb.append("</resources>");
		return sb.toString();
	}

	public String getVersionsXml(Event event) {
		Set<EventVersion> versions = event.getVersions();
		StringBuffer sb = new StringBuffer();
		sb.append("<versions>");
		for (EventVersion version : versions) {
			sb.append(String.format("<version id=\"%s\" languageCode=\"%s\">" +
					                "<title><![CDATA[%s]]></title>" +
					                "<name><![CDATA[%s]]></name>" +
					                "<customLocation><![CDATA[%s]]></customLocation>" +
					                "<alternativeLocation><![CDATA[%s]]></alternativeLocation>" +
					                "<eventUrl><![CDATA[%s]]></eventUrl>" + 
					                "<description><![CDATA[%s]]></description>" +
					                "<shortDescription><![CDATA[%s]]></shortDescription>" +
					                "<longDescription><![CDATA[%s]]></longDescription>" +
					                "<attributes><![CDATA[%s]]></attributes>" + 
					                "<lecturer><![CDATA[%s]]></lecturer>" + 
					                "<organizerName><![CDATA[%s]]></organizerName>" + 
					                "</version>",
					                version.getId(),
					                emptyIfNull(version.getLanguage().getIsoCode()),
					                emptyIfNull(version.getTitle()),
					                emptyIfNull(version.getName()),
					                emptyIfNull(version.getCustomLocation()),
					                emptyIfNull(version.getAlternativeLocation()),
					                emptyIfNull(version.getEventUrl()),
					                emptyIfNull(version.getDescription()),
					                emptyIfNull(version.getShortDescription()),
					                emptyIfNull(version.getLongDescription()),
					                XMLUtils.xmlEncodeString(emptyIfNull(version.getAttributes())),
					                emptyIfNull(version.getLecturer()),
					                emptyIfNull(version.getOrganizerName())
					));
		}
		sb.append("</versions>");
		return sb.toString();
	}

    /**
     * Gets a calendar object with date and hour
     * 
     * @param dateString
     * @param pattern
     * @param hour
     * @return
     */
    
    public java.util.Calendar getCalendar(String dateString, String pattern, boolean fallback)
    {	
    	java.util. Calendar calendar = java.util.Calendar.getInstance();
        if(dateString == null)
        {
            return calendar;
        }
        
        Date date = new Date();    
        
        try
        {
	        // Format the current time.
	        SimpleDateFormat formatter = new SimpleDateFormat(pattern);
	        date = formatter.parse(dateString);
	        calendar.setTime(date);
	        //calendar.set(Calendar.HOUR_OF_DAY, hour.intValue());
        }
        catch(Exception e)
        {
            if(!fallback)
                return null;
        }
        
        return calendar;
    }

}
