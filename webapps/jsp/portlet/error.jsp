<%@ taglib uri="webwork" prefix="ww" %>
<%@ taglib uri="http://java.sun.com/portlet" prefix="portlet"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="calendar" prefix="calendar" %>

<portlet:defineObjects/>

<%@ include file="adminHeader.jsp" %>

<div class="mainCol">
    <div class="portlet_margin no-subfunctionarea">
    
        <h1>Error</h1>
        <p class="errorMessage">
            <ww:property value="#errorMessage"/>
        </p>
        <p>
            The log files will contain more information on the specific error so please consult them for further guidance.
        </p>
        <p>
            <a href="javascript:history.back();">Tillbaka</a>
        </p>	
    </div>
</div>

<%@ include file="adminFooter.jsp" %>