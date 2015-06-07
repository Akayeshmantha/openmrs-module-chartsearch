<style type="text/css">
	#search-saving-section {
		padding-top:8px;
	}
	
	#delete-search-record, #favorite-search-record, #comment-on-search-record, #possible-task-list {
		cursor: pointer;
	}
	
	.search-record-dialog-content {
		display:none;
	}
	
	.ui-dialog > .ui-widget-header {
		background: #00463f;
		color:white;
	}
	
	.ui-widget-header .ui-icon {
		background-image: url(../scripts/jquery-ui/css/green/images/ui-icons_ffffff_256x240.png);
	}

	#dialogFailureMessage {
		display:none;
		color:red;
	}
	
	#bookmark-header {
	    text-align:center;
	    font-weight:bold;
	    margin-bottom:15px;
	}
	
	#remove-current-bookmark, #cancel-edit-bookmark {
		float:right;
	}
	
	#current-bookmark-name {
		width:364px;
	}
	
	#possible-task-list {
		padding-right:2px;
	}
	
	.detailed_results {
		z-index:1;
	}
	
	#lauche-other-chartsearch-features {
		position: absolute;
		z-index: 2;
		height: 300px;
		width: 220px;
		background-color: #eeeeee;
		margin-left: 688px;
		border-radius: 5px;
		box-shadow: -5px 5px 4px #888888;
		border-right: 1px solid #888888;
	}
	
	.possible-task-list-item {
		background-color: #F0EAEA;
		color:black;
		border: 1px solid white;
		overflow:hidden;
		height: 25px;
		cursor: pointer;
		padding-left: 10px;
	}
	
	.possible-task-list-item:hover, .possible-task-list-item:active {
		background-color: #d6d6d6;
	}
	
	#lauche-stored-bookmark {
		position: absolute;
		z-index: 2;
		height: 400px;
		width: 500px;
		background-color: #F0EAEA;
		margin-left: 185px;
		margin-top: 31px;
		border-radius: 5px;
		border: 1px solid #888888;
		overflow-y: scroll;
	}
	
	#bookmark-manager-lancher {
		float:right;
		margin-right: 10px;
	}
	
	#add-new-note-on-this-search {
		border-top: 1px solid #888888;
		padding-top: 8px;
	}
	
	#new-comment-or-note {
		margin-bottom: 5px;
	}
	
	#previous-notes-on-this-search {
		border: 1px solid #888888;
		border-radius: 5px;
		padding: 8px 8px 8px 8px;
		margin-bottom: 10px;
		height: 250px;
		overflow-y: scroll;
	}
	
	#refresh-notes-display, .remove-this-sNote {
		cursor: pointer;
	}
	
</style>

<script type="text/javascript">
	var jq = jQuery;
    
    jq(document).ready(function() {
    
    	jq("#lauche-stored-bookmark").hide();
    	jq("#lauche-other-chartsearch-features").hide();
    	
    	displayExistingBookmarks();
    	
    	displayBothPersonalAndGlobalNotes();
    	
    	jq("#delete-search-record").click(function(event) {
    		invokeDialog("#delete-search-record-dialog", "Delete this Search Record", "300px");
    	});
    
    	jq("#favorite-search-record").click(function(event) {
    		jq("#favorite-search-record").prop('disabled', true);
    		//TODO check if bookmarkExists, else run below
	    	var phrase = jq("#searchText").val();
		    var selectedCats = getSelectedCategoryNames();
		    var patientId = jq("#patient_id").val();
	    	
	    	if(!phrase) {
	    		failedToShowBookmark("A bookmark is only added after searching with a non blank phrase, Enter phrase and search first");
	    	} else {
		    	saveOrUpdateBookmark(selectedCats, phrase, phrase, patientId);
			}
    	});
    	
    	jq("#submit-edit-bookmark").click(function(event) {
    		var phrase = jq("#searchText").val();
    		var bookmarkName = jq("#current-bookmark-name").val();
			var selectedCats = getSelectedCategoryNames();
			var patientId = jq("#patient_id").val();
			
			saveOrUpdateBookmark(selectedCats, phrase, bookmarkName, patientId);
			jq("#favorite-search-record-dialog").dialog("close");
    	});
    	
    	jq("#remove-current-bookmark").click(function(event) {
    		var bookmarkUuid = jq("#current-bookmark-object").val();
    		
    		if(bookmarkUuid) {
    			deleteSearchBookmark(bookmarkUuid, true);
    		}
    		return false;
    	});
    	
    	jq("#cancel-edit-bookmark").click(function(event) {
	    	jq("#favorite-search-record-dialog").dialog("close");
	    	jq("#favorite-search-record").prop('disabled', false);
	    	
    		return false;
    	});
    	
    	jq("#comment-on-search-record").click(function(event) {
    		var phrase = jq("#searchText").val();
    		displayBothPersonalAndGlobalNotes();
    		
    		if(phrase) {
	    		checkIfPhraseExisitsInHistory(phrase, function(exists) {
		    		if(exists) {
		    			displayNotesAtUILevel();
	    			} else {
						failedToShowNotes("Notes are only added and accessed for a search, enter search phrase and search first");
					}
				});
			} else {
				failedToShowNotes("Notes are only added and accessed for a search, enter search phrase and search first");
			}
    	});
    	
    	function displayNotesAtUILevel() {
    		//TODO scroll to comments text field
    		//TODO check every after search for existence of notes on a search and change it icon-comment-alt to icon-comment
			invokeDialog("#comment-on-search-record-dialog", "Notes on this Search for this Patient", "550px");
    	}
    	
    	jq("#quick-searches").click(function(event){
    		invokeDialog("#quick-searches-dialog-message", "Quick Searches", "300px");
    		return false;
    	});
    	
    	jq("#possible-task-list").click(function(event) {
    		if(jq("#lauche-other-chartsearch-features").is(':visible')) {
				jq("#lauche-other-chartsearch-features").hide();
				jq("#lauche-stored-bookmark").hide();
			} else {
				jq("#lauche-other-chartsearch-features").show();
			}
    	});
    	
    	jq("#bookmark-task-list-item").click(function(event) {
    		if(jq("#lauche-stored-bookmark").is(':visible')) {
				jq("#lauche-stored-bookmark").hide();
				jq("#bookmark-task-list-item").css('background-color', '#F0EAEA');
			} else {
				jq("#lauche-stored-bookmark").show();
				jq("#bookmark-task-list-item").css('background-color', '#d6d6d6');
			}
    	});
    	
    	jq("body").on("click", "#lauche-stored-bookmark", "#lauche-stored-bookmark.possible-task-list-item", function (event) {
    		if(event.target.localName === "i") {
    			var bookmarkUuid = event.target.id;
    			deleteSearchBookmark(bookmarkUuid, false);
    		} else if(event.target.localName === "a") {
    			window.open('../chartsearch/chartSearchManager.page?tab=2', '_blank');
    			return false;
    		} else if(event.target.localName === "div" || event.target.localName === "b" || event.target.localName === "em") {
    			var bookmarkUuid = event.target.id;
    			
    			if(bookmarkUuid !== "lauche-stored-bookmark") {
    				searchUsingBookmark(bookmarkUuid);
    			}
    		}
    	});
    	
    	jq("#history-task-list-item").click(function(event) {
    		window.open('../chartsearch/chartSearchManager.page?tab=3', '_blank');
    	});
    	
    	jq("#preferences-task-list-item").click(function(event) {
    		window.open('../chartsearch/chartSearchManager.page?tab=1', '_blank');
    	});
    	
    	jq("#commands-task-list-item").click(function(event) {
    		window.open('../chartsearch/chartSearchManager.page?tab=4', '_blank');
    	});
    	
    	jq("#settings-task-list-item").click(function(event) {
    		window.open('../chartsearch/chartSearchManager.page?tab=5', '_blank');
    	});
    	
    	jq("#notes-task-list-item").click(function(event) {
    		window.open('../chartsearch/chartSearchManager.page?tab=6', '_blank');
    	});
    	
    	jq("#new-note-color").change(function(event) {
    		var bgColor = jq("#new-note-color option:selected").text();
    		if(bgColor !== "Color") {
    			changeNotesBgColor("#new-comment-or-note", bgColor);
    		} else {
    			changeNotesBgColor("#new-comment-or-note", "white");
    		}
    	});
    	
    	jq("#save-a-new-note").click(function(event) {
    		saveSearchNote();
    	});
    	
    	jq("body").on("click", "#previous-notes-on-this-search", function (event) {
    		if(event.target.localName === "i") {
    			var noteUuid = event.target.id;
    			deleteSearchNote(noteUuid);
    		}
    	});
    	
    	jq("#refresh-notes-display").click(function(event) {
    		refreshSearchNotes();
    	});
    	
    	function saveOrUpdateBookmark(selectedCats, phrase, bookmarkName, patientId) {
    		checkIfPhraseExisitsInHistory(phrase, function(exists) {
    			if(exists) {
	    			checkIfBookmarkExists(bookmarkName, phrase, selectedCats, function(bookmarkUuid) {
	    				if(bookmarkUuid === "") {
	    					saveBookmarkAtServerLayer(selectedCats, phrase, bookmarkName, patientId);
	    				} else {
	    					jq("#current-bookmark-object").val(bookmarkUuid);
	    				}
	    				addBookmarkAtUIlayer(phrase, selectedCats, bookmarkName);
	    			});
    			} else {
					failedToShowBookmark("A bookmark is only added after searching with a non blank phrase, Enter phrase and search first");
				}
			});
    	}
    	
    	function checkIfBookmarkExists(bookmarkName, phrase, categories, taskToRunOnSuccess) {
    		if(categories === "") {
				categories = "none";
			}
    		
    		if(bookmarkName !== "" && phrase) {
	    		jq.ajax({
					type: "POST",
					url: "${ ui.actionLink('checkIfBookmarkExists') }",
					data: {"phrase":phrase, "bookmarkName":bookmarkName, "categories":categories},
					dataType: "json",
					success: function(bookmarkUuid) {
						taskToRunOnSuccess(bookmarkUuid);
						
					},
					error: function(e) {
					}
				});
			}
    	}
    	
    	function getSelectedCategoryNames() {
    		var checkedCat = [];
    		var checkedCagegoryNames = "";
    		
    		jq('input:checkbox.category_check:checked').each(function() {
    			checkedCat.push(jq(this).attr('id').replace('_category', ''));
    		});
    		
    		for(i = 0; i < checkedCat.length; i++) {
    			if(i === checkedCat.length - 1) {
    				checkedCagegoryNames += checkedCat[i];
    			} else {
    				checkedCagegoryNames += checkedCat[i] + ", ";
    			}
    		}
    		return checkedCagegoryNames;
    	}
		
		function saveBookmarkAtServerLayer(selectedCategories, phrase, bookmarkName, patientId) {
			if(phrase && bookmarkName && patientId) {
				if(selectedCategories === "") {
					selectedCategories = "none";
				}
				jq.ajax({
					type: "POST",
					url: "${ ui.actionLink('saveOrUpdateBookmark') }",
					data: {"selectedCategories":selectedCategories, "searchPhrase":phrase, "bookmarkName":bookmarkName, "patientId":patientId},
					dataType: "json",
					success: function(bkObjs) {
						if(bkObjs) {
							jsonAfterParse.searchBookmarks = bkObjs.allBookmarks;
							jq("#current-bookmark-object").val(bkObjs.currentUuid);
							displayExistingBookmarks();
						}
						jq("#favorite-search-record").prop('disabled', false);
					},
					error: function(e) {
						//alert(e);
					}
				});
			}  	
    	
    	}
    	
    	function addBookmarkAtUIlayer(phrase, selectedCats, bookmarkName) {
	    	jq("#current-bookmark-name").val(bookmarkName);
	    	jq("#bookmark-category-names").text(selectedCats);
	    	jq("#bookmark-search-phrase").text(phrase);
		    	
    		jq("#favorite-search-record").removeClass("icon-star-empty");
		    jq("#favorite-search-record").addClass("icon-star");
			invokeDialog("#favorite-search-record-dialog", "Bookmark '" + phrase + "'", "400px"); 
    	}
    	
    	function removeBookmarkAtUIlayer() {
    		jq("#favorite-search-record").removeClass("icon-star");
	    	jq("#favorite-search-record").addClass("icon-star-empty");
	    	jq("#favorite-search-record-dialog").dialog("close");
    	}
    	
    	/*Overrides jq.("").dialog()*/
    	function invokeDialog(dialogMessageElement, dialogTitle, dialogWidth) {
	    	jq(dialogMessageElement).dialog({
				title: dialogTitle,
				width:dialogWidth
			});
    	}
    	
    	function checkIfPhraseExisitsInHistory(searchPhrase, taskToRunOnSuccess) {
    		if(searchPhrase !== "") {
	    		jq.ajax({
					type: "POST",
					url: "${ ui.actionLink('checkIfPhraseExisitsInHistory') }",
					data: {"searchPhrase":searchPhrase},
					dataType: "json",
					success: function(exists) {
						taskToRunOnSuccess(exists);
					},
					error: function(e) {
					}
				});
			}
    	}
    	
    	function failedToShowBookmark(message) {
	    	jq("#dialogFailureMessage").html(message);
			invokeDialog("#dialogFailureMessage", "Bookmarks are disabled!");
    	}
    	
    	function failedToShowNotes(message) {
	    	jq("#dialogFailureMessage").html(message);
			invokeDialog("#dialogFailureMessage", "Notes are disabled!");
    	}
    	
    	function deleteSearchBookmark(bookmarkUuid, bookmarkIsOpen) {
    		if(bookmarkUuid) {
    			jq.ajax({
					type: "POST",
					url: "${ ui.actionLink('deleteSearchBookmark') }",
					data: {"bookmarkUuid":bookmarkUuid},
					dataType: "json",
					success: function(bookmarks) {
						//removeBookmarkAtUIlayer();
						if(bookmarks) {
							jsonAfterParse.searchBookmarks = bookmarks;
							displayExistingBookmarks();
						}
					},
					error: function(e) {
					}
				});
			}
    	}
    	
	    function displayExistingBookmarks() {
	    	var bookmarks;
	    	var bookmarksToDisplay = "";
	    	bookmarks = jsonAfterParse.searchBookmarks.reverse();
	    	
	    	for(i = 0; i < bookmarks.length; i++) {
	    		bookmarksToDisplay += "<div class='possible-task-list-item'  id='" + bookmarks[i].uuid + "' name=' "+ bookmarks[i].searchPhrase + "'><i class='icon-remove delete-this-bookmark' id='" + bookmarks[i].uuid + "' title='Delete This Bookmark'></i>&nbsp&nbsp<b id='" + bookmarks[i].uuid + "'>" + bookmarks[i].bookmarkName + "</b>&nbsp&nbsp-&nbsp&nbsp<em id='" + bookmarks[i].uuid + "'>" + bookmarks[i].categories + "</em></div>";
	    	}
	    	
	    	jq("#lauche-stored-bookmark").html(bookmarksToDisplay + "<a href='' id='bookmark-manager-lancher'>Bookmark Manager</a>");
	    }
	    
	    function searchUsingBookmark(bookmarkUuid) {
	    	if(bookmarkUuid) {
	    		jq.ajax({
					type: "POST",
					url: "${ ui.actionLink('getSearchBookmarkSearchDetailsByUuid') }",
					data: {"uuid":bookmarkUuid},
					dataType: "json",
					success: function(bookmarks) {
						var phrase = bookmarks.searchPhrase;
						var cats = bookmarks.categories;
						var bkName = bookmarks.bookmarkName;
						var commaCats = bookmarks.commaCategories;
						
						autoFillSearchForm(phrase, cats, bkName);
						submitChartSearchFormWithAjax2(phrase, cats);
					},
					error: function(e) {
					}
				});
	    	}
	    }
	    
	    function autoFillSearchForm(searchPhrase, categories) {
		    if (searchPhrase) {
		        jq("#searchText").val(searchPhrase);
		
		        if (categories && categories.length !== 0) {
		            jq('input:checkbox.category_check').each(function() {
		                jq(this).prop('checked', false);
		            });
		
		            for (i = 0; i < categories.length; i++) {
		                jq('input:checkbox.category_check').each(function() {
		                    if (categories[i] === jq(this).val()) {
		                        jq(this).prop('checked', true);
		                    }
		                });
		            }
		        }
		    }
		}
		
		function submitChartSearchFormWithAjax2(phrase, cats, bkName) {
		    var searchText = document.getElementById('searchText');
		
		    jq("#lauche-stored-bookmark").hide();
		    jq("#lauche-other-chartsearch-features").hide();
		    jq("#chart-previous-searches-display").hide();
		    jq(".obsgroup_view").empty();
		    jq("#found-results-summary").html('');
		    jq("#obsgroups_results").html('<img class="search-spinner" src="../ms/uiframework/resource/uicommons/images/spinner.gif">');
		
		    jq.ajax({
		        type: "POST",
		        url: "${ ui.actionLink('getResultsFromTheServer') }",
		        data: jq('#chart-search-form-submit').serialize(),
		        dataType: "json",
		        success: function(results) {
		            jq("#obsgroups_results").html('');
		            jq(".inside_filter_categories").fadeOut(500);
		
		            jsonAfterParse = JSON.parse(results);
		            refresh_data();
		
		            jq(".results_table_wrap").fadeIn(500);
		            jq('#first_obs_single').trigger('click');
		            jq(".inside_filter_categories").fadeIn(500);
		            jq("#current-bookmark-name").val(bkName);
		            jq("#bookmark-category-names").text(cats);
		            jq("#bookmark-search-phrase").text(phrase);
		            //jq(".ui-dialog-content").dialog("close");
		            
		            updateBookmarksAndNotesUI();
		            displayBothPersonalAndGlobalNotes();
		            if(cats.length !== 0) {
		            	if(cats[0] !== "") {
		            		jq("#category-filter_method").text(capitalizeFirstLetter(cats[0]) + "...");
		            	}
		            }
		        },
		        error: function(e) {}
		    });
		}
    	
    	function changeNotesBgColor(element, color) {
    		jq(element).css('color', 'black');
    		jq(element).css('background-color', color);
    	}
    	
    	function saveSearchNote() {
    		var searchPhrase = jq("#searchText").val();
    		var patientId = jq("#patient_id").val();
    		var comment = jq("#new-comment-or-note").val();
    		var priority = jq("#new-note-priority option:selected").text();
    		var backgroundColor = jq("#new-note-color option:selected").text();
    		
    		changeNotesBgColor("#new-comment-or-note", "white");
    	
    		if(searchPhrase && patientId && comment) {
	    		jq.ajax({
					type: "POST",
					url: "${ ui.actionLink('saveANewNoteOnToASearch') }",
					data: {"searchPhrase":searchPhrase, "patientId":patientId, "comment":comment, "priority":priority, "backgroundColor":backgroundColor},
					dataType: "json",
					success: function(allNotes) {
						if(allNotes) {
							jsonAfterParse.personalNotes = allNotes.personalNotes;
							jsonAfterParse.globalNotes = allNotes.globalNotes;
							jsonAfterParse.currentUser = allNotes.currentUser;
							
							displayBothPersonalAndGlobalNotes();
							jq("#new-comment-or-note").val("");
							jq("#new-note-color option:selected").text("Color");
							jq("#patient_id").val("Priority");
						}
					},
					error: function(e) {
					}
				});
			}
    	}
    	
    	function formatTimeToShow(dateObj) {
    		var ctdDate = new Date(parseInt(dateObj));
		    var hour = ctdDate.getHours() + 1;
		    var min = ctdDate.getMinutes() + 1;
		    var sec = ctdDate.getSeconds() + 1;
		    var timeStr = hour + ":" + min + ":" + sec;
		    		//toUTCString
		    return ctdDate.toTimeString();
    	}
    	
    	function deleteSearchNote(uuid) {
    		var searchPhrase = jq("#searchText").val();
    		var patientId = jq("#patient_id").val();
    	
    		if(uuid) {
	    		jq.ajax({
					type: "POST",
					url: "${ ui.actionLink('deleteSearchNote') }",
					data: {"uuid":uuid, "searchPhrase":searchPhrase, "patientId":patientId},
					dataType: "json",
					success: function(allNotes) {
						if(allNotes) {
							jsonAfterParse.personalNotes = allNotes.personalNotes;
							jsonAfterParse.globalNotes = allNotes.globalNotes;
							jsonAfterParse.currentUser = allNotes.currentUser;
							
							displayBothPersonalAndGlobalNotes();
						}
					},
					error: function(e) {
					}
				});
			}
    	}
    	
    	function refreshSearchNotes() {
    		var searchPhrase = jq("#searchText").val();
    		var patientId = jq("#patient_id").val();
	    	jq.ajax({
				type: "POST",
				url: "${ ui.actionLink('refreshSearchNotes') }",
				data: {"searchPhrase":searchPhrase, "patientId":patientId},
				dataType: "json",
				success: function(allNotes) {
					if(allNotes) {
						jsonAfterParse.personalNotes = allNotes.personalNotes;
						jsonAfterParse.globalNotes = allNotes.globalNotes;
						jsonAfterParse.currentUser = allNotes.currentUser;
						
						displayBothPersonalAndGlobalNotes();
					}
				},
				error: function(e) {
				}
			});
    	}
    
	});
    
       
</script>



<i id="delete-search-record" class="icon-remove medium" title="Reset"></i>
<div class="search-record-dialog-content" id="delete-search-record-dialog">Do you want to delete?</div>

<i id="favorite-search-record" class="icon-star-empty medium" title="Bookmark Search"></i>
<div class="search-record-dialog-content" id="favorite-search-record-dialog">
	<div id="bookmark-header">Edit This Bookmark</div>
	<div id="bookmark-info">
        <div id="bookmark-icon-and-remove">
            <i class="icon-star medium"></i><a id="remove-current-bookmark" href="">Remove</a>
    	</div>
        <div id="bookmark-name-and-cats">
        	<input type="hidden" id="current-bookmark-object" value="" />
            <b>Name:</b>&nbsp&nbsp<input type="textbox" id="current-bookmark-name" value="" /><br /><br />
            <b>Search Phrase:</b> <label id="bookmark-search-phrase"></label><br /><br />
            <b>Categories:</b> <label id="bookmark-category-names"></label><br /><br />
            <input type="button" id="cancel-edit-bookmark" value="Cancel" />
            <input type="button" id="submit-edit-bookmark" value="Done" /><br />
        </div>
	</div>
</div>

<i id="comment-on-search-record" class="icon-comment-alt medium" title="Comment on Search"></i>
<div class="search-record-dialog-content" id="comment-on-search-record-dialog">
	<b>Previous Notes:</b>
	<div id="previous-notes-on-this-search">
		
	</div>
	<div id="add-new-note-on-this-search">
		<b>Add a new Note:</b><br />
		Comment:
		<textarea id="new-comment-or-note" style="height: 80px; width: 512px;"></textarea>
		<br />
		<i class="icon-user-md medium"></i>&nbsp&nbsp&nbsp&nbsp&nbsp
		<select id="new-note-priority" title="Priority/Severity of this note">
			<option>Priority</option>
			<option>LOW</option>
			<option>HIGH</option>
		</select>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
		<select id="new-note-color" title="Background color for this Note">
			<option>Color</option>
			<option>orange</option>
			<option>yellow</option>
			<option>violet</option>
			<option>lime</option>
			<option>beige</option>
			<option>cyan</option>
			<option>aqua</option>
			<option>deeppink</option>
			<option>magenta</option>
			<option>red</option>
		</select>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
		<i class="icon-refresh medium" id="refresh-notes-display"></i>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
		<input type="button" id="save-a-new-note" value="Save Note" />
	</div>
</div>

<div id="dialogFailureMessage"></div>

<a id="quick-searches" href="" title="Quick Searches">Q.k-<i class="icon-search"></i></a>
<div class="search-record-dialog-content" id="quick-searches-dialog-message"></div>


<i id="possible-task-list" class="icon-reorder medium" title="List Items"></i>
<div id="lauche-stored-bookmark"></div>

<div id="lauche-other-chartsearch-features">
	<div class="possible-task-list-item" id="history-task-list-item">History Manager</div>
	<div class="possible-task-list-item" id="bookmark-task-list-item">Bookmarks</div>
	<div class="possible-task-list-item" id="preferences-task-list-item">Preferences</div>
	<div class="possible-task-list-item" id="commands-task-list-item">Commands</div>
	<div class="possible-task-list-item" id="settings-task-list-item">Settings</div>
	<div class="possible-task-list-item" id="notes-task-list-item">Notes Manager</div>
</div>
