package org.infoglue.calendar.util;

import java.util.Comparator;

import org.infoglue.calendar.entities.Category;
import org.infoglue.calendar.entities.Event;
import org.infoglue.calendar.entities.EventTypeCategoryAttribute;


/**
 * @author Mattias Bogeblad
 *
 */

public class CategoryComparator implements Comparator
{
	private String isoCode;
	
	public CategoryComparator(String isoCode)
	{
		this.isoCode = isoCode;
	}
	
	public int compare(Object o1, Object o2) 
	{
		int result = 0;
		Category e2 = (Category)o2;
		Category e1 = (Category)o1;
		int orderColumnResult = e1.getLocalizedName(isoCode, "en").toLowerCase().compareTo(e2.getLocalizedName(isoCode, "en").toLowerCase());
		
		if(orderColumnResult != 0)
			result = orderColumnResult;
		
		return result;
	}

}
