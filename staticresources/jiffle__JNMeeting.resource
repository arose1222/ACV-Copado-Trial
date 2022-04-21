/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = "./app/scripts/Meeting/app.js");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./app/scripts/Meeting/actions.js":
/*!****************************************!*\
  !*** ./app/scripts/Meeting/actions.js ***!
  \****************************************/
/*! no static exports found */
/***/ (function(module, exports) {

var MeetingActions = Reflux.createActions(['fetchMeetings', 'reFetchMeetings', 'searchMeetings', 'updateSearch', 'resetFilter', 'updateFilter', 'applyFilter', 'meetingAction', 'toggleView', 'getFilters', 'fetchOptions', 'bulkApproveMeetings', 'bulkCancel', 'fetchEventDetails', 'uploadAgendaItemCsv', 'triggerServeyMails', 'bulkReinviteUsers']);

module.exports = MeetingActions;

/***/ }),

/***/ "./app/scripts/Meeting/app.js":
/*!************************************!*\
  !*** ./app/scripts/Meeting/app.js ***!
  \************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

initI18n(enLocale["meetings"]);
var Handler = __webpack_require__(/*! ./handler */ "./app/scripts/Meeting/handler.js");
var Api = __webpack_require__(/*! common_api */ "./app/scripts/commons/jiffle/api.js");

$(document).ready(function () {

    if (typeof jiffle !== 'undefined') {
        Api.sfdcHandler.meetingInit(function () {
            Handler.init();
        });
    } else {
        Handler.init();
    }
    setupUiI18n();
});

/***/ }),

/***/ "./app/scripts/Meeting/handler.js":
/*!****************************************!*\
  !*** ./app/scripts/Meeting/handler.js ***!
  \****************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var Actions = __webpack_require__(/*! ./actions */ "./app/scripts/Meeting/actions.js");
var Store = __webpack_require__(/*! ./store */ "./app/scripts/Meeting/store.js");
var Api = __webpack_require__(/*! common_api */ "./app/scripts/commons/jiffle/api.js");
var meetingFilterCmp = __webpack_require__(/*! ../commons/meeting_filters */ "./app/scripts/commons/meeting_filters.js");
var Api = __webpack_require__(/*! common_api */ "./app/scripts/commons/jiffle/api.js");

var _require = __webpack_require__(/*! ../utils */ "./app/scripts/utils/index.js"),
    putSearchQueryParam = _require.putSearchQueryParam;

// var _ = require('lodash');
// var i18n = require('i18next-client');

var MeetingHandler = function () {
  if (_.isUndefined(window.userType)) {
    window.userType = 'internal';
  }
  if (_.isUndefined(window.MeetingType)) {
    window.MeetingType = 'generalMeetings';
  }

  var meetingListContainer = $('#meeting_list');
  var agendaListContainer = $('#agenda_list');
  var appliedFiltersContainer = $('#applied_filters_list');
  var toggleBtnUl = $('.toggle-menu-list');
  var globalSearch = $('#global_filter');
  var filterSearchField = $('#filter_search');
  var resetFilterBtn = $('#reset_filter');
  var applyFilterBtn = $('#apply_filter');
  var filterToggleBtn = $('#filter_toggle');
  var filter = $('#filter');
  var filterStartDate = $('#filter_start_date');
  var filterEndDate = $('#filter_end_date');
  var exportBtn = $('#export');
  var meetingCount = $('.meeting_count.desktop');
  var meetingCountMobile = $('.meeting_count.mobile');
  var bookMeetingBtn = $('#book_meeting');
  var bookMeetingAddBtn = $('#book_meeting_add_btn');
  var bookAgendaBtn = $('#book_agenda_item');
  var bookAgendaAddBtn = $('#book_agenda_add_btn');
  var notificationModal = $('.notification-modal');
  var filterPanel = $('#filterPanel');
  var selectActivityModal = $('.modal-select-activity');
  var meetingActivityContainer = $('#meeting-type-list');
  var selectedMeetingCardHash = {};
  var surveySelectedMeeting = {};
  var hasSelectedMeetings = false;
  var selectAllFlag = false;
  var bulkActionBar = $('.bulk-action');
  var isStaffEvent;
  var displayLabelForAgenda;
  var uuidOfMeetingTypeForAgenda;
  var agendaItemDateTimeFormat = 'hh:mm A ddd, MMM DD, YYYY';
  var meetingTimeFormat = 'hh:mm A';
  var meetingDateFormat = 'ddd, MMM D, YYYY';
  var externalCountTab = $('.tab_external');
  var mobileExternalCountTab = $('.mobile_tab_external');
  var internalCountTab = $('.tab_internal');

  var mobileInternalCountTab = $('.mobile_tab_internal');
  var sessionCountTab = $('.tab_session');
  var consecutiveMeetingTab = $('.tab_consecutive_meeting');
  var mobileConsecutiveCountTab = $('.mobile_tab_consecutive_meeting');
  var mobileSessionCountTab = $('.mobile_tab_session');
  var currentTab;
  var mobileCurrentTab;
  var revieweeMeetingCountTab = $('.tab_reviewee_meeting');
  var mobileRevieweeMeetingCountTab = $('.mobile_tab_reviewee_meeting');
  var isInternal = userType === 'internal';
  var mobileTabCheckin = $('.mobile_tab_checkin');
  var userTab = $('.tab_' + userType);
  var mobileCurrTab = $('.mobile_tab_' + userType);
  var surveyModalEl = $('.js-meeting-survey-modal');
  var bulkCancelBtn = $('#js-bulk-cancel');

  var TRACKS_AND_SESSIONS_MASTER_NAME = "Tracks and Sessions";

  var storeHandlers = {
    meetinglisting: handleMeetingList,
    viewchanged: handelViewToggle,
    meetingFilters: setMeetingFilters,
    onBulkApprovalSuccess: onBulkApprovalSuccess,
    onBulkCancelSuccess: onBulkCancelSuccess,
    onBulkCancelFailure: onBulkCancelFailure,
    onBulkApprovalFailure: onBulkApprovalFailure,
    onBulkReinviteUserSuccess: onBulkReinviteUserSuccess,
    eventDetails: onEventDetails,
    agendaItemUploadFailure: agendaItemUploadFailureHandler,
    agendaItemUploadSuccess: agendaItemUploadSuccessHandler,
    addToSelectedMeetingCardHash: addToSelectedMeetingCardHash,
    serveyMailsTriggered: serveyMailsTriggered
  };
  var eventInfo;
  var meetingTypeHash = {
    'consecutiveMeetings': {
      displayText: 'CM',
      currentTab: consecutiveMeetingTab,
      currentMobileTab: mobileConsecutiveCountTab,
      checkinUrl: Api.ENDPOINTS.checkin_meetings_list,
      selectAllClass: '',
      isConsecutive: true,
      editMeetingUrl: Api.ENDPOINTS.consecutive_meetings_edit_path,
      viewMeetingUrl: Api.ENDPOINTS.consecutive_meetings_view_path
    },
    'generalMeetings': {
      displayText: 'M',
      currentTab: internalCountTab,
      currentMobileTab: mobileInternalCountTab,
      checkinUrl: Api.ENDPOINTS.checkin_meetings_list,
      selectAllClass: '.manage-internal-selectall',
      isConsecutive: false,
      editMeetingUrl: Api.ENDPOINTS.meeting_request_edit_path,
      viewMeetingUrl: Api.ENDPOINTS.meeting_request_view_path
    }
  };
  function init() {
    Actions.fetchEventDetails();

    var showActivities = new RegExp('[\?&]showActivities=([^&#]*)').exec(window.location.search);
    if (showActivities && showActivities[1] == 'true') {
      showMeetingActivities();
    }

    Store.EventStore.listen(function (data) {
      var func = storeHandlers[data.type];
      if (func) {
        func(data);
      }
    });

    Store.MeetingStore.setCurrentUserFlags();
  };

  function onEventDetails(data) {
    isStaffEvent = Store.EventStore.isStaffSchedulingEvent();
    eventInfo = Store.EventStore.getEventDetails();
    if (data.success) {
      if (isStaffEvent) {
        setupForStaffScheduleEvent();
        displayLabelForAgenda = Store.EventStore.getFieldFromMeetingTypeForAgenda('display_name');
        uuidOfMeetingTypeForAgenda = Store.EventStore.getFieldFromMeetingTypeForAgenda('uuid');
      } else {
        setupForTradeShowEvent();
      }
    }
    enableSelectAllFunctionality();
  }

  function enableSelectAllFunctionality() {
    var selectAllBtn = isStaffEvent ? $('.manage-internal-selectall') : $(meetingTypeHash[MeetingType].selectAllClass);
    selectAllBtn.removeClass('hide');
  }

  function setupForStaffScheduleEvent() {
    Store.MeetingStore.listen(function (data) {
      var func = storeHandlers[data.type];
      if (func) {
        func(data);
      }
    });
    Store.MeetingActionStore.listen(function (result) {
      updateCard(result);
    });
    setupListenersForStaffScheduleEvent();
    Actions.getFilters(envDetails.predefined_filters || {});
  }

  function attachCommonUIListeneres() {
    globalSearch.on('keyup', _.debounce(searchMeetings, 500));
    toggleBtnUl.on('click', 'a.toggle-btn', updateToggleViewState);

    bulkActionBar.on('click', '#js-bulk-approve', handleBulkApproveMeetings);
    bulkActionBar.on('click', '#js-bulk-reinvite', handleBulkReinviteUsers);

    /** filter events **/

    applyFilterBtn.on('click', handleFilterClick);
    resetFilterBtn.on('click', resetFilter);
    filterToggleBtn.on('click', function (e) {
      e.stopPropagation();
      filter.toggleClass('show');
    });

    filterSearchField.on('keyup', _.debounce(updateSearch, 500));
    appliedFiltersContainer.on('click', '.selected-item .remove', removeSelectedFilter);

    /** filter events **/

    $(document).on('click', function (e) {
      filter.removeClass('show');
    });
    filter.on('click', function (e) {
      e.stopPropagation();
    });

    $(window).infiniteScroll({
      offset: 200,
      callback: fetchMoreMeetings
    });

    var listConatainer = isStaffEvent === true ? '.agenda-list' : '.meeting-list';
    $('.select_all_meeting').on('click', { container: listConatainer }, selectAllMeeting);
  }

  function setupListenersForStaffScheduleEvent() {
    attachCommonUIListeneres();

    agendaListContainer.on('change', '.upload-agenda-input', handleAgendaItemUpload).on('change', 'input[name="meetingCard"]', cardSelectionHandler);

    agendaListContainer.on('submit', '.upload-csv', submitAgendaItemUploadForm);
    agendaListContainer.on('click', '.meetingRevealCls', handleAgendaClick);

    agendaListContainer.on('click', bookAgendaBtn.selector, function (e) {
      e.stopPropagation();
      handleBookAgendaClick();
    });

    agendaListContainer.on('click', bookAgendaAddBtn.selector, function (e) {
      e.stopPropagation();
      handleBookAgendaClick();
    });

    agendaListContainer.on('click', '.meeting-accept, .meeting-decline', postMeetingAction).on('click', '.meeting-approve', putMeetingAction).on('click', '.meeting-cancel', cancelMeeting);

    bulkCancelBtn.on('click', handleBulkCancel);
  }

  function handleAgendaClick() {
    var uuid = $(this).data('uuid');
    var agenda = Store.MeetingStore.getMeeting(uuid);
    var url = agenda.edit && agenda.status !== 'cancelled' ? envDetails.urlPrefix + '/meeting_request/' + uuid + '/edit' : envDetails.urlPrefix + '/meeting_request/' + uuid + '/view';
    window.commons.redirectPage(url);
  }

  function handleBookAgendaClick() {
    window.commons.redirectPage(envDetails.urlPrefix + Api.ENDPOINTS.meeting_request_path + '?activity_uuid=' + uuidOfMeetingTypeForAgenda);
  }

  function handleAgendaItemUpload(event) {
    event.stopPropagation();
    event.preventDefault();

    var fileElement = event.target;

    var data = new FormData();
    var files = fileElement.files;

    if (files.length) {
      $('#cover').show();
      $.each(files, function (key, value) {
        data.append('csv_file', value);
      });
      Actions.uploadAgendaItemCsv(data);

      var AgendaUploadWidget = $(fileElement);
      AgendaUploadWidget.val('');
      var AgendaUploadWidgetClone = AgendaUploadWidget.clone(false);
      AgendaUploadWidget.replaceWith(AgendaUploadWidgetClone);
    }
  }

  function submitAgendaItemUploadForm() {
    agendaListContainer.find('.upload-csv').submit();
  }

  function agendaItemUploadFailureHandler(data) {
    $('#cover').fadeOut();

    var headerMessage = i18n.t('agenda_item_csv_upload_failure_header');
    var error_message = data.countMessage + '<br><br>';

    if (data.download_link) {
      error_message += data.download_link;
    }

    var errors = data.errors;

    if (_.isString(errors)) {
      error_message += errors;
    } else if (_.isObject(errors)) {
      _.forEach(errors, function (error, index) {
        error_message += error + '<br>';
      });
    }

    notificationModal.notificationModal({
      type: 'notification',
      class: 'red',
      title: headerMessage,
      body: error_message
    });
  }

  function agendaItemUploadSuccessHandler(data) {
    $('#cover').fadeOut();

    notificationModal.notificationModal({
      type: 'notification',
      class: 'green',
      title: i18n.t('agenda_item_csv_upload_success_header'),
      body: data.countMessage
    });
  }

  function setupForTradeShowEvent() {
    mobileInternalCountTab.removeClass('active');
    mobileExternalCountTab.removeClass('active');
    internalCountTab.removeClass('active');
    externalCountTab.removeClass('active');
    meetingTypeHash[MeetingType].currentTab.addClass('active');
    meetingTypeHash[MeetingType].currentMobileTab.addClass('active');
    meetingTypeHash[MeetingType].currentTab.off('click');

    Store.MeetingStore.listen(function (data) {
      var func = storeHandlers[data.type];
      if (func) {
        func(data);
      }
    });

    Store.MeetingActionStore.listen(function (result) {
      updateCard(result);
    });

    setupUI();
    setupListeners();
  };

  function setupUI() {
    Actions.getFilters(envDetails.predefined_filters || {});
    setActiveState(Store.MeetingStore.getLocalToggle());
    var startDate = moment(envDetails.event.start_date, 'YYYY-MM-DD');
    var endDate = moment(envDetails.event.end_date, 'YYYY-MM-DD');
    filterStartDate.datepicker({
      dateFormat: 'mm/dd/yy',
      minDate: startDate._d,
      maxDate: endDate._d
    });
    filterEndDate.datepicker({
      dateFormat: 'mm/dd/yy',
      minDate: startDate._d,
      maxDate: endDate._d
    });
  };

  function setMeetingFilters(apiResponse) {
    var searchTerm = (apiResponse.data.appliedSearch || '').trim();
    setMeetingSearch(searchTerm);
    Actions.updateSearch(searchTerm);
    meetingFilterCmp.setMeetingFilters(apiResponse.data.filters, filterPanel, Actions);
    applyFilter();
  }

  function setMeetingSearch(searchValue) {
    globalSearch.val(searchValue);
    filterSearchField.val(searchValue);
  }

  function updateToggleViewState(e) {
    e.preventDefault();
    var El = $(e.currentTarget);
    if (!El.hasClass('active')) {
      Actions.toggleView(El.data('switch-type'));
    }
  }

  function handelViewToggle(data) {
    setActiveState(data.selectedView);
    if (data.selectedView === 'checkin') {
      var checkinUrl = meetingTypeHash[MeetingType].checkinUrl;
      window.commons.redirectPage(envDetails.urlPrefix + checkinUrl);
    } else {
      commons.setItem('meeting-list', data.selectedView);
      var viewStyle = data.data.viewStyle;
      var listHolder = isStaffEvent == true ? agendaListContainer.find('.agenda-list') : meetingListContainer.find('.meeting-list');
      listHolder.removeClass('tile-view list-view').addClass(viewStyle);
      listHolder.find('div.item').removeClass('col-md-3 col-sm-4 col-md-12').addClass(data.data.tileSize);
    }
  };

  function setActiveState(selectedView) {
    toggleBtnUl.find('a').removeClass('active');
    $("a[data-switch-type='" + selectedView + "']").addClass('active');
  }

  function handleMeetingList(data) {
    data = data.data;
    if (isStaffEvent) {
      displayAgendaItems(data);
      updateActivityCount(data.total);
    } else {
      displayMeetings(data);
      updateMeetingCount(data.total, data.totalExternal, data.totalSessions, data.totalConsecMeeting, data.totalInternalMeeting, data.totalRevieweeMeeting);
    }
    Store.MeetingStore.updateFetchState(false);
  };

  function updateCard(result) {
    if (_.isEmpty(result.errors)) {
      refreshMeetingListAfterAction();
    } else {
      notificationModal.notificationModal({
        timeout: true,
        class: 'red',
        title: i18n.t('failure'),
        body: result.errors.RuntimeError.join(',')
      });
    }
  };

  function refreshMeetingListAfterAction() {
    Store.MeetingStore.setCurrentPage(1);
    Store.MeetingStore.resetMeetingList();
    Actions.fetchMeetings(1);
  }

  function addCommonFieldsForDisplay(item) {
    if (item && item.invitees_status_counts) {
      item.pendingCount = item.invitees_status_counts.pending || 0;
      item.totalInviteeCount = item.invitees_status_counts.total_invitees || 0;
      item.acceptedCount = item.invitees_status_counts.accepted || 0;
      item.declinedCount = item.invitees_status_counts.declined || 0;
      item.meeting_with = item.meeting_with || '';
      item.fontSize = window.commons.getFontSize(item.meeting_with || '');
      item.tileSize = Store.MeetingStore.getToggleState().tileSize;
      item.showUserActions = true;
      item.meetingType = meetingTypeHash[MeetingType].displayText;
    }
  }

  function addFieldsForMeetingDisplay(meeting) {
    meeting.multipleDayDisplayFormat = false;
    meeting.startTime = moment(meeting.start_time).utc().format(meetingTimeFormat);
    meeting.endTime = moment(meeting.end_time).utc().format(meetingTimeFormat);
    meeting.meetingDate = moment(meeting.start_time).utc().format(meetingDateFormat);
  }

  function addFieldsForAgendaDisplay(agenda) {
    agenda.multipleDayDisplayFormat = true;

    agenda.startDateTime = moment(agenda.start_time).utc().format(agendaItemDateTimeFormat);
    agenda.endDateTime = moment(agenda.end_time).utc().format(agendaItemDateTimeFormat);
  }

  function updateMeetingCount(count, externalCount, sessionCount, consecCount, internalCount, revieweeMeetingCount) {
    currentTab = $('li.active', '.nav-count');
    mobileCurrentTab = $('a.active', '.navbar-header');
    var internalTabText = i18n.t((internalCount || count) === 1 ? 'MEETING' : 'MEETINGS', { count: '' });
    var externalTabText = i18n.t(externalCount === 1 ? 'REQUEST' : 'REQUESTS', { count: '' });
    var externalMobileTabText = i18n.t(externalCount === 1 ? 'REQ' : 'REQS', { count: '' });
    var sessionTabtext = i18n.t(sessionCount === 1 ? 'SESSION' : 'SESSIONS');
    var revieweeMeetingTabText = i18n.t(revieweeMeetingCount === 1 ? 'REVIEWEE_MEETING' : 'REVIEWEE_MEETINGS');
    var consecutiveTabText = i18n.t((consecCount || count) === 1 ? 'CONSECUTIVE MEETING' : 'CONSECUTIVE MEETINGS');
    displayCountInTab(externalCountTab, mobileExternalCountTab, externalCount, externalTabText);
    displayCountInTab(internalCountTab, mobileInternalCountTab, internalCount, internalTabText);
    displayCountInTab(consecutiveMeetingTab, mobileConsecutiveCountTab, consecCount, consecutiveTabText);
    displayCountInTab(sessionCountTab, mobileSessionCountTab, sessionCount, sessionTabtext);
    displayCountInTab(revieweeMeetingCountTab, mobileRevieweeMeetingCountTab, revieweeMeetingCount, revieweeMeetingTabText);
    updateCountInCurrTab(currentTab, mobileCurrentTab, count);
  };

  function updateCountInCurrTab(tab, mobileTab, count) {
    tab.find('.meeting_count').text(count);
    mobileTab.find('.meeting_count').text(count);
  }

  function displayCountInTab(tab, mobileTab, count, textLabel, mobileTextLabel) {
    tab.find('.meeting_count').text(count).siblings('span.title_text').text(textLabel);
    mobileTab.find('.meeting_count').text(count).siblings('span.title_text').text(mobileTextLabel || textLabel);
  }

  function updateActivityCount(count) {
    var label = count > 1 ? pluralize(displayLabelForAgenda) : displayLabelForAgenda;
    $('.tab_internal').find('.meeting_count').text(count).siblings('span.title_text').html(label);
    $('.mobile_tab_internal').find('.meeting_count').text(count).siblings('span.title_text').html(label);
  }

  function displayAgendaItems(data) {
    var template = __webpack_require__(/*! Templates/meeting/meeting-list */ "./templates/meeting/meeting-list.hbs");

    var agendaItems = data.meetings;
    hasSelectedMeetings = false;
    agendaItems.map(function (agendaItem) {
      if (selectedMeetingCardHash[agendaItem.uuid]) {
        agendaItem.checked = 'checked';
        hasSelectedMeetings = true;
      } else {
        agendaItem.checked = '';
      }
      addCommonFieldsForDisplay(agendaItem);
      addFieldsForAgendaDisplay(agendaItem);
    });

    var hideAddActivityOption = eventInfo.isAdmin === false && eventInfo.isActivityManager === false;
    var displayHtml = template({
      meetingList: agendaItems,
      isEBCEvent: false,
      isStaffSchedule: true,
      toggleState: data.toggleState,
      listClass: 'agenda-list',
      approve_label: i18n.t('approve'),
      cancel_label: i18n.t('cancel'),
      decline_label: i18n.t('decline'),
      accept_label: i18n.t('accept'),
      CanAccessViewOnlyEvent: eventInfo.can_access_vo_event,
      displayLabelForAddAgenda: i18n.t('add_agenda_item', { label: displayLabelForAgenda }),
      displayLabelForUploadAgenda: i18n.t('upload_agenda_items', { label: pluralize(displayLabelForAgenda) }),
      downloadAgendaItemTemplateUrl: envDetails.urlPrefix + Api.ENDPOINTS.download_agenda_item_template_url,
      hideAddActivityOption: hideAddActivityOption
    });
    agendaListContainer.html(displayHtml);
    showHideBulkActionBar();
  }

  function displayMeetings(data) {
    var template = __webpack_require__(/*! Templates/meeting/meeting-list */ "./templates/meeting/meeting-list.hbs");
    var bookMeetingPath = envDetails.urlPrefix + Api.ENDPOINTS.meeting_request_path;
    if (typeof jiffle !== 'undefined') {
      bookMeetingPath = Api.ENDPOINTS.jn_book_meeting + window.location.search;
    }

    var meetings = _.cloneDeep(data.meetings);
    hasSelectedMeetings = false;
    meetings.map(function (meeting) {
      if (selectedMeetingCardHash[meeting.uuid]) {
        meeting.checked = 'checked';
        hasSelectedMeetings = true;
      } else {
        meeting.checked = '';
      }
      addCommonFieldsForDisplay(meeting);
      addFieldsForMeetingDisplay(meeting);
    });
    meetingListContainer.html(template({
      meetingList: meetings,
      toggleState: data.toggleState,
      approve_label: i18n.t(meetingTypeHash[MeetingType].approveLabel),
      cancel_label: i18n.t(meetingTypeHash[MeetingType].cancelLabel),
      decline_label: i18n.t(meetingTypeHash[MeetingType].declineLabel),
      accept_label: i18n.t(meetingTypeHash[MeetingType].acceptLabel),
      book_meeting_path: bookMeetingPath,
      CanAccessViewOnlyEvent: eventInfo.can_access_vo_event,
      showNewMeeting: true,
      isEBCEvent: isEBCEvent,
      listClass: 'meeting-list',
      meetingType: meetingTypeHash[MeetingType].displayText,
      isConsecutive: meetingTypeHash[MeetingType].isConsecutive
    }));
    showHideBulkActionBar();
    hideApproveButtonForSfdc();
    hideSurveyIconForSfdc();
  }

  function hideApproveButtonForSfdc() {
    if (!shouldShowActionsForSfdc()) {
      meetingListContainer.find('.meeting-card .card-footer .meeting-approve').addClass('hide');
    }
  }

  function hideSurveyIconForSfdc() {
    if (!shouldShowActionsForSfdc()) {
      meetingListContainer.find('.meeting-card .card-content .js-survey-icon').addClass('hide');
    }
  }

  function shouldShowActionsForSfdc() {
    return !(typeof jiffle !== 'undefined' && (envDetails.isCSM() || envDetails.isMeetingManager() || envDetails.isJuniorMM() || envDetails.isQueueManager()));
  }

  function selectAllMeeting(event) {
    if (!selectAllFlag) {
      selectAllFlag = true;
      $('.select_all_meeting').html(i18n.t('clear'));
      $('input:checkbox.selectable', event.data.container).each(function (index, element) {
        var uuid = $(element).prop('checked', true).data('uuid');
        selectedMeetingCardHash[uuid] = true;
        hasSelectedMeetings = true;
      });
    } else {
      $('.select_all_meeting').html(i18n.t('select_all'));
      selectAllFlag = false;
      $('input:checkbox.selectable', event.data.container).prop('checked', false);
      selectedMeetingCardHash = {};
      hasSelectedMeetings = false;
    }
    showHideBulkActionBar();
  }
  function addToSelectedMeetingCardHash(newList) {
    if (selectAllFlag) {
      _.each(newList.data, function (meeting) {
        selectedMeetingCardHash[meeting.uuid] = true;
        hasSelectedMeetings = true;
      });
    }
  }
  function cardSelectionHandler() {
    var thisMeeting = $(this);
    var uuid = thisMeeting.data('uuid');
    selectAllFlag = false;
    $('.select_all_meeting').html(i18n.t('select_all'));
    if (thisMeeting.is(':checked')) {
      selectedMeetingCardHash[uuid] = true;
      hasSelectedMeetings = true;
    } else {
      delete selectedMeetingCardHash[uuid];
      hasSelectedMeetings = Store.MeetingStore.getAvailableSelectedMeetings(selectedMeetingCardHash).length > 0;
    }
    showHideBulkActionBar();
  }

  function showHideBulkActionBar() {
    // Shameer: if condition will be removed once bulk action comes for consecutive meeting
    if (MeetingType !== 'consecutiveMeetings') {
      bulkActionBar[hasSelectedMeetings ? 'removeClass' : 'addClass']('hide');
    }
  }

  function handleBulkApproveMeetings(event) {
    event.preventDefault();
    event.stopPropagation();

    var _done = false;
    var store = Store.MeetingStore;
    var meetingCount = selectAllFlag === true ? store.getTotalMeetingCount() : store.getAvailableSelectedMeetings(selectedMeetingCardHash).length;
    var bodyMessage = isStaffEvent ? i18n.t('bulk_activity_approval_confirm_message', { count: meetingCount, displayLabel: displayLabelForAgenda.toLocaleLowerCase() }) : i18n.t('bulk_approval_confirm_message');

    notificationModal.notificationModal({
      type: 'confirmation',
      class: 'blue',
      body: bodyMessage,
      title: i18n.t('bulk_approval_confirm_title'),
      done: function done() {
        _done = true;
      },
      dismiss: function dismiss() {
        _done && Actions.bulkApproveMeetings(selectedMeetingCardHash, selectAllFlag);
      }
    });
  }

  function handleBulkReinviteUsers(event) {
    event.stopPropagation();
    event.preventDefault();
    var _done2 = false;
    notificationModal.notificationModal({
      type: 'confirmation',
      class: 'blue',
      body: i18n.t('bulk_user_invite_confirm_message'),
      title: i18n.t('bulk_user_invite_confirm_title'),
      done: function done() {
        _done2 = true;
      },
      dismiss: function dismiss() {
        _done2 && Actions.bulkReinviteUsers(selectedMeetingCardHash, selectAllFlag);
      }
    });
  }

  function handleBulkCancel(event) {
    event.preventDefault();
    event.stopPropagation();

    var titleMessage = i18n.t('bulk_cancel_confirm_title');
    var store = Store.MeetingStore;
    var count = selectAllFlag === true ? store.getTotalMeetingCount() : store.getAvailableSelectedMeetings(selectedMeetingCardHash).length;
    var bodyMessage = i18n.t('bulk_cancel_confirm_message', { count: count, displayLabel: displayLabelForAgenda.toLocaleLowerCase() });
    var _done3 = false;

    notificationModal.notificationModal({
      type: 'confirmation',
      class: 'blue',
      body: bodyMessage,
      title: titleMessage,
      done: function done() {
        _done3 = true;
      },
      dismiss: function dismiss() {
        _done3 && Actions.bulkCancel(selectedMeetingCardHash, selectAllFlag);
      }
    });
  }

  function onBulkApprovalSuccess(data) {
    data = data.data;
    var bodyTitle = isStaffEvent ? i18n.t('bulk_activity_approval_success_title') : i18n.t('bulk_approval_success_title');
    var bodyMessage = isStaffEvent ? i18n.t('bulk_activity_approval_success_message', { count: data.approvedMeetingCount, displayLabel: displayLabelForAgenda.toLocaleLowerCase() }) : i18n.t('bulk_approval_success_message');

    notificationModal.notificationModal({
      type: 'notification',
      class: 'green',
      title: bodyTitle,
      body: bodyMessage,
      dismiss: function dismiss() {
        clearSelectedMeetingHash(data.toBeApprovedMeetings);
        reloadMeetingList();
      }
    });
  }

  function onBulkCancelSuccess(data) {
    data = data.data;
    var bodyTitle = i18n.t('bulk_cancel_success_title');
    var bodyMessage = i18n.t('bulk_cancel_success_message', { count: data.cancelledMeetingCount, displayLabel: displayLabelForAgenda.toLocaleLowerCase() });

    notificationModal.notificationModal({
      type: 'notification',
      class: 'green',
      title: bodyTitle,
      body: bodyMessage,
      dismiss: function dismiss() {
        clearSelectedMeetingHash(data.toBeCancelledMeetings);
        reloadMeetingList();
      }
    });
  }

  function onBulkReinviteUserSuccess(data) {
    notificationModal.notificationModal({
      type: 'notification',
      class: 'green',
      title: i18n.t('bulk_invite_users_success_title'),
      body: i18n.t('bulk_invite_users_success_message'),
      dismiss: function dismiss() {
        clearSelectedMeetingHash(Object.keys(selectedMeetingCardHash));
        reloadMeetingList();
      }
    });
  }

  function onBulkApprovalFailure(data) {
    var entityLabel = isStaffEvent === true ? displayLabelForAgenda.toLocaleLowerCase() : 'meeting';

    notificationModal.notificationModal({
      type: 'notification',
      class: 'red',
      title: i18n.t('bulk_approval_failure_title'),
      body: i18n.t('bulk_approval_failure_message', { entityLabel: entityLabel })
    });
  }

  function onBulkCancelFailure(data) {
    notificationModal.notificationModal({
      type: 'notification',
      class: 'red',
      title: i18n.t('bulk_cancel_failure_title'),
      body: i18n.t('bulk_cancel_failure_message', { entityLabel: displayLabelForAgenda.toLocaleLowerCase() })
    });
  }

  function clearSelectedMeetingHash(approvedMeetings) {
    approvedMeetings.forEach(function (meetingUuid) {
      delete selectedMeetingCardHash[meetingUuid];
    });
    selectAllFlag = false;
    hasSelectedMeetings = Store.MeetingStore.getAvailableSelectedMeetings(selectedMeetingCardHash).length > 0;
    showHideBulkActionBar();
  }

  function reloadMeetingList() {
    window.scrollTo(0, 0);
    selectAllFlag = false;
    $('.select_all_meeting').html(i18n.t('select_all'));
    Store.MeetingStore.setCurrentPage(1);
    Store.MeetingStore.resetMeetingList();
    Actions.fetchMeetings(1);
  }

  function handleInternalTabClick(event) {
    event.preventDefault();
    event.stopPropagation();

    if (typeof jiffle !== 'undefined') {
      var search = window.location.search;
      newPage = Api.ENDPOINTS.apex_jnmeetings + search;
      window.commons.redirectPage(newPage);
    } else window.commons.redirectPage(envDetails.urlPrefix + '/meeting_list');
  }

  function handleExternalTabClick(event) {
    event.preventDefault();
    event.stopPropagation();
    window.commons.redirectPage(envDetails.urlPrefix + '/external_requests');
  }

  function handleSessionTabClick(event) {
    event.preventDefault();
    event.stopPropagation();

    if (typeof jiffle !== 'undefined') {
      var search = window.location.search;
      var eventName = new RegExp('[\?&]eventName=([^&#]*)').exec(search);
      eventName = eventName ? eventName[1] : '';
      newPage = Api.ENDPOINTS.apex_jnsessions + "?eventName=" + eventName;
      window.commons.redirectPage(newPage);
    } else window.commons.redirectPage(envDetails.urlPrefix + '/session_list');
  }

  function handleConsecutiveTabClick(event) {
    event.preventDefault();
    event.stopPropagation();
    window.commons.redirectPage(envDetails.urlPrefix + Api.ENDPOINTS.consecutive_list_page);
  }

  function handleCheckinClick(event) {
    event.preventDefault();
    event.stopPropagation();
    var checkinUrl = meetingTypeHash[MeetingType].checkinUrl;
    window.commons.redirectPage(envDetails.urlPrefix + checkinUrl);
  }

  function setupListeners() {
    attachCommonUIListeneres();

    bulkActionBar.on('click', '#js-bulk-survey-mail', showSurveyPopup);
    exportBtn.on('click', exportMeetings);
    $(document).on('click', '#js-trigger-servey-mail', handleServeyMails);
    meetingListContainer.on('click', '.js-survey-icon', showSurveyPopup);
    selectActivityModal.on('click', '.js-enabled-meeting-types', selectMeetingActivity);

    internalCountTab.on('click', handleInternalTabClick);
    mobileInternalCountTab.on('click', handleInternalTabClick);
    externalCountTab.on('click', handleExternalTabClick);
    mobileExternalCountTab.on('click', handleExternalTabClick);
    sessionCountTab.on('click', handleSessionTabClick);
    consecutiveMeetingTab.on('click', handleConsecutiveTabClick);
    mobileConsecutiveCountTab.on('click', handleConsecutiveTabClick);
    mobileSessionCountTab.on('click', handleSessionTabClick);
    mobileTabCheckin.on('click', handleCheckinClick);

    $(meetingListContainer).on('change', 'input[name="meetingCard"]', cardSelectionHandler).on('click', '.meetingRevealCls', function (e) {
      e.preventDefault();
      e.stopPropagation();
      var briefingStr = '';
      var uuid = $(this).data('uuid');
      var meeting = Store.MeetingStore.getMeeting(uuid);
      var url = '';
      if (meeting.briefing_uuid) {
        briefingStr = '?briefing_uuid=' + meeting.briefing_uuid;
      }
      var editMeetingUrl = Api.ENDPOINTS.meeting_request_edit_path;
      var viewMeetingUrl = Api.ENDPOINTS.meeting_request_view_path;
      if (meeting.type === 'ConsecutiveMeeting') {
        editMeetingUrl = Api.ENDPOINTS.consecutive_meetings_edit_path;
        viewMeetingUrl = Api.ENDPOINTS.consecutive_meetings_view_path;
      }
      if (meeting.edit && meeting.status !== 'cancelled') {
        url = envDetails.urlPrefix + editMeetingUrl.replace('{uuid}', uuid) + briefingStr;
      } else {
        url = envDetails.urlPrefix + viewMeetingUrl.replace('{uuid}', uuid) + briefingStr;
      }

      if (typeof jiffle !== 'undefined') {
        var modeQ = '&mode=edit';
        var meetingQ = '&meeting=' + uuid;
        var query = window.location.search;

        var accidInUrl = new RegExp('[\?&]accid=([^&#]*)').exec(query);
        var opportunityIdInUrl = new RegExp('[\?&]oppid=([^&#]*)').exec(query);
        var leadIdsInUrl = new RegExp('[\?&]lead_ids=([^&#]*)').exec(query);
        var sourceInUrl = new RegExp('[\?&]source=([^&#]*)').exec(query);
        var showActivitiesInUrl = new RegExp('[\?&]showActivities=([^&#]*)').exec(query);

        if (accidInUrl) {
          query = query.replace(accidInUrl[0], '');
        }

        if (opportunityIdInUrl) {
          query = query.replace(opportunityIdInUrl[0], '');
        }

        if (leadIdsInUrl) {
          query = query.replace(leadIdsInUrl[0], '');
        }

        if (sourceInUrl) {
          query = query.replace(sourceInUrl[0], '');
        }

        if (showActivitiesInUrl) {
          query = query.replace(showActivitiesInUrl[0], '');
        }

        if (meeting.edit && meeting.status !== 'cancelled') {
          url = Api.ENDPOINTS.jn_book_meeting + query + meetingQ + modeQ;
        } else {
          modeQ = '&mode=view';
          url = Api.ENDPOINTS.jn_view_book_meeting + query + meetingQ + modeQ;
        }
      }
      window.commons.redirectPage(url);
    });

    $(meetingListContainer).on('click', bookMeetingBtn.selector, function (e) {
      e.stopPropagation();
      showMeetingActivities();
    });

    $(meetingListContainer).on('click', '.meeting-accept, .meeting-decline', postMeetingAction).on('click', '.meeting-approve', putMeetingAction).on('click', '.meeting-approve-all', approveAllMeetingsHandler).on('click', '.meeting-cancel-all', cancelAllMeetingsHandler).on('click', '.meeting-cancel', cancelMeeting);

    $('#ui-datepicker-div').on('click', function (e) {
      e.stopPropagation();
    });
  }
  function showMeetingActivities() {
    if (window.activties_attributes.length > 1) {
      var template = __webpack_require__(/*! Templates/meeting/meeting-type-list */ "./templates/meeting/meeting-type-list.hbs");

      meetingActivityContainer.html(template({
        meetingTypes: window.activties_attributes
      }));

      meetingActivityContainer.addClass('js-enabled-meeting-types');
      selectActivityModal.on('hidden.bs.modal', function () {
        meetingActivityContainer.removeClass('js-enabled-meeting-types');
      });

      selectActivityModal.modal({
        backdrop: false
      });
    } else if (window.activties_attributes.length == 1) {
      var bookMeetingPath = window.location.origin + envDetails.urlPrefix + activties_attributes[0]['redirect_url'];
      if (typeof jiffle !== 'undefined') {

        bookMeetingPath = window.location.origin + (activties_attributes[0]['meeting_type_master_name'] === TRACKS_AND_SESSIONS_MASTER_NAME ? Api.ENDPOINTS.jn_book_nomination : Api.ENDPOINTS.jn_book_meeting);
        bookMeetingPath += window.location.search ? window.location.search + '&source=' + activties_attributes[0]['source'] : '?source=' + activties_attributes[0]['source'];
      }
      window.commons.redirectPage(bookMeetingPath);
    } else {
      notificationModal.notificationModal({
        class: 'red',
        timeout: true,
        body: i18n.t('no_meeting_types'),
        title: i18n.t('info')
      });
    }
  }

  function selectMeetingActivity(e) {
    e.preventDefault();
    e.stopPropagation();

    var meetingTypeUuid = $(e.target).closest('.activity').attr('id');

    if (typeof meetingTypeUuid !== 'undefined') {
      selectActivityModal.modal('hide');

      var chosenActivity = $(e.target).closest('.activity');
      var bookMeetingPath = window.location.origin + envDetails.urlPrefix + chosenActivity.data('redirect-url');
      if (typeof jiffle !== 'undefined') {
        var meetingTypeUuid = chosenActivity.attr('id');

        var meetingTypeMaster = _.find(activties_attributes, function (activity) {
          if (activity.uuid === meetingTypeUuid) return true;
        }).meeting_type_master_name;

        bookMeetingPath = window.location.origin + (meetingTypeMaster === TRACKS_AND_SESSIONS_MASTER_NAME ? Api.ENDPOINTS.jn_book_nomination : Api.ENDPOINTS.jn_book_meeting);
        var updatedSearchParams = putSearchQueryParam(window.location.search, 'activity_uuid', meetingTypeUuid);
        updatedSearchParams = putSearchQueryParam(updatedSearchParams, 'source', $(e.target).closest('.activity').data('activity-source'));
        bookMeetingPath += updatedSearchParams;
      }
      window.commons.redirectPage(bookMeetingPath);
    }
  }

  function putMeetingAction(e, actionType) {
    e.stopPropagation();
    e.preventDefault();
    actionType = actionType || 'put';
    var url = $(this).data('url');
    Actions.meetingAction(url, actionType, 'approve');
  }

  function approveAllMeetingsHandler(e) {
    putMeetingAction.call(this, e, 'post');
  }

  function postMeetingAction(e) {
    e.stopPropagation();
    e.preventDefault();

    var url = $(this).data('url');
    Actions.meetingAction(url, 'post');
  }

  function fetchMoreMeetings() {
    if (Store.MeetingStore.getCurrentPage() <= Store.MeetingStore.getTotalPageCount()) {
      Actions.fetchMeetings(Store.MeetingStore.getCurrentPage());
    }
  };

  function handleFilterClick(e) {
    e.preventDefault();
    e.stopPropagation();

    applyFilter();

    // for mobile
    $('#meetig_view_nav.in').collapse('hide');

    filter.toggleClass('show');
  }

  function applyFilter() {
    globalSearch.val(filterSearchField.val());
    var clubbedFilterData = meetingFilterCmp.getClubbedFilterData(filterPanel);
    Actions.updateFilter(clubbedFilterData.formData, clubbedFilterData.storableFilterData);
    showSelectedFilter(clubbedFilterData.selectedFilterData);
  }

  function showSelectedFilter(data) {
    var html = __webpack_require__(/*! Templates/report/ondemand/selected_filter */ "./templates/report/ondemand/selected_filter.hbs")({ filter: data });
    appliedFiltersContainer.html(html);
  };

  function removeSelectedFilter(e) {
    var currentEl = $(this);
    var filterValue = '' + currentEl.closest('.selected-item').data('key');
    var filterKey = currentEl.closest('.filter').data('type');
    var selectedStoreFilter = Store.MeetingStore.filters[filterKey];
    var storedFilters = Store.MeetingStore.storedFilterData[filterKey];
    var selectedChosen = filterPanel.find('.select.' + filterKey);
    selectAllFlag = false;
    $('.select_all_meeting').html(i18n.t('select_all'));
    selectedStoreFilter.splice($.inArray(filterValue, selectedStoreFilter), 1);
    storedFilters.splice(_.findIndex(storedFilters, function (filter) {
      return filter.value === filterValue;
    }), 1);
    if (storedFilters.length == 0) {
      delete Store.MeetingStore.storedFilterData[filterKey];
    }
    selectedChosen.find('option:selected').each(function (i, element) {
      var El = $(element);
      if (El.val() == filterValue) {
        El.attr('selected', false);
      }
    }).trigger('change');

    currentEl.closest('.filter').remove();
    Actions.updateFilter(Store.MeetingStore.filters, Store.MeetingStore.storedFilterData);
  };

  function resetFilter(e) {
    e.stopPropagation();
    Actions.resetFilter();
    filterSearchField.val('');
    globalSearch.val('');
    showSelectedFilter({});
    filterPanel.find('select').each(function (i, ele) {
      $(ele).val([]).trigger('change');
    });
  };

  function cancelMeeting(e, actionType) {
    e.stopPropagation();
    e.preventDefault();
    actionType = actionType || 'put';
    var url = $(this).data('url');

    notificationModal.notificationModal({
      type: 'confirmation',
      title: i18n.t('cancel_meeting_title'),
      body: i18n.t('cancel_meeting_confirmation'),
      class: 'blue',
      done: function done() {
        Actions.meetingAction(url, actionType);
      }
    });
  };

  function cancelAllMeetingsHandler(e) {
    cancelMeeting.call(this, e, 'post');
  }

  function searchMeetings() {
    var searchValue = globalSearch.val();
    $('.select_all_meeting').html(i18n.t('select_all'));
    selectAllFlag = false;
    filterSearchField.val(searchValue);
    Actions.searchMeetings(searchValue);
  };

  function updateSearch() {
    var searchValue = filterSearchField.val();
    Actions.updateSearch(searchValue);
  };

  function exportMeetings(e) {
    e.preventDefault();
    e.stopPropagation();
    window.commons.redirectPage(Store.MeetingStore.generateExportUrl(exportBtn.data('review')));
  }

  function showSurveyPopup(e) {
    e.preventDefault();
    e.stopPropagation();
    var uuid, meeting;
    var isBulkSurvey = $(e.target).closest('.bulk-action').length;
    var template = __webpack_require__(/*! Templates/meeting/meeting-servey-item */ "./templates/meeting/meeting-servey-item.hbs");
    if (isBulkSurvey) {
      meeting = Store.MeetingStore.bulk_survey;
      uuid = '';
    } else {
      uuid = $(this).closest('.meeting-card').data('uuid');
      meeting = Store.MeetingStore.getMeeting(uuid);
      surveySelectedMeeting = meeting;
    }

    _.forEach(meeting.survey_links, function (link) {
      link['show_survey'] = _.contains(link.user_access, window.envDetails.role);
    });
    surveyModalEl.find('#meeting-servey-container').html(template({ surveys: meeting.survey_links }));
    surveyModalEl.find('#js-trigger-servey-mail')[meeting.show_send_mail || isBulkSurvey ? 'show' : 'hide']();
    surveyModalEl.modal('show').data('uuid', uuid);
  };

  function handleServeyMails(e) {
    var uuids = [];
    var modalEl = $(this).closest('.js-meeting-survey-modal');
    var meetingInfo = modalEl.data('uuid') ? modalEl.data('uuid') : selectedMeetingCardHash;

    modalEl.find('.js-meeting-servey-item').each(function (i, element) {
      var temp_uuid = $(element).data('uuid');
      if ($('#survey-' + temp_uuid).is(':checked')) {
        uuids.push($(element).data('uuid'));
      }
    });

    if (uuids.length > 0) {
      Actions.triggerServeyMails(meetingInfo, uuids, selectAllFlag);
    } else {
      showSurveyError();
    }
  }

  function showSurveyError() {
    notificationModal.notificationModal({
      class: 'yellow',
      title: i18n.t('required_survey'),
      body: i18n.t('survey_not_selected'),
      timeout: 4000
    });
  }

  function serveyMailsTriggered(data) {
    surveyModalEl.modal('hide');
    if (data.data.selectedMeetingList) {
      data.data.response.show_message ? showSurveyMessage(data, resetMeetingList) : resetMeetingList(data);
    } else {
      data.data.response.show_message ? showSurveyMessage(data, resetMeetingList) : updateSurveyDetails(data);
    }
  }

  function updateSurveyDetails(data) {
    var surveyUuidArray = data.data.response.survey_uuid;
    _.each(surveyUuidArray, function (survey) {
      var surveyDetails = _.find(surveySelectedMeeting.survey_links, { uuid: survey.uuid });
      surveyDetails && _.merge(surveyDetails, survey);
    });
  }

  function resetMeetingList(data) {
    clearSelectedMeetingHash(data.data.selectedMeetingList);
    reloadMeetingList();
  }

  function showSurveyMessage(data, callBack) {
    $('.notification-modal').notificationModal({
      class: 'blue',
      title: i18n.t('survey'),
      body: data.data.response.message,
      dismiss: function dismiss() {
        callBack(data);
      }
    });
  }

  return {
    init: init
  };
}();

module.exports = MeetingHandler;

/***/ }),

/***/ "./app/scripts/Meeting/store.js":
/*!**************************************!*\
  !*** ./app/scripts/Meeting/store.js ***!
  \**************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var MeetingActions = __webpack_require__(/*! ./actions */ "./app/scripts/Meeting/actions.js");
var Api = __webpack_require__(/*! common_api */ "./app/scripts/commons/jiffle/api.js");

var EventStore = Reflux.createStore({
  init: function init() {
    this.listenToMany(MeetingActions);
    this.eventDetails = {};
  },
  onFetchEventDetails: function onFetchEventDetails() {
    var promise = Api.fetch({
      url: Api.ENDPOINTS.event_details
    });

    promise.then(function (apiResponse) {
      this.eventDetails = apiResponse.data;
      this.trigger({ success: true, type: 'eventDetails' });
    }.bind(this));
  },
  isStaffSchedulingEvent: function isStaffSchedulingEvent() {
    return this.eventDetails.isStaffScheduling == true;
  },
  getFieldFromMeetingTypeForAgenda: function getFieldFromMeetingTypeForAgenda(field_name) {
    var meetingTypeForAgenda = _.find(this.eventDetails.activities_attributes, function (activity) {
      return activity.name === 'task';
    });
    return _.pick(meetingTypeForAgenda, field_name)[field_name];
  },
  getEventDetails: function getEventDetails() {
    return this.eventDetails;
  }
});

var MeetingStore = Reflux.createStore({

  init: function init() {
    this.listenToMany(MeetingActions);
    this.meetings = [];
    this.toggleStore = {
      'grid': { view: 'tile-view', tile: 'col-md-3 col-sm-4' },
      'list': { view: 'list-view', tile: 'col-md-12' }
    };
    this.filters = {};
    this.storedFilterData = {};
    this.current_page = 1;
    this.total_pages = 0;
    this.fetching = false;
    this.per_page_meeting_count = 10;
    this.totalMeetings = 0;
    var state;
    if (this.getLocalToggle() === 'list') {
      state = this.toggleStore['list'];
    } else {
      state = this.toggleStore['grid'];
    }
    this.toggleState = {
      viewStyle: state['view'],
      tileSize: state['tile']
    };
    this.bulk_survey = {};
    this.ApiList = {
      'generalMeetings': {
        meetings_list: Api.ENDPOINTS.meetings_list,
        list_key: 'meeting_requests',
        filter_param: {
          exclude_consecutive: true
        }
      },
      'consecutiveMeetings': {
        meetings_list: Api.ENDPOINTS.consecutive_meeting_list,
        list_key: 'consecutive_meetings',
        filter_param: {
          exclude_consecutive: false
        }
      }
    };
  },

  getAvailableSelectedMeetings: function getAvailableSelectedMeetings(selectedMeetingCardHash, prop) {
    var availableMeetings = [];
    if (typeof prop === 'undefined') {
      prop = 'uuid';
    }
    this.meetings.forEach(function (meeting) {
      if (selectedMeetingCardHash[meeting.uuid]) {
        availableMeetings.push(meeting[prop]);
      }
    });
    return availableMeetings;
  },

  onFetchOptions: function onFetchOptions(data, success, failure) {
    var promise = Api.fetch({
      data: data,
      url: Api.ENDPOINTS.get_meeting_options,
      prefix: envDetails.urlPrefix
    });
    promise.then(function (response) {
      success(response.data);
    });

    promise[promise.fail ? 'fail' : 'catch'](function (apiResponse) {}.bind(this));

    return promise;
  },

  onUpdateFilter: function onUpdateFilter(formData, storedFilterData) {
    this.updateFilterValues(formData, storedFilterData);
    this.onReFetchMeetings();
  },

  onReFetchMeetings: function onReFetchMeetings(fetchAllExistingCount) {
    var per_page;
    if (fetchAllExistingCount) {
      per_page = this.meetings.length;
    }
    this.setCurrentPage(1);
    this.resetMeetingList();
    this.onFetchMeetings(1, per_page);
  },

  setCurrentUserFlags: function setCurrentUserFlags() {
    this.isCurrentUserMM = envDetails.isMeetingManager();
    this.isCurrentUserCSM = envDetails.isCSM();
    this.isJuniorMM = envDetails.isJuniorMM();
    this.isActivityManager = envDetails.isActivityManager();
    this.isExecutiveAdmin = envDetails.isExecutiveAdmin();
  },

  getToggleState: function getToggleState() {
    return this.toggleState;
  },

  updateFilterValues: function updateFilterValues(filterData, storedFilterData) {
    var search = this.filters.search || '';
    this.filters = filterData;
    this.storedFilterData = storedFilterData || {};
    if (search) {
      this.filters.search = search;
      this.storedFilterData.search = search;
    }
  },

  fetchFirstPage: function fetchFirstPage() {
    this.setCurrentPage(1);
    this.resetMeetingList();
    this.onFetchMeetings(1);
  },

  onUploadAgendaItemCsv: function onUploadAgendaItemCsv(data) {
    var promise = Api.update({
      url: Api.ENDPOINTS.upload_agenda_item_csv,
      data: data,
      processData: false,
      contentType: false
    });

    promise.then(function (apiResponse) {
      var countMessage = apiResponse.message;
      if (apiResponse.success) {
        this.trigger({
          type: 'agendaItemUploadSuccess',
          countMessage: countMessage
        });
        this.fetchFirstPage();
      } else {
        this.trigger({
          type: 'agendaItemUploadFailure',
          errors: apiResponse.errors,
          countMessage: countMessage,
          download_link: apiResponse.download_link
        });
        this.fetchFirstPage();
      }
    }.bind(this));

    promise.fail(function (apiResponse) {
      apiResponse = _.isObject(apiResponse.responseJSON) ? apiResponse.responseJSON : apiResponse;
      this.trigger({
        type: 'agendaItemUploadFailure',
        countMessage: apiResponse.message,
        errors: apiResponse.errors
      });
    }.bind(this));
  },

  onGetFilters: function onGetFilters(preSelectedFilters) {

    if (event_home_page && event_home_page == 'true') {
      preSelectedFilters.event_home_page = true;
    }

    var promise = Api.fetch({
      url: Api.ENDPOINTS.meetings_list_filters + "?v=" + new Date().getTime(),
      data: _.merge({ include_checkin: "no", exclude_cancelled_meetings: "no" }, preSelectedFilters)
    });

    promise.then(function (apiResponse) {

      this.updateFilterValues(preSelectedFilters);
      this.trigger({
        type: 'meetingFilters',
        data: { filters: apiResponse.filters, appliedSearch: apiResponse.applied_search }
      });
    }.bind(this));

    promise[promise.fail ? 'fail' : 'catch'](function (apiResponse) {
      this.trigger({
        type: 'meetingFilters',
        data: { filters: [], appliedSearch: '' }
      });
    }.bind(this));
  },

  generateExportUrl: function generateExportUrl(review) {
    var prefix = envDetails['urlPrefix'] || '';
    var queryString, endpoint;
    if (review) {
      queryString = '?' + $.param({ filters: this.getAppliedFilters() });
      endpoint = Api.ENDPOINTS.export_review;
    } else {
      queryString = '?' + $.param(this.getAppliedFilters());
      endpoint = Api.ENDPOINTS.meeting_request_export;
    }
    return [prefix, endpoint, queryString].join('');
  },
  getSearchValue: function getSearchValue() {
    return this.filters.search;
  },

  getLocalToggle: function getLocalToggle() {
    var lastViewLoaded = commons.getItem('meeting-list');
    switch (lastViewLoaded) {
      case 'grid':
      case 'list':
        return lastViewLoaded;
      default:
        return 'grid';
    }
  },

  isFilterORSearchApplied: function isFilterORSearchApplied() {
    var filters = this.getAppliedFilters();
    for (var key in filters) {
      if (filters.hasOwnProperty(key) && filters[key].length != 0) {
        return true;
      }
    }
    return false;
  },

  onBulkApproveMeetings: function onBulkApproveMeetings(selectedMeetingCardHash, selectAllFlag) {
    var toBeApprovedMeetings = this.getAvailableSelectedMeetings(selectedMeetingCardHash);
    var promise = Api.update({
      url: Api.ENDPOINTS.bulk_approve_meetings,
      data: {
        filter: this.getFiltersForBulkOperations(),
        meeting_uuids: selectAllFlag ? [] : toBeApprovedMeetings
      }
    });

    promise.then(function (apiResponse) {
      this.trigger({
        type: 'onBulkApprovalSuccess',
        data: { toBeApprovedMeetings: toBeApprovedMeetings, approvedMeetingCount: apiResponse.data.approved || 0 }
      });
    }.bind(this));

    promise[promise.fail ? 'fail' : 'catch'](function (response) {
      this.trigger({
        type: 'onBulkApprovalFailure',
        data: response
      });
    }.bind(this));
  },

  onBulkReinviteUsers: function onBulkReinviteUsers(selectedMeetingCardHash, selectAllFlag) {
    var toBeReinvitedMeetings = this.getAvailableSelectedMeetings(selectedMeetingCardHash);
    var promise = Api.update({
      url: Api.ENDPOINTS.bulk_reinvite_users,
      data: {
        filter: this.getFiltersForBulkOperations(),
        meeting_uuids: selectAllFlag ? [] : toBeReinvitedMeetings
      }
    });
    promise.then(function (apiResponse) {
      this.trigger({
        type: 'onBulkReinviteUserSuccess'
      });
    }.bind(this));
  },

  onBulkCancel: function onBulkCancel(selectedMeetingCardHash, selectAllFlag) {
    var toBeCancelledMeetings = this.getAvailableSelectedMeetings(selectedMeetingCardHash);
    var promise = Api.update({
      url: Api.ENDPOINTS.bulk_cancel_meetings,
      data: {
        filter: this.getFiltersForBulkOperations(),
        meeting_uuids: selectAllFlag ? [] : toBeCancelledMeetings
      }
    });

    promise.then(function (apiResponse) {
      this.trigger({
        type: 'onBulkCancelSuccess',
        data: { toBeCancelledMeetings: toBeCancelledMeetings, cancelledMeetingCount: apiResponse.data.cancelled || 0 }
      });
    }.bind(this));

    promise[promise.fail ? 'fail' : 'catch'](function (apiResponse) {
      this.trigger({
        type: 'onBulkCancelFailure',
        data: apiResponse
      });
    }.bind(this));
  },

  getFiltersForBulkOperations: function getFiltersForBulkOperations() {
    var filters = this.getAppliedFilters();
    if (filters['internal_invitees'] || filters['external_invitees']) {
      var internalInvitees = filters['internal_invitees'] || [];
      var externalInvitees = filters['external_invitees'] || [];
      filters['invitees'] = internalInvitees.concat(externalInvitees);
    }
    return filters;
  },

  handleMeetingOperationsDisplay: function handleMeetingOperationsDisplay(meeting) {

    meeting.Accept = 'hide';
    meeting.Decline = 'hide';
    meeting.Approve = 'hide';
    meeting.Cancel = 'hide';
    meeting.approve_all = 'hide';
    meeting.cancel_all = 'hide';

    meeting.approved = 'hide';
    meeting.cancelled = 'hide';
    meeting.accepted = 'hide';
    meeting.declined = 'hide';
    if (meeting.actions) {
      meeting.actions.map(function (action) {
        meeting[action] = '';
      });
    }

    //this.isCurrentUserMM = false;

    if (this.isCurrentUserMM || this.isCurrentUserCSM || this.isJuniorMM || this.isActivityManager || this.isExecutiveAdmin) {

      meeting[meeting.status] = '';

      meeting.Accept = 'hide';
      meeting.Decline = 'hide';
    } else {
      meeting[meeting.invite_status] = '';

      meeting.Approve = 'hide';
      meeting.Cancel = 'hide';
    }
  },

  getStorableFilters: function getStorableFilters() {
    this.storedFilterData.search = this.filters.search;
    return this.storedFilterData;
  },

  onFetchMeetings: function onFetchMeetings(page_no, per_page) {

    if (this.getFetchState() == false) {
      var filters = this.getAppliedFilters();
      _.merge(filters, this.ApiList[MeetingType].filter_param);
      this.updateFetchState(true);
      filters['invitees'] = (filters['internal_invitees'] || []).concat(filters['external_invitees'] || []);
      var promise = Api.fetch({
        url: this.ApiList[MeetingType].meetings_list,
        data: {
          filters: filters,
          storable_filters: JSON.stringify(this.getStorableFilters()),
          page: page_no,
          per_page: per_page || this.per_page_meeting_count
        }
      });

      promise.then(function (apiResponse) {
        var currentUserUuid = envDetails.currentUser.uuid;
        this.trigger({
          type: 'addToSelectedMeetingCardHash',
          data: apiResponse.data[this.ApiList[MeetingType].list_key]
        });
        this.meetings = this.meetings.concat(apiResponse.data[this.ApiList[MeetingType].list_key]);
        this.meetings = _.uniq(this.meetings, 'uuid');
        this.bulk_survey = {
          show_survey: apiResponse.show_survey,
          survey_links: apiResponse.survey_links
        };

        var newlyModifiedId = Number(commons.getItem('eventId'));
        var newlyModifiedMeeting = [];
        for (var i = 0, ln = this.meetings.length; i < ln; i++) {

          var meeting = this.meetings[i];
          meeting.primary_sorting_column = new Date(meeting.created_at);

          this.handleMeetingOperationsDisplay(meeting);
          meeting.latest = false;

          if (newlyModifiedId === Number(meeting.id)) {
            newlyModifiedMeeting = this.meetings.splice(i, 1);
            ln--;
            i--;
          }
        }

        this.meetings = _.sortBy(this.meetings, function (meeting) {
          return meeting.primary_sorting_column;
        });

        if (newlyModifiedMeeting.length > 0) {
          this.meetings.unshift.apply(this.meetings, newlyModifiedMeeting);
        }

        commons.setItem('eventId');
        this.updateFetchState(false);
        this.setCurrentPage(this.getCurrentPage() + 1);
        this.updateTotalMeetingCount(apiResponse.data.total_entries);
        this.setTotalPageCount(Math.ceil(apiResponse.data.total_entries / this.per_page_meeting_count));
        this.trigger({
          type: 'meetinglisting',
          data: {
            meetings: this.meetings,
            toggleState: this.toggleState,
            total: apiResponse.data.total_entries,
            totalExternal: apiResponse.data.external_requests_count,
            totalSessions: apiResponse.data.sessions_count,
            totalConsecMeeting: apiResponse.data.consecutive_meetings_count,
            totalInternalMeeting: apiResponse.data.internal_meetings_count,
            totalRevieweeMeeting: apiResponse.data.reviewee_meetings_count
          }
        });
      }.bind(this));

      promise[promise.fail ? 'fail' : 'catch'](function (apiResponse) {
        this.updateFetchState(false);
      }.bind(this));
    }
  },

  updateTotalMeetingCount: function updateTotalMeetingCount(count) {
    this.totalMeetings = count;
  },

  getTotalMeetingCount: function getTotalMeetingCount() {
    return this.totalMeetings;
  },

  onToggleView: function onToggleView(selectedView) {
    if (selectedView !== 'checkin') {
      this.toggleState = {
        viewStyle: this.toggleStore[selectedView]['view'],
        tileSize: this.toggleStore[selectedView]['tile']
      };
    }
    this.trigger({ type: 'viewchanged', data: this.toggleState, selectedView: selectedView });
  },

  getFetchState: function getFetchState() {
    return this.fetching;
  },
  updateFetchState: function updateFetchState(state) {
    this.fetching = state;
  },
  getCurrentPage: function getCurrentPage() {
    return this.current_page;
  },
  resetMeetingList: function resetMeetingList() {
    this.meetings = [];
  },
  setCurrentPage: function setCurrentPage(page_no) {
    this.current_page = page_no;
  },
  getTotalPageCount: function getTotalPageCount() {
    return this.total_pages;
  },
  setTotalPageCount: function setTotalPageCount(count) {
    this.total_pages = count;
  },
  onSearchMeetings: function onSearchMeetings(search_val) {
    this.filters.search = search_val;
    this.setCurrentPage(1);
    this.resetMeetingList();
    this.onFetchMeetings(1);
  },
  onUpdateSearch: function onUpdateSearch(search_val) {
    this.filters.search = search_val;
  },
  onResetFilter: function onResetFilter() {
    this.filters = {};
    this.setCurrentPage(1);
    this.resetMeetingList();
    this.onFetchMeetings(1);
  },
  onApplyFilter: function onApplyFilter() {
    this.setCurrentPage(1);
    this.resetMeetingList();
    this.onFetchMeetings(1);
  },

  getAppliedFilters: function getAppliedFilters() {
    var filters = _.cloneDeep(this.filters);
    delete filters.page;
    delete filters.per_page;
    return filters;
  },

  getMeeting: function getMeeting(uuid) {
    var meeting = _.find(this.meetings, function (meeting) {
      return meeting.uuid == uuid;
    });
    return meeting;
  },

  onTriggerServeyMails: function onTriggerServeyMails(meetingInfo, surveyUUIDS, selectAllFlag) {
    var pathParam, meetingUUIDS, apiUrl, selectedMeetingList;
    if (typeof meetingInfo == 'string') {
      apiUrl = Api.ENDPOINTS.send_survey_meeting_mail.replace('{UUID}', meetingInfo);
      selectedMeetingList = '';
    } else {
      selectedMeetingList = this.getAvailableSelectedMeetings(meetingInfo);
      meetingUUIDS = selectAllFlag ? [] : selectedMeetingList;
      apiUrl = Api.ENDPOINTS.send_bulk_survey_meeting_mail;
    }
    var promise = Api.update({
      url: apiUrl,
      type: 'PUT',
      data: { survey_uuid: surveyUUIDS, meeting_uuids: meetingUUIDS, filter: this.getFiltersForBulkOperations() }
    });

    promise.then(function (apiResponse) {
      this.trigger({
        type: 'serveyMailsTriggered',
        data: { selectedMeetingList: selectedMeetingList, response: apiResponse }
      });
    }.bind(this));

    promise[promise.fail ? 'fail' : 'catch'](function (apiResponse) {}.bind(this));
  }
});

var MeetingActionStore = Reflux.createStore({
  init: function init() {
    this.listenToMany(MeetingActions);
  },
  onMeetingAction: function onMeetingAction(url, type, action) {
    if (!action) {
      action = "";
    }
    var promiseObj = {
      url: url
    };

    if (type == 'put') {
      promiseObj.type = 'PUT';
    }

    var promise = Api.update(promiseObj);

    promise.then(function (apiResponse) {
      this.trigger({ data: apiResponse.data, action: action });
    }.bind(this));

    promise[promise.fail ? 'fail' : 'catch'](function (apiResponse) {
      this.trigger({ errors: apiResponse.responseJSON.errors });
    }.bind(this));
  }
});

module.exports = {
  MeetingStore: MeetingStore,
  MeetingActionStore: MeetingActionStore,
  EventStore: EventStore
};

/***/ }),

/***/ "./app/scripts/commons/jiffle/api.js":
/*!*******************************************!*\
  !*** ./app/scripts/commons/jiffle/api.js ***!
  \*******************************************/
/*! no static exports found */
/***/ (function(module, exports) {

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

var _ENDPOINTS;

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

/* eslint-disable */

/* global i18n, $, _, FormData, envDetails */
// Note: Add the urls in sorted order
var Api = {
  ENDPOINTS: (_ENDPOINTS = {
    accept_meeting: '/meeting_request/{uuid}/accept_meeting',
    activate_event: '/event/activate',
    activate_room: '/room/{{uuid}}/active',
    activate_user: '/users/UUID/active',
    activity_details: '/activities/{uuid}',
    adapters: '/adapter_ui/integration_adapters',
    add_attendee_to_meeting: '/meetings/add_attendees',
    add_new_location: '/location/{event_uuid}',
    add_supported_api: '/adapter_ui/supported_apis/map_to_integration',
    alert_details_fetch: '/alerts/meeting_meta',
    alert_fetch: '/alerts',
    all_meeting_types: '/meeting_types/index',
    apex_jnlistagenda: '/apex/JNBriefings',
    apex_jnmeetings: '/apex/JNMeetings',
    api_map_or_add_user: { url: '/api/v1/users/book_meeting_create', errorConfig: { handler: 'detailedErrorHandler' } },
    api_register_user: { url: '/api/v1/users', errorConfig: { handler: 'detailedErrorHandler' } },
    api_update_user_event_settings: { url: '/api/v1/user/{{uuid}}/update_settings', errorConfig: { handler: 'detailedErrorHandler', custom_title: 'Cannot Update' } },
    api_update_user: { url: '/api/v1/users/{{uuid}}', errorConfig: { handler: 'detailedErrorHandler', custom_title: 'We’re Sorry!' } },
    appointment_filter_options: '/appointment_filter_options',
    approve_external_request: '/external_request/{uuid}/approve',
    approve_meeting: '/meeting_request/approve_meetings',
    approved_meeting_count: { url: '/approved_meeting_count', errorConfig: { handler: 'summuryErrorHandler' } },
    auto_reminder_setting: '/auto_reminder_setting',
    availability_fetch_ebc: '/configure/initial_availabilities',
    availability_fetch: '/meeting_type/availabilities',
    availability_update: '/configure/update_initial_availabilities',
    block_update: '/calendar/edit_block',
    briefing_centre_long_day: '/bcs/get_long_day',
    briefing_centre: '/bc',
    briefing_custom_forms: '/meeting_type/briefing_custom_forms',
    briefing_details: '/briefing/{briefing_uuid}',
    bulk_approve_mappings: '/appointments/approve',
    bulk_approve_meetings: '/meeting_request/approve_meetings',
    bulk_cancel_mappings: '/appointments/cancel',
    bulk_cancel_meetings: '/meeting_request/cancel_meetings',
    bulk_endorse_users: { url: '/api/v1/users/set_endorsed', errorConfig: { handler: 'detailedErrorHandler' } },
    bulk_reinvite_users: '/meeting_request/bulk_reinvite',
    bulk_set_mm_only_flag: '/api/v1/users/set_mm_only_flag',
    bulk_sync_ext_cal_flag: '/api/v1/users/update_cis_details',
    bulk_relax_sfdc_only_request_meeting: '/api/v1/users/set_relax_sfdc_only_request_meeting',
    bulk_show_as_external_attendee: { url: '/api/v1/users/set_show_as_ext', errorConfig: { handler: 'detailedErrorHandler' } },
    calendar_availability: '/meeting_request/calendar',
    calendar_user_availability: '/calendar/users',
    can_attend_session: '/can_attend_session',
    cancel_external_request: { url: '/external_request/{uuid}/cancel', errorConfig: { handler: 'detailedErrorHandler' } },
    cancel_meeting: '/meeting_request/{meeting_uuid}/cancel_meeting',
    check_attendee_availability: { url: '/api/v1/users/{uuid}/availability' },
    checkin_consecutive_meetings_list: '/checkin_consecutive_meetings',
    checkin_list_filters: '/checkin/meeting_filters',
    checkin_meetings_list: '/checkin_meetings',
    checkin_meetings: '/checkin_list',
    checkin_sessions_list: '/checkin_sessions',
    checkin_users: '/checkin/toggle_checkin',
    cis_service: '/cis_service',
    companies_list: '/companies/search',
    company_fetch: '/company',
    concierge_services_create: '/concierge_services',
    concierge_services_update: '/concierge_services/{uuid}',
    config_auto_remind: '/configure/auto_remind',
    config_history: { url: '/configuration/history_list', errorConfig: { handler: 'detailedErrorHandler' } },
    config_integration_update: '/configure/integration_update',
    config_integration: '/configure/integration',
    config_notification_update: '/configure/notification_update',
    config_notification: '/configure/notification',
    config_topic_update: '/config/update_topic',
    config_topic: '/configure/topic',
    consecutive_list_page: '/consecutive_meetings/list',
    consecutive_meeting_list: { url: '/consecutive_meetings', errorConfig: { handler: 'detailedErrorHandler' } },
    consecutive_meetings_details: { url: '/consecutive_meetings/{uuid}/edit_consecutive_meeting', errorConfig: { handler: 'detailedErrorHandler' } },
    consecutive_meetings_edit_path: '/consecutive_meetings/{uuid}/edit',
    consecutive_meetings_view_path: '/consecutive_meetings/{uuid}/view',
    copy_calendar_settings: '/configure/copy_calendar',
    copy_form_settings: '/configure/copy_form',
    copy_meeting_settings: '/configure/copy_settings',
    copy_notification_settings: '/configure/copy_notification_templates',
    create_consecutive_meetings: '/consecutive_meetings',
    create_external_request: '/external_request/create',
    create_group_nomination: '/group_nomination/create',
    create_integration_user: function create_integration_user(uuid) {
      return '/adapter_ui/integration/' + uuid + '/user';
    },
    integration_user: '/integrations/integration_user',
    create_mapping: '/container_mapping/{activity_uuid}/create',
    create_or_update_track: { url: '/tracks', errorConfig: { handler: 'detailedErrorHandler' } },
    create_self_nomination: { url: '/session/{{sessionUuid}}/create_self_nomination', errorConfig: { handler: 'detailedErrorHandler' } },
    create_session: '/session/create',
    create_tag_clouds: '/tag_cloud',
    custom_field_options: '/custom_form/{UUID}/search',
    custom_form_details: '/custom_form_details',
    customer_availability: '/calendar/companies',
    customer_calendar_export: '/calendar/briefings_center/export',
    custom_labels: { url: '/custom_labels_configurations', errorConfig: { handler: 'detailedErrorHandler' } },
    decline_meeting: '/meeting_request/{uuid}/decline_meeting',
    default_meeting_location_entities: '/event/set_default_meeting_location',
    delete_mapping: '/container_mapping/{{uuid}}/delete',
    delete_location_preference: { url: '/meeting_request/{{uuid}}/delete_loc_pref_proposal', errorConfig: { handler: 'detailedErrorHandler' } },
    demand_report_export: '/api/v1/meetings/ondemand',
    demand_reports: '/reports/demand_report',
    detailed_custom_labels: { url: '/detailed_custom_labels_configurations', errorConfig: { handler: 'detailedErrorHandler' } },
    disable_saved_report: '/user_template/disable/{{uuid}}',
    dismiss_alert: '/alerts/dismiss',
    dismiss_notification: '/notifications/dismiss',
    domain_validation: '/domains/validate',
    domains_valid: '/domains/valid',
    double_booked_resources: '/meeting_request/double_booked_resources',
    download_agenda_item_template_url: '/meeting_request/csv_template',
    user_topic_mapping_template_url: '/api/v1/users/user_topic_mapping/csv_template',
    edit_track: '/tracks/{uuid}/edit',
    enable_double_book_users: { url: '/api/v1/users/enable_double_booking', errorConfig: { handler: 'detailedErrorHandler' } },
    event_access_settings: '/event/roles_event_visibility',
    event_config_export: '/configuration/export',
    event_config_for_user_calendar: '/user_calendar/configurations',
    event_config_import: { url: '/configuration/import', errorConfig: { handler: 'detailedErrorHandler' } },
    event_config: '/event/configurations',
    event_configurations: '/event/{event_uuid}/configurations',
    event_details: '/event_info',
    event_ebc_configurations: '/event/ebc_configurations',
    event_home: 'event/home',
    event_new: '/event/new',
    event_room_cal_path: 'calendar',
    event_user_cal_path: 'user_calendar',
    event_user_filters: '/users/filter_options',
    events_info: '/events',
    events: '/events',
    expert_users: '/mapping/experts',
    export_meeting_checkin: '/reports/meetings_checkin/export.xlsx',
    export_review: '/reviewable/export.csv',
    export_summary_report: '/guided_tour/surveys',
    export_surveys: '/survey/{UUID}/export_surveys',
    ext_enabled_fetch_form_settings: '/external_widget_activities',
    external_attendees: '/users/external',
    external_meetings_list_filters: '/external_requests/filters',
    external_request_dates: '/event_dates',
    external_request_export: '/external_requests/export',
    external_requests: '/external_requests',
    external_widget_sessions: '/external_request/nomination/sessions',
    external_widget_signup_session: '/session/{uuid}/create_external_self_nomination',
    external_widget_topics: '/external_widget/tracks/{uuid}/topics',
    external_widget_tracks: '/external_widget/tracks',
    facilities_list: '/facilities',
    feature_enable_ebc: '/feature_toggle/enable_ebc',
    fetch_active_events: '/active_events',
    fetch_activities: '/user_meeting_types/list',
    fetch_activity_list: '/activities',
    fetch_activity_manager: { url: '/user_settings/{{uuid}}/activity', errorConfig: { handler: 'detailedErrorHandler' } },
    fetch_activity_settings: '/configure/activity_settings',
    fetch_analytics_configs: '/analytics_dashboard/config',
    fetch_archived_event_meeting_analytics: '/archived_events/analytics',
    fetch_archived_events_list: '/event_list_by_type/archived',
    fetch_archived_reports: '/archived_events/all_reports',
    fetch_available_meeting_types: '/fetch_available_meeting_types',
    fetch_booking_analytics: '/analytics/booking',
    fetch_briefing_workflow: '/configure/briefing_settings',
    fetch_calendar_settings: '/configure/calendar_settings',
    fetch_changable_meeting_types: '/fetch_transfer_meeting_types/{meeting_uuid}',
    fetch_concierge_form: '/concierge_services/custom_forms',
    fetch_concierge_notification_settings: '/concierge_services/notification_settings',
    fetch_concierge_services: '/concierge_services',
    fetch_consecutive_meeting_form_settings: '/configure/consecutive_meeting/form_settings',
    fetch_consecutive_meeting_notification_settings: '/configure/consecutive_meeting/notification_settings',
    fetch_customer_info_values: '/importable_entity_info',
    fetch_customers_analytics: '/analytics/customers',
    fetch_ebc_form: '/briefing_custom_form/get_fields',
    fetch_existing_meetings: '/badge_scan_meetings',
    fetch_external_meeting_request: '/external_requests/list',
    fetch_external_user_form_fields: '/fetch_sfdc_contacts_fields',
    fetch_form_settings: '/configure/form_settings',
    fetch_form: '/custom_form/get_fields',
    fetch_guided_tour_integration_fields: '/guided_tour/integration_fields',
    fetch_integration_block_fields: '/integration_block_fields',
    fetch_integration_meeting_fields: '/integration_meeting_fields',
    fetch_integration_survey_fields: '/integration_survey_fields',
    fetch_invitees_analytics: '/analytics/invitees',
    fetch_location_configs: '/configure/location',
    fetch_mapped_meeting_type_for_role: { url: '/users/roles_activities', errorConfig: { handler: 'detailedErrorHandler' } },
    fetch_mapping_details: '/mappings_details',
    fetch_mapping_filters: '/appointment_filters',
    fetch_mapping_rule_types: '/adapter_ui/fetch_integration_rules',
    fetch_mappings: '/mapping_module_count',
    fetch_master_supported_apis: '/adapter_ui/supported_apis',
    fetch_meeting_attendee: '/users/copy_attendees',
    fetch_meeting_count: '/activity_module_count',
    fetch_meeting_data_for_reports: '/users/meetings',
    fetch_meeting_details: '/activity_details',
    fetch_meeting_filters: '/reports/meeting_filters',
    fetch_meeting_list_copy_attendee: '/importable_entity_info/meeting_info_attendee',
    fetch_meeting_list_customer_info: '/importable_entity_info/customer_info_form',
    fetch_meeting_reports_header: '/headers',
    fetch_meeting_reports: '/api/v1/meetings/ondemand',
    fetch_meeting_type_analytics: { url: '/analytics/meetings_by_type', errorConfig: { handler: 'detailedErrorHandler' } },
    fetch_meeting_type_durations: '/calendar/available_meeting_types',
    fetch_meeting_types: '/meeting_types/list',
    fetch_meetings_analytics: '/analytics/meetings',
    fetch_minimum_timeslot: '/setting/minimum_timeslot',
    fetch_nomination_detail: '/nomination/{UUID}/{action}.json',
    fetch_notification_settings: '/configure/notification_settings',
    fetch_portal_custom_form: '/forms',
    fetch_preview_mapping_detail: '/container/{UUID}/details.json',
    fetch_preview_meeting_detail: '/meeting_request/{UUID}/{action}.json',
    fetch_remote_entities: '/fetch_remote_entities',
    fetch_requestor_email: '/fetch_requestor_email',
    fetch_roles_analytics: '/analytics/roles',
    fetch_rooms_analytics: '/analytics/rooms',
    fetch_scanned_users: '/fetch_scanned_users',
    fetch_scanners_name: '/scanners',
    fetch_standard_report: '/reports/standard_report',
    fetch_survey_template: '/configure/consolidated_survey_mail_settings',
    fetch_surveys: '/surveys',
    fetch_tag_configs: '/configure/tag',
    fetch_tag_entity: '/tags/{{uuid}}/{{entity}}',
    fetch_topics: '/topics',
    fetch_track_topics: '/tracks/{{uuid}}/topics',
    fetch_track_activities: '/tracks/{{uuid}}/activities',
    fetch_transferable_meeting_types: '/configure/change_meeting_type_links',
    fetch_unmapped_topic_entity: '/get_meetings_with_unmapped_topic_entity',
    fetch_update_briefing_notification_settings: '/configure/briefing_notification_settings',
    fetch_user_details: '/users/{{uuid}}',
    fetch_user_field_mappings: '/adapter_ui/fetch_integration_configs',
    fetch_user_form_rules: '/user_form_fields',
    fetch_user_notification: '/teddy/notifications/settings',
    fetch_user_topics: '/user_topics',
    fetch_valid_mapping_Times: '/mappings_valid_start_times',
    fetch_conference_list: '/hangout/conferences/enabled_conferences',
    fetch_conference_link: '/hangout/conferences/conference_link',
    fetch_resource_data: { url: '/api/v1/resource_data/fetch', errorConfig: { handler: 'detailedErrorHandler' } },
    fetch_user_custom_field_mapping: '/forms/user/ext_req_config',
    file_upload_url: '/attachment/{type}',
    fill_bulk_consent: { url: '/api/v1/users/set_consent_details', errorConfig: { handler: 'detailedErrorHandler' } },
    get_announcements: '/setting/announcement',
    get_booth_tour_details: '/booth_tour/list',
    get_briefing_filters: '/bc/{BCUUID}/briefing/filters',
    get_briefing_report_options: '/bc/{BCUUID}/briefing/filter_options',
    get_checkin_options: '/checkin_filters/filter_options',
    google_city_search: '/google_client/geo_places',
    google_time_zone_search: '/google_client/geo_timezone',
    set_user_sec_time_zone: '/set_user_timezone',
    get_ebc_role_privileges: '/all_ebc_privileges',
    get_self_serve_privileges: '/self_serve_privileges',
    get_ext_meeting_options: '/external_requests/filter_options',
    get_external_req_details: '/external_request/{uuid}/meeting_info',
    get_external_request: '/external_request/{uuid}/view',
    get_meeting_options: '/meeting_filters/filter_options',
    get_mm_list: '/users/managers',
    get_ondemand_users_list: '/users/ondemand_users',
    get_report_options: '/reports_filters/filter_options',
    get_reviews: '/reviewable/reviews',
    get_swappable_room_list: '/swap_room/list',
    get_tag_clouds: '/tag_cloud',
    get_topics: '/get_topics',
    get_user_preferences: '/users/{uuid}/user_preference',
    group_nomination_edit: '/nomination/{{uuid}}/edit',
    group_nomination_view: '/nomination/{{uuid}}/view',
    inactivate_rooms: '/rooms/inactive',
    inactivate_users: '/api/v1/users/inactive',
    integration_configurations_details: '/adapter_ui/integration_configurations',
    integration_configurations_schema: '/adapter_ui/integration_configurations_schema',
    integration_external_user_info: '/integration_external_user/{user_ref_id}',
    integration_field_mappings: '/integration/field_mappings',
    integration: '/adapter_ui/integrations',
    internal_attendees: '/users/internal',
    jn_book_meeting: '/apex/JNBookMeeting',
    jn_view_book_meeting: '/apex/JNViewMeeting',
    list_briefings_agenda: '/briefing/list_briefings{QUERY_PARAMS}#/list_agenda',
    list_tracks: '/tracks/list',
    mail_template_type_entities_get: '/mail_action/get_associated_entities',
    mail_template_type_get: '/mail_actions',
    manage_external_users: '/manage_external_users',
    manage_users: '/manageusers',
    manual_reminder_user: '/manual_reminders_users',
    mappable_grouping_users: '/reports/all_users',
    mappable_requestors: '/fetch_requestors',
    mappable_users: '/common_utils/fetch_mappable_users',
    mapped_events: '/mappable_events',
    mapping_list: '/container_mapping/list',
    mapping_page: '/mapping_list',
    mapping_valid_durations: '/mappings_valid_durations',
    mappings_export: '/exporter/appointment',
    meeting_availability: '/meeting_request/calendar',
    meeting_create: '/meeting_request/create',
    meeting_drag: '/calendar/relocate',
    meeting_fetch: '/meeting_request/{{uuid}}/show',
    meeting_get_config: '/configure/{:uuid}/meeting_type',
    meeting_get_settings: '/setting/activity',
    meeting_history: '/meeting_request/{uuid}/history',
    meeting_host_count: '/get_meetings_with_meeting_host',
    meeting_list: '/meeting_list',
    meeting_notifications: '/meeting_notifications',
    meeting_request_edit_path: '/meeting_request/{uuid}/edit',
    meeting_request_export: '/meeting_request/export',
    meeting_request_path: '/meeting_request/new',
    meeting_request_view_path: '/meeting_request/{uuid}/view',
    meeting_set_config: '/configure/{:uuid}/meeting_type_update',
    meeting_set_setting: '/setting/activity_update',
    meeting_type_create: '/meeting_type/create',
    meeting_type_update: '/meeting_type/{uuid}/update',
    meeting_types_of_consecutive_sub_meetings: '/consecutive_meetings/meeting_types',
    meeting_types: '/meeting_types',
    meetings_list_filters: '/meeting_request/meeting_filters',
    meetings_list: '/meeting_requests',
    miscellaneous_report_export: '/reports/miscellaneous/{type}',
    non_event_configurations: '/calendar/configurations',
    notification_fetch: '/notifications',
    on_behalf_actions: '/meeting_request/on_behalf_actions',
    portal: '/portal',
    print_user_badge: '/print_badge',
    register_user: { url: '/api/v1/register/user', errorConfig: { handler: 'detailedErrorHandler' } },
    reinvite_attendee_to_meeting: '/meeting_request/reinvite',
    reinvite_users: { url: '/api/v1/users/reinvite', errorConfig: { handler: 'summuryErrorHandler' } },
    reject_external_request: '/external_request/{uuid}/reject',
    reject_location_preference: { url: '/meeting_request/{{uuid}}/reject_loc_pref_proposal', errorConfig: { handler: 'detailedErrorHandler' } },
    reminder_notif_settings: '/reminders/all/templates',
    remove_from_event: '/users/UUID/inactive',
    remove_uploaded_file_url: '/attachment/{uuid}',
    remove_user_from_event: '/trigger/unmap',
    reorder_meeting_types: '/meeting_type/update_order',
    reports: {
      unified_report_filters: '/reports/unified_report_filters',
      user_list: '/reports/users_list',
      unified_report: '/reports/unified_report.{{format}}',
      fetch_report_template: '/report_templates',
      upload_report_template: '/report_templates/{template_type}/upload',
      update_report_template: '/report_templates/{template_type}/update'
    },
    report_survey_activity_list: '/survey/activity_list',
    reschedule_meeting: '/meeting_request/reschedule',
    partial_meeting_update: '/meeting_request/partial_update',
    reviewer_meeting_filter_options: '/reviewable/meeting_filters/filter_options',
    reviewer_meeting_filters: '/reviewable/meeting_filters',
    reviewer_meetings: '/reviewable/meeting_requests',
    role_create: '/role/create',
    role_disable: '/role/{:uuid}/disable',
    role_enable: '/role/{:uuid}/enable',
    role_get_all_privileges: '/all_privileges',
    role_get_privileges: '/role/{:uuid}/get_privileges',
    role_set_privileges: '/role/{:uuid}/set_privileges',
    role_update: '/role/update',
    roles_fetch: '/roles',
    room_activities: '/activities_rooms',
    room_availability: '/calendar/rooms',
    room_calendar_export: '/calendar/rooms/export',
    room_create: '/room/create',
    room_filters: '/room/filter_options',
    room_make_available: '/calendar/make_available',
    room_make_unavailable: '/calendar/make_unavailable',
    room_unblock: '/calendar/unblock',
    room_update: '/room/update',
    rooms_export: '/exporter/room',
    rooms_list: '/rooms/list',
    save_form: '/custom_form/update',
    save_portal_custom_form: '/form/update',
    save_printer_name: '/save_printer_name',
    save_profile_preferences: '/user_form_fields/update',
    save_user_field_mappings: '/create_or_update_integration_configuration',
    saved_report_details: '/user_template/details',
    send_bulk_survey_meeting_mail: '/meeting_request/send_survey_mail/bulk_action',
    send_requestor_email: { url: '/meeting_request/send_email_to_requestor', errorConfig: { handler: 'detailedErrorHandler' } },
    send_survey_meeting_mail: '/meeting_request/{UUID}/send_survey_mail',
    session_checkin_list: '/session_checkin_list',
    session_export: '/session/export',
    session_list: '/session_list',
    session_nominations: '/group_nominations',
    sessions_list: '/sessions',
    set_announcements: '/setting/announcement_update',
    set_participation_mascal: '/meeting_request/set_participation',
    set_participation: { url: '/meeting_request/set_participation', errorConfig: { handler: 'detailedErrorHandler' } },
    set_reminder: '/set_reminder',
    set_user_cis_status: '/set_user_cis_status/{{id}}',
    set_user_preferences: '/users/{uuid}/user_preference',
    sfdc_custom_labels: { url: '/sfdc_custom_labels_configurations', errorConfig: { handler: 'detailedErrorHandler' } },
    show_in_meeting_external_attendee: { url: '/configure/show_in_meeting_external_attendee', errorConfig: { handler: 'detailedErrorHandler' } },
    single_master_calendar_entity_search: 'master_calendar/{entityType}_search',
    standard_report_export_url: '/users/meetings.pdf?user_uuid={{uuid}}',
    standard_report_generate_url: '/api/v1/standard_report/generate.pdf?user_uuid={{uuid}}',
    survey_create: '/survey_masters',
    survey_responses: 'survey_responses',
    survey_update: '/survey_masters/{uuid}',
    swap_room_submit: '/swap_room/swap',
    system_configurations: '/configurations/system_configuration',
    standard_report_export_by_meeting: '/api/v1/meetings/standard_report.pdf',
    time_zone_url: '/time_zone',
    timeline_data: '/calendar/timeline_data',
    tag_create_or_update: '/tags',
    tag_edit: '/tags/{{uuid}}/edit',
    tag_list: '/tags',
    tag_listing_page: '/tag/listing',
    template_upload_url: 'report_templates/{template_type}/upload'
  }, _defineProperty(_ENDPOINTS, 'time_zone_url', '/time_zone'), _defineProperty(_ENDPOINTS, 'timeline_data', '/calendar/timeline_data'), _defineProperty(_ENDPOINTS, 'topic_upload', '/topics/import'), _defineProperty(_ENDPOINTS, 'topic_configurations', { url: '/topic_configurations', errorConfig: { handler: 'summuryErrorHandler' } }), _defineProperty(_ENDPOINTS, 'track_activities', '/get_track_activities'), _defineProperty(_ENDPOINTS, 'tracks_list', '/tracks'), _defineProperty(_ENDPOINTS, 'trigger_sync', '/trigger_sync'), _defineProperty(_ENDPOINTS, 'trigger_welcome_email_users', { url: '/api/v1/users/send_welcome_email', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'ui_get_settings', '/setting/ui'), _defineProperty(_ENDPOINTS, 'ui_set_setting', '/setting/ui_update'), _defineProperty(_ENDPOINTS, 'update_activity_settings', '/configure/activity_setting'), _defineProperty(_ENDPOINTS, 'update_analytics_configs', { url: '/analytics_dashboard/update_config', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'update_briefing_workflow', '/configure/briefing_settings'), _defineProperty(_ENDPOINTS, 'update_calendar_settings', '/configure/calendar_settings/{{uuid}}/update'), _defineProperty(_ENDPOINTS, 'update_checkin_status', '/checkin/toggle_checkin'), _defineProperty(_ENDPOINTS, 'update_company_form', '/company/update_company_configs'), _defineProperty(_ENDPOINTS, 'update_concierge_form', '/concierge_services/{{uuid}}/update_custom_form'), _defineProperty(_ENDPOINTS, 'update_concierge_notification_settings', '/concierge_services/{{uuid}}/update_notification_settings'), _defineProperty(_ENDPOINTS, 'update_config_change_meeting_type', '/configure/change_meeting_type'), _defineProperty(_ENDPOINTS, 'update_config', { url: '/config/update_config/{{config_type}}', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'update_configuration', { url: '/update_configuration', errorConfig: { handler: 'summuryErrorHandler' } }), _defineProperty(_ENDPOINTS, 'update_custom_reports', '/user_template/update'), _defineProperty(_ENDPOINTS, 'update_double_booking_config', { url: '/configure/double_booking', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'update_endorsement_config', { url: '/configure/endorsement', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'update_event_access', { url: '/api/v1/update_event_access', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'update_event_visibility', '/role/{{uuid}}/event_visibility'), _defineProperty(_ENDPOINTS, 'update_external_meeting', '/config/external_meeting'), _defineProperty(_ENDPOINTS, 'update_external_request_form', '/update_external_widget'), _defineProperty(_ENDPOINTS, 'update_custom_form', '/update_custom_form'), _defineProperty(_ENDPOINTS, 'update_form_settings', '/configure/form_settings/{{uuid}}/update'), _defineProperty(_ENDPOINTS, 'update_location_configs', '/config/update_location'), _defineProperty(_ENDPOINTS, 'update_mail_template', '/mail_template/update'), _defineProperty(_ENDPOINTS, 'update_manual_scheduling', '/config/manual_scheduling'), _defineProperty(_ENDPOINTS, 'update_mapping_module_config', '/meeting_type/{activity_uuid}/mapping_module_configs'), _defineProperty(_ENDPOINTS, 'update_mapping_module', { url: '/configure/mapping_module', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'update_virtual_event', { url: '/event/enable_virtual', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'trigger_virtual_event_email', { url: '/event/trigger_mail_virtual_event', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'update_minimum_timeslot', '/setting/minimum_timeslot_update'), _defineProperty(_ENDPOINTS, 'update_notification_settings', '/configure/notification_setting'), _defineProperty(_ENDPOINTS, 'update_review', '/reviewable/review'), _defineProperty(_ENDPOINTS, 'update_survey_form', '/survey_response/{uuid}'), _defineProperty(_ENDPOINTS, 'update_survey_template', '/configure/consolidated_survey_mail_setting'), _defineProperty(_ENDPOINTS, 'update_tag_configs', '/config/update_tag'), _defineProperty(_ENDPOINTS, 'update_track_config', { url: '/configure/tracks', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'update_track_label', { url: '/configure/track_label', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'update_transferable_meeting_types', { url: '/configure/change_meeting_type_links', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'update_user_notif_settings', '/user_setting/notification_setting'), _defineProperty(_ENDPOINTS, 'update_user_notification', '/teddy/notifications/settings'), _defineProperty(_ENDPOINTS, 'update_user_profile', '/user/{{uuid}}'), _defineProperty(_ENDPOINTS, 'update_user_registration', '/company/update_user_register_configs'), _defineProperty(_ENDPOINTS, 'upload_agenda_item_csv', '/meeting_request/import'), _defineProperty(_ENDPOINTS, 'upload_mapping_csv', '/special_appointment/import'), _defineProperty(_ENDPOINTS, 'upload_room_csv', '/room/import'), _defineProperty(_ENDPOINTS, 'upload_user_topic_csv', { url: '/api/v1/users/import_user_topic_mapping', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'upload_ea_attendee_mapping_csv', { url: '/user/bulk_import_ea_attendee_mapping', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'upload_user_csv', { url: '/common_utils/users/import', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'user_block', '/calendar/block'), _defineProperty(_ENDPOINTS, 'user_calendar_export', '/calendar/users/export'), _defineProperty(_ENDPOINTS, 'user_create', '/user/create'), _defineProperty(_ENDPOINTS, 'user_csv_template', '/portal/user/csv_template'), _defineProperty(_ENDPOINTS, 'ea_attendee_mapping', '/user/ea_attendee_csv_template'), _defineProperty(_ENDPOINTS, 'user_export', '/api/v1/users/export'), _defineProperty(_ENDPOINTS, 'ea_attendee_mapping_export', '/user/ea_attendee_mapping_export'), _defineProperty(_ENDPOINTS, 'user_filters', { url: '/common_utils/users/filters', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'user_history', { url: '/user/{uuid}/history', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'user_make_available', '/calendar/make_available'), _defineProperty(_ENDPOINTS, 'user_make_unavailable', '/calendar/make_unavailable'), _defineProperty(_ENDPOINTS, 'user_notif_settings', '/user_setting/notification_settings'), _defineProperty(_ENDPOINTS, 'user_unblock', '/calendar/unblock'), _defineProperty(_ENDPOINTS, 'user_update', '/users/{{uuid}}/update'), _defineProperty(_ENDPOINTS, 'users_events_filters', '/users_events_filters'), _defineProperty(_ENDPOINTS, 'users_events', '/users_events'), _defineProperty(_ENDPOINTS, 'users', { url: '/common_utils/users/list', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'validate_room_capacity', '/room/validate'), _defineProperty(_ENDPOINTS, 'compliance_configuration', { url: '/compliance/configurations', errorConfig: { handler: 'detailedErrorHandler' } }), _defineProperty(_ENDPOINTS, 'fetch_account', '/api/v1/accounts'), _defineProperty(_ENDPOINTS, 'fetch_opportunity', '/api/v1/opportunities'), _defineProperty(_ENDPOINTS, 'supported_api_detail', '/adapter_ui/supported_api_details'), _defineProperty(_ENDPOINTS, 'jn_integration_fields', '/adapter_ui/mappings'), _defineProperty(_ENDPOINTS, 'save_auth_form', '/adapter_ui/integrations/save_auth_fields'), _defineProperty(_ENDPOINTS, 'update_int_config', function update_int_config(uuid) {
    return '/adapter_ui/integration/' + uuid + '/status';
  }), _defineProperty(_ENDPOINTS, 'room_block', '/api/v1/room/interim_block'), _defineProperty(_ENDPOINTS, 'pendo_nps_consent', '/dashboard/pendo_nps'), _defineProperty(_ENDPOINTS, 'get_gdpr_message', '/configuration/privacy_messages'), _defineProperty(_ENDPOINTS, 'fetch_registered_integration', '/adapter_ui/enabled_badge_scans'), _defineProperty(_ENDPOINTS, 'fetch_integration_available_fileds', '/adapter_ui/supported_api_details/parse_schema'), _defineProperty(_ENDPOINTS, 'fetch_available_conferences', '/hangout/conferences'), _defineProperty(_ENDPOINTS, 'create_conference', '/hangout/conferences/'), _ENDPOINTS),

  API_cache: {},

  summuryErrorHandler: function summuryErrorHandler(url, response, errorConfigs) {
    var errorJson = response.responseJSON;
    var modelEl = $('.notification-modal');
    modelEl.notificationModal({
      type: 'notification',
      title: errorConfigs.custom_title || i18n.t('failure'),
      body: errorConfigs.custom_message || errorJson.message,
      class: 'red'
    });
  },

  detailedErrorHandler: function detailedErrorHandler(url, response, errorConfigs) {
    var errorJson = response.responseJSON;
    var errorMsg;
    try {
      errorMsg = _.flatten(_.values(errorJson.errors.details)).join('</br>');
    } catch (err) {
      errorMsg = '';
    }
    var modelEl = $('.notification-modal');
    modelEl.notificationModal({
      type: 'notification',
      title: errorConfigs.custom_title || i18n.t('failure'),
      body: errorConfigs.custom_message || errorMsg,
      class: 'red'
    });
  },

  replaceUrlParams: function replaceUrlParams() {
    var urlEndpoint = _.cloneDeep(arguments[0]);
    if ((typeof urlEndpoint === 'undefined' ? 'undefined' : _typeof(urlEndpoint)) !== 'object') {
      urlEndpoint = { url: urlEndpoint };
    }
    for (var i = 1; i < arguments.length; i++) {
      urlEndpoint.url = urlEndpoint.url.replace(arguments[i][0], arguments[i][1]);
    }
    return urlEndpoint;
  },

  update: function update(options) {
    var _this = this;

    if (options.data && options.data.constructor === FormData) {
      options.data.append('current_location_uuid', envDetails.current_location_uuid);
    } else {
      _.merge(options, { data: { current_location_uuid: envDetails.current_location_uuid } });
    }

    if (_typeof(options.url) === 'object') {
      var errorHandlerConfigs = {};
      var errorHandlerFn;
      if (_typeof(options.url.errorConfig) === 'object') {
        errorHandlerFn = this[options.url.errorConfig.handler];
        errorHandlerConfigs = options.url.errorConfig;
      } else {
        errorHandlerFn = this[options.url.errorConfig];
      }
      options.url = options.url.url;
    }

    options = _.assign({
      dataType: 'json',
      type: options.method || 'post',
      url: '/events',
      errorHandlerFn: errorHandlerFn,
      errorHandlerConfigs: errorHandlerConfigs,
      data: { event: null },
      prefix: envDetails['urlPrefix']
    }, options);

    if (options.req_stringify) {
      options.data = JSON.stringify(options.data);
    }

    if (!/^https?/.test(options['url'])) {
      options['url'] = options['prefix'] + options['url'];
    }
    // TODO: Need a fix here to consider showing loader section loader and handling abort with only one argument check.
    options.sectionLoader && this.setPageLoader(options);
    var promise = $.ajax(options);
    if (options.abortSequentialCalls) {
      this.addRemoveCache(options['url'], promise);
      promise.then(function () {
        _this.UiActionsOnUpdate(options);
      });
    }
    return promise;
  },

  fetch: function fetch(options) {
    if (_typeof(options.url) === 'object') {
      var errorHandlerConfigs = {};
      var errorHandlerFn;
      if (_typeof(options.url.errorConfig) === 'object') {
        errorHandlerFn = this[options.url.errorConfig.handler];
      } else {
        errorHandlerFn = this[options.url.errorConfig];
      }
      options.url = options.url.url;
    }

    options = _.assign({
      dataType: 'json',
      type: 'get',
      url: '/events',
      errorHandlerFn: errorHandlerFn,
      errorHandlerConfigs: errorHandlerConfigs,
      trimSearch: true,
      prefix: envDetails['urlPrefix'] || ''
    }, _.merge(options, { data: { current_location_uuid: envDetails.current_location_uuid } }));

    // by default trim whitespaces from beginning and end of search string

    if (options.data && typeof options.data.search === 'string' && options.trimSearch) {
      options.data.search = options.data.search.trimSpacesForSearch();
    }

    if (!/^https?/.test(options['url'])) {
      options['url'] = options['prefix'] + options['url'];
    }
    var promise = $.ajax(options);
    return promise;
  },

  addRemoveCache: function addRemoveCache(url, promise) {
    if (this.API_cache[url] && this.API_cache[url].state() != 'resolved') {
      this.API_cache[url].abort();
    }
    delete this.API_cache[url];
    this.API_cache[url] = promise;
  },

  setPageLoader: function setPageLoader(_ref) {
    var url = _ref.url,
        sectionLoader = _ref.sectionLoader,
        btnsToDisable = _ref.btnsToDisable;

    envDetails.startPageLoader = false;
    if (!this.API_cache[url]) {
      this.toggleSectionLoader(sectionLoader);
      this.disableWhileFetchingData(true, btnsToDisable);
    }
  },

  UiActionsOnUpdate: function UiActionsOnUpdate(_ref2) {
    var url = _ref2.url,
        sectionLoader = _ref2.sectionLoader,
        btnsToDisable = _ref2.btnsToDisable;

    delete this.API_cache[url];
    this.toggleSectionLoader(sectionLoader);
    this.disableWhileFetchingData(false, btnsToDisable);
  },

  toggleSectionLoader: function toggleSectionLoader(sectionLoader) {
    $(sectionLoader).toggleClass('hide');
  },

  disableWhileFetchingData: function disableWhileFetchingData(shouldDisable, elms) {
    $(elms).attr('disabled', shouldDisable);
  }

};

module.exports = Api;

/***/ }),

/***/ "./app/scripts/commons/meeting_filters.js":
/*!************************************************!*\
  !*** ./app/scripts/commons/meeting_filters.js ***!
  \************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } else { return Array.from(arr); } }

/* global HandlebarsTemplates, i18n, $, _, moment  */
var _window$envDetails = window.envDetails,
    eventType = _window$envDetails.eventType,
    event = _window$envDetails.event,
    pageType = _window$envDetails.pageType;

var boundedEvents = eventType === 'TradeShow' || eventType === 'StaffScheduling';
var datepickerStartFields = ['meeting_start_time', 'briefing_start_date'];
var datepickerEndFields = ['meeting_end_time', 'briefing_end_date'];
var datepickerFields = [].concat(datepickerStartFields, datepickerEndFields);
var datepickerObj = {
  'meeting_start_time': 'meeting_end_time',
  'meeting_end_time': 'meeting_start_time',
  'briefing_start_date': 'briefing_end_date',
  'briefing_end_date': 'briefing_start_date'
};
var dateApiMappings = {
  'meeting_start_time': { name: 'start_date', array: false },
  'meeting_end_time': { name: 'end_date', array: false },
  'briefing_start_date': { name: 'briefing_start_date', array: true },
  'briefing_end_date': { name: 'briefing_end_date', array: true }
};
var apiDateMappings = {
  'start_date': 'meeting_start_time',
  'end_date': 'meeting_end_time'
};
var dateFormat = 'YYYY-MM-DD';
var defaultDate = boundedEvents ? '' : moment().startOf('day').toDate();
var defaultValues = {
  'meeting_start_time': defaultDate

  // Add default dates only if it is event of type EBC
};if (window.isEBCEvent) {
  defaultValues['briefing_start_date'] = defaultDate;
}

function setMeetingFilters(filters, filterPanel, Actions) {
  var customSearchHash = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : {};
  var isCustomTemplate = arguments.length > 4 && arguments[4] !== undefined ? arguments[4] : false;

  var tmpl = __webpack_require__(/*! Templates/report/ondemand/filters */ "./templates/report/ondemand/filters.hbs");
  filterPanel.html(tmpl({ filters: filters, option_cls: 'token-input-fld' }));

  var searchHash = _.assign({
    subjects: 'meeting_with_field',
    meeting_with: 'meeting_with_field',
    reviewees: 'reviewees_field',
    requesters: 'requestors_field',
    internal_invitees: 'internal_attendee_field',
    external_invitees: 'external_attendee_field',
    users: 'internal_attendee_field',
    ids: 'meeting_ids_field',
    creators: 'creators_field',
    topics: 'topics_field',
    tags: 'tags',
    briefing_subjects: 'briefing_with_field',
    briefing_requesters: 'briefing_requestors_field',
    briefing_internal_invitees: 'briefing_internal_attendee_field',
    briefing_external_invitees: 'briefing_external_attendee_field',
    briefing_ids: 'briefing_ids_field',
    briefing_creators: 'briefing_creators_field',
    briefing_rooms: 'briefing_rooms_field'
  }, customSearchHash);

  $('input', '.filter_panel').each(function (i, selectElement) {
    selectElement = $(selectElement);
    var name = selectElement.attr('name');
    if (!_.isUndefined(name)) {
      selectElement.attr('placeholder', i18n.t('search_' + name));
    }
  });

  $('select', '.filter_panel').each(function (i, selectElement) {
    selectElement = $(selectElement);
    var name = selectElement.attr('name');
    var type = selectElement.data('type');
    var customLabel = selectElement.data('custom') || 'meeting type';
    var selectConfig = {
      dropdownParent: null,
      multiple: true,
      width: '100%',
      placeholder: i18n.t('search_' + name, { label: customLabel })
    };
    var ajaxSelectConfig = {
      minimumInputLength: 1,
      cache: true,
      ajax: {
        delay: 256,
        data: function data(params) {
          return {
            field: searchHash[name] || name,
            term: (params['term'] || '').trim()
          };
        },
        processResults: function processResults(results) {
          if (results instanceof Array) {
            results = results.map(function (item) {
              return {
                id: item[0],
                text: item[1]
              };
            });
          }
          return {
            results: results
          };
        }
      }
    };
    var localAjaxConfig;
    switch (name) {
      case 'subjects':
      case 'requesters':
      case 'internal_invitees':
      case 'external_invitees':
      case 'creators':
      case 'topics':
      case 'tags':
      case 'tag_uuids':
      case 'users':
      case 'reviewees':
      case 'meeting_with':
      case 'ids':
        {
          localAjaxConfig = _.assign(selectConfig, ajaxSelectConfig);
          localAjaxConfig.ajax.transport = function (params, success, failure) {
            return Actions.fetchOptions(params.data, success, failure, 'meeting');
          };

          selectElement.select2(localAjaxConfig);
          break;
        }
      case 'briefing_subjects':
      case 'briefing_requesters':
      case 'briefing_internal_invitees':
      case 'briefing_external_invitees':
      case 'briefing_creators':
      case 'briefing_ids':
      case 'briefing_rooms':
        {
          localAjaxConfig = _.assign(selectConfig, ajaxSelectConfig);
          localAjaxConfig.ajax.transport = function (params, success, failure) {
            return Actions.fetchOptions(params.data, success, failure, 'briefing');
          };

          selectElement.select2(localAjaxConfig);
          break;
        }
      case 'user_name':
        {
          localAjaxConfig = _.assign(selectConfig, ajaxSelectConfig);
          localAjaxConfig.ajax.transport = function (params, success, failure) {
            return Actions.fetchOptions(params.data, success, failure, 'calendar');
          };

          selectElement.select2(localAjaxConfig);
          break;
        }
      case 'tag_cloud':
        {
          selectConfig.placeholder = i18n.t('search_by') + type;
          selectElement.select2(selectConfig);
          break;
        }
      default:
        {
          selectElement.select2(selectConfig);
          break;
        }
    }

    selectElement.find('option').length && selectElement.trigger('change');
  });

  // Set date picker only if event is presend and page if ondemand report
  if (event && pageType !== undefined) {
    var _filters$meetings = filters.meetings,
        meetings = _filters$meetings === undefined ? [] : _filters$meetings,
        _filters$briefings = filters.briefings,
        briefings = _filters$briefings === undefined ? [] : _filters$briefings;

    var filtersApplied = [].concat(_toConsumableArray(meetings), _toConsumableArray(briefings));

    // Loop over the filters to get the start and end date for both briefings & meetings
    filtersApplied.map(function (filter) {
      var fieldName = filter.field_name;
      if (datepickerFields.indexOf(fieldName) !== -1) {
        var values = filter.value[0];
        values = values && values.hasOwnProperty('value') ? values.value : values;

        var savedValue = '';

        // Check to handle already existing briefing of different format
        if (values) {
          savedValue = moment(values, 'MM-DD-YYYY');
          savedValue = savedValue.isValid() ? savedValue : moment(values, dateFormat);
          savedValue = savedValue.toDate();
        }

        // Before setting initial value
        defaultValues[fieldName] = savedValue || (isCustomTemplate ? '' : defaultValues[fieldName]);
      }
    });

    datepickerFields.map(function (fieldName) {
      initDatepickers(fieldName);
    });
  }

  $('#ui-datepicker-div').on('click', function (e) {
    e.stopPropagation();
  });

  filterPanel.find('.tab-pane').on('scroll', function () {
    $('.datepicker-dropdown').length && filterPanel.find('.meeting_start_time, .meeting_end_time').each(function (i, el) {
      $(el).bootstrapDP('hide').blur();
    });
  });
}

function initDatepickers(fieldName) {
  var datePickerFunction = datepickerStartFields.indexOf(fieldName) !== -1 ? setStartDatePicker : setEndDatePicker;
  datePickerFunction(fieldName);
}

function setStartDatePicker(fieldName) {
  var datepickerEle = $('.' + fieldName);

  if (!datepickerEle.length) {
    return;
  }

  var selectedDate = defaultValues[fieldName];
  var startDate = event.start_date;
  var endDate = defaultValues[datepickerObj[fieldName]] || (boundedEvents ? event.end_date : '');
  var defaultViewDate = moment(selectedDate || startDate, dateFormat);

  datepickerEle.bootstrapDP('destroy').off('changeDate', datepickerHandler).bootstrapDP({
    format: 'mm/dd/yyyy',
    autoclose: true,
    orientation: 'bottom',
    defaultViewDate: {
      year: defaultViewDate.year(),
      month: defaultViewDate.month(),
      day: defaultViewDate.date()
    },
    startDate: startDate ? moment(startDate, dateFormat).toDate() : null,
    endDate: endDate ? moment(endDate, dateFormat).toDate() : null
  });

  datepickerEle.bootstrapDP('setDate', selectedDate && moment(selectedDate, dateFormat).toDate() || '').on('changeDate', datepickerHandler);
}

function setEndDatePicker(fieldName) {
  var datepickerEle = $('.' + fieldName);

  if (!datepickerEle.length) {
    return;
  }

  var selectedDate = defaultValues[fieldName];
  var startDate = defaultValues[datepickerObj[fieldName]] || event.start_date;
  var endDate = boundedEvents ? event.end_date : '';
  var defaultViewDate = moment(selectedDate || event.end_date, dateFormat);

  datepickerEle.bootstrapDP('destroy').off('changeDate', datepickerHandler).bootstrapDP({
    format: 'mm/dd/yyyy',
    autoclose: true,
    orientation: 'bottom',
    defaultViewDate: {
      year: defaultViewDate.year(),
      month: defaultViewDate.month(),
      day: defaultViewDate.date()
    },
    startDate: startDate ? moment(startDate, dateFormat).toDate() : null,
    endDate: endDate ? moment(endDate, dateFormat).toDate() : null
  });

  datepickerEle.bootstrapDP('setDate', selectedDate && moment(selectedDate, dateFormat).toDate() || '').on('changeDate', datepickerHandler);
}

function datepickerHandler(event) {
  var fieldName = event.currentTarget.name;
  defaultValues[fieldName] = moment(event.date).toDate();
  var datePickerFunction = datepickerStartFields.indexOf(fieldName) !== -1 ? setEndDatePicker : setStartDatePicker;

  datePickerFunction(datepickerObj[fieldName]);
}

function setDatePicker(ele) {
  ele.datepicker({
    dateFormat: 'yy-mm-dd',
    onSelect: updateDateRange
  }).attr('placeholder', i18n.t('search_' + ele.attr('name')));
}

function updateDateRange(dateStr) {
  var event = window.event;
  event && event.preventDefault && event.preventDefault();
  var el = $(this);
  var panel = $('.filter_panel');

  if (el.hasClass('end')) {
    var stDate = panel.find('.date.start');
    setMinMaxDate(stDate, 'maxDate', dateStr);
  } else {
    var edDate = panel.find('.date.end');
    setMinMaxDate(edDate, 'minDate', dateStr);
  }
}

function setMinMaxDate(elem, minMaxDate, dateStr) {
  elem.datepicker('option', minMaxDate, new Date(dateStr));
}

function getClubbedFilterData(filterPanel) {
  var formData = {};
  var selectedFilterData = {};
  var storableFilterData = {};
  var startDate, endDate;
  var briefingStartDate, briefingEndDate;

  if (pageType !== undefined) {
    datepickerFields.map(function (key) {
      var fieldValue = defaultValues[key];
      var _dateApiMappings$key = dateApiMappings[key],
          name = _dateApiMappings$key.name,
          array = _dateApiMappings$key.array;


      if (fieldValue) {
        fieldValue = moment(fieldValue).format('MM/DD/YYYY');
        formData[name] = array ? [fieldValue] : fieldValue;
        selectedFilterData[name] = {
          values: [{ key: key, name: fieldValue }],
          display_name: i18n.t(key)
        };
      }
    });
  }

  filterPanel.find('.select').each(function (index, element) {
    var input = $(element);
    var value = input.val() || [];
    var name = input.attr('name');
    var filterValue = [];
    var storableFilterValues = [];
    var type = input.data('type');

    input.find('option:selected').each(function (i, optionEle) {
      var option = $(optionEle);
      filterValue.push({
        key: option.val(),
        name: option.text()
      });
      storableFilterValues.push({
        value: option.val(),
        display_label: option.text()
      });
    });

    if (value !== null && value !== '') {
      if (!formData[name]) {
        formData[name] = value;
        selectedFilterData[name] = {
          values: filterValue,
          display_name: type
        };
        storableFilterData[name] = storableFilterValues;
      } else {
        formData[name].push(value);
        selectedFilterData[name].values.push(filterValue);
        storableFilterData[name].push(storableFilterValues);
        formData[name] = _.flatten(formData[name]);
        selectedFilterData[name].values = _.flatten(selectedFilterData[name].values);
        storableFilterData[name] = _.flatten(storableFilterData[name]);
      }
    }
  });

  filterPanel.find('.date').each(function (index, element) {
    var input = $(element);
    var value = input.val();
    var name = input.attr('name');
    var filterValue = [];
    var storableFilterValues = [];
    var type = input.data('type');

    if (value !== '') {
      filterValue.push({
        key: [value],
        name: value
      });
      storableFilterValues.push({
        value: [value],
        display_label: value
      });
    }

    formData[name] = value !== '' ? [value] : [];
    selectedFilterData[name] = {
      values: filterValue,
      display_name: type
    };
    storableFilterData[name] = storableFilterValues;
  });

  filterPanel.find('input.enabled[type=checkbox]').each(function (index, element) {
    var input = $(element);
    var value = input.is(':checked');
    var name = input.attr('name');
    var filterValue = [];
    var storableFilterValues = [];
    var type = input.data('type');

    if (value !== '') {
      filterValue.push({
        key: [value],
        name: value
      });
      storableFilterValues.push({
        value: [value],
        display_label: value
      });
    }

    formData[name] = [value];
    selectedFilterData[name] = {
      values: filterValue,
      display_name: type
    };
    storableFilterData[name] = storableFilterValues;
  });

  return {
    formData: formData,
    selectedFilterData: selectedFilterData,
    storableFilterData: storableFilterData
  };
}

function resetDatePickers(fieldKey) {
  datepickerFields.map(function (fieldName) {
    if (fieldKey) {
      if (fieldName === fieldKey) {
        defaultValues[fieldName] = '';
      }
    } else {
      defaultValues[fieldName] = '';
    }

    initDatepickers(fieldName);
  });
}

module.exports = {
  setMeetingFilters: setMeetingFilters,
  getClubbedFilterData: getClubbedFilterData,
  setDatePicker: setDatePicker,
  setMinMaxDate: setMinMaxDate,
  resetDatePickers: resetDatePickers,
  datepickerFields: datepickerFields,
  apiDateMappings: apiDateMappings
};

/***/ }),

/***/ "./app/scripts/utils/index.js":
/*!************************************!*\
  !*** ./app/scripts/utils/index.js ***!
  \************************************/
/*! no static exports found */
/***/ (function(module, exports) {

var declineComments = [];
var cancelComments = [];

function putSearchQueryParam(input, key, value) {
  input = input || ''; // This is not required had we used default parameters but still running older version gulp
  var regexString = '([?&])' + key + '=([^&$]*)';
  var regex = new RegExp(regexString);
  var evaluated = regex.exec(input);
  if (!evaluated) return input.concat(input ? '&' : '?', key, '=', value);
  return input.replace(evaluated[0], '' + evaluated[1] + key + '=' + value);
}

function getComments(_ref) {
  var flag = _ref.flag,
      _ref$comments = _ref.comments,
      comments = _ref$comments === undefined ? [] : _ref$comments;

  if (flag === 'yes') {
    comments = comments.filter(function (comment) {
      return comment;
    });
  }

  return comments;
}

function getDeclineComments() {
  return declineComments;
}

function getCancelComments() {
  return cancelComments;
}

function updateDeclineComments() {
  var inviteOption = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  var declineCommentsEnabled = inviteOption.decline_comments_enabled,
      predefinedDeclineComments = inviteOption.predefined_decline_comments;


  declineComments = getComments({ flag: declineCommentsEnabled, comments: predefinedDeclineComments });
}

function updateCancelComments() {
  var cancelOption = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
  var cancelCommentsEnabled = cancelOption.cancel_comments_enabled,
      predefinedCancelComments = cancelOption.predefined_cancel_comments;


  cancelComments = getComments({ flag: cancelCommentsEnabled, comments: predefinedCancelComments });
}
function abortableFetch(queue, promise) {
  var promiseId = Math.random().toString(36).substr(2, 9);
  queue.map(function (request) {
    request.promise.abort();
  });

  queue.push({ promise: promise, Id: promiseId });
  return { promiseId: promiseId };
}

module.exports = {
  putSearchQueryParam: putSearchQueryParam,
  getDeclineComments: getDeclineComments,
  getCancelComments: getCancelComments,
  updateDeclineComments: updateDeclineComments,
  updateCancelComments: updateCancelComments,
  abortableFetch: abortableFetch
};

/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars.runtime.js":
/*!****************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars.runtime.js ***!
  \****************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

// istanbul ignore next

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj['default'] = obj; return newObj; } }

var _handlebarsBase = __webpack_require__(/*! ./handlebars/base */ "./node_modules/handlebars/dist/cjs/handlebars/base.js");

var base = _interopRequireWildcard(_handlebarsBase);

// Each of these augment the Handlebars object. No need to setup here.
// (This is done to easily share code between commonjs and browse envs)

var _handlebarsSafeString = __webpack_require__(/*! ./handlebars/safe-string */ "./node_modules/handlebars/dist/cjs/handlebars/safe-string.js");

var _handlebarsSafeString2 = _interopRequireDefault(_handlebarsSafeString);

var _handlebarsException = __webpack_require__(/*! ./handlebars/exception */ "./node_modules/handlebars/dist/cjs/handlebars/exception.js");

var _handlebarsException2 = _interopRequireDefault(_handlebarsException);

var _handlebarsUtils = __webpack_require__(/*! ./handlebars/utils */ "./node_modules/handlebars/dist/cjs/handlebars/utils.js");

var Utils = _interopRequireWildcard(_handlebarsUtils);

var _handlebarsRuntime = __webpack_require__(/*! ./handlebars/runtime */ "./node_modules/handlebars/dist/cjs/handlebars/runtime.js");

var runtime = _interopRequireWildcard(_handlebarsRuntime);

var _handlebarsNoConflict = __webpack_require__(/*! ./handlebars/no-conflict */ "./node_modules/handlebars/dist/cjs/handlebars/no-conflict.js");

var _handlebarsNoConflict2 = _interopRequireDefault(_handlebarsNoConflict);

// For compatibility and usage outside of module systems, make the Handlebars object a namespace
function create() {
  var hb = new base.HandlebarsEnvironment();

  Utils.extend(hb, base);
  hb.SafeString = _handlebarsSafeString2['default'];
  hb.Exception = _handlebarsException2['default'];
  hb.Utils = Utils;
  hb.escapeExpression = Utils.escapeExpression;

  hb.VM = runtime;
  hb.template = function (spec) {
    return runtime.template(spec, hb);
  };

  return hb;
}

var inst = create();
inst.create = create;

_handlebarsNoConflict2['default'](inst);

inst['default'] = inst;

exports['default'] = inst;
module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uL2xpYi9oYW5kbGViYXJzLnJ1bnRpbWUuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7Ozs7OEJBQXNCLG1CQUFtQjs7SUFBN0IsSUFBSTs7Ozs7b0NBSU8sMEJBQTBCOzs7O21DQUMzQix3QkFBd0I7Ozs7K0JBQ3ZCLG9CQUFvQjs7SUFBL0IsS0FBSzs7aUNBQ1Esc0JBQXNCOztJQUFuQyxPQUFPOztvQ0FFSSwwQkFBMEI7Ozs7O0FBR2pELFNBQVMsTUFBTSxHQUFHO0FBQ2hCLE1BQUksRUFBRSxHQUFHLElBQUksSUFBSSxDQUFDLHFCQUFxQixFQUFFLENBQUM7O0FBRTFDLE9BQUssQ0FBQyxNQUFNLENBQUMsRUFBRSxFQUFFLElBQUksQ0FBQyxDQUFDO0FBQ3ZCLElBQUUsQ0FBQyxVQUFVLG9DQUFhLENBQUM7QUFDM0IsSUFBRSxDQUFDLFNBQVMsbUNBQVksQ0FBQztBQUN6QixJQUFFLENBQUMsS0FBSyxHQUFHLEtBQUssQ0FBQztBQUNqQixJQUFFLENBQUMsZ0JBQWdCLEdBQUcsS0FBSyxDQUFDLGdCQUFnQixDQUFDOztBQUU3QyxJQUFFLENBQUMsRUFBRSxHQUFHLE9BQU8sQ0FBQztBQUNoQixJQUFFLENBQUMsUUFBUSxHQUFHLFVBQVMsSUFBSSxFQUFFO0FBQzNCLFdBQU8sT0FBTyxDQUFDLFFBQVEsQ0FBQyxJQUFJLEVBQUUsRUFBRSxDQUFDLENBQUM7R0FDbkMsQ0FBQzs7QUFFRixTQUFPLEVBQUUsQ0FBQztDQUNYOztBQUVELElBQUksSUFBSSxHQUFHLE1BQU0sRUFBRSxDQUFDO0FBQ3BCLElBQUksQ0FBQyxNQUFNLEdBQUcsTUFBTSxDQUFDOztBQUVyQixrQ0FBVyxJQUFJLENBQUMsQ0FBQzs7QUFFakIsSUFBSSxDQUFDLFNBQVMsQ0FBQyxHQUFHLElBQUksQ0FBQzs7cUJBRVIsSUFBSSIsImZpbGUiOiJoYW5kbGViYXJzLnJ1bnRpbWUuanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgKiBhcyBiYXNlIGZyb20gJy4vaGFuZGxlYmFycy9iYXNlJztcblxuLy8gRWFjaCBvZiB0aGVzZSBhdWdtZW50IHRoZSBIYW5kbGViYXJzIG9iamVjdC4gTm8gbmVlZCB0byBzZXR1cCBoZXJlLlxuLy8gKFRoaXMgaXMgZG9uZSB0byBlYXNpbHkgc2hhcmUgY29kZSBiZXR3ZWVuIGNvbW1vbmpzIGFuZCBicm93c2UgZW52cylcbmltcG9ydCBTYWZlU3RyaW5nIGZyb20gJy4vaGFuZGxlYmFycy9zYWZlLXN0cmluZyc7XG5pbXBvcnQgRXhjZXB0aW9uIGZyb20gJy4vaGFuZGxlYmFycy9leGNlcHRpb24nO1xuaW1wb3J0ICogYXMgVXRpbHMgZnJvbSAnLi9oYW5kbGViYXJzL3V0aWxzJztcbmltcG9ydCAqIGFzIHJ1bnRpbWUgZnJvbSAnLi9oYW5kbGViYXJzL3J1bnRpbWUnO1xuXG5pbXBvcnQgbm9Db25mbGljdCBmcm9tICcuL2hhbmRsZWJhcnMvbm8tY29uZmxpY3QnO1xuXG4vLyBGb3IgY29tcGF0aWJpbGl0eSBhbmQgdXNhZ2Ugb3V0c2lkZSBvZiBtb2R1bGUgc3lzdGVtcywgbWFrZSB0aGUgSGFuZGxlYmFycyBvYmplY3QgYSBuYW1lc3BhY2VcbmZ1bmN0aW9uIGNyZWF0ZSgpIHtcbiAgbGV0IGhiID0gbmV3IGJhc2UuSGFuZGxlYmFyc0Vudmlyb25tZW50KCk7XG5cbiAgVXRpbHMuZXh0ZW5kKGhiLCBiYXNlKTtcbiAgaGIuU2FmZVN0cmluZyA9IFNhZmVTdHJpbmc7XG4gIGhiLkV4Y2VwdGlvbiA9IEV4Y2VwdGlvbjtcbiAgaGIuVXRpbHMgPSBVdGlscztcbiAgaGIuZXNjYXBlRXhwcmVzc2lvbiA9IFV0aWxzLmVzY2FwZUV4cHJlc3Npb247XG5cbiAgaGIuVk0gPSBydW50aW1lO1xuICBoYi50ZW1wbGF0ZSA9IGZ1bmN0aW9uKHNwZWMpIHtcbiAgICByZXR1cm4gcnVudGltZS50ZW1wbGF0ZShzcGVjLCBoYik7XG4gIH07XG5cbiAgcmV0dXJuIGhiO1xufVxuXG5sZXQgaW5zdCA9IGNyZWF0ZSgpO1xuaW5zdC5jcmVhdGUgPSBjcmVhdGU7XG5cbm5vQ29uZmxpY3QoaW5zdCk7XG5cbmluc3RbJ2RlZmF1bHQnXSA9IGluc3Q7XG5cbmV4cG9ydCBkZWZhdWx0IGluc3Q7XG4iXX0=


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/base.js":
/*!*************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/base.js ***!
  \*************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.HandlebarsEnvironment = HandlebarsEnvironment;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _utils = __webpack_require__(/*! ./utils */ "./node_modules/handlebars/dist/cjs/handlebars/utils.js");

var _exception = __webpack_require__(/*! ./exception */ "./node_modules/handlebars/dist/cjs/handlebars/exception.js");

var _exception2 = _interopRequireDefault(_exception);

var _helpers = __webpack_require__(/*! ./helpers */ "./node_modules/handlebars/dist/cjs/handlebars/helpers.js");

var _decorators = __webpack_require__(/*! ./decorators */ "./node_modules/handlebars/dist/cjs/handlebars/decorators.js");

var _logger = __webpack_require__(/*! ./logger */ "./node_modules/handlebars/dist/cjs/handlebars/logger.js");

var _logger2 = _interopRequireDefault(_logger);

var VERSION = '4.1.2';
exports.VERSION = VERSION;
var COMPILER_REVISION = 7;

exports.COMPILER_REVISION = COMPILER_REVISION;
var REVISION_CHANGES = {
  1: '<= 1.0.rc.2', // 1.0.rc.2 is actually rev2 but doesn't report it
  2: '== 1.0.0-rc.3',
  3: '== 1.0.0-rc.4',
  4: '== 1.x.x',
  5: '== 2.0.0-alpha.x',
  6: '>= 2.0.0-beta.1',
  7: '>= 4.0.0'
};

exports.REVISION_CHANGES = REVISION_CHANGES;
var objectType = '[object Object]';

function HandlebarsEnvironment(helpers, partials, decorators) {
  this.helpers = helpers || {};
  this.partials = partials || {};
  this.decorators = decorators || {};

  _helpers.registerDefaultHelpers(this);
  _decorators.registerDefaultDecorators(this);
}

HandlebarsEnvironment.prototype = {
  constructor: HandlebarsEnvironment,

  logger: _logger2['default'],
  log: _logger2['default'].log,

  registerHelper: function registerHelper(name, fn) {
    if (_utils.toString.call(name) === objectType) {
      if (fn) {
        throw new _exception2['default']('Arg not supported with multiple helpers');
      }
      _utils.extend(this.helpers, name);
    } else {
      this.helpers[name] = fn;
    }
  },
  unregisterHelper: function unregisterHelper(name) {
    delete this.helpers[name];
  },

  registerPartial: function registerPartial(name, partial) {
    if (_utils.toString.call(name) === objectType) {
      _utils.extend(this.partials, name);
    } else {
      if (typeof partial === 'undefined') {
        throw new _exception2['default']('Attempting to register a partial called "' + name + '" as undefined');
      }
      this.partials[name] = partial;
    }
  },
  unregisterPartial: function unregisterPartial(name) {
    delete this.partials[name];
  },

  registerDecorator: function registerDecorator(name, fn) {
    if (_utils.toString.call(name) === objectType) {
      if (fn) {
        throw new _exception2['default']('Arg not supported with multiple decorators');
      }
      _utils.extend(this.decorators, name);
    } else {
      this.decorators[name] = fn;
    }
  },
  unregisterDecorator: function unregisterDecorator(name) {
    delete this.decorators[name];
  }
};

var log = _logger2['default'].log;

exports.log = log;
exports.createFrame = _utils.createFrame;
exports.logger = _logger2['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2Jhc2UuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7cUJBQTRDLFNBQVM7O3lCQUMvQixhQUFhOzs7O3VCQUNFLFdBQVc7OzBCQUNSLGNBQWM7O3NCQUNuQyxVQUFVOzs7O0FBRXRCLElBQU0sT0FBTyxHQUFHLE9BQU8sQ0FBQzs7QUFDeEIsSUFBTSxpQkFBaUIsR0FBRyxDQUFDLENBQUM7OztBQUU1QixJQUFNLGdCQUFnQixHQUFHO0FBQzlCLEdBQUMsRUFBRSxhQUFhO0FBQ2hCLEdBQUMsRUFBRSxlQUFlO0FBQ2xCLEdBQUMsRUFBRSxlQUFlO0FBQ2xCLEdBQUMsRUFBRSxVQUFVO0FBQ2IsR0FBQyxFQUFFLGtCQUFrQjtBQUNyQixHQUFDLEVBQUUsaUJBQWlCO0FBQ3BCLEdBQUMsRUFBRSxVQUFVO0NBQ2QsQ0FBQzs7O0FBRUYsSUFBTSxVQUFVLEdBQUcsaUJBQWlCLENBQUM7O0FBRTlCLFNBQVMscUJBQXFCLENBQUMsT0FBTyxFQUFFLFFBQVEsRUFBRSxVQUFVLEVBQUU7QUFDbkUsTUFBSSxDQUFDLE9BQU8sR0FBRyxPQUFPLElBQUksRUFBRSxDQUFDO0FBQzdCLE1BQUksQ0FBQyxRQUFRLEdBQUcsUUFBUSxJQUFJLEVBQUUsQ0FBQztBQUMvQixNQUFJLENBQUMsVUFBVSxHQUFHLFVBQVUsSUFBSSxFQUFFLENBQUM7O0FBRW5DLGtDQUF1QixJQUFJLENBQUMsQ0FBQztBQUM3Qix3Q0FBMEIsSUFBSSxDQUFDLENBQUM7Q0FDakM7O0FBRUQscUJBQXFCLENBQUMsU0FBUyxHQUFHO0FBQ2hDLGFBQVcsRUFBRSxxQkFBcUI7O0FBRWxDLFFBQU0scUJBQVE7QUFDZCxLQUFHLEVBQUUsb0JBQU8sR0FBRzs7QUFFZixnQkFBYyxFQUFFLHdCQUFTLElBQUksRUFBRSxFQUFFLEVBQUU7QUFDakMsUUFBSSxnQkFBUyxJQUFJLENBQUMsSUFBSSxDQUFDLEtBQUssVUFBVSxFQUFFO0FBQ3RDLFVBQUksRUFBRSxFQUFFO0FBQUUsY0FBTSwyQkFBYyx5Q0FBeUMsQ0FBQyxDQUFDO09BQUU7QUFDM0Usb0JBQU8sSUFBSSxDQUFDLE9BQU8sRUFBRSxJQUFJLENBQUMsQ0FBQztLQUM1QixNQUFNO0FBQ0wsVUFBSSxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsR0FBRyxFQUFFLENBQUM7S0FDekI7R0FDRjtBQUNELGtCQUFnQixFQUFFLDBCQUFTLElBQUksRUFBRTtBQUMvQixXQUFPLElBQUksQ0FBQyxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUM7R0FDM0I7O0FBRUQsaUJBQWUsRUFBRSx5QkFBUyxJQUFJLEVBQUUsT0FBTyxFQUFFO0FBQ3ZDLFFBQUksZ0JBQVMsSUFBSSxDQUFDLElBQUksQ0FBQyxLQUFLLFVBQVUsRUFBRTtBQUN0QyxvQkFBTyxJQUFJLENBQUMsUUFBUSxFQUFFLElBQUksQ0FBQyxDQUFDO0tBQzdCLE1BQU07QUFDTCxVQUFJLE9BQU8sT0FBTyxLQUFLLFdBQVcsRUFBRTtBQUNsQyxjQUFNLHlFQUEwRCxJQUFJLG9CQUFpQixDQUFDO09BQ3ZGO0FBQ0QsVUFBSSxDQUFDLFFBQVEsQ0FBQyxJQUFJLENBQUMsR0FBRyxPQUFPLENBQUM7S0FDL0I7R0FDRjtBQUNELG1CQUFpQixFQUFFLDJCQUFTLElBQUksRUFBRTtBQUNoQyxXQUFPLElBQUksQ0FBQyxRQUFRLENBQUMsSUFBSSxDQUFDLENBQUM7R0FDNUI7O0FBRUQsbUJBQWlCLEVBQUUsMkJBQVMsSUFBSSxFQUFFLEVBQUUsRUFBRTtBQUNwQyxRQUFJLGdCQUFTLElBQUksQ0FBQyxJQUFJLENBQUMsS0FBSyxVQUFVLEVBQUU7QUFDdEMsVUFBSSxFQUFFLEVBQUU7QUFBRSxjQUFNLDJCQUFjLDRDQUE0QyxDQUFDLENBQUM7T0FBRTtBQUM5RSxvQkFBTyxJQUFJLENBQUMsVUFBVSxFQUFFLElBQUksQ0FBQyxDQUFDO0tBQy9CLE1BQU07QUFDTCxVQUFJLENBQUMsVUFBVSxDQUFDLElBQUksQ0FBQyxHQUFHLEVBQUUsQ0FBQztLQUM1QjtHQUNGO0FBQ0QscUJBQW1CLEVBQUUsNkJBQVMsSUFBSSxFQUFFO0FBQ2xDLFdBQU8sSUFBSSxDQUFDLFVBQVUsQ0FBQyxJQUFJLENBQUMsQ0FBQztHQUM5QjtDQUNGLENBQUM7O0FBRUssSUFBSSxHQUFHLEdBQUcsb0JBQU8sR0FBRyxDQUFDOzs7UUFFcEIsV0FBVztRQUFFLE1BQU0iLCJmaWxlIjoiYmFzZS5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7Y3JlYXRlRnJhbWUsIGV4dGVuZCwgdG9TdHJpbmd9IGZyb20gJy4vdXRpbHMnO1xuaW1wb3J0IEV4Y2VwdGlvbiBmcm9tICcuL2V4Y2VwdGlvbic7XG5pbXBvcnQge3JlZ2lzdGVyRGVmYXVsdEhlbHBlcnN9IGZyb20gJy4vaGVscGVycyc7XG5pbXBvcnQge3JlZ2lzdGVyRGVmYXVsdERlY29yYXRvcnN9IGZyb20gJy4vZGVjb3JhdG9ycyc7XG5pbXBvcnQgbG9nZ2VyIGZyb20gJy4vbG9nZ2VyJztcblxuZXhwb3J0IGNvbnN0IFZFUlNJT04gPSAnNC4xLjInO1xuZXhwb3J0IGNvbnN0IENPTVBJTEVSX1JFVklTSU9OID0gNztcblxuZXhwb3J0IGNvbnN0IFJFVklTSU9OX0NIQU5HRVMgPSB7XG4gIDE6ICc8PSAxLjAucmMuMicsIC8vIDEuMC5yYy4yIGlzIGFjdHVhbGx5IHJldjIgYnV0IGRvZXNuJ3QgcmVwb3J0IGl0XG4gIDI6ICc9PSAxLjAuMC1yYy4zJyxcbiAgMzogJz09IDEuMC4wLXJjLjQnLFxuICA0OiAnPT0gMS54LngnLFxuICA1OiAnPT0gMi4wLjAtYWxwaGEueCcsXG4gIDY6ICc+PSAyLjAuMC1iZXRhLjEnLFxuICA3OiAnPj0gNC4wLjAnXG59O1xuXG5jb25zdCBvYmplY3RUeXBlID0gJ1tvYmplY3QgT2JqZWN0XSc7XG5cbmV4cG9ydCBmdW5jdGlvbiBIYW5kbGViYXJzRW52aXJvbm1lbnQoaGVscGVycywgcGFydGlhbHMsIGRlY29yYXRvcnMpIHtcbiAgdGhpcy5oZWxwZXJzID0gaGVscGVycyB8fCB7fTtcbiAgdGhpcy5wYXJ0aWFscyA9IHBhcnRpYWxzIHx8IHt9O1xuICB0aGlzLmRlY29yYXRvcnMgPSBkZWNvcmF0b3JzIHx8IHt9O1xuXG4gIHJlZ2lzdGVyRGVmYXVsdEhlbHBlcnModGhpcyk7XG4gIHJlZ2lzdGVyRGVmYXVsdERlY29yYXRvcnModGhpcyk7XG59XG5cbkhhbmRsZWJhcnNFbnZpcm9ubWVudC5wcm90b3R5cGUgPSB7XG4gIGNvbnN0cnVjdG9yOiBIYW5kbGViYXJzRW52aXJvbm1lbnQsXG5cbiAgbG9nZ2VyOiBsb2dnZXIsXG4gIGxvZzogbG9nZ2VyLmxvZyxcblxuICByZWdpc3RlckhlbHBlcjogZnVuY3Rpb24obmFtZSwgZm4pIHtcbiAgICBpZiAodG9TdHJpbmcuY2FsbChuYW1lKSA9PT0gb2JqZWN0VHlwZSkge1xuICAgICAgaWYgKGZuKSB7IHRocm93IG5ldyBFeGNlcHRpb24oJ0FyZyBub3Qgc3VwcG9ydGVkIHdpdGggbXVsdGlwbGUgaGVscGVycycpOyB9XG4gICAgICBleHRlbmQodGhpcy5oZWxwZXJzLCBuYW1lKTtcbiAgICB9IGVsc2Uge1xuICAgICAgdGhpcy5oZWxwZXJzW25hbWVdID0gZm47XG4gICAgfVxuICB9LFxuICB1bnJlZ2lzdGVySGVscGVyOiBmdW5jdGlvbihuYW1lKSB7XG4gICAgZGVsZXRlIHRoaXMuaGVscGVyc1tuYW1lXTtcbiAgfSxcblxuICByZWdpc3RlclBhcnRpYWw6IGZ1bmN0aW9uKG5hbWUsIHBhcnRpYWwpIHtcbiAgICBpZiAodG9TdHJpbmcuY2FsbChuYW1lKSA9PT0gb2JqZWN0VHlwZSkge1xuICAgICAgZXh0ZW5kKHRoaXMucGFydGlhbHMsIG5hbWUpO1xuICAgIH0gZWxzZSB7XG4gICAgICBpZiAodHlwZW9mIHBhcnRpYWwgPT09ICd1bmRlZmluZWQnKSB7XG4gICAgICAgIHRocm93IG5ldyBFeGNlcHRpb24oYEF0dGVtcHRpbmcgdG8gcmVnaXN0ZXIgYSBwYXJ0aWFsIGNhbGxlZCBcIiR7bmFtZX1cIiBhcyB1bmRlZmluZWRgKTtcbiAgICAgIH1cbiAgICAgIHRoaXMucGFydGlhbHNbbmFtZV0gPSBwYXJ0aWFsO1xuICAgIH1cbiAgfSxcbiAgdW5yZWdpc3RlclBhcnRpYWw6IGZ1bmN0aW9uKG5hbWUpIHtcbiAgICBkZWxldGUgdGhpcy5wYXJ0aWFsc1tuYW1lXTtcbiAgfSxcblxuICByZWdpc3RlckRlY29yYXRvcjogZnVuY3Rpb24obmFtZSwgZm4pIHtcbiAgICBpZiAodG9TdHJpbmcuY2FsbChuYW1lKSA9PT0gb2JqZWN0VHlwZSkge1xuICAgICAgaWYgKGZuKSB7IHRocm93IG5ldyBFeGNlcHRpb24oJ0FyZyBub3Qgc3VwcG9ydGVkIHdpdGggbXVsdGlwbGUgZGVjb3JhdG9ycycpOyB9XG4gICAgICBleHRlbmQodGhpcy5kZWNvcmF0b3JzLCBuYW1lKTtcbiAgICB9IGVsc2Uge1xuICAgICAgdGhpcy5kZWNvcmF0b3JzW25hbWVdID0gZm47XG4gICAgfVxuICB9LFxuICB1bnJlZ2lzdGVyRGVjb3JhdG9yOiBmdW5jdGlvbihuYW1lKSB7XG4gICAgZGVsZXRlIHRoaXMuZGVjb3JhdG9yc1tuYW1lXTtcbiAgfVxufTtcblxuZXhwb3J0IGxldCBsb2cgPSBsb2dnZXIubG9nO1xuXG5leHBvcnQge2NyZWF0ZUZyYW1lLCBsb2dnZXJ9O1xuIl19


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/decorators.js":
/*!*******************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/decorators.js ***!
  \*******************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.registerDefaultDecorators = registerDefaultDecorators;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _decoratorsInline = __webpack_require__(/*! ./decorators/inline */ "./node_modules/handlebars/dist/cjs/handlebars/decorators/inline.js");

var _decoratorsInline2 = _interopRequireDefault(_decoratorsInline);

function registerDefaultDecorators(instance) {
  _decoratorsInline2['default'](instance);
}
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2RlY29yYXRvcnMuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7Z0NBQTJCLHFCQUFxQjs7OztBQUV6QyxTQUFTLHlCQUF5QixDQUFDLFFBQVEsRUFBRTtBQUNsRCxnQ0FBZSxRQUFRLENBQUMsQ0FBQztDQUMxQiIsImZpbGUiOiJkZWNvcmF0b3JzLmpzIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHJlZ2lzdGVySW5saW5lIGZyb20gJy4vZGVjb3JhdG9ycy9pbmxpbmUnO1xuXG5leHBvcnQgZnVuY3Rpb24gcmVnaXN0ZXJEZWZhdWx0RGVjb3JhdG9ycyhpbnN0YW5jZSkge1xuICByZWdpc3RlcklubGluZShpbnN0YW5jZSk7XG59XG5cbiJdfQ==


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/decorators/inline.js":
/*!**************************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/decorators/inline.js ***!
  \**************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

var _utils = __webpack_require__(/*! ../utils */ "./node_modules/handlebars/dist/cjs/handlebars/utils.js");

exports['default'] = function (instance) {
  instance.registerDecorator('inline', function (fn, props, container, options) {
    var ret = fn;
    if (!props.partials) {
      props.partials = {};
      ret = function (context, options) {
        // Create a new partials stack frame prior to exec.
        var original = container.partials;
        container.partials = _utils.extend({}, original, props.partials);
        var ret = fn(context, options);
        container.partials = original;
        return ret;
      };
    }

    props.partials[options.args[0]] = options.fn;

    return ret;
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2RlY29yYXRvcnMvaW5saW5lLmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7cUJBQXFCLFVBQVU7O3FCQUVoQixVQUFTLFFBQVEsRUFBRTtBQUNoQyxVQUFRLENBQUMsaUJBQWlCLENBQUMsUUFBUSxFQUFFLFVBQVMsRUFBRSxFQUFFLEtBQUssRUFBRSxTQUFTLEVBQUUsT0FBTyxFQUFFO0FBQzNFLFFBQUksR0FBRyxHQUFHLEVBQUUsQ0FBQztBQUNiLFFBQUksQ0FBQyxLQUFLLENBQUMsUUFBUSxFQUFFO0FBQ25CLFdBQUssQ0FBQyxRQUFRLEdBQUcsRUFBRSxDQUFDO0FBQ3BCLFNBQUcsR0FBRyxVQUFTLE9BQU8sRUFBRSxPQUFPLEVBQUU7O0FBRS9CLFlBQUksUUFBUSxHQUFHLFNBQVMsQ0FBQyxRQUFRLENBQUM7QUFDbEMsaUJBQVMsQ0FBQyxRQUFRLEdBQUcsY0FBTyxFQUFFLEVBQUUsUUFBUSxFQUFFLEtBQUssQ0FBQyxRQUFRLENBQUMsQ0FBQztBQUMxRCxZQUFJLEdBQUcsR0FBRyxFQUFFLENBQUMsT0FBTyxFQUFFLE9BQU8sQ0FBQyxDQUFDO0FBQy9CLGlCQUFTLENBQUMsUUFBUSxHQUFHLFFBQVEsQ0FBQztBQUM5QixlQUFPLEdBQUcsQ0FBQztPQUNaLENBQUM7S0FDSDs7QUFFRCxTQUFLLENBQUMsUUFBUSxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQyxDQUFDLENBQUMsR0FBRyxPQUFPLENBQUMsRUFBRSxDQUFDOztBQUU3QyxXQUFPLEdBQUcsQ0FBQztHQUNaLENBQUMsQ0FBQztDQUNKIiwiZmlsZSI6ImlubGluZS5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7ZXh0ZW5kfSBmcm9tICcuLi91dGlscyc7XG5cbmV4cG9ydCBkZWZhdWx0IGZ1bmN0aW9uKGluc3RhbmNlKSB7XG4gIGluc3RhbmNlLnJlZ2lzdGVyRGVjb3JhdG9yKCdpbmxpbmUnLCBmdW5jdGlvbihmbiwgcHJvcHMsIGNvbnRhaW5lciwgb3B0aW9ucykge1xuICAgIGxldCByZXQgPSBmbjtcbiAgICBpZiAoIXByb3BzLnBhcnRpYWxzKSB7XG4gICAgICBwcm9wcy5wYXJ0aWFscyA9IHt9O1xuICAgICAgcmV0ID0gZnVuY3Rpb24oY29udGV4dCwgb3B0aW9ucykge1xuICAgICAgICAvLyBDcmVhdGUgYSBuZXcgcGFydGlhbHMgc3RhY2sgZnJhbWUgcHJpb3IgdG8gZXhlYy5cbiAgICAgICAgbGV0IG9yaWdpbmFsID0gY29udGFpbmVyLnBhcnRpYWxzO1xuICAgICAgICBjb250YWluZXIucGFydGlhbHMgPSBleHRlbmQoe30sIG9yaWdpbmFsLCBwcm9wcy5wYXJ0aWFscyk7XG4gICAgICAgIGxldCByZXQgPSBmbihjb250ZXh0LCBvcHRpb25zKTtcbiAgICAgICAgY29udGFpbmVyLnBhcnRpYWxzID0gb3JpZ2luYWw7XG4gICAgICAgIHJldHVybiByZXQ7XG4gICAgICB9O1xuICAgIH1cblxuICAgIHByb3BzLnBhcnRpYWxzW29wdGlvbnMuYXJnc1swXV0gPSBvcHRpb25zLmZuO1xuXG4gICAgcmV0dXJuIHJldDtcbiAgfSk7XG59XG4iXX0=


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/exception.js":
/*!******************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/exception.js ***!
  \******************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

var errorProps = ['description', 'fileName', 'lineNumber', 'message', 'name', 'number', 'stack'];

function Exception(message, node) {
  var loc = node && node.loc,
      line = undefined,
      column = undefined;
  if (loc) {
    line = loc.start.line;
    column = loc.start.column;

    message += ' - ' + line + ':' + column;
  }

  var tmp = Error.prototype.constructor.call(this, message);

  // Unfortunately errors are not enumerable in Chrome (at least), so `for prop in tmp` doesn't work.
  for (var idx = 0; idx < errorProps.length; idx++) {
    this[errorProps[idx]] = tmp[errorProps[idx]];
  }

  /* istanbul ignore else */
  if (Error.captureStackTrace) {
    Error.captureStackTrace(this, Exception);
  }

  try {
    if (loc) {
      this.lineNumber = line;

      // Work around issue under safari where we can't directly set the column value
      /* istanbul ignore next */
      if (Object.defineProperty) {
        Object.defineProperty(this, 'column', {
          value: column,
          enumerable: true
        });
      } else {
        this.column = column;
      }
    }
  } catch (nop) {
    /* Ignore if the browser is very particular */
  }
}

Exception.prototype = new Error();

exports['default'] = Exception;
module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2V4Y2VwdGlvbi5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOzs7O0FBQ0EsSUFBTSxVQUFVLEdBQUcsQ0FBQyxhQUFhLEVBQUUsVUFBVSxFQUFFLFlBQVksRUFBRSxTQUFTLEVBQUUsTUFBTSxFQUFFLFFBQVEsRUFBRSxPQUFPLENBQUMsQ0FBQzs7QUFFbkcsU0FBUyxTQUFTLENBQUMsT0FBTyxFQUFFLElBQUksRUFBRTtBQUNoQyxNQUFJLEdBQUcsR0FBRyxJQUFJLElBQUksSUFBSSxDQUFDLEdBQUc7TUFDdEIsSUFBSSxZQUFBO01BQ0osTUFBTSxZQUFBLENBQUM7QUFDWCxNQUFJLEdBQUcsRUFBRTtBQUNQLFFBQUksR0FBRyxHQUFHLENBQUMsS0FBSyxDQUFDLElBQUksQ0FBQztBQUN0QixVQUFNLEdBQUcsR0FBRyxDQUFDLEtBQUssQ0FBQyxNQUFNLENBQUM7O0FBRTFCLFdBQU8sSUFBSSxLQUFLLEdBQUcsSUFBSSxHQUFHLEdBQUcsR0FBRyxNQUFNLENBQUM7R0FDeEM7O0FBRUQsTUFBSSxHQUFHLEdBQUcsS0FBSyxDQUFDLFNBQVMsQ0FBQyxXQUFXLENBQUMsSUFBSSxDQUFDLElBQUksRUFBRSxPQUFPLENBQUMsQ0FBQzs7O0FBRzFELE9BQUssSUFBSSxHQUFHLEdBQUcsQ0FBQyxFQUFFLEdBQUcsR0FBRyxVQUFVLENBQUMsTUFBTSxFQUFFLEdBQUcsRUFBRSxFQUFFO0FBQ2hELFFBQUksQ0FBQyxVQUFVLENBQUMsR0FBRyxDQUFDLENBQUMsR0FBRyxHQUFHLENBQUMsVUFBVSxDQUFDLEdBQUcsQ0FBQyxDQUFDLENBQUM7R0FDOUM7OztBQUdELE1BQUksS0FBSyxDQUFDLGlCQUFpQixFQUFFO0FBQzNCLFNBQUssQ0FBQyxpQkFBaUIsQ0FBQyxJQUFJLEVBQUUsU0FBUyxDQUFDLENBQUM7R0FDMUM7O0FBRUQsTUFBSTtBQUNGLFFBQUksR0FBRyxFQUFFO0FBQ1AsVUFBSSxDQUFDLFVBQVUsR0FBRyxJQUFJLENBQUM7Ozs7QUFJdkIsVUFBSSxNQUFNLENBQUMsY0FBYyxFQUFFO0FBQ3pCLGNBQU0sQ0FBQyxjQUFjLENBQUMsSUFBSSxFQUFFLFFBQVEsRUFBRTtBQUNwQyxlQUFLLEVBQUUsTUFBTTtBQUNiLG9CQUFVLEVBQUUsSUFBSTtTQUNqQixDQUFDLENBQUM7T0FDSixNQUFNO0FBQ0wsWUFBSSxDQUFDLE1BQU0sR0FBRyxNQUFNLENBQUM7T0FDdEI7S0FDRjtHQUNGLENBQUMsT0FBTyxHQUFHLEVBQUU7O0dBRWI7Q0FDRjs7QUFFRCxTQUFTLENBQUMsU0FBUyxHQUFHLElBQUksS0FBSyxFQUFFLENBQUM7O3FCQUVuQixTQUFTIiwiZmlsZSI6ImV4Y2VwdGlvbi5qcyIsInNvdXJjZXNDb250ZW50IjpbIlxuY29uc3QgZXJyb3JQcm9wcyA9IFsnZGVzY3JpcHRpb24nLCAnZmlsZU5hbWUnLCAnbGluZU51bWJlcicsICdtZXNzYWdlJywgJ25hbWUnLCAnbnVtYmVyJywgJ3N0YWNrJ107XG5cbmZ1bmN0aW9uIEV4Y2VwdGlvbihtZXNzYWdlLCBub2RlKSB7XG4gIGxldCBsb2MgPSBub2RlICYmIG5vZGUubG9jLFxuICAgICAgbGluZSxcbiAgICAgIGNvbHVtbjtcbiAgaWYgKGxvYykge1xuICAgIGxpbmUgPSBsb2Muc3RhcnQubGluZTtcbiAgICBjb2x1bW4gPSBsb2Muc3RhcnQuY29sdW1uO1xuXG4gICAgbWVzc2FnZSArPSAnIC0gJyArIGxpbmUgKyAnOicgKyBjb2x1bW47XG4gIH1cblxuICBsZXQgdG1wID0gRXJyb3IucHJvdG90eXBlLmNvbnN0cnVjdG9yLmNhbGwodGhpcywgbWVzc2FnZSk7XG5cbiAgLy8gVW5mb3J0dW5hdGVseSBlcnJvcnMgYXJlIG5vdCBlbnVtZXJhYmxlIGluIENocm9tZSAoYXQgbGVhc3QpLCBzbyBgZm9yIHByb3AgaW4gdG1wYCBkb2Vzbid0IHdvcmsuXG4gIGZvciAobGV0IGlkeCA9IDA7IGlkeCA8IGVycm9yUHJvcHMubGVuZ3RoOyBpZHgrKykge1xuICAgIHRoaXNbZXJyb3JQcm9wc1tpZHhdXSA9IHRtcFtlcnJvclByb3BzW2lkeF1dO1xuICB9XG5cbiAgLyogaXN0YW5idWwgaWdub3JlIGVsc2UgKi9cbiAgaWYgKEVycm9yLmNhcHR1cmVTdGFja1RyYWNlKSB7XG4gICAgRXJyb3IuY2FwdHVyZVN0YWNrVHJhY2UodGhpcywgRXhjZXB0aW9uKTtcbiAgfVxuXG4gIHRyeSB7XG4gICAgaWYgKGxvYykge1xuICAgICAgdGhpcy5saW5lTnVtYmVyID0gbGluZTtcblxuICAgICAgLy8gV29yayBhcm91bmQgaXNzdWUgdW5kZXIgc2FmYXJpIHdoZXJlIHdlIGNhbid0IGRpcmVjdGx5IHNldCB0aGUgY29sdW1uIHZhbHVlXG4gICAgICAvKiBpc3RhbmJ1bCBpZ25vcmUgbmV4dCAqL1xuICAgICAgaWYgKE9iamVjdC5kZWZpbmVQcm9wZXJ0eSkge1xuICAgICAgICBPYmplY3QuZGVmaW5lUHJvcGVydHkodGhpcywgJ2NvbHVtbicsIHtcbiAgICAgICAgICB2YWx1ZTogY29sdW1uLFxuICAgICAgICAgIGVudW1lcmFibGU6IHRydWVcbiAgICAgICAgfSk7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0aGlzLmNvbHVtbiA9IGNvbHVtbjtcbiAgICAgIH1cbiAgICB9XG4gIH0gY2F0Y2ggKG5vcCkge1xuICAgIC8qIElnbm9yZSBpZiB0aGUgYnJvd3NlciBpcyB2ZXJ5IHBhcnRpY3VsYXIgKi9cbiAgfVxufVxuXG5FeGNlcHRpb24ucHJvdG90eXBlID0gbmV3IEVycm9yKCk7XG5cbmV4cG9ydCBkZWZhdWx0IEV4Y2VwdGlvbjtcbiJdfQ==


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/helpers.js":
/*!****************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/helpers.js ***!
  \****************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.registerDefaultHelpers = registerDefaultHelpers;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _helpersBlockHelperMissing = __webpack_require__(/*! ./helpers/block-helper-missing */ "./node_modules/handlebars/dist/cjs/handlebars/helpers/block-helper-missing.js");

var _helpersBlockHelperMissing2 = _interopRequireDefault(_helpersBlockHelperMissing);

var _helpersEach = __webpack_require__(/*! ./helpers/each */ "./node_modules/handlebars/dist/cjs/handlebars/helpers/each.js");

var _helpersEach2 = _interopRequireDefault(_helpersEach);

var _helpersHelperMissing = __webpack_require__(/*! ./helpers/helper-missing */ "./node_modules/handlebars/dist/cjs/handlebars/helpers/helper-missing.js");

var _helpersHelperMissing2 = _interopRequireDefault(_helpersHelperMissing);

var _helpersIf = __webpack_require__(/*! ./helpers/if */ "./node_modules/handlebars/dist/cjs/handlebars/helpers/if.js");

var _helpersIf2 = _interopRequireDefault(_helpersIf);

var _helpersLog = __webpack_require__(/*! ./helpers/log */ "./node_modules/handlebars/dist/cjs/handlebars/helpers/log.js");

var _helpersLog2 = _interopRequireDefault(_helpersLog);

var _helpersLookup = __webpack_require__(/*! ./helpers/lookup */ "./node_modules/handlebars/dist/cjs/handlebars/helpers/lookup.js");

var _helpersLookup2 = _interopRequireDefault(_helpersLookup);

var _helpersWith = __webpack_require__(/*! ./helpers/with */ "./node_modules/handlebars/dist/cjs/handlebars/helpers/with.js");

var _helpersWith2 = _interopRequireDefault(_helpersWith);

function registerDefaultHelpers(instance) {
  _helpersBlockHelperMissing2['default'](instance);
  _helpersEach2['default'](instance);
  _helpersHelperMissing2['default'](instance);
  _helpersIf2['default'](instance);
  _helpersLog2['default'](instance);
  _helpersLookup2['default'](instance);
  _helpersWith2['default'](instance);
}
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7eUNBQXVDLGdDQUFnQzs7OzsyQkFDOUMsZ0JBQWdCOzs7O29DQUNQLDBCQUEwQjs7Ozt5QkFDckMsY0FBYzs7OzswQkFDYixlQUFlOzs7OzZCQUNaLGtCQUFrQjs7OzsyQkFDcEIsZ0JBQWdCOzs7O0FBRWxDLFNBQVMsc0JBQXNCLENBQUMsUUFBUSxFQUFFO0FBQy9DLHlDQUEyQixRQUFRLENBQUMsQ0FBQztBQUNyQywyQkFBYSxRQUFRLENBQUMsQ0FBQztBQUN2QixvQ0FBc0IsUUFBUSxDQUFDLENBQUM7QUFDaEMseUJBQVcsUUFBUSxDQUFDLENBQUM7QUFDckIsMEJBQVksUUFBUSxDQUFDLENBQUM7QUFDdEIsNkJBQWUsUUFBUSxDQUFDLENBQUM7QUFDekIsMkJBQWEsUUFBUSxDQUFDLENBQUM7Q0FDeEIiLCJmaWxlIjoiaGVscGVycy5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCByZWdpc3RlckJsb2NrSGVscGVyTWlzc2luZyBmcm9tICcuL2hlbHBlcnMvYmxvY2staGVscGVyLW1pc3NpbmcnO1xuaW1wb3J0IHJlZ2lzdGVyRWFjaCBmcm9tICcuL2hlbHBlcnMvZWFjaCc7XG5pbXBvcnQgcmVnaXN0ZXJIZWxwZXJNaXNzaW5nIGZyb20gJy4vaGVscGVycy9oZWxwZXItbWlzc2luZyc7XG5pbXBvcnQgcmVnaXN0ZXJJZiBmcm9tICcuL2hlbHBlcnMvaWYnO1xuaW1wb3J0IHJlZ2lzdGVyTG9nIGZyb20gJy4vaGVscGVycy9sb2cnO1xuaW1wb3J0IHJlZ2lzdGVyTG9va3VwIGZyb20gJy4vaGVscGVycy9sb29rdXAnO1xuaW1wb3J0IHJlZ2lzdGVyV2l0aCBmcm9tICcuL2hlbHBlcnMvd2l0aCc7XG5cbmV4cG9ydCBmdW5jdGlvbiByZWdpc3RlckRlZmF1bHRIZWxwZXJzKGluc3RhbmNlKSB7XG4gIHJlZ2lzdGVyQmxvY2tIZWxwZXJNaXNzaW5nKGluc3RhbmNlKTtcbiAgcmVnaXN0ZXJFYWNoKGluc3RhbmNlKTtcbiAgcmVnaXN0ZXJIZWxwZXJNaXNzaW5nKGluc3RhbmNlKTtcbiAgcmVnaXN0ZXJJZihpbnN0YW5jZSk7XG4gIHJlZ2lzdGVyTG9nKGluc3RhbmNlKTtcbiAgcmVnaXN0ZXJMb29rdXAoaW5zdGFuY2UpO1xuICByZWdpc3RlcldpdGgoaW5zdGFuY2UpO1xufVxuIl19


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/helpers/block-helper-missing.js":
/*!*************************************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/helpers/block-helper-missing.js ***!
  \*************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

var _utils = __webpack_require__(/*! ../utils */ "./node_modules/handlebars/dist/cjs/handlebars/utils.js");

exports['default'] = function (instance) {
  instance.registerHelper('blockHelperMissing', function (context, options) {
    var inverse = options.inverse,
        fn = options.fn;

    if (context === true) {
      return fn(this);
    } else if (context === false || context == null) {
      return inverse(this);
    } else if (_utils.isArray(context)) {
      if (context.length > 0) {
        if (options.ids) {
          options.ids = [options.name];
        }

        return instance.helpers.each(context, options);
      } else {
        return inverse(this);
      }
    } else {
      if (options.data && options.ids) {
        var data = _utils.createFrame(options.data);
        data.contextPath = _utils.appendContextPath(options.data.contextPath, options.name);
        options = { data: data };
      }

      return fn(context, options);
    }
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvYmxvY2staGVscGVyLW1pc3NpbmcuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7OztxQkFBc0QsVUFBVTs7cUJBRWpELFVBQVMsUUFBUSxFQUFFO0FBQ2hDLFVBQVEsQ0FBQyxjQUFjLENBQUMsb0JBQW9CLEVBQUUsVUFBUyxPQUFPLEVBQUUsT0FBTyxFQUFFO0FBQ3ZFLFFBQUksT0FBTyxHQUFHLE9BQU8sQ0FBQyxPQUFPO1FBQ3pCLEVBQUUsR0FBRyxPQUFPLENBQUMsRUFBRSxDQUFDOztBQUVwQixRQUFJLE9BQU8sS0FBSyxJQUFJLEVBQUU7QUFDcEIsYUFBTyxFQUFFLENBQUMsSUFBSSxDQUFDLENBQUM7S0FDakIsTUFBTSxJQUFJLE9BQU8sS0FBSyxLQUFLLElBQUksT0FBTyxJQUFJLElBQUksRUFBRTtBQUMvQyxhQUFPLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQztLQUN0QixNQUFNLElBQUksZUFBUSxPQUFPLENBQUMsRUFBRTtBQUMzQixVQUFJLE9BQU8sQ0FBQyxNQUFNLEdBQUcsQ0FBQyxFQUFFO0FBQ3RCLFlBQUksT0FBTyxDQUFDLEdBQUcsRUFBRTtBQUNmLGlCQUFPLENBQUMsR0FBRyxHQUFHLENBQUMsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDO1NBQzlCOztBQUVELGVBQU8sUUFBUSxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsT0FBTyxFQUFFLE9BQU8sQ0FBQyxDQUFDO09BQ2hELE1BQU07QUFDTCxlQUFPLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQztPQUN0QjtLQUNGLE1BQU07QUFDTCxVQUFJLE9BQU8sQ0FBQyxJQUFJLElBQUksT0FBTyxDQUFDLEdBQUcsRUFBRTtBQUMvQixZQUFJLElBQUksR0FBRyxtQkFBWSxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUM7QUFDckMsWUFBSSxDQUFDLFdBQVcsR0FBRyx5QkFBa0IsT0FBTyxDQUFDLElBQUksQ0FBQyxXQUFXLEVBQUUsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDO0FBQzdFLGVBQU8sR0FBRyxFQUFDLElBQUksRUFBRSxJQUFJLEVBQUMsQ0FBQztPQUN4Qjs7QUFFRCxhQUFPLEVBQUUsQ0FBQyxPQUFPLEVBQUUsT0FBTyxDQUFDLENBQUM7S0FDN0I7R0FDRixDQUFDLENBQUM7Q0FDSiIsImZpbGUiOiJibG9jay1oZWxwZXItbWlzc2luZy5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7YXBwZW5kQ29udGV4dFBhdGgsIGNyZWF0ZUZyYW1lLCBpc0FycmF5fSBmcm9tICcuLi91dGlscyc7XG5cbmV4cG9ydCBkZWZhdWx0IGZ1bmN0aW9uKGluc3RhbmNlKSB7XG4gIGluc3RhbmNlLnJlZ2lzdGVySGVscGVyKCdibG9ja0hlbHBlck1pc3NpbmcnLCBmdW5jdGlvbihjb250ZXh0LCBvcHRpb25zKSB7XG4gICAgbGV0IGludmVyc2UgPSBvcHRpb25zLmludmVyc2UsXG4gICAgICAgIGZuID0gb3B0aW9ucy5mbjtcblxuICAgIGlmIChjb250ZXh0ID09PSB0cnVlKSB7XG4gICAgICByZXR1cm4gZm4odGhpcyk7XG4gICAgfSBlbHNlIGlmIChjb250ZXh0ID09PSBmYWxzZSB8fCBjb250ZXh0ID09IG51bGwpIHtcbiAgICAgIHJldHVybiBpbnZlcnNlKHRoaXMpO1xuICAgIH0gZWxzZSBpZiAoaXNBcnJheShjb250ZXh0KSkge1xuICAgICAgaWYgKGNvbnRleHQubGVuZ3RoID4gMCkge1xuICAgICAgICBpZiAob3B0aW9ucy5pZHMpIHtcbiAgICAgICAgICBvcHRpb25zLmlkcyA9IFtvcHRpb25zLm5hbWVdO1xuICAgICAgICB9XG5cbiAgICAgICAgcmV0dXJuIGluc3RhbmNlLmhlbHBlcnMuZWFjaChjb250ZXh0LCBvcHRpb25zKTtcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHJldHVybiBpbnZlcnNlKHRoaXMpO1xuICAgICAgfVxuICAgIH0gZWxzZSB7XG4gICAgICBpZiAob3B0aW9ucy5kYXRhICYmIG9wdGlvbnMuaWRzKSB7XG4gICAgICAgIGxldCBkYXRhID0gY3JlYXRlRnJhbWUob3B0aW9ucy5kYXRhKTtcbiAgICAgICAgZGF0YS5jb250ZXh0UGF0aCA9IGFwcGVuZENvbnRleHRQYXRoKG9wdGlvbnMuZGF0YS5jb250ZXh0UGF0aCwgb3B0aW9ucy5uYW1lKTtcbiAgICAgICAgb3B0aW9ucyA9IHtkYXRhOiBkYXRhfTtcbiAgICAgIH1cblxuICAgICAgcmV0dXJuIGZuKGNvbnRleHQsIG9wdGlvbnMpO1xuICAgIH1cbiAgfSk7XG59XG4iXX0=


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/helpers/each.js":
/*!*********************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/helpers/each.js ***!
  \*********************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _utils = __webpack_require__(/*! ../utils */ "./node_modules/handlebars/dist/cjs/handlebars/utils.js");

var _exception = __webpack_require__(/*! ../exception */ "./node_modules/handlebars/dist/cjs/handlebars/exception.js");

var _exception2 = _interopRequireDefault(_exception);

exports['default'] = function (instance) {
  instance.registerHelper('each', function (context, options) {
    if (!options) {
      throw new _exception2['default']('Must pass iterator to #each');
    }

    var fn = options.fn,
        inverse = options.inverse,
        i = 0,
        ret = '',
        data = undefined,
        contextPath = undefined;

    if (options.data && options.ids) {
      contextPath = _utils.appendContextPath(options.data.contextPath, options.ids[0]) + '.';
    }

    if (_utils.isFunction(context)) {
      context = context.call(this);
    }

    if (options.data) {
      data = _utils.createFrame(options.data);
    }

    function execIteration(field, index, last) {
      if (data) {
        data.key = field;
        data.index = index;
        data.first = index === 0;
        data.last = !!last;

        if (contextPath) {
          data.contextPath = contextPath + field;
        }
      }

      ret = ret + fn(context[field], {
        data: data,
        blockParams: _utils.blockParams([context[field], field], [contextPath + field, null])
      });
    }

    if (context && typeof context === 'object') {
      if (_utils.isArray(context)) {
        for (var j = context.length; i < j; i++) {
          if (i in context) {
            execIteration(i, i, i === context.length - 1);
          }
        }
      } else {
        var priorKey = undefined;

        for (var key in context) {
          if (context.hasOwnProperty(key)) {
            // We're running the iterations one step out of sync so we can detect
            // the last iteration without have to scan the object twice and create
            // an itermediate keys array.
            if (priorKey !== undefined) {
              execIteration(priorKey, i - 1);
            }
            priorKey = key;
            i++;
          }
        }
        if (priorKey !== undefined) {
          execIteration(priorKey, i - 1, true);
        }
      }
    }

    if (i === 0) {
      ret = inverse(this);
    }

    return ret;
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvZWFjaC5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOzs7Ozs7O3FCQUErRSxVQUFVOzt5QkFDbkUsY0FBYzs7OztxQkFFckIsVUFBUyxRQUFRLEVBQUU7QUFDaEMsVUFBUSxDQUFDLGNBQWMsQ0FBQyxNQUFNLEVBQUUsVUFBUyxPQUFPLEVBQUUsT0FBTyxFQUFFO0FBQ3pELFFBQUksQ0FBQyxPQUFPLEVBQUU7QUFDWixZQUFNLDJCQUFjLDZCQUE2QixDQUFDLENBQUM7S0FDcEQ7O0FBRUQsUUFBSSxFQUFFLEdBQUcsT0FBTyxDQUFDLEVBQUU7UUFDZixPQUFPLEdBQUcsT0FBTyxDQUFDLE9BQU87UUFDekIsQ0FBQyxHQUFHLENBQUM7UUFDTCxHQUFHLEdBQUcsRUFBRTtRQUNSLElBQUksWUFBQTtRQUNKLFdBQVcsWUFBQSxDQUFDOztBQUVoQixRQUFJLE9BQU8sQ0FBQyxJQUFJLElBQUksT0FBTyxDQUFDLEdBQUcsRUFBRTtBQUMvQixpQkFBVyxHQUFHLHlCQUFrQixPQUFPLENBQUMsSUFBSSxDQUFDLFdBQVcsRUFBRSxPQUFPLENBQUMsR0FBRyxDQUFDLENBQUMsQ0FBQyxDQUFDLEdBQUcsR0FBRyxDQUFDO0tBQ2pGOztBQUVELFFBQUksa0JBQVcsT0FBTyxDQUFDLEVBQUU7QUFBRSxhQUFPLEdBQUcsT0FBTyxDQUFDLElBQUksQ0FBQyxJQUFJLENBQUMsQ0FBQztLQUFFOztBQUUxRCxRQUFJLE9BQU8sQ0FBQyxJQUFJLEVBQUU7QUFDaEIsVUFBSSxHQUFHLG1CQUFZLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQztLQUNsQzs7QUFFRCxhQUFTLGFBQWEsQ0FBQyxLQUFLLEVBQUUsS0FBSyxFQUFFLElBQUksRUFBRTtBQUN6QyxVQUFJLElBQUksRUFBRTtBQUNSLFlBQUksQ0FBQyxHQUFHLEdBQUcsS0FBSyxDQUFDO0FBQ2pCLFlBQUksQ0FBQyxLQUFLLEdBQUcsS0FBSyxDQUFDO0FBQ25CLFlBQUksQ0FBQyxLQUFLLEdBQUcsS0FBSyxLQUFLLENBQUMsQ0FBQztBQUN6QixZQUFJLENBQUMsSUFBSSxHQUFHLENBQUMsQ0FBQyxJQUFJLENBQUM7O0FBRW5CLFlBQUksV0FBVyxFQUFFO0FBQ2YsY0FBSSxDQUFDLFdBQVcsR0FBRyxXQUFXLEdBQUcsS0FBSyxDQUFDO1NBQ3hDO09BQ0Y7O0FBRUQsU0FBRyxHQUFHLEdBQUcsR0FBRyxFQUFFLENBQUMsT0FBTyxDQUFDLEtBQUssQ0FBQyxFQUFFO0FBQzdCLFlBQUksRUFBRSxJQUFJO0FBQ1YsbUJBQVcsRUFBRSxtQkFBWSxDQUFDLE9BQU8sQ0FBQyxLQUFLLENBQUMsRUFBRSxLQUFLLENBQUMsRUFBRSxDQUFDLFdBQVcsR0FBRyxLQUFLLEVBQUUsSUFBSSxDQUFDLENBQUM7T0FDL0UsQ0FBQyxDQUFDO0tBQ0o7O0FBRUQsUUFBSSxPQUFPLElBQUksT0FBTyxPQUFPLEtBQUssUUFBUSxFQUFFO0FBQzFDLFVBQUksZUFBUSxPQUFPLENBQUMsRUFBRTtBQUNwQixhQUFLLElBQUksQ0FBQyxHQUFHLE9BQU8sQ0FBQyxNQUFNLEVBQUUsQ0FBQyxHQUFHLENBQUMsRUFBRSxDQUFDLEVBQUUsRUFBRTtBQUN2QyxjQUFJLENBQUMsSUFBSSxPQUFPLEVBQUU7QUFDaEIseUJBQWEsQ0FBQyxDQUFDLEVBQUUsQ0FBQyxFQUFFLENBQUMsS0FBSyxPQUFPLENBQUMsTUFBTSxHQUFHLENBQUMsQ0FBQyxDQUFDO1dBQy9DO1NBQ0Y7T0FDRixNQUFNO0FBQ0wsWUFBSSxRQUFRLFlBQUEsQ0FBQzs7QUFFYixhQUFLLElBQUksR0FBRyxJQUFJLE9BQU8sRUFBRTtBQUN2QixjQUFJLE9BQU8sQ0FBQyxjQUFjLENBQUMsR0FBRyxDQUFDLEVBQUU7Ozs7QUFJL0IsZ0JBQUksUUFBUSxLQUFLLFNBQVMsRUFBRTtBQUMxQiwyQkFBYSxDQUFDLFFBQVEsRUFBRSxDQUFDLEdBQUcsQ0FBQyxDQUFDLENBQUM7YUFDaEM7QUFDRCxvQkFBUSxHQUFHLEdBQUcsQ0FBQztBQUNmLGFBQUMsRUFBRSxDQUFDO1dBQ0w7U0FDRjtBQUNELFlBQUksUUFBUSxLQUFLLFNBQVMsRUFBRTtBQUMxQix1QkFBYSxDQUFDLFFBQVEsRUFBRSxDQUFDLEdBQUcsQ0FBQyxFQUFFLElBQUksQ0FBQyxDQUFDO1NBQ3RDO09BQ0Y7S0FDRjs7QUFFRCxRQUFJLENBQUMsS0FBSyxDQUFDLEVBQUU7QUFDWCxTQUFHLEdBQUcsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDO0tBQ3JCOztBQUVELFdBQU8sR0FBRyxDQUFDO0dBQ1osQ0FBQyxDQUFDO0NBQ0oiLCJmaWxlIjoiZWFjaC5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7YXBwZW5kQ29udGV4dFBhdGgsIGJsb2NrUGFyYW1zLCBjcmVhdGVGcmFtZSwgaXNBcnJheSwgaXNGdW5jdGlvbn0gZnJvbSAnLi4vdXRpbHMnO1xuaW1wb3J0IEV4Y2VwdGlvbiBmcm9tICcuLi9leGNlcHRpb24nO1xuXG5leHBvcnQgZGVmYXVsdCBmdW5jdGlvbihpbnN0YW5jZSkge1xuICBpbnN0YW5jZS5yZWdpc3RlckhlbHBlcignZWFjaCcsIGZ1bmN0aW9uKGNvbnRleHQsIG9wdGlvbnMpIHtcbiAgICBpZiAoIW9wdGlvbnMpIHtcbiAgICAgIHRocm93IG5ldyBFeGNlcHRpb24oJ011c3QgcGFzcyBpdGVyYXRvciB0byAjZWFjaCcpO1xuICAgIH1cblxuICAgIGxldCBmbiA9IG9wdGlvbnMuZm4sXG4gICAgICAgIGludmVyc2UgPSBvcHRpb25zLmludmVyc2UsXG4gICAgICAgIGkgPSAwLFxuICAgICAgICByZXQgPSAnJyxcbiAgICAgICAgZGF0YSxcbiAgICAgICAgY29udGV4dFBhdGg7XG5cbiAgICBpZiAob3B0aW9ucy5kYXRhICYmIG9wdGlvbnMuaWRzKSB7XG4gICAgICBjb250ZXh0UGF0aCA9IGFwcGVuZENvbnRleHRQYXRoKG9wdGlvbnMuZGF0YS5jb250ZXh0UGF0aCwgb3B0aW9ucy5pZHNbMF0pICsgJy4nO1xuICAgIH1cblxuICAgIGlmIChpc0Z1bmN0aW9uKGNvbnRleHQpKSB7IGNvbnRleHQgPSBjb250ZXh0LmNhbGwodGhpcyk7IH1cblxuICAgIGlmIChvcHRpb25zLmRhdGEpIHtcbiAgICAgIGRhdGEgPSBjcmVhdGVGcmFtZShvcHRpb25zLmRhdGEpO1xuICAgIH1cblxuICAgIGZ1bmN0aW9uIGV4ZWNJdGVyYXRpb24oZmllbGQsIGluZGV4LCBsYXN0KSB7XG4gICAgICBpZiAoZGF0YSkge1xuICAgICAgICBkYXRhLmtleSA9IGZpZWxkO1xuICAgICAgICBkYXRhLmluZGV4ID0gaW5kZXg7XG4gICAgICAgIGRhdGEuZmlyc3QgPSBpbmRleCA9PT0gMDtcbiAgICAgICAgZGF0YS5sYXN0ID0gISFsYXN0O1xuXG4gICAgICAgIGlmIChjb250ZXh0UGF0aCkge1xuICAgICAgICAgIGRhdGEuY29udGV4dFBhdGggPSBjb250ZXh0UGF0aCArIGZpZWxkO1xuICAgICAgICB9XG4gICAgICB9XG5cbiAgICAgIHJldCA9IHJldCArIGZuKGNvbnRleHRbZmllbGRdLCB7XG4gICAgICAgIGRhdGE6IGRhdGEsXG4gICAgICAgIGJsb2NrUGFyYW1zOiBibG9ja1BhcmFtcyhbY29udGV4dFtmaWVsZF0sIGZpZWxkXSwgW2NvbnRleHRQYXRoICsgZmllbGQsIG51bGxdKVxuICAgICAgfSk7XG4gICAgfVxuXG4gICAgaWYgKGNvbnRleHQgJiYgdHlwZW9mIGNvbnRleHQgPT09ICdvYmplY3QnKSB7XG4gICAgICBpZiAoaXNBcnJheShjb250ZXh0KSkge1xuICAgICAgICBmb3IgKGxldCBqID0gY29udGV4dC5sZW5ndGg7IGkgPCBqOyBpKyspIHtcbiAgICAgICAgICBpZiAoaSBpbiBjb250ZXh0KSB7XG4gICAgICAgICAgICBleGVjSXRlcmF0aW9uKGksIGksIGkgPT09IGNvbnRleHQubGVuZ3RoIC0gMSk7XG4gICAgICAgICAgfVxuICAgICAgICB9XG4gICAgICB9IGVsc2Uge1xuICAgICAgICBsZXQgcHJpb3JLZXk7XG5cbiAgICAgICAgZm9yIChsZXQga2V5IGluIGNvbnRleHQpIHtcbiAgICAgICAgICBpZiAoY29udGV4dC5oYXNPd25Qcm9wZXJ0eShrZXkpKSB7XG4gICAgICAgICAgICAvLyBXZSdyZSBydW5uaW5nIHRoZSBpdGVyYXRpb25zIG9uZSBzdGVwIG91dCBvZiBzeW5jIHNvIHdlIGNhbiBkZXRlY3RcbiAgICAgICAgICAgIC8vIHRoZSBsYXN0IGl0ZXJhdGlvbiB3aXRob3V0IGhhdmUgdG8gc2NhbiB0aGUgb2JqZWN0IHR3aWNlIGFuZCBjcmVhdGVcbiAgICAgICAgICAgIC8vIGFuIGl0ZXJtZWRpYXRlIGtleXMgYXJyYXkuXG4gICAgICAgICAgICBpZiAocHJpb3JLZXkgIT09IHVuZGVmaW5lZCkge1xuICAgICAgICAgICAgICBleGVjSXRlcmF0aW9uKHByaW9yS2V5LCBpIC0gMSk7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBwcmlvcktleSA9IGtleTtcbiAgICAgICAgICAgIGkrKztcbiAgICAgICAgICB9XG4gICAgICAgIH1cbiAgICAgICAgaWYgKHByaW9yS2V5ICE9PSB1bmRlZmluZWQpIHtcbiAgICAgICAgICBleGVjSXRlcmF0aW9uKHByaW9yS2V5LCBpIC0gMSwgdHJ1ZSk7XG4gICAgICAgIH1cbiAgICAgIH1cbiAgICB9XG5cbiAgICBpZiAoaSA9PT0gMCkge1xuICAgICAgcmV0ID0gaW52ZXJzZSh0aGlzKTtcbiAgICB9XG5cbiAgICByZXR1cm4gcmV0O1xuICB9KTtcbn1cbiJdfQ==


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/helpers/helper-missing.js":
/*!*******************************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/helpers/helper-missing.js ***!
  \*******************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _exception = __webpack_require__(/*! ../exception */ "./node_modules/handlebars/dist/cjs/handlebars/exception.js");

var _exception2 = _interopRequireDefault(_exception);

exports['default'] = function (instance) {
  instance.registerHelper('helperMissing', function () /* [args, ]options */{
    if (arguments.length === 1) {
      // A missing field in a {{foo}} construct.
      return undefined;
    } else {
      // Someone is actually trying to call something, blow up.
      throw new _exception2['default']('Missing helper: "' + arguments[arguments.length - 1].name + '"');
    }
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvaGVscGVyLW1pc3NpbmcuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozt5QkFBc0IsY0FBYzs7OztxQkFFckIsVUFBUyxRQUFRLEVBQUU7QUFDaEMsVUFBUSxDQUFDLGNBQWMsQ0FBQyxlQUFlLEVBQUUsaUNBQWdDO0FBQ3ZFLFFBQUksU0FBUyxDQUFDLE1BQU0sS0FBSyxDQUFDLEVBQUU7O0FBRTFCLGFBQU8sU0FBUyxDQUFDO0tBQ2xCLE1BQU07O0FBRUwsWUFBTSwyQkFBYyxtQkFBbUIsR0FBRyxTQUFTLENBQUMsU0FBUyxDQUFDLE1BQU0sR0FBRyxDQUFDLENBQUMsQ0FBQyxJQUFJLEdBQUcsR0FBRyxDQUFDLENBQUM7S0FDdkY7R0FDRixDQUFDLENBQUM7Q0FDSiIsImZpbGUiOiJoZWxwZXItbWlzc2luZy5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCBFeGNlcHRpb24gZnJvbSAnLi4vZXhjZXB0aW9uJztcblxuZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24oaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ2hlbHBlck1pc3NpbmcnLCBmdW5jdGlvbigvKiBbYXJncywgXW9wdGlvbnMgKi8pIHtcbiAgICBpZiAoYXJndW1lbnRzLmxlbmd0aCA9PT0gMSkge1xuICAgICAgLy8gQSBtaXNzaW5nIGZpZWxkIGluIGEge3tmb299fSBjb25zdHJ1Y3QuXG4gICAgICByZXR1cm4gdW5kZWZpbmVkO1xuICAgIH0gZWxzZSB7XG4gICAgICAvLyBTb21lb25lIGlzIGFjdHVhbGx5IHRyeWluZyB0byBjYWxsIHNvbWV0aGluZywgYmxvdyB1cC5cbiAgICAgIHRocm93IG5ldyBFeGNlcHRpb24oJ01pc3NpbmcgaGVscGVyOiBcIicgKyBhcmd1bWVudHNbYXJndW1lbnRzLmxlbmd0aCAtIDFdLm5hbWUgKyAnXCInKTtcbiAgICB9XG4gIH0pO1xufVxuIl19


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/helpers/if.js":
/*!*******************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/helpers/if.js ***!
  \*******************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

var _utils = __webpack_require__(/*! ../utils */ "./node_modules/handlebars/dist/cjs/handlebars/utils.js");

exports['default'] = function (instance) {
  instance.registerHelper('if', function (conditional, options) {
    if (_utils.isFunction(conditional)) {
      conditional = conditional.call(this);
    }

    // Default behavior is to render the positive path if the value is truthy and not empty.
    // The `includeZero` option may be set to treat the condtional as purely not empty based on the
    // behavior of isEmpty. Effectively this determines if 0 is handled by the positive path or negative.
    if (!options.hash.includeZero && !conditional || _utils.isEmpty(conditional)) {
      return options.inverse(this);
    } else {
      return options.fn(this);
    }
  });

  instance.registerHelper('unless', function (conditional, options) {
    return instance.helpers['if'].call(this, conditional, { fn: options.inverse, inverse: options.fn, hash: options.hash });
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvaWYuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7OztxQkFBa0MsVUFBVTs7cUJBRTdCLFVBQVMsUUFBUSxFQUFFO0FBQ2hDLFVBQVEsQ0FBQyxjQUFjLENBQUMsSUFBSSxFQUFFLFVBQVMsV0FBVyxFQUFFLE9BQU8sRUFBRTtBQUMzRCxRQUFJLGtCQUFXLFdBQVcsQ0FBQyxFQUFFO0FBQUUsaUJBQVcsR0FBRyxXQUFXLENBQUMsSUFBSSxDQUFDLElBQUksQ0FBQyxDQUFDO0tBQUU7Ozs7O0FBS3RFLFFBQUksQUFBQyxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsV0FBVyxJQUFJLENBQUMsV0FBVyxJQUFLLGVBQVEsV0FBVyxDQUFDLEVBQUU7QUFDdkUsYUFBTyxPQUFPLENBQUMsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDO0tBQzlCLE1BQU07QUFDTCxhQUFPLE9BQU8sQ0FBQyxFQUFFLENBQUMsSUFBSSxDQUFDLENBQUM7S0FDekI7R0FDRixDQUFDLENBQUM7O0FBRUgsVUFBUSxDQUFDLGNBQWMsQ0FBQyxRQUFRLEVBQUUsVUFBUyxXQUFXLEVBQUUsT0FBTyxFQUFFO0FBQy9ELFdBQU8sUUFBUSxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQyxJQUFJLENBQUMsSUFBSSxFQUFFLFdBQVcsRUFBRSxFQUFDLEVBQUUsRUFBRSxPQUFPLENBQUMsT0FBTyxFQUFFLE9BQU8sRUFBRSxPQUFPLENBQUMsRUFBRSxFQUFFLElBQUksRUFBRSxPQUFPLENBQUMsSUFBSSxFQUFDLENBQUMsQ0FBQztHQUN2SCxDQUFDLENBQUM7Q0FDSiIsImZpbGUiOiJpZi5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7aXNFbXB0eSwgaXNGdW5jdGlvbn0gZnJvbSAnLi4vdXRpbHMnO1xuXG5leHBvcnQgZGVmYXVsdCBmdW5jdGlvbihpbnN0YW5jZSkge1xuICBpbnN0YW5jZS5yZWdpc3RlckhlbHBlcignaWYnLCBmdW5jdGlvbihjb25kaXRpb25hbCwgb3B0aW9ucykge1xuICAgIGlmIChpc0Z1bmN0aW9uKGNvbmRpdGlvbmFsKSkgeyBjb25kaXRpb25hbCA9IGNvbmRpdGlvbmFsLmNhbGwodGhpcyk7IH1cblxuICAgIC8vIERlZmF1bHQgYmVoYXZpb3IgaXMgdG8gcmVuZGVyIHRoZSBwb3NpdGl2ZSBwYXRoIGlmIHRoZSB2YWx1ZSBpcyB0cnV0aHkgYW5kIG5vdCBlbXB0eS5cbiAgICAvLyBUaGUgYGluY2x1ZGVaZXJvYCBvcHRpb24gbWF5IGJlIHNldCB0byB0cmVhdCB0aGUgY29uZHRpb25hbCBhcyBwdXJlbHkgbm90IGVtcHR5IGJhc2VkIG9uIHRoZVxuICAgIC8vIGJlaGF2aW9yIG9mIGlzRW1wdHkuIEVmZmVjdGl2ZWx5IHRoaXMgZGV0ZXJtaW5lcyBpZiAwIGlzIGhhbmRsZWQgYnkgdGhlIHBvc2l0aXZlIHBhdGggb3IgbmVnYXRpdmUuXG4gICAgaWYgKCghb3B0aW9ucy5oYXNoLmluY2x1ZGVaZXJvICYmICFjb25kaXRpb25hbCkgfHwgaXNFbXB0eShjb25kaXRpb25hbCkpIHtcbiAgICAgIHJldHVybiBvcHRpb25zLmludmVyc2UodGhpcyk7XG4gICAgfSBlbHNlIHtcbiAgICAgIHJldHVybiBvcHRpb25zLmZuKHRoaXMpO1xuICAgIH1cbiAgfSk7XG5cbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ3VubGVzcycsIGZ1bmN0aW9uKGNvbmRpdGlvbmFsLCBvcHRpb25zKSB7XG4gICAgcmV0dXJuIGluc3RhbmNlLmhlbHBlcnNbJ2lmJ10uY2FsbCh0aGlzLCBjb25kaXRpb25hbCwge2ZuOiBvcHRpb25zLmludmVyc2UsIGludmVyc2U6IG9wdGlvbnMuZm4sIGhhc2g6IG9wdGlvbnMuaGFzaH0pO1xuICB9KTtcbn1cbiJdfQ==


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/helpers/log.js":
/*!********************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/helpers/log.js ***!
  \********************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

exports['default'] = function (instance) {
  instance.registerHelper('log', function () /* message, options */{
    var args = [undefined],
        options = arguments[arguments.length - 1];
    for (var i = 0; i < arguments.length - 1; i++) {
      args.push(arguments[i]);
    }

    var level = 1;
    if (options.hash.level != null) {
      level = options.hash.level;
    } else if (options.data && options.data.level != null) {
      level = options.data.level;
    }
    args[0] = level;

    instance.log.apply(instance, args);
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvbG9nLmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7cUJBQWUsVUFBUyxRQUFRLEVBQUU7QUFDaEMsVUFBUSxDQUFDLGNBQWMsQ0FBQyxLQUFLLEVBQUUsa0NBQWlDO0FBQzlELFFBQUksSUFBSSxHQUFHLENBQUMsU0FBUyxDQUFDO1FBQ2xCLE9BQU8sR0FBRyxTQUFTLENBQUMsU0FBUyxDQUFDLE1BQU0sR0FBRyxDQUFDLENBQUMsQ0FBQztBQUM5QyxTQUFLLElBQUksQ0FBQyxHQUFHLENBQUMsRUFBRSxDQUFDLEdBQUcsU0FBUyxDQUFDLE1BQU0sR0FBRyxDQUFDLEVBQUUsQ0FBQyxFQUFFLEVBQUU7QUFDN0MsVUFBSSxDQUFDLElBQUksQ0FBQyxTQUFTLENBQUMsQ0FBQyxDQUFDLENBQUMsQ0FBQztLQUN6Qjs7QUFFRCxRQUFJLEtBQUssR0FBRyxDQUFDLENBQUM7QUFDZCxRQUFJLE9BQU8sQ0FBQyxJQUFJLENBQUMsS0FBSyxJQUFJLElBQUksRUFBRTtBQUM5QixXQUFLLEdBQUcsT0FBTyxDQUFDLElBQUksQ0FBQyxLQUFLLENBQUM7S0FDNUIsTUFBTSxJQUFJLE9BQU8sQ0FBQyxJQUFJLElBQUksT0FBTyxDQUFDLElBQUksQ0FBQyxLQUFLLElBQUksSUFBSSxFQUFFO0FBQ3JELFdBQUssR0FBRyxPQUFPLENBQUMsSUFBSSxDQUFDLEtBQUssQ0FBQztLQUM1QjtBQUNELFFBQUksQ0FBQyxDQUFDLENBQUMsR0FBRyxLQUFLLENBQUM7O0FBRWhCLFlBQVEsQ0FBQyxHQUFHLE1BQUEsQ0FBWixRQUFRLEVBQVMsSUFBSSxDQUFDLENBQUM7R0FDeEIsQ0FBQyxDQUFDO0NBQ0oiLCJmaWxlIjoibG9nLmpzIiwic291cmNlc0NvbnRlbnQiOlsiZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24oaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ2xvZycsIGZ1bmN0aW9uKC8qIG1lc3NhZ2UsIG9wdGlvbnMgKi8pIHtcbiAgICBsZXQgYXJncyA9IFt1bmRlZmluZWRdLFxuICAgICAgICBvcHRpb25zID0gYXJndW1lbnRzW2FyZ3VtZW50cy5sZW5ndGggLSAxXTtcbiAgICBmb3IgKGxldCBpID0gMDsgaSA8IGFyZ3VtZW50cy5sZW5ndGggLSAxOyBpKyspIHtcbiAgICAgIGFyZ3MucHVzaChhcmd1bWVudHNbaV0pO1xuICAgIH1cblxuICAgIGxldCBsZXZlbCA9IDE7XG4gICAgaWYgKG9wdGlvbnMuaGFzaC5sZXZlbCAhPSBudWxsKSB7XG4gICAgICBsZXZlbCA9IG9wdGlvbnMuaGFzaC5sZXZlbDtcbiAgICB9IGVsc2UgaWYgKG9wdGlvbnMuZGF0YSAmJiBvcHRpb25zLmRhdGEubGV2ZWwgIT0gbnVsbCkge1xuICAgICAgbGV2ZWwgPSBvcHRpb25zLmRhdGEubGV2ZWw7XG4gICAgfVxuICAgIGFyZ3NbMF0gPSBsZXZlbDtcblxuICAgIGluc3RhbmNlLmxvZyguLi4gYXJncyk7XG4gIH0pO1xufVxuIl19


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/helpers/lookup.js":
/*!***********************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/helpers/lookup.js ***!
  \***********************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

exports['default'] = function (instance) {
  instance.registerHelper('lookup', function (obj, field) {
    if (!obj) {
      return obj;
    }
    if (field === 'constructor' && !obj.propertyIsEnumerable(field)) {
      return undefined;
    }
    return obj[field];
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvbG9va3VwLmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7cUJBQWUsVUFBUyxRQUFRLEVBQUU7QUFDaEMsVUFBUSxDQUFDLGNBQWMsQ0FBQyxRQUFRLEVBQUUsVUFBUyxHQUFHLEVBQUUsS0FBSyxFQUFFO0FBQ3JELFFBQUksQ0FBQyxHQUFHLEVBQUU7QUFDUixhQUFPLEdBQUcsQ0FBQztLQUNaO0FBQ0QsUUFBSSxLQUFLLEtBQUssYUFBYSxJQUFJLENBQUMsR0FBRyxDQUFDLG9CQUFvQixDQUFDLEtBQUssQ0FBQyxFQUFFO0FBQy9ELGFBQU8sU0FBUyxDQUFDO0tBQ2xCO0FBQ0QsV0FBTyxHQUFHLENBQUMsS0FBSyxDQUFDLENBQUM7R0FDbkIsQ0FBQyxDQUFDO0NBQ0oiLCJmaWxlIjoibG9va3VwLmpzIiwic291cmNlc0NvbnRlbnQiOlsiZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24oaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ2xvb2t1cCcsIGZ1bmN0aW9uKG9iaiwgZmllbGQpIHtcbiAgICBpZiAoIW9iaikge1xuICAgICAgcmV0dXJuIG9iajtcbiAgICB9XG4gICAgaWYgKGZpZWxkID09PSAnY29uc3RydWN0b3InICYmICFvYmoucHJvcGVydHlJc0VudW1lcmFibGUoZmllbGQpKSB7XG4gICAgICByZXR1cm4gdW5kZWZpbmVkO1xuICAgIH1cbiAgICByZXR1cm4gb2JqW2ZpZWxkXTtcbiAgfSk7XG59XG4iXX0=


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/helpers/with.js":
/*!*********************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/helpers/with.js ***!
  \*********************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

var _utils = __webpack_require__(/*! ../utils */ "./node_modules/handlebars/dist/cjs/handlebars/utils.js");

exports['default'] = function (instance) {
  instance.registerHelper('with', function (context, options) {
    if (_utils.isFunction(context)) {
      context = context.call(this);
    }

    var fn = options.fn;

    if (!_utils.isEmpty(context)) {
      var data = options.data;
      if (options.data && options.ids) {
        data = _utils.createFrame(options.data);
        data.contextPath = _utils.appendContextPath(options.data.contextPath, options.ids[0]);
      }

      return fn(context, {
        data: data,
        blockParams: _utils.blockParams([context], [data && data.contextPath])
      });
    } else {
      return options.inverse(this);
    }
  });
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2hlbHBlcnMvd2l0aC5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOzs7O3FCQUErRSxVQUFVOztxQkFFMUUsVUFBUyxRQUFRLEVBQUU7QUFDaEMsVUFBUSxDQUFDLGNBQWMsQ0FBQyxNQUFNLEVBQUUsVUFBUyxPQUFPLEVBQUUsT0FBTyxFQUFFO0FBQ3pELFFBQUksa0JBQVcsT0FBTyxDQUFDLEVBQUU7QUFBRSxhQUFPLEdBQUcsT0FBTyxDQUFDLElBQUksQ0FBQyxJQUFJLENBQUMsQ0FBQztLQUFFOztBQUUxRCxRQUFJLEVBQUUsR0FBRyxPQUFPLENBQUMsRUFBRSxDQUFDOztBQUVwQixRQUFJLENBQUMsZUFBUSxPQUFPLENBQUMsRUFBRTtBQUNyQixVQUFJLElBQUksR0FBRyxPQUFPLENBQUMsSUFBSSxDQUFDO0FBQ3hCLFVBQUksT0FBTyxDQUFDLElBQUksSUFBSSxPQUFPLENBQUMsR0FBRyxFQUFFO0FBQy9CLFlBQUksR0FBRyxtQkFBWSxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUM7QUFDakMsWUFBSSxDQUFDLFdBQVcsR0FBRyx5QkFBa0IsT0FBTyxDQUFDLElBQUksQ0FBQyxXQUFXLEVBQUUsT0FBTyxDQUFDLEdBQUcsQ0FBQyxDQUFDLENBQUMsQ0FBQyxDQUFDO09BQ2hGOztBQUVELGFBQU8sRUFBRSxDQUFDLE9BQU8sRUFBRTtBQUNqQixZQUFJLEVBQUUsSUFBSTtBQUNWLG1CQUFXLEVBQUUsbUJBQVksQ0FBQyxPQUFPLENBQUMsRUFBRSxDQUFDLElBQUksSUFBSSxJQUFJLENBQUMsV0FBVyxDQUFDLENBQUM7T0FDaEUsQ0FBQyxDQUFDO0tBQ0osTUFBTTtBQUNMLGFBQU8sT0FBTyxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQztLQUM5QjtHQUNGLENBQUMsQ0FBQztDQUNKIiwiZmlsZSI6IndpdGguanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQge2FwcGVuZENvbnRleHRQYXRoLCBibG9ja1BhcmFtcywgY3JlYXRlRnJhbWUsIGlzRW1wdHksIGlzRnVuY3Rpb259IGZyb20gJy4uL3V0aWxzJztcblxuZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24oaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ3dpdGgnLCBmdW5jdGlvbihjb250ZXh0LCBvcHRpb25zKSB7XG4gICAgaWYgKGlzRnVuY3Rpb24oY29udGV4dCkpIHsgY29udGV4dCA9IGNvbnRleHQuY2FsbCh0aGlzKTsgfVxuXG4gICAgbGV0IGZuID0gb3B0aW9ucy5mbjtcblxuICAgIGlmICghaXNFbXB0eShjb250ZXh0KSkge1xuICAgICAgbGV0IGRhdGEgPSBvcHRpb25zLmRhdGE7XG4gICAgICBpZiAob3B0aW9ucy5kYXRhICYmIG9wdGlvbnMuaWRzKSB7XG4gICAgICAgIGRhdGEgPSBjcmVhdGVGcmFtZShvcHRpb25zLmRhdGEpO1xuICAgICAgICBkYXRhLmNvbnRleHRQYXRoID0gYXBwZW5kQ29udGV4dFBhdGgob3B0aW9ucy5kYXRhLmNvbnRleHRQYXRoLCBvcHRpb25zLmlkc1swXSk7XG4gICAgICB9XG5cbiAgICAgIHJldHVybiBmbihjb250ZXh0LCB7XG4gICAgICAgIGRhdGE6IGRhdGEsXG4gICAgICAgIGJsb2NrUGFyYW1zOiBibG9ja1BhcmFtcyhbY29udGV4dF0sIFtkYXRhICYmIGRhdGEuY29udGV4dFBhdGhdKVxuICAgICAgfSk7XG4gICAgfSBlbHNlIHtcbiAgICAgIHJldHVybiBvcHRpb25zLmludmVyc2UodGhpcyk7XG4gICAgfVxuICB9KTtcbn1cbiJdfQ==


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/logger.js":
/*!***************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/logger.js ***!
  \***************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

var _utils = __webpack_require__(/*! ./utils */ "./node_modules/handlebars/dist/cjs/handlebars/utils.js");

var logger = {
  methodMap: ['debug', 'info', 'warn', 'error'],
  level: 'info',

  // Maps a given level value to the `methodMap` indexes above.
  lookupLevel: function lookupLevel(level) {
    if (typeof level === 'string') {
      var levelMap = _utils.indexOf(logger.methodMap, level.toLowerCase());
      if (levelMap >= 0) {
        level = levelMap;
      } else {
        level = parseInt(level, 10);
      }
    }

    return level;
  },

  // Can be overridden in the host environment
  log: function log(level) {
    level = logger.lookupLevel(level);

    if (typeof console !== 'undefined' && logger.lookupLevel(logger.level) <= level) {
      var method = logger.methodMap[level];
      if (!console[method]) {
        // eslint-disable-line no-console
        method = 'log';
      }

      for (var _len = arguments.length, message = Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++) {
        message[_key - 1] = arguments[_key];
      }

      console[method].apply(console, message); // eslint-disable-line no-console
    }
  }
};

exports['default'] = logger;
module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL2xvZ2dlci5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOzs7O3FCQUFzQixTQUFTOztBQUUvQixJQUFJLE1BQU0sR0FBRztBQUNYLFdBQVMsRUFBRSxDQUFDLE9BQU8sRUFBRSxNQUFNLEVBQUUsTUFBTSxFQUFFLE9BQU8sQ0FBQztBQUM3QyxPQUFLLEVBQUUsTUFBTTs7O0FBR2IsYUFBVyxFQUFFLHFCQUFTLEtBQUssRUFBRTtBQUMzQixRQUFJLE9BQU8sS0FBSyxLQUFLLFFBQVEsRUFBRTtBQUM3QixVQUFJLFFBQVEsR0FBRyxlQUFRLE1BQU0sQ0FBQyxTQUFTLEVBQUUsS0FBSyxDQUFDLFdBQVcsRUFBRSxDQUFDLENBQUM7QUFDOUQsVUFBSSxRQUFRLElBQUksQ0FBQyxFQUFFO0FBQ2pCLGFBQUssR0FBRyxRQUFRLENBQUM7T0FDbEIsTUFBTTtBQUNMLGFBQUssR0FBRyxRQUFRLENBQUMsS0FBSyxFQUFFLEVBQUUsQ0FBQyxDQUFDO09BQzdCO0tBQ0Y7O0FBRUQsV0FBTyxLQUFLLENBQUM7R0FDZDs7O0FBR0QsS0FBRyxFQUFFLGFBQVMsS0FBSyxFQUFjO0FBQy9CLFNBQUssR0FBRyxNQUFNLENBQUMsV0FBVyxDQUFDLEtBQUssQ0FBQyxDQUFDOztBQUVsQyxRQUFJLE9BQU8sT0FBTyxLQUFLLFdBQVcsSUFBSSxNQUFNLENBQUMsV0FBVyxDQUFDLE1BQU0sQ0FBQyxLQUFLLENBQUMsSUFBSSxLQUFLLEVBQUU7QUFDL0UsVUFBSSxNQUFNLEdBQUcsTUFBTSxDQUFDLFNBQVMsQ0FBQyxLQUFLLENBQUMsQ0FBQztBQUNyQyxVQUFJLENBQUMsT0FBTyxDQUFDLE1BQU0sQ0FBQyxFQUFFOztBQUNwQixjQUFNLEdBQUcsS0FBSyxDQUFDO09BQ2hCOzt3Q0FQbUIsT0FBTztBQUFQLGVBQU87OztBQVEzQixhQUFPLENBQUMsTUFBTSxPQUFDLENBQWYsT0FBTyxFQUFZLE9BQU8sQ0FBQyxDQUFDO0tBQzdCO0dBQ0Y7Q0FDRixDQUFDOztxQkFFYSxNQUFNIiwiZmlsZSI6ImxvZ2dlci5qcyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7aW5kZXhPZn0gZnJvbSAnLi91dGlscyc7XG5cbmxldCBsb2dnZXIgPSB7XG4gIG1ldGhvZE1hcDogWydkZWJ1ZycsICdpbmZvJywgJ3dhcm4nLCAnZXJyb3InXSxcbiAgbGV2ZWw6ICdpbmZvJyxcblxuICAvLyBNYXBzIGEgZ2l2ZW4gbGV2ZWwgdmFsdWUgdG8gdGhlIGBtZXRob2RNYXBgIGluZGV4ZXMgYWJvdmUuXG4gIGxvb2t1cExldmVsOiBmdW5jdGlvbihsZXZlbCkge1xuICAgIGlmICh0eXBlb2YgbGV2ZWwgPT09ICdzdHJpbmcnKSB7XG4gICAgICBsZXQgbGV2ZWxNYXAgPSBpbmRleE9mKGxvZ2dlci5tZXRob2RNYXAsIGxldmVsLnRvTG93ZXJDYXNlKCkpO1xuICAgICAgaWYgKGxldmVsTWFwID49IDApIHtcbiAgICAgICAgbGV2ZWwgPSBsZXZlbE1hcDtcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGxldmVsID0gcGFyc2VJbnQobGV2ZWwsIDEwKTtcbiAgICAgIH1cbiAgICB9XG5cbiAgICByZXR1cm4gbGV2ZWw7XG4gIH0sXG5cbiAgLy8gQ2FuIGJlIG92ZXJyaWRkZW4gaW4gdGhlIGhvc3QgZW52aXJvbm1lbnRcbiAgbG9nOiBmdW5jdGlvbihsZXZlbCwgLi4ubWVzc2FnZSkge1xuICAgIGxldmVsID0gbG9nZ2VyLmxvb2t1cExldmVsKGxldmVsKTtcblxuICAgIGlmICh0eXBlb2YgY29uc29sZSAhPT0gJ3VuZGVmaW5lZCcgJiYgbG9nZ2VyLmxvb2t1cExldmVsKGxvZ2dlci5sZXZlbCkgPD0gbGV2ZWwpIHtcbiAgICAgIGxldCBtZXRob2QgPSBsb2dnZXIubWV0aG9kTWFwW2xldmVsXTtcbiAgICAgIGlmICghY29uc29sZVttZXRob2RdKSB7IC8vIGVzbGludC1kaXNhYmxlLWxpbmUgbm8tY29uc29sZVxuICAgICAgICBtZXRob2QgPSAnbG9nJztcbiAgICAgIH1cbiAgICAgIGNvbnNvbGVbbWV0aG9kXSguLi5tZXNzYWdlKTsgLy8gZXNsaW50LWRpc2FibGUtbGluZSBuby1jb25zb2xlXG4gICAgfVxuICB9XG59O1xuXG5leHBvcnQgZGVmYXVsdCBsb2dnZXI7XG4iXX0=


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/no-conflict.js":
/*!********************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/no-conflict.js ***!
  \********************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(global) {/* global window */


exports.__esModule = true;

exports['default'] = function (Handlebars) {
  /* istanbul ignore next */
  var root = typeof global !== 'undefined' ? global : window,
      $Handlebars = root.Handlebars;
  /* istanbul ignore next */
  Handlebars.noConflict = function () {
    if (root.Handlebars === Handlebars) {
      root.Handlebars = $Handlebars;
    }
    return Handlebars;
  };
};

module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL25vLWNvbmZsaWN0LmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7O3FCQUNlLFVBQVMsVUFBVSxFQUFFOztBQUVsQyxNQUFJLElBQUksR0FBRyxPQUFPLE1BQU0sS0FBSyxXQUFXLEdBQUcsTUFBTSxHQUFHLE1BQU07TUFDdEQsV0FBVyxHQUFHLElBQUksQ0FBQyxVQUFVLENBQUM7O0FBRWxDLFlBQVUsQ0FBQyxVQUFVLEdBQUcsWUFBVztBQUNqQyxRQUFJLElBQUksQ0FBQyxVQUFVLEtBQUssVUFBVSxFQUFFO0FBQ2xDLFVBQUksQ0FBQyxVQUFVLEdBQUcsV0FBVyxDQUFDO0tBQy9CO0FBQ0QsV0FBTyxVQUFVLENBQUM7R0FDbkIsQ0FBQztDQUNIIiwiZmlsZSI6Im5vLWNvbmZsaWN0LmpzIiwic291cmNlc0NvbnRlbnQiOlsiLyogZ2xvYmFsIHdpbmRvdyAqL1xuZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24oSGFuZGxlYmFycykge1xuICAvKiBpc3RhbmJ1bCBpZ25vcmUgbmV4dCAqL1xuICBsZXQgcm9vdCA9IHR5cGVvZiBnbG9iYWwgIT09ICd1bmRlZmluZWQnID8gZ2xvYmFsIDogd2luZG93LFxuICAgICAgJEhhbmRsZWJhcnMgPSByb290LkhhbmRsZWJhcnM7XG4gIC8qIGlzdGFuYnVsIGlnbm9yZSBuZXh0ICovXG4gIEhhbmRsZWJhcnMubm9Db25mbGljdCA9IGZ1bmN0aW9uKCkge1xuICAgIGlmIChyb290LkhhbmRsZWJhcnMgPT09IEhhbmRsZWJhcnMpIHtcbiAgICAgIHJvb3QuSGFuZGxlYmFycyA9ICRIYW5kbGViYXJzO1xuICAgIH1cbiAgICByZXR1cm4gSGFuZGxlYmFycztcbiAgfTtcbn1cbiJdfQ==

/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./../../../../webpack/buildin/global.js */ "./node_modules/webpack/buildin/global.js")))

/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/runtime.js":
/*!****************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/runtime.js ***!
  \****************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.checkRevision = checkRevision;
exports.template = template;
exports.wrapProgram = wrapProgram;
exports.resolvePartial = resolvePartial;
exports.invokePartial = invokePartial;
exports.noop = noop;
// istanbul ignore next

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

// istanbul ignore next

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj['default'] = obj; return newObj; } }

var _utils = __webpack_require__(/*! ./utils */ "./node_modules/handlebars/dist/cjs/handlebars/utils.js");

var Utils = _interopRequireWildcard(_utils);

var _exception = __webpack_require__(/*! ./exception */ "./node_modules/handlebars/dist/cjs/handlebars/exception.js");

var _exception2 = _interopRequireDefault(_exception);

var _base = __webpack_require__(/*! ./base */ "./node_modules/handlebars/dist/cjs/handlebars/base.js");

function checkRevision(compilerInfo) {
  var compilerRevision = compilerInfo && compilerInfo[0] || 1,
      currentRevision = _base.COMPILER_REVISION;

  if (compilerRevision !== currentRevision) {
    if (compilerRevision < currentRevision) {
      var runtimeVersions = _base.REVISION_CHANGES[currentRevision],
          compilerVersions = _base.REVISION_CHANGES[compilerRevision];
      throw new _exception2['default']('Template was precompiled with an older version of Handlebars than the current runtime. ' + 'Please update your precompiler to a newer version (' + runtimeVersions + ') or downgrade your runtime to an older version (' + compilerVersions + ').');
    } else {
      // Use the embedded version info since the runtime doesn't know about this revision yet
      throw new _exception2['default']('Template was precompiled with a newer version of Handlebars than the current runtime. ' + 'Please update your runtime to a newer version (' + compilerInfo[1] + ').');
    }
  }
}

function template(templateSpec, env) {
  /* istanbul ignore next */
  if (!env) {
    throw new _exception2['default']('No environment passed to template');
  }
  if (!templateSpec || !templateSpec.main) {
    throw new _exception2['default']('Unknown template object: ' + typeof templateSpec);
  }

  templateSpec.main.decorator = templateSpec.main_d;

  // Note: Using env.VM references rather than local var references throughout this section to allow
  // for external users to override these as psuedo-supported APIs.
  env.VM.checkRevision(templateSpec.compiler);

  function invokePartialWrapper(partial, context, options) {
    if (options.hash) {
      context = Utils.extend({}, context, options.hash);
      if (options.ids) {
        options.ids[0] = true;
      }
    }

    partial = env.VM.resolvePartial.call(this, partial, context, options);
    var result = env.VM.invokePartial.call(this, partial, context, options);

    if (result == null && env.compile) {
      options.partials[options.name] = env.compile(partial, templateSpec.compilerOptions, env);
      result = options.partials[options.name](context, options);
    }
    if (result != null) {
      if (options.indent) {
        var lines = result.split('\n');
        for (var i = 0, l = lines.length; i < l; i++) {
          if (!lines[i] && i + 1 === l) {
            break;
          }

          lines[i] = options.indent + lines[i];
        }
        result = lines.join('\n');
      }
      return result;
    } else {
      throw new _exception2['default']('The partial ' + options.name + ' could not be compiled when running in runtime-only mode');
    }
  }

  // Just add water
  var container = {
    strict: function strict(obj, name) {
      if (!(name in obj)) {
        throw new _exception2['default']('"' + name + '" not defined in ' + obj);
      }
      return obj[name];
    },
    lookup: function lookup(depths, name) {
      var len = depths.length;
      for (var i = 0; i < len; i++) {
        if (depths[i] && depths[i][name] != null) {
          return depths[i][name];
        }
      }
    },
    lambda: function lambda(current, context) {
      return typeof current === 'function' ? current.call(context) : current;
    },

    escapeExpression: Utils.escapeExpression,
    invokePartial: invokePartialWrapper,

    fn: function fn(i) {
      var ret = templateSpec[i];
      ret.decorator = templateSpec[i + '_d'];
      return ret;
    },

    programs: [],
    program: function program(i, data, declaredBlockParams, blockParams, depths) {
      var programWrapper = this.programs[i],
          fn = this.fn(i);
      if (data || depths || blockParams || declaredBlockParams) {
        programWrapper = wrapProgram(this, i, fn, data, declaredBlockParams, blockParams, depths);
      } else if (!programWrapper) {
        programWrapper = this.programs[i] = wrapProgram(this, i, fn);
      }
      return programWrapper;
    },

    data: function data(value, depth) {
      while (value && depth--) {
        value = value._parent;
      }
      return value;
    },
    merge: function merge(param, common) {
      var obj = param || common;

      if (param && common && param !== common) {
        obj = Utils.extend({}, common, param);
      }

      return obj;
    },
    // An empty object to use as replacement for null-contexts
    nullContext: Object.seal({}),

    noop: env.VM.noop,
    compilerInfo: templateSpec.compiler
  };

  function ret(context) {
    var options = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];

    var data = options.data;

    ret._setup(options);
    if (!options.partial && templateSpec.useData) {
      data = initData(context, data);
    }
    var depths = undefined,
        blockParams = templateSpec.useBlockParams ? [] : undefined;
    if (templateSpec.useDepths) {
      if (options.depths) {
        depths = context != options.depths[0] ? [context].concat(options.depths) : options.depths;
      } else {
        depths = [context];
      }
    }

    function main(context /*, options*/) {
      return '' + templateSpec.main(container, context, container.helpers, container.partials, data, blockParams, depths);
    }
    main = executeDecorators(templateSpec.main, main, container, options.depths || [], data, blockParams);
    return main(context, options);
  }
  ret.isTop = true;

  ret._setup = function (options) {
    if (!options.partial) {
      container.helpers = container.merge(options.helpers, env.helpers);

      if (templateSpec.usePartial) {
        container.partials = container.merge(options.partials, env.partials);
      }
      if (templateSpec.usePartial || templateSpec.useDecorators) {
        container.decorators = container.merge(options.decorators, env.decorators);
      }
    } else {
      container.helpers = options.helpers;
      container.partials = options.partials;
      container.decorators = options.decorators;
    }
  };

  ret._child = function (i, data, blockParams, depths) {
    if (templateSpec.useBlockParams && !blockParams) {
      throw new _exception2['default']('must pass block params');
    }
    if (templateSpec.useDepths && !depths) {
      throw new _exception2['default']('must pass parent depths');
    }

    return wrapProgram(container, i, templateSpec[i], data, 0, blockParams, depths);
  };
  return ret;
}

function wrapProgram(container, i, fn, data, declaredBlockParams, blockParams, depths) {
  function prog(context) {
    var options = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];

    var currentDepths = depths;
    if (depths && context != depths[0] && !(context === container.nullContext && depths[0] === null)) {
      currentDepths = [context].concat(depths);
    }

    return fn(container, context, container.helpers, container.partials, options.data || data, blockParams && [options.blockParams].concat(blockParams), currentDepths);
  }

  prog = executeDecorators(fn, prog, container, depths, data, blockParams);

  prog.program = i;
  prog.depth = depths ? depths.length : 0;
  prog.blockParams = declaredBlockParams || 0;
  return prog;
}

function resolvePartial(partial, context, options) {
  if (!partial) {
    if (options.name === '@partial-block') {
      partial = options.data['partial-block'];
    } else {
      partial = options.partials[options.name];
    }
  } else if (!partial.call && !options.name) {
    // This is a dynamic partial that returned a string
    options.name = partial;
    partial = options.partials[partial];
  }
  return partial;
}

function invokePartial(partial, context, options) {
  // Use the current closure context to save the partial-block if this partial
  var currentPartialBlock = options.data && options.data['partial-block'];
  options.partial = true;
  if (options.ids) {
    options.data.contextPath = options.ids[0] || options.data.contextPath;
  }

  var partialBlock = undefined;
  if (options.fn && options.fn !== noop) {
    (function () {
      options.data = _base.createFrame(options.data);
      // Wrapper function to get access to currentPartialBlock from the closure
      var fn = options.fn;
      partialBlock = options.data['partial-block'] = function partialBlockWrapper(context) {
        var options = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];

        // Restore the partial-block from the closure for the execution of the block
        // i.e. the part inside the block of the partial call.
        options.data = _base.createFrame(options.data);
        options.data['partial-block'] = currentPartialBlock;
        return fn(context, options);
      };
      if (fn.partials) {
        options.partials = Utils.extend({}, options.partials, fn.partials);
      }
    })();
  }

  if (partial === undefined && partialBlock) {
    partial = partialBlock;
  }

  if (partial === undefined) {
    throw new _exception2['default']('The partial ' + options.name + ' could not be found');
  } else if (partial instanceof Function) {
    return partial(context, options);
  }
}

function noop() {
  return '';
}

function initData(context, data) {
  if (!data || !('root' in data)) {
    data = data ? _base.createFrame(data) : {};
    data.root = context;
  }
  return data;
}

function executeDecorators(fn, prog, container, depths, data, blockParams) {
  if (fn.decorator) {
    var props = {};
    prog = fn.decorator(prog, props, container, depths && depths[0], data, blockParams, depths);
    Utils.extend(prog, props);
  }
  return prog;
}
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL3J1bnRpbWUuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7Ozs7Ozs7Ozs7cUJBQXVCLFNBQVM7O0lBQXBCLEtBQUs7O3lCQUNLLGFBQWE7Ozs7b0JBQzhCLFFBQVE7O0FBRWxFLFNBQVMsYUFBYSxDQUFDLFlBQVksRUFBRTtBQUMxQyxNQUFNLGdCQUFnQixHQUFHLFlBQVksSUFBSSxZQUFZLENBQUMsQ0FBQyxDQUFDLElBQUksQ0FBQztNQUN2RCxlQUFlLDBCQUFvQixDQUFDOztBQUUxQyxNQUFJLGdCQUFnQixLQUFLLGVBQWUsRUFBRTtBQUN4QyxRQUFJLGdCQUFnQixHQUFHLGVBQWUsRUFBRTtBQUN0QyxVQUFNLGVBQWUsR0FBRyx1QkFBaUIsZUFBZSxDQUFDO1VBQ25ELGdCQUFnQixHQUFHLHVCQUFpQixnQkFBZ0IsQ0FBQyxDQUFDO0FBQzVELFlBQU0sMkJBQWMseUZBQXlGLEdBQ3ZHLHFEQUFxRCxHQUFHLGVBQWUsR0FBRyxtREFBbUQsR0FBRyxnQkFBZ0IsR0FBRyxJQUFJLENBQUMsQ0FBQztLQUNoSyxNQUFNOztBQUVMLFlBQU0sMkJBQWMsd0ZBQXdGLEdBQ3RHLGlEQUFpRCxHQUFHLFlBQVksQ0FBQyxDQUFDLENBQUMsR0FBRyxJQUFJLENBQUMsQ0FBQztLQUNuRjtHQUNGO0NBQ0Y7O0FBRU0sU0FBUyxRQUFRLENBQUMsWUFBWSxFQUFFLEdBQUcsRUFBRTs7QUFFMUMsTUFBSSxDQUFDLEdBQUcsRUFBRTtBQUNSLFVBQU0sMkJBQWMsbUNBQW1DLENBQUMsQ0FBQztHQUMxRDtBQUNELE1BQUksQ0FBQyxZQUFZLElBQUksQ0FBQyxZQUFZLENBQUMsSUFBSSxFQUFFO0FBQ3ZDLFVBQU0sMkJBQWMsMkJBQTJCLEdBQUcsT0FBTyxZQUFZLENBQUMsQ0FBQztHQUN4RTs7QUFFRCxjQUFZLENBQUMsSUFBSSxDQUFDLFNBQVMsR0FBRyxZQUFZLENBQUMsTUFBTSxDQUFDOzs7O0FBSWxELEtBQUcs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QUUsS0FBSyxFQUFFLFNBQVMsRUFBRSxNQUFNLElBQUksTUFBTSxDQUFDLENBQUMsQ0FBQyxFQUFFLElBQUksRUFBRSxXQUFXLEVBQUUsTUFBTSxDQUFDLENBQUM7QUFDNUYsU0FBSyxDQUFDLE1BQU0sQ0FBQyxJQUFJLEVBQUUsS0FBSyxDQUFDLENBQUM7R0FDM0I7QUFDRCxTQUFPLElBQUksQ0FBQztDQUNiIiwiZmlsZSI6InJ1bnRpbWUuanMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgKiBhcyBVdGlscyBmcm9tICcuL3V0aWxzJztcbmltcG9ydCBFeGNlcHRpb24gZnJvbSAnLi9leGNlcHRpb24nO1xuaW1wb3J0IHsgQ09NUElMRVJfUkVWSVNJT04sIFJFVklTSU9OX0NIQU5HRVMsIGNyZWF0ZUZyYW1lIH0gZnJvbSAnLi9iYXNlJztcblxuZXhwb3J0IGZ1bmN0aW9uIGNoZWNrUmV2aXNpb24oY29tcGlsZXJJbmZvKSB7XG4gIGNvbnN0IGNvbXBpbGVyUmV2aXNpb24gPSBjb21waWxlckluZm8gJiYgY29tcGlsZXJJbmZvWzBdIHx8IDEsXG4gICAgICAgIGN1cnJlbnRSZXZpc2lvbiA9IENPTVBJTEVSX1JFVklTSU9OO1xuXG4gIGlmIChjb21waWxlclJldmlzaW9uICE9PSBjdXJyZW50UmV2aXNpb24pIHtcbiAgICBpZiAoY29tcGlsZXJSZXZpc2lvbiA8IGN1cnJlbnRSZXZpc2lvbikge1xuICAgICAgY29uc3QgcnVudGltZVZlcnNpb25zID0gUkVWSVNJT05fQ0hBTkdFU1tjdXJyZW50UmV2aXNpb25dLFxuICAgICAgICAgICAgY29tcGlsZXJWZXJzaW9ucyA9IFJFVklTSU9OX0NIQU5HRVNbY29tcGlsZXJSZXZpc2lvbl07XG4gICAgICB0aHJvdyBuZXcgRXhjZXB0aW9uKCdUZW1wbGF0ZSB3YXMgcHJlY29tcGlsZWQgd2l0aCBhbiBvbGRlciB2ZXJzaW9uIG9mIEhhbmRsZWJhcnMgdGhhbiB0aGUgY3VycmVudCBydW50aW1lLiAnICtcbiAgICAgICAgICAgICdQbGVhc2UgdXBkYXRlIHlvdXIgcHJlY29tcGlsZXIgdG8gYSBuZXdlciB2ZXJzaW9uICgnICsgcnVudGltZVZlcnNpb25zICsgJykgb3IgZG93bmdyYWRlIHlvdXIgcnVudGltZSB0byBhbiBvbGRlciB2ZXJzaW9uICgnICsgY29tcGlsZXJWZXJzaW9ucyArICcpLicpO1xuICAgIH0gZWxzZSB7XG4gICAgICAvLyBVc2UgdGhlIGVtYmVkZGVkIHZlcnNpb24gaW5mbyBzaW5jZSB0aGUgcnVudGltZSBkb2Vzbid0IGtub3cgYWJvdXQgdGhpcyByZXZpc2lvbiB5ZXRcbiAgICAgIHRocm93IG5ldyBFeGNlcHRpb24oJ1RlbXBsYXRlIHdhcyBwcmVjb21waWxlZCB3aXRoIGEgbmV3ZXIgdmVyc2lvbiBvZiBIYW5kbGViYXJzIHRoYW4gdGhlIGN1cnJlbnQgcnVudGltZS4gJyArXG4gICAgICAgICAgICAnUGxlYXNlIHVwZGF0ZSB5b3VyIHJ1bnRpbWUgdG8gYSBuZXdlciB2ZXJzaW9uICgnICsgY29tcGlsZXJJbmZvWzFdICsgJykuJyk7XG4gICAgfVxuICB9XG59XG5cbmV4cG9ydCBmdW5jdGlvbiB0ZW1wbGF0ZSh0ZW1wbGF0ZVNwZWMsIGVudikge1xuICAvKiBpc3RhbmJ1bCBpZ25vcmUgbmV4dCAqL1xuICBpZiAoIWVudikge1xuICAgIHRocm93IG5ldyBFeGNlcHRpb24oJ05vIGVudmlyb25tZW50IHBhc3NlZCB0byB0ZW1wbGF0ZScpO1xuICB9XG4gIGlmICghdGVtcGxhdGVTcGVjIHx8ICF0ZW1wbGF0ZVNwZWMubWFpbikge1xuICAgIHRocm93IG5ldyBFeGNlcHRpb24oJ1Vua25vd24gdGVtcGxhdGUgb2JqZWN0OiAnICsgdHlwZW9mIHRlbXBsYXRlU3BlYyk7XG4gIH1cblxuICB0ZW1wbGF0ZVNwZWMubWFpbi5kZWNvcmF0b3IgPSB0ZW1wbGF0ZVNwZWMubWFpbl9kO1xuXG4gIC8vIE5vdGU6IFVzaW5nIGVudi5WTSByZWZlcmVuY2VzIHJhdGhlciB0aGFuIGxvY2FsIHZhciByZWZlcmVuY2VzIHRocm91Z2hvdXQgdGhpcyBzZWN0aW9uIHRvIGFsbG93XG4gIC8vIGZvciBleHRlcm5hbCB1c2VycyB0byBvdmVycmlkZSB0aGVzZSBhcyBwc3VlZG8tc3VwcG9ydGVkIEFQSXMuXG4gIGVudi5WTS5jaGVja1JldmlzaW9uKHRlbXBsYXRlU3BlYy5jb21waWxlcik7XG5cbiAgZnVuY3Rpb24gaW52b2tlUGFydGlhbFdyYXBwZXIocGFydGlhbCwgY29udGV4dCwgb3B0aW9ucykge1xuICAgIGlmIChvcHRpb25zLmhhc2gpIHtcbiAgICAgIGNvbnRleHQgPSBVdGlscy5leHRlbmQoe30sIGNvbnRleHQsIG9wdGlvbnMuaGFzaCk7XG4gICAgICBpZiAob3B0aW9ucy5pZHMpIHtcbiAgICAgICAgb3B0aW9ucy5pZHNbMF0gPSB0cnVlO1xuICAgICAgfVxuICAgIH1cblxuICAgIHBhcnRpYWwgPSBlbnYuVk0ucmVzb2x2ZVBhcnRpYWwuY2FsbCh0aGlzLCBwYXJ0aWFsLCBjb250ZXh0LCBvcHRpb25zKTtcbiAgICBsZXQgcmVzdWx0ID0gZW52LlZNLmludm9rZVBhcnRpYWwuY2FsbCh0aGlzLCBwYXJ0aWFsLCBjb250ZXh0LCBvcHRpb25zKTtcblxuICAgIGlmIChyZXN1bHQgPT0gbnVsbCAmJiBlbnYuY29tcGlsZSkge1xuICAgICAgb3B0aW9ucy5wYXJ0aWFsc1tvcHRpb25zLm5hbWVdID0gZW52LmNvbXBpbGUocGFydGlhbCwgdGVtcGxhdGVTcGVjLmNvbXBpbGVyT3B0aW9ucywgZW52KTtcbiAgICAgIHJlc3VsdCA9IG9wdGlvbnMucGFydGlhbHNbb3B0aW9ucy5uYW1lXShjb250ZXh0LCBvcHRpb25zKTtcbiAgICB9XG4gICAgaWYgKHJlc3VsdCAhPSBudWxsKSB7XG4gICAgICBpZiAob3B0aW9ucy5pbmRlbnQpIHtcbiAgICAgICAgbGV0IGxpbmVzID0gcmVzdWx0LnNwbGl0KCdcXG4nKTtcbiAgICAgICAgZm9yIChsZXQgaSA9IDAsIGwgPSBsaW5lcy5sZW5ndGg7IGkgPCBsOyBpKyspIHtcbiAgICAgICAgICBpZiAoIWxpbmVzW2ldICYmIGkgKyAxID09PSBsKSB7XG4gICAgICAgICAgICBicmVhaztcbiAgICAgICAgICB9XG5cbiAgICAgICAgICBsaW5lc1tpXSA9IG9wdGlvbnMuaW5kZW50ICsgbGluZXNbaV07XG4gICAgICAgIH1cbiAgICAgICAgcmVzdWx0ID0gbGluZXMuam9pbignXFxuJyk7XG4gICAgICB9XG4gICAgICByZXR1cm4gcmVzdWx0O1xuICAgIH0gZWxzZSB7XG4gICAgICB0aHJvdyBuZXcgRXhjZXB0aW9uKCdUaGUgcGFydGlhbCAnICsgb3B0aW9ucy5uYW1lICsgJyBjb3VsZCBub3QgYmUgY29tcGlsZWQgd2hlbiBydW5uaW5nIGluIHJ1bnRpbWUtb25seSBtb2RlJyk7XG4gICAgfVxuICB9XG5cbiAgLy8gSnVzdCBhZGQgd2F0ZXJcbiAgbGV0IGNvbnRhaW5lciA9IHtcbiAgICBzdHJpY3Q6IGZ1bmN0aW9uKG9iaiwgbmFtZSkge1xuICAgICAgaWYgKCEobmFtZSBpbiBvYmopKSB7XG4gICAgICAgIHRocm93IG5ldyBFeGNlcHRpb24oJ1wiJyArIG5hbWUgKyAnXCIgbm90IGRlZmluZWQgaW4gJyArIG9iaik7XG4gICAgICB9XG4gICAgICByZXR1cm4gb2JqW25hbWVdO1xuICAgIH0sXG4gICAgbG9va3VwOiBmdW5jdGlvbihkZXB0aHMsIG5hbWUpIHtcbiAgICAgIGNvbnN0IGxlbiA9IGRlcHRocy5sZW5ndGg7XG4gICAgICBmb3IgKGxldCBpID0gMDsgaSA8IGxlbjsgaSsrKSB7XG4gICAgICAgIGlmIChkZXB0aHNbaV0gJiYgZGVwdGhzW2ldW25hbWVdICE9IG51bGwpIHtcbiAgICAgICAgICByZXR1cm4gZGVwdGhzW2ldW25hbWVdO1xuICAgICAgICB9XG4gICAgICB9XG4gICAgfSxcbiAgICBsYW1iZGE6IGZ1bmN0aW9uKGN1cnJlbnQsIGNvbnRleHQpIHtcbiAgICAgIHJldHVybiB0eXBlb2YgY3VycmVudCA9PT0gJ2Z1bmN0aW9uJyA/IGN1cnJlbnQuY2FsbChjb250ZXh0KSA6IGN1cnJlbnQ7XG4gICAgfSxcblxuICAgIGVzY2FwZUV4cHJlc3Npb246IFV0aWxzLmVzY2FwZUV4cHJlc3Npb24sXG4gICAgaW52b2tlUGFydGlhbDogaW52b2tlUGFydGlhbFdyYXBwZXIsXG5cbiAgICBmbjogZnVuY3Rpb24oaSkge1xuICAgICAgbGV0IHJldCA9IHRlbXBsYXRlU3BlY1tpXTtcbiAgICAgIHJldC5kZWNvcmF0b3IgPSB0ZW1wbGF0ZVNwZWNbaSArICdfZCddO1xuICAgICAgcmV0dXJuIHJldDtcbiAgICB9LFxuXG4gICAgcHJvZ3JhbXM6IFtdLFxuICAgIHByb2dyYW06IGZ1bmN0aW9uKGksIGRhdGEsIGRlY2xhcmVkQmxvY2tQYXJhbXMsIGJsb2NrUGFyYW1zLCBkZXB0aHMpIHtcbiAgICAgIGxldCBwcm9ncmFtV3JhcHBlciA9IHRoaXMucHJvZ3JhbXNbaV0sXG4gICAgICAgICAgZm4gPSB0aGlzLmZuKGkpO1xuICAgICAgaWYgKGRhdGEgfHwgZGVwdGhzIHx8IGJsb2NrUGFyYW1zIHx8IGRlY2xhcmVkQmxvY2tQYXJhbXMpIHtcbiAgICAgICAgcHJvZ3JhbVdyYXBwZXIgPSB3cmFwUHJvZ3JhbSh0aGlzLCBpLCBmbiwgZGF0YSwgZGVjbGFyZWRCbG9ja1BhcmFtcywgYmxvY2tQYXJhbXMsIGRlcHRocyk7XG4gICAgICB9IGVsc2UgaWYgKCFwcm9ncmFtV3JhcHBlcikge1xuICAgICAgICBwcm9ncmFtV3JhcHBlciA9IHRoaXMucHJvZ3JhbXNbaV0gPSB3cmFwUHJvZ3JhbSh0aGlzLCBpLCBmbik7XG4gICAgICB9XG4gICAgICByZXR1cm4gcHJvZ3JhbVdyYXBwZXI7XG4gICAgfSxcblxuICAgIGRhdGE6IGZ1bmN0aW9uKHZhbHVlLCBkZXB0aCkge1xuICAgICAgd2hpbGUgKHZhbHVlICYmIGRlcHRoLS0pIHtcbiAgICAgICAgdmFsdWUgPSB2YWx1ZS5fcGFyZW50O1xuICAgICAgfVxuICAgICAgcmV0dXJuIHZhbHVlO1xuICAgIH0sXG4gICAgbWVyZ2U6IGZ1bmN0aW9uKHBhcmFtLCBjb21tb24pIHtcbiAgICAgIGxldCBvYmogPSBwYXJhbSB8fCBjb21tb247XG5cbiAgICAgIGlmIChwYXJhbSAmJiBjb21tb24gJiYgKHBhcmFtICE9PSBjb21tb24pKSB7XG4gICAgICAgIG9iaiA9IFV0aWxzLmV4dGVuZCh7fSwgY29tbW9uLCBwYXJhbSk7XG4gICAgICB9XG5cbiAgICAgIHJldHVybiBvYmo7XG4gICAgfSxcbiAgICAvLyBBbiBlbXB0eSBvYmplY3QgdG8gdXNlIGFzIHJlcGxhY2VtZW50IGZvciBudWxsLWNvbnRleHRzXG4gICAgbnVsbENvbnRleHQ6IE9iamVjdC5zZWFsKHt9KSxcblxuICAgIG5vb3A6IGVudi5WTS5ub29wLFxuICAgIGNvbXBpbGVySW5mbzogdGVtcGxhdGVTcGVjLmNvbXBpbGVyXG4gIH07XG5cbiAgZnVuY3Rpb24gcmV0KGNvbnRleHQsIG9wdGlvbnMgPSB7fSkge1xuICAgIGxldCBkYXRhID0gb3B0aW9ucy5kYXRhO1xuXG4gICAgcmV0Ll9zZXR1cChvcHRpb25zKTtcbiAgICBpZiAoIW9wdGlvbnMucGFydGlhbCAmJiB0ZW1wbGF0ZVNwZWMudXNlRGF0YSkge1xuICAgICAgZGF0YSA9IGluaXREYXRhKGNvbnRleHQsIGRhdGEpO1xuICAgIH1cbiAgICBsZXQgZGVwdGhzLFxuICAgICAgICBibG9ja1BhcmFtcyA9IHRlbXBsYXRlU3BlYy51c2VCbG9ja1BhcmFtcyA/IFtdIDogdW5kZWZpbmVkO1xuICAgIGlmICh0ZW1wbGF0ZVNwZWMudXNlRGVwdGhzKSB7XG4gICAgICBpZiAob3B0aW9ucy5kZXB0aHMpIHtcbiAgICAgICAgZGVwdGhzID0gY29udGV4dCAhPSBvcHRpb25zLmRlcHRoc1swXSA/IFtjb250ZXh0XS5jb25jYXQob3B0aW9ucy5kZXB0aHMpIDogb3B0aW9ucy5kZXB0aHM7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICBkZXB0aHMgPSBbY29udGV4dF07XG4gICAgICB9XG4gICAgfVxuXG4gICAgZnVuY3Rpb24gbWFpbihjb250ZXh0LyosIG9wdGlvbnMqLykge1xuICAgICAgcmV0dXJuICcnICsgdGVtcGxhdGVTcGVjLm1haW4oY29udGFpbmVyLCBjb250ZXh0LCBjb250YWluZXIuaGVscGVycywgY29udGFpbmVyLnBhcnRpYWxzLCBkYXRhLCBibG9ja1BhcmFtcywgZGVwdGhzKTtcbiAgICB9XG4gICAgbWFpbiA9IGV4ZWN1dGVEZWNvcmF0b3JzKHRlbXBsYXRlU3BlYy5tYWluLCBtYWluLCBjb250YWluZXIsIG9wdGlvbnMuZGVwdGhzIHx8IFtdLCBkYXRhLCBibG9ja1BhcmFtcyk7XG4gICAgcmV0dXJuIG1haW4oY29udGV4dCwgb3B0aW9ucyk7XG4gIH1cbiAgcmV0LmlzVG9wID0gdHJ1ZTtcblxuICByZXQuX3NldHVwID0gZnVuY3Rpb24ob3B0aW9ucykge1xuICAgIGlmICghb3B0aW9ucy5wYXJ0aWFsKSB7XG4gICAgICBjb250YWluZXIuaGVscGVycyA9IGNvbnRhaW5lci5tZXJnZShvcHRpb25zLmhlbHBlcnMsIGVudi5oZWxwZXJzKTtcblxuICAgICAgaWYgKHRlbXBsYXRlU3BlYy51c2VQYXJ0aWFsKSB7XG4gICAgICAgIGNvbnRhaW5lci5wYXJ0aWFscyA9IGNvbnRhaW5lci5tZXJnZShvcHRpb25zLnBhcnRpYWxzLCBlbnYucGFydGlhbHMpO1xuICAgICAgfVxuICAgICAgaWYgKHRlbXBsYXRlU3BlYy51c2VQYXJ0aWFsIHx8IHRlbXBsYXRlU3BlYy51c2VEZWNvcmF0b3JzKSB7XG4gICAgICAgIGNvbnRhaW5lci5kZWNvcmF0b3JzID0gY29udGFpbmVyLm1lcmdlKG9wdGlvbnMuZGVjb3JhdG9ycywgZW52LmRlY29yYXRvcnMpO1xuICAgICAgfVxuICAgIH0gZWxzZSB7XG4gICAgICBjb250YWluZXIuaGVscGVycyA9IG9wdGlvbnMuaGVscGVycztcbiAgICAgIGNvbnRhaW5lci5wYXJ0aWFscyA9IG9wdGlvbnMucGFydGlhbHM7XG4gICAgICBjb250YWluZXIuZGVjb3JhdG9ycyA9IG9wdGlvbnMuZGVjb3JhdG9ycztcbiAgICB9XG4gIH07XG5cbiAgcmV0Ll9jaGlsZCA9IGZ1bmN0aW9uKGksIGRhdGEsIGJsb2NrUGFyYW1zLCBkZXB0aHMpIHtcbiAgICBpZiAodGVtcGxhdGVTcGVjLnVzZUJsb2NrUGFyYW1zICYmICFibG9ja1BhcmFtcykge1xuICAgICAgdGhyb3cgbmV3IEV4Y2VwdGlvbignbXVzdCBwYXNzIGJsb2NrIHBhcmFtcycpO1xuICAgIH1cbiAgICBpZiAodGVtcGxhdGVTcGVjLnVzZURlcHRocyAmJiAhZGVwdGhzKSB7XG4gICAgICB0aHJvdyBuZXcgRXhjZXB0aW9uKCdtdXN0IHBhc3MgcGFyZW50IGRlcHRocycpO1xuICAgIH1cblxuICAgIHJldHVybiB3cmFwUHJvZ3JhbShjb250YWluZXIsIGksIHRlbXBsYXRlU3BlY1tpXSwgZGF0YSwgMCwgYmxvY2tQYXJhbXMsIGRlcHRocyk7XG4gIH07XG4gIHJldHVybiByZXQ7XG59XG5cbmV4cG9ydCBmdW5jdGlvbiB3cmFwUHJvZ3JhbShjb250YWluZXIsIGksIGZuLCBkYXRhLCBkZWNsYXJlZEJsb2NrUGFyYW1zLCBibG9ja1BhcmFtcywgZGVwdGhzKSB7XG4gIGZ1bmN0aW9uIHByb2coY29udGV4dCwgb3B0aW9ucyA9IHt9KSB7XG4gICAgbGV0IGN1cnJlbnREZXB0aHMgPSBkZXB0aHM7XG4gICAgaWYgKGRlcHRocyAmJiBjb250ZXh0ICE9IGRlcHRoc1swXSAmJiAhKGNvbnRleHQgPT09IGNvbnRhaW5lci5udWxsQ29udGV4dCAmJiBkZXB0aHNbMF0gPT09IG51bGwpKSB7XG4gICAgICBjdXJyZW50RGVwdGhzID0gW2NvbnRleHRdLmNvbmNhdChkZXB0aHMpO1xuICAgIH1cblxuICAgIHJldHVybiBmbihjb250YWluZXIsXG4gICAgICAgIGNvbnRleHQsXG4gICAgICAgIGNvbnRhaW5lci5oZWxwZXJzLCBjb250YWluZXIucGFydGlhbHMsXG4gICAgICAgIG9wdGlvbnMuZGF0YSB8fCBkYXRhLFxuICAgICAgICBibG9ja1BhcmFtcyAmJiBbb3B0aW9ucy5ibG9ja1BhcmFtc10uY29uY2F0KGJsb2NrUGFyYW1zKSxcbiAgICAgICAgY3VycmVudERlcHRocyk7XG4gIH1cblxuICBwcm9nID0gZXhlY3V0ZURlY29yYXRvcnMoZm4sIHByb2csIGNvbnRhaW5lciwgZGVwdGhzLCBkYXRhLCBibG9ja1BhcmFtcyk7XG5cbiAgcHJvZy5wcm9ncmFtID0gaTtcbiAgcHJvZy5kZXB0aCA9IGRlcHRocyA/IGRlcHRocy5sZW5ndGggOiAwO1xuICBwcm9nLmJsb2NrUGFyYW1zID0gZGVjbGFyZWRCbG9ja1BhcmFtcyB8fCAwO1xuICByZXR1cm4gcHJvZztcbn1cblxuZXhwb3J0IGZ1bmN0aW9uIHJlc29sdmVQYXJ0aWFsKHBhcnRpYWwsIGNvbnRleHQsIG9wdGlvbnMpIHtcbiAgaWYgKCFwYXJ0aWFsKSB7XG4gICAgaWYgKG9wdGlvbnMubmFtZSA9PT0gJ0BwYXJ0aWFsLWJsb2NrJykge1xuICAgICAgcGFydGlhbCA9IG9wdGlvbnMuZGF0YVsncGFydGlhbC1ibG9jayddO1xuICAgIH0gZWxzZSB7XG4gICAgICBwYXJ0aWFsID0gb3B0aW9ucy5wYXJ0aWFsc1tvcHRpb25zLm5hbWVdO1xuICAgIH1cbiAgfSBlbHNlIGlmICghcGFydGlhbC5jYWxsICYmICFvcHRpb25zLm5hbWUpIHtcbiAgICAvLyBUaGlzIGlzIGEgZHluYW1pYyBwYXJ0aWFsIHRoYXQgcmV0dXJuZWQgYSBzdHJpbmdcbiAgICBvcHRpb25zLm5hbWUgPSBwYXJ0aWFsO1xuICAgIHBhcnRpYWwgPSBvcHRpb25zLnBhcnRpYWxzW3BhcnRpYWxdO1xuICB9XG4gIHJldHVybiBwYXJ0aWFsO1xufVxuXG5leHBvcnQgZnVuY3Rpb24gaW52b2tlUGFydGlhbChwYXJ0aWFsLCBjb250ZXh0LCBvcHRpb25zKSB7XG4gIC8vIFVzZSB0aGUgY3VycmVudCBjbG9zdXJlIGNvbnRleHQgdG8gc2F2ZSB0aGUgcGFydGlhbC1ibG9jayBpZiB0aGlzIHBhcnRpYWxcbiAgY29uc3QgY3VycmVudFBhcnRpYWxCbG9jayA9IG9wdGlvbnMuZGF0YSAmJiBvcHRpb25zLmRhdGFbJ3BhcnRpYWwtYmxvY2snXTtcbiAgb3B0aW9ucy5wYXJ0aWFsID0gdHJ1ZTtcbiAgaWYgKG9wdGlvbnMuaWRzKSB7XG4gICAgb3B0aW9ucy5kYXRhLmNvbnRleHRQYXRoID0gb3B0aW9ucy5pZHNbMF0gfHwgb3B0aW9ucy5kYXRhLmNvbnRleHRQYXRoO1xuICB9XG5cbiAgbGV0IHBhcnRpYWxCbG9jaztcbiAgaWYgKG9wdGlvbnMuZm4gJiYgb3B0aW9ucy5mbiAhPT0gbm9vcCkge1xuICAgIG9wdGlvbnMuZGF0YSA9IGNyZWF0ZUZyYW1lKG9wdGlvbnMuZGF0YSk7XG4gICAgLy8gV3JhcHBlciBmdW5jdGlvbiB0byBnZXQgYWNjZXNzIHRvIGN1cnJlbnRQYXJ0aWFsQmxvY2sgZnJvbSB0aGUgY2xvc3VyZVxuICAgIGxldCBmbiA9IG9wdGlvbnMuZm47XG4gICAgcGFydGlhbEJsb2NrID0gb3B0aW9ucy5kYXRhWydwYXJ0aWFsLWJsb2NrJ10gPSBmdW5jdGlvbiBwYXJ0aWFsQmxvY2tXcmFwcGVyKGNvbnRleHQsIG9wdGlvbnMgPSB7fSkge1xuXG4gICAgICAvLyBSZXN0b3JlIHRoZSBwYXJ0aWFsLWJsb2NrIGZyb20gdGhlIGNsb3N1cmUgZm9yIHRoZSBleGVjdXRpb24gb2YgdGhlIGJsb2NrXG4gICAgICAvLyBpLmUuIHRoZSBwYXJ0IGluc2lkZSB0aGUgYmxvY2sgb2YgdGhlIHBhcnRpYWwgY2FsbC5cbiAgICAgIG9wdGlvbnMuZGF0YSA9IGNyZWF0ZUZyYW1lKG9wdGlvbnMuZGF0YSk7XG4gICAgICBvcHRpb25zLmRhdGFbJ3BhcnRpYWwtYmxvY2snXSA9IGN1cnJlbnRQYXJ0aWFsQmxvY2s7XG4gICAgICByZXR1cm4gZm4oY29udGV4dCwgb3B0aW9ucyk7XG4gICAgfTtcbiAgICBpZiAoZm4ucGFydGlhbHMpIHtcbiAgICAgIG9wdGlvbnMucGFydGlhbHMgPSBVdGlscy5leHRlbmQoe30sIG9wdGlvbnMucGFydGlhbHMsIGZuLnBhcnRpYWxzKTtcbiAgICB9XG4gIH1cblxuICBpZiAocGFydGlhbCA9PT0gdW5kZWZpbmVkICYmIHBhcnRpYWxCbG9jaykge1xuICAgIHBhcnRpYWwgPSBwYXJ0aWFsQmxvY2s7XG4gIH1cblxuICBpZiAocGFydGlhbCA9PT0gdW5kZWZpbmVkKSB7XG4gICAgdGhyb3cgbmV3IEV4Y2VwdGlvbignVGhlIHBhcnRpYWwgJyArIG9wdGlvbnMubmFtZSArICcgY291bGQgbm90IGJlIGZvdW5kJyk7XG4gIH0gZWxzZSBpZiAocGFydGlhbCBpbnN0YW5jZW9mIEZ1bmN0aW9uKSB7XG4gICAgcmV0dXJuIHBhcnRpYWwoY29udGV4dCwgb3B0aW9ucyk7XG4gIH1cbn1cblxuZXhwb3J0IGZ1bmN0aW9uIG5vb3AoKSB7IHJldHVybiAnJzsgfVxuXG5mdW5jdGlvbiBpbml0RGF0YShjb250ZXh0LCBkYXRhKSB7XG4gIGlmICghZGF0YSB8fCAhKCdyb290JyBpbiBkYXRhKSkge1xuICAgIGRhdGEgPSBkYXRhID8gY3JlYXRlRnJhbWUoZGF0YSkgOiB7fTtcbiAgICBkYXRhLnJvb3QgPSBjb250ZXh0O1xuICB9XG4gIHJldHVybiBkYXRhO1xufVxuXG5mdW5jdGlvbiBleGVjdXRlRGVjb3JhdG9ycyhmbiwgcHJvZywgY29udGFpbmVyLCBkZXB0aHMsIGRhdGEsIGJsb2NrUGFyYW1zKSB7XG4gIGlmIChmbi5kZWNvcmF0b3IpIHtcbiAgICBsZXQgcHJvcHMgPSB7fTtcbiAgICBwcm9nID0gZm4uZGVjb3JhdG9yKHByb2csIHByb3BzLCBjb250YWluZXIsIGRlcHRocyAmJiBkZXB0aHNbMF0sIGRhdGEsIGJsb2NrUGFyYW1zLCBkZXB0aHMpO1xuICAgIFV0aWxzLmV4dGVuZChwcm9nLCBwcm9wcyk7XG4gIH1cbiAgcmV0dXJuIHByb2c7XG59XG4iXX0=


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/safe-string.js":
/*!********************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/safe-string.js ***!
  \********************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
// Build out our basic SafeString type


exports.__esModule = true;
function SafeString(string) {
  this.string = string;
}

SafeString.prototype.toString = SafeString.prototype.toHTML = function () {
  return '' + this.string;
};

exports['default'] = SafeString;
module.exports = exports['default'];
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL3NhZmUtc3RyaW5nLmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7QUFDQSxTQUFTLFVBQVUsQ0FBQyxNQUFNLEVBQUU7QUFDMUIsTUFBSSxDQUFDLE1BQU0sR0FBRyxNQUFNLENBQUM7Q0FDdEI7O0FBRUQsVUFBVSxDQUFDLFNBQVMsQ0FBQyxRQUFRLEdBQUcsVUFBVSxDQUFDLFNBQVMsQ0FBQyxNQUFNLEdBQUcsWUFBVztBQUN2RSxTQUFPLEVBQUUsR0FBRyxJQUFJLENBQUMsTUFBTSxDQUFDO0NBQ3pCLENBQUM7O3FCQUVhLFVBQVUiLCJmaWxlIjoic2FmZS1zdHJpbmcuanMiLCJzb3VyY2VzQ29udGVudCI6WyIvLyBCdWlsZCBvdXQgb3VyIGJhc2ljIFNhZmVTdHJpbmcgdHlwZVxuZnVuY3Rpb24gU2FmZVN0cmluZyhzdHJpbmcpIHtcbiAgdGhpcy5zdHJpbmcgPSBzdHJpbmc7XG59XG5cblNhZmVTdHJpbmcucHJvdG90eXBlLnRvU3RyaW5nID0gU2FmZVN0cmluZy5wcm90b3R5cGUudG9IVE1MID0gZnVuY3Rpb24oKSB7XG4gIHJldHVybiAnJyArIHRoaXMuc3RyaW5nO1xufTtcblxuZXhwb3J0IGRlZmF1bHQgU2FmZVN0cmluZztcbiJdfQ==


/***/ }),

/***/ "./node_modules/handlebars/dist/cjs/handlebars/utils.js":
/*!**************************************************************!*\
  !*** ./node_modules/handlebars/dist/cjs/handlebars/utils.js ***!
  \**************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.extend = extend;
exports.indexOf = indexOf;
exports.escapeExpression = escapeExpression;
exports.isEmpty = isEmpty;
exports.createFrame = createFrame;
exports.blockParams = blockParams;
exports.appendContextPath = appendContextPath;
var escape = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#x27;',
  '`': '&#x60;',
  '=': '&#x3D;'
};

var badChars = /[&<>"'`=]/g,
    possible = /[&<>"'`=]/;

function escapeChar(chr) {
  return escape[chr];
}

function extend(obj /* , ...source */) {
  for (var i = 1; i < arguments.length; i++) {
    for (var key in arguments[i]) {
      if (Object.prototype.hasOwnProperty.call(arguments[i], key)) {
        obj[key] = arguments[i][key];
      }
    }
  }

  return obj;
}

var toString = Object.prototype.toString;

exports.toString = toString;
// Sourced from lodash
// https://github.com/bestiejs/lodash/blob/master/LICENSE.txt
/* eslint-disable func-style */
var isFunction = function isFunction(value) {
  return typeof value === 'function';
};
// fallback for older versions of Chrome and Safari
/* istanbul ignore next */
if (isFunction(/x/)) {
  exports.isFunction = isFunction = function (value) {
    return typeof value === 'function' && toString.call(value) === '[object Function]';
  };
}
exports.isFunction = isFunction;

/* eslint-enable func-style */

/* istanbul ignore next */
var isArray = Array.isArray || function (value) {
  return value && typeof value === 'object' ? toString.call(value) === '[object Array]' : false;
};

exports.isArray = isArray;
// Older IE versions do not directly support indexOf so we must implement our own, sadly.

function indexOf(array, value) {
  for (var i = 0, len = array.length; i < len; i++) {
    if (array[i] === value) {
      return i;
    }
  }
  return -1;
}

function escapeExpression(string) {
  if (typeof string !== 'string') {
    // don't escape SafeStrings, since they're already safe
    if (string && string.toHTML) {
      return string.toHTML();
    } else if (string == null) {
      return '';
    } else if (!string) {
      return string + '';
    }

    // Force a string conversion as this will be done by the append regardless and
    // the regex test will do this transparently behind the scenes, causing issues if
    // an object's to string has escaped characters in it.
    string = '' + string;
  }

  if (!possible.test(string)) {
    return string;
  }
  return string.replace(badChars, escapeChar);
}

function isEmpty(value) {
  if (!value && value !== 0) {
    return true;
  } else if (isArray(value) && value.length === 0) {
    return true;
  } else {
    return false;
  }
}

function createFrame(object) {
  var frame = extend({}, object);
  frame._parent = object;
  return frame;
}

function blockParams(params, ids) {
  params.path = ids;
  return params;
}

function appendContextPath(contextPath, id) {
  return (contextPath ? contextPath + '.' : '') + id;
}
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL2xpYi9oYW5kbGViYXJzL3V0aWxzLmpzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7Ozs7Ozs7QUFBQSxJQUFNLE1BQU0sR0FBRztBQUNiLEtBQUcsRUFBRSxPQUFPO0FBQ1osS0FBRyxFQUFFLE1BQU07QUFDWCxLQUFHLEVBQUUsTUFBTTtBQUNYLEtBQUcsRUFBRSxRQUFRO0FBQ2IsS0FBRyxFQUFFLFFBQVE7QUFDYixLQUFHLEVBQUUsUUFBUTtBQUNiLEtBQUcsRUFBRSxRQUFRO0NBQ2QsQ0FBQzs7QUFFRixJQUFNLFFBQVEsR0FBRyxZQUFZO0lBQ3ZCLFFBQVEsR0FBRyxXQUFXLENBQUM7O0FBRTdCLFNBQVMsVUFBVSxDQUFDLEdBQUcsRUFBRTtBQUN2QixTQUFPLE1BQU0sQ0FBQyxHQUFHLENBQUMsQ0FBQztDQUNwQjs7QUFFTSxTQUFTLE1BQU0sQ0FBQyxHQUFHLG9CQUFtQjtBQUMzQyxPQUFLLElBQUksQ0FBQyxHQUFHLENBQUMsRUFBRSxDQUFDLEdBQUcsU0FBUyxDQUFDLE1BQU0sRUFBRSxDQUFDLEVBQUUsRUFBRTtBQUN6QyxTQUFLLElBQUksR0FBRyxJQUFJLFNBQVMsQ0FBQyxDQUFDLENBQUMsRUFBRTtBQUM1QixVQUFJLE1BQU0sQ0FBQyxTQUFTLENBQUMsY0FBYyxDQUFDLElBQUksQ0FBQyxTQUFTLENBQUMsQ0FBQyxDQUFDLEVBQUUsR0FBRyxDQUFDLEVBQUU7QUFDM0QsV0FBRyxDQUFDLEdBQUcsQ0FBQyxHQUFHLFNBQVMsQ0FBQyxDQUFDLENBQUMsQ0FBQyxHQUFHLENBQUMsQ0FBQztPQUM5QjtLQUNGO0dBQ0Y7O0FBRUQsU0FBTyxHQUFHLENBQUM7Q0FDWjs7QUFFTSxJQUFJLFFBQVEsR0FBRyxNQUFNLENBQUMsU0FBUyxDQUFDLFFBQVEsQ0FBQzs7Ozs7O0FBS2hELElBQUksVUFBVSxHQUFHLG9CQUFTLEtBQUssRUFBRTtBQUMvQixTQUFPLE9BQU8sS0FBSyxLQUFLLFVBQVUsQ0FBQztDQUNwQyxDQUFDOzs7QUFHRixJQUFJLFVBQVUsQ0FBQyxHQUFHLENBQUMsRUFBRTtBQUNuQixVQUlNLFVBQVUsR0FKaEIsVUFBVSxHQUFHLFVBQVMsS0FBSyxFQUFFO0FBQzNCLFdBQU8sT0FBTyxLQUFLLEtBQUssVUFBVSxJQUFJLFFBQVEsQ0FBQyxJQUFJLENBQUMsS0FBSyxDQUFDLEtBQUssbUJBQW1CLENBQUM7R0FDcEYsQ0FBQztDQUNIO1FBQ08sVUFBVSxHQUFWLFVBQVU7Ozs7O0FBSVgsSUFBTSxPQUFPLEdBQUcsS0FBSyxDQUFDLE9BQU8sSUFBSSxVQUFTLEtBQUssRUFBRTtBQUN0RCxTQUFPLEFBQUMsS0FBSyxJQUFJLE9BQU8sS0FBSyxLQUFLLFFBQVEsR0FBSSxRQUFRLENBQUMsSUFBSSxDQUFDLEtBQUssQ0FBQyxLQUFLLGdCQUFnQixHQUFHLEtBQUssQ0FBQztDQUNqRyxDQUFDOzs7OztBQUdLLFNBQVMsT0FBTyxDQUFDLEtBQUssRUFBRSxLQUFLLEVBQUU7QUFDcEMsT0FBSyxJQUFJLENBQUMsR0FBRyxDQUFDLEVBQUUsR0FBRyxHQUFHLEtBQUssQ0FBQyxNQUFNLEVBQUUsQ0FBQyxHQUFHLEdBQUcsRUFBRSxDQUFDLEVBQUUsRUFBRTtBQUNoRCxRQUFJLEtBQUssQ0FBQyxDQUFDLENBQUMsS0FBSyxLQUFLLEVBQUU7QUFDdEIsYUFBTyxDQUFDLENBQUM7S0FDVjtHQUNGO0FBQ0QsU0FBTyxDQUFDLENBQUMsQ0FBQztDQUNYOztBQUdNLFNBQVMsZ0JBQWdCLENBQUMsTUFBTSxFQUFFO0FBQ3ZDLE1BQUksT0FBTyxNQUFNLEtBQUssUUFBUSxFQUFFOztBQUU5QixRQUFJLE1BQU0sSUFBSSxNQUFNLENBQUMsTUFBTSxFQUFFO0FBQzNCLGFBQU8sTUFBTSxDQUFDLE1BQU0sRUFBRSxDQUFDO0tBQ3hCLE1BQU0sSUFBSSxNQUFNLElBQUksSUFBSSxFQUFFO0FBQ3pCLGFBQU8sRUFBRSxDQUFDO0tBQ1gsTUFBTSxJQUFJLENBQUMsTUFBTSxFQUFFO0FBQ2xCLGFBQU8sTUFBTSxHQUFHLEVBQUUsQ0FBQztLQUNwQjs7Ozs7QUFLRCxVQUFNLEdBQUcsRUFBRSxHQUFHLE1BQU0sQ0FBQztHQUN0Qjs7QUFFRCxNQUFJLENBQUMsUUFBUSxDQUFDLElBQUksQ0FBQyxNQUFNLENBQUMsRUFBRTtBQUFFLFdBQU8sTUFBTSxDQUFDO0dBQUU7QUFDOUMsU0FBTyxNQUFNLENBQUMsT0FBTyxDQUFDLFFBQVEsRUFBRSxVQUFVLENBQUMsQ0FBQztDQUM3Qzs7QUFFTSxTQUFTLE9BQU8sQ0FBQyxLQUFLLEVBQUU7QUFDN0IsTUFBSSxDQUFDLEtBQUssSUFBSSxLQUFLLEtBQUssQ0FBQyxFQUFFO0FBQ3pCLFdBQU8sSUFBSSxDQUFDO0dBQ2IsTUFBTSxJQUFJLE9BQU8sQ0FBQyxLQUFLLENBQUMsSUFBSSxLQUFLLENBQUMsTUFBTSxLQUFLLENBQUMsRUFBRTtBQUMvQyxXQUFPLElBQUksQ0FBQztHQUNiLE1BQU07QUFDTCxXQUFPLEtBQUssQ0FBQztHQUNkO0NBQ0Y7O0FBRU0sU0FBUyxXQUFXLENBQUMsTUFBTSxFQUFFO0FBQ2xDLE1BQUksS0FBSyxHQUFHLE1BQU0sQ0FBQyxFQUFFLEVBQUUsTUFBTSxDQUFDLENBQUM7QUFDL0IsT0FBSyxDQUFDLE9BQU8sR0FBRyxNQUFNLENBQUM7QUFDdkIsU0FBTyxLQUFLLENBQUM7Q0FDZDs7QUFFTSxTQUFTLFdBQVcsQ0FBQyxNQUFNLEVBQUUsR0FBRyxFQUFFO0FBQ3ZDLFFBQU0sQ0FBQyxJQUFJLEdBQUcsR0FBRyxDQUFDO0FBQ2xCLFNBQU8sTUFBTSxDQUFDO0NBQ2Y7O0FBRU0sU0FBUyxpQkFBaUIsQ0FBQyxXQUFXLEVBQUUsRUFBRSxFQUFFO0FBQ2pELFNBQU8sQ0FBQyxXQUFXLEdBQUcsV0FBVyxHQUFHLEdBQUcsR0FBRyxFQUFFLENBQUEsR0FBSSxFQUFFLENBQUM7Q0FDcEQiLCJmaWxlIjoidXRpbHMuanMiLCJzb3VyY2VzQ29udGVudCI6WyJjb25zdCBlc2NhcGUgPSB7XG4gICcmJzogJyZhbXA7JyxcbiAgJzwnOiAnJmx0OycsXG4gICc+JzogJyZndDsnLFxuICAnXCInOiAnJnF1b3Q7JyxcbiAgXCInXCI6ICcmI3gyNzsnLFxuICAnYCc6ICcmI3g2MDsnLFxuICAnPSc6ICcmI3gzRDsnXG59O1xuXG5jb25zdCBiYWRDaGFycyA9IC9bJjw+XCInYD1dL2csXG4gICAgICBwb3NzaWJsZSA9IC9bJjw+XCInYD1dLztcblxuZnVuY3Rpb24gZXNjYXBlQ2hhcihjaHIpIHtcbiAgcmV0dXJuIGVzY2FwZVtjaHJdO1xufVxuXG5leHBvcnQgZnVuY3Rpb24gZXh0ZW5kKG9iai8qICwgLi4uc291cmNlICovKSB7XG4gIGZvciAobGV0IGkgPSAxOyBpIDwgYXJndW1lbnRzLmxlbmd0aDsgaSsrKSB7XG4gICAgZm9yIChsZXQga2V5IGluIGFyZ3VtZW50c1tpXSkge1xuICAgICAgaWYgKE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbChhcmd1bWVudHNbaV0sIGtleSkpIHtcbiAgICAgICAgb2JqW2tleV0gPSBhcmd1bWVudHNbaV1ba2V5XTtcbiAgICAgIH1cbiAgICB9XG4gIH1cblxuICByZXR1cm4gb2JqO1xufVxuXG5leHBvcnQgbGV0IHRvU3RyaW5nID0gT2JqZWN0LnByb3RvdHlwZS50b1N0cmluZztcblxuLy8gU291cmNlZCBmcm9tIGxvZGFzaFxuLy8gaHR0cHM6Ly9naXRodWIuY29tL2Jlc3RpZWpzL2xvZGFzaC9ibG9iL21hc3Rlci9MSUNFTlNFLnR4dFxuLyogZXNsaW50LWRpc2FibGUgZnVuYy1zdHlsZSAqL1xubGV0IGlzRnVuY3Rpb24gPSBmdW5jdGlvbih2YWx1ZSkge1xuICByZXR1cm4gdHlwZW9mIHZhbHVlID09PSAnZnVuY3Rpb24nO1xufTtcbi8vIGZhbGxiYWNrIGZvciBvbGRlciB2ZXJzaW9ucyBvZiBDaHJvbWUgYW5kIFNhZmFyaVxuLyogaXN0YW5idWwgaWdub3JlIG5leHQgKi9cbmlmIChpc0Z1bmN0aW9uKC94LykpIHtcbiAgaXNGdW5jdGlvbiA9IGZ1bmN0aW9uKHZhbHVlKSB7XG4gICAgcmV0dXJuIHR5cGVvZiB2YWx1ZSA9PT0gJ2Z1bmN0aW9uJyAmJiB0b1N0cmluZy5jYWxsKHZhbHVlKSA9PT0gJ1tvYmplY3QgRnVuY3Rpb25dJztcbiAgfTtcbn1cbmV4cG9ydCB7aXNGdW5jdGlvbn07XG4vKiBlc2xpbnQtZW5hYmxlIGZ1bmMtc3R5bGUgKi9cblxuLyogaXN0YW5idWwgaWdub3JlIG5leHQgKi9cbmV4cG9ydCBjb25zdCBpc0FycmF5ID0gQXJyYXkuaXNBcnJheSB8fCBmdW5jdGlvbih2YWx1ZSkge1xuICByZXR1cm4gKHZhbHVlICYmIHR5cGVvZiB2YWx1ZSA9PT0gJ29iamVjdCcpID8gdG9TdHJpbmcuY2FsbCh2YWx1ZSkgPT09ICdbb2JqZWN0IEFycmF5XScgOiBmYWxzZTtcbn07XG5cbi8vIE9sZGVyIElFIHZlcnNpb25zIGRvIG5vdCBkaXJlY3RseSBzdXBwb3J0IGluZGV4T2Ygc28gd2UgbXVzdCBpbXBsZW1lbnQgb3VyIG93biwgc2FkbHkuXG5leHBvcnQgZnVuY3Rpb24gaW5kZXhPZihhcnJheSwgdmFsdWUpIHtcbiAgZm9yIChsZXQgaSA9IDAsIGxlbiA9IGFycmF5Lmxlbmd0aDsgaSA8IGxlbjsgaSsrKSB7XG4gICAgaWYgKGFycmF5W2ldID09PSB2YWx1ZSkge1xuICAgICAgcmV0dXJuIGk7XG4gICAgfVxuICB9XG4gIHJldHVybiAtMTtcbn1cblxuXG5leHBvcnQgZnVuY3Rpb24gZXNjYXBlRXhwcmVzc2lvbihzdHJpbmcpIHtcbiAgaWYgKHR5cGVvZiBzdHJpbmcgIT09ICdzdHJpbmcnKSB7XG4gICAgLy8gZG9uJ3QgZXNjYXBlIFNhZmVTdHJpbmdzLCBzaW5jZSB0aGV5J3JlIGFscmVhZHkgc2FmZVxuICAgIGlmIChzdHJpbmcgJiYgc3RyaW5nLnRvSFRNTCkge1xuICAgICAgcmV0dXJuIHN0cmluZy50b0hUTUwoKTtcbiAgICB9IGVsc2UgaWYgKHN0cmluZyA9PSBudWxsKSB7XG4gICAgICByZXR1cm4gJyc7XG4gICAgfSBlbHNlIGlmICghc3RyaW5nKSB7XG4gICAgICByZXR1cm4gc3RyaW5nICsgJyc7XG4gICAgfVxuXG4gICAgLy8gRm9yY2UgYSBzdHJpbmcgY29udmVyc2lvbiBhcyB0aGlzIHdpbGwgYmUgZG9uZSBieSB0aGUgYXBwZW5kIHJlZ2FyZGxlc3MgYW5kXG4gICAgLy8gdGhlIHJlZ2V4IHRlc3Qgd2lsbCBkbyB0aGlzIHRyYW5zcGFyZW50bHkgYmVoaW5kIHRoZSBzY2VuZXMsIGNhdXNpbmcgaXNzdWVzIGlmXG4gICAgLy8gYW4gb2JqZWN0J3MgdG8gc3RyaW5nIGhhcyBlc2NhcGVkIGNoYXJhY3RlcnMgaW4gaXQuXG4gICAgc3RyaW5nID0gJycgKyBzdHJpbmc7XG4gIH1cblxuICBpZiAoIXBvc3NpYmxlLnRlc3Qoc3RyaW5nKSkgeyByZXR1cm4gc3RyaW5nOyB9XG4gIHJldHVybiBzdHJpbmcucmVwbGFjZShiYWRDaGFycywgZXNjYXBlQ2hhcik7XG59XG5cbmV4cG9ydCBmdW5jdGlvbiBpc0VtcHR5KHZhbHVlKSB7XG4gIGlmICghdmFsdWUgJiYgdmFsdWUgIT09IDApIHtcbiAgICByZXR1cm4gdHJ1ZTtcbiAgfSBlbHNlIGlmIChpc0FycmF5KHZhbHVlKSAmJiB2YWx1ZS5sZW5ndGggPT09IDApIHtcbiAgICByZXR1cm4gdHJ1ZTtcbiAgfSBlbHNlIHtcbiAgICByZXR1cm4gZmFsc2U7XG4gIH1cbn1cblxuZXhwb3J0IGZ1bmN0aW9uIGNyZWF0ZUZyYW1lKG9iamVjdCkge1xuICBsZXQgZnJhbWUgPSBleHRlbmQoe30sIG9iamVjdCk7XG4gIGZyYW1lLl9wYXJlbnQgPSBvYmplY3Q7XG4gIHJldHVybiBmcmFtZTtcbn1cblxuZXhwb3J0IGZ1bmN0aW9uIGJsb2NrUGFyYW1zKHBhcmFtcywgaWRzKSB7XG4gIHBhcmFtcy5wYXRoID0gaWRzO1xuICByZXR1cm4gcGFyYW1zO1xufVxuXG5leHBvcnQgZnVuY3Rpb24gYXBwZW5kQ29udGV4dFBhdGgoY29udGV4dFBhdGgsIGlkKSB7XG4gIHJldHVybiAoY29udGV4dFBhdGggPyBjb250ZXh0UGF0aCArICcuJyA6ICcnKSArIGlkO1xufVxuIl19


/***/ }),

/***/ "./node_modules/handlebars/runtime.js":
/*!********************************************!*\
  !*** ./node_modules/handlebars/runtime.js ***!
  \********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

// Create a simple path alias to allow browserify to resolve
// the runtime on a supported path.
module.exports = __webpack_require__(/*! ./dist/cjs/handlebars.runtime */ "./node_modules/handlebars/dist/cjs/handlebars.runtime.js")['default'];


/***/ }),

/***/ "./node_modules/webpack/buildin/global.js":
/*!***********************************!*\
  !*** (webpack)/buildin/global.js ***!
  \***********************************/
/*! no static exports found */
/***/ (function(module, exports) {

var g;

// This works in non-strict mode
g = (function() {
	return this;
})();

try {
	// This works if eval is allowed (see CSP)
	g = g || new Function("return this")();
} catch (e) {
	// This works if the window reference is available
	if (typeof window === "object") g = window;
}

// g can still be undefined, but nothing to do about it...
// We return undefined, instead of nothing here, so it's
// easier to handle this case. if(!global) { ...}

module.exports = g;


/***/ }),

/***/ "./templates/common_partials/_meeting.hbs":
/*!************************************************!*\
  !*** ./templates/common_partials/_meeting.hbs ***!
  \************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var Handlebars = __webpack_require__(/*! ../../node_modules/handlebars/runtime.js */ "./node_modules/handlebars/runtime.js");
function __default(obj) { return obj && (obj.__esModule ? obj["default"] : obj); }
module.exports = (Handlebars["default"] || Handlebars).template({"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = container.invokePartial(__webpack_require__(/*! ./_meeting_card.hbs */ "./templates/common_partials/_meeting_card.hbs"),depth0,{"name":"_meeting_card","data":data,"helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "")
    + "\n\n";
},"usePartial":true,"useData":true});

/***/ }),

/***/ "./templates/common_partials/_meeting_card.hbs":
/*!*****************************************************!*\
  !*** ./templates/common_partials/_meeting_card.hbs ***!
  \*****************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var Handlebars = __webpack_require__(/*! ../../node_modules/handlebars/runtime.js */ "./node_modules/handlebars/runtime.js");
function __default(obj) { return obj && (obj.__esModule ? obj["default"] : obj); }
module.exports = (Handlebars["default"] || Handlebars).template({"1":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "              <input type=\"checkbox\" name=\"meetingCard\" "
    + alias4(((helper = (helper = helpers.checked || (depth0 != null ? depth0.checked : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"checked","hash":{},"data":data}) : helper)))
    + " data-uuid='"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "' id=\"meetingCard_"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\" class=\"selectable\">\n";
},"3":function(container,depth0,helpers,partials,data) {
    return "              <input type=\"checkbox\" name=\"meetingCard\" class=\"no-hover\" disabled>\n";
},"5":function(container,depth0,helpers,partials,data) {
    var helper;

  return "                 "
    + container.escapeExpression(((helper = (helper = helpers.meetingType || (depth0 != null ? depth0.meetingType : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : (container.nullContext || {}),{"name":"meetingType","hash":{},"data":data}) : helper)))
    + "\n";
},"7":function(container,depth0,helpers,partials,data) {
    return "                 M\n";
},"9":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "              <div class=\"font-lg meeting-title\" title=\""
    + alias4(((helper = (helper = helpers.briefing_meeting_title || (depth0 != null ? depth0.briefing_meeting_title : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"briefing_meeting_title","hash":{},"data":data}) : helper)))
    + "\">"
    + alias4(((helper = (helper = helpers.briefing_meeting_title || (depth0 != null ? depth0.briefing_meeting_title : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"briefing_meeting_title","hash":{},"data":data}) : helper)))
    + "</div>\n";
},"11":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "              <div class=\"font-lg meeting-title\" title=\""
    + alias4(((helper = (helper = helpers.meeting_with || (depth0 != null ? depth0.meeting_with : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"meeting_with","hash":{},"data":data}) : helper)))
    + "\">"
    + alias4(((helper = (helper = helpers.meeting_with || (depth0 != null ? depth0.meeting_with : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"meeting_with","hash":{},"data":data}) : helper)))
    + "</div> \n";
},"13":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "                  <span class=\"font-sm\">"
    + alias4(((helper = (helper = helpers.startDateTime || (depth0 != null ? depth0.startDateTime : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"startDateTime","hash":{},"data":data}) : helper)))
    + "</span>\n                  <br>\n                  <span class=\"font-sm\">"
    + alias4(((helper = (helper = helpers.endDateTime || (depth0 != null ? depth0.endDateTime : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"endDateTime","hash":{},"data":data}) : helper)))
    + "</span>\n                  <br>\n";
},"15":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "                  <span class=\"font-semi-bold\">"
    + alias4(((helper = (helper = helpers.startTime || (depth0 != null ? depth0.startTime : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"startTime","hash":{},"data":data}) : helper)))
    + " - "
    + alias4(((helper = (helper = helpers.endTime || (depth0 != null ? depth0.endTime : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"endTime","hash":{},"data":data}) : helper)))
    + "</span>\n                  <br>\n                  <span class=\"font-sm\">"
    + alias4(((helper = (helper = helpers.meetingDate || (depth0 != null ? depth0.meetingDate : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"meetingDate","hash":{},"data":data}) : helper)))
    + "</span>\n";
},"17":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression, alias5=container.lambda;

  return "\n              <div class=\"meeting-approved "
    + alias4(((helper = (helper = helpers.approved || (depth0 != null ? depth0.approved : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"approved","hash":{},"data":data}) : helper)))
    + "\">\n                <span class=\"font-blue\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"approved",{"name":"t","hash":{},"data":data}))
    + "</span>\n              </div>\n\n              <div class=\"meeting-approve "
    + alias4(((helper = (helper = helpers.Approve || (depth0 != null ? depth0.Approve : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"Approve","hash":{},"data":data}) : helper)))
    + "\" data-url=\""
    + alias4(alias5(((stack1 = (depth0 != null ? depth0.actions_urls : depth0)) != null ? stack1.approve_meeting_url : stack1), depth0))
    + "\">\n                <a href=\"javascript:void(0)\" class=\"icon-box jif-blue\">\n                  <i class=\"jif-check\"></i>\n                  <div class=\"font-8\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"approve",{"name":"t","hash":{},"data":data}))
    + "</div>\n                </a>\n              </div>\n\n              <div class=\"meeting-approve-all "
    + alias4(((helper = (helper = helpers.approve_all || (depth0 != null ? depth0.approve_all : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"approve_all","hash":{},"data":data}) : helper)))
    + "\" data-url=\""
    + alias4(alias5(((stack1 = (depth0 != null ? depth0.action_urls : depth0)) != null ? stack1.approve_all_url : stack1), depth0))
    + "\">\n                <a href=\"javascript:void(0)\" class=\"icon-box jif-blue\">\n                  <i class=\"jif-check\"></i>\n                  <div class=\"font-8\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"approve_all",{"name":"t","hash":{},"data":data}))
    + "</div>\n                </a>\n              </div>\n\n              <div class=\"meeting-cancelled "
    + alias4(((helper = (helper = helpers.cancelled || (depth0 != null ? depth0.cancelled : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"cancelled","hash":{},"data":data}) : helper)))
    + "\">\n                <span class=\"font-red\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"cancelled",{"name":"t","hash":{},"data":data}))
    + "</span>\n              </div>\n\n              <div class=\"meeting-cancel "
    + alias4(((helper = (helper = helpers.Cancel || (depth0 != null ? depth0.Cancel : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"Cancel","hash":{},"data":data}) : helper)))
    + "\" data-url=\""
    + alias4(alias5(((stack1 = (depth0 != null ? depth0.actions_urls : depth0)) != null ? stack1.cancel_meeting_url : stack1), depth0))
    + "\">\n                <a href=\"javascript:void(0)\" class=\"icon-box jif-red\">\n                  <i class=\"jif-trash\"></i>\n                  <div class=\"font-8\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"cancel",{"name":"t","hash":{},"data":data}))
    + "</div>\n                </a>\n              </div>\n\n              <div class=\"meeting-cancel-all "
    + alias4(((helper = (helper = helpers.cancel_all || (depth0 != null ? depth0.cancel_all : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"cancel_all","hash":{},"data":data}) : helper)))
    + "\" data-url=\""
    + alias4(alias5(((stack1 = (depth0 != null ? depth0.action_urls : depth0)) != null ? stack1.cancel_all_url : stack1), depth0))
    + "\">\n                <a href=\"javascript:void(0)\" class=\"icon-box jif-red\">\n                  <i class=\"jif-trash\"></i>\n                  <div class=\"font-8\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"cancel_all",{"name":"t","hash":{},"data":data}))
    + "</div>\n                </a>\n              </div>\n\n              <div class=\"meeting-accepted "
    + alias4(((helper = (helper = helpers.accepted || (depth0 != null ? depth0.accepted : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"accepted","hash":{},"data":data}) : helper)))
    + "\">\n                <span class=\"font-blue\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"accepted",{"name":"t","hash":{},"data":data}))
    + "</span>\n              </div>\n\n              <div class=\"meeting-accept "
    + alias4(((helper = (helper = helpers.Accept || (depth0 != null ? depth0.Accept : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"Accept","hash":{},"data":data}) : helper)))
    + "\" data-url=\""
    + alias4(alias5(((stack1 = (depth0 != null ? depth0.actions_urls : depth0)) != null ? stack1.accept_meeting_url : stack1), depth0))
    + "\">\n                <a href=\"javascript:void(0)\" class=\"icon-box jif-blue\">\n                  <i class=\"jif-check\"></i>\n                  <div class=\"font-8\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"accept",{"name":"t","hash":{},"data":data}))
    + "</div>\n                </a>\n              </div>\n\n              <div class=\"meeting-declined "
    + alias4(((helper = (helper = helpers.declined || (depth0 != null ? depth0.declined : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"declined","hash":{},"data":data}) : helper)))
    + "\">\n                <span class=\"font-red\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"declined",{"name":"t","hash":{},"data":data}))
    + "</span>\n              </div>\n\n\n              <div class=\"meeting-decline "
    + alias4(((helper = (helper = helpers.Decline || (depth0 != null ? depth0.Decline : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"Decline","hash":{},"data":data}) : helper)))
    + "\" data-url=\""
    + alias4(alias5(((stack1 = (depth0 != null ? depth0.actions_urls : depth0)) != null ? stack1.decline_meeting_url : stack1), depth0))
    + "\">\n                <a href=\"javascript:void(0)\" class=\"icon-box jif-red\">\n                  <i class=\"jif-close\"></i>\n                  <div class=\"font-8\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"decline",{"name":"t","hash":{},"data":data}))
    + "</div>\n                </a>\n              </div>\n\n              <div class=\"meeting-summary hide\">\n                <a href=\"javascript:void(0)\" class=\"icon-box jif-blue\">\n                  <i class=\"jif-summary\"></i>\n                  <div class=\"font-8\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"summary",{"name":"t","hash":{},"data":data}))
    + "</div>\n                </a>\n              </div>\n";
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "<div class=\"card meeting-card "
    + alias4(((helper = (helper = helpers.status || (depth0 != null ? depth0.status : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"status","hash":{},"data":data}) : helper)))
    + "\" data-uuid='"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "' id=\""
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\">\n      <div class=\"card-header\">\n        <div class=\"card-header-content\">\n          <div class=\"card-select\">\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.edit : depth0),{"name":"if","hash":{},"fn":container.program(1, data, 0),"inverse":container.program(3, data, 0),"data":data})) != null ? stack1 : "")
    + "            <label for=\"meetingCard_"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\">\n              <div>\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.meetingType : depth0),{"name":"if","hash":{},"fn":container.program(5, data, 0),"inverse":container.program(7, data, 0),"data":data})) != null ? stack1 : "")
    + "              </div>\n            </label>\n          </div>\n          <div class=\"card-click meetingRevealCls\" data-uuid='"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "'>\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.briefing_meeting_title : depth0),{"name":"if","hash":{},"fn":container.program(9, data, 0),"inverse":container.program(11, data, 0),"data":data})) != null ? stack1 : "")
    + "            <div class=\"font-lg\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"ID",{"name":"t","hash":{},"data":data}))
    + " #"
    + alias4(((helper = (helper = helpers.id || (depth0 != null ? depth0.id : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"id","hash":{},"data":data}) : helper)))
    + "</div>\n          </div>\n        </div>\n      </div>\n      <div class=\"card-content meetingRevealCls\" data-uuid='"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "'>\n        <div class=\"card-detail-content\">\n          <div>\n            <div class=\"card-detail icon-sep\">\n              <div class=\"text-content\">\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.multipleDayDisplayFormat : depth0),{"name":"if","hash":{},"fn":container.program(13, data, 0),"inverse":container.program(15, data, 0),"data":data})) != null ? stack1 : "")
    + "              </div>\n              <div class=\"icon-content hide jif-blue text-center icon-box\">\n                <i class=\"jif-checkin\"></i>\n                <div class=\"font-8\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"checkin",{"name":"t","hash":{},"data":data}))
    + "</div>\n              </div>\n            </div>\n            <div class=\"card-detail icon-sep\">\n              <div class=\"text-content location-text two-line-ellipsis\" title=\""
    + alias4(((helper = (helper = helpers.location || (depth0 != null ? depth0.location : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"location","hash":{},"data":data}) : helper)))
    + "\">\n                "
    + alias4(((helper = (helper = helpers.location || (depth0 != null ? depth0.location : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"location","hash":{},"data":data}) : helper)))
    + "\n              </div>\n              <div class=\"icon-content hide jif-blue text-center icon-box\">\n                <i class=\"jif-location\"></i>\n                <div class=\"font-8\" titl>"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"location",{"name":"t","hash":{},"data":data}))
    + "</div>\n              </div>\n            </div>\n          </div>\n          <div class=\"card-detail count\">\n            <div class=\"item-section attedee-counts\">\n              <div class=\"section-count accepted\">\n                <div class=\"count\">"
    + alias4(((helper = (helper = helpers.acceptedCount || (depth0 != null ? depth0.acceptedCount : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"acceptedCount","hash":{},"data":data}) : helper)))
    + "</div>\n                <div class=\"status\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"accepted",{"name":"t","hash":{},"data":data}))
    + "</div>\n              </div>\n              <div class=\"section-count declined\">\n                <div class=\"count\">"
    + alias4(((helper = (helper = helpers.declinedCount || (depth0 != null ? depth0.declinedCount : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"declinedCount","hash":{},"data":data}) : helper)))
    + "</div>\n                <div class=\"status\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"declined",{"name":"t","hash":{},"data":data}))
    + "</div>\n              </div>\n              <div class=\"section-count pending\">\n                <div class=\"count\">"
    + alias4(((helper = (helper = helpers.pendingCount || (depth0 != null ? depth0.pendingCount : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"pendingCount","hash":{},"data":data}) : helper)))
    + "</div>\n                <div class=\"status\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"pending",{"name":"t","hash":{},"data":data}))
    + "</div>\n              </div>\n            </div>\n          </div>\n        </div>\n      </div>\n      <div class=\"card-footer\">\n         <div class=\"card-footer-content\">\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.showUserActions : depth0),{"name":"if","hash":{},"fn":container.program(17, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "         </div>\n      </div>\n</div>\n\n\n\n\n";
},"useData":true});

/***/ }),

/***/ "./templates/helpers/ifDates.js":
/*!**************************************!*\
  !*** ./templates/helpers/ifDates.js ***!
  \**************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = function (item, opts) {
  if (envDetails.eventType === "OngoingSales" && "field_name" in item && item.field_name === "dates") {
    return opts.fn(this);
  } else {
    return opts.inverse(this);
  }
};

/***/ }),

/***/ "./templates/helpers/isEqualTo.js":
/*!****************************************!*\
  !*** ./templates/helpers/isEqualTo.js ***!
  \****************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = function (item, value, opts) {
  if (item === value) {
    return opts.fn(this);
  } else {
    return opts.inverse(this);
  }
};

/***/ }),

/***/ "./templates/helpers/isEqualToEitherOfOne.js":
/*!***************************************************!*\
  !*** ./templates/helpers/isEqualToEitherOfOne.js ***!
  \***************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = function (item, value1, value2, opts) {
  if (item === value1 || item === value2) {
    return opts.fn(this);
  } else {
    return opts.inverse(this);
  }
};

/***/ }),

/***/ "./templates/helpers/t.js":
/*!********************************!*\
  !*** ./templates/helpers/t.js ***!
  \********************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = function (i18n_key, label) {
	var result = i18n.t(i18n_key, { label: label });
	return new Handlebars.SafeString(result);
};

/***/ }),

/***/ "./templates/meeting/meeting-list.hbs":
/*!********************************************!*\
  !*** ./templates/meeting/meeting-list.hbs ***!
  \********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var Handlebars = __webpack_require__(/*! ../../node_modules/handlebars/runtime.js */ "./node_modules/handlebars/runtime.js");
function __default(obj) { return obj && (obj.__esModule ? obj["default"] : obj); }
module.exports = (Handlebars["default"] || Handlebars).template({"1":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers.unless.call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.isEBCEvent : depth0),{"name":"unless","hash":{},"fn":container.program(2, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"2":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers.unless.call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.hideAddActivityOption : depth0),{"name":"unless","hash":{},"fn":container.program(3, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"3":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers.unless.call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.isConsecutive : depth0),{"name":"unless","hash":{},"fn":container.program(4, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"4":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=depth0 != null ? depth0 : (container.nullContext || {});

  return "        <div class=\"card add\">\n          <div class=\"card-content\">\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.isStaffSchedule : depth0),{"name":"if","hash":{},"fn":container.program(5, data, 0),"inverse":container.program(7, data, 0),"data":data})) != null ? stack1 : "")
    + "          </div>\n          <div class=\"card-footer\">\n            <div class=\"card-footer-content\">\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.isStaffSchedule : depth0),{"name":"if","hash":{},"fn":container.program(9, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "            </div>\n          </div>\n        </div>\n";
},"5":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "              <div class=\"add-btn\">\n                <a href=\"javascript:void(0)\" id='book_agenda_add_btn'><i class=\"jif-plus-circle-o jif-light-grey jif-70\"></i></a>\n              </div>\n              <div>\n                <a href=\"javascript:void(0)\" id='book_agenda_item' class='btn btn-white btn-block text-ellipsis'>"
    + alias4(((helper = (helper = helpers.displayLabelForAddAgenda || (depth0 != null ? depth0.displayLabelForAddAgenda : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"displayLabelForAddAgenda","hash":{},"data":data}) : helper)))
    + "</a>\n              </div>\n              <div class=\"text-center font-sm\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"either_or",{"name":"t","hash":{},"data":data}))
    + "</div>\n              <div>\n                <form class=\"upload-csv\" style=\"position: relative;\">\n                  <input id=\"upload_agenda_item\" class=\"upload-agenda-input hide\" type=\"file\" accept=\".csv\">\n                  <label id=\"submit\" class=\"btn btn-white btn-block text-ellipsis\" for=\"upload_agenda_item\">"
    + alias4(((helper = (helper = helpers.displayLabelForUploadAgenda || (depth0 != null ? depth0.displayLabelForUploadAgenda : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"displayLabelForUploadAgenda","hash":{},"data":data}) : helper)))
    + "</label>\n                </form>\n              </div>\n";
},"7":function(container,depth0,helpers,partials,data) {
    return "              <div class=\"add-btn\">\n                <a href=\"javascript:void(0)\" id='book_meeting_add_btn'><i class=\"jif-plus-circle-o jif-light-grey jif-70\"></i></a>\n              </div>\n              <div><a href=\"javascript:void(0)\" id='book_meeting' class='btn btn-white btn-block'>"
    + container.escapeExpression(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(depth0 != null ? depth0 : (container.nullContext || {}),"book_activity",{"name":"t","hash":{},"data":data}))
    + "</a></div>\n";
},"9":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=container.escapeExpression;

  return "                <div class=\"text-center\">\n                  <a href=\""
    + alias2(((helper = (helper = helpers.downloadAgendaItemTemplateUrl || (depth0 != null ? depth0.downloadAgendaItemTemplateUrl : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(alias1,{"name":"downloadAgendaItemTemplateUrl","hash":{},"data":data}) : helper)))
    + "\" class=\"download-format-link font-xs\" data-i18n=\"download_room_csv_format\">"
    + alias2(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"download_agenda_item_csv_format",{"name":"t","hash":{},"data":data}))
    + "</a>\n                </div>\n";
},"11":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = container.invokePartial(__webpack_require__(/*! ../common_partials/_meeting.hbs */ "./templates/common_partials/_meeting.hbs"),depth0,{"name":"../common_partials/_meeting","data":data,"indent":"     ","helpers":helpers,"partials":partials,"decorators":container.decorators})) != null ? stack1 : "");
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=container.escapeExpression;

  return "<div class=\"card-container "
    + alias2(((helper = (helper = helpers.listClass || (depth0 != null ? depth0.listClass : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(alias1,{"name":"listClass","hash":{},"data":data}) : helper)))
    + " "
    + alias2(container.lambda(((stack1 = (depth0 != null ? depth0.toggleState : depth0)) != null ? stack1.viewStyle : stack1), depth0))
    + "\">\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.CanAccessViewOnlyEvent : depth0),{"name":"if","hash":{},"fn":container.program(1, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + ((stack1 = helpers.each.call(alias1,(depth0 != null ? depth0.meetingList : depth0),{"name":"each","hash":{},"fn":container.program(11, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "</div>\n";
},"usePartial":true,"useData":true});

/***/ }),

/***/ "./templates/meeting/meeting-servey-item.hbs":
/*!***************************************************!*\
  !*** ./templates/meeting/meeting-servey-item.hbs ***!
  \***************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var Handlebars = __webpack_require__(/*! ../../node_modules/handlebars/runtime.js */ "./node_modules/handlebars/runtime.js");
function __default(obj) { return obj && (obj.__esModule ? obj["default"] : obj); }
module.exports = (Handlebars["default"] || Handlebars).template({"1":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers["if"].call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.show_survey : depth0),{"name":"if","hash":{},"fn":container.program(2, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"2":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "<div class=\"col-md-12 js-meeting-servey-item\" data-uuid=\""
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\" data-attendee=\""
    + alias4(((helper = (helper = helpers.attendee || (depth0 != null ? depth0.attendee : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"attendee","hash":{},"data":data}) : helper)))
    + "\">\n  <div class=\"card card-xs\">\n    <div class=\"card-header card-xs-header\">\n      <div class=\"card-header-content card-xs-header-content\">\n        <div class=\"card-select\">\n          <input type=\"checkbox\" id=\"survey-"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\">\n          <label for=\"survey-"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\">\n            <div class=\"state "
    + alias4(((helper = (helper = helpers.status || (depth0 != null ? depth0.status : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"status","hash":{},"data":data}) : helper)))
    + "\">\n                <i class=\"jif-survey jif-dark-grey jif-18\"></i>\n            </div>\n          </label>\n        </div>\n      </div>\n    </div>\n    <div class=\"card-content card-xs-content\">\n      <div class=\"card-detail-content\">\n        <div>\n          <div class=\"card-detail\">\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.action : depth0),{"name":"if","hash":{},"fn":container.program(3, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + ((stack1 = helpers.unless.call(alias1,(depth0 != null ? depth0.action : depth0),{"name":"unless","hash":{},"fn":container.program(5, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "          </div>\n        </div>\n      </div>\n    </div>\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.survey_link_sent_at : depth0),{"name":"if","hash":{},"fn":container.program(7, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "  </div>\n</div>\n";
},"3":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "            <a href=\""
    + alias4(((helper = (helper = helpers.action || (depth0 != null ? depth0.action : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"action","hash":{},"data":data}) : helper)))
    + "\" target=\"_blank\">"
    + alias4(((helper = (helper = helpers.key || (data && data.key)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"key","hash":{},"data":data}) : helper)))
    + "</a>\n";
},"5":function(container,depth0,helpers,partials,data) {
    var helper;

  return "            <span class=\"font-lg\">"
    + container.escapeExpression(((helper = (helper = helpers.key || (data && data.key)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : (container.nullContext || {}),{"name":"key","hash":{},"data":data}) : helper)))
    + "</span>\n";
},"7":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=container.escapeExpression;

  return "    <div class=\"card-footer\">\n        <span class=\"font-sm\">"
    + alias2(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"last_sent_at",{"name":"t","hash":{},"data":data}))
    + " "
    + alias2(((helper = (helper = helpers.survey_link_sent_at || (depth0 != null ? depth0.survey_link_sent_at : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(alias1,{"name":"survey_link_sent_at","hash":{},"data":data}) : helper)))
    + "</span>\n    </div>\n";
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers.each.call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.surveys : depth0),{"name":"each","hash":{},"fn":container.program(1, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"useData":true});

/***/ }),

/***/ "./templates/meeting/meeting-type-list.hbs":
/*!*************************************************!*\
  !*** ./templates/meeting/meeting-type-list.hbs ***!
  \*************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var Handlebars = __webpack_require__(/*! ../../node_modules/handlebars/runtime.js */ "./node_modules/handlebars/runtime.js");
function __default(obj) { return obj && (obj.__esModule ? obj["default"] : obj); }
module.exports = (Handlebars["default"] || Handlebars).template({"1":function(container,depth0,helpers,partials,data) {
    var helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "	<li>\n      <div class=\"activity\" id=\""
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\" data-url=\""
    + alias4(((helper = (helper = helpers.meeting_url || (depth0 != null ? depth0.meeting_url : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"meeting_url","hash":{},"data":data}) : helper)))
    + "\" data-redirect-url=\""
    + alias4(((helper = (helper = helpers.redirect_url || (depth0 != null ? depth0.redirect_url : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"redirect_url","hash":{},"data":data}) : helper)))
    + "\" data-template-url=\""
    + alias4(((helper = (helper = helpers.template_url || (depth0 != null ? depth0.template_url : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"template_url","hash":{},"data":data}) : helper)))
    + "\" data-activity-source=\""
    + alias4(((helper = (helper = helpers.source || (depth0 != null ? depth0.source : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"source","hash":{},"data":data}) : helper)))
    + "\">\n        <div class=\"activity-icon\">\n          <i class=\""
    + alias4(((helper = (helper = helpers.icon_url || (depth0 != null ? depth0.icon_url : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"icon_url","hash":{},"data":data}) : helper)))
    + " jif-dark-grey jif-34\"></i>\n        </div>\n        <div class=\"activity-name\">\n        	<div title=\""
    + alias4(((helper = (helper = helpers.name || (depth0 != null ? depth0.name : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"name","hash":{},"data":data}) : helper)))
    + "\">"
    + alias4(((helper = (helper = helpers.name || (depth0 != null ? depth0.name : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"name","hash":{},"data":data}) : helper)))
    + "</div>\n        </div>\n      </div>\n    </li>\n";
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers.each.call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.meetingTypes : depth0),{"name":"each","hash":{},"fn":container.program(1, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"useData":true});

/***/ }),

/***/ "./templates/report/ondemand/filters.hbs":
/*!***********************************************!*\
  !*** ./templates/report/ondemand/filters.hbs ***!
  \***********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var Handlebars = __webpack_require__(/*! ../../../node_modules/handlebars/runtime.js */ "./node_modules/handlebars/runtime.js");
function __default(obj) { return obj && (obj.__esModule ? obj["default"] : obj); }
module.exports = (Handlebars["default"] || Handlebars).template({"1":function(container,depth0,helpers,partials,data) {
    var stack1;

  return "<div id=\"briefing-type-filter\" class=\"tab-pane active\" rle=\"tabpanel\">\n  <div class=\"row\">\n"
    + ((stack1 = helpers.each.call(depth0 != null ? depth0 : (container.nullContext || {}),((stack1 = (depth0 != null ? depth0.filters : depth0)) != null ? stack1.briefings : stack1),{"name":"each","hash":{},"fn":container.program(2, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "  </div>\n</div>\n";
},"2":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.escapeExpression, alias2=depth0 != null ? depth0 : (container.nullContext || {});

  return "        <div class=\"filter-item col-md-6\" data-type=\""
    + alias1(container.lambda((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\">\n        <label>"
    + alias1(__default(__webpack_require__(/*! ../../helpers/t.js */ "./templates/helpers/t.js")).call(alias2,(depth0 != null ? depth0.display_text : depth0),{"name":"t","hash":{},"data":data}))
    + "</label>\n"
    + ((stack1 = __default(__webpack_require__(/*! ../../helpers/isEqualToEitherOfOne.js */ "./templates/helpers/isEqualToEitherOfOne.js")).call(alias2,(depth0 != null ? depth0.field_name : depth0),"briefing_start_date","briefing_end_date",{"name":"isEqualToEitherOfOne","hash":{},"fn":container.program(3, data, 0),"inverse":container.program(5, data, 0),"data":data})) != null ? stack1 : "")
    + "        </div>\n";
},"3":function(container,depth0,helpers,partials,data) {
    var alias1=container.lambda, alias2=container.escapeExpression;

  return "          <div class=\"filter-values date-filter-container\">\n            <div class=\"row\">\n              <div class=\"col-md-12\">\n                <i class=\"jif-calendar-month jif-18\"></i>\n                <input type=\"text\" name=\""
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" class=\"form-control "
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" readonly=\"readonly\" autocomplete=\"off\">\n              </div>\n            </div>\n          </div>\n";
},"5":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers["if"].call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.date_field : depth0),{"name":"if","hash":{},"fn":container.program(6, data, 0),"inverse":container.program(8, data, 0),"data":data})) != null ? stack1 : "");
},"6":function(container,depth0,helpers,partials,data) {
    var alias1=container.lambda, alias2=container.escapeExpression;

  return "          <div class=\"jif-blue jif-calendar-month form-field-icon\">\n              <input id=\""
    + alias2(alias1((depth0 != null ? depth0.name : depth0), depth0))
    + "\" type=\"text\" readonly=\"true\" class=\"date form-control "
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + " "
    + alias2(alias1((depth0 != null ? depth0["class"] : depth0), depth0))
    + "\" data-type=\""
    + alias2(alias1((depth0 != null ? depth0.display_text : depth0), depth0))
    + "\" name=\""
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\"/>\n          </div>\n";
},"8":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.lambda, alias2=container.escapeExpression;

  return "          <div class=\"filter-values token-input-fld\">\n            <select class=\"form-control select "
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" data-type=\""
    + alias2(alias1((depth0 != null ? depth0.display_text : depth0), depth0))
    + "\" multiple name=\""
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" data-custom=\""
    + alias2(alias1((depth0 != null ? depth0.custom_label : depth0), depth0))
    + "\">\n"
    + ((stack1 = helpers.each.call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.value : depth0),{"name":"each","hash":{},"fn":container.program(9, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "            </select>\n          </div>\n";
},"9":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.lambda, alias2=container.escapeExpression;

  return "                <option value=\""
    + alias2(alias1((depth0 != null ? depth0.value : depth0), depth0))
    + "\" "
    + ((stack1 = helpers["if"].call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.selected : depth0),{"name":"if","hash":{},"fn":container.program(10, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + ">"
    + alias2(alias1((depth0 != null ? depth0.display_label : depth0), depth0))
    + "</option>\n";
},"10":function(container,depth0,helpers,partials,data) {
    return " selected ";
},"12":function(container,depth0,helpers,partials,data) {
    return "active";
},"14":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers.each.call(depth0 != null ? depth0 : (container.nullContext || {}),((stack1 = (depth0 != null ? depth0.filters : depth0)) != null ? stack1.meetings : stack1),{"name":"each","hash":{},"fn":container.program(15, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"15":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.escapeExpression, alias2=depth0 != null ? depth0 : (container.nullContext || {});

  return "        <div class=\"filter-item col-md-6\" data-type=\""
    + alias1(container.lambda((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\">\n          <label>"
    + alias1(__default(__webpack_require__(/*! ../../helpers/t.js */ "./templates/helpers/t.js")).call(alias2,(depth0 != null ? depth0.display_text : depth0),{"name":"t","hash":{},"data":data}))
    + "</label>\n"
    + ((stack1 = __default(__webpack_require__(/*! ../../helpers/isEqualToEitherOfOne.js */ "./templates/helpers/isEqualToEitherOfOne.js")).call(alias2,(depth0 != null ? depth0.field_name : depth0),"meeting_start_time","meeting_end_time",{"name":"isEqualToEitherOfOne","hash":{},"fn":container.program(16, data, 0),"inverse":container.program(18, data, 0),"data":data})) != null ? stack1 : "")
    + "        </div>\n";
},"16":function(container,depth0,helpers,partials,data) {
    var alias1=container.lambda, alias2=container.escapeExpression;

  return "            <div class=\"filter-values date-filter-container\">\n              <div class=\"row\">\n                <div class=\"col-md-12\">\n                  <i class=\"jif-calendar-month jif-18\"></i>\n                  <input type=\"text\" name=\""
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" class=\"form-control "
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" readonly=\"readonly\" autocomplete=\"off\">\n                </div>\n              </div>\n            </div>\n";
},"18":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.lambda, alias2=container.escapeExpression;

  return "            <div class=\"filter-values token-input-fld\">\n              <select class=\"form-control select "
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" data-type=\""
    + alias2(alias1((depth0 != null ? depth0.display_text : depth0), depth0))
    + "\" multiple name=\""
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" data-custom=\""
    + alias2(alias1((depth0 != null ? depth0.custom_label : depth0), depth0))
    + "\">\n"
    + ((stack1 = helpers.each.call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.value : depth0),{"name":"each","hash":{},"fn":container.program(19, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "              </select>\n            </div>\n";
},"19":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.lambda, alias2=container.escapeExpression;

  return "                  <option value=\""
    + alias2(alias1((depth0 != null ? depth0.value : depth0), depth0))
    + "\" "
    + ((stack1 = helpers["if"].call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.selected : depth0),{"name":"if","hash":{},"fn":container.program(10, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + ">"
    + alias2(alias1((depth0 != null ? depth0.display_label : depth0), depth0))
    + "</option>\n";
},"21":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = helpers.each.call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.filters : depth0),{"name":"each","hash":{},"fn":container.program(22, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"22":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.escapeExpression, alias2=depth0 != null ? depth0 : (container.nullContext || {});

  return "        <div class=\"filter-item col-md-6\" data-type=\""
    + alias1(container.lambda((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\">\n          <label>"
    + alias1(__default(__webpack_require__(/*! ../../helpers/t.js */ "./templates/helpers/t.js")).call(alias2,(depth0 != null ? depth0.display_text : depth0),{"name":"t","hash":{},"data":data}))
    + "</label>\n          <div class=\"filter-values token-input-fld\">\n"
    + ((stack1 = __default(__webpack_require__(/*! ../../helpers/ifDates.js */ "./templates/helpers/ifDates.js")).call(alias2,depth0,{"name":"ifDates","hash":{},"fn":container.program(23, data, 0),"inverse":container.program(26, data, 0),"data":data})) != null ? stack1 : "")
    + "          </div>\n        </div>\n";
},"23":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.lambda, alias2=container.escapeExpression;

  return "              <input class=\"form-control date "
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" data-type=\""
    + alias2(alias1((depth0 != null ? depth0.display_text : depth0), depth0))
    + "\" name=\""
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" "
    + ((stack1 = helpers["if"].call(depth0 != null ? depth0 : (container.nullContext || {}),((stack1 = ((stack1 = (depth0 != null ? depth0.value : depth0)) != null ? stack1["0"] : stack1)) != null ? stack1.selected : stack1),{"name":"if","hash":{},"fn":container.program(24, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + " />\n";
},"24":function(container,depth0,helpers,partials,data) {
    var stack1;

  return " value="
    + container.escapeExpression(container.lambda(((stack1 = ((stack1 = (depth0 != null ? depth0.value : depth0)) != null ? stack1["0"] : stack1)) != null ? stack1.value : stack1), depth0))
    + " ";
},"26":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.lambda, alias2=container.escapeExpression;

  return "              <select class=\"form-control select "
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" data-type=\""
    + alias2(alias1((depth0 != null ? depth0.display_text : depth0), depth0))
    + "\" multiple name=\""
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" data-custom=\""
    + alias2(alias1((depth0 != null ? depth0.custom_label : depth0), depth0))
    + "\">\n"
    + ((stack1 = helpers.each.call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.value : depth0),{"name":"each","hash":{},"fn":container.program(19, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "              </select>\n";
},"28":function(container,depth0,helpers,partials,data) {
    var stack1;

  return "    <hr/>\n    <label class=\"font-semi-bold\">Attendees</label>\n    <div class=\"row\">\n"
    + ((stack1 = helpers.each.call(depth0 != null ? depth0 : (container.nullContext || {}),((stack1 = (depth0 != null ? depth0.filters : depth0)) != null ? stack1.userFilters : stack1),{"name":"each","hash":{},"fn":container.program(29, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "    </div>\n";
},"29":function(container,depth0,helpers,partials,data) {
    var stack1;

  return ((stack1 = __default(__webpack_require__(/*! ../../helpers/isEqualTo.js */ "./templates/helpers/isEqualTo.js")).call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.field_name : depth0),"meeting_participants",{"name":"isEqualTo","hash":{},"fn":container.program(30, data, 0),"inverse":container.program(33, data, 0),"data":data})) != null ? stack1 : "");
},"30":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.lambda, alias2=container.escapeExpression, alias3=depth0 != null ? depth0 : (container.nullContext || {});

  return "          <div class=\"filter-item col-md-12 hide "
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" data-type=\""
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\">\n            <div class=\"checkbox\">\n              <input type=\"checkbox\" "
    + ((stack1 = helpers["if"].call(alias3,((stack1 = ((stack1 = (depth0 != null ? depth0.value : depth0)) != null ? stack1["0"] : stack1)) != null ? stack1.value : stack1),{"name":"if","hash":{},"fn":container.program(31, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + " id="
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + " name="
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + " data-type=\""
    + alias2(alias1((depth0 != null ? depth0.display_text : depth0), depth0))
    + "\" >\n              <label for="
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + ">"
    + alias2(__default(__webpack_require__(/*! ../../helpers/t.js */ "./templates/helpers/t.js")).call(alias3,(depth0 != null ? depth0.display_text : depth0),{"name":"t","hash":{},"data":data}))
    + "</label>\n            </div>\n          </div>\n";
},"31":function(container,depth0,helpers,partials,data) {
    return " checked ";
},"33":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.lambda, alias2=container.escapeExpression, alias3=depth0 != null ? depth0 : (container.nullContext || {});

  return "          <div class=\"filter-item col-md-6\" data-type=\""
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\">\n            <label>"
    + alias2(__default(__webpack_require__(/*! ../../helpers/t.js */ "./templates/helpers/t.js")).call(alias3,(depth0 != null ? depth0.display_text : depth0),{"name":"t","hash":{},"data":data}))
    + "</label>\n            <div class=\"filter-values token-input-fld\">\n              <select class=\"form-control select attendee-select "
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\" data-type=\""
    + alias2(alias1((depth0 != null ? depth0.display_text : depth0), depth0))
    + "\" multiple name=\""
    + alias2(alias1((depth0 != null ? depth0.field_name : depth0), depth0))
    + "\">\n"
    + ((stack1 = helpers.each.call(alias3,(depth0 != null ? depth0.value : depth0),{"name":"each","hash":{},"fn":container.program(19, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "              </select>\n            </div>\n          </div>\n";
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=depth0 != null ? depth0 : (container.nullContext || {});

  return ((stack1 = helpers["if"].call(alias1,((stack1 = (depth0 != null ? depth0.filters : depth0)) != null ? stack1.briefings : stack1),{"name":"if","hash":{},"fn":container.program(1, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "<div id=\"meeting-type-filter\" class=\"tab-pane "
    + ((stack1 = helpers.unless.call(alias1,((stack1 = (depth0 != null ? depth0.filters : depth0)) != null ? stack1.briefings : stack1),{"name":"unless","hash":{},"fn":container.program(12, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "\" role=\"tabpanel\">\n  <div class=\"row\">\n"
    + ((stack1 = helpers["if"].call(alias1,((stack1 = (depth0 != null ? depth0.filters : depth0)) != null ? stack1.meetings : stack1),{"name":"if","hash":{},"fn":container.program(14, data, 0),"inverse":container.program(21, data, 0),"data":data})) != null ? stack1 : "")
    + "  </div>\n"
    + ((stack1 = helpers["if"].call(alias1,((stack1 = (depth0 != null ? depth0.filters : depth0)) != null ? stack1.userFilters : stack1),{"name":"if","hash":{},"fn":container.program(28, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "</div>\n\n\n\n\n\n\n";
},"useData":true});

/***/ }),

/***/ "./templates/report/ondemand/selected_filter.hbs":
/*!*******************************************************!*\
  !*** ./templates/report/ondemand/selected_filter.hbs ***!
  \*******************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var Handlebars = __webpack_require__(/*! ../../../node_modules/handlebars/runtime.js */ "./node_modules/handlebars/runtime.js");
function __default(obj) { return obj && (obj.__esModule ? obj["default"] : obj); }
module.exports = (Handlebars["default"] || Handlebars).template({"1":function(container,depth0,helpers,partials,data,blockParams,depths) {
    var stack1;

  return ((stack1 = helpers.each.call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.values : depth0),{"name":"each","hash":{},"fn":container.program(2, data, 0, blockParams, depths),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"2":function(container,depth0,helpers,partials,data,blockParams,depths) {
    var helper, alias1=container.lambda, alias2=container.escapeExpression, alias3=depth0 != null ? depth0 : (container.nullContext || {}), alias4=helpers.helperMissing, alias5="function";

  return "	<li class=\"selected-filter\" data-type=\""
    + alias2(alias1((container.data(data, 1) && container.data(data, 1).key), depth0))
    + "\">\n		<div class=\"selected-item\" data-key=\""
    + alias2(((helper = (helper = helpers.key || (depth0 != null ? depth0.key : depth0)) != null ? helper : alias4),(typeof helper === alias5 ? helper.call(alias3,{"name":"key","hash":{},"data":data}) : helper)))
    + "\">\n			<a class=\"remove\" href=\"javascript:void(0)\">\n				<i class=\"jif-close close-applied-filter jif-dark1-grey\"></i>\n			</a>\n			<span class=\"remove_filter_icon\">"
    + alias2(alias1((depths[1] != null ? depths[1].display_name : depths[1]), depth0))
    + ": "
    + alias2(((helper = (helper = helpers.name || (depth0 != null ? depth0.name : depth0)) != null ? helper : alias4),(typeof helper === alias5 ? helper.call(alias3,{"name":"name","hash":{},"data":data}) : helper)))
    + "</span>\n		</div>\n	</li>\n";
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data,blockParams,depths) {
    var stack1;

  return ((stack1 = helpers.each.call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.filter : depth0),{"name":"each","hash":{},"fn":container.program(1, data, 0, blockParams, depths),"inverse":container.noop,"data":data})) != null ? stack1 : "");
},"useData":true,"useDepths":true});

/***/ })

/******/ });
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vLy4vYXBwL3NjcmlwdHMvTWVldGluZy9hY3Rpb25zLmpzIiwid2VicGFjazovLy8uL2FwcC9zY3JpcHRzL01lZXRpbmcvYXBwLmpzIiwid2VicGFjazovLy8uL2FwcC9zY3JpcHRzL01lZXRpbmcvaGFuZGxlci5qcyIsIndlYnBhY2s6Ly8vLi9hcHAvc2NyaXB0cy9NZWV0aW5nL3N0b3JlLmpzIiwid2VicGFjazovLy8uL2FwcC9zY3JpcHRzL2NvbW1vbnMvamlmZmxlL2FwaS5qcyIsIndlYnBhY2s6Ly8vLi9hcHAvc2NyaXB0cy9jb21tb25zL21lZXRpbmdfZmlsdGVycy5qcyIsIndlYnBhY2s6Ly8vLi9hcHAvc2NyaXB0cy91dGlscy9pbmRleC5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9kaXN0L2Nqcy9oYW5kbGViYXJzLnJ1bnRpbWUuanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9iYXNlLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL2Rpc3QvY2pzL2hhbmRsZWJhcnMvZGVjb3JhdG9ycy5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9kaXN0L2Nqcy9oYW5kbGViYXJzL2RlY29yYXRvcnMvaW5saW5lLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL2Rpc3QvY2pzL2hhbmRsZWJhcnMvZXhjZXB0aW9uLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL2Rpc3QvY2pzL2hhbmRsZWJhcnMvaGVscGVycy5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9kaXN0L2Nqcy9oYW5kbGViYXJzL2hlbHBlcnMvYmxvY2staGVscGVyLW1pc3NpbmcuanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9oZWxwZXJzL2VhY2guanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9oZWxwZXJzL2hlbHBlci1taXNzaW5nLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL2Rpc3QvY2pzL2hhbmRsZWJhcnMvaGVscGVycy9pZi5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9kaXN0L2Nqcy9oYW5kbGViYXJzL2hlbHBlcnMvbG9nLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL2Rpc3QvY2pzL2hhbmRsZWJhcnMvaGVscGVycy9sb29rdXAuanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9oZWxwZXJzL3dpdGguanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9sb2dnZXIuanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9uby1jb25mbGljdC5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9kaXN0L2Nqcy9oYW5kbGViYXJzL3J1bnRpbWUuanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9zYWZlLXN0cmluZy5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9kaXN0L2Nqcy9oYW5kbGViYXJzL3V0aWxzLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL3J1bnRpbWUuanMiLCJ3ZWJwYWNrOi8vLyh3ZWJwYWNrKS9idWlsZGluL2dsb2JhbC5qcyIsIndlYnBhY2s6Ly8vLi90ZW1wbGF0ZXMvY29tbW9uX3BhcnRpYWxzL19tZWV0aW5nLmhicyIsIndlYnBhY2s6Ly8vLi90ZW1wbGF0ZXMvY29tbW9uX3BhcnRpYWxzL19tZWV0aW5nX2NhcmQuaGJzIiwid2VicGFjazovLy8uL3RlbXBsYXRlcy9oZWxwZXJzL2lmRGF0ZXMuanMiLCJ3ZWJwYWNrOi8vLy4vdGVtcGxhdGVzL2hlbHBlcnMvaXNFcXVhbFRvLmpzIiwid2VicGFjazovLy8uL3RlbXBsYXRlcy9oZWxwZXJzL2lzRXF1YWxUb0VpdGhlck9mT25lLmpzIiwid2VicGFjazovLy8uL3RlbXBsYXRlcy9oZWxwZXJzL3QuanMiLCJ3ZWJwYWNrOi8vLy4vdGVtcGxhdGVzL21lZXRpbmcvbWVldGluZy1saXN0LmhicyIsIndlYnBhY2s6Ly8vLi90ZW1wbGF0ZXMvbWVldGluZy9tZWV0aW5nLXNlcnZleS1pdGVtLmhicyIsIndlYnBhY2s6Ly8vLi90ZW1wbGF0ZXMvbWVldGluZy9tZWV0aW5nLXR5cGUtbGlzdC5oYnMiLCJ3ZWJwYWNrOi8vLy4vdGVtcGxhdGVzL3JlcG9ydC9vbmRlbWFuZC9maWx0ZXJzLmhicyIsIndlYnBhY2s6Ly8vLi90ZW1wbGF0ZXMvcmVwb3J0L29uZGVtYW5kL3NlbGVjdGVkX2ZpbHRlci5oYnMiXSwibmFtZXMiOlsiTWVldGluZ0FjdGlvbnMiLCJSZWZsdXgiLCJjcmVhdGVBY3Rpb25zIiwibW9kdWxlIiwiZXhwb3J0cyIsImluaXRJMThuIiwiZW5Mb2NhbGUiLCJIYW5kbGVyIiwicmVxdWlyZSIsIkFwaSIsIiQiLCJkb2N1bWVudCIsInJlYWR5IiwiamlmZmxlIiwic2ZkY0hhbmRsZXIiLCJtZWV0aW5nSW5pdCIsImluaXQiLCJzZXR1cFVpSTE4biIsIkFjdGlvbnMiLCJTdG9yZSIsIm1lZXRpbmdGaWx0ZXJDbXAiLCJwdXRTZWFyY2hRdWVyeVBhcmFtIiwiTWVldGluZ0hhbmRsZXIiLCJfIiwiaXNVbmRlZmluZWQiLCJ3aW5kb3ciLCJ1c2VyVHlwZSIsIk1lZXRpbmdUeXBlIiwibWVldGluZ0xpc3RDb250YWluZXIiLCJhZ2VuZGFMaXN0Q29udGFpbmVyIiwiYXBwbGllZEZpbHRlcnNDb250YWluZXIiLCJ0b2dnbGVCdG5VbCIsImdsb2JhbFNlYXJjaCIsImZpbHRlclNlYXJjaEZpZWxkIiwicmVzZXRGaWx0ZXJCdG4iLCJhcHBseUZpbHRlckJ0biIsImZpbHRlclRvZ2dsZUJ0biIsImZpbHRlciIsImZpbHRlclN0YXJ0RGF0ZSIsImZpbHRlckVuZERhdGUiLCJleHBvcnRCdG4iLCJtZWV0aW5nQ291bnQiLCJtZWV0aW5nQ291bnRNb2JpbGUiLCJib29rTWVldGluZ0J0biIsImJvb2tNZWV0aW5nQWRkQnRuIiwiYm9va0FnZW5kYUJ0biIsImJvb2tBZ2VuZGFBZGRCdG4iLCJub3RpZmljYXRpb25Nb2RhbCIsImZpbHRlclBhbmVsIiwic2VsZWN0QWN0aXZpdHlNb2RhbCIsIm1lZXRpbmdBY3Rpdml0eUNvbnRhaW5lciIsInNlbGVjdGVkTWVldGluZ0NhcmRIYXNoIiwic3VydmV5U2VsZWN0ZWRNZWV0aW5nIiwiaGFzU2VsZWN0ZWRNZWV0aW5ncyIsInNlbGVjdEFsbEZsYWciLCJidWxrQWN0aW9uQmFyIiwiaXNTdGFmZkV2ZW50IiwiZGlzcGxheUxhYmVsRm9yQWdlbmRhIiwidXVpZE9mTWVldGluZ1R5cGVGb3JBZ2VuZGEiLCJhZ2VuZGFJdGVtRGF0ZVRpbWVGb3JtYXQiLCJtZWV0aW5nVGltZUZvcm1hdCIsIm1lZXRpbmdEYXRlRm9ybWF0IiwiZXh0ZXJuYWxDb3VudFRhYiIsIm1vYmlsZUV4dGVybmFsQ291bnRUYWIiLCJpbnRlcm5hbENvdW50VGFiIiwibW9iaWxlSW50ZXJuYWxDb3VudFRhYiIsInNlc3Npb25Db3VudFRhYiIsImNvbnNlY3V0aXZlTWVldGluZ1RhYiIsIm1vYmlsZUNvbnNlY3V0aXZlQ291bnRUYWIiLCJtb2JpbGVTZXNzaW9uQ291bnRUYWIiLCJjdXJyZW50VGFiIiwibW9iaWxlQ3VycmVudFRhYiIsInJldmlld2VlTWVldGluZ0NvdW50VGFiIiwibW9iaWxlUmV2aWV3ZWVNZWV0aW5nQ291bnRUYWIiLCJpc0ludGVybmFsIiwibW9iaWxlVGFiQ2hlY2tpbiIsInVzZXJUYWIiLCJtb2JpbGVDdXJyVGFiIiwic3VydmV5TW9kYWxFbCIsImJ1bGtDYW5jZWxCdG4iLCJUUkFDS1NfQU5EX1NFU1NJT05TX01BU1RFUl9OQU1FIiwic3RvcmVIYW5kbGVycyIsIm1lZXRpbmdsaXN0aW5nIiwiaGFuZGxlTWVldGluZ0xpc3QiLCJ2aWV3Y2hhbmdlZCIsImhhbmRlbFZpZXdUb2dnbGUiLCJtZWV0aW5nRmlsdGVycyIsInNldE1lZXRpbmdGaWx0ZXJzIiwib25CdWxrQXBwcm92YWxTdWNjZXNzIiwib25CdWxrQ2FuY2VsU3VjY2VzcyIsIm9uQnVsa0NhbmNlbEZhaWx1cmUiLCJvbkJ1bGtBcHByb3ZhbEZhaWx1cmUiLCJvbkJ1bGtSZWludml0ZVVzZXJTdWNjZXNzIiwiZXZlbnREZXRhaWxzIiwib25FdmVudERldGFpbHMiLCJhZ2VuZGFJdGVtVXBsb2FkRmFpbHVyZSIsImFnZW5kYUl0ZW1VcGxvYWRGYWlsdXJlSGFuZGxlciIsImFnZW5kYUl0ZW1VcGxvYWRTdWNjZXNzIiwiYWdlbmRhSXRlbVVwbG9hZFN1Y2Nlc3NIYW5kbGVyIiwiYWRkVG9TZWxlY3RlZE1lZXRpbmdDYXJkSGFzaCIsInNlcnZleU1haWxzVHJpZ2dlcmVkIiwiZXZlbnRJbmZvIiwibWVldGluZ1R5cGVIYXNoIiwiZGlzcGxheVRleHQiLCJjdXJyZW50TW9iaWxlVGFiIiwiY2hlY2tpblVybCIsIkVORFBPSU5UUyIsImNoZWNraW5fbWVldGluZ3NfbGlzdCIsInNlbGVjdEFsbENsYXNzIiwiaXNDb25zZWN1dGl2ZSIsImVkaXRNZWV0aW5nVXJsIiwiY29uc2VjdXRpdmVfbWVldGluZ3NfZWRpdF9wYXRoIiwidmlld01lZXRpbmdVcmwiLCJjb25zZWN1dGl2ZV9tZWV0aW5nc192aWV3X3BhdGgiLCJtZWV0aW5nX3JlcXVlc3RfZWRpdF9wYXRoIiwibWVldGluZ19yZXF1ZXN0X3ZpZXdfcGF0aCIsImZldGNoRXZlbnREZXRhaWxzIiwic2hvd0FjdGl2aXRpZXMiLCJSZWdFeHAiLCJleGVjIiwibG9jYXRpb24iLCJzZWFyY2giLCJzaG93TWVldGluZ0FjdGl2aXRpZXMiLCJFdmVudFN0b3JlIiwibGlzdGVuIiwiZGF0YSIsImZ1bmMiLCJ0eXBlIiwiTWVldGluZ1N0b3JlIiwic2V0Q3VycmVudFVzZXJGbGFncyIsImlzU3RhZmZTY2hlZHVsaW5nRXZlbnQiLCJnZXRFdmVudERldGFpbHMiLCJzdWNjZXNzIiwic2V0dXBGb3JTdGFmZlNjaGVkdWxlRXZlbnQiLCJnZXRGaWVsZEZyb21NZWV0aW5nVHlwZUZvckFnZW5kYSIsInNldHVwRm9yVHJhZGVTaG93RXZlbnQiLCJlbmFibGVTZWxlY3RBbGxGdW5jdGlvbmFsaXR5Iiwic2VsZWN0QWxsQnRuIiwicmVtb3ZlQ2xhc3MiLCJNZWV0aW5nQWN0aW9uU3RvcmUiLCJyZXN1bHQiLCJ1cGRhdGVDYXJkIiwic2V0dXBMaXN0ZW5lcnNGb3JTdGFmZlNjaGVkdWxlRXZlbnQiLCJnZXRGaWx0ZXJzIiwiZW52RGV0YWlscyIsInByZWRlZmluZWRfZmlsdGVycyIsImF0dGFjaENvbW1vblVJTGlzdGVuZXJlcyIsIm9uIiwiZGVib3VuY2UiLCJzZWFyY2hNZWV0aW5ncyIsInVwZGF0ZVRvZ2dsZVZpZXdTdGF0ZSIsImhhbmRsZUJ1bGtBcHByb3ZlTWVldGluZ3MiLCJoYW5kbGVCdWxrUmVpbnZpdGVVc2VycyIsImhhbmRsZUZpbHRlckNsaWNrIiwicmVzZXRGaWx0ZXIiLCJlIiwic3RvcFByb3BhZ2F0aW9uIiwidG9nZ2xlQ2xhc3MiLCJ1cGRhdGVTZWFyY2giLCJyZW1vdmVTZWxlY3RlZEZpbHRlciIsImluZmluaXRlU2Nyb2xsIiwib2Zmc2V0IiwiY2FsbGJhY2siLCJmZXRjaE1vcmVNZWV0aW5ncyIsImxpc3RDb25hdGFpbmVyIiwiY29udGFpbmVyIiwic2VsZWN0QWxsTWVldGluZyIsImhhbmRsZUFnZW5kYUl0ZW1VcGxvYWQiLCJjYXJkU2VsZWN0aW9uSGFuZGxlciIsInN1Ym1pdEFnZW5kYUl0ZW1VcGxvYWRGb3JtIiwiaGFuZGxlQWdlbmRhQ2xpY2siLCJzZWxlY3RvciIsImhhbmRsZUJvb2tBZ2VuZGFDbGljayIsInBvc3RNZWV0aW5nQWN0aW9uIiwicHV0TWVldGluZ0FjdGlvbiIsImNhbmNlbE1lZXRpbmciLCJoYW5kbGVCdWxrQ2FuY2VsIiwidXVpZCIsImFnZW5kYSIsImdldE1lZXRpbmciLCJ1cmwiLCJlZGl0Iiwic3RhdHVzIiwidXJsUHJlZml4IiwiY29tbW9ucyIsInJlZGlyZWN0UGFnZSIsIm1lZXRpbmdfcmVxdWVzdF9wYXRoIiwiZXZlbnQiLCJwcmV2ZW50RGVmYXVsdCIsImZpbGVFbGVtZW50IiwidGFyZ2V0IiwiRm9ybURhdGEiLCJmaWxlcyIsImxlbmd0aCIsInNob3ciLCJlYWNoIiwia2V5IiwidmFsdWUiLCJhcHBlbmQiLCJ1cGxvYWRBZ2VuZGFJdGVtQ3N2IiwiQWdlbmRhVXBsb2FkV2lkZ2V0IiwidmFsIiwiQWdlbmRhVXBsb2FkV2lkZ2V0Q2xvbmUiLCJjbG9uZSIsInJlcGxhY2VXaXRoIiwiZmluZCIsInN1Ym1pdCIsImZhZGVPdXQiLCJoZWFkZXJNZXNzYWdlIiwiaTE4biIsInQiLCJlcnJvcl9tZXNzYWdlIiwiY291bnRNZXNzYWdlIiwiZG93bmxvYWRfbGluayIsImVycm9ycyIsImlzU3RyaW5nIiwiaXNPYmplY3QiLCJmb3JFYWNoIiwiZXJyb3IiLCJpbmRleCIsImNsYXNzIiwidGl0bGUiLCJib2R5IiwiYWRkQ2xhc3MiLCJvZmYiLCJzZXR1cFVJIiwic2V0dXBMaXN0ZW5lcnMiLCJzZXRBY3RpdmVTdGF0ZSIsImdldExvY2FsVG9nZ2xlIiwic3RhcnREYXRlIiwibW9tZW50Iiwic3RhcnRfZGF0ZSIsImVuZERhdGUiLCJlbmRfZGF0ZSIsImRhdGVwaWNrZXIiLCJkYXRlRm9ybWF0IiwibWluRGF0ZSIsIl9kIiwibWF4RGF0ZSIsImFwaVJlc3BvbnNlIiwic2VhcmNoVGVybSIsImFwcGxpZWRTZWFyY2giLCJ0cmltIiwic2V0TWVldGluZ1NlYXJjaCIsImZpbHRlcnMiLCJhcHBseUZpbHRlciIsInNlYXJjaFZhbHVlIiwiRWwiLCJjdXJyZW50VGFyZ2V0IiwiaGFzQ2xhc3MiLCJ0b2dnbGVWaWV3Iiwic2VsZWN0ZWRWaWV3Iiwic2V0SXRlbSIsInZpZXdTdHlsZSIsImxpc3RIb2xkZXIiLCJ0aWxlU2l6ZSIsImRpc3BsYXlBZ2VuZGFJdGVtcyIsInVwZGF0ZUFjdGl2aXR5Q291bnQiLCJ0b3RhbCIsImRpc3BsYXlNZWV0aW5ncyIsInVwZGF0ZU1lZXRpbmdDb3VudCIsInRvdGFsRXh0ZXJuYWwiLCJ0b3RhbFNlc3Npb25zIiwidG90YWxDb25zZWNNZWV0aW5nIiwidG90YWxJbnRlcm5hbE1lZXRpbmciLCJ0b3RhbFJldmlld2VlTWVldGluZyIsInVwZGF0ZUZldGNoU3RhdGUiLCJpc0VtcHR5IiwicmVmcmVzaE1lZXRpbmdMaXN0QWZ0ZXJBY3Rpb24iLCJ0aW1lb3V0IiwiUnVudGltZUVycm9yIiwiam9pbiIsInNldEN1cnJlbnRQYWdlIiwicmVzZXRNZWV0aW5nTGlzdCIsImZldGNoTWVldGluZ3MiLCJhZGRDb21tb25GaWVsZHNGb3JEaXNwbGF5IiwiaXRlbSIsImludml0ZWVzX3N0YXR1c19jb3VudHMiLCJwZW5kaW5nQ291bnQiLCJwZW5kaW5nIiwidG90YWxJbnZpdGVlQ291bnQiLCJ0b3RhbF9pbnZpdGVlcyIsImFjY2VwdGVkQ291bnQiLCJhY2NlcHRlZCIsImRlY2xpbmVkQ291bnQiLCJkZWNsaW5lZCIsIm1lZXRpbmdfd2l0aCIsImZvbnRTaXplIiwiZ2V0Rm9udFNpemUiLCJnZXRUb2dnbGVTdGF0ZSIsInNob3dVc2VyQWN0aW9ucyIsIm1lZXRpbmdUeXBlIiwiYWRkRmllbGRzRm9yTWVldGluZ0Rpc3BsYXkiLCJtZWV0aW5nIiwibXVsdGlwbGVEYXlEaXNwbGF5Rm9ybWF0Iiwic3RhcnRUaW1lIiwic3RhcnRfdGltZSIsInV0YyIsImZvcm1hdCIsImVuZFRpbWUiLCJlbmRfdGltZSIsIm1lZXRpbmdEYXRlIiwiYWRkRmllbGRzRm9yQWdlbmRhRGlzcGxheSIsInN0YXJ0RGF0ZVRpbWUiLCJlbmREYXRlVGltZSIsImNvdW50IiwiZXh0ZXJuYWxDb3VudCIsInNlc3Npb25Db3VudCIsImNvbnNlY0NvdW50IiwiaW50ZXJuYWxDb3VudCIsInJldmlld2VlTWVldGluZ0NvdW50IiwiaW50ZXJuYWxUYWJUZXh0IiwiZXh0ZXJuYWxUYWJUZXh0IiwiZXh0ZXJuYWxNb2JpbGVUYWJUZXh0Iiwic2Vzc2lvblRhYnRleHQiLCJyZXZpZXdlZU1lZXRpbmdUYWJUZXh0IiwiY29uc2VjdXRpdmVUYWJUZXh0IiwiZGlzcGxheUNvdW50SW5UYWIiLCJ1cGRhdGVDb3VudEluQ3VyclRhYiIsInRhYiIsIm1vYmlsZVRhYiIsInRleHQiLCJ0ZXh0TGFiZWwiLCJtb2JpbGVUZXh0TGFiZWwiLCJzaWJsaW5ncyIsImxhYmVsIiwicGx1cmFsaXplIiwiaHRtbCIsInRlbXBsYXRlIiwiYWdlbmRhSXRlbXMiLCJtZWV0aW5ncyIsIm1hcCIsImFnZW5kYUl0ZW0iLCJjaGVja2VkIiwiaGlkZUFkZEFjdGl2aXR5T3B0aW9uIiwiaXNBZG1pbiIsImlzQWN0aXZpdHlNYW5hZ2VyIiwiZGlzcGxheUh0bWwiLCJtZWV0aW5nTGlzdCIsImlzRUJDRXZlbnQiLCJpc1N0YWZmU2NoZWR1bGUiLCJ0b2dnbGVTdGF0ZSIsImxpc3RDbGFzcyIsImFwcHJvdmVfbGFiZWwiLCJjYW5jZWxfbGFiZWwiLCJkZWNsaW5lX2xhYmVsIiwiYWNjZXB0X2xhYmVsIiwiQ2FuQWNjZXNzVmlld09ubHlFdmVudCIsImNhbl9hY2Nlc3Nfdm9fZXZlbnQiLCJkaXNwbGF5TGFiZWxGb3JBZGRBZ2VuZGEiLCJkaXNwbGF5TGFiZWxGb3JVcGxvYWRBZ2VuZGEiLCJkb3dubG9hZEFnZW5kYUl0ZW1UZW1wbGF0ZVVybCIsImRvd25sb2FkX2FnZW5kYV9pdGVtX3RlbXBsYXRlX3VybCIsInNob3dIaWRlQnVsa0FjdGlvbkJhciIsImJvb2tNZWV0aW5nUGF0aCIsImpuX2Jvb2tfbWVldGluZyIsImNsb25lRGVlcCIsImFwcHJvdmVMYWJlbCIsImNhbmNlbExhYmVsIiwiZGVjbGluZUxhYmVsIiwiYWNjZXB0TGFiZWwiLCJib29rX21lZXRpbmdfcGF0aCIsInNob3dOZXdNZWV0aW5nIiwiaGlkZUFwcHJvdmVCdXR0b25Gb3JTZmRjIiwiaGlkZVN1cnZleUljb25Gb3JTZmRjIiwic2hvdWxkU2hvd0FjdGlvbnNGb3JTZmRjIiwiaXNDU00iLCJpc01lZXRpbmdNYW5hZ2VyIiwiaXNKdW5pb3JNTSIsImlzUXVldWVNYW5hZ2VyIiwiZWxlbWVudCIsInByb3AiLCJuZXdMaXN0IiwidGhpc01lZXRpbmciLCJpcyIsImdldEF2YWlsYWJsZVNlbGVjdGVkTWVldGluZ3MiLCJkb25lIiwic3RvcmUiLCJnZXRUb3RhbE1lZXRpbmdDb3VudCIsImJvZHlNZXNzYWdlIiwiZGlzcGxheUxhYmVsIiwidG9Mb2NhbGVMb3dlckNhc2UiLCJkaXNtaXNzIiwiYnVsa0FwcHJvdmVNZWV0aW5ncyIsImJ1bGtSZWludml0ZVVzZXJzIiwidGl0bGVNZXNzYWdlIiwiYnVsa0NhbmNlbCIsImJvZHlUaXRsZSIsImFwcHJvdmVkTWVldGluZ0NvdW50IiwiY2xlYXJTZWxlY3RlZE1lZXRpbmdIYXNoIiwidG9CZUFwcHJvdmVkTWVldGluZ3MiLCJyZWxvYWRNZWV0aW5nTGlzdCIsImNhbmNlbGxlZE1lZXRpbmdDb3VudCIsInRvQmVDYW5jZWxsZWRNZWV0aW5ncyIsIk9iamVjdCIsImtleXMiLCJlbnRpdHlMYWJlbCIsImFwcHJvdmVkTWVldGluZ3MiLCJtZWV0aW5nVXVpZCIsInNjcm9sbFRvIiwiaGFuZGxlSW50ZXJuYWxUYWJDbGljayIsIm5ld1BhZ2UiLCJhcGV4X2pubWVldGluZ3MiLCJoYW5kbGVFeHRlcm5hbFRhYkNsaWNrIiwiaGFuZGxlU2Vzc2lvblRhYkNsaWNrIiwiZXZlbnROYW1lIiwiYXBleF9qbnNlc3Npb25zIiwiaGFuZGxlQ29uc2VjdXRpdmVUYWJDbGljayIsImNvbnNlY3V0aXZlX2xpc3RfcGFnZSIsImhhbmRsZUNoZWNraW5DbGljayIsInNob3dTdXJ2ZXlQb3B1cCIsImV4cG9ydE1lZXRpbmdzIiwiaGFuZGxlU2VydmV5TWFpbHMiLCJzZWxlY3RNZWV0aW5nQWN0aXZpdHkiLCJicmllZmluZ1N0ciIsImJyaWVmaW5nX3V1aWQiLCJyZXBsYWNlIiwibW9kZVEiLCJtZWV0aW5nUSIsInF1ZXJ5IiwiYWNjaWRJblVybCIsIm9wcG9ydHVuaXR5SWRJblVybCIsImxlYWRJZHNJblVybCIsInNvdXJjZUluVXJsIiwic2hvd0FjdGl2aXRpZXNJblVybCIsImpuX3ZpZXdfYm9va19tZWV0aW5nIiwiYXBwcm92ZUFsbE1lZXRpbmdzSGFuZGxlciIsImNhbmNlbEFsbE1lZXRpbmdzSGFuZGxlciIsImFjdGl2dGllc19hdHRyaWJ1dGVzIiwibWVldGluZ1R5cGVzIiwibW9kYWwiLCJiYWNrZHJvcCIsIm9yaWdpbiIsImpuX2Jvb2tfbm9taW5hdGlvbiIsIm1lZXRpbmdUeXBlVXVpZCIsImNsb3Nlc3QiLCJhdHRyIiwiY2hvc2VuQWN0aXZpdHkiLCJtZWV0aW5nVHlwZU1hc3RlciIsImFjdGl2aXR5IiwibWVldGluZ190eXBlX21hc3Rlcl9uYW1lIiwidXBkYXRlZFNlYXJjaFBhcmFtcyIsImFjdGlvblR5cGUiLCJtZWV0aW5nQWN0aW9uIiwiY2FsbCIsImdldEN1cnJlbnRQYWdlIiwiZ2V0VG90YWxQYWdlQ291bnQiLCJjb2xsYXBzZSIsImNsdWJiZWRGaWx0ZXJEYXRhIiwiZ2V0Q2x1YmJlZEZpbHRlckRhdGEiLCJ1cGRhdGVGaWx0ZXIiLCJmb3JtRGF0YSIsInN0b3JhYmxlRmlsdGVyRGF0YSIsInNob3dTZWxlY3RlZEZpbHRlciIsInNlbGVjdGVkRmlsdGVyRGF0YSIsImN1cnJlbnRFbCIsImZpbHRlclZhbHVlIiwiZmlsdGVyS2V5Iiwic2VsZWN0ZWRTdG9yZUZpbHRlciIsInN0b3JlZEZpbHRlcnMiLCJzdG9yZWRGaWx0ZXJEYXRhIiwic2VsZWN0ZWRDaG9zZW4iLCJzcGxpY2UiLCJpbkFycmF5IiwiZmluZEluZGV4IiwiaSIsInRyaWdnZXIiLCJyZW1vdmUiLCJlbGUiLCJnZW5lcmF0ZUV4cG9ydFVybCIsImlzQnVsa1N1cnZleSIsImJ1bGtfc3VydmV5Iiwic3VydmV5X2xpbmtzIiwibGluayIsImNvbnRhaW5zIiwidXNlcl9hY2Nlc3MiLCJyb2xlIiwic3VydmV5cyIsInNob3dfc2VuZF9tYWlsIiwidXVpZHMiLCJtb2RhbEVsIiwibWVldGluZ0luZm8iLCJ0ZW1wX3V1aWQiLCJwdXNoIiwidHJpZ2dlclNlcnZleU1haWxzIiwic2hvd1N1cnZleUVycm9yIiwic2VsZWN0ZWRNZWV0aW5nTGlzdCIsInJlc3BvbnNlIiwic2hvd19tZXNzYWdlIiwic2hvd1N1cnZleU1lc3NhZ2UiLCJ1cGRhdGVTdXJ2ZXlEZXRhaWxzIiwic3VydmV5VXVpZEFycmF5Iiwic3VydmV5X3V1aWQiLCJzdXJ2ZXkiLCJzdXJ2ZXlEZXRhaWxzIiwibWVyZ2UiLCJjYWxsQmFjayIsIm1lc3NhZ2UiLCJjcmVhdGVTdG9yZSIsImxpc3RlblRvTWFueSIsIm9uRmV0Y2hFdmVudERldGFpbHMiLCJwcm9taXNlIiwiZmV0Y2giLCJldmVudF9kZXRhaWxzIiwidGhlbiIsImJpbmQiLCJpc1N0YWZmU2NoZWR1bGluZyIsImZpZWxkX25hbWUiLCJtZWV0aW5nVHlwZUZvckFnZW5kYSIsImFjdGl2aXRpZXNfYXR0cmlidXRlcyIsIm5hbWUiLCJwaWNrIiwidG9nZ2xlU3RvcmUiLCJ2aWV3IiwidGlsZSIsImN1cnJlbnRfcGFnZSIsInRvdGFsX3BhZ2VzIiwiZmV0Y2hpbmciLCJwZXJfcGFnZV9tZWV0aW5nX2NvdW50IiwidG90YWxNZWV0aW5ncyIsInN0YXRlIiwiQXBpTGlzdCIsIm1lZXRpbmdzX2xpc3QiLCJsaXN0X2tleSIsImZpbHRlcl9wYXJhbSIsImV4Y2x1ZGVfY29uc2VjdXRpdmUiLCJjb25zZWN1dGl2ZV9tZWV0aW5nX2xpc3QiLCJhdmFpbGFibGVNZWV0aW5ncyIsIm9uRmV0Y2hPcHRpb25zIiwiZmFpbHVyZSIsImdldF9tZWV0aW5nX29wdGlvbnMiLCJwcmVmaXgiLCJmYWlsIiwib25VcGRhdGVGaWx0ZXIiLCJ1cGRhdGVGaWx0ZXJWYWx1ZXMiLCJvblJlRmV0Y2hNZWV0aW5ncyIsImZldGNoQWxsRXhpc3RpbmdDb3VudCIsInBlcl9wYWdlIiwib25GZXRjaE1lZXRpbmdzIiwiaXNDdXJyZW50VXNlck1NIiwiaXNDdXJyZW50VXNlckNTTSIsImlzRXhlY3V0aXZlQWRtaW4iLCJmaWx0ZXJEYXRhIiwiZmV0Y2hGaXJzdFBhZ2UiLCJvblVwbG9hZEFnZW5kYUl0ZW1Dc3YiLCJ1cGRhdGUiLCJ1cGxvYWRfYWdlbmRhX2l0ZW1fY3N2IiwicHJvY2Vzc0RhdGEiLCJjb250ZW50VHlwZSIsInJlc3BvbnNlSlNPTiIsIm9uR2V0RmlsdGVycyIsInByZVNlbGVjdGVkRmlsdGVycyIsImV2ZW50X2hvbWVfcGFnZSIsIm1lZXRpbmdzX2xpc3RfZmlsdGVycyIsIkRhdGUiLCJnZXRUaW1lIiwiaW5jbHVkZV9jaGVja2luIiwiZXhjbHVkZV9jYW5jZWxsZWRfbWVldGluZ3MiLCJhcHBsaWVkX3NlYXJjaCIsInJldmlldyIsInF1ZXJ5U3RyaW5nIiwiZW5kcG9pbnQiLCJwYXJhbSIsImdldEFwcGxpZWRGaWx0ZXJzIiwiZXhwb3J0X3JldmlldyIsIm1lZXRpbmdfcmVxdWVzdF9leHBvcnQiLCJnZXRTZWFyY2hWYWx1ZSIsImxhc3RWaWV3TG9hZGVkIiwiZ2V0SXRlbSIsImlzRmlsdGVyT1JTZWFyY2hBcHBsaWVkIiwiaGFzT3duUHJvcGVydHkiLCJvbkJ1bGtBcHByb3ZlTWVldGluZ3MiLCJidWxrX2FwcHJvdmVfbWVldGluZ3MiLCJnZXRGaWx0ZXJzRm9yQnVsa09wZXJhdGlvbnMiLCJtZWV0aW5nX3V1aWRzIiwiYXBwcm92ZWQiLCJvbkJ1bGtSZWludml0ZVVzZXJzIiwidG9CZVJlaW52aXRlZE1lZXRpbmdzIiwiYnVsa19yZWludml0ZV91c2VycyIsIm9uQnVsa0NhbmNlbCIsImJ1bGtfY2FuY2VsX21lZXRpbmdzIiwiY2FuY2VsbGVkIiwiaW50ZXJuYWxJbnZpdGVlcyIsImV4dGVybmFsSW52aXRlZXMiLCJjb25jYXQiLCJoYW5kbGVNZWV0aW5nT3BlcmF0aW9uc0Rpc3BsYXkiLCJBY2NlcHQiLCJEZWNsaW5lIiwiQXBwcm92ZSIsIkNhbmNlbCIsImFwcHJvdmVfYWxsIiwiY2FuY2VsX2FsbCIsImFjdGlvbnMiLCJhY3Rpb24iLCJpbnZpdGVfc3RhdHVzIiwiZ2V0U3RvcmFibGVGaWx0ZXJzIiwicGFnZV9ubyIsImdldEZldGNoU3RhdGUiLCJzdG9yYWJsZV9maWx0ZXJzIiwiSlNPTiIsInN0cmluZ2lmeSIsInBhZ2UiLCJjdXJyZW50VXNlclV1aWQiLCJjdXJyZW50VXNlciIsInVuaXEiLCJzaG93X3N1cnZleSIsIm5ld2x5TW9kaWZpZWRJZCIsIk51bWJlciIsIm5ld2x5TW9kaWZpZWRNZWV0aW5nIiwibG4iLCJwcmltYXJ5X3NvcnRpbmdfY29sdW1uIiwiY3JlYXRlZF9hdCIsImxhdGVzdCIsImlkIiwic29ydEJ5IiwidW5zaGlmdCIsImFwcGx5IiwidXBkYXRlVG90YWxNZWV0aW5nQ291bnQiLCJ0b3RhbF9lbnRyaWVzIiwic2V0VG90YWxQYWdlQ291bnQiLCJNYXRoIiwiY2VpbCIsImV4dGVybmFsX3JlcXVlc3RzX2NvdW50Iiwic2Vzc2lvbnNfY291bnQiLCJjb25zZWN1dGl2ZV9tZWV0aW5nc19jb3VudCIsImludGVybmFsX21lZXRpbmdzX2NvdW50IiwicmV2aWV3ZWVfbWVldGluZ3NfY291bnQiLCJvblRvZ2dsZVZpZXciLCJvblNlYXJjaE1lZXRpbmdzIiwic2VhcmNoX3ZhbCIsIm9uVXBkYXRlU2VhcmNoIiwib25SZXNldEZpbHRlciIsIm9uQXBwbHlGaWx0ZXIiLCJvblRyaWdnZXJTZXJ2ZXlNYWlscyIsInN1cnZleVVVSURTIiwicGF0aFBhcmFtIiwibWVldGluZ1VVSURTIiwiYXBpVXJsIiwic2VuZF9zdXJ2ZXlfbWVldGluZ19tYWlsIiwic2VuZF9idWxrX3N1cnZleV9tZWV0aW5nX21haWwiLCJvbk1lZXRpbmdBY3Rpb24iLCJwcm9taXNlT2JqIiwiYWNjZXB0X21lZXRpbmciLCJhY3RpdmF0ZV9ldmVudCIsImFjdGl2YXRlX3Jvb20iLCJhY3RpdmF0ZV91c2VyIiwiYWN0aXZpdHlfZGV0YWlscyIsImFkYXB0ZXJzIiwiYWRkX2F0dGVuZGVlX3RvX21lZXRpbmciLCJhZGRfbmV3X2xvY2F0aW9uIiwiYWRkX3N1cHBvcnRlZF9hcGkiLCJhbGVydF9kZXRhaWxzX2ZldGNoIiwiYWxlcnRfZmV0Y2giLCJhbGxfbWVldGluZ190eXBlcyIsImFwZXhfam5saXN0YWdlbmRhIiwiYXBpX21hcF9vcl9hZGRfdXNlciIsImVycm9yQ29uZmlnIiwiaGFuZGxlciIsImFwaV9yZWdpc3Rlcl91c2VyIiwiYXBpX3VwZGF0ZV91c2VyX2V2ZW50X3NldHRpbmdzIiwiY3VzdG9tX3RpdGxlIiwiYXBpX3VwZGF0ZV91c2VyIiwiYXBwb2ludG1lbnRfZmlsdGVyX29wdGlvbnMiLCJhcHByb3ZlX2V4dGVybmFsX3JlcXVlc3QiLCJhcHByb3ZlX21lZXRpbmciLCJhcHByb3ZlZF9tZWV0aW5nX2NvdW50IiwiYXV0b19yZW1pbmRlcl9zZXR0aW5nIiwiYXZhaWxhYmlsaXR5X2ZldGNoX2ViYyIsImF2YWlsYWJpbGl0eV9mZXRjaCIsImF2YWlsYWJpbGl0eV91cGRhdGUiLCJibG9ja191cGRhdGUiLCJicmllZmluZ19jZW50cmVfbG9uZ19kYXkiLCJicmllZmluZ19jZW50cmUiLCJicmllZmluZ19jdXN0b21fZm9ybXMiLCJicmllZmluZ19kZXRhaWxzIiwiYnVsa19hcHByb3ZlX21hcHBpbmdzIiwiYnVsa19jYW5jZWxfbWFwcGluZ3MiLCJidWxrX2VuZG9yc2VfdXNlcnMiLCJidWxrX3NldF9tbV9vbmx5X2ZsYWciLCJidWxrX3N5bmNfZXh0X2NhbF9mbGFnIiwiYnVsa19yZWxheF9zZmRjX29ubHlfcmVxdWVzdF9tZWV0aW5nIiwiYnVsa19zaG93X2FzX2V4dGVybmFsX2F0dGVuZGVlIiwiY2FsZW5kYXJfYXZhaWxhYmlsaXR5IiwiY2FsZW5kYXJfdXNlcl9hdmFpbGFiaWxpdHkiLCJjYW5fYXR0ZW5kX3Nlc3Npb24iLCJjYW5jZWxfZXh0ZXJuYWxfcmVxdWVzdCIsImNhbmNlbF9tZWV0aW5nIiwiY2hlY2tfYXR0ZW5kZWVfYXZhaWxhYmlsaXR5IiwiY2hlY2tpbl9jb25zZWN1dGl2ZV9tZWV0aW5nc19saXN0IiwiY2hlY2tpbl9saXN0X2ZpbHRlcnMiLCJjaGVja2luX21lZXRpbmdzIiwiY2hlY2tpbl9zZXNzaW9uc19saXN0IiwiY2hlY2tpbl91c2VycyIsImNpc19zZXJ2aWNlIiwiY29tcGFuaWVzX2xpc3QiLCJjb21wYW55X2ZldGNoIiwiY29uY2llcmdlX3NlcnZpY2VzX2NyZWF0ZSIsImNvbmNpZXJnZV9zZXJ2aWNlc191cGRhdGUiLCJjb25maWdfYXV0b19yZW1pbmQiLCJjb25maWdfaGlzdG9yeSIsImNvbmZpZ19pbnRlZ3JhdGlvbl91cGRhdGUiLCJjb25maWdfaW50ZWdyYXRpb24iLCJjb25maWdfbm90aWZpY2F0aW9uX3VwZGF0ZSIsImNvbmZpZ19ub3RpZmljYXRpb24iLCJjb25maWdfdG9waWNfdXBkYXRlIiwiY29uZmlnX3RvcGljIiwiY29uc2VjdXRpdmVfbWVldGluZ3NfZGV0YWlscyIsImNvcHlfY2FsZW5kYXJfc2V0dGluZ3MiLCJjb3B5X2Zvcm1fc2V0dGluZ3MiLCJjb3B5X21lZXRpbmdfc2V0dGluZ3MiLCJjb3B5X25vdGlmaWNhdGlvbl9zZXR0aW5ncyIsImNyZWF0ZV9jb25zZWN1dGl2ZV9tZWV0aW5ncyIsImNyZWF0ZV9leHRlcm5hbF9yZXF1ZXN0IiwiY3JlYXRlX2dyb3VwX25vbWluYXRpb24iLCJjcmVhdGVfaW50ZWdyYXRpb25fdXNlciIsImludGVncmF0aW9uX3VzZXIiLCJjcmVhdGVfbWFwcGluZyIsImNyZWF0ZV9vcl91cGRhdGVfdHJhY2siLCJjcmVhdGVfc2VsZl9ub21pbmF0aW9uIiwiY3JlYXRlX3Nlc3Npb24iLCJjcmVhdGVfdGFnX2Nsb3VkcyIsImN1c3RvbV9maWVsZF9vcHRpb25zIiwiY3VzdG9tX2Zvcm1fZGV0YWlscyIsImN1c3RvbWVyX2F2YWlsYWJpbGl0eSIsImN1c3RvbWVyX2NhbGVuZGFyX2V4cG9ydCIsImN1c3RvbV9sYWJlbHMiLCJkZWNsaW5lX21lZXRpbmciLCJkZWZhdWx0X21lZXRpbmdfbG9jYXRpb25fZW50aXRpZXMiLCJkZWxldGVfbWFwcGluZyIsImRlbGV0ZV9sb2NhdGlvbl9wcmVmZXJlbmNlIiwiZGVtYW5kX3JlcG9ydF9leHBvcnQiLCJkZW1hbmRfcmVwb3J0cyIsImRldGFpbGVkX2N1c3RvbV9sYWJlbHMiLCJkaXNhYmxlX3NhdmVkX3JlcG9ydCIsImRpc21pc3NfYWxlcnQiLCJkaXNtaXNzX25vdGlmaWNhdGlvbiIsImRvbWFpbl92YWxpZGF0aW9uIiwiZG9tYWluc192YWxpZCIsImRvdWJsZV9ib29rZWRfcmVzb3VyY2VzIiwidXNlcl90b3BpY19tYXBwaW5nX3RlbXBsYXRlX3VybCIsImVkaXRfdHJhY2siLCJlbmFibGVfZG91YmxlX2Jvb2tfdXNlcnMiLCJldmVudF9hY2Nlc3Nfc2V0dGluZ3MiLCJldmVudF9jb25maWdfZXhwb3J0IiwiZXZlbnRfY29uZmlnX2Zvcl91c2VyX2NhbGVuZGFyIiwiZXZlbnRfY29uZmlnX2ltcG9ydCIsImV2ZW50X2NvbmZpZyIsImV2ZW50X2NvbmZpZ3VyYXRpb25zIiwiZXZlbnRfZWJjX2NvbmZpZ3VyYXRpb25zIiwiZXZlbnRfaG9tZSIsImV2ZW50X25ldyIsImV2ZW50X3Jvb21fY2FsX3BhdGgiLCJldmVudF91c2VyX2NhbF9wYXRoIiwiZXZlbnRfdXNlcl9maWx0ZXJzIiwiZXZlbnRzX2luZm8iLCJldmVudHMiLCJleHBlcnRfdXNlcnMiLCJleHBvcnRfbWVldGluZ19jaGVja2luIiwiZXhwb3J0X3N1bW1hcnlfcmVwb3J0IiwiZXhwb3J0X3N1cnZleXMiLCJleHRfZW5hYmxlZF9mZXRjaF9mb3JtX3NldHRpbmdzIiwiZXh0ZXJuYWxfYXR0ZW5kZWVzIiwiZXh0ZXJuYWxfbWVldGluZ3NfbGlzdF9maWx0ZXJzIiwiZXh0ZXJuYWxfcmVxdWVzdF9kYXRlcyIsImV4dGVybmFsX3JlcXVlc3RfZXhwb3J0IiwiZXh0ZXJuYWxfcmVxdWVzdHMiLCJleHRlcm5hbF93aWRnZXRfc2Vzc2lvbnMiLCJleHRlcm5hbF93aWRnZXRfc2lnbnVwX3Nlc3Npb24iLCJleHRlcm5hbF93aWRnZXRfdG9waWNzIiwiZXh0ZXJuYWxfd2lkZ2V0X3RyYWNrcyIsImZhY2lsaXRpZXNfbGlzdCIsImZlYXR1cmVfZW5hYmxlX2ViYyIsImZldGNoX2FjdGl2ZV9ldmVudHMiLCJmZXRjaF9hY3Rpdml0aWVzIiwiZmV0Y2hfYWN0aXZpdHlfbGlzdCIsImZldGNoX2FjdGl2aXR5X21hbmFnZXIiLCJmZXRjaF9hY3Rpdml0eV9zZXR0aW5ncyIsImZldGNoX2FuYWx5dGljc19jb25maWdzIiwiZmV0Y2hfYXJjaGl2ZWRfZXZlbnRfbWVldGluZ19hbmFseXRpY3MiLCJmZXRjaF9hcmNoaXZlZF9ldmVudHNfbGlzdCIsImZldGNoX2FyY2hpdmVkX3JlcG9ydHMiLCJmZXRjaF9hdmFpbGFibGVfbWVldGluZ190eXBlcyIsImZldGNoX2Jvb2tpbmdfYW5hbHl0aWNzIiwiZmV0Y2hfYnJpZWZpbmdfd29ya2Zsb3ciLCJmZXRjaF9jYWxlbmRhcl9zZXR0aW5ncyIsImZldGNoX2NoYW5nYWJsZV9tZWV0aW5nX3R5cGVzIiwiZmV0Y2hfY29uY2llcmdlX2Zvcm0iLCJmZXRjaF9jb25jaWVyZ2Vfbm90aWZpY2F0aW9uX3NldHRpbmdzIiwiZmV0Y2hfY29uY2llcmdlX3NlcnZpY2VzIiwiZmV0Y2hfY29uc2VjdXRpdmVfbWVldGluZ19mb3JtX3NldHRpbmdzIiwiZmV0Y2hfY29uc2VjdXRpdmVfbWVldGluZ19ub3RpZmljYXRpb25fc2V0dGluZ3MiLCJmZXRjaF9jdXN0b21lcl9pbmZvX3ZhbHVlcyIsImZldGNoX2N1c3RvbWVyc19hbmFseXRpY3MiLCJmZXRjaF9lYmNfZm9ybSIsImZldGNoX2V4aXN0aW5nX21lZXRpbmdzIiwiZmV0Y2hfZXh0ZXJuYWxfbWVldGluZ19yZXF1ZXN0IiwiZmV0Y2hfZXh0ZXJuYWxfdXNlcl9mb3JtX2ZpZWxkcyIsImZldGNoX2Zvcm1fc2V0dGluZ3MiLCJmZXRjaF9mb3JtIiwiZmV0Y2hfZ3VpZGVkX3RvdXJfaW50ZWdyYXRpb25fZmllbGRzIiwiZmV0Y2hfaW50ZWdyYXRpb25fYmxvY2tfZmllbGRzIiwiZmV0Y2hfaW50ZWdyYXRpb25fbWVldGluZ19maWVsZHMiLCJmZXRjaF9pbnRlZ3JhdGlvbl9zdXJ2ZXlfZmllbGRzIiwiZmV0Y2hfaW52aXRlZXNfYW5hbHl0aWNzIiwiZmV0Y2hfbG9jYXRpb25fY29uZmlncyIsImZldGNoX21hcHBlZF9tZWV0aW5nX3R5cGVfZm9yX3JvbGUiLCJmZXRjaF9tYXBwaW5nX2RldGFpbHMiLCJmZXRjaF9tYXBwaW5nX2ZpbHRlcnMiLCJmZXRjaF9tYXBwaW5nX3J1bGVfdHlwZXMiLCJmZXRjaF9tYXBwaW5ncyIsImZldGNoX21hc3Rlcl9zdXBwb3J0ZWRfYXBpcyIsImZldGNoX21lZXRpbmdfYXR0ZW5kZWUiLCJmZXRjaF9tZWV0aW5nX2NvdW50IiwiZmV0Y2hfbWVldGluZ19kYXRhX2Zvcl9yZXBvcnRzIiwiZmV0Y2hfbWVldGluZ19kZXRhaWxzIiwiZmV0Y2hfbWVldGluZ19maWx0ZXJzIiwiZmV0Y2hfbWVldGluZ19saXN0X2NvcHlfYXR0ZW5kZWUiLCJmZXRjaF9tZWV0aW5nX2xpc3RfY3VzdG9tZXJfaW5mbyIsImZldGNoX21lZXRpbmdfcmVwb3J0c19oZWFkZXIiLCJmZXRjaF9tZWV0aW5nX3JlcG9ydHMiLCJmZXRjaF9tZWV0aW5nX3R5cGVfYW5hbHl0aWNzIiwiZmV0Y2hfbWVldGluZ190eXBlX2R1cmF0aW9ucyIsImZldGNoX21lZXRpbmdfdHlwZXMiLCJmZXRjaF9tZWV0aW5nc19hbmFseXRpY3MiLCJmZXRjaF9taW5pbXVtX3RpbWVzbG90IiwiZmV0Y2hfbm9taW5hdGlvbl9kZXRhaWwiLCJmZXRjaF9ub3RpZmljYXRpb25fc2V0dGluZ3MiLCJmZXRjaF9wb3J0YWxfY3VzdG9tX2Zvcm0iLCJmZXRjaF9wcmV2aWV3X21hcHBpbmdfZGV0YWlsIiwiZmV0Y2hfcHJldmlld19tZWV0aW5nX2RldGFpbCIsImZldGNoX3JlbW90ZV9lbnRpdGllcyIsImZldGNoX3JlcXVlc3Rvcl9lbWFpbCIsImZldGNoX3JvbGVzX2FuYWx5dGljcyIsImZldGNoX3Jvb21zX2FuYWx5dGljcyIsImZldGNoX3NjYW5uZWRfdXNlcnMiLCJmZXRjaF9zY2FubmVyc19uYW1lIiwiZmV0Y2hfc3RhbmRhcmRfcmVwb3J0IiwiZmV0Y2hfc3VydmV5X3RlbXBsYXRlIiwiZmV0Y2hfc3VydmV5cyIsImZldGNoX3RhZ19jb25maWdzIiwiZmV0Y2hfdGFnX2VudGl0eSIsImZldGNoX3RvcGljcyIsImZldGNoX3RyYWNrX3RvcGljcyIsImZldGNoX3RyYWNrX2FjdGl2aXRpZXMiLCJmZXRjaF90cmFuc2ZlcmFibGVfbWVldGluZ190eXBlcyIsImZldGNoX3VubWFwcGVkX3RvcGljX2VudGl0eSIsImZldGNoX3VwZGF0ZV9icmllZmluZ19ub3RpZmljYXRpb25fc2V0dGluZ3MiLCJmZXRjaF91c2VyX2RldGFpbHMiLCJmZXRjaF91c2VyX2ZpZWxkX21hcHBpbmdzIiwiZmV0Y2hfdXNlcl9mb3JtX3J1bGVzIiwiZmV0Y2hfdXNlcl9ub3RpZmljYXRpb24iLCJmZXRjaF91c2VyX3RvcGljcyIsImZldGNoX3ZhbGlkX21hcHBpbmdfVGltZXMiLCJmZXRjaF9jb25mZXJlbmNlX2xpc3QiLCJmZXRjaF9jb25mZXJlbmNlX2xpbmsiLCJmZXRjaF9yZXNvdXJjZV9kYXRhIiwiZmV0Y2hfdXNlcl9jdXN0b21fZmllbGRfbWFwcGluZyIsImZpbGVfdXBsb2FkX3VybCIsImZpbGxfYnVsa19jb25zZW50IiwiZ2V0X2Fubm91bmNlbWVudHMiLCJnZXRfYm9vdGhfdG91cl9kZXRhaWxzIiwiZ2V0X2JyaWVmaW5nX2ZpbHRlcnMiLCJnZXRfYnJpZWZpbmdfcmVwb3J0X29wdGlvbnMiLCJnZXRfY2hlY2tpbl9vcHRpb25zIiwiZ29vZ2xlX2NpdHlfc2VhcmNoIiwiZ29vZ2xlX3RpbWVfem9uZV9zZWFyY2giLCJzZXRfdXNlcl9zZWNfdGltZV96b25lIiwiZ2V0X2ViY19yb2xlX3ByaXZpbGVnZXMiLCJnZXRfc2VsZl9zZXJ2ZV9wcml2aWxlZ2VzIiwiZ2V0X2V4dF9tZWV0aW5nX29wdGlvbnMiLCJnZXRfZXh0ZXJuYWxfcmVxX2RldGFpbHMiLCJnZXRfZXh0ZXJuYWxfcmVxdWVzdCIsImdldF9tbV9saXN0IiwiZ2V0X29uZGVtYW5kX3VzZXJzX2xpc3QiLCJnZXRfcmVwb3J0X29wdGlvbnMiLCJnZXRfcmV2aWV3cyIsImdldF9zd2FwcGFibGVfcm9vbV9saXN0IiwiZ2V0X3RhZ19jbG91ZHMiLCJnZXRfdG9waWNzIiwiZ2V0X3VzZXJfcHJlZmVyZW5jZXMiLCJncm91cF9ub21pbmF0aW9uX2VkaXQiLCJncm91cF9ub21pbmF0aW9uX3ZpZXciLCJpbmFjdGl2YXRlX3Jvb21zIiwiaW5hY3RpdmF0ZV91c2VycyIsImludGVncmF0aW9uX2NvbmZpZ3VyYXRpb25zX2RldGFpbHMiLCJpbnRlZ3JhdGlvbl9jb25maWd1cmF0aW9uc19zY2hlbWEiLCJpbnRlZ3JhdGlvbl9leHRlcm5hbF91c2VyX2luZm8iLCJpbnRlZ3JhdGlvbl9maWVsZF9tYXBwaW5ncyIsImludGVncmF0aW9uIiwiaW50ZXJuYWxfYXR0ZW5kZWVzIiwibGlzdF9icmllZmluZ3NfYWdlbmRhIiwibGlzdF90cmFja3MiLCJtYWlsX3RlbXBsYXRlX3R5cGVfZW50aXRpZXNfZ2V0IiwibWFpbF90ZW1wbGF0ZV90eXBlX2dldCIsIm1hbmFnZV9leHRlcm5hbF91c2VycyIsIm1hbmFnZV91c2VycyIsIm1hbnVhbF9yZW1pbmRlcl91c2VyIiwibWFwcGFibGVfZ3JvdXBpbmdfdXNlcnMiLCJtYXBwYWJsZV9yZXF1ZXN0b3JzIiwibWFwcGFibGVfdXNlcnMiLCJtYXBwZWRfZXZlbnRzIiwibWFwcGluZ19saXN0IiwibWFwcGluZ19wYWdlIiwibWFwcGluZ192YWxpZF9kdXJhdGlvbnMiLCJtYXBwaW5nc19leHBvcnQiLCJtZWV0aW5nX2F2YWlsYWJpbGl0eSIsIm1lZXRpbmdfY3JlYXRlIiwibWVldGluZ19kcmFnIiwibWVldGluZ19mZXRjaCIsIm1lZXRpbmdfZ2V0X2NvbmZpZyIsIm1lZXRpbmdfZ2V0X3NldHRpbmdzIiwibWVldGluZ19oaXN0b3J5IiwibWVldGluZ19ob3N0X2NvdW50IiwibWVldGluZ19saXN0IiwibWVldGluZ19ub3RpZmljYXRpb25zIiwibWVldGluZ19zZXRfY29uZmlnIiwibWVldGluZ19zZXRfc2V0dGluZyIsIm1lZXRpbmdfdHlwZV9jcmVhdGUiLCJtZWV0aW5nX3R5cGVfdXBkYXRlIiwibWVldGluZ190eXBlc19vZl9jb25zZWN1dGl2ZV9zdWJfbWVldGluZ3MiLCJtZWV0aW5nX3R5cGVzIiwibWlzY2VsbGFuZW91c19yZXBvcnRfZXhwb3J0Iiwibm9uX2V2ZW50X2NvbmZpZ3VyYXRpb25zIiwibm90aWZpY2F0aW9uX2ZldGNoIiwib25fYmVoYWxmX2FjdGlvbnMiLCJwb3J0YWwiLCJwcmludF91c2VyX2JhZGdlIiwicmVnaXN0ZXJfdXNlciIsInJlaW52aXRlX2F0dGVuZGVlX3RvX21lZXRpbmciLCJyZWludml0ZV91c2VycyIsInJlamVjdF9leHRlcm5hbF9yZXF1ZXN0IiwicmVqZWN0X2xvY2F0aW9uX3ByZWZlcmVuY2UiLCJyZW1pbmRlcl9ub3RpZl9zZXR0aW5ncyIsInJlbW92ZV9mcm9tX2V2ZW50IiwicmVtb3ZlX3VwbG9hZGVkX2ZpbGVfdXJsIiwicmVtb3ZlX3VzZXJfZnJvbV9ldmVudCIsInJlb3JkZXJfbWVldGluZ190eXBlcyIsInJlcG9ydHMiLCJ1bmlmaWVkX3JlcG9ydF9maWx0ZXJzIiwidXNlcl9saXN0IiwidW5pZmllZF9yZXBvcnQiLCJmZXRjaF9yZXBvcnRfdGVtcGxhdGUiLCJ1cGxvYWRfcmVwb3J0X3RlbXBsYXRlIiwidXBkYXRlX3JlcG9ydF90ZW1wbGF0ZSIsInJlcG9ydF9zdXJ2ZXlfYWN0aXZpdHlfbGlzdCIsInJlc2NoZWR1bGVfbWVldGluZyIsInBhcnRpYWxfbWVldGluZ191cGRhdGUiLCJyZXZpZXdlcl9tZWV0aW5nX2ZpbHRlcl9vcHRpb25zIiwicmV2aWV3ZXJfbWVldGluZ19maWx0ZXJzIiwicmV2aWV3ZXJfbWVldGluZ3MiLCJyb2xlX2NyZWF0ZSIsInJvbGVfZGlzYWJsZSIsInJvbGVfZW5hYmxlIiwicm9sZV9nZXRfYWxsX3ByaXZpbGVnZXMiLCJyb2xlX2dldF9wcml2aWxlZ2VzIiwicm9sZV9zZXRfcHJpdmlsZWdlcyIsInJvbGVfdXBkYXRlIiwicm9sZXNfZmV0Y2giLCJyb29tX2FjdGl2aXRpZXMiLCJyb29tX2F2YWlsYWJpbGl0eSIsInJvb21fY2FsZW5kYXJfZXhwb3J0Iiwicm9vbV9jcmVhdGUiLCJyb29tX2ZpbHRlcnMiLCJyb29tX21ha2VfYXZhaWxhYmxlIiwicm9vbV9tYWtlX3VuYXZhaWxhYmxlIiwicm9vbV91bmJsb2NrIiwicm9vbV91cGRhdGUiLCJyb29tc19leHBvcnQiLCJyb29tc19saXN0Iiwic2F2ZV9mb3JtIiwic2F2ZV9wb3J0YWxfY3VzdG9tX2Zvcm0iLCJzYXZlX3ByaW50ZXJfbmFtZSIsInNhdmVfcHJvZmlsZV9wcmVmZXJlbmNlcyIsInNhdmVfdXNlcl9maWVsZF9tYXBwaW5ncyIsInNhdmVkX3JlcG9ydF9kZXRhaWxzIiwic2VuZF9yZXF1ZXN0b3JfZW1haWwiLCJzZXNzaW9uX2NoZWNraW5fbGlzdCIsInNlc3Npb25fZXhwb3J0Iiwic2Vzc2lvbl9saXN0Iiwic2Vzc2lvbl9ub21pbmF0aW9ucyIsInNlc3Npb25zX2xpc3QiLCJzZXRfYW5ub3VuY2VtZW50cyIsInNldF9wYXJ0aWNpcGF0aW9uX21hc2NhbCIsInNldF9wYXJ0aWNpcGF0aW9uIiwic2V0X3JlbWluZGVyIiwic2V0X3VzZXJfY2lzX3N0YXR1cyIsInNldF91c2VyX3ByZWZlcmVuY2VzIiwic2ZkY19jdXN0b21fbGFiZWxzIiwic2hvd19pbl9tZWV0aW5nX2V4dGVybmFsX2F0dGVuZGVlIiwic2luZ2xlX21hc3Rlcl9jYWxlbmRhcl9lbnRpdHlfc2VhcmNoIiwic3RhbmRhcmRfcmVwb3J0X2V4cG9ydF91cmwiLCJzdGFuZGFyZF9yZXBvcnRfZ2VuZXJhdGVfdXJsIiwic3VydmV5X2NyZWF0ZSIsInN1cnZleV9yZXNwb25zZXMiLCJzdXJ2ZXlfdXBkYXRlIiwic3dhcF9yb29tX3N1Ym1pdCIsInN5c3RlbV9jb25maWd1cmF0aW9ucyIsInN0YW5kYXJkX3JlcG9ydF9leHBvcnRfYnlfbWVldGluZyIsInRpbWVfem9uZV91cmwiLCJ0aW1lbGluZV9kYXRhIiwidGFnX2NyZWF0ZV9vcl91cGRhdGUiLCJ0YWdfZWRpdCIsInRhZ19saXN0IiwidGFnX2xpc3RpbmdfcGFnZSIsInRlbXBsYXRlX3VwbG9hZF91cmwiLCJBUElfY2FjaGUiLCJzdW1tdXJ5RXJyb3JIYW5kbGVyIiwiZXJyb3JDb25maWdzIiwiZXJyb3JKc29uIiwibW9kZWxFbCIsImN1c3RvbV9tZXNzYWdlIiwiZGV0YWlsZWRFcnJvckhhbmRsZXIiLCJlcnJvck1zZyIsImZsYXR0ZW4iLCJ2YWx1ZXMiLCJkZXRhaWxzIiwiZXJyIiwicmVwbGFjZVVybFBhcmFtcyIsInVybEVuZHBvaW50IiwiYXJndW1lbnRzIiwib3B0aW9ucyIsImNvbnN0cnVjdG9yIiwiY3VycmVudF9sb2NhdGlvbl91dWlkIiwiZXJyb3JIYW5kbGVyQ29uZmlncyIsImVycm9ySGFuZGxlckZuIiwiYXNzaWduIiwiZGF0YVR5cGUiLCJtZXRob2QiLCJyZXFfc3RyaW5naWZ5IiwidGVzdCIsInNlY3Rpb25Mb2FkZXIiLCJzZXRQYWdlTG9hZGVyIiwiYWpheCIsImFib3J0U2VxdWVudGlhbENhbGxzIiwiYWRkUmVtb3ZlQ2FjaGUiLCJVaUFjdGlvbnNPblVwZGF0ZSIsInRyaW1TZWFyY2giLCJ0cmltU3BhY2VzRm9yU2VhcmNoIiwiYWJvcnQiLCJidG5zVG9EaXNhYmxlIiwic3RhcnRQYWdlTG9hZGVyIiwidG9nZ2xlU2VjdGlvbkxvYWRlciIsImRpc2FibGVXaGlsZUZldGNoaW5nRGF0YSIsInNob3VsZERpc2FibGUiLCJlbG1zIiwiZXZlbnRUeXBlIiwicGFnZVR5cGUiLCJib3VuZGVkRXZlbnRzIiwiZGF0ZXBpY2tlclN0YXJ0RmllbGRzIiwiZGF0ZXBpY2tlckVuZEZpZWxkcyIsImRhdGVwaWNrZXJGaWVsZHMiLCJkYXRlcGlja2VyT2JqIiwiZGF0ZUFwaU1hcHBpbmdzIiwiYXJyYXkiLCJhcGlEYXRlTWFwcGluZ3MiLCJkZWZhdWx0RGF0ZSIsInN0YXJ0T2YiLCJ0b0RhdGUiLCJkZWZhdWx0VmFsdWVzIiwiY3VzdG9tU2VhcmNoSGFzaCIsImlzQ3VzdG9tVGVtcGxhdGUiLCJ0bXBsIiwib3B0aW9uX2NscyIsInNlYXJjaEhhc2giLCJzdWJqZWN0cyIsInJldmlld2VlcyIsInJlcXVlc3RlcnMiLCJpbnRlcm5hbF9pbnZpdGVlcyIsImV4dGVybmFsX2ludml0ZWVzIiwidXNlcnMiLCJpZHMiLCJjcmVhdG9ycyIsInRvcGljcyIsInRhZ3MiLCJicmllZmluZ19zdWJqZWN0cyIsImJyaWVmaW5nX3JlcXVlc3RlcnMiLCJicmllZmluZ19pbnRlcm5hbF9pbnZpdGVlcyIsImJyaWVmaW5nX2V4dGVybmFsX2ludml0ZWVzIiwiYnJpZWZpbmdfaWRzIiwiYnJpZWZpbmdfY3JlYXRvcnMiLCJicmllZmluZ19yb29tcyIsInNlbGVjdEVsZW1lbnQiLCJjdXN0b21MYWJlbCIsInNlbGVjdENvbmZpZyIsImRyb3Bkb3duUGFyZW50IiwibXVsdGlwbGUiLCJ3aWR0aCIsInBsYWNlaG9sZGVyIiwiYWpheFNlbGVjdENvbmZpZyIsIm1pbmltdW1JbnB1dExlbmd0aCIsImNhY2hlIiwiZGVsYXkiLCJwYXJhbXMiLCJmaWVsZCIsInRlcm0iLCJwcm9jZXNzUmVzdWx0cyIsInJlc3VsdHMiLCJBcnJheSIsImxvY2FsQWpheENvbmZpZyIsInRyYW5zcG9ydCIsImZldGNoT3B0aW9ucyIsInNlbGVjdDIiLCJ1bmRlZmluZWQiLCJicmllZmluZ3MiLCJmaWx0ZXJzQXBwbGllZCIsImZpZWxkTmFtZSIsImluZGV4T2YiLCJzYXZlZFZhbHVlIiwiaXNWYWxpZCIsImluaXREYXRlcGlja2VycyIsImVsIiwiYm9vdHN0cmFwRFAiLCJibHVyIiwiZGF0ZVBpY2tlckZ1bmN0aW9uIiwic2V0U3RhcnREYXRlUGlja2VyIiwic2V0RW5kRGF0ZVBpY2tlciIsImRhdGVwaWNrZXJFbGUiLCJzZWxlY3RlZERhdGUiLCJkZWZhdWx0Vmlld0RhdGUiLCJkYXRlcGlja2VySGFuZGxlciIsImF1dG9jbG9zZSIsIm9yaWVudGF0aW9uIiwieWVhciIsIm1vbnRoIiwiZGF5IiwiZGF0ZSIsInNldERhdGVQaWNrZXIiLCJvblNlbGVjdCIsInVwZGF0ZURhdGVSYW5nZSIsImRhdGVTdHIiLCJwYW5lbCIsInN0RGF0ZSIsInNldE1pbk1heERhdGUiLCJlZERhdGUiLCJlbGVtIiwibWluTWF4RGF0ZSIsImJyaWVmaW5nU3RhcnREYXRlIiwiYnJpZWZpbmdFbmREYXRlIiwiZmllbGRWYWx1ZSIsImRpc3BsYXlfbmFtZSIsImlucHV0Iiwic3RvcmFibGVGaWx0ZXJWYWx1ZXMiLCJvcHRpb25FbGUiLCJvcHRpb24iLCJkaXNwbGF5X2xhYmVsIiwicmVzZXREYXRlUGlja2VycyIsImZpZWxkS2V5IiwiZGVjbGluZUNvbW1lbnRzIiwiY2FuY2VsQ29tbWVudHMiLCJyZWdleFN0cmluZyIsInJlZ2V4IiwiZXZhbHVhdGVkIiwiZ2V0Q29tbWVudHMiLCJmbGFnIiwiY29tbWVudHMiLCJjb21tZW50IiwiZ2V0RGVjbGluZUNvbW1lbnRzIiwiZ2V0Q2FuY2VsQ29tbWVudHMiLCJ1cGRhdGVEZWNsaW5lQ29tbWVudHMiLCJpbnZpdGVPcHRpb24iLCJkZWNsaW5lQ29tbWVudHNFbmFibGVkIiwiZGVjbGluZV9jb21tZW50c19lbmFibGVkIiwicHJlZGVmaW5lZERlY2xpbmVDb21tZW50cyIsInByZWRlZmluZWRfZGVjbGluZV9jb21tZW50cyIsInVwZGF0ZUNhbmNlbENvbW1lbnRzIiwiY2FuY2VsT3B0aW9uIiwiY2FuY2VsQ29tbWVudHNFbmFibGVkIiwiY2FuY2VsX2NvbW1lbnRzX2VuYWJsZWQiLCJwcmVkZWZpbmVkQ2FuY2VsQ29tbWVudHMiLCJwcmVkZWZpbmVkX2NhbmNlbF9jb21tZW50cyIsImFib3J0YWJsZUZldGNoIiwicXVldWUiLCJwcm9taXNlSWQiLCJyYW5kb20iLCJ0b1N0cmluZyIsInN1YnN0ciIsInJlcXVlc3QiLCJJZCIsIm9wdHMiLCJmbiIsImludmVyc2UiLCJ2YWx1ZTEiLCJ2YWx1ZTIiLCJpMThuX2tleSIsIkhhbmRsZWJhcnMiLCJTYWZlU3RyaW5nIl0sIm1hcHBpbmdzIjoiO0FBQUE7QUFDQTs7QUFFQTtBQUNBOztBQUVBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBOztBQUVBO0FBQ0E7O0FBRUE7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7OztBQUdBO0FBQ0E7O0FBRUE7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7QUFDQSxrREFBMEMsZ0NBQWdDO0FBQzFFO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0EsZ0VBQXdELGtCQUFrQjtBQUMxRTtBQUNBLHlEQUFpRCxjQUFjO0FBQy9EOztBQUVBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQSxpREFBeUMsaUNBQWlDO0FBQzFFLHdIQUFnSCxtQkFBbUIsRUFBRTtBQUNySTtBQUNBOztBQUVBO0FBQ0E7QUFDQTtBQUNBLG1DQUEyQiwwQkFBMEIsRUFBRTtBQUN2RCx5Q0FBaUMsZUFBZTtBQUNoRDtBQUNBO0FBQ0E7O0FBRUE7QUFDQSw4REFBc0QsK0RBQStEOztBQUVySDtBQUNBOzs7QUFHQTtBQUNBOzs7Ozs7Ozs7Ozs7QUNsRkEsSUFBSUEsaUJBQWlCQyxPQUFPQyxhQUFQLENBQXFCLENBQ3RDLGVBRHNDLEVBRXRDLGlCQUZzQyxFQUd0QyxnQkFIc0MsRUFJdEMsY0FKc0MsRUFLdEMsYUFMc0MsRUFNdEMsY0FOc0MsRUFPdEMsYUFQc0MsRUFRdEMsZUFSc0MsRUFTdEMsWUFUc0Ms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LE9BQU87QUFDUDtBQUNBO0FBQ0E7QUFDQSxLQUFLOztBQUVMO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQSxLQUFLO0FBQ0w7QUFDQTs7QUFFQTtBQUNBLDZCQUE2QjtBQUM3Qjs7QUFFQTtBQUNBLEtBQUs7QUFDTDtBQUNBLCtCQUErQjs7QUFFL0I7QUFDQTtBQUNBOztBQUVBO0FBQ0EsMEVBQTBFOztBQUUxRTs7QUFFQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQSxPQUFPO0FBQ1A7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQSxLQUFLO0FBQ0w7QUFDQTtBQUNBO0FBQ0E7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7QUFDQTs7QUFFQTtBQUNBO0FBQ0EsMEVBQTBFOztBQUUxRTtBQUNBO0FBQ0E7QUFDQTs7QUFFQTtBQUNBOztBQUVBOztBQUVBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQSxLQUFLO0FBQ0w7QUFDQTtBQUNBLEdBQUc7QUFDSDtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQSw4RUFBOEU7O0FBRTlFO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0EsMENBQTBDO0FBQzFDO0FBQ0EsS0FBSztBQUNMOztBQUVBO0FBQ0E7QUFDQTs7QUFFQTtBQUNBO0FBQ0EsR0FBRztBQUNIO0FBQ0E7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBLDJDQUEy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ImZpbGUiOiJNZWV0aW5nLmFwcC5qcyIsInNvdXJjZXNDb250ZW50IjpbIiBcdC8vIFRoZSBtb2R1bGUgY2FjaGVcbiBcdHZhciBpbnN0YWxsZWRNb2R1bGVzID0ge307XG5cbiBcdC8vIFRoZSByZXF1aXJlIGZ1bmN0aW9uXG4gXHRmdW5jdGlvbiBfX3dlYnBhY2tfcmVxdWlyZV9fKG1vZHVsZUlkKSB7XG5cbiBcdFx0Ly8gQ2hlY2sgaWYgbW9kdWxlIGlzIGluIGNhY2hlXG4gXHRcdGlmKGluc3RhbGxlZE1vZHVsZXNbbW9kdWxlSWRdKSB7XG4gXHRcdFx0cmV0dXJuIGluc3RhbGxlZE1vZHVsZXNbbW9kdWxlSWRdLmV4cG9ydHM7XG4gXHRcdH1cbiBcdFx0Ly8gQ3JlYXRlIGEgbmV3IG1vZHVsZSAoYW5kIHB1dCBpdCBpbnRvIHRoZSBjYWNoZSlcbiBcdFx0dmFyIG1vZHVsZSA9IGluc3RhbGxlZE1vZHVsZXNbbW9kdWxlSWRdID0ge1xuIFx0XHRcdGk6IG1vZHVsZUlkLFxuIFx0XHRcdGw6IGZhbHNlLFxuIFx0XHRcdGV4cG9ydHM6IHt9XG4gXHRcdH07XG5cbiBcdFx0Ly8gRXhlY3V0ZSB0aGUgbW9kdWxlIGZ1bmN0aW9uXG4gXHRcdG1vZHVsZXNbbW9kdWxlSWRdLmNhbGwobW9kdWxlLmV4cG9ydHMsIG1vZHVsZSwgbW9kdWxlLmV4cG9ydHMsIF9fd2VicGFja19yZXF1aXJlX18pO1xuXG4gXHRcdC8vIEZsYWcgdGhlIG1vZHVsZSBhcyBsb2FkZWRcbiBcdFx0bW9kdWxlLmwgPSB0cnVlO1xuXG4gXHRcdC8vIFJldHVybiB0aGUgZXhwb3J0cyBvZiB0aGUgbW9kdWxlXG4gXHRcdHJldHVybiBtb2R1bGUuZXhwb3J0cztcbiBcdH1cblxuXG4gXHQvLyBleHBvc2UgdGhlIG1vZHVsZXMgb2JqZWN0IChfX3dlYnBhY2tfbW9kdWxlc19fKVxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5tID0gbW9kdWxlcztcblxuIFx0Ly8gZXhwb3NlIHRoZSBtb2R1bGUgY2FjaGVcbiBcdF9fd2VicGFja19yZXF1aXJlX18uYyA9IGluc3RhbGxlZE1vZHVsZXM7XG5cbiBcdC8vIGRlZmluZSBnZXR0ZXIgZnVuY3Rpb24gZm9yIGhhcm1vbnkgZXhwb3J0c1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5kID0gZnVuY3Rpb24oZXhwb3J0cywgbmFtZSwgZ2V0dGVyKSB7XG4gXHRcdGlmKCFfX3dlYnBhY2tfcmVxdWlyZV9fLm8oZXhwb3J0cywgbmFtZSkpIHtcbiBcdFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgbmFtZSwgeyBlbnVtZXJhYmxlOiB0cnVlLCBnZXQ6IGdldHRlciB9KTtcbiBcdFx0fVxuIFx0fTtcblxuIFx0Ly8gZGVmaW5lIF9fZXNNb2R1bGUgb24gZXhwb3J0c1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5yID0gZnVuY3Rpb24oZXhwb3J0cykge1xuIFx0XHRpZih0eXBlb2YgU3ltYm9sICE9PSAndW5kZWZpbmVkJyAmJiBTeW1ib2wudG9TdHJpbmdUYWcpIHtcbiBcdFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgU3ltYm9sLnRvU3RyaW5nVGFnLCB7IHZhbHVlOiAnTW9kdWxlJyB9KTtcbiBcdFx0fVxuIFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgJ19fZXNNb2R1bGUnLCB7IHZhbHVlOiB0cnVlIH0pO1xuIFx0fTtcblxuIFx0Ly8gY3JlYXRlIGEgZmFrZSBuYW1lc3BhY2Ugb2JqZWN0XG4gXHQvLyBtb2RlICYgMTogdmFsdWUgaXMgYSBtb2R1bGUgaWQsIHJlcXVpcmUgaXRcbiBcdC8vIG1vZGUgJiAyOiBtZXJnZSBhbGwgcHJvcGVydGllcyBvZiB2YWx1ZSBpbnRvIHRoZSBuc1xuIFx0Ly8gbW9kZSAmIDQ6IHJldHVybiB2YWx1ZSB3aGVuIGFscmVhZHkgbnMgb2JqZWN0XG4gXHQvLyBtb2RlICYgOHwxOiBiZWhhdmUgbGlrZSByZXF1aXJlXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLnQgPSBmdW5jdGlvbih2YWx1ZSwgbW9kZSkge1xuIFx0XHRpZihtb2RlICYgMSkgdmFsdWUgPSBfX3dlYnBhY2tfcmVxdWlyZV9fKHZhbHVlKTtcbiBcdFx0aWYobW9kZSAmIDgpIHJldHVybiB2YWx1ZTtcbiBcdFx0aWYoKG1vZGUgJiA0KSAmJiB0eXBlb2YgdmFsdWUgPT09ICdvYmplY3QnICYmIHZhbHVlICYmIHZhbHVlLl9fZXNNb2R1bGUpIHJldHVybiB2YWx1ZTtcbiBcdFx0dmFyIG5zID0gT2JqZWN0LmNyZWF0ZShudWxsKTtcbiBcdFx0X193ZWJwYWNrX3JlcXVpcmVfXy5yKG5zKTtcbiBcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KG5zLCAnZGVmYXVsdCcsIHsgZW51bWVyYWJsZTogdHJ1ZSwgdmFsdWU6IHZhbHVlIH0pO1xuIFx0XHRpZihtb2RlICYgMiAmJiB0eXBlb2YgdmFsdWUgIT0gJ3N0cmluZycpIGZvcih2YXIga2V5IGluIHZhbHVlKSBfX3dlYnBhY2tfcmVxdWlyZV9fLmQobnMsIGtleSwgZnVuY3Rpb24oa2V5KSB7IHJldHVybiB2YWx1ZVtrZXldOyB9LmJpbmQobnVsbCwga2V5KSk7XG4gXHRcdHJldHVybiBucztcbiBcdH07XG5cbiBcdC8vIGdldERlZmF1bHRFeHBvcnQgZnVuY3Rpb24gZm9yIGNvbXBhdGliaWxpdHkgd2l0aCBub24taGFybW9ueSBtb2R1bGVzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm4gPSBmdW5jdGlvbihtb2R1bGUpIHtcbiBcdFx0dmFyIGdldHRlciA9IG1vZHVsZSAmJiBtb2R1bGUuX19lc01vZHVsZSA/XG4gXHRcdFx0ZnVuY3Rpb24gZ2V0RGVmYXVsdCgpIHsgcmV0dXJuIG1vZHVsZVsnZGVmYXVsdCddOyB9IDpcbiBcdFx0XHRmdW5jdGlvbiBnZXRNb2R1bGVFeHBvcnRzKCkgeyByZXR1cm4gbW9kdWxlOyB9O1xuIFx0XHRfX3dlYnBhY2tfcmVxdWlyZV9fLmQoZ2V0dGVyLCAnYScsIGdldHRlcik7XG4gXHRcdHJldHVybiBnZXR0ZXI7XG4gXHR9O1xuXG4gXHQvLyBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGxcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubyA9IGZ1bmN0aW9uKG9iamVjdCwgcHJvcGVydHkpIHsgcmV0dXJuIE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbChvYmplY3QsIHByb3BlcnR5KTsgfTtcblxuIFx0Ly8gX193ZWJwYWNrX3B1YmxpY19wYXRoX19cbiBcdF9fd2VicGFja19yZXF1aXJlX18ucCA9IFwiXCI7XG5cblxuIFx0Ly8gTG9hZCBlbnRyeSBtb2R1bGUgYW5kIHJldHVybiBleHBvcnRzXG4gXHRyZXR1cm4gX193ZWJwYWNrX3JlcXVpcmVfXyhfX3dlYnBhY2tfcmVxdWlyZV9fLnMgPSBcIi4vYXBwL3NjcmlwdHMvTWVldGluZy9hcHAuanNcIik7XG4iLCJ2YXIgTWVldGluZ0FjdGlvbnMgPSBSZWZsdXguY3JlYXRlQWN0aW9ucyhbXG4gICAgJ2ZldGNoTWVldGluZ3MnLFxuICAgICdyZUZldGNoTWVldGluZ3MnLFxuICAgICdzZWFyY2hNZWV0aW5ncycsXG4gICAgJ3VwZGF0ZVNlYXJjaCcsXG4gICAgJ3Jlc2V0RmlsdGVyJyxcbiAgICAndXBkYXRlRmlsdGVyJyxcbiAgICAnYXBwbHlGaWx0ZXInLFxuICAgICdtZWV0aW5nQWN0aW9uJyxcbiAgICAndG9nZ2xlVmlldycsXG4gICAgJ2dldEZpbHRlcnMnLFxuICAgICdmZXRjaE9wdGlvbnMnLFxuICAgICdidWxrQXBwcm92ZU1lZXRpbmdzJyxcbiAgICAnYnVsa0NhbmNlbCcsXG4gICAgJ2ZldGNoRXZlbnREZXRhaWxzJyxcbiAgICAndXBsb2FkQWdlbmRhSXRlbUNzdicsXG4gICAgJ3RyaWdnZXJTZXJ2ZXlNYWlscycsXG4gICAgJ2J1bGtSZWludml0ZVVzZXJzJ1xuXSk7XG5cbm1vZHVsZS5leHBvcnRzID0gTWVldGluZ0FjdGlvbnM7XG4iLCJpbml0STE4bihlbkxvY2FsZVtcIm1lZXRpbmdzXCJdKTtcbnZhciBIYW5kbGVyID0gcmVxdWlyZSgnLi9oYW5kbGVyJyk7XG52YXIgQXBpID0gcmVxdWlyZSgnY29tbW9uX2FwaScpO1xuXG5cbiQoZG9jdW1lbnQpLnJlYWR5KGZ1bmN0aW9uKCl7XG5cbiAgICBpZih0eXBlb2YgamlmZmxlICE9PSAndW5kZWZpbmVkJykge1xuICAgICAgICBBcGkuc2ZkY0hhbmRsZXIubWVldGluZ0luaXQoZnVuY3Rpb24oKXtcbiAgICAgICAgICAgIEhhbmRsZXIuaW5pdCgpO1xuICAgICAgICB9KTtcbiAgICB9IGVsc2Uge1xuICAgICAgICBIYW5kbGVyLmluaXQoKTtcbiAgICB9XG4gICAgc2V0dXBVaUkxOG4oKTtcblxufSk7IiwidmFyIEFjdGlvbnMgPSByZXF1aXJlKCcuL2FjdGlvbnMnKVxudmFyIFN0b3JlID0gcmVxdWlyZSgnLi9zdG9yZScpXG52YXIgQXBpID0gcmVxdWlyZSgnY29tbW9uX2FwaScpXG52YXIgbWVldGluZ0ZpbHRlckNtcCA9IHJlcXVpcmUoJy4uL2NvbW1vbnMvbWVldGluZ19maWx0ZXJzJylcbnZhciBBcGkgPSByZXF1aXJlKCdjb21tb25fYXBpJylcbnZhciB7IHB1dFNlYXJjaFF1ZXJ5UGFyYW0gfSA9IHJlcXVpcmUoJy4uL3V0aWxzJylcblxuLy8gdmFyIF8gPSByZXF1aXJlKCdsb2Rhc2gnKTtcbi8vIHZhciBpMThuID0gcmVxdWlyZSgnaTE4bmV4dC1jbGllbnQnKTtcblxudmFyIE1lZXRpbmdIYW5kbGVyID0gKGZ1bmN0aW9uICgpIHtcbiAgaWYgKF8uaXNVbmRlZmluZWQod2luZG93LnVzZXJUeXBlKSkge1xuICAgIHdpbmRvdy51c2VyVHlwZSA9ICdpbnRlcm5hbCdcbiAgfVxuICBpZiAoXy5pc1VuZGVmaW5lZCh3aW5kb3cuTWVldGluZ1R5cGUpKSB7XG4gICAgd2luZG93Lk1lZXRpbmdUeXBlID0gJ2dlbmVyYWxNZWV0aW5ncydcbiAgfVxuXG4gIHZhciBtZWV0aW5nTGlzdENvbnRhaW5lciA9ICQoJyNtZWV0aW5nX2xpc3QnKVxuICB2YXIgYWdlbmRhTGlzdENvbnRhaW5lciA9ICQoJyNhZ2VuZGFfbGlzdCcpXG4gIHZhciBhcHBsaWVkRmlsdGVyc0NvbnRhaW5lciA9ICQoJyNhcHBsaWVkX2ZpbHRlcnNfbGlzdCcpXG4gIHZhciB0b2dnbGVCdG5VbCA9ICQoJy50b2dnbGUtbWVudS1saXN0JylcbiAgdmFyIGdsb2JhbFNlYXJjaCA9ICQoJyNnbG9iYWxfZmlsdGVyJylcbiAgdmFyIGZpbHRlclNlYXJjaEZpZWxkID0gJCgnI2ZpbHRlcl9zZWFyY2gnKVxuICB2YXIgcmVzZXRGaWx0ZXJCdG4gPSAkKCcjcmVzZXRfZmlsdGVyJylcbiAgdmFyIGFwcGx5RmlsdGVyQnRuID0gJCgnI2FwcGx5X2ZpbHRlcicpXG4gIHZhciBmaWx0ZXJUb2dnbGVCdG4gPSAkKCcjZmlsdGVyX3RvZ2dsZScpXG4gIHZhciBmaWx0ZXIgPSAkKCcjZmlsdGVyJylcbiAgdmFyIGZpbHRlclN0YXJ0RGF0ZSA9ICQoJyNmaWx0ZXJfc3RhcnRfZGF0ZScpXG4gIHZhciBmaWx0ZXJFbmREYXRlID0gJCgnI2ZpbHRlcl9lbmRfZGF0ZScpXG4gIHZhciBleHBvcnRCdG4gPSAkKCcjZXhwb3J0JylcbiAgdmFyIG1lZXRpbmdDb3VudCA9ICQoJy5tZWV0aW5nX2NvdW50LmRlc2t0b3AnKVxuICB2YXIgbWVldGluZ0NvdW50TW9iaWxlID0gJCgnLm1lZXRpbmdfY291bnQubW9iaWxlJylcbiAgdmFyIGJvb2tNZWV0aW5nQnRuID0gJCgnI2Jvb2tfbWVldGluZycpXG4gIHZhciBib29rTWVldGluZ0FkZEJ0biA9ICQoJyNib29rX21lZXRpbmdfYWRkX2J0bicpXG4gIHZhciBib29rQWdlbmRhQnRuID0gJCgnI2Jvb2tfYWdlbmRhX2l0ZW0nKVxuICB2YXIgYm9va0FnZW5kYUFkZEJ0biA9ICQoJyNib29rX2FnZW5kYV9hZGRfYnRuJylcbiAgdmFyIG5vdGlmaWNhdGlvbk1vZGFsID0gJCgnLm5vdGlmaWNhdGlvbi1tb2RhbCcpXG4gIHZhciBmaWx0ZXJQYW5lbCA9ICQoJyNmaWx0ZXJQYW5lbCcpXG4gIHZhciBzZWxlY3RBY3Rpdml0eU1vZGFsID0gJCgnLm1vZGFsLXNlbGVjdC1hY3Rpdml0eScpXG4gIHZhciBtZWV0aW5nQWN0aXZpdHlDb250YWluZXIgPSAkKCcjbWVldGluZy10eXBlLWxpc3QnKVxuICB2YXIgc2VsZWN0ZWRNZWV0aW5nQ2FyZEhhc2ggPSB7fVxuICB2YXIgc3VydmV5U2VsZWN0ZWRNZWV0aW5nID0ge31cbiAgdmFyIGhhc1NlbGVjdGVkTWVldGluZ3MgPSBmYWxzZVxuICB2YXIgc2VsZWN0QWxsRmxhZyA9IGZhbHNlXG4gIHZhciBidWxrQWN0aW9uQmFyID0gJCgnLmJ1bGstYWN0aW9uJylcbiAgdmFyIGlzU3RhZmZFdmVudFxuICB2YXIgZGlzcGxheUxhYmVsRm9yQWdlbmRhXG4gIHZhciB1dWlkT2ZNZWV0aW5nVHlwZUZvckFnZW5kYVxuICB2YXIgYWdlbmRhSXRlbURhdGVUaW1lRm9ybWF0ID0gJ2hoOm1tIEEgZGRkLCBNTU0gREQsIFlZWVknXG4gIHZhciBtZWV0aW5nVGltZUZvcm1hdCA9ICdoaDptbSBBJ1xuICB2YXIgbWVldGluZ0RhdGVGb3JtYXQgPSAnZGRkLCBNTU0gRCwgWVlZWSdcbiAgdmFyIGV4dGVybmFsQ291bnRUYWIgPSAkKCcudGFiX2V4dGVybmFsJylcbiAgdmFyIG1vYmlsZUV4dGVybmFsQ291bnRUYWIgPSAkKCcubW9iaWxlX3RhYl9leHRlcm5hbCcpXG4gIHZhciBpbnRlcm5hbENvdW50VGFiID0gJCgnLnRhYl9pbnRlcm5hbCcpXG5cbiAgdmFyIG1vYmlsZUludGVybmFsQ291bnRUYWIgPSAkKCcubW9iaWxlX3RhYl9pbnRlcm5hbCcpXG4gIHZhciBzZXNzaW9uQ291bnRUYWIgPSAkKCcudGFiX3Nlc3Npb24nKVxuICB2YXIgY29uc2VjdXRpdmVNZWV0aW5nVGFiID0gJCgnLnRhYl9jb25zZWN1dGl2ZV9tZWV0aW5nJylcbiAgdmFyIG1vYmlsZUNvbnNlY3V0aXZlQ291bnRUYWIgPSAkKCcubW9iaWxlX3RhYl9jb25zZWN1dGl2ZV9tZWV0aW5nJylcbiAgdmFyIG1vYmlsZVNlc3Npb25Db3VudFRhYiA9ICQoJy5tb2JpbGVfdGFiX3Nlc3Npb24nKVxuICB2YXIgY3VycmVudFRhYlxuICB2YXIgbW9iaWxlQ3VycmVudFRhYlxuICB2YXIgcmV2aWV3ZWVNZWV0aW5nQ291bnRUYWIgPSAkKCcudGFiX3Jldmlld2VlX21lZXRpbmcnKVxuICB2YXIgbW9iaWxlUmV2aWV3ZWVNZWV0aW5nQ291bnRUYWIgPSAkKCcubW9iaWxlX3RhYl9yZXZpZXdlZV9tZWV0aW5nJylcbiAgdmFyIGlzSW50ZXJuYWwgPSAodXNlclR5cGUgPT09ICdpbnRlcm5hbCcpXG4gIHZhciBtb2JpbGVUYWJDaGVja2luID0gJCgnLm1vYmlsZV90YWJfY2hlY2tpbicpXG4gIHZhciB1c2VyVGFiID0gJCgnLnRhYl8nICsgdXNlclR5cGUpXG4gIHZhciBtb2JpbGVDdXJyVGFiID0gJCgnLm1vYmlsZV90YWJfJyArIHVzZXJUeXBlKVxuICB2YXIgc3VydmV5TW9kYWxFbCA9ICQoJy5qcy1tZWV0aW5nLXN1cnZleS1tb2RhbCcpXG4gIHZhciBidWxrQ2FuY2VsQnRuID0gJCgnI2pzLWJ1bGstY2FuY2VsJylcblxuICB2YXIgVFJBQ0tTX0FORF9TRVNTSU9OU19NQVNURVJfTkFNRSA9IFwiVHJhY2tzIGFuZCBTZXNzaW9uc1wiO1xuXG4gIHZhciBzdG9yZUhhbmRsZXJzID0ge1xuICAgIG1lZXRpbmdsaXN0aW5nOiBoYW5kbGVNZWV0aW5nTGlzdCxcbiAgICB2aWV3Y2hhbmdlZDogaGFuZGVsVmlld1RvZ2dsZSxcbiAgICBtZWV0aW5nRmlsdGVyczogc2V0TWVldGluZ0ZpbHRlcnMsXG4gICAgb25CdWxrQXBwcm92YWxTdWNjZXNzOiBvbkJ1bGtBcHByb3ZhbFN1Y2Nlc3MsXG4gICAgb25CdWxrQ2FuY2VsU3VjY2Vzczogb25CdWxrQ2FuY2VsU3VjY2VzcyxcbiAgICBvbkJ1bGtDYW5jZWxGYWlsdXJlOiBvbkJ1bGtDYW5jZWxGYWlsdXJlLFxuICAgIG9uQnVsa0FwcHJvdmFsRmFpbHVyZTogb25CdWxrQXBwcm92YWxGYWlsdXJlLFxuICAgIG9uQnVsa1JlaW52aXRlVXNlclN1Y2Nlc3M6IG9uQnVsa1JlaW52aXRlVXNlclN1Y2Nlc3MsXG4gICAgZXZlbnREZXRhaWxzOiBvbkV2ZW50RGV0YWlscyxcbiAgICBhZ2VuZGFJdGVtVXBsb2FkRmFpbHVyZTogYWdlbmRhSXRlbVVwbG9hZEZhaWx1cmVIYW5kbGVyLFxuICAgIGFnZW5kYUl0ZW1VcGxvYWRTdWNjZXNzOiBhZ2VuZGFJdGVtVXBsb2FkU3VjY2Vzc0hhbmRsZXIsXG4gICAgYWRkVG9TZWxlY3RlZE1lZXRpbmdDYXJkSGFzaDogYWRkVG9TZWxlY3RlZE1lZXRpbmdDYXJkSGFzaCxcbiAgICBzZXJ2ZXlNYWlsc1RyaWdnZXJlZDogc2VydmV5TWFpbHNUcmlnZ2VyZWRcbiAgfVxuICB2YXIgZXZlbnRJbmZvXG4gIHZhciBtZWV0aW5nVHlwZUhhc2ggPSB7XG4gICAgJ2NvbnNlY3V0aXZlTWVldGluZ3MnOiB7XG4gICAgICBkaXNwbGF5VGV4dDogJ0NNJyxcbiAgICAgIGN1cnJlbnRUYWI6IGNvbnNlY3V0aXZlTWVldGluZ1RhYixcbiAgICAgIGN1cnJlbnRNb2JpbGVUYWI6IG1vYmlsZUNvbnNlY3V0aXZlQ291bnRUYWIsXG4gICAgICBjaGVja2luVXJsOiBBcGkuRU5EUE9JTlRTLmNoZWNraW5fbWVldGluZ3NfbGlzdCxcbiAgICAgIHNlbGVjdEFsbENsYXNzOiAnJyxcbiAgICAgIGlzQ29uc2VjdXRpdmU6IHRydWUsXG4gICAgICBlZGl0TWVldGluZ1VybDogQXBpLkVORFBPSU5UUy5jb25zZWN1dGl2ZV9tZWV0aW5nc19lZGl0X3BhdGgsXG4gICAgICB2aWV3TWVldGluZ1VybDogQXBpLkVORFBPSU5UUy5jb25zZWN1dGl2ZV9tZWV0aW5nc192aWV3X3BhdGhcbiAgICB9LFxuICAgICdnZW5lcmFsTWVldGluZ3MnOiB7XG4gICAgICBkaXNwbGF5VGV4dDogJ00nLFxuICAgICAgY3VycmVudFRhYjogaW50ZXJuYWxDb3VudFRhYixcbiAgICAgIGN1cnJlbnRNb2JpbGVUYWI6IG1vYmlsZUludGVybmFsQ291bnRUYWIsXG4gICAgICBjaGVja2luVXJsOiBBcGkuRU5EUE9JTlRTLmNoZWNraW5fbWVldGluZ3NfbGlzdCxcbiAgICAgIHNlbGVjdEFsbENsYXNzOiAnLm1hbmFnZS1pbnRlcm5hbC1zZWxlY3RhbGwnLFxuICAgICAgaXNDb25zZWN1dGl2ZTogZmFsc2UsXG4gICAgICBlZGl0TWVldGluZ1VybDogQXBpLkVORFBPSU5UUy5tZWV0aW5nX3JlcXVlc3RfZWRpdF9wYXRoLFxuICAgICAgdmlld01lZXRpbmdVcmw6IEFwaS5FTkRQT0lOVFMubWVldGluZ19yZXF1ZXN0X3ZpZXdfcGF0aFxuICAgIH1cbiAgfVxuICBmdW5jdGlvbiBpbml0ICgpIHtcbiAgICBBY3Rpb25zLmZldGNoRXZlbnREZXRhaWxzKClcblxuICAgIHZhciBzaG93QWN0aXZpdGllcyA9IG5ldyBSZWdFeHAoJ1tcXD8mXXNob3dBY3Rpdml0aWVzPShbXiYjXSopJykuZXhlYyh3aW5kb3cubG9jYXRpb24uc2VhcmNoKVxuICAgIGlmIChzaG93QWN0aXZpdGllcyAmJiAoc2hvd0FjdGl2aXRpZXNbMV0gPT0gJ3RydWUnKSkge1xuICAgICAgc2hvd01lZXRpbmdBY3Rpdml0aWVzKClcbiAgICB9XG5cbiAgICBTdG9yZS5FdmVudFN0b3JlLmxpc3RlbihmdW5jdGlvbiAoZGF0YSkge1xuICAgICAgdmFyIGZ1bmMgPSBzdG9yZUhhbmRsZXJzW2RhdGEudHlwZV1cbiAgICAgIGlmIChmdW5jKSB7XG4gICAgICAgIGZ1bmMoZGF0YSlcbiAgICAgIH1cbiAgICB9KVxuXG4gICAgU3RvcmUuTWVldGluZ1N0b3JlLnNldEN1cnJlbnRVc2VyRmxhZ3MoKVxuICB9O1xuXG4gIGZ1bmN0aW9uIG9uRXZlbnREZXRhaWxzIChkYXRhKSB7XG4gICAgaXNTdGFmZkV2ZW50ID0gU3RvcmUuRXZlbnRTdG9yZS5pc1N0YWZmU2NoZWR1bGluZ0V2ZW50KClcbiAgICBldmVudEluZm8gPSBTdG9yZS5FdmVudFN0b3JlLmdldEV2ZW50RGV0YWlscygpXG4gICAgaWYgKGRhdGEuc3VjY2Vzcykge1xuICAgICAgaWYgKGlzU3RhZmZFdmVudCkge1xuICAgICAgICBzZXR1cEZvclN0YWZmU2NoZWR1bGVFdmVudCgpXG4gICAgICAgIGRpc3BsYXlMYWJlbEZvckFnZW5kYSA9IFN0b3JlLkV2ZW50U3RvcmUuZ2V0RmllbGRGcm9tTWVldGluZ1R5cGVGb3JBZ2VuZGEoJ2Rpc3BsYXlfbmFtZScpXG4gICAgICAgIHV1aWRPZk1lZXRpbmdUeXBlRm9yQWdlbmRhID0gU3RvcmUuRXZlbnRTdG9yZS5nZXRGaWVsZEZyb21NZWV0aW5nVHlwZUZvckFnZW5kYSgndXVpZCcpXG4gICAgICB9IGVsc2Uge1xuICAgICAgICBzZXR1cEZvclRyYWRlU2hvd0V2ZW50KClcbiAgICAgIH1cbiAgICB9XG4gICAgZW5hYmxlU2VsZWN0QWxsRnVuY3Rpb25hbGl0eSgpXG4gIH1cblxuICBmdW5jdGlvbiBlbmFibGVTZWxlY3RBbGxGdW5jdGlvbmFsaXR5ICgpIHtcbiAgICB2YXIgc2VsZWN0QWxsQnRuID0gaXNTdGFmZkV2ZW50ID8gJCgnLm1hbmFnZS1pbnRlcm5hbC1zZWxlY3RhbGwnKSA6ICQobWVldGluZ1R5cGVIYXNoW01lZXRpbmdUeXBlXS5zZWxlY3RBbGxDbGFzcylcbiAgICBzZWxlY3RBbGxCdG4ucmVtb3ZlQ2xhc3MoJ2hpZGUnKVxuICB9XG5cbiAgZnVuY3Rpb24gc2V0dXBGb3JTdGFmZlNjaGVkdWxlRXZlbnQgKCkge1xuICAgIFN0b3JlLk1lZXRpbmdTdG9yZS5saXN0ZW4oZnVuY3Rpb24gKGRhdGEpIHtcbiAgICAgIHZhciBmdW5jID0gc3RvcmVIYW5kbGVyc1tkYXRhLnR5cGVdXG4gICAgICBpZiAoZnVuYykge1xuICAgICAgICBmdW5jKGRhdGEpXG4gICAgICB9XG4gICAgfSlcbiAgICBTdG9yZS5NZWV0aW5nQWN0aW9uU3RvcmUubGlzdGVuKGZ1bmN0aW9uIChyZXN1bHQpIHtcbiAgICAgIHVwZGF0ZUNhcmQocmVzdWx0KVxuICAgIH0pXG4gICAgc2V0dXBMaXN0ZW5lcnNGb3JTdGFmZlNjaGVkdWxlRXZlbnQoKVxuICAgIEFjdGlvbnMuZ2V0RmlsdGVycyhlbnZEZXRhaWxzLnByZWRlZmluZWRfZmlsdGVycyB8fCB7fSlcbiAgfVxuXG4gIGZ1bmN0aW9uIGF0dGFjaENvbW1vblVJTGlzdGVuZXJlcyAoKSB7XG4gICAgZ2xvYmFsU2VhcmNoLm9uKCdrZXl1cCcsIF8uZGVib3VuY2Uoc2VhcmNoTWVldGluZ3MsIDUwMCkpXG4gICAgdG9nZ2xlQnRuVWwub24oJ2NsaWNrJywgJ2EudG9nZ2xlLWJ0bicsIHVwZGF0ZVRvZ2dsZVZpZXdTdGF0ZSlcblxuICAgIGJ1bGtBY3Rpb25CYXIub24oJ2NsaWNrJywgJyNqcy1idWxrLWFwcHJvdmUnLCBoYW5kbGVCdWxrQXBwcm92ZU1lZXRpbmdzKVxuICAgIGJ1bGtBY3Rpb25CYXIub24oJ2NsaWNrJywgJyNqcy1idWxrLXJlaW52aXRlJywgaGFuZGxlQnVsa1JlaW52aXRlVXNlcnMpXG5cbiAgICAgIC8qKiBmaWx0ZXIgZXZlbnRzICoqL1xuXG4gICAgYXBwbHlGaWx0ZXJCdG4ub24oJ2NsaWNrJywgaGFuZGxlRmlsdGVyQ2xpY2spXG4gICAgcmVzZXRGaWx0ZXJCdG4ub24oJ2NsaWNrJywgcmVzZXRGaWx0ZXIpXG4gICAgZmlsdGVyVG9nZ2xlQnRuLm9uKCdjbGljaycsIGZ1bmN0aW9uIChlKSB7XG4gICAgICBlLnN0b3BQcm9wYWdhdGlvbigpXG4gICAgICBmaWx0ZXIudG9nZ2xlQ2xhc3MoJ3Nob3cnKVxuICAgIH0pXG5cbiAgICBmaWx0ZXJTZWFyY2hGaWVsZC5vbigna2V5dXAnLCBfLmRlYm91bmNlKHVwZGF0ZVNlYXJjaCwgNTAwKSlcbiAgICBhcHBsaWVkRmlsdGVyc0NvbnRhaW5lci5vbignY2xpY2snLCAnLnNlbGVjdGVkLWl0ZW0gLnJlbW92ZScsIHJlbW92ZVNlbGVjdGVkRmlsdGVyKVxuXG4gICAgICAvKiogZmlsdGVyIGV2ZW50cyAqKi9cblxuICAgICQoZG9jdW1lbnQpLm9uKCdjbGljaycsIGZ1bmN0aW9uIChlKSB7XG4gICAgICBmaWx0ZXIucmVtb3ZlQ2xhc3MoJ3Nob3cnKVxuICAgIH0pXG4gICAgZmlsdGVyLm9uKCdjbGljaycsIGZ1bmN0aW9uIChlKSB7XG4gICAgICBlLnN0b3BQcm9wYWdhdGlvbigpXG4gICAgfSlcblxuICAgICQod2luZG93KS5pbmZpbml0ZVNjcm9sbCh7XG4gICAgICBvZmZzZXQ6IDIwMCxcbiAgICAgIGNhbGxiYWNrOiBmZXRjaE1vcmVNZWV0aW5nc1xuICAgIH0pXG5cbiAgICB2YXIgbGlzdENvbmF0YWluZXIgPSBpc1N0YWZmRXZlbnQgPT09IHRydWUgPyAnLmFnZW5kYS1saXN0JyA6ICcubWVldGluZy1saXN0J1xuICAgICQoJy5zZWxlY3RfYWxsX21lZXRpbmcnKS5vbignY2xpY2snLCB7Y29udGFpbmVyOiBsaXN0Q29uYXRhaW5lcn0sIHNlbGVjdEFsbE1lZXRpbmcpXG4gIH1cblxuICBmdW5jdGlvbiBzZXR1cExpc3RlbmVyc0ZvclN0YWZmU2NoZWR1bGVFdmVudCAoKSB7XG4gICAgYXR0YWNoQ29tbW9uVUlMaXN0ZW5lcmVzKClcblxuICAgIGFnZW5kYUxpc3RDb250YWluZXIub24oJ2NoYW5nZScsICcudXBsb2FkLWFnZW5kYS1pbnB1dCcsIGhhbmRsZUFnZW5kYUl0ZW1VcGxvYWQpXG4gICAgICAub24oJ2NoYW5nZScsICdpbnB1dFtuYW1lPVwibWVldGluZ0NhcmRcIl0nLCBjYXJkU2VsZWN0aW9uSGFuZGxlcilcblxuICAgIGFnZW5kYUxpc3RDb250YWluZXIub24oJ3N1Ym1pdCcsICcudXBsb2FkLWNzdicsIHN1Ym1pdEFnZW5kYUl0ZW1VcGxvYWRGb3JtKVxuICAgIGFnZW5kYUxpc3RDb250YWluZXIub24oJ2NsaWNrJywgJy5tZWV0aW5nUmV2ZWFsQ2xzJywgaGFuZGxlQWdlbmRhQ2xpY2spXG5cbiAgICBhZ2VuZGFMaXN0Q29udGFpbmVyLm9uKCdjbGljaycsIGJvb2tBZ2VuZGFCdG4uc2VsZWN0b3IsIGZ1bmN0aW9uIChlKSB7XG4gICAgICBlLnN0b3BQcm9wYWdhdGlvbigpXG4gICAgICBoYW5kbGVCb29rQWdlbmRhQ2xpY2soKVxuICAgIH0pXG5cbiAgICBhZ2VuZGFMaXN0Q29udGFpbmVyLm9uKCdjbGljaycsIGJvb2tBZ2VuZGFBZGRCdG4uc2VsZWN0b3IsIGZ1bmN0aW9uIChlKSB7XG4gICAgICBlLnN0b3BQcm9wYWdhdGlvbigpXG4gICAgICBoYW5kbGVCb29rQWdlbmRhQ2xpY2soKVxuICAgIH0pXG5cbiAgICBhZ2VuZGFMaXN0Q29udGFpbmVyLm9uKCdjbGljaycsICcubWVldGluZy1hY2NlcHQsIC5tZWV0aW5nLWRlY2xpbmUnLCBwb3N0TWVldGluZ0FjdGlvbilcbiAgICAgIC5vbignY2xpY2snLCAnLm1lZXRpbmctYXBwcm92ZScsIHB1dE1lZXRpbmdBY3Rpb24pXG4gICAgICAub24oJ2NsaWNrJywgJy5tZWV0aW5nLWNhbmNlbCcsIGNhbmNlbE1lZXRpbmcpXG5cbiAgICBidWxrQ2FuY2VsQnRuLm9uKCdjbGljaycsIGhhbmRsZUJ1bGtDYW5jZWwpXG4gIH1cblxuICBmdW5jdGlvbiBoYW5kbGVBZ2VuZGFDbGljayAoKSB7XG4gICAgdmFyIHV1aWQgPSAkKHRoaXMpLmRhdGEoJ3V1aWQnKVxuICAgIHZhciBhZ2VuZGEgPSBTdG9yZS5NZWV0aW5nU3RvcmUuZ2V0TWVldGluZyh1dWlkKVxuICAgIHZhciB1cmwgPSBhZ2VuZGEuZWRpdCAmJiBhZ2VuZGEuc3RhdHVzICE9PSAnY2FuY2VsbGVkJyA/IGVudkRldGFpbHMudXJsUHJlZml4ICsgJy9tZWV0aW5nX3JlcXVlc3QvJyArIHV1aWQgKyAnL2VkaXQnIDogZW52RGV0YWlscy51cmxQcmVmaXggKyAnL21lZXRpbmdfcmVxdWVzdC8nICsgdXVpZCArICcvdmlldydcbiAgICB3aW5kb3cuY29tbW9ucy5yZWRpcmVjdFBhZ2UodXJsKVxuICB9XG5cbiAgZnVuY3Rpb24gaGFuZGxlQm9va0FnZW5kYUNsaWNrICgpIHtcbiAgICB3aW5kb3cuY29tbW9ucy5yZWRpcmVjdFBhZ2UoZW52RGV0YWlscy51cmxQcmVmaXggKyBBcGkuRU5EUE9JTlRTLm1lZXRpbmdfcmVxdWVzdF9wYXRoICsgJz9hY3Rpdml0eV91dWlkPScgKyB1dWlkT2ZNZWV0aW5nVHlwZUZvckFnZW5kYSlcbiAgfVxuXG4gIGZ1bmN0aW9uIGhhbmRsZUFnZW5kYUl0ZW1VcGxvYWQgKGV2ZW50KSB7XG4gICAgZXZlbnQuc3RvcFByb3BhZ2F0aW9uKClcbiAgICBldmVudC5wcmV2ZW50RGVmYXVsdCgpXG5cbiAgICB2YXIgZmlsZUVsZW1lbnQgPSBldmVudC50YXJnZXRcblxuICAgIHZhciBkYXRhID0gbmV3IEZvcm1EYXRhKClcbiAgICB2YXIgZmlsZXMgPSBmaWxlRWxlbWVudC5maWxlc1xuXG4gICAgaWYgKGZpbGVzLmxlbmd0aCkge1xuICAgICAgJCgnI2NvdmVyJykuc2hvdygpXG4gICAgICAkLmVhY2goZmlsZXMsIGZ1bmN0aW9uIChrZXksIHZhbHVlKSB7XG4gICAgICAgIGRhdGEuYXBwZW5kKCdjc3ZfZmlsZScsIHZhbHVlKVxuICAgICAgfSlcbiAgICAgIEFjdGlvbnMudXBsb2FkQWdlbmRhSXRlbUNzdihkYXRhKVxuXG4gICAgICB2YXIgQWdlbmRhVXBsb2FkV2lkZ2V0ID0gJChmaWxlRWxlbWVudClcbiAgICAgIEFnZW5kYVVwbG9hZFdpZGdldC52YWwoJycpXG4gICAgICB2YXIgQWdlbmRhVXBsb2FkV2lkZ2V0Q2xvbmUgPSBBZ2VuZGFVcGxvYWRXaWRnZXQuY2xvbmUoZmFsc2UpXG4gICAgICBBZ2VuZGFVcGxvYWRXaWRnZXQucmVwbGFjZVdpdGgoQWdlbmRhVXBsb2FkV2lkZ2V0Q2xvbmUpXG4gICAgfVxuICB9XG5cbiAgZnVuY3Rpb24gc3VibWl0QWdlbmRhSXRlbVVwbG9hZEZvcm0gKCkge1xuICAgIGFnZW5kYUxpc3RDb250YWluZXIuZmluZCgnLnVwbG9hZC1jc3YnKS5zdWJtaXQoKVxuICB9XG5cbiAgZnVuY3Rpb24gYWdlbmRhSXRlbVVwbG9hZEZhaWx1cmVIYW5kbGVyIChkYXRhKSB7XG4gICAgJCgnI2NvdmVyJykuZmFkZU91dCgpXG5cbiAgICB2YXIgaGVhZGVyTWVzc2FnZSA9IGkxOG4udCgnYWdlbmRhX2l0ZW1fY3N2X3VwbG9hZF9mYWlsdXJlX2hlYWRlcicpXG4gICAgdmFyIGVycm9yX21lc3NhZ2UgPSBkYXRhLmNvdW50TWVzc2FnZSArICc8YnI+PGJyPidcblxuICAgIGlmIChkYXRhLmRvd25sb2FkX2xpbmspIHtcbiAgICAgIGVycm9yX21lc3NhZ2UgKz0gZGF0YS5kb3dubG9hZF9saW5rXG4gICAgfVxuXG4gICAgdmFyIGVycm9ycyA9IGRhdGEuZXJyb3JzXG5cbiAgICBpZiAoXy5pc1N0cmluZyhlcnJvcnMpKSB7XG4gICAgICBlcnJvcl9tZXNzYWdlICs9IGVycm9yc1xuICAgIH0gZWxzZSBpZiAoXy5pc09iamVjdChlcnJvcnMpKSB7XG4gICAgICBfLmZvckVhY2goZXJyb3JzLCBmdW5jdGlvbiAoZXJyb3IsIGluZGV4KSB7XG4gICAgICAgIGVycm9yX21lc3NhZ2UgKz0gZXJyb3IgKyAnPGJyPidcbiAgICAgIH0pXG4gICAgfVxuXG4gICAgbm90aWZpY2F0aW9uTW9kYWwubm90aWZpY2F0aW9uTW9kYWwoe1xuICAgICAgdHlwZTogJ25vdGlmaWNhdGlvbicsXG4gICAgICBjbGFzczogJ3JlZCcsXG4gICAgICB0aXRsZTogaGVhZGVyTWVzc2FnZSxcbiAgICAgIGJvZHk6IGVycm9yX21lc3NhZ2VcbiAgICB9KVxuICB9XG5cbiAgZnVuY3Rpb24gYWdlbmRhSXRlbVVwbG9hZFN1Y2Nlc3NIYW5kbGVyIChkYXRhKSB7XG4gICAgJCgnI2NvdmVyJykuZmFkZU91dCgpXG5cbiAgICBub3RpZmljYXRpb25Nb2RhbC5ub3RpZmljYXRpb25Nb2RhbCh7XG4gICAgICB0eXBlOiAnbm90aWZpY2F0aW9uJyxcbiAgICAgIGNsYXNzOiAnZ3JlZW4nLFxuICAgICAgdGl0bGU6IGkxOG4udCgnYWdlbmRhX2l0ZW1fY3N2X3VwbG9hZF9zdWNjZXNzX2hlYWRlcicpLFxuICAgICAgYm9keTogZGF0YS5jb3VudE1lc3NhZ2VcbiAgICB9KVxuICB9XG5cbiAgZnVuY3Rpb24gc2V0dXBGb3JUcmFkZVNob3dFdmVudCAoKSB7XG4gICAgbW9iaWxlSW50ZXJuYWxDb3VudFRhYi5yZW1vdmVDbGFzcygnYWN0aXZlJylcbiAgICBtb2JpbGVFeHRlcm5hbENvdW50VGFiLnJlbW92ZUNsYXNzKCdhY3RpdmUnKVxuICAgIGludGVybmFsQ291bnRUYWIucmVtb3ZlQ2xhc3MoJ2FjdGl2ZScpXG4gICAgZXh0ZXJuYWxDb3VudFRhYi5yZW1vdmVDbGFzcygnYWN0aXZlJylcbiAgICBtZWV0aW5nVHlwZUhhc2hbTWVldGluZ1R5cGVdLmN1cnJlbnRUYWIuYWRkQ2xhc3MoJ2FjdGl2ZScpXG4gICAgbWVldGluZ1R5cGVIYXNoW01lZXRpbmdUeXBlXS5jdXJyZW50TW9iaWxlVGFiLmFkZENsYXNzKCdhY3RpdmUnKVxuICAgIG1lZXRpbmdUeXBlSGFzaFtNZWV0aW5nVHlwZV0uY3VycmVudFRhYi5vZmYoJ2NsaWNrJylcblxuICAgIFN0b3JlLk1lZXRpbmdTdG9yZS5saXN0ZW4oZnVuY3Rpb24gKGRhdGEpIHtcbiAgICAgIHZhciBmdW5jID0gc3RvcmVIYW5kbGVyc1tkYXRhLnR5cGVdXG4gICAgICBpZiAoZnVuYykge1xuICAgICAgICBmdW5jKGRhdGEpXG4gICAgICB9XG4gICAgfSlcblxuICAgIFN0b3JlLk1lZXRpbmdBY3Rpb25TdG9yZS5saXN0ZW4oZnVuY3Rpb24gKHJlc3VsdCkge1xuICAgICAgdXBkYXRlQ2FyZChyZXN1bHQpXG4gICAgfSlcblxuICAgIHNldHVwVUkoKVxuICAgIHNldHVwTGlzdGVuZXJzKClcbiAgfTtcblxuICBmdW5jdGlvbiBzZXR1cFVJICgpIHtcbiAgICBBY3Rpb25zLmdldEZpbHRlcnMoZW52RGV0YWlscy5wcmVkZWZpbmVkX2ZpbHRlcnMgfHwge30pXG4gICAgc2V0QWN0aXZlU3RhdGUoU3RvcmUuTWVldGluZ1N0b3JlLmdldExvY2FsVG9nZ2xlKCkpXG4gICAgdmFyIHN0YXJ0RGF0ZSA9IG1vbWVudChlbnZEZXRhaWxzLmV2ZW50LnN0YXJ0X2RhdGUsICdZWVlZLU1NLUREJylcbiAgICB2YXIgZW5kRGF0ZSA9IG1vbWVudChlbnZEZXRhaWxzLmV2ZW50LmVuZF9kYXRlLCAnWVlZWS1NTS1ERCcpXG4gICAgZmlsdGVyU3RhcnREYXRlLmRhdGVwaWNrZXIoe1xuICAgICAgZGF0ZUZvcm1hdDogJ21tL2RkL3l5JyxcbiAgICAgIG1pbkRhdGU6IHN0YXJ0RGF0ZS5fZCxcbiAgICAgIG1heERhdGU6IGVuZERhdGUuX2RcbiAgICB9KVxuICAgIGZpbHRlckVuZERhdGUuZGF0ZXBpY2tlcih7XG4gICAgICBkYXRlRm9ybWF0OiAnbW0vZGQveXknLFxuICAgICAgbWluRGF0ZTogc3RhcnREYXRlLl9kLFxuICAgICAgbWF4RGF0ZTogZW5kRGF0ZS5fZFxuICAgIH0pXG4gIH07XG5cbiAgZnVuY3Rpb24gc2V0TWVldGluZ0ZpbHRlcnMgKGFwaVJlc3BvbnNlKSB7XG4gICAgdmFyIHNlYXJjaFRlcm0gPSAoYXBpUmVzcG9uc2UuZGF0YS5hcHBsaWVkU2VhcmNoIHx8ICcnKS50cmltKClcbiAgICBzZXRNZWV0aW5nU2VhcmNoKHNlYXJjaFRlcm0pXG4gICAgQWN0aW9ucy51cGRhdGVTZWFyY2goc2VhcmNoVGVybSlcbiAgICBtZWV0aW5nRmlsdGVyQ21wLnNldE1lZXRpbmdGaWx0ZXJzKGFwaVJlc3BvbnNlLmRhdGEuZmlsdGVycywgZmlsdGVyUGFuZWwsIEFjdGlvbnMpXG4gICAgYXBwbHlGaWx0ZXIoKVxuICB9XG5cbiAgZnVuY3Rpb24gc2V0TWVldGluZ1NlYXJjaCAoc2VhcmNoVmFsdWUpIHtcbiAgICBnbG9iYWxTZWFyY2gudmFsKHNlYXJjaFZhbHVlKVxuICAgIGZpbHRlclNlYXJjaEZpZWxkLnZhbChzZWFyY2hWYWx1ZSlcbiAgfVxuXG4gIGZ1bmN0aW9uIHVwZGF0ZVRvZ2dsZVZpZXdTdGF0ZSAoZSkge1xuICAgIGUucHJldmVudERlZmF1bHQoKVxuICAgIHZhciBFbCA9ICQoZS5jdXJyZW50VGFyZ2V0KVxuICAgIGlmICghRWwuaGFzQ2xhc3MoJ2FjdGl2ZScpKSB7XG4gICAgICBBY3Rpb25zLnRvZ2dsZVZpZXcoRWwuZGF0YSgnc3dpdGNoLXR5cGUnKSlcbiAgICB9XG4gIH1cblxuICBmdW5jdGlvbiBoYW5kZWxWaWV3VG9nZ2xlIChkYXRhKSB7XG4gICAgc2V0QWN0aXZlU3RhdGUoZGF0YS5zZWxlY3RlZFZpZXcpXG4gICAgaWYgKGRhdGEuc2VsZWN0ZWRWaWV3ID09PSAnY2hlY2tpbicpIHtcbiAgICAgIHZhciBjaGVja2luVXJsID0gbWVldGluZ1R5cGVIYXNoW01lZXRpbmdUeXBlXS5jaGVja2luVXJsXG4gICAgICB3aW5kb3cuY29tbW9ucy5yZWRpcmVjdFBhZ2UoZW52RGV0YWlscy51cmxQcmVmaXggKyBjaGVja2luVXJsKVxuICAgIH0gZWxzZSB7XG4gICAgICBjb21tb25zLnNldEl0ZW0oJ21lZXRpbmctbGlzdCcsIGRhdGEuc2VsZWN0ZWRWaWV3KVxuICAgICAgdmFyIHZpZXdTdHlsZSA9IGRhdGEuZGF0YS52aWV3U3R5bGVcbiAgICAgIHZhciBsaXN0SG9sZGVyID0gaXNTdGFmZkV2ZW50ID09IHRydWUgPyBhZ2VuZGFMaXN0Q29udGFpbmVyLmZpbmQoJy5hZ2VuZGEtbGlzdCcpIDogbWVldGluZ0xpc3RDb250YWluZXIuZmluZCgnLm1lZXRpbmctbGlzdCcpXG4gICAgICBsaXN0SG9sZGVyLnJlbW92ZUNsYXNzKCd0aWxlLXZpZXcgbGlzdC12aWV3JykuYWRkQ2xhc3Modmlld1N0eWxlKVxuICAgICAgbGlzdEhvbGRlci5maW5kKCdkaXYuaXRlbScpLnJlbW92ZUNsYXNzKCdjb2wtbWQtMyBjb2wtc20tNCBjb2wtbWQtMTInKS5hZGRDbGFzcyhkYXRhLmRhdGEudGlsZVNpemUpXG4gICAgfVxuICB9O1xuXG4gIGZ1bmN0aW9uIHNldEFjdGl2ZVN0YXRlIChzZWxlY3RlZFZpZXcpIHtcbiAgICB0b2dnbGVCdG5VbC5maW5kKCdhJykucmVtb3ZlQ2xhc3MoJ2FjdGl2ZScpXG4gICAgJChcImFbZGF0YS1zd2l0Y2gtdHlwZT0nXCIgKyBzZWxlY3RlZFZpZXcgKyBcIiddXCIpLmFkZENsYXNzKCdhY3RpdmUnKVxuICB9XG5cbiAgZnVuY3Rpb24gaGFuZGxlTWVldGluZ0xpc3QgKGRhdGEpIHtcbiAgICBkYXRhID0gZGF0YS5kYXRhXG4gICAgaWYgKGlzU3RhZmZFdmVudCkge1xuICAgICAgZGlzcGxheUFnZW5kYUl0ZW1zKGRhdGEpXG4gICAgICB1cGRhdGVBY3Rpdml0eUNvdW50KGRhdGEudG90YWwpXG4gICAgfSBlbHNlIHtcbiAgICAgIGRpc3BsYXlNZWV0aW5ncyhkYXRhKVxuICAgICAgdXBkYXRlTWVldGluZ0NvdW50KGRhdGEudG90YWwsIGRhdGEudG90YWxFeHRlcm5hbCwgZGF0YS50b3RhbFNlc3Npb25zLCBkYXRhLnRvdGFsQ29uc2VjTWVldGluZywgZGF0YS50b3RhbEludGVybmFsTWVldGluZywgZGF0YS50b3RhbFJldmlld2VlTWVldGluZylcbiAgICB9XG4gICAgU3RvcmUuTWVldGluZ1N0b3JlLnVwZGF0ZUZldGNoU3RhdGUoZmFsc2UpXG4gIH07XG5cbiAgZnVuY3Rpb24gdXBkYXRlQ2FyZCAocmVzdWx0KSB7XG4gICAgaWYgKF8uaXNFbXB0eShyZXN1bHQuZXJyb3JzKSkge1xuICAgICAgcmVmcmVzaE1lZXRpbmdMaXN0QWZ0ZXJBY3Rpb24oKVxuICAgIH0gZWxzZSB7XG4gICAgICBub3RpZmljYXRpb25Nb2RhbC5ub3RpZmljYXRpb25Nb2RhbCh7XG4gICAgICAgIHRpbWVvdXQ6IHRydWUsXG4gICAgICAgIGNsYXNzOiAncmVkJyxcbiAgICAgICAgdGl0bGU6IGkxOG4udCgnZmFpbHVyZScpLFxuICAgICAgICBib2R5OiByZXN1bHQuZXJyb3JzLlJ1bnRpbWVFcnJvci5qb2luKCcsJylcbiAgICAgIH0pXG4gICAgfVxuICB9O1xuXG4gIGZ1bmN0aW9uIHJlZnJlc2hNZWV0aW5nTGlzdEFmdGVyQWN0aW9uICgpIHtcbiAgICBTdG9yZS5NZWV0aW5nU3RvcmUuc2V0Q3VycmVudFBhZ2UoMSlcbiAgICBTdG9yZS5NZWV0aW5nU3RvcmUucmVzZXRNZWV0aW5nTGlzdCgpXG4gICAgQWN0aW9ucy5mZXRjaE1lZXRpbmdzKDEpXG4gIH1cblxuICBmdW5jdGlvbiBhZGRDb21tb25GaWVsZHNGb3JEaXNwbGF5IChpdGVtKSB7XG4gICAgaWYgKGl0ZW0gJiYgaXRlbS5pbnZpdGVlc19zdGF0dXNfY291bnRzKSB7XG4gICAgICBpdGVtLnBlbmRpbmdDb3VudCA9IGl0ZW0uaW52aXRlZXNfc3RhdHVzX2NvdW50cy5wZW5kaW5nIHx8IDBcbiAgICAgIGl0ZW0udG90YWxJbnZpdGVlQ291bnQgPSBpdGVtLmludml0ZWVzX3N0YXR1c19jb3VudHMudG90YWxfaW52aXRlZXMgfHwgMFxuICAgICAgaXRlbS5hY2NlcHRlZENvdW50ID0gaXRlbS5pbnZpdGVlc19zdGF0dXNfY291bnRzLmFjY2VwdGVkIHx8IDBcbiAgICAgIGl0ZW0uZGVjbGluZWRDb3VudCA9IGl0ZW0uaW52aXRlZXNfc3RhdHVzX2NvdW50cy5kZWNsaW5lZCB8fCAwXG4gICAgICBpdGVtLm1lZXRpbmdfd2l0aCA9IGl0ZW0ubWVldGluZ193aXRoIHx8ICcnXG4gICAgICBpdGVtLmZvbnRTaXplID0gd2luZG93LmNvbW1vbnMuZ2V0Rm9udFNpemUoaXRlbS5tZWV0aW5nX3dpdGggfHwgJycpXG4gICAgICBpdGVtLnRpbGVTaXplID0gU3RvcmUuTWVldGluZ1N0b3JlLmdldFRvZ2dsZVN0YXRlKCkudGlsZVNpemVcbiAgICAgIGl0ZW0uc2hvd1VzZXJBY3Rpb25zID0gdHJ1ZVxuICAgICAgaXRlbS5tZWV0aW5nVHlwZSA9IG1lZXRpbmdUeXBlSGFzaFtNZWV0aW5nVHlwZV0uZGlzcGxheVRleHRcbiAgICB9XG4gIH1cblxuICBmdW5jdGlvbiBhZGRGaWVsZHNGb3JNZWV0aW5nRGlzcGxheSAobWVldGluZykge1xuICAgIG1lZXRpbmcubXVsdGlwbGVEYXlEaXNwbGF5Rm9ybWF0ID0gZmFsc2VcbiAgICBtZWV0aW5nLnN0YXJ0VGltZSA9IG1vbWVudChtZWV0aW5nLnN0YXJ0X3RpbWUpLnV0YygpLmZvcm1hdChtZWV0aW5nVGltZUZvcm1hdClcbiAgICBtZWV0aW5nLmVuZFRpbWUgPSBtb21lbnQobWVldGluZy5lbmRfdGltZSkudXRjKCkuZm9ybWF0KG1lZXRpbmdUaW1lRm9ybWF0KVxuICAgIG1lZXRpbmcubWVldGluZ0RhdGUgPSBtb21lbnQobWVldGluZy5zdGFydF90aW1lKS51dGMoKS5mb3JtYXQobWVldGluZ0RhdGVGb3JtYXQpXG4gIH1cblxuICBmdW5jdGlvbiBhZGRGaWVsZHNGb3JBZ2VuZGFEaXNwbGF5IChhZ2VuZGEpIHtcbiAgICBhZ2VuZGEubXVsdGlwbGVEYXlEaXNwbGF5Rm9ybWF0ID0gdHJ1ZVxuXG4gICAgYWdlbmRhLnN0YXJ0RGF0ZVRpbWUgPSBtb21lbnQoYWdlbmRhLnN0YXJ0X3RpbWUpLnV0YygpLmZvcm1hdChhZ2VuZGFJdGVtRGF0ZVRpbWVGb3JtYXQpXG4gICAgYWdlbmRhLmVuZERhdGVUaW1lID0gbW9tZW50KGFnZW5kYS5lbmRfdGltZSkudXRjKCkuZm9ybWF0KGFnZW5kYUl0ZW1EYXRlVGltZUZvcm1hdClcbiAgfVxuXG4gIGZ1bmN0aW9uIHVwZGF0ZU1lZXRpbmdDb3VudCAoY291bnQsIGV4dGVybmFsQ291bnQsIHNlc3Npb25Db3VudCwgY29uc2VjQ291bnQsIGludGVybmFsQ291bnQsIHJldmlld2VlTWVldGluZ0NvdW50KSB7XG4gICAgY3VycmVudFRhYiA9ICQoJ2xpLmFjdGl2ZScsICcubmF2LWNvdW50JylcbiAgICBtb2JpbGVDdXJyZW50VGFiID0gJCgnYS5hY3RpdmUnLCAnLm5hdmJhci1oZWFkZXInKVxuICAgIHZhciBpbnRlcm5hbFRhYlRleHQgPSBpMThuLnQoKChpbnRlcm5hbENvdW50IHx8IGNvdW50KSA9PT0gMSA/ICdNRUVUSU5HJyA6ICdNRUVUSU5HUycpLCB7IGNvdW50OiAnJyB9KVxuICAgIHZhciBleHRlcm5hbFRhYlRleHQgPSBpMThuLnQoKGV4dGVybmFsQ291bnQgPT09IDEgPyAnUkVRVUVTVCcgOiAnUkVRVUVTVFMnKSwgeyBjb3VudDogJycgfSlcbiAgICB2YXIgZXh0ZXJuYWxNb2JpbGVUYWJUZXh0ID0gaTE4bi50KChleHRlcm5hbENvdW50ID09PSAxID8gJ1JFUScgOiAnUkVRUycpLCB7IGNvdW50OiAnJyB9KVxuICAgIHZhciBzZXNzaW9uVGFidGV4dCA9IGkxOG4udCgoc2Vzc2lvbkNvdW50ID09PSAxID8gJ1NFU1NJT04nIDogJ1NFU1NJT05TJykpXG4gICAgdmFyIHJldmlld2VlTWVldGluZ1RhYlRleHQgPSBpMThuLnQocmV2aWV3ZWVNZWV0aW5nQ291bnQgPT09IDEgPyAnUkVWSUVXRUVfTUVFVElORycgOiAnUkVWSUVXRUVfTUVFVElOR1MnKVxuICAgIHZhciBjb25zZWN1dGl2ZVRhYlRleHQgPSBpMThuLnQoKChjb25zZWNDb3VudCB8fCBjb3VudCkgPT09IDEgPyAnQ09OU0VDVVRJVkUgTUVFVElORycgOiAnQ09OU0VDVVRJVkUgTUVFVElOR1MnKSlcbiAgICBkaXNwbGF5Q291bnRJblRhYihleHRlcm5hbENvdW50VGFiLCBtb2JpbGVFeHRlcm5hbENvdW50VGFiLCBleHRlcm5hbENvdW50LCBleHRlcm5hbFRhYlRleHQpXG4gICAgZGlzcGxheUNvdW50SW5UYWIoaW50ZXJuYWxDb3VudFRhYiwgbW9iaWxlSW50ZXJuYWxDb3VudFRhYiwgaW50ZXJuYWxDb3VudCwgaW50ZXJuYWxUYWJUZXh0KVxuICAgIGRpc3BsYXlDb3VudEluVGFiKGNvbnNlY3V0aXZlTWVldGluZ1RhYiwgbW9iaWxlQ29uc2VjdXRpdmVDb3VudFRhYiwgY29uc2VjQ291bnQsIGNvbnNlY3V0aXZlVGFiVGV4dClcbiAgICBkaXNwbGF5Q291bnRJblRhYihzZXNzaW9uQ291bnRUYWIsIG1vYmlsZVNlc3Npb25Db3VudFRhYiwgc2Vzc2lvbkNvdW50LCBzZXNzaW9uVGFidGV4dClcbiAgICBkaXNwbGF5Q291bnRJblRhYihyZXZpZXdlZU1lZXRpbmdDb3VudFRhYiwgbW9iaWxlUmV2aWV3ZWVNZWV0aW5nQ291bnRUYWIsIHJldmlld2VlTWVldGluZ0NvdW50LCByZXZpZXdlZU1lZXRpbmdUYWJUZXh0KVxuICAgIHVwZGF0ZUNvdW50SW5DdXJyVGFiKGN1cnJlbnRUYWIsIG1vYmlsZUN1cnJlbnRUYWIsIGNvdW50KVxuICB9O1xuXG4gIGZ1bmN0aW9uIHVwZGF0ZUNvdW50SW5DdXJyVGFiICh0YWIsIG1vYmlsZVRhYiwgY291bnQpIHtcbiAgICB0YWIuZmluZCgnLm1lZXRpbmdfY291bnQnKS50ZXh0KGNvdW50KVxuICAgIG1vYmlsZVRhYi5maW5kKCcubWVldGluZ19jb3VudCcpLnRleHQoY291bnQpXG4gIH1cblxuICBmdW5jdGlvbiBkaXNwbGF5Q291bnRJblRhYiAodGFiLCBtb2JpbGVUYWIsIGNvdW50LCB0ZXh0TGFiZWwsIG1vYmlsZVRleHRMYWJlbCkge1xuICAgIHRhYi5maW5kKCcubWVldGluZ19jb3VudCcpLnRleHQoY291bnQpXG4gICAgICAgICAgICAuc2libGluZ3MoJ3NwYW4udGl0bGVfdGV4dCcpLnRleHQodGV4dExhYmVsKVxuICAgIG1vYmlsZVRhYi5maW5kKCcubWVldGluZ19jb3VudCcpLnRleHQoY291bnQpXG4gICAgICAgICAgICAuc2libGluZ3MoJ3NwYW4udGl0bGVfdGV4dCcpLnRleHQobW9iaWxlVGV4dExhYmVsIHx8IHRleHRMYWJlbClcbiAgfVxuXG4gIGZ1bmN0aW9uIHVwZGF0ZUFjdGl2aXR5Q291bnQgKGNvdW50KSB7XG4gICAgdmFyIGxhYmVsID0gY291bnQgPiAxID8gcGx1cmFsaXplKGRpc3BsYXlMYWJlbEZvckFnZW5kYSkgOiBkaXNwbGF5TGFiZWxGb3JBZ2VuZGFcbiAgICAkKCcudGFiX2ludGVybmFsJykuZmluZCgnLm1lZXRpbmdfY291bnQnKS50ZXh0KGNvdW50KVxuICAgICAgICAgICAgLnNpYmxpbmdzKCdzcGFuLnRpdGxlX3RleHQnKS5odG1sKGxhYmVsKVxuICAgICQoJy5tb2JpbGVfdGFiX2ludGVybmFsJykuZmluZCgnLm1lZXRpbmdfY291bnQnKS50ZXh0KGNvdW50KVxuICAgICAgICAgICAgLnNpYmxpbmdzKCdzcGFuLnRpdGxlX3RleHQnKS5odG1sKGxhYmVsKVxuICB9XG5cbiAgZnVuY3Rpb24gZGlzcGxheUFnZW5kYUl0ZW1zIChkYXRhKSB7XG4gICAgdmFyIHRlbXBsYXRlID0gcmVxdWlyZSgnVGVtcGxhdGVzL21lZXRpbmcvbWVldGluZy1saXN0JylcblxuICAgIHZhciBhZ2VuZGFJdGVtcyA9IGRhdGEubWVldGluZ3NcbiAgICBoYXNTZWxlY3RlZE1lZXRpbmdzID0gZmFsc2VcbiAgICBhZ2VuZGFJdGVtcy5tYXAoZnVuY3Rpb24gKGFnZW5kYUl0ZW0pIHtcbiAgICAgIGlmIChzZWxlY3RlZE1lZXRpbmdDYXJkSGFzaFthZ2VuZGFJdGVtLnV1aWRdKSB7XG4gICAgICAgIGFnZW5kYUl0ZW0uY2hlY2tlZCA9ICdjaGVja2VkJ1xuICAgICAgICBoYXNTZWxlY3RlZE1lZXRpbmdzID0gdHJ1ZVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgYWdlbmRhSXRlbS5jaGVja2VkID0gJydcbiAgICAgIH1cbiAgICAgIGFkZENvbW1vbkZpZWxkc0ZvckRpc3BsYXkoYWdlbmRhSXRlbSlcbiAgICAgIGFkZEZpZWxkc0ZvckFnZW5kYURpc3BsYXkoYWdlbmRhSXRlbSlcbiAgICB9KVxuXG4gICAgdmFyIGhpZGVBZGRBY3Rpdml0eU9wdGlvbiA9IGV2ZW50SW5mby5pc0FkbWluID09PSBmYWxzZSAmJiBldmVudEluZm8uaXNBY3Rpdml0eU1hbmFnZXIgPT09IGZhbHNlXG4gICAgdmFyIGRpc3BsYXlIdG1sID0gdGVtcGxhdGUoe1xuICAgICAgbWVldGluZ0xpc3Q6IGFnZW5kYUl0ZW1zLFxuICAgICAgaXNFQkNFdmVudDogZmFsc2UsXG4gICAgICBpc1N0YWZmU2NoZWR1bGU6IHRydWUsXG4gICAgICB0b2dnbGVTdGF0ZTogZGF0YS50b2dnbGVTdGF0ZSxcbiAgICAgIGxpc3RDbGFzczogJ2FnZW5kYS1saXN0JyxcbiAgICAgIGFwcHJvdmVfbGFiZWw6IGkxOG4udCgnYXBwcm92ZScpLFxuICAgICAgY2FuY2VsX2xhYmVsOiBpMThuLnQoJ2NhbmNlbCcpLFxuICAgICAgZGVjbGluZV9sYWJlbDogaTE4bi50KCdkZWNsaW5lJyksXG4gICAgICBhY2NlcHRfbGFiZWw6IGkxOG4udCgnYWNjZXB0JyksXG4gICAgICBDYW5BY2Nlc3NWaWV3T25seUV2ZW50OiBldmVudEluZm8uY2FuX2FjY2Vzc192b19ldmVudCxcbiAgICAgIGRpc3BsYXlMYWJlbEZvckFkZEFnZW5kYTogaTE4bi50KCdhZGRfYWdlbmRhX2l0ZW0nLCB7IGxhYmVsOiBkaXNwbGF5TGFiZWxGb3JBZ2VuZGEgfSksXG4gICAgICBkaXNwbGF5TGFiZWxGb3JVcGxvYWRBZ2VuZGE6IGkxOG4udCgndXBsb2FkX2FnZW5kYV9pdGVtcycsIHsgbGFiZWw6IHBsdXJhbGl6ZShkaXNwbGF5TGFiZWxGb3JBZ2VuZGEpIH0pLFxuICAgICAgZG93bmxvYWRBZ2VuZGFJdGVtVGVtcGxhdGVVcmw6IGVudkRldGFpbHMudXJsUHJlZml4ICsgQXBpLkVORFBPSU5UUy5kb3dubG9hZF9hZ2VuZGFfaXRlbV90ZW1wbGF0ZV91cmwsXG4gICAgICBoaWRlQWRkQWN0aXZpdHlPcHRpb246IGhpZGVBZGRBY3Rpdml0eU9wdGlvblxuICAgIH0pXG4gICAgYWdlbmRhTGlzdENvbnRhaW5lci5odG1sKGRpc3BsYXlIdG1sKVxuICAgIHNob3dIaWRlQnVsa0FjdGlvbkJhcigpXG4gIH1cblxuICBmdW5jdGlvbiBkaXNwbGF5TWVldGluZ3MgKGRhdGEpIHtcbiAgICB2YXIgdGVtcGxhdGUgPSByZXF1aXJlKCdUZW1wbGF0ZXMvbWVldGluZy9tZWV0aW5nLWxpc3QnKVxuICAgIHZhciBib29rTWVldGluZ1BhdGggPSBlbnZEZXRhaWxzLnVybFByZWZpeCArIEFwaS5FTkRQT0lOVFMubWVldGluZ19yZXF1ZXN0X3BhdGhcbiAgICBpZiAodHlwZW9mIGppZmZsZSAhPT0gJ3VuZGVmaW5lZCcpIHtcbiAgICAgIGJvb2tNZWV0aW5nUGF0aCA9IEFwaS5FTkRQT0lOVFMuam5fYm9va19tZWV0aW5nICsgd2luZG93LmxvY2F0aW9uLnNlYXJjaFxuICAgIH1cblxuICAgIHZhciBtZWV0aW5ncyA9IF8uY2xvbmVEZWVwKGRhdGEubWVldGluZ3MpXG4gICAgaGFzU2VsZWN0ZWRNZWV0aW5ncyA9IGZhbHNlXG4gICAgbWVldGluZ3MubWFwKGZ1bmN0aW9uIChtZWV0aW5nKSB7XG4gICAgICBpZiAoc2VsZWN0ZWRNZWV0aW5nQ2FyZEhhc2hbbWVldGluZy51dWlkXSkge1xuICAgICAgICBtZWV0aW5nLmNoZWNrZWQgPSAnY2hlY2tlZCdcbiAgICAgICAgaGFzU2VsZWN0ZWRNZWV0aW5ncyA9IHRydWVcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIG1lZXRpbmcuY2hlY2tlZCA9ICcnXG4gICAgICB9XG4gICAgICBhZGRDb21tb25GaWVsZHNGb3JEaXNwbGF5KG1lZXRpbmcpXG4gICAgICBhZGRGaWVsZHNGb3JNZWV0aW5nRGlzcGxheShtZWV0aW5nKVxuICAgIH0pXG4gICAgbWVldGluZ0xpc3RDb250YWluZXIuaHRtbCh0ZW1wbGF0ZSh7XG4gICAgICBtZWV0aW5nTGlzdDogbWVldGluZ3MsXG4gICAgICB0b2dnbGVTdGF0ZTogZGF0YS50b2dnbGVTdGF0ZSxcbiAgICAgIGFwcHJvdmVfbGFiZWw6IGkxOG4udChtZWV0aW5nVHlwZUhhc2hbTWVldGluZ1R5cGVdLmFwcHJvdmVMYWJlbCksXG4gICAgICBjYW5jZWxfbGFiZWw6IGkxOG4udChtZWV0aW5nVHlwZUhhc2hbTWVldGluZ1R5cGVdLmNhbmNlbExhYmVsKSxcbiAgICAgIGRlY2xpbmVfbGFiZWw6IGkxOG4udChtZWV0aW5nVHlwZUhhc2hbTWVldGluZ1R5cGVdLmRlY2xpbmVMYWJlbCksXG4gICAgICBhY2NlcHRfbGFiZWw6IGkxOG4udChtZWV0aW5nVHlwZUhhc2hbTWVldGluZ1R5cGVdLmFjY2VwdExhYmVsKSxcbiAgICAgIGJvb2tfbWVldGluZ19wYXRoOiBib29rTWVldGluZ1BhdGgsXG4gICAgICBDYW5BY2Nlc3NWaWV3T25seUV2ZW50OiBldmVudEluZm8uY2FuX2FjY2Vzc192b19ldmVudCxcbiAgICAgIHNob3dOZXdNZWV0aW5nOiB0cnVlLFxuICAgICAgaXNFQkNFdmVudDogaXNFQkNFdmVudCxcbiAgICAgIGxpc3RDbGFzczogJ21lZXRpbmctbGlzdCcsXG4gICAgICBtZWV0aW5nVHlwZTogbWVldGluZ1R5cGVIYXNoW01lZXRpbmdUeXBlXS5kaXNwbGF5VGV4dCxcbiAgICAgIGlzQ29uc2VjdXRpdmU6IG1lZXRpbmdUeXBlSGFzaFtNZWV0aW5nVHlwZV0uaXNDb25zZWN1dGl2ZVxuICAgIH0pKVxuICAgIHNob3dIaWRlQnVsa0FjdGlvbkJhcigpXG4gICAgaGlkZUFwcHJvdmVCdXR0b25Gb3JTZmRjKClcbiAgICBoaWRlU3VydmV5SWNvbkZvclNmZGMoKVxuICB9XG5cbiAgZnVuY3Rpb24gaGlkZUFwcHJvdmVCdXR0b25Gb3JTZmRjICgpIHtcbiAgICBpZiAoIXNob3VsZFNob3dBY3Rpb25zRm9yU2ZkYygpKSB7XG4gICAgICBtZWV0aW5nTGlzdENvbnRhaW5lci5maW5kKCcubWVldGluZy1jYXJkIC5jYXJkLWZvb3RlciAubWVldGluZy1hcHByb3ZlJykuYWRkQ2xhc3MoJ2hpZGUnKVxuICAgIH1cbiAgfVxuXG4gIGZ1bmN0aW9uIGhpZGVTdXJ2ZXlJY29uRm9yU2ZkYyAoKSB7XG4gICAgaWYgKCFzaG91bGRTaG93QWN0aW9uc0ZvclNmZGMoKSkge1xuICAgICAgbWVldGluZ0xpc3RDb250YWluZXIuZmluZCgnLm1lZXRpbmctY2FyZCAuY2FyZC1jb250ZW50IC5qcy1zdXJ2ZXktaWNvbicpLmFkZENsYXNzKCdoaWRlJylcbiAgICB9XG4gIH1cblxuICBmdW5jdGlvbiBzaG91bGRTaG93QWN0aW9uc0ZvclNmZGMgKCkge1xuICAgIHJldHVybiAhKHR5cGVvZiBqaWZmbGUgIT09ICd1bmRlZmluZWQnICYmIChlbnZEZXRhaWxzLmlzQ1NNKCkgfHwgZW52RGV0YWlscy5pc01lZXRpbmdNYW5hZ2VyKCkgfHwgZW52RGV0YWlscy5pc0p1bmlvck1NKCkgfHwgZW52RGV0YWlscy5pc1F1ZXVlTWFuYWdlcigpKSlcbiAgfVxuXG4gIGZ1bmN0aW9uIHNlbGVjdEFsbE1lZXRpbmcgKGV2ZW50KSB7XG4gICAgaWYgKCFzZWxlY3RBbGxGbGFnKSB7XG4gICAgICBzZWxlY3RBbGxGbGFnID0gdHJ1ZVxuICAgICAgJCgnLnNlbGVjdF9hbGxfbWVldGluZycpLmh0bWwoaTE4bi50KCdjbGVhcicpKVxuICAgICAgJCgnaW5wdXQ6Y2hlY2tib3guc2VsZWN0YWJsZScsIGV2ZW50LmRhdGEuY29udGFpbmVyKS5lYWNoKGZ1bmN0aW9uIChpbmRleCwgZWxlbWVudCkge1xuICAgICAgICB2YXIgdXVpZCA9ICQoZWxlbWVudCkucHJvcCgnY2hlY2tlZCcsIHRydWUpLmRhdGEoJ3V1aWQnKVxuICAgICAgICBzZWxlY3RlZE1lZXRpbmdDYXJkSGFzaFt1dWlkXSA9IHRydWVcbiAgICAgICAgaGFzU2VsZWN0ZWRNZWV0aW5ncyA9IHRydWVcbiAgICAgIH0pXG4gICAgfSBlbHNlIHtcbiAgICAgICQoJy5zZWxlY3RfYWxsX21lZXRpbmcnKS5odG1sKGkxOG4udCgnc2VsZWN0X2FsbCcpKVxuICAgICAgc2VsZWN0QWxsRmxhZyA9IGZhbHNlXG4gICAgICAkKCdpbnB1dDpjaGVja2JveC5zZWxlY3RhYmxlJywgZXZlbnQuZGF0YS5jb250YWluZXIpLnByb3AoJ2NoZWNrZWQnLCBmYWxzZSlcbiAgICAgIHNlbGVjdGVkTWVldGluZ0NhcmRIYXNoID0ge31cbiAgICAgIGhhc1NlbGVjdGVkTWVldGluZ3MgPSBmYWxzZVxuICAgIH1cbiAgICBzaG93SGlkZUJ1bGtBY3Rpb25CYXIoKVxuICB9XG4gIGZ1bmN0aW9uIGFkZFRvU2VsZWN0ZWRNZWV0aW5nQ2FyZEhhc2ggKG5ld0xpc3QpIHtcbiAgICBpZiAoc2VsZWN0QWxsRmxhZykge1xuICAgICAgXy5lYWNoKG5ld0xpc3QuZGF0YSwgZnVuY3Rpb24gKG1lZXRpbmcpIHtcbiAgICAgICAgc2VsZWN0ZWRNZWV0aW5nQ2FyZEhhc2hbbWVldGluZy51dWlkXSA9IHRydWVcbiAgICAgICAgaGFzU2VsZWN0ZWRNZWV0aW5ncyA9IHRydWVcbiAgICAgIH0pXG4gICAgfVxuICB9XG4gIGZ1bmN0aW9uIGNhcmRTZWxlY3Rpb25IYW5kbGVyICgpIHtcbiAgICB2YXIgdGhpc01lZXRpbmcgPSAkKHRoaXMpXG4gICAgdmFyIHV1aWQgPSB0aGlzTWVldGluZy5kYXRhKCd1dWlkJylcbiAgICBzZWxlY3RBbGxGbGFnID0gZmFsc2VcbiAgICAkKCcuc2VsZWN0X2FsbF9tZWV0aW5nJykuaHRtbChpMThuLnQoJ3NlbGVjdF9hbGwnKSlcbiAgICBpZiAodGhpc01lZXRpbmcuaXMoJzpjaGVja2VkJykpIHtcbiAgICAgIHNlbGVjdGVkTWVldGluZ0NhcmRIYXNoW3V1aWRdID0gdHJ1ZVxuICAgICAgaGFzU2VsZWN0ZWRNZWV0aW5ncyA9IHRydWVcbiAgICB9IGVsc2Uge1xuICAgICAgZGVsZXRlIHNlbGVjdGVkTWVldGluZ0NhcmRIYXNoW3V1aWRdXG4gICAgICBoYXNTZWxlY3RlZE1lZXRpbmdzID0gU3RvcmUuTWVldGluZ1N0b3JlLmdldEF2YWlsYWJsZVNlbGVjdGVkTWVldGluZ3Moc2VsZWN0ZWRNZWV0aW5nQ2FyZEhhc2gpLmxlbmd0aCA+IDBcbiAgICB9XG4gICAgc2hvd0hpZGVCdWxrQWN0aW9uQmFyKClcbiAgfVxuXG4gIGZ1bmN0aW9uIHNob3dIaWRlQnVsa0FjdGlvbkJhciAoKSB7XG4gICAgICAvLyBTaGFtZWVyOiBpZiBjb25kaXRpb24gd2lsbCBiZSByZW1vdmVkIG9uY2UgYnVsayBhY3Rpb24gY29tZXMgZm9yIGNvbnNlY3V0aXZlIG1lZXRpbmdcbiAgICBpZiAoTWVldGluZ1R5cGUgIT09ICdjb25zZWN1dGl2ZU1lZXRpbmdzJykge1xuICAgICAgYnVsa0FjdGlvbkJhcltoYXNTZWxlY3RlZE1lZXRpbmdzID8gJ3JlbW92ZUNsYXNzJyA6ICdhZGRDbGFzcyddKCdoaWRlJylcbiAgICB9XG4gIH1cblxuICBmdW5jdGlvbiBoYW5kbGVCdWxrQXBwcm92ZU1lZXRpbmdzIChldmVudCkge1xuICAgIGV2ZW50LnByZXZlbnREZWZhdWx0KClcbiAgICBldmVudC5zdG9wUHJvcGFnYXRpb24oKVxuXG4gICAgdmFyIGRvbmUgPSBmYWxzZVxuICAgIHZhciBzdG9yZSA9IFN0b3JlLk1lZXRpbmdTdG9yZVxuICAgIHZhciBtZWV0aW5nQ291bnQgPSBzZWxlY3RBbGxGbGFnID09PSB0cnVlID8gc3RvcmUuZ2V0VG90YWxNZWV0aW5nQ291bnQoKSA6IHN0b3JlLmdldEF2YWlsYWJsZVNlbGVjdGVkTWVldGluZ3Moc2VsZWN0ZWRNZWV0aW5nQ2FyZEhhc2gpLmxlbmd0aFxuICAgIHZhciBib2R5TWVzc2FnZSA9IGlzU3RhZmZFdmVudCA/IGkxOG4udCgnYnVsa19hY3Rpdml0eV9hcHByb3ZhbF9jb25maXJtX21lc3NhZ2UnLCB7IGNvdW50OiBtZWV0aW5nQ291bnQsIGRpc3BsYXlMYWJlbDogZGlzcGxheUxhYmVsRm9yQWdlbmRhLnRvTG9jYWxlTG93ZXJDYXNlKCkgfSkgOiBpMThuLnQoJ2J1bGtfYXBwcm92YWxfY29uZmlybV9tZXNzYWdlJylcblxuICAgIG5vdGlmaWNhdGlvbk1vZGFsLm5vdGlmaWNhdGlvbk1vZGFsKHtcbiAgICAgIHR5cGU6ICdjb25maXJtYXRpb24nLFxuICAgICAgY2xhc3M6ICdibHVlJyxcbiAgICAgIGJvZHk6IGJvZHlNZXNzYWdlLFxuICAgICAgdGl0bGU6IGkxOG4udCgnYnVsa19hcHByb3ZhbF9jb25maXJtX3RpdGxlJyksXG4gICAgICBkb25lOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgIGRvbmUgPSB0cnVlXG4gICAgICB9LFxuICAgICAgZGlzbWlzczogZnVuY3Rpb24gKCkge1xuICAgICAgICBkb25lICYmIEFjdGlvbnMuYnVsa0FwcHJvdmVNZWV0aW5ncyhzZWxlY3RlZE1lZXRpbmdDYXJkSGFzaCwgc2VsZWN0QWxsRmxhZylcbiAgICAgIH1cbiAgICB9KVxuICB9XG5cbiAgZnVuY3Rpb24gaGFuZGxlQnVsa1JlaW52aXRlVXNlcnMgKGV2ZW50KSB7XG4gICAgZXZlbnQuc3RvcFByb3BhZ2F0aW9uKClcbiAgICBldmVudC5wcmV2ZW50RGVmYXVsdCgpXG4gICAgdmFyIGRvbmUgPSBmYWxzZVxuICAgIG5vdGlmaWNhdGlvbk1vZGFsLm5vdGlmaWNhdGlvbk1vZGFsKHtcbiAgICAgIHR5cGU6ICdjb25maXJtYXRpb24nLFxuICAgICAgY2xhc3M6ICdibHVlJyxcbiAgICAgIGJvZHk6IGkxOG4udCgnYnVsa191c2VyX2ludml0ZV9jb25maXJtX21lc3NhZ2UnKSxcbiAgICAgIHRpdGxlOiBpMThuLnQoJ2J1bGtfdXNlcl9pbnZpdGVfY29uZmlybV90aXRsZScpLFxuICAgICAgZG9uZTogZnVuY3Rpb24gKCkge1xuICAgICAgICBkb25lID0gdHJ1ZVxuICAgICAgfSxcbiAgICAgIGRpc21pc3M6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgZG9uZSAmJiBBY3Rpb25zLmJ1bGtSZWludml0ZVVzZXJzKHNlbGVjdGVkTWVldGluZ0NhcmRIYXNoLCBzZWxlY3RBbGxGbGFnKVxuICAgICAgfVxuICAgIH0pXG4gIH1cblxuICBmdW5jdGlvbiBoYW5kbGVCdWxrQ2FuY2VsIChldmVudCkge1xuICAgIGV2ZW50LnByZXZlbnREZWZhdWx0KClcbiAgICBldmVudC5zdG9wUHJvcGFnYXRpb24oKVxuXG4gICAgdmFyIHRpdGxlTWVzc2FnZSA9IGkxOG4udCgnYnVsa19jYW5jZWxfY29uZmlybV90aXRsZScpXG4gICAgdmFyIHN0b3JlID0gU3RvcmUuTWVldGluZ1N0b3JlXG4gICAgdmFyIGNvdW50ID0gc2VsZWN0QWxsRmxhZyA9PT0gdHJ1ZSA/IHN0b3JlLmdldFRvdGFsTWVldGluZ0NvdW50KCkgOiBzdG9yZS5nZXRBdmFpbGFibGVTZWxlY3RlZE1lZXRpbmdzKHNlbGVjdGVkTWVldGluZ0NhcmRIYXNoKS5sZW5ndGhcbiAgICB2YXIgYm9keU1lc3NhZ2UgPSBpMThuLnQoJ2J1bGtfY2FuY2VsX2NvbmZpcm1fbWVzc2FnZScsIHsgY291bnQ6IGNvdW50LCBkaXNwbGF5TGFiZWw6IGRpc3BsYXlMYWJlbEZvckFnZW5kYS50b0xvY2FsZUxvd2VyQ2FzZSgpIH0pXG4gICAgdmFyIGRvbmUgPSBmYWxzZVxuXG4gICAgbm90aWZpY2F0aW9uTW9kYWwubm90aWZpY2F0aW9uTW9kYWwoe1xuICAgICAgdHlwZTogJ2NvbmZpcm1hdGlvbicsXG4gICAgICBjbGFzczogJ2JsdWUnLFxuICAgICAgYm9keTogYm9keU1lc3NhZ2UsXG4gICAgICB0aXRsZTogdGl0bGVNZXNzYWdlLFxuICAgICAgZG9uZTogZnVuY3Rpb24gKCkge1xuICAgICAgICBkb25lID0gdHJ1ZVxuICAgICAgfSxcbiAgICAgIGRpc21pc3M6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgZG9uZSAmJiBBY3Rpb25zLmJ1bGtDYW5jZWwoc2VsZWN0ZWRNZWV0aW5nQ2FyZEhhc2gsIHNlbGVjdEFsbEZsYWcpXG4gICAgICB9XG4gICAgfSlcbiAgfVxuXG4gIGZ1bmN0aW9uIG9uQnVsa0FwcHJvdmFsU3VjY2VzcyAoZGF0YSkge1xuICAgIGRhdGEgPSBkYXRhLmRhdGFcbiAgICB2YXIgYm9keVRpdGxlID0gaXNTdGFmZkV2ZW50ID8gaTE4bi50KCdidWxrX2FjdGl2aXR5X2FwcHJvdmFsX3N1Y2Nlc3NfdGl0bGUnKSA6IGkxOG4udCgnYnVsa19hcHByb3ZhbF9zdWNjZXNzX3RpdGxlJylcbiAgICB2YXIgYm9keU1lc3NhZ2UgPSBpc1N0YWZmRXZlbnQgPyBpMThuLnQoJ2J1bGtfYWN0aXZpdHlfYXBwcm92YWxfc3VjY2Vzc19tZXNzYWdlJywge2NvdW50OiBkYXRhLmFwcHJvdmVkTWVldGluZ0NvdW50LCBkaXNwbGF5TGFiZWw6IGRpc3BsYXlMYWJlbEZvckFnZW5kYS50b0xvY2FsZUxvd2VyQ2FzZSgpIH0pIDogaTE4bi50KCdidWxrX2FwcHJvdmFsX3N1Y2Nlc3NfbWVzc2FnZScpXG5cbiAgICBub3RpZmljYXRpb25Nb2RhbC5ub3RpZmljYXRpb25Nb2RhbCh7XG4gICAgICB0eXBlOiAnbm90aWZpY2F0aW9uJyxcbiAgICAgIGNsYXNzOiAnZ3JlZW4nLFxuICAgICAgdGl0bGU6IGJvZHlUaXRsZSxcbiAgICAgIGJvZHk6IGJvZHlNZXNzYWdlLFxuICAgICAgZGlzbWlzczogZnVuY3Rpb24gKCkge1xuICAgICAgICBjbGVhclNlbGVjdGVkTWVldGluZ0hhc2goZGF0YS50b0JlQXBwcm92ZWRNZWV0aW5ncylcbiAgICAgICAgcmVsb2FkTWVldGluZ0xpc3QoKVxuICAgICAgfVxuICAgIH0pXG4gIH1cblxuICBmdW5jdGlvbiBvbkJ1bGtDYW5jZWxTdWNjZXNzIChkYXRhKSB7XG4gICAgZGF0YSA9IGRhdGEuZGF0YVxuICAgIHZhciBib2R5VGl0bGUgPSBpMThuLnQoJ2J1bGtfY2FuY2VsX3N1Y2Nlc3NfdGl0bGUnKVxuICAgIHZhciBib2R5TWVzc2FnZSA9IGkxOG4udCgnYnVsa19jYW5jZWxfc3VjY2Vzc19tZXNzYWdlJywge2NvdW50OiBkYXRhLmNhbmNlbGxlZE1lZXRpbmdDb3VudCwgZGlzcGxheUxhYmVsOiBkaXNwbGF5TGFiZWxGb3JBZ2VuZGEudG9Mb2NhbGVMb3dlckNhc2UoKSB9KVxuXG4gICAgbm90aWZpY2F0aW9uTW9kYWwubm90aWZpY2F0aW9uTW9kYWwoe1xuICAgICAgdHlwZTogJ25vdGlmaWNhdGlvbicsXG4gICAgICBjbGFzczogJ2dyZWVuJyxcbiAgICAgIHRpdGxlOiBib2R5VGl0bGUsXG4gICAgICBib2R5OiBib2R5TWVzc2FnZSxcbiAgICAgIGRpc21pc3M6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgY2xlYXJTZWxlY3RlZE1lZXRpbmdIYXNoKGRhdGEudG9CZUNhbmNlbGxlZE1lZXRpbmdzKVxuICAgICAgICByZWxvYWRNZWV0aW5nTGlzdCgpXG4gICAgICB9XG4gICAgfSlcbiAgfVxuXG4gIGZ1bmN0aW9uIG9uQnVsa1JlaW52aXRlVXNlclN1Y2Nlc3MgKGRhdGEpIHtcbiAgICBub3RpZmljYXRpb25Nb2RhbC5ub3RpZmljYXRpb25Nb2RhbCh7XG4gICAgICB0eXBlOiAnbm90aWZpY2F0aW9uJyxcbiAgICAgIGNsYXNzOiAnZ3JlZW4nLFxuICAgICAgdGl0bGU6IGkxOG4udCgnYnVsa19pbnZpdGVfdXNlcnNfc3VjY2Vzc190aXRsZScpLFxuICAgICAgYm9keTogaTE4bi50KCdidWxrX2ludml0ZV91c2Vyc19zdWNjZXNzX21lc3NhZ2UnKSxcbiAgICAgIGRpc21pc3M6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgY2xlYXJTZWxlY3RlZE1lZXRpbmdIYXNoKE9iamVjdC5rZXlzKHNlbGVjdGVkTWVldGluZ0NhcmRIYXNoKSlcbiAgICAgICAgcmVsb2FkTWVldGluZ0xpc3QoKVxuICAgICAgfVxuICAgIH0pXG4gIH1cblxuICBmdW5jdGlvbiBvbkJ1bGtBcHByb3ZhbEZhaWx1cmUgKGRhdGEpIHtcbiAgICB2YXIgZW50aXR5TGFiZWwgPSBpc1N0YWZmRXZlbnQgPT09IHRydWUgPyBkaXNwbGF5TGFiZWxGb3JBZ2VuZGEudG9Mb2NhbGVMb3dlckNhc2UoKSA6ICdtZWV0aW5nJ1xuXG4gICAgbm90aWZpY2F0aW9uTW9kYWwubm90aWZpY2F0aW9uTW9kYWwoe1xuICAgICAgdHlwZTogJ25vdGlmaWNhdGlvbicsXG4gICAgICBjbGFzczogJ3JlZCcsXG4gICAgICB0aXRsZTogaTE4bi50KCdidWxrX2FwcHJvdmFsX2ZhaWx1cmVfdGl0bGUnKSxcbiAgICAgIGJvZHk6IGkxOG4udCgnYnVsa19hcHByb3ZhbF9mYWlsdXJlX21lc3NhZ2UnLCB7IGVudGl0eUxhYmVsOiBlbnRpdHlMYWJlbCB9KVxuICAgIH0pXG4gIH1cblxuICBmdW5jdGlvbiBvbkJ1bGtDYW5jZWxGYWlsdXJlIChkYXRhKSB7XG4gICAgbm90aWZpY2F0aW9uTW9kYWwubm90aWZpY2F0aW9uTW9kYWwoe1xuICAgICAgdHlwZTogJ25vdGlmaWNhdGlvbicsXG4gICAgICBjbGFzczogJ3JlZCcsXG4gICAgICB0aXRsZTogaTE4bi50KCdidWxrX2NhbmNlbF9mYWlsdXJlX3RpdGxlJyksXG4gICAgICBib2R5OiBpMThuLnQoJ2J1bGtfY2FuY2VsX2ZhaWx1cmVfbWVzc2FnZScsIHsgZW50aXR5TGFiZWw6IGRpc3BsYXlMYWJlbEZvckFnZW5kYS50b0xvY2FsZUxvd2VyQ2FzZSgpIH0pXG4gICAgfSlcbiAgfVxuXG4gIGZ1bmN0aW9uIGNsZWFyU2VsZWN0ZWRNZWV0aW5nSGFzaCAoYXBwcm92ZWRNZWV0aW5ncykge1xuICAgIGFwcHJvdmVkTWVldGluZ3MuZm9yRWFjaChmdW5jdGlvbiAobWVldGluZ1V1aWQpIHtcbiAgICAgIGRlbGV0ZSBzZWxlY3RlZE1lZXRpbmdDYXJkSGFzaFttZWV0aW5nVXVpZF1cbiAgICB9KVxuICAgIHNlbGVjdEFsbEZsYWcgPSBmYWxzZVxuICAgIGhhc1NlbGVjdGVkTWVldGluZ3MgPSBTdG9yZS5NZWV0aW5nU3RvcmUuZ2V0QXZhaWxhYmxlU2VsZWN0ZWRNZWV0aW5ncyhzZWxlY3RlZE1lZXRpbmdDYXJkSGFzaCkubGVuZ3RoID4gMFxuICAgIHNob3dIaWRlQnVsa0FjdGlvbkJhcigpXG4gIH1cblxuICBmdW5jdGlvbiByZWxvYWRNZWV0aW5nTGlzdCAoKSB7XG4gICAgd2luZG93LnNjcm9sbFRvKDAsIDApXG4gICAgc2VsZWN0QWxsRmxhZyA9IGZhbHNlXG4gICAgJCgnLnNlbGVjdF9hbGxfbWVldGluZycpLmh0bWwoaTE4bi50KCdzZWxlY3RfYWxsJykpXG4gICAgU3RvcmUuTWVldGluZ1N0b3JlLnNldEN1cnJlbnRQYWdlKDEpXG4gICAgU3RvcmUuTWVldGluZ1N0b3JlLnJlc2V0TWVldGluZ0xpc3QoKVxuICAgIEFjdGlvbnMuZmV0Y2hNZWV0aW5ncygxKVxuICB9XG5cbiAgZnVuY3Rpb24gaGFuZGxlSW50ZXJuYWxUYWJDbGljayAoZXZlbnQpIHtcbiAgICBldmVudC5wcmV2ZW50RGVmYXVsdCgpXG4gICAgZXZlbnQuc3RvcFByb3BhZ2F0aW9uKClcbiAgICBcbiAgICBpZiAodHlwZW9mIGppZmZsZSAhPT0gJ3VuZGVmaW5lZCcpIHtcbiAgICAgIHZhciBzZWFyY2ggPSB3aW5kb3cubG9jYXRpb24uc2VhcmNoXG4gICAgICBuZXdQYWdlID0gQXBpLkVORFBPSU5UUy5hcGV4X2pubWVldGluZ3MgKyBzZWFyY2hcbiAgICAgIHdpbmRvdy5jb21tb25zLnJlZGlyZWN0UGFnZShuZXdQYWdlKVxuICAgIH1cbiAgICBlbHNlIFxuICAgICAgd2luZG93LmNvbW1vbnMucmVkaXJlY3RQYWdlKGVudkRldGFpbHMudXJsUHJlZml4ICsgJy9tZWV0aW5nX2xpc3QnKVxuICB9XG5cbiAgZnVuY3Rpb24gaGFuZGxlRXh0ZXJuYWxUYWJDbGljayAoZXZlbnQpIHtcbiAgICBldmVudC5wcmV2ZW50RGVmYXVsdCgpXG4gICAgZXZlbnQuc3RvcFByb3BhZ2F0aW9uKClcbiAgICB3aW5kb3cuY29tbW9ucy5yZWRpcmVjdFBhZ2UoZW52RGV0YWlscy51cmxQcmVmaXggKyAnL2V4dGVybmFsX3JlcXVlc3RzJylcbiAgfVxuXG4gIGZ1bmN0aW9uIGhhbmRsZVNlc3Npb25UYWJDbGljayAoZXZlbnQpIHtcbiAgICBldmVudC5wcmV2ZW50RGVmYXVsdCgpXG4gICAgZXZlbnQuc3RvcFByb3BhZ2F0aW9uKClcblxuICAgIGlmICh0eXBlb2YgamlmZmxlICE9PSAndW5kZWZpbmVkJykge1xuICAgICAgdmFyIHNlYXJjaCA9IHdpbmRvdy5sb2NhdGlvbi5zZWFyY2hcbiAgICAgIHZhciBldmVudE5hbWUgPSBuZXcgUmVnRXhwKCdbXFw/Jl1ldmVudE5hbWU9KFteJiNdKiknKS5leGVjKHNlYXJjaClcbiAgICAgIGV2ZW50TmFtZSA9IGV2ZW50TmFtZSA/IGV2ZW50TmFtZVsxXSA6ICcnXG4gICAgICBuZXdQYWdlID0gQXBpLkVORFBPSU5UUy5hcGV4X2puc2Vzc2lvbnMgKyBcIj9ldmVudE5hbWU9XCIrZXZlbnROYW1lXG4gICAgICB3aW5kb3cuY29tbW9ucy5yZWRpcmVjdFBhZ2UobmV3UGFnZSlcbiAgICB9XG4gICAgZWxzZSBcbiAgICAgIHdpbmRvdy5jb21tb25zLnJlZGlyZWN0UGFnZShlbnZEZXRhaWxzLnVybFByZWZpeCArICcvc2Vzc2lvbl9saXN0JylcbiAgfVxuXG4gIGZ1bmN0aW9uIGhhbmRsZUNvbnNlY3V0aXZlVGFiQ2xpY2sgKGV2ZW50KSB7XG4gICAgZXZlbnQucHJldmVudERlZmF1bHQoKVxuICAgIGV2ZW50LnN0b3BQcm9wYWdhdGlvbigpXG4gICAgd2luZG93LmNvbW1vbnMucmVkaXJlY3RQYWdlKGVudkRldGFpbHMudXJsUHJlZml4ICsgQXBpLkVORFBPSU5UUy5jb25zZWN1dGl2ZV9saXN0X3BhZ2UpXG4gIH1cblxuICBmdW5jdGlvbiBoYW5kbGVDaGVja2luQ2xpY2sgKGV2ZW50KSB7XG4gICAgZXZlbnQucHJldmVudERlZmF1bHQoKVxuICAgIGV2ZW50LnN0b3BQcm9wYWdhdGlvbigpXG4gICAgdmFyIGNoZWNraW5VcmwgPSBtZWV0aW5nVHlwZUhhc2hbTWVldGluZ1R5cGVdLmNoZWNraW5VcmxcbiAgICB3aW5kb3cuY29tbW9ucy5yZWRpcmVjdFBhZ2UoZW52RGV0YWlscy51cmxQcmVmaXggKyBjaGVja2luVXJsKVxuICB9XG5cbiAgZnVuY3Rpb24gc2V0dXBMaXN0ZW5lcnMgKCkge1xuICAgIGF0dGFjaENvbW1vblVJTGlzdGVuZXJlcygpXG5cbiAgICBidWxrQWN0aW9uQmFyLm9uKCdjbGljaycsICcjanMtYnVsay1zdXJ2ZXktbWFpbCcsIHNob3dTdXJ2ZXlQb3B1cClcbiAgICBleHBvcnRCdG4ub24oJ2NsaWNrJywgZXhwb3J0TWVldGluZ3MpXG4gICAgJChkb2N1bWVudCkub24oJ2NsaWNrJywgJyNqcy10cmlnZ2VyLXNlcnZleS1tYWlsJywgaGFuZGxlU2VydmV5TWFpbHMpXG4gICAgbWVldGluZ0xpc3RDb250YWluZXIub24oJ2NsaWNrJywgJy5qcy1zdXJ2ZXktaWNvbicsIHNob3dTdXJ2ZXlQb3B1cClcbiAgICBzZWxlY3RBY3Rpdml0eU1vZGFsLm9uKCdjbGljaycsICcuanMtZW5hYmxlZC1tZWV0aW5nLXR5cGVzJywgc2VsZWN0TWVldGluZ0FjdGl2aXR5KVxuXG4gICAgaW50ZXJuYWxDb3VudFRhYi5vbignY2xpY2snLCBoYW5kbGVJbnRlcm5hbFRhYkNsaWNrKVxuICAgIG1vYmlsZUludGVybmFsQ291bnRUYWIub24oJ2NsaWNrJywgaGFuZGxlSW50ZXJuYWxUYWJDbGljaylcbiAgICBleHRlcm5hbENvdW50VGFiLm9uKCdjbGljaycsIGhhbmRsZUV4dGVybmFsVGFiQ2xpY2spXG4gICAgbW9iaWxlRXh0ZXJuYWxDb3VudFRhYi5vbignY2xpY2snLCBoYW5kbGVFeHRlcm5hbFRhYkNsaWNrKVxuICAgIHNlc3Npb25Db3VudFRhYi5vbignY2xpY2snLCBoYW5kbGVTZXNzaW9uVGFiQ2xpY2spXG4gICAgY29uc2VjdXRpdmVNZWV0aW5nVGFiLm9uKCdjbGljaycsIGhhbmRsZUNvbnNlY3V0aXZlVGFiQ2xpY2spXG4gICAgbW9iaWxlQ29uc2VjdXRpdmVDb3VudFRhYi5vbignY2xpY2snLCBoYW5kbGVDb25zZWN1dGl2ZVRhYkNsaWNrKVxuICAgIG1vYmlsZVNlc3Npb25Db3VudFRhYi5vbignY2xpY2snLCBoYW5kbGVTZXNzaW9uVGFiQ2xpY2spXG4gICAgbW9iaWxlVGFiQ2hlY2tpbi5vbignY2xpY2snLCBoYW5kbGVDaGVja2luQ2xpY2spXG5cbiAgICAkKG1lZXRpbmdMaXN0Q29udGFpbmVyKVxuICAgICAgICAub24oJ2NoYW5nZScsICdpbnB1dFtuYW1lPVwibWVldGluZ0NhcmRcIl0nLCBjYXJkU2VsZWN0aW9uSGFuZGxlcilcbiAgICAgICAgLm9uKCdjbGljaycsICcubWVldGluZ1JldmVhbENscycsIGZ1bmN0aW9uIChlKSB7XG4gICAgICAgICAgZS5wcmV2ZW50RGVmYXVsdCgpXG4gICAgICAgICAgZS5zdG9wUHJvcGFnYXRpb24oKVxuICAgICAgICAgIHZhciBicmllZmluZ1N0ciA9ICcnXG4gICAgICAgICAgdmFyIHV1aWQgPSAkKHRoaXMpLmRhdGEoJ3V1aWQnKVxuICAgICAgICAgIHZhciBtZWV0aW5nID0gU3RvcmUuTWVldGluZ1N0b3JlLmdldE1lZXRpbmcodXVpZClcbiAgICAgICAgICB2YXIgdXJsID0gJydcbiAgICAgICAgICBpZiAobWVldGluZy5icmllZmluZ191dWlkKSB7XG4gICAgICAgICAgICBicmllZmluZ1N0ciA9ICc/YnJpZWZpbmdfdXVpZD0nICsgbWVldGluZy5icmllZmluZ191dWlkXG4gICAgICAgICAgfVxuICAgICAgICAgIHZhciBlZGl0TWVldGluZ1VybCA9IEFwaS5FTkRQT0lOVFMubWVldGluZ19yZXF1ZXN0X2VkaXRfcGF0aFxuICAgICAgICAgIHZhciB2aWV3TWVldGluZ1VybCA9IEFwaS5FTkRQT0lOVFMubWVldGluZ19yZXF1ZXN0X3ZpZXdfcGF0aFxuICAgICAgICAgIGlmIChtZWV0aW5nLnR5cGUgPT09ICdDb25zZWN1dGl2ZU1lZXRpbmcnKSB7XG4gICAgICAgICAgICBlZGl0TWVldGluZ1VybCA9IEFwaS5FTkRQT0lOVFMuY29uc2VjdXRpdmVfbWVldGluZ3NfZWRpdF9wYXRoXG4gICAgICAgICAgICB2aWV3TWVldGluZ1VybCA9IEFwaS5FTkRQT0lOVFMuY29uc2VjdXRpdmVfbWVldGluZ3Nfdmlld19wYXRoXG4gICAgICAgICAgfVxuICAgICAgICAgIGlmIChtZWV0aW5nLmVkaXQgJiYgbWVldGluZy5zdGF0dXMgIT09ICdjYW5jZWxsZWQnKSB7XG4gICAgICAgICAgICB1cmwgPSBlbnZEZXRhaWxzLnVybFByZWZpeCArIGVkaXRNZWV0aW5nVXJsLnJlcGxhY2UoJ3t1dWlkfScsIHV1aWQpICsgYnJpZWZpbmdTdHJcbiAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgdXJsID0gZW52RGV0YWlscy51cmxQcmVmaXggKyB2aWV3TWVldGluZ1VybC5yZXBsYWNlKCd7dXVpZH0nLCB1dWlkKSArIGJyaWVmaW5nU3RyXG4gICAgICAgICAgfVxuXG4gICAgICAgICAgaWYgKHR5cGVvZiBqaWZmbGUgIT09ICd1bmRlZmluZWQnKSB7XG4gICAgICAgICAgICB2YXIgbW9kZVEgPSAnJm1vZGU9ZWRpdCdcbiAgICAgICAgICAgIHZhciBtZWV0aW5nUSA9ICcmbWVldGluZz0nICsgdXVpZFxuICAgICAgICAgICAgdmFyIHF1ZXJ5ID0gd2luZG93LmxvY2F0aW9uLnNlYXJjaFxuXG4gICAgICAgICAgICB2YXIgYWNjaWRJblVybCA9IG5ldyBSZWdFeHAoJ1tcXD8mXWFjY2lkPShbXiYjXSopJykuZXhlYyhxdWVyeSlcbiAgICAgICAgICAgIHZhciBvcHBvcnR1bml0eUlkSW5VcmwgPSBuZXcgUmVnRXhwKCdbXFw/Jl1vcHBpZD0oW14mI10qKScpLmV4ZWMocXVlcnkpXG4gICAgICAgICAgICB2YXIgbGVhZElkc0luVXJsID0gbmV3IFJlZ0V4cCgnW1xcPyZdbGVhZF9pZHM9KFteJiNdKiknKS5leGVjKHF1ZXJ5KVxuICAgICAgICAgICAgdmFyIHNvdXJjZUluVXJsID0gbmV3IFJlZ0V4cCgnW1xcPyZdc291cmNlPShbXiYjXSopJykuZXhlYyhxdWVyeSlcbiAgICAgICAgICAgIHZhciBzaG93QWN0aXZpdGllc0luVXJsID0gbmV3IFJlZ0V4cCgnW1xcPyZdc2hvd0FjdGl2aXRpZXM9KFteJiNdKiknKS5leGVjKHF1ZXJ5KVxuXG4gICAgICAgICAgICBpZiAoYWNjaWRJblVybCkgeyBxdWVyeSA9IHF1ZXJ5LnJlcGxhY2UoYWNjaWRJblVybFswXSwgJycpIH1cblxuICAgICAgICAgICAgaWYgKG9wcG9ydHVuaXR5SWRJblVybCkgeyBxdWVyeSA9IHF1ZXJ5LnJlcGxhY2Uob3Bwb3J0dW5pdHlJZEluVXJsWzBdLCAnJykgfVxuXG4gICAgICAgICAgICBpZiAobGVhZElkc0luVXJsKSB7IHF1ZXJ5ID0gcXVlcnkucmVwbGFjZShsZWFkSWRzSW5VcmxbMF0sICcnKSB9XG5cbiAgICAgICAgICAgIGlmIChzb3VyY2VJblVybCkgeyBxdWVyeSA9IHF1ZXJ5LnJlcGxhY2Uoc291cmNlSW5VcmxbMF0sICcnKSB9XG5cbiAgICAgICAgICAgIGlmIChzaG93QWN0aXZpdGllc0luVXJsKSB7IHF1ZXJ5ID0gcXVlcnkucmVwbGFjZShzaG93QWN0aXZpdGllc0luVXJsWzBdLCAnJykgfVxuXG4gICAgICAgICAgICBpZiAobWVldGluZy5lZGl0ICYmIG1lZXRpbmcuc3RhdHVzICE9PSAnY2FuY2VsbGVkJykge1xuICAgICAgICAgICAgICB1cmwgPSBBcGkuRU5EUE9JTlRTLmpuX2Jvb2tfbWVldGluZyArIHF1ZXJ5ICsgbWVldGluZ1EgKyBtb2RlUVxuICAgICAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAgICAgbW9kZVEgPSAnJm1vZGU9dmlldydcbiAgICAgICAgICAgICAgdXJsID0gQXBpLkVORFBPSU5UUy5qbl92aWV3X2Jvb2tfbWVldGluZyArIHF1ZXJ5ICsgbWVldGluZ1EgKyBtb2RlUVxuICAgICAgICAgICAgfVxuICAgICAgICAgIH1cbiAgICAgICAgICB3aW5kb3cuY29tbW9ucy5yZWRpcmVjdFBhZ2UodXJsKVxuICAgICAgICB9KVxuXG4gICAgJChtZWV0aW5nTGlzdENvbnRhaW5lcikub24oJ2NsaWNrJywgYm9va01lZXRpbmdCdG4uc2VsZWN0b3IsIGZ1bmN0aW9uIChlKSB7XG4gICAgICBlLnN0b3BQcm9wYWdhdGlvbigpXG4gICAgICBzaG93TWVldGluZ0FjdGl2aXRpZXMoKVxuICAgIH0pXG5cbiAgICAkKG1lZXRpbmdMaXN0Q29udGFpbmVyKS5vbignY2xpY2snLCAnLm1lZXRpbmctYWNjZXB0LCAubWVldGluZy1kZWNsaW5lJywgcG9zdE1lZXRpbmdBY3Rpb24pXG4gICAgICAub24oJ2NsaWNrJywgJy5tZWV0aW5nLWFwcHJvdmUnLCBwdXRNZWV0aW5nQWN0aW9uKVxuICAgICAgLm9uKCdjbGljaycsICcubWVldGluZy1hcHByb3ZlLWFsbCcsIGFwcHJvdmVBbGxNZWV0aW5nc0hhbmRsZXIpXG4gICAgICAub24oJ2NsaWNrJywgJy5tZWV0aW5nLWNhbmNlbC1hbGwnLCBjYW5jZWxBbGxNZWV0aW5nc0hhbmRsZXIpXG4gICAgICAub24oJ2NsaWNrJywgJy5tZWV0aW5nLWNhbmNlbCcsIGNhbmNlbE1lZXRpbmcpXG5cbiAgICAkKCcjdWktZGF0ZXBpY2tlci1kaXYnKS5vbignY2xpY2snLCBmdW5jdGlvbiAoZSkge1xuICAgICAgZS5zdG9wUHJvcGFnYXRpb24oKVxuICAgIH0pXG4gIH1cbiAgZnVuY3Rpb24gc2hvd01lZXRpbmdBY3Rpdml0aWVzICgpIHtcbiAgICBpZiAod2luZG93LmFjdGl2dGllc19hdHRyaWJ1dGVzLmxlbmd0aCA+IDEpIHtcbiAgICAgIHZhciB0ZW1wbGF0ZSA9IHJlcXVpcmUoJ1RlbXBsYXRlcy9tZWV0aW5nL21lZXRpbmctdHlwZS1saXN0JylcblxuICAgICAgbWVldGluZ0FjdGl2aXR5Q29udGFpbmVyLmh0bWwodGVtcGxhdGUoe1xuICAgICAgICBtZWV0aW5nVHlwZXM6IHdpbmRvdy5hY3RpdnRpZXNfYXR0cmlidXRlc1xuICAgICAgfSkpXG5cbiAgICAgIG1lZXRpbmdBY3Rpdml0eUNvbnRhaW5lci5hZGRDbGFzcygnanMtZW5hYmxlZC1tZWV0aW5nLXR5cGVzJylcbiAgICAgIHNlbGVjdEFjdGl2aXR5TW9kYWwub24oJ2hpZGRlbi5icy5tb2RhbCcsIGZ1bmN0aW9uICgpIHtcbiAgICAgICAgbWVldGluZ0FjdGl2aXR5Q29udGFpbmVyLnJlbW92ZUNsYXNzKCdqcy1lbmFibGVkLW1lZXRpbmctdHlwZXMnKVxuICAgICAgfSlcblxuICAgICAgc2VsZWN0QWN0aXZpdHlNb2RhbC5tb2RhbCh7XG4gICAgICAgIGJhY2tkcm9wOiBmYWxzZVxuICAgICAgfSlcbiAgICB9IGVsc2UgaWYgKHdpbmRvdy5hY3RpdnRpZXNfYXR0cmlidXRlcy5sZW5ndGggPT0gMSkge1xuICAgICAgdmFyIGJvb2tNZWV0aW5nUGF0aCA9IHdpbmRvdy5sb2NhdGlvbi5vcmlnaW4gKyBlbnZEZXRhaWxzLnVybFByZWZpeCArIGFjdGl2dGllc19hdHRyaWJ1dGVzWzBdWydyZWRpcmVjdF91cmwnXVxuICAgICAgaWYgKHR5cGVvZiBqaWZmbGUgIT09ICd1bmRlZmluZWQnKSB7XG5cbiAgICAgICAgYm9va01lZXRpbmdQYXRoID0gd2luZG93LmxvY2F0aW9uLm9yaWdpbiArICgoYWN0aXZ0aWVzX2F0dHJpYnV0ZXNbMF1bJ21lZXRpbmdfdHlwZV9tYXN0ZXJfbmFtZSddID09PSBUUkFDS1NfQU5EX1NFU1NJT05TX01BU1RFUl9OQU1FKSA/IEFwaS5FTkRQT0lOVFMuam5fYm9va19ub21pbmF0aW9uIDogQXBpLkVORFBPSU5UUy5qbl9ib29rX21lZXRpbmcpXG4gICAgICAgIGJvb2tNZWV0aW5nUGF0aCArPSAod2luZG93LmxvY2F0aW9uLnNlYXJjaClcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA/ICh3aW5kb3cubG9jYXRpb24uc2VhcmNoICsgJyZzb3VyY2U9JyArIGFjdGl2dGllc19hdHRyaWJ1dGVzWzBdWydzb3VyY2UnXSlcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDogJz9zb3VyY2U9JyArIGFjdGl2dGllc19hdHRyaWJ1dGVzWzBdWydzb3VyY2UnXVxuICAgICAgfVxuICAgICAgd2luZG93LmNvbW1vbnMucmVkaXJlY3RQYWdlKGJvb2tNZWV0aW5nUGF0aClcbiAgICB9IGVsc2Uge1xuICAgICAgbm90aWZpY2F0aW9uTW9kYWwubm90aWZpY2F0aW9uTW9kYWwoe1xuICAgICAgICBjbGFzczogJ3JlZCcsXG4gICAgICAgIHRpbWVvdXQ6IHRydWUsXG4gICAgICAgIGJvZHk6IGkxOG4udCgnbm9fbWVldGluZ190eXBlcycpLFxuICAgICAgICB0aXRsZTogaTE4bi50KCdpbmZvJylcbiAgICAgIH0pXG4gICAgfVxuICB9XG5cbiAgZnVuY3Rpb24gc2VsZWN0TWVldGluZ0FjdGl2aXR5IChlKSB7XG4gICAgZS5wcmV2ZW50RGVmYXVsdCgpXG4gICAgZS5zdG9wUHJvcGFnYXRpb24oKVxuXG4gICAgdmFyIG1lZXRpbmdUeXBlVXVpZCA9ICQoZS50YXJnZXQpLmNsb3Nlc3QoJy5hY3Rpdml0eScpLmF0dHIoJ2lkJylcblxuICAgIGlmICh0eXBlb2YgbWVldGluZ1R5cGVVdWlkICE9PSAndW5kZWZpbmVkJykge1xuICAgICAgc2VsZWN0QWN0aXZpdHlNb2RhbC5tb2RhbCgnaGlkZScpXG5cbiAgICAgIHZhciBjaG9zZW5BY3Rpdml0eSA9ICQoZS50YXJnZXQpLmNsb3Nlc3QoJy5hY3Rpdml0eScpXG4gICAgICB2YXIgYm9va01lZXRpbmdQYXRoID0gd2luZG93LmxvY2F0aW9uLm9yaWdpbiArIGVudkRldGFpbHMudXJsUHJlZml4ICsgY2hvc2VuQWN0aXZpdHkuZGF0YSgncmVkaXJlY3QtdXJsJylcbiAgICAgIGlmICh0eXBlb2YgamlmZmxlICE9PSAndW5kZWZpbmVkJykge1xuICAgICAgICB2YXIgbWVldGluZ1R5cGVVdWlkID0gY2hvc2VuQWN0aXZpdHkuYXR0cignaWQnKVxuXG4gICAgICAgIHZhciBtZWV0aW5nVHlwZU1hc3RlciA9IF8uZmluZChhY3RpdnRpZXNfYXR0cmlidXRlcywgZnVuY3Rpb24oYWN0aXZpdHkpe1xuICAgICAgICAgIGlmKGFjdGl2aXR5LnV1aWQgPT09IG1lZXRpbmdUeXBlVXVpZClcbiAgICAgICAgICAgIHJldHVybiB0cnVlXG4gICAgICAgIH0pLm1lZXRpbmdfdHlwZV9tYXN0ZXJfbmFtZTtcblxuICAgICAgICBib29rTWVldGluZ1BhdGggPSB3aW5kb3cubG9jYXRpb24ub3JpZ2luICsgXG4gICAgICAgICAgKChtZWV0aW5nVHlwZU1hc3RlciA9PT0gVFJBQ0tTX0FORF9TRVNTSU9OU19NQVNURVJfTkFNRSkgPyBBcGkuRU5EUE9JTlRTLmpuX2Jvb2tfbm9taW5hdGlvbiA6IEFwaS5FTkRQT0lOVFMuam5fYm9va19tZWV0aW5nKSBcbiAgICAgICAgdmFyIHVwZGF0ZWRTZWFyY2hQYXJhbXMgPSBwdXRTZWFyY2hRdWVyeVBhcmFtKHdpbmRvdy5sb2NhdGlvbi5zZWFyY2gsICdhY3Rpdml0eV91dWlkJywgbWVldGluZ1R5cGVVdWlkKVxuICAgICAgICB1cGRhdGVkU2VhcmNoUGFyYW1zID0gcHV0U2VhcmNoUXVlcnlQYXJhbSh1cGRhdGVkU2VhcmNoUGFyYW1zLCAnc291cmNlJywgJChlLnRhcmdldCkuY2xvc2VzdCgnLmFjdGl2aXR5JykuZGF0YSgnYWN0aXZpdHktc291cmNlJykpXG4gICAgICAgIGJvb2tNZWV0aW5nUGF0aCArPSB1cGRhdGVkU2VhcmNoUGFyYW1zXG4gICAgICB9XG4gICAgICB3aW5kb3cuY29tbW9ucy5yZWRpcmVjdFBhZ2UoYm9va01lZXRpbmdQYXRoKVxuICAgIH1cbiAgfVxuXG4gIGZ1bmN0aW9uIHB1dE1lZXRpbmdBY3Rpb24gKGUsIGFjdGlvblR5cGUpIHtcbiAgICBlLnN0b3BQcm9wYWdhdGlvbigpXG4gICAgZS5wcmV2ZW50RGVmYXVsdCgpXG4gICAgYWN0aW9uVHlwZSA9IGFjdGlvblR5cGUgfHwgJ3B1dCdcbiAgICB2YXIgdXJsID0gJCh0aGlzKS5kYXRhKCd1cmwnKVxuICAgIEFjdGlvbnMubWVldGluZ0FjdGlvbih1cmwsIGFjdGlvblR5cGUsICdhcHByb3ZlJylcbiAgfVxuXG4gIGZ1bmN0aW9uIGFwcHJvdmVBbGxNZWV0aW5nc0hhbmRsZXIgKGUpIHtcbiAgICBwdXRNZWV0aW5nQWN0aW9uLmNhbGwodGhpcywgZSwgJ3Bvc3QnKVxuICB9XG5cbiAgZnVuY3Rpb24gcG9zdE1lZXRpbmdBY3Rpb24gKGUpIHtcbiAgICBlLnN0b3BQcm9wYWdhdGlvbigpXG4gICAgZS5wcmV2ZW50RGVmYXVsdCgpXG5cbiAgICB2YXIgdXJsID0gJCh0aGlzKS5kYXRhKCd1cmwnKVxuICAgIEFjdGlvbnMubWVldGluZ0FjdGlvbih1cmwsICdwb3N0JylcbiAgfVxuXG4gIGZ1bmN0aW9uIGZldGNoTW9yZU1lZXRpbmdzICgpIHtcbiAgICBpZiAoU3RvcmUuTWVldGluZ1N0b3JlLmdldEN1cnJlbnRQYWdlKCkgPD0gU3RvcmUuTWVldGluZ1N0b3JlLmdldFRvdGFsUGFnZUNvdW50KCkpIHtcbiAgICAgIEFjdGlvbnMuZmV0Y2hNZWV0aW5ncyhTdG9yZS5NZWV0aW5nU3RvcmUuZ2V0Q3VycmVudFBhZ2UoKSlcbiAgICB9XG4gIH07XG5cbiAgZnVuY3Rpb24gaGFuZGxlRmlsdGVyQ2xpY2sgKGUpIHtcbiAgICBlLnByZXZlbnREZWZhdWx0KClcbiAgICBlLnN0b3BQcm9wYWdhdGlvbigpXG5cbiAgICBhcHBseUZpbHRlcigpXG5cbiAgICAgIC8vIGZvciBtb2JpbGVcbiAgICAkKCcjbWVldGlnX3ZpZXdfbmF2LmluJykuY29sbGFwc2UoJ2hpZGUnKVxuXG4gICAgZmlsdGVyLnRvZ2dsZUNsYXNzKCdzaG93JylcbiAgfVxuXG4gIGZ1bmN0aW9uIGFwcGx5RmlsdGVyICgpIHtcbiAgICBnbG9iYWxTZWFyY2gudmFsKGZpbHRlclNlYXJjaEZpZWxkLnZhbCgpKVxuICAgIHZhciBjbHViYmVkRmlsdGVyRGF0YSA9IG1lZXRpbmdGaWx0ZXJDbXAuZ2V0Q2x1YmJlZEZpbHRlckRhdGEoZmlsdGVyUGFuZWwpXG4gICAgQWN0aW9ucy51cGRhdGVGaWx0ZXIoY2x1YmJlZEZpbHRlckRhdGEuZm9ybURhdGEsIGNsdWJiZWRGaWx0ZXJEYXRhLnN0b3JhYmxlRmlsdGVyRGF0YSlcbiAgICBzaG93U2VsZWN0ZWRGaWx0ZXIoY2x1YmJlZEZpbHRlckRhdGEuc2VsZWN0ZWRGaWx0ZXJEYXRhKVxuICB9XG5cbiAgZnVuY3Rpb24gc2hvd1NlbGVjdGVkRmlsdGVyIChkYXRhKSB7XG4gICAgdmFyIGh0bWwgPSByZXF1aXJlKCdUZW1wbGF0ZXMvcmVwb3J0L29uZGVtYW5kL3NlbGVjdGVkX2ZpbHRlcicpKHsgZmlsdGVyOiBkYXRhIH0pXG4gICAgYXBwbGllZEZpbHRlcnNDb250YWluZXIuaHRtbChodG1sKVxuICB9O1xuXG4gIGZ1bmN0aW9uIHJlbW92ZVNlbGVjdGVkRmlsdGVyIChlKSB7XG4gICAgdmFyIGN1cnJlbnRFbCA9ICQodGhpcylcbiAgICB2YXIgZmlsdGVyVmFsdWUgPSAnJyArIGN1cnJlbnRFbC5jbG9zZXN0KCcuc2VsZWN0ZWQtaXRlbScpLmRhdGEoJ2tleScpXG4gICAgdmFyIGZpbHRlcktleSA9IGN1cnJlbnRFbC5jbG9zZXN0KCcuZmlsdGVyJykuZGF0YSgndHlwZScpXG4gICAgdmFyIHNlbGVjdGVkU3RvcmVGaWx0ZXIgPSBTdG9yZS5NZWV0aW5nU3RvcmUuZmlsdGVyc1tmaWx0ZXJLZXldXG4gICAgdmFyIHN0b3JlZEZpbHRlcnMgPSBTdG9yZS5NZWV0aW5nU3RvcmUuc3RvcmVkRmlsdGVyRGF0YVtmaWx0ZXJLZXldXG4gICAgdmFyIHNlbGVjdGVkQ2hvc2VuID0gZmlsdGVyUGFuZWwuZmluZCgnLnNlbGVjdC4nICsgZmlsdGVyS2V5KVxuICAgIHNlbGVjdEFsbEZsYWcgPSBmYWxzZVxuICAgICQoJy5zZWxlY3RfYWxsX21lZXRpbmcnKS5odG1sKGkxOG4udCgnc2VsZWN0X2FsbCcpKVxuICAgIHNlbGVjdGVkU3RvcmVGaWx0ZXIuc3BsaWNlKCQuaW5BcnJheShmaWx0ZXJWYWx1ZSwgc2VsZWN0ZWRTdG9yZUZpbHRlciksIDEpXG4gICAgc3RvcmVkRmlsdGVycy5zcGxpY2UoXy5maW5kSW5kZXgoc3RvcmVkRmlsdGVycywgZnVuY3Rpb24gKGZpbHRlcikge1xuICAgICAgcmV0dXJuIGZpbHRlci52YWx1ZSA9PT0gZmlsdGVyVmFsdWVcbiAgICB9KSwgMSlcbiAgICBpZiAoc3RvcmVkRmlsdGVycy5sZW5ndGggPT0gMCkge1xuICAgICAgZGVsZXRlIFN0b3JlLk1lZXRpbmdTdG9yZS5zdG9yZWRGaWx0ZXJEYXRhW2ZpbHRlcktleV1cbiAgICB9XG4gICAgc2VsZWN0ZWRDaG9zZW4uZmluZCgnb3B0aW9uOnNlbGVjdGVkJykuZWFjaChmdW5jdGlvbiAoaSwgZWxlbWVudCkge1xuICAgICAgdmFyIEVsID0gJChlbGVtZW50KVxuICAgICAgaWYgKEVsLnZhbCgpID09IGZpbHRlclZhbHVlKSB7XG4gICAgICAgIEVsLmF0dHIoJ3NlbGVjdGVkJywgZmFsc2UpXG4gICAgICB9XG4gICAgfSkudHJpZ2dlcignY2hhbmdlJylcblxuICAgIGN1cnJlbnRFbC5jbG9zZXN0KCcuZmlsdGVyJykucmVtb3ZlKClcbiAgICBBY3Rpb25zLnVwZGF0ZUZpbHRlcihTdG9yZS5NZWV0aW5nU3RvcmUuZmlsdGVycywgU3RvcmUuTWVldGluZ1N0b3JlLnN0b3JlZEZpbHRlckRhdGEpXG4gIH07XG5cbiAgZnVuY3Rpb24gcmVzZXRGaWx0ZXIgKGUpIHtcbiAgICBlLnN0b3BQcm9wYWdhdGlvbigpXG4gICAgQWN0aW9ucy5yZXNldEZpbHRlcigpXG4gICAgZmlsdGVyU2VhcmNoRmllbGQudmFsKCcnKVxuICAgIGdsb2JhbFNlYXJjaC52YWwoJycpXG4gICAgc2hvd1NlbGVjdGVkRmlsdGVyKHt9KVxuICAgIGZpbHRlclBhbmVsLmZpbmQoJ3NlbGVjdCcpLmVhY2goZnVuY3Rpb24gKGksIGVsZSkge1xuICAgICAgJChlbGUpLnZhbChbXSkudHJpZ2dlcignY2hhbmdlJylcbiAgICB9KVxuICB9O1xuXG4gIGZ1bmN0aW9uIGNhbmNlbE1lZXRpbmcgKGUsIGFjdGlvblR5cGUpIHtcbiAgICBlLnN0b3BQcm9wYWdhdGlvbigpXG4gICAgZS5wcmV2ZW50RGVmYXVsdCgpXG4gICAgYWN0aW9uVHlwZSA9IGFjdGlvblR5cGUgfHwgJ3B1dCdcbiAgICB2YXIgdXJsID0gJCh0aGlzKS5kYXRhKCd1cmwnKVxuXG4gICAgbm90aWZpY2F0aW9uTW9kYWwubm90aWZpY2F0aW9uTW9kYWwoe1xuICAgICAgdHlwZTogJ2NvbmZpcm1hdGlvbicsXG4gICAgICB0aXRsZTogaTE4bi50KCdjYW5jZWxfbWVldGluZ190aXRsZScpLFxuICAgICAgYm9keTogaTE4bi50KCdjYW5jZWxfbWVldGluZ19jb25maXJtYXRpb24nKSxcbiAgICAgIGNsYXNzOiAnYmx1ZScsXG4gICAgICBkb25lOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgIEFjdGlvbnMubWVldGluZ0FjdGlvbih1cmwsIGFjdGlvblR5cGUpXG4gICAgICB9XG4gICAgfSlcbiAgfTtcblxuICBmdW5jdGlvbiBjYW5jZWxBbGxNZWV0aW5nc0hhbmRsZXIgKGUpIHtcbiAgICBjYW5jZWxNZWV0aW5nLmNhbGwodGhpcywgZSwgJ3Bvc3QnKVxuICB9XG5cbiAgZnVuY3Rpb24gc2VhcmNoTWVldGluZ3MgKCkge1xuICAgIHZhciBzZWFyY2hWYWx1ZSA9IGdsb2JhbFNlYXJjaC52YWwoKVxuICAgICQoJy5zZWxlY3RfYWxsX21lZXRpbmcnKS5odG1sKGkxOG4udCgnc2VsZWN0X2FsbCcpKVxuICAgIHNlbGVjdEFsbEZsYWcgPSBmYWxzZVxuICAgIGZpbHRlclNlYXJjaEZpZWxkLnZhbChzZWFyY2hWYWx1ZSlcbiAgICBBY3Rpb25zLnNlYXJjaE1lZXRpbmdzKHNlYXJjaFZhbHVlKVxuICB9O1xuXG4gIGZ1bmN0aW9uIHVwZGF0ZVNlYXJjaCAoKSB7XG4gICAgdmFyIHNlYXJjaFZhbHVlID0gZmlsdGVyU2VhcmNoRmllbGQudmFsKClcbiAgICBBY3Rpb25zLnVwZGF0ZVNlYXJjaChzZWFyY2hWYWx1ZSlcbiAgfTtcblxuICBmdW5jdGlvbiBleHBvcnRNZWV0aW5ncyAoZSkge1xuICAgIGUucHJldmVudERlZmF1bHQoKVxuICAgIGUuc3RvcFByb3BhZ2F0aW9uKClcbiAgICB3aW5kb3cuY29tbW9ucy5yZWRpcmVjdFBhZ2UoU3RvcmUuTWVldGluZ1N0b3JlLmdlbmVyYXRlRXhwb3J0VXJsKGV4cG9ydEJ0bi5kYXRhKCdyZXZpZXcnKSkpXG4gIH1cblxuICBmdW5jdGlvbiBzaG93U3VydmV5UG9wdXAgKGUpIHtcbiAgICBlLnByZXZlbnREZWZhdWx0KClcbiAgICBlLnN0b3BQcm9wYWdhdGlvbigpXG4gICAgdmFyIHV1aWQsIG1lZXRpbmdcbiAgICB2YXIgaXNCdWxrU3VydmV5ID0gJChlLnRhcmdldCkuY2xvc2VzdCgnLmJ1bGstYWN0aW9uJykubGVuZ3RoXG4gICAgdmFyIHRlbXBsYXRlID0gcmVxdWlyZSgnVGVtcGxhdGVzL21lZXRpbmcvbWVldGluZy1zZXJ2ZXktaXRlbScpXG4gICAgaWYgKGlzQnVsa1N1cnZleSkge1xuICAgICAgbWVldGluZyA9IFN0b3JlLk1lZXRpbmdTdG9yZS5idWxrX3N1cnZleVxuICAgICAgdXVpZCA9ICcnXG4gICAgfSBlbHNlIHtcbiAgICAgIHV1aWQgPSAkKHRoaXMpLmNsb3Nlc3QoJy5tZWV0aW5nLWNhcmQnKS5kYXRhKCd1dWlkJylcbiAgICAgIG1lZXRpbmcgPSBTdG9yZS5NZWV0aW5nU3RvcmUuZ2V0TWVldGluZyh1dWlkKVxuICAgICAgc3VydmV5U2VsZWN0ZWRNZWV0aW5nID0gbWVldGluZ1xuICAgIH1cblxuICAgIF8uZm9yRWFjaChtZWV0aW5nLnN1cnZleV9saW5rcywgZnVuY3Rpb24gKGxpbmspIHtcbiAgICAgIGxpbmtbJ3Nob3dfc3VydmV5J10gPSBfLmNvbnRhaW5zKGxpbmsudXNlcl9hY2Nlc3MsIHdpbmRvdy5lbnZEZXRhaWxzLnJvbGUpXG4gICAgfSlcbiAgICBzdXJ2ZXlNb2RhbEVsLmZpbmQoJyNtZWV0aW5nLXNlcnZleS1jb250YWluZXInKS5odG1sKHRlbXBsYXRlKHsgc3VydmV5czogbWVldGluZy5zdXJ2ZXlfbGlua3MgfSkpXG4gICAgc3VydmV5TW9kYWxFbC5maW5kKCcjanMtdHJpZ2dlci1zZXJ2ZXktbWFpbCcpWyhtZWV0aW5nLnNob3dfc2VuZF9tYWlsIHx8IGlzQnVsa1N1cnZleSkgPyAnc2hvdycgOiAnaGlkZSddKClcbiAgICBzdXJ2ZXlNb2RhbEVsLm1vZGFsKCdzaG93JykuZGF0YSgndXVpZCcsIHV1aWQpXG4gIH07XG5cbiAgZnVuY3Rpb24gaGFuZGxlU2VydmV5TWFpbHMgKGUpIHtcbiAgICB2YXIgdXVpZHMgPSBbXVxuICAgIHZhciBtb2RhbEVsID0gJCh0aGlzKS5jbG9zZXN0KCcuanMtbWVldGluZy1zdXJ2ZXktbW9kYWwnKVxuICAgIHZhciBtZWV0aW5nSW5mbyA9IG1vZGFsRWwuZGF0YSgndXVpZCcpID8gbW9kYWxFbC5kYXRhKCd1dWlkJykgOiBzZWxlY3RlZE1lZXRpbmdDYXJkSGFzaFxuXG4gICAgbW9kYWxFbC5maW5kKCcuanMtbWVldGluZy1zZXJ2ZXktaXRlbScpLmVhY2goZnVuY3Rpb24gKGksIGVsZW1lbnQpIHtcbiAgICAgIHZhciB0ZW1wX3V1aWQgPSAkKGVsZW1lbnQpLmRhdGEoJ3V1aWQnKVxuICAgICAgaWYgKCQoJyNzdXJ2ZXktJyArIHRlbXBfdXVpZCkuaXMoJzpjaGVja2VkJykpIHtcbiAgICAgICAgdXVpZHMucHVzaCgkKGVsZW1lbnQpLmRhdGEoJ3V1aWQnKSlcbiAgICAgIH1cbiAgICB9KVxuXG4gICAgaWYgKHV1aWRzLmxlbmd0aCA+IDApIHtcbiAgICAgIEFjdGlvbnMudHJpZ2dlclNlcnZleU1haWxzKG1lZXRpbmdJbmZvLCB1dWlkcywgc2VsZWN0QWxsRmxhZylcbiAgICB9IGVsc2Uge1xuICAgICAgc2hvd1N1cnZleUVycm9yKClcbiAgICB9XG4gIH1cblxuICBmdW5jdGlvbiBzaG93U3VydmV5RXJyb3IgKCkge1xuICAgIG5vdGlmaWNhdGlvbk1vZGFsLm5vdGlmaWNhdGlvbk1vZGFsKHtcbiAgICAgIGNsYXNzOiAneWVsbG93JyxcbiAgICAgIHRpdGxlOiBpMThuLnQoJ3JlcXVpcmVkX3N1cnZleScpLFxuICAgICAgYm9keTogaTE4bi50KCdzdXJ2ZXlfbm90X3NlbGVjdGVkJyksXG4gICAgICB0aW1lb3V0OiA0MDAwXG4gICAgfSlcbiAgfVxuXG4gIGZ1bmN0aW9uIHNlcnZleU1haWxzVHJpZ2dlcmVkIChkYXRhKSB7XG4gICAgc3VydmV5TW9kYWxFbC5tb2RhbCgnaGlkZScpXG4gICAgaWYgKGRhdGEuZGF0YS5zZWxlY3RlZE1lZXRpbmdMaXN0KSB7XG4gICAgICBkYXRhLmRhdGEucmVzcG9uc2Uuc2hvd19tZXNzYWdlID8gc2hvd1N1cnZleU1lc3NhZ2UoZGF0YSwgcmVzZXRNZWV0aW5nTGlzdCkgOiByZXNldE1lZXRpbmdMaXN0KGRhdGEpXG4gICAgfSBlbHNlIHtcbiAgICAgIGRhdGEuZGF0YS5yZXNwb25zZS5zaG93X21lc3NhZ2UgPyBzaG93U3VydmV5TWVzc2FnZShkYXRhLCByZXNldE1lZXRpbmdMaXN0KSA6IHVwZGF0ZVN1cnZleURldGFpbHMoZGF0YSlcbiAgICB9XG4gIH1cblxuICBmdW5jdGlvbiB1cGRhdGVTdXJ2ZXlEZXRhaWxzKGRhdGEpe1xuICAgIHZhciBzdXJ2ZXlVdWlkQXJyYXkgPSBkYXRhLmRhdGEucmVzcG9uc2Uuc3VydmV5X3V1aWRcbiAgICBfLmVhY2goc3VydmV5VXVpZEFycmF5LCBmdW5jdGlvbiAoc3VydmV5KSB7XG4gICAgICB2YXIgc3VydmV5RGV0YWlscyA9IF8uZmluZChzdXJ2ZXlTZWxlY3RlZE1lZXRpbmcuc3VydmV5X2xpbmtzLCB7dXVpZDogc3VydmV5LnV1aWR9KVxuICAgICAgc3VydmV5RGV0YWlscyAmJiBfLm1lcmdlKHN1cnZleURldGFpbHMsIHN1cnZleSlcbiAgICB9KVxuICB9XG5cbiAgZnVuY3Rpb24gcmVzZXRNZWV0aW5nTGlzdChkYXRhKSB7XG4gICAgY2xlYXJTZWxlY3RlZE1lZXRpbmdIYXNoKGRhdGEuZGF0YS5zZWxlY3RlZE1lZXRpbmdMaXN0KVxuICAgIHJlbG9hZE1lZXRpbmdMaXN0KClcbiAgfVxuXG4gIGZ1bmN0aW9uIHNob3dTdXJ2ZXlNZXNzYWdlKGRhdGEsIGNhbGxCYWNrKSB7XG4gICAgJCgnLm5vdGlmaWNhdGlvbi1tb2RhbCcpLm5vdGlmaWNhdGlvbk1vZGFsKHtcbiAgICAgICAgY2xhc3M6ICdibHVlJyxcbiAgICAgICAgdGl0bGU6IGkxOG4udCgnc3VydmV5JyksXG4gICAgICAgIGJvZHk6IGRhdGEuZGF0YS5yZXNwb25zZS5tZXNzYWdlLFxuICAgICAgICBkaXNtaXNzOiBmdW5jdGlvbigpIHtcbiAgICAgICAgICBjYWxsQmFjayhkYXRhKVxuICAgICAgICB9XG4gICAgfSk7XG4gIH1cblxuICByZXR1cm4ge1xuICAgIGluaXQ6IGluaXRcbiAgfVxufSgpKVxuXG5tb2R1bGUuZXhwb3J0cyA9IE1lZXRpbmdIYW5kbGVyXG4iLCJ2YXIgTWVldGluZ0FjdGlvbnMgPSByZXF1aXJlKFwiLi9hY3Rpb25zXCIpO1xudmFyIEFwaSA9IHJlcXVpcmUoJ2NvbW1vbl9hcGknKTtcblxudmFyIEV2ZW50U3RvcmUgPSBSZWZsdXguY3JlYXRlU3RvcmUoe1xuICBpbml0OiBmdW5jdGlvbigpe1xuICAgIHRoaXMubGlzdGVuVG9NYW55KE1lZXRpbmdBY3Rpb25zKTtcbiAgICB0aGlzLmV2ZW50RGV0YWlscyA9IHt9XG4gIH0sXG4gIG9uRmV0Y2hFdmVudERldGFpbHM6IGZ1bmN0aW9uKCl7XG4gICAgdmFyIHByb21pc2UgPSBBcGkuZmV0Y2goe1xuICAgICAgdXJsOiBBcGkuRU5EUE9JTlRTLmV2ZW50X2RldGFpbHNcbiAgICB9KVxuXG4gICAgcHJvbWlzZS50aGVuKGZ1bmN0aW9uKGFwaVJlc3BvbnNlKSB7XG4gICAgICB0aGlzLmV2ZW50RGV0YWlscyA9IGFwaVJlc3BvbnNlLmRhdGE7XG4gICAgICB0aGlzLnRyaWdnZXIoe3N1Y2Nlc3M6IHRydWUsIHR5cGU6ICdldmVudERldGFpbHMnfSlcbiAgICB9LmJpbmQodGhpcykpO1xuICB9LFxuICBpc1N0YWZmU2NoZWR1bGluZ0V2ZW50OiBmdW5jdGlvbigpe1xuICAgIHJldHVybiB0aGlzLmV2ZW50RGV0YWlscy5pc1N0YWZmU2NoZWR1bGluZyA9PSB0cnVlXG4gIH0sXG4gIGdldEZpZWxkRnJvbU1lZXRpbmdUeXBlRm9yQWdlbmRhOiBmdW5jdGlvbihmaWVsZF9uYW1lKXtcbiAgICB2YXIgbWVldGluZ1R5cGVGb3JBZ2VuZGEgPSBfLmZpbmQodGhpcy5ldmVudERldGFpbHMuYWN0aXZpdGllc19hdHRyaWJ1dGVzLCBmdW5jdGlvbihhY3Rpdml0eSl7XG4gICAgICByZXR1cm4gYWN0aXZpdHkubmFtZSA9PT0gJ3Rhc2snXG4gICAgfSlcbiAgICByZXR1cm4gXy5waWNrKG1lZXRpbmdUeXBlRm9yQWdlbmRhLCBmaWVsZF9uYW1lKVtmaWVsZF9uYW1lXTtcbiAgfSxcbiAgZ2V0RXZlbnREZXRhaWxzOiBmdW5jdGlvbigpe1xuICAgIHJldHVybiB0aGlzLmV2ZW50RGV0YWlscztcbiAgfVxufSlcblxudmFyIE1lZXRpbmdTdG9yZSA9IFJlZmx1eC5jcmVhdGVTdG9yZSh7XG5cbiAgICBpbml0OiBmdW5jdGlvbiAoKSB7XG4gICAgICAgIHRoaXMubGlzdGVuVG9NYW55KE1lZXRpbmdBY3Rpb25zKTtcbiAgICAgICAgdGhpcy5tZWV0aW5ncyA9IFtdO1xuICAgICAgICB0aGlzLnRvZ2dsZVN0b3JlID0ge1xuICAgICAgICAgICdncmlkJzogeyB2aWV3OiAndGlsZS12aWV3JywgdGlsZTogJ2NvbC1tZC0zIGNvbC1zbS00JyB9LFxuICAgICAgICAgICdsaXN0JzogeyB2aWV3OiAnbGlzdC12aWV3JywgdGlsZTogJ2NvbC1tZC0xMicgfVxuICAgICAgICB9O1xuICAgICAgICB0aGlzLmZpbHRlcnMgPSB7fTtcbiAgICAgICAgdGhpcy5zdG9yZWRGaWx0ZXJEYXRhID0ge307XG4gICAgICAgIHRoaXMuY3VycmVudF9wYWdlID0gMTtcbiAgICAgICAgdGhpcy50b3RhbF9wYWdlcyA9IDA7XG4gICAgICAgIHRoaXMuZmV0Y2hpbmcgPSBmYWxzZTtcbiAgICAgICAgdGhpcy5wZXJfcGFnZV9tZWV0aW5nX2NvdW50ID0gMTA7XG4gICAgICAgIHRoaXMudG90YWxNZWV0aW5ncyA9IDA7XG4gICAgICAgIHZhciBzdGF0ZTtcbiAgICAgICAgaWYgKHRoaXMuZ2V0TG9jYWxUb2dnbGUoKSA9PT0gJ2xpc3QnKSB7XG4gICAgICAgICAgc3RhdGUgPSB0aGlzLnRvZ2dsZVN0b3JlWydsaXN0J107XG4gICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgc3RhdGUgPSB0aGlzLnRvZ2dsZVN0b3JlWydncmlkJ107XG4gICAgICAgIH1cbiAgICAgICAgdGhpcy50b2dnbGVTdGF0ZSA9IHtcbiAgICAgICAgICB2aWV3U3R5bGU6IHN0YXRlWyd2aWV3J10sXG4gICAgICAgICAgdGlsZVNpemU6IHN0YXRlWyd0aWxlJ11cbiAgICAgICAgfTtcbiAgICAgICAgdGhpcy5idWxrX3N1cnZleSA9IHt9O1xuICAgICAgICB0aGlzLkFwaUxpc3QgPSB7XG4gICAgICAgICAgJ2dlbmVyYWxNZWV0aW5ncyc6IHtcbiAgICAgICAgICAgIG1lZXRpbmdzX2xpc3Q6IEFwaS5FTkRQT0lOVFMubWVldGluZ3NfbGlzdCxcbiAgICAgICAgICAgIGxpc3Rfa2V5OiAnbWVldGluZ19yZXF1ZXN0cycsXG4gICAgICAgICAgICBmaWx0ZXJfcGFyYW06IHtcbiAgICAgICAgICAgICAgZXhjbHVkZV9jb25zZWN1dGl2ZTogdHJ1ZSxcbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9LFxuICAgICAgICAgICdjb25zZWN1dGl2ZU1lZXRpbmdzJzoge1xuICAgICAgICAgICAgbWVldGluZ3NfbGlzdDogQXBpLkVORFBPSU5UUy5jb25zZWN1dGl2ZV9tZWV0aW5nX2xpc3QsXG4gICAgICAgICAgICBsaXN0X2tleTogJ2NvbnNlY3V0aXZlX21lZXRpbmdzJyxcbiAgICAgICAgICAgIGZpbHRlcl9wYXJhbToge1xuICAgICAgICAgICAgICBleGNsdWRlX2NvbnNlY3V0aXZlOiBmYWxzZSxcbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9XG4gICAgICAgIH1cbiAgICB9LFxuXG4gICAgZ2V0QXZhaWxhYmxlU2VsZWN0ZWRNZWV0aW5nczogZnVuY3Rpb24oc2VsZWN0ZWRNZWV0aW5nQ2FyZEhhc2gsIHByb3ApIHtcbiAgICAgIHZhciBhdmFpbGFibGVNZWV0aW5ncyA9IFtdO1xuICAgICAgaWYgKHR5cGVvZiBwcm9wID09PSAndW5kZWZpbmVkJykge1xuICAgICAgICBwcm9wID0gJ3V1aWQnO1xuICAgICAgfVxuICAgICAgdGhpcy5tZWV0aW5ncy5mb3JFYWNoKGZ1bmN0aW9uKG1lZXRpbmcpIHtcbiAgICAgICAgaWYgKHNlbGVjdGVkTWVldGluZ0NhcmRIYXNoW21lZXRpbmcudXVpZF0pIHtcbiAgICAgICAgICBhdmFpbGFibGVNZWV0aW5ncy5wdXNoKG1lZXRpbmdbcHJvcF0pO1xuICAgICAgICB9XG4gICAgICB9KTtcbiAgICAgIHJldHVybiBhdmFpbGFibGVNZWV0aW5ncztcbiAgICB9LFxuXG4gICAgb25GZXRjaE9wdGlvbnM6IGZ1bmN0aW9uKGRhdGEsIHN1Y2Nlc3MsIGZhaWx1cmUpIHtcbiAgICAgIHZhciBwcm9taXNlID0gQXBpLmZldGNoKHtcbiAgICAgICAgZGF0YTogZGF0YSxcbiAgICAgICAgdXJsOiBBcGkuRU5EUE9JTlRTLmdldF9tZWV0aW5nX29wdGlvbnMsXG4gICAgICAgIHByZWZpeDogZW52RGV0YWlscy51cmxQcmVmaXhcbiAgICAgIH0pXG4gICAgICBwcm9taXNlLnRoZW4oZnVuY3Rpb24ocmVzcG9uc2UpIHsgc3VjY2VzcyhyZXNwb25zZS5kYXRhKTsgfSk7XG5cbiAgICAgIHByb21pc2VbcHJvbWlzZS5mYWlsID8gJ2ZhaWwnOiAnY2F0Y2gnXShmdW5jdGlvbihhcGlSZXNwb25zZSl7XG4gICAgICB9LmJpbmQodGhpcykpO1xuXG4gICAgICByZXR1cm4gcHJvbWlzZTtcbiAgICB9LFxuXG4gICAgb25VcGRhdGVGaWx0ZXI6IGZ1bmN0aW9uKGZvcm1EYXRhLCBzdG9yZWRGaWx0ZXJEYXRhKSB7XG4gICAgICB0aGlzLnVwZGF0ZUZpbHRlclZhbHVlcyhmb3JtRGF0YSwgc3RvcmVkRmlsdGVyRGF0YSk7XG4gICAgICB0aGlzLm9uUmVGZXRjaE1lZXRpbmdzKCk7XG4gICAgfSxcblxuICAgIG9uUmVGZXRjaE1lZXRpbmdzOiBmdW5jdGlvbihmZXRjaEFsbEV4aXN0aW5nQ291bnQpIHtcbiAgICAgIHZhciBwZXJfcGFnZTtcbiAgICAgIGlmIChmZXRjaEFsbEV4aXN0aW5nQ291bnQpIHtcbiAgICAgICAgcGVyX3BhZ2UgPSB0aGlzLm1lZXRpbmdzLmxlbmd0aDtcbiAgICAgIH1cbiAgICAgIHRoaXMuc2V0Q3VycmVudFBhZ2UoMSk7XG4gICAgICB0aGlzLnJlc2V0TWVldGluZ0xpc3QoKTtcbiAgICAgIHRoaXMub25GZXRjaE1lZXRpbmdzKDEsIHBlcl9wYWdlKTtcbiAgICB9LFxuXG4gICAgc2V0Q3VycmVudFVzZXJGbGFnczogZnVuY3Rpb24oKXtcbiAgICAgIHRoaXMuaXNDdXJyZW50VXNlck1NID0gZW52RGV0YWlscy5pc01lZXRpbmdNYW5hZ2VyKCk7XG4gICAgICB0aGlzLmlzQ3VycmVudFVzZXJDU00gPSBlbnZEZXRhaWxzLmlzQ1NNKCk7XG4gICAgICB0aGlzLmlzSnVuaW9yTU0gPSBlbnZEZXRhaWxzLmlzSnVuaW9yTU0oKTtcbiAgICAgIHRoaXMuaXNBY3Rpdml0eU1hbmFnZXIgPSBlbnZEZXRhaWxzLmlzQWN0aXZpdHlNYW5hZ2VyKCk7XG4gICAgICB0aGlzLmlzRXhlY3V0aXZlQWRtaW4gPSBlbnZEZXRhaWxzLmlzRXhlY3V0aXZlQWRtaW4oKTtcbiAgICB9LFxuXG4gICAgZ2V0VG9nZ2xlU3RhdGU6IGZ1bmN0aW9uKCl7XG4gICAgICByZXR1cm4gdGhpcy50b2dnbGVTdGF0ZTtcbiAgICB9LFxuXG4gICAgdXBkYXRlRmlsdGVyVmFsdWVzOiBmdW5jdGlvbihmaWx0ZXJEYXRhLCBzdG9yZWRGaWx0ZXJEYXRhKSB7XG4gICAgICB2YXIgc2VhcmNoID0gdGhpcy5maWx0ZXJzLnNlYXJjaCB8fCAnJztcbiAgICAgIHRoaXMuZmlsdGVycyA9IGZpbHRlckRhdGE7XG4gICAgICB0aGlzLnN0b3JlZEZpbHRlckRhdGEgPSBzdG9yZWRGaWx0ZXJEYXRhIHx8IHt9O1xuICAgICAgaWYgKHNlYXJjaCkge1xuICAgICAgICB0aGlzLmZpbHRlcnMuc2VhcmNoID0gc2VhcmNoO1xuICAgICAgICB0aGlzLnN0b3JlZEZpbHRlckRhdGEuc2VhcmNoID0gc2VhcmNoO1xuICAgICAgfVxuICAgIH0sXG5cbiAgICBmZXRjaEZpcnN0UGFnZTogZnVuY3Rpb24oKXtcbiAgICAgIHRoaXMuc2V0Q3VycmVudFBhZ2UoMSk7XG4gICAgICB0aGlzLnJlc2V0TWVldGluZ0xpc3QoKTtcbiAgICAgIHRoaXMub25GZXRjaE1lZXRpbmdzKDEpO1xuICAgIH0sXG5cbiAgICBvblVwbG9hZEFnZW5kYUl0ZW1Dc3Y6IGZ1bmN0aW9uKGRhdGEpe1xuICAgICAgdmFyIHByb21pc2UgPSBBcGkudXBkYXRlKHtcbiAgICAgICAgdXJsOiBBcGkuRU5EUE9JTlRTLnVwbG9hZF9hZ2VuZGFfaXRlbV9jc3YsXG4gICAgICAgIGRhdGE6IGRhdGEsXG4gICAgICAgIHByb2Nlc3NEYXRhOiBmYWxzZSxcbiAgICAgICAgY29udGVudFR5cGU6IGZhbHNlLFxuICAgICAgfSk7XG5cbiAgICAgIHByb21pc2UudGhlbihmdW5jdGlvbihhcGlSZXNwb25zZSl7XG4gICAgICAgIHZhciBjb3VudE1lc3NhZ2UgPSBhcGlSZXNwb25zZS5tZXNzYWdlO1xuICAgICAgICBpZihhcGlSZXNwb25zZS5zdWNjZXNzKXtcbiAgICAgICAgICB0aGlzLnRyaWdnZXIoe1xuICAgICAgICAgICAgdHlwZTogJ2FnZW5kYUl0ZW1VcGxvYWRTdWNjZXNzJyxcbiAgICAgICAgICAgIGNvdW50TWVzc2FnZTogY291bnRNZXNzYWdlXG4gICAgICAgICAgfSk7XG4gICAgICAgICAgdGhpcy5mZXRjaEZpcnN0UGFnZSgpO1xuICAgICAgICB9ZWxzZXtcbiAgICAgICAgICB0aGlzLnRyaWdnZXIoe1xuICAgICAgICAgICAgdHlwZTogJ2FnZW5kYUl0ZW1VcGxvYWRGYWlsdXJlJyxcbiAgICAgICAgICAgIGVycm9yczogYXBpUmVzcG9uc2UuZXJyb3JzLFxuICAgICAgICAgICAgY291bnRNZXNzYWdlOiBjb3VudE1lc3NhZ2UsXG4gICAgICAgICAgICBkb3dubG9hZF9saW5rOiBhcGlSZXNwb25zZS5kb3dubG9hZF9saW5rXG4gICAgICAgICAgfSlcbiAgICAgICAgICB0aGlzLmZldGNoRmlyc3RQYWdlKCk7XG4gICAgICAgIH1cblxuICAgICAgfS5iaW5kKHRoaXMpKTtcblxuICAgICAgcHJvbWlzZS5mYWlsKGZ1bmN0aW9uKGFwaVJlc3BvbnNlKXtcbiAgICAgICAgYXBpUmVzcG9uc2UgPSBfLmlzT2JqZWN0KGFwaVJlc3BvbnNlLnJlc3BvbnNlSlNPTikgPyBhcGlSZXNwb25zZS5yZXNwb25zZUpTT04gOiBhcGlSZXNwb25zZVxuICAgICAgICB0aGlzLnRyaWdnZXIoe1xuICAgICAgICAgICAgdHlwZTogJ2FnZW5kYUl0ZW1VcGxvYWRGYWlsdXJlJyxcbiAgICAgICAgICAgIGNvdW50TWVzc2FnZTogYXBpUmVzcG9uc2UubWVzc2FnZSxcbiAgICAgICAgICAgIGVycm9yczogYXBpUmVzcG9uc2UuZXJyb3JzXG4gICAgICAgICAgfSlcbiAgICAgIH0uYmluZCh0aGlzKSk7XG4gICAgfSxcblxuICAgIG9uR2V0RmlsdGVyczogZnVuY3Rpb24ocHJlU2VsZWN0ZWRGaWx0ZXJzKSB7XG5cbiAgICAgIGlmKGV2ZW50X2hvbWVfcGFnZSAmJiBldmVudF9ob21lX3BhZ2UgPT0gJ3RydWUnKXtcbiAgICAgICAgcHJlU2VsZWN0ZWRGaWx0ZXJzLmV2ZW50X2hvbWVfcGFnZSA9IHRydWU7XG4gICAgICB9XG5cbiAgICAgIHZhciBwcm9taXNlID0gQXBpLmZldGNoKHtcbiAgICAgICAgdXJsOiBBcGkuRU5EUE9JTlRTLm1lZXRpbmdzX2xpc3RfZmlsdGVycyArIFwiP3Y9XCIgKyAobmV3IERhdGUoKS5nZXRUaW1lKCkpLFxuICAgICAgICBkYXRhOiBfLm1lcmdlKHsgaW5jbHVkZV9jaGVja2luOiBcIm5vXCIsIGV4Y2x1ZGVfY2FuY2VsbGVkX21lZXRpbmdzOiBcIm5vXCIgfSwgcHJlU2VsZWN0ZWRGaWx0ZXJzKVxuICAgICAgfSk7XG5cbiAgICAgIHByb21pc2UudGhlbihmdW5jdGlvbiAoYXBpUmVzcG9uc2UpIHtcblxuICAgICAgICB0aGlzLnVwZGF0ZUZpbHRlclZhbHVlcyhwcmVTZWxlY3RlZEZpbHRlcnMpO1xuICAgICAgICB0aGlzLnRyaWdnZXIoe1xuICAgICAgICAgIHR5cGU6ICdtZWV0aW5nRmlsdGVycycsXG4gICAgICAgICAgZGF0YTogeyBmaWx0ZXJzIDogYXBpUmVzcG9uc2UuZmlsdGVycywgYXBwbGllZFNlYXJjaCA6IGFwaVJlc3BvbnNlLmFwcGxpZWRfc2VhcmNoIH1cbiAgICAgICAgfSlcbiAgICAgIH0uYmluZCh0aGlzKSk7XG5cbiAgICAgIHByb21pc2VbcHJvbWlzZS5mYWlsID8gJ2ZhaWwnOiAnY2F0Y2gnXShmdW5jdGlvbihhcGlSZXNwb25zZSl7XG4gICAgICAgIHRoaXMudHJpZ2dlcih7XG4gICAgICAgICAgdHlwZTogJ21lZXRpbmdGaWx0ZXJzJyxcbiAgICAgICAgICBkYXRhOiB7IGZpbHRlcnMgOiBbXSwgYXBwbGllZFNlYXJjaCA6ICcnIH1cbiAgICAgICAgfSlcbiAgICAgIH0uYmluZCh0aGlzKSk7XG4gICAgfSxcblxuICAgIGdlbmVyYXRlRXhwb3J0VXJsOiBmdW5jdGlvbihyZXZpZXcpe1xuICAgICAgdmFyIHByZWZpeCA9IGVudkRldGFpbHNbJ3VybFByZWZpeCddIHx8ICcnXG4gICAgICB2YXIgcXVlcnlTdHJpbmcsIGVuZHBvaW50XG4gICAgICBpZiAocmV2aWV3KSB7XG4gICAgICAgIHF1ZXJ5U3RyaW5nID0gJz8nICsgJC5wYXJhbSh7ZmlsdGVyczogdGhpcy5nZXRBcHBsaWVkRmlsdGVycygpfSlcbiAgICAgICAgZW5kcG9pbnQgPSBBcGkuRU5EUE9JTlRTLmV4cG9ydF9yZXZpZXdcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHF1ZXJ5U3RyaW5nID0gJz8nICsgJC5wYXJhbSh0aGlzLmdldEFwcGxpZWRGaWx0ZXJzKCkpXG4gICAgICAgIGVuZHBvaW50ID0gQXBpLkVORFBPSU5UUy5tZWV0aW5nX3JlcXVlc3RfZXhwb3J0XG4gICAgICB9XG4gICAgICByZXR1cm4gW3ByZWZpeCwgZW5kcG9pbnQsIHF1ZXJ5U3RyaW5nXS5qb2luKCcnKVxuICAgIH0sXG4gICAgZ2V0U2VhcmNoVmFsdWU6IGZ1bmN0aW9uKCl7XG4gICAgICByZXR1cm4gdGhpcy5maWx0ZXJzLnNlYXJjaDtcbiAgICB9LFxuXG4gICAgZ2V0TG9jYWxUb2dnbGU6IGZ1bmN0aW9uKCl7XG4gICAgICB2YXIgbGFzdFZpZXdMb2FkZWQgPSBjb21tb25zLmdldEl0ZW0oJ21lZXRpbmctbGlzdCcpO1xuICAgICAgc3dpdGNoIChsYXN0Vmlld0xvYWRlZCkge1xuICAgICAgICBjYXNlICdncmlkJzpcbiAgICAgICAgY2FzZSAnbGlzdCc6XG4gICAgICAgICAgcmV0dXJuIGxhc3RWaWV3TG9hZGVkO1xuICAgICAgICBkZWZhdWx0OlxuICAgICAgICAgIHJldHVybiAnZ3JpZCc7XG4gICAgICB9XG4gICAgfSxcblxuICAgIGlzRmlsdGVyT1JTZWFyY2hBcHBsaWVkOiBmdW5jdGlvbigpe1xuICAgICAgdmFyIGZpbHRlcnMgPSB0aGlzLmdldEFwcGxpZWRGaWx0ZXJzKCk7XG4gICAgICBmb3IgKHZhciBrZXkgaW4gZmlsdGVycykge1xuICAgICAgICBpZiAoZmlsdGVycy5oYXNPd25Qcm9wZXJ0eShrZXkpICYmIGZpbHRlcnNba2V5XS5sZW5ndGggIT0gMCkge1xuICAgICAgICAgIHJldHVybiB0cnVlO1xuICAgICAgICB9XG4gICAgICB9XG4gICAgICByZXR1cm4gZmFsc2U7XG4gICAgfSxcblxuICAgIG9uQnVsa0FwcHJvdmVNZWV0aW5nczogZnVuY3Rpb24oc2VsZWN0ZWRNZWV0aW5nQ2FyZEhhc2gsIHNlbGVjdEFsbEZsYWcpIHtcbiAgICAgIHZhciB0b0JlQXBwcm92ZWRNZWV0aW5ncyA9IHRoaXMuZ2V0QXZhaWxhYmxlU2VsZWN0ZWRNZWV0aW5ncyhzZWxlY3RlZE1lZXRpbmdDYXJkSGFzaCk7XG4gICAgICB2YXIgcHJvbWlzZSA9IEFwaS51cGRhdGUoe1xuICAgICAgICB1cmw6IEFwaS5FTkRQT0lOVFMuYnVsa19hcHByb3ZlX21lZXRpbmdzLFxuICAgICAgICBkYXRhOiB7XG4gICAgICAgICAgZmlsdGVyIDogdGhpcy5nZXRGaWx0ZXJzRm9yQnVsa09wZXJhdGlvbnMoKSxcbiAgICAgICAgICBtZWV0aW5nX3V1aWRzOiAoc2VsZWN0QWxsRmxhZyA/IFtdOiB0b0JlQXBwcm92ZWRNZWV0aW5ncylcbiAgICAgICAgfVxuICAgICAgfSk7XG5cbiAgICAgIHByb21pc2UudGhlbihmdW5jdGlvbihhcGlSZXNwb25zZSkge1xuICAgICAgICB0aGlzLnRyaWdnZXIoe1xuICAgICAgICAgIHR5cGU6ICdvbkJ1bGtBcHByb3ZhbFN1Y2Nlc3MnLFxuICAgICAgICAgIGRhdGE6IHsgdG9CZUFwcHJvdmVkTWVldGluZ3M6IHRvQmVBcHByb3ZlZE1lZXRpbmdzLCBhcHByb3ZlZE1lZXRpbmdDb3VudDogYXBpUmVzcG9uc2UuZGF0YS5hcHByb3ZlZCB8fCAwfVxuICAgICAgICB9KTtcbiAgICAgIH0uYmluZCh0aGlzKSk7XG5cbiAgICAgIHByb21pc2VbcHJvbWlzZS5mYWlsID8gJ2ZhaWwnOiAnY2F0Y2gnXShmdW5jdGlvbihyZXNwb25zZSkge1xuICAgICAgICB0aGlzLnRyaWdnZXIoe1xuICAgICAgICAgIHR5cGU6ICdvbkJ1bGtBcHByb3ZhbEZhaWx1cmUnLFxuICAgICAgICAgIGRhdGE6IHJlc3BvbnNlXG4gICAgICAgIH0pO1xuICAgICAgfS5iaW5kKHRoaXMpKTtcbiAgICB9LFxuXG4gICAgb25CdWxrUmVpbnZpdGVVc2VyczogZnVuY3Rpb24gKHNlbGVjdGVkTWVldGluZ0NhcmRIYXNoLCBzZWxlY3RBbGxGbGFnKSB7XG4gICAgICB2YXIgdG9CZVJlaW52aXRlZE1lZXRpbmdzID0gdGhpcy5nZXRBdmFpbGFibGVTZWxlY3RlZE1lZXRpbmdzKHNlbGVjdGVkTWVldGluZ0NhcmRIYXNoKVxuICAgICAgdmFyIHByb21pc2UgPSBBcGkudXBkYXRlKHtcbiAgICAgICAgdXJsOiBBcGkuRU5EUE9JTlRTLmJ1bGtfcmVpbnZpdGVfdXNlcnMsXG4gICAgICAgIGRhdGE6IHtcbiAgICAgICAgICBmaWx0ZXIgOiB0aGlzLmdldEZpbHRlcnNGb3JCdWxrT3BlcmF0aW9ucygpLFxuICAgICAgICAgIG1lZXRpbmdfdXVpZHM6IChzZWxlY3RBbGxGbGFnID8gW106IHRvQmVSZWludml0ZWRNZWV0aW5ncylcbiAgICAgICAgfVxuICAgICAgfSlcbiAgICAgIHByb21pc2UudGhlbihmdW5jdGlvbiAoYXBpUmVzcG9uc2UpIHtcbiAgICAgICAgdGhpcy50cmlnZ2VyKHtcbiAgICAgICAgICB0eXBlOiAnb25CdWxrUmVpbnZpdGVVc2VyU3VjY2VzcydcbiAgICAgICAgfSlcbiAgICAgIH0uYmluZCh0aGlzKSlcbiAgICB9LFxuXG4gICAgb25CdWxrQ2FuY2VsOiBmdW5jdGlvbihzZWxlY3RlZE1lZXRpbmdDYXJkSGFzaCwgc2VsZWN0QWxsRmxhZyl7XG4gICAgICB2YXIgdG9CZUNhbmNlbGxlZE1lZXRpbmdzID0gdGhpcy5nZXRBdmFpbGFibGVTZWxlY3RlZE1lZXRpbmdzKHNlbGVjdGVkTWVldGluZ0NhcmRIYXNoKTtcbiAgICAgIHZhciBwcm9taXNlID0gQXBpLnVwZGF0ZSh7XG4gICAgICAgIHVybDogQXBpLkVORFBPSU5UUy5idWxrX2NhbmNlbF9tZWV0aW5ncyxcbiAgICAgICAgZGF0YToge1xuICAgICAgICAgIGZpbHRlcjogdGhpcy5nZXRGaWx0ZXJzRm9yQnVsa09wZXJhdGlvbnMoKSxcbiAgICAgICAgICBtZWV0aW5nX3V1aWRzOiAoc2VsZWN0QWxsRmxhZyA/IFtdIDogdG9CZUNhbmNlbGxlZE1lZXRpbmdzKVxuICAgICAgICB9XG4gICAgICB9KVxuXG4gICAgICBwcm9taXNlLnRoZW4oZnVuY3Rpb24oYXBpUmVzcG9uc2Upe1xuICAgICAgICB0aGlzLnRyaWdnZXIoe1xuICAgICAgICAgIHR5cGU6ICdvbkJ1bGtDYW5jZWxTdWNjZXNzJyxcbiAgICAgICAgICBkYXRhOiB7dG9CZUNhbmNlbGxlZE1lZXRpbmdzOiB0b0JlQ2FuY2VsbGVkTWVldGluZ3MsIGNhbmNlbGxlZE1lZXRpbmdDb3VudDogYXBpUmVzcG9uc2UuZGF0YS5jYW5jZWxsZWQgfHwgMH1cbiAgICAgICAgfSk7XG4gICAgICB9LmJpbmQodGhpcykpO1xuXG4gICAgICBwcm9taXNlW3Byb21pc2UuZmFpbCA/ICdmYWlsJyA6ICdjYXRjaCddKGZ1bmN0aW9uKGFwaVJlc3BvbnNlKXtcbiAgICAgICAgdGhpcy50cmlnZ2VyKHtcbiAgICAgICAgICB0eXBlOiAnb25CdWxrQ2FuY2VsRmFpbHVyZScsXG4gICAgICAgICAgZGF0YTogYXBpUmVzcG9uc2VcbiAgICAgICAgfSk7XG4gICAgICB9LmJpbmQodGhpcykpO1xuICAgIH0sXG5cbiAgICBnZXRGaWx0ZXJzRm9yQnVsa09wZXJhdGlvbnM6IGZ1bmN0aW9uKCl7XG4gICAgICB2YXIgZmlsdGVycyA9IHRoaXMuZ2V0QXBwbGllZEZpbHRlcnMoKTtcbiAgICAgIGlmKGZpbHRlcnNbJ2ludGVybmFsX2ludml0ZWVzJ10gfHwgZmlsdGVyc1snZXh0ZXJuYWxfaW52aXRlZXMnXSl7XG4gICAgICAgIHZhciBpbnRlcm5hbEludml0ZWVzID0gZmlsdGVyc1snaW50ZXJuYWxfaW52aXRlZXMnXSB8fCBbXTtcbiAgICAgICAgdmFyIGV4dGVybmFsSW52aXRlZXMgPSBmaWx0ZXJzWydleHRlcm5hbF9pbnZpdGVlcyddIHx8IFtdO1xuICAgICAgICBmaWx0ZXJzWydpbnZpdGVlcyddID0gaW50ZXJuYWxJbnZpdGVlcy5jb25jYXQoZXh0ZXJuYWxJbnZpdGVlcyk7XG4gICAgICB9XG4gICAgICByZXR1cm4gZmlsdGVycztcbiAgICB9LFxuXG4gICAgaGFuZGxlTWVldGluZ09wZXJhdGlvbnNEaXNwbGF5OiBmdW5jdGlvbihtZWV0aW5nKXtcblxuICAgICAgbWVldGluZy5BY2NlcHQgPSAgJ2hpZGUnO1xuICAgICAgbWVldGluZy5EZWNsaW5lID0gJ2hpZGUnO1xuICAgICAgbWVldGluZy5BcHByb3ZlID0gJ2hpZGUnO1xuICAgICAgbWVldGluZy5DYW5jZWwgPSAnaGlkZSc7XG4gICAgICBtZWV0aW5nLmFwcHJvdmVfYWxsID0gJ2hpZGUnO1xuICAgICAgbWVldGluZy5jYW5jZWxfYWxsID0gJ2hpZGUnO1xuXG4gICAgICBtZWV0aW5nLmFwcHJvdmVkID0gJ2hpZGUnO1xuICAgICAgbWVldGluZy5jYW5jZWxsZWQgPSAnaGlkZSc7XG4gICAgICBtZWV0aW5nLmFjY2VwdGVkID0gJ2hpZGUnO1xuICAgICAgbWVldGluZy5kZWNsaW5lZCA9ICdoaWRlJztcbiAgICAgIGlmKG1lZXRpbmcuYWN0aW9ucyl7XG4gICAgICAgIG1lZXRpbmcuYWN0aW9ucy5tYXAoZnVuY3Rpb24oYWN0aW9uKXtcbiAgICAgICAgICBtZWV0aW5nW2FjdGlvbl0gPSAnJztcbiAgICAgICAgfSk7XG4gICAgICB9XG5cblxuICAgICAgLy90aGlzLmlzQ3VycmVudFVzZXJNTSA9IGZhbHNlO1xuXG4gICAgICBpZih0aGlzLmlzQ3VycmVudFVzZXJNTSB8fCB0aGlzLmlzQ3VycmVudFVzZXJDU00gfHwgdGhpcy5pc0p1bmlvck1NIHx8IHRoaXMuaXNBY3Rpdml0eU1hbmFnZXIgfHwgdGhpcy5pc0V4ZWN1dGl2ZUFkbWluKXtcblxuICAgICAgICBtZWV0aW5nW21lZXRpbmcuc3RhdHVzXSA9ICcnO1xuXG4gICAgICAgIG1lZXRpbmcuQWNjZXB0ID0gJ2hpZGUnO1xuICAgICAgICBtZWV0aW5nLkRlY2xpbmUgPSAnaGlkZSc7XG4gICAgICB9ZWxzZXtcbiAgICAgICAgbWVldGluZ1ttZWV0aW5nLmludml0ZV9zdGF0dXNdID0gJyc7XG5cbiAgICAgICAgbWVldGluZy5BcHByb3ZlID0gJ2hpZGUnO1xuICAgICAgICBtZWV0aW5nLkNhbmNlbCA9ICdoaWRlJztcbiAgICAgIH1cbiAgICB9LFxuXG4gICAgZ2V0U3RvcmFibGVGaWx0ZXJzOiBmdW5jdGlvbigpIHtcbiAgICAgIHRoaXMuc3RvcmVkRmlsdGVyRGF0YS5zZWFyY2ggPSB0aGlzLmZpbHRlcnMuc2VhcmNoO1xuICAgICAgcmV0dXJuIHRoaXMuc3RvcmVkRmlsdGVyRGF0YTtcbiAgICB9LFxuXG4gICAgb25GZXRjaE1lZXRpbmdzOiBmdW5jdGlvbiAocGFnZV9ubywgcGVyX3BhZ2UpIHtcblxuICAgICAgICBpZiAodGhpcy5nZXRGZXRjaFN0YXRlKCkgPT0gZmFsc2UpIHtcbiAgICAgICAgICB2YXIgZmlsdGVycyA9IHRoaXMuZ2V0QXBwbGllZEZpbHRlcnMoKTtcbiAgICAgICAgICBfLm1lcmdlKGZpbHRlcnMsIHRoaXMuQXBpTGlzdFtNZWV0aW5nVHlwZV0uZmlsdGVyX3BhcmFtKTtcbiAgICAgICAgICB0aGlzLnVwZGF0ZUZldGNoU3RhdGUodHJ1ZSk7XG4gICAgICAgICAgZmlsdGVyc1snaW52aXRlZXMnXSA9IChmaWx0ZXJzWydpbnRlcm5hbF9pbnZpdGVlcyddIHx8IFtdKS5jb25jYXQoZmlsdGVyc1snZXh0ZXJuYWxfaW52aXRlZXMnXSB8fCBbXSk7XG4gICAgICAgICAgdmFyIHByb21pc2UgPSBBcGkuZmV0Y2goe1xuICAgICAgICAgICAgdXJsOiB0aGlzLkFwaUxpc3RbTWVldGluZ1R5cGVdLm1lZXRpbmdzX2xpc3QgLFxuICAgICAgICAgICAgZGF0YToge1xuICAgICAgICAgICAgICBmaWx0ZXJzOiBmaWx0ZXJzLFxuICAgICAgICAgICAgICBzdG9yYWJsZV9maWx0ZXJzOiBKU09OLnN0cmluZ2lmeSh0aGlzLmdldFN0b3JhYmxlRmlsdGVycygpKSxcbiAgICAgICAgICAgICAgcGFnZTogcGFnZV9ubyxcbiAgICAgICAgICAgICAgcGVyX3BhZ2U6IHBlcl9wYWdlIHx8IHRoaXMucGVyX3BhZ2VfbWVldGluZ19jb3VudFxuICAgICAgICAgICAgfVxuICAgICAgICAgIH0pO1xuXG4gICAgICAgICAgcHJvbWlzZS50aGVuKGZ1bmN0aW9uIChhcGlSZXNwb25zZSkge1xuICAgICAgICAgICAgdmFyIGN1cnJlbnRVc2VyVXVpZCA9IGVudkRldGFpbHMuY3VycmVudFVzZXIudXVpZDtcbiAgICAgICAgICAgIHRoaXMudHJpZ2dlcih7XG4gICAgICAgICAgICAgIHR5cGU6ICdhZGRUb1NlbGVjdGVkTWVldGluZ0NhcmRIYXNoJyxcbiAgICAgICAgICAgICAgZGF0YTogYXBpUmVzcG9uc2UuZGF0YVsgdGhpcy5BcGlMaXN0W01lZXRpbmdUeXBlXS5saXN0X2tleSBdXG4gICAgICAgICAgICB9KTtcbiAgICAgICAgICAgIHRoaXMubWVldGluZ3MgPSB0aGlzLm1lZXRpbmdzLmNvbmNhdChhcGlSZXNwb25zZS5kYXRhWyB0aGlzLkFwaUxpc3RbTWVldGluZ1R5cGVdLmxpc3Rfa2V5IF0pO1xuICAgICAgICAgICAgdGhpcy5tZWV0aW5ncyA9IF8udW5pcSh0aGlzLm1lZXRpbmdzLCAndXVpZCcpO1xuICAgICAgICAgICAgdGhpcy5idWxrX3N1cnZleSA9IHtcbiAgICAgICAgICAgICAgc2hvd19zdXJ2ZXk6IGFwaVJlc3BvbnNlLnNob3dfc3VydmV5LFxuICAgICAgICAgICAgICBzdXJ2ZXlfbGlua3M6IGFwaVJlc3BvbnNlLnN1cnZleV9saW5rc1xuICAgICAgICAgICAgfTtcblxuICAgICAgICAgICAgdmFyIG5ld2x5TW9kaWZpZWRJZCA9IE51bWJlcihjb21tb25zLmdldEl0ZW0oJ2V2ZW50SWQnKSk7XG4gICAgICAgICAgICB2YXIgbmV3bHlNb2RpZmllZE1lZXRpbmcgPSBbXTtcbiAgICAgICAgICAgIGZvciAodmFyIGkgPSAwLCBsbiA9IHRoaXMubWVldGluZ3MubGVuZ3RoOyBpIDwgbG47IGkrKykge1xuXG4gICAgICAgICAgICAgIHZhciBtZWV0aW5nID0gdGhpcy5tZWV0aW5nc1tpXTtcbiAgICAgICAgICAgICAgbWVldGluZy5wcmltYXJ5X3NvcnRpbmdfY29sdW1uID0gbmV3IERhdGUobWVldGluZy5jcmVhdGVkX2F0KTtcblxuICAgICAgICAgICAgICB0aGlzLmhhbmRsZU1lZXRpbmdPcGVyYXRpb25zRGlzcGxheShtZWV0aW5nKTtcbiAgICAgICAgICAgICAgbWVldGluZy5sYXRlc3QgPSBmYWxzZTtcblxuICAgICAgICAgICAgICBpZiAobmV3bHlNb2RpZmllZElkID09PSBOdW1iZXIobWVldGluZy5pZCkpIHtcbiAgICAgICAgICAgICAgICBuZXdseU1vZGlmaWVkTWVldGluZyA9IHRoaXMubWVldGluZ3Muc3BsaWNlKGksIDEpO1xuICAgICAgICAgICAgICAgIGxuLS07XG4gICAgICAgICAgICAgICAgaS0tO1xuICAgICAgICAgICAgICB9XG4gICAgICAgICAgICB9XG5cbiAgICAgICAgICAgIHRoaXMubWVldGluZ3MgPSBfLnNvcnRCeSh0aGlzLm1lZXRpbmdzLCBmdW5jdGlvbihtZWV0aW5nKSB7XG4gICAgICAgICAgICAgIHJldHVybiBtZWV0aW5nLnByaW1hcnlfc29ydGluZ19jb2x1bW47XG4gICAgICAgICAgICB9KTtcblxuICAgICAgICAgICAgaWYgKG5ld2x5TW9kaWZpZWRNZWV0aW5nLmxlbmd0aCA+IDApIHtcbiAgICAgICAgICAgICAgdGhpcy5tZWV0aW5ncy51bnNoaWZ0LmFwcGx5KHRoaXMubWVldGluZ3MsIG5ld2x5TW9kaWZpZWRNZWV0aW5nKTtcbiAgICAgICAgICAgIH1cblxuICAgICAgICAgICAgY29tbW9ucy5zZXRJdGVtKCdldmVudElkJyk7XG4gICAgICAgICAgICB0aGlzLnVwZGF0ZUZldGNoU3RhdGUoZmFsc2UpO1xuICAgICAgICAgICAgdGhpcy5zZXRDdXJyZW50UGFnZSh0aGlzLmdldEN1cnJlbnRQYWdlKCkgKyAxKVxuICAgICAgICAgICAgdGhpcy51cGRhdGVUb3RhbE1lZXRpbmdDb3VudChhcGlSZXNwb25zZS5kYXRhLnRvdGFsX2VudHJpZXMpO1xuICAgICAgICAgICAgdGhpcy5zZXRUb3RhbFBhZ2VDb3VudChNYXRoLmNlaWwoYXBpUmVzcG9uc2UuZGF0YS50b3RhbF9lbnRyaWVzIC8gdGhpcy5wZXJfcGFnZV9tZWV0aW5nX2NvdW50KSk7XG4gICAgICAgICAgICB0aGlzLnRyaWdnZXIoe1xuICAgICAgICAgICAgICB0eXBlOiAnbWVldGluZ2xpc3RpbmcnLFxuICAgICAgICAgICAgICBkYXRhOiB7XG4gICAgICAgICAgICAgICAgbWVldGluZ3M6IHRoaXMubWVldGluZ3MsXG4gICAgICAgICAgICAgICAgdG9nZ2xlU3RhdGU6IHRoaXMudG9nZ2xlU3RhdGUsXG4gICAgICAgICAgICAgICAgdG90YWw6IGFwaVJlc3BvbnNlLmRhdGEudG90YWxfZW50cmllcyxcbiAgICAgICAgICAgICAgICB0b3RhbEV4dGVybmFsOiBhcGlSZXNwb25zZS5kYXRhLmV4dGVybmFsX3JlcXVlc3RzX2NvdW50LFxuICAgICAgICAgICAgICAgIHRvdGFsU2Vzc2lvbnM6IGFwaVJlc3BvbnNlLmRhdGEuc2Vzc2lvbnNfY291bnQsXG4gICAgICAgICAgICAgICAgdG90YWxDb25zZWNNZWV0aW5nOiBhcGlSZXNwb25zZS5kYXRhLmNvbnNlY3V0aXZlX21lZXRpbmdzX2NvdW50LFxuICAgICAgICAgICAgICAgIHRvdGFsSW50ZXJuYWxNZWV0aW5nOiBhcGlSZXNwb25zZS5kYXRhLmludGVybmFsX21lZXRpbmdzX2NvdW50LFxuICAgICAgICAgICAgICAgIHRvdGFsUmV2aWV3ZWVNZWV0aW5nOiBhcGlSZXNwb25zZS5kYXRhLnJldmlld2VlX21lZXRpbmdzX2NvdW50XG4gICAgICAgICAgICAgIH1cbiAgICAgICAgICAgIH0pO1xuICAgICAgICAgIH0uYmluZCh0aGlzKSk7XG5cbiAgICAgICAgICBwcm9taXNlW3Byb21pc2UuZmFpbCA/ICdmYWlsJzogJ2NhdGNoJ10oZnVuY3Rpb24oYXBpUmVzcG9uc2Upe1xuICAgICAgICAgICAgdGhpcy51cGRhdGVGZXRjaFN0YXRlKGZhbHNlKTtcbiAgICAgICAgICB9LmJpbmQodGhpcykpO1xuICAgICAgICB9XG5cbiAgICB9LFxuXG4gICAgdXBkYXRlVG90YWxNZWV0aW5nQ291bnQ6IGZ1bmN0aW9uKGNvdW50KXtcbiAgICAgIHRoaXMudG90YWxNZWV0aW5ncyA9IGNvdW50O1xuICAgIH0sXG5cbiAgICBnZXRUb3RhbE1lZXRpbmdDb3VudDogZnVuY3Rpb24oKXtcbiAgICAgIHJldHVybiB0aGlzLnRvdGFsTWVldGluZ3M7XG4gICAgfSxcblxuICAgIG9uVG9nZ2xlVmlldzogZnVuY3Rpb24oc2VsZWN0ZWRWaWV3KXtcbiAgICAgIGlmIChzZWxlY3RlZFZpZXcgIT09ICdjaGVja2luJykge1xuICAgICAgICB0aGlzLnRvZ2dsZVN0YXRlID0ge1xuICAgICAgICAgIHZpZXdTdHlsZTogdGhpcy50b2dnbGVTdG9yZVtzZWxlY3RlZFZpZXddWyd2aWV3J10sXG4gICAgICAgICAgdGlsZVNpemU6IHRoaXMudG9nZ2xlU3RvcmVbc2VsZWN0ZWRWaWV3XVsndGlsZSddXG4gICAgICAgIH07XG4gICAgICB9XG4gICAgICB0aGlzLnRyaWdnZXIoeyB0eXBlOiAndmlld2NoYW5nZWQnLCBkYXRhOiB0aGlzLnRvZ2dsZVN0YXRlLCBzZWxlY3RlZFZpZXc6IHNlbGVjdGVkVmlldyB9KTtcbiAgICB9LFxuXG4gICAgZ2V0RmV0Y2hTdGF0ZTogZnVuY3Rpb24oKXtcbiAgICAgIHJldHVybiB0aGlzLmZldGNoaW5nO1xuICAgIH0sXG4gICAgdXBkYXRlRmV0Y2hTdGF0ZTogZnVuY3Rpb24oc3RhdGUpe1xuICAgICAgdGhpcy5mZXRjaGluZyA9IHN0YXRlXG4gICAgfSxcbiAgICBnZXRDdXJyZW50UGFnZTogZnVuY3Rpb24oKXtcbiAgICAgIHJldHVybiB0aGlzLmN1cnJlbnRfcGFnZVxuICAgIH0sXG4gICAgcmVzZXRNZWV0aW5nTGlzdDogZnVuY3Rpb24oKXtcbiAgICAgIHRoaXMubWVldGluZ3MgPSBbXTtcbiAgICB9LFxuICAgIHNldEN1cnJlbnRQYWdlOiBmdW5jdGlvbihwYWdlX25vKXtcbiAgICAgIHRoaXMuY3VycmVudF9wYWdlID0gcGFnZV9ubztcbiAgICB9LFxuICAgIGdldFRvdGFsUGFnZUNvdW50OiBmdW5jdGlvbigpIHtcbiAgICAgIHJldHVybiB0aGlzLnRvdGFsX3BhZ2VzO1xuICAgIH0sXG4gICAgc2V0VG90YWxQYWdlQ291bnQ6IGZ1bmN0aW9uKGNvdW50KSB7XG4gICAgICB0aGlzLnRvdGFsX3BhZ2VzID0gY291bnQ7XG4gICAgfSxcbiAgICBvblNlYXJjaE1lZXRpbmdzOiBmdW5jdGlvbihzZWFyY2hfdmFsKSB7XG4gICAgICB0aGlzLmZpbHRlcnMuc2VhcmNoID0gc2VhcmNoX3ZhbDtcbiAgICAgIHRoaXMuc2V0Q3VycmVudFBhZ2UoMSk7XG4gICAgICB0aGlzLnJlc2V0TWVldGluZ0xpc3QoKTtcbiAgICAgIHRoaXMub25GZXRjaE1lZXRpbmdzKDEpO1xuICAgIH0sXG4gICAgb25VcGRhdGVTZWFyY2g6IGZ1bmN0aW9uKHNlYXJjaF92YWwpIHtcbiAgICAgIHRoaXMuZmlsdGVycy5zZWFyY2ggPSBzZWFyY2hfdmFsXG4gICAgfSxcbiAgICBvblJlc2V0RmlsdGVyOiBmdW5jdGlvbigpIHtcbiAgICAgIHRoaXMuZmlsdGVycyA9IHt9O1xuICAgICAgdGhpcy5zZXRDdXJyZW50UGFnZSgxKTtcbiAgICAgIHRoaXMucmVzZXRNZWV0aW5nTGlzdCgpO1xuICAgICAgdGhpcy5vbkZldGNoTWVldGluZ3MoMSk7XG4gICAgfSxcbiAgICBvbkFwcGx5RmlsdGVyOiBmdW5jdGlvbigpIHtcbiAgICAgIHRoaXMuc2V0Q3VycmVudFBhZ2UoMSk7XG4gICAgICB0aGlzLnJlc2V0TWVldGluZ0xpc3QoKTtcbiAgICAgIHRoaXMub25GZXRjaE1lZXRpbmdzKDEpO1xuICAgIH0sXG5cbiAgICBnZXRBcHBsaWVkRmlsdGVyczogZnVuY3Rpb24oKSB7XG4gICAgICB2YXIgZmlsdGVycyA9IF8uY2xvbmVEZWVwKHRoaXMuZmlsdGVycyk7XG4gICAgICBkZWxldGUgZmlsdGVycy5wYWdlO1xuICAgICAgZGVsZXRlIGZpbHRlcnMucGVyX3BhZ2U7XG4gICAgICByZXR1cm4gZmlsdGVycztcbiAgICB9LFxuXG4gICAgZ2V0TWVldGluZzogZnVuY3Rpb24odXVpZCkge1xuICAgICAgdmFyIG1lZXRpbmcgPSBfLmZpbmQodGhpcy5tZWV0aW5ncywgZnVuY3Rpb24obWVldGluZykge1xuICAgICAgICByZXR1cm4gbWVldGluZy51dWlkID09IHV1aWRcbiAgICAgIH0pXG4gICAgICByZXR1cm4gbWVldGluZztcbiAgICB9LFxuXG4gICAgb25UcmlnZ2VyU2VydmV5TWFpbHM6IGZ1bmN0aW9uKG1lZXRpbmdJbmZvLCBzdXJ2ZXlVVUlEUywgc2VsZWN0QWxsRmxhZyl7XG4gICAgICB2YXIgcGF0aFBhcmFtLCBtZWV0aW5nVVVJRFMsIGFwaVVybCwgc2VsZWN0ZWRNZWV0aW5nTGlzdDtcbiAgICAgIGlmKHR5cGVvZiBtZWV0aW5nSW5mbyA9PSAnc3RyaW5nJyl7XG4gICAgICAgIGFwaVVybCA9IEFwaS5FTkRQT0lOVFMuc2VuZF9zdXJ2ZXlfbWVldGluZ19tYWlsLnJlcGxhY2UoJ3tVVUlEfScsIG1lZXRpbmdJbmZvKTtcbiAgICAgICAgc2VsZWN0ZWRNZWV0aW5nTGlzdCA9ICcnO1xuICAgICAgfVxuICAgICAgZWxzZSB7XG4gICAgICAgIHNlbGVjdGVkTWVldGluZ0xpc3QgPSB0aGlzLmdldEF2YWlsYWJsZVNlbGVjdGVkTWVldGluZ3MobWVldGluZ0luZm8pO1xuICAgICAgICBtZWV0aW5nVVVJRFMgPSBzZWxlY3RBbGxGbGFnID8gW10gOiBzZWxlY3RlZE1lZXRpbmdMaXN0O1xuICAgICAgICBhcGlVcmwgPSBBcGkuRU5EUE9JTlRTLnNlbmRfYnVsa19zdXJ2ZXlfbWVldGluZ19tYWlsO1xuICAgICAgfVxuICAgICAgdmFyIHByb21pc2UgPSBBcGkudXBkYXRlKHtcbiAgICAgICAgdXJsOiBhcGlVcmwsXG4gICAgICAgIHR5cGU6ICdQVVQnLFxuICAgICAgICBkYXRhOiB7c3VydmV5X3V1aWQ6IHN1cnZleVVVSURTLCBtZWV0aW5nX3V1aWRzOiBtZWV0aW5nVVVJRFMsIGZpbHRlcjogdGhpcy5nZXRGaWx0ZXJzRm9yQnVsa09wZXJhdGlvbnMoKX1cbiAgICAgIH0pO1xuXG4gICAgICBwcm9taXNlLnRoZW4oZnVuY3Rpb24gKGFwaVJlc3BvbnNlKSB7XG4gICAgICAgIHRoaXMudHJpZ2dlcih7XG4gICAgICAgICAgdHlwZTogJ3NlcnZleU1haWxzVHJpZ2dlcmVkJyxcbiAgICAgICAgICBkYXRhOiB7c2VsZWN0ZWRNZWV0aW5nTGlzdDogc2VsZWN0ZWRNZWV0aW5nTGlzdCwgcmVzcG9uc2U6IGFwaVJlc3BvbnNlfVxuICAgICAgICB9KTtcbiAgICAgIH0uYmluZCh0aGlzKSk7XG5cbiAgICAgIHByb21pc2VbcHJvbWlzZS5mYWlsID8gJ2ZhaWwnOiAnY2F0Y2gnXShmdW5jdGlvbihhcGlSZXNwb25zZSl7XG4gICAgICB9LmJpbmQodGhpcykpO1xuICAgIH1cbn0pO1xuXG5cbnZhciBNZWV0aW5nQWN0aW9uU3RvcmUgPSBSZWZsdXguY3JlYXRlU3RvcmUoe1xuICAgIGluaXQ6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgdGhpcy5saXN0ZW5Ub01hbnkoTWVldGluZ0FjdGlvbnMpO1xuICAgIH0sXG4gICAgb25NZWV0aW5nQWN0aW9uOiBmdW5jdGlvbih1cmwsIHR5cGUgLCBhY3Rpb24pIHtcbiAgICAgIGlmKCFhY3Rpb24pe1xuICAgICAgICBhY3Rpb24gPSBcIlwiO1xuICAgICAgfVxuICAgICAgdmFyIHByb21pc2VPYmogPSB7XG4gICAgICAgIHVybDogdXJsXG4gICAgICB9O1xuXG4gICAgICBpZiAodHlwZSA9PSAncHV0Jyl7XG4gICAgICAgICBwcm9taXNlT2JqLnR5cGUgPSAnUFVUJ1xuICAgICAgfVxuXG4gICAgICB2YXIgcHJvbWlzZSA9IEFwaS51cGRhdGUocHJvbWlzZU9iaik7XG5cbiAgICAgIHByb21pc2UudGhlbihmdW5jdGlvbihhcGlSZXNwb25zZSl7XG4gICAgICAgICAgdGhpcy50cmlnZ2VyKHsgZGF0YTogYXBpUmVzcG9uc2UuZGF0YSwgYWN0aW9uOiBhY3Rpb259KTtcbiAgICAgIH0uYmluZCh0aGlzKSk7XG5cbiAgICAgIHByb21pc2VbcHJvbWlzZS5mYWlsID8gJ2ZhaWwnOiAnY2F0Y2gnXShmdW5jdGlvbihhcGlSZXNwb25zZSl7XG4gICAgICAgIHRoaXMudHJpZ2dlcih7IGVycm9yczogYXBpUmVzcG9uc2UucmVzcG9uc2VKU09OLmVycm9ycyB9KTtcbiAgICAgIH0uYmluZCh0aGlzKSk7XG4gICAgfVxufSk7XG5cbm1vZHVsZS5leHBvcnRzID0ge1xuICAgIE1lZXRpbmdTdG9yZTogTWVldGluZ1N0b3JlLFxuICAgIE1lZXRpbmdBY3Rpb25TdG9yZTogTWVldGluZ0FjdGlvblN0b3JlLFxuICAgIEV2ZW50U3RvcmU6IEV2ZW50U3RvcmVcbn1cbiIsIi8qIGVzbGludC1kaXNhYmxlICovXG5cbi8qIGdsb2JhbCBpMThuLCAkLCBfLCBGb3JtRGF0YSwgZW52RGV0YWlscyAqL1xuLy8gTm90ZTogQWRkIHRoZSB1cmxzIGluIHNvcnRlZCBvcmRlclxudmFyIEFwaSA9IHtcbiAgRU5EUE9JTlRTOiB7XG4gICAgYWNjZXB0X21lZXRpbmc6ICcvbWVldGluZ19yZXF1ZXN0L3t1dWlkfS9hY2NlcHRfbWVldGluZycsXG4gICAgYWN0aXZhdGVfZXZlbnQ6ICcvZXZlbnQvYWN0aXZhdGUnLFxuICAgIGFjdGl2YXRlX3Jvb206ICcvcm9vbS97e3V1aWR9fS9hY3RpdmUnLFxuICAgIGFjdGl2YXRlX3VzZXI6ICcvdXNlcnMvVVVJRC9hY3RpdmUnLFxuICAgIGFjdGl2aXR5X2RldGFpbHM6ICcvYWN0aXZpdGllcy97dXVpZH0nLFxuICAgIGFkYXB0ZXJzOiAnL2FkYXB0ZXJfdWkvaW50ZWdyYXRpb25fYWRhcHRlcnMnLFxuICAgIGFkZF9hdHRlbmRlZV90b19tZWV0aW5nOiAnL21lZXRpbmdzL2FkZF9hdHRlbmRlZXMnLFxuICAgIGFkZF9uZXdfbG9jYXRpb246ICcvbG9jYXRpb24ve2V2ZW50X3V1aWR9JyxcbiAgICBhZGRfc3VwcG9ydGVkX2FwaTogJy9hZGFwdGVyX3VpL3N1cHBvcnRlZF9hcGlzL21hcF90b19pbnRlZ3JhdGlvbicsXG4gICAgYWxlcnRfZGV0YWlsc19mZXRjaDogJy9hbGVydHMvbWVldGluZ19tZXRhJyxcbiAgICBhbGVydF9mZXRjaDogJy9hbGVydHMnLFxuICAgIGFsbF9tZWV0aW5nX3R5cGVzOiAnL21lZXRpbmdfdHlwZXMvaW5kZXgnLFxuICAgIGFwZXhfam5saXN0YWdlbmRhOiAnL2FwZXgvSk5CcmllZmluZ3MnLFxuICAgIGFwZXhfam5tZWV0aW5nczogJy9hcGV4L0pOTWVldGluZ3MnLFxuICAgIGFwaV9tYXBfb3JfYWRkX3VzZXI6IHsgdXJsOiAnL2FwaS92MS91c2Vycy9ib29rX21lZXRpbmdfY3JlYXRlJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgYXBpX3JlZ2lzdGVyX3VzZXI6IHsgdXJsOiAnL2FwaS92MS91c2VycycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIGFwaV91cGRhdGVfdXNlcl9ldmVudF9zZXR0aW5nczogeyB1cmw6ICcvYXBpL3YxL3VzZXIve3t1dWlkfX0vdXBkYXRlX3NldHRpbmdzJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJywgY3VzdG9tX3RpdGxlOiAnQ2Fubm90IFVwZGF0ZScgfSB9LFxuICAgIGFwaV91cGRhdGVfdXNlcjogeyB1cmw6ICcvYXBpL3YxL3VzZXJzL3t7dXVpZH19JywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJywgY3VzdG9tX3RpdGxlOiAnV2XigJlyZSBTb3JyeSEnIH0gfSxcbiAgICBhcHBvaW50bWVudF9maWx0ZXJfb3B0aW9uczogJy9hcHBvaW50bWVudF9maWx0ZXJfb3B0aW9ucycsXG4gICAgYXBwcm92ZV9leHRlcm5hbF9yZXF1ZXN0OiAnL2V4dGVybmFsX3JlcXVlc3Qve3V1aWR9L2FwcHJvdmUnLFxuICAgIGFwcHJvdmVfbWVldGluZzogJy9tZWV0aW5nX3JlcXVlc3QvYXBwcm92ZV9tZWV0aW5ncycsXG4gICAgYXBwcm92ZWRfbWVldGluZ19jb3VudDogeyB1cmw6ICcvYXBwcm92ZWRfbWVldGluZ19jb3VudCcsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdzdW1tdXJ5RXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgYXV0b19yZW1pbmRlcl9zZXR0aW5nOiAnL2F1dG9fcmVtaW5kZXJfc2V0dGluZycsXG4gICAgYXZhaWxhYmlsaXR5X2ZldGNoX2ViYzogJy9jb25maWd1cmUvaW5pdGlhbF9hdmFpbGFiaWxpdGllcycsXG4gICAgYXZhaWxhYmlsaXR5X2ZldGNoOiAnL21lZXRpbmdfdHlwZS9hdmFpbGFiaWxpdGllcycsXG4gICAgYXZhaWxhYmlsaXR5X3VwZGF0ZTogJy9jb25maWd1cmUvdXBkYXRlX2luaXRpYWxfYXZhaWxhYmlsaXRpZXMnLFxuICAgIGJsb2NrX3VwZGF0ZTogJy9jYWxlbmRhci9lZGl0X2Jsb2NrJyxcbiAgICBicmllZmluZ19jZW50cmVfbG9uZ19kYXk6ICcvYmNzL2dldF9sb25nX2RheScsXG4gICAgYnJpZWZpbmdfY2VudHJlOiAnL2JjJyxcbiAgICBicmllZmluZ19jdXN0b21fZm9ybXM6ICcvbWVldGluZ190eXBlL2JyaWVmaW5nX2N1c3RvbV9mb3JtcycsXG4gICAgYnJpZWZpbmdfZGV0YWlsczogJy9icmllZmluZy97YnJpZWZpbmdfdXVpZH0nLFxuICAgIGJ1bGtfYXBwcm92ZV9tYXBwaW5nczogJy9hcHBvaW50bWVudHMvYXBwcm92ZScsXG4gICAgYnVsa19hcHByb3ZlX21lZXRpbmdzOiAnL21lZXRpbmdfcmVxdWVzdC9hcHByb3ZlX21lZXRpbmdzJyxcbiAgICBidWxrX2NhbmNlbF9tYXBwaW5nczogJy9hcHBvaW50bWVudHMvY2FuY2VsJyxcbiAgICBidWxrX2NhbmNlbF9tZWV0aW5nczogJy9tZWV0aW5nX3JlcXVlc3QvY2FuY2VsX21lZXRpbmdzJyxcbiAgICBidWxrX2VuZG9yc2VfdXNlcnM6IHsgdXJsOiAnL2FwaS92MS91c2Vycy9zZXRfZW5kb3JzZWQnLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInIH0gfSxcbiAgICBidWxrX3JlaW52aXRlX3VzZXJzOiAnL21lZXRpbmdfcmVxdWVzdC9idWxrX3JlaW52aXRlJyxcbiAgICBidWxrX3NldF9tbV9vbmx5X2ZsYWc6ICcvYXBpL3YxL3VzZXJzL3NldF9tbV9vbmx5X2ZsYWcnLFxuICAgIGJ1bGtfc3luY19leHRfY2FsX2ZsYWc6ICcvYXBpL3YxL3VzZXJzL3VwZGF0ZV9jaXNfZGV0YWlscycsXG4gICAgYnVsa19yZWxheF9zZmRjX29ubHlfcmVxdWVzdF9tZWV0aW5nOiAnL2FwaS92MS91c2Vycy9zZXRfcmVsYXhfc2ZkY19vbmx5X3JlcXVlc3RfbWVldGluZycsXG4gICAgYnVsa19zaG93X2FzX2V4dGVybmFsX2F0dGVuZGVlOiB7IHVybDogJy9hcGkvdjEvdXNlcnMvc2V0X3Nob3dfYXNfZXh0JywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgY2FsZW5kYXJfYXZhaWxhYmlsaXR5OiAnL21lZXRpbmdfcmVxdWVzdC9jYWxlbmRhcicsXG4gICAgY2FsZW5kYXJfdXNlcl9hdmFpbGFiaWxpdHk6ICcvY2FsZW5kYXIvdXNlcnMnLFxuICAgIGNhbl9hdHRlbmRfc2Vzc2lvbjogJy9jYW5fYXR0ZW5kX3Nlc3Npb24nLFxuICAgIGNhbmNlbF9leHRlcm5hbF9yZXF1ZXN0OiB7IHVybDogJy9leHRlcm5hbF9yZXF1ZXN0L3t1dWlkfS9jYW5jZWwnLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInIH0gfSxcbiAgICBjYW5jZWxfbWVldGluZzogJy9tZWV0aW5nX3JlcXVlc3Qve21lZXRpbmdfdXVpZH0vY2FuY2VsX21lZXRpbmcnLFxuICAgIGNoZWNrX2F0dGVuZGVlX2F2YWlsYWJpbGl0eTogeyB1cmw6ICcvYXBpL3YxL3VzZXJzL3t1dWlkfS9hdmFpbGFiaWxpdHknIH0sXG4gICAgY2hlY2tpbl9jb25zZWN1dGl2ZV9tZWV0aW5nc19saXN0OiAnL2NoZWNraW5fY29uc2VjdXRpdmVfbWVldGluZ3MnLFxuICAgIGNoZWNraW5fbGlzdF9maWx0ZXJzOiAnL2NoZWNraW4vbWVldGluZ19maWx0ZXJzJyxcbiAgICBjaGVja2luX21lZXRpbmdzX2xpc3Q6ICcvY2hlY2tpbl9tZWV0aW5ncycsXG4gICAgY2hlY2tpbl9tZWV0aW5nczogJy9jaGVja2luX2xpc3QnLFxuICAgIGNoZWNraW5fc2Vzc2lvbnNfbGlzdDogJy9jaGVja2luX3Nlc3Npb25zJyxcbiAgICBjaGVja2luX3VzZXJzOiAnL2NoZWNraW4vdG9nZ2xlX2NoZWNraW4nLFxuICAgIGNpc19zZXJ2aWNlOiAnL2Npc19zZXJ2aWNlJyxcbiAgICBjb21wYW5pZXNfbGlzdDogJy9jb21wYW5pZXMvc2VhcmNoJyxcbiAgICBjb21wYW55X2ZldGNoOiAnL2NvbXBhbnknLFxuICAgIGNvbmNpZXJnZV9zZXJ2aWNlc19jcmVhdGU6ICcvY29uY2llcmdlX3NlcnZpY2VzJyxcbiAgICBjb25jaWVyZ2Vfc2VydmljZXNfdXBkYXRlOiAnL2NvbmNpZXJnZV9zZXJ2aWNlcy97dXVpZH0nLFxuICAgIGNvbmZpZ19hdXRvX3JlbWluZDogJy9jb25maWd1cmUvYXV0b19yZW1pbmQnLFxuICAgIGNvbmZpZ19oaXN0b3J5OiB7IHVybDogJy9jb25maWd1cmF0aW9uL2hpc3RvcnlfbGlzdCcsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIGNvbmZpZ19pbnRlZ3JhdGlvbl91cGRhdGU6ICcvY29uZmlndXJlL2ludGVncmF0aW9uX3VwZGF0ZScsXG4gICAgY29uZmlnX2ludGVncmF0aW9uOiAnL2NvbmZpZ3VyZS9pbnRlZ3JhdGlvbicsXG4gICAgY29uZmlnX25vdGlmaWNhdGlvbl91cGRhdGU6ICcvY29uZmlndXJlL25vdGlmaWNhdGlvbl91cGRhdGUnLFxuICAgIGNvbmZpZ19ub3RpZmljYXRpb246ICcvY29uZmlndXJlL25vdGlmaWNhdGlvbicsXG4gICAgY29uZmlnX3RvcGljX3VwZGF0ZTogJy9jb25maWcvdXBkYXRlX3RvcGljJyxcbiAgICBjb25maWdfdG9waWM6ICcvY29uZmlndXJlL3RvcGljJyxcbiAgICBjb25zZWN1dGl2ZV9saXN0X3BhZ2U6ICcvY29uc2VjdXRpdmVfbWVldGluZ3MvbGlzdCcsXG4gICAgY29uc2VjdXRpdmVfbWVldGluZ19saXN0OiB7IHVybDogJy9jb25zZWN1dGl2ZV9tZWV0aW5ncycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIGNvbnNlY3V0aXZlX21lZXRpbmdzX2RldGFpbHM6IHsgdXJsOiAnL2NvbnNlY3V0aXZlX21lZXRpbmdzL3t1dWlkfS9lZGl0X2NvbnNlY3V0aXZlX21lZXRpbmcnLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInIH0gfSxcbiAgICBjb25zZWN1dGl2ZV9tZWV0aW5nc19lZGl0X3BhdGg6ICcvY29uc2VjdXRpdmVfbWVldGluZ3Mve3V1aWR9L2VkaXQnLFxuICAgIGNvbnNlY3V0aXZlX21lZXRpbmdzX3ZpZXdfcGF0aDogJy9jb25zZWN1dGl2ZV9tZWV0aW5ncy97dXVpZH0vdmlldycsXG4gICAgY29weV9jYWxlbmRhcl9zZXR0aW5nczogJy9jb25maWd1cmUvY29weV9jYWxlbmRhcicsXG4gICAgY29weV9mb3JtX3NldHRpbmdzOiAnL2NvbmZpZ3VyZS9jb3B5X2Zvcm0nLFxuICAgIGNvcHlfbWVldGluZ19zZXR0aW5nczogJy9jb25maWd1cmUvY29weV9zZXR0aW5ncycsXG4gICAgY29weV9ub3RpZmljYXRpb25fc2V0dGluZ3M6ICcvY29uZmlndXJlL2NvcHlfbm90aWZpY2F0aW9uX3RlbXBsYXRlcycsXG4gICAgY3JlYXRlX2NvbnNlY3V0aXZlX21lZXRpbmdzOiAnL2NvbnNlY3V0aXZlX21lZXRpbmdzJyxcbiAgICBjcmVhdGVfZXh0ZXJuYWxfcmVxdWVzdDogJy9leHRlcm5hbF9yZXF1ZXN0L2NyZWF0ZScsXG4gICAgY3JlYXRlX2dyb3VwX25vbWluYXRpb246ICcvZ3JvdXBfbm9taW5hdGlvbi9jcmVhdGUnLFxuICAgIGNyZWF0ZV9pbnRlZ3JhdGlvbl91c2VyOiAodXVpZCkgPT4gYC9hZGFwdGVyX3VpL2ludGVncmF0aW9uLyR7dXVpZH0vdXNlcmAsXG4gICAgaW50ZWdyYXRpb25fdXNlcjogJy9pbnRlZ3JhdGlvbnMvaW50ZWdyYXRpb25fdXNlcicsXG4gICAgY3JlYXRlX21hcHBpbmc6ICcvY29udGFpbmVyX21hcHBpbmcve2FjdGl2aXR5X3V1aWR9L2NyZWF0ZScsXG4gICAgY3JlYXRlX29yX3VwZGF0ZV90cmFjazogeyB1cmw6ICcvdHJhY2tzJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgY3JlYXRlX3NlbGZfbm9taW5hdGlvbjogeyB1cmw6ICcvc2Vzc2lvbi97e3Nlc3Npb25VdWlkfX0vY3JlYXRlX3NlbGZfbm9taW5hdGlvbicsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIGNyZWF0ZV9zZXNzaW9uOiAnL3Nlc3Npb24vY3JlYXRlJyxcbiAgICBjcmVhdGVfdGFnX2Nsb3VkczogJy90YWdfY2xvdWQnLFxuICAgIGN1c3RvbV9maWVsZF9vcHRpb25zOiAnL2N1c3RvbV9mb3JtL3tVVUlEfS9zZWFyY2gnLFxuICAgIGN1c3RvbV9mb3JtX2RldGFpbHM6ICcvY3VzdG9tX2Zvcm1fZGV0YWlscycsXG4gICAgY3VzdG9tZXJfYXZhaWxhYmlsaXR5OiAnL2NhbGVuZGFyL2NvbXBhbmllcycsXG4gICAgY3VzdG9tZXJfY2FsZW5kYXJfZXhwb3J0OiAnL2NhbGVuZGFyL2JyaWVmaW5nc19jZW50ZXIvZXhwb3J0JyxcbiAgICBjdXN0b21fbGFiZWxzOiB7dXJsIDogJy9jdXN0b21fbGFiZWxzX2NvbmZpZ3VyYXRpb25zJywgZXJyb3JDb25maWcgOiB7aGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJ319LFxuICAgIGRlY2xpbmVfbWVldGluZzogJy9tZWV0aW5nX3JlcXVlc3Qve3V1aWR9L2RlY2xpbmVfbWVldGluZycsXG4gICAgZGVmYXVsdF9tZWV0aW5nX2xvY2F0aW9uX2VudGl0aWVzOiAnL2V2ZW50L3NldF9kZWZhdWx0X21lZXRpbmdfbG9jYXRpb24nLFxuICAgIGRlbGV0ZV9tYXBwaW5nOiAnL2NvbnRhaW5lcl9tYXBwaW5nL3t7dXVpZH19L2RlbGV0ZScsXG4gICAgZGVsZXRlX2xvY2F0aW9uX3ByZWZlcmVuY2U6IHt1cmw6ICcvbWVldGluZ19yZXF1ZXN0L3t7dXVpZH19L2RlbGV0ZV9sb2NfcHJlZl9wcm9wb3NhbCcsIGVycm9yQ29uZmlnOiB7aGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJ30gfSxcbiAgICBkZW1hbmRfcmVwb3J0X2V4cG9ydDogJy9hcGkvdjEvbWVldGluZ3Mvb25kZW1hbmQnLFxuICAgIGRlbWFuZF9yZXBvcnRzOiAnL3JlcG9ydHMvZGVtYW5kX3JlcG9ydCcsXG4gICAgZGV0YWlsZWRfY3VzdG9tX2xhYmVsczoge3VybCA6ICcvZGV0YWlsZWRfY3VzdG9tX2xhYmVsc19jb25maWd1cmF0aW9ucycsIGVycm9yQ29uZmlnIDoge2hhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcid9fSxcbiAgICBkaXNhYmxlX3NhdmVkX3JlcG9ydDogJy91c2VyX3RlbXBsYXRlL2Rpc2FibGUve3t1dWlkfX0nLFxuICAgIGRpc21pc3NfYWxlcnQ6ICcvYWxlcnRzL2Rpc21pc3MnLFxuICAgIGRpc21pc3Nfbm90aWZpY2F0aW9uOiAnL25vdGlmaWNhdGlvbnMvZGlzbWlzcycsXG4gICAgZG9tYWluX3ZhbGlkYXRpb246ICcvZG9tYWlucy92YWxpZGF0ZScsXG4gICAgZG9tYWluc192YWxpZDogJy9kb21haW5zL3ZhbGlkJyxcbiAgICBkb3VibGVfYm9va2VkX3Jlc291cmNlczogJy9tZWV0aW5nX3JlcXVlc3QvZG91YmxlX2Jvb2tlZF9yZXNvdXJjZXMnLFxuICAgIGRvd25sb2FkX2FnZW5kYV9pdGVtX3RlbXBsYXRlX3VybDogJy9tZWV0aW5nX3JlcXVlc3QvY3N2X3RlbXBsYXRlJyxcbiAgICB1c2VyX3RvcGljX21hcHBpbmdfdGVtcGxhdGVfdXJsOiAnL2FwaS92MS91c2Vycy91c2VyX3RvcGljX21hcHBpbmcvY3N2X3RlbXBsYXRlJyxcbiAgICBlZGl0X3RyYWNrOiAnL3RyYWNrcy97dXVpZH0vZWRpdCcsXG4gICAgZW5hYmxlX2RvdWJsZV9ib29rX3VzZXJzOiB7IHVybDogJy9hcGkvdjEvdXNlcnMvZW5hYmxlX2RvdWJsZV9ib29raW5nJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgZXZlbnRfYWNjZXNzX3NldHRpbmdzOiAnL2V2ZW50L3JvbGVzX2V2ZW50X3Zpc2liaWxpdHknLFxuICAgIGV2ZW50X2NvbmZpZ19leHBvcnQ6ICcvY29uZmlndXJhdGlvbi9leHBvcnQnLFxuICAgIGV2ZW50X2NvbmZpZ19mb3JfdXNlcl9jYWxlbmRhcjogJy91c2VyX2NhbGVuZGFyL2NvbmZpZ3VyYXRpb25zJyxcbiAgICBldmVudF9jb25maWdfaW1wb3J0OiB7IHVybDogICcvY29uZmlndXJhdGlvbi9pbXBvcnQnLCBlcnJvckNvbmZpZzoge2hhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcid9IH0sXG4gICAgZXZlbnRfY29uZmlnOiAnL2V2ZW50L2NvbmZpZ3VyYXRpb25zJyxcbiAgICBldmVudF9jb25maWd1cmF0aW9uczogJy9ldmVudC97ZXZlbnRfdXVpZH0vY29uZmlndXJhdGlvbnMnLFxuICAgIGV2ZW50X2RldGFpbHM6ICcvZXZlbnRfaW5mbycsXG4gICAgZXZlbnRfZWJjX2NvbmZpZ3VyYXRpb25zOiAnL2V2ZW50L2ViY19jb25maWd1cmF0aW9ucycsXG4gICAgZXZlbnRfaG9tZTogJ2V2ZW50L2hvbWUnLFxuICAgIGV2ZW50X25ldzogJy9ldmVudC9uZXcnLFxuICAgIGV2ZW50X3Jvb21fY2FsX3BhdGg6ICdjYWxlbmRhcicsXG4gICAgZXZlbnRfdXNlcl9jYWxfcGF0aDogJ3VzZXJfY2FsZW5kYXInLFxuICAgIGV2ZW50X3VzZXJfZmlsdGVyczogJy91c2Vycy9maWx0ZXJfb3B0aW9ucycsXG4gICAgZXZlbnRzX2luZm86ICcvZXZlbnRzJyxcbiAgICBldmVudHM6ICcvZXZlbnRzJyxcbiAgICBleHBlcnRfdXNlcnM6ICcvbWFwcGluZy9leHBlcnRzJyxcbiAgICBleHBvcnRfbWVldGluZ19jaGVja2luOiAnL3JlcG9ydHMvbWVldGluZ3NfY2hlY2tpbi9leHBvcnQueGxzeCcsXG4gICAgZXhwb3J0X3JldmlldzogJy9yZXZpZXdhYmxlL2V4cG9ydC5jc3YnLFxuICAgIGV4cG9ydF9zdW1tYXJ5X3JlcG9ydDogJy9ndWlkZWRfdG91ci9zdXJ2ZXlzJyxcbiAgICBleHBvcnRfc3VydmV5czogJy9zdXJ2ZXkve1VVSUR9L2V4cG9ydF9zdXJ2ZXlzJyxcbiAgICBleHRfZW5hYmxlZF9mZXRjaF9mb3JtX3NldHRpbmdzOiAnL2V4dGVybmFsX3dpZGdldF9hY3Rpdml0aWVzJyxcbiAgICBleHRlcm5hbF9hdHRlbmRlZXM6ICcvdXNlcnMvZXh0ZXJuYWwnLFxuICAgIGV4dGVybmFsX21lZXRpbmdzX2xpc3RfZmlsdGVyczogJy9leHRlcm5hbF9yZXF1ZXN0cy9maWx0ZXJzJyxcbiAgICBleHRlcm5hbF9yZXF1ZXN0X2RhdGVzOiAnL2V2ZW50X2RhdGVzJyxcbiAgICBleHRlcm5hbF9yZXF1ZXN0X2V4cG9ydDogJy9leHRlcm5hbF9yZXF1ZXN0cy9leHBvcnQnLFxuICAgIGV4dGVybmFsX3JlcXVlc3RzOiAnL2V4dGVybmFsX3JlcXVlc3RzJyxcbiAgICBleHRlcm5hbF93aWRnZXRfc2Vzc2lvbnM6ICcvZXh0ZXJuYWxfcmVxdWVzdC9ub21pbmF0aW9uL3Nlc3Npb25zJyxcbiAgICBleHRlcm5hbF93aWRnZXRfc2lnbnVwX3Nlc3Npb246ICcvc2Vzc2lvbi97dXVpZH0vY3JlYXRlX2V4dGVybmFsX3NlbGZfbm9taW5hdGlvbicsXG4gICAgZXh0ZXJuYWxfd2lkZ2V0X3RvcGljczogJy9leHRlcm5hbF93aWRnZXQvdHJhY2tzL3t1dWlkfS90b3BpY3MnLFxuICAgIGV4dGVybmFsX3dpZGdldF90cmFja3M6ICcvZXh0ZXJuYWxfd2lkZ2V0L3RyYWNrcycsXG4gICAgZmFjaWxpdGllc19saXN0OiAnL2ZhY2lsaXRpZXMnLFxuICAgIGZlYXR1cmVfZW5hYmxlX2ViYzogJy9mZWF0dXJlX3RvZ2dsZS9lbmFibGVfZWJjJyxcbiAgICBmZXRjaF9hY3RpdmVfZXZlbnRzOiAnL2FjdGl2ZV9ldmVudHMnLFxuICAgIGZldGNoX2FjdGl2aXRpZXM6ICcvdXNlcl9tZWV0aW5nX3R5cGVzL2xpc3QnLFxuICAgIGZldGNoX2FjdGl2aXR5X2xpc3Q6ICcvYWN0aXZpdGllcycsXG4gICAgZmV0Y2hfYWN0aXZpdHlfbWFuYWdlcjogeyB1cmw6ICcvdXNlcl9zZXR0aW5ncy97e3V1aWR9fS9hY3Rpdml0eScsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIGZldGNoX2FjdGl2aXR5X3NldHRpbmdzOiAnL2NvbmZpZ3VyZS9hY3Rpdml0eV9zZXR0aW5ncycsXG4gICAgZmV0Y2hfYW5hbHl0aWNzX2NvbmZpZ3M6ICcvYW5hbHl0aWNzX2Rhc2hib2FyZC9jb25maWcnLFxuICAgIGZldGNoX2FyY2hpdmVkX2V2ZW50X21lZXRpbmdfYW5hbHl0aWNzOiAnL2FyY2hpdmVkX2V2ZW50cy9hbmFseXRpY3MnLFxuICAgIGZldGNoX2FyY2hpdmVkX2V2ZW50c19saXN0OiAnL2V2ZW50X2xpc3RfYnlfdHlwZS9hcmNoaXZlZCcsXG4gICAgZmV0Y2hfYXJjaGl2ZWRfcmVwb3J0czogJy9hcmNoaXZlZF9ldmVudHMvYWxsX3JlcG9ydHMnLFxuICAgIGZldGNoX2F2YWlsYWJsZV9tZWV0aW5nX3R5cGVzOiAnL2ZldGNoX2F2YWlsYWJsZV9tZWV0aW5nX3R5cGVzJyxcbiAgICBmZXRjaF9ib29raW5nX2FuYWx5dGljczogJy9hbmFseXRpY3MvYm9va2luZycsXG4gICAgZmV0Y2hfYnJpZWZpbmdfd29ya2Zsb3c6ICcvY29uZmlndXJlL2JyaWVmaW5nX3NldHRpbmdzJyxcbiAgICBmZXRjaF9jYWxlbmRhcl9zZXR0aW5nczogJy9jb25maWd1cmUvY2FsZW5kYXJfc2V0dGluZ3MnLFxuICAgIGZldGNoX2NoYW5nYWJsZV9tZWV0aW5nX3R5cGVzOiAnL2ZldGNoX3RyYW5zZmVyX21lZXRpbmdfdHlwZXMve21lZXRpbmdfdXVpZH0nLFxuICAgIGZldGNoX2NvbmNpZXJnZV9mb3JtOiAnL2NvbmNpZXJnZV9zZXJ2aWNlcy9jdXN0b21fZm9ybXMnLFxuICAgIGZldGNoX2NvbmNpZXJnZV9ub3RpZmljYXRpb25fc2V0dGluZ3M6ICcvY29uY2llcmdlX3NlcnZpY2VzL25vdGlmaWNhdGlvbl9zZXR0aW5ncycsXG4gICAgZmV0Y2hfY29uY2llcmdlX3NlcnZpY2VzOiAnL2NvbmNpZXJnZV9zZXJ2aWNlcycsXG4gICAgZmV0Y2hfY29uc2VjdXRpdmVfbWVldGluZ19mb3JtX3NldHRpbmdzOiAnL2NvbmZpZ3VyZS9jb25zZWN1dGl2ZV9tZWV0aW5nL2Zvcm1fc2V0dGluZ3MnLFxuICAgIGZldGNoX2NvbnNlY3V0aXZlX21lZXRpbmdfbm90aWZpY2F0aW9uX3NldHRpbmdzOiAnL2NvbmZpZ3VyZS9jb25zZWN1dGl2ZV9tZWV0aW5nL25vdGlmaWNhdGlvbl9zZXR0aW5ncycsXG4gICAgZmV0Y2hfY3VzdG9tZXJfaW5mb192YWx1ZXM6ICcvaW1wb3J0YWJsZV9lbnRpdHlfaW5mbycsXG4gICAgZmV0Y2hfY3VzdG9tZXJzX2FuYWx5dGljczogJy9hbmFseXRpY3MvY3VzdG9tZXJzJyxcbiAgICBmZXRjaF9lYmNfZm9ybTogJy9icmllZmluZ19jdXN0b21fZm9ybS9nZXRfZmllbGRzJyxcbiAgICBmZXRjaF9leGlzdGluZ19tZWV0aW5nczogJy9iYWRnZV9zY2FuX21lZXRpbmdzJyxcbiAgICBmZXRjaF9leHRlcm5hbF9tZWV0aW5nX3JlcXVlc3Q6ICcvZXh0ZXJuYWxfcmVxdWVzdHMvbGlzdCcsXG4gICAgZmV0Y2hfZXh0ZXJuYWxfdXNlcl9mb3JtX2ZpZWxkczogJy9mZXRjaF9zZmRjX2NvbnRhY3RzX2ZpZWxkcycsXG4gICAgZmV0Y2hfZm9ybV9zZXR0aW5nczogJy9jb25maWd1cmUvZm9ybV9zZXR0aW5ncycsXG4gICAgZmV0Y2hfZm9ybTogJy9jdXN0b21fZm9ybS9nZXRfZmllbGRzJyxcbiAgICBmZXRjaF9ndWlkZWRfdG91cl9pbnRlZ3JhdGlvbl9maWVsZHM6ICcvZ3VpZGVkX3RvdXIvaW50ZWdyYXRpb25fZmllbGRzJyxcbiAgICBmZXRjaF9pbnRlZ3JhdGlvbl9ibG9ja19maWVsZHM6ICcvaW50ZWdyYXRpb25fYmxvY2tfZmllbGRzJyxcbiAgICBmZXRjaF9pbnRlZ3JhdGlvbl9tZWV0aW5nX2ZpZWxkczogJy9pbnRlZ3JhdGlvbl9tZWV0aW5nX2ZpZWxkcycsXG4gICAgZmV0Y2hfaW50ZWdyYXRpb25fc3VydmV5X2ZpZWxkczogJy9pbnRlZ3JhdGlvbl9zdXJ2ZXlfZmllbGRzJyxcbiAgICBmZXRjaF9pbnZpdGVlc19hbmFseXRpY3M6ICcvYW5hbHl0aWNzL2ludml0ZWVzJyxcbiAgICBmZXRjaF9sb2NhdGlvbl9jb25maWdzOiAnL2NvbmZpZ3VyZS9sb2NhdGlvbicsXG4gICAgZmV0Y2hfbWFwcGVkX21lZXRpbmdfdHlwZV9mb3Jfcm9sZTogeyB1cmw6ICcvdXNlcnMvcm9sZXNfYWN0aXZpdGllcycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIGZldGNoX21hcHBpbmdfZGV0YWlsczogJy9tYXBwaW5nc19kZXRhaWxzJyxcbiAgICBmZXRjaF9tYXBwaW5nX2ZpbHRlcnM6ICcvYXBwb2ludG1lbnRfZmlsdGVycycsXG4gICAgZmV0Y2hfbWFwcGluZ19ydWxlX3R5cGVzOiAnL2FkYXB0ZXJfdWkvZmV0Y2hfaW50ZWdyYXRpb25fcnVsZXMnLFxuICAgIGZldGNoX21hcHBpbmdzOiAnL21hcHBpbmdfbW9kdWxlX2NvdW50JyxcbiAgICBmZXRjaF9tYXN0ZXJfc3VwcG9ydGVkX2FwaXM6ICcvYWRhcHRlcl91aS9zdXBwb3J0ZWRfYXBpcycsXG4gICAgZmV0Y2hfbWVldGluZ19hdHRlbmRlZTogJy91c2Vycy9jb3B5X2F0dGVuZGVlcycsXG4gICAgZmV0Y2hfbWVldGluZ19jb3VudDogJy9hY3Rpdml0eV9tb2R1bGVfY291bnQnLFxuICAgIGZldGNoX21lZXRpbmdfZGF0YV9mb3JfcmVwb3J0czogJy91c2Vycy9tZWV0aW5ncycsXG4gICAgZmV0Y2hfbWVldGluZ19kZXRhaWxzOiAnL2FjdGl2aXR5X2RldGFpbHMnLFxuICAgIGZldGNoX21lZXRpbmdfZmlsdGVyczogJy9yZXBvcnRzL21lZXRpbmdfZmlsdGVycycsXG4gICAgZmV0Y2hfbWVldGluZ19saXN0X2NvcHlfYXR0ZW5kZWU6ICcvaW1wb3J0YWJsZV9lbnRpdHlfaW5mby9tZWV0aW5nX2luZm9fYXR0ZW5kZWUnLFxuICAgIGZldGNoX21lZXRpbmdfbGlzdF9jdXN0b21lcl9pbmZvOiAnL2ltcG9ydGFibGVfZW50aXR5X2luZm8vY3VzdG9tZXJfaW5mb19mb3JtJyxcbiAgICBmZXRjaF9tZWV0aW5nX3JlcG9ydHNfaGVhZGVyOiAnL2hlYWRlcnMnLFxuICAgIGZldGNoX21lZXRpbmdfcmVwb3J0czogJy9hcGkvdjEvbWVldGluZ3Mvb25kZW1hbmQnLFxuICAgIGZldGNoX21lZXRpbmdfdHlwZV9hbmFseXRpY3M6IHsgdXJsOiAnL2FuYWx5dGljcy9tZWV0aW5nc19ieV90eXBlJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgZmV0Y2hfbWVldGluZ190eXBlX2R1cmF0aW9uczogJy9jYWxlbmRhci9hdmFpbGFibGVfbWVldGluZ190eXBlcycsXG4gICAgZmV0Y2hfbWVldGluZ190eXBlczogJy9tZWV0aW5nX3R5cGVzL2xpc3QnLFxuICAgIGZldGNoX21lZXRpbmdzX2FuYWx5dGljczogJy9hbmFseXRpY3MvbWVldGluZ3MnLFxuICAgIGZldGNoX21pbmltdW1fdGltZXNsb3Q6ICcvc2V0dGluZy9taW5pbXVtX3RpbWVzbG90JyxcbiAgICBmZXRjaF9ub21pbmF0aW9uX2RldGFpbDogJy9ub21pbmF0aW9uL3tVVUlEfS97YWN0aW9ufS5qc29uJyxcbiAgICBmZXRjaF9ub3RpZmljYXRpb25fc2V0dGluZ3M6ICcvY29uZmlndXJlL25vdGlmaWNhdGlvbl9zZXR0aW5ncycsXG4gICAgZmV0Y2hfcG9ydGFsX2N1c3RvbV9mb3JtOiAnL2Zvcm1zJyxcbiAgICBmZXRjaF9wcmV2aWV3X21hcHBpbmdfZGV0YWlsOiAnL2NvbnRhaW5lci97VVVJRH0vZGV0YWlscy5qc29uJyxcbiAgICBmZXRjaF9wcmV2aWV3X21lZXRpbmdfZGV0YWlsOiAnL21lZXRpbmdfcmVxdWVzdC97VVVJRH0ve2FjdGlvbn0uanNvbicsXG4gICAgZmV0Y2hfcmVtb3RlX2VudGl0aWVzOiAnL2ZldGNoX3JlbW90ZV9lbnRpdGllcycsXG4gICAgZmV0Y2hfcmVxdWVzdG9yX2VtYWlsOiAnL2ZldGNoX3JlcXVlc3Rvcl9lbWFpbCcsXG4gICAgZmV0Y2hfcm9sZXNfYW5hbHl0aWNzOiAnL2FuYWx5dGljcy9yb2xlcycsXG4gICAgZmV0Y2hfcm9vbXNfYW5hbHl0aWNzOiAnL2FuYWx5dGljcy9yb29tcycsXG4gICAgZmV0Y2hfc2Nhbm5lZF91c2VyczogJy9mZXRjaF9zY2FubmVkX3VzZXJzJyxcbiAgICBmZXRjaF9zY2FubmVyc19uYW1lOiAnL3NjYW5uZXJzJyxcbiAgICBmZXRjaF9zdGFuZGFyZF9yZXBvcnQ6ICcvcmVwb3J0cy9zdGFuZGFyZF9yZXBvcnQnLFxuICAgIGZldGNoX3N1cnZleV90ZW1wbGF0ZTogJy9jb25maWd1cmUvY29uc29saWRhdGVkX3N1cnZleV9tYWlsX3NldHRpbmdzJyxcbiAgICBmZXRjaF9zdXJ2ZXlzOiAnL3N1cnZleXMnLFxuICAgIGZldGNoX3RhZ19jb25maWdzOiAnL2NvbmZpZ3VyZS90YWcnLFxuICAgIGZldGNoX3RhZ19lbnRpdHk6ICcvdGFncy97e3V1aWR9fS97e2VudGl0eX19JyxcbiAgICBmZXRjaF90b3BpY3M6ICcvdG9waWNzJyxcbiAgICBmZXRjaF90cmFja190b3BpY3M6ICcvdHJhY2tzL3t7dXVpZH19L3RvcGljcycsXG4gICAgZmV0Y2hfdHJhY2tfYWN0aXZpdGllczogJy90cmFja3Mve3t1dWlkfX0vYWN0aXZpdGllcycsXG4gICAgZmV0Y2hfdHJhbnNmZXJhYmxlX21lZXRpbmdfdHlwZXM6ICcvY29uZmlndXJlL2NoYW5nZV9tZWV0aW5nX3R5cGVfbGlua3MnLFxuICAgIGZldGNoX3VubWFwcGVkX3RvcGljX2VudGl0eTogJy9nZXRfbWVldGluZ3Nfd2l0aF91bm1hcHBlZF90b3BpY19lbnRpdHknLFxuICAgIGZldGNoX3VwZGF0ZV9icmllZmluZ19ub3RpZmljYXRpb25fc2V0dGluZ3M6ICcvY29uZmlndXJlL2JyaWVmaW5nX25vdGlmaWNhdGlvbl9zZXR0aW5ncycsXG4gICAgZmV0Y2hfdXNlcl9kZXRhaWxzOiAnL3VzZXJzL3t7dXVpZH19JyxcbiAgICBmZXRjaF91c2VyX2ZpZWxkX21hcHBpbmdzOiAnL2FkYXB0ZXJfdWkvZmV0Y2hfaW50ZWdyYXRpb25fY29uZmlncycsXG4gICAgZmV0Y2hfdXNlcl9mb3JtX3J1bGVzOiAnL3VzZXJfZm9ybV9maWVsZHMnLFxuICAgIGZldGNoX3VzZXJfbm90aWZpY2F0aW9uOiAnL3RlZGR5L25vdGlmaWNhdGlvbnMvc2V0dGluZ3MnLFxuICAgIGZldGNoX3VzZXJfdG9waWNzOiAnL3VzZXJfdG9waWNzJyxcbiAgICBmZXRjaF92YWxpZF9tYXBwaW5nX1RpbWVzOiAnL21hcHBpbmdzX3ZhbGlkX3N0YXJ0X3RpbWVzJyxcbiAgICBmZXRjaF9jb25mZXJlbmNlX2xpc3Q6ICcvaGFuZ291dC9jb25mZXJlbmNlcy9lbmFibGVkX2NvbmZlcmVuY2VzJyxcbiAgICBmZXRjaF9jb25mZXJlbmNlX2xpbms6ICcvaGFuZ291dC9jb25mZXJlbmNlcy9jb25mZXJlbmNlX2xpbmsnLFxuICAgIGZldGNoX3Jlc291cmNlX2RhdGE6IHt1cmw6ICcvYXBpL3YxL3Jlc291cmNlX2RhdGEvZmV0Y2gnLCBlcnJvckNvbmZpZzoge2hhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcid9fSxcbiAgICBmZXRjaF91c2VyX2N1c3RvbV9maWVsZF9tYXBwaW5nOiAnL2Zvcm1zL3VzZXIvZXh0X3JlcV9jb25maWcnLFxuICAgIGZpbGVfdXBsb2FkX3VybDogJy9hdHRhY2htZW50L3t0eXBlfScsXG4gICAgZmlsbF9idWxrX2NvbnNlbnQ6IHt1cmw6ICcvYXBpL3YxL3VzZXJzL3NldF9jb25zZW50X2RldGFpbHMnLCBlcnJvckNvbmZpZzoge2hhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcid9fSxcbiAgICBnZXRfYW5ub3VuY2VtZW50czogJy9zZXR0aW5nL2Fubm91bmNlbWVudCcsXG4gICAgZ2V0X2Jvb3RoX3RvdXJfZGV0YWlsczogJy9ib290aF90b3VyL2xpc3QnLFxuICAgIGdldF9icmllZmluZ19maWx0ZXJzOiAnL2JjL3tCQ1VVSUR9L2JyaWVmaW5nL2ZpbHRlcnMnLFxuICAgIGdldF9icmllZmluZ19yZXBvcnRfb3B0aW9uczogJy9iYy97QkNVVUlEfS9icmllZmluZy9maWx0ZXJfb3B0aW9ucycsXG4gICAgZ2V0X2NoZWNraW5fb3B0aW9uczogJy9jaGVja2luX2ZpbHRlcnMvZmlsdGVyX29wdGlvbnMnLFxuICAgIGdvb2dsZV9jaXR5X3NlYXJjaDogJy9nb29nbGVfY2xpZW50L2dlb19wbGFjZXMnLFxuICAgIGdvb2dsZV90aW1lX3pvbmVfc2VhcmNoOiAnL2dvb2dsZV9jbGllbnQvZ2VvX3RpbWV6b25lJyxcbiAgICBzZXRfdXNlcl9zZWNfdGltZV96b25lOiAnL3NldF91c2VyX3RpbWV6b25lJyxcbiAgICBnZXRfZWJjX3JvbGVfcHJpdmlsZWdlczogJy9hbGxfZWJjX3ByaXZpbGVnZXMnLFxuICAgIGdldF9zZWxmX3NlcnZlX3ByaXZpbGVnZXM6ICcvc2VsZl9zZXJ2ZV9wcml2aWxlZ2VzJyxcbiAgICBnZXRfZXh0X21lZXRpbmdfb3B0aW9uczogJy9leHRlcm5hbF9yZXF1ZXN0cy9maWx0ZXJfb3B0aW9ucycsXG4gICAgZ2V0X2V4dGVybmFsX3JlcV9kZXRhaWxzOiAnL2V4dGVybmFsX3JlcXVlc3Qve3V1aWR9L21lZXRpbmdfaW5mbycsXG4gICAgZ2V0X2V4dGVybmFsX3JlcXVlc3Q6ICcvZXh0ZXJuYWxfcmVxdWVzdC97dXVpZH0vdmlldycsXG4gICAgZ2V0X21lZXRpbmdfb3B0aW9uczogJy9tZWV0aW5nX2ZpbHRlcnMvZmlsdGVyX29wdGlvbnMnLFxuICAgIGdldF9tbV9saXN0OiAnL3VzZXJzL21hbmFnZXJzJyxcbiAgICBnZXRfb25kZW1hbmRfdXNlcnNfbGlzdDogJy91c2Vycy9vbmRlbWFuZF91c2VycycsXG4gICAgZ2V0X3JlcG9ydF9vcHRpb25zOiAnL3JlcG9ydHNfZmlsdGVycy9maWx0ZXJfb3B0aW9ucycsXG4gICAgZ2V0X3Jldmlld3M6ICcvcmV2aWV3YWJsZS9yZXZpZXdzJyxcbiAgICBnZXRfc3dhcHBhYmxlX3Jvb21fbGlzdDogJy9zd2FwX3Jvb20vbGlzdCcsXG4gICAgZ2V0X3RhZ19jbG91ZHM6ICcvdGFnX2Nsb3VkJyxcbiAgICBnZXRfdG9waWNzOiAnL2dldF90b3BpY3MnLFxuICAgIGdldF91c2VyX3ByZWZlcmVuY2VzOiAnL3VzZXJzL3t1dWlkfS91c2VyX3ByZWZlcmVuY2UnLFxuICAgIGdyb3VwX25vbWluYXRpb25fZWRpdDogJy9ub21pbmF0aW9uL3t7dXVpZH19L2VkaXQnLFxuICAgIGdyb3VwX25vbWluYXRpb25fdmlldzogJy9ub21pbmF0aW9uL3t7dXVpZH19L3ZpZXcnLFxuICAgIGluYWN0aXZhdGVfcm9vbXM6ICcvcm9vbXMvaW5hY3RpdmUnLFxuICAgIGluYWN0aXZhdGVfdXNlcnM6ICcvYXBpL3YxL3VzZXJzL2luYWN0aXZlJyxcbiAgICBpbnRlZ3JhdGlvbl9jb25maWd1cmF0aW9uc19kZXRhaWxzOiAnL2FkYXB0ZXJfdWkvaW50ZWdyYXRpb25fY29uZmlndXJhdGlvbnMnLFxuICAgIGludGVncmF0aW9uX2NvbmZpZ3VyYXRpb25zX3NjaGVtYTogJy9hZGFwdGVyX3VpL2ludGVncmF0aW9uX2NvbmZpZ3VyYXRpb25zX3NjaGVtYScsXG4gICAgaW50ZWdyYXRpb25fZXh0ZXJuYWxfdXNlcl9pbmZvOiAnL2ludGVncmF0aW9uX2V4dGVybmFsX3VzZXIve3VzZXJfcmVmX2lkfScsXG4gICAgaW50ZWdyYXRpb25fZmllbGRfbWFwcGluZ3M6ICcvaW50ZWdyYXRpb24vZmllbGRfbWFwcGluZ3MnLFxuICAgIGludGVncmF0aW9uOiAnL2FkYXB0ZXJfdWkvaW50ZWdyYXRpb25zJyxcbiAgICBpbnRlcm5hbF9hdHRlbmRlZXM6ICcvdXNlcnMvaW50ZXJuYWwnLFxuICAgIGpuX2Jvb2tfbWVldGluZzogJy9hcGV4L0pOQm9va01lZXRpbmcnLFxuICAgIGpuX3ZpZXdfYm9va19tZWV0aW5nOiAnL2FwZXgvSk5WaWV3TWVldGluZycsXG4gICAgbGlzdF9icmllZmluZ3NfYWdlbmRhOiAnL2JyaWVmaW5nL2xpc3RfYnJpZWZpbmdze1FVRVJZX1BBUkFNU30jL2xpc3RfYWdlbmRhJyxcbiAgICBsaXN0X3RyYWNrczogJy90cmFja3MvbGlzdCcsXG4gICAgbWFpbF90ZW1wbGF0ZV90eXBlX2VudGl0aWVzX2dldDogJy9tYWlsX2FjdGlvbi9nZXRfYXNzb2NpYXRlZF9lbnRpdGllcycsXG4gICAgbWFpbF90ZW1wbGF0ZV90eXBlX2dldDogJy9tYWlsX2FjdGlvbnMnLFxuICAgIG1hbmFnZV9leHRlcm5hbF91c2VyczogJy9tYW5hZ2VfZXh0ZXJuYWxfdXNlcnMnLFxuICAgIG1hbmFnZV91c2VyczogJy9tYW5hZ2V1c2VycycsXG4gICAgbWFudWFsX3JlbWluZGVyX3VzZXI6ICcvbWFudWFsX3JlbWluZGVyc191c2VycycsXG4gICAgbWFwcGFibGVfZ3JvdXBpbmdfdXNlcnM6ICcvcmVwb3J0cy9hbGxfdXNlcnMnLFxuICAgIG1hcHBhYmxlX3JlcXVlc3RvcnM6ICcvZmV0Y2hfcmVxdWVzdG9ycycsXG4gICAgbWFwcGFibGVfdXNlcnM6ICcvY29tbW9uX3V0aWxzL2ZldGNoX21hcHBhYmxlX3VzZXJzJyxcbiAgICBtYXBwZWRfZXZlbnRzOiAnL21hcHBhYmxlX2V2ZW50cycsXG4gICAgbWFwcGluZ19saXN0OiAnL2NvbnRhaW5lcl9tYXBwaW5nL2xpc3QnLFxuICAgIG1hcHBpbmdfcGFnZTogJy9tYXBwaW5nX2xpc3QnLFxuICAgIG1hcHBpbmdfdmFsaWRfZHVyYXRpb25zOiAnL21hcHBpbmdzX3ZhbGlkX2R1cmF0aW9ucycsXG4gICAgbWFwcGluZ3NfZXhwb3J0OiAnL2V4cG9ydGVyL2FwcG9pbnRtZW50JyxcbiAgICBtZWV0aW5nX2F2YWlsYWJpbGl0eTogJy9tZWV0aW5nX3JlcXVlc3QvY2FsZW5kYXInLFxuICAgIG1lZXRpbmdfY3JlYXRlOiAnL21lZXRpbmdfcmVxdWVzdC9jcmVhdGUnLFxuICAgIG1lZXRpbmdfZHJhZzogJy9jYWxlbmRhci9yZWxvY2F0ZScsXG4gICAgbWVldGluZ19mZXRjaDogJy9tZWV0aW5nX3JlcXVlc3Qve3t1dWlkfX0vc2hvdycsXG4gICAgbWVldGluZ19nZXRfY29uZmlnOiAnL2NvbmZpZ3VyZS97OnV1aWR9L21lZXRpbmdfdHlwZScsXG4gICAgbWVldGluZ19nZXRfc2V0dGluZ3M6ICcvc2V0dGluZy9hY3Rpdml0eScsXG4gICAgbWVldGluZ19oaXN0b3J5OiAnL21lZXRpbmdfcmVxdWVzdC97dXVpZH0vaGlzdG9yeScsXG4gICAgbWVldGluZ19ob3N0X2NvdW50OiAnL2dldF9tZWV0aW5nc193aXRoX21lZXRpbmdfaG9zdCcsXG4gICAgbWVldGluZ19saXN0OiAnL21lZXRpbmdfbGlzdCcsXG4gICAgbWVldGluZ19ub3RpZmljYXRpb25zOiAnL21lZXRpbmdfbm90aWZpY2F0aW9ucycsXG4gICAgbWVldGluZ19yZXF1ZXN0X2VkaXRfcGF0aDogJy9tZWV0aW5nX3JlcXVlc3Qve3V1aWR9L2VkaXQnLFxuICAgIG1lZXRpbmdfcmVxdWVzdF9leHBvcnQ6ICcvbWVldGluZ19yZXF1ZXN0L2V4cG9ydCcsXG4gICAgbWVldGluZ19yZXF1ZXN0X3BhdGg6ICcvbWVldGluZ19yZXF1ZXN0L25ldycsXG4gICAgbWVldGluZ19yZXF1ZXN0X3ZpZXdfcGF0aDogJy9tZWV0aW5nX3JlcXVlc3Qve3V1aWR9L3ZpZXcnLFxuICAgIG1lZXRpbmdfc2V0X2NvbmZpZzogJy9jb25maWd1cmUvezp1dWlkfS9tZWV0aW5nX3R5cGVfdXBkYXRlJyxcbiAgICBtZWV0aW5nX3NldF9zZXR0aW5nOiAnL3NldHRpbmcvYWN0aXZpdHlfdXBkYXRlJyxcbiAgICBtZWV0aW5nX3R5cGVfY3JlYXRlOiAnL21lZXRpbmdfdHlwZS9jcmVhdGUnLFxuICAgIG1lZXRpbmdfdHlwZV91cGRhdGU6ICcvbWVldGluZ190eXBlL3t1dWlkfS91cGRhdGUnLFxuICAgIG1lZXRpbmdfdHlwZXNfb2ZfY29uc2VjdXRpdmVfc3ViX21lZXRpbmdzOiAnL2NvbnNlY3V0aXZlX21lZXRpbmdzL21lZXRpbmdfdHlwZXMnLFxuICAgIG1lZXRpbmdfdHlwZXM6ICcvbWVldGluZ190eXBlcycsXG4gICAgbWVldGluZ3NfbGlzdF9maWx0ZXJzOiAnL21lZXRpbmdfcmVxdWVzdC9tZWV0aW5nX2ZpbHRlcnMnLFxuICAgIG1lZXRpbmdzX2xpc3Q6ICcvbWVldGluZ19yZXF1ZXN0cycsXG4gICAgbWlzY2VsbGFuZW91c19yZXBvcnRfZXhwb3J0OiAnL3JlcG9ydHMvbWlzY2VsbGFuZW91cy97dHlwZX0nLFxuICAgIG5vbl9ldmVudF9jb25maWd1cmF0aW9uczogJy9jYWxlbmRhci9jb25maWd1cmF0aW9ucycsXG4gICAgbm90aWZpY2F0aW9uX2ZldGNoOiAnL25vdGlmaWNhdGlvbnMnLFxuICAgIG9uX2JlaGFsZl9hY3Rpb25zOiAnL21lZXRpbmdfcmVxdWVzdC9vbl9iZWhhbGZfYWN0aW9ucycsXG4gICAgcG9ydGFsOiAnL3BvcnRhbCcsXG4gICAgcHJpbnRfdXNlcl9iYWRnZTogJy9wcmludF9iYWRnZScsXG4gICAgcmVnaXN0ZXJfdXNlcjogeyB1cmw6ICcvYXBpL3YxL3JlZ2lzdGVyL3VzZXInLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInIH0gfSxcbiAgICByZWludml0ZV9hdHRlbmRlZV90b19tZWV0aW5nOiAnL21lZXRpbmdfcmVxdWVzdC9yZWludml0ZScsXG4gICAgcmVpbnZpdGVfdXNlcnM6IHsgdXJsOiAnL2FwaS92MS91c2Vycy9yZWludml0ZScsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdzdW1tdXJ5RXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgcmVqZWN0X2V4dGVybmFsX3JlcXVlc3Q6ICcvZXh0ZXJuYWxfcmVxdWVzdC97dXVpZH0vcmVqZWN0JyxcbiAgICByZWplY3RfbG9jYXRpb25fcHJlZmVyZW5jZToge3VybDogJy9tZWV0aW5nX3JlcXVlc3Qve3t1dWlkfX0vcmVqZWN0X2xvY19wcmVmX3Byb3Bvc2FsJywgZXJyb3JDb25maWc6IHtoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInfSB9LFxuICAgIHJlbWluZGVyX25vdGlmX3NldHRpbmdzOiAnL3JlbWluZGVycy9hbGwvdGVtcGxhdGVzJyxcbiAgICByZW1vdmVfZnJvbV9ldmVudDogJy91c2Vycy9VVUlEL2luYWN0aXZlJyxcbiAgICByZW1vdmVfdXBsb2FkZWRfZmlsZV91cmw6ICcvYXR0YWNobWVudC97dXVpZH0nLFxuICAgIHJlbW92ZV91c2VyX2Zyb21fZXZlbnQ6ICcvdHJpZ2dlci91bm1hcCcsXG4gICAgcmVvcmRlcl9tZWV0aW5nX3R5cGVzOiAnL21lZXRpbmdfdHlwZS91cGRhdGVfb3JkZXInLFxuICAgIHJlcG9ydHM6IHtcbiAgICAgIHVuaWZpZWRfcmVwb3J0X2ZpbHRlcnM6ICcvcmVwb3J0cy91bmlmaWVkX3JlcG9ydF9maWx0ZXJzJyxcbiAgICAgIHVzZXJfbGlzdDogJy9yZXBvcnRzL3VzZXJzX2xpc3QnLFxuICAgICAgdW5pZmllZF9yZXBvcnQ6ICcvcmVwb3J0cy91bmlmaWVkX3JlcG9ydC57e2Zvcm1hdH19JyxcbiAgICAgIGZldGNoX3JlcG9ydF90ZW1wbGF0ZTogJy9yZXBvcnRfdGVtcGxhdGVzJyxcbiAgICAgIHVwbG9hZF9yZXBvcnRfdGVtcGxhdGU6ICcvcmVwb3J0X3RlbXBsYXRlcy97dGVtcGxhdGVfdHlwZX0vdXBsb2FkJyxcbiAgICAgIHVwZGF0ZV9yZXBvcnRfdGVtcGxhdGU6ICcvcmVwb3J0X3RlbXBsYXRlcy97dGVtcGxhdGVfdHlwZX0vdXBkYXRlJ1xuICAgIH0sXG4gICAgcmVwb3J0X3N1cnZleV9hY3Rpdml0eV9saXN0OiAnL3N1cnZleS9hY3Rpdml0eV9saXN0JyxcbiAgICByZXNjaGVkdWxlX21lZXRpbmc6ICcvbWVldGluZ19yZXF1ZXN0L3Jlc2NoZWR1bGUnLFxuICAgIHBhcnRpYWxfbWVldGluZ191cGRhdGU6ICcvbWVldGluZ19yZXF1ZXN0L3BhcnRpYWxfdXBkYXRlJyxcbiAgICByZXZpZXdlcl9tZWV0aW5nX2ZpbHRlcl9vcHRpb25zOiAnL3Jldmlld2FibGUvbWVldGluZ19maWx0ZXJzL2ZpbHRlcl9vcHRpb25zJyxcbiAgICByZXZpZXdlcl9tZWV0aW5nX2ZpbHRlcnM6ICcvcmV2aWV3YWJsZS9tZWV0aW5nX2ZpbHRlcnMnLFxuICAgIHJldmlld2VyX21lZXRpbmdzOiAnL3Jldmlld2FibGUvbWVldGluZ19yZXF1ZXN0cycsXG4gICAgcm9sZV9jcmVhdGU6ICcvcm9sZS9jcmVhdGUnLFxuICAgIHJvbGVfZGlzYWJsZTogJy9yb2xlL3s6dXVpZH0vZGlzYWJsZScsXG4gICAgcm9sZV9lbmFibGU6ICcvcm9sZS97OnV1aWR9L2VuYWJsZScsXG4gICAgcm9sZV9nZXRfYWxsX3ByaXZpbGVnZXM6ICcvYWxsX3ByaXZpbGVnZXMnLFxuICAgIHJvbGVfZ2V0X3ByaXZpbGVnZXM6ICcvcm9sZS97OnV1aWR9L2dldF9wcml2aWxlZ2VzJyxcbiAgICByb2xlX3NldF9wcml2aWxlZ2VzOiAnL3JvbGUvezp1dWlkfS9zZXRfcHJpdmlsZWdlcycsXG4gICAgcm9sZV91cGRhdGU6ICcvcm9sZS91cGRhdGUnLFxuICAgIHJvbGVzX2ZldGNoOiAnL3JvbGVzJyxcbiAgICByb29tX2FjdGl2aXRpZXM6ICcvYWN0aXZpdGllc19yb29tcycsXG4gICAgcm9vbV9hdmFpbGFiaWxpdHk6ICcvY2FsZW5kYXIvcm9vbXMnLFxuICAgIHJvb21fY2FsZW5kYXJfZXhwb3J0OiAnL2NhbGVuZGFyL3Jvb21zL2V4cG9ydCcsXG4gICAgcm9vbV9jcmVhdGU6ICcvcm9vbS9jcmVhdGUnLFxuICAgIHJvb21fZmlsdGVyczogJy9yb29tL2ZpbHRlcl9vcHRpb25zJyxcbiAgICByb29tX21ha2VfYXZhaWxhYmxlOiAnL2NhbGVuZGFyL21ha2VfYXZhaWxhYmxlJyxcbiAgICByb29tX21ha2VfdW5hdmFpbGFibGU6ICcvY2FsZW5kYXIvbWFrZV91bmF2YWlsYWJsZScsXG4gICAgcm9vbV91bmJsb2NrOiAnL2NhbGVuZGFyL3VuYmxvY2snLFxuICAgIHJvb21fdXBkYXRlOiAnL3Jvb20vdXBkYXRlJyxcbiAgICByb29tc19leHBvcnQ6ICcvZXhwb3J0ZXIvcm9vbScsXG4gICAgcm9vbXNfbGlzdDogJy9yb29tcy9saXN0JyxcbiAgICBzYXZlX2Zvcm06ICcvY3VzdG9tX2Zvcm0vdXBkYXRlJyxcbiAgICBzYXZlX3BvcnRhbF9jdXN0b21fZm9ybTogJy9mb3JtL3VwZGF0ZScsXG4gICAgc2F2ZV9wcmludGVyX25hbWU6ICcvc2F2ZV9wcmludGVyX25hbWUnLFxuICAgIHNhdmVfcHJvZmlsZV9wcmVmZXJlbmNlczogJy91c2VyX2Zvcm1fZmllbGRzL3VwZGF0ZScsXG4gICAgc2F2ZV91c2VyX2ZpZWxkX21hcHBpbmdzOiAnL2NyZWF0ZV9vcl91cGRhdGVfaW50ZWdyYXRpb25fY29uZmlndXJhdGlvbicsXG4gICAgc2F2ZWRfcmVwb3J0X2RldGFpbHM6ICcvdXNlcl90ZW1wbGF0ZS9kZXRhaWxzJyxcbiAgICBzZW5kX2J1bGtfc3VydmV5X21lZXRpbmdfbWFpbDogJy9tZWV0aW5nX3JlcXVlc3Qvc2VuZF9zdXJ2ZXlfbWFpbC9idWxrX2FjdGlvbicsXG4gICAgc2VuZF9yZXF1ZXN0b3JfZW1haWw6IHsgdXJsOiAnL21lZXRpbmdfcmVxdWVzdC9zZW5kX2VtYWlsX3RvX3JlcXVlc3RvcicsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHNlbmRfc3VydmV5X21lZXRpbmdfbWFpbDogJy9tZWV0aW5nX3JlcXVlc3Qve1VVSUR9L3NlbmRfc3VydmV5X21haWwnLFxuICAgIHNlc3Npb25fY2hlY2tpbl9saXN0OiAnL3Nlc3Npb25fY2hlY2tpbl9saXN0JyxcbiAgICBzZXNzaW9uX2V4cG9ydDogJy9zZXNzaW9uL2V4cG9ydCcsXG4gICAgc2Vzc2lvbl9saXN0OiAnL3Nlc3Npb25fbGlzdCcsXG4gICAgc2Vzc2lvbl9ub21pbmF0aW9uczogJy9ncm91cF9ub21pbmF0aW9ucycsXG4gICAgc2Vzc2lvbnNfbGlzdDogJy9zZXNzaW9ucycsXG4gICAgc2V0X2Fubm91bmNlbWVudHM6ICcvc2V0dGluZy9hbm5vdW5jZW1lbnRfdXBkYXRlJyxcbiAgICBzZXRfcGFydGljaXBhdGlvbl9tYXNjYWw6ICcvbWVldGluZ19yZXF1ZXN0L3NldF9wYXJ0aWNpcGF0aW9uJyxcbiAgICBzZXRfcGFydGljaXBhdGlvbjogeyB1cmw6ICcvbWVldGluZ19yZXF1ZXN0L3NldF9wYXJ0aWNpcGF0aW9uJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgc2V0X3JlbWluZGVyOiAnL3NldF9yZW1pbmRlcicsXG4gICAgc2V0X3VzZXJfY2lzX3N0YXR1czogJy9zZXRfdXNlcl9jaXNfc3RhdHVzL3t7aWR9fScsXG4gICAgc2V0X3VzZXJfcHJlZmVyZW5jZXM6ICcvdXNlcnMve3V1aWR9L3VzZXJfcHJlZmVyZW5jZScsXG4gICAgc2ZkY19jdXN0b21fbGFiZWxzOiB7dXJsIDogJy9zZmRjX2N1c3RvbV9sYWJlbHNfY29uZmlndXJhdGlvbnMnLCBlcnJvckNvbmZpZyA6IHtoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInfX0sXG4gICAgc2hvd19pbl9tZWV0aW5nX2V4dGVybmFsX2F0dGVuZGVlOiB7IHVybDogJy9jb25maWd1cmUvc2hvd19pbl9tZWV0aW5nX2V4dGVybmFsX2F0dGVuZGVlJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgc2luZ2xlX21hc3Rlcl9jYWxlbmRhcl9lbnRpdHlfc2VhcmNoOiAnbWFzdGVyX2NhbGVuZGFyL3tlbnRpdHlUeXBlfV9zZWFyY2gnLFxuICAgIHN0YW5kYXJkX3JlcG9ydF9leHBvcnRfdXJsOiAnL3VzZXJzL21lZXRpbmdzLnBkZj91c2VyX3V1aWQ9e3t1dWlkfX0nLFxuICAgIHN0YW5kYXJkX3JlcG9ydF9nZW5lcmF0ZV91cmw6ICcvYXBpL3YxL3N0YW5kYXJkX3JlcG9ydC9nZW5lcmF0ZS5wZGY/dXNlcl91dWlkPXt7dXVpZH19JyxcbiAgICBzdXJ2ZXlfY3JlYXRlOiAnL3N1cnZleV9tYXN0ZXJzJyxcbiAgICBzdXJ2ZXlfcmVzcG9uc2VzOiAnc3VydmV5X3Jlc3BvbnNlcycsXG4gICAgc3VydmV5X3VwZGF0ZTogJy9zdXJ2ZXlfbWFzdGVycy97dXVpZH0nLFxuICAgIHN3YXBfcm9vbV9zdWJtaXQ6ICcvc3dhcF9yb29tL3N3YXAnLFxuICAgIHN5c3RlbV9jb25maWd1cmF0aW9uczogJy9jb25maWd1cmF0aW9ucy9zeXN0ZW1fY29uZmlndXJhdGlvbicsXG4gICAgc3RhbmRhcmRfcmVwb3J0X2V4cG9ydF9ieV9tZWV0aW5nOiAnL2FwaS92MS9tZWV0aW5ncy9zdGFuZGFyZF9yZXBvcnQucGRmJyxcbiAgICB0aW1lX3pvbmVfdXJsOiAnL3RpbWVfem9uZScsXG4gICAgdGltZWxpbmVfZGF0YTogJy9jYWxlbmRhci90aW1lbGluZV9kYXRhJyxcbiAgICB0YWdfY3JlYXRlX29yX3VwZGF0ZTogJy90YWdzJyxcbiAgICB0YWdfZWRpdDogJy90YWdzL3t7dXVpZH19L2VkaXQnLFxuICAgIHRhZ19saXN0OiAnL3RhZ3MnLFxuICAgIHRhZ19saXN0aW5nX3BhZ2U6ICcvdGFnL2xpc3RpbmcnLFxuICAgIHRlbXBsYXRlX3VwbG9hZF91cmw6ICdyZXBvcnRfdGVtcGxhdGVzL3t0ZW1wbGF0ZV90eXBlfS91cGxvYWQnLFxuICAgIHRpbWVfem9uZV91cmw6ICcvdGltZV96b25lJyxcbiAgICB0aW1lbGluZV9kYXRhOiAnL2NhbGVuZGFyL3RpbWVsaW5lX2RhdGEnLFxuICAgIHRvcGljX3VwbG9hZDogJy90b3BpY3MvaW1wb3J0JyxcbiAgICB0b3BpY19jb25maWd1cmF0aW9uczogeyB1cmw6ICcvdG9waWNfY29uZmlndXJhdGlvbnMnLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnc3VtbXVyeUVycm9ySGFuZGxlcicgfSB9LFxuICAgIHRyYWNrX2FjdGl2aXRpZXM6ICcvZ2V0X3RyYWNrX2FjdGl2aXRpZXMnLFxuICAgIHRyYWNrc19saXN0OiAnL3RyYWNrcycsXG4gICAgdHJpZ2dlcl9zeW5jOiAnL3RyaWdnZXJfc3luYycsXG4gICAgdHJpZ2dlcl93ZWxjb21lX2VtYWlsX3VzZXJzOiB7IHVybDogJy9hcGkvdjEvdXNlcnMvc2VuZF93ZWxjb21lX2VtYWlsJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdWlfZ2V0X3NldHRpbmdzOiAnL3NldHRpbmcvdWknLFxuICAgIHVpX3NldF9zZXR0aW5nOiAnL3NldHRpbmcvdWlfdXBkYXRlJyxcbiAgICB1cGRhdGVfYWN0aXZpdHlfc2V0dGluZ3M6ICcvY29uZmlndXJlL2FjdGl2aXR5X3NldHRpbmcnLFxuICAgIHVwZGF0ZV9hbmFseXRpY3NfY29uZmlnczogeyB1cmw6ICcvYW5hbHl0aWNzX2Rhc2hib2FyZC91cGRhdGVfY29uZmlnJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXBkYXRlX2JyaWVmaW5nX3dvcmtmbG93OiAnL2NvbmZpZ3VyZS9icmllZmluZ19zZXR0aW5ncycsXG4gICAgdXBkYXRlX2NhbGVuZGFyX3NldHRpbmdzOiAnL2NvbmZpZ3VyZS9jYWxlbmRhcl9zZXR0aW5ncy97e3V1aWR9fS91cGRhdGUnLFxuICAgIHVwZGF0ZV9jaGVja2luX3N0YXR1czogJy9jaGVja2luL3RvZ2dsZV9jaGVja2luJyxcbiAgICB1cGRhdGVfY29tcGFueV9mb3JtOiAnL2NvbXBhbnkvdXBkYXRlX2NvbXBhbnlfY29uZmlncycsXG4gICAgdXBkYXRlX2NvbmNpZXJnZV9mb3JtOiAnL2NvbmNpZXJnZV9zZXJ2aWNlcy97e3V1aWR9fS91cGRhdGVfY3VzdG9tX2Zvcm0nLFxuICAgIHVwZGF0ZV9jb25jaWVyZ2Vfbm90aWZpY2F0aW9uX3NldHRpbmdzOiAnL2NvbmNpZXJnZV9zZXJ2aWNlcy97e3V1aWR9fS91cGRhdGVfbm90aWZpY2F0aW9uX3NldHRpbmdzJyxcbiAgICB1cGRhdGVfY29uZmlnX2NoYW5nZV9tZWV0aW5nX3R5cGU6ICcvY29uZmlndXJlL2NoYW5nZV9tZWV0aW5nX3R5cGUnLFxuICAgIHVwZGF0ZV9jb25maWc6IHsgdXJsOiAnL2NvbmZpZy91cGRhdGVfY29uZmlnL3t7Y29uZmlnX3R5cGV9fScsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHVwZGF0ZV9jb25maWd1cmF0aW9uOiB7IHVybDogJy91cGRhdGVfY29uZmlndXJhdGlvbicsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdzdW1tdXJ5RXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXBkYXRlX2N1c3RvbV9yZXBvcnRzOiAnL3VzZXJfdGVtcGxhdGUvdXBkYXRlJyxcbiAgICB1cGRhdGVfZG91YmxlX2Jvb2tpbmdfY29uZmlnOiB7IHVybDogJy9jb25maWd1cmUvZG91YmxlX2Jvb2tpbmcnLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInIH0gfSxcbiAgICB1cGRhdGVfZW5kb3JzZW1lbnRfY29uZmlnOiB7IHVybDogJy9jb25maWd1cmUvZW5kb3JzZW1lbnQnLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInIH0gfSxcbiAgICB1cGRhdGVfZXZlbnRfYWNjZXNzOiB7IHVybDogJy9hcGkvdjEvdXBkYXRlX2V2ZW50X2FjY2VzcycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHVwZGF0ZV9ldmVudF92aXNpYmlsaXR5OiAnL3JvbGUve3t1dWlkfX0vZXZlbnRfdmlzaWJpbGl0eScsXG4gICAgdXBkYXRlX2V4dGVybmFsX21lZXRpbmc6ICcvY29uZmlnL2V4dGVybmFsX21lZXRpbmcnLFxuICAgIHVwZGF0ZV9leHRlcm5hbF9yZXF1ZXN0X2Zvcm06ICcvdXBkYXRlX2V4dGVybmFsX3dpZGdldCcsXG4gICAgdXBkYXRlX2N1c3RvbV9mb3JtOiAnL3VwZGF0ZV9jdXN0b21fZm9ybScsXG4gICAgdXBkYXRlX2Zvcm1fc2V0dGluZ3M6ICcvY29uZmlndXJlL2Zvcm1fc2V0dGluZ3Mve3t1dWlkfX0vdXBkYXRlJyxcbiAgICB1cGRhdGVfbG9jYXRpb25fY29uZmlnczogJy9jb25maWcvdXBkYXRlX2xvY2F0aW9uJyxcbiAgICB1cGRhdGVfbWFpbF90ZW1wbGF0ZTogJy9tYWlsX3RlbXBsYXRlL3VwZGF0ZScsXG4gICAgdXBkYXRlX21hbnVhbF9zY2hlZHVsaW5nOiAnL2NvbmZpZy9tYW51YWxfc2NoZWR1bGluZycsXG4gICAgdXBkYXRlX21hcHBpbmdfbW9kdWxlX2NvbmZpZzogJy9tZWV0aW5nX3R5cGUve2FjdGl2aXR5X3V1aWR9L21hcHBpbmdfbW9kdWxlX2NvbmZpZ3MnLFxuICAgIHVwZGF0ZV9tYXBwaW5nX21vZHVsZTogeyB1cmw6ICcvY29uZmlndXJlL21hcHBpbmdfbW9kdWxlJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXBkYXRlX3ZpcnR1YWxfZXZlbnQ6IHsgdXJsOiAnL2V2ZW50L2VuYWJsZV92aXJ0dWFsJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdHJpZ2dlcl92aXJ0dWFsX2V2ZW50X2VtYWlsOiB7IHVybDogJy9ldmVudC90cmlnZ2VyX21haWxfdmlydHVhbF9ldmVudCcsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHVwZGF0ZV9taW5pbXVtX3RpbWVzbG90OiAnL3NldHRpbmcvbWluaW11bV90aW1lc2xvdF91cGRhdGUnLFxuICAgIHVwZGF0ZV9ub3RpZmljYXRpb25fc2V0dGluZ3M6ICcvY29uZmlndXJlL25vdGlmaWNhdGlvbl9zZXR0aW5nJyxcbiAgICB1cGRhdGVfcmV2aWV3OiAnL3Jldmlld2FibGUvcmV2aWV3JyxcbiAgICB1cGRhdGVfc3VydmV5X2Zvcm06ICcvc3VydmV5X3Jlc3BvbnNlL3t1dWlkfScsXG4gICAgdXBkYXRlX3N1cnZleV90ZW1wbGF0ZTogJy9jb25maWd1cmUvY29uc29saWRhdGVkX3N1cnZleV9tYWlsX3NldHRpbmcnLFxuICAgIHVwZGF0ZV90YWdfY29uZmlnczogJy9jb25maWcvdXBkYXRlX3RhZycsXG4gICAgdXBkYXRlX3RyYWNrX2NvbmZpZzogeyB1cmw6ICcvY29uZmlndXJlL3RyYWNrcycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHVwZGF0ZV90cmFja19sYWJlbDogeyB1cmw6ICcvY29uZmlndXJlL3RyYWNrX2xhYmVsJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXBkYXRlX3RyYW5zZmVyYWJsZV9tZWV0aW5nX3R5cGVzOiB7IHVybDogJy9jb25maWd1cmUvY2hhbmdlX21lZXRpbmdfdHlwZV9saW5rcycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHVwZGF0ZV91c2VyX25vdGlmX3NldHRpbmdzOiAnL3VzZXJfc2V0dGluZy9ub3RpZmljYXRpb25fc2V0dGluZycsXG4gICAgdXBkYXRlX3VzZXJfbm90aWZpY2F0aW9uOiAnL3RlZGR5L25vdGlmaWNhdGlvbnMvc2V0dGluZ3MnLFxuICAgIHVwZGF0ZV91c2VyX3Byb2ZpbGU6ICcvdXNlci97e3V1aWR9fScsXG4gICAgdXBkYXRlX3VzZXJfcmVnaXN0cmF0aW9uOiAnL2NvbXBhbnkvdXBkYXRlX3VzZXJfcmVnaXN0ZXJfY29uZmlncycsXG4gICAgdXBsb2FkX2FnZW5kYV9pdGVtX2NzdjogJy9tZWV0aW5nX3JlcXVlc3QvaW1wb3J0JyxcbiAgICB1cGxvYWRfbWFwcGluZ19jc3Y6ICcvc3BlY2lhbF9hcHBvaW50bWVudC9pbXBvcnQnLFxuICAgIHVwbG9hZF9yb29tX2NzdjogJy9yb29tL2ltcG9ydCcsXG4gICAgdXBsb2FkX3VzZXJfdG9waWNfY3N2OiB7IHVybDogJy9hcGkvdjEvdXNlcnMvaW1wb3J0X3VzZXJfdG9waWNfbWFwcGluZycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHVwbG9hZF9lYV9hdHRlbmRlZV9tYXBwaW5nX2NzdjogeyB1cmw6ICcvdXNlci9idWxrX2ltcG9ydF9lYV9hdHRlbmRlZV9tYXBwaW5nJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXBsb2FkX3VzZXJfY3N2OiB7IHVybDogJy9jb21tb25fdXRpbHMvdXNlcnMvaW1wb3J0JywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXNlcl9ibG9jazogJy9jYWxlbmRhci9ibG9jaycsXG4gICAgdXNlcl9jYWxlbmRhcl9leHBvcnQ6ICcvY2FsZW5kYXIvdXNlcnMvZXhwb3J0JyxcbiAgICB1c2VyX2NyZWF0ZTogJy91c2VyL2NyZWF0ZScsXG4gICAgdXNlcl9jc3ZfdGVtcGxhdGU6ICcvcG9ydGFsL3VzZXIvY3N2X3RlbXBsYXRlJyxcbiAgICBlYV9hdHRlbmRlZV9tYXBwaW5nOiAnL3VzZXIvZWFfYXR0ZW5kZWVfY3N2X3RlbXBsYXRlJyxcbiAgICB1c2VyX2V4cG9ydDogJy9hcGkvdjEvdXNlcnMvZXhwb3J0JyxcbiAgICBlYV9hdHRlbmRlZV9tYXBwaW5nX2V4cG9ydDogJy91c2VyL2VhX2F0dGVuZGVlX21hcHBpbmdfZXhwb3J0JyxcbiAgICB1c2VyX2ZpbHRlcnM6IHsgdXJsOiAnL2NvbW1vbl91dGlscy91c2Vycy9maWx0ZXJzJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXNlcl9oaXN0b3J5OiB7IHVybDogJy91c2VyL3t1dWlkfS9oaXN0b3J5JywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXNlcl9tYWtlX2F2YWlsYWJsZTogJy9jYWxlbmRhci9tYWtlX2F2YWlsYWJsZScsXG4gICAgdXNlcl9tYWtlX3VuYXZhaWxhYmxlOiAnL2NhbGVuZGFyL21ha2VfdW5hdmFpbGFibGUnLFxuICAgIHVzZXJfbm90aWZfc2V0dGluZ3M6ICcvdXNlcl9zZXR0aW5nL25vdGlmaWNhdGlvbl9zZXR0aW5ncycsXG4gICAgdXNlcl91bmJsb2NrOiAnL2NhbGVuZGFyL3VuYmxvY2snLFxuICAgIHVzZXJfdXBkYXRlOiAnL3VzZXJzL3t7dXVpZH19L3VwZGF0ZScsXG4gICAgdXNlcnNfZXZlbnRzX2ZpbHRlcnM6ICcvdXNlcnNfZXZlbnRzX2ZpbHRlcnMnLFxuICAgIHVzZXJzX2V2ZW50czogJy91c2Vyc19ldmVudHMnLFxuICAgIHVzZXJzOiB7IHVybDogJy9jb21tb25fdXRpbHMvdXNlcnMvbGlzdCcsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHZhbGlkYXRlX3Jvb21fY2FwYWNpdHk6ICcvcm9vbS92YWxpZGF0ZScsXG4gICAgY29tcGxpYW5jZV9jb25maWd1cmF0aW9uOiB7IHVybDogJy9jb21wbGlhbmNlL2NvbmZpZ3VyYXRpb25zJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgZmV0Y2hfYWNjb3VudDogJy9hcGkvdjEvYWNjb3VudHMnLFxuICAgIGZldGNoX29wcG9ydHVuaXR5OiAnL2FwaS92MS9vcHBvcnR1bml0aWVzJyxcbiAgICBzdXBwb3J0ZWRfYXBpX2RldGFpbDogJy9hZGFwdGVyX3VpL3N1cHBvcnRlZF9hcGlfZGV0YWlscycsXG4gICAgam5faW50ZWdyYXRpb25fZmllbGRzOiAnL2FkYXB0ZXJfdWkvbWFwcGluZ3MnLFxuICAgIHNhdmVfYXV0aF9mb3JtOiAnL2FkYXB0ZXJfdWkvaW50ZWdyYXRpb25zL3NhdmVfYXV0aF9maWVsZHMnLFxuICAgIHVwZGF0ZV9pbnRfY29uZmlnOiAodXVpZCkgPT4gYC9hZGFwdGVyX3VpL2ludGVncmF0aW9uLyR7dXVpZH0vc3RhdHVzYCxcbiAgICByb29tX2Jsb2NrOiAnL2FwaS92MS9yb29tL2ludGVyaW1fYmxvY2snLFxuICAgIHBlbmRvX25wc19jb25zZW50OiAnL2Rhc2hib2FyZC9wZW5kb19ucHMnLFxuICAgIGdldF9nZHByX21lc3NhZ2U6ICcvY29uZmlndXJhdGlvbi9wcml2YWN5X21lc3NhZ2VzJyxcbiAgICBmZXRjaF9yZWdpc3RlcmVkX2ludGVncmF0aW9uOiAnL2FkYXB0ZXJfdWkvZW5hYmxlZF9iYWRnZV9zY2FucycsXG4gICAgZmV0Y2hfaW50ZWdyYXRpb25fYXZhaWxhYmxlX2ZpbGVkczogJy9hZGFwdGVyX3VpL3N1cHBvcnRlZF9hcGlfZGV0YWlscy9wYXJzZV9zY2hlbWEnLFxuICAgIGZldGNoX2F2YWlsYWJsZV9jb25mZXJlbmNlczogJy9oYW5nb3V0L2NvbmZlcmVuY2VzJyxcbiAgICBjcmVhdGVfY29uZmVyZW5jZTogJy9oYW5nb3V0L2NvbmZlcmVuY2VzLydcbiAgfSxcblxuICBBUElfY2FjaGUgOiB7fSxcblxuICBzdW1tdXJ5RXJyb3JIYW5kbGVyOiBmdW5jdGlvbiAodXJsLCByZXNwb25zZSwgZXJyb3JDb25maWdzKSB7XG4gICAgdmFyIGVycm9ySnNvbiA9IHJlc3BvbnNlLnJlc3BvbnNlSlNPTlxuICAgIHZhciBtb2RlbEVsID0gJCgnLm5vdGlmaWNhdGlvbi1tb2RhbCcpXG4gICAgbW9kZWxFbC5ub3RpZmljYXRpb25Nb2RhbCh7XG4gICAgICB0eXBlOiAnbm90aWZpY2F0aW9uJyxcbiAgICAgIHRpdGxlOiBlcnJvckNvbmZpZ3MuY3VzdG9tX3RpdGxlIHx8IGkxOG4udCgnZmFpbHVyZScpLFxuICAgICAgYm9keTogZXJyb3JDb25maWdzLmN1c3RvbV9tZXNzYWdlIHx8IGVycm9ySnNvbi5tZXNzYWdlLFxuICAgICAgY2xhc3M6ICdyZWQnXG4gICAgfSlcbiAgfSxcblxuICBkZXRhaWxlZEVycm9ySGFuZGxlcjogZnVuY3Rpb24gKHVybCwgcmVzcG9uc2UsIGVycm9yQ29uZmlncykge1xuICAgIHZhciBlcnJvckpzb24gPSByZXNwb25zZS5yZXNwb25zZUpTT05cbiAgICB2YXIgZXJyb3JNc2dcbiAgICB0cnkge1xuICAgICAgZXJyb3JNc2cgPSBfLmZsYXR0ZW4oXy52YWx1ZXMoZXJyb3JKc29uLmVycm9ycy5kZXRhaWxzKSkuam9pbignPC9icj4nKVxuICAgIH0gY2F0Y2ggKGVycikge1xuICAgICAgZXJyb3JNc2cgPSAnJ1xuICAgIH1cbiAgICB2YXIgbW9kZWxFbCA9ICQoJy5ub3RpZmljYXRpb24tbW9kYWwnKVxuICAgIG1vZGVsRWwubm90aWZpY2F0aW9uTW9kYWwoe1xuICAgICAgdHlwZTogJ25vdGlmaWNhdGlvbicsXG4gICAgICB0aXRsZTogZXJyb3JDb25maWdzLmN1c3RvbV90aXRsZSB8fCBpMThuLnQoJ2ZhaWx1cmUnKSxcbiAgICAgIGJvZHk6IGVycm9yQ29uZmlncy5jdXN0b21fbWVzc2FnZSB8fCBlcnJvck1zZyxcbiAgICAgIGNsYXNzOiAncmVkJ1xuICAgIH0pXG4gIH0sXG5cbiAgcmVwbGFjZVVybFBhcmFtczogZnVuY3Rpb24gKCkge1xuICAgIHZhciB1cmxFbmRwb2ludCA9IF8uY2xvbmVEZWVwKGFyZ3VtZW50c1swXSlcbiAgICBpZiAodHlwZW9mIHVybEVuZHBvaW50ICE9PSAnb2JqZWN0Jykge1xuICAgICAgdXJsRW5kcG9pbnQgPSB7IHVybDogdXJsRW5kcG9pbnQgfVxuICAgIH1cbiAgICBmb3IgKHZhciBpID0gMTsgaSA8IGFyZ3VtZW50cy5sZW5ndGg7IGkrKykge1xuICAgICAgdXJsRW5kcG9pbnQudXJsID0gdXJsRW5kcG9pbnQudXJsLnJlcGxhY2UoYXJndW1lbnRzW2ldWzBdLCBhcmd1bWVudHNbaV1bMV0pXG4gICAgfVxuICAgIHJldHVybiB1cmxFbmRwb2ludFxuICB9LFxuXG4gIHVwZGF0ZTogZnVuY3Rpb24gKG9wdGlvbnMpIHtcblxuICAgIGlmIChvcHRpb25zLmRhdGEgJiYgb3B0aW9ucy5kYXRhLmNvbnN0cnVjdG9yID09PSBGb3JtRGF0YSkge1xuICAgICAgICBvcHRpb25zLmRhdGEuYXBwZW5kKCdjdXJyZW50X2xvY2F0aW9uX3V1aWQnLCBlbnZEZXRhaWxzLmN1cnJlbnRfbG9jYXRpb25fdXVpZClcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIF8ubWVyZ2Uob3B0aW9ucywgeyBkYXRhOiB7IGN1cnJlbnRfbG9jYXRpb25fdXVpZDogZW52RGV0YWlscy5jdXJyZW50X2xvY2F0aW9uX3V1aWQgfSB9KVxuICAgIH1cblxuICAgIGlmICh0eXBlb2Ygb3B0aW9ucy51cmwgPT09ICdvYmplY3QnKSB7XG4gICAgICB2YXIgZXJyb3JIYW5kbGVyQ29uZmlncyA9IHt9XG4gICAgICB2YXIgZXJyb3JIYW5kbGVyRm5cbiAgICAgIGlmICh0eXBlb2Ygb3B0aW9ucy51cmwuZXJyb3JDb25maWcgPT09ICdvYmplY3QnKSB7XG4gICAgICAgIGVycm9ySGFuZGxlckZuID0gdGhpc1tvcHRpb25zLnVybC5lcnJvckNvbmZpZy5oYW5kbGVyXVxuICAgICAgICBlcnJvckhhbmRsZXJDb25maWdzID0gb3B0aW9ucy51cmwuZXJyb3JDb25maWdcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGVycm9ySGFuZGxlckZuID0gdGhpc1tvcHRpb25zLnVybC5lcnJvckNvbmZpZ11cbiAgICAgIH1cbiAgICAgIG9wdGlvbnMudXJsID0gb3B0aW9ucy51cmwudXJsXG4gICAgfVxuXG4gICAgb3B0aW9ucyA9IF8uYXNzaWduKHtcbiAgICAgIGRhdGFUeXBlOiAnanNvbicsXG4gICAgICB0eXBlOiBvcHRpb25zLm1ldGhvZCB8fCAncG9zdCcsXG4gICAgICB1cmw6ICcvZXZlbnRzJyxcbiAgICAgIGVycm9ySGFuZGxlckZuOiBlcnJvckhhbmRsZXJGbixcbiAgICAgIGVycm9ySGFuZGxlckNvbmZpZ3M6IGVycm9ySGFuZGxlckNvbmZpZ3MsXG4gICAgICBkYXRhOiB7IGV2ZW50OiBudWxsIH0sXG4gICAgICBwcmVmaXg6IGVudkRldGFpbHNbJ3VybFByZWZpeCddXG4gICAgfSwgb3B0aW9ucylcbiAgICBcbiAgICBpZihvcHRpb25zLnJlcV9zdHJpbmdpZnkpIHtcbiAgICAgIG9wdGlvbnMuZGF0YSA9IEpTT04uc3RyaW5naWZ5KG9wdGlvbnMuZGF0YSlcbiAgICB9XG5cbiAgICBpZiAoIS9eaHR0cHM/Ly50ZXN0KG9wdGlvbnNbJ3VybCddKSkge1xuICAgICAgb3B0aW9uc1sndXJsJ10gPSBvcHRpb25zWydwcmVmaXgnXSArIG9wdGlvbnNbJ3VybCddXG4gICAgfVxuICAgIC8vIFRPRE86IE5lZWQgYSBmaXggaGVyZSB0byBjb25zaWRlciBzaG93aW5nIGxvYWRlciBzZWN0aW9uIGxvYWRlciBhbmQgaGFuZGxpbmcgYWJvcnQgd2l0aCBvbmx5IG9uZSBhcmd1bWVudCBjaGVjay5cbiAgICBvcHRpb25zLnNlY3Rpb25Mb2FkZXIgJiYgdGhpcy5zZXRQYWdlTG9hZGVyKG9wdGlvbnMpXG4gICAgdmFyIHByb21pc2UgPSAkLmFqYXgob3B0aW9ucylcbiAgICBpZihvcHRpb25zLmFib3J0U2VxdWVudGlhbENhbGxzKSB7XG4gICAgICB0aGlzLmFkZFJlbW92ZUNhY2hlKG9wdGlvbnNbJ3VybCddLCBwcm9taXNlKVxuICAgICAgcHJvbWlzZS50aGVuKCgpID0+IHtcbiAgICAgICAgdGhpcy5VaUFjdGlvbnNPblVwZGF0ZShvcHRpb25zKVxuICAgICAgfSlcbiAgICB9XG4gICAgcmV0dXJuIHByb21pc2VcbiAgfSxcblxuICBmZXRjaDogZnVuY3Rpb24gKG9wdGlvbnMpIHtcbiAgICBpZiAodHlwZW9mIG9wdGlvbnMudXJsID09PSAnb2JqZWN0Jykge1xuICAgICAgdmFyIGVycm9ySGFuZGxlckNvbmZpZ3MgPSB7fVxuICAgICAgdmFyIGVycm9ySGFuZGxlckZuXG4gICAgICBpZiAodHlwZW9mIG9wdGlvbnMudXJsLmVycm9yQ29uZmlnID09PSAnb2JqZWN0Jykge1xuICAgICAgICBlcnJvckhhbmRsZXJGbiA9IHRoaXNbb3B0aW9ucy51cmwuZXJyb3JDb25maWcuaGFuZGxlcl1cbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGVycm9ySGFuZGxlckZuID0gdGhpc1tvcHRpb25zLnVybC5lcnJvckNvbmZpZ11cbiAgICAgIH1cbiAgICAgIG9wdGlvbnMudXJsID0gb3B0aW9ucy51cmwudXJsXG4gICAgfVxuXG4gICAgb3B0aW9ucyA9IF8uYXNzaWduKHtcbiAgICAgIGRhdGFUeXBlOiAnanNvbicsXG4gICAgICB0eXBlOiAnZ2V0JyxcbiAgICAgIHVybDogJy9ldmVudHMnLFxuICAgICAgZXJyb3JIYW5kbGVyRm46IGVycm9ySGFuZGxlckZuLFxuICAgICAgZXJyb3JIYW5kbGVyQ29uZmlnczogZXJyb3JIYW5kbGVyQ29uZmlncyxcbiAgICAgIHRyaW1TZWFyY2g6IHRydWUsXG4gICAgICBwcmVmaXg6IGVudkRldGFpbHNbJ3VybFByZWZpeCddIHx8ICcnXG4gICAgfSwgXy5tZXJnZShvcHRpb25zLCB7IGRhdGE6IHsgY3VycmVudF9sb2NhdGlvbl91dWlkOiBlbnZEZXRhaWxzLmN1cnJlbnRfbG9jYXRpb25fdXVpZCB9IH0pKVxuXG4gICAgLy8gYnkgZGVmYXVsdCB0cmltIHdoaXRlc3BhY2VzIGZyb20gYmVnaW5uaW5nIGFuZCBlbmQgb2Ygc2VhcmNoIHN0cmluZ1xuXG4gICAgaWYgKG9wdGlvbnMuZGF0YSAmJiAodHlwZW9mIG9wdGlvbnMuZGF0YS5zZWFyY2ggPT09ICdzdHJpbmcnKSAmJiBvcHRpb25zLnRyaW1TZWFyY2gpIHtcbiAgICAgIG9wdGlvbnMuZGF0YS5zZWFyY2ggPSBvcHRpb25zLmRhdGEuc2VhcmNoLnRyaW1TcGFjZXNGb3JTZWFyY2goKVxuICAgIH1cblxuICAgIGlmICghL15odHRwcz8vLnRlc3Qob3B0aW9uc1sndXJsJ10pKSB7XG4gICAgICBvcHRpb25zWyd1cmwnXSA9IG9wdGlvbnNbJ3ByZWZpeCddICsgb3B0aW9uc1sndXJsJ11cbiAgICB9XG4gICAgdmFyIHByb21pc2UgPSAkLmFqYXgob3B0aW9ucylcbiAgICByZXR1cm4gcHJvbWlzZVxuICB9LFxuXG4gIGFkZFJlbW92ZUNhY2hlOiBmdW5jdGlvbiAodXJsLCBwcm9taXNlKSB7XG4gICAgaWYodGhpcy5BUElfY2FjaGVbdXJsXSAmJiB0aGlzLkFQSV9jYWNoZVt1cmxdLnN0YXRlKCkgIT0gJ3Jlc29sdmVkJykge1xuICAgICAgICB0aGlzLkFQSV9jYWNoZVt1cmxdLmFib3J0KClcbiAgICB9XG4gICAgZGVsZXRlIHRoaXMuQVBJX2NhY2hlW3VybF1cbiAgICB0aGlzLkFQSV9jYWNoZVt1cmxdID0gcHJvbWlzZVxuICB9LFxuXG4gIHNldFBhZ2VMb2FkZXI6IGZ1bmN0aW9uICh7dXJsLCBzZWN0aW9uTG9hZGVyLCBidG5zVG9EaXNhYmxlfSkge1xuICAgICAgZW52RGV0YWlscy5zdGFydFBhZ2VMb2FkZXIgPSBmYWxzZVxuICAgICAgaWYoIXRoaXMuQVBJX2NhY2hlW3VybF0pIHtcbiAgICAgICAgdGhpcy50b2dnbGVTZWN0aW9uTG9hZGVyKHNlY3Rpb25Mb2FkZXIpXG4gICAgICAgIHRoaXMuZGlzYWJsZVdoaWxlRmV0Y2hpbmdEYXRhKHRydWUsIGJ0bnNUb0Rpc2FibGUpXG4gICAgICB9XG4gIH0sXG5cbiAgVWlBY3Rpb25zT25VcGRhdGU6IGZ1bmN0aW9uICh7dXJsLCBzZWN0aW9uTG9hZGVyLCBidG5zVG9EaXNhYmxlfSkge1xuICAgIGRlbGV0ZSB0aGlzLkFQSV9jYWNoZVt1cmxdXG4gICAgdGhpcy50b2dnbGVTZWN0aW9uTG9hZGVyKHNlY3Rpb25Mb2FkZXIpXG4gICAgdGhpcy5kaXNhYmxlV2hpbGVGZXRjaGluZ0RhdGEoZmFsc2UsIGJ0bnNUb0Rpc2FibGUpXG4gIH0sXG5cbiAgdG9nZ2xlU2VjdGlvbkxvYWRlcjogZnVuY3Rpb24oc2VjdGlvbkxvYWRlcikge1xuICAgICAgJChzZWN0aW9uTG9hZGVyKS50b2dnbGVDbGFzcygnaGlkZScpXG4gIH0sXG5cbiAgZGlzYWJsZVdoaWxlRmV0Y2hpbmdEYXRhOiBmdW5jdGlvbihzaG91bGREaXNhYmxlLGVsbXMpIHtcbiAgICAgICQoZWxtcykuYXR0cignZGlzYWJsZWQnLCBzaG91bGREaXNhYmxlKVxuICB9XG5cbn1cblxuXG5tb2R1bGUuZXhwb3J0cyA9IEFwaVxuIiwiLyogZ2xvYmFsIEhhbmRsZWJhcnNUZW1wbGF0ZXMsIGkxOG4sICQsIF8sIG1vbWVudCAgKi9cbmNvbnN0IHtldmVudFR5cGUsIGV2ZW50LCBwYWdlVHlwZX0gPSB3aW5kb3cuZW52RGV0YWlsc1xuY29uc3QgYm91bmRlZEV2ZW50cyA9IGV2ZW50VHlwZSA9PT0gJ1RyYWRlU2hvdycgfHwgZXZlbnRUeXBlID09PSAnU3RhZmZTY2hlZHVsaW5nJ1xuY29uc3QgZGF0ZXBpY2tlclN0YXJ0RmllbGRzID0gWydtZWV0aW5nX3N0YXJ0X3RpbWUnLCAnYnJpZWZpbmdfc3RhcnRfZGF0ZSddXG5jb25zdCBkYXRlcGlja2VyRW5kRmllbGRzID0gWydtZWV0aW5nX2VuZF90aW1lJywgJ2JyaWVmaW5nX2VuZF9kYXRlJ11cbmNvbnN0IGRhdGVwaWNrZXJGaWVsZHMgPSBbLi4uZGF0ZXBpY2tlclN0YXJ0RmllbGRzLCAuLi5kYXRlcGlja2VyRW5kRmllbGRzXVxuY29uc3QgZGF0ZXBpY2tlck9iaiA9IHtcbiAgJ21lZXRpbmdfc3RhcnRfdGltZSc6ICdtZWV0aW5nX2VuZF90aW1lJyxcbiAgJ21lZXRpbmdfZW5kX3RpbWUnOiAnbWVldGluZ19zdGFydF90aW1lJyxcbiAgJ2JyaWVmaW5nX3N0YXJ0X2RhdGUnOiAnYnJpZWZpbmdfZW5kX2RhdGUnLFxuICAnYnJpZWZpbmdfZW5kX2RhdGUnOiAnYnJpZWZpbmdfc3RhcnRfZGF0ZSdcbn1cbmNvbnN0IGRhdGVBcGlNYXBwaW5ncyA9IHtcbiAgJ21lZXRpbmdfc3RhcnRfdGltZSc6IHsgbmFtZTogJ3N0YXJ0X2RhdGUnLCBhcnJheTogZmFsc2UgfSxcbiAgJ21lZXRpbmdfZW5kX3RpbWUnOiB7IG5hbWU6ICdlbmRfZGF0ZScsIGFycmF5OiBmYWxzZSB9LFxuICAnYnJpZWZpbmdfc3RhcnRfZGF0ZSc6IHsgbmFtZTogJ2JyaWVmaW5nX3N0YXJ0X2RhdGUnLCBhcnJheTogdHJ1ZSB9LFxuICAnYnJpZWZpbmdfZW5kX2RhdGUnOiB7IG5hbWU6ICdicmllZmluZ19lbmRfZGF0ZScsIGFycmF5OiB0cnVlIH1cbn1cbmNvbnN0IGFwaURhdGVNYXBwaW5ncyA9IHtcbiAgJ3N0YXJ0X2RhdGUnOiAnbWVldGluZ19zdGFydF90aW1lJyxcbiAgJ2VuZF9kYXRlJzogJ21lZXRpbmdfZW5kX3RpbWUnXG59XG5jb25zdCBkYXRlRm9ybWF0ID0gJ1lZWVktTU0tREQnXG5jb25zdCBkZWZhdWx0RGF0ZSA9IGJvdW5kZWRFdmVudHMgPyAnJyA6IG1vbWVudCgpLnN0YXJ0T2YoJ2RheScpLnRvRGF0ZSgpXG5jb25zdCBkZWZhdWx0VmFsdWVzID0ge1xuICAnbWVldGluZ19zdGFydF90aW1lJzogZGVmYXVsdERhdGVcbn1cblxuLy8gQWRkIGRlZmF1bHQgZGF0ZXMgb25seSBpZiBpdCBpcyBldmVudCBvZiB0eXBlIEVCQ1xuaWYgKHdpbmRvdy5pc0VCQ0V2ZW50KSB7XG4gIGRlZmF1bHRWYWx1ZXNbJ2JyaWVmaW5nX3N0YXJ0X2RhdGUnXSA9IGRlZmF1bHREYXRlXG59XG5cbmZ1bmN0aW9uIHNldE1lZXRpbmdGaWx0ZXJzIChmaWx0ZXJzLCBmaWx0ZXJQYW5lbCwgQWN0aW9ucywgY3VzdG9tU2VhcmNoSGFzaCA9IHt9LCBpc0N1c3RvbVRlbXBsYXRlID0gZmFsc2UpIHtcbiAgY29uc3QgdG1wbCA9IHJlcXVpcmUoJ1RlbXBsYXRlcy9yZXBvcnQvb25kZW1hbmQvZmlsdGVycycpXG4gIGZpbHRlclBhbmVsLmh0bWwodG1wbCh7IGZpbHRlcnMsIG9wdGlvbl9jbHM6ICd0b2tlbi1pbnB1dC1mbGQnIH0pKVxuXG4gIHZhciBzZWFyY2hIYXNoID0gXy5hc3NpZ24oe1xuICAgIHN1YmplY3RzOiAnbWVldGluZ193aXRoX2ZpZWxkJyxcbiAgICBtZWV0aW5nX3dpdGg6ICdtZWV0aW5nX3dpdGhfZmllbGQnLFxuICAgIHJldmlld2VlczogJ3Jldmlld2Vlc19maWVsZCcsXG4gICAgcmVxdWVzdGVyczogJ3JlcXVlc3RvcnNfZmllbGQnLFxuICAgIGludGVybmFsX2ludml0ZWVzOiAnaW50ZXJuYWxfYXR0ZW5kZWVfZmllbGQnLFxuICAgIGV4dGVybmFsX2ludml0ZWVzOiAnZXh0ZXJuYWxfYXR0ZW5kZWVfZmllbGQnLFxuICAgIHVzZXJzOiAnaW50ZXJuYWxfYXR0ZW5kZWVfZmllbGQnLFxuICAgIGlkczogJ21lZXRpbmdfaWRzX2ZpZWxkJyxcbiAgICBjcmVhdG9yczogJ2NyZWF0b3JzX2ZpZWxkJyxcbiAgICB0b3BpY3M6ICd0b3BpY3NfZmllbGQnLFxuICAgIHRhZ3M6ICd0YWdzJyxcbiAgICBicmllZmluZ19zdWJqZWN0czogJ2JyaWVmaW5nX3dpdGhfZmllbGQnLFxuICAgIGJyaWVmaW5nX3JlcXVlc3RlcnM6ICdicmllZmluZ19yZXF1ZXN0b3JzX2ZpZWxkJyxcbiAgICBicmllZmluZ19pbnRlcm5hbF9pbnZpdGVlczogJ2JyaWVmaW5nX2ludGVybmFsX2F0dGVuZGVlX2ZpZWxkJyxcbiAgICBicmllZmluZ19leHRlcm5hbF9pbnZpdGVlczogJ2JyaWVmaW5nX2V4dGVybmFsX2F0dGVuZGVlX2ZpZWxkJyxcbiAgICBicmllZmluZ19pZHM6ICdicmllZmluZ19pZHNfZmllbGQnLFxuICAgIGJyaWVmaW5nX2NyZWF0b3JzOiAnYnJpZWZpbmdfY3JlYXRvcnNfZmllbGQnLFxuICAgIGJyaWVmaW5nX3Jvb21zOiAnYnJpZWZpbmdfcm9vbXNfZmllbGQnXG4gIH0sIGN1c3RvbVNlYXJjaEhhc2gpXG5cbiAgJCgnaW5wdXQnLCAnLmZpbHRlcl9wYW5lbCcpLmVhY2goZnVuY3Rpb24gKGksIHNlbGVjdEVsZW1lbnQpIHtcbiAgICBzZWxlY3RFbGVtZW50ID0gJChzZWxlY3RFbGVtZW50KVxuICAgIHZhciBuYW1lID0gc2VsZWN0RWxlbWVudC5hdHRyKCduYW1lJylcbiAgICBpZiAoIV8uaXNVbmRlZmluZWQobmFtZSkpIHtcbiAgICAgIHNlbGVjdEVsZW1lbnQuYXR0cigncGxhY2Vob2xkZXInLCBpMThuLnQoYHNlYXJjaF8ke25hbWV9YCkpXG4gICAgfVxuICB9KVxuXG4gICQoJ3NlbGVjdCcsICcuZmlsdGVyX3BhbmVsJykuZWFjaChmdW5jdGlvbiAoaSwgc2VsZWN0RWxlbWVudCkge1xuICAgIHNlbGVjdEVsZW1lbnQgPSAkKHNlbGVjdEVsZW1lbnQpXG4gICAgdmFyIG5hbWUgPSBzZWxlY3RFbGVtZW50LmF0dHIoJ25hbWUnKVxuICAgIHZhciB0eXBlID0gc2VsZWN0RWxlbWVudC5kYXRhKCd0eXBlJylcbiAgICBjb25zdCBjdXN0b21MYWJlbCA9IHNlbGVjdEVsZW1lbnQuZGF0YSgnY3VzdG9tJykgfHwgJ21lZXRpbmcgdHlwZSdcbiAgICB2YXIgc2VsZWN0Q29uZmlnID0ge1xuICAgICAgZHJvcGRvd25QYXJlbnQ6IG51bGwsXG4gICAgICBtdWx0aXBsZTogdHJ1ZSxcbiAgICAgIHdpZHRoOiAnMTAwJScsXG4gICAgICBwbGFjZWhvbGRlcjogaTE4bi50KGBzZWFyY2hfJHtuYW1lfWAsIHsgbGFiZWw6IGN1c3RvbUxhYmVsIH0pXG4gICAgfVxuICAgIHZhciBhamF4U2VsZWN0Q29uZmlnID0ge1xuICAgICAgbWluaW11bUlucHV0TGVuZ3RoOiAxLFxuICAgICAgY2FjaGU6IHRydWUsXG4gICAgICBhamF4OiB7XG4gICAgICAgIGRlbGF5OiAyNTYsXG4gICAgICAgIGRhdGE6IGZ1bmN0aW9uIChwYXJhbXMpIHtcbiAgICAgICAgICByZXR1cm4ge1xuICAgICAgICAgICAgZmllbGQ6IHNlYXJjaEhhc2hbbmFtZV0gfHwgbmFtZSxcbiAgICAgICAgICAgIHRlcm06IChwYXJhbXNbJ3Rlcm0nXSB8fCAnJykudHJpbSgpXG4gICAgICAgICAgfVxuICAgICAgICB9LFxuICAgICAgICBwcm9jZXNzUmVzdWx0czogZnVuY3Rpb24gKHJlc3VsdHMpIHtcbiAgICAgICAgICBpZiAocmVzdWx0cyBpbnN0YW5jZW9mIEFycmF5KSB7XG4gICAgICAgICAgICByZXN1bHRzID0gcmVzdWx0cy5tYXAoZnVuY3Rpb24gKGl0ZW0pIHtcbiAgICAgICAgICAgICAgcmV0dXJuIHtcbiAgICAgICAgICAgICAgICBpZDogaXRlbVswXSxcbiAgICAgICAgICAgICAgICB0ZXh0OiBpdGVtWzFdXG4gICAgICAgICAgICAgIH1cbiAgICAgICAgICAgIH0pXG4gICAgICAgICAgfVxuICAgICAgICAgIHJldHVybiB7XG4gICAgICAgICAgICByZXN1bHRzXG4gICAgICAgICAgfVxuICAgICAgICB9XG4gICAgICB9XG4gICAgfVxuICAgIHZhciBsb2NhbEFqYXhDb25maWdcbiAgICBzd2l0Y2ggKG5hbWUpIHtcbiAgICAgIGNhc2UgJ3N1YmplY3RzJzpcbiAgICAgIGNhc2UgJ3JlcXVlc3RlcnMnOlxuICAgICAgY2FzZSAnaW50ZXJuYWxfaW52aXRlZXMnOlxuICAgICAgY2FzZSAnZXh0ZXJuYWxfaW52aXRlZXMnOlxuICAgICAgY2FzZSAnY3JlYXRvcnMnOlxuICAgICAgY2FzZSAndG9waWNzJzpcbiAgICAgIGNhc2UgJ3RhZ3MnOlxuICAgICAgY2FzZSAndGFnX3V1aWRzJzpcbiAgICAgIGNhc2UgJ3VzZXJzJzpcbiAgICAgIGNhc2UgJ3Jldmlld2Vlcyc6XG4gICAgICBjYXNlICdtZWV0aW5nX3dpdGgnOlxuICAgICAgY2FzZSAnaWRzJzoge1xuICAgICAgICBsb2NhbEFqYXhDb25maWcgPSBfLmFzc2lnbihzZWxlY3RDb25maWcsIGFqYXhTZWxlY3RDb25maWcpXG4gICAgICAgIGxvY2FsQWpheENvbmZpZy5hamF4LnRyYW5zcG9ydCA9IGZ1bmN0aW9uIChwYXJhbXMsIHN1Y2Nlc3MsIGZhaWx1cmUpIHtcbiAgICAgICAgICByZXR1cm4gQWN0aW9ucy5mZXRjaE9wdGlvbnMocGFyYW1zLmRhdGEsIHN1Y2Nlc3MsIGZhaWx1cmUsICdtZWV0aW5nJylcbiAgICAgICAgfVxuXG4gICAgICAgIHNlbGVjdEVsZW1lbnQuc2VsZWN0Mihsb2NhbEFqYXhDb25maWcpXG4gICAgICAgIGJyZWFrXG4gICAgICB9XG4gICAgICBjYXNlICdicmllZmluZ19zdWJqZWN0cyc6XG4gICAgICBjYXNlICdicmllZmluZ19yZXF1ZXN0ZXJzJzpcbiAgICAgIGNhc2UgJ2JyaWVmaW5nX2ludGVybmFsX2ludml0ZWVzJzpcbiAgICAgIGNhc2UgJ2JyaWVmaW5nX2V4dGVybmFsX2ludml0ZWVzJzpcbiAgICAgIGNhc2UgJ2JyaWVmaW5nX2NyZWF0b3JzJzpcbiAgICAgIGNhc2UgJ2JyaWVmaW5nX2lkcyc6XG4gICAgICBjYXNlICdicmllZmluZ19yb29tcyc6e1xuICAgICAgICBsb2NhbEFqYXhDb25maWcgPSBfLmFzc2lnbihzZWxlY3RDb25maWcsIGFqYXhTZWxlY3RDb25maWcpXG4gICAgICAgIGxvY2FsQWpheENvbmZpZy5hamF4LnRyYW5zcG9ydCA9IGZ1bmN0aW9uIChwYXJhbXMsIHN1Y2Nlc3MsIGZhaWx1cmUpIHtcbiAgICAgICAgICByZXR1cm4gQWN0aW9ucy5mZXRjaE9wdGlvbnMocGFyYW1zLmRhdGEsIHN1Y2Nlc3MsIGZhaWx1cmUsICdicmllZmluZycpXG4gICAgICAgIH1cblxuICAgICAgICBzZWxlY3RFbGVtZW50LnNlbGVjdDIobG9jYWxBamF4Q29uZmlnKVxuICAgICAgICBicmVha1xuICAgICAgfVxuICAgICAgY2FzZSAndXNlcl9uYW1lJzoge1xuICAgICAgICBsb2NhbEFqYXhDb25maWcgPSBfLmFzc2lnbihzZWxlY3RDb25maWcsIGFqYXhTZWxlY3RDb25maWcpXG4gICAgICAgIGxvY2FsQWpheENvbmZpZy5hamF4LnRyYW5zcG9ydCA9IGZ1bmN0aW9uIChwYXJhbXMsIHN1Y2Nlc3MsIGZhaWx1cmUpIHtcbiAgICAgICAgICByZXR1cm4gQWN0aW9ucy5mZXRjaE9wdGlvbnMocGFyYW1zLmRhdGEsIHN1Y2Nlc3MsIGZhaWx1cmUsICdjYWxlbmRhcicpXG4gICAgICAgIH1cblxuICAgICAgICBzZWxlY3RFbGVtZW50LnNlbGVjdDIobG9jYWxBamF4Q29uZmlnKVxuICAgICAgICBicmVha1xuICAgICAgfVxuICAgICAgY2FzZSAndGFnX2Nsb3VkJzoge1xuICAgICAgICBzZWxlY3RDb25maWcucGxhY2Vob2xkZXIgPSBpMThuLnQoJ3NlYXJjaF9ieScpICsgdHlwZVxuICAgICAgICBzZWxlY3RFbGVtZW50LnNlbGVjdDIoc2VsZWN0Q29uZmlnKVxuICAgICAgICBicmVha1xuICAgICAgfVxuICAgICAgZGVmYXVsdDoge1xuICAgICAgICBzZWxlY3RFbGVtZW50LnNlbGVjdDIoc2VsZWN0Q29uZmlnKVxuICAgICAgICBicmVha1xuICAgICAgfVxuICAgIH1cblxuICAgIHNlbGVjdEVsZW1lbnQuZmluZCgnb3B0aW9uJykubGVuZ3RoICYmIHNlbGVjdEVsZW1lbnQudHJpZ2dlcignY2hhbmdlJylcbiAgfSlcblxuICAvLyBTZXQgZGF0ZSBwaWNrZXIgb25seSBpZiBldmVudCBpcyBwcmVzZW5kIGFuZCBwYWdlIGlmIG9uZGVtYW5kIHJlcG9ydFxuICBpZiAoZXZlbnQgJiYgcGFnZVR5cGUgIT09IHVuZGVmaW5lZCkge1xuICAgIGNvbnN0IHttZWV0aW5ncyA9IFtdLCBicmllZmluZ3M9W119ID0gZmlsdGVyc1xuICAgIGNvbnN0IGZpbHRlcnNBcHBsaWVkID0gWy4uLm1lZXRpbmdzLCAuLi5icmllZmluZ3NdXG5cbiAgICAvLyBMb29wIG92ZXIgdGhlIGZpbHRlcnMgdG8gZ2V0IHRoZSBzdGFydCBhbmQgZW5kIGRhdGUgZm9yIGJvdGggYnJpZWZpbmdzICYgbWVldGluZ3NcbiAgICBmaWx0ZXJzQXBwbGllZC5tYXAoZnVuY3Rpb24gKGZpbHRlcikge1xuICAgICAgY29uc3QgZmllbGROYW1lID0gZmlsdGVyLmZpZWxkX25hbWVcbiAgICAgIGlmIChkYXRlcGlja2VyRmllbGRzLmluZGV4T2YoZmllbGROYW1lKSAhPT0gLTEpIHtcbiAgICAgICAgbGV0IHZhbHVlcyA9IGZpbHRlci52YWx1ZVswXVxuICAgICAgICB2YWx1ZXMgPSAodmFsdWVzICYmIHZhbHVlcy5oYXNPd25Qcm9wZXJ0eSgndmFsdWUnKSkgPyB2YWx1ZXMudmFsdWUgOiB2YWx1ZXNcblxuICAgICAgICBsZXQgc2F2ZWRWYWx1ZSA9ICcnXG5cbiAgICAgICAgLy8gQ2hlY2sgdG8gaGFuZGxlIGFscmVhZHkgZXhpc3RpbmcgYnJpZWZpbmcgb2YgZGlmZmVyZW50IGZvcm1hdFxuICAgICAgICBpZiAodmFsdWVzKSB7XG4gICAgICAgICAgc2F2ZWRWYWx1ZSA9IG1vbWVudCh2YWx1ZXMsICdNTS1ERC1ZWVlZJylcbiAgICAgICAgICBzYXZlZFZhbHVlID0gc2F2ZWRWYWx1ZS5pc1ZhbGlkKCkgPyBzYXZlZFZhbHVlIDogbW9tZW50KHZhbHVlcywgZGF0ZUZvcm1hdClcbiAgICAgICAgICBzYXZlZFZhbHVlID0gc2F2ZWRWYWx1ZS50b0RhdGUoKVxuICAgICAgICB9XG5cbiAgICAgICAgLy8gQmVmb3JlIHNldHRpbmcgaW5pdGlhbCB2YWx1ZVxuICAgICAgICBkZWZhdWx0VmFsdWVzW2ZpZWxkTmFtZV0gPSBzYXZlZFZhbHVlIHx8IChpc0N1c3RvbVRlbXBsYXRlID8gJycgOiBkZWZhdWx0VmFsdWVzW2ZpZWxkTmFtZV0pXG4gICAgICB9XG4gICAgfSlcblxuICAgIGRhdGVwaWNrZXJGaWVsZHMubWFwKChmaWVsZE5hbWUpID0+IHtcbiAgICAgIGluaXREYXRlcGlja2VycyhmaWVsZE5hbWUpXG4gICAgfSlcbiAgfVxuXG4gICQoJyN1aS1kYXRlcGlja2VyLWRpdicpLm9uKCdjbGljaycsIGZ1bmN0aW9uIChlKSB7XG4gICAgZS5zdG9wUHJvcGFnYXRpb24oKVxuICB9KVxuXG4gIGZpbHRlclBhbmVsLmZpbmQoJy50YWItcGFuZScpLm9uKCdzY3JvbGwnLCBmdW5jdGlvbiAoKSB7XG4gICAgJCgnLmRhdGVwaWNrZXItZHJvcGRvd24nKS5sZW5ndGggJiYgZmlsdGVyUGFuZWwuZmluZCgnLm1lZXRpbmdfc3RhcnRfdGltZSwgLm1lZXRpbmdfZW5kX3RpbWUnKS5lYWNoKGZ1bmN0aW9uIChpLCBlbCkge1xuICAgICAgJChlbCkuYm9vdHN0cmFwRFAoJ2hpZGUnKS5ibHVyKClcbiAgICB9KVxuICB9KVxufVxuXG5mdW5jdGlvbiBpbml0RGF0ZXBpY2tlcnMgKGZpZWxkTmFtZSkge1xuICBjb25zdCBkYXRlUGlja2VyRnVuY3Rpb24gPSBkYXRlcGlja2VyU3RhcnRGaWVsZHMuaW5kZXhPZihmaWVsZE5hbWUpICE9PSAtMSA/IHNldFN0YXJ0RGF0ZVBpY2tlciA6IHNldEVuZERhdGVQaWNrZXJcbiAgZGF0ZVBpY2tlckZ1bmN0aW9uKGZpZWxkTmFtZSlcbn1cblxuZnVuY3Rpb24gc2V0U3RhcnREYXRlUGlja2VyIChmaWVsZE5hbWUpIHtcbiAgY29uc3QgZGF0ZXBpY2tlckVsZSA9ICQoYC4ke2ZpZWxkTmFtZX1gKVxuXG4gIGlmICghZGF0ZXBpY2tlckVsZS5sZW5ndGgpIHtcbiAgICByZXR1cm5cbiAgfVxuXG4gIGNvbnN0IHNlbGVjdGVkRGF0ZSA9IGRlZmF1bHRWYWx1ZXNbZmllbGROYW1lXVxuICBjb25zdCBzdGFydERhdGUgPSBldmVudC5zdGFydF9kYXRlXG4gIGNvbnN0IGVuZERhdGUgPSBkZWZhdWx0VmFsdWVzW2RhdGVwaWNrZXJPYmpbZmllbGROYW1lXV0gfHwgKGJvdW5kZWRFdmVudHMgPyBldmVudC5lbmRfZGF0ZSA6ICcnKVxuICBjb25zdCBkZWZhdWx0Vmlld0RhdGUgPSBtb21lbnQoc2VsZWN0ZWREYXRlIHx8IHN0YXJ0RGF0ZSwgZGF0ZUZvcm1hdClcblxuICBkYXRlcGlja2VyRWxlXG4gICAgLmJvb3RzdHJhcERQKCdkZXN0cm95JylcbiAgICAub2ZmKCdjaGFuZ2VEYXRlJywgZGF0ZXBpY2tlckhhbmRsZXIpXG4gICAgLmJvb3RzdHJhcERQKHtcbiAgICAgIGZvcm1hdDogJ21tL2RkL3l5eXknLFxuICAgICAgYXV0b2Nsb3NlOiB0cnVlLFxuICAgICAgb3JpZW50YXRpb246ICdib3R0b20nLFxuICAgICAgZGVmYXVsdFZpZXdEYXRlOiB7XG4gICAgICAgIHllYXI6IGRlZmF1bHRWaWV3RGF0ZS55ZWFyKCksXG4gICAgICAgIG1vbnRoOiBkZWZhdWx0Vmlld0RhdGUubW9udGgoKSxcbiAgICAgICAgZGF5OiBkZWZhdWx0Vmlld0RhdGUuZGF0ZSgpXG4gICAgICB9LFxuICAgICAgc3RhcnREYXRlOiBzdGFydERhdGUgPyBtb21lbnQoc3RhcnREYXRlLCBkYXRlRm9ybWF0KS50b0RhdGUoKSA6IG51bGwsXG4gICAgICBlbmREYXRlOiBlbmREYXRlID8gbW9tZW50KGVuZERhdGUsIGRhdGVGb3JtYXQpLnRvRGF0ZSgpIDogbnVsbFxuICAgIH0pXG5cbiAgZGF0ZXBpY2tlckVsZVxuICAgIC5ib290c3RyYXBEUCgnc2V0RGF0ZScsIChzZWxlY3RlZERhdGUgJiYgbW9tZW50KHNlbGVjdGVkRGF0ZSwgZGF0ZUZvcm1hdCkudG9EYXRlKCkpIHx8ICcnKVxuICAgIC5vbignY2hhbmdlRGF0ZScsIGRhdGVwaWNrZXJIYW5kbGVyKVxufVxuXG5mdW5jdGlvbiBzZXRFbmREYXRlUGlja2VyIChmaWVsZE5hbWUpIHtcbiAgY29uc3QgZGF0ZXBpY2tlckVsZSA9ICQoYC4ke2ZpZWxkTmFtZX1gKVxuXG4gIGlmICghZGF0ZXBpY2tlckVsZS5sZW5ndGgpIHtcbiAgICByZXR1cm5cbiAgfVxuXG4gIGNvbnN0IHNlbGVjdGVkRGF0ZSA9IGRlZmF1bHRWYWx1ZXNbZmllbGROYW1lXVxuICBjb25zdCBzdGFydERhdGUgPSBkZWZhdWx0VmFsdWVzW2RhdGVwaWNrZXJPYmpbZmllbGROYW1lXV0gfHwgZXZlbnQuc3RhcnRfZGF0ZVxuICBjb25zdCBlbmREYXRlID0gYm91bmRlZEV2ZW50cyA/IGV2ZW50LmVuZF9kYXRlIDogJydcbiAgY29uc3QgZGVmYXVsdFZpZXdEYXRlID0gbW9tZW50KHNlbGVjdGVkRGF0ZSB8fCBldmVudC5lbmRfZGF0ZSwgZGF0ZUZvcm1hdClcblxuICBkYXRlcGlja2VyRWxlXG4gICAgLmJvb3RzdHJhcERQKCdkZXN0cm95JylcbiAgICAub2ZmKCdjaGFuZ2VEYXRlJywgZGF0ZXBpY2tlckhhbmRsZXIpXG4gICAgLmJvb3RzdHJhcERQKHtcbiAgICAgIGZvcm1hdDogJ21tL2RkL3l5eXknLFxuICAgICAgYXV0b2Nsb3NlOiB0cnVlLFxuICAgICAgb3JpZW50YXRpb246ICdib3R0b20nLFxuICAgICAgZGVmYXVsdFZpZXdEYXRlOiB7XG4gICAgICAgIHllYXI6IGRlZmF1bHRWaWV3RGF0ZS55ZWFyKCksXG4gICAgICAgIG1vbnRoOiBkZWZhdWx0Vmlld0RhdGUubW9udGgoKSxcbiAgICAgICAgZGF5OiBkZWZhdWx0Vmlld0RhdGUuZGF0ZSgpXG4gICAgICB9LFxuICAgICAgc3RhcnREYXRlOiBzdGFydERhdGUgPyBtb21lbnQoc3RhcnREYXRlLCBkYXRlRm9ybWF0KS50b0RhdGUoKSA6IG51bGwsXG4gICAgICBlbmREYXRlOiBlbmREYXRlID8gbW9tZW50KGVuZERhdGUsIGRhdGVGb3JtYXQpLnRvRGF0ZSgpIDogbnVsbFxuICAgIH0pXG5cbiAgZGF0ZXBpY2tlckVsZVxuICAgIC5ib290c3RyYXBEUCgnc2V0RGF0ZScsIChzZWxlY3RlZERhdGUgJiYgbW9tZW50KHNlbGVjdGVkRGF0ZSwgZGF0ZUZvcm1hdCkudG9EYXRlKCkpIHx8ICcnKVxuICAgIC5vbignY2hhbmdlRGF0ZScsIGRhdGVwaWNrZXJIYW5kbGVyKVxufVxuXG5mdW5jdGlvbiBkYXRlcGlja2VySGFuZGxlciAoZXZlbnQpIHtcbiAgY29uc3QgZmllbGROYW1lID0gZXZlbnQuY3VycmVudFRhcmdldC5uYW1lXG4gIGRlZmF1bHRWYWx1ZXNbZmllbGROYW1lXSA9IG1vbWVudChldmVudC5kYXRlKS50b0RhdGUoKVxuICBjb25zdCBkYXRlUGlja2VyRnVuY3Rpb24gPSBkYXRlcGlja2VyU3RhcnRGaWVsZHMuaW5kZXhPZihmaWVsZE5hbWUpICE9PSAtMSA/IHNldEVuZERhdGVQaWNrZXIgOiBzZXRTdGFydERhdGVQaWNrZXJcblxuICBkYXRlUGlja2VyRnVuY3Rpb24oZGF0ZXBpY2tlck9ialtmaWVsZE5hbWVdKVxufVxuXG5mdW5jdGlvbiBzZXREYXRlUGlja2VyIChlbGUpIHtcbiAgZWxlLmRhdGVwaWNrZXIoe1xuICAgIGRhdGVGb3JtYXQ6ICd5eS1tbS1kZCcsXG4gICAgb25TZWxlY3Q6IHVwZGF0ZURhdGVSYW5nZVxuICB9KS5hdHRyKCdwbGFjZWhvbGRlcicsIGkxOG4udCgnc2VhcmNoXycgKyBlbGUuYXR0cignbmFtZScpKSlcbn1cblxuZnVuY3Rpb24gdXBkYXRlRGF0ZVJhbmdlIChkYXRlU3RyKSB7XG4gIHZhciBldmVudCA9IHdpbmRvdy5ldmVudFxuICBldmVudCAmJiBldmVudC5wcmV2ZW50RGVmYXVsdCAmJiBldmVudC5wcmV2ZW50RGVmYXVsdCgpXG4gIHZhciBlbCA9ICQodGhpcylcbiAgdmFyIHBhbmVsID0gJCgnLmZpbHRlcl9wYW5lbCcpXG5cbiAgaWYgKGVsLmhhc0NsYXNzKCdlbmQnKSkge1xuICAgIHZhciBzdERhdGUgPSBwYW5lbC5maW5kKCcuZGF0ZS5zdGFydCcpXG4gICAgc2V0TWluTWF4RGF0ZShzdERhdGUsICdtYXhEYXRlJywgZGF0ZVN0cilcbiAgfSBlbHNlIHtcbiAgICB2YXIgZWREYXRlID0gcGFuZWwuZmluZCgnLmRhdGUuZW5kJylcbiAgICBzZXRNaW5NYXhEYXRlKGVkRGF0ZSwgJ21pbkRhdGUnLCBkYXRlU3RyKVxuICB9XG59XG5cbmZ1bmN0aW9uIHNldE1pbk1heERhdGUgKGVsZW0sIG1pbk1heERhdGUsIGRhdGVTdHIpIHtcbiAgZWxlbS5kYXRlcGlja2VyKCdvcHRpb24nLCBtaW5NYXhEYXRlLCBuZXcgRGF0ZShkYXRlU3RyKSlcbn1cblxuZnVuY3Rpb24gZ2V0Q2x1YmJlZEZpbHRlckRhdGEgKGZpbHRlclBhbmVsKSB7XG4gIHZhciBmb3JtRGF0YSA9IHt9XG4gIHZhciBzZWxlY3RlZEZpbHRlckRhdGEgPSB7fVxuICB2YXIgc3RvcmFibGVGaWx0ZXJEYXRhID0ge31cbiAgdmFyIHN0YXJ0RGF0ZSwgZW5kRGF0ZVxuICB2YXIgYnJpZWZpbmdTdGFydERhdGUsIGJyaWVmaW5nRW5kRGF0ZVxuXG4gIGlmIChwYWdlVHlwZSAhPT0gdW5kZWZpbmVkKSB7XG4gICAgZGF0ZXBpY2tlckZpZWxkcy5tYXAoKGtleSkgPT4ge1xuICAgICAgbGV0IGZpZWxkVmFsdWUgPSBkZWZhdWx0VmFsdWVzW2tleV1cbiAgICAgIGNvbnN0IHsgbmFtZSwgYXJyYXkgfSA9IGRhdGVBcGlNYXBwaW5nc1trZXldXG5cbiAgICAgIGlmIChmaWVsZFZhbHVlKSB7XG4gICAgICAgIGZpZWxkVmFsdWUgPSBtb21lbnQoZmllbGRWYWx1ZSkuZm9ybWF0KCdNTS9ERC9ZWVlZJylcbiAgICAgICAgZm9ybURhdGFbbmFtZV0gPSBhcnJheSA/IFtmaWVsZFZhbHVlXSA6IGZpZWxkVmFsdWVcbiAgICAgICAgc2VsZWN0ZWRGaWx0ZXJEYXRhW25hbWVdID0ge1xuICAgICAgICAgIHZhbHVlczogW3sga2V5LCBuYW1lOiBmaWVsZFZhbHVlfV0sXG4gICAgICAgICAgZGlzcGxheV9uYW1lOiBpMThuLnQoa2V5KVxuICAgICAgICB9XG4gICAgICB9XG4gICAgfSlcbiAgfVxuXG4gIGZpbHRlclBhbmVsLmZpbmQoJy5zZWxlY3QnKS5lYWNoKGZ1bmN0aW9uIChpbmRleCwgZWxlbWVudCkge1xuICAgIHZhciBpbnB1dCA9ICQoZWxlbWVudClcbiAgICB2YXIgdmFsdWUgPSBpbnB1dC52YWwoKSB8fCBbXVxuICAgIHZhciBuYW1lID0gaW5wdXQuYXR0cignbmFtZScpXG4gICAgdmFyIGZpbHRlclZhbHVlID0gW11cbiAgICB2YXIgc3RvcmFibGVGaWx0ZXJWYWx1ZXMgPSBbXVxuICAgIHZhciB0eXBlID0gaW5wdXQuZGF0YSgndHlwZScpXG5cbiAgICBpbnB1dC5maW5kKCdvcHRpb246c2VsZWN0ZWQnKS5lYWNoKGZ1bmN0aW9uIChpLCBvcHRpb25FbGUpIHtcbiAgICAgIHZhciBvcHRpb24gPSAkKG9wdGlvbkVsZSlcbiAgICAgIGZpbHRlclZhbHVlLnB1c2goe1xuICAgICAgICBrZXk6IG9wdGlvbi52YWwoKSxcbiAgICAgICAgbmFtZTogb3B0aW9uLnRleHQoKVxuICAgICAgfSlcbiAgICAgIHN0b3JhYmxlRmlsdGVyVmFsdWVzLnB1c2goe1xuICAgICAgICB2YWx1ZTogb3B0aW9uLnZhbCgpLFxuICAgICAgICBkaXNwbGF5X2xhYmVsOiBvcHRpb24udGV4dCgpXG4gICAgICB9KVxuICAgIH0pXG5cbiAgICBpZiAodmFsdWUgIT09IG51bGwgJiYgdmFsdWUgIT09ICcnKSB7XG4gICAgICBpZiAoIWZvcm1EYXRhW25hbWVdKSB7XG4gICAgICAgIGZvcm1EYXRhW25hbWVdID0gdmFsdWVcbiAgICAgICAgc2VsZWN0ZWRGaWx0ZXJEYXRhW25hbWVdID0ge1xuICAgICAgICAgIHZhbHVlczogZmlsdGVyVmFsdWUsXG4gICAgICAgICAgZGlzcGxheV9uYW1lOiB0eXBlXG4gICAgICAgIH1cbiAgICAgICAgc3RvcmFibGVGaWx0ZXJEYXRhW25hbWVdID0gc3RvcmFibGVGaWx0ZXJWYWx1ZXNcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGZvcm1EYXRhW25hbWVdLnB1c2godmFsdWUpXG4gICAgICAgIHNlbGVjdGVkRmlsdGVyRGF0YVtuYW1lXS52YWx1ZXMucHVzaChmaWx0ZXJWYWx1ZSlcbiAgICAgICAgc3RvcmFibGVGaWx0ZXJEYXRhW25hbWVdLnB1c2goc3RvcmFibGVGaWx0ZXJWYWx1ZXMpXG4gICAgICAgIGZvcm1EYXRhW25hbWVdID0gXy5mbGF0dGVuKGZvcm1EYXRhW25hbWVdKVxuICAgICAgICBzZWxlY3RlZEZpbHRlckRhdGFbbmFtZV0udmFsdWVzID0gXy5mbGF0dGVuKHNlbGVjdGVkRmlsdGVyRGF0YVtuYW1lXS52YWx1ZXMpXG4gICAgICAgIHN0b3JhYmxlRmlsdGVyRGF0YVtuYW1lXSA9IF8uZmxhdHRlbihzdG9yYWJsZUZpbHRlckRhdGFbbmFtZV0pXG4gICAgICB9XG4gICAgfVxuICB9KVxuXG4gIGZpbHRlclBhbmVsLmZpbmQoJy5kYXRlJykuZWFjaChmdW5jdGlvbiAoaW5kZXgsIGVsZW1lbnQpIHtcbiAgICB2YXIgaW5wdXQgPSAkKGVsZW1lbnQpXG4gICAgdmFyIHZhbHVlID0gaW5wdXQudmFsKClcbiAgICB2YXIgbmFtZSA9IGlucHV0LmF0dHIoJ25hbWUnKVxuICAgIHZhciBmaWx0ZXJWYWx1ZSA9IFtdXG4gICAgdmFyIHN0b3JhYmxlRmlsdGVyVmFsdWVzID0gW11cbiAgICB2YXIgdHlwZSA9IGlucHV0LmRhdGEoJ3R5cGUnKVxuXG4gICAgaWYgKHZhbHVlICE9PSAnJykge1xuICAgICAgZmlsdGVyVmFsdWUucHVzaCh7XG4gICAgICAgIGtleTogW3ZhbHVlXSxcbiAgICAgICAgbmFtZTogdmFsdWVcbiAgICAgIH0pXG4gICAgICBzdG9yYWJsZUZpbHRlclZhbHVlcy5wdXNoKHtcbiAgICAgICAgdmFsdWU6IFt2YWx1ZV0sXG4gICAgICAgIGRpc3BsYXlfbGFiZWw6IHZhbHVlXG4gICAgICB9KVxuICAgIH1cblxuICAgIGZvcm1EYXRhW25hbWVdID0gdmFsdWUgIT09ICcnID8gW3ZhbHVlXSA6IFtdXG4gICAgc2VsZWN0ZWRGaWx0ZXJEYXRhW25hbWVdID0ge1xuICAgICAgdmFsdWVzOiBmaWx0ZXJWYWx1ZSxcbiAgICAgIGRpc3BsYXlfbmFtZTogdHlwZVxuICAgIH1cbiAgICBzdG9yYWJsZUZpbHRlckRhdGFbbmFtZV0gPSBzdG9yYWJsZUZpbHRlclZhbHVlc1xuICB9KVxuXG4gIGZpbHRlclBhbmVsLmZpbmQoJ2lucHV0LmVuYWJsZWRbdHlwZT1jaGVja2JveF0nKS5lYWNoKGZ1bmN0aW9uIChpbmRleCwgZWxlbWVudCkge1xuICAgIHZhciBpbnB1dCA9ICQoZWxlbWVudClcbiAgICB2YXIgdmFsdWUgPSBpbnB1dC5pcygnOmNoZWNrZWQnKVxuICAgIHZhciBuYW1lID0gaW5wdXQuYXR0cignbmFtZScpXG4gICAgdmFyIGZpbHRlclZhbHVlID0gW11cbiAgICB2YXIgc3RvcmFibGVGaWx0ZXJWYWx1ZXMgPSBbXVxuICAgIHZhciB0eXBlID0gaW5wdXQuZGF0YSgndHlwZScpXG5cbiAgICBpZiAodmFsdWUgIT09ICcnKSB7XG4gICAgICBmaWx0ZXJWYWx1ZS5wdXNoKHtcbiAgICAgICAga2V5OiBbdmFsdWVdLFxuICAgICAgICBuYW1lOiB2YWx1ZVxuICAgICAgfSlcbiAgICAgIHN0b3JhYmxlRmlsdGVyVmFsdWVzLnB1c2goe1xuICAgICAgICB2YWx1ZTogW3ZhbHVlXSxcbiAgICAgICAgZGlzcGxheV9sYWJlbDogdmFsdWVcbiAgICAgIH0pXG4gICAgfVxuXG4gICAgZm9ybURhdGFbbmFtZV0gPSBbdmFsdWVdXG4gICAgc2VsZWN0ZWRGaWx0ZXJEYXRhW25hbWVdID0ge1xuICAgICAgdmFsdWVzOiBmaWx0ZXJWYWx1ZSxcbiAgICAgIGRpc3BsYXlfbmFtZTogdHlwZVxuICAgIH1cbiAgICBzdG9yYWJsZUZpbHRlckRhdGFbbmFtZV0gPSBzdG9yYWJsZUZpbHRlclZhbHVlc1xuICB9KVxuXG4gIHJldHVybiB7XG4gICAgZm9ybURhdGEsXG4gICAgc2VsZWN0ZWRGaWx0ZXJEYXRhLFxuICAgIHN0b3JhYmxlRmlsdGVyRGF0YVxuICB9XG59XG5cbmZ1bmN0aW9uIHJlc2V0RGF0ZVBpY2tlcnMgKGZpZWxkS2V5KSB7XG4gIGRhdGVwaWNrZXJGaWVsZHMubWFwKChmaWVsZE5hbWUpID0+IHtcbiAgICBpZiAoZmllbGRLZXkpIHtcbiAgICAgIGlmIChmaWVsZE5hbWUgPT09IGZpZWxkS2V5KSB7XG4gICAgICAgIGRlZmF1bHRWYWx1ZXNbZmllbGROYW1lXSA9ICcnXG4gICAgICB9XG4gICAgfSBlbHNlIHtcbiAgICAgIGRlZmF1bHRWYWx1ZXNbZmllbGROYW1lXSA9ICcnXG4gICAgfVxuXG4gICAgaW5pdERhdGVwaWNrZXJzKGZpZWxkTmFtZSlcbiAgfSlcbn1cblxubW9kdWxlLmV4cG9ydHMgPSB7XG4gIHNldE1lZXRpbmdGaWx0ZXJzLFxuICBnZXRDbHViYmVkRmlsdGVyRGF0YSxcbiAgc2V0RGF0ZVBpY2tlcixcbiAgc2V0TWluTWF4RGF0ZSxcbiAgcmVzZXREYXRlUGlja2VycyxcbiAgZGF0ZXBpY2tlckZpZWxkcyxcbiAgYXBpRGF0ZU1hcHBpbmdzXG59XG4iLCJsZXQgZGVjbGluZUNvbW1lbnRzID0gW11cbmxldCBjYW5jZWxDb21tZW50cyA9IFtdXG5cbmZ1bmN0aW9uIHB1dFNlYXJjaFF1ZXJ5UGFyYW0oaW5wdXQsIGtleSwgdmFsdWUpIHtcbiAgaW5wdXQgPSBpbnB1dCB8fCAnJyAvLyBUaGlzIGlzIG5vdCByZXF1aXJlZCBoYWQgd2UgdXNlZCBkZWZhdWx0IHBhcmFtZXRlcnMgYnV0IHN0aWxsIHJ1bm5pbmcgb2xkZXIgdmVyc2lvbiBndWxwXG4gIHZhciByZWdleFN0cmluZyA9IGAoW1xcPyZdKSR7a2V5fT0oW14mJF0qKWBcbiAgdmFyIHJlZ2V4ID0gbmV3IFJlZ0V4cChyZWdleFN0cmluZylcbiAgdmFyIGV2YWx1YXRlZCA9IHJlZ2V4LmV4ZWMoaW5wdXQpXG4gIGlmICghZXZhbHVhdGVkKSByZXR1cm4gaW5wdXQuY29uY2F0KGlucHV0ID8gJyYnIDogJz8nLCBrZXksICc9JywgdmFsdWUpIFxuICByZXR1cm4gaW5wdXQucmVwbGFjZShldmFsdWF0ZWRbMF0sIGAke2V2YWx1YXRlZFsxXX0ke2tleX09JHt2YWx1ZX1gKVxufVxuXG5mdW5jdGlvbiBnZXRDb21tZW50cyh7IGZsYWcsIGNvbW1lbnRzID0gW10gfSkge1xuICBpZiAoZmxhZyA9PT0gJ3llcycpIHtcbiAgICBjb21tZW50cyA9IGNvbW1lbnRzLmZpbHRlcihjb21tZW50ID0+IGNvbW1lbnQpXG4gIH1cblxuICByZXR1cm4gY29tbWVudHNcbn1cblxuZnVuY3Rpb24gZ2V0RGVjbGluZUNvbW1lbnRzKCkge1xuICByZXR1cm4gZGVjbGluZUNvbW1lbnRzXG59XG5cbmZ1bmN0aW9uIGdldENhbmNlbENvbW1lbnRzKCkge1xuICByZXR1cm4gY2FuY2VsQ29tbWVudHNcbn1cblxuZnVuY3Rpb24gdXBkYXRlRGVjbGluZUNvbW1lbnRzIChpbnZpdGVPcHRpb24gPSB7fSkge1xuICBjb25zdCB7IGRlY2xpbmVfY29tbWVudHNfZW5hYmxlZDogZGVjbGluZUNvbW1lbnRzRW5hYmxlZCwgcHJlZGVmaW5lZF9kZWNsaW5lX2NvbW1lbnRzOiBwcmVkZWZpbmVkRGVjbGluZUNvbW1lbnRzIH0gPSBpbnZpdGVPcHRpb25cblxuICBkZWNsaW5lQ29tbWVudHMgPSBnZXRDb21tZW50cyh7IGZsYWc6IGRlY2xpbmVDb21tZW50c0VuYWJsZWQsIGNvbW1lbnRzOiBwcmVkZWZpbmVkRGVjbGluZUNvbW1lbnRzIH0pXG59XG5cbmZ1bmN0aW9uIHVwZGF0ZUNhbmNlbENvbW1lbnRzIChjYW5jZWxPcHRpb24gPSB7fSkge1xuICBjb25zdCB7IGNhbmNlbF9jb21tZW50c19lbmFibGVkOiBjYW5jZWxDb21tZW50c0VuYWJsZWQsIHByZWRlZmluZWRfY2FuY2VsX2NvbW1lbnRzOiBwcmVkZWZpbmVkQ2FuY2VsQ29tbWVudHMgfSA9IGNhbmNlbE9wdGlvblxuXG4gIGNhbmNlbENvbW1lbnRzID0gZ2V0Q29tbWVudHMoeyBmbGFnOiBjYW5jZWxDb21tZW50c0VuYWJsZWQsIGNvbW1lbnRzOiBwcmVkZWZpbmVkQ2FuY2VsQ29tbWVudHMgfSlcbn1cbmZ1bmN0aW9uIGFib3J0YWJsZUZldGNoIChxdWV1ZSwgcHJvbWlzZSkge1xuICB2YXIgcHJvbWlzZUlkID0gTWF0aC5yYW5kb20oKS50b1N0cmluZygzNikuc3Vic3RyKDIsIDkpO1xuICBxdWV1ZS5tYXAoZnVuY3Rpb24gKHJlcXVlc3QpIHtcbiAgICByZXF1ZXN0LnByb21pc2UuYWJvcnQoKVxuICB9KVxuXG4gIHF1ZXVlLnB1c2goe3Byb21pc2U6IHByb21pc2UsIElkOiBwcm9taXNlSWR9KVxuICByZXR1cm4ge3Byb21pc2VJZH1cbn1cblxubW9kdWxlLmV4cG9ydHMgPSB7XG4gIHB1dFNlYXJjaFF1ZXJ5UGFyYW0sXG4gIGdldERlY2xpbmVDb21tZW50cyxcbiAgZ2V0Q2FuY2VsQ29tbWVudHMsXG4gIHVwZGF0ZURlY2xpbmVDb21tZW50cyxcbiAgdXBkYXRlQ2FuY2VsQ29tbWVudHMsXG4gIGFib3J0YWJsZUZldGNoXG59XG4iLCIndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG4vLyBpc3RhbmJ1bCBpZ25vcmUgbmV4dFxuXG5mdW5jdGlvbiBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KG9iaikgeyByZXR1cm4gb2JqICYmIG9iai5fX2VzTW9kdWxlID8gb2JqIDogeyAnZGVmYXVsdCc6IG9iaiB9OyB9XG5cbi8vIGlzdGFuYnVsIGlnbm9yZSBuZXh0XG5cbmZ1bmN0aW9uIF9pbnRlcm9wUmVxdWlyZVdpbGRjYXJkKG9iaikgeyBpZiAob2JqICYmIG9iai5fX2VzTW9kdWxlKSB7IHJldHVybiBvYmo7IH0gZWxzZSB7IHZhciBuZXdPYmogPSB7fTsgaWYgKG9iaiAhPSBudWxsKSB7IGZvciAodmFyIGtleSBpbiBvYmopIHsgaWYgKE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbChvYmosIGtleSkpIG5ld09ialtrZXldID0gb2JqW2tleV07IH0gfSBuZXdPYmpbJ2RlZmF1bHQnXSA9IG9iajsgcmV0dXJuIG5ld09iajsgfSB9XG5cbnZhciBfaGFuZGxlYmFyc0Jhc2UgPSByZXF1aXJlKCcuL2hhbmRsZWJhcnMvYmFzZScpO1xuXG52YXIgYmFzZSA9IF9pbnRlcm9wUmVxdWlyZVdpbGRjYXJkKF9oYW5kbGViYXJzQmFzZSk7XG5cbi8vIEVhY2ggb2YgdGhlc2UgYXVnbWVudCB0aGUgSGFuZGxlYmFycyBvYmplY3QuIE5vIG5lZWQgdG8gc2V0dXAgaGVyZS5cbi8vIChUaGlzIGlzIGRvbmUgdG8gZWFzaWx5IHNoYXJlIGNvZGUgYmV0d2VlbiBjb21tb25qcyBhbmQgYnJvd3NlIGVudnMpXG5cbnZhciBfaGFuZGxlYmFyc1NhZmVTdHJpbmcgPSByZXF1aXJlKCcuL2hhbmRsZWJhcnMvc2FmZS1zdHJpbmcnKTtcblxudmFyIF9oYW5kbGViYXJzU2FmZVN0cmluZzIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9oYW5kbGViYXJzU2FmZVN0cmluZyk7XG5cbnZhciBfaGFuZGxlYmFyc0V4Y2VwdGlvbiA9IHJlcXVpcmUoJy4vaGFuZGxlYmFycy9leGNlcHRpb24nKTtcblxudmFyIF9oYW5kbGViYXJzRXhjZXB0aW9uMiA9IF9pbnRlcm9wUmVxdWlyZURlZmF1bHQoX2hhbmRsZWJhcnNFeGNlcHRpb24pO1xuXG52YXIgX2hhbmRsZWJhcnNVdGlscyA9IHJlcXVpcmUoJy4vaGFuZGxlYmFycy91dGlscycpO1xuXG52YXIgVXRpbHMgPSBfaW50ZXJvcFJlcXVpcmVXaWxkY2FyZChfaGFuZGxlYmFyc1V0aWxzKTtcblxudmFyIF9oYW5kbGViYXJzUnVudGltZSA9IHJlcXVpcmUoJy4vaGFuZGxlYmFycy9ydW50aW1lJyk7XG5cbnZhciBydW50aW1lID0gX2ludGVyb3BSZXF1aXJlV2lsZGNhcmQoX2hhbmRsZWJhcnNSdW50aW1lKTtcblxudmFyIF9oYW5kbGViYXJzTm9Db25mbGljdCA9IHJlcXVpcmUoJy4vaGFuZGxlYmFycy9uby1jb25mbGljdCcpO1xuXG52YXIgX2hhbmRsZWJhcnNOb0NvbmZsaWN0MiA9IF9pbnRlcm9wUmVxdWlyZURlZmF1bHQoX2hhbmRsZWJhcnNOb0NvbmZsaWN0KTtcblxuLy8gRm9yIGNvbXBhdGliaWxpdHkgYW5kIHVzYWdlIG91dHNpZGUgb2YgbW9kdWxlIHN5c3RlbXMsIG1ha2UgdGhlIEhhbmRsZWJhcnMgb2JqZWN0IGEgbmFtZXNwYWNlXG5mdW5jdGlvbiBjcmVhdGUoKSB7XG4gIHZhciBoYiA9IG5ldyBiYXNlLkhhbmRsZWJhcnNFbnZpcm9ubWVudCgpO1xuXG4gIFV0aWxzLmV4dGVuZChoYiwgYmFzZSk7XG4gIGhiLlNhZmVTdHJpbmcgPSBfaGFuZGxlYmFyc1NhZmVTdHJpbmcyWydkZWZhdWx0J107XG4gIGhiLkV4Y2VwdGlvbiA9IF9oYW5kbGViYXJzRXhjZXB0aW9uMlsnZGVmYXVsdCddO1xuICBoYi5VdGlscyA9IFV0aWxzO1xuICBoYi5lc2NhcGVFeHByZXNzaW9uID0gVXRpbHMuZXNjYXBlRXhwcmVzc2lvbjtcblxuICBoYi5WTSA9IHJ1bnRpbWU7XG4gIGhiLnRlbXBsYXRlID0gZnVuY3Rpb24gKHNwZWMpIHtcbiAgICByZXR1cm4gcnVudGltZS50ZW1wbGF0ZShzcGVjLCBoYik7XG4gIH07XG5cbiAgcmV0dXJuIGhiO1xufVxuXG52YXIgaW5zdCA9IGNyZWF0ZSgpO1xuaW5zdC5jcmVhdGUgPSBjcmVhdGU7XG5cbl9oYW5kbGViYXJzTm9Db25mbGljdDJbJ2RlZmF1bHQnXShpbnN0KTtcblxuaW5zdFsnZGVmYXVsdCddID0gaW5zdDtcblxuZXhwb3J0c1snZGVmYXVsdCddID0gaW5zdDtcbm1vZHVsZS5leHBvcnRzID0gZXhwb3J0c1snZGVmYXVsdCddO1xuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMMnhwWWk5b1lXNWtiR1ZpWVhKekxuSjFiblJwYldVdWFuTWlYU3dpYm1GdFpYTWlPbHRkTENKdFlYQndhVzVuY3lJNklqczdPenM3T3pzN096czdPRUpCUVhOQ0xHMUNRVUZ0UWpzN1NVRkJOMElzU1VGQlNUczdPenM3YjBOQlNVOHNNRUpCUVRCQ096czdPMjFEUVVNelFpeDNRa0ZCZDBJN096czdLMEpCUTNaQ0xHOUNRVUZ2UWpzN1NVRkJMMElzUzBGQlN6czdhVU5CUTFFc2MwSkJRWE5DT3p0SlFVRnVReXhQUVVGUE96dHZRMEZGU1N3d1FrRkJNRUk3T3pzN08wRkJSMnBFTEZOQlFWTXNUVUZCVFN4SFFVRkhPMEZCUTJoQ0xFMUJRVWtzUlVGQlJTeEhRVUZITEVsQlFVa3NTVUZCU1N4RFFVRkRMSEZDUVVGeFFpeEZRVUZGTEVOQlFVTTdPMEZCUlRGRExFOUJRVXNzUTBGQlF5eE5RVUZOTEVOQlFVTXNSVUZCUlN4RlFVRkZMRWxCUVVrc1EwRkJReXhEUVVGRE8wRkJRM1pDTEVsQlFVVXNRMEZCUXl4VlFVRlZMRzlEUVVGaExFTkJRVU03UVVGRE0wSXNTVUZCUlN4RFFVRkRMRk5CUVZNc2JVTkJRVmtzUTBGQlF6dEJRVU42UWl4SlFVRkZMRU5CUVVNc1MwRkJTeXhIUVVGSExFdEJRVXNzUTBGQlF6dEJRVU5xUWl4SlFVRkZMRU5CUVVNc1owSkJRV2RDTEVkQlFVY3NTMEZCU3l4RFFVRkRMR2RDUVVGblFpeERRVUZET3p0QlFVVTNReXhKUVVGRkxFTkJRVU1zUlVGQlJTeEhRVUZITEU5QlFVOHNRMEZCUXp0QlFVTm9RaXhKUVVGRkxFTkJRVU1zVVVGQlVTeEhRVUZITEZWQlFWTXNTVUZCU1N4RlFVRkZPMEZCUXpOQ0xGZEJRVThzVDBGQlR5eERRVUZETEZGQlFWRXNRMEZCUXl4SlFVRkpMRVZCUVVVc1JVRkJSU3hEUVVGRExFTkJRVU03UjBGRGJrTXNRMEZCUXpzN1FVRkZSaXhUUVVGUExFVkJRVVVzUTBGQlF6dERRVU5ZT3p0QlFVVkVMRWxCUVVrc1NVRkJTU3hIUVVGSExFMUJRVTBzUlVGQlJTeERRVUZETzBGQlEzQkNMRWxCUVVrc1EwRkJReXhOUVVGTkxFZEJRVWNzVFVGQlRTeERRVUZET3p0QlFVVnlRaXhyUTBGQlZ5eEpRVUZKTEVOQlFVTXNRMEZCUXpzN1FVRkZha0lzU1VGQlNTeERRVUZETEZOQlFWTXNRMEZCUXl4SFFVRkhMRWxCUVVrc1EwRkJRenM3Y1VKQlJWSXNTVUZCU1NJc0ltWnBiR1VpT2lKb1lXNWtiR1ZpWVhKekxuSjFiblJwYldVdWFuTWlMQ0p6YjNWeVkyVnpRMjl1ZEdWdWRDSTZXeUpwYlhCdmNuUWdLaUJoY3lCaVlYTmxJR1p5YjIwZ0p5NHZhR0Z1Wkd4bFltRnljeTlpWVhObEp6dGNibHh1THk4Z1JXRmphQ0J2WmlCMGFHVnpaU0JoZFdkdFpXNTBJSFJvWlNCSVlXNWtiR1ZpWVhKeklHOWlhbVZqZEM0Z1RtOGdibVZsWkNCMGJ5QnpaWFIxY0NCb1pYSmxMbHh1THk4Z0tGUm9hWE1nYVhNZ1pHOXVaU0IwYnlCbFlYTnBiSGtnYzJoaGNtVWdZMjlrWlNCaVpYUjNaV1Z1SUdOdmJXMXZibXB6SUdGdVpDQmljbTkzYzJVZ1pXNTJjeWxjYm1sdGNHOXlkQ0JUWVdabFUzUnlhVzVuSUdaeWIyMGdKeTR2YUdGdVpHeGxZbUZ5Y3k5ellXWmxMWE4wY21sdVp5YzdYRzVwYlhCdmNuUWdSWGhqWlhCMGFXOXVJR1p5YjIwZ0p5NHZhR0Z1Wkd4bFltRnljeTlsZUdObGNIUnBiMjRuTzF4dWFXMXdiM0owSUNvZ1lYTWdWWFJwYkhNZ1puSnZiU0FuTGk5b1lXNWtiR1ZpWVhKekwzVjBhV3h6Snp0Y2JtbHRjRzl5ZENBcUlHRnpJSEoxYm5ScGJXVWdabkp2YlNBbkxpOW9ZVzVrYkdWaVlYSnpMM0oxYm5ScGJXVW5PMXh1WEc1cGJYQnZjblFnYm05RGIyNW1iR2xqZENCbWNtOXRJQ2N1TDJoaGJtUnNaV0poY25NdmJtOHRZMjl1Wm14cFkzUW5PMXh1WEc0dkx5QkdiM0lnWTI5dGNHRjBhV0pwYkdsMGVTQmhibVFnZFhOaFoyVWdiM1YwYzJsa1pTQnZaaUJ0YjJSMWJHVWdjM2x6ZEdWdGN5d2diV0ZyWlNCMGFHVWdTR0Z1Wkd4bFltRnljeUJ2WW1wbFkzUWdZU0J1WVcxbGMzQmhZMlZjYm1aMWJtTjBhVzl1SUdOeVpXRjBaU2dwSUh0Y2JpQWdiR1YwSUdoaUlEMGdibVYzSUdKaGMyVXVTR0Z1Wkd4bFltRnljMFZ1ZG1seWIyNXRaVzUwS0NrN1hHNWNiaUFnVlhScGJITXVaWGgwWlc1a0tHaGlMQ0JpWVhObEtUdGNiaUFnYUdJdVUyRm1aVk4wY21sdVp5QTlJRk5oWm1WVGRISnBibWM3WEc0Z0lHaGlMa1Y0WTJWd2RHbHZiaUE5SUVWNFkyVndkR2x2Ymp0Y2JpQWdhR0l1VlhScGJITWdQU0JWZEdsc2N6dGNiaUFnYUdJdVpYTmpZWEJsUlhod2NtVnpjMmx2YmlBOUlGVjBhV3h6TG1WelkyRndaVVY0Y0hKbGMzTnBiMjQ3WEc1Y2JpQWdhR0l1VmswZ1BTQnlkVzUwYVcxbE8xeHVJQ0JvWWk1MFpXMXdiR0YwWlNBOUlHWjFibU4wYVc5dUtITndaV01wSUh0Y2JpQWdJQ0J5WlhSMWNtNGdjblZ1ZEdsdFpTNTBaVzF3YkdGMFpTaHpjR1ZqTENCb1lpazdYRzRnSUgwN1hHNWNiaUFnY21WMGRYSnVJR2hpTzF4dWZWeHVYRzVzWlhRZ2FXNXpkQ0E5SUdOeVpXRjBaU2dwTzF4dWFXNXpkQzVqY21WaGRHVWdQU0JqY21WaGRHVTdYRzVjYm01dlEyOXVabXhwWTNRb2FXNXpkQ2s3WEc1Y2JtbHVjM1JiSjJSbFptRjFiSFFuWFNBOUlHbHVjM1E3WEc1Y2JtVjRjRzl5ZENCa1pXWmhkV3gwSUdsdWMzUTdYRzRpWFgwPVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuZXhwb3J0cy5IYW5kbGViYXJzRW52aXJvbm1lbnQgPSBIYW5kbGViYXJzRW52aXJvbm1lbnQ7XG4vLyBpc3RhbmJ1bCBpZ25vcmUgbmV4dFxuXG5mdW5jdGlvbiBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KG9iaikgeyByZXR1cm4gb2JqICYmIG9iai5fX2VzTW9kdWxlID8gb2JqIDogeyAnZGVmYXVsdCc6IG9iaiB9OyB9XG5cbnZhciBfdXRpbHMgPSByZXF1aXJlKCcuL3V0aWxzJyk7XG5cbnZhciBfZXhjZXB0aW9uID0gcmVxdWlyZSgnLi9leGNlcHRpb24nKTtcblxudmFyIF9leGNlcHRpb24yID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfZXhjZXB0aW9uKTtcblxudmFyIF9oZWxwZXJzID0gcmVxdWlyZSgnLi9oZWxwZXJzJyk7XG5cbnZhciBfZGVjb3JhdG9ycyA9IHJlcXVpcmUoJy4vZGVjb3JhdG9ycycpO1xuXG52YXIgX2xvZ2dlciA9IHJlcXVpcmUoJy4vbG9nZ2VyJyk7XG5cbnZhciBfbG9nZ2VyMiA9IF9pbnRlcm9wUmVxdWlyZURlZmF1bHQoX2xvZ2dlcik7XG5cbnZhciBWRVJTSU9OID0gJzQuMS4yJztcbmV4cG9ydHMuVkVSU0lPTiA9IFZFUlNJT047XG52YXIgQ09NUElMRVJfUkVWSVNJT04gPSA3O1xuXG5leHBvcnRzLkNPTVBJTEVSX1JFVklTSU9OID0gQ09NUElMRVJfUkVWSVNJT047XG52YXIgUkVWSVNJT05fQ0hBTkdFUyA9IHtcbiAgMTogJzw9IDEuMC5yYy4yJywgLy8gMS4wLnJjLjIgaXMgYWN0dWFsbHkgcmV2MiBidXQgZG9lc24ndCByZXBvcnQgaXRcbiAgMjogJz09IDEuMC4wLXJjLjMnLFxuICAzOiAnPT0gMS4wLjAtcmMuNCcsXG4gIDQ6ICc9PSAxLngueCcsXG4gIDU6ICc9PSAyLjAuMC1hbHBoYS54JyxcbiAgNjogJz49IDIuMC4wLWJldGEuMScsXG4gIDc6ICc+PSA0LjAuMCdcbn07XG5cbmV4cG9ydHMuUkVWSVNJT05fQ0hBTkdFUyA9IFJFVklTSU9OX0NIQU5HRVM7XG52YXIgb2JqZWN0VHlwZSA9ICdbb2JqZWN0IE9iamVjdF0nO1xuXG5mdW5jdGlvbiBIYW5kbGViYXJzRW52aXJvbm1lbnQoaGVscGVycywgcGFydGlhbHMsIGRlY29yYXRvcnMpIHtcbiAgdGhpcy5oZWxwZXJzID0gaGVscGVycyB8fCB7fTtcbiAgdGhpcy5wYXJ0aWFscyA9IHBhcnRpYWxzIHx8IHt9O1xuICB0aGlzLmRlY29yYXRvcnMgPSBkZWNvcmF0b3JzIHx8IHt9O1xuXG4gIF9oZWxwZXJzLnJlZ2lzdGVyRGVmYXVsdEhlbHBlcnModGhpcyk7XG4gIF9kZWNvcmF0b3JzLnJlZ2lzdGVyRGVmYXVsdERlY29yYXRvcnModGhpcyk7XG59XG5cbkhhbmRsZWJhcnNFbnZpcm9ubWVudC5wcm90b3R5cGUgPSB7XG4gIGNvbnN0cnVjdG9yOiBIYW5kbGViYXJzRW52aXJvbm1lbnQsXG5cbiAgbG9nZ2VyOiBfbG9nZ2VyMlsnZGVmYXVsdCddLFxuICBsb2c6IF9sb2dnZXIyWydkZWZhdWx0J10ubG9nLFxuXG4gIHJlZ2lzdGVySGVscGVyOiBmdW5jdGlvbiByZWdpc3RlckhlbHBlcihuYW1lLCBmbikge1xuICAgIGlmIChfdXRpbHMudG9TdHJpbmcuY2FsbChuYW1lKSA9PT0gb2JqZWN0VHlwZSkge1xuICAgICAgaWYgKGZuKSB7XG4gICAgICAgIHRocm93IG5ldyBfZXhjZXB0aW9uMlsnZGVmYXVsdCddKCdBcmcgbm90IHN1cHBvcnRlZCB3aXRoIG11bHRpcGxlIGhlbHBlcnMnKTtcbiAgICAgIH1cbiAgICAgIF91dGlscy5leHRlbmQodGhpcy5oZWxwZXJzLCBuYW1lKTtcbiAgICB9IGVsc2Uge1xuICAgICAgdGhpcy5oZWxwZXJzW25hbWVdID0gZm47XG4gICAgfVxuICB9LFxuICB1bnJlZ2lzdGVySGVscGVyOiBmdW5jdGlvbiB1bnJlZ2lzdGVySGVscGVyKG5hbWUpIHtcbiAgICBkZWxldGUgdGhpcy5oZWxwZXJzW25hbWVdO1xuICB9LFxuXG4gIHJlZ2lzdGVyUGFydGlhbDogZnVuY3Rpb24gcmVnaXN0ZXJQYXJ0aWFsKG5hbWUsIHBhcnRpYWwpIHtcbiAgICBpZiAoX3V0aWxzLnRvU3RyaW5nLmNhbGwobmFtZSkgPT09IG9iamVjdFR5cGUpIHtcbiAgICAgIF91dGlscy5leHRlbmQodGhpcy5wYXJ0aWFscywgbmFtZSk7XG4gICAgfSBlbHNlIHtcbiAgICAgIGlmICh0eXBlb2YgcGFydGlhbCA9PT0gJ3VuZGVmaW5lZCcpIHtcbiAgICAgICAgdGhyb3cgbmV3IF9leGNlcHRpb24yWydkZWZhdWx0J10oJ0F0dGVtcHRpbmcgdG8gcmVnaXN0ZXIgYSBwYXJ0aWFsIGNhbGxlZCBcIicgKyBuYW1lICsgJ1wiIGFzIHVuZGVmaW5lZCcpO1xuICAgICAgfVxuICAgICAgdGhpcy5wYXJ0aWFsc1tuYW1lXSA9IHBhcnRpYWw7XG4gICAgfVxuICB9LFxuICB1bnJlZ2lzdGVyUGFydGlhbDogZnVuY3Rpb24gdW5yZWdpc3RlclBhcnRpYWwobmFtZSkge1xuICAgIGRlbGV0ZSB0aGlzLnBhcnRpYWxzW25hbWVdO1xuICB9LFxuXG4gIHJlZ2lzdGVyRGVjb3JhdG9yOiBmdW5jdGlvbiByZWdpc3RlckRlY29yYXRvcihuYW1lLCBmbikge1xuICAgIGlmIChfdXRpbHMudG9TdHJpbmcuY2FsbChuYW1lKSA9PT0gb2JqZWN0VHlwZSkge1xuICAgICAgaWYgKGZuKSB7XG4gICAgICAgIHRocm93IG5ldyBfZXhjZXB0aW9uMlsnZGVmYXVsdCddKCdBcmcgbm90IHN1cHBvcnRlZCB3aXRoIG11bHRpcGxlIGRlY29yYXRvcnMnKTtcbiAgICAgIH1cbiAgICAgIF91dGlscy5leHRlbmQodGhpcy5kZWNvcmF0b3JzLCBuYW1lKTtcbiAgICB9IGVsc2Uge1xuICAgICAgdGhpcy5kZWNvcmF0b3JzW25hbWVdID0gZm47XG4gICAgfVxuICB9LFxuICB1bnJlZ2lzdGVyRGVjb3JhdG9yOiBmdW5jdGlvbiB1bnJlZ2lzdGVyRGVjb3JhdG9yKG5hbWUpIHtcbiAgICBkZWxldGUgdGhpcy5kZWNvcmF0b3JzW25hbWVdO1xuICB9XG59O1xuXG52YXIgbG9nID0gX2xvZ2dlcjJbJ2RlZmF1bHQnXS5sb2c7XG5cbmV4cG9ydHMubG9nID0gbG9nO1xuZXhwb3J0cy5jcmVhdGVGcmFtZSA9IF91dGlscy5jcmVhdGVGcmFtZTtcbmV4cG9ydHMubG9nZ2VyID0gX2xvZ2dlcjJbJ2RlZmF1bHQnXTtcbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDJKaGMyVXVhbk1pWFN3aWJtRnRaWE1pT2x0ZExDSnRZWEJ3YVc1bmN5STZJanM3T3pzN096czdjVUpCUVRSRExGTkJRVk03TzNsQ1FVTXZRaXhoUVVGaE96czdPM1ZDUVVORkxGZEJRVmM3T3pCQ1FVTlNMR05CUVdNN08zTkNRVU51UXl4VlFVRlZPenM3TzBGQlJYUkNMRWxCUVUwc1QwRkJUeXhIUVVGSExFOUJRVThzUTBGQlF6czdRVUZEZUVJc1NVRkJUU3hwUWtGQmFVSXNSMEZCUnl4RFFVRkRMRU5CUVVNN096dEJRVVUxUWl4SlFVRk5MR2RDUVVGblFpeEhRVUZITzBGQlF6bENMRWRCUVVNc1JVRkJSU3hoUVVGaE8wRkJRMmhDTEVkQlFVTXNSVUZCUlN4bFFVRmxPMEZCUTJ4Q0xFZEJRVU1zUlVGQlJTeGxRVUZsTzBGQlEyeENMRWRCUVVNc1JVRkJSU3hWUVVGVk8wRkJRMklzUjBGQlF5eEZRVUZGTEd0Q1FVRnJRanRCUVVOeVFpeEhRVUZETEVWQlFVVXNhVUpCUVdsQ08wRkJRM0JDTEVkQlFVTXNSVUZCUlN4VlFVRlZPME5CUTJRc1EwRkJRenM3TzBGQlJVWXNTVUZCVFN4VlFVRlZMRWRCUVVjc2FVSkJRV2xDTEVOQlFVTTdPMEZCUlRsQ0xGTkJRVk1zY1VKQlFYRkNMRU5CUVVNc1QwRkJUeXhGUVVGRkxGRkJRVkVzUlVGQlJTeFZRVUZWTEVWQlFVVTdRVUZEYmtVc1RVRkJTU3hEUVVGRExFOUJRVThzUjBGQlJ5eFBRVUZQTEVsQlFVa3NSVUZCUlN4RFFVRkRPMEZCUXpkQ0xFMUJRVWtzUTBGQlF5eFJRVUZSTEVkQlFVY3NVVUZCVVN4SlFVRkpMRVZCUVVVc1EwRkJRenRCUVVNdlFpeE5RVUZKTEVOQlFVTXNWVUZCVlN4SFFVRkhMRlZCUVZVc1NVRkJTU3hGUVVGRkxFTkJRVU03TzBGQlJXNURMR3REUVVGMVFpeEpRVUZKTEVOQlFVTXNRMEZCUXp0QlFVTTNRaXgzUTBGQk1FSXNTVUZCU1N4RFFVRkRMRU5CUVVNN1EwRkRha003TzBGQlJVUXNjVUpCUVhGQ0xFTkJRVU1zVTBGQlV5eEhRVUZITzBGQlEyaERMR0ZCUVZjc1JVRkJSU3h4UWtGQmNVSTdPMEZCUld4RExGRkJRVTBzY1VKQlFWRTdRVUZEWkN4TFFVRkhMRVZCUVVVc2IwSkJRVThzUjBGQlJ6czdRVUZGWml4blFrRkJZeXhGUVVGRkxIZENRVUZUTEVsQlFVa3NSVUZCUlN4RlFVRkZMRVZCUVVVN1FVRkRha01zVVVGQlNTeG5Ra0ZCVXl4SlFVRkpMRU5CUVVNc1NVRkJTU3hEUVVGRExFdEJRVXNzVlVGQlZTeEZRVUZGTzBGQlEzUkRMRlZCUVVrc1JVRkJSU3hGUVVGRk8wRkJRVVVzWTBGQlRTd3lRa0ZCWXl4NVEwRkJlVU1zUTBGQlF5eERRVUZETzA5QlFVVTdRVUZETTBVc2IwSkJRVThzU1VGQlNTeERRVUZETEU5QlFVOHNSVUZCUlN4SlFVRkpMRU5CUVVNc1EwRkJRenRMUVVNMVFpeE5RVUZOTzBGQlEwd3NWVUZCU1N4RFFVRkRMRTlCUVU4c1EwRkJReXhKUVVGSkxFTkJRVU1zUjBGQlJ5eEZRVUZGTEVOQlFVTTdTMEZEZWtJN1IwRkRSanRCUVVORUxHdENRVUZuUWl4RlFVRkZMREJDUVVGVExFbEJRVWtzUlVGQlJUdEJRVU12UWl4WFFVRlBMRWxCUVVrc1EwRkJReXhQUVVGUExFTkJRVU1zU1VGQlNTeERRVUZETEVOQlFVTTdSMEZETTBJN08wRkJSVVFzYVVKQlFXVXNSVUZCUlN4NVFrRkJVeXhKUVVGSkxFVkJRVVVzVDBGQlR5eEZRVUZGTzBGQlEzWkRMRkZCUVVrc1owSkJRVk1zU1VGQlNTeERRVUZETEVsQlFVa3NRMEZCUXl4TFFVRkxMRlZCUVZVc1JVRkJSVHRCUVVOMFF5eHZRa0ZCVHl4SlFVRkpMRU5CUVVNc1VVRkJVU3hGUVVGRkxFbEJRVWtzUTBGQlF5eERRVUZETzB0QlF6ZENMRTFCUVUwN1FVRkRUQ3hWUVVGSkxFOUJRVThzVDBGQlR5eExRVUZMTEZkQlFWY3NSVUZCUlR0QlFVTnNReXhqUVVGTkxIbEZRVUV3UkN4SlFVRkpMRzlDUVVGcFFpeERRVUZETzA5QlEzWkdPMEZCUTBRc1ZVRkJTU3hEUVVGRExGRkJRVkVzUTBGQlF5eEpRVUZKTEVOQlFVTXNSMEZCUnl4UFFVRlBMRU5CUVVNN1MwRkRMMEk3UjBGRFJqdEJRVU5FTEcxQ1FVRnBRaXhGUVVGRkxESkNRVUZUTEVsQlFVa3NSVUZCUlR0QlFVTm9ReXhYUVVGUExFbEJRVWtzUTBGQlF5eFJRVUZSTEVOQlFVTXNTVUZCU1N4RFFVRkRMRU5CUVVNN1IwRkROVUk3TzBGQlJVUXNiVUpCUVdsQ0xFVkJRVVVzTWtKQlFWTXNTVUZCU1N4RlFVRkZMRVZCUVVVc1JVRkJSVHRCUVVOd1F5eFJRVUZKTEdkQ1FVRlRMRWxCUVVrc1EwRkJReXhKUVVGSkxFTkJRVU1zUzBGQlN5eFZRVUZWTEVWQlFVVTdRVUZEZEVNc1ZVRkJTU3hGUVVGRkxFVkJRVVU3UVVGQlJTeGpRVUZOTERKQ1FVRmpMRFJEUVVFMFF5eERRVUZETEVOQlFVTTdUMEZCUlR0QlFVTTVSU3h2UWtGQlR5eEpRVUZKTEVOQlFVTXNWVUZCVlN4RlFVRkZMRWxCUVVrc1EwRkJReXhEUVVGRE8wdEJReTlDTEUxQlFVMDdRVUZEVEN4VlFVRkpMRU5CUVVNc1ZVRkJWU3hEUVVGRExFbEJRVWtzUTBGQlF5eEhRVUZITEVWQlFVVXNRMEZCUXp0TFFVTTFRanRIUVVOR08wRkJRMFFzY1VKQlFXMUNMRVZCUVVVc05rSkJRVk1zU1VGQlNTeEZRVUZGTzBGQlEyeERMRmRCUVU4c1NVRkJTU3hEUVVGRExGVkJRVlVzUTBGQlF5eEpRVUZKTEVOQlFVTXNRMEZCUXp0SFFVTTVRanREUVVOR0xFTkJRVU03TzBGQlJVc3NTVUZCU1N4SFFVRkhMRWRCUVVjc2IwSkJRVThzUjBGQlJ5eERRVUZET3pzN1VVRkZjRUlzVjBGQlZ6dFJRVUZGTEUxQlFVMGlMQ0ptYVd4bElqb2lZbUZ6WlM1cWN5SXNJbk52ZFhKalpYTkRiMjUwWlc1MElqcGJJbWx0Y0c5eWRDQjdZM0psWVhSbFJuSmhiV1VzSUdWNGRHVnVaQ3dnZEc5VGRISnBibWQ5SUdaeWIyMGdKeTR2ZFhScGJITW5PMXh1YVcxd2IzSjBJRVY0WTJWd2RHbHZiaUJtY205dElDY3VMMlY0WTJWd2RHbHZiaWM3WEc1cGJYQnZjblFnZTNKbFoybHpkR1Z5UkdWbVlYVnNkRWhsYkhCbGNuTjlJR1p5YjIwZ0p5NHZhR1ZzY0dWeWN5YzdYRzVwYlhCdmNuUWdlM0psWjJsemRHVnlSR1ZtWVhWc2RFUmxZMjl5WVhSdmNuTjlJR1p5YjIwZ0p5NHZaR1ZqYjNKaGRHOXljeWM3WEc1cGJYQnZjblFnYkc5bloyVnlJR1p5YjIwZ0p5NHZiRzluWjJWeUp6dGNibHh1Wlhod2IzSjBJR052Ym5OMElGWkZVbE5KVDA0Z1BTQW5OQzR4TGpJbk8xeHVaWGh3YjNKMElHTnZibk4wSUVOUFRWQkpURVZTWDFKRlZrbFRTVTlPSUQwZ056dGNibHh1Wlhod2IzSjBJR052Ym5OMElGSkZWa2xUU1U5T1gwTklRVTVIUlZNZ1BTQjdYRzRnSURFNklDYzhQU0F4TGpBdWNtTXVNaWNzSUM4dklERXVNQzV5WXk0eUlHbHpJR0ZqZEhWaGJHeDVJSEpsZGpJZ1luVjBJR1J2WlhOdUozUWdjbVZ3YjNKMElHbDBYRzRnSURJNklDYzlQU0F4TGpBdU1DMXlZeTR6Snl4Y2JpQWdNem9nSnowOUlERXVNQzR3TFhKakxqUW5MRnh1SUNBME9pQW5QVDBnTVM1NExuZ25MRnh1SUNBMU9pQW5QVDBnTWk0d0xqQXRZV3h3YUdFdWVDY3NYRzRnSURZNklDYytQU0F5TGpBdU1DMWlaWFJoTGpFbkxGeHVJQ0EzT2lBblBqMGdOQzR3TGpBblhHNTlPMXh1WEc1amIyNXpkQ0J2WW1wbFkzUlVlWEJsSUQwZ0oxdHZZbXBsWTNRZ1QySnFaV04wWFNjN1hHNWNibVY0Y0c5eWRDQm1kVzVqZEdsdmJpQklZVzVrYkdWaVlYSnpSVzUyYVhKdmJtMWxiblFvYUdWc2NHVnljeXdnY0dGeWRHbGhiSE1zSUdSbFkyOXlZWFJ2Y25NcElIdGNiaUFnZEdocGN5NW9aV3h3WlhKeklEMGdhR1ZzY0dWeWN5QjhmQ0I3ZlR0Y2JpQWdkR2hwY3k1d1lYSjBhV0ZzY3lBOUlIQmhjblJwWVd4eklIeDhJSHQ5TzF4dUlDQjBhR2x6TG1SbFkyOXlZWFJ2Y25NZ1BTQmtaV052Y21GMGIzSnpJSHg4SUh0OU8xeHVYRzRnSUhKbFoybHpkR1Z5UkdWbVlYVnNkRWhsYkhCbGNuTW9kR2hwY3lrN1hHNGdJSEpsWjJsemRHVnlSR1ZtWVhWc2RFUmxZMjl5WVhSdmNuTW9kR2hwY3lrN1hHNTlYRzVjYmtoaGJtUnNaV0poY25ORmJuWnBjbTl1YldWdWRDNXdjbTkwYjNSNWNHVWdQU0I3WEc0Z0lHTnZibk4wY25WamRHOXlPaUJJWVc1a2JHVmlZWEp6Ulc1MmFYSnZibTFsYm5Rc1hHNWNiaUFnYkc5bloyVnlPaUJzYjJkblpYSXNYRzRnSUd4dlp6b2diRzluWjJWeUxteHZaeXhjYmx4dUlDQnlaV2RwYzNSbGNraGxiSEJsY2pvZ1puVnVZM1JwYjI0b2JtRnRaU3dnWm00cElIdGNiaUFnSUNCcFppQW9kRzlUZEhKcGJtY3VZMkZzYkNodVlXMWxLU0E5UFQwZ2IySnFaV04wVkhsd1pTa2dlMXh1SUNBZ0lDQWdhV1lnS0dadUtTQjdJSFJvY205M0lHNWxkeUJGZUdObGNIUnBiMjRvSjBGeVp5QnViM1FnYzNWd2NHOXlkR1ZrSUhkcGRHZ2diWFZzZEdsd2JHVWdhR1ZzY0dWeWN5Y3BPeUI5WEc0Z0lDQWdJQ0JsZUhSbGJtUW9kR2hwY3k1b1pXeHdaWEp6TENCdVlXMWxLVHRjYmlBZ0lDQjlJR1ZzYzJVZ2UxeHVJQ0FnSUNBZ2RHaHBjeTVvWld4d1pYSnpXMjVoYldWZElEMGdabTQ3WEc0Z0lDQWdmVnh1SUNCOUxGeHVJQ0IxYm5KbFoybHpkR1Z5U0dWc2NHVnlPaUJtZFc1amRHbHZiaWh1WVcxbEtTQjdYRzRnSUNBZ1pHVnNaWFJsSUhSb2FYTXVhR1ZzY0dWeWMxdHVZVzFsWFR0Y2JpQWdmU3hjYmx4dUlDQnlaV2RwYzNSbGNsQmhjblJwWVd3NklHWjFibU4wYVc5dUtHNWhiV1VzSUhCaGNuUnBZV3dwSUh0Y2JpQWdJQ0JwWmlBb2RHOVRkSEpwYm1jdVkyRnNiQ2h1WVcxbEtTQTlQVDBnYjJKcVpXTjBWSGx3WlNrZ2UxeHVJQ0FnSUNBZ1pYaDBaVzVrS0hSb2FYTXVjR0Z5ZEdsaGJITXNJRzVoYldVcE8xeHVJQ0FnSUgwZ1pXeHpaU0I3WEc0Z0lDQWdJQ0JwWmlBb2RIbHdaVzltSUhCaGNuUnBZV3dnUFQwOUlDZDFibVJsWm1sdVpXUW5LU0I3WEc0Z0lDQWdJQ0FnSUhSb2NtOTNJRzVsZHlCRmVHTmxjSFJwYjI0b1lFRjBkR1Z0Y0hScGJtY2dkRzhnY21WbmFYTjBaWElnWVNCd1lYSjBhV0ZzSUdOaGJHeGxaQ0JjSWlSN2JtRnRaWDFjSWlCaGN5QjFibVJsWm1sdVpXUmdLVHRjYmlBZ0lDQWdJSDFjYmlBZ0lDQWdJSFJvYVhNdWNHRnlkR2xoYkhOYmJtRnRaVjBnUFNCd1lYSjBhV0ZzTzF4dUlDQWdJSDFjYmlBZ2ZTeGNiaUFnZFc1eVpXZHBjM1JsY2xCaGNuUnBZV3c2SUdaMWJtTjBhVzl1S0c1aGJXVXBJSHRjYmlBZ0lDQmtaV3hsZEdVZ2RHaHBjeTV3WVhKMGFXRnNjMXR1WVcxbFhUdGNiaUFnZlN4Y2JseHVJQ0J5WldkcGMzUmxja1JsWTI5eVlYUnZjam9nWm5WdVkzUnBiMjRvYm1GdFpTd2dabTRwSUh0Y2JpQWdJQ0JwWmlBb2RHOVRkSEpwYm1jdVkyRnNiQ2h1WVcxbEtTQTlQVDBnYjJKcVpXTjBWSGx3WlNrZ2UxeHVJQ0FnSUNBZ2FXWWdLR1p1S1NCN0lIUm9jbTkzSUc1bGR5QkZlR05sY0hScGIyNG9KMEZ5WnlCdWIzUWdjM1Z3Y0c5eWRHVmtJSGRwZEdnZ2JYVnNkR2x3YkdVZ1pHVmpiM0poZEc5eWN5Y3BPeUI5WEc0Z0lDQWdJQ0JsZUhSbGJtUW9kR2hwY3k1a1pXTnZjbUYwYjNKekxDQnVZVzFsS1R0Y2JpQWdJQ0I5SUdWc2MyVWdlMXh1SUNBZ0lDQWdkR2hwY3k1a1pXTnZjbUYwYjNKelcyNWhiV1ZkSUQwZ1ptNDdYRzRnSUNBZ2ZWeHVJQ0I5TEZ4dUlDQjFibkpsWjJsemRHVnlSR1ZqYjNKaGRHOXlPaUJtZFc1amRHbHZiaWh1WVcxbEtTQjdYRzRnSUNBZ1pHVnNaWFJsSUhSb2FYTXVaR1ZqYjNKaGRHOXljMXR1WVcxbFhUdGNiaUFnZlZ4dWZUdGNibHh1Wlhod2IzSjBJR3hsZENCc2IyY2dQU0JzYjJkblpYSXViRzluTzF4dVhHNWxlSEJ2Y25RZ2UyTnlaV0YwWlVaeVlXMWxMQ0JzYjJkblpYSjlPMXh1SWwxOVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuZXhwb3J0cy5yZWdpc3RlckRlZmF1bHREZWNvcmF0b3JzID0gcmVnaXN0ZXJEZWZhdWx0RGVjb3JhdG9ycztcbi8vIGlzdGFuYnVsIGlnbm9yZSBuZXh0XG5cbmZ1bmN0aW9uIF9pbnRlcm9wUmVxdWlyZURlZmF1bHQob2JqKSB7IHJldHVybiBvYmogJiYgb2JqLl9fZXNNb2R1bGUgPyBvYmogOiB7ICdkZWZhdWx0Jzogb2JqIH07IH1cblxudmFyIF9kZWNvcmF0b3JzSW5saW5lID0gcmVxdWlyZSgnLi9kZWNvcmF0b3JzL2lubGluZScpO1xuXG52YXIgX2RlY29yYXRvcnNJbmxpbmUyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfZGVjb3JhdG9yc0lubGluZSk7XG5cbmZ1bmN0aW9uIHJlZ2lzdGVyRGVmYXVsdERlY29yYXRvcnMoaW5zdGFuY2UpIHtcbiAgX2RlY29yYXRvcnNJbmxpbmUyWydkZWZhdWx0J10oaW5zdGFuY2UpO1xufVxuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMeTR1TDJ4cFlpOW9ZVzVrYkdWaVlYSnpMMlJsWTI5eVlYUnZjbk11YW5NaVhTd2libUZ0WlhNaU9sdGRMQ0p0WVhCd2FXNW5jeUk2SWpzN096czdPenM3WjBOQlFUSkNMSEZDUVVGeFFqczdPenRCUVVWNlF5eFRRVUZUTEhsQ1FVRjVRaXhEUVVGRExGRkJRVkVzUlVGQlJUdEJRVU5zUkN4blEwRkJaU3hSUVVGUkxFTkJRVU1zUTBGQlF6dERRVU14UWlJc0ltWnBiR1VpT2lKa1pXTnZjbUYwYjNKekxtcHpJaXdpYzI5MWNtTmxjME52Ym5SbGJuUWlPbHNpYVcxd2IzSjBJSEpsWjJsemRHVnlTVzVzYVc1bElHWnliMjBnSnk0dlpHVmpiM0poZEc5eWN5OXBibXhwYm1Vbk8xeHVYRzVsZUhCdmNuUWdablZ1WTNScGIyNGdjbVZuYVhOMFpYSkVaV1poZFd4MFJHVmpiM0poZEc5eWN5aHBibk4wWVc1alpTa2dlMXh1SUNCeVpXZHBjM1JsY2tsdWJHbHVaU2hwYm5OMFlXNWpaU2s3WEc1OVhHNWNiaUpkZlE9PVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuXG52YXIgX3V0aWxzID0gcmVxdWlyZSgnLi4vdXRpbHMnKTtcblxuZXhwb3J0c1snZGVmYXVsdCddID0gZnVuY3Rpb24gKGluc3RhbmNlKSB7XG4gIGluc3RhbmNlLnJlZ2lzdGVyRGVjb3JhdG9yKCdpbmxpbmUnLCBmdW5jdGlvbiAoZm4sIHByb3BzLCBjb250YWluZXIsIG9wdGlvbnMpIHtcbiAgICB2YXIgcmV0ID0gZm47XG4gICAgaWYgKCFwcm9wcy5wYXJ0aWFscykge1xuICAgICAgcHJvcHMucGFydGlhbHMgPSB7fTtcbiAgICAgIHJldCA9IGZ1bmN0aW9uIChjb250ZXh0LCBvcHRpb25zKSB7XG4gICAgICAgIC8vIENyZWF0ZSBhIG5ldyBwYXJ0aWFscyBzdGFjayBmcmFtZSBwcmlvciB0byBleGVjLlxuICAgICAgICB2YXIgb3JpZ2luYWwgPSBjb250YWluZXIucGFydGlhbHM7XG4gICAgICAgIGNvbnRhaW5lci5wYXJ0aWFscyA9IF91dGlscy5leHRlbmQoe30sIG9yaWdpbmFsLCBwcm9wcy5wYXJ0aWFscyk7XG4gICAgICAgIHZhciByZXQgPSBmbihjb250ZXh0LCBvcHRpb25zKTtcbiAgICAgICAgY29udGFpbmVyLnBhcnRpYWxzID0gb3JpZ2luYWw7XG4gICAgICAgIHJldHVybiByZXQ7XG4gICAgICB9O1xuICAgIH1cblxuICAgIHByb3BzLnBhcnRpYWxzW29wdGlvbnMuYXJnc1swXV0gPSBvcHRpb25zLmZuO1xuXG4gICAgcmV0dXJuIHJldDtcbiAgfSk7XG59O1xuXG5tb2R1bGUuZXhwb3J0cyA9IGV4cG9ydHNbJ2RlZmF1bHQnXTtcbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUx5NHVMMnhwWWk5b1lXNWtiR1ZpWVhKekwyUmxZMjl5WVhSdmNuTXZhVzVzYVc1bExtcHpJbDBzSW01aGJXVnpJanBiWFN3aWJXRndjR2x1WjNNaU9pSTdPenM3Y1VKQlFYRkNMRlZCUVZVN08zRkNRVVZvUWl4VlFVRlRMRkZCUVZFc1JVRkJSVHRCUVVOb1F5eFZRVUZSTEVOQlFVTXNhVUpCUVdsQ0xFTkJRVU1zVVVGQlVTeEZRVUZGTEZWQlFWTXNSVUZCUlN4RlFVRkZMRXRCUVVzc1JVRkJSU3hUUVVGVExFVkJRVVVzVDBGQlR5eEZRVUZGTzBGQlF6TkZMRkZCUVVrc1IwRkJSeXhIUVVGSExFVkJRVVVzUTBGQlF6dEJRVU5pTEZGQlFVa3NRMEZCUXl4TFFVRkxMRU5CUVVNc1VVRkJVU3hGUVVGRk8wRkJRMjVDTEZkQlFVc3NRMEZCUXl4UlFVRlJMRWRCUVVjc1JVRkJSU3hEUVVGRE8wRkJRM0JDTEZOQlFVY3NSMEZCUnl4VlFVRlRMRTlCUVU4c1JVRkJSU3hQUVVGUExFVkJRVVU3TzBGQlJTOUNMRmxCUVVrc1VVRkJVU3hIUVVGSExGTkJRVk1zUTBGQlF5eFJRVUZSTEVOQlFVTTdRVUZEYkVNc2FVSkJRVk1zUTBGQlF5eFJRVUZSTEVkQlFVY3NZMEZCVHl4RlFVRkZMRVZCUVVVc1VVRkJVU3hGUVVGRkxFdEJRVXNzUTBGQlF5eFJRVUZSTEVOQlFVTXNRMEZCUXp0QlFVTXhSQ3haUVVGSkxFZEJRVWNzUjBGQlJ5eEZRVUZGTEVOQlFVTXNUMEZCVHl4RlFVRkZMRTlCUVU4c1EwRkJReXhEUVVGRE8wRkJReTlDTEdsQ1FVRlRMRU5CUVVNc1VVRkJVU3hIUVVGSExGRkJRVkVzUTBGQlF6dEJRVU01UWl4bFFVRlBMRWRCUVVjc1EwRkJRenRQUVVOYUxFTkJRVU03UzBGRFNEczdRVUZGUkN4VFFVRkxMRU5CUVVNc1VVRkJVU3hEUVVGRExFOUJRVThzUTBGQlF5eEpRVUZKTEVOQlFVTXNRMEZCUXl4RFFVRkRMRU5CUVVNc1IwRkJSeXhQUVVGUExFTkJRVU1zUlVGQlJTeERRVUZET3p0QlFVVTNReXhYUVVGUExFZEJRVWNzUTBGQlF6dEhRVU5hTEVOQlFVTXNRMEZCUXp0RFFVTktJaXdpWm1sc1pTSTZJbWx1YkdsdVpTNXFjeUlzSW5OdmRYSmpaWE5EYjI1MFpXNTBJanBiSW1sdGNHOXlkQ0I3WlhoMFpXNWtmU0JtY205dElDY3VMaTkxZEdsc2N5YzdYRzVjYm1WNGNHOXlkQ0JrWldaaGRXeDBJR1oxYm1OMGFXOXVLR2x1YzNSaGJtTmxLU0I3WEc0Z0lHbHVjM1JoYm1ObExuSmxaMmx6ZEdWeVJHVmpiM0poZEc5eUtDZHBibXhwYm1VbkxDQm1kVzVqZEdsdmJpaG1iaXdnY0hKdmNITXNJR052Ym5SaGFXNWxjaXdnYjNCMGFXOXVjeWtnZTF4dUlDQWdJR3hsZENCeVpYUWdQU0JtYmp0Y2JpQWdJQ0JwWmlBb0lYQnliM0J6TG5CaGNuUnBZV3h6S1NCN1hHNGdJQ0FnSUNCd2NtOXdjeTV3WVhKMGFXRnNjeUE5SUh0OU8xeHVJQ0FnSUNBZ2NtVjBJRDBnWm5WdVkzUnBiMjRvWTI5dWRHVjRkQ3dnYjNCMGFXOXVjeWtnZTF4dUlDQWdJQ0FnSUNBdkx5QkRjbVZoZEdVZ1lTQnVaWGNnY0dGeWRHbGhiSE1nYzNSaFkyc2dabkpoYldVZ2NISnBiM0lnZEc4Z1pYaGxZeTVjYmlBZ0lDQWdJQ0FnYkdWMElHOXlhV2RwYm1Gc0lEMGdZMjl1ZEdGcGJtVnlMbkJoY25ScFlXeHpPMXh1SUNBZ0lDQWdJQ0JqYjI1MFlXbHVaWEl1Y0dGeWRHbGhiSE1nUFNCbGVIUmxibVFvZTMwc0lHOXlhV2RwYm1Gc0xDQndjbTl3Y3k1d1lYSjBhV0ZzY3lrN1hHNGdJQ0FnSUNBZ0lHeGxkQ0J5WlhRZ1BTQm1iaWhqYjI1MFpYaDBMQ0J2Y0hScGIyNXpLVHRjYmlBZ0lDQWdJQ0FnWTI5dWRHRnBibVZ5TG5CaGNuUnBZV3h6SUQwZ2IzSnBaMmx1WVd3N1hHNGdJQ0FnSUNBZ0lISmxkSFZ5YmlCeVpYUTdYRzRnSUNBZ0lDQjlPMXh1SUNBZ0lIMWNibHh1SUNBZ0lIQnliM0J6TG5CaGNuUnBZV3h6VzI5d2RHbHZibk11WVhKbmMxc3dYVjBnUFNCdmNIUnBiMjV6TG1adU8xeHVYRzRnSUNBZ2NtVjBkWEp1SUhKbGREdGNiaUFnZlNrN1hHNTlYRzRpWFgwPVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuXG52YXIgZXJyb3JQcm9wcyA9IFsnZGVzY3JpcHRpb24nLCAnZmlsZU5hbWUnLCAnbGluZU51bWJlcicsICdtZXNzYWdlJywgJ25hbWUnLCAnbnVtYmVyJywgJ3N0YWNrJ107XG5cbmZ1bmN0aW9uIEV4Y2VwdGlvbihtZXNzYWdlLCBub2RlKSB7XG4gIHZhciBsb2MgPSBub2RlICYmIG5vZGUubG9jLFxuICAgICAgbGluZSA9IHVuZGVmaW5lZCxcbiAgICAgIGNvbHVtbiA9IHVuZGVmaW5lZDtcbiAgaWYgKGxvYykge1xuICAgIGxpbmUgPSBsb2Muc3RhcnQubGluZTtcbiAgICBjb2x1bW4gPSBsb2Muc3RhcnQuY29sdW1uO1xuXG4gICAgbWVzc2FnZSArPSAnIC0gJyArIGxpbmUgKyAnOicgKyBjb2x1bW47XG4gIH1cblxuICB2YXIgdG1wID0gRXJyb3IucHJvdG90eXBlLmNvbnN0cnVjdG9yLmNhbGwodGhpcywgbWVzc2FnZSk7XG5cbiAgLy8gVW5mb3J0dW5hdGVseSBlcnJvcnMgYXJlIG5vdCBlbnVtZXJhYmxlIGluIENocm9tZSAoYXQgbGVhc3QpLCBzbyBgZm9yIHByb3AgaW4gdG1wYCBkb2Vzbid0IHdvcmsuXG4gIGZvciAodmFyIGlkeCA9IDA7IGlkeCA8IGVycm9yUHJvcHMubGVuZ3RoOyBpZHgrKykge1xuICAgIHRoaXNbZXJyb3JQcm9wc1tpZHhdXSA9IHRtcFtlcnJvclByb3BzW2lkeF1dO1xuICB9XG5cbiAgLyogaXN0YW5idWwgaWdub3JlIGVsc2UgKi9cbiAgaWYgKEVycm9yLmNhcHR1cmVTdGFja1RyYWNlKSB7XG4gICAgRXJyb3IuY2FwdHVyZVN0YWNrVHJhY2UodGhpcywgRXhjZXB0aW9uKTtcbiAgfVxuXG4gIHRyeSB7XG4gICAgaWYgKGxvYykge1xuICAgICAgdGhpcy5saW5lTnVtYmVyID0gbGluZTtcblxuICAgICAgLy8gV29yayBhcm91bmQgaXNzdWUgdW5kZXIgc2FmYXJpIHdoZXJlIHdlIGNhbid0IGRpcmVjdGx5IHNldCB0aGUgY29sdW1uIHZhbHVlXG4gICAgICAvKiBpc3RhbmJ1bCBpZ25vcmUgbmV4dCAqL1xuICAgICAgaWYgKE9iamVjdC5kZWZpbmVQcm9wZXJ0eSkge1xuICAgICAgICBPYmplY3QuZGVmaW5lUHJvcGVydHkodGhpcywgJ2NvbHVtbicsIHtcbiAgICAgICAgICB2YWx1ZTogY29sdW1uLFxuICAgICAgICAgIGVudW1lcmFibGU6IHRydWVcbiAgICAgICAgfSk7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0aGlzLmNvbHVtbiA9IGNvbHVtbjtcbiAgICAgIH1cbiAgICB9XG4gIH0gY2F0Y2ggKG5vcCkge1xuICAgIC8qIElnbm9yZSBpZiB0aGUgYnJvd3NlciBpcyB2ZXJ5IHBhcnRpY3VsYXIgKi9cbiAgfVxufVxuXG5FeGNlcHRpb24ucHJvdG90eXBlID0gbmV3IEVycm9yKCk7XG5cbmV4cG9ydHNbJ2RlZmF1bHQnXSA9IEV4Y2VwdGlvbjtcbm1vZHVsZS5leHBvcnRzID0gZXhwb3J0c1snZGVmYXVsdCddO1xuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMeTR1TDJ4cFlpOW9ZVzVrYkdWaVlYSnpMMlY0WTJWd2RHbHZiaTVxY3lKZExDSnVZVzFsY3lJNlcxMHNJbTFoY0hCcGJtZHpJam9pT3pzN08wRkJRMEVzU1VGQlRTeFZRVUZWTEVkQlFVY3NRMEZCUXl4aFFVRmhMRVZCUVVVc1ZVRkJWU3hGUVVGRkxGbEJRVmtzUlVGQlJTeFRRVUZUTEVWQlFVVXNUVUZCVFN4RlFVRkZMRkZCUVZFc1JVRkJSU3hQUVVGUExFTkJRVU1zUTBGQlF6czdRVUZGYmtjc1UwRkJVeXhUUVVGVExFTkJRVU1zVDBGQlR5eEZRVUZGTEVsQlFVa3NSVUZCUlR0QlFVTm9ReXhOUVVGSkxFZEJRVWNzUjBGQlJ5eEpRVUZKTEVsQlFVa3NTVUZCU1N4RFFVRkRMRWRCUVVjN1RVRkRkRUlzU1VGQlNTeFpRVUZCTzAxQlEwb3NUVUZCVFN4WlFVRkJMRU5CUVVNN1FVRkRXQ3hOUVVGSkxFZEJRVWNzUlVGQlJUdEJRVU5RTEZGQlFVa3NSMEZCUnl4SFFVRkhMRU5CUVVNc1MwRkJTeXhEUVVGRExFbEJRVWtzUTBGQlF6dEJRVU4wUWl4VlFVRk5MRWRCUVVjc1IwRkJSeXhEUVVGRExFdEJRVXNzUTBGQlF5eE5RVUZOTEVOQlFVTTdPMEZCUlRGQ0xGZEJRVThzU1VGQlNTeExRVUZMTEVkQlFVY3NTVUZCU1N4SFFVRkhMRWRCUVVjc1IwRkJSeXhOUVVGTkxFTkJRVU03UjBGRGVFTTdPMEZCUlVRc1RVRkJTU3hIUVVGSExFZEJRVWNzUzBGQlN5eERRVUZETEZOQlFWTXNRMEZCUXl4WFFVRlhMRU5CUVVNc1NVRkJTU3hEUVVGRExFbEJRVWtzUlVGQlJTeFBRVUZQTEVOQlFVTXNRMEZCUXpzN08wRkJSekZFTEU5QlFVc3NTVUZCU1N4SFFVRkhMRWRCUVVjc1EwRkJReXhGUVVGRkxFZEJRVWNzUjBGQlJ5eFZRVUZWTEVOQlFVTXNUVUZCVFN4RlFVRkZMRWRCUVVjc1JVRkJSU3hGUVVGRk8wRkJRMmhFTEZGQlFVa3NRMEZCUXl4VlFVRlZMRU5CUVVNc1IwRkJSeXhEUVVGRExFTkJRVU1zUjBGQlJ5eEhRVUZITEVOQlFVTXNWVUZCVlN4RFFVRkRMRWRCUVVjc1EwRkJReXhEUVVGRExFTkJRVU03UjBGRE9VTTdPenRCUVVkRUxFMUJRVWtzUzBGQlN5eERRVUZETEdsQ1FVRnBRaXhGUVVGRk8wRkJRek5DTEZOQlFVc3NRMEZCUXl4cFFrRkJhVUlzUTBGQlF5eEpRVUZKTEVWQlFVVXNVMEZCVXl4RFFVRkRMRU5CUVVNN1IwRkRNVU03TzBGQlJVUXNUVUZCU1R0QlFVTkdMRkZCUVVrc1IwRkJSeXhGUVVGRk8wRkJRMUFzVlVGQlNTeERRVUZETEZWQlFWVXNSMEZCUnl4SlFVRkpMRU5CUVVNN096czdRVUZKZGtJc1ZVRkJTU3hOUVVGTkxFTkJRVU1zWTBGQll5eEZRVUZGTzBGQlEzcENMR05CUVUwc1EwRkJReXhqUVVGakxFTkJRVU1zU1VGQlNTeEZRVUZGTEZGQlFWRXNSVUZCUlR0QlFVTndReXhsUVVGTExFVkJRVVVzVFVGQlRUdEJRVU5pTEc5Q1FVRlZMRVZCUVVVc1NVRkJTVHRUUVVOcVFpeERRVUZETEVOQlFVTTdUMEZEU2l4TlFVRk5PMEZCUTB3c1dVRkJTU3hEUVVGRExFMUJRVTBzUjBGQlJ5eE5RVUZOTEVOQlFVTTdUMEZEZEVJN1MwRkRSanRIUVVOR0xFTkJRVU1zVDBGQlR5eEhRVUZITEVWQlFVVTdPMGRCUldJN1EwRkRSanM3UVVGRlJDeFRRVUZUTEVOQlFVTXNVMEZCVXl4SFFVRkhMRWxCUVVrc1MwRkJTeXhGUVVGRkxFTkJRVU03TzNGQ1FVVnVRaXhUUVVGVElpd2labWxzWlNJNkltVjRZMlZ3ZEdsdmJpNXFjeUlzSW5OdmRYSmpaWE5EYjI1MFpXNTBJanBiSWx4dVkyOXVjM1FnWlhKeWIzSlFjbTl3Y3lBOUlGc25aR1Z6WTNKcGNIUnBiMjRuTENBblptbHNaVTVoYldVbkxDQW5iR2x1WlU1MWJXSmxjaWNzSUNkdFpYTnpZV2RsSnl3Z0oyNWhiV1VuTENBbmJuVnRZbVZ5Snl3Z0ozTjBZV05ySjEwN1hHNWNibVoxYm1OMGFXOXVJRVY0WTJWd2RHbHZiaWh0WlhOellXZGxMQ0J1YjJSbEtTQjdYRzRnSUd4bGRDQnNiMk1nUFNCdWIyUmxJQ1ltSUc1dlpHVXViRzlqTEZ4dUlDQWdJQ0FnYkdsdVpTeGNiaUFnSUNBZ0lHTnZiSFZ0Ymp0Y2JpQWdhV1lnS0d4dll5a2dlMXh1SUNBZ0lHeHBibVVnUFNCc2IyTXVjM1JoY25RdWJHbHVaVHRjYmlBZ0lDQmpiMngxYlc0Z1BTQnNiMk11YzNSaGNuUXVZMjlzZFcxdU8xeHVYRzRnSUNBZ2JXVnpjMkZuWlNBclBTQW5JQzBnSnlBcklHeHBibVVnS3lBbk9pY2dLeUJqYjJ4MWJXNDdYRzRnSUgxY2JseHVJQ0JzWlhRZ2RHMXdJRDBnUlhKeWIzSXVjSEp2ZEc5MGVYQmxMbU52Ym5OMGNuVmpkRzl5TG1OaGJHd29kR2hwY3l3Z2JXVnpjMkZuWlNrN1hHNWNiaUFnTHk4Z1ZXNW1iM0owZFc1aGRHVnNlU0JsY25KdmNuTWdZWEpsSUc1dmRDQmxiblZ0WlhKaFlteGxJR2x1SUVOb2NtOXRaU0FvWVhRZ2JHVmhjM1FwTENCemJ5QmdabTl5SUhCeWIzQWdhVzRnZEcxd1lDQmtiMlZ6YmlkMElIZHZjbXN1WEc0Z0lHWnZjaUFvYkdWMElHbGtlQ0E5SURBN0lHbGtlQ0E4SUdWeWNtOXlVSEp2Y0hNdWJHVnVaM1JvT3lCcFpIZ3JLeWtnZTF4dUlDQWdJSFJvYVhOYlpYSnliM0pRY205d2MxdHBaSGhkWFNBOUlIUnRjRnRsY25KdmNsQnliM0J6VzJsa2VGMWRPMXh1SUNCOVhHNWNiaUFnTHlvZ2FYTjBZVzVpZFd3Z2FXZHViM0psSUdWc2MyVWdLaTljYmlBZ2FXWWdLRVZ5Y205eUxtTmhjSFIxY21WVGRHRmphMVJ5WVdObEtTQjdYRzRnSUNBZ1JYSnliM0l1WTJGd2RIVnlaVk4wWVdOclZISmhZMlVvZEdocGN5d2dSWGhqWlhCMGFXOXVLVHRjYmlBZ2ZWeHVYRzRnSUhSeWVTQjdYRzRnSUNBZ2FXWWdLR3h2WXlrZ2UxeHVJQ0FnSUNBZ2RHaHBjeTVzYVc1bFRuVnRZbVZ5SUQwZ2JHbHVaVHRjYmx4dUlDQWdJQ0FnTHk4Z1YyOXlheUJoY205MWJtUWdhWE56ZFdVZ2RXNWtaWElnYzJGbVlYSnBJSGRvWlhKbElIZGxJR05oYmlkMElHUnBjbVZqZEd4NUlITmxkQ0IwYUdVZ1kyOXNkVzF1SUhaaGJIVmxYRzRnSUNBZ0lDQXZLaUJwYzNSaGJtSjFiQ0JwWjI1dmNtVWdibVY0ZENBcUwxeHVJQ0FnSUNBZ2FXWWdLRTlpYW1WamRDNWtaV1pwYm1WUWNtOXdaWEowZVNrZ2UxeHVJQ0FnSUNBZ0lDQlBZbXBsWTNRdVpHVm1hVzVsVUhKdmNHVnlkSGtvZEdocGN5d2dKMk52YkhWdGJpY3NJSHRjYmlBZ0lDQWdJQ0FnSUNCMllXeDFaVG9nWTI5c2RXMXVMRnh1SUNBZ0lDQWdJQ0FnSUdWdWRXMWxjbUZpYkdVNklIUnlkV1ZjYmlBZ0lDQWdJQ0FnZlNrN1hHNGdJQ0FnSUNCOUlHVnNjMlVnZTF4dUlDQWdJQ0FnSUNCMGFHbHpMbU52YkhWdGJpQTlJR052YkhWdGJqdGNiaUFnSUNBZ0lIMWNiaUFnSUNCOVhHNGdJSDBnWTJGMFkyZ2dLRzV2Y0NrZ2UxeHVJQ0FnSUM4cUlFbG5ibTl5WlNCcFppQjBhR1VnWW5KdmQzTmxjaUJwY3lCMlpYSjVJSEJoY25ScFkzVnNZWElnS2k5Y2JpQWdmVnh1ZlZ4dVhHNUZlR05sY0hScGIyNHVjSEp2ZEc5MGVYQmxJRDBnYm1WM0lFVnljbTl5S0NrN1hHNWNibVY0Y0c5eWRDQmtaV1poZFd4MElFVjRZMlZ3ZEdsdmJqdGNiaUpkZlE9PVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuZXhwb3J0cy5yZWdpc3RlckRlZmF1bHRIZWxwZXJzID0gcmVnaXN0ZXJEZWZhdWx0SGVscGVycztcbi8vIGlzdGFuYnVsIGlnbm9yZSBuZXh0XG5cbmZ1bmN0aW9uIF9pbnRlcm9wUmVxdWlyZURlZmF1bHQob2JqKSB7IHJldHVybiBvYmogJiYgb2JqLl9fZXNNb2R1bGUgPyBvYmogOiB7ICdkZWZhdWx0Jzogb2JqIH07IH1cblxudmFyIF9oZWxwZXJzQmxvY2tIZWxwZXJNaXNzaW5nID0gcmVxdWlyZSgnLi9oZWxwZXJzL2Jsb2NrLWhlbHBlci1taXNzaW5nJyk7XG5cbnZhciBfaGVscGVyc0Jsb2NrSGVscGVyTWlzc2luZzIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9oZWxwZXJzQmxvY2tIZWxwZXJNaXNzaW5nKTtcblxudmFyIF9oZWxwZXJzRWFjaCA9IHJlcXVpcmUoJy4vaGVscGVycy9lYWNoJyk7XG5cbnZhciBfaGVscGVyc0VhY2gyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfaGVscGVyc0VhY2gpO1xuXG52YXIgX2hlbHBlcnNIZWxwZXJNaXNzaW5nID0gcmVxdWlyZSgnLi9oZWxwZXJzL2hlbHBlci1taXNzaW5nJyk7XG5cbnZhciBfaGVscGVyc0hlbHBlck1pc3NpbmcyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfaGVscGVyc0hlbHBlck1pc3NpbmcpO1xuXG52YXIgX2hlbHBlcnNJZiA9IHJlcXVpcmUoJy4vaGVscGVycy9pZicpO1xuXG52YXIgX2hlbHBlcnNJZjIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9oZWxwZXJzSWYpO1xuXG52YXIgX2hlbHBlcnNMb2cgPSByZXF1aXJlKCcuL2hlbHBlcnMvbG9nJyk7XG5cbnZhciBfaGVscGVyc0xvZzIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9oZWxwZXJzTG9nKTtcblxudmFyIF9oZWxwZXJzTG9va3VwID0gcmVxdWlyZSgnLi9oZWxwZXJzL2xvb2t1cCcpO1xuXG52YXIgX2hlbHBlcnNMb29rdXAyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfaGVscGVyc0xvb2t1cCk7XG5cbnZhciBfaGVscGVyc1dpdGggPSByZXF1aXJlKCcuL2hlbHBlcnMvd2l0aCcpO1xuXG52YXIgX2hlbHBlcnNXaXRoMiA9IF9pbnRlcm9wUmVxdWlyZURlZmF1bHQoX2hlbHBlcnNXaXRoKTtcblxuZnVuY3Rpb24gcmVnaXN0ZXJEZWZhdWx0SGVscGVycyhpbnN0YW5jZSkge1xuICBfaGVscGVyc0Jsb2NrSGVscGVyTWlzc2luZzJbJ2RlZmF1bHQnXShpbnN0YW5jZSk7XG4gIF9oZWxwZXJzRWFjaDJbJ2RlZmF1bHQnXShpbnN0YW5jZSk7XG4gIF9oZWxwZXJzSGVscGVyTWlzc2luZzJbJ2RlZmF1bHQnXShpbnN0YW5jZSk7XG4gIF9oZWxwZXJzSWYyWydkZWZhdWx0J10oaW5zdGFuY2UpO1xuICBfaGVscGVyc0xvZzJbJ2RlZmF1bHQnXShpbnN0YW5jZSk7XG4gIF9oZWxwZXJzTG9va3VwMlsnZGVmYXVsdCddKGluc3RhbmNlKTtcbiAgX2hlbHBlcnNXaXRoMlsnZGVmYXVsdCddKGluc3RhbmNlKTtcbn1cbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDJobGJIQmxjbk11YW5NaVhTd2libUZ0WlhNaU9sdGRMQ0p0WVhCd2FXNW5jeUk2SWpzN096czdPenM3ZVVOQlFYVkRMR2REUVVGblF6czdPenN5UWtGRE9VTXNaMEpCUVdkQ096czdPMjlEUVVOUUxEQkNRVUV3UWpzN096dDVRa0ZEY2tNc1kwRkJZenM3T3pzd1FrRkRZaXhsUVVGbE96czdPelpDUVVOYUxHdENRVUZyUWpzN096c3lRa0ZEY0VJc1owSkJRV2RDT3pzN08wRkJSV3hETEZOQlFWTXNjMEpCUVhOQ0xFTkJRVU1zVVVGQlVTeEZRVUZGTzBGQlF5OURMSGxEUVVFeVFpeFJRVUZSTEVOQlFVTXNRMEZCUXp0QlFVTnlReXd5UWtGQllTeFJRVUZSTEVOQlFVTXNRMEZCUXp0QlFVTjJRaXh2UTBGQmMwSXNVVUZCVVN4RFFVRkRMRU5CUVVNN1FVRkRhRU1zZVVKQlFWY3NVVUZCVVN4RFFVRkRMRU5CUVVNN1FVRkRja0lzTUVKQlFWa3NVVUZCVVN4RFFVRkRMRU5CUVVNN1FVRkRkRUlzTmtKQlFXVXNVVUZCVVN4RFFVRkRMRU5CUVVNN1FVRkRla0lzTWtKQlFXRXNVVUZCVVN4RFFVRkRMRU5CUVVNN1EwRkRlRUlpTENKbWFXeGxJam9pYUdWc2NHVnljeTVxY3lJc0luTnZkWEpqWlhORGIyNTBaVzUwSWpwYkltbHRjRzl5ZENCeVpXZHBjM1JsY2tKc2IyTnJTR1ZzY0dWeVRXbHpjMmx1WnlCbWNtOXRJQ2N1TDJobGJIQmxjbk12WW14dlkyc3RhR1ZzY0dWeUxXMXBjM05wYm1jbk8xeHVhVzF3YjNKMElISmxaMmx6ZEdWeVJXRmphQ0JtY205dElDY3VMMmhsYkhCbGNuTXZaV0ZqYUNjN1hHNXBiWEJ2Y25RZ2NtVm5hWE4wWlhKSVpXeHdaWEpOYVhOemFXNW5JR1p5YjIwZ0p5NHZhR1ZzY0dWeWN5OW9aV3h3WlhJdGJXbHpjMmx1WnljN1hHNXBiWEJ2Y25RZ2NtVm5hWE4wWlhKSlppQm1jbTl0SUNjdUwyaGxiSEJsY25NdmFXWW5PMXh1YVcxd2IzSjBJSEpsWjJsemRHVnlURzluSUdaeWIyMGdKeTR2YUdWc2NHVnljeTlzYjJjbk8xeHVhVzF3YjNKMElISmxaMmx6ZEdWeVRHOXZhM1Z3SUdaeWIyMGdKeTR2YUdWc2NHVnljeTlzYjI5cmRYQW5PMXh1YVcxd2IzSjBJSEpsWjJsemRHVnlWMmwwYUNCbWNtOXRJQ2N1TDJobGJIQmxjbk12ZDJsMGFDYzdYRzVjYm1WNGNHOXlkQ0JtZFc1amRHbHZiaUJ5WldkcGMzUmxja1JsWm1GMWJIUklaV3h3WlhKektHbHVjM1JoYm1ObEtTQjdYRzRnSUhKbFoybHpkR1Z5UW14dlkydElaV3h3WlhKTmFYTnphVzVuS0dsdWMzUmhibU5sS1R0Y2JpQWdjbVZuYVhOMFpYSkZZV05vS0dsdWMzUmhibU5sS1R0Y2JpQWdjbVZuYVhOMFpYSklaV3h3WlhKTmFYTnphVzVuS0dsdWMzUmhibU5sS1R0Y2JpQWdjbVZuYVhOMFpYSkpaaWhwYm5OMFlXNWpaU2s3WEc0Z0lISmxaMmx6ZEdWeVRHOW5LR2x1YzNSaGJtTmxLVHRjYmlBZ2NtVm5hWE4wWlhKTWIyOXJkWEFvYVc1emRHRnVZMlVwTzF4dUlDQnlaV2RwYzNSbGNsZHBkR2dvYVc1emRHRnVZMlVwTzF4dWZWeHVJbDE5XG4iLCIndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG5cbnZhciBfdXRpbHMgPSByZXF1aXJlKCcuLi91dGlscycpO1xuXG5leHBvcnRzWydkZWZhdWx0J10gPSBmdW5jdGlvbiAoaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ2Jsb2NrSGVscGVyTWlzc2luZycsIGZ1bmN0aW9uIChjb250ZXh0LCBvcHRpb25zKSB7XG4gICAgdmFyIGludmVyc2UgPSBvcHRpb25zLmludmVyc2UsXG4gICAgICAgIGZuID0gb3B0aW9ucy5mbjtcblxuICAgIGlmIChjb250ZXh0ID09PSB0cnVlKSB7XG4gICAgICByZXR1cm4gZm4odGhpcyk7XG4gICAgfSBlbHNlIGlmIChjb250ZXh0ID09PSBmYWxzZSB8fCBjb250ZXh0ID09IG51bGwpIHtcbiAgICAgIHJldHVybiBpbnZlcnNlKHRoaXMpO1xuICAgIH0gZWxzZSBpZiAoX3V0aWxzLmlzQXJyYXkoY29udGV4dCkpIHtcbiAgICAgIGlmIChjb250ZXh0Lmxlbmd0aCA+IDApIHtcbiAgICAgICAgaWYgKG9wdGlvbnMuaWRzKSB7XG4gICAgICAgICAgb3B0aW9ucy5pZHMgPSBbb3B0aW9ucy5uYW1lXTtcbiAgICAgICAgfVxuXG4gICAgICAgIHJldHVybiBpbnN0YW5jZS5oZWxwZXJzLmVhY2goY29udGV4dCwgb3B0aW9ucyk7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICByZXR1cm4gaW52ZXJzZSh0aGlzKTtcbiAgICAgIH1cbiAgICB9IGVsc2Uge1xuICAgICAgaWYgKG9wdGlvbnMuZGF0YSAmJiBvcHRpb25zLmlkcykge1xuICAgICAgICB2YXIgZGF0YSA9IF91dGlscy5jcmVhdGVGcmFtZShvcHRpb25zLmRhdGEpO1xuICAgICAgICBkYXRhLmNvbnRleHRQYXRoID0gX3V0aWxzLmFwcGVuZENvbnRleHRQYXRoKG9wdGlvbnMuZGF0YS5jb250ZXh0UGF0aCwgb3B0aW9ucy5uYW1lKTtcbiAgICAgICAgb3B0aW9ucyA9IHsgZGF0YTogZGF0YSB9O1xuICAgICAgfVxuXG4gICAgICByZXR1cm4gZm4oY29udGV4dCwgb3B0aW9ucyk7XG4gICAgfVxuICB9KTtcbn07XG5cbm1vZHVsZS5leHBvcnRzID0gZXhwb3J0c1snZGVmYXVsdCddO1xuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDJobGJIQmxjbk12WW14dlkyc3RhR1ZzY0dWeUxXMXBjM05wYm1jdWFuTWlYU3dpYm1GdFpYTWlPbHRkTENKdFlYQndhVzVuY3lJNklqczdPenR4UWtGQmMwUXNWVUZCVlRzN2NVSkJSV3BFTEZWQlFWTXNVVUZCVVN4RlFVRkZPMEZCUTJoRExGVkJRVkVzUTBGQlF5eGpRVUZqTEVOQlFVTXNiMEpCUVc5Q0xFVkJRVVVzVlVGQlV5eFBRVUZQTEVWQlFVVXNUMEZCVHl4RlFVRkZPMEZCUTNaRkxGRkJRVWtzVDBGQlR5eEhRVUZITEU5QlFVOHNRMEZCUXl4UFFVRlBPMUZCUTNwQ0xFVkJRVVVzUjBGQlJ5eFBRVUZQTEVOQlFVTXNSVUZCUlN4RFFVRkRPenRCUVVWd1FpeFJRVUZKTEU5QlFVOHNTMEZCU3l4SlFVRkpMRVZCUVVVN1FVRkRjRUlzWVVGQlR5eEZRVUZGTEVOQlFVTXNTVUZCU1N4RFFVRkRMRU5CUVVNN1MwRkRha0lzVFVGQlRTeEpRVUZKTEU5QlFVOHNTMEZCU3l4TFFVRkxMRWxCUVVrc1QwRkJUeXhKUVVGSkxFbEJRVWtzUlVGQlJUdEJRVU12UXl4aFFVRlBMRTlCUVU4c1EwRkJReXhKUVVGSkxFTkJRVU1zUTBGQlF6dExRVU4wUWl4TlFVRk5MRWxCUVVrc1pVRkJVU3hQUVVGUExFTkJRVU1zUlVGQlJUdEJRVU16UWl4VlFVRkpMRTlCUVU4c1EwRkJReXhOUVVGTkxFZEJRVWNzUTBGQlF5eEZRVUZGTzBGQlEzUkNMRmxCUVVrc1QwRkJUeXhEUVVGRExFZEJRVWNzUlVGQlJUdEJRVU5tTEdsQ1FVRlBMRU5CUVVNc1IwRkJSeXhIUVVGSExFTkJRVU1zVDBGQlR5eERRVUZETEVsQlFVa3NRMEZCUXl4RFFVRkRPMU5CUXpsQ096dEJRVVZFTEdWQlFVOHNVVUZCVVN4RFFVRkRMRTlCUVU4c1EwRkJReXhKUVVGSkxFTkJRVU1zVDBGQlR5eEZRVUZGTEU5QlFVOHNRMEZCUXl4RFFVRkRPMDlCUTJoRUxFMUJRVTA3UVVGRFRDeGxRVUZQTEU5QlFVOHNRMEZCUXl4SlFVRkpMRU5CUVVNc1EwRkJRenRQUVVOMFFqdExRVU5HTEUxQlFVMDdRVUZEVEN4VlFVRkpMRTlCUVU4c1EwRkJReXhKUVVGSkxFbEJRVWtzVDBGQlR5eERRVUZETEVkQlFVY3NSVUZCUlR0QlFVTXZRaXhaUVVGSkxFbEJRVWtzUjBGQlJ5eHRRa0ZCV1N4UFFVRlBMRU5CUVVNc1NVRkJTU3hEUVVGRExFTkJRVU03UVVGRGNrTXNXVUZCU1N4RFFVRkRMRmRCUVZjc1IwRkJSeXg1UWtGQmEwSXNUMEZCVHl4RFFVRkRMRWxCUVVrc1EwRkJReXhYUVVGWExFVkJRVVVzVDBGQlR5eERRVUZETEVsQlFVa3NRMEZCUXl4RFFVRkRPMEZCUXpkRkxHVkJRVThzUjBGQlJ5eEZRVUZETEVsQlFVa3NSVUZCUlN4SlFVRkpMRVZCUVVNc1EwRkJRenRQUVVONFFqczdRVUZGUkN4aFFVRlBMRVZCUVVVc1EwRkJReXhQUVVGUExFVkJRVVVzVDBGQlR5eERRVUZETEVOQlFVTTdTMEZETjBJN1IwRkRSaXhEUVVGRExFTkJRVU03UTBGRFNpSXNJbVpwYkdVaU9pSmliRzlqYXkxb1pXeHdaWEl0YldsemMybHVaeTVxY3lJc0luTnZkWEpqWlhORGIyNTBaVzUwSWpwYkltbHRjRzl5ZENCN1lYQndaVzVrUTI5dWRHVjRkRkJoZEdnc0lHTnlaV0YwWlVaeVlXMWxMQ0JwYzBGeWNtRjVmU0JtY205dElDY3VMaTkxZEdsc2N5YzdYRzVjYm1WNGNHOXlkQ0JrWldaaGRXeDBJR1oxYm1OMGFXOXVLR2x1YzNSaGJtTmxLU0I3WEc0Z0lHbHVjM1JoYm1ObExuSmxaMmx6ZEdWeVNHVnNjR1Z5S0NkaWJHOWphMGhsYkhCbGNrMXBjM05wYm1jbkxDQm1kVzVqZEdsdmJpaGpiMjUwWlhoMExDQnZjSFJwYjI1ektTQjdYRzRnSUNBZ2JHVjBJR2x1ZG1WeWMyVWdQU0J2Y0hScGIyNXpMbWx1ZG1WeWMyVXNYRzRnSUNBZ0lDQWdJR1p1SUQwZ2IzQjBhVzl1Y3k1bWJqdGNibHh1SUNBZ0lHbG1JQ2hqYjI1MFpYaDBJRDA5UFNCMGNuVmxLU0I3WEc0Z0lDQWdJQ0J5WlhSMWNtNGdabTRvZEdocGN5azdYRzRnSUNBZ2ZTQmxiSE5sSUdsbUlDaGpiMjUwWlhoMElEMDlQU0JtWVd4elpTQjhmQ0JqYjI1MFpYaDBJRDA5SUc1MWJHd3BJSHRjYmlBZ0lDQWdJSEpsZEhWeWJpQnBiblpsY25ObEtIUm9hWE1wTzF4dUlDQWdJSDBnWld4elpTQnBaaUFvYVhOQmNuSmhlU2hqYjI1MFpYaDBLU2tnZTF4dUlDQWdJQ0FnYVdZZ0tHTnZiblJsZUhRdWJHVnVaM1JvSUQ0Z01Da2dlMXh1SUNBZ0lDQWdJQ0JwWmlBb2IzQjBhVzl1Y3k1cFpITXBJSHRjYmlBZ0lDQWdJQ0FnSUNCdmNIUnBiMjV6TG1sa2N5QTlJRnR2Y0hScGIyNXpMbTVoYldWZE8xeHVJQ0FnSUNBZ0lDQjlYRzVjYmlBZ0lDQWdJQ0FnY21WMGRYSnVJR2x1YzNSaGJtTmxMbWhsYkhCbGNuTXVaV0ZqYUNoamIyNTBaWGgwTENCdmNIUnBiMjV6S1R0Y2JpQWdJQ0FnSUgwZ1pXeHpaU0I3WEc0Z0lDQWdJQ0FnSUhKbGRIVnliaUJwYm5abGNuTmxLSFJvYVhNcE8xeHVJQ0FnSUNBZ2ZWeHVJQ0FnSUgwZ1pXeHpaU0I3WEc0Z0lDQWdJQ0JwWmlBb2IzQjBhVzl1Y3k1a1lYUmhJQ1ltSUc5d2RHbHZibk11YVdSektTQjdYRzRnSUNBZ0lDQWdJR3hsZENCa1lYUmhJRDBnWTNKbFlYUmxSbkpoYldVb2IzQjBhVzl1Y3k1a1lYUmhLVHRjYmlBZ0lDQWdJQ0FnWkdGMFlTNWpiMjUwWlhoMFVHRjBhQ0E5SUdGd2NHVnVaRU52Ym5SbGVIUlFZWFJvS0c5d2RHbHZibk11WkdGMFlTNWpiMjUwWlhoMFVHRjBhQ3dnYjNCMGFXOXVjeTV1WVcxbEtUdGNiaUFnSUNBZ0lDQWdiM0IwYVc5dWN5QTlJSHRrWVhSaE9pQmtZWFJoZlR0Y2JpQWdJQ0FnSUgxY2JseHVJQ0FnSUNBZ2NtVjBkWEp1SUdadUtHTnZiblJsZUhRc0lHOXdkR2x2Ym5NcE8xeHVJQ0FnSUgxY2JpQWdmU2s3WEc1OVhHNGlYWDA9XG4iLCIndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG4vLyBpc3RhbmJ1bCBpZ25vcmUgbmV4dFxuXG5mdW5jdGlvbiBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KG9iaikgeyByZXR1cm4gb2JqICYmIG9iai5fX2VzTW9kdWxlID8gb2JqIDogeyAnZGVmYXVsdCc6IG9iaiB9OyB9XG5cbnZhciBfdXRpbHMgPSByZXF1aXJlKCcuLi91dGlscycpO1xuXG52YXIgX2V4Y2VwdGlvbiA9IHJlcXVpcmUoJy4uL2V4Y2VwdGlvbicpO1xuXG52YXIgX2V4Y2VwdGlvbjIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9leGNlcHRpb24pO1xuXG5leHBvcnRzWydkZWZhdWx0J10gPSBmdW5jdGlvbiAoaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ2VhY2gnLCBmdW5jdGlvbiAoY29udGV4dCwgb3B0aW9ucykge1xuICAgIGlmICghb3B0aW9ucykge1xuICAgICAgdGhyb3cgbmV3IF9leGNlcHRpb24yWydkZWZhdWx0J10oJ011c3QgcGFzcyBpdGVyYXRvciB0byAjZWFjaCcpO1xuICAgIH1cblxuICAgIHZhciBmbiA9IG9wdGlvbnMuZm4sXG4gICAgICAgIGludmVyc2UgPSBvcHRpb25zLmludmVyc2UsXG4gICAgICAgIGkgPSAwLFxuICAgICAgICByZXQgPSAnJyxcbiAgICAgICAgZGF0YSA9IHVuZGVmaW5lZCxcbiAgICAgICAgY29udGV4dFBhdGggPSB1bmRlZmluZWQ7XG5cbiAgICBpZiAob3B0aW9ucy5kYXRhICYmIG9wdGlvbnMuaWRzKSB7XG4gICAgICBjb250ZXh0UGF0aCA9IF91dGlscy5hcHBlbmRDb250ZXh0UGF0aChvcHRpb25zLmRhdGEuY29udGV4dFBhdGgsIG9wdGlvbnMuaWRzWzBdKSArICcuJztcbiAgICB9XG5cbiAgICBpZiAoX3V0aWxzLmlzRnVuY3Rpb24oY29udGV4dCkpIHtcbiAgICAgIGNvbnRleHQgPSBjb250ZXh0LmNhbGwodGhpcyk7XG4gICAgfVxuXG4gICAgaWYgKG9wdGlvbnMuZGF0YSkge1xuICAgICAgZGF0YSA9IF91dGlscy5jcmVhdGVGcmFtZShvcHRpb25zLmRhdGEpO1xuICAgIH1cblxuICAgIGZ1bmN0aW9uIGV4ZWNJdGVyYXRpb24oZmllbGQsIGluZGV4LCBsYXN0KSB7XG4gICAgICBpZiAoZGF0YSkge1xuICAgICAgICBkYXRhLmtleSA9IGZpZWxkO1xuICAgICAgICBkYXRhLmluZGV4ID0gaW5kZXg7XG4gICAgICAgIGRhdGEuZmlyc3QgPSBpbmRleCA9PT0gMDtcbiAgICAgICAgZGF0YS5sYXN0ID0gISFsYXN0O1xuXG4gICAgICAgIGlmIChjb250ZXh0UGF0aCkge1xuICAgICAgICAgIGRhdGEuY29udGV4dFBhdGggPSBjb250ZXh0UGF0aCArIGZpZWxkO1xuICAgICAgICB9XG4gICAgICB9XG5cbiAgICAgIHJldCA9IHJldCArIGZuKGNvbnRleHRbZmllbGRdLCB7XG4gICAgICAgIGRhdGE6IGRhdGEsXG4gICAgICAgIGJsb2NrUGFyYW1zOiBfdXRpbHMuYmxvY2tQYXJhbXMoW2NvbnRleHRbZmllbGRdLCBmaWVsZF0sIFtjb250ZXh0UGF0aCArIGZpZWxkLCBudWxsXSlcbiAgICAgIH0pO1xuICAgIH1cblxuICAgIGlmIChjb250ZXh0ICYmIHR5cGVvZiBjb250ZXh0ID09PSAnb2JqZWN0Jykge1xuICAgICAgaWYgKF91dGlscy5pc0FycmF5KGNvbnRleHQpKSB7XG4gICAgICAgIGZvciAodmFyIGogPSBjb250ZXh0Lmxlbmd0aDsgaSA8IGo7IGkrKykge1xuICAgICAgICAgIGlmIChpIGluIGNvbnRleHQpIHtcbiAgICAgICAgICAgIGV4ZWNJdGVyYXRpb24oaSwgaSwgaSA9PT0gY29udGV4dC5sZW5ndGggLSAxKTtcbiAgICAgICAgICB9XG4gICAgICAgIH1cbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHZhciBwcmlvcktleSA9IHVuZGVmaW5lZDtcblxuICAgICAgICBmb3IgKHZhciBrZXkgaW4gY29udGV4dCkge1xuICAgICAgICAgIGlmIChjb250ZXh0Lmhhc093blByb3BlcnR5KGtleSkpIHtcbiAgICAgICAgICAgIC8vIFdlJ3JlIHJ1bm5pbmcgdGhlIGl0ZXJhdGlvbnMgb25lIHN0ZXAgb3V0IG9mIHN5bmMgc28gd2UgY2FuIGRldGVjdFxuICAgICAgICAgICAgLy8gdGhlIGxhc3QgaXRlcmF0aW9uIHdpdGhvdXQgaGF2ZSB0byBzY2FuIHRoZSBvYmplY3QgdHdpY2UgYW5kIGNyZWF0ZVxuICAgICAgICAgICAgLy8gYW4gaXRlcm1lZGlhdGUga2V5cyBhcnJheS5cbiAgICAgICAgICAgIGlmIChwcmlvcktleSAhPT0gdW5kZWZpbmVkKSB7XG4gICAgICAgICAgICAgIGV4ZWNJdGVyYXRpb24ocHJpb3JLZXksIGkgLSAxKTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIHByaW9yS2V5ID0ga2V5O1xuICAgICAgICAgICAgaSsrO1xuICAgICAgICAgIH1cbiAgICAgICAgfVxuICAgICAgICBpZiAocHJpb3JLZXkgIT09IHVuZGVmaW5lZCkge1xuICAgICAgICAgIGV4ZWNJdGVyYXRpb24ocHJpb3JLZXksIGkgLSAxLCB0cnVlKTtcbiAgICAgICAgfVxuICAgICAgfVxuICAgIH1cblxuICAgIGlmIChpID09PSAwKSB7XG4gICAgICByZXQgPSBpbnZlcnNlKHRoaXMpO1xuICAgIH1cblxuICAgIHJldHVybiByZXQ7XG4gIH0pO1xufTtcblxubW9kdWxlLmV4cG9ydHMgPSBleHBvcnRzWydkZWZhdWx0J107XG4vLyMgc291cmNlTWFwcGluZ1VSTD1kYXRhOmFwcGxpY2F0aW9uL2pzb247Y2hhcnNldD11dGYtODtiYXNlNjQsZXlKMlpYSnphVzl1SWpvekxDSnpiM1Z5WTJWeklqcGJJaTR1THk0dUx5NHVMeTR1TDJ4cFlpOW9ZVzVrYkdWaVlYSnpMMmhsYkhCbGNuTXZaV0ZqYUM1cWN5SmRMQ0p1WVcxbGN5STZXMTBzSW0xaGNIQnBibWR6SWpvaU96czdPenM3TzNGQ1FVRXJSU3hWUVVGVk96dDVRa0ZEYmtVc1kwRkJZenM3T3p0eFFrRkZja0lzVlVGQlV5eFJRVUZSTEVWQlFVVTdRVUZEYUVNc1ZVRkJVU3hEUVVGRExHTkJRV01zUTBGQlF5eE5RVUZOTEVWQlFVVXNWVUZCVXl4UFFVRlBMRVZCUVVVc1QwRkJUeXhGUVVGRk8wRkJRM3BFTEZGQlFVa3NRMEZCUXl4UFFVRlBMRVZCUVVVN1FVRkRXaXhaUVVGTkxESkNRVUZqTERaQ1FVRTJRaXhEUVVGRExFTkJRVU03UzBGRGNFUTdPMEZCUlVRc1VVRkJTU3hGUVVGRkxFZEJRVWNzVDBGQlR5eERRVUZETEVWQlFVVTdVVUZEWml4UFFVRlBMRWRCUVVjc1QwRkJUeXhEUVVGRExFOUJRVTg3VVVGRGVrSXNRMEZCUXl4SFFVRkhMRU5CUVVNN1VVRkRUQ3hIUVVGSExFZEJRVWNzUlVGQlJUdFJRVU5TTEVsQlFVa3NXVUZCUVR0UlFVTktMRmRCUVZjc1dVRkJRU3hEUVVGRE96dEJRVVZvUWl4UlFVRkpMRTlCUVU4c1EwRkJReXhKUVVGSkxFbEJRVWtzVDBGQlR5eERRVUZETEVkQlFVY3NSVUZCUlR0QlFVTXZRaXhwUWtGQlZ5eEhRVUZITEhsQ1FVRnJRaXhQUVVGUExFTkJRVU1zU1VGQlNTeERRVUZETEZkQlFWY3NSVUZCUlN4UFFVRlBMRU5CUVVNc1IwRkJSeXhEUVVGRExFTkJRVU1zUTBGQlF5eERRVUZETEVkQlFVY3NSMEZCUnl4RFFVRkRPMHRCUTJwR096dEJRVVZFTEZGQlFVa3NhMEpCUVZjc1QwRkJUeXhEUVVGRExFVkJRVVU3UVVGQlJTeGhRVUZQTEVkQlFVY3NUMEZCVHl4RFFVRkRMRWxCUVVrc1EwRkJReXhKUVVGSkxFTkJRVU1zUTBGQlF6dExRVUZGT3p0QlFVVXhSQ3hSUVVGSkxFOUJRVThzUTBGQlF5eEpRVUZKTEVWQlFVVTdRVUZEYUVJc1ZVRkJTU3hIUVVGSExHMUNRVUZaTEU5QlFVOHNRMEZCUXl4SlFVRkpMRU5CUVVNc1EwRkJRenRMUVVOc1F6czdRVUZGUkN4aFFVRlRMR0ZCUVdFc1EwRkJReXhMUVVGTExFVkJRVVVzUzBGQlN5eEZRVUZGTEVsQlFVa3NSVUZCUlR0QlFVTjZReXhWUVVGSkxFbEJRVWtzUlVGQlJUdEJRVU5TTEZsQlFVa3NRMEZCUXl4SFFVRkhMRWRCUVVjc1MwRkJTeXhEUVVGRE8wRkJRMnBDTEZsQlFVa3NRMEZCUXl4TFFVRkxMRWRCUVVjc1MwRkJTeXhEUVVGRE8wRkJRMjVDTEZsQlFVa3NRMEZCUXl4TFFVRkxMRWRCUVVjc1MwRkJTeXhMUVVGTExFTkJRVU1zUTBGQlF6dEJRVU42UWl4WlFVRkpMRU5CUVVNc1NVRkJTU3hIUVVGSExFTkJRVU1zUTBGQlF5eEpRVUZKTEVOQlFVTTdPMEZCUlc1Q0xGbEJRVWtzVjBGQlZ5eEZRVUZGTzBGQlEyWXNZMEZCU1N4RFFVRkRMRmRCUVZjc1IwRkJSeXhYUVVGWExFZEJRVWNzUzBGQlN5eERRVUZETzFOQlEzaERPMDlCUTBZN08wRkJSVVFzVTBGQlJ5eEhRVUZITEVkQlFVY3NSMEZCUnl4RlFVRkZMRU5CUVVNc1QwRkJUeXhEUVVGRExFdEJRVXNzUTBGQlF5eEZRVUZGTzBGQlF6ZENMRmxCUVVrc1JVRkJSU3hKUVVGSk8wRkJRMVlzYlVKQlFWY3NSVUZCUlN4dFFrRkJXU3hEUVVGRExFOUJRVThzUTBGQlF5eExRVUZMTEVOQlFVTXNSVUZCUlN4TFFVRkxMRU5CUVVNc1JVRkJSU3hEUVVGRExGZEJRVmNzUjBGQlJ5eExRVUZMTEVWQlFVVXNTVUZCU1N4RFFVRkRMRU5CUVVNN1QwRkRMMFVzUTBGQlF5eERRVUZETzB0QlEwbzdPMEZCUlVRc1VVRkJTU3hQUVVGUExFbEJRVWtzVDBGQlR5eFBRVUZQTEV0QlFVc3NVVUZCVVN4RlFVRkZPMEZCUXpGRExGVkJRVWtzWlVGQlVTeFBRVUZQTEVOQlFVTXNSVUZCUlR0QlFVTndRaXhoUVVGTExFbEJRVWtzUTBGQlF5eEhRVUZITEU5QlFVOHNRMEZCUXl4TlFVRk5MRVZCUVVVc1EwRkJReXhIUVVGSExFTkJRVU1zUlVGQlJTeERRVUZETEVWQlFVVXNSVUZCUlR0QlFVTjJReXhqUVVGSkxFTkJRVU1zU1VGQlNTeFBRVUZQTEVWQlFVVTdRVUZEYUVJc2VVSkJRV0VzUTBGQlF5eERRVUZETEVWQlFVVXNRMEZCUXl4RlFVRkZMRU5CUVVNc1MwRkJTeXhQUVVGUExFTkJRVU1zVFVGQlRTeEhRVUZITEVOQlFVTXNRMEZCUXl4RFFVRkRPMWRCUXk5RE8xTkJRMFk3VDBGRFJpeE5RVUZOTzBGQlEwd3NXVUZCU1N4UlFVRlJMRmxCUVVFc1EwRkJRenM3UVVGRllpeGhRVUZMTEVsQlFVa3NSMEZCUnl4SlFVRkpMRTlCUVU4c1JVRkJSVHRCUVVOMlFpeGpRVUZKTEU5QlFVOHNRMEZCUXl4alFVRmpMRU5CUVVNc1IwRkJSeXhEUVVGRExFVkJRVVU3T3pzN1FVRkpMMElzWjBKQlFVa3NVVUZCVVN4TFFVRkxMRk5CUVZNc1JVRkJSVHRCUVVNeFFpd3lRa0ZCWVN4RFFVRkRMRkZCUVZFc1JVRkJSU3hEUVVGRExFZEJRVWNzUTBGQlF5eERRVUZETEVOQlFVTTdZVUZEYUVNN1FVRkRSQ3h2UWtGQlVTeEhRVUZITEVkQlFVY3NRMEZCUXp0QlFVTm1MR0ZCUVVNc1JVRkJSU3hEUVVGRE8xZEJRMHc3VTBGRFJqdEJRVU5FTEZsQlFVa3NVVUZCVVN4TFFVRkxMRk5CUVZNc1JVRkJSVHRCUVVNeFFpeDFRa0ZCWVN4RFFVRkRMRkZCUVZFc1JVRkJSU3hEUVVGRExFZEJRVWNzUTBGQlF5eEZRVUZGTEVsQlFVa3NRMEZCUXl4RFFVRkRPMU5CUTNSRE8wOUJRMFk3UzBGRFJqczdRVUZGUkN4UlFVRkpMRU5CUVVNc1MwRkJTeXhEUVVGRExFVkJRVVU3UVVGRFdDeFRRVUZITEVkQlFVY3NUMEZCVHl4RFFVRkRMRWxCUVVrc1EwRkJReXhEUVVGRE8wdEJRM0pDT3p0QlFVVkVMRmRCUVU4c1IwRkJSeXhEUVVGRE8wZEJRMW9zUTBGQlF5eERRVUZETzBOQlEwb2lMQ0ptYVd4bElqb2laV0ZqYUM1cWN5SXNJbk52ZFhKalpYTkRiMjUwWlc1MElqcGJJbWx0Y0c5eWRDQjdZWEJ3Wlc1a1EyOXVkR1Y0ZEZCaGRHZ3NJR0pzYjJOclVHRnlZVzF6TENCamNtVmhkR1ZHY21GdFpTd2dhWE5CY25KaGVTd2dhWE5HZFc1amRHbHZibjBnWm5KdmJTQW5MaTR2ZFhScGJITW5PMXh1YVcxd2IzSjBJRVY0WTJWd2RHbHZiaUJtY205dElDY3VMaTlsZUdObGNIUnBiMjRuTzF4dVhHNWxlSEJ2Y25RZ1pHVm1ZWFZzZENCbWRXNWpkR2x2YmlocGJuTjBZVzVqWlNrZ2UxeHVJQ0JwYm5OMFlXNWpaUzV5WldkcGMzUmxja2hsYkhCbGNpZ25aV0ZqYUNjc0lHWjFibU4wYVc5dUtHTnZiblJsZUhRc0lHOXdkR2x2Ym5NcElIdGNiaUFnSUNCcFppQW9JVzl3ZEdsdmJuTXBJSHRjYmlBZ0lDQWdJSFJvY205M0lHNWxkeUJGZUdObGNIUnBiMjRvSjAxMWMzUWdjR0Z6Y3lCcGRHVnlZWFJ2Y2lCMGJ5QWpaV0ZqYUNjcE8xeHVJQ0FnSUgxY2JseHVJQ0FnSUd4bGRDQm1iaUE5SUc5d2RHbHZibk11Wm00c1hHNGdJQ0FnSUNBZ0lHbHVkbVZ5YzJVZ1BTQnZjSFJwYjI1ekxtbHVkbVZ5YzJVc1hHNGdJQ0FnSUNBZ0lHa2dQU0F3TEZ4dUlDQWdJQ0FnSUNCeVpYUWdQU0FuSnl4Y2JpQWdJQ0FnSUNBZ1pHRjBZU3hjYmlBZ0lDQWdJQ0FnWTI5dWRHVjRkRkJoZEdnN1hHNWNiaUFnSUNCcFppQW9iM0IwYVc5dWN5NWtZWFJoSUNZbUlHOXdkR2x2Ym5NdWFXUnpLU0I3WEc0Z0lDQWdJQ0JqYjI1MFpYaDBVR0YwYUNBOUlHRndjR1Z1WkVOdmJuUmxlSFJRWVhSb0tHOXdkR2x2Ym5NdVpHRjBZUzVqYjI1MFpYaDBVR0YwYUN3Z2IzQjBhVzl1Y3k1cFpITmJNRjBwSUNzZ0p5NG5PMXh1SUNBZ0lIMWNibHh1SUNBZ0lHbG1JQ2hwYzBaMWJtTjBhVzl1S0dOdmJuUmxlSFFwS1NCN0lHTnZiblJsZUhRZ1BTQmpiMjUwWlhoMExtTmhiR3dvZEdocGN5azdJSDFjYmx4dUlDQWdJR2xtSUNodmNIUnBiMjV6TG1SaGRHRXBJSHRjYmlBZ0lDQWdJR1JoZEdFZ1BTQmpjbVZoZEdWR2NtRnRaU2h2Y0hScGIyNXpMbVJoZEdFcE8xeHVJQ0FnSUgxY2JseHVJQ0FnSUdaMWJtTjBhVzl1SUdWNFpXTkpkR1Z5WVhScGIyNG9abWxsYkdRc0lHbHVaR1Y0TENCc1lYTjBLU0I3WEc0Z0lDQWdJQ0JwWmlBb1pHRjBZU2tnZTF4dUlDQWdJQ0FnSUNCa1lYUmhMbXRsZVNBOUlHWnBaV3hrTzF4dUlDQWdJQ0FnSUNCa1lYUmhMbWx1WkdWNElEMGdhVzVrWlhnN1hHNGdJQ0FnSUNBZ0lHUmhkR0V1Wm1seWMzUWdQU0JwYm1SbGVDQTlQVDBnTUR0Y2JpQWdJQ0FnSUNBZ1pHRjBZUzVzWVhOMElEMGdJU0ZzWVhOME8xeHVYRzRnSUNBZ0lDQWdJR2xtSUNoamIyNTBaWGgwVUdGMGFDa2dlMXh1SUNBZ0lDQWdJQ0FnSUdSaGRHRXVZMjl1ZEdWNGRGQmhkR2dnUFNCamIyNTBaWGgwVUdGMGFDQXJJR1pwWld4a08xeHVJQ0FnSUNBZ0lDQjlYRzRnSUNBZ0lDQjlYRzVjYmlBZ0lDQWdJSEpsZENBOUlISmxkQ0FySUdadUtHTnZiblJsZUhSYlptbGxiR1JkTENCN1hHNGdJQ0FnSUNBZ0lHUmhkR0U2SUdSaGRHRXNYRzRnSUNBZ0lDQWdJR0pzYjJOclVHRnlZVzF6T2lCaWJHOWphMUJoY21GdGN5aGJZMjl1ZEdWNGRGdG1hV1ZzWkYwc0lHWnBaV3hrWFN3Z1cyTnZiblJsZUhSUVlYUm9JQ3NnWm1sbGJHUXNJRzUxYkd4ZEtWeHVJQ0FnSUNBZ2ZTazdYRzRnSUNBZ2ZWeHVYRzRnSUNBZ2FXWWdLR052Ym5SbGVIUWdKaVlnZEhsd1pXOW1JR052Ym5SbGVIUWdQVDA5SUNkdlltcGxZM1FuS1NCN1hHNGdJQ0FnSUNCcFppQW9hWE5CY25KaGVTaGpiMjUwWlhoMEtTa2dlMXh1SUNBZ0lDQWdJQ0JtYjNJZ0tHeGxkQ0JxSUQwZ1kyOXVkR1Y0ZEM1c1pXNW5kR2c3SUdrZ1BDQnFPeUJwS3lzcElIdGNiaUFnSUNBZ0lDQWdJQ0JwWmlBb2FTQnBiaUJqYjI1MFpYaDBLU0I3WEc0Z0lDQWdJQ0FnSUNBZ0lDQmxlR1ZqU1hSbGNtRjBhVzl1S0drc0lHa3NJR2tnUFQwOUlHTnZiblJsZUhRdWJHVnVaM1JvSUMwZ01TazdYRzRnSUNBZ0lDQWdJQ0FnZlZ4dUlDQWdJQ0FnSUNCOVhHNGdJQ0FnSUNCOUlHVnNjMlVnZTF4dUlDQWdJQ0FnSUNCc1pYUWdjSEpwYjNKTFpYazdYRzVjYmlBZ0lDQWdJQ0FnWm05eUlDaHNaWFFnYTJWNUlHbHVJR052Ym5SbGVIUXBJSHRjYmlBZ0lDQWdJQ0FnSUNCcFppQW9ZMjl1ZEdWNGRDNW9ZWE5QZDI1UWNtOXdaWEowZVNoclpYa3BLU0I3WEc0Z0lDQWdJQ0FnSUNBZ0lDQXZMeUJYWlNkeVpTQnlkVzV1YVc1bklIUm9aU0JwZEdWeVlYUnBiMjV6SUc5dVpTQnpkR1Z3SUc5MWRDQnZaaUJ6ZVc1aklITnZJSGRsSUdOaGJpQmtaWFJsWTNSY2JpQWdJQ0FnSUNBZ0lDQWdJQzh2SUhSb1pTQnNZWE4wSUdsMFpYSmhkR2x2YmlCM2FYUm9iM1YwSUdoaGRtVWdkRzhnYzJOaGJpQjBhR1VnYjJKcVpXTjBJSFIzYVdObElHRnVaQ0JqY21WaGRHVmNiaUFnSUNBZ0lDQWdJQ0FnSUM4dklHRnVJR2wwWlhKdFpXUnBZWFJsSUd0bGVYTWdZWEp5WVhrdVhHNGdJQ0FnSUNBZ0lDQWdJQ0JwWmlBb2NISnBiM0pMWlhrZ0lUMDlJSFZ1WkdWbWFXNWxaQ2tnZTF4dUlDQWdJQ0FnSUNBZ0lDQWdJQ0JsZUdWalNYUmxjbUYwYVc5dUtIQnlhVzl5UzJWNUxDQnBJQzBnTVNrN1hHNGdJQ0FnSUNBZ0lDQWdJQ0I5WEc0Z0lDQWdJQ0FnSUNBZ0lDQndjbWx2Y2t0bGVTQTlJR3RsZVR0Y2JpQWdJQ0FnSUNBZ0lDQWdJR2tyS3p0Y2JpQWdJQ0FnSUNBZ0lDQjlYRzRnSUNBZ0lDQWdJSDFjYmlBZ0lDQWdJQ0FnYVdZZ0tIQnlhVzl5UzJWNUlDRTlQU0IxYm1SbFptbHVaV1FwSUh0Y2JpQWdJQ0FnSUNBZ0lDQmxlR1ZqU1hSbGNtRjBhVzl1S0hCeWFXOXlTMlY1TENCcElDMGdNU3dnZEhKMVpTazdYRzRnSUNBZ0lDQWdJSDFjYmlBZ0lDQWdJSDFjYmlBZ0lDQjlYRzVjYmlBZ0lDQnBaaUFvYVNBOVBUMGdNQ2tnZTF4dUlDQWdJQ0FnY21WMElEMGdhVzUyWlhKelpTaDBhR2x6S1R0Y2JpQWdJQ0I5WEc1Y2JpQWdJQ0J5WlhSMWNtNGdjbVYwTzF4dUlDQjlLVHRjYm4xY2JpSmRmUT09XG4iLCIndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG4vLyBpc3RhbmJ1bCBpZ25vcmUgbmV4dFxuXG5mdW5jdGlvbiBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KG9iaikgeyByZXR1cm4gb2JqICYmIG9iai5fX2VzTW9kdWxlID8gb2JqIDogeyAnZGVmYXVsdCc6IG9iaiB9OyB9XG5cbnZhciBfZXhjZXB0aW9uID0gcmVxdWlyZSgnLi4vZXhjZXB0aW9uJyk7XG5cbnZhciBfZXhjZXB0aW9uMiA9IF9pbnRlcm9wUmVxdWlyZURlZmF1bHQoX2V4Y2VwdGlvbik7XG5cbmV4cG9ydHNbJ2RlZmF1bHQnXSA9IGZ1bmN0aW9uIChpbnN0YW5jZSkge1xuICBpbnN0YW5jZS5yZWdpc3RlckhlbHBlcignaGVscGVyTWlzc2luZycsIGZ1bmN0aW9uICgpIC8qIFthcmdzLCBdb3B0aW9ucyAqL3tcbiAgICBpZiAoYXJndW1lbnRzLmxlbmd0aCA9PT0gMSkge1xuICAgICAgLy8gQSBtaXNzaW5nIGZpZWxkIGluIGEge3tmb299fSBjb25zdHJ1Y3QuXG4gICAgICByZXR1cm4gdW5kZWZpbmVkO1xuICAgIH0gZWxzZSB7XG4gICAgICAvLyBTb21lb25lIGlzIGFjdHVhbGx5IHRyeWluZyB0byBjYWxsIHNvbWV0aGluZywgYmxvdyB1cC5cbiAgICAgIHRocm93IG5ldyBfZXhjZXB0aW9uMlsnZGVmYXVsdCddKCdNaXNzaW5nIGhlbHBlcjogXCInICsgYXJndW1lbnRzW2FyZ3VtZW50cy5sZW5ndGggLSAxXS5uYW1lICsgJ1wiJyk7XG4gICAgfVxuICB9KTtcbn07XG5cbm1vZHVsZS5leHBvcnRzID0gZXhwb3J0c1snZGVmYXVsdCddO1xuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDJobGJIQmxjbk12YUdWc2NHVnlMVzFwYzNOcGJtY3Vhbk1pWFN3aWJtRnRaWE1pT2x0ZExDSnRZWEJ3YVc1bmN5STZJanM3T3pzN096dDVRa0ZCYzBJc1kwRkJZenM3T3p0eFFrRkZja0lzVlVGQlV5eFJRVUZSTEVWQlFVVTdRVUZEYUVNc1ZVRkJVU3hEUVVGRExHTkJRV01zUTBGQlF5eGxRVUZsTEVWQlFVVXNhVU5CUVdkRE8wRkJRM1pGTEZGQlFVa3NVMEZCVXl4RFFVRkRMRTFCUVUwc1MwRkJTeXhEUVVGRExFVkJRVVU3TzBGQlJURkNMR0ZCUVU4c1UwRkJVeXhEUVVGRE8wdEJRMnhDTEUxQlFVMDdPMEZCUlV3c1dVRkJUU3d5UWtGQll5eHRRa0ZCYlVJc1IwRkJSeXhUUVVGVExFTkJRVU1zVTBGQlV5eERRVUZETEUxQlFVMHNSMEZCUnl4RFFVRkRMRU5CUVVNc1EwRkJReXhKUVVGSkxFZEJRVWNzUjBGQlJ5eERRVUZETEVOQlFVTTdTMEZEZGtZN1IwRkRSaXhEUVVGRExFTkJRVU03UTBGRFNpSXNJbVpwYkdVaU9pSm9aV3h3WlhJdGJXbHpjMmx1Wnk1cWN5SXNJbk52ZFhKalpYTkRiMjUwWlc1MElqcGJJbWx0Y0c5eWRDQkZlR05sY0hScGIyNGdabkp2YlNBbkxpNHZaWGhqWlhCMGFXOXVKenRjYmx4dVpYaHdiM0owSUdSbFptRjFiSFFnWm5WdVkzUnBiMjRvYVc1emRHRnVZMlVwSUh0Y2JpQWdhVzV6ZEdGdVkyVXVjbVZuYVhOMFpYSklaV3h3WlhJb0oyaGxiSEJsY2sxcGMzTnBibWNuTENCbWRXNWpkR2x2YmlndktpQmJZWEpuY3l3Z1hXOXdkR2x2Ym5NZ0tpOHBJSHRjYmlBZ0lDQnBaaUFvWVhKbmRXMWxiblJ6TG14bGJtZDBhQ0E5UFQwZ01Ta2dlMXh1SUNBZ0lDQWdMeThnUVNCdGFYTnphVzVuSUdacFpXeGtJR2x1SUdFZ2UzdG1iMjk5ZlNCamIyNXpkSEoxWTNRdVhHNGdJQ0FnSUNCeVpYUjFjbTRnZFc1a1pXWnBibVZrTzF4dUlDQWdJSDBnWld4elpTQjdYRzRnSUNBZ0lDQXZMeUJUYjIxbGIyNWxJR2x6SUdGamRIVmhiR3g1SUhSeWVXbHVaeUIwYnlCallXeHNJSE52YldWMGFHbHVaeXdnWW14dmR5QjFjQzVjYmlBZ0lDQWdJSFJvY205M0lHNWxkeUJGZUdObGNIUnBiMjRvSjAxcGMzTnBibWNnYUdWc2NHVnlPaUJjSWljZ0t5QmhjbWQxYldWdWRITmJZWEpuZFcxbGJuUnpMbXhsYm1kMGFDQXRJREZkTG01aGJXVWdLeUFuWENJbktUdGNiaUFnSUNCOVhHNGdJSDBwTzF4dWZWeHVJbDE5XG4iLCIndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG5cbnZhciBfdXRpbHMgPSByZXF1aXJlKCcuLi91dGlscycpO1xuXG5leHBvcnRzWydkZWZhdWx0J10gPSBmdW5jdGlvbiAoaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ2lmJywgZnVuY3Rpb24gKGNvbmRpdGlvbmFsLCBvcHRpb25zKSB7XG4gICAgaWYgKF91dGlscy5pc0Z1bmN0aW9uKGNvbmRpdGlvbmFsKSkge1xuICAgICAgY29uZGl0aW9uYWwgPSBjb25kaXRpb25hbC5jYWxsKHRoaXMpO1xuICAgIH1cblxuICAgIC8vIERlZmF1bHQgYmVoYXZpb3IgaXMgdG8gcmVuZGVyIHRoZSBwb3NpdGl2ZSBwYXRoIGlmIHRoZSB2YWx1ZSBpcyB0cnV0aHkgYW5kIG5vdCBlbXB0eS5cbiAgICAvLyBUaGUgYGluY2x1ZGVaZXJvYCBvcHRpb24gbWF5IGJlIHNldCB0byB0cmVhdCB0aGUgY29uZHRpb25hbCBhcyBwdXJlbHkgbm90IGVtcHR5IGJhc2VkIG9uIHRoZVxuICAgIC8vIGJlaGF2aW9yIG9mIGlzRW1wdHkuIEVmZmVjdGl2ZWx5IHRoaXMgZGV0ZXJtaW5lcyBpZiAwIGlzIGhhbmRsZWQgYnkgdGhlIHBvc2l0aXZlIHBhdGggb3IgbmVnYXRpdmUuXG4gICAgaWYgKCFvcHRpb25zLmhhc2guaW5jbHVkZVplcm8gJiYgIWNvbmRpdGlvbmFsIHx8IF91dGlscy5pc0VtcHR5KGNvbmRpdGlvbmFsKSkge1xuICAgICAgcmV0dXJuIG9wdGlvbnMuaW52ZXJzZSh0aGlzKTtcbiAgICB9IGVsc2Uge1xuICAgICAgcmV0dXJuIG9wdGlvbnMuZm4odGhpcyk7XG4gICAgfVxuICB9KTtcblxuICBpbnN0YW5jZS5yZWdpc3RlckhlbHBlcigndW5sZXNzJywgZnVuY3Rpb24gKGNvbmRpdGlvbmFsLCBvcHRpb25zKSB7XG4gICAgcmV0dXJuIGluc3RhbmNlLmhlbHBlcnNbJ2lmJ10uY2FsbCh0aGlzLCBjb25kaXRpb25hbCwgeyBmbjogb3B0aW9ucy5pbnZlcnNlLCBpbnZlcnNlOiBvcHRpb25zLmZuLCBoYXNoOiBvcHRpb25zLmhhc2ggfSk7XG4gIH0pO1xufTtcblxubW9kdWxlLmV4cG9ydHMgPSBleHBvcnRzWydkZWZhdWx0J107XG4vLyMgc291cmNlTWFwcGluZ1VSTD1kYXRhOmFwcGxpY2F0aW9uL2pzb247Y2hhcnNldD11dGYtODtiYXNlNjQsZXlKMlpYSnphVzl1SWpvekxDSnpiM1Z5WTJWeklqcGJJaTR1THk0dUx5NHVMeTR1TDJ4cFlpOW9ZVzVrYkdWaVlYSnpMMmhsYkhCbGNuTXZhV1l1YW5NaVhTd2libUZ0WlhNaU9sdGRMQ0p0WVhCd2FXNW5jeUk2SWpzN096dHhRa0ZCYTBNc1ZVRkJWVHM3Y1VKQlJUZENMRlZCUVZNc1VVRkJVU3hGUVVGRk8wRkJRMmhETEZWQlFWRXNRMEZCUXl4alFVRmpMRU5CUVVNc1NVRkJTU3hGUVVGRkxGVkJRVk1zVjBGQlZ5eEZRVUZGTEU5QlFVOHNSVUZCUlR0QlFVTXpSQ3hSUVVGSkxHdENRVUZYTEZkQlFWY3NRMEZCUXl4RlFVRkZPMEZCUVVVc2FVSkJRVmNzUjBGQlJ5eFhRVUZYTEVOQlFVTXNTVUZCU1N4RFFVRkRMRWxCUVVrc1EwRkJReXhEUVVGRE8wdEJRVVU3T3pzN08wRkJTM1JGTEZGQlFVa3NRVUZCUXl4RFFVRkRMRTlCUVU4c1EwRkJReXhKUVVGSkxFTkJRVU1zVjBGQlZ5eEpRVUZKTEVOQlFVTXNWMEZCVnl4SlFVRkxMR1ZCUVZFc1YwRkJWeXhEUVVGRExFVkJRVVU3UVVGRGRrVXNZVUZCVHl4UFFVRlBMRU5CUVVNc1QwRkJUeXhEUVVGRExFbEJRVWtzUTBGQlF5eERRVUZETzB0QlF6bENMRTFCUVUwN1FVRkRUQ3hoUVVGUExFOUJRVThzUTBGQlF5eEZRVUZGTEVOQlFVTXNTVUZCU1N4RFFVRkRMRU5CUVVNN1MwRkRla0k3UjBGRFJpeERRVUZETEVOQlFVTTdPMEZCUlVnc1ZVRkJVU3hEUVVGRExHTkJRV01zUTBGQlF5eFJRVUZSTEVWQlFVVXNWVUZCVXl4WFFVRlhMRVZCUVVVc1QwRkJUeXhGUVVGRk8wRkJReTlFTEZkQlFVOHNVVUZCVVN4RFFVRkRMRTlCUVU4c1EwRkJReXhKUVVGSkxFTkJRVU1zUTBGQlF5eEpRVUZKTEVOQlFVTXNTVUZCU1N4RlFVRkZMRmRCUVZjc1JVRkJSU3hGUVVGRExFVkJRVVVzUlVGQlJTeFBRVUZQTEVOQlFVTXNUMEZCVHl4RlFVRkZMRTlCUVU4c1JVRkJSU3hQUVVGUExFTkJRVU1zUlVGQlJTeEZRVUZGTEVsQlFVa3NSVUZCUlN4UFFVRlBMRU5CUVVNc1NVRkJTU3hGUVVGRExFTkJRVU1zUTBGQlF6dEhRVU4yU0N4RFFVRkRMRU5CUVVNN1EwRkRTaUlzSW1acGJHVWlPaUpwWmk1cWN5SXNJbk52ZFhKalpYTkRiMjUwWlc1MElqcGJJbWx0Y0c5eWRDQjdhWE5GYlhCMGVTd2dhWE5HZFc1amRHbHZibjBnWm5KdmJTQW5MaTR2ZFhScGJITW5PMXh1WEc1bGVIQnZjblFnWkdWbVlYVnNkQ0JtZFc1amRHbHZiaWhwYm5OMFlXNWpaU2tnZTF4dUlDQnBibk4wWVc1alpTNXlaV2RwYzNSbGNraGxiSEJsY2lnbmFXWW5MQ0JtZFc1amRHbHZiaWhqYjI1a2FYUnBiMjVoYkN3Z2IzQjBhVzl1Y3lrZ2UxeHVJQ0FnSUdsbUlDaHBjMFoxYm1OMGFXOXVLR052Ym1ScGRHbHZibUZzS1NrZ2V5QmpiMjVrYVhScGIyNWhiQ0E5SUdOdmJtUnBkR2x2Ym1Gc0xtTmhiR3dvZEdocGN5azdJSDFjYmx4dUlDQWdJQzh2SUVSbFptRjFiSFFnWW1Wb1lYWnBiM0lnYVhNZ2RHOGdjbVZ1WkdWeUlIUm9aU0J3YjNOcGRHbDJaU0J3WVhSb0lHbG1JSFJvWlNCMllXeDFaU0JwY3lCMGNuVjBhSGtnWVc1a0lHNXZkQ0JsYlhCMGVTNWNiaUFnSUNBdkx5QlVhR1VnWUdsdVkyeDFaR1ZhWlhKdllDQnZjSFJwYjI0Z2JXRjVJR0psSUhObGRDQjBieUIwY21WaGRDQjBhR1VnWTI5dVpIUnBiMjVoYkNCaGN5QndkWEpsYkhrZ2JtOTBJR1Z0Y0hSNUlHSmhjMlZrSUc5dUlIUm9aVnh1SUNBZ0lDOHZJR0psYUdGMmFXOXlJRzltSUdselJXMXdkSGt1SUVWbVptVmpkR2wyWld4NUlIUm9hWE1nWkdWMFpYSnRhVzVsY3lCcFppQXdJR2x6SUdoaGJtUnNaV1FnWW5rZ2RHaGxJSEJ2YzJsMGFYWmxJSEJoZEdnZ2IzSWdibVZuWVhScGRtVXVYRzRnSUNBZ2FXWWdLQ2doYjNCMGFXOXVjeTVvWVhOb0xtbHVZMngxWkdWYVpYSnZJQ1ltSUNGamIyNWthWFJwYjI1aGJDa2dmSHdnYVhORmJYQjBlU2hqYjI1a2FYUnBiMjVoYkNrcElIdGNiaUFnSUNBZ0lISmxkSFZ5YmlCdmNIUnBiMjV6TG1sdWRtVnljMlVvZEdocGN5azdYRzRnSUNBZ2ZTQmxiSE5sSUh0Y2JpQWdJQ0FnSUhKbGRIVnliaUJ2Y0hScGIyNXpMbVp1S0hSb2FYTXBPMXh1SUNBZ0lIMWNiaUFnZlNrN1hHNWNiaUFnYVc1emRHRnVZMlV1Y21WbmFYTjBaWEpJWld4d1pYSW9KM1Z1YkdWemN5Y3NJR1oxYm1OMGFXOXVLR052Ym1ScGRHbHZibUZzTENCdmNIUnBiMjV6S1NCN1hHNGdJQ0FnY21WMGRYSnVJR2x1YzNSaGJtTmxMbWhsYkhCbGNuTmJKMmxtSjEwdVkyRnNiQ2gwYUdsekxDQmpiMjVrYVhScGIyNWhiQ3dnZTJadU9pQnZjSFJwYjI1ekxtbHVkbVZ5YzJVc0lHbHVkbVZ5YzJVNklHOXdkR2x2Ym5NdVptNHNJR2hoYzJnNklHOXdkR2x2Ym5NdWFHRnphSDBwTzF4dUlDQjlLVHRjYm4xY2JpSmRmUT09XG4iLCIndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG5cbmV4cG9ydHNbJ2RlZmF1bHQnXSA9IGZ1bmN0aW9uIChpbnN0YW5jZSkge1xuICBpbnN0YW5jZS5yZWdpc3RlckhlbHBlcignbG9nJywgZnVuY3Rpb24gKCkgLyogbWVzc2FnZSwgb3B0aW9ucyAqL3tcbiAgICB2YXIgYXJncyA9IFt1bmRlZmluZWRdLFxuICAgICAgICBvcHRpb25zID0gYXJndW1lbnRzW2FyZ3VtZW50cy5sZW5ndGggLSAxXTtcbiAgICBmb3IgKHZhciBpID0gMDsgaSA8IGFyZ3VtZW50cy5sZW5ndGggLSAxOyBpKyspIHtcbiAgICAgIGFyZ3MucHVzaChhcmd1bWVudHNbaV0pO1xuICAgIH1cblxuICAgIHZhciBsZXZlbCA9IDE7XG4gICAgaWYgKG9wdGlvbnMuaGFzaC5sZXZlbCAhPSBudWxsKSB7XG4gICAgICBsZXZlbCA9IG9wdGlvbnMuaGFzaC5sZXZlbDtcbiAgICB9IGVsc2UgaWYgKG9wdGlvbnMuZGF0YSAmJiBvcHRpb25zLmRhdGEubGV2ZWwgIT0gbnVsbCkge1xuICAgICAgbGV2ZWwgPSBvcHRpb25zLmRhdGEubGV2ZWw7XG4gICAgfVxuICAgIGFyZ3NbMF0gPSBsZXZlbDtcblxuICAgIGluc3RhbmNlLmxvZy5hcHBseShpbnN0YW5jZSwgYXJncyk7XG4gIH0pO1xufTtcblxubW9kdWxlLmV4cG9ydHMgPSBleHBvcnRzWydkZWZhdWx0J107XG4vLyMgc291cmNlTWFwcGluZ1VSTD1kYXRhOmFwcGxpY2F0aW9uL2pzb247Y2hhcnNldD11dGYtODtiYXNlNjQsZXlKMlpYSnphVzl1SWpvekxDSnpiM1Z5WTJWeklqcGJJaTR1THk0dUx5NHVMeTR1TDJ4cFlpOW9ZVzVrYkdWaVlYSnpMMmhsYkhCbGNuTXZiRzluTG1weklsMHNJbTVoYldWeklqcGJYU3dpYldGd2NHbHVaM01pT2lJN096czdjVUpCUVdVc1ZVRkJVeXhSUVVGUkxFVkJRVVU3UVVGRGFFTXNWVUZCVVN4RFFVRkRMR05CUVdNc1EwRkJReXhMUVVGTExFVkJRVVVzYTBOQlFXbERPMEZCUXpsRUxGRkJRVWtzU1VGQlNTeEhRVUZITEVOQlFVTXNVMEZCVXl4RFFVRkRPMUZCUTJ4Q0xFOUJRVThzUjBGQlJ5eFRRVUZUTEVOQlFVTXNVMEZCVXl4RFFVRkRMRTFCUVUwc1IwRkJSeXhEUVVGRExFTkJRVU1zUTBGQlF6dEJRVU01UXl4VFFVRkxMRWxCUVVrc1EwRkJReXhIUVVGSExFTkJRVU1zUlVGQlJTeERRVUZETEVkQlFVY3NVMEZCVXl4RFFVRkRMRTFCUVUwc1IwRkJSeXhEUVVGRExFVkJRVVVzUTBGQlF5eEZRVUZGTEVWQlFVVTdRVUZETjBNc1ZVRkJTU3hEUVVGRExFbEJRVWtzUTBGQlF5eFRRVUZUTEVOQlFVTXNRMEZCUXl4RFFVRkRMRU5CUVVNc1EwRkJRenRMUVVONlFqczdRVUZGUkN4UlFVRkpMRXRCUVVzc1IwRkJSeXhEUVVGRExFTkJRVU03UVVGRFpDeFJRVUZKTEU5QlFVOHNRMEZCUXl4SlFVRkpMRU5CUVVNc1MwRkJTeXhKUVVGSkxFbEJRVWtzUlVGQlJUdEJRVU01UWl4WFFVRkxMRWRCUVVjc1QwRkJUeXhEUVVGRExFbEJRVWtzUTBGQlF5eExRVUZMTEVOQlFVTTdTMEZETlVJc1RVRkJUU3hKUVVGSkxFOUJRVThzUTBGQlF5eEpRVUZKTEVsQlFVa3NUMEZCVHl4RFFVRkRMRWxCUVVrc1EwRkJReXhMUVVGTExFbEJRVWtzU1VGQlNTeEZRVUZGTzBGQlEzSkVMRmRCUVVzc1IwRkJSeXhQUVVGUExFTkJRVU1zU1VGQlNTeERRVUZETEV0QlFVc3NRMEZCUXp0TFFVTTFRanRCUVVORUxGRkJRVWtzUTBGQlF5eERRVUZETEVOQlFVTXNSMEZCUnl4TFFVRkxMRU5CUVVNN08wRkJSV2hDTEZsQlFWRXNRMEZCUXl4SFFVRkhMRTFCUVVFc1EwRkJXaXhSUVVGUkxFVkJRVk1zU1VGQlNTeERRVUZETEVOQlFVTTdSMEZEZUVJc1EwRkJReXhEUVVGRE8wTkJRMG9pTENKbWFXeGxJam9pYkc5bkxtcHpJaXdpYzI5MWNtTmxjME52Ym5SbGJuUWlPbHNpWlhod2IzSjBJR1JsWm1GMWJIUWdablZ1WTNScGIyNG9hVzV6ZEdGdVkyVXBJSHRjYmlBZ2FXNXpkR0Z1WTJVdWNtVm5hWE4wWlhKSVpXeHdaWElvSjJ4dlp5Y3NJR1oxYm1OMGFXOXVLQzhxSUcxbGMzTmhaMlVzSUc5d2RHbHZibk1nS2k4cElIdGNiaUFnSUNCc1pYUWdZWEpuY3lBOUlGdDFibVJsWm1sdVpXUmRMRnh1SUNBZ0lDQWdJQ0J2Y0hScGIyNXpJRDBnWVhKbmRXMWxiblJ6VzJGeVozVnRaVzUwY3k1c1pXNW5kR2dnTFNBeFhUdGNiaUFnSUNCbWIzSWdLR3hsZENCcElEMGdNRHNnYVNBOElHRnlaM1Z0Wlc1MGN5NXNaVzVuZEdnZ0xTQXhPeUJwS3lzcElIdGNiaUFnSUNBZ0lHRnlaM011Y0hWemFDaGhjbWQxYldWdWRITmJhVjBwTzF4dUlDQWdJSDFjYmx4dUlDQWdJR3hsZENCc1pYWmxiQ0E5SURFN1hHNGdJQ0FnYVdZZ0tHOXdkR2x2Ym5NdWFHRnphQzVzWlhabGJDQWhQU0J1ZFd4c0tTQjdYRzRnSUNBZ0lDQnNaWFpsYkNBOUlHOXdkR2x2Ym5NdWFHRnphQzVzWlhabGJEdGNiaUFnSUNCOUlHVnNjMlVnYVdZZ0tHOXdkR2x2Ym5NdVpHRjBZU0FtSmlCdmNIUnBiMjV6TG1SaGRHRXViR1YyWld3Z0lUMGdiblZzYkNrZ2UxeHVJQ0FnSUNBZ2JHVjJaV3dnUFNCdmNIUnBiMjV6TG1SaGRHRXViR1YyWld3N1hHNGdJQ0FnZlZ4dUlDQWdJR0Z5WjNOYk1GMGdQU0JzWlhabGJEdGNibHh1SUNBZ0lHbHVjM1JoYm1ObExteHZaeWd1TGk0Z1lYSm5jeWs3WEc0Z0lIMHBPMXh1ZlZ4dUlsMTlcbiIsIid1c2Ugc3RyaWN0JztcblxuZXhwb3J0cy5fX2VzTW9kdWxlID0gdHJ1ZTtcblxuZXhwb3J0c1snZGVmYXVsdCddID0gZnVuY3Rpb24gKGluc3RhbmNlKSB7XG4gIGluc3RhbmNlLnJlZ2lzdGVySGVscGVyKCdsb29rdXAnLCBmdW5jdGlvbiAob2JqLCBmaWVsZCkge1xuICAgIGlmICghb2JqKSB7XG4gICAgICByZXR1cm4gb2JqO1xuICAgIH1cbiAgICBpZiAoZmllbGQgPT09ICdjb25zdHJ1Y3RvcicgJiYgIW9iai5wcm9wZXJ0eUlzRW51bWVyYWJsZShmaWVsZCkpIHtcbiAgICAgIHJldHVybiB1bmRlZmluZWQ7XG4gICAgfVxuICAgIHJldHVybiBvYmpbZmllbGRdO1xuICB9KTtcbn07XG5cbm1vZHVsZS5leHBvcnRzID0gZXhwb3J0c1snZGVmYXVsdCddO1xuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDJobGJIQmxjbk12Ykc5dmEzVndMbXB6SWwwc0ltNWhiV1Z6SWpwYlhTd2liV0Z3Y0dsdVozTWlPaUk3T3pzN2NVSkJRV1VzVlVGQlV5eFJRVUZSTEVWQlFVVTdRVUZEYUVNc1ZVRkJVU3hEUVVGRExHTkJRV01zUTBGQlF5eFJRVUZSTEVWQlFVVXNWVUZCVXl4SFFVRkhMRVZCUVVVc1MwRkJTeXhGUVVGRk8wRkJRM0pFTEZGQlFVa3NRMEZCUXl4SFFVRkhMRVZCUVVVN1FVRkRVaXhoUVVGUExFZEJRVWNzUTBGQlF6dExRVU5hTzBGQlEwUXNVVUZCU1N4TFFVRkxMRXRCUVVzc1lVRkJZU3hKUVVGSkxFTkJRVU1zUjBGQlJ5eERRVUZETEc5Q1FVRnZRaXhEUVVGRExFdEJRVXNzUTBGQlF5eEZRVUZGTzBGQlF5OUVMR0ZCUVU4c1UwRkJVeXhEUVVGRE8wdEJRMnhDTzBGQlEwUXNWMEZCVHl4SFFVRkhMRU5CUVVNc1MwRkJTeXhEUVVGRExFTkJRVU03UjBGRGJrSXNRMEZCUXl4RFFVRkRPME5CUTBvaUxDSm1hV3hsSWpvaWJHOXZhM1Z3TG1weklpd2ljMjkxY21ObGMwTnZiblJsYm5RaU9sc2laWGh3YjNKMElHUmxabUYxYkhRZ1puVnVZM1JwYjI0b2FXNXpkR0Z1WTJVcElIdGNiaUFnYVc1emRHRnVZMlV1Y21WbmFYTjBaWEpJWld4d1pYSW9KMnh2YjJ0MWNDY3NJR1oxYm1OMGFXOXVLRzlpYWl3Z1ptbGxiR1FwSUh0Y2JpQWdJQ0JwWmlBb0lXOWlhaWtnZTF4dUlDQWdJQ0FnY21WMGRYSnVJRzlpYWp0Y2JpQWdJQ0I5WEc0Z0lDQWdhV1lnS0dacFpXeGtJRDA5UFNBblkyOXVjM1J5ZFdOMGIzSW5JQ1ltSUNGdlltb3VjSEp2Y0dWeWRIbEpjMFZ1ZFcxbGNtRmliR1VvWm1sbGJHUXBLU0I3WEc0Z0lDQWdJQ0J5WlhSMWNtNGdkVzVrWldacGJtVmtPMXh1SUNBZ0lIMWNiaUFnSUNCeVpYUjFjbTRnYjJKcVcyWnBaV3hrWFR0Y2JpQWdmU2s3WEc1OVhHNGlYWDA9XG4iLCIndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG5cbnZhciBfdXRpbHMgPSByZXF1aXJlKCcuLi91dGlscycpO1xuXG5leHBvcnRzWydkZWZhdWx0J10gPSBmdW5jdGlvbiAoaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ3dpdGgnLCBmdW5jdGlvbiAoY29udGV4dCwgb3B0aW9ucykge1xuICAgIGlmIChfdXRpbHMuaXNGdW5jdGlvbihjb250ZXh0KSkge1xuICAgICAgY29udGV4dCA9IGNvbnRleHQuY2FsbCh0aGlzKTtcbiAgICB9XG5cbiAgICB2YXIgZm4gPSBvcHRpb25zLmZuO1xuXG4gICAgaWYgKCFfdXRpbHMuaXNFbXB0eShjb250ZXh0KSkge1xuICAgICAgdmFyIGRhdGEgPSBvcHRpb25zLmRhdGE7XG4gICAgICBpZiAob3B0aW9ucy5kYXRhICYmIG9wdGlvbnMuaWRzKSB7XG4gICAgICAgIGRhdGEgPSBfdXRpbHMuY3JlYXRlRnJhbWUob3B0aW9ucy5kYXRhKTtcbiAgICAgICAgZGF0YS5jb250ZXh0UGF0aCA9IF91dGlscy5hcHBlbmRDb250ZXh0UGF0aChvcHRpb25zLmRhdGEuY29udGV4dFBhdGgsIG9wdGlvbnMuaWRzWzBdKTtcbiAgICAgIH1cblxuICAgICAgcmV0dXJuIGZuKGNvbnRleHQsIHtcbiAgICAgICAgZGF0YTogZGF0YSxcbiAgICAgICAgYmxvY2tQYXJhbXM6IF91dGlscy5ibG9ja1BhcmFtcyhbY29udGV4dF0sIFtkYXRhICYmIGRhdGEuY29udGV4dFBhdGhdKVxuICAgICAgfSk7XG4gICAgfSBlbHNlIHtcbiAgICAgIHJldHVybiBvcHRpb25zLmludmVyc2UodGhpcyk7XG4gICAgfVxuICB9KTtcbn07XG5cbm1vZHVsZS5leHBvcnRzID0gZXhwb3J0c1snZGVmYXVsdCddO1xuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDJobGJIQmxjbk12ZDJsMGFDNXFjeUpkTENKdVlXMWxjeUk2VzEwc0ltMWhjSEJwYm1keklqb2lPenM3TzNGQ1FVRXJSU3hWUVVGVk96dHhRa0ZGTVVVc1ZVRkJVeXhSUVVGUkxFVkJRVVU3UVVGRGFFTXNWVUZCVVN4RFFVRkRMR05CUVdNc1EwRkJReXhOUVVGTkxFVkJRVVVzVlVGQlV5eFBRVUZQTEVWQlFVVXNUMEZCVHl4RlFVRkZPMEZCUTNwRUxGRkJRVWtzYTBKQlFWY3NUMEZCVHl4RFFVRkRMRVZCUVVVN1FVRkJSU3hoUVVGUExFZEJRVWNzVDBGQlR5eERRVUZETEVsQlFVa3NRMEZCUXl4SlFVRkpMRU5CUVVNc1EwRkJRenRMUVVGRk96dEJRVVV4UkN4UlFVRkpMRVZCUVVVc1IwRkJSeXhQUVVGUExFTkJRVU1zUlVGQlJTeERRVUZET3p0QlFVVndRaXhSUVVGSkxFTkJRVU1zWlVGQlVTeFBRVUZQTEVOQlFVTXNSVUZCUlR0QlFVTnlRaXhWUVVGSkxFbEJRVWtzUjBGQlJ5eFBRVUZQTEVOQlFVTXNTVUZCU1N4RFFVRkRPMEZCUTNoQ0xGVkJRVWtzVDBGQlR5eERRVUZETEVsQlFVa3NTVUZCU1N4UFFVRlBMRU5CUVVNc1IwRkJSeXhGUVVGRk8wRkJReTlDTEZsQlFVa3NSMEZCUnl4dFFrRkJXU3hQUVVGUExFTkJRVU1zU1VGQlNTeERRVUZETEVOQlFVTTdRVUZEYWtNc1dVRkJTU3hEUVVGRExGZEJRVmNzUjBGQlJ5eDVRa0ZCYTBJc1QwRkJUeXhEUVVGRExFbEJRVWtzUTBGQlF5eFhRVUZYTEVWQlFVVXNUMEZCVHl4RFFVRkRMRWRCUVVjc1EwRkJReXhEUVVGRExFTkJRVU1zUTBGQlF5eERRVUZETzA5QlEyaEdPenRCUVVWRUxHRkJRVThzUlVGQlJTeERRVUZETEU5QlFVOHNSVUZCUlR0QlFVTnFRaXhaUVVGSkxFVkJRVVVzU1VGQlNUdEJRVU5XTEcxQ1FVRlhMRVZCUVVVc2JVSkJRVmtzUTBGQlF5eFBRVUZQTEVOQlFVTXNSVUZCUlN4RFFVRkRMRWxCUVVrc1NVRkJTU3hKUVVGSkxFTkJRVU1zVjBGQlZ5eERRVUZETEVOQlFVTTdUMEZEYUVVc1EwRkJReXhEUVVGRE8wdEJRMG9zVFVGQlRUdEJRVU5NTEdGQlFVOHNUMEZCVHl4RFFVRkRMRTlCUVU4c1EwRkJReXhKUVVGSkxFTkJRVU1zUTBGQlF6dExRVU01UWp0SFFVTkdMRU5CUVVNc1EwRkJRenREUVVOS0lpd2labWxzWlNJNkluZHBkR2d1YW5NaUxDSnpiM1Z5WTJWelEyOXVkR1Z1ZENJNld5SnBiWEJ2Y25RZ2UyRndjR1Z1WkVOdmJuUmxlSFJRWVhSb0xDQmliRzlqYTFCaGNtRnRjeXdnWTNKbFlYUmxSbkpoYldVc0lHbHpSVzF3ZEhrc0lHbHpSblZ1WTNScGIyNTlJR1p5YjIwZ0p5NHVMM1YwYVd4ekp6dGNibHh1Wlhod2IzSjBJR1JsWm1GMWJIUWdablZ1WTNScGIyNG9hVzV6ZEdGdVkyVXBJSHRjYmlBZ2FXNXpkR0Z1WTJVdWNtVm5hWE4wWlhKSVpXeHdaWElvSjNkcGRHZ25MQ0JtZFc1amRHbHZiaWhqYjI1MFpYaDBMQ0J2Y0hScGIyNXpLU0I3WEc0Z0lDQWdhV1lnS0dselJuVnVZM1JwYjI0b1kyOXVkR1Y0ZENrcElIc2dZMjl1ZEdWNGRDQTlJR052Ym5SbGVIUXVZMkZzYkNoMGFHbHpLVHNnZlZ4dVhHNGdJQ0FnYkdWMElHWnVJRDBnYjNCMGFXOXVjeTVtYmp0Y2JseHVJQ0FnSUdsbUlDZ2hhWE5GYlhCMGVTaGpiMjUwWlhoMEtTa2dlMXh1SUNBZ0lDQWdiR1YwSUdSaGRHRWdQU0J2Y0hScGIyNXpMbVJoZEdFN1hHNGdJQ0FnSUNCcFppQW9iM0IwYVc5dWN5NWtZWFJoSUNZbUlHOXdkR2x2Ym5NdWFXUnpLU0I3WEc0Z0lDQWdJQ0FnSUdSaGRHRWdQU0JqY21WaGRHVkdjbUZ0WlNodmNIUnBiMjV6TG1SaGRHRXBPMXh1SUNBZ0lDQWdJQ0JrWVhSaExtTnZiblJsZUhSUVlYUm9JRDBnWVhCd1pXNWtRMjl1ZEdWNGRGQmhkR2dvYjNCMGFXOXVjeTVrWVhSaExtTnZiblJsZUhSUVlYUm9MQ0J2Y0hScGIyNXpMbWxrYzFzd1hTazdYRzRnSUNBZ0lDQjlYRzVjYmlBZ0lDQWdJSEpsZEhWeWJpQm1iaWhqYjI1MFpYaDBMQ0I3WEc0Z0lDQWdJQ0FnSUdSaGRHRTZJR1JoZEdFc1hHNGdJQ0FnSUNBZ0lHSnNiMk5yVUdGeVlXMXpPaUJpYkc5amExQmhjbUZ0Y3loYlkyOXVkR1Y0ZEYwc0lGdGtZWFJoSUNZbUlHUmhkR0V1WTI5dWRHVjRkRkJoZEdoZEtWeHVJQ0FnSUNBZ2ZTazdYRzRnSUNBZ2ZTQmxiSE5sSUh0Y2JpQWdJQ0FnSUhKbGRIVnliaUJ2Y0hScGIyNXpMbWx1ZG1WeWMyVW9kR2hwY3lrN1hHNGdJQ0FnZlZ4dUlDQjlLVHRjYm4xY2JpSmRmUT09XG4iLCIndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG5cbnZhciBfdXRpbHMgPSByZXF1aXJlKCcuL3V0aWxzJyk7XG5cbnZhciBsb2dnZXIgPSB7XG4gIG1ldGhvZE1hcDogWydkZWJ1ZycsICdpbmZvJywgJ3dhcm4nLCAnZXJyb3InXSxcbiAgbGV2ZWw6ICdpbmZvJyxcblxuICAvLyBNYXBzIGEgZ2l2ZW4gbGV2ZWwgdmFsdWUgdG8gdGhlIGBtZXRob2RNYXBgIGluZGV4ZXMgYWJvdmUuXG4gIGxvb2t1cExldmVsOiBmdW5jdGlvbiBsb29rdXBMZXZlbChsZXZlbCkge1xuICAgIGlmICh0eXBlb2YgbGV2ZWwgPT09ICdzdHJpbmcnKSB7XG4gICAgICB2YXIgbGV2ZWxNYXAgPSBfdXRpbHMuaW5kZXhPZihsb2dnZXIubWV0aG9kTWFwLCBsZXZlbC50b0xvd2VyQ2FzZSgpKTtcbiAgICAgIGlmIChsZXZlbE1hcCA+PSAwKSB7XG4gICAgICAgIGxldmVsID0gbGV2ZWxNYXA7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICBsZXZlbCA9IHBhcnNlSW50KGxldmVsLCAxMCk7XG4gICAgICB9XG4gICAgfVxuXG4gICAgcmV0dXJuIGxldmVsO1xuICB9LFxuXG4gIC8vIENhbiBiZSBvdmVycmlkZGVuIGluIHRoZSBob3N0IGVudmlyb25tZW50XG4gIGxvZzogZnVuY3Rpb24gbG9nKGxldmVsKSB7XG4gICAgbGV2ZWwgPSBsb2dnZXIubG9va3VwTGV2ZWwobGV2ZWwpO1xuXG4gICAgaWYgKHR5cGVvZiBjb25zb2xlICE9PSAndW5kZWZpbmVkJyAmJiBsb2dnZXIubG9va3VwTGV2ZWwobG9nZ2VyLmxldmVsKSA8PSBsZXZlbCkge1xuICAgICAgdmFyIG1ldGhvZCA9IGxvZ2dlci5tZXRob2RNYXBbbGV2ZWxdO1xuICAgICAgaWYgKCFjb25zb2xlW21ldGhvZF0pIHtcbiAgICAgICAgLy8gZXNsaW50LWRpc2FibGUtbGluZSBuby1jb25zb2xlXG4gICAgICAgIG1ldGhvZCA9ICdsb2cnO1xuICAgICAgfVxuXG4gICAgICBmb3IgKHZhciBfbGVuID0gYXJndW1lbnRzLmxlbmd0aCwgbWVzc2FnZSA9IEFycmF5KF9sZW4gPiAxID8gX2xlbiAtIDEgOiAwKSwgX2tleSA9IDE7IF9rZXkgPCBfbGVuOyBfa2V5KyspIHtcbiAgICAgICAgbWVzc2FnZVtfa2V5IC0gMV0gPSBhcmd1bWVudHNbX2tleV07XG4gICAgICB9XG5cbiAgICAgIGNvbnNvbGVbbWV0aG9kXS5hcHBseShjb25zb2xlLCBtZXNzYWdlKTsgLy8gZXNsaW50LWRpc2FibGUtbGluZSBuby1jb25zb2xlXG4gICAgfVxuICB9XG59O1xuXG5leHBvcnRzWydkZWZhdWx0J10gPSBsb2dnZXI7XG5tb2R1bGUuZXhwb3J0cyA9IGV4cG9ydHNbJ2RlZmF1bHQnXTtcbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDJ4dloyZGxjaTVxY3lKZExDSnVZVzFsY3lJNlcxMHNJbTFoY0hCcGJtZHpJam9pT3pzN08zRkNRVUZ6UWl4VFFVRlRPenRCUVVVdlFpeEpRVUZKTEUxQlFVMHNSMEZCUnp0QlFVTllMRmRCUVZNc1JVRkJSU3hEUVVGRExFOUJRVThzUlVGQlJTeE5RVUZOTEVWQlFVVXNUVUZCVFN4RlFVRkZMRTlCUVU4c1EwRkJRenRCUVVNM1F5eFBRVUZMTEVWQlFVVXNUVUZCVFRzN08wRkJSMklzWVVGQlZ5eEZRVUZGTEhGQ1FVRlRMRXRCUVVzc1JVRkJSVHRCUVVNelFpeFJRVUZKTEU5QlFVOHNTMEZCU3l4TFFVRkxMRkZCUVZFc1JVRkJSVHRCUVVNM1FpeFZRVUZKTEZGQlFWRXNSMEZCUnl4bFFVRlJMRTFCUVUwc1EwRkJReXhUUVVGVExFVkJRVVVzUzBGQlN5eERRVUZETEZkQlFWY3NSVUZCUlN4RFFVRkRMRU5CUVVNN1FVRkRPVVFzVlVGQlNTeFJRVUZSTEVsQlFVa3NRMEZCUXl4RlFVRkZPMEZCUTJwQ0xHRkJRVXNzUjBGQlJ5eFJRVUZSTEVOQlFVTTdUMEZEYkVJc1RVRkJUVHRCUVVOTUxHRkJRVXNzUjBGQlJ5eFJRVUZSTEVOQlFVTXNTMEZCU3l4RlFVRkZMRVZCUVVVc1EwRkJReXhEUVVGRE8wOUJRemRDTzB0QlEwWTdPMEZCUlVRc1YwRkJUeXhMUVVGTExFTkJRVU03UjBGRFpEczdPMEZCUjBRc1MwRkJSeXhGUVVGRkxHRkJRVk1zUzBGQlN5eEZRVUZqTzBGQlF5OUNMRk5CUVVzc1IwRkJSeXhOUVVGTkxFTkJRVU1zVjBGQlZ5eERRVUZETEV0QlFVc3NRMEZCUXl4RFFVRkRPenRCUVVWc1F5eFJRVUZKTEU5QlFVOHNUMEZCVHl4TFFVRkxMRmRCUVZjc1NVRkJTU3hOUVVGTkxFTkJRVU1zVjBGQlZ5eERRVUZETEUxQlFVMHNRMEZCUXl4TFFVRkxMRU5CUVVNc1NVRkJTU3hMUVVGTExFVkJRVVU3UVVGREwwVXNWVUZCU1N4TlFVRk5MRWRCUVVjc1RVRkJUU3hEUVVGRExGTkJRVk1zUTBGQlF5eExRVUZMTEVOQlFVTXNRMEZCUXp0QlFVTnlReXhWUVVGSkxFTkJRVU1zVDBGQlR5eERRVUZETEUxQlFVMHNRMEZCUXl4RlFVRkZPenRCUVVOd1FpeGpRVUZOTEVkQlFVY3NTMEZCU3l4RFFVRkRPMDlCUTJoQ096dDNRMEZRYlVJc1QwRkJUenRCUVVGUUxHVkJRVTg3T3p0QlFWRXpRaXhoUVVGUExFTkJRVU1zVFVGQlRTeFBRVUZETEVOQlFXWXNUMEZCVHl4RlFVRlpMRTlCUVU4c1EwRkJReXhEUVVGRE8wdEJRemRDTzBkQlEwWTdRMEZEUml4RFFVRkRPenR4UWtGRllTeE5RVUZOSWl3aVptbHNaU0k2SW14dloyZGxjaTVxY3lJc0luTnZkWEpqWlhORGIyNTBaVzUwSWpwYkltbHRjRzl5ZENCN2FXNWtaWGhQWm4wZ1puSnZiU0FuTGk5MWRHbHNjeWM3WEc1Y2JteGxkQ0JzYjJkblpYSWdQU0I3WEc0Z0lHMWxkR2h2WkUxaGNEb2dXeWRrWldKMVp5Y3NJQ2RwYm1adkp5d2dKM2RoY200bkxDQW5aWEp5YjNJblhTeGNiaUFnYkdWMlpXdzZJQ2RwYm1adkp5eGNibHh1SUNBdkx5Qk5ZWEJ6SUdFZ1oybDJaVzRnYkdWMlpXd2dkbUZzZFdVZ2RHOGdkR2hsSUdCdFpYUm9iMlJOWVhCZ0lHbHVaR1Y0WlhNZ1lXSnZkbVV1WEc0Z0lHeHZiMnQxY0V4bGRtVnNPaUJtZFc1amRHbHZiaWhzWlhabGJDa2dlMXh1SUNBZ0lHbG1JQ2gwZVhCbGIyWWdiR1YyWld3Z1BUMDlJQ2R6ZEhKcGJtY25LU0I3WEc0Z0lDQWdJQ0JzWlhRZ2JHVjJaV3hOWVhBZ1BTQnBibVJsZUU5bUtHeHZaMmRsY2k1dFpYUm9iMlJOWVhBc0lHeGxkbVZzTG5SdlRHOTNaWEpEWVhObEtDa3BPMXh1SUNBZ0lDQWdhV1lnS0d4bGRtVnNUV0Z3SUQ0OUlEQXBJSHRjYmlBZ0lDQWdJQ0FnYkdWMlpXd2dQU0JzWlhabGJFMWhjRHRjYmlBZ0lDQWdJSDBnWld4elpTQjdYRzRnSUNBZ0lDQWdJR3hsZG1Wc0lEMGdjR0Z5YzJWSmJuUW9iR1YyWld3c0lERXdLVHRjYmlBZ0lDQWdJSDFjYmlBZ0lDQjlYRzVjYmlBZ0lDQnlaWFIxY200Z2JHVjJaV3c3WEc0Z0lIMHNYRzVjYmlBZ0x5OGdRMkZ1SUdKbElHOTJaWEp5YVdSa1pXNGdhVzRnZEdobElHaHZjM1FnWlc1MmFYSnZibTFsYm5SY2JpQWdiRzluT2lCbWRXNWpkR2x2Ymloc1pYWmxiQ3dnTGk0dWJXVnpjMkZuWlNrZ2UxeHVJQ0FnSUd4bGRtVnNJRDBnYkc5bloyVnlMbXh2YjJ0MWNFeGxkbVZzS0d4bGRtVnNLVHRjYmx4dUlDQWdJR2xtSUNoMGVYQmxiMllnWTI5dWMyOXNaU0FoUFQwZ0ozVnVaR1ZtYVc1bFpDY2dKaVlnYkc5bloyVnlMbXh2YjJ0MWNFeGxkbVZzS0d4dloyZGxjaTVzWlhabGJDa2dQRDBnYkdWMlpXd3BJSHRjYmlBZ0lDQWdJR3hsZENCdFpYUm9iMlFnUFNCc2IyZG5aWEl1YldWMGFHOWtUV0Z3VzJ4bGRtVnNYVHRjYmlBZ0lDQWdJR2xtSUNnaFkyOXVjMjlzWlZ0dFpYUm9iMlJkS1NCN0lDOHZJR1Z6YkdsdWRDMWthWE5oWW14bExXeHBibVVnYm04dFkyOXVjMjlzWlZ4dUlDQWdJQ0FnSUNCdFpYUm9iMlFnUFNBbmJHOW5KenRjYmlBZ0lDQWdJSDFjYmlBZ0lDQWdJR052Ym5OdmJHVmJiV1YwYUc5a1hTZ3VMaTV0WlhOellXZGxLVHNnTHk4Z1pYTnNhVzUwTFdScGMyRmliR1V0YkdsdVpTQnVieTFqYjI1emIyeGxYRzRnSUNBZ2ZWeHVJQ0I5WEc1OU8xeHVYRzVsZUhCdmNuUWdaR1ZtWVhWc2RDQnNiMmRuWlhJN1hHNGlYWDA9XG4iLCIvKiBnbG9iYWwgd2luZG93ICovXG4ndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG5cbmV4cG9ydHNbJ2RlZmF1bHQnXSA9IGZ1bmN0aW9uIChIYW5kbGViYXJzKSB7XG4gIC8qIGlzdGFuYnVsIGlnbm9yZSBuZXh0ICovXG4gIHZhciByb290ID0gdHlwZW9mIGdsb2JhbCAhPT0gJ3VuZGVmaW5lZCcgPyBnbG9iYWwgOiB3aW5kb3csXG4gICAgICAkSGFuZGxlYmFycyA9IHJvb3QuSGFuZGxlYmFycztcbiAgLyogaXN0YW5idWwgaWdub3JlIG5leHQgKi9cbiAgSGFuZGxlYmFycy5ub0NvbmZsaWN0ID0gZnVuY3Rpb24gKCkge1xuICAgIGlmIChyb290LkhhbmRsZWJhcnMgPT09IEhhbmRsZWJhcnMpIHtcbiAgICAgIHJvb3QuSGFuZGxlYmFycyA9ICRIYW5kbGViYXJzO1xuICAgIH1cbiAgICByZXR1cm4gSGFuZGxlYmFycztcbiAgfTtcbn07XG5cbm1vZHVsZS5leHBvcnRzID0gZXhwb3J0c1snZGVmYXVsdCddO1xuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMeTR1TDJ4cFlpOW9ZVzVrYkdWaVlYSnpMMjV2TFdOdmJtWnNhV04wTG1weklsMHNJbTVoYldWeklqcGJYU3dpYldGd2NHbHVaM01pT2lJN096czdPM0ZDUVVObExGVkJRVk1zVlVGQlZTeEZRVUZGT3p0QlFVVnNReXhOUVVGSkxFbEJRVWtzUjBGQlJ5eFBRVUZQTEUxQlFVMHNTMEZCU3l4WFFVRlhMRWRCUVVjc1RVRkJUU3hIUVVGSExFMUJRVTA3VFVGRGRFUXNWMEZCVnl4SFFVRkhMRWxCUVVrc1EwRkJReXhWUVVGVkxFTkJRVU03TzBGQlJXeERMRmxCUVZVc1EwRkJReXhWUVVGVkxFZEJRVWNzV1VGQlZ6dEJRVU5xUXl4UlFVRkpMRWxCUVVrc1EwRkJReXhWUVVGVkxFdEJRVXNzVlVGQlZTeEZRVUZGTzBGQlEyeERMRlZCUVVrc1EwRkJReXhWUVVGVkxFZEJRVWNzVjBGQlZ5eERRVUZETzB0QlF5OUNPMEZCUTBRc1YwRkJUeXhWUVVGVkxFTkJRVU03UjBGRGJrSXNRMEZCUXp0RFFVTklJaXdpWm1sc1pTSTZJbTV2TFdOdmJtWnNhV04wTG1weklpd2ljMjkxY21ObGMwTnZiblJsYm5RaU9sc2lMeW9nWjJ4dlltRnNJSGRwYm1SdmR5QXFMMXh1Wlhod2IzSjBJR1JsWm1GMWJIUWdablZ1WTNScGIyNG9TR0Z1Wkd4bFltRnljeWtnZTF4dUlDQXZLaUJwYzNSaGJtSjFiQ0JwWjI1dmNtVWdibVY0ZENBcUwxeHVJQ0JzWlhRZ2NtOXZkQ0E5SUhSNWNHVnZaaUJuYkc5aVlXd2dJVDA5SUNkMWJtUmxabWx1WldRbklEOGdaMnh2WW1Gc0lEb2dkMmx1Wkc5M0xGeHVJQ0FnSUNBZ0pFaGhibVJzWldKaGNuTWdQU0J5YjI5MExraGhibVJzWldKaGNuTTdYRzRnSUM4cUlHbHpkR0Z1WW5Wc0lHbG5ibTl5WlNCdVpYaDBJQ292WEc0Z0lFaGhibVJzWldKaGNuTXVibTlEYjI1bWJHbGpkQ0E5SUdaMWJtTjBhVzl1S0NrZ2UxeHVJQ0FnSUdsbUlDaHliMjkwTGtoaGJtUnNaV0poY25NZ1BUMDlJRWhoYm1Sc1pXSmhjbk1wSUh0Y2JpQWdJQ0FnSUhKdmIzUXVTR0Z1Wkd4bFltRnljeUE5SUNSSVlXNWtiR1ZpWVhKek8xeHVJQ0FnSUgxY2JpQWdJQ0J5WlhSMWNtNGdTR0Z1Wkd4bFltRnljenRjYmlBZ2ZUdGNibjFjYmlKZGZRPT1cbiIsIid1c2Ugc3RyaWN0JztcblxuZXhwb3J0cy5fX2VzTW9kdWxlID0gdHJ1ZTtcbmV4cG9ydHMuY2hlY2tSZXZpc2lvbiA9IGNoZWNrUmV2aXNpb247XG5leHBvcnRzLnRlbXBsYXRlID0gdGVtcGxhdGU7XG5leHBvcnRzLndyYXBQcm9ncmFtID0gd3JhcFByb2dyYW07XG5leHBvcnRzLnJlc29sdmVQYXJ0aWFsID0gcmVzb2x2ZVBhcnRpYWw7XG5leHBvcnRzLmludm9rZVBhcnRpYWwgPSBpbnZva2VQYXJ0aWFsO1xuZXhwb3J0cy5ub29wID0gbm9vcDtcbi8vIGlzdGFuYnVsIGlnbm9yZSBuZXh0XG5cbmZ1bmN0aW9uIF9pbnRlcm9wUmVxdWlyZURlZmF1bHQob2JqKSB7IHJldHVybiBvYmogJiYgb2JqLl9fZXNNb2R1bGUgPyBvYmogOiB7ICdkZWZhdWx0Jzogb2JqIH07IH1cblxuLy8gaXN0YW5idWwgaWdub3JlIG5leHRcblxuZnVuY3Rpb24gX2ludGVyb3BSZXF1aXJlV2lsZGNhcmQob2JqKSB7IGlmIChvYmogJiYgb2JqLl9fZXNNb2R1bGUpIHsgcmV0dXJuIG9iajsgfSBlbHNlIHsgdmFyIG5ld09iaiA9IHt9OyBpZiAob2JqICE9IG51bGwpIHsgZm9yICh2YXIga2V5IGluIG9iaikgeyBpZiAoT2JqZWN0LnByb3RvdHlwZS5oYXNPd25Qcm9wZXJ0eS5jYWxsKG9iaiwga2V5KSkgbmV3T2JqW2tleV0gPSBvYmpba2V5XTsgfSB9IG5ld09ialsnZGVmYXVsdCddID0gb2JqOyByZXR1cm4gbmV3T2JqOyB9IH1cblxudmFyIF91dGlscyA9IHJlcXVpcmUoJy4vdXRpbHMnKTtcblxudmFyIFV0aWxzID0gX2ludGVyb3BSZXF1aXJlV2lsZGNhcmQoX3V0aWxzKTtcblxudmFyIF9leGNlcHRpb24gPSByZXF1aXJlKCcuL2V4Y2VwdGlvbicpO1xuXG52YXIgX2V4Y2VwdGlvbjIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9leGNlcHRpb24pO1xuXG52YXIgX2Jhc2UgPSByZXF1aXJlKCcuL2Jhc2UnKTtcblxuZnVuY3Rpb24gY2hlY2tSZXZpc2lvbihjb21waWxlckluZm8pIHtcbiAgdmFyIGNvbXBpbGVyUmV2aXNpb24gPSBjb21waWxlckluZm8gJiYgY29tcGlsZXJJbmZvWzBdIHx8IDEsXG4gICAgICBjdXJyZW50UmV2aXNpb24gPSBfYmFzZS5DT01QSUxFUl9SRVZJU0lPTjtcblxuICBpZiAoY29tcGlsZXJSZXZpc2lvbiAhPT0gY3VycmVudFJldmlzaW9uKSB7XG4gICAgaWYgKGNvbXBpbGVyUmV2aXNpb24gPCBjdXJyZW50UmV2aXNpb24pIHtcbiAgICAgIHZhciBydW50aW1lVmVyc2lvbnMgPSBfYmFzZS5SRVZJU0lPTl9DSEFOR0VTW2N1cnJlbnRSZXZpc2lvbl0sXG4gICAgICAgICAgY29tcGlsZXJWZXJzaW9ucyA9IF9iYXNlLlJFVklTSU9OX0NIQU5HRVNbY29tcGlsZXJSZXZpc2lvbl07XG4gICAgICB0aHJvdyBuZXcgX2V4Y2VwdGlvbjJbJ2RlZmF1bHQnXSgnVGVtcGxhdGUgd2FzIHByZWNvbXBpbGVkIHdpdGggYW4gb2xkZXIgdmVyc2lvbiBvZiBIYW5kbGViYXJzIHRoYW4gdGhlIGN1cnJlbnQgcnVudGltZS4gJyArICdQbGVhc2UgdXBkYXRlIHlvdXIgcHJlY29tcGlsZXIgdG8gYSBuZXdlciB2ZXJzaW9uICgnICsgcnVudGltZVZlcnNpb25zICsgJykgb3IgZG93bmdyYWRlIHlvdXIgcnVudGltZSB0byBhbiBvbGRlciB2ZXJzaW9uICgnICsgY29tcGlsZXJWZXJzaW9ucyArICcpLicpO1xuICAgIH0gZWxzZSB7XG4gICAgICAvLyBVc2UgdGhlIGVtYmVkZGVkIHZlcnNpb24gaW5mbyBzaW5jZSB0aGUgcnVudGltZSBkb2Vzbid0IGtub3cgYWJvdXQgdGhpcyByZXZpc2lvbiB5ZXRcbiAgICAgIHRocm93IG5ldyBfZXhjZXB0aW9uMlsnZGVmYXVsdCddKCdUZW1wbGF0ZSB3YXMgcHJlY29tcGlsZWQgd2l0aCBhIG5ld2VyIHZlcnNpb24gb2YgSGFuZGxlYmFycyB0aGFuIHRoZSBjdXJyZW50IHJ1bnRpbWUuICcgKyAnUGxlYXNlIHVwZGF0ZSB5b3VyIHJ1bnRpbWUgdG8gYSBuZXdlciB2ZXJzaW9uICgnICsgY29tcGlsZXJJbmZvWzFdICsgJykuJyk7XG4gICAgfVxuICB9XG59XG5cbmZ1bmN0aW9uIHRlbXBsYXRlKHRlbXBsYXRlU3BlYywgZW52KSB7XG4gIC8qIGlzdGFuYnVsIGlnbm9yZSBuZXh0ICovXG4gIGlmICghZW52KSB7XG4gICAgdGhyb3cgbmV3IF9leGNlcHRpb24yWydkZWZhdWx0J10oJ05vIGVudmlyb25tZW50IHBhc3NlZCB0byB0ZW1wbGF0ZScpO1xuICB9XG4gIGlmICghdGVtcGxhdGVTcGVjIHx8ICF0ZW1wbGF0ZVNwZWMubWFpbikge1xuICAgIHRocm93IG5ldyBfZXhjZXB0aW9uMlsnZGVmYXVsdCddKCdVbmtub3duIHRlbXBsYXRlIG9iamVjdDogJyArIHR5cGVvZiB0ZW1wbGF0ZVNwZWMpO1xuICB9XG5cbiAgdGVtcGxhdGVTcGVjLm1haW4uZGVjb3JhdG9yID0gdGVtcGxhdGVTcGVjLm1haW5fZDtcblxuICAvLyBOb3RlOiBVc2luZyBlbnYuVk0gcmVmZXJlbmNlcyByYXRoZXIgdGhhbiBsb2NhbCB2YXIgcmVmZXJlbmNlcyB0aHJvdWdob3V0IHRoaXMgc2VjdGlvbiB0byBhbGxvd1xuICAvLyBmb3IgZXh0ZXJuYWwgdXNlcnMgdG8gb3ZlcnJpZGUgdGhlc2UgYXMgcHN1ZWRvLXN1cHBvcnRlZCBBUElzLlxuICBlbnYuVk0uY2hlY2tSZXZpc2lvbih0ZW1wbGF0ZVNwZWMuY29tcGlsZXIpO1xuXG4gIGZ1bmN0aW9uIGludm9rZVBhcnRpYWxXcmFwcGVyKHBhcnRpYWwsIGNvbnRleHQsIG9wdGlvbnMpIHtcbiAgICBpZiAob3B0aW9ucy5oYXNoKSB7XG4gICAgICBjb250ZXh0ID0gVXRpbHMuZXh0ZW5kKHt9LCBjb250ZXh0LCBvcHRpb25zLmhhc2gpO1xuICAgICAgaWYgKG9wdGlvbnMuaWRzKSB7XG4gICAgICAgIG9wdGlvbnMuaWRzWzBdID0gdHJ1ZTtcbiAgICAgIH1cbiAgICB9XG5cbiAgICBwYXJ0aWFsID0gZW52LlZNLnJlc29sdmVQYXJ0aWFsLmNhbGwodGhpcywgcGFydGlhbCwgY29udGV4dCwgb3B0aW9ucyk7XG4gICAgdmFyIHJlc3VsdCA9IGVudi5WTS5pbnZva2VQYXJ0aWFsLmNhbGwodGhpcywgcGFydGlhbCwgY29udGV4dCwgb3B0aW9ucyk7XG5cbiAgICBpZiAocmVzdWx0ID09IG51bGwgJiYgZW52LmNvbXBpbGUpIHtcbiAgICAgIG9wdGlvbnMucGFydGlhbHNbb3B0aW9ucy5uYW1lXSA9IGVudi5jb21waWxlKHBhcnRpYWwsIHRlbXBsYXRlU3BlYy5jb21waWxlck9wdGlvbnMsIGVudik7XG4gICAgICByZXN1bHQgPSBvcHRpb25zLnBhcnRpYWxzW29wdGlvbnMubmFtZV0oY29udGV4dCwgb3B0aW9ucyk7XG4gICAgfVxuICAgIGlmIChyZXN1bHQgIT0gbnVsbCkge1xuICAgICAgaWYgKG9wdGlvbnMuaW5kZW50KSB7XG4gICAgICAgIHZhciBsaW5lcyA9IHJlc3VsdC5zcGxpdCgnXFxuJyk7XG4gICAgICAgIGZvciAodmFyIGkgPSAwLCBsID0gbGluZXMubGVuZ3RoOyBpIDwgbDsgaSsrKSB7XG4gICAgICAgICAgaWYgKCFsaW5lc1tpXSAmJiBpICsgMSA9PT0gbCkge1xuICAgICAgICAgICAgYnJlYWs7XG4gICAgICAgICAgfVxuXG4gICAgICAgICAgbGluZXNbaV0gPSBvcHRpb25zLmluZGVudCArIGxpbmVzW2ldO1xuICAgICAgICB9XG4gICAgICAgIHJlc3VsdCA9IGxpbmVzLmpvaW4oJ1xcbicpO1xuICAgICAgfVxuICAgICAgcmV0dXJuIHJlc3VsdDtcbiAgICB9IGVsc2Uge1xuICAgICAgdGhyb3cgbmV3IF9leGNlcHRpb24yWydkZWZhdWx0J10oJ1RoZSBwYXJ0aWFsICcgKyBvcHRpb25zLm5hbWUgKyAnIGNvdWxkIG5vdCBiZSBjb21waWxlZCB3aGVuIHJ1bm5pbmcgaW4gcnVudGltZS1vbmx5IG1vZGUnKTtcbiAgICB9XG4gIH1cblxuICAvLyBKdXN0IGFkZCB3YXRlclxuICB2YXIgY29udGFpbmVyID0ge1xuICAgIHN0cmljdDogZnVuY3Rpb24gc3RyaWN0KG9iaiwgbmFtZSkge1xuICAgICAgaWYgKCEobmFtZSBpbiBvYmopKSB7XG4gICAgICAgIHRocm93IG5ldyBfZXhjZXB0aW9uMlsnZGVmYXVsdCddKCdcIicgKyBuYW1lICsgJ1wiIG5vdCBkZWZpbmVkIGluICcgKyBvYmopO1xuICAgICAgfVxuICAgICAgcmV0dXJuIG9ialtuYW1lXTtcbiAgICB9LFxuICAgIGxvb2t1cDogZnVuY3Rpb24gbG9va3VwKGRlcHRocywgbmFtZSkge1xuICAgICAgdmFyIGxlbiA9IGRlcHRocy5sZW5ndGg7XG4gICAgICBmb3IgKHZhciBpID0gMDsgaSA8IGxlbjsgaSsrKSB7XG4gICAgICAgIGlmIChkZXB0aHNbaV0gJiYgZGVwdGhzW2ldW25hbWVdICE9IG51bGwpIHtcbiAgICAgICAgICByZXR1cm4gZGVwdGhzW2ldW25hbWVdO1xuICAgICAgICB9XG4gICAgICB9XG4gICAgfSxcbiAgICBsYW1iZGE6IGZ1bmN0aW9uIGxhbWJkYShjdXJyZW50LCBjb250ZXh0KSB7XG4gICAgICByZXR1cm4gdHlwZW9mIGN1cnJlbnQgPT09ICdmdW5jdGlvbicgPyBjdXJyZW50LmNhbGwoY29udGV4dCkgOiBjdXJyZW50O1xuICAgIH0sXG5cbiAgICBlc2NhcGVFeHByZXNzaW9uOiBVdGlscy5lc2NhcGVFeHByZXNzaW9uLFxuICAgIGludm9rZVBhcnRpYWw6IGludm9rZVBhcnRpYWxXcmFwcGVyLFxuXG4gICAgZm46IGZ1bmN0aW9uIGZuKGkpIHtcbiAgICAgIHZhciByZXQgPSB0ZW1wbGF0ZVNwZWNbaV07XG4gICAgICByZXQuZGVjb3JhdG9yID0gdGVtcGxhdGVTcGVjW2kgKyAnX2QnXTtcbiAgICAgIHJldHVybiByZXQ7XG4gICAgfSxcblxuICAgIHByb2dyYW1zOiBbXSxcbiAgICBwcm9ncmFtOiBmdW5jdGlvbiBwcm9ncmFtKGksIGRhdGEsIGRlY2xhcmVkQmxvY2tQYXJhbXMsIGJsb2NrUGFyYW1zLCBkZXB0aHMpIHtcbiAgICAgIHZhciBwcm9ncmFtV3JhcHBlciA9IHRoaXMucHJvZ3JhbXNbaV0sXG4gICAgICAgICAgZm4gPSB0aGlzLmZuKGkpO1xuICAgICAgaWYgKGRhdGEgfHwgZGVwdGhzIHx8IGJsb2NrUGFyYW1zIHx8IGRlY2xhcmVkQmxvY2tQYXJhbXMpIHtcbiAgICAgICAgcHJvZ3JhbVdyYXBwZXIgPSB3cmFwUHJvZ3JhbSh0aGlzLCBpLCBmbiwgZGF0YSwgZGVjbGFyZWRCbG9ja1BhcmFtcywgYmxvY2tQYXJhbXMsIGRlcHRocyk7XG4gICAgICB9IGVsc2UgaWYgKCFwcm9ncmFtV3JhcHBlcikge1xuICAgICAgICBwcm9ncmFtV3JhcHBlciA9IHRoaXMucHJvZ3JhbXNbaV0gPSB3cmFwUHJvZ3JhbSh0aGlzLCBpLCBmbik7XG4gICAgICB9XG4gICAgICByZXR1cm4gcHJvZ3JhbVdyYXBwZXI7XG4gICAgfSxcblxuICAgIGRhdGE6IGZ1bmN0aW9uIGRhdGEodmFsdWUsIGRlcHRoKSB7XG4gICAgICB3aGlsZSAodmFsdWUgJiYgZGVwdGgtLSkge1xuICAgICAgICB2YWx1ZSA9IHZhbHVlLl9wYXJlbnQ7XG4gICAgICB9XG4gICAgICByZXR1cm4gdmFsdWU7XG4gICAgfSxcbiAgICBtZXJnZTogZnVuY3Rpb24gbWVyZ2UocGFyYW0sIGNvbW1vbikge1xuICAgICAgdmFyIG9iaiA9IHBhcmFtIHx8IGNvbW1vbjtcblxuICAgICAgaWYgKHBhcmFtICYmIGNvbW1vbiAmJiBwYXJhbSAhPT0gY29tbW9uKSB7XG4gICAgICAgIG9iaiA9IFV0aWxzLmV4dGVuZCh7fSwgY29tbW9uLCBwYXJhbSk7XG4gICAgICB9XG5cbiAgICAgIHJldHVybiBvYmo7XG4gICAgfSxcbiAgICAvLyBBbiBlbXB0eSBvYmplY3QgdG8gdXNlIGFzIHJlcGxhY2VtZW50IGZvciBudWxsLWNvbnRleHRzXG4gICAgbnVsbENvbnRleHQ6IE9iamVjdC5zZWFsKHt9KSxcblxuICAgIG5vb3A6IGVudi5WTS5ub29wLFxuICAgIGNvbXBpbGVySW5mbzogdGVtcGxhdGVTcGVjLmNvbXBpbGVyXG4gIH07XG5cbiAgZnVuY3Rpb24gcmV0KGNvbnRleHQpIHtcbiAgICB2YXIgb3B0aW9ucyA9IGFyZ3VtZW50cy5sZW5ndGggPD0gMSB8fCBhcmd1bWVudHNbMV0gPT09IHVuZGVmaW5lZCA/IHt9IDogYXJndW1lbnRzWzFdO1xuXG4gICAgdmFyIGRhdGEgPSBvcHRpb25zLmRhdGE7XG5cbiAgICByZXQuX3NldHVwKG9wdGlvbnMpO1xuICAgIGlmICghb3B0aW9ucy5wYXJ0aWFsICYmIHRlbXBsYXRlU3BlYy51c2VEYXRhKSB7XG4gICAgICBkYXRhID0gaW5pdERhdGEoY29udGV4dCwgZGF0YSk7XG4gICAgfVxuICAgIHZhciBkZXB0aHMgPSB1bmRlZmluZWQsXG4gICAgICAgIGJsb2NrUGFyYW1zID0gdGVtcGxhdGVTcGVjLnVzZUJsb2NrUGFyYW1zID8gW10gOiB1bmRlZmluZWQ7XG4gICAgaWYgKHRlbXBsYXRlU3BlYy51c2VEZXB0aHMpIHtcbiAgICAgIGlmIChvcHRpb25zLmRlcHRocykge1xuICAgICAgICBkZXB0aHMgPSBjb250ZXh0ICE9IG9wdGlvbnMuZGVwdGhzWzBdID8gW2NvbnRleHRdLmNvbmNhdChvcHRpb25zLmRlcHRocykgOiBvcHRpb25zLmRlcHRocztcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGRlcHRocyA9IFtjb250ZXh0XTtcbiAgICAgIH1cbiAgICB9XG5cbiAgICBmdW5jdGlvbiBtYWluKGNvbnRleHQgLyosIG9wdGlvbnMqLykge1xuICAgICAgcmV0dXJuICcnICsgdGVtcGxhdGVTcGVjLm1haW4oY29udGFpbmVyLCBjb250ZXh0LCBjb250YWluZXIuaGVscGVycywgY29udGFpbmVyLnBhcnRpYWxzLCBkYXRhLCBibG9ja1BhcmFtcywgZGVwdGhzKTtcbiAgICB9XG4gICAgbWFpbiA9IGV4ZWN1dGVEZWNvcmF0b3JzKHRlbXBsYXRlU3BlYy5tYWluLCBtYWluLCBjb250YWluZXIsIG9wdGlvbnMuZGVwdGhzIHx8IFtdLCBkYXRhLCBibG9ja1BhcmFtcyk7XG4gICAgcmV0dXJuIG1haW4oY29udGV4dCwgb3B0aW9ucyk7XG4gIH1cbiAgcmV0LmlzVG9wID0gdHJ1ZTtcblxuICByZXQuX3NldHVwID0gZnVuY3Rpb24gKG9wdGlvbnMpIHtcbiAgICBpZiAoIW9wdGlvbnMucGFydGlhbCkge1xuICAgICAgY29udGFpbmVyLmhlbHBlcnMgPSBjb250YWluZXIubWVyZ2Uob3B0aW9ucy5oZWxwZXJzLCBlbnYuaGVscGVycyk7XG5cbiAgICAgIGlmICh0ZW1wbGF0ZVNwZWMudXNlUGFydGlhbCkge1xuICAgICAgICBjb250YWluZXIucGFydGlhbHMgPSBjb250YWluZXIubWVyZ2Uob3B0aW9ucy5wYXJ0aWFscywgZW52LnBhcnRpYWxzKTtcbiAgICAgIH1cbiAgICAgIGlmICh0ZW1wbGF0ZVNwZWMudXNlUGFydGlhbCB8fCB0ZW1wbGF0ZVNwZWMudXNlRGVjb3JhdG9ycykge1xuICAgICAgICBjb250YWluZXIuZGVjb3JhdG9ycyA9IGNvbnRhaW5lci5tZXJnZShvcHRpb25zLmRlY29yYXRvcnMsIGVudi5kZWNvcmF0b3JzKTtcbiAgICAgIH1cbiAgICB9IGVsc2Uge1xuICAgICAgY29udGFpbmVyLmhlbHBlcnMgPSBvcHRpb25zLmhlbHBlcnM7XG4gICAgICBjb250YWluZXIucGFydGlhbHMgPSBvcHRpb25zLnBhcnRpYWxzO1xuICAgICAgY29udGFpbmVyLmRlY29yYXRvcnMgPSBvcHRpb25zLmRlY29yYXRvcnM7XG4gICAgfVxuICB9O1xuXG4gIHJldC5fY2hpbGQgPSBmdW5jdGlvbiAoaSwgZGF0YSwgYmxvY2tQYXJhbXMsIGRlcHRocykge1xuICAgIGlmICh0ZW1wbGF0ZVNwZWMudXNlQmxvY2tQYXJhbXMgJiYgIWJsb2NrUGFyYW1zKSB7XG4gICAgICB0aHJvdyBuZXcgX2V4Y2VwdGlvbjJbJ2RlZmF1bHQnXSgnbXVzdCBwYXNzIGJsb2NrIHBhcmFtcycpO1xuICAgIH1cbiAgICBpZiAodGVtcGxhdGVTcGVjLnVzZURlcHRocyAmJiAhZGVwdGhzKSB7XG4gICAgICB0aHJvdyBuZXcgX2V4Y2VwdGlvbjJbJ2RlZmF1bHQnXSgnbXVzdCBwYXNzIHBhcmVudCBkZXB0aHMnKTtcbiAgICB9XG5cbiAgICByZXR1cm4gd3JhcFByb2dyYW0oY29udGFpbmVyLCBpLCB0ZW1wbGF0ZVNwZWNbaV0sIGRhdGEsIDAsIGJsb2NrUGFyYW1zLCBkZXB0aHMpO1xuICB9O1xuICByZXR1cm4gcmV0O1xufVxuXG5mdW5jdGlvbiB3cmFwUHJvZ3JhbShjb250YWluZXIsIGksIGZuLCBkYXRhLCBkZWNsYXJlZEJsb2NrUGFyYW1zLCBibG9ja1BhcmFtcywgZGVwdGhzKSB7XG4gIGZ1bmN0aW9uIHByb2coY29udGV4dCkge1xuICAgIHZhciBvcHRpb25zID0gYXJndW1lbnRzLmxlbmd0aCA8PSAxIHx8IGFyZ3VtZW50c1sxXSA9PT0gdW5kZWZpbmVkID8ge30gOiBhcmd1bWVudHNbMV07XG5cbiAgICB2YXIgY3VycmVudERlcHRocyA9IGRlcHRocztcbiAgICBpZiAoZGVwdGhzICYmIGNvbnRleHQgIT0gZGVwdGhzWzBdICYmICEoY29udGV4dCA9PT0gY29udGFpbmVyLm51bGxDb250ZXh0ICYmIGRlcHRoc1swXSA9PT0gbnVsbCkpIHtcbiAgICAgIGN1cnJlbnREZXB0aHMgPSBbY29udGV4dF0uY29uY2F0KGRlcHRocyk7XG4gICAgfVxuXG4gICAgcmV0dXJuIGZuKGNvbnRhaW5lciwgY29udGV4dCwgY29udGFpbmVyLmhlbHBlcnMsIGNvbnRhaW5lci5wYXJ0aWFscywgb3B0aW9ucy5kYXRhIHx8IGRhdGEsIGJsb2NrUGFyYW1zICYmIFtvcHRpb25zLmJsb2NrUGFyYW1zXS5jb25jYXQoYmxvY2tQYXJhbXMpLCBjdXJyZW50RGVwdGhzKTtcbiAgfVxuXG4gIHByb2cgPSBleGVjdXRlRGVjb3JhdG9ycyhmbiwgcHJvZywgY29udGFpbmVyLCBkZXB0aHMsIGRhdGEsIGJsb2NrUGFyYW1zKTtcblxuICBwcm9nLnByb2dyYW0gPSBpO1xuICBwcm9nLmRlcHRoID0gZGVwdGhzID8gZGVwdGhzLmxlbmd0aCA6IDA7XG4gIHByb2cuYmxvY2tQYXJhbXMgPSBkZWNsYXJlZEJsb2NrUGFyYW1zIHx8IDA7XG4gIHJldHVybiBwcm9nO1xufVxuXG5mdW5jdGlvbiByZXNvbHZlUGFydGlhbChwYXJ0aWFsLCBjb250ZXh0LCBvcHRpb25zKSB7XG4gIGlmICghcGFydGlhbCkge1xuICAgIGlmIChvcHRpb25zLm5hbWUgPT09ICdAcGFydGlhbC1ibG9jaycpIHtcbiAgICAgIHBhcnRpYWwgPSBvcHRpb25zLmRhdGFbJ3BhcnRpYWwtYmxvY2snXTtcbiAgICB9IGVsc2Uge1xuICAgICAgcGFydGlhbCA9IG9wdGlvbnMucGFydGlhbHNbb3B0aW9ucy5uYW1lXTtcbiAgICB9XG4gIH0gZWxzZSBpZiAoIXBhcnRpYWwuY2FsbCAmJiAhb3B0aW9ucy5uYW1lKSB7XG4gICAgLy8gVGhpcyBpcyBhIGR5bmFtaWMgcGFydGlhbCB0aGF0IHJldHVybmVkIGEgc3RyaW5nXG4gICAgb3B0aW9ucy5uYW1lID0gcGFydGlhbDtcbiAgICBwYXJ0aWFsID0gb3B0aW9ucy5wYXJ0aWFsc1twYXJ0aWFsXTtcbiAgfVxuICByZXR1cm4gcGFydGlhbDtcbn1cblxuZnVuY3Rpb24gaW52b2tlUGFydGlhbChwYXJ0aWFsLCBjb250ZXh0LCBvcHRpb25zKSB7XG4gIC8vIFVzZSB0aGUgY3VycmVudCBjbG9zdXJlIGNvbnRleHQgdG8gc2F2ZSB0aGUgcGFydGlhbC1ibG9jayBpZiB0aGlzIHBhcnRpYWxcbiAgdmFyIGN1cnJlbnRQYXJ0aWFsQmxvY2sgPSBvcHRpb25zLmRhdGEgJiYgb3B0aW9ucy5kYXRhWydwYXJ0aWFsLWJsb2NrJ107XG4gIG9wdGlvbnMucGFydGlhbCA9IHRydWU7XG4gIGlmIChvcHRpb25zLmlkcykge1xuICAgIG9wdGlvbnMuZGF0YS5jb250ZXh0UGF0aCA9IG9wdGlvbnMuaWRzWzBdIHx8IG9wdGlvbnMuZGF0YS5jb250ZXh0UGF0aDtcbiAgfVxuXG4gIHZhciBwYXJ0aWFsQmxvY2sgPSB1bmRlZmluZWQ7XG4gIGlmIChvcHRpb25zLmZuICYmIG9wdGlvbnMuZm4gIT09IG5vb3ApIHtcbiAgICAoZnVuY3Rpb24gKCkge1xuICAgICAgb3B0aW9ucy5kYXRhID0gX2Jhc2UuY3JlYXRlRnJhbWUob3B0aW9ucy5kYXRhKTtcbiAgICAgIC8vIFdyYXBwZXIgZnVuY3Rpb24gdG8gZ2V0IGFjY2VzcyB0byBjdXJyZW50UGFydGlhbEJsb2NrIGZyb20gdGhlIGNsb3N1cmVcbiAgICAgIHZhciBmbiA9IG9wdGlvbnMuZm47XG4gICAgICBwYXJ0aWFsQmxvY2sgPSBvcHRpb25zLmRhdGFbJ3BhcnRpYWwtYmxvY2snXSA9IGZ1bmN0aW9uIHBhcnRpYWxCbG9ja1dyYXBwZXIoY29udGV4dCkge1xuICAgICAgICB2YXIgb3B0aW9ucyA9IGFyZ3VtZW50cy5sZW5ndGggPD0gMSB8fCBhcmd1bWVudHNbMV0gPT09IHVuZGVmaW5lZCA/IHt9IDogYXJndW1lbnRzWzFdO1xuXG4gICAgICAgIC8vIFJlc3RvcmUgdGhlIHBhcnRpYWwtYmxvY2sgZnJvbSB0aGUgY2xvc3VyZSBmb3IgdGhlIGV4ZWN1dGlvbiBvZiB0aGUgYmxvY2tcbiAgICAgICAgLy8gaS5lLiB0aGUgcGFydCBpbnNpZGUgdGhlIGJsb2NrIG9mIHRoZSBwYXJ0aWFsIGNhbGwuXG4gICAgICAgIG9wdGlvbnMuZGF0YSA9IF9iYXNlLmNyZWF0ZUZyYW1lKG9wdGlvbnMuZGF0YSk7XG4gICAgICAgIG9wdGlvbnMuZGF0YVsncGFydGlhbC1ibG9jayddID0gY3VycmVudFBhcnRpYWxCbG9jaztcbiAgICAgICAgcmV0dXJuIGZuKGNvbnRleHQsIG9wdGlvbnMpO1xuICAgICAgfTtcbiAgICAgIGlmIChmbi5wYXJ0aWFscykge1xuICAgICAgICBvcHRpb25zLnBhcnRpYWxzID0gVXRpbHMuZXh0ZW5kKHt9LCBvcHRpb25zLnBhcnRpYWxzLCBmbi5wYXJ0aWFscyk7XG4gICAgICB9XG4gICAgfSkoKTtcbiAgfVxuXG4gIGlmIChwYXJ0aWFsID09PSB1bmRlZmluZWQgJiYgcGFydGlhbEJsb2NrKSB7XG4gICAgcGFydGlhbCA9IHBhcnRpYWxCbG9jaztcbiAgfVxuXG4gIGlmIChwYXJ0aWFsID09PSB1bmRlZmluZWQpIHtcbiAgICB0aHJvdyBuZXcgX2V4Y2VwdGlvbjJbJ2RlZmF1bHQnXSgnVGhlIHBhcnRpYWwgJyArIG9wdGlvbnMubmFtZSArICcgY291bGQgbm90IGJlIGZvdW5kJyk7XG4gIH0gZWxzZSBpZiAocGFydGlhbCBpbnN0YW5jZW9mIEZ1bmN0aW9uKSB7XG4gICAgcmV0dXJuIHBhcnRpYWwoY29udGV4dCwgb3B0aW9ucyk7XG4gIH1cbn1cblxuZnVuY3Rpb24gbm9vcCgpIHtcbiAgcmV0dXJuICcnO1xufVxuXG5mdW5jdGlvbiBpbml0RGF0YShjb250ZXh0LCBkYXRhKSB7XG4gIGlmICghZGF0YSB8fCAhKCdyb290JyBpbiBkYXRhKSkge1xuICAgIGRhdGEgPSBkYXRhID8gX2Jhc2UuY3JlYXRlRnJhbWUoZGF0YSkgOiB7fTtcbiAgICBkYXRhLnJvb3QgPSBjb250ZXh0O1xuICB9XG4gIHJldHVybiBkYXRhO1xufVxuXG5mdW5jdGlvbiBleGVjdXRlRGVjb3JhdG9ycyhmbiwgcHJvZywgY29udGFpbmVyLCBkZXB0aHMsIGRhdGEsIGJsb2NrUGFyYW1zKSB7XG4gIGlmIChmbi5kZWNvcmF0b3IpIHtcbiAgICB2YXIgcHJvcHMgPSB7fTtcbiAgICBwcm9nID0gZm4uZGVjb3JhdG9yKHByb2csIHByb3BzLCBjb250YWluZXIsIGRlcHRocyAmJiBkZXB0aHNbMF0sIGRhdGEsIGJsb2NrUGFyYW1zLCBkZXB0aHMpO1xuICAgIFV0aWxzLmV4dGVuZChwcm9nLCBwcm9wcyk7XG4gIH1cbiAgcmV0dXJuIHByb2c7XG59XG4vLyMgc291cmNlTWFwcGluZ1VSTD1kYXRhOmFwcGxpY2F0aW9uL2pzb247Y2hhcnNldD11dGYtODtiYXNlNjQsZXlKMlpYSnphVzl1SWpvekxDSnpiM1Z5WTJWeklqcGJJaTR1THk0dUx5NHVMMnhwWWk5b1lXNWtiR1ZpWVhKekwzSjFiblJwYldVdWFuTWlYU3dpYm1GdFpYTWlPbHRkTENKdFlYQndhVzVuY3lJNklqczdPenM3T3pzN096czdPenM3T3pzN2NVSkJRWFZDTEZOQlFWTTdPMGxCUVhCQ0xFdEJRVXM3TzNsQ1FVTkxMR0ZCUVdFN096czdiMEpCUXpoQ0xGRkJRVkU3TzBGQlJXeEZMRk5CUVZNc1lVRkJZU3hEUVVGRExGbEJRVmtzUlVGQlJUdEJRVU14UXl4TlFVRk5MR2RDUVVGblFpeEhRVUZITEZsQlFWa3NTVUZCU1N4WlFVRlpMRU5CUVVNc1EwRkJReXhEUVVGRExFbEJRVWtzUTBGQlF6dE5RVU4yUkN4bFFVRmxMREJDUVVGdlFpeERRVUZET3p0QlFVVXhReXhOUVVGSkxHZENRVUZuUWl4TFFVRkxMR1ZCUVdVc1JVRkJSVHRCUVVONFF5eFJRVUZKTEdkQ1FVRm5RaXhIUVVGSExHVkJRV1VzUlVGQlJUdEJRVU4wUXl4VlFVRk5MR1ZCUVdVc1IwRkJSeXgxUWtGQmFVSXNaVUZCWlN4RFFVRkRPMVZCUTI1RUxHZENRVUZuUWl4SFFVRkhMSFZDUVVGcFFpeG5Ra0ZCWjBJc1EwRkJReXhEUVVGRE8wRkJRelZFTEZsQlFVMHNNa0pCUVdNc2VVWkJRWGxHTEVkQlEzWkhMSEZFUVVGeFJDeEhRVUZITEdWQlFXVXNSMEZCUnl4dFJFRkJiVVFzUjBGQlJ5eG5Ra0ZCWjBJc1IwRkJSeXhKUVVGSkxFTkJRVU1zUTBGQlF6dExRVU5vU3l4TlFVRk5PenRCUVVWTUxGbEJRVTBzTWtKQlFXTXNkMFpCUVhkR0xFZEJRM1JITEdsRVFVRnBSQ3hIUVVGSExGbEJRVmtzUTBGQlF5eERRVUZETEVOQlFVTXNSMEZCUnl4SlFVRkpMRU5CUVVNc1EwRkJRenRMUVVOdVJqdEhRVU5HTzBOQlEwWTdPMEZCUlUwc1UwRkJVeXhSUVVGUkxFTkJRVU1zV1VGQldTeEZRVUZGTEVkQlFVY3NSVUZCUlRzN1FVRkZNVU1zVFVGQlNTeERRVUZETEVkQlFVY3NSVUZCUlR0QlFVTlNMRlZCUVUwc01rSkJRV01zYlVOQlFXMURMRU5CUVVNc1EwRkJRenRIUVVNeFJEdEJRVU5FTEUxQlFVa3NRMEZCUXl4WlFVRlpMRWxCUVVrc1EwRkJReXhaUVVGWkxFTkJRVU1zU1VGQlNTeEZRVUZGTzBGQlEzWkRMRlZCUVUwc01rSkJRV01zTWtKQlFUSkNMRWRCUVVjc1QwRkJUeXhaUVVGWkxFTkJRVU1zUTBGQlF6dEhRVU40UlRzN1FVRkZSQ3hqUVVGWkxFTkJRVU1zU1VGQlNTeERRVUZETEZOQlFWTXNSMEZCUnl4WlFVRlpMRU5CUVVNc1RVRkJUU3hEUVVGRE96czdPMEZCU1d4RUxFdEJRVWNzUTBGQlF5eEZRVUZGTEVOQlFVTXNZVUZCWVN4RFFVRkRMRmxCUVZrc1EwRkJReXhSUVVGUkxFTkJRVU1zUTBGQlF6czdRVUZGTlVNc1YwRkJVeXh2UWtGQmIwSXNRMEZCUXl4UFFVRlBMRVZCUVVVc1QwRkJUeXhGUVVGRkxFOUJRVThzUlVGQlJUdEJRVU4yUkN4UlFVRkpMRTlCUVU4c1EwRkJReXhKUVVGSkxFVkJRVVU3UVVGRGFFSXNZVUZCVHl4SFFVRkhMRXRCUVVzc1EwRkJReXhOUVVGTkxFTkJRVU1zUlVGQlJTeEZRVUZGTEU5QlFVOHNSVUZCUlN4UFFVRlBMRU5CUVVNc1NVRkJTU3hEUVVGRExFTkJRVU03UVVGRGJFUXNWVUZCU1N4UFFVRlBMRU5CUVVNc1IwRkJSeXhGUVVGRk8wRkJRMllzWlVGQlR5eERRVUZETEVkQlFVY3NRMEZCUXl4RFFVRkRMRU5CUVVNc1IwRkJSeXhKUVVGSkxFTkJRVU03VDBGRGRrSTdTMEZEUmpzN1FVRkZSQ3hYUVVGUExFZEJRVWNzUjBGQlJ5eERRVUZETEVWQlFVVXNRMEZCUXl4alFVRmpMRU5CUVVNc1NVRkJTU3hEUVVGRExFbEJRVWtzUlVGQlJTeFBRVUZQTEVWQlFVVXNUMEZCVHl4RlFVRkZMRTlCUVU4c1EwRkJReXhEUVVGRE8wRkJRM1JGTEZGQlFVa3NUVUZCVFN4SFFVRkhMRWRCUVVjc1EwRkJReXhGUVVGRkxFTkJRVU1zWVVGQllTeERRVUZETEVsQlFVa3NRMEZCUXl4SlFVRkpMRVZCUVVVc1QwRkJUeXhGUVVGRkxFOUJRVThzUlVGQlJTeFBRVUZQTEVOQlFVTXNRMEZCUXpzN1FVRkZlRVVzVVVGQlNTeE5RVUZOTEVsQlFVa3NTVUZCU1N4SlFVRkpMRWRCUVVjc1EwRkJReXhQUVVGUExFVkJRVVU3UVVGRGFrTXNZVUZCVHl4RFFVRkRMRkZCUVZFc1EwRkJReXhQUVVGUExFTkJRVU1zU1VGQlNTeERRVUZETEVkQlFVY3NSMEZCUnl4RFFVRkRMRTlCUVU4c1EwRkJReXhQUVVGUExFVkJRVVVzV1VGQldTeERRVUZETEdWQlFXVXNSVUZCUlN4SFFVRkhMRU5CUVVNc1EwRkJRenRCUVVONlJpeFpRVUZOTEVkQlFVY3NUMEZCVHl4RFFVRkRMRkZCUVZFc1EwRkJReXhQUVVGUExFTkJRVU1zU1VGQlNTeERRVUZETEVOQlFVTXNUMEZCVHl4RlFVRkZMRTlCUVU4c1EwRkJReXhEUVVGRE8wdEJRek5FTzBGQlEwUXNVVUZCU1N4TlFVRk5MRWxCUVVrc1NVRkJTU3hGUVVGRk8wRkJRMnhDTEZWQlFVa3NUMEZCVHl4RFFVRkRMRTFCUVUwc1JVRkJSVHRCUVVOc1FpeFpRVUZKTEV0QlFVc3NSMEZCUnl4TlFVRk5MRU5CUVVNc1MwRkJTeXhEUVVGRExFbEJRVWtzUTBGQlF5eERRVUZETzBGQlF5OUNMR0ZCUVVzc1NVRkJTU3hEUVVGRExFZEJRVWNzUTBGQlF5eEZRVUZGTEVOQlFVTXNSMEZCUnl4TFFVRkxMRU5CUVVNc1RVRkJUU3hGUVVGRkxFTkJRVU1zUjBGQlJ5eERRVUZETEVWQlFVVXNRMEZCUXl4RlFVRkZMRVZCUVVVN1FVRkROVU1zWTBGQlNTeERRVUZETEV0QlFVc3NRMEZCUXl4RFFVRkRMRU5CUVVNc1NVRkJTU3hEUVVGRExFZEJRVWNzUTBGQlF5eExRVUZMTEVOQlFVTXNSVUZCUlR0QlFVTTFRaXhyUWtGQlRUdFhRVU5RT3p0QlFVVkVMR1ZCUVVzc1EwRkJReXhEUVVGRExFTkJRVU1zUjBGQlJ5eFBRVUZQTEVOQlFVTXNUVUZCVFN4SFFVRkhMRXRCUVVzc1EwRkJReXhEUVVGRExFTkJRVU1zUTBGQlF6dFRRVU4wUXp0QlFVTkVMR05CUVUwc1IwRkJSeXhMUVVGTExFTkJRVU1zU1VGQlNTeERRVUZETEVsQlFVa3NRMEZCUXl4RFFVRkRPMDlCUXpOQ08wRkJRMFFzWVVGQlR5eE5RVUZOTEVOQlFVTTdTMEZEWml4TlFVRk5PMEZCUTB3c1dVRkJUU3d5UWtGQll5eGpRVUZqTEVkQlFVY3NUMEZCVHl4RFFVRkRMRWxCUVVrc1IwRkJSeXd3UkVGQk1FUXNRMEZCUXl4RFFVRkRPMHRCUTJwSU8wZEJRMFk3T3p0QlFVZEVMRTFCUVVrc1UwRkJVeXhIUVVGSE8wRkJRMlFzVlVGQlRTeEZRVUZGTEdkQ1FVRlRMRWRCUVVjc1JVRkJSU3hKUVVGSkxFVkJRVVU3UVVGRE1VSXNWVUZCU1N4RlFVRkZMRWxCUVVrc1NVRkJTU3hIUVVGSExFTkJRVUVzUVVGQlF5eEZRVUZGTzBGQlEyeENMR05CUVUwc01rSkJRV01zUjBGQlJ5eEhRVUZITEVsQlFVa3NSMEZCUnl4dFFrRkJiVUlzUjBGQlJ5eEhRVUZITEVOQlFVTXNRMEZCUXp0UFFVTTNSRHRCUVVORUxHRkJRVThzUjBGQlJ5eERRVUZETEVsQlFVa3NRMEZCUXl4RFFVRkRPMHRCUTJ4Q08wRkJRMFFzVlVGQlRTeEZRVUZGTEdkQ1FVRlRMRTFCUVUwc1JVRkJSU3hKUVVGSkxFVkJRVVU3UVVGRE4wSXNWVUZCVFN4SFFVRkhMRWRCUVVjc1RVRkJUU3hEUVVGRExFMUJRVTBzUTBGQlF6dEJRVU14UWl4WFFVRkxMRWxCUVVrc1EwRkJReXhIUVVGSExFTkJRVU1zUlVGQlJTeERRVUZETEVkQlFVY3NSMEZCUnl4RlFVRkZMRU5CUVVNc1JVRkJSU3hGUVVGRk8wRkJRelZDTEZsQlFVa3NUVUZCVFN4RFFVRkRMRU5CUVVNc1EwRkJReXhKUVVGSkxFMUJRVTBzUTBGQlF5eERRVUZETEVOQlFVTXNRMEZCUXl4SlFVRkpMRU5CUVVNc1NVRkJTU3hKUVVGSkxFVkJRVVU3UVVGRGVFTXNhVUpCUVU4c1RVRkJUU3hEUVVGRExFTkJRVU1zUTBGQlF5eERRVUZETEVsQlFVa3NRMEZCUXl4RFFVRkRPMU5CUTNoQ08wOUJRMFk3UzBGRFJqdEJRVU5FTEZWQlFVMHNSVUZCUlN4blFrRkJVeXhQUVVGUExFVkJRVVVzVDBGQlR5eEZRVUZGTzBGQlEycERMR0ZCUVU4c1QwRkJUeXhQUVVGUExFdEJRVXNzVlVGQlZTeEhRVUZITEU5QlFVOHNRMEZCUXl4SlFVRkpMRU5CUVVNc1QwRkJUeXhEUVVGRExFZEJRVWNzVDBGQlR5eERRVUZETzB0QlEzaEZPenRCUVVWRUxHOUNRVUZuUWl4RlFVRkZMRXRCUVVzc1EwRkJReXhuUWtGQlowSTdRVUZEZUVNc2FVSkJRV0VzUlVGQlJTeHZRa0ZCYjBJN08wRkJSVzVETEUxQlFVVXNSVUZCUlN4WlFVRlRMRU5CUVVNc1JVRkJSVHRCUVVOa0xGVkJRVWtzUjBGQlJ5eEhRVUZITEZsQlFWa3NRMEZCUXl4RFFVRkRMRU5CUVVNc1EwRkJRenRCUVVNeFFpeFRRVUZITEVOQlFVTXNVMEZCVXl4SFFVRkhMRmxCUVZrc1EwRkJReXhEUVVGRExFZEJRVWNzU1VGQlNTeERRVUZETEVOQlFVTTdRVUZEZGtNc1lVRkJUeXhIUVVGSExFTkJRVU03UzBGRFdqczdRVUZGUkN4WlFVRlJMRVZCUVVVc1JVRkJSVHRCUVVOYUxGZEJRVThzUlVGQlJTeHBRa0ZCVXl4RFFVRkRMRVZCUVVVc1NVRkJTU3hGUVVGRkxHMUNRVUZ0UWl4RlFVRkZMRmRCUVZjc1JVRkJSU3hOUVVGTkxFVkJRVVU3UVVGRGJrVXNWVUZCU1N4alFVRmpMRWRCUVVjc1NVRkJTU3hEUVVGRExGRkJRVkVzUTBGQlF5eERRVUZETEVOQlFVTTdWVUZEYWtNc1JVRkJSU3hIUVVGSExFbEJRVWtzUTBGQlF5eEZRVUZGTEVOQlFVTXNRMEZCUXl4RFFVRkRMRU5CUVVNN1FVRkRjRUlzVlVGQlNTeEpRVUZKTEVsQlFVa3NUVUZCVFN4SlFVRkpMRmRCUVZjc1NVRkJTU3h0UWtGQmJVSXNSVUZCUlR0QlFVTjRSQ3h6UWtGQll5eEhRVUZITEZkQlFWY3NRMEZCUXl4SlFVRkpMRVZCUVVVc1EwRkJReXhGUVVGRkxFVkJRVVVzUlVGQlJTeEpRVUZKTEVWQlFVVXNiVUpCUVcxQ0xFVkJRVVVzVjBGQlZ5eEZRVUZGTEUxQlFVMHNRMEZCUXl4RFFVRkRPMDlCUXpOR0xFMUJRVTBzU1VGQlNTeERRVUZETEdOQlFXTXNSVUZCUlR0QlFVTXhRaXh6UWtGQll5eEhRVUZITEVsQlFVa3NRMEZCUXl4UlFVRlJMRU5CUVVNc1EwRkJReXhEUVVGRExFZEJRVWNzVjBGQlZ5eERRVUZETEVsQlFVa3NSVUZCUlN4RFFVRkRMRVZCUVVVc1JVRkJSU3hEUVVGRExFTkJRVU03VDBGRE9VUTdRVUZEUkN4aFFVRlBMR05CUVdNc1EwRkJRenRMUVVOMlFqczdRVUZGUkN4UlFVRkpMRVZCUVVVc1kwRkJVeXhMUVVGTExFVkJRVVVzUzBGQlN5eEZRVUZGTzBGQlF6TkNMR0ZCUVU4c1MwRkJTeXhKUVVGSkxFdEJRVXNzUlVGQlJTeEZRVUZGTzBGQlEzWkNMR0ZCUVVzc1IwRkJSeXhMUVVGTExFTkJRVU1zVDBGQlR5eERRVUZETzA5QlEzWkNPMEZCUTBRc1lVRkJUeXhMUVVGTExFTkJRVU03UzBGRFpEdEJRVU5FTEZOQlFVc3NSVUZCUlN4bFFVRlRMRXRCUVVzc1JVRkJSU3hOUVVGTkxFVkJRVVU3UVVGRE4wSXNWVUZCU1N4SFFVRkhMRWRCUVVjc1MwRkJTeXhKUVVGSkxFMUJRVTBzUTBGQlF6czdRVUZGTVVJc1ZVRkJTU3hMUVVGTExFbEJRVWtzVFVGQlRTeEpRVUZMTEV0QlFVc3NTMEZCU3l4TlFVRk5MRUZCUVVNc1JVRkJSVHRCUVVONlF5eFhRVUZITEVkQlFVY3NTMEZCU3l4RFFVRkRMRTFCUVUwc1EwRkJReXhGUVVGRkxFVkJRVVVzVFVGQlRTeEZRVUZGTEV0QlFVc3NRMEZCUXl4RFFVRkRPMDlCUTNaRE96dEJRVVZFTEdGQlFVOHNSMEZCUnl4RFFVRkRPMHRCUTFvN08wRkJSVVFzWlVGQlZ5eEZRVUZGTEUxQlFVMHNRMEZCUXl4SlFVRkpMRU5CUVVNc1JVRkJSU3hEUVVGRE96dEJRVVUxUWl4UlFVRkpMRVZCUVVVc1IwRkJSeXhEUVVGRExFVkJRVVVzUTBGQlF5eEpRVUZKTzBGQlEycENMR2RDUVVGWkxFVkJRVVVzV1VGQldTeERRVUZETEZGQlFWRTdSMEZEY0VNc1EwRkJRenM3UVVGRlJpeFhRVUZUTEVkQlFVY3NRMEZCUXl4UFFVRlBMRVZCUVdkQ08xRkJRV1FzVDBGQlR5eDVSRUZCUnl4RlFVRkZPenRCUVVOb1F5eFJRVUZKTEVsQlFVa3NSMEZCUnl4UFFVRlBMRU5CUVVNc1NVRkJTU3hEUVVGRE96dEJRVVY0UWl4UFFVRkhMRU5CUVVNc1RVRkJUU3hEUVVGRExFOUJRVThzUTBGQlF5eERRVUZETzBGQlEzQkNMRkZCUVVrc1EwRkJReXhQUVVGUExFTkJRVU1zVDBGQlR5eEpRVUZKTEZsQlFWa3NRMEZCUXl4UFFVRlBMRVZCUVVVN1FVRkROVU1zVlVGQlNTeEhRVUZITEZGQlFWRXNRMEZCUXl4UFFVRlBMRVZCUVVVc1NVRkJTU3hEUVVGRExFTkJRVU03UzBGRGFFTTdRVUZEUkN4UlFVRkpMRTFCUVUwc1dVRkJRVHRSUVVOT0xGZEJRVmNzUjBGQlJ5eFpRVUZaTEVOQlFVTXNZMEZCWXl4SFFVRkhMRVZCUVVVc1IwRkJSeXhUUVVGVExFTkJRVU03UVVGREwwUXNVVUZCU1N4WlFVRlpMRU5CUVVNc1UwRkJVeXhGUVVGRk8wRkJRekZDTEZWQlFVa3NUMEZCVHl4RFFVRkRMRTFCUVUwc1JVRkJSVHRCUVVOc1FpeGpRVUZOTEVkQlFVY3NUMEZCVHl4SlFVRkpMRTlCUVU4c1EwRkJReXhOUVVGTkxFTkJRVU1zUTBGQlF5eERRVUZETEVkQlFVY3NRMEZCUXl4UFFVRlBMRU5CUVVNc1EwRkJReXhOUVVGTkxFTkJRVU1zVDBGQlR5eERRVUZETEUxQlFVMHNRMEZCUXl4SFFVRkhMRTlCUVU4c1EwRkJReXhOUVVGTkxFTkJRVU03VDBGRE0wWXNUVUZCVFR0QlFVTk1MR05CUVUwc1IwRkJSeXhEUVVGRExFOUJRVThzUTBGQlF5eERRVUZETzA5QlEzQkNPMHRCUTBZN08wRkJSVVFzWVVGQlV5eEpRVUZKTEVOQlFVTXNUMEZCVHl4blFrRkJaVHRCUVVOc1F5eGhRVUZQTEVWQlFVVXNSMEZCUnl4WlFVRlpMRU5CUVVNc1NVRkJTU3hEUVVGRExGTkJRVk1zUlVGQlJTeFBRVUZQTEVWQlFVVXNVMEZCVXl4RFFVRkRMRTlCUVU4c1JVRkJSU3hUUVVGVExFTkJRVU1zVVVGQlVTeEZRVUZGTEVsQlFVa3NSVUZCUlN4WFFVRlhMRVZCUVVVc1RVRkJUU3hEUVVGRExFTkJRVU03UzBGRGNrZzdRVUZEUkN4UlFVRkpMRWRCUVVjc2FVSkJRV2xDTEVOQlFVTXNXVUZCV1N4RFFVRkRMRWxCUVVrc1JVRkJSU3hKUVVGSkxFVkJRVVVzVTBGQlV5eEZRVUZGTEU5QlFVOHNRMEZCUXl4TlFVRk5MRWxCUVVrc1JVRkJSU3hGUVVGRkxFbEJRVWtzUlVGQlJTeFhRVUZYTEVOQlFVTXNRMEZCUXp0QlFVTjBSeXhYUVVGUExFbEJRVWtzUTBGQlF5eFBRVUZQTEVWQlFVVXNUMEZCVHl4RFFVRkRMRU5CUVVNN1IwRkRMMEk3UVVGRFJDeExRVUZITEVOQlFVTXNTMEZCU3l4SFFVRkhMRWxCUVVrc1EwRkJRenM3UVVGRmFrSXNTMEZCUnl4RFFVRkRMRTFCUVUwc1IwRkJSeXhWUVVGVExFOUJRVThzUlVGQlJUdEJRVU0zUWl4UlFVRkpMRU5CUVVNc1QwRkJUeXhEUVVGRExFOUJRVThzUlVGQlJUdEJRVU53UWl4bFFVRlRMRU5CUVVNc1QwRkJUeXhIUVVGSExGTkJRVk1zUTBGQlF5eExRVUZMTEVOQlFVTXNUMEZCVHl4RFFVRkRMRTlCUVU4c1JVRkJSU3hIUVVGSExFTkJRVU1zVDBGQlR5eERRVUZETEVOQlFVTTdPMEZCUld4RkxGVkJRVWtzV1VGQldTeERRVUZETEZWQlFWVXNSVUZCUlR0QlFVTXpRaXhwUWtGQlV5eERRVUZETEZGQlFWRXNSMEZCUnl4VFFVRlRMRU5CUVVNc1MwRkJTeXhEUVVGRExFOUJRVThzUTBGQlF5eFJRVUZSTEVWQlFVVXNSMEZCUnl4RFFVRkRMRkZCUVZFc1EwRkJReXhEUVVGRE8wOUJRM1JGTzBGQlEwUXNWVUZCU1N4WlFVRlpMRU5CUVVNc1ZVRkJWU3hKUVVGSkxGbEJRVmtzUTBGQlF5eGhRVUZoTEVWQlFVVTdRVUZEZWtRc2FVSkJRVk1zUTBGQlF5eFZRVUZWTEVkQlFVY3NVMEZCVXl4RFFVRkRMRXRCUVVzc1EwRkJReXhQUVVGUExFTkJRVU1zVlVGQlZTeEZRVUZGTEVkQlFVY3NRMEZCUXl4VlFVRlZMRU5CUVVNc1EwRkJRenRQUVVNMVJUdExRVU5HTEUxQlFVMDdRVUZEVEN4bFFVRlRMRU5CUVVNc1QwRkJUeXhIUVVGSExFOUJRVThzUTBGQlF5eFBRVUZQTEVOQlFVTTdRVUZEY0VNc1pVRkJVeXhEUVVGRExGRkJRVkVzUjBGQlJ5eFBRVUZQTEVOQlFVTXNVVUZCVVN4RFFVRkRPMEZCUTNSRExHVkJRVk1zUTBGQlF5eFZRVUZWTEVkQlFVY3NUMEZCVHl4RFFVRkRMRlZCUVZVc1EwRkJRenRMUVVNelF6dEhRVU5HTEVOQlFVTTdPMEZCUlVZc1MwRkJSeXhEUVVGRExFMUJRVTBzUjBGQlJ5eFZRVUZUTEVOQlFVTXNSVUZCUlN4SlFVRkpMRVZCUVVVc1YwRkJWeXhGUVVGRkxFMUJRVTBzUlVGQlJUdEJRVU5zUkN4UlFVRkpMRmxCUVZrc1EwRkJReXhqUVVGakxFbEJRVWtzUTBGQlF5eFhRVUZYTEVWQlFVVTdRVUZETDBNc1dVRkJUU3d5UWtGQll5eDNRa0ZCZDBJc1EwRkJReXhEUVVGRE8wdEJReTlETzBGQlEwUXNVVUZCU1N4WlFVRlpMRU5CUVVNc1UwRkJVeXhKUVVGSkxFTkJRVU1zVFVGQlRTeEZRVUZGTzBGQlEzSkRMRmxCUVUwc01rSkJRV01zZVVKQlFYbENMRU5CUVVNc1EwRkJRenRMUVVOb1JEczdRVUZGUkN4WFFVRlBMRmRCUVZjc1EwRkJReXhUUVVGVExFVkJRVVVzUTBGQlF5eEZRVUZGTEZsQlFWa3NRMEZCUXl4RFFVRkRMRU5CUVVNc1JVRkJSU3hKUVVGSkxFVkJRVVVzUTBGQlF5eEZRVUZGTEZkQlFWY3NSVUZCUlN4TlFVRk5MRU5CUVVNc1EwRkJRenRIUVVOcVJpeERRVUZETzBGQlEwWXNVMEZCVHl4SFFVRkhMRU5CUVVNN1EwRkRXanM3UVVGRlRTeFRRVUZUTEZkQlFWY3NRMEZCUXl4VFFVRlRMRVZCUVVVc1EwRkJReXhGUVVGRkxFVkJRVVVzUlVGQlJTeEpRVUZKTEVWQlFVVXNiVUpCUVcxQ0xFVkJRVVVzVjBGQlZ5eEZRVUZGTEUxQlFVMHNSVUZCUlR0QlFVTTFSaXhYUVVGVExFbEJRVWtzUTBGQlF5eFBRVUZQTEVWQlFXZENPMUZCUVdRc1QwRkJUeXg1UkVGQlJ5eEZRVUZGT3p0QlFVTnFReXhSUVVGSkxHRkJRV0VzUjBGQlJ5eE5RVUZOTEVOQlFVTTdRVUZETTBJc1VVRkJTU3hOUVVGTkxFbEJRVWtzVDBGQlR5eEpRVUZKTEUxQlFVMHNRMEZCUXl4RFFVRkRMRU5CUVVNc1NVRkJTU3hGUVVGRkxFOUJRVThzUzBGQlN5eFRRVUZUTEVOQlFVTXNWMEZCVnl4SlFVRkpMRTFCUVUwc1EwRkJReXhEUVVGRExFTkJRVU1zUzBGQlN5eEpRVUZKTEVOQlFVRXNRVUZCUXl4RlFVRkZPMEZCUTJoSExHMUNRVUZoTEVkQlFVY3NRMEZCUXl4UFFVRlBMRU5CUVVNc1EwRkJReXhOUVVGTkxFTkJRVU1zVFVGQlRTeERRVUZETEVOQlFVTTdTMEZETVVNN08wRkJSVVFzVjBGQlR5eEZRVUZGTEVOQlFVTXNVMEZCVXl4RlFVTm1MRTlCUVU4c1JVRkRVQ3hUUVVGVExFTkJRVU1zVDBGQlR5eEZRVUZGTEZOQlFWTXNRMEZCUXl4UlFVRlJMRVZCUTNKRExFOUJRVThzUTBGQlF5eEpRVUZKTEVsQlFVa3NTVUZCU1N4RlFVTndRaXhYUVVGWExFbEJRVWtzUTBGQlF5eFBRVUZQTEVOQlFVTXNWMEZCVnl4RFFVRkRMRU5CUVVNc1RVRkJUU3hEUVVGRExGZEJRVmNzUTBGQlF5eEZRVU40UkN4aFFVRmhMRU5CUVVNc1EwRkJRenRIUVVOd1FqczdRVUZGUkN4TlFVRkpMRWRCUVVjc2FVSkJRV2xDTEVOQlFVTXNSVUZCUlN4RlFVRkZMRWxCUVVrc1JVRkJSU3hUUVVGVExFVkJRVVVzVFVGQlRTeEZRVUZGTEVsQlFVa3NSVUZCUlN4WFFVRlhMRU5CUVVNc1EwRkJRenM3UVVGRmVrVXNUVUZCU1N4RFFVRkRMRTlCUVU4c1IwRkJSeXhEUVVGRExFTkJRVU03UVVGRGFrSXNUVUZCU1N4RFFVRkRMRXRCUVVzc1IwRkJSeXhOUVVGTkxFZEJRVWNzVFVGQlRTeERRVUZETEUxQlFVMHNSMEZCUnl4RFFVRkRMRU5CUVVNN1FVRkRlRU1zVFVGQlNTeERRVUZETEZkQlFWY3NSMEZCUnl4dFFrRkJiVUlzU1VGQlNTeERRVUZETEVOQlFVTTdRVUZETlVNc1UwRkJUeXhKUVVGSkxFTkJRVU03UTBGRFlqczdRVUZGVFN4VFFVRlRMR05CUVdNc1EwRkJReXhQUVVGUExFVkJRVVVzVDBGQlR5eEZRVUZGTEU5QlFVOHNSVUZCUlR0QlFVTjRSQ3hOUVVGSkxFTkJRVU1zVDBGQlR5eEZRVUZGTzBGQlExb3NVVUZCU1N4UFFVRlBMRU5CUVVNc1NVRkJTU3hMUVVGTExHZENRVUZuUWl4RlFVRkZPMEZCUTNKRExHRkJRVThzUjBGQlJ5eFBRVUZQTEVOQlFVTXNTVUZCU1N4RFFVRkRMR1ZCUVdVc1EwRkJReXhEUVVGRE8wdEJRM3BETEUxQlFVMDdRVUZEVEN4aFFVRlBMRWRCUVVjc1QwRkJUeXhEUVVGRExGRkJRVkVzUTBGQlF5eFBRVUZQTEVOQlFVTXNTVUZCU1N4RFFVRkRMRU5CUVVNN1MwRkRNVU03UjBGRFJpeE5RVUZOTEVsQlFVa3NRMEZCUXl4UFFVRlBMRU5CUVVNc1NVRkJTU3hKUVVGSkxFTkJRVU1zVDBGQlR5eERRVUZETEVsQlFVa3NSVUZCUlRzN1FVRkZla01zVjBGQlR5eERRVUZETEVsQlFVa3NSMEZCUnl4UFFVRlBMRU5CUVVNN1FVRkRka0lzVjBGQlR5eEhRVUZITEU5QlFVOHNRMEZCUXl4UlFVRlJMRU5CUVVNc1QwRkJUeXhEUVVGRExFTkJRVU03UjBGRGNrTTdRVUZEUkN4VFFVRlBMRTlCUVU4c1EwRkJRenREUVVOb1FqczdRVUZGVFN4VFFVRlRMR0ZCUVdFc1EwRkJReXhQUVVGUExFVkJRVVVzVDBGQlR5eEZRVUZGTEU5QlFVOHNSVUZCUlRzN1FVRkZka1FzVFVGQlRTeHRRa0ZCYlVJc1IwRkJSeXhQUVVGUExFTkJRVU1zU1VGQlNTeEpRVUZKTEU5QlFVOHNRMEZCUXl4SlFVRkpMRU5CUVVNc1pVRkJaU3hEUVVGRExFTkJRVU03UVVGRE1VVXNVMEZCVHl4RFFVRkRMRTlCUVU4c1IwRkJSeXhKUVVGSkxFTkJRVU03UVVGRGRrSXNUVUZCU1N4UFFVRlBMRU5CUVVNc1IwRkJSeXhGUVVGRk8wRkJRMllzVjBGQlR5eERRVUZETEVsQlFVa3NRMEZCUXl4WFFVRlhMRWRCUVVjc1QwRkJUeXhEUVVGRExFZEJRVWNzUTBGQlF5eERRVUZETEVOQlFVTXNTVUZCU1N4UFFVRlBMRU5CUVVNc1NVRkJTU3hEUVVGRExGZEJRVmNzUTBGQlF6dEhRVU4yUlRzN1FVRkZSQ3hOUVVGSkxGbEJRVmtzV1VGQlFTeERRVUZETzBGQlEycENMRTFCUVVrc1QwRkJUeXhEUVVGRExFVkJRVVVzU1VGQlNTeFBRVUZQTEVOQlFVTXNSVUZCUlN4TFFVRkxMRWxCUVVrc1JVRkJSVHM3UVVGRGNrTXNZVUZCVHl4RFFVRkRMRWxCUVVrc1IwRkJSeXhyUWtGQldTeFBRVUZQTEVOQlFVTXNTVUZCU1N4RFFVRkRMRU5CUVVNN08wRkJSWHBETEZWQlFVa3NSVUZCUlN4SFFVRkhMRTlCUVU4c1EwRkJReXhGUVVGRkxFTkJRVU03UVVGRGNFSXNhMEpCUVZrc1IwRkJSeXhQUVVGUExFTkJRVU1zU1VGQlNTeERRVUZETEdWQlFXVXNRMEZCUXl4SFFVRkhMRk5CUVZNc2JVSkJRVzFDTEVOQlFVTXNUMEZCVHl4RlFVRm5RanRaUVVGa0xFOUJRVThzZVVSQlFVY3NSVUZCUlRzN096dEJRVWt2Uml4bFFVRlBMRU5CUVVNc1NVRkJTU3hIUVVGSExHdENRVUZaTEU5QlFVOHNRMEZCUXl4SlFVRkpMRU5CUVVNc1EwRkJRenRCUVVONlF5eGxRVUZQTEVOQlFVTXNTVUZCU1N4RFFVRkRMR1ZCUVdVc1EwRkJReXhIUVVGSExHMUNRVUZ0UWl4RFFVRkRPMEZCUTNCRUxHVkJRVThzUlVGQlJTeERRVUZETEU5QlFVOHNSVUZCUlN4UFFVRlBMRU5CUVVNc1EwRkJRenRQUVVNM1FpeERRVUZETzBGQlEwWXNWVUZCU1N4RlFVRkZMRU5CUVVNc1VVRkJVU3hGUVVGRk8wRkJRMllzWlVGQlR5eERRVUZETEZGQlFWRXNSMEZCUnl4TFFVRkxMRU5CUVVNc1RVRkJUU3hEUVVGRExFVkJRVVVzUlVGQlJTeFBRVUZQTEVOQlFVTXNVVUZCVVN4RlFVRkZMRVZCUVVVc1EwRkJReXhSUVVGUkxFTkJRVU1zUTBGQlF6dFBRVU53UlRzN1IwRkRSanM3UVVGRlJDeE5RVUZKTEU5QlFVOHNTMEZCU3l4VFFVRlRMRWxCUVVrc1dVRkJXU3hGUVVGRk8wRkJRM3BETEZkQlFVOHNSMEZCUnl4WlFVRlpMRU5CUVVNN1IwRkRlRUk3TzBGQlJVUXNUVUZCU1N4UFFVRlBMRXRCUVVzc1UwRkJVeXhGUVVGRk8wRkJRM3BDTEZWQlFVMHNNa0pCUVdNc1kwRkJZeXhIUVVGSExFOUJRVThzUTBGQlF5eEpRVUZKTEVkQlFVY3NjVUpCUVhGQ0xFTkJRVU1zUTBGQlF6dEhRVU0xUlN4TlFVRk5MRWxCUVVrc1QwRkJUeXhaUVVGWkxGRkJRVkVzUlVGQlJUdEJRVU4wUXl4WFFVRlBMRTlCUVU4c1EwRkJReXhQUVVGUExFVkJRVVVzVDBGQlR5eERRVUZETEVOQlFVTTdSMEZEYkVNN1EwRkRSanM3UVVGRlRTeFRRVUZUTEVsQlFVa3NSMEZCUnp0QlFVRkZMRk5CUVU4c1JVRkJSU3hEUVVGRE8wTkJRVVU3TzBGQlJYSkRMRk5CUVZNc1VVRkJVU3hEUVVGRExFOUJRVThzUlVGQlJTeEpRVUZKTEVWQlFVVTdRVUZETDBJc1RVRkJTU3hEUVVGRExFbEJRVWtzU1VGQlNTeEZRVUZGTEUxQlFVMHNTVUZCU1N4SlFVRkpMRU5CUVVFc1FVRkJReXhGUVVGRk8wRkJRemxDTEZGQlFVa3NSMEZCUnl4SlFVRkpMRWRCUVVjc2EwSkJRVmtzU1VGQlNTeERRVUZETEVkQlFVY3NSVUZCUlN4RFFVRkRPMEZCUTNKRExGRkJRVWtzUTBGQlF5eEpRVUZKTEVkQlFVY3NUMEZCVHl4RFFVRkRPMGRCUTNKQ08wRkJRMFFzVTBGQlR5eEpRVUZKTEVOQlFVTTdRMEZEWWpzN1FVRkZSQ3hUUVVGVExHbENRVUZwUWl4RFFVRkRMRVZCUVVVc1JVRkJSU3hKUVVGSkxFVkJRVVVzVTBGQlV5eEZRVUZGTEUxQlFVMHNSVUZCUlN4SlFVRkpMRVZCUVVVc1YwRkJWeXhGUVVGRk8wRkJRM3BGTEUxQlFVa3NSVUZCUlN4RFFVRkRMRk5CUVZNc1JVRkJSVHRCUVVOb1FpeFJRVUZKTEV0QlFVc3NSMEZCUnl4RlFVRkZMRU5CUVVNN1FVRkRaaXhSUVVGSkxFZEJRVWNzUlVGQlJTeERRVUZETEZOQlFWTXNRMEZCUXl4SlFVRkpMRVZCUVVVc1MwRkJTeXhGUVVGRkxGTkJRVk1zUlVGQlJTeE5RVUZOTEVsQlFVa3NUVUZCVFN4RFFVRkRMRU5CUVVNc1EwRkJReXhGUVVGRkxFbEJRVWtzUlVGQlJTeFhRVUZYTEVWQlFVVXNUVUZCVFN4RFFVRkRMRU5CUVVNN1FVRkROVVlzVTBGQlN5eERRVUZETEUxQlFVMHNRMEZCUXl4SlFVRkpMRVZCUVVVc1MwRkJTeXhEUVVGRExFTkJRVU03UjBGRE0wSTdRVUZEUkN4VFFVRlBMRWxCUVVrc1EwRkJRenREUVVOaUlpd2labWxzWlNJNkluSjFiblJwYldVdWFuTWlMQ0p6YjNWeVkyVnpRMjl1ZEdWdWRDSTZXeUpwYlhCdmNuUWdLaUJoY3lCVmRHbHNjeUJtY205dElDY3VMM1YwYVd4ekp6dGNibWx0Y0c5eWRDQkZlR05sY0hScGIyNGdabkp2YlNBbkxpOWxlR05sY0hScGIyNG5PMXh1YVcxd2IzSjBJSHNnUTA5TlVFbE1SVkpmVWtWV1NWTkpUMDRzSUZKRlZrbFRTVTlPWDBOSVFVNUhSVk1zSUdOeVpXRjBaVVp5WVcxbElIMGdabkp2YlNBbkxpOWlZWE5sSnp0Y2JseHVaWGh3YjNKMElHWjFibU4wYVc5dUlHTm9aV05yVW1WMmFYTnBiMjRvWTI5dGNHbHNaWEpKYm1adktTQjdYRzRnSUdOdmJuTjBJR052YlhCcGJHVnlVbVYyYVhOcGIyNGdQU0JqYjIxd2FXeGxja2x1Wm04Z0ppWWdZMjl0Y0dsc1pYSkpibVp2V3pCZElIeDhJREVzWEc0Z0lDQWdJQ0FnSUdOMWNuSmxiblJTWlhacGMybHZiaUE5SUVOUFRWQkpURVZTWDFKRlZrbFRTVTlPTzF4dVhHNGdJR2xtSUNoamIyMXdhV3hsY2xKbGRtbHphVzl1SUNFOVBTQmpkWEp5Wlc1MFVtVjJhWE5wYjI0cElIdGNiaUFnSUNCcFppQW9ZMjl0Y0dsc1pYSlNaWFpwYzJsdmJpQThJR04xY25KbGJuUlNaWFpwYzJsdmJpa2dlMXh1SUNBZ0lDQWdZMjl1YzNRZ2NuVnVkR2x0WlZabGNuTnBiMjV6SUQwZ1VrVldTVk5KVDA1ZlEwaEJUa2RGVTF0amRYSnlaVzUwVW1WMmFYTnBiMjVkTEZ4dUlDQWdJQ0FnSUNBZ0lDQWdZMjl0Y0dsc1pYSldaWEp6YVc5dWN5QTlJRkpGVmtsVFNVOU9YME5JUVU1SFJWTmJZMjl0Y0dsc1pYSlNaWFpwYzJsdmJsMDdYRzRnSUNBZ0lDQjBhSEp2ZHlCdVpYY2dSWGhqWlhCMGFXOXVLQ2RVWlcxd2JHRjBaU0IzWVhNZ2NISmxZMjl0Y0dsc1pXUWdkMmwwYUNCaGJpQnZiR1JsY2lCMlpYSnphVzl1SUc5bUlFaGhibVJzWldKaGNuTWdkR2hoYmlCMGFHVWdZM1Z5Y21WdWRDQnlkVzUwYVcxbExpQW5JQ3RjYmlBZ0lDQWdJQ0FnSUNBZ0lDZFFiR1ZoYzJVZ2RYQmtZWFJsSUhsdmRYSWdjSEpsWTI5dGNHbHNaWElnZEc4Z1lTQnVaWGRsY2lCMlpYSnphVzl1SUNnbklDc2djblZ1ZEdsdFpWWmxjbk5wYjI1eklDc2dKeWtnYjNJZ1pHOTNibWR5WVdSbElIbHZkWElnY25WdWRHbHRaU0IwYnlCaGJpQnZiR1JsY2lCMlpYSnphVzl1SUNnbklDc2dZMjl0Y0dsc1pYSldaWEp6YVc5dWN5QXJJQ2NwTGljcE8xeHVJQ0FnSUgwZ1pXeHpaU0I3WEc0Z0lDQWdJQ0F2THlCVmMyVWdkR2hsSUdWdFltVmtaR1ZrSUhabGNuTnBiMjRnYVc1bWJ5QnphVzVqWlNCMGFHVWdjblZ1ZEdsdFpTQmtiMlZ6YmlkMElHdHViM2NnWVdKdmRYUWdkR2hwY3lCeVpYWnBjMmx2YmlCNVpYUmNiaUFnSUNBZ0lIUm9jbTkzSUc1bGR5QkZlR05sY0hScGIyNG9KMVJsYlhCc1lYUmxJSGRoY3lCd2NtVmpiMjF3YVd4bFpDQjNhWFJvSUdFZ2JtVjNaWElnZG1WeWMybHZiaUJ2WmlCSVlXNWtiR1ZpWVhKeklIUm9ZVzRnZEdobElHTjFjbkpsYm5RZ2NuVnVkR2x0WlM0Z0p5QXJYRzRnSUNBZ0lDQWdJQ0FnSUNBblVHeGxZWE5sSUhWd1pHRjBaU0I1YjNWeUlISjFiblJwYldVZ2RHOGdZU0J1WlhkbGNpQjJaWEp6YVc5dUlDZ25JQ3NnWTI5dGNHbHNaWEpKYm1adld6RmRJQ3NnSnlrdUp5azdYRzRnSUNBZ2ZWeHVJQ0I5WEc1OVhHNWNibVY0Y0c5eWRDQm1kVzVqZEdsdmJpQjBaVzF3YkdGMFpTaDBaVzF3YkdGMFpWTndaV01zSUdWdWRpa2dlMXh1SUNBdktpQnBjM1JoYm1KMWJDQnBaMjV2Y21VZ2JtVjRkQ0FxTDF4dUlDQnBaaUFvSVdWdWRpa2dlMXh1SUNBZ0lIUm9jbTkzSUc1bGR5QkZlR05sY0hScGIyNG9KMDV2SUdWdWRtbHliMjV0Wlc1MElIQmhjM05sWkNCMGJ5QjBaVzF3YkdGMFpTY3BPMXh1SUNCOVhHNGdJR2xtSUNnaGRHVnRjR3hoZEdWVGNHVmpJSHg4SUNGMFpXMXdiR0YwWlZOd1pXTXViV0ZwYmlrZ2UxeHVJQ0FnSUhSb2NtOTNJRzVsZHlCRmVHTmxjSFJwYjI0b0oxVnVhMjV2ZDI0Z2RHVnRjR3hoZEdVZ2IySnFaV04wT2lBbklDc2dkSGx3Wlc5bUlIUmxiWEJzWVhSbFUzQmxZeWs3WEc0Z0lIMWNibHh1SUNCMFpXMXdiR0YwWlZOd1pXTXViV0ZwYmk1a1pXTnZjbUYwYjNJZ1BTQjBaVzF3YkdGMFpWTndaV011YldGcGJsOWtPMXh1WEc0Z0lDOHZJRTV2ZEdVNklGVnphVzVuSUdWdWRpNVdUU0J5WldabGNtVnVZMlZ6SUhKaGRHaGxjaUIwYUdGdUlHeHZZMkZzSUhaaGNpQnlaV1psY21WdVkyVnpJSFJvY205MVoyaHZkWFFnZEdocGN5QnpaV04wYVc5dUlIUnZJR0ZzYkc5M1hHNGdJQzh2SUdadmNpQmxlSFJsY201aGJDQjFjMlZ5Y3lCMGJ5QnZkbVZ5Y21sa1pTQjBhR1Z6WlNCaGN5QndjM1ZsWkc4dGMzVndjRzl5ZEdWa0lFRlFTWE11WEc0Z0lHVnVkaTVXVFM1amFHVmphMUpsZG1semFXOXVLSFJsYlhCc1lYUmxVM0JsWXk1amIyMXdhV3hsY2lrN1hHNWNiaUFnWm5WdVkzUnBiMjRnYVc1MmIydGxVR0Z5ZEdsaGJGZHlZWEJ3WlhJb2NHRnlkR2xoYkN3Z1kyOXVkR1Y0ZEN3Z2IzQjBhVzl1Y3lrZ2UxeHVJQ0FnSUdsbUlDaHZjSFJwYjI1ekxtaGhjMmdwSUh0Y2JpQWdJQ0FnSUdOdmJuUmxlSFFnUFNCVmRHbHNjeTVsZUhSbGJtUW9lMzBzSUdOdmJuUmxlSFFzSUc5d2RHbHZibk11YUdGemFDazdYRzRnSUNBZ0lDQnBaaUFvYjNCMGFXOXVjeTVwWkhNcElIdGNiaUFnSUNBZ0lDQWdiM0IwYVc5dWN5NXBaSE5iTUYwZ1BTQjBjblZsTzF4dUlDQWdJQ0FnZlZ4dUlDQWdJSDFjYmx4dUlDQWdJSEJoY25ScFlXd2dQU0JsYm5ZdVZrMHVjbVZ6YjJ4MlpWQmhjblJwWVd3dVkyRnNiQ2gwYUdsekxDQndZWEowYVdGc0xDQmpiMjUwWlhoMExDQnZjSFJwYjI1ektUdGNiaUFnSUNCc1pYUWdjbVZ6ZFd4MElEMGdaVzUyTGxaTkxtbHVkbTlyWlZCaGNuUnBZV3d1WTJGc2JDaDBhR2x6TENCd1lYSjBhV0ZzTENCamIyNTBaWGgwTENCdmNIUnBiMjV6S1R0Y2JseHVJQ0FnSUdsbUlDaHlaWE4xYkhRZ1BUMGdiblZzYkNBbUppQmxibll1WTI5dGNHbHNaU2tnZTF4dUlDQWdJQ0FnYjNCMGFXOXVjeTV3WVhKMGFXRnNjMXR2Y0hScGIyNXpMbTVoYldWZElEMGdaVzUyTG1OdmJYQnBiR1VvY0dGeWRHbGhiQ3dnZEdWdGNHeGhkR1ZUY0dWakxtTnZiWEJwYkdWeVQzQjBhVzl1Y3l3Z1pXNTJLVHRjYmlBZ0lDQWdJSEpsYzNWc2RDQTlJRzl3ZEdsdmJuTXVjR0Z5ZEdsaGJITmJiM0IwYVc5dWN5NXVZVzFsWFNoamIyNTBaWGgwTENCdmNIUnBiMjV6S1R0Y2JpQWdJQ0I5WEc0Z0lDQWdhV1lnS0hKbGMzVnNkQ0FoUFNCdWRXeHNLU0I3WEc0Z0lDQWdJQ0JwWmlBb2IzQjBhVzl1Y3k1cGJtUmxiblFwSUh0Y2JpQWdJQ0FnSUNBZ2JHVjBJR3hwYm1WeklEMGdjbVZ6ZFd4MExuTndiR2wwS0NkY1hHNG5LVHRjYmlBZ0lDQWdJQ0FnWm05eUlDaHNaWFFnYVNBOUlEQXNJR3dnUFNCc2FXNWxjeTVzWlc1bmRHZzdJR2tnUENCc095QnBLeXNwSUh0Y2JpQWdJQ0FnSUNBZ0lDQnBaaUFvSVd4cGJtVnpXMmxkSUNZbUlHa2dLeUF4SUQwOVBTQnNLU0I3WEc0Z0lDQWdJQ0FnSUNBZ0lDQmljbVZoYXp0Y2JpQWdJQ0FnSUNBZ0lDQjlYRzVjYmlBZ0lDQWdJQ0FnSUNCc2FXNWxjMXRwWFNBOUlHOXdkR2x2Ym5NdWFXNWtaVzUwSUNzZ2JHbHVaWE5iYVYwN1hHNGdJQ0FnSUNBZ0lIMWNiaUFnSUNBZ0lDQWdjbVZ6ZFd4MElEMGdiR2x1WlhNdWFtOXBiaWduWEZ4dUp5azdYRzRnSUNBZ0lDQjlYRzRnSUNBZ0lDQnlaWFIxY200Z2NtVnpkV3gwTzF4dUlDQWdJSDBnWld4elpTQjdYRzRnSUNBZ0lDQjBhSEp2ZHlCdVpYY2dSWGhqWlhCMGFXOXVLQ2RVYUdVZ2NHRnlkR2xoYkNBbklDc2diM0IwYVc5dWN5NXVZVzFsSUNzZ0p5QmpiM1ZzWkNCdWIzUWdZbVVnWTI5dGNHbHNaV1FnZDJobGJpQnlkVzV1YVc1bklHbHVJSEoxYm5ScGJXVXRiMjVzZVNCdGIyUmxKeWs3WEc0Z0lDQWdmVnh1SUNCOVhHNWNiaUFnTHk4Z1NuVnpkQ0JoWkdRZ2QyRjBaWEpjYmlBZ2JHVjBJR052Ym5SaGFXNWxjaUE5SUh0Y2JpQWdJQ0J6ZEhKcFkzUTZJR1oxYm1OMGFXOXVLRzlpYWl3Z2JtRnRaU2tnZTF4dUlDQWdJQ0FnYVdZZ0tDRW9ibUZ0WlNCcGJpQnZZbW9wS1NCN1hHNGdJQ0FnSUNBZ0lIUm9jbTkzSUc1bGR5QkZlR05sY0hScGIyNG9KMXdpSnlBcklHNWhiV1VnS3lBblhDSWdibTkwSUdSbFptbHVaV1FnYVc0Z0p5QXJJRzlpYWlrN1hHNGdJQ0FnSUNCOVhHNGdJQ0FnSUNCeVpYUjFjbTRnYjJKcVcyNWhiV1ZkTzF4dUlDQWdJSDBzWEc0Z0lDQWdiRzl2YTNWd09pQm1kVzVqZEdsdmJpaGtaWEIwYUhNc0lHNWhiV1VwSUh0Y2JpQWdJQ0FnSUdOdmJuTjBJR3hsYmlBOUlHUmxjSFJvY3k1c1pXNW5kR2c3WEc0Z0lDQWdJQ0JtYjNJZ0tHeGxkQ0JwSUQwZ01Ec2dhU0E4SUd4bGJqc2dhU3NyS1NCN1hHNGdJQ0FnSUNBZ0lHbG1JQ2hrWlhCMGFITmJhVjBnSmlZZ1pHVndkR2h6VzJsZFcyNWhiV1ZkSUNFOUlHNTFiR3dwSUh0Y2JpQWdJQ0FnSUNBZ0lDQnlaWFIxY200Z1pHVndkR2h6VzJsZFcyNWhiV1ZkTzF4dUlDQWdJQ0FnSUNCOVhHNGdJQ0FnSUNCOVhHNGdJQ0FnZlN4Y2JpQWdJQ0JzWVcxaVpHRTZJR1oxYm1OMGFXOXVLR04xY25KbGJuUXNJR052Ym5SbGVIUXBJSHRjYmlBZ0lDQWdJSEpsZEhWeWJpQjBlWEJsYjJZZ1kzVnljbVZ1ZENBOVBUMGdKMloxYm1OMGFXOXVKeUEvSUdOMWNuSmxiblF1WTJGc2JDaGpiMjUwWlhoMEtTQTZJR04xY25KbGJuUTdYRzRnSUNBZ2ZTeGNibHh1SUNBZ0lHVnpZMkZ3WlVWNGNISmxjM05wYjI0NklGVjBhV3h6TG1WelkyRndaVVY0Y0hKbGMzTnBiMjRzWEc0Z0lDQWdhVzUyYjJ0bFVHRnlkR2xoYkRvZ2FXNTJiMnRsVUdGeWRHbGhiRmR5WVhCd1pYSXNYRzVjYmlBZ0lDQm1iam9nWm5WdVkzUnBiMjRvYVNrZ2UxeHVJQ0FnSUNBZ2JHVjBJSEpsZENBOUlIUmxiWEJzWVhSbFUzQmxZMXRwWFR0Y2JpQWdJQ0FnSUhKbGRDNWtaV052Y21GMGIzSWdQU0IwWlcxd2JHRjBaVk53WldOYmFTQXJJQ2RmWkNkZE8xeHVJQ0FnSUNBZ2NtVjBkWEp1SUhKbGREdGNiaUFnSUNCOUxGeHVYRzRnSUNBZ2NISnZaM0poYlhNNklGdGRMRnh1SUNBZ0lIQnliMmR5WVcwNklHWjFibU4wYVc5dUtHa3NJR1JoZEdFc0lHUmxZMnhoY21Wa1FteHZZMnRRWVhKaGJYTXNJR0pzYjJOclVHRnlZVzF6TENCa1pYQjBhSE1wSUh0Y2JpQWdJQ0FnSUd4bGRDQndjbTluY21GdFYzSmhjSEJsY2lBOUlIUm9hWE11Y0hKdlozSmhiWE5iYVYwc1hHNGdJQ0FnSUNBZ0lDQWdabTRnUFNCMGFHbHpMbVp1S0drcE8xeHVJQ0FnSUNBZ2FXWWdLR1JoZEdFZ2ZId2daR1Z3ZEdoeklIeDhJR0pzYjJOclVHRnlZVzF6SUh4OElHUmxZMnhoY21Wa1FteHZZMnRRWVhKaGJYTXBJSHRjYmlBZ0lDQWdJQ0FnY0hKdlozSmhiVmR5WVhCd1pYSWdQU0IzY21Gd1VISnZaM0poYlNoMGFHbHpMQ0JwTENCbWJpd2daR0YwWVN3Z1pHVmpiR0Z5WldSQ2JHOWphMUJoY21GdGN5d2dZbXh2WTJ0UVlYSmhiWE1zSUdSbGNIUm9jeWs3WEc0Z0lDQWdJQ0I5SUdWc2MyVWdhV1lnS0NGd2NtOW5jbUZ0VjNKaGNIQmxjaWtnZTF4dUlDQWdJQ0FnSUNCd2NtOW5jbUZ0VjNKaGNIQmxjaUE5SUhSb2FYTXVjSEp2WjNKaGJYTmJhVjBnUFNCM2NtRndVSEp2WjNKaGJTaDBhR2x6TENCcExDQm1iaWs3WEc0Z0lDQWdJQ0I5WEc0Z0lDQWdJQ0J5WlhSMWNtNGdjSEp2WjNKaGJWZHlZWEJ3WlhJN1hHNGdJQ0FnZlN4Y2JseHVJQ0FnSUdSaGRHRTZJR1oxYm1OMGFXOXVLSFpoYkhWbExDQmtaWEIwYUNrZ2UxeHVJQ0FnSUNBZ2QyaHBiR1VnS0haaGJIVmxJQ1ltSUdSbGNIUm9MUzBwSUh0Y2JpQWdJQ0FnSUNBZ2RtRnNkV1VnUFNCMllXeDFaUzVmY0dGeVpXNTBPMXh1SUNBZ0lDQWdmVnh1SUNBZ0lDQWdjbVYwZFhKdUlIWmhiSFZsTzF4dUlDQWdJSDBzWEc0Z0lDQWdiV1Z5WjJVNklHWjFibU4wYVc5dUtIQmhjbUZ0TENCamIyMXRiMjRwSUh0Y2JpQWdJQ0FnSUd4bGRDQnZZbW9nUFNCd1lYSmhiU0I4ZkNCamIyMXRiMjQ3WEc1Y2JpQWdJQ0FnSUdsbUlDaHdZWEpoYlNBbUppQmpiMjF0YjI0Z0ppWWdLSEJoY21GdElDRTlQU0JqYjIxdGIyNHBLU0I3WEc0Z0lDQWdJQ0FnSUc5aWFpQTlJRlYwYVd4ekxtVjRkR1Z1WkNoN2ZTd2dZMjl0Ylc5dUxDQndZWEpoYlNrN1hHNGdJQ0FnSUNCOVhHNWNiaUFnSUNBZ0lISmxkSFZ5YmlCdlltbzdYRzRnSUNBZ2ZTeGNiaUFnSUNBdkx5QkJiaUJsYlhCMGVTQnZZbXBsWTNRZ2RHOGdkWE5sSUdGeklISmxjR3hoWTJWdFpXNTBJR1p2Y2lCdWRXeHNMV052Ym5SbGVIUnpYRzRnSUNBZ2JuVnNiRU52Ym5SbGVIUTZJRTlpYW1WamRDNXpaV0ZzS0h0OUtTeGNibHh1SUNBZ0lHNXZiM0E2SUdWdWRpNVdUUzV1YjI5d0xGeHVJQ0FnSUdOdmJYQnBiR1Z5U1c1bWJ6b2dkR1Z0Y0d4aGRHVlRjR1ZqTG1OdmJYQnBiR1Z5WEc0Z0lIMDdYRzVjYmlBZ1puVnVZM1JwYjI0Z2NtVjBLR052Ym5SbGVIUXNJRzl3ZEdsdmJuTWdQU0I3ZlNrZ2UxeHVJQ0FnSUd4bGRDQmtZWFJoSUQwZ2IzQjBhVzl1Y3k1a1lYUmhPMXh1WEc0Z0lDQWdjbVYwTGw5elpYUjFjQ2h2Y0hScGIyNXpLVHRjYmlBZ0lDQnBaaUFvSVc5d2RHbHZibk11Y0dGeWRHbGhiQ0FtSmlCMFpXMXdiR0YwWlZOd1pXTXVkWE5sUkdGMFlTa2dlMXh1SUNBZ0lDQWdaR0YwWVNBOUlHbHVhWFJFWVhSaEtHTnZiblJsZUhRc0lHUmhkR0VwTzF4dUlDQWdJSDFjYmlBZ0lDQnNaWFFnWkdWd2RHaHpMRnh1SUNBZ0lDQWdJQ0JpYkc5amExQmhjbUZ0Y3lBOUlIUmxiWEJzWVhSbFUzQmxZeTUxYzJWQ2JHOWphMUJoY21GdGN5QS9JRnRkSURvZ2RXNWtaV1pwYm1Wa08xeHVJQ0FnSUdsbUlDaDBaVzF3YkdGMFpWTndaV011ZFhObFJHVndkR2h6S1NCN1hHNGdJQ0FnSUNCcFppQW9iM0IwYVc5dWN5NWtaWEIwYUhNcElIdGNiaUFnSUNBZ0lDQWdaR1Z3ZEdoeklEMGdZMjl1ZEdWNGRDQWhQU0J2Y0hScGIyNXpMbVJsY0hSb2Mxc3dYU0EvSUZ0amIyNTBaWGgwWFM1amIyNWpZWFFvYjNCMGFXOXVjeTVrWlhCMGFITXBJRG9nYjNCMGFXOXVjeTVrWlhCMGFITTdYRzRnSUNBZ0lDQjlJR1ZzYzJVZ2UxeHVJQ0FnSUNBZ0lDQmtaWEIwYUhNZ1BTQmJZMjl1ZEdWNGRGMDdYRzRnSUNBZ0lDQjlYRzRnSUNBZ2ZWeHVYRzRnSUNBZ1puVnVZM1JwYjI0Z2JXRnBiaWhqYjI1MFpYaDBMeW9zSUc5d2RHbHZibk1xTHlrZ2UxeHVJQ0FnSUNBZ2NtVjBkWEp1SUNjbklDc2dkR1Z0Y0d4aGRHVlRjR1ZqTG0xaGFXNG9ZMjl1ZEdGcGJtVnlMQ0JqYjI1MFpYaDBMQ0JqYjI1MFlXbHVaWEl1YUdWc2NHVnljeXdnWTI5dWRHRnBibVZ5TG5CaGNuUnBZV3h6TENCa1lYUmhMQ0JpYkc5amExQmhjbUZ0Y3l3Z1pHVndkR2h6S1R0Y2JpQWdJQ0I5WEc0Z0lDQWdiV0ZwYmlBOUlHVjRaV04xZEdWRVpXTnZjbUYwYjNKektIUmxiWEJzWVhSbFUzQmxZeTV0WVdsdUxDQnRZV2x1TENCamIyNTBZV2x1WlhJc0lHOXdkR2x2Ym5NdVpHVndkR2h6SUh4OElGdGRMQ0JrWVhSaExDQmliRzlqYTFCaGNtRnRjeWs3WEc0Z0lDQWdjbVYwZFhKdUlHMWhhVzRvWTI5dWRHVjRkQ3dnYjNCMGFXOXVjeWs3WEc0Z0lIMWNiaUFnY21WMExtbHpWRzl3SUQwZ2RISjFaVHRjYmx4dUlDQnlaWFF1WDNObGRIVndJRDBnWm5WdVkzUnBiMjRvYjNCMGFXOXVjeWtnZTF4dUlDQWdJR2xtSUNnaGIzQjBhVzl1Y3k1d1lYSjBhV0ZzS1NCN1hHNGdJQ0FnSUNCamIyNTBZV2x1WlhJdWFHVnNjR1Z5Y3lBOUlHTnZiblJoYVc1bGNpNXRaWEpuWlNodmNIUnBiMjV6TG1obGJIQmxjbk1zSUdWdWRpNW9aV3h3WlhKektUdGNibHh1SUNBZ0lDQWdhV1lnS0hSbGJYQnNZWFJsVTNCbFl5NTFjMlZRWVhKMGFXRnNLU0I3WEc0Z0lDQWdJQ0FnSUdOdmJuUmhhVzVsY2k1d1lYSjBhV0ZzY3lBOUlHTnZiblJoYVc1bGNpNXRaWEpuWlNodmNIUnBiMjV6TG5CaGNuUnBZV3h6TENCbGJuWXVjR0Z5ZEdsaGJITXBPMXh1SUNBZ0lDQWdmVnh1SUNBZ0lDQWdhV1lnS0hSbGJYQnNZWFJsVTNCbFl5NTFjMlZRWVhKMGFXRnNJSHg4SUhSbGJYQnNZWFJsVTNCbFl5NTFjMlZFWldOdmNtRjBiM0p6S1NCN1hHNGdJQ0FnSUNBZ0lHTnZiblJoYVc1bGNpNWtaV052Y21GMGIzSnpJRDBnWTI5dWRHRnBibVZ5TG0xbGNtZGxLRzl3ZEdsdmJuTXVaR1ZqYjNKaGRHOXljeXdnWlc1MkxtUmxZMjl5WVhSdmNuTXBPMXh1SUNBZ0lDQWdmVnh1SUNBZ0lIMGdaV3h6WlNCN1hHNGdJQ0FnSUNCamIyNTBZV2x1WlhJdWFHVnNjR1Z5Y3lBOUlHOXdkR2x2Ym5NdWFHVnNjR1Z5Y3p0Y2JpQWdJQ0FnSUdOdmJuUmhhVzVsY2k1d1lYSjBhV0ZzY3lBOUlHOXdkR2x2Ym5NdWNHRnlkR2xoYkhNN1hHNGdJQ0FnSUNCamIyNTBZV2x1WlhJdVpHVmpiM0poZEc5eWN5QTlJRzl3ZEdsdmJuTXVaR1ZqYjNKaGRHOXljenRjYmlBZ0lDQjlYRzRnSUgwN1hHNWNiaUFnY21WMExsOWphR2xzWkNBOUlHWjFibU4wYVc5dUtHa3NJR1JoZEdFc0lHSnNiMk5yVUdGeVlXMXpMQ0JrWlhCMGFITXBJSHRjYmlBZ0lDQnBaaUFvZEdWdGNHeGhkR1ZUY0dWakxuVnpaVUpzYjJOclVHRnlZVzF6SUNZbUlDRmliRzlqYTFCaGNtRnRjeWtnZTF4dUlDQWdJQ0FnZEdoeWIzY2dibVYzSUVWNFkyVndkR2x2YmlnbmJYVnpkQ0J3WVhOeklHSnNiMk5ySUhCaGNtRnRjeWNwTzF4dUlDQWdJSDFjYmlBZ0lDQnBaaUFvZEdWdGNHeGhkR1ZUY0dWakxuVnpaVVJsY0hSb2N5QW1KaUFoWkdWd2RHaHpLU0I3WEc0Z0lDQWdJQ0IwYUhKdmR5QnVaWGNnUlhoalpYQjBhVzl1S0NkdGRYTjBJSEJoYzNNZ2NHRnlaVzUwSUdSbGNIUm9jeWNwTzF4dUlDQWdJSDFjYmx4dUlDQWdJSEpsZEhWeWJpQjNjbUZ3VUhKdlozSmhiU2hqYjI1MFlXbHVaWElzSUdrc0lIUmxiWEJzWVhSbFUzQmxZMXRwWFN3Z1pHRjBZU3dnTUN3Z1lteHZZMnRRWVhKaGJYTXNJR1JsY0hSb2N5azdYRzRnSUgwN1hHNGdJSEpsZEhWeWJpQnlaWFE3WEc1OVhHNWNibVY0Y0c5eWRDQm1kVzVqZEdsdmJpQjNjbUZ3VUhKdlozSmhiU2hqYjI1MFlXbHVaWElzSUdrc0lHWnVMQ0JrWVhSaExDQmtaV05zWVhKbFpFSnNiMk5yVUdGeVlXMXpMQ0JpYkc5amExQmhjbUZ0Y3l3Z1pHVndkR2h6S1NCN1hHNGdJR1oxYm1OMGFXOXVJSEJ5YjJjb1kyOXVkR1Y0ZEN3Z2IzQjBhVzl1Y3lBOUlIdDlLU0I3WEc0Z0lDQWdiR1YwSUdOMWNuSmxiblJFWlhCMGFITWdQU0JrWlhCMGFITTdYRzRnSUNBZ2FXWWdLR1JsY0hSb2N5QW1KaUJqYjI1MFpYaDBJQ0U5SUdSbGNIUm9jMXN3WFNBbUppQWhLR052Ym5SbGVIUWdQVDA5SUdOdmJuUmhhVzVsY2k1dWRXeHNRMjl1ZEdWNGRDQW1KaUJrWlhCMGFITmJNRjBnUFQwOUlHNTFiR3dwS1NCN1hHNGdJQ0FnSUNCamRYSnlaVzUwUkdWd2RHaHpJRDBnVzJOdmJuUmxlSFJkTG1OdmJtTmhkQ2hrWlhCMGFITXBPMXh1SUNBZ0lIMWNibHh1SUNBZ0lISmxkSFZ5YmlCbWJpaGpiMjUwWVdsdVpYSXNYRzRnSUNBZ0lDQWdJR052Ym5SbGVIUXNYRzRnSUNBZ0lDQWdJR052Ym5SaGFXNWxjaTVvWld4d1pYSnpMQ0JqYjI1MFlXbHVaWEl1Y0dGeWRHbGhiSE1zWEc0Z0lDQWdJQ0FnSUc5d2RHbHZibk11WkdGMFlTQjhmQ0JrWVhSaExGeHVJQ0FnSUNBZ0lDQmliRzlqYTFCaGNtRnRjeUFtSmlCYmIzQjBhVzl1Y3k1aWJHOWphMUJoY21GdGMxMHVZMjl1WTJGMEtHSnNiMk5yVUdGeVlXMXpLU3hjYmlBZ0lDQWdJQ0FnWTNWeWNtVnVkRVJsY0hSb2N5azdYRzRnSUgxY2JseHVJQ0J3Y205bklEMGdaWGhsWTNWMFpVUmxZMjl5WVhSdmNuTW9abTRzSUhCeWIyY3NJR052Ym5SaGFXNWxjaXdnWkdWd2RHaHpMQ0JrWVhSaExDQmliRzlqYTFCaGNtRnRjeWs3WEc1Y2JpQWdjSEp2Wnk1d2NtOW5jbUZ0SUQwZ2FUdGNiaUFnY0hKdlp5NWtaWEIwYUNBOUlHUmxjSFJvY3lBL0lHUmxjSFJvY3k1c1pXNW5kR2dnT2lBd08xeHVJQ0J3Y205bkxtSnNiMk5yVUdGeVlXMXpJRDBnWkdWamJHRnlaV1JDYkc5amExQmhjbUZ0Y3lCOGZDQXdPMXh1SUNCeVpYUjFjbTRnY0hKdlp6dGNibjFjYmx4dVpYaHdiM0owSUdaMWJtTjBhVzl1SUhKbGMyOXNkbVZRWVhKMGFXRnNLSEJoY25ScFlXd3NJR052Ym5SbGVIUXNJRzl3ZEdsdmJuTXBJSHRjYmlBZ2FXWWdLQ0Z3WVhKMGFXRnNLU0I3WEc0Z0lDQWdhV1lnS0c5d2RHbHZibk11Ym1GdFpTQTlQVDBnSjBCd1lYSjBhV0ZzTFdKc2IyTnJKeWtnZTF4dUlDQWdJQ0FnY0dGeWRHbGhiQ0E5SUc5d2RHbHZibk11WkdGMFlWc25jR0Z5ZEdsaGJDMWliRzlqYXlkZE8xeHVJQ0FnSUgwZ1pXeHpaU0I3WEc0Z0lDQWdJQ0J3WVhKMGFXRnNJRDBnYjNCMGFXOXVjeTV3WVhKMGFXRnNjMXR2Y0hScGIyNXpMbTVoYldWZE8xeHVJQ0FnSUgxY2JpQWdmU0JsYkhObElHbG1JQ2doY0dGeWRHbGhiQzVqWVd4c0lDWW1JQ0Z2Y0hScGIyNXpMbTVoYldVcElIdGNiaUFnSUNBdkx5QlVhR2x6SUdseklHRWdaSGx1WVcxcFl5QndZWEowYVdGc0lIUm9ZWFFnY21WMGRYSnVaV1FnWVNCemRISnBibWRjYmlBZ0lDQnZjSFJwYjI1ekxtNWhiV1VnUFNCd1lYSjBhV0ZzTzF4dUlDQWdJSEJoY25ScFlXd2dQU0J2Y0hScGIyNXpMbkJoY25ScFlXeHpXM0JoY25ScFlXeGRPMXh1SUNCOVhHNGdJSEpsZEhWeWJpQndZWEowYVdGc08xeHVmVnh1WEc1bGVIQnZjblFnWm5WdVkzUnBiMjRnYVc1MmIydGxVR0Z5ZEdsaGJDaHdZWEowYVdGc0xDQmpiMjUwWlhoMExDQnZjSFJwYjI1ektTQjdYRzRnSUM4dklGVnpaU0IwYUdVZ1kzVnljbVZ1ZENCamJHOXpkWEpsSUdOdmJuUmxlSFFnZEc4Z2MyRjJaU0IwYUdVZ2NHRnlkR2xoYkMxaWJHOWpheUJwWmlCMGFHbHpJSEJoY25ScFlXeGNiaUFnWTI5dWMzUWdZM1Z5Y21WdWRGQmhjblJwWVd4Q2JHOWpheUE5SUc5d2RHbHZibk11WkdGMFlTQW1KaUJ2Y0hScGIyNXpMbVJoZEdGYkozQmhjblJwWVd3dFlteHZZMnNuWFR0Y2JpQWdiM0IwYVc5dWN5NXdZWEowYVdGc0lEMGdkSEoxWlR0Y2JpQWdhV1lnS0c5d2RHbHZibk11YVdSektTQjdYRzRnSUNBZ2IzQjBhVzl1Y3k1a1lYUmhMbU52Ym5SbGVIUlFZWFJvSUQwZ2IzQjBhVzl1Y3k1cFpITmJNRjBnZkh3Z2IzQjBhVzl1Y3k1a1lYUmhMbU52Ym5SbGVIUlFZWFJvTzF4dUlDQjlYRzVjYmlBZ2JHVjBJSEJoY25ScFlXeENiRzlqYXp0Y2JpQWdhV1lnS0c5d2RHbHZibk11Wm00Z0ppWWdiM0IwYVc5dWN5NW1iaUFoUFQwZ2JtOXZjQ2tnZTF4dUlDQWdJRzl3ZEdsdmJuTXVaR0YwWVNBOUlHTnlaV0YwWlVaeVlXMWxLRzl3ZEdsdmJuTXVaR0YwWVNrN1hHNGdJQ0FnTHk4Z1YzSmhjSEJsY2lCbWRXNWpkR2x2YmlCMGJ5Qm5aWFFnWVdOalpYTnpJSFJ2SUdOMWNuSmxiblJRWVhKMGFXRnNRbXh2WTJzZ1puSnZiU0IwYUdVZ1kyeHZjM1Z5WlZ4dUlDQWdJR3hsZENCbWJpQTlJRzl3ZEdsdmJuTXVabTQ3WEc0Z0lDQWdjR0Z5ZEdsaGJFSnNiMk5ySUQwZ2IzQjBhVzl1Y3k1a1lYUmhXeWR3WVhKMGFXRnNMV0pzYjJOckoxMGdQU0JtZFc1amRHbHZiaUJ3WVhKMGFXRnNRbXh2WTJ0WGNtRndjR1Z5S0dOdmJuUmxlSFFzSUc5d2RHbHZibk1nUFNCN2ZTa2dlMXh1WEc0Z0lDQWdJQ0F2THlCU1pYTjBiM0psSUhSb1pTQndZWEowYVdGc0xXSnNiMk5ySUdaeWIyMGdkR2hsSUdOc2IzTjFjbVVnWm05eUlIUm9aU0JsZUdWamRYUnBiMjRnYjJZZ2RHaGxJR0pzYjJOclhHNGdJQ0FnSUNBdkx5QnBMbVV1SUhSb1pTQndZWEowSUdsdWMybGtaU0IwYUdVZ1lteHZZMnNnYjJZZ2RHaGxJSEJoY25ScFlXd2dZMkZzYkM1Y2JpQWdJQ0FnSUc5d2RHbHZibk11WkdGMFlTQTlJR055WldGMFpVWnlZVzFsS0c5d2RHbHZibk11WkdGMFlTazdYRzRnSUNBZ0lDQnZjSFJwYjI1ekxtUmhkR0ZiSjNCaGNuUnBZV3d0WW14dlkyc25YU0E5SUdOMWNuSmxiblJRWVhKMGFXRnNRbXh2WTJzN1hHNGdJQ0FnSUNCeVpYUjFjbTRnWm00b1kyOXVkR1Y0ZEN3Z2IzQjBhVzl1Y3lrN1hHNGdJQ0FnZlR0Y2JpQWdJQ0JwWmlBb1ptNHVjR0Z5ZEdsaGJITXBJSHRjYmlBZ0lDQWdJRzl3ZEdsdmJuTXVjR0Z5ZEdsaGJITWdQU0JWZEdsc2N5NWxlSFJsYm1Rb2UzMHNJRzl3ZEdsdmJuTXVjR0Z5ZEdsaGJITXNJR1p1TG5CaGNuUnBZV3h6S1R0Y2JpQWdJQ0I5WEc0Z0lIMWNibHh1SUNCcFppQW9jR0Z5ZEdsaGJDQTlQVDBnZFc1a1pXWnBibVZrSUNZbUlIQmhjblJwWVd4Q2JHOWpheWtnZTF4dUlDQWdJSEJoY25ScFlXd2dQU0J3WVhKMGFXRnNRbXh2WTJzN1hHNGdJSDFjYmx4dUlDQnBaaUFvY0dGeWRHbGhiQ0E5UFQwZ2RXNWtaV1pwYm1Wa0tTQjdYRzRnSUNBZ2RHaHliM2NnYm1WM0lFVjRZMlZ3ZEdsdmJpZ25WR2hsSUhCaGNuUnBZV3dnSnlBcklHOXdkR2x2Ym5NdWJtRnRaU0FySUNjZ1kyOTFiR1FnYm05MElHSmxJR1p2ZFc1a0p5azdYRzRnSUgwZ1pXeHpaU0JwWmlBb2NHRnlkR2xoYkNCcGJuTjBZVzVqWlc5bUlFWjFibU4wYVc5dUtTQjdYRzRnSUNBZ2NtVjBkWEp1SUhCaGNuUnBZV3dvWTI5dWRHVjRkQ3dnYjNCMGFXOXVjeWs3WEc0Z0lIMWNibjFjYmx4dVpYaHdiM0owSUdaMWJtTjBhVzl1SUc1dmIzQW9LU0I3SUhKbGRIVnliaUFuSnpzZ2ZWeHVYRzVtZFc1amRHbHZiaUJwYm1sMFJHRjBZU2hqYjI1MFpYaDBMQ0JrWVhSaEtTQjdYRzRnSUdsbUlDZ2haR0YwWVNCOGZDQWhLQ2R5YjI5MEp5QnBiaUJrWVhSaEtTa2dlMXh1SUNBZ0lHUmhkR0VnUFNCa1lYUmhJRDhnWTNKbFlYUmxSbkpoYldVb1pHRjBZU2tnT2lCN2ZUdGNiaUFnSUNCa1lYUmhMbkp2YjNRZ1BTQmpiMjUwWlhoME8xeHVJQ0I5WEc0Z0lISmxkSFZ5YmlCa1lYUmhPMXh1ZlZ4dVhHNW1kVzVqZEdsdmJpQmxlR1ZqZFhSbFJHVmpiM0poZEc5eWN5aG1iaXdnY0hKdlp5d2dZMjl1ZEdGcGJtVnlMQ0JrWlhCMGFITXNJR1JoZEdFc0lHSnNiMk5yVUdGeVlXMXpLU0I3WEc0Z0lHbG1JQ2htYmk1a1pXTnZjbUYwYjNJcElIdGNiaUFnSUNCc1pYUWdjSEp2Y0hNZ1BTQjdmVHRjYmlBZ0lDQndjbTluSUQwZ1ptNHVaR1ZqYjNKaGRHOXlLSEJ5YjJjc0lIQnliM0J6TENCamIyNTBZV2x1WlhJc0lHUmxjSFJvY3lBbUppQmtaWEIwYUhOYk1GMHNJR1JoZEdFc0lHSnNiMk5yVUdGeVlXMXpMQ0JrWlhCMGFITXBPMXh1SUNBZ0lGVjBhV3h6TG1WNGRHVnVaQ2h3Y205bkxDQndjbTl3Y3lrN1hHNGdJSDFjYmlBZ2NtVjBkWEp1SUhCeWIyYzdYRzU5WEc0aVhYMD1cbiIsIi8vIEJ1aWxkIG91dCBvdXIgYmFzaWMgU2FmZVN0cmluZyB0eXBlXG4ndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG5mdW5jdGlvbiBTYWZlU3RyaW5nKHN0cmluZykge1xuICB0aGlzLnN0cmluZyA9IHN0cmluZztcbn1cblxuU2FmZVN0cmluZy5wcm90b3R5cGUudG9TdHJpbmcgPSBTYWZlU3RyaW5nLnByb3RvdHlwZS50b0hUTUwgPSBmdW5jdGlvbiAoKSB7XG4gIHJldHVybiAnJyArIHRoaXMuc3RyaW5nO1xufTtcblxuZXhwb3J0c1snZGVmYXVsdCddID0gU2FmZVN0cmluZztcbm1vZHVsZS5leHBvcnRzID0gZXhwb3J0c1snZGVmYXVsdCddO1xuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMeTR1TDJ4cFlpOW9ZVzVrYkdWaVlYSnpMM05oWm1VdGMzUnlhVzVuTG1weklsMHNJbTVoYldWeklqcGJYU3dpYldGd2NHbHVaM01pT2lJN096czdRVUZEUVN4VFFVRlRMRlZCUVZVc1EwRkJReXhOUVVGTkxFVkJRVVU3UVVGRE1VSXNUVUZCU1N4RFFVRkRMRTFCUVUwc1IwRkJSeXhOUVVGTkxFTkJRVU03UTBGRGRFSTdPMEZCUlVRc1ZVRkJWU3hEUVVGRExGTkJRVk1zUTBGQlF5eFJRVUZSTEVkQlFVY3NWVUZCVlN4RFFVRkRMRk5CUVZNc1EwRkJReXhOUVVGTkxFZEJRVWNzV1VGQlZ6dEJRVU4yUlN4VFFVRlBMRVZCUVVVc1IwRkJSeXhKUVVGSkxFTkJRVU1zVFVGQlRTeERRVUZETzBOQlEzcENMRU5CUVVNN08zRkNRVVZoTEZWQlFWVWlMQ0ptYVd4bElqb2ljMkZtWlMxemRISnBibWN1YW5NaUxDSnpiM1Z5WTJWelEyOXVkR1Z1ZENJNld5SXZMeUJDZFdsc1pDQnZkWFFnYjNWeUlHSmhjMmxqSUZOaFptVlRkSEpwYm1jZ2RIbHdaVnh1Wm5WdVkzUnBiMjRnVTJGbVpWTjBjbWx1WnloemRISnBibWNwSUh0Y2JpQWdkR2hwY3k1emRISnBibWNnUFNCemRISnBibWM3WEc1OVhHNWNibE5oWm1WVGRISnBibWN1Y0hKdmRHOTBlWEJsTG5SdlUzUnlhVzVuSUQwZ1UyRm1aVk4wY21sdVp5NXdjbTkwYjNSNWNHVXVkRzlJVkUxTUlEMGdablZ1WTNScGIyNG9LU0I3WEc0Z0lISmxkSFZ5YmlBbkp5QXJJSFJvYVhNdWMzUnlhVzVuTzF4dWZUdGNibHh1Wlhod2IzSjBJR1JsWm1GMWJIUWdVMkZtWlZOMGNtbHVaenRjYmlKZGZRPT1cbiIsIid1c2Ugc3RyaWN0JztcblxuZXhwb3J0cy5fX2VzTW9kdWxlID0gdHJ1ZTtcbmV4cG9ydHMuZXh0ZW5kID0gZXh0ZW5kO1xuZXhwb3J0cy5pbmRleE9mID0gaW5kZXhPZjtcbmV4cG9ydHMuZXNjYXBlRXhwcmVzc2lvbiA9IGVzY2FwZUV4cHJlc3Npb247XG5leHBvcnRzLmlzRW1wdHkgPSBpc0VtcHR5O1xuZXhwb3J0cy5jcmVhdGVGcmFtZSA9IGNyZWF0ZUZyYW1lO1xuZXhwb3J0cy5ibG9ja1BhcmFtcyA9IGJsb2NrUGFyYW1zO1xuZXhwb3J0cy5hcHBlbmRDb250ZXh0UGF0aCA9IGFwcGVuZENvbnRleHRQYXRoO1xudmFyIGVzY2FwZSA9IHtcbiAgJyYnOiAnJmFtcDsnLFxuICAnPCc6ICcmbHQ7JyxcbiAgJz4nOiAnJmd0OycsXG4gICdcIic6ICcmcXVvdDsnLFxuICBcIidcIjogJyYjeDI3OycsXG4gICdgJzogJyYjeDYwOycsXG4gICc9JzogJyYjeDNEOydcbn07XG5cbnZhciBiYWRDaGFycyA9IC9bJjw+XCInYD1dL2csXG4gICAgcG9zc2libGUgPSAvWyY8PlwiJ2A9XS87XG5cbmZ1bmN0aW9uIGVzY2FwZUNoYXIoY2hyKSB7XG4gIHJldHVybiBlc2NhcGVbY2hyXTtcbn1cblxuZnVuY3Rpb24gZXh0ZW5kKG9iaiAvKiAsIC4uLnNvdXJjZSAqLykge1xuICBmb3IgKHZhciBpID0gMTsgaSA8IGFyZ3VtZW50cy5sZW5ndGg7IGkrKykge1xuICAgIGZvciAodmFyIGtleSBpbiBhcmd1bWVudHNbaV0pIHtcbiAgICAgIGlmIChPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwoYXJndW1lbnRzW2ldLCBrZXkpKSB7XG4gICAgICAgIG9ialtrZXldID0gYXJndW1lbnRzW2ldW2tleV07XG4gICAgICB9XG4gICAgfVxuICB9XG5cbiAgcmV0dXJuIG9iajtcbn1cblxudmFyIHRvU3RyaW5nID0gT2JqZWN0LnByb3RvdHlwZS50b1N0cmluZztcblxuZXhwb3J0cy50b1N0cmluZyA9IHRvU3RyaW5nO1xuLy8gU291cmNlZCBmcm9tIGxvZGFzaFxuLy8gaHR0cHM6Ly9naXRodWIuY29tL2Jlc3RpZWpzL2xvZGFzaC9ibG9iL21hc3Rlci9MSUNFTlNFLnR4dFxuLyogZXNsaW50LWRpc2FibGUgZnVuYy1zdHlsZSAqL1xudmFyIGlzRnVuY3Rpb24gPSBmdW5jdGlvbiBpc0Z1bmN0aW9uKHZhbHVlKSB7XG4gIHJldHVybiB0eXBlb2YgdmFsdWUgPT09ICdmdW5jdGlvbic7XG59O1xuLy8gZmFsbGJhY2sgZm9yIG9sZGVyIHZlcnNpb25zIG9mIENocm9tZSBhbmQgU2FmYXJpXG4vKiBpc3RhbmJ1bCBpZ25vcmUgbmV4dCAqL1xuaWYgKGlzRnVuY3Rpb24oL3gvKSkge1xuICBleHBvcnRzLmlzRnVuY3Rpb24gPSBpc0Z1bmN0aW9uID0gZnVuY3Rpb24gKHZhbHVlKSB7XG4gICAgcmV0dXJuIHR5cGVvZiB2YWx1ZSA9PT0gJ2Z1bmN0aW9uJyAmJiB0b1N0cmluZy5jYWxsKHZhbHVlKSA9PT0gJ1tvYmplY3QgRnVuY3Rpb25dJztcbiAgfTtcbn1cbmV4cG9ydHMuaXNGdW5jdGlvbiA9IGlzRnVuY3Rpb247XG5cbi8qIGVzbGludC1lbmFibGUgZnVuYy1zdHlsZSAqL1xuXG4vKiBpc3RhbmJ1bCBpZ25vcmUgbmV4dCAqL1xudmFyIGlzQXJyYXkgPSBBcnJheS5pc0FycmF5IHx8IGZ1bmN0aW9uICh2YWx1ZSkge1xuICByZXR1cm4gdmFsdWUgJiYgdHlwZW9mIHZhbHVlID09PSAnb2JqZWN0JyA/IHRvU3RyaW5nLmNhbGwodmFsdWUpID09PSAnW29iamVjdCBBcnJheV0nIDogZmFsc2U7XG59O1xuXG5leHBvcnRzLmlzQXJyYXkgPSBpc0FycmF5O1xuLy8gT2xkZXIgSUUgdmVyc2lvbnMgZG8gbm90IGRpcmVjdGx5IHN1cHBvcnQgaW5kZXhPZiBzbyB3ZSBtdXN0IGltcGxlbWVudCBvdXIgb3duLCBzYWRseS5cblxuZnVuY3Rpb24gaW5kZXhPZihhcnJheSwgdmFsdWUpIHtcbiAgZm9yICh2YXIgaSA9IDAsIGxlbiA9IGFycmF5Lmxlbmd0aDsgaSA8IGxlbjsgaSsrKSB7XG4gICAgaWYgKGFycmF5W2ldID09PSB2YWx1ZSkge1xuICAgICAgcmV0dXJuIGk7XG4gICAgfVxuICB9XG4gIHJldHVybiAtMTtcbn1cblxuZnVuY3Rpb24gZXNjYXBlRXhwcmVzc2lvbihzdHJpbmcpIHtcbiAgaWYgKHR5cGVvZiBzdHJpbmcgIT09ICdzdHJpbmcnKSB7XG4gICAgLy8gZG9uJ3QgZXNjYXBlIFNhZmVTdHJpbmdzLCBzaW5jZSB0aGV5J3JlIGFscmVhZHkgc2FmZVxuICAgIGlmIChzdHJpbmcgJiYgc3RyaW5nLnRvSFRNTCkge1xuICAgICAgcmV0dXJuIHN0cmluZy50b0hUTUwoKTtcbiAgICB9IGVsc2UgaWYgKHN0cmluZyA9PSBudWxsKSB7XG4gICAgICByZXR1cm4gJyc7XG4gICAgfSBlbHNlIGlmICghc3RyaW5nKSB7XG4gICAgICByZXR1cm4gc3RyaW5nICsgJyc7XG4gICAgfVxuXG4gICAgLy8gRm9yY2UgYSBzdHJpbmcgY29udmVyc2lvbiBhcyB0aGlzIHdpbGwgYmUgZG9uZSBieSB0aGUgYXBwZW5kIHJlZ2FyZGxlc3MgYW5kXG4gICAgLy8gdGhlIHJlZ2V4IHRlc3Qgd2lsbCBkbyB0aGlzIHRyYW5zcGFyZW50bHkgYmVoaW5kIHRoZSBzY2VuZXMsIGNhdXNpbmcgaXNzdWVzIGlmXG4gICAgLy8gYW4gb2JqZWN0J3MgdG8gc3RyaW5nIGhhcyBlc2NhcGVkIGNoYXJhY3RlcnMgaW4gaXQuXG4gICAgc3RyaW5nID0gJycgKyBzdHJpbmc7XG4gIH1cblxuICBpZiAoIXBvc3NpYmxlLnRlc3Qoc3RyaW5nKSkge1xuICAgIHJldHVybiBzdHJpbmc7XG4gIH1cbiAgcmV0dXJuIHN0cmluZy5yZXBsYWNlKGJhZENoYXJzLCBlc2NhcGVDaGFyKTtcbn1cblxuZnVuY3Rpb24gaXNFbXB0eSh2YWx1ZSkge1xuICBpZiAoIXZhbHVlICYmIHZhbHVlICE9PSAwKSB7XG4gICAgcmV0dXJuIHRydWU7XG4gIH0gZWxzZSBpZiAoaXNBcnJheSh2YWx1ZSkgJiYgdmFsdWUubGVuZ3RoID09PSAwKSB7XG4gICAgcmV0dXJuIHRydWU7XG4gIH0gZWxzZSB7XG4gICAgcmV0dXJuIGZhbHNlO1xuICB9XG59XG5cbmZ1bmN0aW9uIGNyZWF0ZUZyYW1lKG9iamVjdCkge1xuICB2YXIgZnJhbWUgPSBleHRlbmQoe30sIG9iamVjdCk7XG4gIGZyYW1lLl9wYXJlbnQgPSBvYmplY3Q7XG4gIHJldHVybiBmcmFtZTtcbn1cblxuZnVuY3Rpb24gYmxvY2tQYXJhbXMocGFyYW1zLCBpZHMpIHtcbiAgcGFyYW1zLnBhdGggPSBpZHM7XG4gIHJldHVybiBwYXJhbXM7XG59XG5cbmZ1bmN0aW9uIGFwcGVuZENvbnRleHRQYXRoKGNvbnRleHRQYXRoLCBpZCkge1xuICByZXR1cm4gKGNvbnRleHRQYXRoID8gY29udGV4dFBhdGggKyAnLicgOiAnJykgKyBpZDtcbn1cbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDNWMGFXeHpMbXB6SWwwc0ltNWhiV1Z6SWpwYlhTd2liV0Z3Y0dsdVozTWlPaUk3T3pzN096czdPenM3UVVGQlFTeEpRVUZOTEUxQlFVMHNSMEZCUnp0QlFVTmlMRXRCUVVjc1JVRkJSU3hQUVVGUE8wRkJRMW9zUzBGQlJ5eEZRVUZGTEUxQlFVMDdRVUZEV0N4TFFVRkhMRVZCUVVVc1RVRkJUVHRCUVVOWUxFdEJRVWNzUlVGQlJTeFJRVUZSTzBGQlEySXNTMEZCUnl4RlFVRkZMRkZCUVZFN1FVRkRZaXhMUVVGSExFVkJRVVVzVVVGQlVUdEJRVU5pTEV0QlFVY3NSVUZCUlN4UlFVRlJPME5CUTJRc1EwRkJRenM3UVVGRlJpeEpRVUZOTEZGQlFWRXNSMEZCUnl4WlFVRlpPMGxCUTNaQ0xGRkJRVkVzUjBGQlJ5eFhRVUZYTEVOQlFVTTdPMEZCUlRkQ0xGTkJRVk1zVlVGQlZTeERRVUZETEVkQlFVY3NSVUZCUlR0QlFVTjJRaXhUUVVGUExFMUJRVTBzUTBGQlF5eEhRVUZITEVOQlFVTXNRMEZCUXp0RFFVTndRanM3UVVGRlRTeFRRVUZUTEUxQlFVMHNRMEZCUXl4SFFVRkhMRzlDUVVGdFFqdEJRVU16UXl4UFFVRkxMRWxCUVVrc1EwRkJReXhIUVVGSExFTkJRVU1zUlVGQlJTeERRVUZETEVkQlFVY3NVMEZCVXl4RFFVRkRMRTFCUVUwc1JVRkJSU3hEUVVGRExFVkJRVVVzUlVGQlJUdEJRVU42UXl4VFFVRkxMRWxCUVVrc1IwRkJSeXhKUVVGSkxGTkJRVk1zUTBGQlF5eERRVUZETEVOQlFVTXNSVUZCUlR0QlFVTTFRaXhWUVVGSkxFMUJRVTBzUTBGQlF5eFRRVUZUTEVOQlFVTXNZMEZCWXl4RFFVRkRMRWxCUVVrc1EwRkJReXhUUVVGVExFTkJRVU1zUTBGQlF5eERRVUZETEVWQlFVVXNSMEZCUnl4RFFVRkRMRVZCUVVVN1FVRkRNMFFzVjBGQlJ5eERRVUZETEVkQlFVY3NRMEZCUXl4SFFVRkhMRk5CUVZNc1EwRkJReXhEUVVGRExFTkJRVU1zUTBGQlF5eEhRVUZITEVOQlFVTXNRMEZCUXp0UFFVTTVRanRMUVVOR08wZEJRMFk3TzBGQlJVUXNVMEZCVHl4SFFVRkhMRU5CUVVNN1EwRkRXanM3UVVGRlRTeEpRVUZKTEZGQlFWRXNSMEZCUnl4TlFVRk5MRU5CUVVNc1UwRkJVeXhEUVVGRExGRkJRVkVzUTBGQlF6czdPenM3TzBGQlMyaEVMRWxCUVVrc1ZVRkJWU3hIUVVGSExHOUNRVUZUTEV0QlFVc3NSVUZCUlR0QlFVTXZRaXhUUVVGUExFOUJRVThzUzBGQlN5eExRVUZMTEZWQlFWVXNRMEZCUXp0RFFVTndReXhEUVVGRE96czdRVUZIUml4SlFVRkpMRlZCUVZVc1EwRkJReXhIUVVGSExFTkJRVU1zUlVGQlJUdEJRVU51UWl4VlFVbE5MRlZCUVZVc1IwRkthRUlzVlVGQlZTeEhRVUZITEZWQlFWTXNTMEZCU3l4RlFVRkZPMEZCUXpOQ0xGZEJRVThzVDBGQlR5eExRVUZMTEV0QlFVc3NWVUZCVlN4SlFVRkpMRkZCUVZFc1EwRkJReXhKUVVGSkxFTkJRVU1zUzBGQlN5eERRVUZETEV0QlFVc3NiVUpCUVcxQ0xFTkJRVU03UjBGRGNFWXNRMEZCUXp0RFFVTklPMUZCUTA4c1ZVRkJWU3hIUVVGV0xGVkJRVlU3T3pzN08wRkJTVmdzU1VGQlRTeFBRVUZQTEVkQlFVY3NTMEZCU3l4RFFVRkRMRTlCUVU4c1NVRkJTU3hWUVVGVExFdEJRVXNzUlVGQlJUdEJRVU4wUkN4VFFVRlBMRUZCUVVNc1MwRkJTeXhKUVVGSkxFOUJRVThzUzBGQlN5eExRVUZMTEZGQlFWRXNSMEZCU1N4UlFVRlJMRU5CUVVNc1NVRkJTU3hEUVVGRExFdEJRVXNzUTBGQlF5eExRVUZMTEdkQ1FVRm5RaXhIUVVGSExFdEJRVXNzUTBGQlF6dERRVU5xUnl4RFFVRkRPenM3T3p0QlFVZExMRk5CUVZNc1QwRkJUeXhEUVVGRExFdEJRVXNzUlVGQlJTeExRVUZMTEVWQlFVVTdRVUZEY0VNc1QwRkJTeXhKUVVGSkxFTkJRVU1zUjBGQlJ5eERRVUZETEVWQlFVVXNSMEZCUnl4SFFVRkhMRXRCUVVzc1EwRkJReXhOUVVGTkxFVkJRVVVzUTBGQlF5eEhRVUZITEVkQlFVY3NSVUZCUlN4RFFVRkRMRVZCUVVVc1JVRkJSVHRCUVVOb1JDeFJRVUZKTEV0QlFVc3NRMEZCUXl4RFFVRkRMRU5CUVVNc1MwRkJTeXhMUVVGTExFVkJRVVU3UVVGRGRFSXNZVUZCVHl4RFFVRkRMRU5CUVVNN1MwRkRWanRIUVVOR08wRkJRMFFzVTBGQlR5eERRVUZETEVOQlFVTXNRMEZCUXp0RFFVTllPenRCUVVkTkxGTkJRVk1zWjBKQlFXZENMRU5CUVVNc1RVRkJUU3hGUVVGRk8wRkJRM1pETEUxQlFVa3NUMEZCVHl4TlFVRk5MRXRCUVVzc1VVRkJVU3hGUVVGRk96dEJRVVU1UWl4UlFVRkpMRTFCUVUwc1NVRkJTU3hOUVVGTkxFTkJRVU1zVFVGQlRTeEZRVUZGTzBGQlF6TkNMR0ZCUVU4c1RVRkJUU3hEUVVGRExFMUJRVTBzUlVGQlJTeERRVUZETzB0QlEzaENMRTFCUVUwc1NVRkJTU3hOUVVGTkxFbEJRVWtzU1VGQlNTeEZRVUZGTzBGQlEzcENMR0ZCUVU4c1JVRkJSU3hEUVVGRE8wdEJRMWdzVFVGQlRTeEpRVUZKTEVOQlFVTXNUVUZCVFN4RlFVRkZPMEZCUTJ4Q0xHRkJRVThzVFVGQlRTeEhRVUZITEVWQlFVVXNRMEZCUXp0TFFVTndRanM3T3pzN1FVRkxSQ3hWUVVGTkxFZEJRVWNzUlVGQlJTeEhRVUZITEUxQlFVMHNRMEZCUXp0SFFVTjBRanM3UVVGRlJDeE5RVUZKTEVOQlFVTXNVVUZCVVN4RFFVRkRMRWxCUVVrc1EwRkJReXhOUVVGTkxFTkJRVU1zUlVGQlJUdEJRVUZGTEZkQlFVOHNUVUZCVFN4RFFVRkRPMGRCUVVVN1FVRkRPVU1zVTBGQlR5eE5RVUZOTEVOQlFVTXNUMEZCVHl4RFFVRkRMRkZCUVZFc1JVRkJSU3hWUVVGVkxFTkJRVU1zUTBGQlF6dERRVU0zUXpzN1FVRkZUU3hUUVVGVExFOUJRVThzUTBGQlF5eExRVUZMTEVWQlFVVTdRVUZETjBJc1RVRkJTU3hEUVVGRExFdEJRVXNzU1VGQlNTeExRVUZMTEV0QlFVc3NRMEZCUXl4RlFVRkZPMEZCUTNwQ0xGZEJRVThzU1VGQlNTeERRVUZETzBkQlEySXNUVUZCVFN4SlFVRkpMRTlCUVU4c1EwRkJReXhMUVVGTExFTkJRVU1zU1VGQlNTeExRVUZMTEVOQlFVTXNUVUZCVFN4TFFVRkxMRU5CUVVNc1JVRkJSVHRCUVVNdlF5eFhRVUZQTEVsQlFVa3NRMEZCUXp0SFFVTmlMRTFCUVUwN1FVRkRUQ3hYUVVGUExFdEJRVXNzUTBGQlF6dEhRVU5rTzBOQlEwWTdPMEZCUlUwc1UwRkJVeXhYUVVGWExFTkJRVU1zVFVGQlRTeEZRVUZGTzBGQlEyeERMRTFCUVVrc1MwRkJTeXhIUVVGSExFMUJRVTBzUTBGQlF5eEZRVUZGTEVWQlFVVXNUVUZCVFN4RFFVRkRMRU5CUVVNN1FVRkRMMElzVDBGQlN5eERRVUZETEU5QlFVOHNSMEZCUnl4TlFVRk5MRU5CUVVNN1FVRkRka0lzVTBGQlR5eExRVUZMTEVOQlFVTTdRMEZEWkRzN1FVRkZUU3hUUVVGVExGZEJRVmNzUTBGQlF5eE5RVUZOTEVWQlFVVXNSMEZCUnl4RlFVRkZPMEZCUTNaRExGRkJRVTBzUTBGQlF5eEpRVUZKTEVkQlFVY3NSMEZCUnl4RFFVRkRPMEZCUTJ4Q0xGTkJRVThzVFVGQlRTeERRVUZETzBOQlEyWTdPMEZCUlUwc1UwRkJVeXhwUWtGQmFVSXNRMEZCUXl4WFFVRlhMRVZCUVVVc1JVRkJSU3hGUVVGRk8wRkJRMnBFTEZOQlFVOHNRMEZCUXl4WFFVRlhMRWRCUVVjc1YwRkJWeXhIUVVGSExFZEJRVWNzUjBGQlJ5eEZRVUZGTEVOQlFVRXNSMEZCU1N4RlFVRkZMRU5CUVVNN1EwRkRjRVFpTENKbWFXeGxJam9pZFhScGJITXVhbk1pTENKemIzVnlZMlZ6UTI5dWRHVnVkQ0k2V3lKamIyNXpkQ0JsYzJOaGNHVWdQU0I3WEc0Z0lDY21Kem9nSnlaaGJYQTdKeXhjYmlBZ0p6d25PaUFuSm14ME95Y3NYRzRnSUNjK0p6b2dKeVpuZERzbkxGeHVJQ0FuWENJbk9pQW5KbkYxYjNRN0p5eGNiaUFnWENJblhDSTZJQ2NtSTNneU56c25MRnh1SUNBbllDYzZJQ2NtSTNnMk1Ec25MRnh1SUNBblBTYzZJQ2NtSTNnelJEc25YRzU5TzF4dVhHNWpiMjV6ZENCaVlXUkRhR0Z5Y3lBOUlDOWJKancrWENJbllEMWRMMmNzWEc0Z0lDQWdJQ0J3YjNOemFXSnNaU0E5SUM5YkpqdytYQ0luWUQxZEx6dGNibHh1Wm5WdVkzUnBiMjRnWlhOallYQmxRMmhoY2loamFISXBJSHRjYmlBZ2NtVjBkWEp1SUdWelkyRndaVnRqYUhKZE8xeHVmVnh1WEc1bGVIQnZjblFnWm5WdVkzUnBiMjRnWlhoMFpXNWtLRzlpYWk4cUlDd2dMaTR1YzI5MWNtTmxJQ292S1NCN1hHNGdJR1p2Y2lBb2JHVjBJR2tnUFNBeE95QnBJRHdnWVhKbmRXMWxiblJ6TG14bGJtZDBhRHNnYVNzcktTQjdYRzRnSUNBZ1ptOXlJQ2hzWlhRZ2EyVjVJR2x1SUdGeVozVnRaVzUwYzF0cFhTa2dlMXh1SUNBZ0lDQWdhV1lnS0U5aWFtVmpkQzV3Y205MGIzUjVjR1V1YUdGelQzZHVVSEp2Y0dWeWRIa3VZMkZzYkNoaGNtZDFiV1Z1ZEhOYmFWMHNJR3RsZVNrcElIdGNiaUFnSUNBZ0lDQWdiMkpxVzJ0bGVWMGdQU0JoY21kMWJXVnVkSE5iYVYxYmEyVjVYVHRjYmlBZ0lDQWdJSDFjYmlBZ0lDQjlYRzRnSUgxY2JseHVJQ0J5WlhSMWNtNGdiMkpxTzF4dWZWeHVYRzVsZUhCdmNuUWdiR1YwSUhSdlUzUnlhVzVuSUQwZ1QySnFaV04wTG5CeWIzUnZkSGx3WlM1MGIxTjBjbWx1Wnp0Y2JseHVMeThnVTI5MWNtTmxaQ0JtY205dElHeHZaR0Z6YUZ4dUx5OGdhSFIwY0hNNkx5OW5hWFJvZFdJdVkyOXRMMkpsYzNScFpXcHpMMnh2WkdGemFDOWliRzlpTDIxaGMzUmxjaTlNU1VORlRsTkZMblI0ZEZ4dUx5b2daWE5zYVc1MExXUnBjMkZpYkdVZ1puVnVZeTF6ZEhsc1pTQXFMMXh1YkdWMElHbHpSblZ1WTNScGIyNGdQU0JtZFc1amRHbHZiaWgyWVd4MVpTa2dlMXh1SUNCeVpYUjFjbTRnZEhsd1pXOW1JSFpoYkhWbElEMDlQU0FuWm5WdVkzUnBiMjRuTzF4dWZUdGNiaTh2SUdaaGJHeGlZV05ySUdadmNpQnZiR1JsY2lCMlpYSnphVzl1Y3lCdlppQkRhSEp2YldVZ1lXNWtJRk5oWm1GeWFWeHVMeW9nYVhOMFlXNWlkV3dnYVdkdWIzSmxJRzVsZUhRZ0tpOWNibWxtSUNocGMwWjFibU4wYVc5dUtDOTRMeWtwSUh0Y2JpQWdhWE5HZFc1amRHbHZiaUE5SUdaMWJtTjBhVzl1S0haaGJIVmxLU0I3WEc0Z0lDQWdjbVYwZFhKdUlIUjVjR1Z2WmlCMllXeDFaU0E5UFQwZ0oyWjFibU4wYVc5dUp5QW1KaUIwYjFOMGNtbHVaeTVqWVd4c0tIWmhiSFZsS1NBOVBUMGdKMXR2WW1wbFkzUWdSblZ1WTNScGIyNWRKenRjYmlBZ2ZUdGNibjFjYm1WNGNHOXlkQ0I3YVhOR2RXNWpkR2x2Ym4wN1hHNHZLaUJsYzJ4cGJuUXRaVzVoWW14bElHWjFibU10YzNSNWJHVWdLaTljYmx4dUx5b2dhWE4wWVc1aWRXd2dhV2R1YjNKbElHNWxlSFFnS2k5Y2JtVjRjRzl5ZENCamIyNXpkQ0JwYzBGeWNtRjVJRDBnUVhKeVlYa3VhWE5CY25KaGVTQjhmQ0JtZFc1amRHbHZiaWgyWVd4MVpTa2dlMXh1SUNCeVpYUjFjbTRnS0haaGJIVmxJQ1ltSUhSNWNHVnZaaUIyWVd4MVpTQTlQVDBnSjI5aWFtVmpkQ2NwSUQ4Z2RHOVRkSEpwYm1jdVkyRnNiQ2gyWVd4MVpTa2dQVDA5SUNkYmIySnFaV04wSUVGeWNtRjVYU2NnT2lCbVlXeHpaVHRjYm4wN1hHNWNiaTh2SUU5c1pHVnlJRWxGSUhabGNuTnBiMjV6SUdSdklHNXZkQ0JrYVhKbFkzUnNlU0J6ZFhCd2IzSjBJR2x1WkdWNFQyWWdjMjhnZDJVZ2JYVnpkQ0JwYlhCc1pXMWxiblFnYjNWeUlHOTNiaXdnYzJGa2JIa3VYRzVsZUhCdmNuUWdablZ1WTNScGIyNGdhVzVrWlhoUFppaGhjbkpoZVN3Z2RtRnNkV1VwSUh0Y2JpQWdabTl5SUNoc1pYUWdhU0E5SURBc0lHeGxiaUE5SUdGeWNtRjVMbXhsYm1kMGFEc2dhU0E4SUd4bGJqc2dhU3NyS1NCN1hHNGdJQ0FnYVdZZ0tHRnljbUY1VzJsZElEMDlQU0IyWVd4MVpTa2dlMXh1SUNBZ0lDQWdjbVYwZFhKdUlHazdYRzRnSUNBZ2ZWeHVJQ0I5WEc0Z0lISmxkSFZ5YmlBdE1UdGNibjFjYmx4dVhHNWxlSEJ2Y25RZ1puVnVZM1JwYjI0Z1pYTmpZWEJsUlhod2NtVnpjMmx2YmloemRISnBibWNwSUh0Y2JpQWdhV1lnS0hSNWNHVnZaaUJ6ZEhKcGJtY2dJVDA5SUNkemRISnBibWNuS1NCN1hHNGdJQ0FnTHk4Z1pHOXVKM1FnWlhOallYQmxJRk5oWm1WVGRISnBibWR6TENCemFXNWpaU0IwYUdWNUozSmxJR0ZzY21WaFpIa2djMkZtWlZ4dUlDQWdJR2xtSUNoemRISnBibWNnSmlZZ2MzUnlhVzVuTG5SdlNGUk5UQ2tnZTF4dUlDQWdJQ0FnY21WMGRYSnVJSE4wY21sdVp5NTBiMGhVVFV3b0tUdGNiaUFnSUNCOUlHVnNjMlVnYVdZZ0tITjBjbWx1WnlBOVBTQnVkV3hzS1NCN1hHNGdJQ0FnSUNCeVpYUjFjbTRnSnljN1hHNGdJQ0FnZlNCbGJITmxJR2xtSUNnaGMzUnlhVzVuS1NCN1hHNGdJQ0FnSUNCeVpYUjFjbTRnYzNSeWFXNW5JQ3NnSnljN1hHNGdJQ0FnZlZ4dVhHNGdJQ0FnTHk4Z1JtOXlZMlVnWVNCemRISnBibWNnWTI5dWRtVnljMmx2YmlCaGN5QjBhR2x6SUhkcGJHd2dZbVVnWkc5dVpTQmllU0IwYUdVZ1lYQndaVzVrSUhKbFoyRnlaR3hsYzNNZ1lXNWtYRzRnSUNBZ0x5OGdkR2hsSUhKbFoyVjRJSFJsYzNRZ2QybHNiQ0JrYnlCMGFHbHpJSFJ5WVc1emNHRnlaVzUwYkhrZ1ltVm9hVzVrSUhSb1pTQnpZMlZ1WlhNc0lHTmhkWE5wYm1jZ2FYTnpkV1Z6SUdsbVhHNGdJQ0FnTHk4Z1lXNGdiMkpxWldOMEozTWdkRzhnYzNSeWFXNW5JR2hoY3lCbGMyTmhjR1ZrSUdOb1lYSmhZM1JsY25NZ2FXNGdhWFF1WEc0Z0lDQWdjM1J5YVc1bklEMGdKeWNnS3lCemRISnBibWM3WEc0Z0lIMWNibHh1SUNCcFppQW9JWEJ2YzNOcFlteGxMblJsYzNRb2MzUnlhVzVuS1NrZ2V5QnlaWFIxY200Z2MzUnlhVzVuT3lCOVhHNGdJSEpsZEhWeWJpQnpkSEpwYm1jdWNtVndiR0ZqWlNoaVlXUkRhR0Z5Y3l3Z1pYTmpZWEJsUTJoaGNpazdYRzU5WEc1Y2JtVjRjRzl5ZENCbWRXNWpkR2x2YmlCcGMwVnRjSFI1S0haaGJIVmxLU0I3WEc0Z0lHbG1JQ2doZG1Gc2RXVWdKaVlnZG1Gc2RXVWdJVDA5SURBcElIdGNiaUFnSUNCeVpYUjFjbTRnZEhKMVpUdGNiaUFnZlNCbGJITmxJR2xtSUNocGMwRnljbUY1S0haaGJIVmxLU0FtSmlCMllXeDFaUzVzWlc1bmRHZ2dQVDA5SURBcElIdGNiaUFnSUNCeVpYUjFjbTRnZEhKMVpUdGNiaUFnZlNCbGJITmxJSHRjYmlBZ0lDQnlaWFIxY200Z1ptRnNjMlU3WEc0Z0lIMWNibjFjYmx4dVpYaHdiM0owSUdaMWJtTjBhVzl1SUdOeVpXRjBaVVp5WVcxbEtHOWlhbVZqZENrZ2UxeHVJQ0JzWlhRZ1puSmhiV1VnUFNCbGVIUmxibVFvZTMwc0lHOWlhbVZqZENrN1hHNGdJR1p5WVcxbExsOXdZWEpsYm5RZ1BTQnZZbXBsWTNRN1hHNGdJSEpsZEhWeWJpQm1jbUZ0WlR0Y2JuMWNibHh1Wlhod2IzSjBJR1oxYm1OMGFXOXVJR0pzYjJOclVHRnlZVzF6S0hCaGNtRnRjeXdnYVdSektTQjdYRzRnSUhCaGNtRnRjeTV3WVhSb0lEMGdhV1J6TzF4dUlDQnlaWFIxY200Z2NHRnlZVzF6TzF4dWZWeHVYRzVsZUhCdmNuUWdablZ1WTNScGIyNGdZWEJ3Wlc1a1EyOXVkR1Y0ZEZCaGRHZ29ZMjl1ZEdWNGRGQmhkR2dzSUdsa0tTQjdYRzRnSUhKbGRIVnliaUFvWTI5dWRHVjRkRkJoZEdnZ1B5QmpiMjUwWlhoMFVHRjBhQ0FySUNjdUp5QTZJQ2NuS1NBcklHbGtPMXh1ZlZ4dUlsMTlcbiIsIi8vIENyZWF0ZSBhIHNpbXBsZSBwYXRoIGFsaWFzIHRvIGFsbG93IGJyb3dzZXJpZnkgdG8gcmVzb2x2ZVxuLy8gdGhlIHJ1bnRpbWUgb24gYSBzdXBwb3J0ZWQgcGF0aC5cbm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnLi9kaXN0L2Nqcy9oYW5kbGViYXJzLnJ1bnRpbWUnKVsnZGVmYXVsdCddO1xuIiwidmFyIGc7XG5cbi8vIFRoaXMgd29ya3MgaW4gbm9uLXN0cmljdCBtb2RlXG5nID0gKGZ1bmN0aW9uKCkge1xuXHRyZXR1cm4gdGhpcztcbn0pKCk7XG5cbnRyeSB7XG5cdC8vIFRoaXMgd29ya3MgaWYgZXZhbCBpcyBhbGxvd2VkIChzZWUgQ1NQKVxuXHRnID0gZyB8fCBuZXcgRnVuY3Rpb24oXCJyZXR1cm4gdGhpc1wiKSgpO1xufSBjYXRjaCAoZSkge1xuXHQvLyBUaGlzIHdvcmtzIGlmIHRoZSB3aW5kb3cgcmVmZXJlbmNlIGlzIGF2YWlsYWJsZVxuXHRpZiAodHlwZW9mIHdpbmRvdyA9PT0gXCJvYmplY3RcIikgZyA9IHdpbmRvdztcbn1cblxuLy8gZyBjYW4gc3RpbGwgYmUgdW5kZWZpbmVkLCBidXQgbm90aGluZyB0byBkbyBhYm91dCBpdC4uLlxuLy8gV2UgcmV0dXJuIHVuZGVmaW5lZCwgaW5zdGVhZCBvZiBub3RoaW5nIGhlcmUsIHNvIGl0J3Ncbi8vIGVhc2llciB0byBoYW5kbGUgdGhpcyBjYXNlLiBpZighZ2xvYmFsKSB7IC4uLn1cblxubW9kdWxlLmV4cG9ydHMgPSBnO1xuIiwidmFyIEhhbmRsZWJhcnMgPSByZXF1aXJlKFwiLi4vLi4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvcnVudGltZS5qc1wiKTtcbmZ1bmN0aW9uIF9fZGVmYXVsdChvYmopIHsgcmV0dXJuIG9iaiAmJiAob2JqLl9fZXNNb2R1bGUgPyBvYmpbXCJkZWZhdWx0XCJdIDogb2JqKTsgfVxubW9kdWxlLmV4cG9ydHMgPSAoSGFuZGxlYmFyc1tcImRlZmF1bHRcIl0gfHwgSGFuZGxlYmFycykudGVtcGxhdGUoe1wiY29tcGlsZXJcIjpbNyxcIj49IDQuMC4wXCJdLFwibWFpblwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMTtcblxuICByZXR1cm4gKChzdGFjazEgPSBjb250YWluZXIuaW52b2tlUGFydGlhbChyZXF1aXJlKFwiLi9fbWVldGluZ19jYXJkLmhic1wiKSxkZXB0aDAse1wibmFtZVwiOlwiX21lZXRpbmdfY2FyZFwiLFwiZGF0YVwiOmRhdGEsXCJoZWxwZXJzXCI6aGVscGVycyxcInBhcnRpYWxzXCI6cGFydGlhbHMsXCJkZWNvcmF0b3JzXCI6Y29udGFpbmVyLmRlY29yYXRvcnN9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpXG4gICAgKyBcIlxcblxcblwiO1xufSxcInVzZVBhcnRpYWxcIjp0cnVlLFwidXNlRGF0YVwiOnRydWV9KTsiLCJ2YXIgSGFuZGxlYmFycyA9IHJlcXVpcmUoXCIuLi8uLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9ydW50aW1lLmpzXCIpO1xuZnVuY3Rpb24gX19kZWZhdWx0KG9iaikgeyByZXR1cm4gb2JqICYmIChvYmouX19lc01vZHVsZSA/IG9ialtcImRlZmF1bHRcIl0gOiBvYmopOyB9XG5tb2R1bGUuZXhwb3J0cyA9IChIYW5kbGViYXJzW1wiZGVmYXVsdFwiXSB8fCBIYW5kbGViYXJzKS50ZW1wbGF0ZSh7XCIxXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgaGVscGVyLCBhbGlhczE9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwgYWxpYXMyPWhlbHBlcnMuaGVscGVyTWlzc2luZywgYWxpYXMzPVwiZnVuY3Rpb25cIiwgYWxpYXM0PWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uO1xuXG4gIHJldHVybiBcIiAgICAgICAgICAgICAgPGlucHV0IHR5cGU9XFxcImNoZWNrYm94XFxcIiBuYW1lPVxcXCJtZWV0aW5nQ2FyZFxcXCIgXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmNoZWNrZWQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmNoZWNrZWQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImNoZWNrZWRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiIGRhdGEtdXVpZD0nXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnV1aWQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnV1aWQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcInV1aWRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiJyBpZD1cXFwibWVldGluZ0NhcmRfXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnV1aWQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnV1aWQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcInV1aWRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBjbGFzcz1cXFwic2VsZWN0YWJsZVxcXCI+XFxuXCI7XG59LFwiM1wiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgcmV0dXJuIFwiICAgICAgICAgICAgICA8aW5wdXQgdHlwZT1cXFwiY2hlY2tib3hcXFwiIG5hbWU9XFxcIm1lZXRpbmdDYXJkXFxcIiBjbGFzcz1cXFwibm8taG92ZXJcXFwiIGRpc2FibGVkPlxcblwiO1xufSxcIjVcIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSkge1xuICAgIHZhciBoZWxwZXI7XG5cbiAgcmV0dXJuIFwiICAgICAgICAgICAgICAgICBcIlxuICAgICsgY29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb24oKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5tZWV0aW5nVHlwZSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAubWVldGluZ1R5cGUgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogaGVscGVycy5oZWxwZXJNaXNzaW5nKSwodHlwZW9mIGhlbHBlciA9PT0gXCJmdW5jdGlvblwiID8gaGVscGVyLmNhbGwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSx7XCJuYW1lXCI6XCJtZWV0aW5nVHlwZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXG5cIjtcbn0sXCI3XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICByZXR1cm4gXCIgICAgICAgICAgICAgICAgIE1cXG5cIjtcbn0sXCI5XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgaGVscGVyLCBhbGlhczE9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwgYWxpYXMyPWhlbHBlcnMuaGVscGVyTWlzc2luZywgYWxpYXMzPVwiZnVuY3Rpb25cIiwgYWxpYXM0PWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uO1xuXG4gIHJldHVybiBcIiAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiZm9udC1sZyBtZWV0aW5nLXRpdGxlXFxcIiB0aXRsZT1cXFwiXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmJyaWVmaW5nX21lZXRpbmdfdGl0bGUgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmJyaWVmaW5nX21lZXRpbmdfdGl0bGUgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImJyaWVmaW5nX21lZXRpbmdfdGl0bGVcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIj5cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuYnJpZWZpbmdfbWVldGluZ190aXRsZSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuYnJpZWZpbmdfbWVldGluZ190aXRsZSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiYnJpZWZpbmdfbWVldGluZ190aXRsZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCI8L2Rpdj5cXG5cIjtcbn0sXCIxMVwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIGhlbHBlciwgYWxpYXMxPWRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSksIGFsaWFzMj1oZWxwZXJzLmhlbHBlck1pc3NpbmcsIGFsaWFzMz1cImZ1bmN0aW9uXCIsIGFsaWFzND1jb250YWluZXIuZXNjYXBlRXhwcmVzc2lvbjtcblxuICByZXR1cm4gXCIgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImZvbnQtbGcgbWVldGluZy10aXRsZVxcXCIgdGl0bGU9XFxcIlwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5tZWV0aW5nX3dpdGggfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLm1lZXRpbmdfd2l0aCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwibWVldGluZ193aXRoXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCI+XCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLm1lZXRpbmdfd2l0aCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAubWVldGluZ193aXRoIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJtZWV0aW5nX3dpdGhcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9kaXY+IFxcblwiO1xufSxcIjEzXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgaGVscGVyLCBhbGlhczE9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwgYWxpYXMyPWhlbHBlcnMuaGVscGVyTWlzc2luZywgYWxpYXMzPVwiZnVuY3Rpb25cIiwgYWxpYXM0PWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uO1xuXG4gIHJldHVybiBcIiAgICAgICAgICAgICAgICAgIDxzcGFuIGNsYXNzPVxcXCJmb250LXNtXFxcIj5cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuc3RhcnREYXRlVGltZSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuc3RhcnREYXRlVGltZSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwic3RhcnREYXRlVGltZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCI8L3NwYW4+XFxuICAgICAgICAgICAgICAgICAgPGJyPlxcbiAgICAgICAgICAgICAgICAgIDxzcGFuIGNsYXNzPVxcXCJmb250LXNtXFxcIj5cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuZW5kRGF0ZVRpbWUgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmVuZERhdGVUaW1lIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJlbmREYXRlVGltZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCI8L3NwYW4+XFxuICAgICAgICAgICAgICAgICAgPGJyPlxcblwiO1xufSxcIjE1XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgaGVscGVyLCBhbGlhczE9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwgYWxpYXMyPWhlbHBlcnMuaGVscGVyTWlzc2luZywgYWxpYXMzPVwiZnVuY3Rpb25cIiwgYWxpYXM0PWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uO1xuXG4gIHJldHVybiBcIiAgICAgICAgICAgICAgICAgIDxzcGFuIGNsYXNzPVxcXCJmb250LXNlbWktYm9sZFxcXCI+XCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnN0YXJ0VGltZSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuc3RhcnRUaW1lIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJzdGFydFRpbWVcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiIC0gXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmVuZFRpbWUgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmVuZFRpbWUgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImVuZFRpbWVcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9zcGFuPlxcbiAgICAgICAgICAgICAgICAgIDxicj5cXG4gICAgICAgICAgICAgICAgICA8c3BhbiBjbGFzcz1cXFwiZm9udC1zbVxcXCI+XCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLm1lZXRpbmdEYXRlIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5tZWV0aW5nRGF0ZSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwibWVldGluZ0RhdGVcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9zcGFuPlxcblwiO1xufSxcIjE3XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgc3RhY2sxLCBoZWxwZXIsIGFsaWFzMT1kZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLCBhbGlhczI9aGVscGVycy5oZWxwZXJNaXNzaW5nLCBhbGlhczM9XCJmdW5jdGlvblwiLCBhbGlhczQ9Y29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb24sIGFsaWFzNT1jb250YWluZXIubGFtYmRhO1xuXG4gIHJldHVybiBcIlxcbiAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwibWVldGluZy1hcHByb3ZlZCBcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuYXBwcm92ZWQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmFwcHJvdmVkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJhcHByb3ZlZFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiPlxcbiAgICAgICAgICAgICAgICA8c3BhbiBjbGFzcz1cXFwiZm9udC1ibHVlXFxcIj5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImFwcHJvdmVkXCIse1wibmFtZVwiOlwidFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSlcbiAgICArIFwiPC9zcGFuPlxcbiAgICAgICAgICAgICAgPC9kaXY+XFxuXFxuICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJtZWV0aW5nLWFwcHJvdmUgXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLkFwcHJvdmUgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLkFwcHJvdmUgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcIkFwcHJvdmVcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBkYXRhLXVybD1cXFwiXCJcbiAgICArIGFsaWFzNChhbGlhczUoKChzdGFjazEgPSAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuYWN0aW9uc191cmxzIDogZGVwdGgwKSkgIT0gbnVsbCA/IHN0YWNrMS5hcHByb3ZlX21lZXRpbmdfdXJsIDogc3RhY2sxKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIj5cXG4gICAgICAgICAgICAgICAgPGEgaHJlZj1cXFwiamF2YXNjcmlwdDp2b2lkKDApXFxcIiBjbGFzcz1cXFwiaWNvbi1ib3ggamlmLWJsdWVcXFwiPlxcbiAgICAgICAgICAgICAgICAgIDxpIGNsYXNzPVxcXCJqaWYtY2hlY2tcXFwiPjwvaT5cXG4gICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJmb250LThcXFwiPlwiXG4gICAgKyBhbGlhczQoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMxLFwiYXBwcm92ZVwiLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIjwvZGl2PlxcbiAgICAgICAgICAgICAgICA8L2E+XFxuICAgICAgICAgICAgICA8L2Rpdj5cXG5cXG4gICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcIm1lZXRpbmctYXBwcm92ZS1hbGwgXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmFwcHJvdmVfYWxsIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5hcHByb3ZlX2FsbCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiYXBwcm92ZV9hbGxcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBkYXRhLXVybD1cXFwiXCJcbiAgICArIGFsaWFzNChhbGlhczUoKChzdGFjazEgPSAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuYWN0aW9uX3VybHMgOiBkZXB0aDApKSAhPSBudWxsID8gc3RhY2sxLmFwcHJvdmVfYWxsX3VybCA6IHN0YWNrMSksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCI+XFxuICAgICAgICAgICAgICAgIDxhIGhyZWY9XFxcImphdmFzY3JpcHQ6dm9pZCgwKVxcXCIgY2xhc3M9XFxcImljb24tYm94IGppZi1ibHVlXFxcIj5cXG4gICAgICAgICAgICAgICAgICA8aSBjbGFzcz1cXFwiamlmLWNoZWNrXFxcIj48L2k+XFxuICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiZm9udC04XFxcIj5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImFwcHJvdmVfYWxsXCIse1wibmFtZVwiOlwidFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICAgIDwvYT5cXG4gICAgICAgICAgICAgIDwvZGl2PlxcblxcbiAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwibWVldGluZy1jYW5jZWxsZWQgXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmNhbmNlbGxlZCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuY2FuY2VsbGVkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJjYW5jZWxsZWRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIj5cXG4gICAgICAgICAgICAgICAgPHNwYW4gY2xhc3M9XFxcImZvbnQtcmVkXFxcIj5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImNhbmNlbGxlZFwiLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIjwvc3Bhbj5cXG4gICAgICAgICAgICAgIDwvZGl2PlxcblxcbiAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwibWVldGluZy1jYW5jZWwgXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLkNhbmNlbCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuQ2FuY2VsIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJDYW5jZWxcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBkYXRhLXVybD1cXFwiXCJcbiAgICArIGFsaWFzNChhbGlhczUoKChzdGFjazEgPSAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuYWN0aW9uc191cmxzIDogZGVwdGgwKSkgIT0gbnVsbCA/IHN0YWNrMS5jYW5jZWxfbWVldGluZ191cmwgOiBzdGFjazEpLCBkZXB0aDApKVxuICAgICsgXCJcXFwiPlxcbiAgICAgICAgICAgICAgICA8YSBocmVmPVxcXCJqYXZhc2NyaXB0OnZvaWQoMClcXFwiIGNsYXNzPVxcXCJpY29uLWJveCBqaWYtcmVkXFxcIj5cXG4gICAgICAgICAgICAgICAgICA8aSBjbGFzcz1cXFwiamlmLXRyYXNoXFxcIj48L2k+XFxuICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiZm9udC04XFxcIj5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImNhbmNlbFwiLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIjwvZGl2PlxcbiAgICAgICAgICAgICAgICA8L2E+XFxuICAgICAgICAgICAgICA8L2Rpdj5cXG5cXG4gICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcIm1lZXRpbmctY2FuY2VsLWFsbCBcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuY2FuY2VsX2FsbCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuY2FuY2VsX2FsbCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiY2FuY2VsX2FsbFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiIGRhdGEtdXJsPVxcXCJcIlxuICAgICsgYWxpYXM0KGFsaWFzNSgoKHN0YWNrMSA9IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5hY3Rpb25fdXJscyA6IGRlcHRoMCkpICE9IG51bGwgPyBzdGFjazEuY2FuY2VsX2FsbF91cmwgOiBzdGFjazEpLCBkZXB0aDApKVxuICAgICsgXCJcXFwiPlxcbiAgICAgICAgICAgICAgICA8YSBocmVmPVxcXCJqYXZhc2NyaXB0OnZvaWQoMClcXFwiIGNsYXNzPVxcXCJpY29uLWJveCBqaWYtcmVkXFxcIj5cXG4gICAgICAgICAgICAgICAgICA8aSBjbGFzcz1cXFwiamlmLXRyYXNoXFxcIj48L2k+XFxuICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiZm9udC04XFxcIj5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImNhbmNlbF9hbGxcIix7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCI8L2Rpdj5cXG4gICAgICAgICAgICAgICAgPC9hPlxcbiAgICAgICAgICAgICAgPC9kaXY+XFxuXFxuICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJtZWV0aW5nLWFjY2VwdGVkIFwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5hY2NlcHRlZCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuYWNjZXB0ZWQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImFjY2VwdGVkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCI+XFxuICAgICAgICAgICAgICAgIDxzcGFuIGNsYXNzPVxcXCJmb250LWJsdWVcXFwiPlwiXG4gICAgKyBhbGlhczQoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMxLFwiYWNjZXB0ZWRcIix7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCI8L3NwYW4+XFxuICAgICAgICAgICAgICA8L2Rpdj5cXG5cXG4gICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcIm1lZXRpbmctYWNjZXB0IFwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5BY2NlcHQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLkFjY2VwdCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiQWNjZXB0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCIgZGF0YS11cmw9XFxcIlwiXG4gICAgKyBhbGlhczQoYWxpYXM1KCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmFjdGlvbnNfdXJscyA6IGRlcHRoMCkpICE9IG51bGwgPyBzdGFjazEuYWNjZXB0X21lZXRpbmdfdXJsIDogc3RhY2sxKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIj5cXG4gICAgICAgICAgICAgICAgPGEgaHJlZj1cXFwiamF2YXNjcmlwdDp2b2lkKDApXFxcIiBjbGFzcz1cXFwiaWNvbi1ib3ggamlmLWJsdWVcXFwiPlxcbiAgICAgICAgICAgICAgICAgIDxpIGNsYXNzPVxcXCJqaWYtY2hlY2tcXFwiPjwvaT5cXG4gICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJmb250LThcXFwiPlwiXG4gICAgKyBhbGlhczQoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMxLFwiYWNjZXB0XCIse1wibmFtZVwiOlwidFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICAgIDwvYT5cXG4gICAgICAgICAgICAgIDwvZGl2PlxcblxcbiAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwibWVldGluZy1kZWNsaW5lZCBcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuZGVjbGluZWQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmRlY2xpbmVkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJkZWNsaW5lZFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiPlxcbiAgICAgICAgICAgICAgICA8c3BhbiBjbGFzcz1cXFwiZm9udC1yZWRcXFwiPlwiXG4gICAgKyBhbGlhczQoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMxLFwiZGVjbGluZWRcIix7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCI8L3NwYW4+XFxuICAgICAgICAgICAgICA8L2Rpdj5cXG5cXG5cXG4gICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcIm1lZXRpbmctZGVjbGluZSBcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuRGVjbGluZSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuRGVjbGluZSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiRGVjbGluZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiIGRhdGEtdXJsPVxcXCJcIlxuICAgICsgYWxpYXM0KGFsaWFzNSgoKHN0YWNrMSA9IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5hY3Rpb25zX3VybHMgOiBkZXB0aDApKSAhPSBudWxsID8gc3RhY2sxLmRlY2xpbmVfbWVldGluZ191cmwgOiBzdGFjazEpLCBkZXB0aDApKVxuICAgICsgXCJcXFwiPlxcbiAgICAgICAgICAgICAgICA8YSBocmVmPVxcXCJqYXZhc2NyaXB0OnZvaWQoMClcXFwiIGNsYXNzPVxcXCJpY29uLWJveCBqaWYtcmVkXFxcIj5cXG4gICAgICAgICAgICAgICAgICA8aSBjbGFzcz1cXFwiamlmLWNsb3NlXFxcIj48L2k+XFxuICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiZm9udC04XFxcIj5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImRlY2xpbmVcIix7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCI8L2Rpdj5cXG4gICAgICAgICAgICAgICAgPC9hPlxcbiAgICAgICAgICAgICAgPC9kaXY+XFxuXFxuICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJtZWV0aW5nLXN1bW1hcnkgaGlkZVxcXCI+XFxuICAgICAgICAgICAgICAgIDxhIGhyZWY9XFxcImphdmFzY3JpcHQ6dm9pZCgwKVxcXCIgY2xhc3M9XFxcImljb24tYm94IGppZi1ibHVlXFxcIj5cXG4gICAgICAgICAgICAgICAgICA8aSBjbGFzcz1cXFwiamlmLXN1bW1hcnlcXFwiPjwvaT5cXG4gICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJmb250LThcXFwiPlwiXG4gICAgKyBhbGlhczQoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMxLFwic3VtbWFyeVwiLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIjwvZGl2PlxcbiAgICAgICAgICAgICAgICA8L2E+XFxuICAgICAgICAgICAgICA8L2Rpdj5cXG5cIjtcbn0sXCJjb21waWxlclwiOls3LFwiPj0gNC4wLjBcIl0sXCJtYWluXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgc3RhY2sxLCBoZWxwZXIsIGFsaWFzMT1kZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLCBhbGlhczI9aGVscGVycy5oZWxwZXJNaXNzaW5nLCBhbGlhczM9XCJmdW5jdGlvblwiLCBhbGlhczQ9Y29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb247XG5cbiAgcmV0dXJuIFwiPGRpdiBjbGFzcz1cXFwiY2FyZCBtZWV0aW5nLWNhcmQgXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnN0YXR1cyB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuc3RhdHVzIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJzdGF0dXNcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBkYXRhLXV1aWQ9J1wiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIicgaWQ9XFxcIlwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCI+XFxuICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1oZWFkZXJcXFwiPlxcbiAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1oZWFkZXItY29udGVudFxcXCI+XFxuICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtc2VsZWN0XFxcIj5cXG5cIlxuICAgICsgKChzdGFjazEgPSBoZWxwZXJzW1wiaWZcIl0uY2FsbChhbGlhczEsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmVkaXQgOiBkZXB0aDApLHtcIm5hbWVcIjpcImlmXCIsXCJoYXNoXCI6e30sXCJmblwiOmNvbnRhaW5lci5wcm9ncmFtKDEsIGRhdGEsIDApLFwiaW52ZXJzZVwiOmNvbnRhaW5lci5wcm9ncmFtKDMsIGRhdGEsIDApLFwiZGF0YVwiOmRhdGF9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpXG4gICAgKyBcIiAgICAgICAgICAgIDxsYWJlbCBmb3I9XFxcIm1lZXRpbmdDYXJkX1wiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCI+XFxuICAgICAgICAgICAgICA8ZGl2PlxcblwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnNbXCJpZlwiXS5jYWxsKGFsaWFzMSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAubWVldGluZ1R5cGUgOiBkZXB0aDApLHtcIm5hbWVcIjpcImlmXCIsXCJoYXNoXCI6e30sXCJmblwiOmNvbnRhaW5lci5wcm9ncmFtKDUsIGRhdGEsIDApLFwiaW52ZXJzZVwiOmNvbnRhaW5lci5wcm9ncmFtKDcsIGRhdGEsIDApLFwiZGF0YVwiOmRhdGF9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpXG4gICAgKyBcIiAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgPC9sYWJlbD5cXG4gICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtY2xpY2sgbWVldGluZ1JldmVhbENsc1xcXCIgZGF0YS11dWlkPSdcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMudXVpZCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAudXVpZCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwidXVpZFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCInPlxcblwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnNbXCJpZlwiXS5jYWxsKGFsaWFzMSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuYnJpZWZpbmdfbWVldGluZ190aXRsZSA6IGRlcHRoMCkse1wibmFtZVwiOlwiaWZcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oOSwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLnByb2dyYW0oMTEsIGRhdGEsIDApLFwiZGF0YVwiOmRhdGF9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpXG4gICAgKyBcIiAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImZvbnQtbGdcXFwiPlwiXG4gICAgKyBhbGlhczQoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMxLFwiSURcIix7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCIgI1wiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5pZCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuaWQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIjwvZGl2PlxcbiAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgIDwvZGl2PlxcbiAgICAgIDwvZGl2PlxcbiAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtY29udGVudCBtZWV0aW5nUmV2ZWFsQ2xzXFxcIiBkYXRhLXV1aWQ9J1wiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIic+XFxuICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWRldGFpbC1jb250ZW50XFxcIj5cXG4gICAgICAgICAgPGRpdj5cXG4gICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWRldGFpbCBpY29uLXNlcFxcXCI+XFxuICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJ0ZXh0LWNvbnRlbnRcXFwiPlxcblwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnNbXCJpZlwiXS5jYWxsKGFsaWFzMSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAubXVsdGlwbGVEYXlEaXNwbGF5Rm9ybWF0IDogZGVwdGgwKSx7XCJuYW1lXCI6XCJpZlwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSgxMywgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLnByb2dyYW0oMTUsIGRhdGEsIDApLFwiZGF0YVwiOmRhdGF9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpXG4gICAgKyBcIiAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJpY29uLWNvbnRlbnQgaGlkZSBqaWYtYmx1ZSB0ZXh0LWNlbnRlciBpY29uLWJveFxcXCI+XFxuICAgICAgICAgICAgICAgIDxpIGNsYXNzPVxcXCJqaWYtY2hlY2tpblxcXCI+PC9pPlxcbiAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJmb250LThcXFwiPlwiXG4gICAgKyBhbGlhczQoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMxLFwiY2hlY2tpblwiLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIjwvZGl2PlxcbiAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1kZXRhaWwgaWNvbi1zZXBcXFwiPlxcbiAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwidGV4dC1jb250ZW50IGxvY2F0aW9uLXRleHQgdHdvLWxpbmUtZWxsaXBzaXNcXFwiIHRpdGxlPVxcXCJcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMubG9jYXRpb24gfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmxvY2F0aW9uIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJsb2NhdGlvblwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiPlxcbiAgICAgICAgICAgICAgICBcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMubG9jYXRpb24gfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmxvY2F0aW9uIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJsb2NhdGlvblwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXG4gICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiaWNvbi1jb250ZW50IGhpZGUgamlmLWJsdWUgdGV4dC1jZW50ZXIgaWNvbi1ib3hcXFwiPlxcbiAgICAgICAgICAgICAgICA8aSBjbGFzcz1cXFwiamlmLWxvY2F0aW9uXFxcIj48L2k+XFxuICAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImZvbnQtOFxcXCIgdGl0bD5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImxvY2F0aW9uXCIse1wibmFtZVwiOlwidFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtZGV0YWlsIGNvdW50XFxcIj5cXG4gICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJpdGVtLXNlY3Rpb24gYXR0ZWRlZS1jb3VudHNcXFwiPlxcbiAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwic2VjdGlvbi1jb3VudCBhY2NlcHRlZFxcXCI+XFxuICAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImNvdW50XFxcIj5cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuYWNjZXB0ZWRDb3VudCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuYWNjZXB0ZWRDb3VudCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiYWNjZXB0ZWRDb3VudFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCI8L2Rpdj5cXG4gICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwic3RhdHVzXFxcIj5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImFjY2VwdGVkXCIse1wibmFtZVwiOlwidFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcInNlY3Rpb24tY291bnQgZGVjbGluZWRcXFwiPlxcbiAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjb3VudFxcXCI+XCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmRlY2xpbmVkQ291bnQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmRlY2xpbmVkQ291bnQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImRlY2xpbmVkQ291bnRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcInN0YXR1c1xcXCI+XCJcbiAgICArIGFsaWFzNChfX2RlZmF1bHQocmVxdWlyZShcIi4uL2hlbHBlcnMvdC5qc1wiKSkuY2FsbChhbGlhczEsXCJkZWNsaW5lZFwiLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIjwvZGl2PlxcbiAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJzZWN0aW9uLWNvdW50IHBlbmRpbmdcXFwiPlxcbiAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjb3VudFxcXCI+XCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnBlbmRpbmdDb3VudCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAucGVuZGluZ0NvdW50IDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJwZW5kaW5nQ291bnRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcInN0YXR1c1xcXCI+XCJcbiAgICArIGFsaWFzNChfX2RlZmF1bHQocmVxdWlyZShcIi4uL2hlbHBlcnMvdC5qc1wiKSkuY2FsbChhbGlhczEsXCJwZW5kaW5nXCIse1wibmFtZVwiOlwidFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgPC9kaXY+XFxuICAgICAgICA8L2Rpdj5cXG4gICAgICA8L2Rpdj5cXG4gICAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWZvb3RlclxcXCI+XFxuICAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1mb290ZXItY29udGVudFxcXCI+XFxuXCJcbiAgICArICgoc3RhY2sxID0gaGVscGVyc1tcImlmXCJdLmNhbGwoYWxpYXMxLChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5zaG93VXNlckFjdGlvbnMgOiBkZXB0aDApLHtcIm5hbWVcIjpcImlmXCIsXCJoYXNoXCI6e30sXCJmblwiOmNvbnRhaW5lci5wcm9ncmFtKDE3LCBkYXRhLCAwKSxcImludmVyc2VcIjpjb250YWluZXIubm9vcCxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKVxuICAgICsgXCIgICAgICAgICA8L2Rpdj5cXG4gICAgICA8L2Rpdj5cXG48L2Rpdj5cXG5cXG5cXG5cXG5cXG5cIjtcbn0sXCJ1c2VEYXRhXCI6dHJ1ZX0pOyIsIm1vZHVsZS5leHBvcnRzID0gZnVuY3Rpb24gKGl0ZW0sIG9wdHMpIHtcbiAgaWYgKGVudkRldGFpbHMuZXZlbnRUeXBlID09PSBcIk9uZ29pbmdTYWxlc1wiICYmIFwiZmllbGRfbmFtZVwiIGluIGl0ZW0gJiYgaXRlbS5maWVsZF9uYW1lID09PSBcImRhdGVzXCIpIHtcbiAgICByZXR1cm4gb3B0cy5mbih0aGlzKTtcbiAgfSBlbHNlIHtcbiAgICByZXR1cm4gb3B0cy5pbnZlcnNlKHRoaXMpO1xuICB9XG59IiwibW9kdWxlLmV4cG9ydHMgPSBmdW5jdGlvbiAoaXRlbSwgdmFsdWUsIG9wdHMpIHtcbiAgaWYgKGl0ZW0gPT09IHZhbHVlKSB7XG4gICAgcmV0dXJuIG9wdHMuZm4odGhpcylcbiAgfSBlbHNlIHtcbiAgICByZXR1cm4gb3B0cy5pbnZlcnNlKHRoaXMpXG4gIH1cbn0iLCJtb2R1bGUuZXhwb3J0cyA9IGZ1bmN0aW9uIChpdGVtLCB2YWx1ZTEsIHZhbHVlMiwgb3B0cykge1xuICBpZiAoaXRlbSA9PT0gdmFsdWUxIHx8IGl0ZW0gPT09IHZhbHVlMikge1xuICAgIHJldHVybiBvcHRzLmZuKHRoaXMpXG4gIH0gZWxzZSB7XG4gICAgcmV0dXJuIG9wdHMuaW52ZXJzZSh0aGlzKVxuICB9XG59IiwibW9kdWxlLmV4cG9ydHMgPSBmdW5jdGlvbihpMThuX2tleSwgbGFiZWwpIHtcblx0dmFyIHJlc3VsdCA9IGkxOG4udChpMThuX2tleSwge2xhYmVsfSk7XG5cdHJldHVybiBuZXcgSGFuZGxlYmFycy5TYWZlU3RyaW5nKHJlc3VsdCk7XG59IiwidmFyIEhhbmRsZWJhcnMgPSByZXF1aXJlKFwiLi4vLi4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvcnVudGltZS5qc1wiKTtcbmZ1bmN0aW9uIF9fZGVmYXVsdChvYmopIHsgcmV0dXJuIG9iaiAmJiAob2JqLl9fZXNNb2R1bGUgPyBvYmpbXCJkZWZhdWx0XCJdIDogb2JqKTsgfVxubW9kdWxlLmV4cG9ydHMgPSAoSGFuZGxlYmFyc1tcImRlZmF1bHRcIl0gfHwgSGFuZGxlYmFycykudGVtcGxhdGUoe1wiMVwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMTtcblxuICByZXR1cm4gKChzdGFjazEgPSBoZWxwZXJzLnVubGVzcy5jYWxsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSksKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmlzRUJDRXZlbnQgOiBkZXB0aDApLHtcIm5hbWVcIjpcInVubGVzc1wiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSgyLCBkYXRhLCAwKSxcImludmVyc2VcIjpjb250YWluZXIubm9vcCxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKTtcbn0sXCIyXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgc3RhY2sxO1xuXG4gIHJldHVybiAoKHN0YWNrMSA9IGhlbHBlcnMudW5sZXNzLmNhbGwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuaGlkZUFkZEFjdGl2aXR5T3B0aW9uIDogZGVwdGgwKSx7XCJuYW1lXCI6XCJ1bmxlc3NcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMywgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIik7XG59LFwiM1wiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMTtcblxuICByZXR1cm4gKChzdGFjazEgPSBoZWxwZXJzLnVubGVzcy5jYWxsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSksKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmlzQ29uc2VjdXRpdmUgOiBkZXB0aDApLHtcIm5hbWVcIjpcInVubGVzc1wiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSg0LCBkYXRhLCAwKSxcImludmVyc2VcIjpjb250YWluZXIubm9vcCxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKTtcbn0sXCI0XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgc3RhY2sxLCBhbGlhczE9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KTtcblxuICByZXR1cm4gXCIgICAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQgYWRkXFxcIj5cXG4gICAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1jb250ZW50XFxcIj5cXG5cIlxuICAgICsgKChzdGFjazEgPSBoZWxwZXJzW1wiaWZcIl0uY2FsbChhbGlhczEsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmlzU3RhZmZTY2hlZHVsZSA6IGRlcHRoMCkse1wibmFtZVwiOlwiaWZcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oNSwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLnByb2dyYW0oNywgZGF0YSwgMCksXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWZvb3RlclxcXCI+XFxuICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1mb290ZXItY29udGVudFxcXCI+XFxuXCJcbiAgICArICgoc3RhY2sxID0gaGVscGVyc1tcImlmXCJdLmNhbGwoYWxpYXMxLChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5pc1N0YWZmU2NoZWR1bGUgOiBkZXB0aDApLHtcIm5hbWVcIjpcImlmXCIsXCJoYXNoXCI6e30sXCJmblwiOmNvbnRhaW5lci5wcm9ncmFtKDksIGRhdGEsIDApLFwiaW52ZXJzZVwiOmNvbnRhaW5lci5ub29wLFwiZGF0YVwiOmRhdGF9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpXG4gICAgKyBcIiAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgIDwvZGl2PlxcblwiO1xufSxcIjVcIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSkge1xuICAgIHZhciBoZWxwZXIsIGFsaWFzMT1kZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLCBhbGlhczI9aGVscGVycy5oZWxwZXJNaXNzaW5nLCBhbGlhczM9XCJmdW5jdGlvblwiLCBhbGlhczQ9Y29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb247XG5cbiAgcmV0dXJuIFwiICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJhZGQtYnRuXFxcIj5cXG4gICAgICAgICAgICAgICAgPGEgaHJlZj1cXFwiamF2YXNjcmlwdDp2b2lkKDApXFxcIiBpZD0nYm9va19hZ2VuZGFfYWRkX2J0bic+PGkgY2xhc3M9XFxcImppZi1wbHVzLWNpcmNsZS1vIGppZi1saWdodC1ncmV5IGppZi03MFxcXCI+PC9pPjwvYT5cXG4gICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgPGRpdj5cXG4gICAgICAgICAgICAgICAgPGEgaHJlZj1cXFwiamF2YXNjcmlwdDp2b2lkKDApXFxcIiBpZD0nYm9va19hZ2VuZGFfaXRlbScgY2xhc3M9J2J0biBidG4td2hpdGUgYnRuLWJsb2NrIHRleHQtZWxsaXBzaXMnPlwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5kaXNwbGF5TGFiZWxGb3JBZGRBZ2VuZGEgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmRpc3BsYXlMYWJlbEZvckFkZEFnZW5kYSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiZGlzcGxheUxhYmVsRm9yQWRkQWdlbmRhXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIjwvYT5cXG4gICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwidGV4dC1jZW50ZXIgZm9udC1zbVxcXCI+XCJcbiAgICArIGFsaWFzNChfX2RlZmF1bHQocmVxdWlyZShcIi4uL2hlbHBlcnMvdC5qc1wiKSkuY2FsbChhbGlhczEsXCJlaXRoZXJfb3JcIix7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCI8L2Rpdj5cXG4gICAgICAgICAgICAgIDxkaXY+XFxuICAgICAgICAgICAgICAgIDxmb3JtIGNsYXNzPVxcXCJ1cGxvYWQtY3N2XFxcIiBzdHlsZT1cXFwicG9zaXRpb246IHJlbGF0aXZlO1xcXCI+XFxuICAgICAgICAgICAgICAgICAgPGlucHV0IGlkPVxcXCJ1cGxvYWRfYWdlbmRhX2l0ZW1cXFwiIGNsYXNzPVxcXCJ1cGxvYWQtYWdlbmRhLWlucHV0IGhpZGVcXFwiIHR5cGU9XFxcImZpbGVcXFwiIGFjY2VwdD1cXFwiLmNzdlxcXCI+XFxuICAgICAgICAgICAgICAgICAgPGxhYmVsIGlkPVxcXCJzdWJtaXRcXFwiIGNsYXNzPVxcXCJidG4gYnRuLXdoaXRlIGJ0bi1ibG9jayB0ZXh0LWVsbGlwc2lzXFxcIiBmb3I9XFxcInVwbG9hZF9hZ2VuZGFfaXRlbVxcXCI+XCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmRpc3BsYXlMYWJlbEZvclVwbG9hZEFnZW5kYSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZGlzcGxheUxhYmVsRm9yVXBsb2FkQWdlbmRhIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJkaXNwbGF5TGFiZWxGb3JVcGxvYWRBZ2VuZGFcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9sYWJlbD5cXG4gICAgICAgICAgICAgICAgPC9mb3JtPlxcbiAgICAgICAgICAgICAgPC9kaXY+XFxuXCI7XG59LFwiN1wiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgcmV0dXJuIFwiICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJhZGQtYnRuXFxcIj5cXG4gICAgICAgICAgICAgICAgPGEgaHJlZj1cXFwiamF2YXNjcmlwdDp2b2lkKDApXFxcIiBpZD0nYm9va19tZWV0aW5nX2FkZF9idG4nPjxpIGNsYXNzPVxcXCJqaWYtcGx1cy1jaXJjbGUtbyBqaWYtbGlnaHQtZ3JleSBqaWYtNzBcXFwiPjwvaT48L2E+XFxuICAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICAgIDxkaXY+PGEgaHJlZj1cXFwiamF2YXNjcmlwdDp2b2lkKDApXFxcIiBpZD0nYm9va19tZWV0aW5nJyBjbGFzcz0nYnRuIGJ0bi13aGl0ZSBidG4tYmxvY2snPlwiXG4gICAgKyBjb250YWluZXIuZXNjYXBlRXhwcmVzc2lvbihfX2RlZmF1bHQocmVxdWlyZShcIi4uL2hlbHBlcnMvdC5qc1wiKSkuY2FsbChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLFwiYm9va19hY3Rpdml0eVwiLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIjwvYT48L2Rpdj5cXG5cIjtcbn0sXCI5XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgaGVscGVyLCBhbGlhczE9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwgYWxpYXMyPWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uO1xuXG4gIHJldHVybiBcIiAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJ0ZXh0LWNlbnRlclxcXCI+XFxuICAgICAgICAgICAgICAgICAgPGEgaHJlZj1cXFwiXCJcbiAgICArIGFsaWFzMigoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmRvd25sb2FkQWdlbmRhSXRlbVRlbXBsYXRlVXJsIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5kb3dubG9hZEFnZW5kYUl0ZW1UZW1wbGF0ZVVybCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBoZWxwZXJzLmhlbHBlck1pc3NpbmcpLCh0eXBlb2YgaGVscGVyID09PSBcImZ1bmN0aW9uXCIgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiZG93bmxvYWRBZ2VuZGFJdGVtVGVtcGxhdGVVcmxcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBjbGFzcz1cXFwiZG93bmxvYWQtZm9ybWF0LWxpbmsgZm9udC14c1xcXCIgZGF0YS1pMThuPVxcXCJkb3dubG9hZF9yb29tX2Nzdl9mb3JtYXRcXFwiPlwiXG4gICAgKyBhbGlhczIoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMxLFwiZG93bmxvYWRfYWdlbmRhX2l0ZW1fY3N2X2Zvcm1hdFwiLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIjwvYT5cXG4gICAgICAgICAgICAgICAgPC9kaXY+XFxuXCI7XG59LFwiMTFcIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSkge1xuICAgIHZhciBzdGFjazE7XG5cbiAgcmV0dXJuICgoc3RhY2sxID0gY29udGFpbmVyLmludm9rZVBhcnRpYWwocmVxdWlyZShcIi4uL2NvbW1vbl9wYXJ0aWFscy9fbWVldGluZy5oYnNcIiksZGVwdGgwLHtcIm5hbWVcIjpcIi4uL2NvbW1vbl9wYXJ0aWFscy9fbWVldGluZ1wiLFwiZGF0YVwiOmRhdGEsXCJpbmRlbnRcIjpcIiAgICAgXCIsXCJoZWxwZXJzXCI6aGVscGVycyxcInBhcnRpYWxzXCI6cGFydGlhbHMsXCJkZWNvcmF0b3JzXCI6Y29udGFpbmVyLmRlY29yYXRvcnN9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpO1xufSxcImNvbXBpbGVyXCI6WzcsXCI+PSA0LjAuMFwiXSxcIm1haW5cIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSkge1xuICAgIHZhciBzdGFjazEsIGhlbHBlciwgYWxpYXMxPWRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSksIGFsaWFzMj1jb250YWluZXIuZXNjYXBlRXhwcmVzc2lvbjtcblxuICByZXR1cm4gXCI8ZGl2IGNsYXNzPVxcXCJjYXJkLWNvbnRhaW5lciBcIlxuICAgICsgYWxpYXMyKCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMubGlzdENsYXNzIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5saXN0Q2xhc3MgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogaGVscGVycy5oZWxwZXJNaXNzaW5nKSwodHlwZW9mIGhlbHBlciA9PT0gXCJmdW5jdGlvblwiID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImxpc3RDbGFzc1wiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCIgXCJcbiAgICArIGFsaWFzMihjb250YWluZXIubGFtYmRhKCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnRvZ2dsZVN0YXRlIDogZGVwdGgwKSkgIT0gbnVsbCA/IHN0YWNrMS52aWV3U3R5bGUgOiBzdGFjazEpLCBkZXB0aDApKVxuICAgICsgXCJcXFwiPlxcblwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnNbXCJpZlwiXS5jYWxsKGFsaWFzMSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuQ2FuQWNjZXNzVmlld09ubHlFdmVudCA6IGRlcHRoMCkse1wibmFtZVwiOlwiaWZcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMSwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArICgoc3RhY2sxID0gaGVscGVycy5lYWNoLmNhbGwoYWxpYXMxLChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5tZWV0aW5nTGlzdCA6IGRlcHRoMCkse1wibmFtZVwiOlwiZWFjaFwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSgxMSwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiPC9kaXY+XFxuXCI7XG59LFwidXNlUGFydGlhbFwiOnRydWUsXCJ1c2VEYXRhXCI6dHJ1ZX0pOyIsInZhciBIYW5kbGViYXJzID0gcmVxdWlyZShcIi4uLy4uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL3J1bnRpbWUuanNcIik7XG5mdW5jdGlvbiBfX2RlZmF1bHQob2JqKSB7IHJldHVybiBvYmogJiYgKG9iai5fX2VzTW9kdWxlID8gb2JqW1wiZGVmYXVsdFwiXSA6IG9iaik7IH1cbm1vZHVsZS5leHBvcnRzID0gKEhhbmRsZWJhcnNbXCJkZWZhdWx0XCJdIHx8IEhhbmRsZWJhcnMpLnRlbXBsYXRlKHtcIjFcIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSkge1xuICAgIHZhciBzdGFjazE7XG5cbiAgcmV0dXJuICgoc3RhY2sxID0gaGVscGVyc1tcImlmXCJdLmNhbGwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuc2hvd19zdXJ2ZXkgOiBkZXB0aDApLHtcIm5hbWVcIjpcImlmXCIsXCJoYXNoXCI6e30sXCJmblwiOmNvbnRhaW5lci5wcm9ncmFtKDIsIGRhdGEsIDApLFwiaW52ZXJzZVwiOmNvbnRhaW5lci5ub29wLFwiZGF0YVwiOmRhdGF9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpO1xufSxcIjJcIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSkge1xuICAgIHZhciBzdGFjazEsIGhlbHBlciwgYWxpYXMxPWRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSksIGFsaWFzMj1oZWxwZXJzLmhlbHBlck1pc3NpbmcsIGFsaWFzMz1cImZ1bmN0aW9uXCIsIGFsaWFzND1jb250YWluZXIuZXNjYXBlRXhwcmVzc2lvbjtcblxuICByZXR1cm4gXCI8ZGl2IGNsYXNzPVxcXCJjb2wtbWQtMTIganMtbWVldGluZy1zZXJ2ZXktaXRlbVxcXCIgZGF0YS11dWlkPVxcXCJcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMudXVpZCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAudXVpZCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwidXVpZFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiIGRhdGEtYXR0ZW5kZWU9XFxcIlwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5hdHRlbmRlZSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuYXR0ZW5kZWUgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImF0dGVuZGVlXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCI+XFxuICA8ZGl2IGNsYXNzPVxcXCJjYXJkIGNhcmQteHNcXFwiPlxcbiAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWhlYWRlciBjYXJkLXhzLWhlYWRlclxcXCI+XFxuICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1oZWFkZXItY29udGVudCBjYXJkLXhzLWhlYWRlci1jb250ZW50XFxcIj5cXG4gICAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtc2VsZWN0XFxcIj5cXG4gICAgICAgICAgPGlucHV0IHR5cGU9XFxcImNoZWNrYm94XFxcIiBpZD1cXFwic3VydmV5LVwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCI+XFxuICAgICAgICAgIDxsYWJlbCBmb3I9XFxcInN1cnZleS1cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMudXVpZCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAudXVpZCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwidXVpZFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiPlxcbiAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcInN0YXRlIFwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5zdGF0dXMgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnN0YXR1cyA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwic3RhdHVzXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCI+XFxuICAgICAgICAgICAgICAgIDxpIGNsYXNzPVxcXCJqaWYtc3VydmV5IGppZi1kYXJrLWdyZXkgamlmLTE4XFxcIj48L2k+XFxuICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgIDwvbGFiZWw+XFxuICAgICAgICA8L2Rpdj5cXG4gICAgICA8L2Rpdj5cXG4gICAgPC9kaXY+XFxuICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtY29udGVudCBjYXJkLXhzLWNvbnRlbnRcXFwiPlxcbiAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtZGV0YWlsLWNvbnRlbnRcXFwiPlxcbiAgICAgICAgPGRpdj5cXG4gICAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1kZXRhaWxcXFwiPlxcblwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnNbXCJpZlwiXS5jYWxsKGFsaWFzMSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuYWN0aW9uIDogZGVwdGgwKSx7XCJuYW1lXCI6XCJpZlwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSgzLCBkYXRhLCAwKSxcImludmVyc2VcIjpjb250YWluZXIubm9vcCxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKVxuICAgICsgKChzdGFjazEgPSBoZWxwZXJzLnVubGVzcy5jYWxsKGFsaWFzMSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuYWN0aW9uIDogZGVwdGgwKSx7XCJuYW1lXCI6XCJ1bmxlc3NcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oNSwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgPC9kaXY+XFxuICAgICAgPC9kaXY+XFxuICAgIDwvZGl2PlxcblwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnNbXCJpZlwiXS5jYWxsKGFsaWFzMSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuc3VydmV5X2xpbmtfc2VudF9hdCA6IGRlcHRoMCkse1wibmFtZVwiOlwiaWZcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oNywgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiICA8L2Rpdj5cXG48L2Rpdj5cXG5cIjtcbn0sXCIzXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgaGVscGVyLCBhbGlhczE9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwgYWxpYXMyPWhlbHBlcnMuaGVscGVyTWlzc2luZywgYWxpYXMzPVwiZnVuY3Rpb25cIiwgYWxpYXM0PWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uO1xuXG4gIHJldHVybiBcIiAgICAgICAgICAgIDxhIGhyZWY9XFxcIlwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5hY3Rpb24gfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmFjdGlvbiA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiYWN0aW9uXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCIgdGFyZ2V0PVxcXCJfYmxhbmtcXFwiPlwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5rZXkgfHwgKGRhdGEgJiYgZGF0YS5rZXkpKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImtleVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCI8L2E+XFxuXCI7XG59LFwiNVwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIGhlbHBlcjtcblxuICByZXR1cm4gXCIgICAgICAgICAgICA8c3BhbiBjbGFzcz1cXFwiZm9udC1sZ1xcXCI+XCJcbiAgICArIGNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uKCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMua2V5IHx8IChkYXRhICYmIGRhdGEua2V5KSkgIT0gbnVsbCA/IGhlbHBlciA6IGhlbHBlcnMuaGVscGVyTWlzc2luZyksKHR5cGVvZiBoZWxwZXIgPT09IFwiZnVuY3Rpb25cIiA/IGhlbHBlci5jYWxsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSkse1wibmFtZVwiOlwia2V5XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIjwvc3Bhbj5cXG5cIjtcbn0sXCI3XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgaGVscGVyLCBhbGlhczE9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwgYWxpYXMyPWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uO1xuXG4gIHJldHVybiBcIiAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWZvb3RlclxcXCI+XFxuICAgICAgICA8c3BhbiBjbGFzcz1cXFwiZm9udC1zbVxcXCI+XCJcbiAgICArIGFsaWFzMihfX2RlZmF1bHQocmVxdWlyZShcIi4uL2hlbHBlcnMvdC5qc1wiKSkuY2FsbChhbGlhczEsXCJsYXN0X3NlbnRfYXRcIix7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCIgXCJcbiAgICArIGFsaWFzMigoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnN1cnZleV9saW5rX3NlbnRfYXQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnN1cnZleV9saW5rX3NlbnRfYXQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogaGVscGVycy5oZWxwZXJNaXNzaW5nKSwodHlwZW9mIGhlbHBlciA9PT0gXCJmdW5jdGlvblwiID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcInN1cnZleV9saW5rX3NlbnRfYXRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9zcGFuPlxcbiAgICA8L2Rpdj5cXG5cIjtcbn0sXCJjb21waWxlclwiOls3LFwiPj0gNC4wLjBcIl0sXCJtYWluXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgc3RhY2sxO1xuXG4gIHJldHVybiAoKHN0YWNrMSA9IGhlbHBlcnMuZWFjaC5jYWxsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSksKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnN1cnZleXMgOiBkZXB0aDApLHtcIm5hbWVcIjpcImVhY2hcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMSwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIik7XG59LFwidXNlRGF0YVwiOnRydWV9KTsiLCJ2YXIgSGFuZGxlYmFycyA9IHJlcXVpcmUoXCIuLi8uLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9ydW50aW1lLmpzXCIpO1xuZnVuY3Rpb24gX19kZWZhdWx0KG9iaikgeyByZXR1cm4gb2JqICYmIChvYmouX19lc01vZHVsZSA/IG9ialtcImRlZmF1bHRcIl0gOiBvYmopOyB9XG5tb2R1bGUuZXhwb3J0cyA9IChIYW5kbGViYXJzW1wiZGVmYXVsdFwiXSB8fCBIYW5kbGViYXJzKS50ZW1wbGF0ZSh7XCIxXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgaGVscGVyLCBhbGlhczE9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwgYWxpYXMyPWhlbHBlcnMuaGVscGVyTWlzc2luZywgYWxpYXMzPVwiZnVuY3Rpb25cIiwgYWxpYXM0PWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uO1xuXG4gIHJldHVybiBcIlx0PGxpPlxcbiAgICAgIDxkaXYgY2xhc3M9XFxcImFjdGl2aXR5XFxcIiBpZD1cXFwiXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnV1aWQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnV1aWQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcInV1aWRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBkYXRhLXVybD1cXFwiXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLm1lZXRpbmdfdXJsIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5tZWV0aW5nX3VybCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwibWVldGluZ191cmxcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBkYXRhLXJlZGlyZWN0LXVybD1cXFwiXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnJlZGlyZWN0X3VybCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAucmVkaXJlY3RfdXJsIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJyZWRpcmVjdF91cmxcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBkYXRhLXRlbXBsYXRlLXVybD1cXFwiXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnRlbXBsYXRlX3VybCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAudGVtcGxhdGVfdXJsIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ0ZW1wbGF0ZV91cmxcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBkYXRhLWFjdGl2aXR5LXNvdXJjZT1cXFwiXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnNvdXJjZSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuc291cmNlIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJzb3VyY2VcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIj5cXG4gICAgICAgIDxkaXYgY2xhc3M9XFxcImFjdGl2aXR5LWljb25cXFwiPlxcbiAgICAgICAgICA8aSBjbGFzcz1cXFwiXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmljb25fdXJsIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5pY29uX3VybCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiaWNvbl91cmxcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiIGppZi1kYXJrLWdyZXkgamlmLTM0XFxcIj48L2k+XFxuICAgICAgICA8L2Rpdj5cXG4gICAgICAgIDxkaXYgY2xhc3M9XFxcImFjdGl2aXR5LW5hbWVcXFwiPlxcbiAgICAgICAgXHQ8ZGl2IHRpdGxlPVxcXCJcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMubmFtZSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAubmFtZSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwibmFtZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiPlwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5uYW1lIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5uYW1lIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJuYW1lXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIjwvZGl2PlxcbiAgICAgICAgPC9kaXY+XFxuICAgICAgPC9kaXY+XFxuICAgIDwvbGk+XFxuXCI7XG59LFwiY29tcGlsZXJcIjpbNyxcIj49IDQuMC4wXCJdLFwibWFpblwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMTtcblxuICByZXR1cm4gKChzdGFjazEgPSBoZWxwZXJzLmVhY2guY2FsbChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5tZWV0aW5nVHlwZXMgOiBkZXB0aDApLHtcIm5hbWVcIjpcImVhY2hcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMSwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIik7XG59LFwidXNlRGF0YVwiOnRydWV9KTsiLCJ2YXIgSGFuZGxlYmFycyA9IHJlcXVpcmUoXCIuLi8uLi8uLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9ydW50aW1lLmpzXCIpO1xuZnVuY3Rpb24gX19kZWZhdWx0KG9iaikgeyByZXR1cm4gb2JqICYmIChvYmouX19lc01vZHVsZSA/IG9ialtcImRlZmF1bHRcIl0gOiBvYmopOyB9XG5tb2R1bGUuZXhwb3J0cyA9IChIYW5kbGViYXJzW1wiZGVmYXVsdFwiXSB8fCBIYW5kbGViYXJzKS50ZW1wbGF0ZSh7XCIxXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgc3RhY2sxO1xuXG4gIHJldHVybiBcIjxkaXYgaWQ9XFxcImJyaWVmaW5nLXR5cGUtZmlsdGVyXFxcIiBjbGFzcz1cXFwidGFiLXBhbmUgYWN0aXZlXFxcIiBybGU9XFxcInRhYnBhbmVsXFxcIj5cXG4gIDxkaXYgY2xhc3M9XFxcInJvd1xcXCI+XFxuXCJcbiAgICArICgoc3RhY2sxID0gaGVscGVycy5lYWNoLmNhbGwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwoKHN0YWNrMSA9IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWx0ZXJzIDogZGVwdGgwKSkgIT0gbnVsbCA/IHN0YWNrMS5icmllZmluZ3MgOiBzdGFjazEpLHtcIm5hbWVcIjpcImVhY2hcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMiwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiICA8L2Rpdj5cXG48L2Rpdj5cXG5cIjtcbn0sXCIyXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgc3RhY2sxLCBhbGlhczE9Y29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb24sIGFsaWFzMj1kZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pO1xuXG4gIHJldHVybiBcIiAgICAgICAgPGRpdiBjbGFzcz1cXFwiZmlsdGVyLWl0ZW0gY29sLW1kLTZcXFwiIGRhdGEtdHlwZT1cXFwiXCJcbiAgICArIGFsaWFzMShjb250YWluZXIubGFtYmRhKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIj5cXG4gICAgICAgIDxsYWJlbD5cIlxuICAgICsgYWxpYXMxKF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMiwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZGlzcGxheV90ZXh0IDogZGVwdGgwKSx7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCI8L2xhYmVsPlxcblwiXG4gICAgKyAoKHN0YWNrMSA9IF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vLi4vaGVscGVycy9pc0VxdWFsVG9FaXRoZXJPZk9uZS5qc1wiKSkuY2FsbChhbGlhczIsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpZWxkX25hbWUgOiBkZXB0aDApLFwiYnJpZWZpbmdfc3RhcnRfZGF0ZVwiLFwiYnJpZWZpbmdfZW5kX2RhdGVcIix7XCJuYW1lXCI6XCJpc0VxdWFsVG9FaXRoZXJPZk9uZVwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSgzLCBkYXRhLCAwKSxcImludmVyc2VcIjpjb250YWluZXIucHJvZ3JhbSg1LCBkYXRhLCAwKSxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKVxuICAgICsgXCIgICAgICAgIDwvZGl2PlxcblwiO1xufSxcIjNcIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSkge1xuICAgIHZhciBhbGlhczE9Y29udGFpbmVyLmxhbWJkYSwgYWxpYXMyPWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uO1xuXG4gIHJldHVybiBcIiAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJmaWx0ZXItdmFsdWVzIGRhdGUtZmlsdGVyLWNvbnRhaW5lclxcXCI+XFxuICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwicm93XFxcIj5cXG4gICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImNvbC1tZC0xMlxcXCI+XFxuICAgICAgICAgICAgICAgIDxpIGNsYXNzPVxcXCJqaWYtY2FsZW5kYXItbW9udGggamlmLTE4XFxcIj48L2k+XFxuICAgICAgICAgICAgICAgIDxpbnB1dCB0eXBlPVxcXCJ0ZXh0XFxcIiBuYW1lPVxcXCJcIlxuICAgICsgYWxpYXMyKGFsaWFzMSgoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZmllbGRfbmFtZSA6IGRlcHRoMCksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCIgY2xhc3M9XFxcImZvcm0tY29udHJvbCBcIlxuICAgICsgYWxpYXMyKGFsaWFzMSgoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZmllbGRfbmFtZSA6IGRlcHRoMCksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCIgcmVhZG9ubHk9XFxcInJlYWRvbmx5XFxcIiBhdXRvY29tcGxldGU9XFxcIm9mZlxcXCI+XFxuICAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgPC9kaXY+XFxuXCI7XG59LFwiNVwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMTtcblxuICByZXR1cm4gKChzdGFjazEgPSBoZWxwZXJzW1wiaWZcIl0uY2FsbChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5kYXRlX2ZpZWxkIDogZGVwdGgwKSx7XCJuYW1lXCI6XCJpZlwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSg2LCBkYXRhLCAwKSxcImludmVyc2VcIjpjb250YWluZXIucHJvZ3JhbSg4LCBkYXRhLCAwKSxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKTtcbn0sXCI2XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgYWxpYXMxPWNvbnRhaW5lci5sYW1iZGEsIGFsaWFzMj1jb250YWluZXIuZXNjYXBlRXhwcmVzc2lvbjtcblxuICByZXR1cm4gXCIgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiamlmLWJsdWUgamlmLWNhbGVuZGFyLW1vbnRoIGZvcm0tZmllbGQtaWNvblxcXCI+XFxuICAgICAgICAgICAgICA8aW5wdXQgaWQ9XFxcIlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiB0eXBlPVxcXCJ0ZXh0XFxcIiByZWFkb25seT1cXFwidHJ1ZVxcXCIgY2xhc3M9XFxcImRhdGUgZm9ybS1jb250cm9sIFwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiIFwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMFtcImNsYXNzXCJdIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiBkYXRhLXR5cGU9XFxcIlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5kaXNwbGF5X3RleHQgOiBkZXB0aDApLCBkZXB0aDApKVxuICAgICsgXCJcXFwiIG5hbWU9XFxcIlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIi8+XFxuICAgICAgICAgIDwvZGl2PlxcblwiO1xufSxcIjhcIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSkge1xuICAgIHZhciBzdGFjazEsIGFsaWFzMT1jb250YWluZXIubGFtYmRhLCBhbGlhczI9Y29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb247XG5cbiAgcmV0dXJuIFwiICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImZpbHRlci12YWx1ZXMgdG9rZW4taW5wdXQtZmxkXFxcIj5cXG4gICAgICAgICAgICA8c2VsZWN0IGNsYXNzPVxcXCJmb3JtLWNvbnRyb2wgc2VsZWN0IFwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiBkYXRhLXR5cGU9XFxcIlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5kaXNwbGF5X3RleHQgOiBkZXB0aDApLCBkZXB0aDApKVxuICAgICsgXCJcXFwiIG11bHRpcGxlIG5hbWU9XFxcIlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiBkYXRhLWN1c3RvbT1cXFwiXCJcbiAgICArIGFsaWFzMihhbGlhczEoKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmN1c3RvbV9sYWJlbCA6IGRlcHRoMCksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCI+XFxuXCJcbiAgICArICgoc3RhY2sxID0gaGVscGVycy5lYWNoLmNhbGwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAudmFsdWUgOiBkZXB0aDApLHtcIm5hbWVcIjpcImVhY2hcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oOSwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiICAgICAgICAgICAgPC9zZWxlY3Q+XFxuICAgICAgICAgIDwvZGl2PlxcblwiO1xufSxcIjlcIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSkge1xuICAgIHZhciBzdGFjazEsIGFsaWFzMT1jb250YWluZXIubGFtYmRhLCBhbGlhczI9Y29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb247XG5cbiAgcmV0dXJuIFwiICAgICAgICAgICAgICAgIDxvcHRpb24gdmFsdWU9XFxcIlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC52YWx1ZSA6IGRlcHRoMCksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCIgXCJcbiAgICArICgoc3RhY2sxID0gaGVscGVyc1tcImlmXCJdLmNhbGwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuc2VsZWN0ZWQgOiBkZXB0aDApLHtcIm5hbWVcIjpcImlmXCIsXCJoYXNoXCI6e30sXCJmblwiOmNvbnRhaW5lci5wcm9ncmFtKDEwLCBkYXRhLCAwKSxcImludmVyc2VcIjpjb250YWluZXIubm9vcCxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKVxuICAgICsgXCI+XCJcbiAgICArIGFsaWFzMihhbGlhczEoKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmRpc3BsYXlfbGFiZWwgOiBkZXB0aDApLCBkZXB0aDApKVxuICAgICsgXCI8L29wdGlvbj5cXG5cIjtcbn0sXCIxMFwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgcmV0dXJuIFwiIHNlbGVjdGVkIFwiO1xufSxcIjEyXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICByZXR1cm4gXCJhY3RpdmVcIjtcbn0sXCIxNFwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMTtcblxuICByZXR1cm4gKChzdGFjazEgPSBoZWxwZXJzLmVhY2guY2FsbChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpbHRlcnMgOiBkZXB0aDApKSAhPSBudWxsID8gc3RhY2sxLm1lZXRpbmdzIDogc3RhY2sxKSx7XCJuYW1lXCI6XCJlYWNoXCIsXCJoYXNoXCI6e30sXCJmblwiOmNvbnRhaW5lci5wcm9ncmFtKDE1LCBkYXRhLCAwKSxcImludmVyc2VcIjpjb250YWluZXIubm9vcCxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKTtcbn0sXCIxNVwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMSwgYWxpYXMxPWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uLCBhbGlhczI9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KTtcblxuICByZXR1cm4gXCIgICAgICAgIDxkaXYgY2xhc3M9XFxcImZpbHRlci1pdGVtIGNvbC1tZC02XFxcIiBkYXRhLXR5cGU9XFxcIlwiXG4gICAgKyBhbGlhczEoY29udGFpbmVyLmxhbWJkYSgoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZmllbGRfbmFtZSA6IGRlcHRoMCksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCI+XFxuICAgICAgICAgIDxsYWJlbD5cIlxuICAgICsgYWxpYXMxKF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMiwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZGlzcGxheV90ZXh0IDogZGVwdGgwKSx7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCI8L2xhYmVsPlxcblwiXG4gICAgKyAoKHN0YWNrMSA9IF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vLi4vaGVscGVycy9pc0VxdWFsVG9FaXRoZXJPZk9uZS5qc1wiKSkuY2FsbChhbGlhczIsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpZWxkX25hbWUgOiBkZXB0aDApLFwibWVldGluZ19zdGFydF90aW1lXCIsXCJtZWV0aW5nX2VuZF90aW1lXCIse1wibmFtZVwiOlwiaXNFcXVhbFRvRWl0aGVyT2ZPbmVcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMTYsIGRhdGEsIDApLFwiaW52ZXJzZVwiOmNvbnRhaW5lci5wcm9ncmFtKDE4LCBkYXRhLCAwKSxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKVxuICAgICsgXCIgICAgICAgIDwvZGl2PlxcblwiO1xufSxcIjE2XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgYWxpYXMxPWNvbnRhaW5lci5sYW1iZGEsIGFsaWFzMj1jb250YWluZXIuZXNjYXBlRXhwcmVzc2lvbjtcblxuICByZXR1cm4gXCIgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJmaWx0ZXItdmFsdWVzIGRhdGUtZmlsdGVyLWNvbnRhaW5lclxcXCI+XFxuICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJyb3dcXFwiPlxcbiAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjb2wtbWQtMTJcXFwiPlxcbiAgICAgICAgICAgICAgICAgIDxpIGNsYXNzPVxcXCJqaWYtY2FsZW5kYXItbW9udGggamlmLTE4XFxcIj48L2k+XFxuICAgICAgICAgICAgICAgICAgPGlucHV0IHR5cGU9XFxcInRleHRcXFwiIG5hbWU9XFxcIlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiBjbGFzcz1cXFwiZm9ybS1jb250cm9sIFwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiByZWFkb25seT1cXFwicmVhZG9ubHlcXFwiIGF1dG9jb21wbGV0ZT1cXFwib2ZmXFxcIj5cXG4gICAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICA8L2Rpdj5cXG5cIjtcbn0sXCIxOFwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMSwgYWxpYXMxPWNvbnRhaW5lci5sYW1iZGEsIGFsaWFzMj1jb250YWluZXIuZXNjYXBlRXhwcmVzc2lvbjtcblxuICByZXR1cm4gXCIgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJmaWx0ZXItdmFsdWVzIHRva2VuLWlucHV0LWZsZFxcXCI+XFxuICAgICAgICAgICAgICA8c2VsZWN0IGNsYXNzPVxcXCJmb3JtLWNvbnRyb2wgc2VsZWN0IFwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiBkYXRhLXR5cGU9XFxcIlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5kaXNwbGF5X3RleHQgOiBkZXB0aDApLCBkZXB0aDApKVxuICAgICsgXCJcXFwiIG11bHRpcGxlIG5hbWU9XFxcIlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiBkYXRhLWN1c3RvbT1cXFwiXCJcbiAgICArIGFsaWFzMihhbGlhczEoKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmN1c3RvbV9sYWJlbCA6IGRlcHRoMCksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCI+XFxuXCJcbiAgICArICgoc3RhY2sxID0gaGVscGVycy5lYWNoLmNhbGwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAudmFsdWUgOiBkZXB0aDApLHtcIm5hbWVcIjpcImVhY2hcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMTksIGRhdGEsIDApLFwiaW52ZXJzZVwiOmNvbnRhaW5lci5ub29wLFwiZGF0YVwiOmRhdGF9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpXG4gICAgKyBcIiAgICAgICAgICAgICAgPC9zZWxlY3Q+XFxuICAgICAgICAgICAgPC9kaXY+XFxuXCI7XG59LFwiMTlcIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSkge1xuICAgIHZhciBzdGFjazEsIGFsaWFzMT1jb250YWluZXIubGFtYmRhLCBhbGlhczI9Y29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb247XG5cbiAgcmV0dXJuIFwiICAgICAgICAgICAgICAgICAgPG9wdGlvbiB2YWx1ZT1cXFwiXCJcbiAgICArIGFsaWFzMihhbGlhczEoKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnZhbHVlIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiBcIlxuICAgICsgKChzdGFjazEgPSBoZWxwZXJzW1wiaWZcIl0uY2FsbChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5zZWxlY3RlZCA6IGRlcHRoMCkse1wibmFtZVwiOlwiaWZcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMTAsIGRhdGEsIDApLFwiaW52ZXJzZVwiOmNvbnRhaW5lci5ub29wLFwiZGF0YVwiOmRhdGF9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpXG4gICAgKyBcIj5cIlxuICAgICsgYWxpYXMyKGFsaWFzMSgoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZGlzcGxheV9sYWJlbCA6IGRlcHRoMCksIGRlcHRoMCkpXG4gICAgKyBcIjwvb3B0aW9uPlxcblwiO1xufSxcIjIxXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgc3RhY2sxO1xuXG4gIHJldHVybiAoKHN0YWNrMSA9IGhlbHBlcnMuZWFjaC5jYWxsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSksKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpbHRlcnMgOiBkZXB0aDApLHtcIm5hbWVcIjpcImVhY2hcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMjIsIGRhdGEsIDApLFwiaW52ZXJzZVwiOmNvbnRhaW5lci5ub29wLFwiZGF0YVwiOmRhdGF9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpO1xufSxcIjIyXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgc3RhY2sxLCBhbGlhczE9Y29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb24sIGFsaWFzMj1kZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pO1xuXG4gIHJldHVybiBcIiAgICAgICAgPGRpdiBjbGFzcz1cXFwiZmlsdGVyLWl0ZW0gY29sLW1kLTZcXFwiIGRhdGEtdHlwZT1cXFwiXCJcbiAgICArIGFsaWFzMShjb250YWluZXIubGFtYmRhKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIj5cXG4gICAgICAgICAgPGxhYmVsPlwiXG4gICAgKyBhbGlhczEoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi8uLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMyLChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5kaXNwbGF5X3RleHQgOiBkZXB0aDApLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIjwvbGFiZWw+XFxuICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImZpbHRlci12YWx1ZXMgdG9rZW4taW5wdXQtZmxkXFxcIj5cXG5cIlxuICAgICsgKChzdGFjazEgPSBfX2RlZmF1bHQocmVxdWlyZShcIi4uLy4uL2hlbHBlcnMvaWZEYXRlcy5qc1wiKSkuY2FsbChhbGlhczIsZGVwdGgwLHtcIm5hbWVcIjpcImlmRGF0ZXNcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMjMsIGRhdGEsIDApLFwiaW52ZXJzZVwiOmNvbnRhaW5lci5wcm9ncmFtKDI2LCBkYXRhLCAwKSxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKVxuICAgICsgXCIgICAgICAgICAgPC9kaXY+XFxuICAgICAgICA8L2Rpdj5cXG5cIjtcbn0sXCIyM1wiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMSwgYWxpYXMxPWNvbnRhaW5lci5sYW1iZGEsIGFsaWFzMj1jb250YWluZXIuZXNjYXBlRXhwcmVzc2lvbjtcblxuICByZXR1cm4gXCIgICAgICAgICAgICAgIDxpbnB1dCBjbGFzcz1cXFwiZm9ybS1jb250cm9sIGRhdGUgXCJcbiAgICArIGFsaWFzMihhbGlhczEoKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpZWxkX25hbWUgOiBkZXB0aDApLCBkZXB0aDApKVxuICAgICsgXCJcXFwiIGRhdGEtdHlwZT1cXFwiXCJcbiAgICArIGFsaWFzMihhbGlhczEoKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmRpc3BsYXlfdGV4dCA6IGRlcHRoMCksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCIgbmFtZT1cXFwiXCJcbiAgICArIGFsaWFzMihhbGlhczEoKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpZWxkX25hbWUgOiBkZXB0aDApLCBkZXB0aDApKVxuICAgICsgXCJcXFwiIFwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnNbXCJpZlwiXS5jYWxsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSksKChzdGFjazEgPSAoKHN0YWNrMSA9IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC52YWx1ZSA6IGRlcHRoMCkpICE9IG51bGwgPyBzdGFjazFbXCIwXCJdIDogc3RhY2sxKSkgIT0gbnVsbCA/IHN0YWNrMS5zZWxlY3RlZCA6IHN0YWNrMSkse1wibmFtZVwiOlwiaWZcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMjQsIGRhdGEsIDApLFwiaW52ZXJzZVwiOmNvbnRhaW5lci5ub29wLFwiZGF0YVwiOmRhdGF9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpXG4gICAgKyBcIiAvPlxcblwiO1xufSxcIjI0XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgc3RhY2sxO1xuXG4gIHJldHVybiBcIiB2YWx1ZT1cIlxuICAgICsgY29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb24oY29udGFpbmVyLmxhbWJkYSgoKHN0YWNrMSA9ICgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnZhbHVlIDogZGVwdGgwKSkgIT0gbnVsbCA/IHN0YWNrMVtcIjBcIl0gOiBzdGFjazEpKSAhPSBudWxsID8gc3RhY2sxLnZhbHVlIDogc3RhY2sxKSwgZGVwdGgwKSlcbiAgICArIFwiIFwiO1xufSxcIjI2XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgc3RhY2sxLCBhbGlhczE9Y29udGFpbmVyLmxhbWJkYSwgYWxpYXMyPWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uO1xuXG4gIHJldHVybiBcIiAgICAgICAgICAgICAgPHNlbGVjdCBjbGFzcz1cXFwiZm9ybS1jb250cm9sIHNlbGVjdCBcIlxuICAgICsgYWxpYXMyKGFsaWFzMSgoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZmllbGRfbmFtZSA6IGRlcHRoMCksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCIgZGF0YS10eXBlPVxcXCJcIlxuICAgICsgYWxpYXMyKGFsaWFzMSgoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZGlzcGxheV90ZXh0IDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiBtdWx0aXBsZSBuYW1lPVxcXCJcIlxuICAgICsgYWxpYXMyKGFsaWFzMSgoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZmllbGRfbmFtZSA6IGRlcHRoMCksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCIgZGF0YS1jdXN0b209XFxcIlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5jdXN0b21fbGFiZWwgOiBkZXB0aDApLCBkZXB0aDApKVxuICAgICsgXCJcXFwiPlxcblwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnMuZWFjaC5jYWxsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSksKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnZhbHVlIDogZGVwdGgwKSx7XCJuYW1lXCI6XCJlYWNoXCIsXCJoYXNoXCI6e30sXCJmblwiOmNvbnRhaW5lci5wcm9ncmFtKDE5LCBkYXRhLCAwKSxcImludmVyc2VcIjpjb250YWluZXIubm9vcCxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKVxuICAgICsgXCIgICAgICAgICAgICAgIDwvc2VsZWN0PlxcblwiO1xufSxcIjI4XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICB2YXIgc3RhY2sxO1xuXG4gIHJldHVybiBcIiAgICA8aHIvPlxcbiAgICA8bGFiZWwgY2xhc3M9XFxcImZvbnQtc2VtaS1ib2xkXFxcIj5BdHRlbmRlZXM8L2xhYmVsPlxcbiAgICA8ZGl2IGNsYXNzPVxcXCJyb3dcXFwiPlxcblwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnMuZWFjaC5jYWxsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSksKChzdGFjazEgPSAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZmlsdGVycyA6IGRlcHRoMCkpICE9IG51bGwgPyBzdGFjazEudXNlckZpbHRlcnMgOiBzdGFjazEpLHtcIm5hbWVcIjpcImVhY2hcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMjksIGRhdGEsIDApLFwiaW52ZXJzZVwiOmNvbnRhaW5lci5ub29wLFwiZGF0YVwiOmRhdGF9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpXG4gICAgKyBcIiAgICA8L2Rpdj5cXG5cIjtcbn0sXCIyOVwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMTtcblxuICByZXR1cm4gKChzdGFjazEgPSBfX2RlZmF1bHQocmVxdWlyZShcIi4uLy4uL2hlbHBlcnMvaXNFcXVhbFRvLmpzXCIpKS5jYWxsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSksKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpZWxkX25hbWUgOiBkZXB0aDApLFwibWVldGluZ19wYXJ0aWNpcGFudHNcIix7XCJuYW1lXCI6XCJpc0VxdWFsVG9cIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMzAsIGRhdGEsIDApLFwiaW52ZXJzZVwiOmNvbnRhaW5lci5wcm9ncmFtKDMzLCBkYXRhLCAwKSxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKTtcbn0sXCIzMFwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMSwgYWxpYXMxPWNvbnRhaW5lci5sYW1iZGEsIGFsaWFzMj1jb250YWluZXIuZXNjYXBlRXhwcmVzc2lvbiwgYWxpYXMzPWRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSk7XG5cbiAgcmV0dXJuIFwiICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImZpbHRlci1pdGVtIGNvbC1tZC0xMiBoaWRlIFwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiBkYXRhLXR5cGU9XFxcIlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIj5cXG4gICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjaGVja2JveFxcXCI+XFxuICAgICAgICAgICAgICA8aW5wdXQgdHlwZT1cXFwiY2hlY2tib3hcXFwiIFwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnNbXCJpZlwiXS5jYWxsKGFsaWFzMywoKHN0YWNrMSA9ICgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnZhbHVlIDogZGVwdGgwKSkgIT0gbnVsbCA/IHN0YWNrMVtcIjBcIl0gOiBzdGFjazEpKSAhPSBudWxsID8gc3RhY2sxLnZhbHVlIDogc3RhY2sxKSx7XCJuYW1lXCI6XCJpZlwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSgzMSwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiIGlkPVwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiIG5hbWU9XCJcbiAgICArIGFsaWFzMihhbGlhczEoKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpZWxkX25hbWUgOiBkZXB0aDApLCBkZXB0aDApKVxuICAgICsgXCIgZGF0YS10eXBlPVxcXCJcIlxuICAgICsgYWxpYXMyKGFsaWFzMSgoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZGlzcGxheV90ZXh0IDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiA+XFxuICAgICAgICAgICAgICA8bGFiZWwgZm9yPVwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiPlwiXG4gICAgKyBhbGlhczIoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi8uLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMzLChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5kaXNwbGF5X3RleHQgOiBkZXB0aDApLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIjwvbGFiZWw+XFxuICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgIDwvZGl2PlxcblwiO1xufSxcIjMxXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICByZXR1cm4gXCIgY2hlY2tlZCBcIjtcbn0sXCIzM1wiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMSwgYWxpYXMxPWNvbnRhaW5lci5sYW1iZGEsIGFsaWFzMj1jb250YWluZXIuZXNjYXBlRXhwcmVzc2lvbiwgYWxpYXMzPWRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSk7XG5cbiAgcmV0dXJuIFwiICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImZpbHRlci1pdGVtIGNvbC1tZC02XFxcIiBkYXRhLXR5cGU9XFxcIlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maWVsZF9uYW1lIDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIj5cXG4gICAgICAgICAgICA8bGFiZWw+XCJcbiAgICArIGFsaWFzMihfX2RlZmF1bHQocmVxdWlyZShcIi4uLy4uL2hlbHBlcnMvdC5qc1wiKSkuY2FsbChhbGlhczMsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmRpc3BsYXlfdGV4dCA6IGRlcHRoMCkse1wibmFtZVwiOlwidFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSlcbiAgICArIFwiPC9sYWJlbD5cXG4gICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJmaWx0ZXItdmFsdWVzIHRva2VuLWlucHV0LWZsZFxcXCI+XFxuICAgICAgICAgICAgICA8c2VsZWN0IGNsYXNzPVxcXCJmb3JtLWNvbnRyb2wgc2VsZWN0IGF0dGVuZGVlLXNlbGVjdCBcIlxuICAgICsgYWxpYXMyKGFsaWFzMSgoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZmllbGRfbmFtZSA6IGRlcHRoMCksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCIgZGF0YS10eXBlPVxcXCJcIlxuICAgICsgYWxpYXMyKGFsaWFzMSgoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZGlzcGxheV90ZXh0IDogZGVwdGgwKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIiBtdWx0aXBsZSBuYW1lPVxcXCJcIlxuICAgICsgYWxpYXMyKGFsaWFzMSgoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZmllbGRfbmFtZSA6IGRlcHRoMCksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCI+XFxuXCJcbiAgICArICgoc3RhY2sxID0gaGVscGVycy5lYWNoLmNhbGwoYWxpYXMzLChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC52YWx1ZSA6IGRlcHRoMCkse1wibmFtZVwiOlwiZWFjaFwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSgxOSwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiICAgICAgICAgICAgICA8L3NlbGVjdD5cXG4gICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgPC9kaXY+XFxuXCI7XG59LFwiY29tcGlsZXJcIjpbNyxcIj49IDQuMC4wXCJdLFwibWFpblwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMSwgYWxpYXMxPWRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSk7XG5cbiAgcmV0dXJuICgoc3RhY2sxID0gaGVscGVyc1tcImlmXCJdLmNhbGwoYWxpYXMxLCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpbHRlcnMgOiBkZXB0aDApKSAhPSBudWxsID8gc3RhY2sxLmJyaWVmaW5ncyA6IHN0YWNrMSkse1wibmFtZVwiOlwiaWZcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMSwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiPGRpdiBpZD1cXFwibWVldGluZy10eXBlLWZpbHRlclxcXCIgY2xhc3M9XFxcInRhYi1wYW5lIFwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnMudW5sZXNzLmNhbGwoYWxpYXMxLCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpbHRlcnMgOiBkZXB0aDApKSAhPSBudWxsID8gc3RhY2sxLmJyaWVmaW5ncyA6IHN0YWNrMSkse1wibmFtZVwiOlwidW5sZXNzXCIsXCJoYXNoXCI6e30sXCJmblwiOmNvbnRhaW5lci5wcm9ncmFtKDEyLCBkYXRhLCAwKSxcImludmVyc2VcIjpjb250YWluZXIubm9vcCxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKVxuICAgICsgXCJcXFwiIHJvbGU9XFxcInRhYnBhbmVsXFxcIj5cXG4gIDxkaXYgY2xhc3M9XFxcInJvd1xcXCI+XFxuXCJcbiAgICArICgoc3RhY2sxID0gaGVscGVyc1tcImlmXCJdLmNhbGwoYWxpYXMxLCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpbHRlcnMgOiBkZXB0aDApKSAhPSBudWxsID8gc3RhY2sxLm1lZXRpbmdzIDogc3RhY2sxKSx7XCJuYW1lXCI6XCJpZlwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSgxNCwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLnByb2dyYW0oMjEsIGRhdGEsIDApLFwiZGF0YVwiOmRhdGF9KSkgIT0gbnVsbCA/IHN0YWNrMSA6IFwiXCIpXG4gICAgKyBcIiAgPC9kaXY+XFxuXCJcbiAgICArICgoc3RhY2sxID0gaGVscGVyc1tcImlmXCJdLmNhbGwoYWxpYXMxLCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpbHRlcnMgOiBkZXB0aDApKSAhPSBudWxsID8gc3RhY2sxLnVzZXJGaWx0ZXJzIDogc3RhY2sxKSx7XCJuYW1lXCI6XCJpZlwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSgyOCwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiPC9kaXY+XFxuXFxuXFxuXFxuXFxuXFxuXFxuXCI7XG59LFwidXNlRGF0YVwiOnRydWV9KTsiLCJ2YXIgSGFuZGxlYmFycyA9IHJlcXVpcmUoXCIuLi8uLi8uLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9ydW50aW1lLmpzXCIpO1xuZnVuY3Rpb24gX19kZWZhdWx0KG9iaikgeyByZXR1cm4gb2JqICYmIChvYmouX19lc01vZHVsZSA/IG9ialtcImRlZmF1bHRcIl0gOiBvYmopOyB9XG5tb2R1bGUuZXhwb3J0cyA9IChIYW5kbGViYXJzW1wiZGVmYXVsdFwiXSB8fCBIYW5kbGViYXJzKS50ZW1wbGF0ZSh7XCIxXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEsYmxvY2tQYXJhbXMsZGVwdGhzKSB7XG4gICAgdmFyIHN0YWNrMTtcblxuICByZXR1cm4gKChzdGFjazEgPSBoZWxwZXJzLmVhY2guY2FsbChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC52YWx1ZXMgOiBkZXB0aDApLHtcIm5hbWVcIjpcImVhY2hcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMiwgZGF0YSwgMCwgYmxvY2tQYXJhbXMsIGRlcHRocyksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIik7XG59LFwiMlwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhLGJsb2NrUGFyYW1zLGRlcHRocykge1xuICAgIHZhciBoZWxwZXIsIGFsaWFzMT1jb250YWluZXIubGFtYmRhLCBhbGlhczI9Y29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb24sIGFsaWFzMz1kZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLCBhbGlhczQ9aGVscGVycy5oZWxwZXJNaXNzaW5nLCBhbGlhczU9XCJmdW5jdGlvblwiO1xuXG4gIHJldHVybiBcIlx0PGxpIGNsYXNzPVxcXCJzZWxlY3RlZC1maWx0ZXJcXFwiIGRhdGEtdHlwZT1cXFwiXCJcbiAgICArIGFsaWFzMihhbGlhczEoKGNvbnRhaW5lci5kYXRhKGRhdGEsIDEpICYmIGNvbnRhaW5lci5kYXRhKGRhdGEsIDEpLmtleSksIGRlcHRoMCkpXG4gICAgKyBcIlxcXCI+XFxuXHRcdDxkaXYgY2xhc3M9XFxcInNlbGVjdGVkLWl0ZW1cXFwiIGRhdGEta2V5PVxcXCJcIlxuICAgICsgYWxpYXMyKCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMua2V5IHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5rZXkgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXM0KSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXM1ID8gaGVscGVyLmNhbGwoYWxpYXMzLHtcIm5hbWVcIjpcImtleVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiPlxcblx0XHRcdDxhIGNsYXNzPVxcXCJyZW1vdmVcXFwiIGhyZWY9XFxcImphdmFzY3JpcHQ6dm9pZCgwKVxcXCI+XFxuXHRcdFx0XHQ8aSBjbGFzcz1cXFwiamlmLWNsb3NlIGNsb3NlLWFwcGxpZWQtZmlsdGVyIGppZi1kYXJrMS1ncmV5XFxcIj48L2k+XFxuXHRcdFx0PC9hPlxcblx0XHRcdDxzcGFuIGNsYXNzPVxcXCJyZW1vdmVfZmlsdGVyX2ljb25cXFwiPlwiXG4gICAgKyBhbGlhczIoYWxpYXMxKChkZXB0aHNbMV0gIT0gbnVsbCA/IGRlcHRoc1sxXS5kaXNwbGF5X25hbWUgOiBkZXB0aHNbMV0pLCBkZXB0aDApKVxuICAgICsgXCI6IFwiXG4gICAgKyBhbGlhczIoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5uYW1lIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5uYW1lIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzNCksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzNSA/IGhlbHBlci5jYWxsKGFsaWFzMyx7XCJuYW1lXCI6XCJuYW1lXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIjwvc3Bhbj5cXG5cdFx0PC9kaXY+XFxuXHQ8L2xpPlxcblwiO1xufSxcImNvbXBpbGVyXCI6WzcsXCI+PSA0LjAuMFwiXSxcIm1haW5cIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSxibG9ja1BhcmFtcyxkZXB0aHMpIHtcbiAgICB2YXIgc3RhY2sxO1xuXG4gIHJldHVybiAoKHN0YWNrMSA9IGhlbHBlcnMuZWFjaC5jYWxsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSksKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmZpbHRlciA6IGRlcHRoMCkse1wibmFtZVwiOlwiZWFjaFwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSgxLCBkYXRhLCAwLCBibG9ja1BhcmFtcywgZGVwdGhzKSxcImludmVyc2VcIjpjb250YWluZXIubm9vcCxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKTtcbn0sXCJ1c2VEYXRhXCI6dHJ1ZSxcInVzZURlcHRoc1wiOnRydWV9KTsiXSwic291cmNlUm9vdCI6IiJ9