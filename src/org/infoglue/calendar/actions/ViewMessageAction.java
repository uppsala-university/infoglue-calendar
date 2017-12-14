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

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Calendar;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.infoglue.calendar.entities.Event;

import com.opensymphony.xwork.Action;

/**
 * This action represents a Calendar Administration screen.
 * 
 * @author Mattias Bogeblad
 */

public class ViewMessageAction extends CalendarAbstractAction
{
	private static Log log = LogFactory.getLog(ViewMessageAction.class);

	private Long eventId;
	private Event newEvent;

	public String execute() throws Exception 
	{
		return Action.SUCCESS;
	} 

	public String submitted() throws Exception 
	{
		return "successSubmitForPublish";
	} 

	public String published() throws Exception 
	{
		pushEventUrlToSearch();

		return "successPublished";
	} 

	public Long getEventId()
	{
		return eventId;
	}

	public void setEventId(Long eventId)
	{
		this.eventId = eventId;
	}

	/**
	 * Pushes this event's URL to the search index.
	 */
	private void pushEventUrlToSearch() {
		String apiUrl = getSetting("search.index.push.api.url");
		if (apiUrl == null || apiUrl.equals("")) {
			log.error("No push api url in calendar settings. Can not push to search.");
			return;
		}
		
		String eventPageUrl = getSetting("search.index.push.event.page.url");
		if (eventPageUrl == null || eventPageUrl.equals("")) {
			log.error("No push event page url in calendar settings. Can not push to search.");
			return;
		}

		String secret = getSetting("search.index.push.endpoint.secret");
		if (secret == null || secret.equals("")) {
			log.error("No secret in calendar settings. Can not push to search.");
			return;
		}
		
		String url = eventPageUrl + getEventId();
		String encodedUrl;
		
		// Encode the url we will be pushing to the search index since we 
		// will send it as a parameter.
		try {
			encodedUrl = URLEncoder.encode(url, StandardCharsets.UTF_8.name());
		} catch (UnsupportedEncodingException e) {
			// Shouldn't happen, but if it does, skip encoding.
			encodedUrl = url;
		}

		String hash = getTodaysHash(url, secret);
		if (hash == null) {
			log.error("Could not generate hash for " + url);
			return;
		}
	
		try {
			// Create the push api url to call
			URL pushUrl = new URL(apiUrl + "?url=" + encodedUrl + "&hash=" + hash);

			// Set up the connection
			URLConnection pushURLConnection = pushUrl.openConnection();
			pushURLConnection.setRequestProperty("Accept-Charset", StandardCharsets.UTF_8.name());

			// Open input stream to make request happen. 
			// At the moment we don't care about the response, so don't use it.
			pushURLConnection.getInputStream();
		} catch (MalformedURLException e) {
			log.error("Malformed event url " + url + ". Can not push to search.", e);
		} catch (IOException e) {
			log.error("Could not push event url " + url + " to search.", e);
		}
	}

	/**
	 * Hash input string using a secret combined with today's date as salt.
	 * Uses SHA256 as hashing algorithm.
	 * @return null if the SHA256 algorithm is not available
	 */
	public String getTodaysHash(String data, String secret) {
		// Create the salt
		Calendar now = Calendar.getInstance();
		String salt = secret + now.get(Calendar.YEAR) + now.get(Calendar.MONTH) + now.get(Calendar.DATE);

		// Create the data to be hashed
		String dataAndSalt = data + salt;
		byte[] dataBytes = dataAndSalt.getBytes(StandardCharsets.UTF_8);

		try {
			// Hash data and salt and return as a string
			MessageDigest digest = MessageDigest.getInstance("SHA-256");
			byte[] hashBytes = digest.digest(dataBytes);
			String hashString = bytesToHex(hashBytes);
			return hashString;
		} catch (NoSuchAlgorithmException e) {
			log.error("Could not hash " + data, e);
			return null;
		}
	}

	private static String bytesToHex(byte[] hash) {
		StringBuffer hexString = new StringBuffer();
		for (int i = 0; i < hash.length; i++) {
			String hex = Integer.toHexString(0xff & hash[i]);
			if(hex.length() == 1) hexString.append('0');
			hexString.append(hex);
		}
		return hexString.toString();
	}
}
