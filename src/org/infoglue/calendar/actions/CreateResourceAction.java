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

package org.infoglue.calendar.actions;

import java.io.File;
import java.util.Iterator;
import java.util.List;

import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.portlet.PortletFileUpload;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.infoglue.calendar.controllers.ResourceController;

import com.opensymphony.webwork.ServletActionContext;
import com.opensymphony.xwork.Action;
import com.opensymphony.xwork.ActionContext;

/**
 * This action represents a Calendar Administration screen.
 * 
 * @author Mattias Bogeblad
 */

public class CreateResourceAction extends CalendarUploadAbstractAction
{
	private static Log log = LogFactory.getLog(CreateResourceAction.class);

    private Long eventId;

    private Long calendarId;
    private String mode;
        
    private String message = "";
	private String returnUrl = "";

    /**
     * This is the entry point for the main listing.
     */
    
    public String execute() throws Exception 
    {
        log.debug("-------------Uploading file.....");
        
        File uploadedFile = null;
        
        try
        {
	        DiskFileItemFactory factory = new DiskFileItemFactory();
	        factory.setSizeThreshold(2000000);
	        //factory.setRepository(yourTempDirectory);

	        PortletFileUpload upload = new PortletFileUpload(factory);

			int maxSize = ResourceController.getController().getMaxUploadSize(getSetting("AssetUploadMaxFileSize"));
			upload.setSizeMax(maxSize);

	        List fileItems = upload.parseRequest(ServletActionContext.getRequest());
            log.debug("fileItems:" + fileItems.size());
	        Iterator i = fileItems.iterator();
	        DiskFileItem theFile = null;
	        while(i.hasNext())
	        {
	            Object o = i.next();
	            DiskFileItem dfi = (DiskFileItem)o;
	            log.debug("dfi:" + dfi.getFieldName());
	            log.debug("dfi:" + dfi);
	            
	            if (dfi.isFormField()) 
	            {
	                String name = dfi.getFieldName();
	                String value = dfi.getString();

	                log.debug("name:" + name);
	                log.debug("value:" + value);
	                if(name.equals("assetKey"))
	                {
	                    this.assetKey = value;
	                }
	                else if(name.equals("eventId"))
	                {
	                    this.eventId = new Long(value);
	                    ServletActionContext.getRequest().setAttribute("eventId", this.eventId);
	                }
	                else if(name.equals("calendarId"))
	                {
	                    this.calendarId = new Long(value);
	                	ServletActionContext.getRequest().setAttribute("calendarId", this.calendarId);
	            	}
	               	else if(name.equals("mode"))
	                    this.mode = value;
	            }
	            else
	            {
					theFile = dfi;
	            }
	        }

			if (theFile != null)
			{
				log.debug("Found uploaded file.");
				if (!validateFileType(theFile))
				{
					log.warn("Wrong file type uploaded. Got: " + theFile.getContentType() + ". For file: " + theFile.getName());
					ServletActionContext.getRequest().getSession().setAttribute("uploadErrorMessage", getParameterizedLabel("labels.event.uploadForm.error.invalidContentType", theFile.getContentType()));
					return Action.ERROR;
				}

                this.fileName = theFile.getName();
                log.debug("FileName:" + this.fileName);
                uploadedFile = new File(getTempFilePath() + File.separator + this.fileName);
                theFile.write(uploadedFile);
	        }
	    }
		catch (FileUploadException ex)
        {
			ServletActionContext.getRequest().getSession().setAttribute("uploadErrorMessage", getLabel("labels.event.uploadForm.error.tooLargeFile"));
			log.error("Exception uploading file. " + ex.getMessage());
			return Action.ERROR;
        }
        catch(Exception e)
        {
			ServletActionContext.getRequest().getSession().setAttribute("uploadErrorMessage", getLabel("labels.event.uploadForm.error.general"));
			log.error("Exception uploading resource. " + e.getMessage(), e);
        	return Action.ERROR;
        }
 
        try
        {
	        log.debug("Creating resources.....:" + this.eventId + ":" + ServletActionContext.getRequest().getParameter("eventId") + ":" + ServletActionContext.getRequest().getParameter("calendarId"));
	        ResourceController.getController().createResource(this.eventId, this.getAssetKey(), this.getFileContentType(), this.getFileName(), uploadedFile, getSession());
        }
        catch (Exception e)
        {
        	ServletActionContext.getRequest().getSession().setAttribute("errorMessage", "Exception saving resource to database: " + e.getMessage());
        	ActionContext.getContext().getValueStack().getContext().put("errorMessage", "Exception saving resource to database: " + e.getMessage());
        	log.error("Exception saving resource to database. " + e.getMessage());
        	return Action.ERROR;
		}
        
        return Action.SUCCESS;
    }

	private boolean validateFileType(DiskFileItem dfi) {
		String fileType = dfi.getContentType();
		log.info("Uploaded file's file type is: " + fileType);
		List<String> allowedFileType = ResourceController.getController().getFileTypesForAssetKey(getAssetKey());
		return allowedFileType == null ? true : allowedFileType.contains(fileType);
	}

	public String getEventIdAsString()
    {
        return eventId.toString();
    }

    public String getCalendarIdAsString()
    {
        return calendarId.toString();
    }
    
    public Long getEventId()
    {
        return eventId;
    }
    
    public void setEventId(Long eventId)
    {
        this.eventId = eventId;
    }
    
    public Long getCalendarId()
    {
        return calendarId;
    }
    
    public void setCalendarId(Long calendarId)
    {
        this.calendarId = calendarId;
    }
    
    public String getMode()
    {
        return mode;
    }
    
    public void setMode(String mode)
    {
        this.mode = mode;
    }

    public String getMessage() 
    {
		return message;
	}

	public String getReturnUrl() 
	{
		return returnUrl;
	}
}
