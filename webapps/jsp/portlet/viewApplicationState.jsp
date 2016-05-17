<%@ taglib uri="webwork" prefix="ww" %>
<%@ taglib uri="http://java.sun.com/portlet" prefix="portlet"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="calendar" prefix="calendar" %>

<portlet:defineObjects/>

<c:set var="activeNavItem" value="Settings" scope="page"/>
<c:set var="activeEventSubNavItem" value="ViewApplicationState" scope="page"/>

<%@ include file="adminHeader.jsp" %>
<%@ include file="functionMenu.jsp" %>
<%@ include file="settingsSubFunctionMenu.jsp" %>
<portlet:actionURL var="updateModelActionUrl">
	<portlet:param name="action" value="ViewApplicationState!upgradeModel"/>
</portlet:actionURL>
<portlet:actionURL var="fixInconsistenciesActionUrl">
	<portlet:param name="action" value="ViewApplicationState!fixInconsistencies"/>
</portlet:actionURL>

<div class="mainCol">
    <center>
    
    <h1>Calendar Status (<ww:property value="serverName"/>)</h1>
    
    <ww:if test="#message != ''">
    <h3 style="color: red;">Message: <ww:property value="#message"/></h3>
    </ww:if>
    
    <table border="0" cellpadding="4" cellspacing="0" width="700" style="border: 1px solid #ccc; margin: 10px;">
      <tr>
        <td class="header">Maintainence actions</td>
      </tr>
      <tr>
        <td><a href="<c:out value="${fixInconsistenciesActionUrl}"/>">Fix inconsistencies</a></td>
      </tr>
      <tr>
        <td><a href="<c:out value="${updateModelActionUrl}"/>">Upgrade model</a></td>
      </tr>
       <tr>
        <td><hr/></td>
      </tr>
      
        <portlet:actionURL var="clearAuthCachesViewStateActionUrl">
            <portlet:param name="action" value="ViewApplicationState!clearCaches"/>
        </portlet:actionURL>
    
        <portlet:actionURL var="clearAllCachesViewStateActionUrl">
            <portlet:param name="action" value="ViewApplicationState!clearAllCaches"/>
        </portlet:actionURL>
      
        <tr>
            <td class="header">Cache actions</td>
        </tr>
            <tr>
            <td class="text"><a href="<c:out value="${clearAuthCachesViewStateActionUrl}"/>">Clear auth cache</a></td>
        </tr>
        <tr>
            <td class="text"><a href="<c:out value="${clearAllCachesViewStateActionUrl}"/>">Clear all caches</a></td>
        </tr>
        <tr>
            <td><hr/></td>
        </tr>
        <tr>
            <td class="header">Log settings</td>
        </tr>
      
        <portlet:actionURL var="updateStateActionUrl">
            <portlet:param name="action" value="UpdateApplicationState"/>
        </portlet:actionURL>
      
      <tr>
        <td class="text" align="left">
            <form action="<c:out value="${updateStateActionUrl}"/>" method="post"> 
                ClassName:
                <input type="textfield" name="className">
                Log level:
                <select name="logLevel">
                    <option value="debug">Debug</option>
                    <option value="info">Information</option>
                    <option value="warn">Warning</option>
                    <option value="error">Error</option>
                </select>
                <input type="submit" value="Submit"/>
            </form>
        </td>
      </tr>
    
    </table>
    </center>

</div>
<div style="clear:both"></div>

