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

package org.infoglue.common.util;

import java.util.Properties;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.io.*;
import java.util.ArrayList;


/**
* CMSPropertyHandler.java
* Created on 2002-sep-12 
* 
* This class is used to get properties for the system in a transparent way.
* 
* @author Stefan Sik, ss@frovi.com
* @author Mattias Bogeblad 
*/

public class PropertyHelper
{
	private static Log log = LogFactory.getLog(PropertyHelper.class);
	private static Properties cachedProperties = null;
	private static File propertyFile = null;
		
	public static void setPropertyFile(File aPropertyFile)
	{
		propertyFile = aPropertyFile;
	}
	
	/**
	 * This method initializes the parameter hash with values.
	 */

	private static void initializeProperties()
	{
		try
		{
			System.out.println("**************************************");
			System.out.println("Initializing properties from file.....");
			System.out.println("**************************************");
			
			cachedProperties = new Properties();
			if(propertyFile != null)
			    cachedProperties.load(new FileInputStream(propertyFile));
			else
			    cachedProperties.load(PropertyHelper.class.getResourceAsStream("/application.properties"));
			
		}	
		catch(Exception e)
		{
			cachedProperties = null;
			e.printStackTrace();
		}
		
	}

	/**
	 * This method returns all properties .
	 */

	public static Properties getProperties()
	{
		if(cachedProperties == null)
			initializeProperties();
				
		return cachedProperties;
	}	


	/**
	 * This method returns a propertyValue corresponding to the key supplied.
	 */

	public static String getProperty(String key)
	{
		String value;
		if(cachedProperties == null)
			initializeProperties();
		
		value = cachedProperties.getProperty(key);
		if (value != null)
			value = value.trim();
				
		return value;
	}	


	/**
	 * This method sets a property during runtime.
	 */

	public static void setProperty(String key, String value)
	{
		if(cachedProperties == null)
			initializeProperties();
		
		cachedProperties.setProperty(key, value);
	}	

	public static boolean getBooleanProperty( String key, boolean def ) {
		if( cachedProperties == null ) {
			initializeProperties();		
		}
		String value = cachedProperties.getProperty( key );
		Boolean bool = new Boolean( value );
		return bool.booleanValue();
	}
	
	public static boolean getBooleanProperty( String key  ) {
		return getBooleanProperty( key, false );
	}

	public static long getLongProperty( String key, long def ) {
		try {
			String value = cachedProperties.getProperty( key );
			Long propertyAsLong = new Long( value );
			return propertyAsLong.longValue();
		} catch( Exception e ) {}
		return def;
	}

	/**
	 * Determine if the given property is valid. The value is verified to have a non-empty string value
	 * and that that it does not conform to the default placeholder syntax.
	 *
	 * @param property The property to verify. May be null or empty.
	 * @param namePrefix A prefix used by the placeholder syntax. May be null.
	 * @return true if the given property is determined to be a defined value, false otherwise.
	 */
	public static boolean isUndefinedProperty(String property, String namePrefix)
	{
		return property == null || property.trim().equals("") ||  property.startsWith("@" + (namePrefix == null ? "" : namePrefix)) && property.endsWith("@");
	}

	/**
	 * Get a list of property values based on the given base key. The base key is assumed to reference
	 * a property using the list property syntax. An empty list will be returned if the base key is not
	 * on the desired format or if the key can not be found.
	 * @param baseKey The key to fetch properties for
	 * @return An array list of property values
	 */
	public static ArrayList<String> getListProperty(String baseKey)
	{
		ArrayList<String> result = new ArrayList<String>();
		baseKey = baseKey + ".";

		int i = 0;
		String assetKey = PropertyHelper.getProperty(baseKey + i);
		while (!isUndefinedProperty(assetKey, baseKey))
		{
			result.add(assetKey);
			i++;
			assetKey = PropertyHelper.getProperty(baseKey + i);
		}

		return result;
	}

	/**
	 * Get a property value from the <em>related list</em> at the corresponding index of the <em>lookup value</em>'s position
	 * in the <em>lookup list</em>. Both lists must be list properties. Since list property does not support null-values the
	 * returned value will never be null if a value was found in the related list.
	 *
	 * @param lookupListKey A list property prefix where <em>lookup value</em> should be present
	 * @param relatedListKey A list property
	 * @param lookupValue A value to look for in the lookup list. Its index will be used for lookup in the related list.
	 * @return Returns the corresponding value from related list, null otherwise.
	 */
	public static String getRelatedListPropertValue(String lookupListKey, String relatedListKey, String lookupValue)
	{
		ArrayList<String> assetKeys = PropertyHelper.getListProperty(lookupListKey);
		if (log.isDebugEnabled()) {
			log.debug("Looking for value " + lookupValue + " in property list");
			log.debug("Property value list " + assetKeys);
		}
		for (int index = 0; index < assetKeys.size(); ++index)
		{
			String currentValue = assetKeys.get(index);
			if (currentValue.equals(lookupValue))
			{
				ArrayList<String> relatedAssetKeys = PropertyHelper.getListProperty(relatedListKey);
				if (log.isDebugEnabled()) {
					log.debug("Related property value list" + relatedAssetKeys);
				}
				if (index < relatedAssetKeys.size())
				{
					if (log.isDebugEnabled()) {
						log.debug("Found related property value at index" + index + ". Value: " + relatedAssetKeys.get(index));
					}
					return relatedAssetKeys.get(index);
				}
			}
		}

		return null;
	}

}
