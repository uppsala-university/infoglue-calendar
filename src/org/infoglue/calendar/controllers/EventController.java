/* ===============================================================================
*
* Part of the InfoGlue Content Management Platform (www.infoglue.org)
*
* ===============================================================================
*
*  Copyright (C)
* 
* This program is free software; you can redistribute it and/or modify it under
* the terms of the GNU General Public License version 2, as published by the
* Free Software Foundation. See the file LICENSE.html for more information.
* 
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY, including the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License along with
* this program; if not, write to the Free Software Foundation, Inc. / 59 Temple
* Place, Suite 330 / Boston, MA 02111-1307 / USA.
*
* ===============================================================================
*/

package org.infoglue.calendar.controllers;

import java.io.File;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.infoglue.calendar.entities.Calendar;
import org.infoglue.calendar.entities.Category;
import org.infoglue.calendar.entities.Event;
import org.infoglue.calendar.entities.EventCategory;
import org.infoglue.calendar.entities.EventTypeCategoryAttribute;
import org.infoglue.calendar.entities.EventVersion;
import org.infoglue.calendar.entities.Group;
import org.infoglue.calendar.entities.Language;
import org.infoglue.calendar.entities.Location;
import org.infoglue.calendar.entities.Participant;
import org.infoglue.calendar.entities.Resource;
import org.infoglue.calendar.entities.Role;
import org.infoglue.calendar.entities.Subscriber;
import org.infoglue.calendar.util.EventComparator;
import org.infoglue.common.security.beans.InfoGluePrincipalBean;
import org.infoglue.common.util.PropertyHelper;
import org.infoglue.common.util.RemoteCacheUpdater;
import org.infoglue.common.util.VelocityTemplateProcessor;
import org.infoglue.common.util.io.FileHelper;
import org.infoglue.common.util.mail.MailServiceFactory;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.criterion.Conjunction;
import org.hibernate.criterion.Criterion;
import org.hibernate.criterion.DetachedCriteria;
import org.hibernate.criterion.Expression;
import org.hibernate.criterion.Junction;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Property;
import org.hibernate.criterion.Restrictions;
import org.hibernate.criterion.Subqueries;

import com.sun.syndication.feed.atom.Link;

public class EventController extends BasicController
{    
    //Logger for this class
    private static Log log = LogFactory.getLog(EventController.class);
        
    
    /**
     * Factory method to get EventController
     * 
     * @return EventController
     */
    
    public static EventController getController()
    {
        return new EventController();
    }
        
    
    /**
     * This method is used to create a new Event object in the database.
     */
    
    public Event createEvent(Long calendarId, 
            				Event originalEvent, 
            	            Integer stateId,
            	            String creator,
            	            Long entryFormId,
            	            Session session) throws HibernateException, Exception 
    {
        Event event = null;
 
		Calendar calendar = CalendarController.getController().getCalendar(calendarId, session);
		
		Set locations = new HashSet();
		Iterator oldLocationsIterator = originalEvent.getLocations().iterator();
		while(oldLocationsIterator.hasNext())
		{
		    Location location = (Location)oldLocationsIterator.next();
		    locations.add(location);
		}
		
		Set participants = new HashSet();
		Iterator oldParticipantsIterator = originalEvent.getParticipants().iterator();
		while(oldParticipantsIterator.hasNext())
		{
		    Participant oldParticipant = (Participant)oldParticipantsIterator.next();
		    Participant participant = new Participant();
		    participant.setUserName(oldParticipant.getUserName());
		    participant.setEvent(event);
		    session.save(participant);
		    participants.add(participant);
		}
		
		event = createEvent(calendar, 
			                originalEvent.getIsInternal(), 
			                originalEvent.getIsOrganizedByGU(), 
			                originalEvent.getLastRegistrationDateTime(),
			                originalEvent.getMaximumParticipants(),
			                originalEvent.getStartDateTime(), 
			                originalEvent.getEndDateTime(),
			                originalEvent.getContactEmail(),
			                originalEvent.getContactName(),
			                originalEvent.getContactPhone(),
			                originalEvent.getPrice(),
			                locations, 
		        			participants,
		        			stateId,
		        			creator,
		        			entryFormId,
		        			session);
		
		Set eventVersions = new HashSet();
		Iterator eventVersionIterator = originalEvent.getVersions().iterator();
		while(eventVersionIterator.hasNext())
		{
			EventVersion originalEventVersion = (EventVersion)eventVersionIterator.next();
			
			EventVersion eventVersion = new EventVersion();

			eventVersion.setName(originalEventVersion.getName());
			eventVersion.setTitle(originalEventVersion.getTitle());
			eventVersion.setDescription(originalEventVersion.getDescription());
			eventVersion.setOrganizerName(originalEventVersion.getOrganizerName());
			eventVersion.setLecturer(originalEventVersion.getLecturer());
			eventVersion.setCustomLocation(originalEventVersion.getCustomLocation());
			eventVersion.setAlternativeLocation(originalEventVersion.getAlternativeLocation());
			eventVersion.setShortDescription(originalEventVersion.getShortDescription());
			eventVersion.setLongDescription(originalEventVersion.getLongDescription());
			eventVersion.setEventUrl(originalEventVersion.getEventUrl());
			//eventVersion.setContactName(originalEventVersion.getContactName());
			//eventVersion.setContactEmail(originalEventVersion.getContactEmail());
			//eventVersion.setContactPhone(originalEventVersion.getContactPhone());
			//eventVersion.setPrice(originalEventVersion.getPrice());
			
			eventVersion.setEvent(event);
			eventVersion.setLanguage(originalEventVersion.getLanguage());

			session.save(eventVersion);
		
			eventVersions.add(eventVersion);
		}

		Set eventCategories = new HashSet();
		Iterator oldEventCategoriesIterator = originalEvent.getEventCategories().iterator();
		while(oldEventCategoriesIterator.hasNext())
		{
		    EventCategory oldEventCategory = (EventCategory)oldEventCategoriesIterator.next();
		    
		    EventCategory eventCategory = new EventCategory();
		    eventCategory.setEvent(event);
		    eventCategory.setCategory(oldEventCategory.getCategory());
		    eventCategory.setEventTypeCategoryAttribute(oldEventCategory.getEventTypeCategoryAttribute());

		    session.save(eventCategory);
		    
	        eventCategories.add(eventCategory);
		}

		event.setEventCategories(eventCategories);
		event.setVersions(eventVersions);
		
        return event;
    }

    
    /**
     * This method is used to create a new Event object in the database.
     */
    
    public Event createEvent(Long calendarId, 
    						Long languageId,
            				String name, 
            				String title, 
            				String description, 
            				Boolean isInternal, 
            	            Boolean isOrganizedByGU, 
            	            String organizerName, 
            	            String lecturer, 
            	            String customLocation,
            	            String alternativeLocation,
            	            String shortDescription,
            	            String longDescription,
            	            String eventUrl,
            	            String contactName,
            	            String contactEmail,
            	            String contactPhone,
            	            String price,
            	            java.util.Calendar lastRegistrationCalendar,
            	            Integer maximumParticipants,
            	            java.util.Calendar startDateTime, 
            	            java.util.Calendar endDateTime, 
            	            Set oldLocations, 
            	            Set oldEventCategories, 
            	            Set oldParticipants,
            	            Integer stateId,
            	            String creator,
            	            Long entryFormId,
            	            String xml,
            	            Session session) throws HibernateException, Exception 
    {
        Event event = null;
 
		Calendar calendar = CalendarController.getController().getCalendar(calendarId, session);
		Language language = LanguageController.getController().getLanguage(languageId, session);
		
		Set locations = new HashSet();
		Iterator oldLocationsIterator = oldLocations.iterator();
		while(oldLocationsIterator.hasNext())
		{
		    Location location = (Location)oldLocationsIterator.next();
		    locations.add(location);
		}
		
		Set participants = new HashSet();
		Iterator oldParticipantsIterator = oldParticipants.iterator();
		while(oldParticipantsIterator.hasNext())
		{
		    Participant oldParticipant = (Participant)oldParticipantsIterator.next();
		    Participant participant = new Participant();
		    participant.setUserName(oldParticipant.getUserName());
		    participant.setEvent(event);
		    session.save(participant);
		    participants.add(participant);
		}

		event = createEvent(calendar, 
		        			isInternal, 
		                    isOrganizedByGU, 
		                    lastRegistrationCalendar,
		                    maximumParticipants,
		        			startDateTime, 
		        			endDateTime, 
		        			contactEmail,
		        			contactName,
		        			contactPhone,
		        			price,
		        			locations, 
		        			participants,
		        			stateId,
		        			creator,
		        			entryFormId,
		        			session);
		
		//Creates the master language version
		Set eventVersions = new HashSet();
		EventVersion eventVersion = new EventVersion();

		eventVersion.setName(name);
		eventVersion.setTitle(title);
		eventVersion.setDescription(description);
		eventVersion.setOrganizerName(organizerName);
		eventVersion.setLecturer(lecturer);
		eventVersion.setCustomLocation(customLocation);
		eventVersion.setAlternativeLocation(alternativeLocation);
		eventVersion.setShortDescription(shortDescription);
		eventVersion.setLongDescription(longDescription);
		eventVersion.setEventUrl(eventUrl);

		eventVersion.setEvent(event);
		eventVersion.setLanguage(language);

		session.save(eventVersion);

		eventVersions.add(eventVersion);

		
		Set eventCategories = new HashSet();
		Iterator oldEventCategoriesIterator = oldEventCategories.iterator();
		while(oldEventCategoriesIterator.hasNext())
		{
		    EventCategory oldEventCategory = (EventCategory)oldEventCategoriesIterator.next();
		    
		    EventCategory eventCategory = new EventCategory();
		    eventCategory.setEvent(event);
		    eventCategory.setCategory(oldEventCategory.getCategory());
		    eventCategory.setEventTypeCategoryAttribute(oldEventCategory.getEventTypeCategoryAttribute());
		    session.save(eventCategory);
		    
	        eventCategories.add(eventCategory);
		}

		event.setVersions(eventVersions);
		event.setEventCategories(eventCategories);
		
        return event;
    }

    
    
    /**
     * This method is used to create a new Event object in the database.
     */

    public Event createEvent(Long calendarId, 
    		Long languageId,
			String name, 
			String title, 
			String description, 
			Boolean isInternal, 
            Boolean isOrganizedByGU, 
            String organizerName, 
            String lecturer, 
            String customLocation,
            String alternativeLocation,
            String shortDescription,
            String longDescription,
            String eventUrl,
            String contactName,
            String contactEmail,
            String contactPhone,
            String price,
            java.util.Calendar lastRegistrationCalendar,
            Integer maximumParticipants,
            java.util.Calendar startDateTime, 
            java.util.Calendar endDateTime, 
            String[] locationId, 
            Map categoryAttributes, 
            String[] participantUserName,
            Integer stateId,
            String creator,
            Long entryFormId,
            String xml,
            Session session) throws HibernateException, Exception 
	{
		Event event = null;
		
		Calendar calendar = CalendarController.getController().getCalendar(calendarId, session);
		Language language = null;
		if(languageId != null)
			language = LanguageController.getController().getLanguage(languageId, session);
		else
			language = LanguageController.getController().getMasterLanguage(session);
		
		Set locations = new HashSet();
		if(locationId != null)
		{
			for(int i=0; i<locationId.length; i++)
			{
				if(!locationId[i].equals(""))
				{
					Location location = LocationController.getController().getLocation(new Long(locationId[i]), session);
					locations.add(location);
				}
			}
		}
		
		Set participants = new HashSet();
		if(participantUserName != null)
		{
			for(int i=0; i<participantUserName.length; i++)
			{
				Participant participant = new Participant();
				participant.setUserName(participantUserName[i]);
				participant.setEvent(event);
				session.save(participant);
				participants.add(participant);
			}
		}
		
		event = createEvent(calendar, 
					isInternal, 
		            isOrganizedByGU, 
		            lastRegistrationCalendar,
		            maximumParticipants,
					startDateTime, 
					endDateTime, 
					contactEmail,
					contactName,
					contactPhone,
					price,
					locations, 
					participants,
					stateId,
					creator,
					entryFormId,
					session);

		//Creates the master language version
		Set eventVersions = new HashSet();
		EventVersion eventVersion = new EventVersion();
		
		eventVersion.setName(name);
		eventVersion.setTitle(title);
		eventVersion.setDescription(description);
		eventVersion.setOrganizerName(organizerName);
		eventVersion.setLecturer(lecturer);
		eventVersion.setCustomLocation(customLocation);
		eventVersion.setAlternativeLocation(alternativeLocation);
		eventVersion.setShortDescription(shortDescription);
		eventVersion.setLongDescription(longDescription);
		eventVersion.setEventUrl(eventUrl);
		eventVersion.setAttributes(xml);

		eventVersion.setEvent(event);
		eventVersion.setLanguage(language);

		session.save(eventVersion);

		eventVersions.add(eventVersion);
		
		
		Set eventCategories = new HashSet();
		if(categoryAttributes != null)
		{
			Iterator categoryAttributesIterator = categoryAttributes.keySet().iterator();
			while(categoryAttributesIterator.hasNext())
			{
				String categoryAttributeId = (String)categoryAttributesIterator.next(); 
				log.info("categoryAttributeId:" + categoryAttributeId);
				EventTypeCategoryAttribute eventTypeCategoryAttribute = EventTypeCategoryAttributeController.getController().getEventTypeCategoryAttribute(new Long(categoryAttributeId), session);
				 
				String[] categoriesArray = (String[])categoryAttributes.get(categoryAttributeId);
				for(int i=0; i < categoriesArray.length; i++)
				{
				    Category category = CategoryController.getController().getCategory(new Long(categoriesArray[i]), session);
				    
				    EventCategory eventCategory = new EventCategory();
				    eventCategory.setEvent(event);
				    eventCategory.setCategory(category);
				    eventCategory.setEventTypeCategoryAttribute(eventTypeCategoryAttribute);
				    session.save(eventCategory);
				    
				    eventCategories.add(eventCategory);
				}
			}
		}
		
		event.setEventCategories(eventCategories);
		event.setVersions(eventVersions);
		
		return event;
	}
    
    
    /**
     * This method is used to create a new Event object in the database inside a transaction.
     */
    
    public Event createEvent(Calendar owningCalendar, 
            				Boolean isInternal, 
            	            Boolean isOrganizedByGU, 
            	            java.util.Calendar lastRegistrationCalendar,
            	            Integer maximumParticipants,
            	            java.util.Calendar startDateTime, 
            				java.util.Calendar endDateTime, 
            				String contactEmail,
            				String contactName,
    						String contactPhone,
    						String price,
            				Set locations, 
            				Set participants,
            				Integer stateId,
            				String creator,
            				Long entryFormId,
            				Session session) throws HibernateException, Exception 
    {
        Event event = new Event();
        event.setIsInternal(isInternal);
        event.setIsOrganizedByGU(isOrganizedByGU);
        event.setMaximumParticipants(maximumParticipants);
        event.setLastRegistrationDateTime(lastRegistrationCalendar);
        event.setStartDateTime(startDateTime);
        event.setEndDateTime(endDateTime);
        event.setContactEmail(contactEmail);
        event.setContactName(contactName);
        event.setContactPhone(contactPhone);
        event.setPrice(price);
        event.setStateId(stateId);
        event.setCreator(creator);
        event.setEntryFormId(entryFormId);
        
        event.setOwningCalendar(owningCalendar);
        event.getCalendars().add(owningCalendar);
        event.setLocations(locations);
        event.setParticipants(participants);
        owningCalendar.getEvents().add(event);
        
        session.save(event);
        
        return event;
    }
    
    /**
     * Updates an event.
     * 
     * @throws Exception
     */
    
    public void updateEvent(
            Long id, 
            Long languageId,
            String name, 
            String title,
            String description, 
            Boolean isInternal, 
            Boolean isOrganizedByGU, 
            String organizerName, 
            String lecturer, 
            String customLocation,
            String alternativeLocation,
            String shortDescription,
            String longDescription,
            String eventUrl,
            String contactName,
            String contactEmail,
            String contactPhone,
            String price,
            java.util.Calendar lastRegistrationCalendar,
            Integer maximumParticipants,
            java.util.Calendar startDateTime, 
            java.util.Calendar endDateTime, 
            String[] locationId, 
            Map categoryAttributes, 
            String[] participantUserName,
            Long entryFormId,
            String xml,
            Session session) throws Exception 
    {

        Event event = getEvent(id, session);
        Language language = LanguageController.getController().getLanguage(languageId, session);
        
		Set locations = new HashSet();
		if(locationId != null)
		{
			for(int i=0; i<locationId.length; i++)
			{
			    if(!locationId[i].equalsIgnoreCase(""))
			    {
			        Location location = LocationController.getController().getLocation(new Long(locationId[i]), session);
			        locations.add(location);
			    }
			}
		}
		
	    log.info("participantUserName: " + participantUserName);
		Set participants = new HashSet();
		if(participantUserName != null)
		{
			for(int i=0; i<participantUserName.length; i++)
			{
			    Participant participant = new Participant();
			    participant.setUserName(participantUserName[i]);
			    participant.setEvent(event);
			    log.info("Adding " + participantUserName[i]);

			    session.save(participant);
			    participants.add(participant);
			}
		}
		
		updateEvent(
		        event,
		        language,
		        name, 
		        title,
		        description, 
		        isInternal, 
		        isOrganizedByGU, 
		        organizerName, 
		        lecturer, 
		        customLocation,
		        alternativeLocation,
                shortDescription,
                longDescription,
                eventUrl,
                contactName,
                contactEmail,
                contactPhone,
                price,
                lastRegistrationCalendar,
                maximumParticipants,
		        startDateTime, 
		        endDateTime, 
		        locations, 
		        categoryAttributes, 
		        participants, 
		        entryFormId,
		        xml,
		        session);
		
    }
    
    /**
     * Updates an event inside an transaction.
     * 
     * @throws Exception
     */
    
    public void updateEvent(
            Event event, 
            Language language,
            String name, 
            String title, 
            String description, 
            Boolean isInternal, 
            Boolean isOrganizedByGU, 
            String organizerName, 
            String lecturer, 
            String customLocation,
            String alternativeLocation,
            String shortDescription,
            String longDescription,
            String eventUrl,
            String contactName,
            String contactEmail,
            String contactPhone,
            String price,
            java.util.Calendar lastRegistrationCalendar,
            Integer maximumParticipants,
            java.util.Calendar startDateTime, 
            java.util.Calendar endDateTime, 
            Set locations, 
            Map categoryAttributes, 
            Set participants, 
            Long entryFormId,
            String xml,
            Session session) throws Exception 
    {
    	EventVersion eventVersion = null;
        Iterator eventVersions = event.getVersions().iterator();
        while(eventVersions.hasNext())
        {
        	EventVersion currentEventVersion = (EventVersion)eventVersions.next();
        	if(currentEventVersion.getVersionLanguageId().equals(language.getId()))
        	{
        		eventVersion = currentEventVersion;
        		break;
        	}
        }
        
        if(eventVersion == null)
        {
        	eventVersion = new EventVersion();
        	eventVersion.setLanguage(language);
        	eventVersion.setEvent(event);
        	eventVersion.setName(name);
    		eventVersion.setTitle(title);
        	eventVersion.setDescription(description);
            eventVersion.setOrganizerName(organizerName);
            eventVersion.setLecturer(lecturer);
            eventVersion.setCustomLocation(customLocation);
            eventVersion.setAlternativeLocation(alternativeLocation);
            eventVersion.setShortDescription(shortDescription);
            eventVersion.setLongDescription(longDescription);
            eventVersion.setEventUrl(eventUrl);
            eventVersion.setAttributes(xml);
            
        	session.save(eventVersion);
        }
        else
        {
        	eventVersion.setName(name);
    		eventVersion.setTitle(title);
        	eventVersion.setDescription(description);
            eventVersion.setOrganizerName(organizerName);
            eventVersion.setLecturer(lecturer);
            eventVersion.setCustomLocation(customLocation);
            eventVersion.setAlternativeLocation(alternativeLocation);
            eventVersion.setShortDescription(shortDescription);
            eventVersion.setLongDescription(longDescription);
            eventVersion.setEventUrl(eventUrl);
            eventVersion.setAttributes(xml);
            
    		session.update(eventVersion);
        }

        event.setIsInternal(isInternal);
        event.setIsOrganizedByGU(isOrganizedByGU);
        event.setContactName(contactName);
        event.setContactEmail(contactEmail);
        event.setContactPhone(contactPhone);
        event.setPrice(price);
        event.setMaximumParticipants(maximumParticipants);
        event.setLastRegistrationDateTime(lastRegistrationCalendar);
        event.setStartDateTime(startDateTime);
        event.setEndDateTime(endDateTime);
        event.setLocations(locations);
        event.setEntryFormId(entryFormId);
        //event.setAttributes(xml);
        
        Iterator eventCategoryIterator = event.getEventCategories().iterator();
		while(eventCategoryIterator.hasNext())
		{
		    EventCategory eventCategory = (EventCategory)eventCategoryIterator.next();
		    session.delete(eventCategory);
		}
		
        Set eventCategories = new HashSet();
		if(categoryAttributes != null)
		{
			Iterator categoryAttributesIterator = categoryAttributes.keySet().iterator();
			while(categoryAttributesIterator.hasNext())
			{
			    String categoryAttributeId = (String)categoryAttributesIterator.next(); 
			    log.info("categoryAttributeId:" + categoryAttributeId);
			    EventTypeCategoryAttribute eventTypeCategoryAttribute = EventTypeCategoryAttributeController.getController().getEventTypeCategoryAttribute(new Long(categoryAttributeId), session);
			     
			    String[] categoriesArray = (String[])categoryAttributes.get(categoryAttributeId);
			    for(int i=0; i < categoriesArray.length; i++)
			    {
			        Category category = CategoryController.getController().getCategory(new Long(categoriesArray[i]), session);
			        
			        EventCategory eventCategory = new EventCategory();
				    eventCategory.setEvent(event);
			    	
				    eventCategory.setCategory(category);
				    eventCategory.setEventTypeCategoryAttribute(eventTypeCategoryAttribute);
				    session.save(eventCategory);
				    
			        eventCategories.add(eventCategory);
			    }
			}
		}
		event.setEventCategories(eventCategories);
        
        event.setParticipants(participants);
        
		session.update(event);
		
		if(event.getStateId().equals(Event.STATE_PUBLISHED))
		    new RemoteCacheUpdater().updateRemoteCaches(event.getCalendars());
	}
    

    /**
     * This method is used to create a new Event object in the database.
     */
    
    public void linkEvent(Long calendarId, Long eventId, Session session) throws HibernateException, Exception 
    {
        Calendar calendar = CalendarController.getController().getCalendar(calendarId, session);
        Event event = EventController.getController().getEvent(eventId, session);		

        event.getCalendars().add(calendar);
        
		new RemoteCacheUpdater().updateRemoteCaches(calendarId);
    }

    /**
     * Submits an event for publication.
     * 
     * @throws Exception
     */
    
    public void submitForPublishEvent(Long id, String publishEventUrl, String languageCode, InfoGluePrincipalBean infoGluePrincipal, Session session) throws Exception 
    {
		Event event = getEvent(id, session);
		event.setStateId(Event.STATE_PUBLISH);
		EventVersion eventVersion = getEventVersion(event, languageCode, session);
		System.out.println("notifyPublishers:" + notifyPublishers());
		System.out.println("useEventPublishing:" + useEventPublishing());
        if(useEventPublishing() && notifyPublishers())
        {
            try
            {
                EventController.getController().notifyPublisher(event, eventVersion, publishEventUrl, infoGluePrincipal);
            }
            catch(Exception e)
            {
                log.warn("An error occcurred:" + e.getMessage(), e);
            }
        }

    }    

    
    /**
     * Publishes an event.
     * 
     * @throws Exception
     */
    
    public void publishEvent(Long id, String publishedEventUrl, String languageCode, InfoGluePrincipalBean infoGluePrincipal, Session session) throws Exception 
    {
		Event event = getEvent(id, session);
		event.setStateId(Event.STATE_PUBLISHED);
		EventVersion eventVersion = getEventVersion(event, languageCode, session);
		
		new RemoteCacheUpdater().updateRemoteCaches(event.getOwningCalendar().getId());
		
        if(useGlobalEventNotification())
        {
            try
            {
                EventController.getController().notifySubscribers(event, eventVersion, publishedEventUrl, infoGluePrincipal);
            }
            catch(Exception e)
            {
                log.warn("An error occcurred:" + e.getMessage(), e);
            }
        }

    }    
    
    /**
     * This method returns a Event based on it's primary key inside a transaction
     * @return Event
     * @throws Exception
     */

    public Event getEvent(Long id, Session session) throws Exception
    {
        Event event = (Event)session.load(Event.class, id);
		
		return event;
    }

    /**
     * This method returns a Event based on it's primary key inside a transaction
     * @return Event
     * @throws Exception
     */

    public EventVersion getEventVersion(Long id, Session session) throws Exception
    {
        EventVersion eventVersion = (EventVersion)session.load(EventVersion.class, id);
		
		return eventVersion;
    }

    public EventVersion getEventVersion(Event event, String languageCode, Session session)
    {        
        if(event == null)
    		return null;

    	EventVersion eventVersion = null;

    	try
    	{
    		Language language = LanguageController.getController().getLanguageWithCode(languageCode, session);
	    	
	    	Iterator eventVersionsIterator = event.getVersions().iterator();
	        while(eventVersionsIterator.hasNext())
	        {
	        	EventVersion currentEventVersion = (EventVersion)eventVersionsIterator.next();
	        	if(currentEventVersion.getVersionLanguageId().equals(language.getId()))
	        	{
	        		eventVersion = currentEventVersion;
	        		break;
	        	}
	        }
	        
	        if(eventVersion == null && event.getVersions().size() > 0)
	        	eventVersion = (EventVersion)event.getVersions().toArray()[0];
    	}
    	catch(Exception e)
    	{
    		log.error("Error when getting event version for event: " + event + ":" + e.getMessage(), e); 
    	}
    	
        return eventVersion;
    }

    /**
     * This method returns a Event based on it's primary key inside a transaction and states if it's a read only or not
     * @return Event
     * @throws Exception
     */
/*    
    public Event getEvent(Long id, Session session, boolean readOnly) throws Exception
    {
        Event event = (Event)session.load(Event.class, id);
		session.setReadOnly(event, readOnly);
		
		return event;
    }
*/    
    
    /**
     * Gets a list of all events available for a particular day.
     * @return List of Event
     * @throws Exception
     */
    
    public List getEventList(Session session) throws Exception 
    {
        List result = null;
        
        Query q = session.createQuery("from Event event order by event.id");
   
        result = q.list();
        
        return result;
    }
    
    
    /**
     * Gets a list of all events matching the arguments given.
     * @return List of Event
     * @throws Exception
     */
    
    public List getExpiredEventList(java.util.Calendar now/*, java.util.Calendar lastCheckedDate*/, Session session) throws Exception 
    {
        java.util.Calendar recentExpirations = java.util.Calendar.getInstance();
        recentExpirations.setTime(now.getTime());
        recentExpirations.add(java.util.Calendar.HOUR_OF_DAY, -1);
        
        List result = null;
        log.info("Checking for any events which are published and which have expired just now..");
        
        Criteria criteria = session.createCriteria(Event.class);
        criteria.add(Expression.lt("endDateTime", now));
        criteria.add(Expression.gt("endDateTime", recentExpirations));

        //criteria.add(Expression.gt("endDateTime", lastCheckedDate));

        log.info("endDateTime:" + now.getTime());
        
        result = criteria.list();
        
        return result;
    }

    
    /**
     * Gets a list of all events matching the arguments given.
     * @return List of Event
     * @throws Exception
     */
    
    public List getEventList(String name,
            java.util.Calendar startDateTime,
            java.util.Calendar endDateTime,
        	String organizerName,
        	String lecturer,
            String customLocation,
            String alternativeLocation,
            String contactName,
            String contactEmail,
            String contactPhone,
            String price,
            Integer maximumParticipants,
            Boolean sortAscending,
            Long categoryId,
            Long calendarId,
            Long locationId,
            Session session) throws Exception 
    {
        List result = null;
                
        Criteria criteria = session.createCriteria(Event.class);
        
        Criteria eventVersionCriteria = criteria.createCriteria("versions");
        if(name != null && name.length() > 0)
        	eventVersionCriteria.add(Restrictions.like("name", "%" + name + "%"));
        
        if(organizerName != null && organizerName.length() > 0)
        	eventVersionCriteria.add(Restrictions.like("organizerName", "%" + organizerName + "%"));

        if(lecturer != null && lecturer.length() > 0)
        	eventVersionCriteria.add(Restrictions.like("lecturer", "%" + lecturer + "%"));

        if(customLocation != null && customLocation.length() > 0)
        	eventVersionCriteria.add(Restrictions.like("customLocation", "%" + customLocation + "%"));

        if(alternativeLocation != null && alternativeLocation.length() > 0)
        	eventVersionCriteria.add(Restrictions.like("alternativeLocation", "%" + alternativeLocation + "%"));

        if(contactName != null && contactName.length() > 0)
        	criteria.add(Restrictions.like("contactName", "%" + contactName + "%"));

        if(contactEmail != null && contactEmail.length() > 0)
        	criteria.add(Restrictions.like("contactEmail", "%" + contactEmail + "%"));

        if(contactPhone != null && contactPhone.length() > 0)
        	criteria.add(Restrictions.like("contactPhone", "%" + contactPhone + "%"));

        if(price != null && price.length() > 0)
        	criteria.add(Restrictions.eq("price", "%" + price + "%"));

        if(maximumParticipants != null)
        	criteria.add(Restrictions.le("maximumParticipants", maximumParticipants));

        if(startDateTime != null)
        	criteria.add(Restrictions.ge("startDateTime", startDateTime));

        if(endDateTime != null)
        	criteria.add(Restrictions.le("endDateTime", endDateTime));
        
        if(sortAscending.booleanValue())
        {
        	criteria.addOrder(Order.asc("startDateTime"));
        }
        else
        {
        	criteria.addOrder(Order.desc("startDateTime"));	
        }
        
        result = criteria.list();
   
        if(categoryId != null)
        {
	        Iterator resultIterator = result.iterator();
	        while(resultIterator.hasNext())
	        {
	        	Event event = (Event)resultIterator.next();
	        	if(!getHasCategory(event, categoryId))
	        		resultIterator.remove();
	        }
        }

        if(calendarId != null)
        {
	        Iterator resultIterator = result.iterator();
	        while(resultIterator.hasNext())
	        {
	        	Event event = (Event)resultIterator.next();
	        	if(!getHasCalendar(event, calendarId))
	        		resultIterator.remove();
	        }
        }

        if(locationId != null)
        {
	        Iterator resultIterator = result.iterator();
	        while(resultIterator.hasNext())
	        {
	        	Event event = (Event)resultIterator.next();
	        	if(!getHasLocation(event, locationId))
	        		resultIterator.remove();
	        }
        }

        return result;
    }
    
    
    
    /**
     * Gets a list of all events available for a particular user.
     * @return List of Event
     * @throws Exception
     */
    
    public Set getEventList(java.util.Calendar startDate, java.util.Calendar endDate, String userName, List roles, List groups, Integer stateId, boolean includeLinked, boolean includeEventsCreatedByUser, Session session) throws Exception 
    {
        List result = new ArrayList();
        
        if(includeLinked)
        {
            String rolesSQL = getRoleSQL(roles);
            log.info("groups:" + groups.size());
	        String groupsSQL = getGroupsSQL(groups);
	        log.info("groupsSQL:" + groupsSQL);
	        String sql = "select c from Calendar c, Role cr, Group g where cr.calendar = c AND g.calendar = c " + (rolesSQL != null ? " AND cr.name IN " + rolesSQL : "") + (groupsSQL != null ? " AND g.name IN " + groupsSQL : "") + " order by c.id";
	        log.info("sql:" + sql);
	        Query q = session.createQuery(sql);
	        setRoleNames(0, q, roles);
	        setGroupNames(roles.size(), q, groups);
	        List calendars = q.list();

	        /*
	        Long[] calendarIdArray = new Long[calendars.size()];

	        int i = 0;
	        Iterator calendarsIterator = calendars.iterator();
        	while(calendarsIterator.hasNext())
	        {
	            Calendar calendar = (Calendar)calendarsIterator.next();
	            log.info("calendar: " + calendar.getName());
	            calendarIdArray[i] = calendar.getId();
	            i++;                
	        }
        	
            if(calendarIdArray.length > 0)
	        */
	        if (calendars.size() > 0)
            {
            	String linkedSql =
            			"select " +
            			"  event from Event event, Calendar c " +
            			"where " +
    	        		"  c in elements(event.calendars) AND " +
    	        		// Make sure we are allowed to access the event
    	        		"  c in (:calendars) AND " +
    	        		// Do not include events that have exactly one calendar AND that calendar being the owningCalendar
    	        		" NOT (size(event.calendars) = 1 AND event.owningCalendar in elements(event.calendars)) AND " +
    	        		"  event.endDateTime >= :endDateTime " +
    	        		"order by " +
    	        		"  event.startDateTime";
    	        Query linkedQuery = session.createQuery(linkedSql);
    	        linkedQuery.setParameterList("calendars", calendars);
    	        linkedQuery.setCalendar("endDateTime", startDate);
    	        result = linkedQuery.list();
            }	        
        }
        else
        {
	        String rolesSQL = getRoleSQL(roles);
	        log.info("groups:" + groups.size());
	        String groupsSQL = getGroupsSQL(groups);
	        log.info("groupsSQL:" + groupsSQL);
	        String sql = "select event from Event event, Calendar c, Role cr, Group g where event.owningCalendar = c AND cr.calendar = c AND g.calendar = c AND event.stateId = ? AND event.endDateTime >= ? " + (rolesSQL != null ? " AND cr.name IN " + rolesSQL : "") + (groupsSQL != null ? " AND g.name IN " + groupsSQL : "") + " order by event.startDateTime";
	        log.info("sql:" + sql);
	        Query q = session.createQuery(sql);
	        q.setInteger(0, stateId.intValue());
	        q.setCalendar(1, startDate);
	        log.info("startDate:" + startDate.getTime());
	        setRoleNames(2, q, roles);
	        setGroupNames(roles.size() + 2, q, groups);
	        
	        result = q.list();
        }
        
        log.info("result:" + result.size());
        
        Set set = new LinkedHashSet();
        set.addAll(result);	

        if(includeEventsCreatedByUser)
        {
            Criteria criteria = session.createCriteria(Event.class);
            criteria.add(Restrictions.eq("stateId", stateId));
            criteria.add(Restrictions.eq("creator", userName));
            criteria.add(Expression.gt("endDateTime", startDate));
            criteria.addOrder(Order.asc("startDateTime"));
            
            set.addAll(criteria.list());	
        }
        
        List sortedList = new ArrayList();
        sortedList.addAll(set);
        
        Collections.sort(sortedList, new EventComparator());
        set.clear();
        
        set.addAll(sortedList);
        
        return set;
    }


    /**
     * Gets a list of all events available for a particular user which are in working mode.
     * @return List of Event
     * @throws Exception
     */
    
    public Set getMyWorkingEventList(String userName, List roles, List groups, Session session) throws Exception 
    {
        java.util.Calendar now = java.util.Calendar.getInstance();
        java.util.Calendar endDate = java.util.Calendar.getInstance();
        endDate.add(java.util.Calendar.YEAR, 5);
        
        Set result = getEventList(now, endDate, userName, roles, groups, Event.STATE_WORKING, false, true, session);
        
        return result;
    }

    
    /**
     * Gets a list of all events available for a particular user which are in working mode.
     * @return List of Event
     * @throws Exception
     */
    
    public Set getWaitingEventList(String userName, List roles, List groups, Session session) throws Exception 
    {
        java.util.Calendar now = java.util.Calendar.getInstance();
        java.util.Calendar endDate = java.util.Calendar.getInstance();
        endDate.add(java.util.Calendar.YEAR, 5);
        
        Set result = getEventList(now, endDate, userName, roles, groups, Event.STATE_PUBLISH, false, false, session);
        
        return result;
    }

    /**
     * Gets a list of all events available for a particular user which are in working mode.
     * @return List of Event
     * @throws Exception
     */
    
    public Set getPublishedEventList(String userName, List roles, List groups, Long categoryId, Session session) throws Exception 
    {
        java.util.Calendar now = java.util.Calendar.getInstance();
        java.util.Calendar endDate = java.util.Calendar.getInstance();
        endDate.add(java.util.Calendar.YEAR, 5);
        
        Set result = getEventList(now, endDate, userName, roles, groups, Event.STATE_PUBLISHED, false, true, session);
        
        if(categoryId != null)
        {
	        Iterator resultIterator = result.iterator();
	        while(resultIterator.hasNext())
	        {
	        	Event event = (Event)resultIterator.next();
	        	if(!getHasCategory(event, categoryId))
	        		resultIterator.remove();
	        }
        }
        
        return result;
    }

    public boolean getHasCategory(Event event, Long categoryId)
    {        
        Iterator i = event.getEventCategories().iterator();
        while(i.hasNext())
        {
            EventCategory eventCategory = (EventCategory)i.next();
            if(eventCategory.getCategory().getId().equals(categoryId))
                return true;
        }

        return false;
    }

    public boolean getHasCalendar(Event event, Long calendarId)
    {        
    	if(event.getOwningCalendar() != null)
    		return calendarId.equals(event.getOwningCalendar().getId());
    	else
    		return false;
    }

    public boolean getHasLocation(Event event, Long locationId)
    {        
        Iterator i = event.getLocations().iterator();
        while(i.hasNext())
        {
            Location location = (Location)i.next();
            if(location.getId().equals(locationId))
                return true;
        }

        return false;
    }

    /**
     * Gets a list of all events available for a particular user which are in working mode.
     * @return List of Event
     * @throws Exception
     */
    
    public Set getLinkedPublishedEventList(String userName, List roles, List groups, Long categoryId, Session session) throws Exception 
    {
        java.util.Calendar now = java.util.Calendar.getInstance();
        java.util.Calendar endDate = java.util.Calendar.getInstance();
        endDate.add(java.util.Calendar.YEAR, 5);
        
        Set result = getEventList(now, endDate, userName, roles, groups, Event.STATE_PUBLISHED, true, false, session);
        
        if(categoryId != null)
        {
	        Iterator resultIterator = result.iterator();
	        while(resultIterator.hasNext())
	        {
	        	Event event = (Event)resultIterator.next();
	        	if(!getHasCategory(event, categoryId))
	        		resultIterator.remove();
	        }
        }

        return result;
    }

    public Set getEventList(Long id, Integer stateId, java.util.Calendar startDate, java.util.Calendar endDate, Session session) throws Exception
    {
        Set list = null;
        
		Calendar calendar = CalendarController.getController().getCalendar(id, session);
		list = getEventList(calendar, stateId, startDate, endDate, session);
		
		return list;
    }

    /**
     * @deprecated Use {@link #getEventList(String[], Map, String, java.util.Calendar, java.util.Calendar, String, Session)} instead, which has a more general category handling
     */
    public List<Event> getEventList(String[] calendarIds, String categoryAttribute, String[] categoryNames, String includedLanguages, java.util.Calendar startCalendar, java.util.Calendar endCalendar, String freeText, Session session) throws Exception 
    {
    	return getEventList(calendarIds, Collections.singletonMap(categoryAttribute, categoryNames), includedLanguages, startCalendar, endCalendar, freeText, session);
    }

    /**
     * @deprecated Use {@link #getEventList(String[], Map, String, java.util.Calendar, java.util.Calendar, String, String, Integer, Session)} instead, which has a more general category handling
     */
    public List<Event> getEventList(String[] calendarIds, String categoryAttribute, String[] categoryNames, String includedLanguages, java.util.Calendar startCalendar, java.util.Calendar endCalendar, String freeText, Integer numberOfItems, Session session) throws Exception
    {
    	return getEventList(calendarIds, Collections.singletonMap(categoryAttribute, categoryNames), includedLanguages, startCalendar, endCalendar, freeText, numberOfItems, null, session);
    }

    public List<Event> getEventList(String[] calendarIds, Map<String, String[]> categories, String includedLanguages, java.util.Calendar startCalendar, java.util.Calendar endCalendar, String freeText, Session session) throws Exception 
    {
    	return getEventList(calendarIds, categories, includedLanguages, startCalendar, endCalendar, freeText, null, null, session);
    }

    /**
     * Gets a list of all events available for a particular calendar with the optional categories.
     * @param categories The Map should have the form: key = EventType's categoryattribute name, value = list of Category.internalNames to match against
     * @param daysToCountAsLongEvent If specified, will make events longer than this duration to be put at the end of the returned list, preserving order.
     * @return List of Event
     * @throws Exception
     */
    public List<Event> getEventList(String[] calendarIds, Map<String, String[]> categories, String includedLanguages, java.util.Calendar startCalendar, java.util.Calendar endCalendar, String freeText, Integer numberOfItems, Integer daysToCountAsLongEvent, Session session) throws Exception 
    {
        List result = null;
        
        String calendarSQL = null;
        if(calendarIds != null && calendarIds.length > 0)
        {
            calendarSQL = "(";
	        for(int i=0; i<calendarIds.length; i++)
	        {
	            String calendarIdString = calendarIds[i];

	            try
	            {
	                Integer calendarId = new Integer(calendarIdString);
	            }
	            catch(Exception e)
	            {
	                log.warn("An invalid calendarId was given:" + e.getMessage());
	                return null;
	            }
	            
	            if(i > 0)
	                calendarSQL += ",";
	            
	            calendarSQL += calendarIdString;
	        }
	        calendarSQL += ")";
        }
        else
        {
            return null;
        }

        Object[] calendarIdArray = new Object[calendarIds.length];
        for(int i=0; i<calendarIds.length; i++)
            calendarIdArray[i] = new Long(calendarIds[i]);

        // Use a LinkedHashSet instead of any Set explicitly since we want a Set that preveserves insertion order.
        // Use a Set instead of a List to avoid duplicate events
        LinkedHashSet<Event> orderedEventSet = new LinkedHashSet<Event>();
        
        if(calendarIdArray.length > 0)
        {
	        Criteria criteria = session.createCriteria(Event.class);
	        criteria.add(Expression.eq("stateId", Event.STATE_PUBLISHED));

	        Criteria versionsCriteria = criteria.createAlias("versions", "v");
	        
	        if(startCalendar != null && endCalendar != null)
	        {
	        	// It would be optimal to use a half open approach here, but we don't want to change this code too much
	        	// since there could be calling code that relies on the current behavior.
	        	// See https://stackoverflow.com/a/20536041/185596
	        	criteria.add(Expression.and(Expression.le("startDateTime", endCalendar), Expression.ge("endDateTime", startCalendar)));
	        }
	        else
	        {
	        	criteria.add(Expression.gt("endDateTime", java.util.Calendar.getInstance()));
		    }
	        
	        
	        criteria.add(Expression.eq("stateId", Event.STATE_PUBLISHED));
	        criteria.addOrder(Order.asc("startDateTime"));
	        criteria.createCriteria("calendars")
	        .add(Expression.in("id", calendarIdArray));

	        if (log.isInfoEnabled())
	        {
	        	StringBuilder sb = null;
	        	if (categories != null)
	        	{
	        		sb = new StringBuilder();
	        		sb.append("{");
	        		for (Map.Entry<String, String[]> category : categories.entrySet())
	        		{
	        			if (category.getKey() != null)
	        			{
		        			sb.append(category.getKey() );
		        			sb.append("=");
		        			sb.append(Arrays.toString(category.getValue()));
		        			sb.append(", ");
	        			}
	        			else
	        			{
	        				sb.append("--null-key--, ");
	        			}
	        		}
	        		// Remove extra comma
	        		if (categories.size() > 0)
	        		sb.delete(sb.length() - 2, sb.length());
	        		sb.append("}");
	        	}
	        	log.info("categories:" + sb);
	        }
	        if(categories != null && categories.size() > 0)
	        {
	        	List<DetachedCriteria> eventCategoryCriterias = new LinkedList<DetachedCriteria>();
	            for (Map.Entry<String, String[]> entry : categories.entrySet())
	            {
	            	DetachedCriteria dc = DetachedCriteria.forClass(EventCategory.class, "ec")
	            			.setProjection(Property.forName("event.id"))
		        			.createAlias("ec.eventTypeCategoryAttribute", "etca")
		        			.createAlias("ec.category", "cat");

	            	Conjunction cas = Restrictions.conjunction();
	            	boolean include = false;
	            	if (entry.getKey() != null && !"".equals(entry.getKey())) // empty string means categoryAttribute was not defined
	            	{
		            	log.debug("Adding category internal name: " + entry.getKey());
		            	cas.add(Property.forName("etca.internalName").eq(entry.getKey()));
		            	include = true;
	            	}
	            	else if(log.isInfoEnabled())
	            	{
	            		log.info("Got no category attribute. Will search for provided categorys in all category keys.");
	            	}
	            	if (entry.getValue() != null && entry.getValue().length > 0)
	            	{
	            		log.debug("Category values: " + Arrays.toString(entry.getValue()));
	            		if (entry.getValue().length == 1 && "".equals(entry.getValue()[0]))
        				{
	            			log.debug("Category value list was empty will not add criteria");
	            			continue;
        				}
	            		cas.add(Property.forName("cat.internalName").in(entry.getValue()));
	            		include = true;
	            	}
	            	if (include)
	            	{
		            	dc.add(cas);
		            	eventCategoryCriterias.add(dc);
		            }
	            }
	            for (DetachedCriteria dc : eventCategoryCriterias)
	            {
	            	criteria.add( Subqueries.propertyIn("id", dc) );
	            }
	        }

	        Criteria languageVersionCriteria = null;
	        log.info("includedLanguages:" + includedLanguages);
	        if(includedLanguages != null && !includedLanguages.equalsIgnoreCase("") && !includedLanguages.equalsIgnoreCase("*"))
	        {
	        	//languageVersionCriteria = criteria.createCriteria("versions");
	        	versionsCriteria.createCriteria("v.language").add(Expression.eq("isoCode", includedLanguages));
	        }

	        if(freeText != null && !freeText.equals(""))
	        {
	        	Criterion nameRestriction = Restrictions.like("name", "%" + freeText + "%");
	        	Criterion organizerNameRestriction = Restrictions.like("organizerName", "%" + freeText + "%");

	        	Junction d1 = Restrictions.disjunction()
	            .add(Restrictions.like("v.name", "%" + freeText + "%"))
	            .add(Restrictions.like("v.description", "%" + freeText + "%"))
	            .add(Restrictions.like("v.lecturer", "%" + freeText + "%"))
	            .add(Restrictions.like("v.longDescription", "%" + freeText + "%"))
	            .add(Restrictions.like("v.shortDescription", "%" + freeText + "%"))
	            .add(Restrictions.like("v.organizerName", "%" + freeText + "%"))
	            .add(Restrictions.like("v.customLocation", "%" + freeText + "%"))
	            .add(Restrictions.like("v.eventUrl", "%" + freeText + "%"))
	            .add(Restrictions.like("v.alternativeLocation", "%" + freeText + "%"))
	            .add(Restrictions.like("name", "%" + freeText + "%"))
	            .add(Restrictions.like("description", "%" + freeText + "%"))
	            .add(Restrictions.like("contactName", "%" + freeText + "%"))
	            .add(Restrictions.like("lecturer", "%" + freeText + "%"))
	            .add(Restrictions.like("longDescription", "%" + freeText + "%"))
	            .add(Restrictions.like("contactEmail", "%" + freeText + "%"))
	            .add(Restrictions.like("shortDescription", "%" + freeText + "%"))
	            .add(Restrictions.like("organizerName", "%" + freeText + "%"))
	            .add(Restrictions.like("contactPhone", "%" + freeText + "%"))
	            .add(Restrictions.like("price", "%" + freeText + "%"))
	            .add(Restrictions.like("customLocation", "%" + freeText + "%"))
	            .add(Restrictions.like("eventUrl", "%" + freeText + "%"))
	            .add(Restrictions.like("alternativeLocation", "%" + freeText + "%"));
	            
	        	criteria.add(d1);
	        }

	        if(numberOfItems != null && numberOfItems != -1)
	        {
	        	criteria.setMaxResults(numberOfItems);
	        }

	        
	        result = criteria.list();

	        log.info("result:" + result.size());
	        
	        orderedEventSet.addAll(result);	
        }
        
        // Convert Set to List
        List<Event> eventList = new LinkedList<Event>(orderedEventSet);
        
        if (daysToCountAsLongEvent != null) 
        {
        	// Move all long events to the end of the list
        	List<Event> longEvents = new LinkedList<Event>();
        	for (Iterator<Event> iterator = eventList.iterator(); iterator.hasNext();) {
        		Event event = iterator.next();
        	    if (eventDuration(event) >= daysToCountAsLongEvent) {
        	    	longEvents.add(event);
        	        iterator.remove();
        	    }
        	}
        	eventList.addAll(longEvents);
        }
        
        return eventList;
    }
    
    public static java.util.Calendar beginningOfDay(java.util.Calendar date) 
    {    	
    	date = (java.util.Calendar) date.clone();
    	date.set(java.util.Calendar.HOUR_OF_DAY, 0);
    	date.set(java.util.Calendar.MINUTE, 0);
    	date.set(java.util.Calendar.SECOND, 0);
    	
    	return date;
    }
    
    /*
     * Copied from https://stackoverflow.com/a/19463133/185596 and
     * modified.
     */
    public static long daysBetween(java.util.Calendar startDate, java.util.Calendar endDate) {
    	startDate = beginningOfDay(startDate);
    	endDate = beginningOfDay(endDate);
    	
        long end = endDate.getTimeInMillis();
        long start = startDate.getTimeInMillis();
        return TimeUnit.MILLISECONDS.toDays(Math.abs(end - start));
    }
    
    /**
     * Returns the number of days an event lasts, not caring about at what time of day the event starts and ends.
     */
    public static long eventDuration(Event event) {
    	return daysBetween(event.getStartDateTime(), event.getEndDateTime());
    }
    
    /**
     * Gets a list of all events available for a particular calendar with the optional categories.
     * @return List of Event
     * @throws Exception
     */
    
    public Set<EventCategory> getEventCategoryList(Long categoryId, Session session) throws Exception 
    {
        List result = null;

        Set<EventCategory> set = new LinkedHashSet<EventCategory>();

        Criteria criteria = session.createCriteria(EventCategory.class);
        Criteria categoryCriteria = criteria.createCriteria("category");
        categoryCriteria.add(Expression.eq("id", categoryId));
        
        result = criteria.list();
        
        log.info("result:" + result.size());
        
        set.addAll(result);	        
        
        return set;
    }
    
    /**
     * This method returns a list of Events based on a number of parameters within a transaction
     * @return List
     * @throws Exception
     */
    
    public Set getEventList(Calendar calendar, Integer stateId, java.util.Calendar startDate, java.util.Calendar endDate, Session session) throws Exception
    {
        Query q = session.createQuery("from Event as event inner join fetch event.owningCalendar as calendar where event.owningCalendar = ? AND event.stateId = ? AND event.startDateTime >= ? AND event.endDateTime <= ? order by event.startDateTime");
        q.setEntity(0, calendar);
        q.setInteger(1, stateId.intValue());
        q.setCalendar(2, startDate);
        q.setCalendar(3, endDate);
        
        List list = q.list();

        Set set = new LinkedHashSet();
        set.addAll(list);	

		return set;
    }


    /**
     * Gets a list of events fetched by name.
     * @return List of Event
     * @throws Exception
     */
    
    public List getEvent(String name, Session session) throws Exception 
    {
        List events = null;
        
        events = session.createQuery("from Event as event where event.name = ?").setString(0, name).list();
        
        return events;
    }
    
    
    /**
     * Deletes a event object in the database. Also cascades all events associated to it.
     * @throws Exception
     */
    
    public void deleteEventVersion(Long id, Session session) throws Exception 
    {
        EventVersion eventVersion = this.getEventVersion(id, session);
        
        if(eventVersion.getEvent().getStateId().equals(Event.STATE_PUBLISHED))
            new RemoteCacheUpdater().updateRemoteCaches(eventVersion.getEvent().getCalendars());
        
        eventVersion.getEvent().getVersions().remove(eventVersion);
        
        session.delete(eventVersion);
    }

    /**
     * Deletes a event object in the database. Also cascades all events associated to it.
     * @throws Exception
     */
    
    public void deleteEvent(Long id, Session session) throws Exception 
    {
        Event event = this.getEvent(id, session);
        
        Iterator eventCategoriesIterator = event.getEventCategories().iterator();
        while(eventCategoriesIterator.hasNext())
        {
            EventCategory eventCategory = (EventCategory)eventCategoriesIterator.next();
            session.delete(eventCategory);
            eventCategoriesIterator.remove();
        }
        
        if(event.getStateId().equals(Event.STATE_PUBLISHED))
            new RemoteCacheUpdater().updateRemoteCaches(event.getCalendars());

        session.delete(event);
    }
    
    /**
     * Deletes a link to a event object in the database.
     * @throws Exception
     */
    
    public void deleteLinkedEvent(Long id, Long calendarId, Session session) throws Exception 
    {
        Event event = this.getEvent(id, session);
        Calendar calendar = CalendarController.getController().getCalendar(calendarId, session);
        event.getCalendars().remove(calendar);
        calendar.getEvents().remove(event);
        
		new RemoteCacheUpdater().updateRemoteCaches(calendarId);
    }

	private void filterSetOnOwningGroups(Set<InfoGluePrincipalBean> principals, Calendar calendar)
	{
		Iterator<InfoGluePrincipalBean> it = principals.iterator();
		InfoGluePrincipalBean principal;
		while (it.hasNext())
		{
			principal = it.next();
			// Populates the principal with roles and groups
			principal = AccessRightController.getController().getPrincipal(principal.getName());
			if (log.isDebugEnabled())
			{
				log.debug("Will compare <" + InfoGluePrincipalBean.dumpUserData(principal) + "> to <" + calendar.getOwningGroups() + ">");
			}

			if (!AccessRightController.getController().groupListContainsAny(principal.getGroups(), calendar.getOwningGroups()))
			{
				log.debug("Principal <" + principal + "> was not member of any owning groups");
				it.remove();
			}
		}
	}

	private Set<InfoGluePrincipalBean> getPublishersToNotify(Calendar calendar)
	{
		Set<InfoGluePrincipalBean> principals = new HashSet<InfoGluePrincipalBean>();
		Collection owningRoles = calendar.getOwningRoles();
		log.info("owningRoles:" + owningRoles.size());

		Iterator owningRolesIterator = owningRoles.iterator();
		while(owningRolesIterator.hasNext())
		{
			Role role = (Role)owningRolesIterator.next();
			log.info("Owning role:" + role.getName());

			principals.addAll(AccessRightController.getController().getPrincipalsWithRole(role.getName()));
			if (log.isInfoEnabled())
			{
				log.debug("principals so far:" + principals.size());
			}
		}

		if (log.isInfoEnabled())
		{
			log.info("Principals with ownning calendar role:" + principals.size());
		}

		filterSetOnOwningGroups(principals, calendar);

		return principals;
	}

    /**
     * This method emails the owner of an event the new information and an address to visit.
     * @throws Exception
     */

	public void notifyPublisher(Event event, EventVersion eventVersion, String publishEventUrl, InfoGluePrincipalBean infoGluePrincipal) throws Exception
	{
		String email = "";

	    try
	    {
	        Set<InfoGluePrincipalBean> allPrincipals = getPublishersToNotify(event.getOwningCalendar());

	        if (allPrincipals.size() == 0)
	        {
				log.info("No publishers found for calendar: " + event.getOwningCalendar().getName());
	        }
	        else
	        {
				String addresses = "";
				Iterator allPrincipalsIterator = allPrincipals.iterator();
				while(allPrincipalsIterator.hasNext())
				{
					InfoGluePrincipalBean infogluePrincipal = (InfoGluePrincipalBean)allPrincipalsIterator.next();
					if (!infogluePrincipal.getEmail().contains("@"))
					{
						log.info("User <" + infogluePrincipal + "> does not have a valid email adress. Skipping..");
						continue;
					}
					addresses += infogluePrincipal.getEmail() + ";";
				}

				String template;

				String contentType = PropertyHelper.getProperty("mail.contentType");
				if(contentType == null || contentType.length() == 0)
					contentType = "text/html";

				if(contentType.equalsIgnoreCase("text/plain"))
					template = FileHelper.getFileAsString(new File(PropertyHelper.getProperty("contextRootPath") + "templates/newEventNotification_plain.vm"));
				else
					template = FileHelper.getFileAsString(new File(PropertyHelper.getProperty("contextRootPath") + "templates/newEventNotification_html.vm"));

				publishEventUrl = publishEventUrl.replaceAll("j_username", "fold1");
				publishEventUrl = publishEventUrl.replaceAll("j_password", "fold2");

				Map parameters = new HashMap();

				parameters.put("principal", infoGluePrincipal);
				parameters.put("event", event);
				parameters.put("eventVersion", eventVersion);
				parameters.put("publishEventUrl", publishEventUrl.replaceAll("\\{eventId\\}", event.getId().toString()));

				StringWriter tempString = new StringWriter();
				PrintWriter pw = new PrintWriter(tempString);
				new VelocityTemplateProcessor().renderTemplate(parameters, pw, template);
				email = tempString.toString();

				String systemEmailSender = PropertyHelper.getProperty("systemEmailSender");
				if(systemEmailSender == null || systemEmailSender.equalsIgnoreCase("")){
					systemEmailSender = "infoglueCalendar@" + PropertyHelper.getProperty("mail.smtp.host");
				}
				System.out.println(systemEmailSender + addresses + "InfoGlue Calendar - new event waiting" + email + contentType + "UTF-8");
				log.info("Sending mail to:" + systemEmailSender + " and " + addresses);
				MailServiceFactory.getService().send(systemEmailSender, addresses, null, "InfoGlue Calendar - new event waiting", email, contentType, "UTF-8", null);
			}
		}
		catch(Exception e)
		{
			log.error("The notification was not sent. Reason:" + e.getMessage(), e);
		}
		
	}

    
    /**
     * This method emails the owner of an event the new information and an address to visit.
     * @throws Exception
     */
    
    public void notifySubscribers(Event event, EventVersion eventVersion, String publishedEventUrl, InfoGluePrincipalBean infoGluePrincipal) throws Exception
    {
	    String subscriberEmails = PropertyHelper.getProperty("subscriberEmails");
	    
	    try
	    {
            String template;
	        
	        String contentType = PropertyHelper.getProperty("mail.contentType");
	        if(contentType == null || contentType.length() == 0)
	            contentType = "text/html";
	        
	        if(contentType.equalsIgnoreCase("text/plain"))
	            template = FileHelper.getFileAsString(new File(PropertyHelper.getProperty("contextRootPath") + "templates/newEventPublishedNotification_plain.vm"));
		    else
	            template = FileHelper.getFileAsString(new File(PropertyHelper.getProperty("contextRootPath") + "templates/newEventPublishedNotification_html.vm"));
		    
	        publishedEventUrl = publishedEventUrl.replaceAll("j_username", "fold1");
	        publishedEventUrl = publishedEventUrl.replaceAll("j_password", "fold2");
	        
	        Map parameters = new HashMap();
		    parameters.put("principal", infoGluePrincipal);
		    parameters.put("event", event);
		    parameters.put("eventVersion", eventVersion);
		    parameters.put("publishedEventUrl", publishedEventUrl.replaceAll("\\{eventId\\}", event.getId().toString()));
		    
			StringWriter tempString = new StringWriter();
			PrintWriter pw = new PrintWriter(tempString);
			new VelocityTemplateProcessor().renderTemplate(parameters, pw, template);
			String email = tempString.toString();
	    
			String systemEmailSender = PropertyHelper.getProperty("systemEmailSender");
			if(systemEmailSender == null || systemEmailSender.equalsIgnoreCase(""))
				systemEmailSender = "infoglueCalendar@" + PropertyHelper.getProperty("mail.smtp.host");

			log.info("Sending mail to:" + systemEmailSender + " and " + subscriberEmails);
			MailServiceFactory.getService().send(systemEmailSender, subscriberEmails, null, "InfoGlue Calendar - new event published", email, contentType, "UTF-8", null);
	    
			String subscriberString = "";
			Set subscribers = event.getOwningCalendar().getSubscriptions();
			Iterator subscribersIterator = subscribers.iterator();
			while(subscribersIterator.hasNext())
			{
			    Subscriber subscriber = (Subscriber)subscribersIterator.next();

			    if(subscriberString.length() > 0)
			        subscriberString += ";";
		        
			    subscriberString += subscriber.getEmail();
			}

		    try
		    {
		        
				log.info("Sending mail to:" + systemEmailSender + " and " + subscriberString);
				if(subscriberString != null && !subscriberString.equals(""))
					MailServiceFactory.getService().send(systemEmailSender, subscriberString, null, "InfoGlue Calendar - new event published", email, contentType, "UTF-8", null);
		    }
			catch(Exception e)
			{
				log.error("The notification was not sent to persons. Reason:" + e.getMessage());
				log.error("systemEmailSender:" + systemEmailSender);
				log.error("subscriberString:" + subscriberString);
			}

	    }
		catch(Exception e)
		{
			log.error("The notification was not sent. Reason:" + e.getMessage(), e);
		}
		
    }

    /**
     * This method checks if a user has one of the roles defined in the event.
     * @param principal
     * @param event
     * @return
     * @throws Exception
     */
    public boolean hasUserGroup(InfoGluePrincipalBean principal, Event event) throws Exception
    {
        Collection owningGroups = event.getOwningCalendar().getOwningGroups();
        if(owningGroups == null || owningGroups.size() == 0)
            return true;
        
        Iterator owningGroupsIterator = owningGroups.iterator();
        while(owningGroupsIterator.hasNext())
        {
            Group group = (Group)owningGroupsIterator.next();
            
            List principals = new ArrayList();
            principals.addAll(AccessRightController.getController().getPrincipalsWithGroup(group.getName()));
            log.info("principals with group '" + group.getName() + "': " + principals.size());
            //List principals = GroupControllerProxy.getController().getInfoGluePrincipals(group.getName());

            if(principals.contains(principal))
                return true;
        }
        
        return false;
    }

	/**
	 * Calls {@linkplain #getAssetKeys(Event)} with null as Event.
	 * @return
	 */
	public List getAssetKeys()
	{
		return getAssetKeys(null);
	}

	/**
	 * Gets all asset keys defined in the system filtered based on the asset keys already used by the given event.
	 * @param event
	 * @return
	 */
	public List<String> getAssetKeys(Event event)
	{
		List<String> assetKeys = PropertyHelper.getListProperty("assetKey");

		if (event != null)
		{
			Set<Resource> currentResources = event.getResources();
			for (Resource resource : currentResources)
			{
				if (assetKeys.contains(resource.getAssetKey()) && !isAssetKeyMultiple(resource.getAssetKey()))
				{
					log.debug("Removing assetKey since it's already assigned for the given Event");
					assetKeys.remove(resource.getAssetKey());
				}
			}
		}
		return assetKeys;
	}

	private boolean isAssetKeyMultiple(String assetKey)
	{
		ArrayList<String> assetKeys = PropertyHelper.getListProperty("assetKey");
		ArrayList<String> assetKeyIsMultiple = PropertyHelper.getListProperty("assetKeyIsMultiple");

		if (log.isDebugEnabled())
		{
			log.debug("Will test if assetKey <" + assetKey + "> is multiple mode. AssetKeys: " + assetKeys + ". Multiple mode: " + assetKeyIsMultiple);
		}

		try
		{
			for (int i = 0; i < assetKeys.size(); ++i)
			{
				if (assetKeys.get(i).equals(assetKey))
				{
					return Boolean.parseBoolean(assetKeyIsMultiple.get(i));
				}
			}
		}
		catch (IndexOutOfBoundsException ex)
		{
			log.warn("Multiple asset binding was not defined for assetKey " + assetKey + ". Message: " + ex.getMessage());
		}

		return false;
	}

    private String getRoleSQL(List roles)
    {
        String rolesSQL = null;
        if(roles != null && roles.size() > 0)
        {
            rolesSQL = "(";
	        int i = 0;
	    	Iterator iterator = roles.iterator();
	        while(iterator.hasNext())
	        {
	            String roleName = (String)iterator.next();
	            
	            if(i > 0)
	                rolesSQL += ",";
	            
	            rolesSQL += "?";
	            i++;
	        }
	        rolesSQL += ")";
        }
   
        return rolesSQL;
    }
    
    private void setRoleNames(int index, Query q, List roles)
    {
        Iterator iterator = roles.iterator();
        while(iterator.hasNext())
        {
            String roleName = (String)iterator.next();
            log.info("roleName:" + roleName);
            q.setString(index, roleName);
            index++;
        }
    }

    private String getGroupsSQL(List groups)
    {
        String groupsSQL = null;
        if(groups != null && groups.size() > 0)
        {
            groupsSQL = "(";
	        int i = 0;
	    	Iterator iterator = groups.iterator();
	        while(iterator.hasNext())
	        {
	            String roleName = (String)iterator.next();
	            
	            if(i > 0)
	                groupsSQL += ",";
	            
	            groupsSQL += "?";
	            i++;
	        }
	        groupsSQL += ")";
        }
   
        return groupsSQL;
    }
    
    private void setGroupNames(int index, Query q, List groups)
    {
        Iterator iterator = groups.iterator();
        while(iterator.hasNext())
        {
            String groupName = (String)iterator.next();
            log.info("groupName:" + groupName);

            q.setString(index, groupName);
            index++;
        }
    }

}