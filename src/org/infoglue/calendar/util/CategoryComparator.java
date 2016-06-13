package org.infoglue.calendar.util;

import java.util.Comparator;

import org.infoglue.calendar.entities.Category;

/**
 * @author Mattias Bogeblad
 *
 */

public class CategoryComparator implements Comparator<Category>
{
	private String isoCode;

	public CategoryComparator(String isoCode)
	{
		this.isoCode = isoCode;
	}
	
	private Integer handleNullCases(Object value1, Object value2)
	{
		/*
		 * Put null values last
		 */
		if (value1 == null && value2 == null)
		{
			return 0;
		}
		else if (value1 == null && value2 != null)
		{
			return 1;
		}
		else if (value1 != null && value2 == null)
		{
			return -1;
		}
		else
		{
			return null;
		}
	}

	public int compare(Category c1, Category c2)
	{
		Integer result = handleNullCases(c1, c2);
		
		if (result != null)
		{
			return result;
		}
		else
		{
			String category1Name = c1.getLocalizedName(isoCode, "en");
			String category2Name = c2.getLocalizedName(isoCode, "en");

			result = handleNullCases(category1Name, category2Name);
			if (result != null)
			{
				return result;
			}
			else
			{
				return category1Name.toLowerCase().compareTo(category2Name.toLowerCase());
			}
		}
	}

}
