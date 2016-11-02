/**
 * Copyright (c) 2003-2012, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// IG Defaults
	config.contentsCss = '/infoglueCalendar/applications/ckeditor/uu-contents.css';
	
	config.toolbar_longDescription = [
		{ name: 'basicstyles', items: ['Bold','Italic'] },
		{ name: 'links', items: ['Link','Unlink'] },
	];
	config.toolbar_shortDescription = [
		{ name: 'basicstyles', items: ['Bold','Italic'] },
		{ name: 'links', items: ['Link','Unlink'] },
	];
};
