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
package org.infoglue.calendar.taglib;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.Set;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.infoglue.calendar.entities.BaseEntity;
import org.infoglue.common.util.ResourceBundleHelper;

import com.opensymphony.webwork.ServletActionContext;
import com.opensymphony.xwork.ActionContext;


/**
 * 
 */
public class TextValueTag extends AbstractCalendarTag 
{
    private static Log log = LogFactory.getLog(TextValueTag.class);

	private static final long serialVersionUID = 3617579309963752240L;
	
	private String labelCssClass = "";
	private String cssClass = "";
	private Object value = "";
	private String label = "";
	private Map values;

	
	/**
	 * 
	 */
	public TextValueTag() 
	{
		super();
	}
	
		  
	public int doEndTag() throws JspException
    {
	    StringBuffer sb = new StringBuffer();
	    if(this.label != null)
	        sb.append("<span class=\"" + labelCssClass + "\">" + this.label + "</span>");

        String outValue = ""; // Init with empty string to work with List-case
        String wrapperTag = "span";
        if(value instanceof Boolean)
        {
            String translatedLabel = this.getLabel("" + value, this.values);
            if(translatedLabel != null && translatedLabel.length() > 0)
                value = translatedLabel;

            outValue = ((value == null) ? "" : value.toString());
        }
        else if(value instanceof String)
        {
        	outValue = ((value == null) ? "" : value.toString());
        	if (outValue.indexOf("</p>") != -1)
        	{
        		wrapperTag = "div";
        	}
        }
        else if(value instanceof Integer)
        	outValue = ((value == null) ? "" : value.toString());
        else if(value instanceof Float)
        	outValue = ((value == null) ? "" : value.toString());
        else if(value instanceof List || value instanceof Set)
        {
            Iterator i = ((Collection)value).iterator();
            while(i.hasNext())
            {
                Object o = i.next();
                outValue = ((BaseEntity)o).getLocalizedName(getLanguageCode(), "sv") + ", ";
            }
        }
        else
        	outValue = ((value == null) ? "" : value.toString());

        sb.append("<br>");
        sb.append("<" + wrapperTag + " class=\"" + cssClass + "\">");
        sb.append(outValue);
        sb.append("</" + wrapperTag + ">");

        write(sb.toString());

        cssClass = "";
        labelCssClass = "";
        
        return EVAL_PAGE;
    }

	
    public void setCssClass(String cssClass)
    {
        this.cssClass = cssClass;
    }

    public void setLabelCssClass(String labelCssClass)
    {
        this.labelCssClass = labelCssClass;
    }

    public void setLabel(String rawLabel) throws JspException
    {
        Object o = findOnValueStack(rawLabel);
        String evaluatedString = evaluateString("TextValueTag", "label", rawLabel);
        log.info("o:" + o);
        log.info("evaluatedString:" + evaluatedString);
        if(o != null)
            this.label = (String)o;
        else if(evaluatedString != null && !evaluatedString.equals(rawLabel))
            this.label = evaluatedString;
        else
        {
            String translatedLabel = this.getLabel(rawLabel);
            if(translatedLabel != null && translatedLabel.length() > 0)
                this.label = translatedLabel;
        }
    }

    
    public void setValue(String value)
    {
        Object o = findOnValueStack(value);
        if(o != null) 
            this.value = o;
        else
            this.value = null;
    }
    
    public void setValueMap(String valueMap) throws JspException
    {
        Object o = findOnValueStack(valueMap);
        if(o != null) 
        {
            this.values = (Map)o;
        }
        else
        {
            this.values = null;
        }
    }

}
