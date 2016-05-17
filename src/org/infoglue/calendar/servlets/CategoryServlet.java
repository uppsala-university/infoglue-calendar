package org.infoglue.calendar.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.Logger;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.infoglue.calendar.controllers.CategoryController;
import org.infoglue.calendar.entities.Category;
import org.infoglue.common.util.HibernateUtil;
import org.infoglue.common.util.PropertyHelper;

/**
 * Servlet implementation class CategoryServlet
 */

public class CategoryServlet extends HttpServlet 
{
	private static final long serialVersionUID = 1L;

    private final static Logger logger = Logger.getLogger(CategoryServlet.class.getName());

	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		StringBuffer sb = new StringBuffer();

        try
        {
        	Session session = HibernateUtil.currentSession();
        	Transaction tx = null;
        	try 
        	{
        		tx = session.beginTransaction();

        		String languageCode = "en";
        		String languageCodeParameter = request.getParameter("languageCode");
        		if(languageCodeParameter != null && !languageCodeParameter.equals(""))
        			languageCode = languageCodeParameter;

        		logger.debug("Category on path is: " + request.getPathInfo());

        		String categoryPath;
        		if (request.getPathInfo() != null && !"/".equals(request.getPathInfo()))
        		{
        			categoryPath = request.getPathInfo();
        		}
        		else
        		{
        			categoryPath = PropertyHelper.getProperty("filterCategoryPath");
        		}

        		StringBuffer allCategoriesProperty = new StringBuffer("");

        		Category filterCategory = CategoryController.getController().getCategoryByPath(session, categoryPath);

        		if (filterCategory == null)
        		{
        			logger.info("The requested category path did not match a category. Path: " + categoryPath);
        		}

        		if (filterCategory != null)
        		{
	        		@SuppressWarnings("unchecked")
					Set<Category> categorySet = filterCategory.getChildren();

	        		// Add all categories to a map (sorted)
	        		Map<String,Category> categoryMap = new TreeMap<String, Category>();

	        		Iterator<Category> categoryIterator = categorySet.iterator();
	        		while(categoryIterator.hasNext())
	        		{
	        			Category category = (Category)categoryIterator.next();
	        			categoryMap.put(category.getLocalizedName(languageCode, "en").toLowerCase(), category);
	        		}

	        		// Iterate the sorted map
	        		Iterator<String> categorySetIterator = categoryMap.keySet().iterator();
	        		while(categorySetIterator.hasNext())
	        		{
	        			Category category = (Category)categoryMap.get(categorySetIterator.next());

	        			sb.append("    <property name=\"" + StringEscapeUtils.escapeXml(category.getLocalizedName(languageCode, "en")) + "\" value=\"" + StringEscapeUtils.escapeXml(category.getInternalName()) + "\"/>");
	        			if(allCategoriesProperty.length() > 0)
	        				allCategoriesProperty.append(",");
	        			allCategoriesProperty.append(StringEscapeUtils.escapeXml(category.getInternalName()));
	        		}
        		}

        		sb.insert(0, "<?xml version=\"1.0\" encoding=\"UTF-8\"?><properties><property name=\"All\" value=\"" + allCategoriesProperty + "\"/>");
                sb.append("</properties>");

        		tx.commit();
        	}
        	catch (Exception e) 
        	{
        		if (tx!=null) tx.rollback();
        	    throw e;
        	}
        	finally 
        	{
        		HibernateUtil.closeSession();
        	}
        }
        catch(Exception e)
        {
        	logger.error("An error occurred when we tried fetch a list of categories. Message:" + e.getMessage(), e);
        }

		response.setContentType("text/xml");

		PrintWriter pw = response.getWriter();

		pw.println(sb.toString());
		pw.flush();
		pw.close();
	}


}
