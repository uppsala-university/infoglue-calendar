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

import org.apache.log4j.Logger;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.infoglue.calendar.controllers.EventController;
import org.infoglue.calendar.controllers.ResourceController;
import org.infoglue.calendar.entities.Event;
import org.infoglue.calendar.entities.EventVersion;
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
		StringBuffer sb = new StringBuffer();

		String eventIdStr = request.getParameter("eventId");

		sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");

		Session session = HibernateUtil.currentSession();
		Transaction tx = null;

		try 
		{
			tx = session.beginTransaction();
			
			Long eventId = new Long(eventIdStr);
			Event event = EventController.getController().getEvent(eventId, session);

			Set<EventVersion> versions = event.getVersions();
			StringBuffer versionsSb = new StringBuffer();
			versionsSb.append("<versions>");
			for (EventVersion version : versions) {
				versionsSb.append(String.format("<version id=\"%s\" languageCode=\"%s\" name=\"\" shortDescription=\"%s\" longDescription=\"%s\" customLocation=\"%s\" eventUrl=\"\"/>",
						          version.getId(),
						          version.getLanguage().getIsoCode(),
						          version.getName(),
						          version.getShortDescription(),
						          version.getLongDescription(),
						          version.getCustomLocation(),
						          version.getEventUrl()
						));
			}
			versionsSb.append("</versions>");
			
			Set<Resource> resources = event.getResources();
			StringBuffer resourcesSb = new StringBuffer();
			resourcesSb.append("<resources>");
			for (Resource resource : resources) {
				String url = ResourceController.getController().getResourceUrl(resource.getId(), session);
				resourcesSb.append(String.format("<resource key=\"%s\" url=\"%s\"/>",
						          resource.getAssetKey(),
						          url));
			}
			resourcesSb.append("</resources>");
			
			sb.append(String.format("<event id=\"%s\" startDate=\"%s\" endDate=\"%s\">%s%s</event>",
					                event.getId(),
					                vf.formatDate(event.getStartDateTime().getTime(), "yyyy-MM-dd"), 
					                vf.formatDate(event.getEndDateTime().getTime(), "yyyy-MM-dd"),
					                versionsSb,
					                resourcesSb
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
