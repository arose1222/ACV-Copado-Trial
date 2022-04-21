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
/******/ 	return __webpack_require__(__webpack_require__.s = "./app/scripts/Session/app.js");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./app/scripts/Session/actions.js":
/*!****************************************!*\
  !*** ./app/scripts/Session/actions.js ***!
  \****************************************/
/*! no static exports found */
/***/ (function(module, exports) {

var SessionActions = Reflux.createActions(['fetchSessions', 'fetchSessionNominations', 'fetchSessionCheckinList', 'checkinSession', 'checkinAttendee']);
module.exports = SessionActions;

/***/ }),

/***/ "./app/scripts/Session/app.js":
/*!************************************!*\
  !*** ./app/scripts/Session/app.js ***!
  \************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

initI18n(_.assign(enLocale['meetings'], enLocale['external_meetings'], enLocale['sessions']));
var Handler = __webpack_require__(/*! ./handler */ "./app/scripts/Session/handler.js");
var checkinHandler = __webpack_require__(/*! ./checkin_handler */ "./app/scripts/Session/checkin_handler.js");
var Api = __webpack_require__(/*! common_api */ "./app/scripts/commons/jiffle/api.js");

$(document).ready(function (jQuery) {
    if (typeof jiffle !== 'undefined') {
        Api.sfdcHandler.meetingInit(function () {
            Handler.init();
        });
    } else {
        window.sessionCheckin === true ? checkinHandler.init() : Handler.init();
    }
    setupUiI18n();
});

/***/ }),

/***/ "./app/scripts/Session/checkin_handler.js":
/*!************************************************!*\
  !*** ./app/scripts/Session/checkin_handler.js ***!
  \************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var Actions = __webpack_require__(/*! ./actions */ "./app/scripts/Session/actions.js");
var Store = __webpack_require__(/*! ./store */ "./app/scripts/Session/store.js").CheckinStore;
var SessionStore = __webpack_require__(/*! ./store */ "./app/scripts/Session/store.js").SessionStore;
var Api = __webpack_require__(/*! common_api */ "./app/scripts/commons/jiffle/api.js");

var CheckinHandler = function () {
  var navbarSearch = $('.navbar-search.navbar-form');
  var filter = $('.dropdown.filter-dropdown');
  var sessionCheckinContainer = $('#session_checkin_list');
  var defaultToggleState = { viewStyle: 'list-view', tileSize: 'col-md-12' };
  var consecutiveMeetingTab = $('.tab_consecutive_meeting');
  var mobileConsecutiveCountTab = $('.mobile_tab_consecutive_meeting');
  var sessionCountTab = $('.tab_session');
  var mobileSessionCountTab = $('.mobile_tab_session');
  var internalCountTab = $('.tab_internal');
  var mobileInternalCountTab = $('.mobile_tab_internal');
  var externalCountTab = $('.tab_external');
  var mobileExternalCountTab = $('.mobile_tab_external');
  var exportBtn = $('#export');

  var storeHandlers = {
    onSessionCheckinListSuccess: onSessionCheckinListSuccess
  };

  function init() {
    setupUI();
    setupListeners();
    setupStoreListeners();
    Actions.fetchSessionCheckinList(1);
    activateTabs();
  }

  function activateTabs() {
    internalCountTab.removeClass('active');
    mobileInternalCountTab.removeClass('active');
    externalCountTab.removeClass('active');
    mobileExternalCountTab.removeClass('active');
    consecutiveMeetingTab.removeClass('active');
    mobileConsecutiveCountTab.removeClass('active');
    sessionCountTab.addClass('active');
    mobileSessionCountTab.addClass('active');
  }

  function setupUI() {
    navbarSearch.addClass('hide');
    filter.addClass('hide');
  }

  function setupStoreListeners() {
    Store.listen(function (data) {
      var callBackFunction = storeHandlers[data.action];
      if (data.action && _.isFunction(callBackFunction)) {
        callBackFunction(data.payload);
      }
    });
  }

  function onSessionCheckinListSuccess(payload) {
    var sessions = payload.data;
    displayCounts(payload.totalInternal, payload.totalExternal, payload.totalConsecMeeting, payload.totalSessions);
    var template = __webpack_require__(/*! Templates/meeting/checkin */ "./templates/meeting/checkin.hbs");
    sessions.map(function (session) {
      session.pendingCount = session.invitees_status_counts.pending || 0;
      session.totalInviteeCount = session.invitees_status_counts.total_invitees || 0;
      session.acceptedCount = session.invitees_status_counts.accepted || 0;
      session.declinedCount = session.invitees_status_counts.declined || 0;
      session.topicName = session.topic.name;
      session.startTime = moment(session.start_time, "YYYY-MM-DD hh:mm A").format("hh:mm A");
      session.endTime = moment(session.end_time, "YYYY-MM-DD hh:mm A").format("hh:mm A");
      session.meetingDate = moment(session.start_time).toDate().toMediumDate();
      session.location = session.room.name;
      session.checkedIn = session.checkin === true;
      setCheckInStatuses(session.users.internal.concat(session.users.external));
    });

    var html = template({
      meeting_list: sessions,
      toggle_state: defaultToggleState
    });
    sessionCheckinContainer.html(html);
  }

  function displayCounts(internalCount, externalCount, consecCount, sessionCount) {
    var internalTabText = i18n.t(internalCount === 1 ? "MEETING" : "MEETINGS", { count: '' });
    var externalTabText = i18n.t(externalCount === 1 ? "REQUEST" : "REQUESTS", { count: '' });
    var externalMobileTabText = i18n.t(externalCount === 1 ? "REQ" : "REQS", { count: '' });
    var sessionTabtext = i18n.t(sessionCount === 1 ? "SESSION" : "SESSIONS");
    var consecutiveTabText = i18n.t(consecCount === 1 ? "CONSECUTIVE MEETING" : "CONSECUTIVE MEETINGS");
    displayCountInTab(externalCountTab, mobileExternalCountTab, externalCount, externalTabText);
    displayCountInTab(internalCountTab, mobileInternalCountTab, internalCount, internalTabText);
    displayCountInTab(consecutiveMeetingTab, mobileConsecutiveCountTab, consecCount, consecutiveTabText);
    displayCountInTab(sessionCountTab, mobileSessionCountTab, sessionCount, sessionTabtext);
  }

  function displayCountInTab(tab, mobileTab, count, textLabel, mobileTextLabel) {
    tab.find(".meeting_count").text(count).siblings('span.title_text').text(textLabel);
    mobileTab.find(".meeting_count").text(count).siblings('span.title_text').text(mobileTextLabel || textLabel);
  }

  function setCheckInStatuses(attendees) {
    if (attendees instanceof Array) {
      attendees.map(function (attendee) {
        attendee.checkedIn = attendee.checkin === true;
      });
    }
  }

  function setupListeners() {
    $('.toggle-btn').on('click', handleToggleView);
    $(window).infiniteScroll({
      offset: 200,
      callback: fetchMoreSessionsCheckin
    });
    sessionCheckinContainer.on('change', '.checkin_meeting', handleSessionCheckin);
    sessionCheckinContainer.on('change', '.checkin_user', handleAttendeeCheckin);
    internalCountTab.on('click', handleInternalTabClick);
    mobileInternalCountTab.on('click', handleInternalTabClick);
    externalCountTab.on('click', handleExternalTabClick);
    mobileExternalCountTab.on('click', handleExternalTabClick);
    consecutiveMeetingTab.on('click', handleConsecutiveTabClick);
    mobileConsecutiveCountTab.on('click', handleConsecutiveTabClick);
    exportBtn.on('click', exportSessions);
  }

  function exportSessions(event) {
    event.preventDefault();
    event.stopPropagation();
    window.commons.redirectPage(SessionStore.generateExportUrl());
  }

  function handleConsecutiveTabClick(event) {
    event.preventDefault();
    event.stopPropagation();
    commons.redirectPage(envDetails.urlPrefix + Api.ENDPOINTS.consecutive_list_page);
  }

  function handleInternalTabClick(event) {
    event.preventDefault();
    event.stopPropagation();
    commons.redirectPage(envDetails.urlPrefix + Api.ENDPOINTS.meeting_list);
  }

  function handleExternalTabClick(event) {
    event.preventDefault();
    event.stopPropagation();
    commons.redirectPage(envDetails.urlPrefix + Api.ENDPOINTS.external_requests);
  }

  function handleSessionCheckin(event) {
    event.preventDefault();
    event.stopPropagation();
    var session = $(this);
    var sessionUuid = session.closest('.meeting-card').data('uuid');
    var status = session.is(':checked') ? 1 : 0;
    Actions.checkinSession(sessionUuid, status);
  }

  function handleAttendeeCheckin(event) {
    event.preventDefault();
    event.stopPropagation();
    var attendee = $(this);
    var session = attendee.closest('.meeting-card');
    var sessionUuid = session.data('uuid');
    var attendeeUuid = attendee.data('uuid');
    var attendeeType = attendee.data('attendee_type');
    var status = attendee.is(':checked') ? 1 : 0;
    if (status === 1) {
      session.find('.checkin_meeting').prop('checked', true);
    }
    Actions.checkinAttendee(sessionUuid, attendeeUuid, status, attendeeType);
  }

  function fetchMoreSessionsCheckin() {
    if (Store.getCurrentPage() <= Store.getTotalPages()) {
      Actions.fetchSessionCheckinList(Store.getCurrentPage());
    }
  }

  function handleToggleView() {
    var elem = $(this);
    var type = elem.data('switch-type');
    if (type !== 'checkin') {
      var redirectUrl = envDetails.urlPrefix + Api.ENDPOINTS.session_list;
      commons.redirectPage(redirectUrl);
      commons.setItem('session-list', type);
    }
  }

  return {
    init: init
  };
}();

module.exports = CheckinHandler;

/***/ }),

/***/ "./app/scripts/Session/handler.js":
/*!****************************************!*\
  !*** ./app/scripts/Session/handler.js ***!
  \****************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var Actions = __webpack_require__(/*! ./actions */ "./app/scripts/Session/actions.js");
var Store = __webpack_require__(/*! ./store */ "./app/scripts/Session/store.js").SessionStore;
var Api = __webpack_require__(/*! common_api */ "./app/scripts/commons/jiffle/api.js");

var SessionHandler = function () {

  var sessionListContainer = $('#meeting_list');
  //var externalCountTab = $('.tab_external');
  //var mobileExternalCountTab = $('.mobile_tab_external');
  var internalCountTab = $('.tab_internal');
  var mobileInternalCountTab = $('.mobile_tab_internal');
  var sessionCountTab = $('.tab_session');
  var mobileSessionCountTab = $('.mobile_tab_session');
  var internalSelectAll = $(".manage-internal-selectall");
  var exportBtn = $('#export');
  var currentViewStyle;
  var consecutiveMeetingTab = $('.tab_consecutive_meeting');
  var mobileConsecutiveCountTab = $('.mobile_tab_consecutive_meeting');
  var notificationModal = $(".notification-modal");
  var itemSize = {
    'tile-view': 'col-md-3 col-sm-4',
    'list-view': 'col-md-12'
  };

  var storeHandlers = {
    sessionlisting: handelSessionList,
    sessionNominations: handleSessionNominations
  };

  function init() {

    $(".navbar-form").hide();
    $("li.filter-dropdown").hide(); // vinay: hiding since there is no search and filters for sessions yet.
    sessionListContainer.on('click', '#session_click', getNominations);
    mobileInternalCountTab.removeClass('active');
    //mobileExternalCountTab.removeClass('active');
    internalCountTab.removeClass('active');
    //externalCountTab.removeClass('active');
    sessionCountTab.addClass('active');
    mobileSessionCountTab.addClass('active');
    commons.setItem('meeting-list', 'grid');
    internalSelectAll.addClass("hide");
    setUpListeners();
    Store.listen(function (data) {
      var func = storeHandlers[data.type];
      if (func) {
        func(data);
      }
    });

    Actions.fetchSessions(1);
    setView();
  }

  function setView() {
    $('a[data-switch-type]').removeClass('active');
    if (commons.getItem('session-list') === 'list') {
      currentViewStyle = 'list-view';
      $('a[data-switch-type="list"]').addClass('active');
    } else {
      currentViewStyle = 'tile-view';
      $('a[data-switch-type="grid"]').addClass('active');
    }
  }

  function handleConsecutiveTabClick(event) {
    event.preventDefault();
    event.stopPropagation();
    commons.redirectPage(envDetails.urlPrefix + Api.ENDPOINTS.consecutive_list_page);
  }

  function setUpListeners() {

    attachCommonUIListeneres();

    internalCountTab.on('click', handleInternalTabClick);
    mobileInternalCountTab.on('click', handleInternalTabClick);
    //externalCountTab.on('click', handleExternalTabClick);
    //mobileExternalCountTab.on('click', handleExternalTabClick);
    $('a[data-switch-type]').on('click', handelViewToggle);
    exportBtn.on('click', exportSessions);
    consecutiveMeetingTab.on('click', handleConsecutiveTabClick);
    mobileConsecutiveCountTab.on('click', handleConsecutiveTabClick);
    sessionCountTab.on('click', handleSessionTabClick);
    mobileSessionCountTab.on('click', handleSessionTabClick);
  }

  function attachCommonUIListeneres() {

    $(window).infiniteScroll({
      offset: 200,
      callback: fetchMoreSessions
    });
  }

  function getNominations(e) {
    var sessionUuid = $(this).data("uuid");
    Actions.fetchSessionNominations({ session_uuid: sessionUuid });
  }

  function exportSessions(e) {
    e.preventDefault();
    e.stopPropagation();
    window.commons.redirectPage(Store.generateExportUrl());
  }

  function hideNominationsList() {
    $("#group-nominatoin-list").modal('hide');
  }

  function showNominationsList() {
    $("#group-nominatoin-list").modal('show');
  }

  function handleSessionNominations(apiResponse) {
    var nominationLabel = commonStore.getCustomLabels()['nomination_custom_label'];
    var nominations = apiResponse.data.data.nominations,
        redirectionPath;
    if (nominations.length === 0) {
      if (apiResponse.data.data.show_message) {
        notificationModal.notificationModal({ title: i18n.t('no_nominations_header', { nominationLabel: nominationLabel }), body: apiResponse.data.data.message, class: 'blue' });
      } else {
        var sessionParams = "";
        var sessionObj = Store.getSessionObj(apiResponse.data.data.session_uuid);
        if (!_.isEmpty(sessionObj)) {
          sessionParams = "&session_uuid=" + sessionObj.uuid + "&track_uuid=" + sessionObj.track.uuid + "&topic_uuid=" + sessionObj.topic.uuid;
        }
        commons.redirectPage(envDetails.urlPrefix + Api.ENDPOINTS.meeting_request_path + '?' + $.param({
          activity_uuid: apiResponse.data.data.activity_uuid
        }) + sessionParams);
      }
    } else {
      var editable_nomination;
      $(nominations).each(function (i, value) {
        if (value.can_edit) {
          editable_nomination = value;
          return false;
        }
      });
      if (editable_nomination) {
        if (typeof jiffle !== 'undefined') {
          var redirectionPath = window.location.origin + Api.ENDPOINTS.jn_book_nomination;
          var search = window.location.search;
          var modeQ = '&mode=edit';
          search = search + "&nomination=" + editable_nomination.uuid;
          redirectionPath = redirectionPath + search + modeQ;
        } else {
          redirectionPath = envDetails.urlPrefix + Api.ENDPOINTS.group_nomination_edit;
          redirectionPath = redirectionPath.replace('{{uuid}}', editable_nomination.uuid);
        }
      } else {
        if (typeof jiffle !== 'undefined') {
          var redirectionPath = window.location.origin + Api.ENDPOINTS.jn_view_nomination;
          var search = window.location.search;
          var modeQ = '&mode=view';
          search = search + "&nomination=" + nominations[0].uuid;
          redirectionPath = redirectionPath + search + modeQ;
        } else {
          redirectionPath = envDetails.urlPrefix + Api.ENDPOINTS.group_nomination_view;
          redirectionPath = redirectionPath.replace('{{uuid}}', nominations[0].uuid);
        }
      }
      commons.redirectPage(redirectionPath);
    }
  }
  function handelSessionList(data) {
    displayMeetings(data.data);
    updateMeetingCount(data.data.total, data.data.totalExternal, data.data.totalInternal, data.data.totalConsec);
  }

  function handelViewToggle(data) {
    var El = $(this);
    var isCheckInClick = El.data('switch-type') === 'checkin' ? true : false;

    if (isCheckInClick) {
      var checkinUrl = envDetails.urlPrefix + Api.ENDPOINTS.checkin_sessions_list;
      window.commons.redirectPage(checkinUrl);
    } else {
      $('a[data-switch-type]').removeClass('active');
      El.addClass('active');
      var viewStyle = { 'grid': 'tile-view', 'list': 'list-view' }[El.data("switch-type")];
      currentViewStyle = viewStyle;
      var listHolder = sessionListContainer.find('.meeting-list');
      listHolder.removeClass("tile-view list-view").addClass(viewStyle);
      listHolder.find("div.item").removeClass("col-md-3 col-sm-4 col-md-12").addClass(itemSize[viewStyle]);
    }
  }

  function displayMeetings(data) {

    var template = __webpack_require__(/*! Templates/meeting/session-list */ "./templates/meeting/session-list.hbs");
    var sessions = _.cloneDeep(data.sessions);
    sessions.map(function (session) {
      session.remainingCount = session.capacity - session.not_declined_user_count;
      session.sessionDate = moment(session.start_time).toDate().toMediumDate();
      session.startTime = moment(session.start_time, "YYYY-MM-DD hh:mm A").format("hh:mm A");
      session.endTime = moment(session.end_time, "YYYY-MM-DD hh:mm A").format("hh:mm A");
    });
    sessionListContainer.html(template({
      sessions_list: sessions,
      toggle_state: {
        viewStyle: currentViewStyle,
        tileSize: itemSize[currentViewStyle]
      }
    }));
  }

  function updateMeetingCount(count, externalCount, internalCount, consecCount) {

    $(".tab_session").find(".meeting_count").text(count).siblings('span.title_text').html(i18n.t(count === 1 ? "SESSION" : "SESSIONS", { count: '' }));
    $(".mobile_tab_session").find(".meeting_count").text(count).siblings('span.title_text').html(i18n.t(count === 1 ? "SESSION" : "SESSIONS", { count: '' }));
    $(".mobile_tab_internal").find(".meeting_count").text(internalCount).siblings('span.title_text').html(i18n.t(internalCount === 1 ? "MEETING" : "MEETINGS", { count: '' }));
    $(".tab_internal").find(".meeting_count").text(internalCount).siblings('span.title_text').html(i18n.t(internalCount === 1 ? "MEETING" : "MEETINGS", { count: '' }));
    $(".mobile_tab_external").find(".meeting_count").text(externalCount).siblings('span.title_text').html(i18n.t(externalCount === 1 ? "REQ" : "REQS", { count: '' }));
    $(".tab_external").find(".meeting_count").text(externalCount).siblings('span.title_text').html(i18n.t(externalCount === 1 ? "REQUEST" : "REQUESTS", { count: '' }));
    consecutiveMeetingTab.find(".meeting_count").text(consecCount).siblings('span.title_text').html(i18n.t(consecCount === 1 ? "consecutive_meeting" : "consecutive_meetings", { count: '' }));
    mobileConsecutiveCountTab.find(".meeting_count").text(consecCount).siblings('span.title_text').html(i18n.t(consecCount === 1 ? "consecutive_meetings" : "consecutive_meetings", { count: '' }));
  }

  function handleInternalTabClick(event) {
    event.preventDefault();
    event.stopPropagation();

    if (typeof jiffle !== 'undefined') {
      var search = window.location.search;
      newPage = Api.ENDPOINTS.apex_jnmeetings + search;
      window.commons.redirectPage(newPage);
    } else commons.redirectPage(envDetails.urlPrefix + '/meeting_list');
  }

  function handleSessionTabClick(event) {
    event.preventDefault();
    event.stopPropagation();

    if (typeof jiffle !== 'undefined') {
      var search = window.location.search;
      newPage = Api.ENDPOINTS.apex_jnsessions + search;
      window.commons.redirectPage(newPage);
    } else window.commons.redirectPage(envDetails.urlPrefix + '/session_list');
  }

  /*  function handleExternalTabClick(event) {
      event.preventDefault();
      event.stopPropagation();
  
      window.location.href = envDetails.urlPrefix + '/external_requests';
    }*/

  function fetchMoreSessions() {
    if (Store.getCurrentPage() <= Store.getTotalPageCount()) {
      Actions.fetchSessions(Store.getCurrentPage());
    }
  }

  return {
    init: init
  };
}();

module.exports = SessionHandler;

/***/ }),

/***/ "./app/scripts/Session/store.js":
/*!**************************************!*\
  !*** ./app/scripts/Session/store.js ***!
  \**************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var SessionActions = __webpack_require__(/*! ./actions */ "./app/scripts/Session/actions.js");
var Api = __webpack_require__(/*! common_api */ "./app/scripts/commons/jiffle/api.js");

var SessionStore = Reflux.createStore({

  init: function init() {
    this.listenToMany(SessionActions);

    this.sessions = [];
    this.fetching = false;
    this.per_page_session_count = 10;
    this.current_page = 1;
    this.total_pages = 0;
  },

  generateExportUrl: function generateExportUrl() {
    var prefix = envDetails['urlPrefix'] || "";
    return [prefix, Api.ENDPOINTS.session_export].join("");
  },

  onFetchSessions: function onFetchSessions(page_no, per_page) {

    if (this.getFetchState() == false) {
      this.updateFetchState(true);
      var promise = Api.fetch({
        url: Api.ENDPOINTS.sessions_list,
        data: {
          page: page_no,
          per_page: per_page || this.per_page_session_count
        }
      });

      promise.then(function (apiResponse) {

        this.updateFetchState(false);
        this.setCurrentPage(this.getCurrentPage() + 1);
        this.setTotalPageCount(Math.ceil(apiResponse.data.sessions.total_entries / this.per_page_session_count));

        this.sessions = this.sessions.concat(apiResponse.data.sessions.items);

        this.trigger({
          type: 'sessionlisting',
          data: {
            sessions: this.sessions,
            total: apiResponse.data.sessions.total_entries,
            totalExternal: apiResponse.data.external_requests_count,
            totalInternal: apiResponse.data.internal_meetings_count,
            totalConsec: apiResponse.data.consecutive_meetings_count
          }
        });
      }.bind(this));

      promise[promise.fail ? 'fail' : 'catch'](function (apiResponse) {
        this.updateFetchState(false);
      }.bind(this));
    }
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
  setCurrentPage: function setCurrentPage(page_no) {
    this.current_page = page_no;
  },
  getTotalPageCount: function getTotalPageCount() {
    return this.total_pages;
  },
  setTotalPageCount: function setTotalPageCount(count) {
    this.total_pages = count;
  },
  getSessionObj: function getSessionObj(session_uuid) {
    return _.find(this.sessions, function (session) {
      return session.uuid === session_uuid;
    });
  },

  onFetchSessionNominations: function onFetchSessionNominations(params) {
    params = _.extend(params, { page: 1, per_page: 500 });
    if (typeof nominationInfo != "undefined" && nominationInfo.request.session.uuid) {
      params = _.extend(params, { session_uuid: nominationInfo.request.session.uuid });
    }
    var promise = Api.fetch({
      url: Api.ENDPOINTS.session_nominations,
      data: params
    });

    promise.then(function (response) {
      response.data.session_uuid = params['session_uuid'];
      this.trigger({ type: 'sessionNominations', data: response });
    }.bind(this));

    promise[promise.fail ? 'fail' : 'catch'](function (data) {
      var response = data.responseJSON;
      this.trigger({ action: 'onCreateSessionFailed', payload: response });
    }.bind(this));
  }
});

var CheckinStore = Reflux.createStore({
  init: function init() {
    this.listenToMany(SessionActions);
    this.perPage = 10;
    this.totalPages;
    this.currentPage = 1;
    this.isFetching = false;
    this.sessions = [];
  },

  onFetchSessionCheckinList: function onFetchSessionCheckinList(pageNo) {
    var fetchState = this.getFetchState();

    if (fetchState === false) {
      this.setFetchState(true);
      var promise = Api.fetch({
        url: Api.ENDPOINTS.session_checkin_list,
        data: {
          page: pageNo,
          per_page: this.perPage
        }
      });
      promise.done(function (apiResponse) {
        this.setData(apiResponse.data.sessions);
        this.setTotalPages(apiResponse.data.total_entries);
        this.setCurrentPage(this.getCurrentPage() + 1);

        this.trigger({
          action: 'onSessionCheckinListSuccess',
          payload: {
            data: this.getData(),
            totalInternal: apiResponse.data.internal_request_count || 0,
            totalSessions: apiResponse.data.sessions_count || 0,
            totalExternal: apiResponse.data.external_requests_count || 0,
            totalConsecMeeting: apiResponse.data.consecutive_meetings_count || 0
          }
        });
        this.setFetchState(false);
      }.bind(this));
    }
  },

  onCheckinSession: function onCheckinSession(sessionUuid, status) {
    var promise = Api.update({
      url: Api.ENDPOINTS.update_checkin_status,
      type: "put",
      data: {
        user_uuid: '',
        object_type: "Session",
        meeting_uuid: sessionUuid,
        status: status
      }
    });
    promise.done(function (apiResponse) {}.bind(this));
  },

  onCheckinAttendee: function onCheckinAttendee(sessionUuid, attendeeUuid, status, attendeeType) {
    var promise = Api.update({
      url: Api.ENDPOINTS.update_checkin_status,
      type: "put",
      data: {
        object_type: "Session",
        user_uuid: attendeeUuid,
        meeting_uuid: sessionUuid,
        status: status
      }
    });

    promise.done(function (apiResponse) {}.bind(this));
  },

  setData: function setData(sessions) {
    this.sessions = this.sessions.concat(sessions);
  },

  getData: function getData() {
    return this.sessions;
  },

  setTotalPages: function setTotalPages(totalEntries) {
    this.totalPages = totalEntries % this.perPage == 0 ? totalEntries / this.perPage : Math.floor(totalEntries / this.perPage) + 1;
  },

  setCurrentPage: function setCurrentPage(page) {
    this.currentPage = page;
  },

  getCurrentPage: function getCurrentPage() {
    return this.currentPage;
  },

  setFetchState: function setFetchState(state) {
    this.isFetching = state;
  },

  getTotalPages: function getTotalPages() {
    return this.totalPages;
  },

  getFetchState: function getFetchState() {
    return this.isFetching;
  }
});

module.exports = {
  SessionStore: SessionStore,
  CheckinStore: CheckinStore
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

/***/ "./templates/meeting/checkin.hbs":
/*!***************************************!*\
  !*** ./templates/meeting/checkin.hbs ***!
  \***************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var Handlebars = __webpack_require__(/*! ../../node_modules/handlebars/runtime.js */ "./node_modules/handlebars/runtime.js");
function __default(obj) { return obj && (obj.__esModule ? obj["default"] : obj); }
module.exports = (Handlebars["default"] || Handlebars).template({"1":function(container,depth0,helpers,partials,data,blockParams,depths) {
    var stack1, helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression;

  return "      <div class=\"card meeting-card "
    + alias4(((helper = (helper = helpers.status || (depth0 != null ? depth0.status : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"status","hash":{},"data":data}) : helper)))
    + "\" data-uuid='"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "'>\n        <div class=\"card-header\">\n          <div class=\"card-header-content\">\n            <div class=\"card-select\">\n              <input type=\"checkbox\" class=\"meeting_card\" data-edit='"
    + alias4(((helper = (helper = helpers.edit || (depth0 != null ? depth0.edit : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"edit","hash":{},"data":data}) : helper)))
    + "' data-status=\""
    + alias4(((helper = (helper = helpers.status || (depth0 != null ? depth0.status : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"status","hash":{},"data":data}) : helper)))
    + "\" id=\""
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\">\n              <label for=\""
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\">\n                <div>M</div>\n              </label>\n            </div>\n            <div class=\"card-click\">\n"
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.meeting_with : depth0),{"name":"if","hash":{},"fn":container.program(2, data, 0, blockParams, depths),"inverse":container.program(4, data, 0, blockParams, depths),"data":data})) != null ? stack1 : "")
    + "              <div class=\"font-lg\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"ID",{"name":"t","hash":{},"data":data}))
    + " #"
    + alias4(((helper = (helper = helpers.id || (depth0 != null ? depth0.id : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"id","hash":{},"data":data}) : helper)))
    + "</div>\n            </div>\n          </div>\n        </div>\n        <div class=\"card-content\">\n          <div class=\"card-detail-content\">\n            <div >\n              <div class=\"card-detail icon-sep\">\n                <div class=\"text-content\">\n                  <span class=\"font-semi-bold\">"
    + alias4(((helper = (helper = helpers.startTime || (depth0 != null ? depth0.startTime : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"startTime","hash":{},"data":data}) : helper)))
    + " - "
    + alias4(((helper = (helper = helpers.endTime || (depth0 != null ? depth0.endTime : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"endTime","hash":{},"data":data}) : helper)))
    + "</span>\n                  <br>\n                  <span class=\"font-sm\">"
    + alias4(((helper = (helper = helpers.meetingDate || (depth0 != null ? depth0.meetingDate : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"meetingDate","hash":{},"data":data}) : helper)))
    + "</span>\n                </div>\n                <div class=\"icon-content hide jif-blue text-center icon-box\">\n                  <i class=\"jif-checkin\"></i>\n                  <div class=\"font-8\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"checkin",{"name":"t","hash":{},"data":data}))
    + "</div>\n                </div>\n              </div>\n              <div class=\"card-detail icon-sep\">\n                <div class=\"text-content\" title=\""
    + alias4(((helper = (helper = helpers.location || (depth0 != null ? depth0.location : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"location","hash":{},"data":data}) : helper)))
    + "\">\n                  "
    + alias4(((helper = (helper = helpers.location || (depth0 != null ? depth0.location : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"location","hash":{},"data":data}) : helper)))
    + "\n                </div>\n                <div class=\"icon-content hide jif-blue text-center icon-box\">\n                  <i class=\"jif-location\"></i>\n                  <div class=\"font-8\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"location",{"name":"t","hash":{},"data":data}))
    + "</div>\n                </div>\n              </div>\n            </div>\n            <div class=\"card-detail count hidden-xs hidden-sm\">\n              <div class=\"item-section attedee-counts\">\n                <div class=\"section-count accepted\">\n                  <div class=\"count\">"
    + alias4(((helper = (helper = helpers.acceptedCount || (depth0 != null ? depth0.acceptedCount : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"acceptedCount","hash":{},"data":data}) : helper)))
    + "</div>\n                  <div class=\"status\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"accepted",{"name":"t","hash":{},"data":data}))
    + "</div>\n                </div>\n                <div class=\"section-count declined\">\n                  <div class=\"count\">"
    + alias4(((helper = (helper = helpers.declinedCount || (depth0 != null ? depth0.declinedCount : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"declinedCount","hash":{},"data":data}) : helper)))
    + "</div>\n                  <div class=\"status\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"declined",{"name":"t","hash":{},"data":data}))
    + "</div>\n                </div>\n                <div class=\"section-count pending\">\n                  <div class=\"count\">"
    + alias4(((helper = (helper = helpers.pendingCount || (depth0 != null ? depth0.pendingCount : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"pendingCount","hash":{},"data":data}) : helper)))
    + "</div>\n                  <div class=\"status\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"pending",{"name":"t","hash":{},"data":data}))
    + "</div>\n                </div>\n              </div>\n            </div>\n          </div>\n        </div>\n        <div class=\"card-footer\">\n           <div class=\"card-footer-content\">\n            <div class=\"toggle-switch\">\n              <input type=\"checkbox\" "
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.checkedIn : depth0),{"name":"if","hash":{},"fn":container.program(6, data, 0, blockParams, depths),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + " class=\"checkin_meeting\" id=\"checkin_meeting_"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\" />\n              <label for=\"checkin_meeting_"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\"></label>\n            </div>\n            <div>"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"checkin",{"name":"t","hash":{},"data":data}))
    + "</div>\n           </div>\n        </div>\n        <div class=\"card-list-content\">\n          <div class=\"checkin-attedndee-list\">\n            <div class=\"row\">\n              <div class=\"col-md-6 col-sm-6\">\n                <div class=\"internal-attendee\">\n                  <div class=\"list-title\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"internal_participants",{"name":"t","hash":{},"data":data}))
    + "</div>\n                  <div>\n"
    + ((stack1 = helpers.each.call(alias1,((stack1 = (depth0 != null ? depth0.users : depth0)) != null ? stack1.internal : stack1),{"name":"each","hash":{},"fn":container.program(8, data, 0, blockParams, depths),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "                  </div>\n                </div>\n              </div>\n              <div class=\"col-md-6 col-sm-6\">\n                <div class=\"external-attendee\">\n                  <div class=\"list-title\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"external_participants",{"name":"t","hash":{},"data":data}))
    + "</div>\n                  <div>\n"
    + ((stack1 = helpers.each.call(alias1,((stack1 = (depth0 != null ? depth0.users : depth0)) != null ? stack1.external : stack1),{"name":"each","hash":{},"fn":container.program(10, data, 0, blockParams, depths),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "                  </div>\n                </div>\n              </div>\n            </div>\n          </div>\n        </div>\n      </div>\n";
},"2":function(container,depth0,helpers,partials,data) {
    var helper;

  return "              <div class=\"font-lg\">"
    + container.escapeExpression(((helper = (helper = helpers.meeting_with || (depth0 != null ? depth0.meeting_with : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : (container.nullContext || {}),{"name":"meeting_with","hash":{},"data":data}) : helper)))
    + "</div>\n";
},"4":function(container,depth0,helpers,partials,data) {
    var helper;

  return "              <div class=\"font-lg\">"
    + container.escapeExpression(((helper = (helper = helpers.topicName || (depth0 != null ? depth0.topicName : depth0)) != null ? helper : helpers.helperMissing),(typeof helper === "function" ? helper.call(depth0 != null ? depth0 : (container.nullContext || {}),{"name":"topicName","hash":{},"data":data}) : helper)))
    + "</div>\n";
},"6":function(container,depth0,helpers,partials,data) {
    return " checked ";
},"8":function(container,depth0,helpers,partials,data,blockParams,depths) {
    var stack1, helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression, alias5=container.lambda;

  return "                      <div class=\"attendee-item checkin "
    + alias4(((helper = (helper = helpers.invite_status || (depth0 != null ? depth0.invite_status : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"invite_status","hash":{},"data":data}) : helper)))
    + "\">\n                        <div class=\"attendee-pic\">\n                          <i class=\"jif-people jif-light-grey jif-18\"></i>\n                          <span class=\"icon-user-"
    + alias4(((helper = (helper = helpers.invite_status || (depth0 != null ? depth0.invite_status : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"invite_status","hash":{},"data":data}) : helper)))
    + " user-status "
    + alias4(((helper = (helper = helpers.invite_status || (depth0 != null ? depth0.invite_status : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"invite_status","hash":{},"data":data}) : helper)))
    + "\"></span>\n                        </div>\n                        <div class=\"attendee-details\">\n                          <div class=\"attendee-name\">"
    + alias4(((helper = (helper = helpers.first_name || (depth0 != null ? depth0.first_name : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"first_name","hash":{},"data":data}) : helper)))
    + " "
    + alias4(((helper = (helper = helpers.last_name || (depth0 != null ? depth0.last_name : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"last_name","hash":{},"data":data}) : helper)))
    + "</div>\n                          <div class=\"attendee-desn\">\n                            <span>"
    + alias4(((helper = (helper = helpers.title || (depth0 != null ? depth0.title : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"title","hash":{},"data":data}) : helper)))
    + ", </span>\n                            <span>"
    + alias4(((helper = (helper = helpers.company_name || (depth0 != null ? depth0.company_name : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"company_name","hash":{},"data":data}) : helper)))
    + "</span>\n                          </div>\n                        </div>\n                        <div class=\"action\">\n                          <div class=\"toggle-switch\">\n                            <input type=\"checkbox\" "
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.checkedIn : depth0),{"name":"if","hash":{},"fn":container.program(6, data, 0, blockParams, depths),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + " class=\"checkin_user\" data-attendee_type=\"internal\" data-uuid=\""
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\" id=\""
    + alias4(alias5((depths[1] != null ? depths[1].uuid : depths[1]), depth0))
    + "_"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\" />\n                            <label for=\""
    + alias4(alias5((depths[1] != null ? depths[1].uuid : depths[1]), depth0))
    + "_"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\"></label>\n                          </div>\n                        </div>\n                      </div>\n";
},"10":function(container,depth0,helpers,partials,data,blockParams,depths) {
    var stack1, helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression, alias5=container.lambda;

  return "                      <div class=\"attendee-item checkin "
    + alias4(((helper = (helper = helpers.invite_status || (depth0 != null ? depth0.invite_status : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"invite_status","hash":{},"data":data}) : helper)))
    + "\">\n                        <div class=\"attendee-pic\">\n                          <i class=\"jif-people jif-light-grey jif-18\"></i>\n                          <span class=\"icon-user-"
    + alias4(((helper = (helper = helpers.invite_status || (depth0 != null ? depth0.invite_status : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"invite_status","hash":{},"data":data}) : helper)))
    + " user-status "
    + alias4(((helper = (helper = helpers.invite_status || (depth0 != null ? depth0.invite_status : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"invite_status","hash":{},"data":data}) : helper)))
    + "\"></span>\n                        </div>\n                        <div class=\"attendee-details\">\n                          <div class=\"attendee-name\">"
    + alias4(((helper = (helper = helpers.first_name || (depth0 != null ? depth0.first_name : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"first_name","hash":{},"data":data}) : helper)))
    + " "
    + alias4(((helper = (helper = helpers.last_name || (depth0 != null ? depth0.last_name : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"last_name","hash":{},"data":data}) : helper)))
    + "</div>\n                          <div class=\"attendee-desn\">\n                            <span>"
    + alias4(((helper = (helper = helpers.title || (depth0 != null ? depth0.title : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"title","hash":{},"data":data}) : helper)))
    + ", </span>\n                            <span>"
    + alias4(((helper = (helper = helpers.company_name || (depth0 != null ? depth0.company_name : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"company_name","hash":{},"data":data}) : helper)))
    + "</span>\n                          </div>\n                        </div>\n                        <div class=\"action\">\n                          <div class=\"toggle-switch\">\n                            <input type=\"checkbox\" "
    + ((stack1 = helpers["if"].call(alias1,(depth0 != null ? depth0.checkedIn : depth0),{"name":"if","hash":{},"fn":container.program(6, data, 0, blockParams, depths),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + " data-attendee_type=\"external\" class=\"checkin_user\" data-uuid=\""
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\" id=\""
    + alias4(alias5((depths[1] != null ? depths[1].uuid : depths[1]), depth0))
    + "_"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\" />\n                            <label for=\""
    + alias4(alias5((depths[1] != null ? depths[1].uuid : depths[1]), depth0))
    + "_"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\"></label>\n                          </div>\n                        </div>\n                      </div>\n";
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data,blockParams,depths) {
    var stack1;

  return "<div class=\"card-container checkin-list meeting-list "
    + container.escapeExpression(container.lambda(((stack1 = (depth0 != null ? depth0.toggle_state : depth0)) != null ? stack1.viewStyle : stack1), depth0))
    + "\">\n"
    + ((stack1 = helpers.each.call(depth0 != null ? depth0 : (container.nullContext || {}),(depth0 != null ? depth0.meeting_list : depth0),{"name":"each","hash":{},"fn":container.program(1, data, 0, blockParams, depths),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "</div>\n";
},"useData":true,"useDepths":true});

/***/ }),

/***/ "./templates/meeting/session-list.hbs":
/*!********************************************!*\
  !*** ./templates/meeting/session-list.hbs ***!
  \********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var Handlebars = __webpack_require__(/*! ../../node_modules/handlebars/runtime.js */ "./node_modules/handlebars/runtime.js");
function __default(obj) { return obj && (obj.__esModule ? obj["default"] : obj); }
module.exports = (Handlebars["default"] || Handlebars).template({"1":function(container,depth0,helpers,partials,data) {
    var stack1, helper, alias1=depth0 != null ? depth0 : (container.nullContext || {}), alias2=helpers.helperMissing, alias3="function", alias4=container.escapeExpression, alias5=container.lambda;

  return "    <div class=\"card meeting-card "
    + alias4(((helper = (helper = helpers.status || (depth0 != null ? depth0.status : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"status","hash":{},"data":data}) : helper)))
    + "\" data-uuid='"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "' id=\""
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\">\n      <div class=\"card-header\">\n        <div class=\"card-header-content\">\n          <div class=\"card-select\">\n            <input type=\"checkbox\" name=\"meetingCard\" data-uuid='"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "' id=\"meetingCard_"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\">\n            <label for=\"meetingCard_"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "\">\n              <div>S</div>\n            </label>\n          </div>\n          <div class=\"card-click meetingRevealCls\" id=\"session_click\" data-uuid='"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "'>\n            <a href=\"javascript:void(0)\">\n              <div class=\"font-lg meeting-title\" title=\""
    + alias4(alias5(((stack1 = (depth0 != null ? depth0.topic : depth0)) != null ? stack1.name : stack1), depth0))
    + "\">"
    + alias4(alias5(((stack1 = (depth0 != null ? depth0.topic : depth0)) != null ? stack1.name : stack1), depth0))
    + "</div>\n              <div class=\"font-lg\">"
    + alias4(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias1,"ID",{"name":"t","hash":{},"data":data}))
    + " #"
    + alias4(((helper = (helper = helpers.id || (depth0 != null ? depth0.id : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"id","hash":{},"data":data}) : helper)))
    + "</div>\n            </a>\n          </div>\n        </div>\n      </div>\n      <div class=\"card-content meetingRevealCls\" data-uuid='"
    + alias4(((helper = (helper = helpers.uuid || (depth0 != null ? depth0.uuid : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"uuid","hash":{},"data":data}) : helper)))
    + "'>\n        <div class=\"card-detail-content\">\n          <div>\n            <div class=\"card-detail\">\n              <span class=\"font-semi-bold\">"
    + alias4(((helper = (helper = helpers.startTime || (depth0 != null ? depth0.startTime : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"startTime","hash":{},"data":data}) : helper)))
    + " - "
    + alias4(((helper = (helper = helpers.endTime || (depth0 != null ? depth0.endTime : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"endTime","hash":{},"data":data}) : helper)))
    + "</span>\n            <span class=\"font-sm\">"
    + alias4(((helper = (helper = helpers.sessionDate || (depth0 != null ? depth0.sessionDate : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"sessionDate","hash":{},"data":data}) : helper)))
    + "</span>\n            </div>\n            <div class=\"card-detail icon-sep\">\n              <div class=\"text-content location-text two-line-ellipsis\">\n                "
    + alias4(alias5(((stack1 = (depth0 != null ? depth0.room : depth0)) != null ? stack1.name : stack1), depth0))
    + "\n              </div>\n            </div>\n          </div>\n          <div class=\"card-detail count\">\n            <div class=\"item-section attedee-counts\">\n             <div class=\"section-count accepted\">\n               <div class=\"count\">"
    + alias4(alias5(((stack1 = (depth0 != null ? depth0.invitees_status_counts : depth0)) != null ? stack1.accepted : stack1), depth0))
    + "</div>\n               <div class=\"status\">Accepted</div>\n             </div>\n             <div class=\"section-count declined\">\n               <div class=\"count\">"
    + alias4(alias5(((stack1 = (depth0 != null ? depth0.invitees_status_counts : depth0)) != null ? stack1.declined : stack1), depth0))
    + "</div>\n               <div class=\"status\">Declined</div>\n             </div>\n             <div class=\"section-count pending\">\n               <div class=\"count\">"
    + alias4(alias5(((stack1 = (depth0 != null ? depth0.invitees_status_counts : depth0)) != null ? stack1.pending : stack1), depth0))
    + "</div>\n               <div class=\"status\">Pending</div>\n             </div>\n            </div>\n          </div>\n        </div>\n      </div>\n      <div class=\"card-footer\">\n        <div class=\"card-footer-content padding-left-10\">\n          <div>Seats Remaining: "
    + alias4(((helper = (helper = helpers.remainingCount || (depth0 != null ? depth0.remainingCount : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"remainingCount","hash":{},"data":data}) : helper)))
    + "/"
    + alias4(((helper = (helper = helpers.capacity || (depth0 != null ? depth0.capacity : depth0)) != null ? helper : alias2),(typeof helper === alias3 ? helper.call(alias1,{"name":"capacity","hash":{},"data":data}) : helper)))
    + "</div>\n        </div>\n      </div>\n    </div>\n";
},"compiler":[7,">= 4.0.0"],"main":function(container,depth0,helpers,partials,data) {
    var stack1, alias1=container.escapeExpression, alias2=depth0 != null ? depth0 : (container.nullContext || {});

  return "<div class=\"card-container meeting-list "
    + alias1(container.lambda(((stack1 = (depth0 != null ? depth0.toggle_state : depth0)) != null ? stack1.viewStyle : stack1), depth0))
    + "\">\n"
    + ((stack1 = helpers.each.call(alias2,(depth0 != null ? depth0.sessions_list : depth0),{"name":"each","hash":{},"fn":container.program(1, data, 0),"inverse":container.noop,"data":data})) != null ? stack1 : "")
    + "</div>\n\n\n<!-- Modal -->\n<div class=\"modal modal-jiffle modal-list event-list-modal blue fade\" id=\"group-nominatoin-list\" tabindex=\"-1\" role=\"dialog\" aria-labelledby=\"myModalLabel\">\n  <div class=\"modal-dialog\" role=\"document\">\n    <div class=\"modal-content\">\n      <div class=\"modal-header\">\n        <button type=\"button\" class=\"close hidden-lg hidden-md hidden-sm\" data-dismiss=\"modal\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button>\n        <h4 class=\"modal-title\" id=\"myModalLabel\" data-i18n=\"\">"
    + alias1(__default(__webpack_require__(/*! ../helpers/t.js */ "./templates/helpers/t.js")).call(alias2,"nomination_header",{"name":"t","hash":{},"data":data}))
    + "</h4>\n      </div>\n      <div class=\"modal-body\">\n        <div class=\"container-fluid no-padding event-list-content card-container list-view\">\n          <div class=\"row\">\n            <div class=\"col-md-12\">\n              <div class=\"font-red\" id=\"errorMsg\"></div>\n            </div>\n          </div>\n          <div class=\"row\" id=\"session-nominations\">\n\n          </div>\n        </div>\n      </div>\n    </div>\n  </div>\n</div>\n";
},"useData":true});

/***/ })

/******/ });
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vLy4vYXBwL3NjcmlwdHMvU2Vzc2lvbi9hY3Rpb25zLmpzIiwid2VicGFjazovLy8uL2FwcC9zY3JpcHRzL1Nlc3Npb24vYXBwLmpzIiwid2VicGFjazovLy8uL2FwcC9zY3JpcHRzL1Nlc3Npb24vY2hlY2tpbl9oYW5kbGVyLmpzIiwid2VicGFjazovLy8uL2FwcC9zY3JpcHRzL1Nlc3Npb24vaGFuZGxlci5qcyIsIndlYnBhY2s6Ly8vLi9hcHAvc2NyaXB0cy9TZXNzaW9uL3N0b3JlLmpzIiwid2VicGFjazovLy8uL2FwcC9zY3JpcHRzL2NvbW1vbnMvamlmZmxlL2FwaS5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9kaXN0L2Nqcy9oYW5kbGViYXJzLnJ1bnRpbWUuanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9iYXNlLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL2Rpc3QvY2pzL2hhbmRsZWJhcnMvZGVjb3JhdG9ycy5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9kaXN0L2Nqcy9oYW5kbGViYXJzL2RlY29yYXRvcnMvaW5saW5lLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL2Rpc3QvY2pzL2hhbmRsZWJhcnMvZXhjZXB0aW9uLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL2Rpc3QvY2pzL2hhbmRsZWJhcnMvaGVscGVycy5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9kaXN0L2Nqcy9oYW5kbGViYXJzL2hlbHBlcnMvYmxvY2staGVscGVyLW1pc3NpbmcuanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9oZWxwZXJzL2VhY2guanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9oZWxwZXJzL2hlbHBlci1taXNzaW5nLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL2Rpc3QvY2pzL2hhbmRsZWJhcnMvaGVscGVycy9pZi5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9kaXN0L2Nqcy9oYW5kbGViYXJzL2hlbHBlcnMvbG9nLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL2Rpc3QvY2pzL2hhbmRsZWJhcnMvaGVscGVycy9sb29rdXAuanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9oZWxwZXJzL3dpdGguanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9sb2dnZXIuanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9uby1jb25mbGljdC5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9kaXN0L2Nqcy9oYW5kbGViYXJzL3J1bnRpbWUuanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvZGlzdC9janMvaGFuZGxlYmFycy9zYWZlLXN0cmluZy5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvaGFuZGxlYmFycy9kaXN0L2Nqcy9oYW5kbGViYXJzL3V0aWxzLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL3J1bnRpbWUuanMiLCJ3ZWJwYWNrOi8vLyh3ZWJwYWNrKS9idWlsZGluL2dsb2JhbC5qcyIsIndlYnBhY2s6Ly8vLi90ZW1wbGF0ZXMvaGVscGVycy90LmpzIiwid2VicGFjazovLy8uL3RlbXBsYXRlcy9tZWV0aW5nL2NoZWNraW4uaGJzIiwid2VicGFjazovLy8uL3RlbXBsYXRlcy9tZWV0aW5nL3Nlc3Npb24tbGlzdC5oYnMiXSwibmFtZXMiOlsiU2Vzc2lvbkFjdGlvbnMiLCJSZWZsdXgiLCJjcmVhdGVBY3Rpb25zIiwibW9kdWxlIiwiZXhwb3J0cyIsImluaXRJMThuIiwiXyIsImFzc2lnbiIsImVuTG9jYWxlIiwiSGFuZGxlciIsInJlcXVpcmUiLCJjaGVja2luSGFuZGxlciIsIkFwaSIsIiQiLCJkb2N1bWVudCIsInJlYWR5IiwialF1ZXJ5IiwiamlmZmxlIiwic2ZkY0hhbmRsZXIiLCJtZWV0aW5nSW5pdCIsImluaXQiLCJ3aW5kb3ciLCJzZXNzaW9uQ2hlY2tpbiIsInNldHVwVWlJMThuIiwiQWN0aW9ucyIsIlN0b3JlIiwiQ2hlY2tpblN0b3JlIiwiU2Vzc2lvblN0b3JlIiwiQ2hlY2tpbkhhbmRsZXIiLCJuYXZiYXJTZWFyY2giLCJmaWx0ZXIiLCJzZXNzaW9uQ2hlY2tpbkNvbnRhaW5lciIsImRlZmF1bHRUb2dnbGVTdGF0ZSIsInZpZXdTdHlsZSIsInRpbGVTaXplIiwiY29uc2VjdXRpdmVNZWV0aW5nVGFiIiwibW9iaWxlQ29uc2VjdXRpdmVDb3VudFRhYiIsInNlc3Npb25Db3VudFRhYiIsIm1vYmlsZVNlc3Npb25Db3VudFRhYiIsImludGVybmFsQ291bnRUYWIiLCJtb2JpbGVJbnRlcm5hbENvdW50VGFiIiwiZXh0ZXJuYWxDb3VudFRhYiIsIm1vYmlsZUV4dGVybmFsQ291bnRUYWIiLCJleHBvcnRCdG4iLCJzdG9yZUhhbmRsZXJzIiwib25TZXNzaW9uQ2hlY2tpbkxpc3RTdWNjZXNzIiwic2V0dXBVSSIsInNldHVwTGlzdGVuZXJzIiwic2V0dXBTdG9yZUxpc3RlbmVycyIsImZldGNoU2Vzc2lvbkNoZWNraW5MaXN0IiwiYWN0aXZhdGVUYWJzIiwicmVtb3ZlQ2xhc3MiLCJhZGRDbGFzcyIsImxpc3RlbiIsImRhdGEiLCJjYWxsQmFja0Z1bmN0aW9uIiwiYWN0aW9uIiwiaXNGdW5jdGlvbiIsInBheWxvYWQiLCJzZXNzaW9ucyIsImRpc3BsYXlDb3VudHMiLCJ0b3RhbEludGVybmFsIiwidG90YWxFeHRlcm5hbCIsInRvdGFsQ29uc2VjTWVldGluZyIsInRvdGFsU2Vzc2lvbnMiLCJ0ZW1wbGF0ZSIsIm1hcCIsInNlc3Npb24iLCJwZW5kaW5nQ291bnQiLCJpbnZpdGVlc19zdGF0dXNfY291bnRzIiwicGVuZGluZyIsInRvdGFsSW52aXRlZUNvdW50IiwidG90YWxfaW52aXRlZXMiLCJhY2NlcHRlZENvdW50IiwiYWNjZXB0ZWQiLCJkZWNsaW5lZENvdW50IiwiZGVjbGluZWQiLCJ0b3BpY05hbWUiLCJ0b3BpYyIsIm5hbWUiLCJzdGFydFRpbWUiLCJtb21lbnQiLCJzdGFydF90aW1lIiwiZm9ybWF0IiwiZW5kVGltZSIsImVuZF90aW1lIiwibWVldGluZ0RhdGUiLCJ0b0RhdGUiLCJ0b01lZGl1bURhdGUiLCJsb2NhdGlvbiIsInJvb20iLCJjaGVja2VkSW4iLCJjaGVja2luIiwic2V0Q2hlY2tJblN0YXR1c2VzIiwidXNlcnMiLCJpbnRlcm5hbCIsImNvbmNhdCIsImV4dGVybmFsIiwiaHRtbCIsIm1lZXRpbmdfbGlzdCIsInRvZ2dsZV9zdGF0ZSIsImludGVybmFsQ291bnQiLCJleHRlcm5hbENvdW50IiwiY29uc2VjQ291bnQiLCJzZXNzaW9uQ291bnQiLCJpbnRlcm5hbFRhYlRleHQiLCJpMThuIiwidCIsImNvdW50IiwiZXh0ZXJuYWxUYWJUZXh0IiwiZXh0ZXJuYWxNb2JpbGVUYWJUZXh0Iiwic2Vzc2lvblRhYnRleHQiLCJjb25zZWN1dGl2ZVRhYlRleHQiLCJkaXNwbGF5Q291bnRJblRhYiIsInRhYiIsIm1vYmlsZVRhYiIsInRleHRMYWJlbCIsIm1vYmlsZVRleHRMYWJlbCIsImZpbmQiLCJ0ZXh0Iiwic2libGluZ3MiLCJhdHRlbmRlZXMiLCJBcnJheSIsImF0dGVuZGVlIiwib24iLCJoYW5kbGVUb2dnbGVWaWV3IiwiaW5maW5pdGVTY3JvbGwiLCJvZmZzZXQiLCJjYWxsYmFjayIsImZldGNoTW9yZVNlc3Npb25zQ2hlY2tpbiIsImhhbmRsZVNlc3Npb25DaGVja2luIiwiaGFuZGxlQXR0ZW5kZWVDaGVja2luIiwiaGFuZGxlSW50ZXJuYWxUYWJDbGljayIsImhhbmRsZUV4dGVybmFsVGFiQ2xpY2siLCJoYW5kbGVDb25zZWN1dGl2ZVRhYkNsaWNrIiwiZXhwb3J0U2Vzc2lvbnMiLCJldmVudCIsInByZXZlbnREZWZhdWx0Iiwic3RvcFByb3BhZ2F0aW9uIiwiY29tbW9ucyIsInJlZGlyZWN0UGFnZSIsImdlbmVyYXRlRXhwb3J0VXJsIiwiZW52RGV0YWlscyIsInVybFByZWZpeCIsIkVORFBPSU5UUyIsImNvbnNlY3V0aXZlX2xpc3RfcGFnZSIsImV4dGVybmFsX3JlcXVlc3RzIiwic2Vzc2lvblV1aWQiLCJjbG9zZXN0Iiwic3RhdHVzIiwiaXMiLCJjaGVja2luU2Vzc2lvbiIsImF0dGVuZGVlVXVpZCIsImF0dGVuZGVlVHlwZSIsInByb3AiLCJjaGVja2luQXR0ZW5kZWUiLCJnZXRDdXJyZW50UGFnZSIsImdldFRvdGFsUGFnZXMiLCJlbGVtIiwidHlwZSIsInJlZGlyZWN0VXJsIiwic2Vzc2lvbl9saXN0Iiwic2V0SXRlbSIsIlNlc3Npb25IYW5kbGVyIiwic2Vzc2lvbkxpc3RDb250YWluZXIiLCJpbnRlcm5hbFNlbGVjdEFsbCIsImN1cnJlbnRWaWV3U3R5bGUiLCJub3RpZmljYXRpb25Nb2RhbCIsIml0ZW1TaXplIiwic2Vzc2lvbmxpc3RpbmciLCJoYW5kZWxTZXNzaW9uTGlzdCIsInNlc3Npb25Ob21pbmF0aW9ucyIsImhhbmRsZVNlc3Npb25Ob21pbmF0aW9ucyIsImhpZGUiLCJnZXROb21pbmF0aW9ucyIsInNldFVwTGlzdGVuZXJzIiwiZnVuYyIsImZldGNoU2Vzc2lvbnMiLCJzZXRWaWV3IiwiZ2V0SXRlbSIsImF0dGFjaENvbW1vblVJTGlzdGVuZXJlcyIsImhhbmRlbFZpZXdUb2dnbGUiLCJoYW5kbGVTZXNzaW9uVGFiQ2xpY2siLCJmZXRjaE1vcmVTZXNzaW9ucyIsImUiLCJmZXRjaFNlc3Npb25Ob21pbmF0aW9ucyIsInNlc3Npb25fdXVpZCIsImhpZGVOb21pbmF0aW9uc0xpc3QiLCJtb2RhbCIsInNob3dOb21pbmF0aW9uc0xpc3QiLCJhcGlSZXNwb25zZSIsIm5vbWluYXRpb25MYWJlbCIsImNvbW1vblN0b3JlIiwiZ2V0Q3VzdG9tTGFiZWxzIiwibm9taW5hdGlvbnMiLCJyZWRpcmVjdGlvblBhdGgiLCJsZW5ndGgiLCJzaG93X21lc3NhZ2UiLCJ0aXRsZSIsImJvZHkiLCJtZXNzYWdlIiwiY2xhc3MiLCJzZXNzaW9uUGFyYW1zIiwic2Vzc2lvbk9iaiIsImdldFNlc3Npb25PYmoiLCJpc0VtcHR5IiwidXVpZCIsInRyYWNrIiwibWVldGluZ19yZXF1ZXN0X3BhdGgiLCJwYXJhbSIsImFjdGl2aXR5X3V1aWQiLCJlZGl0YWJsZV9ub21pbmF0aW9uIiwiZWFjaCIsImkiLCJ2YWx1ZSIsImNhbl9lZGl0Iiwib3JpZ2luIiwiam5fYm9va19ub21pbmF0aW9uIiwic2VhcmNoIiwibW9kZVEiLCJncm91cF9ub21pbmF0aW9uX2VkaXQiLCJyZXBsYWNlIiwiam5fdmlld19ub21pbmF0aW9uIiwiZ3JvdXBfbm9taW5hdGlvbl92aWV3IiwiZGlzcGxheU1lZXRpbmdzIiwidXBkYXRlTWVldGluZ0NvdW50IiwidG90YWwiLCJ0b3RhbENvbnNlYyIsIkVsIiwiaXNDaGVja0luQ2xpY2siLCJjaGVja2luVXJsIiwiY2hlY2tpbl9zZXNzaW9uc19saXN0IiwibGlzdEhvbGRlciIsImNsb25lRGVlcCIsInJlbWFpbmluZ0NvdW50IiwiY2FwYWNpdHkiLCJub3RfZGVjbGluZWRfdXNlcl9jb3VudCIsInNlc3Npb25EYXRlIiwic2Vzc2lvbnNfbGlzdCIsIm5ld1BhZ2UiLCJhcGV4X2pubWVldGluZ3MiLCJhcGV4X2puc2Vzc2lvbnMiLCJnZXRUb3RhbFBhZ2VDb3VudCIsImNyZWF0ZVN0b3JlIiwibGlzdGVuVG9NYW55IiwiZmV0Y2hpbmciLCJwZXJfcGFnZV9zZXNzaW9uX2NvdW50IiwiY3VycmVudF9wYWdlIiwidG90YWxfcGFnZXMiLCJwcmVmaXgiLCJzZXNzaW9uX2V4cG9ydCIsImpvaW4iLCJvbkZldGNoU2Vzc2lvbnMiLCJwYWdlX25vIiwicGVyX3BhZ2UiLCJnZXRGZXRjaFN0YXRlIiwidXBkYXRlRmV0Y2hTdGF0ZSIsInByb21pc2UiLCJmZXRjaCIsInVybCIsInBhZ2UiLCJ0aGVuIiwic2V0Q3VycmVudFBhZ2UiLCJzZXRUb3RhbFBhZ2VDb3VudCIsIk1hdGgiLCJjZWlsIiwidG90YWxfZW50cmllcyIsIml0ZW1zIiwidHJpZ2dlciIsImV4dGVybmFsX3JlcXVlc3RzX2NvdW50IiwiaW50ZXJuYWxfbWVldGluZ3NfY291bnQiLCJjb25zZWN1dGl2ZV9tZWV0aW5nc19jb3VudCIsImJpbmQiLCJmYWlsIiwic3RhdGUiLCJvbkZldGNoU2Vzc2lvbk5vbWluYXRpb25zIiwicGFyYW1zIiwiZXh0ZW5kIiwibm9taW5hdGlvbkluZm8iLCJyZXF1ZXN0Iiwic2Vzc2lvbl9ub21pbmF0aW9ucyIsInJlc3BvbnNlIiwicmVzcG9uc2VKU09OIiwicGVyUGFnZSIsInRvdGFsUGFnZXMiLCJjdXJyZW50UGFnZSIsImlzRmV0Y2hpbmciLCJvbkZldGNoU2Vzc2lvbkNoZWNraW5MaXN0IiwicGFnZU5vIiwiZmV0Y2hTdGF0ZSIsInNldEZldGNoU3RhdGUiLCJzZXNzaW9uX2NoZWNraW5fbGlzdCIsImRvbmUiLCJzZXREYXRhIiwic2V0VG90YWxQYWdlcyIsImdldERhdGEiLCJpbnRlcm5hbF9yZXF1ZXN0X2NvdW50Iiwic2Vzc2lvbnNfY291bnQiLCJvbkNoZWNraW5TZXNzaW9uIiwidXBkYXRlIiwidXBkYXRlX2NoZWNraW5fc3RhdHVzIiwidXNlcl91dWlkIiwib2JqZWN0X3R5cGUiLCJtZWV0aW5nX3V1aWQiLCJvbkNoZWNraW5BdHRlbmRlZSIsInRvdGFsRW50cmllcyIsImZsb29yIiwiYWNjZXB0X21lZXRpbmciLCJhY3RpdmF0ZV9ldmVudCIsImFjdGl2YXRlX3Jvb20iLCJhY3RpdmF0ZV91c2VyIiwiYWN0aXZpdHlfZGV0YWlscyIsImFkYXB0ZXJzIiwiYWRkX2F0dGVuZGVlX3RvX21lZXRpbmciLCJhZGRfbmV3X2xvY2F0aW9uIiwiYWRkX3N1cHBvcnRlZF9hcGkiLCJhbGVydF9kZXRhaWxzX2ZldGNoIiwiYWxlcnRfZmV0Y2giLCJhbGxfbWVldGluZ190eXBlcyIsImFwZXhfam5saXN0YWdlbmRhIiwiYXBpX21hcF9vcl9hZGRfdXNlciIsImVycm9yQ29uZmlnIiwiaGFuZGxlciIsImFwaV9yZWdpc3Rlcl91c2VyIiwiYXBpX3VwZGF0ZV91c2VyX2V2ZW50X3NldHRpbmdzIiwiY3VzdG9tX3RpdGxlIiwiYXBpX3VwZGF0ZV91c2VyIiwiYXBwb2ludG1lbnRfZmlsdGVyX29wdGlvbnMiLCJhcHByb3ZlX2V4dGVybmFsX3JlcXVlc3QiLCJhcHByb3ZlX21lZXRpbmciLCJhcHByb3ZlZF9tZWV0aW5nX2NvdW50IiwiYXV0b19yZW1pbmRlcl9zZXR0aW5nIiwiYXZhaWxhYmlsaXR5X2ZldGNoX2ViYyIsImF2YWlsYWJpbGl0eV9mZXRjaCIsImF2YWlsYWJpbGl0eV91cGRhdGUiLCJibG9ja191cGRhdGUiLCJicmllZmluZ19jZW50cmVfbG9uZ19kYXkiLCJicmllZmluZ19jZW50cmUiLCJicmllZmluZ19jdXN0b21fZm9ybXMiLCJicmllZmluZ19kZXRhaWxzIiwiYnVsa19hcHByb3ZlX21hcHBpbmdzIiwiYnVsa19hcHByb3ZlX21lZXRpbmdzIiwiYnVsa19jYW5jZWxfbWFwcGluZ3MiLCJidWxrX2NhbmNlbF9tZWV0aW5ncyIsImJ1bGtfZW5kb3JzZV91c2VycyIsImJ1bGtfcmVpbnZpdGVfdXNlcnMiLCJidWxrX3NldF9tbV9vbmx5X2ZsYWciLCJidWxrX3N5bmNfZXh0X2NhbF9mbGFnIiwiYnVsa19yZWxheF9zZmRjX29ubHlfcmVxdWVzdF9tZWV0aW5nIiwiYnVsa19zaG93X2FzX2V4dGVybmFsX2F0dGVuZGVlIiwiY2FsZW5kYXJfYXZhaWxhYmlsaXR5IiwiY2FsZW5kYXJfdXNlcl9hdmFpbGFiaWxpdHkiLCJjYW5fYXR0ZW5kX3Nlc3Npb24iLCJjYW5jZWxfZXh0ZXJuYWxfcmVxdWVzdCIsImNhbmNlbF9tZWV0aW5nIiwiY2hlY2tfYXR0ZW5kZWVfYXZhaWxhYmlsaXR5IiwiY2hlY2tpbl9jb25zZWN1dGl2ZV9tZWV0aW5nc19saXN0IiwiY2hlY2tpbl9saXN0X2ZpbHRlcnMiLCJjaGVja2luX21lZXRpbmdzX2xpc3QiLCJjaGVja2luX21lZXRpbmdzIiwiY2hlY2tpbl91c2VycyIsImNpc19zZXJ2aWNlIiwiY29tcGFuaWVzX2xpc3QiLCJjb21wYW55X2ZldGNoIiwiY29uY2llcmdlX3NlcnZpY2VzX2NyZWF0ZSIsImNvbmNpZXJnZV9zZXJ2aWNlc191cGRhdGUiLCJjb25maWdfYXV0b19yZW1pbmQiLCJjb25maWdfaGlzdG9yeSIsImNvbmZpZ19pbnRlZ3JhdGlvbl91cGRhdGUiLCJjb25maWdfaW50ZWdyYXRpb24iLCJjb25maWdfbm90aWZpY2F0aW9uX3VwZGF0ZSIsImNvbmZpZ19ub3RpZmljYXRpb24iLCJjb25maWdfdG9waWNfdXBkYXRlIiwiY29uZmlnX3RvcGljIiwiY29uc2VjdXRpdmVfbWVldGluZ19saXN0IiwiY29uc2VjdXRpdmVfbWVldGluZ3NfZGV0YWlscyIsImNvbnNlY3V0aXZlX21lZXRpbmdzX2VkaXRfcGF0aCIsImNvbnNlY3V0aXZlX21lZXRpbmdzX3ZpZXdfcGF0aCIsImNvcHlfY2FsZW5kYXJfc2V0dGluZ3MiLCJjb3B5X2Zvcm1fc2V0dGluZ3MiLCJjb3B5X21lZXRpbmdfc2V0dGluZ3MiLCJjb3B5X25vdGlmaWNhdGlvbl9zZXR0aW5ncyIsImNyZWF0ZV9jb25zZWN1dGl2ZV9tZWV0aW5ncyIsImNyZWF0ZV9leHRlcm5hbF9yZXF1ZXN0IiwiY3JlYXRlX2dyb3VwX25vbWluYXRpb24iLCJjcmVhdGVfaW50ZWdyYXRpb25fdXNlciIsImludGVncmF0aW9uX3VzZXIiLCJjcmVhdGVfbWFwcGluZyIsImNyZWF0ZV9vcl91cGRhdGVfdHJhY2siLCJjcmVhdGVfc2VsZl9ub21pbmF0aW9uIiwiY3JlYXRlX3Nlc3Npb24iLCJjcmVhdGVfdGFnX2Nsb3VkcyIsImN1c3RvbV9maWVsZF9vcHRpb25zIiwiY3VzdG9tX2Zvcm1fZGV0YWlscyIsImN1c3RvbWVyX2F2YWlsYWJpbGl0eSIsImN1c3RvbWVyX2NhbGVuZGFyX2V4cG9ydCIsImN1c3RvbV9sYWJlbHMiLCJkZWNsaW5lX21lZXRpbmciLCJkZWZhdWx0X21lZXRpbmdfbG9jYXRpb25fZW50aXRpZXMiLCJkZWxldGVfbWFwcGluZyIsImRlbGV0ZV9sb2NhdGlvbl9wcmVmZXJlbmNlIiwiZGVtYW5kX3JlcG9ydF9leHBvcnQiLCJkZW1hbmRfcmVwb3J0cyIsImRldGFpbGVkX2N1c3RvbV9sYWJlbHMiLCJkaXNhYmxlX3NhdmVkX3JlcG9ydCIsImRpc21pc3NfYWxlcnQiLCJkaXNtaXNzX25vdGlmaWNhdGlvbiIsImRvbWFpbl92YWxpZGF0aW9uIiwiZG9tYWluc192YWxpZCIsImRvdWJsZV9ib29rZWRfcmVzb3VyY2VzIiwiZG93bmxvYWRfYWdlbmRhX2l0ZW1fdGVtcGxhdGVfdXJsIiwidXNlcl90b3BpY19tYXBwaW5nX3RlbXBsYXRlX3VybCIsImVkaXRfdHJhY2siLCJlbmFibGVfZG91YmxlX2Jvb2tfdXNlcnMiLCJldmVudF9hY2Nlc3Nfc2V0dGluZ3MiLCJldmVudF9jb25maWdfZXhwb3J0IiwiZXZlbnRfY29uZmlnX2Zvcl91c2VyX2NhbGVuZGFyIiwiZXZlbnRfY29uZmlnX2ltcG9ydCIsImV2ZW50X2NvbmZpZyIsImV2ZW50X2NvbmZpZ3VyYXRpb25zIiwiZXZlbnRfZGV0YWlscyIsImV2ZW50X2ViY19jb25maWd1cmF0aW9ucyIsImV2ZW50X2hvbWUiLCJldmVudF9uZXciLCJldmVudF9yb29tX2NhbF9wYXRoIiwiZXZlbnRfdXNlcl9jYWxfcGF0aCIsImV2ZW50X3VzZXJfZmlsdGVycyIsImV2ZW50c19pbmZvIiwiZXZlbnRzIiwiZXhwZXJ0X3VzZXJzIiwiZXhwb3J0X21lZXRpbmdfY2hlY2tpbiIsImV4cG9ydF9yZXZpZXciLCJleHBvcnRfc3VtbWFyeV9yZXBvcnQiLCJleHBvcnRfc3VydmV5cyIsImV4dF9lbmFibGVkX2ZldGNoX2Zvcm1fc2V0dGluZ3MiLCJleHRlcm5hbF9hdHRlbmRlZXMiLCJleHRlcm5hbF9tZWV0aW5nc19saXN0X2ZpbHRlcnMiLCJleHRlcm5hbF9yZXF1ZXN0X2RhdGVzIiwiZXh0ZXJuYWxfcmVxdWVzdF9leHBvcnQiLCJleHRlcm5hbF93aWRnZXRfc2Vzc2lvbnMiLCJleHRlcm5hbF93aWRnZXRfc2lnbnVwX3Nlc3Npb24iLCJleHRlcm5hbF93aWRnZXRfdG9waWNzIiwiZXh0ZXJuYWxfd2lkZ2V0X3RyYWNrcyIsImZhY2lsaXRpZXNfbGlzdCIsImZlYXR1cmVfZW5hYmxlX2ViYyIsImZldGNoX2FjdGl2ZV9ldmVudHMiLCJmZXRjaF9hY3Rpdml0aWVzIiwiZmV0Y2hfYWN0aXZpdHlfbGlzdCIsImZldGNoX2FjdGl2aXR5X21hbmFnZXIiLCJmZXRjaF9hY3Rpdml0eV9zZXR0aW5ncyIsImZldGNoX2FuYWx5dGljc19jb25maWdzIiwiZmV0Y2hfYXJjaGl2ZWRfZXZlbnRfbWVldGluZ19hbmFseXRpY3MiLCJmZXRjaF9hcmNoaXZlZF9ldmVudHNfbGlzdCIsImZldGNoX2FyY2hpdmVkX3JlcG9ydHMiLCJmZXRjaF9hdmFpbGFibGVfbWVldGluZ190eXBlcyIsImZldGNoX2Jvb2tpbmdfYW5hbHl0aWNzIiwiZmV0Y2hfYnJpZWZpbmdfd29ya2Zsb3ciLCJmZXRjaF9jYWxlbmRhcl9zZXR0aW5ncyIsImZldGNoX2NoYW5nYWJsZV9tZWV0aW5nX3R5cGVzIiwiZmV0Y2hfY29uY2llcmdlX2Zvcm0iLCJmZXRjaF9jb25jaWVyZ2Vfbm90aWZpY2F0aW9uX3NldHRpbmdzIiwiZmV0Y2hfY29uY2llcmdlX3NlcnZpY2VzIiwiZmV0Y2hfY29uc2VjdXRpdmVfbWVldGluZ19mb3JtX3NldHRpbmdzIiwiZmV0Y2hfY29uc2VjdXRpdmVfbWVldGluZ19ub3RpZmljYXRpb25fc2V0dGluZ3MiLCJmZXRjaF9jdXN0b21lcl9pbmZvX3ZhbHVlcyIsImZldGNoX2N1c3RvbWVyc19hbmFseXRpY3MiLCJmZXRjaF9lYmNfZm9ybSIsImZldGNoX2V4aXN0aW5nX21lZXRpbmdzIiwiZmV0Y2hfZXh0ZXJuYWxfbWVldGluZ19yZXF1ZXN0IiwiZmV0Y2hfZXh0ZXJuYWxfdXNlcl9mb3JtX2ZpZWxkcyIsImZldGNoX2Zvcm1fc2V0dGluZ3MiLCJmZXRjaF9mb3JtIiwiZmV0Y2hfZ3VpZGVkX3RvdXJfaW50ZWdyYXRpb25fZmllbGRzIiwiZmV0Y2hfaW50ZWdyYXRpb25fYmxvY2tfZmllbGRzIiwiZmV0Y2hfaW50ZWdyYXRpb25fbWVldGluZ19maWVsZHMiLCJmZXRjaF9pbnRlZ3JhdGlvbl9zdXJ2ZXlfZmllbGRzIiwiZmV0Y2hfaW52aXRlZXNfYW5hbHl0aWNzIiwiZmV0Y2hfbG9jYXRpb25fY29uZmlncyIsImZldGNoX21hcHBlZF9tZWV0aW5nX3R5cGVfZm9yX3JvbGUiLCJmZXRjaF9tYXBwaW5nX2RldGFpbHMiLCJmZXRjaF9tYXBwaW5nX2ZpbHRlcnMiLCJmZXRjaF9tYXBwaW5nX3J1bGVfdHlwZXMiLCJmZXRjaF9tYXBwaW5ncyIsImZldGNoX21hc3Rlcl9zdXBwb3J0ZWRfYXBpcyIsImZldGNoX21lZXRpbmdfYXR0ZW5kZWUiLCJmZXRjaF9tZWV0aW5nX2NvdW50IiwiZmV0Y2hfbWVldGluZ19kYXRhX2Zvcl9yZXBvcnRzIiwiZmV0Y2hfbWVldGluZ19kZXRhaWxzIiwiZmV0Y2hfbWVldGluZ19maWx0ZXJzIiwiZmV0Y2hfbWVldGluZ19saXN0X2NvcHlfYXR0ZW5kZWUiLCJmZXRjaF9tZWV0aW5nX2xpc3RfY3VzdG9tZXJfaW5mbyIsImZldGNoX21lZXRpbmdfcmVwb3J0c19oZWFkZXIiLCJmZXRjaF9tZWV0aW5nX3JlcG9ydHMiLCJmZXRjaF9tZWV0aW5nX3R5cGVfYW5hbHl0aWNzIiwiZmV0Y2hfbWVldGluZ190eXBlX2R1cmF0aW9ucyIsImZldGNoX21lZXRpbmdfdHlwZXMiLCJmZXRjaF9tZWV0aW5nc19hbmFseXRpY3MiLCJmZXRjaF9taW5pbXVtX3RpbWVzbG90IiwiZmV0Y2hfbm9taW5hdGlvbl9kZXRhaWwiLCJmZXRjaF9ub3RpZmljYXRpb25fc2V0dGluZ3MiLCJmZXRjaF9wb3J0YWxfY3VzdG9tX2Zvcm0iLCJmZXRjaF9wcmV2aWV3X21hcHBpbmdfZGV0YWlsIiwiZmV0Y2hfcHJldmlld19tZWV0aW5nX2RldGFpbCIsImZldGNoX3JlbW90ZV9lbnRpdGllcyIsImZldGNoX3JlcXVlc3Rvcl9lbWFpbCIsImZldGNoX3JvbGVzX2FuYWx5dGljcyIsImZldGNoX3Jvb21zX2FuYWx5dGljcyIsImZldGNoX3NjYW5uZWRfdXNlcnMiLCJmZXRjaF9zY2FubmVyc19uYW1lIiwiZmV0Y2hfc3RhbmRhcmRfcmVwb3J0IiwiZmV0Y2hfc3VydmV5X3RlbXBsYXRlIiwiZmV0Y2hfc3VydmV5cyIsImZldGNoX3RhZ19jb25maWdzIiwiZmV0Y2hfdGFnX2VudGl0eSIsImZldGNoX3RvcGljcyIsImZldGNoX3RyYWNrX3RvcGljcyIsImZldGNoX3RyYWNrX2FjdGl2aXRpZXMiLCJmZXRjaF90cmFuc2ZlcmFibGVfbWVldGluZ190eXBlcyIsImZldGNoX3VubWFwcGVkX3RvcGljX2VudGl0eSIsImZldGNoX3VwZGF0ZV9icmllZmluZ19ub3RpZmljYXRpb25fc2V0dGluZ3MiLCJmZXRjaF91c2VyX2RldGFpbHMiLCJmZXRjaF91c2VyX2ZpZWxkX21hcHBpbmdzIiwiZmV0Y2hfdXNlcl9mb3JtX3J1bGVzIiwiZmV0Y2hfdXNlcl9ub3RpZmljYXRpb24iLCJmZXRjaF91c2VyX3RvcGljcyIsImZldGNoX3ZhbGlkX21hcHBpbmdfVGltZXMiLCJmZXRjaF9jb25mZXJlbmNlX2xpc3QiLCJmZXRjaF9jb25mZXJlbmNlX2xpbmsiLCJmZXRjaF9yZXNvdXJjZV9kYXRhIiwiZmV0Y2hfdXNlcl9jdXN0b21fZmllbGRfbWFwcGluZyIsImZpbGVfdXBsb2FkX3VybCIsImZpbGxfYnVsa19jb25zZW50IiwiZ2V0X2Fubm91bmNlbWVudHMiLCJnZXRfYm9vdGhfdG91cl9kZXRhaWxzIiwiZ2V0X2JyaWVmaW5nX2ZpbHRlcnMiLCJnZXRfYnJpZWZpbmdfcmVwb3J0X29wdGlvbnMiLCJnZXRfY2hlY2tpbl9vcHRpb25zIiwiZ29vZ2xlX2NpdHlfc2VhcmNoIiwiZ29vZ2xlX3RpbWVfem9uZV9zZWFyY2giLCJzZXRfdXNlcl9zZWNfdGltZV96b25lIiwiZ2V0X2ViY19yb2xlX3ByaXZpbGVnZXMiLCJnZXRfc2VsZl9zZXJ2ZV9wcml2aWxlZ2VzIiwiZ2V0X2V4dF9tZWV0aW5nX29wdGlvbnMiLCJnZXRfZXh0ZXJuYWxfcmVxX2RldGFpbHMiLCJnZXRfZXh0ZXJuYWxfcmVxdWVzdCIsImdldF9tZWV0aW5nX29wdGlvbnMiLCJnZXRfbW1fbGlzdCIsImdldF9vbmRlbWFuZF91c2Vyc19saXN0IiwiZ2V0X3JlcG9ydF9vcHRpb25zIiwiZ2V0X3Jldmlld3MiLCJnZXRfc3dhcHBhYmxlX3Jvb21fbGlzdCIsImdldF90YWdfY2xvdWRzIiwiZ2V0X3RvcGljcyIsImdldF91c2VyX3ByZWZlcmVuY2VzIiwiaW5hY3RpdmF0ZV9yb29tcyIsImluYWN0aXZhdGVfdXNlcnMiLCJpbnRlZ3JhdGlvbl9jb25maWd1cmF0aW9uc19kZXRhaWxzIiwiaW50ZWdyYXRpb25fY29uZmlndXJhdGlvbnNfc2NoZW1hIiwiaW50ZWdyYXRpb25fZXh0ZXJuYWxfdXNlcl9pbmZvIiwiaW50ZWdyYXRpb25fZmllbGRfbWFwcGluZ3MiLCJpbnRlZ3JhdGlvbiIsImludGVybmFsX2F0dGVuZGVlcyIsImpuX2Jvb2tfbWVldGluZyIsImpuX3ZpZXdfYm9va19tZWV0aW5nIiwibGlzdF9icmllZmluZ3NfYWdlbmRhIiwibGlzdF90cmFja3MiLCJtYWlsX3RlbXBsYXRlX3R5cGVfZW50aXRpZXNfZ2V0IiwibWFpbF90ZW1wbGF0ZV90eXBlX2dldCIsIm1hbmFnZV9leHRlcm5hbF91c2VycyIsIm1hbmFnZV91c2VycyIsIm1hbnVhbF9yZW1pbmRlcl91c2VyIiwibWFwcGFibGVfZ3JvdXBpbmdfdXNlcnMiLCJtYXBwYWJsZV9yZXF1ZXN0b3JzIiwibWFwcGFibGVfdXNlcnMiLCJtYXBwZWRfZXZlbnRzIiwibWFwcGluZ19saXN0IiwibWFwcGluZ19wYWdlIiwibWFwcGluZ192YWxpZF9kdXJhdGlvbnMiLCJtYXBwaW5nc19leHBvcnQiLCJtZWV0aW5nX2F2YWlsYWJpbGl0eSIsIm1lZXRpbmdfY3JlYXRlIiwibWVldGluZ19kcmFnIiwibWVldGluZ19mZXRjaCIsIm1lZXRpbmdfZ2V0X2NvbmZpZyIsIm1lZXRpbmdfZ2V0X3NldHRpbmdzIiwibWVldGluZ19oaXN0b3J5IiwibWVldGluZ19ob3N0X2NvdW50IiwibWVldGluZ19ub3RpZmljYXRpb25zIiwibWVldGluZ19yZXF1ZXN0X2VkaXRfcGF0aCIsIm1lZXRpbmdfcmVxdWVzdF9leHBvcnQiLCJtZWV0aW5nX3JlcXVlc3Rfdmlld19wYXRoIiwibWVldGluZ19zZXRfY29uZmlnIiwibWVldGluZ19zZXRfc2V0dGluZyIsIm1lZXRpbmdfdHlwZV9jcmVhdGUiLCJtZWV0aW5nX3R5cGVfdXBkYXRlIiwibWVldGluZ190eXBlc19vZl9jb25zZWN1dGl2ZV9zdWJfbWVldGluZ3MiLCJtZWV0aW5nX3R5cGVzIiwibWVldGluZ3NfbGlzdF9maWx0ZXJzIiwibWVldGluZ3NfbGlzdCIsIm1pc2NlbGxhbmVvdXNfcmVwb3J0X2V4cG9ydCIsIm5vbl9ldmVudF9jb25maWd1cmF0aW9ucyIsIm5vdGlmaWNhdGlvbl9mZXRjaCIsIm9uX2JlaGFsZl9hY3Rpb25zIiwicG9ydGFsIiwicHJpbnRfdXNlcl9iYWRnZSIsInJlZ2lzdGVyX3VzZXIiLCJyZWludml0ZV9hdHRlbmRlZV90b19tZWV0aW5nIiwicmVpbnZpdGVfdXNlcnMiLCJyZWplY3RfZXh0ZXJuYWxfcmVxdWVzdCIsInJlamVjdF9sb2NhdGlvbl9wcmVmZXJlbmNlIiwicmVtaW5kZXJfbm90aWZfc2V0dGluZ3MiLCJyZW1vdmVfZnJvbV9ldmVudCIsInJlbW92ZV91cGxvYWRlZF9maWxlX3VybCIsInJlbW92ZV91c2VyX2Zyb21fZXZlbnQiLCJyZW9yZGVyX21lZXRpbmdfdHlwZXMiLCJyZXBvcnRzIiwidW5pZmllZF9yZXBvcnRfZmlsdGVycyIsInVzZXJfbGlzdCIsInVuaWZpZWRfcmVwb3J0IiwiZmV0Y2hfcmVwb3J0X3RlbXBsYXRlIiwidXBsb2FkX3JlcG9ydF90ZW1wbGF0ZSIsInVwZGF0ZV9yZXBvcnRfdGVtcGxhdGUiLCJyZXBvcnRfc3VydmV5X2FjdGl2aXR5X2xpc3QiLCJyZXNjaGVkdWxlX21lZXRpbmciLCJwYXJ0aWFsX21lZXRpbmdfdXBkYXRlIiwicmV2aWV3ZXJfbWVldGluZ19maWx0ZXJfb3B0aW9ucyIsInJldmlld2VyX21lZXRpbmdfZmlsdGVycyIsInJldmlld2VyX21lZXRpbmdzIiwicm9sZV9jcmVhdGUiLCJyb2xlX2Rpc2FibGUiLCJyb2xlX2VuYWJsZSIsInJvbGVfZ2V0X2FsbF9wcml2aWxlZ2VzIiwicm9sZV9nZXRfcHJpdmlsZWdlcyIsInJvbGVfc2V0X3ByaXZpbGVnZXMiLCJyb2xlX3VwZGF0ZSIsInJvbGVzX2ZldGNoIiwicm9vbV9hY3Rpdml0aWVzIiwicm9vbV9hdmFpbGFiaWxpdHkiLCJyb29tX2NhbGVuZGFyX2V4cG9ydCIsInJvb21fY3JlYXRlIiwicm9vbV9maWx0ZXJzIiwicm9vbV9tYWtlX2F2YWlsYWJsZSIsInJvb21fbWFrZV91bmF2YWlsYWJsZSIsInJvb21fdW5ibG9jayIsInJvb21fdXBkYXRlIiwicm9vbXNfZXhwb3J0Iiwicm9vbXNfbGlzdCIsInNhdmVfZm9ybSIsInNhdmVfcG9ydGFsX2N1c3RvbV9mb3JtIiwic2F2ZV9wcmludGVyX25hbWUiLCJzYXZlX3Byb2ZpbGVfcHJlZmVyZW5jZXMiLCJzYXZlX3VzZXJfZmllbGRfbWFwcGluZ3MiLCJzYXZlZF9yZXBvcnRfZGV0YWlscyIsInNlbmRfYnVsa19zdXJ2ZXlfbWVldGluZ19tYWlsIiwic2VuZF9yZXF1ZXN0b3JfZW1haWwiLCJzZW5kX3N1cnZleV9tZWV0aW5nX21haWwiLCJzZXRfYW5ub3VuY2VtZW50cyIsInNldF9wYXJ0aWNpcGF0aW9uX21hc2NhbCIsInNldF9wYXJ0aWNpcGF0aW9uIiwic2V0X3JlbWluZGVyIiwic2V0X3VzZXJfY2lzX3N0YXR1cyIsInNldF91c2VyX3ByZWZlcmVuY2VzIiwic2ZkY19jdXN0b21fbGFiZWxzIiwic2hvd19pbl9tZWV0aW5nX2V4dGVybmFsX2F0dGVuZGVlIiwic2luZ2xlX21hc3Rlcl9jYWxlbmRhcl9lbnRpdHlfc2VhcmNoIiwic3RhbmRhcmRfcmVwb3J0X2V4cG9ydF91cmwiLCJzdGFuZGFyZF9yZXBvcnRfZ2VuZXJhdGVfdXJsIiwic3VydmV5X2NyZWF0ZSIsInN1cnZleV9yZXNwb25zZXMiLCJzdXJ2ZXlfdXBkYXRlIiwic3dhcF9yb29tX3N1Ym1pdCIsInN5c3RlbV9jb25maWd1cmF0aW9ucyIsInN0YW5kYXJkX3JlcG9ydF9leHBvcnRfYnlfbWVldGluZyIsInRpbWVfem9uZV91cmwiLCJ0aW1lbGluZV9kYXRhIiwidGFnX2NyZWF0ZV9vcl91cGRhdGUiLCJ0YWdfZWRpdCIsInRhZ19saXN0IiwidGFnX2xpc3RpbmdfcGFnZSIsInRlbXBsYXRlX3VwbG9hZF91cmwiLCJBUElfY2FjaGUiLCJzdW1tdXJ5RXJyb3JIYW5kbGVyIiwiZXJyb3JDb25maWdzIiwiZXJyb3JKc29uIiwibW9kZWxFbCIsImN1c3RvbV9tZXNzYWdlIiwiZGV0YWlsZWRFcnJvckhhbmRsZXIiLCJlcnJvck1zZyIsImZsYXR0ZW4iLCJ2YWx1ZXMiLCJlcnJvcnMiLCJkZXRhaWxzIiwiZXJyIiwicmVwbGFjZVVybFBhcmFtcyIsInVybEVuZHBvaW50IiwiYXJndW1lbnRzIiwib3B0aW9ucyIsImNvbnN0cnVjdG9yIiwiRm9ybURhdGEiLCJhcHBlbmQiLCJjdXJyZW50X2xvY2F0aW9uX3V1aWQiLCJtZXJnZSIsImVycm9ySGFuZGxlckNvbmZpZ3MiLCJlcnJvckhhbmRsZXJGbiIsImRhdGFUeXBlIiwibWV0aG9kIiwicmVxX3N0cmluZ2lmeSIsIkpTT04iLCJzdHJpbmdpZnkiLCJ0ZXN0Iiwic2VjdGlvbkxvYWRlciIsInNldFBhZ2VMb2FkZXIiLCJhamF4IiwiYWJvcnRTZXF1ZW50aWFsQ2FsbHMiLCJhZGRSZW1vdmVDYWNoZSIsIlVpQWN0aW9uc09uVXBkYXRlIiwidHJpbVNlYXJjaCIsInRyaW1TcGFjZXNGb3JTZWFyY2giLCJhYm9ydCIsImJ0bnNUb0Rpc2FibGUiLCJzdGFydFBhZ2VMb2FkZXIiLCJ0b2dnbGVTZWN0aW9uTG9hZGVyIiwiZGlzYWJsZVdoaWxlRmV0Y2hpbmdEYXRhIiwidG9nZ2xlQ2xhc3MiLCJzaG91bGREaXNhYmxlIiwiZWxtcyIsImF0dHIiLCJpMThuX2tleSIsImxhYmVsIiwicmVzdWx0IiwiSGFuZGxlYmFycyIsIlNhZmVTdHJpbmciXSwibWFwcGluZ3MiOiI7QUFBQTtBQUNBOztBQUVBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7O0FBRUE7QUFDQTs7QUFFQTtBQUNBOztBQUVBO0FBQ0E7QUFDQTs7O0FBR0E7QUFDQTs7QUFFQTtBQUNBOztBQUVBO0FBQ0E7QUFDQTtBQUNBLGtEQUEwQyxnQ0FBZ0M7QUFDMUU7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7QUFDQSxnRUFBd0Qsa0JBQWtCO0FBQzFFO0FBQ0EseURBQWlELGNBQWM7QUFDL0Q7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBLGlEQUF5QyxpQ0FBaUM7QUFDMUUsd0hBQWdILG1CQUFtQixFQUFFO0FBQ3JJO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0EsbUNBQTJCLDBCQUEwQixFQUFFO0FBQ3ZELHlDQUFpQyxlQUFlO0FBQ2hEO0FBQ0E7QUFDQTs7QUFFQTtBQUNBLDhEQUFzRCwrREFBK0Q7O0FBRXJIO0FBQ0E7OztBQUdBO0FBQ0E7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QyxhQUFhO0FBQ3hPO0FBQ0EsOEtBQThLLDJCQUEyQixhQUFhO0FBQ3ROO0FBQ0EsQ0FBQztBQUNELGdIQUFnSDs7QUFFaEg7QUFDQTtBQUNBO0FBQ0EsNEZBQTRGLHVCQUF1Qix5RUFBeUU7QUFDNUwsZ2VBQWdlO0FBQ2hlLHVCQUF1QixtQkFBTyxDQUFDLGlEQUFpQixvQ0FBb0Msb0JBQW9CLGFBQWE7QUFDckg7QUFDQSxDQUFDLGdCQUFnQixFIiwiZmlsZSI6IlNlc3Npb24uYXBwLmpzIiwic291cmNlc0NvbnRlbnQiOlsiIFx0Ly8gVGhlIG1vZHVsZSBjYWNoZVxuIFx0dmFyIGluc3RhbGxlZE1vZHVsZXMgPSB7fTtcblxuIFx0Ly8gVGhlIHJlcXVpcmUgZnVuY3Rpb25cbiBcdGZ1bmN0aW9uIF9fd2VicGFja19yZXF1aXJlX18obW9kdWxlSWQpIHtcblxuIFx0XHQvLyBDaGVjayBpZiBtb2R1bGUgaXMgaW4gY2FjaGVcbiBcdFx0aWYoaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0pIHtcbiBcdFx0XHRyZXR1cm4gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0uZXhwb3J0cztcbiBcdFx0fVxuIFx0XHQvLyBDcmVhdGUgYSBuZXcgbW9kdWxlIChhbmQgcHV0IGl0IGludG8gdGhlIGNhY2hlKVxuIFx0XHR2YXIgbW9kdWxlID0gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0gPSB7XG4gXHRcdFx0aTogbW9kdWxlSWQsXG4gXHRcdFx0bDogZmFsc2UsXG4gXHRcdFx0ZXhwb3J0czoge31cbiBcdFx0fTtcblxuIFx0XHQvLyBFeGVjdXRlIHRoZSBtb2R1bGUgZnVuY3Rpb25cbiBcdFx0bW9kdWxlc1ttb2R1bGVJZF0uY2FsbChtb2R1bGUuZXhwb3J0cywgbW9kdWxlLCBtb2R1bGUuZXhwb3J0cywgX193ZWJwYWNrX3JlcXVpcmVfXyk7XG5cbiBcdFx0Ly8gRmxhZyB0aGUgbW9kdWxlIGFzIGxvYWRlZFxuIFx0XHRtb2R1bGUubCA9IHRydWU7XG5cbiBcdFx0Ly8gUmV0dXJuIHRoZSBleHBvcnRzIG9mIHRoZSBtb2R1bGVcbiBcdFx0cmV0dXJuIG1vZHVsZS5leHBvcnRzO1xuIFx0fVxuXG5cbiBcdC8vIGV4cG9zZSB0aGUgbW9kdWxlcyBvYmplY3QgKF9fd2VicGFja19tb2R1bGVzX18pXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm0gPSBtb2R1bGVzO1xuXG4gXHQvLyBleHBvc2UgdGhlIG1vZHVsZSBjYWNoZVxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5jID0gaW5zdGFsbGVkTW9kdWxlcztcblxuIFx0Ly8gZGVmaW5lIGdldHRlciBmdW5jdGlvbiBmb3IgaGFybW9ueSBleHBvcnRzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLmQgPSBmdW5jdGlvbihleHBvcnRzLCBuYW1lLCBnZXR0ZXIpIHtcbiBcdFx0aWYoIV9fd2VicGFja19yZXF1aXJlX18ubyhleHBvcnRzLCBuYW1lKSkge1xuIFx0XHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCBuYW1lLCB7IGVudW1lcmFibGU6IHRydWUsIGdldDogZ2V0dGVyIH0pO1xuIFx0XHR9XG4gXHR9O1xuXG4gXHQvLyBkZWZpbmUgX19lc01vZHVsZSBvbiBleHBvcnRzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLnIgPSBmdW5jdGlvbihleHBvcnRzKSB7XG4gXHRcdGlmKHR5cGVvZiBTeW1ib2wgIT09ICd1bmRlZmluZWQnICYmIFN5bWJvbC50b1N0cmluZ1RhZykge1xuIFx0XHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCBTeW1ib2wudG9TdHJpbmdUYWcsIHsgdmFsdWU6ICdNb2R1bGUnIH0pO1xuIFx0XHR9XG4gXHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCAnX19lc01vZHVsZScsIHsgdmFsdWU6IHRydWUgfSk7XG4gXHR9O1xuXG4gXHQvLyBjcmVhdGUgYSBmYWtlIG5hbWVzcGFjZSBvYmplY3RcbiBcdC8vIG1vZGUgJiAxOiB2YWx1ZSBpcyBhIG1vZHVsZSBpZCwgcmVxdWlyZSBpdFxuIFx0Ly8gbW9kZSAmIDI6IG1lcmdlIGFsbCBwcm9wZXJ0aWVzIG9mIHZhbHVlIGludG8gdGhlIG5zXG4gXHQvLyBtb2RlICYgNDogcmV0dXJuIHZhbHVlIHdoZW4gYWxyZWFkeSBucyBvYmplY3RcbiBcdC8vIG1vZGUgJiA4fDE6IGJlaGF2ZSBsaWtlIHJlcXVpcmVcbiBcdF9fd2VicGFja19yZXF1aXJlX18udCA9IGZ1bmN0aW9uKHZhbHVlLCBtb2RlKSB7XG4gXHRcdGlmKG1vZGUgJiAxKSB2YWx1ZSA9IF9fd2VicGFja19yZXF1aXJlX18odmFsdWUpO1xuIFx0XHRpZihtb2RlICYgOCkgcmV0dXJuIHZhbHVlO1xuIFx0XHRpZigobW9kZSAmIDQpICYmIHR5cGVvZiB2YWx1ZSA9PT0gJ29iamVjdCcgJiYgdmFsdWUgJiYgdmFsdWUuX19lc01vZHVsZSkgcmV0dXJuIHZhbHVlO1xuIFx0XHR2YXIgbnMgPSBPYmplY3QuY3JlYXRlKG51bGwpO1xuIFx0XHRfX3dlYnBhY2tfcmVxdWlyZV9fLnIobnMpO1xuIFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkobnMsICdkZWZhdWx0JywgeyBlbnVtZXJhYmxlOiB0cnVlLCB2YWx1ZTogdmFsdWUgfSk7XG4gXHRcdGlmKG1vZGUgJiAyICYmIHR5cGVvZiB2YWx1ZSAhPSAnc3RyaW5nJykgZm9yKHZhciBrZXkgaW4gdmFsdWUpIF9fd2VicGFja19yZXF1aXJlX18uZChucywga2V5LCBmdW5jdGlvbihrZXkpIHsgcmV0dXJuIHZhbHVlW2tleV07IH0uYmluZChudWxsLCBrZXkpKTtcbiBcdFx0cmV0dXJuIG5zO1xuIFx0fTtcblxuIFx0Ly8gZ2V0RGVmYXVsdEV4cG9ydCBmdW5jdGlvbiBmb3IgY29tcGF0aWJpbGl0eSB3aXRoIG5vbi1oYXJtb255IG1vZHVsZXNcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubiA9IGZ1bmN0aW9uKG1vZHVsZSkge1xuIFx0XHR2YXIgZ2V0dGVyID0gbW9kdWxlICYmIG1vZHVsZS5fX2VzTW9kdWxlID9cbiBcdFx0XHRmdW5jdGlvbiBnZXREZWZhdWx0KCkgeyByZXR1cm4gbW9kdWxlWydkZWZhdWx0J107IH0gOlxuIFx0XHRcdGZ1bmN0aW9uIGdldE1vZHVsZUV4cG9ydHMoKSB7IHJldHVybiBtb2R1bGU7IH07XG4gXHRcdF9fd2VicGFja19yZXF1aXJlX18uZChnZXR0ZXIsICdhJywgZ2V0dGVyKTtcbiBcdFx0cmV0dXJuIGdldHRlcjtcbiBcdH07XG5cbiBcdC8vIE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbFxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5vID0gZnVuY3Rpb24ob2JqZWN0LCBwcm9wZXJ0eSkgeyByZXR1cm4gT2JqZWN0LnByb3RvdHlwZS5oYXNPd25Qcm9wZXJ0eS5jYWxsKG9iamVjdCwgcHJvcGVydHkpOyB9O1xuXG4gXHQvLyBfX3dlYnBhY2tfcHVibGljX3BhdGhfX1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5wID0gXCJcIjtcblxuXG4gXHQvLyBMb2FkIGVudHJ5IG1vZHVsZSBhbmQgcmV0dXJuIGV4cG9ydHNcbiBcdHJldHVybiBfX3dlYnBhY2tfcmVxdWlyZV9fKF9fd2VicGFja19yZXF1aXJlX18ucyA9IFwiLi9hcHAvc2NyaXB0cy9TZXNzaW9uL2FwcC5qc1wiKTtcbiIsInZhciBTZXNzaW9uQWN0aW9ucyA9IFJlZmx1eC5jcmVhdGVBY3Rpb25zKFtcblx0J2ZldGNoU2Vzc2lvbnMnLFxuXHQnZmV0Y2hTZXNzaW9uTm9taW5hdGlvbnMnLFxuICAnZmV0Y2hTZXNzaW9uQ2hlY2tpbkxpc3QnLFxuICAnY2hlY2tpblNlc3Npb24nLFxuICAnY2hlY2tpbkF0dGVuZGVlJ1xuXSk7XG5tb2R1bGUuZXhwb3J0cyA9IFNlc3Npb25BY3Rpb25zOyIsImluaXRJMThuKF8uYXNzaWduKCBlbkxvY2FsZVsnbWVldGluZ3MnXSwgZW5Mb2NhbGVbJ2V4dGVybmFsX21lZXRpbmdzJ10sIGVuTG9jYWxlWydzZXNzaW9ucyddKSApO1xudmFyIEhhbmRsZXIgPSByZXF1aXJlKCcuL2hhbmRsZXInKTtcbnZhciBjaGVja2luSGFuZGxlciA9IHJlcXVpcmUoJy4vY2hlY2tpbl9oYW5kbGVyJyk7XG52YXIgQXBpID0gcmVxdWlyZSgnY29tbW9uX2FwaScpO1xuXG4kKGRvY3VtZW50KS5yZWFkeShmdW5jdGlvbihqUXVlcnkpe1xuICAgIGlmKHR5cGVvZiBqaWZmbGUgIT09ICd1bmRlZmluZWQnKSB7XG4gICAgXHRBcGkuc2ZkY0hhbmRsZXIubWVldGluZ0luaXQoZnVuY3Rpb24oKXtcbiAgICAgICAgXHRIYW5kbGVyLmluaXQoKTtcbiAgICBcdH0pO1xuICAgIH0gZWxzZSB7XG4gICAgICAgIHdpbmRvdy5zZXNzaW9uQ2hlY2tpbiA9PT0gdHJ1ZSA/IGNoZWNraW5IYW5kbGVyLmluaXQoKSA6IEhhbmRsZXIuaW5pdCgpO1xuICAgIH1cblx0c2V0dXBVaUkxOG4oKTtcbn0pOyIsInZhciBBY3Rpb25zID0gcmVxdWlyZSgnLi9hY3Rpb25zJyk7XG52YXIgU3RvcmUgPSByZXF1aXJlKCcuL3N0b3JlJykuQ2hlY2tpblN0b3JlO1xudmFyIFNlc3Npb25TdG9yZSA9IHJlcXVpcmUoJy4vc3RvcmUnKS5TZXNzaW9uU3RvcmU7XG52YXIgQXBpID0gcmVxdWlyZSgnY29tbW9uX2FwaScpO1xuXG5cbnZhciBDaGVja2luSGFuZGxlciA9IChmdW5jdGlvbigpIHtcbiAgdmFyIG5hdmJhclNlYXJjaCA9ICQoJy5uYXZiYXItc2VhcmNoLm5hdmJhci1mb3JtJyk7XG4gIHZhciBmaWx0ZXIgPSAkKCcuZHJvcGRvd24uZmlsdGVyLWRyb3Bkb3duJyk7XG4gIHZhciBzZXNzaW9uQ2hlY2tpbkNvbnRhaW5lciA9ICQoJyNzZXNzaW9uX2NoZWNraW5fbGlzdCcpO1xuICB2YXIgZGVmYXVsdFRvZ2dsZVN0YXRlID0geyB2aWV3U3R5bGU6ICdsaXN0LXZpZXcnLCB0aWxlU2l6ZTogJ2NvbC1tZC0xMid9O1xuICB2YXIgY29uc2VjdXRpdmVNZWV0aW5nVGFiID0gJCgnLnRhYl9jb25zZWN1dGl2ZV9tZWV0aW5nJyk7XG4gIHZhciBtb2JpbGVDb25zZWN1dGl2ZUNvdW50VGFiID0gJCgnLm1vYmlsZV90YWJfY29uc2VjdXRpdmVfbWVldGluZycpO1xuICB2YXIgc2Vzc2lvbkNvdW50VGFiID0gJCgnLnRhYl9zZXNzaW9uJyk7XG4gIHZhciBtb2JpbGVTZXNzaW9uQ291bnRUYWIgPSAkKCcubW9iaWxlX3RhYl9zZXNzaW9uJyk7XG4gIHZhciBpbnRlcm5hbENvdW50VGFiID0gJCgnLnRhYl9pbnRlcm5hbCcpO1xuICB2YXIgbW9iaWxlSW50ZXJuYWxDb3VudFRhYiA9ICQoJy5tb2JpbGVfdGFiX2ludGVybmFsJyk7XG4gIHZhciBleHRlcm5hbENvdW50VGFiID0gJCgnLnRhYl9leHRlcm5hbCcpO1xuICB2YXIgbW9iaWxlRXh0ZXJuYWxDb3VudFRhYiA9ICQoJy5tb2JpbGVfdGFiX2V4dGVybmFsJyk7XG4gIHZhciBleHBvcnRCdG4gPSAkKCcjZXhwb3J0Jyk7XG5cbiAgdmFyIHN0b3JlSGFuZGxlcnMgPSB7XG4gICAgb25TZXNzaW9uQ2hlY2tpbkxpc3RTdWNjZXNzOiBvblNlc3Npb25DaGVja2luTGlzdFN1Y2Nlc3NcbiAgfVxuXG4gIGZ1bmN0aW9uIGluaXQoKSB7XG4gIFx0c2V0dXBVSSgpO1xuICBcdHNldHVwTGlzdGVuZXJzKCk7XG4gICAgc2V0dXBTdG9yZUxpc3RlbmVycygpO1xuICAgIEFjdGlvbnMuZmV0Y2hTZXNzaW9uQ2hlY2tpbkxpc3QoMSk7XG4gICAgYWN0aXZhdGVUYWJzKCk7XG4gIH1cblxuICBmdW5jdGlvbiBhY3RpdmF0ZVRhYnMoKXtcbiAgICBpbnRlcm5hbENvdW50VGFiLnJlbW92ZUNsYXNzKCdhY3RpdmUnKTtcbiAgICBtb2JpbGVJbnRlcm5hbENvdW50VGFiLnJlbW92ZUNsYXNzKCdhY3RpdmUnKTtcbiAgICBleHRlcm5hbENvdW50VGFiLnJlbW92ZUNsYXNzKCdhY3RpdmUnKTtcbiAgICBtb2JpbGVFeHRlcm5hbENvdW50VGFiLnJlbW92ZUNsYXNzKCdhY3RpdmUnKTtcbiAgICBjb25zZWN1dGl2ZU1lZXRpbmdUYWIucmVtb3ZlQ2xhc3MoJ2FjdGl2ZScpO1xuICAgIG1vYmlsZUNvbnNlY3V0aXZlQ291bnRUYWIucmVtb3ZlQ2xhc3MoJ2FjdGl2ZScpO1xuICAgIHNlc3Npb25Db3VudFRhYi5hZGRDbGFzcygnYWN0aXZlJylcbiAgICBtb2JpbGVTZXNzaW9uQ291bnRUYWIuYWRkQ2xhc3MoJ2FjdGl2ZScpO1xuICB9XG5cbiAgZnVuY3Rpb24gc2V0dXBVSSgpe1xuICBcdG5hdmJhclNlYXJjaC5hZGRDbGFzcygnaGlkZScpO1xuICBcdGZpbHRlci5hZGRDbGFzcygnaGlkZScpO1xuICB9XG5cbiAgZnVuY3Rpb24gc2V0dXBTdG9yZUxpc3RlbmVycygpe1xuICAgIFN0b3JlLmxpc3RlbihmdW5jdGlvbihkYXRhKXtcbiAgICAgIHZhciBjYWxsQmFja0Z1bmN0aW9uID0gc3RvcmVIYW5kbGVyc1tkYXRhLmFjdGlvbl07XG4gICAgICBpZihkYXRhLmFjdGlvbiAmJiBfLmlzRnVuY3Rpb24oY2FsbEJhY2tGdW5jdGlvbikpe1xuICAgICAgICBjYWxsQmFja0Z1bmN0aW9uKGRhdGEucGF5bG9hZCk7XG4gICAgICB9XG4gICAgfSlcbiAgfVxuXG4gIGZ1bmN0aW9uIG9uU2Vzc2lvbkNoZWNraW5MaXN0U3VjY2VzcyhwYXlsb2FkKXtcbiAgICB2YXIgc2Vzc2lvbnMgPSBwYXlsb2FkLmRhdGE7XG4gICAgZGlzcGxheUNvdW50cyhwYXlsb2FkLnRvdGFsSW50ZXJuYWwsIHBheWxvYWQudG90YWxFeHRlcm5hbCwgcGF5bG9hZC50b3RhbENvbnNlY01lZXRpbmcsIHBheWxvYWQudG90YWxTZXNzaW9ucyk7XG4gICAgdmFyIHRlbXBsYXRlID0gcmVxdWlyZSgnVGVtcGxhdGVzL21lZXRpbmcvY2hlY2tpbicpXG4gICAgc2Vzc2lvbnMubWFwKGZ1bmN0aW9uKHNlc3Npb24pe1xuICAgICAgc2Vzc2lvbi5wZW5kaW5nQ291bnQgPSBzZXNzaW9uLmludml0ZWVzX3N0YXR1c19jb3VudHMucGVuZGluZyB8fCAwO1xuICAgICAgc2Vzc2lvbi50b3RhbEludml0ZWVDb3VudCA9IHNlc3Npb24uaW52aXRlZXNfc3RhdHVzX2NvdW50cy50b3RhbF9pbnZpdGVlcyB8fCAwO1xuICAgICAgc2Vzc2lvbi5hY2NlcHRlZENvdW50ID0gc2Vzc2lvbi5pbnZpdGVlc19zdGF0dXNfY291bnRzLmFjY2VwdGVkIHx8IDA7XG4gICAgICBzZXNzaW9uLmRlY2xpbmVkQ291bnQgPSBzZXNzaW9uLmludml0ZWVzX3N0YXR1c19jb3VudHMuZGVjbGluZWQgfHwgMDtcbiAgICAgIHNlc3Npb24udG9waWNOYW1lID0gc2Vzc2lvbi50b3BpYy5uYW1lO1xuICAgICAgc2Vzc2lvbi5zdGFydFRpbWUgPSBtb21lbnQoc2Vzc2lvbi5zdGFydF90aW1lLCBcIllZWVktTU0tREQgaGg6bW0gQVwiKS5mb3JtYXQoXCJoaDptbSBBXCIpO1xuICAgICAgc2Vzc2lvbi5lbmRUaW1lID0gbW9tZW50KHNlc3Npb24uZW5kX3RpbWUsIFwiWVlZWS1NTS1ERCBoaDptbSBBXCIpLmZvcm1hdChcImhoOm1tIEFcIik7XG4gICAgICBzZXNzaW9uLm1lZXRpbmdEYXRlID0gIG1vbWVudChzZXNzaW9uLnN0YXJ0X3RpbWUpLnRvRGF0ZSgpLnRvTWVkaXVtRGF0ZSgpO1xuICAgICAgc2Vzc2lvbi5sb2NhdGlvbiA9IHNlc3Npb24ucm9vbS5uYW1lO1xuICAgICAgc2Vzc2lvbi5jaGVja2VkSW4gPSAoc2Vzc2lvbi5jaGVja2luID09PSB0cnVlKTtcbiAgICAgIHNldENoZWNrSW5TdGF0dXNlcyhzZXNzaW9uLnVzZXJzLmludGVybmFsLmNvbmNhdChzZXNzaW9uLnVzZXJzLmV4dGVybmFsKSk7XG4gICAgfSk7XG5cbiAgICB2YXIgaHRtbCA9IHRlbXBsYXRlKHtcbiAgICAgIG1lZXRpbmdfbGlzdDogc2Vzc2lvbnMsXG4gICAgICB0b2dnbGVfc3RhdGU6IGRlZmF1bHRUb2dnbGVTdGF0ZVxuICAgIH0pXG4gICAgc2Vzc2lvbkNoZWNraW5Db250YWluZXIuaHRtbChodG1sKTtcbiAgfVxuXG4gIGZ1bmN0aW9uIGRpc3BsYXlDb3VudHMoaW50ZXJuYWxDb3VudCwgZXh0ZXJuYWxDb3VudCwgY29uc2VjQ291bnQsIHNlc3Npb25Db3VudCl7XG4gICAgdmFyIGludGVybmFsVGFiVGV4dCA9IGkxOG4udCggKCBpbnRlcm5hbENvdW50ID09PSAxID8gXCJNRUVUSU5HXCI6IFwiTUVFVElOR1NcIiksIHsgY291bnQ6ICcnIH0gKTtcbiAgICB2YXIgZXh0ZXJuYWxUYWJUZXh0ID0gaTE4bi50KCAoZXh0ZXJuYWxDb3VudCA9PT0gMSA/IFwiUkVRVUVTVFwiOiBcIlJFUVVFU1RTXCIpLCB7IGNvdW50OiAnJyB9KTtcbiAgICB2YXIgZXh0ZXJuYWxNb2JpbGVUYWJUZXh0ID0gaTE4bi50KCAoZXh0ZXJuYWxDb3VudCA9PT0gMSA/IFwiUkVRXCI6IFwiUkVRU1wiKSwgeyBjb3VudDogJycgfSk7XG4gICAgdmFyIHNlc3Npb25UYWJ0ZXh0ID0gaTE4bi50KCAoc2Vzc2lvbkNvdW50ID09PSAxID8gXCJTRVNTSU9OXCI6IFwiU0VTU0lPTlNcIikgKTtcbiAgICB2YXIgY29uc2VjdXRpdmVUYWJUZXh0ID0gaTE4bi50KCAoIGNvbnNlY0NvdW50ID09PSAxID8gXCJDT05TRUNVVElWRSBNRUVUSU5HXCIgOiBcIkNPTlNFQ1VUSVZFIE1FRVRJTkdTXCIpICk7XG4gICAgZGlzcGxheUNvdW50SW5UYWIoZXh0ZXJuYWxDb3VudFRhYiwgbW9iaWxlRXh0ZXJuYWxDb3VudFRhYiwgZXh0ZXJuYWxDb3VudCwgZXh0ZXJuYWxUYWJUZXh0KTtcbiAgICBkaXNwbGF5Q291bnRJblRhYihpbnRlcm5hbENvdW50VGFiLCBtb2JpbGVJbnRlcm5hbENvdW50VGFiLCBpbnRlcm5hbENvdW50LCBpbnRlcm5hbFRhYlRleHQpO1xuICAgIGRpc3BsYXlDb3VudEluVGFiKGNvbnNlY3V0aXZlTWVldGluZ1RhYiwgbW9iaWxlQ29uc2VjdXRpdmVDb3VudFRhYiwgY29uc2VjQ291bnQsIGNvbnNlY3V0aXZlVGFiVGV4dCk7XG4gICAgZGlzcGxheUNvdW50SW5UYWIoc2Vzc2lvbkNvdW50VGFiLCBtb2JpbGVTZXNzaW9uQ291bnRUYWIsIHNlc3Npb25Db3VudCwgc2Vzc2lvblRhYnRleHQpO1xuICB9XG5cbiAgZnVuY3Rpb24gZGlzcGxheUNvdW50SW5UYWIodGFiLCBtb2JpbGVUYWIsIGNvdW50LCB0ZXh0TGFiZWwsIG1vYmlsZVRleHRMYWJlbCkge1xuICAgIHRhYi5maW5kKFwiLm1lZXRpbmdfY291bnRcIikudGV4dChjb3VudClcbiAgICAgICAgICAgIC5zaWJsaW5ncygnc3Bhbi50aXRsZV90ZXh0JykudGV4dCh0ZXh0TGFiZWwpO1xuICAgIG1vYmlsZVRhYi5maW5kKFwiLm1lZXRpbmdfY291bnRcIikudGV4dChjb3VudClcbiAgICAgICAgICAgIC5zaWJsaW5ncygnc3Bhbi50aXRsZV90ZXh0JykudGV4dCggbW9iaWxlVGV4dExhYmVsIHx8IHRleHRMYWJlbCk7XG4gIH1cblxuICBmdW5jdGlvbiBzZXRDaGVja0luU3RhdHVzZXMoYXR0ZW5kZWVzKSB7XG4gICAgaWYgKGF0dGVuZGVlcyBpbnN0YW5jZW9mIEFycmF5KSB7XG4gICAgICBhdHRlbmRlZXMubWFwKGZ1bmN0aW9uKGF0dGVuZGVlKSB7XG4gICAgICAgIGF0dGVuZGVlLmNoZWNrZWRJbiA9IChhdHRlbmRlZS5jaGVja2luID09PSB0cnVlKTtcbiAgICAgIH0pO1xuICAgIH1cbiAgfVxuXG4gIGZ1bmN0aW9uIHNldHVwTGlzdGVuZXJzKCl7XG4gIFx0JCgnLnRvZ2dsZS1idG4nKS5vbignY2xpY2snLCBoYW5kbGVUb2dnbGVWaWV3KTtcbiAgICAkKHdpbmRvdykuaW5maW5pdGVTY3JvbGwoe1xuICAgICAgb2Zmc2V0OiAyMDAsXG4gICAgICBjYWxsYmFjazogZmV0Y2hNb3JlU2Vzc2lvbnNDaGVja2luXG4gICAgfSk7XG4gICAgc2Vzc2lvbkNoZWNraW5Db250YWluZXIub24oJ2NoYW5nZScsICcuY2hlY2tpbl9tZWV0aW5nJywgaGFuZGxlU2Vzc2lvbkNoZWNraW4pO1xuICAgIHNlc3Npb25DaGVja2luQ29udGFpbmVyLm9uKCdjaGFuZ2UnLCAnLmNoZWNraW5fdXNlcicsIGhhbmRsZUF0dGVuZGVlQ2hlY2tpbilcbiAgICBpbnRlcm5hbENvdW50VGFiLm9uKCdjbGljaycsIGhhbmRsZUludGVybmFsVGFiQ2xpY2spO1xuICAgIG1vYmlsZUludGVybmFsQ291bnRUYWIub24oJ2NsaWNrJywgaGFuZGxlSW50ZXJuYWxUYWJDbGljayk7XG4gICAgZXh0ZXJuYWxDb3VudFRhYi5vbignY2xpY2snLCBoYW5kbGVFeHRlcm5hbFRhYkNsaWNrKTtcbiAgICBtb2JpbGVFeHRlcm5hbENvdW50VGFiLm9uKCdjbGljaycsIGhhbmRsZUV4dGVybmFsVGFiQ2xpY2spO1xuICAgIGNvbnNlY3V0aXZlTWVldGluZ1RhYi5vbignY2xpY2snLCBoYW5kbGVDb25zZWN1dGl2ZVRhYkNsaWNrKTtcbiAgICBtb2JpbGVDb25zZWN1dGl2ZUNvdW50VGFiLm9uKCdjbGljaycsIGhhbmRsZUNvbnNlY3V0aXZlVGFiQ2xpY2spO1xuICAgIGV4cG9ydEJ0bi5vbignY2xpY2snLCBleHBvcnRTZXNzaW9ucyk7XG4gIH1cblxuICBmdW5jdGlvbiBleHBvcnRTZXNzaW9ucyhldmVudCl7XG4gICAgZXZlbnQucHJldmVudERlZmF1bHQoKTtcbiAgICBldmVudC5zdG9wUHJvcGFnYXRpb24oKTtcbiAgICB3aW5kb3cuY29tbW9ucy5yZWRpcmVjdFBhZ2UoU2Vzc2lvblN0b3JlLmdlbmVyYXRlRXhwb3J0VXJsKCkpO1xuICB9XG5cbiAgZnVuY3Rpb24gaGFuZGxlQ29uc2VjdXRpdmVUYWJDbGljayhldmVudCl7XG4gICAgZXZlbnQucHJldmVudERlZmF1bHQoKTtcbiAgICBldmVudC5zdG9wUHJvcGFnYXRpb24oKTtcbiAgICBjb21tb25zLnJlZGlyZWN0UGFnZShlbnZEZXRhaWxzLnVybFByZWZpeCArIEFwaS5FTkRQT0lOVFMuY29uc2VjdXRpdmVfbGlzdF9wYWdlKTtcbiAgfVxuXG4gIGZ1bmN0aW9uIGhhbmRsZUludGVybmFsVGFiQ2xpY2soZXZlbnQpe1xuICAgIGV2ZW50LnByZXZlbnREZWZhdWx0KCk7XG4gICAgZXZlbnQuc3RvcFByb3BhZ2F0aW9uKCk7XG4gICAgY29tbW9ucy5yZWRpcmVjdFBhZ2UoZW52RGV0YWlscy51cmxQcmVmaXggKyBBcGkuRU5EUE9JTlRTLm1lZXRpbmdfbGlzdCk7XG4gIH1cblxuICBmdW5jdGlvbiBoYW5kbGVFeHRlcm5hbFRhYkNsaWNrKGV2ZW50KXtcbiAgICBldmVudC5wcmV2ZW50RGVmYXVsdCgpO1xuICAgIGV2ZW50LnN0b3BQcm9wYWdhdGlvbigpO1xuICAgIGNvbW1vbnMucmVkaXJlY3RQYWdlKGVudkRldGFpbHMudXJsUHJlZml4ICsgQXBpLkVORFBPSU5UUy5leHRlcm5hbF9yZXF1ZXN0cyk7XG4gIH1cblxuICBmdW5jdGlvbiBoYW5kbGVTZXNzaW9uQ2hlY2tpbihldmVudCl7XG4gICAgZXZlbnQucHJldmVudERlZmF1bHQoKTtcbiAgICBldmVudC5zdG9wUHJvcGFnYXRpb24oKTtcbiAgICB2YXIgc2Vzc2lvbiA9ICQodGhpcyk7XG4gICAgdmFyIHNlc3Npb25VdWlkID0gc2Vzc2lvbi5jbG9zZXN0KCcubWVldGluZy1jYXJkJykuZGF0YSgndXVpZCcpO1xuICAgIHZhciBzdGF0dXMgPSBzZXNzaW9uLmlzKCc6Y2hlY2tlZCcpID8gMSA6IDA7XG4gICAgQWN0aW9ucy5jaGVja2luU2Vzc2lvbihzZXNzaW9uVXVpZCwgc3RhdHVzKTtcbiAgfVxuXG4gIGZ1bmN0aW9uIGhhbmRsZUF0dGVuZGVlQ2hlY2tpbihldmVudCl7XG4gICAgZXZlbnQucHJldmVudERlZmF1bHQoKTtcbiAgICBldmVudC5zdG9wUHJvcGFnYXRpb24oKTtcbiAgICB2YXIgYXR0ZW5kZWUgPSAkKHRoaXMpO1xuICAgIHZhciBzZXNzaW9uID0gYXR0ZW5kZWUuY2xvc2VzdCgnLm1lZXRpbmctY2FyZCcpO1xuICAgIHZhciBzZXNzaW9uVXVpZCA9IHNlc3Npb24uZGF0YSgndXVpZCcpO1xuICAgIHZhciBhdHRlbmRlZVV1aWQgPSBhdHRlbmRlZS5kYXRhKCd1dWlkJyk7XG4gICAgdmFyIGF0dGVuZGVlVHlwZSA9IGF0dGVuZGVlLmRhdGEoJ2F0dGVuZGVlX3R5cGUnKTtcbiAgICB2YXIgc3RhdHVzID0gYXR0ZW5kZWUuaXMoJzpjaGVja2VkJykgPyAxIDogMFxuICAgIGlmKHN0YXR1cyA9PT0gMSl7XG4gICAgICBzZXNzaW9uLmZpbmQoJy5jaGVja2luX21lZXRpbmcnKS5wcm9wKCdjaGVja2VkJywgdHJ1ZSk7XG4gICAgfVxuICAgIEFjdGlvbnMuY2hlY2tpbkF0dGVuZGVlKHNlc3Npb25VdWlkLCBhdHRlbmRlZVV1aWQsIHN0YXR1cywgYXR0ZW5kZWVUeXBlKTtcbiAgfVxuXG4gIGZ1bmN0aW9uIGZldGNoTW9yZVNlc3Npb25zQ2hlY2tpbigpe1xuICAgIGlmIChTdG9yZS5nZXRDdXJyZW50UGFnZSgpIDw9IFN0b3JlLmdldFRvdGFsUGFnZXMoKSl7XG4gICAgICBBY3Rpb25zLmZldGNoU2Vzc2lvbkNoZWNraW5MaXN0KFN0b3JlLmdldEN1cnJlbnRQYWdlKCkpO1xuICAgIH1cbiAgfVxuXG4gIGZ1bmN0aW9uIGhhbmRsZVRvZ2dsZVZpZXcoKXtcbiAgXHR2YXIgZWxlbSA9ICQodGhpcyk7XG4gIFx0dmFyIHR5cGUgPSBlbGVtLmRhdGEoJ3N3aXRjaC10eXBlJyk7XG4gIFx0aWYodHlwZSAhPT0gJ2NoZWNraW4nKXtcbiAgXHRcdHZhciByZWRpcmVjdFVybCA9IGVudkRldGFpbHMudXJsUHJlZml4ICsgQXBpLkVORFBPSU5UUy5zZXNzaW9uX2xpc3Q7XG4gIFx0XHRjb21tb25zLnJlZGlyZWN0UGFnZShyZWRpcmVjdFVybCk7XG4gICAgICBjb21tb25zLnNldEl0ZW0oJ3Nlc3Npb24tbGlzdCcsIHR5cGUpO1xuICBcdH1cbiAgfVxuXG4gIHJldHVybiB7XG4gICAgaW5pdDogaW5pdFxuICB9XG5cbn0pKCk7XG5cbm1vZHVsZS5leHBvcnRzID0gQ2hlY2tpbkhhbmRsZXI7XG4iLCJ2YXIgQWN0aW9ucyA9IHJlcXVpcmUoJy4vYWN0aW9ucycpO1xudmFyIFN0b3JlID0gcmVxdWlyZSgnLi9zdG9yZScpLlNlc3Npb25TdG9yZTtcbnZhciBBcGkgPSByZXF1aXJlKCdjb21tb25fYXBpJyk7XG5cblxudmFyIFNlc3Npb25IYW5kbGVyID0gKGZ1bmN0aW9uKCkge1xuXG4gIHZhciBzZXNzaW9uTGlzdENvbnRhaW5lciA9ICQoJyNtZWV0aW5nX2xpc3QnKTtcbiAgLy92YXIgZXh0ZXJuYWxDb3VudFRhYiA9ICQoJy50YWJfZXh0ZXJuYWwnKTtcbiAgLy92YXIgbW9iaWxlRXh0ZXJuYWxDb3VudFRhYiA9ICQoJy5tb2JpbGVfdGFiX2V4dGVybmFsJyk7XG4gIHZhciBpbnRlcm5hbENvdW50VGFiID0gJCgnLnRhYl9pbnRlcm5hbCcpO1xuICB2YXIgbW9iaWxlSW50ZXJuYWxDb3VudFRhYiA9ICQoJy5tb2JpbGVfdGFiX2ludGVybmFsJyk7XG4gIHZhciBzZXNzaW9uQ291bnRUYWIgPSAkKCcudGFiX3Nlc3Npb24nKTtcbiAgdmFyIG1vYmlsZVNlc3Npb25Db3VudFRhYiA9ICQoJy5tb2JpbGVfdGFiX3Nlc3Npb24nKTtcbiAgdmFyIGludGVybmFsU2VsZWN0QWxsID0gJChcIi5tYW5hZ2UtaW50ZXJuYWwtc2VsZWN0YWxsXCIpO1xuICB2YXIgZXhwb3J0QnRuID0gJCgnI2V4cG9ydCcpO1xuICB2YXIgY3VycmVudFZpZXdTdHlsZTtcbiAgdmFyIGNvbnNlY3V0aXZlTWVldGluZ1RhYiA9ICQoJy50YWJfY29uc2VjdXRpdmVfbWVldGluZycpO1xuICB2YXIgbW9iaWxlQ29uc2VjdXRpdmVDb3VudFRhYiA9ICQoJy5tb2JpbGVfdGFiX2NvbnNlY3V0aXZlX21lZXRpbmcnKTtcbiAgdmFyIG5vdGlmaWNhdGlvbk1vZGFsID0gJChcIi5ub3RpZmljYXRpb24tbW9kYWxcIik7XG4gIHZhciBpdGVtU2l6ZSA9IHtcbiAgICAndGlsZS12aWV3JzogJ2NvbC1tZC0zIGNvbC1zbS00JyxcbiAgICAnbGlzdC12aWV3JzogJ2NvbC1tZC0xMidcbiAgfTtcblxuICB2YXIgc3RvcmVIYW5kbGVycyA9IHtcbiAgICBzZXNzaW9ubGlzdGluZzogaGFuZGVsU2Vzc2lvbkxpc3QsXG4gICAgc2Vzc2lvbk5vbWluYXRpb25zOiBoYW5kbGVTZXNzaW9uTm9taW5hdGlvbnNcbiAgfTtcblxuICBmdW5jdGlvbiBpbml0KCkge1xuXG4gICAgJChcIi5uYXZiYXItZm9ybVwiKS5oaWRlKCk7XG4gICAgJChcImxpLmZpbHRlci1kcm9wZG93blwiKS5oaWRlKCk7IC8vIHZpbmF5OiBoaWRpbmcgc2luY2UgdGhlcmUgaXMgbm8gc2VhcmNoIGFuZCBmaWx0ZXJzIGZvciBzZXNzaW9ucyB5ZXQuXG4gICAgc2Vzc2lvbkxpc3RDb250YWluZXIub24oJ2NsaWNrJywgJyNzZXNzaW9uX2NsaWNrJywgZ2V0Tm9taW5hdGlvbnMpO1xuICAgIG1vYmlsZUludGVybmFsQ291bnRUYWIucmVtb3ZlQ2xhc3MoJ2FjdGl2ZScpO1xuICAgIC8vbW9iaWxlRXh0ZXJuYWxDb3VudFRhYi5yZW1vdmVDbGFzcygnYWN0aXZlJyk7XG4gICAgaW50ZXJuYWxDb3VudFRhYi5yZW1vdmVDbGFzcygnYWN0aXZlJyk7XG4gICAgLy9leHRlcm5hbENvdW50VGFiLnJlbW92ZUNsYXNzKCdhY3RpdmUnKTtcbiAgICBzZXNzaW9uQ291bnRUYWIuYWRkQ2xhc3MoJ2FjdGl2ZScpO1xuICAgIG1vYmlsZVNlc3Npb25Db3VudFRhYi5hZGRDbGFzcygnYWN0aXZlJyk7XG4gICAgY29tbW9ucy5zZXRJdGVtKCdtZWV0aW5nLWxpc3QnLCAnZ3JpZCcpO1xuICAgIGludGVybmFsU2VsZWN0QWxsLmFkZENsYXNzKFwiaGlkZVwiKTtcbiAgICBzZXRVcExpc3RlbmVycygpO1xuICAgIFN0b3JlLmxpc3RlbihmdW5jdGlvbihkYXRhKSB7XG4gICAgICB2YXIgZnVuYyA9IHN0b3JlSGFuZGxlcnNbZGF0YS50eXBlXTtcbiAgICAgIGlmIChmdW5jKSB7XG4gICAgICAgIGZ1bmMoZGF0YSk7XG4gICAgICB9XG4gICAgfSk7XG5cbiAgICBBY3Rpb25zLmZldGNoU2Vzc2lvbnMoMSk7XG4gICAgc2V0VmlldygpO1xuICB9XG5cbiAgZnVuY3Rpb24gc2V0Vmlldygpe1xuICAgICQoJ2FbZGF0YS1zd2l0Y2gtdHlwZV0nKS5yZW1vdmVDbGFzcygnYWN0aXZlJyk7XG4gICAgaWYoY29tbW9ucy5nZXRJdGVtKCdzZXNzaW9uLWxpc3QnKSA9PT0gJ2xpc3QnKXtcbiAgICAgIGN1cnJlbnRWaWV3U3R5bGUgPSAnbGlzdC12aWV3JztcbiAgICAgICQoJ2FbZGF0YS1zd2l0Y2gtdHlwZT1cImxpc3RcIl0nKS5hZGRDbGFzcygnYWN0aXZlJyk7XG4gICAgfWVsc2V7XG4gICAgICBjdXJyZW50Vmlld1N0eWxlID0gJ3RpbGUtdmlldyc7XG4gICAgICAkKCdhW2RhdGEtc3dpdGNoLXR5cGU9XCJncmlkXCJdJykuYWRkQ2xhc3MoJ2FjdGl2ZScpO1xuICAgIH1cbiAgfVxuXG4gIGZ1bmN0aW9uIGhhbmRsZUNvbnNlY3V0aXZlVGFiQ2xpY2soZXZlbnQpe1xuICAgICAgZXZlbnQucHJldmVudERlZmF1bHQoKTtcbiAgICAgIGV2ZW50LnN0b3BQcm9wYWdhdGlvbigpO1xuICAgICAgY29tbW9ucy5yZWRpcmVjdFBhZ2UoZW52RGV0YWlscy51cmxQcmVmaXggKyBBcGkuRU5EUE9JTlRTLmNvbnNlY3V0aXZlX2xpc3RfcGFnZSlcbiAgfVxuXG4gIGZ1bmN0aW9uIHNldFVwTGlzdGVuZXJzKCkge1xuXG4gICAgYXR0YWNoQ29tbW9uVUlMaXN0ZW5lcmVzKCk7XG5cbiAgICBpbnRlcm5hbENvdW50VGFiLm9uKCdjbGljaycsIGhhbmRsZUludGVybmFsVGFiQ2xpY2spO1xuICAgIG1vYmlsZUludGVybmFsQ291bnRUYWIub24oJ2NsaWNrJywgaGFuZGxlSW50ZXJuYWxUYWJDbGljayk7XG4gICAgLy9leHRlcm5hbENvdW50VGFiLm9uKCdjbGljaycsIGhhbmRsZUV4dGVybmFsVGFiQ2xpY2spO1xuICAgIC8vbW9iaWxlRXh0ZXJuYWxDb3VudFRhYi5vbignY2xpY2snLCBoYW5kbGVFeHRlcm5hbFRhYkNsaWNrKTtcbiAgICAkKCdhW2RhdGEtc3dpdGNoLXR5cGVdJykub24oJ2NsaWNrJywgaGFuZGVsVmlld1RvZ2dsZSk7XG4gICAgZXhwb3J0QnRuLm9uKCdjbGljaycsIGV4cG9ydFNlc3Npb25zKTtcbiAgICBjb25zZWN1dGl2ZU1lZXRpbmdUYWIub24oJ2NsaWNrJywgaGFuZGxlQ29uc2VjdXRpdmVUYWJDbGljayk7XG4gICAgbW9iaWxlQ29uc2VjdXRpdmVDb3VudFRhYi5vbignY2xpY2snLCBoYW5kbGVDb25zZWN1dGl2ZVRhYkNsaWNrKTtcbiAgICBzZXNzaW9uQ291bnRUYWIub24oJ2NsaWNrJywgaGFuZGxlU2Vzc2lvblRhYkNsaWNrKTtcbiAgICBtb2JpbGVTZXNzaW9uQ291bnRUYWIub24oJ2NsaWNrJywgaGFuZGxlU2Vzc2lvblRhYkNsaWNrKTtcbiAgfVxuXG4gIGZ1bmN0aW9uIGF0dGFjaENvbW1vblVJTGlzdGVuZXJlcygpIHtcblxuICAgICQod2luZG93KS5pbmZpbml0ZVNjcm9sbCh7XG4gICAgICBvZmZzZXQ6IDIwMCxcbiAgICAgIGNhbGxiYWNrOiBmZXRjaE1vcmVTZXNzaW9uc1xuICAgIH0pO1xuICB9XG5cbiAgZnVuY3Rpb24gZ2V0Tm9taW5hdGlvbnMoZSkge1xuICAgIHZhciBzZXNzaW9uVXVpZCA9ICQodGhpcykuZGF0YShcInV1aWRcIik7XG4gICAgQWN0aW9ucy5mZXRjaFNlc3Npb25Ob21pbmF0aW9ucyh7c2Vzc2lvbl91dWlkOiBzZXNzaW9uVXVpZH0pO1xuICB9XG5cbiAgZnVuY3Rpb24gZXhwb3J0U2Vzc2lvbnMoZSkge1xuICAgICAgZS5wcmV2ZW50RGVmYXVsdCgpO1xuICAgICAgZS5zdG9wUHJvcGFnYXRpb24oKTtcbiAgICAgIHdpbmRvdy5jb21tb25zLnJlZGlyZWN0UGFnZShTdG9yZS5nZW5lcmF0ZUV4cG9ydFVybCgpKTtcbiAgICB9XG5cbiAgZnVuY3Rpb24gaGlkZU5vbWluYXRpb25zTGlzdCgpIHtcbiAgICAkKFwiI2dyb3VwLW5vbWluYXRvaW4tbGlzdFwiKS5tb2RhbCgnaGlkZScpO1xuICB9XG5cbiAgZnVuY3Rpb24gc2hvd05vbWluYXRpb25zTGlzdCgpIHtcbiAgICAkKFwiI2dyb3VwLW5vbWluYXRvaW4tbGlzdFwiKS5tb2RhbCgnc2hvdycpO1xuICB9XG5cbiAgZnVuY3Rpb24gaGFuZGxlU2Vzc2lvbk5vbWluYXRpb25zKGFwaVJlc3BvbnNlKSB7XG4gICAgY29uc3Qgbm9taW5hdGlvbkxhYmVsID0gY29tbW9uU3RvcmUuZ2V0Q3VzdG9tTGFiZWxzKClbJ25vbWluYXRpb25fY3VzdG9tX2xhYmVsJ11cbiAgICB2YXIgbm9taW5hdGlvbnMgPSBhcGlSZXNwb25zZS5kYXRhLmRhdGEubm9taW5hdGlvbnMsXG4gICAgICByZWRpcmVjdGlvblBhdGg7XG4gICAgaWYobm9taW5hdGlvbnMubGVuZ3RoID09PSAwKSB7XG4gICAgICBpZihhcGlSZXNwb25zZS5kYXRhLmRhdGEuc2hvd19tZXNzYWdlKSB7XG4gICAgICAgIG5vdGlmaWNhdGlvbk1vZGFsLm5vdGlmaWNhdGlvbk1vZGFsKHt0aXRsZTogaTE4bi50KCdub19ub21pbmF0aW9uc19oZWFkZXInLCB7bm9taW5hdGlvbkxhYmVsfSksIGJvZHk6IGFwaVJlc3BvbnNlLmRhdGEuZGF0YS5tZXNzYWdlLCBjbGFzczogJ2JsdWUnfSlcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHZhciBzZXNzaW9uUGFyYW1zID0gXCJcIjtcbiAgICAgICAgdmFyIHNlc3Npb25PYmogPSBTdG9yZS5nZXRTZXNzaW9uT2JqKGFwaVJlc3BvbnNlLmRhdGEuZGF0YS5zZXNzaW9uX3V1aWQpO1xuICAgICAgICBpZiAoICFfLmlzRW1wdHkoc2Vzc2lvbk9iaikgKSB7XG4gICAgICAgICAgc2Vzc2lvblBhcmFtcyA9IFwiJnNlc3Npb25fdXVpZD1cIiArIHNlc3Npb25PYmoudXVpZCArXG4gICAgICAgICAgICBcIiZ0cmFja191dWlkPVwiICsgc2Vzc2lvbk9iai50cmFjay51dWlkICtcbiAgICAgICAgICAgIFwiJnRvcGljX3V1aWQ9XCIgKyBzZXNzaW9uT2JqLnRvcGljLnV1aWQ7XG4gICAgICAgIH1cbiAgICAgICAgY29tbW9ucy5yZWRpcmVjdFBhZ2UoZW52RGV0YWlscy51cmxQcmVmaXggKyBBcGkuRU5EUE9JTlRTLm1lZXRpbmdfcmVxdWVzdF9wYXRoICsgJz8nICsgJC5wYXJhbSh7XG4gICAgICAgICAgYWN0aXZpdHlfdXVpZDogYXBpUmVzcG9uc2UuZGF0YS5kYXRhLmFjdGl2aXR5X3V1aWRcbiAgICAgICAgfSkgKyBzZXNzaW9uUGFyYW1zKVxuICAgICAgfVxuICAgIH0gZWxzZSB7XG4gICAgICB2YXIgZWRpdGFibGVfbm9taW5hdGlvbjtcbiAgICAgICQobm9taW5hdGlvbnMpLmVhY2goZnVuY3Rpb24oaSwgdmFsdWUpe1xuICAgICAgICBpZih2YWx1ZS5jYW5fZWRpdCl7XG4gICAgICAgICAgZWRpdGFibGVfbm9taW5hdGlvbiA9IHZhbHVlO1xuICAgICAgICAgcmV0dXJuIGZhbHNlO1xuICAgICAgICB9XG4gICAgICB9KTtcbiAgICAgIGlmKGVkaXRhYmxlX25vbWluYXRpb24pe1xuICAgICAgICBpZih0eXBlb2YgamlmZmxlICE9PSAndW5kZWZpbmVkJyl7XG4gICAgICAgICAgdmFyIHJlZGlyZWN0aW9uUGF0aCA9IHdpbmRvdy5sb2NhdGlvbi5vcmlnaW4gKyBBcGkuRU5EUE9JTlRTLmpuX2Jvb2tfbm9taW5hdGlvbjtcbiAgICAgICAgICB2YXIgc2VhcmNoID0gd2luZG93LmxvY2F0aW9uLnNlYXJjaDtcbiAgICAgICAgICB2YXIgbW9kZVEgPSAnJm1vZGU9ZWRpdCdcbiAgICAgICAgICBzZWFyY2ggPSBzZWFyY2ggKyBcIiZub21pbmF0aW9uPVwiICsgZWRpdGFibGVfbm9taW5hdGlvbi51dWlkO1xuICAgICAgICAgIHJlZGlyZWN0aW9uUGF0aCA9IHJlZGlyZWN0aW9uUGF0aCArIHNlYXJjaCArIG1vZGVRO1xuICAgICAgICB9ZWxzZXtcbiAgICAgICAgICByZWRpcmVjdGlvblBhdGggPSBlbnZEZXRhaWxzLnVybFByZWZpeCArIEFwaS5FTkRQT0lOVFMuZ3JvdXBfbm9taW5hdGlvbl9lZGl0O1xuICAgICAgICAgIHJlZGlyZWN0aW9uUGF0aCA9IHJlZGlyZWN0aW9uUGF0aC5yZXBsYWNlKCd7e3V1aWR9fScsIGVkaXRhYmxlX25vbWluYXRpb24udXVpZClcbiAgICAgICAgfVxuICAgICAgfVxuICAgICAgZWxzZXtcbiAgICAgICAgaWYodHlwZW9mIGppZmZsZSAhPT0gJ3VuZGVmaW5lZCcpe1xuICAgICAgICAgIHZhciByZWRpcmVjdGlvblBhdGggPSB3aW5kb3cubG9jYXRpb24ub3JpZ2luICsgQXBpLkVORFBPSU5UUy5qbl92aWV3X25vbWluYXRpb247XG4gICAgICAgICAgdmFyIHNlYXJjaCA9IHdpbmRvdy5sb2NhdGlvbi5zZWFyY2g7XG4gICAgICAgICAgdmFyIG1vZGVRID0gJyZtb2RlPXZpZXcnXG4gICAgICAgICAgc2VhcmNoID0gc2VhcmNoICsgXCImbm9taW5hdGlvbj1cIiArIG5vbWluYXRpb25zWzBdLnV1aWQ7XG4gICAgICAgICAgcmVkaXJlY3Rpb25QYXRoID0gcmVkaXJlY3Rpb25QYXRoICsgc2VhcmNoICsgbW9kZVE7XG4gICAgICAgIH1lbHNle1xuICAgICAgICAgIHJlZGlyZWN0aW9uUGF0aCA9IGVudkRldGFpbHMudXJsUHJlZml4ICsgQXBpLkVORFBPSU5UUy5ncm91cF9ub21pbmF0aW9uX3ZpZXc7XG4gICAgICAgICAgcmVkaXJlY3Rpb25QYXRoID0gcmVkaXJlY3Rpb25QYXRoLnJlcGxhY2UoJ3t7dXVpZH19Jywgbm9taW5hdGlvbnNbMF0udXVpZClcbiAgICAgICAgfVxuICAgICAgfVxuICAgICAgY29tbW9ucy5yZWRpcmVjdFBhZ2UocmVkaXJlY3Rpb25QYXRoKVxuICAgIH1cbiAgfVxuICBmdW5jdGlvbiBoYW5kZWxTZXNzaW9uTGlzdChkYXRhKSB7XG4gICAgZGlzcGxheU1lZXRpbmdzKGRhdGEuZGF0YSk7XG4gICAgdXBkYXRlTWVldGluZ0NvdW50KGRhdGEuZGF0YS50b3RhbCwgZGF0YS5kYXRhLnRvdGFsRXh0ZXJuYWwsIGRhdGEuZGF0YS50b3RhbEludGVybmFsLCBkYXRhLmRhdGEudG90YWxDb25zZWMpO1xuICB9XG5cbiAgZnVuY3Rpb24gaGFuZGVsVmlld1RvZ2dsZShkYXRhKSB7XG4gICAgdmFyIEVsID0gJCh0aGlzKTtcbiAgICB2YXIgaXNDaGVja0luQ2xpY2sgPSBFbC5kYXRhKCdzd2l0Y2gtdHlwZScpID09PSAnY2hlY2tpbicgPyB0cnVlIDogZmFsc2U7XG5cbiAgICBpZihpc0NoZWNrSW5DbGljayl7XG4gICAgICB2YXIgY2hlY2tpblVybCA9IGVudkRldGFpbHMudXJsUHJlZml4ICsgQXBpLkVORFBPSU5UUy5jaGVja2luX3Nlc3Npb25zX2xpc3Q7XG4gICAgICB3aW5kb3cuY29tbW9ucy5yZWRpcmVjdFBhZ2UoY2hlY2tpblVybCk7XG4gICAgfWVsc2V7XG4gICAgICAgICQoJ2FbZGF0YS1zd2l0Y2gtdHlwZV0nKS5yZW1vdmVDbGFzcygnYWN0aXZlJyk7XG4gICAgICAgIEVsLmFkZENsYXNzKCdhY3RpdmUnKTtcbiAgICAgICAgdmFyIHZpZXdTdHlsZSA9IHsgJ2dyaWQnOiAndGlsZS12aWV3JywgJ2xpc3QnOiAnbGlzdC12aWV3JyB9W0VsLmRhdGEoXCJzd2l0Y2gtdHlwZVwiKV07XG4gICAgICAgIGN1cnJlbnRWaWV3U3R5bGUgPSB2aWV3U3R5bGU7XG4gICAgICAgIHZhciBsaXN0SG9sZGVyID0gc2Vzc2lvbkxpc3RDb250YWluZXIuZmluZCgnLm1lZXRpbmctbGlzdCcpO1xuICAgICAgICBsaXN0SG9sZGVyLnJlbW92ZUNsYXNzKFwidGlsZS12aWV3IGxpc3Qtdmlld1wiKS5hZGRDbGFzcyh2aWV3U3R5bGUpO1xuICAgICAgICBsaXN0SG9sZGVyLmZpbmQoXCJkaXYuaXRlbVwiKS5yZW1vdmVDbGFzcyhcImNvbC1tZC0zIGNvbC1zbS00IGNvbC1tZC0xMlwiKS5hZGRDbGFzcyhpdGVtU2l6ZVt2aWV3U3R5bGVdKTtcbiAgICB9XG4gIH1cblxuICBmdW5jdGlvbiBkaXNwbGF5TWVldGluZ3MoZGF0YSkge1xuXG4gICAgdmFyIHRlbXBsYXRlID0gcmVxdWlyZSgnVGVtcGxhdGVzL21lZXRpbmcvc2Vzc2lvbi1saXN0JylcbiAgICB2YXIgc2Vzc2lvbnMgPSBfLmNsb25lRGVlcChkYXRhLnNlc3Npb25zKTtcbiAgICBzZXNzaW9ucy5tYXAoZnVuY3Rpb24oc2Vzc2lvbil7XG4gICAgICBzZXNzaW9uLnJlbWFpbmluZ0NvdW50ID0gc2Vzc2lvbi5jYXBhY2l0eSAtIHNlc3Npb24ubm90X2RlY2xpbmVkX3VzZXJfY291bnQ7XG4gICAgICBzZXNzaW9uLnNlc3Npb25EYXRlID0gbW9tZW50KHNlc3Npb24uc3RhcnRfdGltZSkudG9EYXRlKCkudG9NZWRpdW1EYXRlKCk7XG4gICAgICBzZXNzaW9uLnN0YXJ0VGltZSA9ICBtb21lbnQoc2Vzc2lvbi5zdGFydF90aW1lLCBcIllZWVktTU0tREQgaGg6bW0gQVwiKS5mb3JtYXQoXCJoaDptbSBBXCIpO1xuICAgICAgc2Vzc2lvbi5lbmRUaW1lID0gIG1vbWVudChzZXNzaW9uLmVuZF90aW1lLCBcIllZWVktTU0tREQgaGg6bW0gQVwiKS5mb3JtYXQoXCJoaDptbSBBXCIpO1xuICAgIH0pXG4gICAgc2Vzc2lvbkxpc3RDb250YWluZXIuaHRtbCh0ZW1wbGF0ZSh7XG4gICAgICBzZXNzaW9uc19saXN0OiBzZXNzaW9ucyxcbiAgICAgIHRvZ2dsZV9zdGF0ZToge1xuICAgICAgICB2aWV3U3R5bGU6IGN1cnJlbnRWaWV3U3R5bGUsXG4gICAgICAgIHRpbGVTaXplOiBpdGVtU2l6ZVtjdXJyZW50Vmlld1N0eWxlXVxuICAgICAgfVxuICAgIH0pKTtcbiAgfVxuXG4gIGZ1bmN0aW9uIHVwZGF0ZU1lZXRpbmdDb3VudChjb3VudCwgZXh0ZXJuYWxDb3VudCwgaW50ZXJuYWxDb3VudCwgY29uc2VjQ291bnQpIHtcblxuICAgICQoXCIudGFiX3Nlc3Npb25cIikuZmluZChcIi5tZWV0aW5nX2NvdW50XCIpLnRleHQoY291bnQpXG4gICAgICAuc2libGluZ3MoJ3NwYW4udGl0bGVfdGV4dCcpLmh0bWwoaTE4bi50KChjb3VudCA9PT0gMSA/IFwiU0VTU0lPTlwiIDogXCJTRVNTSU9OU1wiKSwgeyBjb3VudDogJycgfSkpO1xuICAgICQoXCIubW9iaWxlX3RhYl9zZXNzaW9uXCIpLmZpbmQoXCIubWVldGluZ19jb3VudFwiKS50ZXh0KGNvdW50KVxuICAgICAgLnNpYmxpbmdzKCdzcGFuLnRpdGxlX3RleHQnKS5odG1sKGkxOG4udCgoY291bnQgPT09IDEgPyBcIlNFU1NJT05cIiA6IFwiU0VTU0lPTlNcIiksIHsgY291bnQ6ICcnIH0pKTtcbiAgICAkKFwiLm1vYmlsZV90YWJfaW50ZXJuYWxcIikuZmluZChcIi5tZWV0aW5nX2NvdW50XCIpLnRleHQoaW50ZXJuYWxDb3VudClcbiAgICAgIC5zaWJsaW5ncygnc3Bhbi50aXRsZV90ZXh0JykuaHRtbChpMThuLnQoKGludGVybmFsQ291bnQgPT09IDEgPyBcIk1FRVRJTkdcIiA6IFwiTUVFVElOR1NcIiksIHsgY291bnQ6ICcnIH0pKTtcbiAgICAkKFwiLnRhYl9pbnRlcm5hbFwiKS5maW5kKFwiLm1lZXRpbmdfY291bnRcIikudGV4dChpbnRlcm5hbENvdW50KVxuICAgICAgLnNpYmxpbmdzKCdzcGFuLnRpdGxlX3RleHQnKS5odG1sKGkxOG4udCgoaW50ZXJuYWxDb3VudCA9PT0gMSA/IFwiTUVFVElOR1wiIDogXCJNRUVUSU5HU1wiKSwgeyBjb3VudDogJycgfSkpO1xuICAgICQoXCIubW9iaWxlX3RhYl9leHRlcm5hbFwiKS5maW5kKFwiLm1lZXRpbmdfY291bnRcIikudGV4dChleHRlcm5hbENvdW50KVxuICAgICAgLnNpYmxpbmdzKCdzcGFuLnRpdGxlX3RleHQnKS5odG1sKGkxOG4udCgoZXh0ZXJuYWxDb3VudCA9PT0gMSA/IFwiUkVRXCIgOiBcIlJFUVNcIiksIHsgY291bnQ6ICcnIH0pKTtcbiAgICAkKFwiLnRhYl9leHRlcm5hbFwiKS5maW5kKFwiLm1lZXRpbmdfY291bnRcIikudGV4dChleHRlcm5hbENvdW50KVxuICAgICAgLnNpYmxpbmdzKCdzcGFuLnRpdGxlX3RleHQnKS5odG1sKGkxOG4udCgoZXh0ZXJuYWxDb3VudCA9PT0gMSA/IFwiUkVRVUVTVFwiIDogXCJSRVFVRVNUU1wiKSwgeyBjb3VudDogJycgfSkpO1xuICAgIGNvbnNlY3V0aXZlTWVldGluZ1RhYi5maW5kKFwiLm1lZXRpbmdfY291bnRcIikudGV4dChjb25zZWNDb3VudClcbiAgICAgIC5zaWJsaW5ncygnc3Bhbi50aXRsZV90ZXh0JykuaHRtbChpMThuLnQoKGNvbnNlY0NvdW50ID09PSAxID8gXCJjb25zZWN1dGl2ZV9tZWV0aW5nXCIgOiBcImNvbnNlY3V0aXZlX21lZXRpbmdzXCIpLCB7IGNvdW50OiAnJyB9KSk7XG4gICAgbW9iaWxlQ29uc2VjdXRpdmVDb3VudFRhYi5maW5kKFwiLm1lZXRpbmdfY291bnRcIikudGV4dChjb25zZWNDb3VudClcbiAgICAgIC5zaWJsaW5ncygnc3Bhbi50aXRsZV90ZXh0JykuaHRtbChpMThuLnQoKGNvbnNlY0NvdW50ID09PSAxID8gXCJjb25zZWN1dGl2ZV9tZWV0aW5nc1wiIDogXCJjb25zZWN1dGl2ZV9tZWV0aW5nc1wiKSwgeyBjb3VudDogJycgfSkpO1xuICB9XG5cbiAgZnVuY3Rpb24gaGFuZGxlSW50ZXJuYWxUYWJDbGljayhldmVudCkge1xuICAgIGV2ZW50LnByZXZlbnREZWZhdWx0KCk7XG4gICAgZXZlbnQuc3RvcFByb3BhZ2F0aW9uKCk7XG5cbiAgICBpZiAodHlwZW9mIGppZmZsZSAhPT0gJ3VuZGVmaW5lZCcpIHtcbiAgICAgIHZhciBzZWFyY2ggPSB3aW5kb3cubG9jYXRpb24uc2VhcmNoXG4gICAgICBuZXdQYWdlID0gQXBpLkVORFBPSU5UUy5hcGV4X2pubWVldGluZ3MgKyBzZWFyY2hcbiAgICAgIHdpbmRvdy5jb21tb25zLnJlZGlyZWN0UGFnZShuZXdQYWdlKVxuICAgIH1cbiAgICBlbHNlIFxuICAgICAgY29tbW9ucy5yZWRpcmVjdFBhZ2UoZW52RGV0YWlscy51cmxQcmVmaXggKyAnL21lZXRpbmdfbGlzdCcpXG4gIH1cblxuICBmdW5jdGlvbiBoYW5kbGVTZXNzaW9uVGFiQ2xpY2sgKGV2ZW50KSB7XG4gICAgZXZlbnQucHJldmVudERlZmF1bHQoKVxuICAgIGV2ZW50LnN0b3BQcm9wYWdhdGlvbigpXG5cbiAgICBpZiAodHlwZW9mIGppZmZsZSAhPT0gJ3VuZGVmaW5lZCcpIHtcbiAgICAgIHZhciBzZWFyY2ggPSB3aW5kb3cubG9jYXRpb24uc2VhcmNoXG4gICAgICBuZXdQYWdlID0gQXBpLkVORFBPSU5UUy5hcGV4X2puc2Vzc2lvbnMgKyBzZWFyY2hcbiAgICAgIHdpbmRvdy5jb21tb25zLnJlZGlyZWN0UGFnZShuZXdQYWdlKVxuICAgIH1cbiAgICBlbHNlXG4gICAgICB3aW5kb3cuY29tbW9ucy5yZWRpcmVjdFBhZ2UoZW52RGV0YWlscy51cmxQcmVmaXggKyAnL3Nlc3Npb25fbGlzdCcpXG4gIH1cblxuLyogIGZ1bmN0aW9uIGhhbmRsZUV4dGVybmFsVGFiQ2xpY2soZXZlbnQpIHtcbiAgICBldmVudC5wcmV2ZW50RGVmYXVsdCgpO1xuICAgIGV2ZW50LnN0b3BQcm9wYWdhdGlvbigpO1xuXG4gICAgd2luZG93LmxvY2F0aW9uLmhyZWYgPSBlbnZEZXRhaWxzLnVybFByZWZpeCArICcvZXh0ZXJuYWxfcmVxdWVzdHMnO1xuICB9Ki9cblxuICBmdW5jdGlvbiBmZXRjaE1vcmVTZXNzaW9ucygpIHtcbiAgICBpZiAoU3RvcmUuZ2V0Q3VycmVudFBhZ2UoKSA8PSBTdG9yZS5nZXRUb3RhbFBhZ2VDb3VudCgpKSB7XG4gICAgICBBY3Rpb25zLmZldGNoU2Vzc2lvbnMoU3RvcmUuZ2V0Q3VycmVudFBhZ2UoKSk7XG4gICAgfVxuICB9XG5cbiAgcmV0dXJuIHtcbiAgICBpbml0OiBpbml0XG4gIH1cblxufSkoKTtcblxubW9kdWxlLmV4cG9ydHMgPSBTZXNzaW9uSGFuZGxlcjtcbiIsInZhciBTZXNzaW9uQWN0aW9ucyA9IHJlcXVpcmUoXCIuL2FjdGlvbnNcIik7XG52YXIgQXBpID0gcmVxdWlyZSgnY29tbW9uX2FwaScpO1xuXG52YXIgU2Vzc2lvblN0b3JlID0gUmVmbHV4LmNyZWF0ZVN0b3JlKHtcblxuXHRpbml0OiBmdW5jdGlvbigpIHtcblx0ICAgIHRoaXMubGlzdGVuVG9NYW55KFNlc3Npb25BY3Rpb25zKTtcblxuXHQgICAgdGhpcy5zZXNzaW9ucyA9IFtdO1xuXHQgICAgdGhpcy5mZXRjaGluZyA9IGZhbHNlO1xuXHQgICAgdGhpcy5wZXJfcGFnZV9zZXNzaW9uX2NvdW50ID0gMTA7XG5cdCAgICB0aGlzLmN1cnJlbnRfcGFnZSA9IDE7XG5cdCAgICB0aGlzLnRvdGFsX3BhZ2VzID0gMDtcblx0fSxcblxuICBnZW5lcmF0ZUV4cG9ydFVybDogZnVuY3Rpb24oKXtcbiAgICB2YXIgcHJlZml4ID0gZW52RGV0YWlsc1sndXJsUHJlZml4J10gfHwgXCJcIjtcbiAgICByZXR1cm4gW3ByZWZpeCwgQXBpLkVORFBPSU5UUy5zZXNzaW9uX2V4cG9ydF0uam9pbihcIlwiKTtcbiAgfSxcblxuXHRvbkZldGNoU2Vzc2lvbnM6IGZ1bmN0aW9uIChwYWdlX25vLCBwZXJfcGFnZSkge1xuXG4gICAgICAgIGlmICh0aGlzLmdldEZldGNoU3RhdGUoKSA9PSBmYWxzZSkge1xuICAgICAgICAgIHRoaXMudXBkYXRlRmV0Y2hTdGF0ZSh0cnVlKTtcbiAgICAgICAgICB2YXIgcHJvbWlzZSA9IEFwaS5mZXRjaCh7XG4gICAgICAgICAgICB1cmw6IEFwaS5FTkRQT0lOVFMuc2Vzc2lvbnNfbGlzdCxcbiAgICAgICAgICAgIGRhdGE6IHtcbiAgICAgICAgICAgICAgcGFnZTogcGFnZV9ubyxcbiAgICAgICAgICAgICAgcGVyX3BhZ2U6IHBlcl9wYWdlIHx8IHRoaXMucGVyX3BhZ2Vfc2Vzc2lvbl9jb3VudFxuICAgICAgICAgICAgfVxuICAgICAgICAgIH0pO1xuXG4gICAgICAgICAgcHJvbWlzZS50aGVuKGZ1bmN0aW9uIChhcGlSZXNwb25zZSkge1xuXG4gICAgICAgICAgICB0aGlzLnVwZGF0ZUZldGNoU3RhdGUoZmFsc2UpO1xuICAgICAgICAgICAgdGhpcy5zZXRDdXJyZW50UGFnZSh0aGlzLmdldEN1cnJlbnRQYWdlKCkgKyAxKVxuICAgICAgICAgICAgdGhpcy5zZXRUb3RhbFBhZ2VDb3VudChNYXRoLmNlaWwoYXBpUmVzcG9uc2UuZGF0YS5zZXNzaW9ucy50b3RhbF9lbnRyaWVzIC8gdGhpcy5wZXJfcGFnZV9zZXNzaW9uX2NvdW50KSk7XG5cbiAgICAgICAgICAgIHRoaXMuc2Vzc2lvbnMgPSB0aGlzLnNlc3Npb25zLmNvbmNhdChhcGlSZXNwb25zZS5kYXRhLnNlc3Npb25zLml0ZW1zKTtcblxuICAgICAgICAgICAgdGhpcy50cmlnZ2VyKHtcbiAgICAgICAgICAgICAgdHlwZTogJ3Nlc3Npb25saXN0aW5nJyxcbiAgICAgICAgICAgICAgZGF0YToge1xuICAgICAgICAgICAgICAgIHNlc3Npb25zOiB0aGlzLnNlc3Npb25zLFxuICAgICAgICAgICAgICAgIHRvdGFsOiBhcGlSZXNwb25zZS5kYXRhLnNlc3Npb25zLnRvdGFsX2VudHJpZXMsXG4gICAgICAgICAgICAgICAgdG90YWxFeHRlcm5hbDogYXBpUmVzcG9uc2UuZGF0YS5leHRlcm5hbF9yZXF1ZXN0c19jb3VudCxcbiAgICAgICAgICAgICAgICB0b3RhbEludGVybmFsOiBhcGlSZXNwb25zZS5kYXRhLmludGVybmFsX21lZXRpbmdzX2NvdW50LFxuICAgICAgICAgICAgICAgIHRvdGFsQ29uc2VjOiBhcGlSZXNwb25zZS5kYXRhLmNvbnNlY3V0aXZlX21lZXRpbmdzX2NvdW50LFxuICAgICAgICAgICAgICB9XG4gICAgICAgICAgICB9KTtcbiAgICAgICAgICB9LmJpbmQodGhpcykpO1xuXG4gICAgICAgICAgcHJvbWlzZVtwcm9taXNlLmZhaWwgPyAnZmFpbCc6ICdjYXRjaCddKGZ1bmN0aW9uKGFwaVJlc3BvbnNlKXtcbiAgICAgICAgICAgIHRoaXMudXBkYXRlRmV0Y2hTdGF0ZShmYWxzZSk7XG4gICAgICAgICAgfS5iaW5kKHRoaXMpKTtcbiAgICAgICAgfVxuICAgIH0sXG5cbiAgICBnZXRGZXRjaFN0YXRlOiBmdW5jdGlvbigpe1xuICAgICAgcmV0dXJuIHRoaXMuZmV0Y2hpbmc7XG4gICAgfSxcbiAgICB1cGRhdGVGZXRjaFN0YXRlOiBmdW5jdGlvbihzdGF0ZSl7XG4gICAgICB0aGlzLmZldGNoaW5nID0gc3RhdGVcbiAgICB9LFxuICAgIGdldEN1cnJlbnRQYWdlOiBmdW5jdGlvbigpe1xuICAgICAgcmV0dXJuIHRoaXMuY3VycmVudF9wYWdlO1xuICAgIH0sXG4gICAgc2V0Q3VycmVudFBhZ2U6IGZ1bmN0aW9uKHBhZ2Vfbm8pe1xuICAgICAgdGhpcy5jdXJyZW50X3BhZ2UgPSBwYWdlX25vO1xuICAgIH0sXG4gICAgZ2V0VG90YWxQYWdlQ291bnQ6IGZ1bmN0aW9uKCkge1xuICAgICAgcmV0dXJuIHRoaXMudG90YWxfcGFnZXM7XG4gICAgfSxcbiAgICBzZXRUb3RhbFBhZ2VDb3VudDogZnVuY3Rpb24oY291bnQpIHtcbiAgICAgIHRoaXMudG90YWxfcGFnZXMgPSBjb3VudDtcbiAgICB9LFxuICAgIGdldFNlc3Npb25PYmo6IGZ1bmN0aW9uKHNlc3Npb25fdXVpZCl7XG4gICAgICByZXR1cm4gXy5maW5kKHRoaXMuc2Vzc2lvbnMsIGZ1bmN0aW9uKHNlc3Npb24pe1xuICAgICAgICByZXR1cm4gc2Vzc2lvbi51dWlkID09PSBzZXNzaW9uX3V1aWQ7XG4gICAgICB9KTtcbiAgICB9LFxuXG4gICAgb25GZXRjaFNlc3Npb25Ob21pbmF0aW9uczogZnVuY3Rpb24ocGFyYW1zKSB7XG4gICAgICBwYXJhbXMgPSBfLmV4dGVuZChwYXJhbXMsIHtwYWdlOiAxLCBwZXJfcGFnZTogNTAwfSlcbiAgICAgIGlmICh0eXBlb2Ygbm9taW5hdGlvbkluZm8gIT0gXCJ1bmRlZmluZWRcIiAmJiBub21pbmF0aW9uSW5mby5yZXF1ZXN0LnNlc3Npb24udXVpZCl7XG4gICAgICAgIHBhcmFtcyA9IF8uZXh0ZW5kKHBhcmFtcywge3Nlc3Npb25fdXVpZDogbm9taW5hdGlvbkluZm8ucmVxdWVzdC5zZXNzaW9uLnV1aWR9KVxuICAgICAgfVxuICAgICAgdmFyIHByb21pc2UgPSBBcGkuZmV0Y2goe1xuICAgICAgICB1cmw6IEFwaS5FTkRQT0lOVFMuc2Vzc2lvbl9ub21pbmF0aW9ucyxcbiAgICAgICAgZGF0YTogcGFyYW1zXG4gICAgICB9KTtcblxuICAgICAgcHJvbWlzZS50aGVuKGZ1bmN0aW9uKHJlc3BvbnNlKSB7XG4gICAgICAgIHJlc3BvbnNlLmRhdGEuc2Vzc2lvbl91dWlkID0gcGFyYW1zWydzZXNzaW9uX3V1aWQnXTtcbiAgICAgICAgdGhpcy50cmlnZ2VyKHt0eXBlOiAnc2Vzc2lvbk5vbWluYXRpb25zJywgZGF0YTogcmVzcG9uc2V9KTtcbiAgICAgIH0uYmluZCh0aGlzKSk7XG5cbiAgICAgIHByb21pc2VbcHJvbWlzZS5mYWlsID8gJ2ZhaWwnOiAnY2F0Y2gnXShmdW5jdGlvbihkYXRhKSB7XG4gICAgICAgIHZhciByZXNwb25zZSA9IGRhdGEucmVzcG9uc2VKU09OO1xuICAgICAgICB0aGlzLnRyaWdnZXIoeyBhY3Rpb246ICdvbkNyZWF0ZVNlc3Npb25GYWlsZWQnLCBwYXlsb2FkOiByZXNwb25zZSB9KTtcbiAgICAgIH0uYmluZCh0aGlzKSk7XG4gICAgfVxufSk7XG5cbnZhciBDaGVja2luU3RvcmUgPSBSZWZsdXguY3JlYXRlU3RvcmUoe1xuICBpbml0OiBmdW5jdGlvbigpe1xuICAgIHRoaXMubGlzdGVuVG9NYW55KFNlc3Npb25BY3Rpb25zKTtcbiAgICB0aGlzLnBlclBhZ2UgPSAxMDtcbiAgICB0aGlzLnRvdGFsUGFnZXM7XG4gICAgdGhpcy5jdXJyZW50UGFnZSA9IDE7XG4gICAgdGhpcy5pc0ZldGNoaW5nID0gZmFsc2U7XG4gICAgdGhpcy5zZXNzaW9ucyA9IFtdO1xuICB9LFxuXG4gIG9uRmV0Y2hTZXNzaW9uQ2hlY2tpbkxpc3Q6IGZ1bmN0aW9uKHBhZ2VObyl7XG4gICAgdmFyIGZldGNoU3RhdGUgPSB0aGlzLmdldEZldGNoU3RhdGUoKTtcblxuICAgIGlmKGZldGNoU3RhdGUgPT09IGZhbHNlKXtcbiAgICAgIHRoaXMuc2V0RmV0Y2hTdGF0ZSh0cnVlKTtcbiAgICAgIHZhciBwcm9taXNlID0gQXBpLmZldGNoKHtcbiAgICAgICAgdXJsOiBBcGkuRU5EUE9JTlRTLnNlc3Npb25fY2hlY2tpbl9saXN0LFxuICAgICAgICBkYXRhOiB7XG4gICAgICAgICAgcGFnZTogcGFnZU5vLFxuICAgICAgICAgIHBlcl9wYWdlOiB0aGlzLnBlclBhZ2VcbiAgICAgICAgfVxuICAgICAgfSlcbiAgICAgIHByb21pc2UuZG9uZShmdW5jdGlvbihhcGlSZXNwb25zZSl7XG4gICAgICAgIHRoaXMuc2V0RGF0YShhcGlSZXNwb25zZS5kYXRhLnNlc3Npb25zKTtcbiAgICAgICAgdGhpcy5zZXRUb3RhbFBhZ2VzKGFwaVJlc3BvbnNlLmRhdGEudG90YWxfZW50cmllcyk7XG4gICAgICAgIHRoaXMuc2V0Q3VycmVudFBhZ2UodGhpcy5nZXRDdXJyZW50UGFnZSgpICsgMSk7XG5cbiAgICAgICAgdGhpcy50cmlnZ2VyKHtcbiAgICAgICAgICBhY3Rpb246ICdvblNlc3Npb25DaGVja2luTGlzdFN1Y2Nlc3MnLFxuICAgICAgICAgIHBheWxvYWQ6IHtcbiAgICAgICAgICAgIGRhdGE6IHRoaXMuZ2V0RGF0YSgpLFxuICAgICAgICAgICAgdG90YWxJbnRlcm5hbDogYXBpUmVzcG9uc2UuZGF0YS5pbnRlcm5hbF9yZXF1ZXN0X2NvdW50IHx8IDAsXG4gICAgICAgICAgICB0b3RhbFNlc3Npb25zOiBhcGlSZXNwb25zZS5kYXRhLnNlc3Npb25zX2NvdW50IHx8IDAsXG4gICAgICAgICAgICB0b3RhbEV4dGVybmFsOiBhcGlSZXNwb25zZS5kYXRhLmV4dGVybmFsX3JlcXVlc3RzX2NvdW50IHx8IDAsXG4gICAgICAgICAgICB0b3RhbENvbnNlY01lZXRpbmc6IGFwaVJlc3BvbnNlLmRhdGEuY29uc2VjdXRpdmVfbWVldGluZ3NfY291bnQgfHwgMFxuICAgICAgICAgIH1cbiAgICAgICAgfSk7XG4gICAgICAgIHRoaXMuc2V0RmV0Y2hTdGF0ZShmYWxzZSk7XG4gICAgICB9LmJpbmQodGhpcykpO1xuICAgIH1cbiAgfSxcblxuICBvbkNoZWNraW5TZXNzaW9uOiBmdW5jdGlvbihzZXNzaW9uVXVpZCwgc3RhdHVzKXtcbiAgICB2YXIgcHJvbWlzZSA9IEFwaS51cGRhdGUoe1xuICAgICAgdXJsOiBBcGkuRU5EUE9JTlRTLnVwZGF0ZV9jaGVja2luX3N0YXR1cyxcbiAgICAgIHR5cGU6IFwicHV0XCIsXG4gICAgICBkYXRhOiB7XG4gICAgICAgIHVzZXJfdXVpZDogJycsXG4gICAgICAgIG9iamVjdF90eXBlOiBcIlNlc3Npb25cIixcbiAgICAgICAgbWVldGluZ191dWlkOiBzZXNzaW9uVXVpZCxcbiAgICAgICAgc3RhdHVzOiBzdGF0dXNcbiAgICAgIH1cbiAgICB9KTtcbiAgICBwcm9taXNlLmRvbmUoZnVuY3Rpb24oYXBpUmVzcG9uc2UpIHt9LmJpbmQodGhpcykpO1xuICB9LFxuXG4gIG9uQ2hlY2tpbkF0dGVuZGVlOiBmdW5jdGlvbihzZXNzaW9uVXVpZCwgYXR0ZW5kZWVVdWlkLCBzdGF0dXMsIGF0dGVuZGVlVHlwZSl7XG4gICAgdmFyIHByb21pc2UgPSBBcGkudXBkYXRlKHtcbiAgICAgIHVybDogQXBpLkVORFBPSU5UUy51cGRhdGVfY2hlY2tpbl9zdGF0dXMsXG4gICAgICB0eXBlOiBcInB1dFwiLFxuICAgICAgZGF0YToge1xuICAgICAgICBvYmplY3RfdHlwZTogXCJTZXNzaW9uXCIsXG4gICAgICAgIHVzZXJfdXVpZDogYXR0ZW5kZWVVdWlkLFxuICAgICAgICBtZWV0aW5nX3V1aWQ6IHNlc3Npb25VdWlkLFxuICAgICAgICBzdGF0dXM6IHN0YXR1c1xuICAgICAgfVxuICAgIH0pO1xuXG4gICAgcHJvbWlzZS5kb25lKGZ1bmN0aW9uKGFwaVJlc3BvbnNlKSB7fS5iaW5kKHRoaXMpKTtcbiAgfSxcblxuICBzZXREYXRhOiBmdW5jdGlvbihzZXNzaW9ucyl7XG4gICAgdGhpcy5zZXNzaW9ucyA9IHRoaXMuc2Vzc2lvbnMuY29uY2F0KHNlc3Npb25zKTtcbiAgfSxcblxuICBnZXREYXRhOiBmdW5jdGlvbigpe1xuICAgIHJldHVybiB0aGlzLnNlc3Npb25zO1xuICB9LFxuXG4gIHNldFRvdGFsUGFnZXM6IGZ1bmN0aW9uKHRvdGFsRW50cmllcyl7XG4gICAgdGhpcy50b3RhbFBhZ2VzID0gdG90YWxFbnRyaWVzICUgdGhpcy5wZXJQYWdlID09IDAgPyAodG90YWxFbnRyaWVzLyB0aGlzLnBlclBhZ2UpIDogTWF0aC5mbG9vcigodG90YWxFbnRyaWVzIC8gdGhpcy5wZXJQYWdlKSkgKyAxO1xuICB9LFxuXG4gIHNldEN1cnJlbnRQYWdlOiBmdW5jdGlvbihwYWdlKXtcbiAgICB0aGlzLmN1cnJlbnRQYWdlID0gcGFnZTtcbiAgfSxcblxuICBnZXRDdXJyZW50UGFnZTogZnVuY3Rpb24oKXtcbiAgICByZXR1cm4gdGhpcy5jdXJyZW50UGFnZTtcbiAgfSxcblxuICBzZXRGZXRjaFN0YXRlOiBmdW5jdGlvbihzdGF0ZSl7XG4gICAgdGhpcy5pc0ZldGNoaW5nID0gc3RhdGU7XG4gIH0sXG5cbiAgZ2V0VG90YWxQYWdlczogZnVuY3Rpb24oKXtcbiAgICByZXR1cm4gdGhpcy50b3RhbFBhZ2VzO1xuICB9LFxuXG4gIGdldEZldGNoU3RhdGU6IGZ1bmN0aW9uKCl7XG4gICAgcmV0dXJuIHRoaXMuaXNGZXRjaGluZztcbiAgfVxufSlcblxubW9kdWxlLmV4cG9ydHMgPSB7XG4gIFNlc3Npb25TdG9yZTogU2Vzc2lvblN0b3JlLFxuICBDaGVja2luU3RvcmU6IENoZWNraW5TdG9yZVxufSIsIi8qIGVzbGludC1kaXNhYmxlICovXG5cbi8qIGdsb2JhbCBpMThuLCAkLCBfLCBGb3JtRGF0YSwgZW52RGV0YWlscyAqL1xuLy8gTm90ZTogQWRkIHRoZSB1cmxzIGluIHNvcnRlZCBvcmRlclxudmFyIEFwaSA9IHtcbiAgRU5EUE9JTlRTOiB7XG4gICAgYWNjZXB0X21lZXRpbmc6ICcvbWVldGluZ19yZXF1ZXN0L3t1dWlkfS9hY2NlcHRfbWVldGluZycsXG4gICAgYWN0aXZhdGVfZXZlbnQ6ICcvZXZlbnQvYWN0aXZhdGUnLFxuICAgIGFjdGl2YXRlX3Jvb206ICcvcm9vbS97e3V1aWR9fS9hY3RpdmUnLFxuICAgIGFjdGl2YXRlX3VzZXI6ICcvdXNlcnMvVVVJRC9hY3RpdmUnLFxuICAgIGFjdGl2aXR5X2RldGFpbHM6ICcvYWN0aXZpdGllcy97dXVpZH0nLFxuICAgIGFkYXB0ZXJzOiAnL2FkYXB0ZXJfdWkvaW50ZWdyYXRpb25fYWRhcHRlcnMnLFxuICAgIGFkZF9hdHRlbmRlZV90b19tZWV0aW5nOiAnL21lZXRpbmdzL2FkZF9hdHRlbmRlZXMnLFxuICAgIGFkZF9uZXdfbG9jYXRpb246ICcvbG9jYXRpb24ve2V2ZW50X3V1aWR9JyxcbiAgICBhZGRfc3VwcG9ydGVkX2FwaTogJy9hZGFwdGVyX3VpL3N1cHBvcnRlZF9hcGlzL21hcF90b19pbnRlZ3JhdGlvbicsXG4gICAgYWxlcnRfZGV0YWlsc19mZXRjaDogJy9hbGVydHMvbWVldGluZ19tZXRhJyxcbiAgICBhbGVydF9mZXRjaDogJy9hbGVydHMnLFxuICAgIGFsbF9tZWV0aW5nX3R5cGVzOiAnL21lZXRpbmdfdHlwZXMvaW5kZXgnLFxuICAgIGFwZXhfam5saXN0YWdlbmRhOiAnL2FwZXgvSk5CcmllZmluZ3MnLFxuICAgIGFwZXhfam5tZWV0aW5nczogJy9hcGV4L0pOTWVldGluZ3MnLFxuICAgIGFwaV9tYXBfb3JfYWRkX3VzZXI6IHsgdXJsOiAnL2FwaS92MS91c2Vycy9ib29rX21lZXRpbmdfY3JlYXRlJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgYXBpX3JlZ2lzdGVyX3VzZXI6IHsgdXJsOiAnL2FwaS92MS91c2VycycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIGFwaV91cGRhdGVfdXNlcl9ldmVudF9zZXR0aW5nczogeyB1cmw6ICcvYXBpL3YxL3VzZXIve3t1dWlkfX0vdXBkYXRlX3NldHRpbmdzJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJywgY3VzdG9tX3RpdGxlOiAnQ2Fubm90IFVwZGF0ZScgfSB9LFxuICAgIGFwaV91cGRhdGVfdXNlcjogeyB1cmw6ICcvYXBpL3YxL3VzZXJzL3t7dXVpZH19JywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJywgY3VzdG9tX3RpdGxlOiAnV2XigJlyZSBTb3JyeSEnIH0gfSxcbiAgICBhcHBvaW50bWVudF9maWx0ZXJfb3B0aW9uczogJy9hcHBvaW50bWVudF9maWx0ZXJfb3B0aW9ucycsXG4gICAgYXBwcm92ZV9leHRlcm5hbF9yZXF1ZXN0OiAnL2V4dGVybmFsX3JlcXVlc3Qve3V1aWR9L2FwcHJvdmUnLFxuICAgIGFwcHJvdmVfbWVldGluZzogJy9tZWV0aW5nX3JlcXVlc3QvYXBwcm92ZV9tZWV0aW5ncycsXG4gICAgYXBwcm92ZWRfbWVldGluZ19jb3VudDogeyB1cmw6ICcvYXBwcm92ZWRfbWVldGluZ19jb3VudCcsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdzdW1tdXJ5RXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgYXV0b19yZW1pbmRlcl9zZXR0aW5nOiAnL2F1dG9fcmVtaW5kZXJfc2V0dGluZycsXG4gICAgYXZhaWxhYmlsaXR5X2ZldGNoX2ViYzogJy9jb25maWd1cmUvaW5pdGlhbF9hdmFpbGFiaWxpdGllcycsXG4gICAgYXZhaWxhYmlsaXR5X2ZldGNoOiAnL21lZXRpbmdfdHlwZS9hdmFpbGFiaWxpdGllcycsXG4gICAgYXZhaWxhYmlsaXR5X3VwZGF0ZTogJy9jb25maWd1cmUvdXBkYXRlX2luaXRpYWxfYXZhaWxhYmlsaXRpZXMnLFxuICAgIGJsb2NrX3VwZGF0ZTogJy9jYWxlbmRhci9lZGl0X2Jsb2NrJyxcbiAgICBicmllZmluZ19jZW50cmVfbG9uZ19kYXk6ICcvYmNzL2dldF9sb25nX2RheScsXG4gICAgYnJpZWZpbmdfY2VudHJlOiAnL2JjJyxcbiAgICBicmllZmluZ19jdXN0b21fZm9ybXM6ICcvbWVldGluZ190eXBlL2JyaWVmaW5nX2N1c3RvbV9mb3JtcycsXG4gICAgYnJpZWZpbmdfZGV0YWlsczogJy9icmllZmluZy97YnJpZWZpbmdfdXVpZH0nLFxuICAgIGJ1bGtfYXBwcm92ZV9tYXBwaW5nczogJy9hcHBvaW50bWVudHMvYXBwcm92ZScsXG4gICAgYnVsa19hcHByb3ZlX21lZXRpbmdzOiAnL21lZXRpbmdfcmVxdWVzdC9hcHByb3ZlX21lZXRpbmdzJyxcbiAgICBidWxrX2NhbmNlbF9tYXBwaW5nczogJy9hcHBvaW50bWVudHMvY2FuY2VsJyxcbiAgICBidWxrX2NhbmNlbF9tZWV0aW5nczogJy9tZWV0aW5nX3JlcXVlc3QvY2FuY2VsX21lZXRpbmdzJyxcbiAgICBidWxrX2VuZG9yc2VfdXNlcnM6IHsgdXJsOiAnL2FwaS92MS91c2Vycy9zZXRfZW5kb3JzZWQnLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInIH0gfSxcbiAgICBidWxrX3JlaW52aXRlX3VzZXJzOiAnL21lZXRpbmdfcmVxdWVzdC9idWxrX3JlaW52aXRlJyxcbiAgICBidWxrX3NldF9tbV9vbmx5X2ZsYWc6ICcvYXBpL3YxL3VzZXJzL3NldF9tbV9vbmx5X2ZsYWcnLFxuICAgIGJ1bGtfc3luY19leHRfY2FsX2ZsYWc6ICcvYXBpL3YxL3VzZXJzL3VwZGF0ZV9jaXNfZGV0YWlscycsXG4gICAgYnVsa19yZWxheF9zZmRjX29ubHlfcmVxdWVzdF9tZWV0aW5nOiAnL2FwaS92MS91c2Vycy9zZXRfcmVsYXhfc2ZkY19vbmx5X3JlcXVlc3RfbWVldGluZycsXG4gICAgYnVsa19zaG93X2FzX2V4dGVybmFsX2F0dGVuZGVlOiB7IHVybDogJy9hcGkvdjEvdXNlcnMvc2V0X3Nob3dfYXNfZXh0JywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgY2FsZW5kYXJfYXZhaWxhYmlsaXR5OiAnL21lZXRpbmdfcmVxdWVzdC9jYWxlbmRhcicsXG4gICAgY2FsZW5kYXJfdXNlcl9hdmFpbGFiaWxpdHk6ICcvY2FsZW5kYXIvdXNlcnMnLFxuICAgIGNhbl9hdHRlbmRfc2Vzc2lvbjogJy9jYW5fYXR0ZW5kX3Nlc3Npb24nLFxuICAgIGNhbmNlbF9leHRlcm5hbF9yZXF1ZXN0OiB7IHVybDogJy9leHRlcm5hbF9yZXF1ZXN0L3t1dWlkfS9jYW5jZWwnLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInIH0gfSxcbiAgICBjYW5jZWxfbWVldGluZzogJy9tZWV0aW5nX3JlcXVlc3Qve21lZXRpbmdfdXVpZH0vY2FuY2VsX21lZXRpbmcnLFxuICAgIGNoZWNrX2F0dGVuZGVlX2F2YWlsYWJpbGl0eTogeyB1cmw6ICcvYXBpL3YxL3VzZXJzL3t1dWlkfS9hdmFpbGFiaWxpdHknIH0sXG4gICAgY2hlY2tpbl9jb25zZWN1dGl2ZV9tZWV0aW5nc19saXN0OiAnL2NoZWNraW5fY29uc2VjdXRpdmVfbWVldGluZ3MnLFxuICAgIGNoZWNraW5fbGlzdF9maWx0ZXJzOiAnL2NoZWNraW4vbWVldGluZ19maWx0ZXJzJyxcbiAgICBjaGVja2luX21lZXRpbmdzX2xpc3Q6ICcvY2hlY2tpbl9tZWV0aW5ncycsXG4gICAgY2hlY2tpbl9tZWV0aW5nczogJy9jaGVja2luX2xpc3QnLFxuICAgIGNoZWNraW5fc2Vzc2lvbnNfbGlzdDogJy9jaGVja2luX3Nlc3Npb25zJyxcbiAgICBjaGVja2luX3VzZXJzOiAnL2NoZWNraW4vdG9nZ2xlX2NoZWNraW4nLFxuICAgIGNpc19zZXJ2aWNlOiAnL2Npc19zZXJ2aWNlJyxcbiAgICBjb21wYW5pZXNfbGlzdDogJy9jb21wYW5pZXMvc2VhcmNoJyxcbiAgICBjb21wYW55X2ZldGNoOiAnL2NvbXBhbnknLFxuICAgIGNvbmNpZXJnZV9zZXJ2aWNlc19jcmVhdGU6ICcvY29uY2llcmdlX3NlcnZpY2VzJyxcbiAgICBjb25jaWVyZ2Vfc2VydmljZXNfdXBkYXRlOiAnL2NvbmNpZXJnZV9zZXJ2aWNlcy97dXVpZH0nLFxuICAgIGNvbmZpZ19hdXRvX3JlbWluZDogJy9jb25maWd1cmUvYXV0b19yZW1pbmQnLFxuICAgIGNvbmZpZ19oaXN0b3J5OiB7IHVybDogJy9jb25maWd1cmF0aW9uL2hpc3RvcnlfbGlzdCcsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIGNvbmZpZ19pbnRlZ3JhdGlvbl91cGRhdGU6ICcvY29uZmlndXJlL2ludGVncmF0aW9uX3VwZGF0ZScsXG4gICAgY29uZmlnX2ludGVncmF0aW9uOiAnL2NvbmZpZ3VyZS9pbnRlZ3JhdGlvbicsXG4gICAgY29uZmlnX25vdGlmaWNhdGlvbl91cGRhdGU6ICcvY29uZmlndXJlL25vdGlmaWNhdGlvbl91cGRhdGUnLFxuICAgIGNvbmZpZ19ub3RpZmljYXRpb246ICcvY29uZmlndXJlL25vdGlmaWNhdGlvbicsXG4gICAgY29uZmlnX3RvcGljX3VwZGF0ZTogJy9jb25maWcvdXBkYXRlX3RvcGljJyxcbiAgICBjb25maWdfdG9waWM6ICcvY29uZmlndXJlL3RvcGljJyxcbiAgICBjb25zZWN1dGl2ZV9saXN0X3BhZ2U6ICcvY29uc2VjdXRpdmVfbWVldGluZ3MvbGlzdCcsXG4gICAgY29uc2VjdXRpdmVfbWVldGluZ19saXN0OiB7IHVybDogJy9jb25zZWN1dGl2ZV9tZWV0aW5ncycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIGNvbnNlY3V0aXZlX21lZXRpbmdzX2RldGFpbHM6IHsgdXJsOiAnL2NvbnNlY3V0aXZlX21lZXRpbmdzL3t1dWlkfS9lZGl0X2NvbnNlY3V0aXZlX21lZXRpbmcnLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInIH0gfSxcbiAgICBjb25zZWN1dGl2ZV9tZWV0aW5nc19lZGl0X3BhdGg6ICcvY29uc2VjdXRpdmVfbWVldGluZ3Mve3V1aWR9L2VkaXQnLFxuICAgIGNvbnNlY3V0aXZlX21lZXRpbmdzX3ZpZXdfcGF0aDogJy9jb25zZWN1dGl2ZV9tZWV0aW5ncy97dXVpZH0vdmlldycsXG4gICAgY29weV9jYWxlbmRhcl9zZXR0aW5nczogJy9jb25maWd1cmUvY29weV9jYWxlbmRhcicsXG4gICAgY29weV9mb3JtX3NldHRpbmdzOiAnL2NvbmZpZ3VyZS9jb3B5X2Zvcm0nLFxuICAgIGNvcHlfbWVldGluZ19zZXR0aW5nczogJy9jb25maWd1cmUvY29weV9zZXR0aW5ncycsXG4gICAgY29weV9ub3RpZmljYXRpb25fc2V0dGluZ3M6ICcvY29uZmlndXJlL2NvcHlfbm90aWZpY2F0aW9uX3RlbXBsYXRlcycsXG4gICAgY3JlYXRlX2NvbnNlY3V0aXZlX21lZXRpbmdzOiAnL2NvbnNlY3V0aXZlX21lZXRpbmdzJyxcbiAgICBjcmVhdGVfZXh0ZXJuYWxfcmVxdWVzdDogJy9leHRlcm5hbF9yZXF1ZXN0L2NyZWF0ZScsXG4gICAgY3JlYXRlX2dyb3VwX25vbWluYXRpb246ICcvZ3JvdXBfbm9taW5hdGlvbi9jcmVhdGUnLFxuICAgIGNyZWF0ZV9pbnRlZ3JhdGlvbl91c2VyOiAodXVpZCkgPT4gYC9hZGFwdGVyX3VpL2ludGVncmF0aW9uLyR7dXVpZH0vdXNlcmAsXG4gICAgaW50ZWdyYXRpb25fdXNlcjogJy9pbnRlZ3JhdGlvbnMvaW50ZWdyYXRpb25fdXNlcicsXG4gICAgY3JlYXRlX21hcHBpbmc6ICcvY29udGFpbmVyX21hcHBpbmcve2FjdGl2aXR5X3V1aWR9L2NyZWF0ZScsXG4gICAgY3JlYXRlX29yX3VwZGF0ZV90cmFjazogeyB1cmw6ICcvdHJhY2tzJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgY3JlYXRlX3NlbGZfbm9taW5hdGlvbjogeyB1cmw6ICcvc2Vzc2lvbi97e3Nlc3Npb25VdWlkfX0vY3JlYXRlX3NlbGZfbm9taW5hdGlvbicsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIGNyZWF0ZV9zZXNzaW9uOiAnL3Nlc3Npb24vY3JlYXRlJyxcbiAgICBjcmVhdGVfdGFnX2Nsb3VkczogJy90YWdfY2xvdWQnLFxuICAgIGN1c3RvbV9maWVsZF9vcHRpb25zOiAnL2N1c3RvbV9mb3JtL3tVVUlEfS9zZWFyY2gnLFxuICAgIGN1c3RvbV9mb3JtX2RldGFpbHM6ICcvY3VzdG9tX2Zvcm1fZGV0YWlscycsXG4gICAgY3VzdG9tZXJfYXZhaWxhYmlsaXR5OiAnL2NhbGVuZGFyL2NvbXBhbmllcycsXG4gICAgY3VzdG9tZXJfY2FsZW5kYXJfZXhwb3J0OiAnL2NhbGVuZGFyL2JyaWVmaW5nc19jZW50ZXIvZXhwb3J0JyxcbiAgICBjdXN0b21fbGFiZWxzOiB7dXJsIDogJy9jdXN0b21fbGFiZWxzX2NvbmZpZ3VyYXRpb25zJywgZXJyb3JDb25maWcgOiB7aGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJ319LFxuICAgIGRlY2xpbmVfbWVldGluZzogJy9tZWV0aW5nX3JlcXVlc3Qve3V1aWR9L2RlY2xpbmVfbWVldGluZycsXG4gICAgZGVmYXVsdF9tZWV0aW5nX2xvY2F0aW9uX2VudGl0aWVzOiAnL2V2ZW50L3NldF9kZWZhdWx0X21lZXRpbmdfbG9jYXRpb24nLFxuICAgIGRlbGV0ZV9tYXBwaW5nOiAnL2NvbnRhaW5lcl9tYXBwaW5nL3t7dXVpZH19L2RlbGV0ZScsXG4gICAgZGVsZXRlX2xvY2F0aW9uX3ByZWZlcmVuY2U6IHt1cmw6ICcvbWVldGluZ19yZXF1ZXN0L3t7dXVpZH19L2RlbGV0ZV9sb2NfcHJlZl9wcm9wb3NhbCcsIGVycm9yQ29uZmlnOiB7aGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJ30gfSxcbiAgICBkZW1hbmRfcmVwb3J0X2V4cG9ydDogJy9hcGkvdjEvbWVldGluZ3Mvb25kZW1hbmQnLFxuICAgIGRlbWFuZF9yZXBvcnRzOiAnL3JlcG9ydHMvZGVtYW5kX3JlcG9ydCcsXG4gICAgZGV0YWlsZWRfY3VzdG9tX2xhYmVsczoge3VybCA6ICcvZGV0YWlsZWRfY3VzdG9tX2xhYmVsc19jb25maWd1cmF0aW9ucycsIGVycm9yQ29uZmlnIDoge2hhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcid9fSxcbiAgICBkaXNhYmxlX3NhdmVkX3JlcG9ydDogJy91c2VyX3RlbXBsYXRlL2Rpc2FibGUve3t1dWlkfX0nLFxuICAgIGRpc21pc3NfYWxlcnQ6ICcvYWxlcnRzL2Rpc21pc3MnLFxuICAgIGRpc21pc3Nfbm90aWZpY2F0aW9uOiAnL25vdGlmaWNhdGlvbnMvZGlzbWlzcycsXG4gICAgZG9tYWluX3ZhbGlkYXRpb246ICcvZG9tYWlucy92YWxpZGF0ZScsXG4gICAgZG9tYWluc192YWxpZDogJy9kb21haW5zL3ZhbGlkJyxcbiAgICBkb3VibGVfYm9va2VkX3Jlc291cmNlczogJy9tZWV0aW5nX3JlcXVlc3QvZG91YmxlX2Jvb2tlZF9yZXNvdXJjZXMnLFxuICAgIGRvd25sb2FkX2FnZW5kYV9pdGVtX3RlbXBsYXRlX3VybDogJy9tZWV0aW5nX3JlcXVlc3QvY3N2X3RlbXBsYXRlJyxcbiAgICB1c2VyX3RvcGljX21hcHBpbmdfdGVtcGxhdGVfdXJsOiAnL2FwaS92MS91c2Vycy91c2VyX3RvcGljX21hcHBpbmcvY3N2X3RlbXBsYXRlJyxcbiAgICBlZGl0X3RyYWNrOiAnL3RyYWNrcy97dXVpZH0vZWRpdCcsXG4gICAgZW5hYmxlX2RvdWJsZV9ib29rX3VzZXJzOiB7IHVybDogJy9hcGkvdjEvdXNlcnMvZW5hYmxlX2RvdWJsZV9ib29raW5nJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgZXZlbnRfYWNjZXNzX3NldHRpbmdzOiAnL2V2ZW50L3JvbGVzX2V2ZW50X3Zpc2liaWxpdHknLFxuICAgIGV2ZW50X2NvbmZpZ19leHBvcnQ6ICcvY29uZmlndXJhdGlvbi9leHBvcnQnLFxuICAgIGV2ZW50X2NvbmZpZ19mb3JfdXNlcl9jYWxlbmRhcjogJy91c2VyX2NhbGVuZGFyL2NvbmZpZ3VyYXRpb25zJyxcbiAgICBldmVudF9jb25maWdfaW1wb3J0OiB7IHVybDogICcvY29uZmlndXJhdGlvbi9pbXBvcnQnLCBlcnJvckNvbmZpZzoge2hhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcid9IH0sXG4gICAgZXZlbnRfY29uZmlnOiAnL2V2ZW50L2NvbmZpZ3VyYXRpb25zJyxcbiAgICBldmVudF9jb25maWd1cmF0aW9uczogJy9ldmVudC97ZXZlbnRfdXVpZH0vY29uZmlndXJhdGlvbnMnLFxuICAgIGV2ZW50X2RldGFpbHM6ICcvZXZlbnRfaW5mbycsXG4gICAgZXZlbnRfZWJjX2NvbmZpZ3VyYXRpb25zOiAnL2V2ZW50L2ViY19jb25maWd1cmF0aW9ucycsXG4gICAgZXZlbnRfaG9tZTogJ2V2ZW50L2hvbWUnLFxuICAgIGV2ZW50X25ldzogJy9ldmVudC9uZXcnLFxuICAgIGV2ZW50X3Jvb21fY2FsX3BhdGg6ICdjYWxlbmRhcicsXG4gICAgZXZlbnRfdXNlcl9jYWxfcGF0aDogJ3VzZXJfY2FsZW5kYXInLFxuICAgIGV2ZW50X3VzZXJfZmlsdGVyczogJy91c2Vycy9maWx0ZXJfb3B0aW9ucycsXG4gICAgZXZlbnRzX2luZm86ICcvZXZlbnRzJyxcbiAgICBldmVudHM6ICcvZXZlbnRzJyxcbiAgICBleHBlcnRfdXNlcnM6ICcvbWFwcGluZy9leHBlcnRzJyxcbiAgICBleHBvcnRfbWVldGluZ19jaGVja2luOiAnL3JlcG9ydHMvbWVldGluZ3NfY2hlY2tpbi9leHBvcnQueGxzeCcsXG4gICAgZXhwb3J0X3JldmlldzogJy9yZXZpZXdhYmxlL2V4cG9ydC5jc3YnLFxuICAgIGV4cG9ydF9zdW1tYXJ5X3JlcG9ydDogJy9ndWlkZWRfdG91ci9zdXJ2ZXlzJyxcbiAgICBleHBvcnRfc3VydmV5czogJy9zdXJ2ZXkve1VVSUR9L2V4cG9ydF9zdXJ2ZXlzJyxcbiAgICBleHRfZW5hYmxlZF9mZXRjaF9mb3JtX3NldHRpbmdzOiAnL2V4dGVybmFsX3dpZGdldF9hY3Rpdml0aWVzJyxcbiAgICBleHRlcm5hbF9hdHRlbmRlZXM6ICcvdXNlcnMvZXh0ZXJuYWwnLFxuICAgIGV4dGVybmFsX21lZXRpbmdzX2xpc3RfZmlsdGVyczogJy9leHRlcm5hbF9yZXF1ZXN0cy9maWx0ZXJzJyxcbiAgICBleHRlcm5hbF9yZXF1ZXN0X2RhdGVzOiAnL2V2ZW50X2RhdGVzJyxcbiAgICBleHRlcm5hbF9yZXF1ZXN0X2V4cG9ydDogJy9leHRlcm5hbF9yZXF1ZXN0cy9leHBvcnQnLFxuICAgIGV4dGVybmFsX3JlcXVlc3RzOiAnL2V4dGVybmFsX3JlcXVlc3RzJyxcbiAgICBleHRlcm5hbF93aWRnZXRfc2Vzc2lvbnM6ICcvZXh0ZXJuYWxfcmVxdWVzdC9ub21pbmF0aW9uL3Nlc3Npb25zJyxcbiAgICBleHRlcm5hbF93aWRnZXRfc2lnbnVwX3Nlc3Npb246ICcvc2Vzc2lvbi97dXVpZH0vY3JlYXRlX2V4dGVybmFsX3NlbGZfbm9taW5hdGlvbicsXG4gICAgZXh0ZXJuYWxfd2lkZ2V0X3RvcGljczogJy9leHRlcm5hbF93aWRnZXQvdHJhY2tzL3t1dWlkfS90b3BpY3MnLFxuICAgIGV4dGVybmFsX3dpZGdldF90cmFja3M6ICcvZXh0ZXJuYWxfd2lkZ2V0L3RyYWNrcycsXG4gICAgZmFjaWxpdGllc19saXN0OiAnL2ZhY2lsaXRpZXMnLFxuICAgIGZlYXR1cmVfZW5hYmxlX2ViYzogJy9mZWF0dXJlX3RvZ2dsZS9lbmFibGVfZWJjJyxcbiAgICBmZXRjaF9hY3RpdmVfZXZlbnRzOiAnL2FjdGl2ZV9ldmVudHMnLFxuICAgIGZldGNoX2FjdGl2aXRpZXM6ICcvdXNlcl9tZWV0aW5nX3R5cGVzL2xpc3QnLFxuICAgIGZldGNoX2FjdGl2aXR5X2xpc3Q6ICcvYWN0aXZpdGllcycsXG4gICAgZmV0Y2hfYWN0aXZpdHlfbWFuYWdlcjogeyB1cmw6ICcvdXNlcl9zZXR0aW5ncy97e3V1aWR9fS9hY3Rpdml0eScsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIGZldGNoX2FjdGl2aXR5X3NldHRpbmdzOiAnL2NvbmZpZ3VyZS9hY3Rpdml0eV9zZXR0aW5ncycsXG4gICAgZmV0Y2hfYW5hbHl0aWNzX2NvbmZpZ3M6ICcvYW5hbHl0aWNzX2Rhc2hib2FyZC9jb25maWcnLFxuICAgIGZldGNoX2FyY2hpdmVkX2V2ZW50X21lZXRpbmdfYW5hbHl0aWNzOiAnL2FyY2hpdmVkX2V2ZW50cy9hbmFseXRpY3MnLFxuICAgIGZldGNoX2FyY2hpdmVkX2V2ZW50c19saXN0OiAnL2V2ZW50X2xpc3RfYnlfdHlwZS9hcmNoaXZlZCcsXG4gICAgZmV0Y2hfYXJjaGl2ZWRfcmVwb3J0czogJy9hcmNoaXZlZF9ldmVudHMvYWxsX3JlcG9ydHMnLFxuICAgIGZldGNoX2F2YWlsYWJsZV9tZWV0aW5nX3R5cGVzOiAnL2ZldGNoX2F2YWlsYWJsZV9tZWV0aW5nX3R5cGVzJyxcbiAgICBmZXRjaF9ib29raW5nX2FuYWx5dGljczogJy9hbmFseXRpY3MvYm9va2luZycsXG4gICAgZmV0Y2hfYnJpZWZpbmdfd29ya2Zsb3c6ICcvY29uZmlndXJlL2JyaWVmaW5nX3NldHRpbmdzJyxcbiAgICBmZXRjaF9jYWxlbmRhcl9zZXR0aW5nczogJy9jb25maWd1cmUvY2FsZW5kYXJfc2V0dGluZ3MnLFxuICAgIGZldGNoX2NoYW5nYWJsZV9tZWV0aW5nX3R5cGVzOiAnL2ZldGNoX3RyYW5zZmVyX21lZXRpbmdfdHlwZXMve21lZXRpbmdfdXVpZH0nLFxuICAgIGZldGNoX2NvbmNpZXJnZV9mb3JtOiAnL2NvbmNpZXJnZV9zZXJ2aWNlcy9jdXN0b21fZm9ybXMnLFxuICAgIGZldGNoX2NvbmNpZXJnZV9ub3RpZmljYXRpb25fc2V0dGluZ3M6ICcvY29uY2llcmdlX3NlcnZpY2VzL25vdGlmaWNhdGlvbl9zZXR0aW5ncycsXG4gICAgZmV0Y2hfY29uY2llcmdlX3NlcnZpY2VzOiAnL2NvbmNpZXJnZV9zZXJ2aWNlcycsXG4gICAgZmV0Y2hfY29uc2VjdXRpdmVfbWVldGluZ19mb3JtX3NldHRpbmdzOiAnL2NvbmZpZ3VyZS9jb25zZWN1dGl2ZV9tZWV0aW5nL2Zvcm1fc2V0dGluZ3MnLFxuICAgIGZldGNoX2NvbnNlY3V0aXZlX21lZXRpbmdfbm90aWZpY2F0aW9uX3NldHRpbmdzOiAnL2NvbmZpZ3VyZS9jb25zZWN1dGl2ZV9tZWV0aW5nL25vdGlmaWNhdGlvbl9zZXR0aW5ncycsXG4gICAgZmV0Y2hfY3VzdG9tZXJfaW5mb192YWx1ZXM6ICcvaW1wb3J0YWJsZV9lbnRpdHlfaW5mbycsXG4gICAgZmV0Y2hfY3VzdG9tZXJzX2FuYWx5dGljczogJy9hbmFseXRpY3MvY3VzdG9tZXJzJyxcbiAgICBmZXRjaF9lYmNfZm9ybTogJy9icmllZmluZ19jdXN0b21fZm9ybS9nZXRfZmllbGRzJyxcbiAgICBmZXRjaF9leGlzdGluZ19tZWV0aW5nczogJy9iYWRnZV9zY2FuX21lZXRpbmdzJyxcbiAgICBmZXRjaF9leHRlcm5hbF9tZWV0aW5nX3JlcXVlc3Q6ICcvZXh0ZXJuYWxfcmVxdWVzdHMvbGlzdCcsXG4gICAgZmV0Y2hfZXh0ZXJuYWxfdXNlcl9mb3JtX2ZpZWxkczogJy9mZXRjaF9zZmRjX2NvbnRhY3RzX2ZpZWxkcycsXG4gICAgZmV0Y2hfZm9ybV9zZXR0aW5nczogJy9jb25maWd1cmUvZm9ybV9zZXR0aW5ncycsXG4gICAgZmV0Y2hfZm9ybTogJy9jdXN0b21fZm9ybS9nZXRfZmllbGRzJyxcbiAgICBmZXRjaF9ndWlkZWRfdG91cl9pbnRlZ3JhdGlvbl9maWVsZHM6ICcvZ3VpZGVkX3RvdXIvaW50ZWdyYXRpb25fZmllbGRzJyxcbiAgICBmZXRjaF9pbnRlZ3JhdGlvbl9ibG9ja19maWVsZHM6ICcvaW50ZWdyYXRpb25fYmxvY2tfZmllbGRzJyxcbiAgICBmZXRjaF9pbnRlZ3JhdGlvbl9tZWV0aW5nX2ZpZWxkczogJy9pbnRlZ3JhdGlvbl9tZWV0aW5nX2ZpZWxkcycsXG4gICAgZmV0Y2hfaW50ZWdyYXRpb25fc3VydmV5X2ZpZWxkczogJy9pbnRlZ3JhdGlvbl9zdXJ2ZXlfZmllbGRzJyxcbiAgICBmZXRjaF9pbnZpdGVlc19hbmFseXRpY3M6ICcvYW5hbHl0aWNzL2ludml0ZWVzJyxcbiAgICBmZXRjaF9sb2NhdGlvbl9jb25maWdzOiAnL2NvbmZpZ3VyZS9sb2NhdGlvbicsXG4gICAgZmV0Y2hfbWFwcGVkX21lZXRpbmdfdHlwZV9mb3Jfcm9sZTogeyB1cmw6ICcvdXNlcnMvcm9sZXNfYWN0aXZpdGllcycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIGZldGNoX21hcHBpbmdfZGV0YWlsczogJy9tYXBwaW5nc19kZXRhaWxzJyxcbiAgICBmZXRjaF9tYXBwaW5nX2ZpbHRlcnM6ICcvYXBwb2ludG1lbnRfZmlsdGVycycsXG4gICAgZmV0Y2hfbWFwcGluZ19ydWxlX3R5cGVzOiAnL2FkYXB0ZXJfdWkvZmV0Y2hfaW50ZWdyYXRpb25fcnVsZXMnLFxuICAgIGZldGNoX21hcHBpbmdzOiAnL21hcHBpbmdfbW9kdWxlX2NvdW50JyxcbiAgICBmZXRjaF9tYXN0ZXJfc3VwcG9ydGVkX2FwaXM6ICcvYWRhcHRlcl91aS9zdXBwb3J0ZWRfYXBpcycsXG4gICAgZmV0Y2hfbWVldGluZ19hdHRlbmRlZTogJy91c2Vycy9jb3B5X2F0dGVuZGVlcycsXG4gICAgZmV0Y2hfbWVldGluZ19jb3VudDogJy9hY3Rpdml0eV9tb2R1bGVfY291bnQnLFxuICAgIGZldGNoX21lZXRpbmdfZGF0YV9mb3JfcmVwb3J0czogJy91c2Vycy9tZWV0aW5ncycsXG4gICAgZmV0Y2hfbWVldGluZ19kZXRhaWxzOiAnL2FjdGl2aXR5X2RldGFpbHMnLFxuICAgIGZldGNoX21lZXRpbmdfZmlsdGVyczogJy9yZXBvcnRzL21lZXRpbmdfZmlsdGVycycsXG4gICAgZmV0Y2hfbWVldGluZ19saXN0X2NvcHlfYXR0ZW5kZWU6ICcvaW1wb3J0YWJsZV9lbnRpdHlfaW5mby9tZWV0aW5nX2luZm9fYXR0ZW5kZWUnLFxuICAgIGZldGNoX21lZXRpbmdfbGlzdF9jdXN0b21lcl9pbmZvOiAnL2ltcG9ydGFibGVfZW50aXR5X2luZm8vY3VzdG9tZXJfaW5mb19mb3JtJyxcbiAgICBmZXRjaF9tZWV0aW5nX3JlcG9ydHNfaGVhZGVyOiAnL2hlYWRlcnMnLFxuICAgIGZldGNoX21lZXRpbmdfcmVwb3J0czogJy9hcGkvdjEvbWVldGluZ3Mvb25kZW1hbmQnLFxuICAgIGZldGNoX21lZXRpbmdfdHlwZV9hbmFseXRpY3M6IHsgdXJsOiAnL2FuYWx5dGljcy9tZWV0aW5nc19ieV90eXBlJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgZmV0Y2hfbWVldGluZ190eXBlX2R1cmF0aW9uczogJy9jYWxlbmRhci9hdmFpbGFibGVfbWVldGluZ190eXBlcycsXG4gICAgZmV0Y2hfbWVldGluZ190eXBlczogJy9tZWV0aW5nX3R5cGVzL2xpc3QnLFxuICAgIGZldGNoX21lZXRpbmdzX2FuYWx5dGljczogJy9hbmFseXRpY3MvbWVldGluZ3MnLFxuICAgIGZldGNoX21pbmltdW1fdGltZXNsb3Q6ICcvc2V0dGluZy9taW5pbXVtX3RpbWVzbG90JyxcbiAgICBmZXRjaF9ub21pbmF0aW9uX2RldGFpbDogJy9ub21pbmF0aW9uL3tVVUlEfS97YWN0aW9ufS5qc29uJyxcbiAgICBmZXRjaF9ub3RpZmljYXRpb25fc2V0dGluZ3M6ICcvY29uZmlndXJlL25vdGlmaWNhdGlvbl9zZXR0aW5ncycsXG4gICAgZmV0Y2hfcG9ydGFsX2N1c3RvbV9mb3JtOiAnL2Zvcm1zJyxcbiAgICBmZXRjaF9wcmV2aWV3X21hcHBpbmdfZGV0YWlsOiAnL2NvbnRhaW5lci97VVVJRH0vZGV0YWlscy5qc29uJyxcbiAgICBmZXRjaF9wcmV2aWV3X21lZXRpbmdfZGV0YWlsOiAnL21lZXRpbmdfcmVxdWVzdC97VVVJRH0ve2FjdGlvbn0uanNvbicsXG4gICAgZmV0Y2hfcmVtb3RlX2VudGl0aWVzOiAnL2ZldGNoX3JlbW90ZV9lbnRpdGllcycsXG4gICAgZmV0Y2hfcmVxdWVzdG9yX2VtYWlsOiAnL2ZldGNoX3JlcXVlc3Rvcl9lbWFpbCcsXG4gICAgZmV0Y2hfcm9sZXNfYW5hbHl0aWNzOiAnL2FuYWx5dGljcy9yb2xlcycsXG4gICAgZmV0Y2hfcm9vbXNfYW5hbHl0aWNzOiAnL2FuYWx5dGljcy9yb29tcycsXG4gICAgZmV0Y2hfc2Nhbm5lZF91c2VyczogJy9mZXRjaF9zY2FubmVkX3VzZXJzJyxcbiAgICBmZXRjaF9zY2FubmVyc19uYW1lOiAnL3NjYW5uZXJzJyxcbiAgICBmZXRjaF9zdGFuZGFyZF9yZXBvcnQ6ICcvcmVwb3J0cy9zdGFuZGFyZF9yZXBvcnQnLFxuICAgIGZldGNoX3N1cnZleV90ZW1wbGF0ZTogJy9jb25maWd1cmUvY29uc29saWRhdGVkX3N1cnZleV9tYWlsX3NldHRpbmdzJyxcbiAgICBmZXRjaF9zdXJ2ZXlzOiAnL3N1cnZleXMnLFxuICAgIGZldGNoX3RhZ19jb25maWdzOiAnL2NvbmZpZ3VyZS90YWcnLFxuICAgIGZldGNoX3RhZ19lbnRpdHk6ICcvdGFncy97e3V1aWR9fS97e2VudGl0eX19JyxcbiAgICBmZXRjaF90b3BpY3M6ICcvdG9waWNzJyxcbiAgICBmZXRjaF90cmFja190b3BpY3M6ICcvdHJhY2tzL3t7dXVpZH19L3RvcGljcycsXG4gICAgZmV0Y2hfdHJhY2tfYWN0aXZpdGllczogJy90cmFja3Mve3t1dWlkfX0vYWN0aXZpdGllcycsXG4gICAgZmV0Y2hfdHJhbnNmZXJhYmxlX21lZXRpbmdfdHlwZXM6ICcvY29uZmlndXJlL2NoYW5nZV9tZWV0aW5nX3R5cGVfbGlua3MnLFxuICAgIGZldGNoX3VubWFwcGVkX3RvcGljX2VudGl0eTogJy9nZXRfbWVldGluZ3Nfd2l0aF91bm1hcHBlZF90b3BpY19lbnRpdHknLFxuICAgIGZldGNoX3VwZGF0ZV9icmllZmluZ19ub3RpZmljYXRpb25fc2V0dGluZ3M6ICcvY29uZmlndXJlL2JyaWVmaW5nX25vdGlmaWNhdGlvbl9zZXR0aW5ncycsXG4gICAgZmV0Y2hfdXNlcl9kZXRhaWxzOiAnL3VzZXJzL3t7dXVpZH19JyxcbiAgICBmZXRjaF91c2VyX2ZpZWxkX21hcHBpbmdzOiAnL2FkYXB0ZXJfdWkvZmV0Y2hfaW50ZWdyYXRpb25fY29uZmlncycsXG4gICAgZmV0Y2hfdXNlcl9mb3JtX3J1bGVzOiAnL3VzZXJfZm9ybV9maWVsZHMnLFxuICAgIGZldGNoX3VzZXJfbm90aWZpY2F0aW9uOiAnL3RlZGR5L25vdGlmaWNhdGlvbnMvc2V0dGluZ3MnLFxuICAgIGZldGNoX3VzZXJfdG9waWNzOiAnL3VzZXJfdG9waWNzJyxcbiAgICBmZXRjaF92YWxpZF9tYXBwaW5nX1RpbWVzOiAnL21hcHBpbmdzX3ZhbGlkX3N0YXJ0X3RpbWVzJyxcbiAgICBmZXRjaF9jb25mZXJlbmNlX2xpc3Q6ICcvaGFuZ291dC9jb25mZXJlbmNlcy9lbmFibGVkX2NvbmZlcmVuY2VzJyxcbiAgICBmZXRjaF9jb25mZXJlbmNlX2xpbms6ICcvaGFuZ291dC9jb25mZXJlbmNlcy9jb25mZXJlbmNlX2xpbmsnLFxuICAgIGZldGNoX3Jlc291cmNlX2RhdGE6IHt1cmw6ICcvYXBpL3YxL3Jlc291cmNlX2RhdGEvZmV0Y2gnLCBlcnJvckNvbmZpZzoge2hhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcid9fSxcbiAgICBmZXRjaF91c2VyX2N1c3RvbV9maWVsZF9tYXBwaW5nOiAnL2Zvcm1zL3VzZXIvZXh0X3JlcV9jb25maWcnLFxuICAgIGZpbGVfdXBsb2FkX3VybDogJy9hdHRhY2htZW50L3t0eXBlfScsXG4gICAgZmlsbF9idWxrX2NvbnNlbnQ6IHt1cmw6ICcvYXBpL3YxL3VzZXJzL3NldF9jb25zZW50X2RldGFpbHMnLCBlcnJvckNvbmZpZzoge2hhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcid9fSxcbiAgICBnZXRfYW5ub3VuY2VtZW50czogJy9zZXR0aW5nL2Fubm91bmNlbWVudCcsXG4gICAgZ2V0X2Jvb3RoX3RvdXJfZGV0YWlsczogJy9ib290aF90b3VyL2xpc3QnLFxuICAgIGdldF9icmllZmluZ19maWx0ZXJzOiAnL2JjL3tCQ1VVSUR9L2JyaWVmaW5nL2ZpbHRlcnMnLFxuICAgIGdldF9icmllZmluZ19yZXBvcnRfb3B0aW9uczogJy9iYy97QkNVVUlEfS9icmllZmluZy9maWx0ZXJfb3B0aW9ucycsXG4gICAgZ2V0X2NoZWNraW5fb3B0aW9uczogJy9jaGVja2luX2ZpbHRlcnMvZmlsdGVyX29wdGlvbnMnLFxuICAgIGdvb2dsZV9jaXR5X3NlYXJjaDogJy9nb29nbGVfY2xpZW50L2dlb19wbGFjZXMnLFxuICAgIGdvb2dsZV90aW1lX3pvbmVfc2VhcmNoOiAnL2dvb2dsZV9jbGllbnQvZ2VvX3RpbWV6b25lJyxcbiAgICBzZXRfdXNlcl9zZWNfdGltZV96b25lOiAnL3NldF91c2VyX3RpbWV6b25lJyxcbiAgICBnZXRfZWJjX3JvbGVfcHJpdmlsZWdlczogJy9hbGxfZWJjX3ByaXZpbGVnZXMnLFxuICAgIGdldF9zZWxmX3NlcnZlX3ByaXZpbGVnZXM6ICcvc2VsZl9zZXJ2ZV9wcml2aWxlZ2VzJyxcbiAgICBnZXRfZXh0X21lZXRpbmdfb3B0aW9uczogJy9leHRlcm5hbF9yZXF1ZXN0cy9maWx0ZXJfb3B0aW9ucycsXG4gICAgZ2V0X2V4dGVybmFsX3JlcV9kZXRhaWxzOiAnL2V4dGVybmFsX3JlcXVlc3Qve3V1aWR9L21lZXRpbmdfaW5mbycsXG4gICAgZ2V0X2V4dGVybmFsX3JlcXVlc3Q6ICcvZXh0ZXJuYWxfcmVxdWVzdC97dXVpZH0vdmlldycsXG4gICAgZ2V0X21lZXRpbmdfb3B0aW9uczogJy9tZWV0aW5nX2ZpbHRlcnMvZmlsdGVyX29wdGlvbnMnLFxuICAgIGdldF9tbV9saXN0OiAnL3VzZXJzL21hbmFnZXJzJyxcbiAgICBnZXRfb25kZW1hbmRfdXNlcnNfbGlzdDogJy91c2Vycy9vbmRlbWFuZF91c2VycycsXG4gICAgZ2V0X3JlcG9ydF9vcHRpb25zOiAnL3JlcG9ydHNfZmlsdGVycy9maWx0ZXJfb3B0aW9ucycsXG4gICAgZ2V0X3Jldmlld3M6ICcvcmV2aWV3YWJsZS9yZXZpZXdzJyxcbiAgICBnZXRfc3dhcHBhYmxlX3Jvb21fbGlzdDogJy9zd2FwX3Jvb20vbGlzdCcsXG4gICAgZ2V0X3RhZ19jbG91ZHM6ICcvdGFnX2Nsb3VkJyxcbiAgICBnZXRfdG9waWNzOiAnL2dldF90b3BpY3MnLFxuICAgIGdldF91c2VyX3ByZWZlcmVuY2VzOiAnL3VzZXJzL3t1dWlkfS91c2VyX3ByZWZlcmVuY2UnLFxuICAgIGdyb3VwX25vbWluYXRpb25fZWRpdDogJy9ub21pbmF0aW9uL3t7dXVpZH19L2VkaXQnLFxuICAgIGdyb3VwX25vbWluYXRpb25fdmlldzogJy9ub21pbmF0aW9uL3t7dXVpZH19L3ZpZXcnLFxuICAgIGluYWN0aXZhdGVfcm9vbXM6ICcvcm9vbXMvaW5hY3RpdmUnLFxuICAgIGluYWN0aXZhdGVfdXNlcnM6ICcvYXBpL3YxL3VzZXJzL2luYWN0aXZlJyxcbiAgICBpbnRlZ3JhdGlvbl9jb25maWd1cmF0aW9uc19kZXRhaWxzOiAnL2FkYXB0ZXJfdWkvaW50ZWdyYXRpb25fY29uZmlndXJhdGlvbnMnLFxuICAgIGludGVncmF0aW9uX2NvbmZpZ3VyYXRpb25zX3NjaGVtYTogJy9hZGFwdGVyX3VpL2ludGVncmF0aW9uX2NvbmZpZ3VyYXRpb25zX3NjaGVtYScsXG4gICAgaW50ZWdyYXRpb25fZXh0ZXJuYWxfdXNlcl9pbmZvOiAnL2ludGVncmF0aW9uX2V4dGVybmFsX3VzZXIve3VzZXJfcmVmX2lkfScsXG4gICAgaW50ZWdyYXRpb25fZmllbGRfbWFwcGluZ3M6ICcvaW50ZWdyYXRpb24vZmllbGRfbWFwcGluZ3MnLFxuICAgIGludGVncmF0aW9uOiAnL2FkYXB0ZXJfdWkvaW50ZWdyYXRpb25zJyxcbiAgICBpbnRlcm5hbF9hdHRlbmRlZXM6ICcvdXNlcnMvaW50ZXJuYWwnLFxuICAgIGpuX2Jvb2tfbWVldGluZzogJy9hcGV4L0pOQm9va01lZXRpbmcnLFxuICAgIGpuX3ZpZXdfYm9va19tZWV0aW5nOiAnL2FwZXgvSk5WaWV3TWVldGluZycsXG4gICAgbGlzdF9icmllZmluZ3NfYWdlbmRhOiAnL2JyaWVmaW5nL2xpc3RfYnJpZWZpbmdze1FVRVJZX1BBUkFNU30jL2xpc3RfYWdlbmRhJyxcbiAgICBsaXN0X3RyYWNrczogJy90cmFja3MvbGlzdCcsXG4gICAgbWFpbF90ZW1wbGF0ZV90eXBlX2VudGl0aWVzX2dldDogJy9tYWlsX2FjdGlvbi9nZXRfYXNzb2NpYXRlZF9lbnRpdGllcycsXG4gICAgbWFpbF90ZW1wbGF0ZV90eXBlX2dldDogJy9tYWlsX2FjdGlvbnMnLFxuICAgIG1hbmFnZV9leHRlcm5hbF91c2VyczogJy9tYW5hZ2VfZXh0ZXJuYWxfdXNlcnMnLFxuICAgIG1hbmFnZV91c2VyczogJy9tYW5hZ2V1c2VycycsXG4gICAgbWFudWFsX3JlbWluZGVyX3VzZXI6ICcvbWFudWFsX3JlbWluZGVyc191c2VycycsXG4gICAgbWFwcGFibGVfZ3JvdXBpbmdfdXNlcnM6ICcvcmVwb3J0cy9hbGxfdXNlcnMnLFxuICAgIG1hcHBhYmxlX3JlcXVlc3RvcnM6ICcvZmV0Y2hfcmVxdWVzdG9ycycsXG4gICAgbWFwcGFibGVfdXNlcnM6ICcvY29tbW9uX3V0aWxzL2ZldGNoX21hcHBhYmxlX3VzZXJzJyxcbiAgICBtYXBwZWRfZXZlbnRzOiAnL21hcHBhYmxlX2V2ZW50cycsXG4gICAgbWFwcGluZ19saXN0OiAnL2NvbnRhaW5lcl9tYXBwaW5nL2xpc3QnLFxuICAgIG1hcHBpbmdfcGFnZTogJy9tYXBwaW5nX2xpc3QnLFxuICAgIG1hcHBpbmdfdmFsaWRfZHVyYXRpb25zOiAnL21hcHBpbmdzX3ZhbGlkX2R1cmF0aW9ucycsXG4gICAgbWFwcGluZ3NfZXhwb3J0OiAnL2V4cG9ydGVyL2FwcG9pbnRtZW50JyxcbiAgICBtZWV0aW5nX2F2YWlsYWJpbGl0eTogJy9tZWV0aW5nX3JlcXVlc3QvY2FsZW5kYXInLFxuICAgIG1lZXRpbmdfY3JlYXRlOiAnL21lZXRpbmdfcmVxdWVzdC9jcmVhdGUnLFxuICAgIG1lZXRpbmdfZHJhZzogJy9jYWxlbmRhci9yZWxvY2F0ZScsXG4gICAgbWVldGluZ19mZXRjaDogJy9tZWV0aW5nX3JlcXVlc3Qve3t1dWlkfX0vc2hvdycsXG4gICAgbWVldGluZ19nZXRfY29uZmlnOiAnL2NvbmZpZ3VyZS97OnV1aWR9L21lZXRpbmdfdHlwZScsXG4gICAgbWVldGluZ19nZXRfc2V0dGluZ3M6ICcvc2V0dGluZy9hY3Rpdml0eScsXG4gICAgbWVldGluZ19oaXN0b3J5OiAnL21lZXRpbmdfcmVxdWVzdC97dXVpZH0vaGlzdG9yeScsXG4gICAgbWVldGluZ19ob3N0X2NvdW50OiAnL2dldF9tZWV0aW5nc193aXRoX21lZXRpbmdfaG9zdCcsXG4gICAgbWVldGluZ19saXN0OiAnL21lZXRpbmdfbGlzdCcsXG4gICAgbWVldGluZ19ub3RpZmljYXRpb25zOiAnL21lZXRpbmdfbm90aWZpY2F0aW9ucycsXG4gICAgbWVldGluZ19yZXF1ZXN0X2VkaXRfcGF0aDogJy9tZWV0aW5nX3JlcXVlc3Qve3V1aWR9L2VkaXQnLFxuICAgIG1lZXRpbmdfcmVxdWVzdF9leHBvcnQ6ICcvbWVldGluZ19yZXF1ZXN0L2V4cG9ydCcsXG4gICAgbWVldGluZ19yZXF1ZXN0X3BhdGg6ICcvbWVldGluZ19yZXF1ZXN0L25ldycsXG4gICAgbWVldGluZ19yZXF1ZXN0X3ZpZXdfcGF0aDogJy9tZWV0aW5nX3JlcXVlc3Qve3V1aWR9L3ZpZXcnLFxuICAgIG1lZXRpbmdfc2V0X2NvbmZpZzogJy9jb25maWd1cmUvezp1dWlkfS9tZWV0aW5nX3R5cGVfdXBkYXRlJyxcbiAgICBtZWV0aW5nX3NldF9zZXR0aW5nOiAnL3NldHRpbmcvYWN0aXZpdHlfdXBkYXRlJyxcbiAgICBtZWV0aW5nX3R5cGVfY3JlYXRlOiAnL21lZXRpbmdfdHlwZS9jcmVhdGUnLFxuICAgIG1lZXRpbmdfdHlwZV91cGRhdGU6ICcvbWVldGluZ190eXBlL3t1dWlkfS91cGRhdGUnLFxuICAgIG1lZXRpbmdfdHlwZXNfb2ZfY29uc2VjdXRpdmVfc3ViX21lZXRpbmdzOiAnL2NvbnNlY3V0aXZlX21lZXRpbmdzL21lZXRpbmdfdHlwZXMnLFxuICAgIG1lZXRpbmdfdHlwZXM6ICcvbWVldGluZ190eXBlcycsXG4gICAgbWVldGluZ3NfbGlzdF9maWx0ZXJzOiAnL21lZXRpbmdfcmVxdWVzdC9tZWV0aW5nX2ZpbHRlcnMnLFxuICAgIG1lZXRpbmdzX2xpc3Q6ICcvbWVldGluZ19yZXF1ZXN0cycsXG4gICAgbWlzY2VsbGFuZW91c19yZXBvcnRfZXhwb3J0OiAnL3JlcG9ydHMvbWlzY2VsbGFuZW91cy97dHlwZX0nLFxuICAgIG5vbl9ldmVudF9jb25maWd1cmF0aW9uczogJy9jYWxlbmRhci9jb25maWd1cmF0aW9ucycsXG4gICAgbm90aWZpY2F0aW9uX2ZldGNoOiAnL25vdGlmaWNhdGlvbnMnLFxuICAgIG9uX2JlaGFsZl9hY3Rpb25zOiAnL21lZXRpbmdfcmVxdWVzdC9vbl9iZWhhbGZfYWN0aW9ucycsXG4gICAgcG9ydGFsOiAnL3BvcnRhbCcsXG4gICAgcHJpbnRfdXNlcl9iYWRnZTogJy9wcmludF9iYWRnZScsXG4gICAgcmVnaXN0ZXJfdXNlcjogeyB1cmw6ICcvYXBpL3YxL3JlZ2lzdGVyL3VzZXInLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInIH0gfSxcbiAgICByZWludml0ZV9hdHRlbmRlZV90b19tZWV0aW5nOiAnL21lZXRpbmdfcmVxdWVzdC9yZWludml0ZScsXG4gICAgcmVpbnZpdGVfdXNlcnM6IHsgdXJsOiAnL2FwaS92MS91c2Vycy9yZWludml0ZScsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdzdW1tdXJ5RXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgcmVqZWN0X2V4dGVybmFsX3JlcXVlc3Q6ICcvZXh0ZXJuYWxfcmVxdWVzdC97dXVpZH0vcmVqZWN0JyxcbiAgICByZWplY3RfbG9jYXRpb25fcHJlZmVyZW5jZToge3VybDogJy9tZWV0aW5nX3JlcXVlc3Qve3t1dWlkfX0vcmVqZWN0X2xvY19wcmVmX3Byb3Bvc2FsJywgZXJyb3JDb25maWc6IHtoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInfSB9LFxuICAgIHJlbWluZGVyX25vdGlmX3NldHRpbmdzOiAnL3JlbWluZGVycy9hbGwvdGVtcGxhdGVzJyxcbiAgICByZW1vdmVfZnJvbV9ldmVudDogJy91c2Vycy9VVUlEL2luYWN0aXZlJyxcbiAgICByZW1vdmVfdXBsb2FkZWRfZmlsZV91cmw6ICcvYXR0YWNobWVudC97dXVpZH0nLFxuICAgIHJlbW92ZV91c2VyX2Zyb21fZXZlbnQ6ICcvdHJpZ2dlci91bm1hcCcsXG4gICAgcmVvcmRlcl9tZWV0aW5nX3R5cGVzOiAnL21lZXRpbmdfdHlwZS91cGRhdGVfb3JkZXInLFxuICAgIHJlcG9ydHM6IHtcbiAgICAgIHVuaWZpZWRfcmVwb3J0X2ZpbHRlcnM6ICcvcmVwb3J0cy91bmlmaWVkX3JlcG9ydF9maWx0ZXJzJyxcbiAgICAgIHVzZXJfbGlzdDogJy9yZXBvcnRzL3VzZXJzX2xpc3QnLFxuICAgICAgdW5pZmllZF9yZXBvcnQ6ICcvcmVwb3J0cy91bmlmaWVkX3JlcG9ydC57e2Zvcm1hdH19JyxcbiAgICAgIGZldGNoX3JlcG9ydF90ZW1wbGF0ZTogJy9yZXBvcnRfdGVtcGxhdGVzJyxcbiAgICAgIHVwbG9hZF9yZXBvcnRfdGVtcGxhdGU6ICcvcmVwb3J0X3RlbXBsYXRlcy97dGVtcGxhdGVfdHlwZX0vdXBsb2FkJyxcbiAgICAgIHVwZGF0ZV9yZXBvcnRfdGVtcGxhdGU6ICcvcmVwb3J0X3RlbXBsYXRlcy97dGVtcGxhdGVfdHlwZX0vdXBkYXRlJ1xuICAgIH0sXG4gICAgcmVwb3J0X3N1cnZleV9hY3Rpdml0eV9saXN0OiAnL3N1cnZleS9hY3Rpdml0eV9saXN0JyxcbiAgICByZXNjaGVkdWxlX21lZXRpbmc6ICcvbWVldGluZ19yZXF1ZXN0L3Jlc2NoZWR1bGUnLFxuICAgIHBhcnRpYWxfbWVldGluZ191cGRhdGU6ICcvbWVldGluZ19yZXF1ZXN0L3BhcnRpYWxfdXBkYXRlJyxcbiAgICByZXZpZXdlcl9tZWV0aW5nX2ZpbHRlcl9vcHRpb25zOiAnL3Jldmlld2FibGUvbWVldGluZ19maWx0ZXJzL2ZpbHRlcl9vcHRpb25zJyxcbiAgICByZXZpZXdlcl9tZWV0aW5nX2ZpbHRlcnM6ICcvcmV2aWV3YWJsZS9tZWV0aW5nX2ZpbHRlcnMnLFxuICAgIHJldmlld2VyX21lZXRpbmdzOiAnL3Jldmlld2FibGUvbWVldGluZ19yZXF1ZXN0cycsXG4gICAgcm9sZV9jcmVhdGU6ICcvcm9sZS9jcmVhdGUnLFxuICAgIHJvbGVfZGlzYWJsZTogJy9yb2xlL3s6dXVpZH0vZGlzYWJsZScsXG4gICAgcm9sZV9lbmFibGU6ICcvcm9sZS97OnV1aWR9L2VuYWJsZScsXG4gICAgcm9sZV9nZXRfYWxsX3ByaXZpbGVnZXM6ICcvYWxsX3ByaXZpbGVnZXMnLFxuICAgIHJvbGVfZ2V0X3ByaXZpbGVnZXM6ICcvcm9sZS97OnV1aWR9L2dldF9wcml2aWxlZ2VzJyxcbiAgICByb2xlX3NldF9wcml2aWxlZ2VzOiAnL3JvbGUvezp1dWlkfS9zZXRfcHJpdmlsZWdlcycsXG4gICAgcm9sZV91cGRhdGU6ICcvcm9sZS91cGRhdGUnLFxuICAgIHJvbGVzX2ZldGNoOiAnL3JvbGVzJyxcbiAgICByb29tX2FjdGl2aXRpZXM6ICcvYWN0aXZpdGllc19yb29tcycsXG4gICAgcm9vbV9hdmFpbGFiaWxpdHk6ICcvY2FsZW5kYXIvcm9vbXMnLFxuICAgIHJvb21fY2FsZW5kYXJfZXhwb3J0OiAnL2NhbGVuZGFyL3Jvb21zL2V4cG9ydCcsXG4gICAgcm9vbV9jcmVhdGU6ICcvcm9vbS9jcmVhdGUnLFxuICAgIHJvb21fZmlsdGVyczogJy9yb29tL2ZpbHRlcl9vcHRpb25zJyxcbiAgICByb29tX21ha2VfYXZhaWxhYmxlOiAnL2NhbGVuZGFyL21ha2VfYXZhaWxhYmxlJyxcbiAgICByb29tX21ha2VfdW5hdmFpbGFibGU6ICcvY2FsZW5kYXIvbWFrZV91bmF2YWlsYWJsZScsXG4gICAgcm9vbV91bmJsb2NrOiAnL2NhbGVuZGFyL3VuYmxvY2snLFxuICAgIHJvb21fdXBkYXRlOiAnL3Jvb20vdXBkYXRlJyxcbiAgICByb29tc19leHBvcnQ6ICcvZXhwb3J0ZXIvcm9vbScsXG4gICAgcm9vbXNfbGlzdDogJy9yb29tcy9saXN0JyxcbiAgICBzYXZlX2Zvcm06ICcvY3VzdG9tX2Zvcm0vdXBkYXRlJyxcbiAgICBzYXZlX3BvcnRhbF9jdXN0b21fZm9ybTogJy9mb3JtL3VwZGF0ZScsXG4gICAgc2F2ZV9wcmludGVyX25hbWU6ICcvc2F2ZV9wcmludGVyX25hbWUnLFxuICAgIHNhdmVfcHJvZmlsZV9wcmVmZXJlbmNlczogJy91c2VyX2Zvcm1fZmllbGRzL3VwZGF0ZScsXG4gICAgc2F2ZV91c2VyX2ZpZWxkX21hcHBpbmdzOiAnL2NyZWF0ZV9vcl91cGRhdGVfaW50ZWdyYXRpb25fY29uZmlndXJhdGlvbicsXG4gICAgc2F2ZWRfcmVwb3J0X2RldGFpbHM6ICcvdXNlcl90ZW1wbGF0ZS9kZXRhaWxzJyxcbiAgICBzZW5kX2J1bGtfc3VydmV5X21lZXRpbmdfbWFpbDogJy9tZWV0aW5nX3JlcXVlc3Qvc2VuZF9zdXJ2ZXlfbWFpbC9idWxrX2FjdGlvbicsXG4gICAgc2VuZF9yZXF1ZXN0b3JfZW1haWw6IHsgdXJsOiAnL21lZXRpbmdfcmVxdWVzdC9zZW5kX2VtYWlsX3RvX3JlcXVlc3RvcicsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHNlbmRfc3VydmV5X21lZXRpbmdfbWFpbDogJy9tZWV0aW5nX3JlcXVlc3Qve1VVSUR9L3NlbmRfc3VydmV5X21haWwnLFxuICAgIHNlc3Npb25fY2hlY2tpbl9saXN0OiAnL3Nlc3Npb25fY2hlY2tpbl9saXN0JyxcbiAgICBzZXNzaW9uX2V4cG9ydDogJy9zZXNzaW9uL2V4cG9ydCcsXG4gICAgc2Vzc2lvbl9saXN0OiAnL3Nlc3Npb25fbGlzdCcsXG4gICAgc2Vzc2lvbl9ub21pbmF0aW9uczogJy9ncm91cF9ub21pbmF0aW9ucycsXG4gICAgc2Vzc2lvbnNfbGlzdDogJy9zZXNzaW9ucycsXG4gICAgc2V0X2Fubm91bmNlbWVudHM6ICcvc2V0dGluZy9hbm5vdW5jZW1lbnRfdXBkYXRlJyxcbiAgICBzZXRfcGFydGljaXBhdGlvbl9tYXNjYWw6ICcvbWVldGluZ19yZXF1ZXN0L3NldF9wYXJ0aWNpcGF0aW9uJyxcbiAgICBzZXRfcGFydGljaXBhdGlvbjogeyB1cmw6ICcvbWVldGluZ19yZXF1ZXN0L3NldF9wYXJ0aWNpcGF0aW9uJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgc2V0X3JlbWluZGVyOiAnL3NldF9yZW1pbmRlcicsXG4gICAgc2V0X3VzZXJfY2lzX3N0YXR1czogJy9zZXRfdXNlcl9jaXNfc3RhdHVzL3t7aWR9fScsXG4gICAgc2V0X3VzZXJfcHJlZmVyZW5jZXM6ICcvdXNlcnMve3V1aWR9L3VzZXJfcHJlZmVyZW5jZScsXG4gICAgc2ZkY19jdXN0b21fbGFiZWxzOiB7dXJsIDogJy9zZmRjX2N1c3RvbV9sYWJlbHNfY29uZmlndXJhdGlvbnMnLCBlcnJvckNvbmZpZyA6IHtoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInfX0sXG4gICAgc2hvd19pbl9tZWV0aW5nX2V4dGVybmFsX2F0dGVuZGVlOiB7IHVybDogJy9jb25maWd1cmUvc2hvd19pbl9tZWV0aW5nX2V4dGVybmFsX2F0dGVuZGVlJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgc2luZ2xlX21hc3Rlcl9jYWxlbmRhcl9lbnRpdHlfc2VhcmNoOiAnbWFzdGVyX2NhbGVuZGFyL3tlbnRpdHlUeXBlfV9zZWFyY2gnLFxuICAgIHN0YW5kYXJkX3JlcG9ydF9leHBvcnRfdXJsOiAnL3VzZXJzL21lZXRpbmdzLnBkZj91c2VyX3V1aWQ9e3t1dWlkfX0nLFxuICAgIHN0YW5kYXJkX3JlcG9ydF9nZW5lcmF0ZV91cmw6ICcvYXBpL3YxL3N0YW5kYXJkX3JlcG9ydC9nZW5lcmF0ZS5wZGY/dXNlcl91dWlkPXt7dXVpZH19JyxcbiAgICBzdXJ2ZXlfY3JlYXRlOiAnL3N1cnZleV9tYXN0ZXJzJyxcbiAgICBzdXJ2ZXlfcmVzcG9uc2VzOiAnc3VydmV5X3Jlc3BvbnNlcycsXG4gICAgc3VydmV5X3VwZGF0ZTogJy9zdXJ2ZXlfbWFzdGVycy97dXVpZH0nLFxuICAgIHN3YXBfcm9vbV9zdWJtaXQ6ICcvc3dhcF9yb29tL3N3YXAnLFxuICAgIHN5c3RlbV9jb25maWd1cmF0aW9uczogJy9jb25maWd1cmF0aW9ucy9zeXN0ZW1fY29uZmlndXJhdGlvbicsXG4gICAgc3RhbmRhcmRfcmVwb3J0X2V4cG9ydF9ieV9tZWV0aW5nOiAnL2FwaS92MS9tZWV0aW5ncy9zdGFuZGFyZF9yZXBvcnQucGRmJyxcbiAgICB0aW1lX3pvbmVfdXJsOiAnL3RpbWVfem9uZScsXG4gICAgdGltZWxpbmVfZGF0YTogJy9jYWxlbmRhci90aW1lbGluZV9kYXRhJyxcbiAgICB0YWdfY3JlYXRlX29yX3VwZGF0ZTogJy90YWdzJyxcbiAgICB0YWdfZWRpdDogJy90YWdzL3t7dXVpZH19L2VkaXQnLFxuICAgIHRhZ19saXN0OiAnL3RhZ3MnLFxuICAgIHRhZ19saXN0aW5nX3BhZ2U6ICcvdGFnL2xpc3RpbmcnLFxuICAgIHRlbXBsYXRlX3VwbG9hZF91cmw6ICdyZXBvcnRfdGVtcGxhdGVzL3t0ZW1wbGF0ZV90eXBlfS91cGxvYWQnLFxuICAgIHRpbWVfem9uZV91cmw6ICcvdGltZV96b25lJyxcbiAgICB0aW1lbGluZV9kYXRhOiAnL2NhbGVuZGFyL3RpbWVsaW5lX2RhdGEnLFxuICAgIHRvcGljX3VwbG9hZDogJy90b3BpY3MvaW1wb3J0JyxcbiAgICB0b3BpY19jb25maWd1cmF0aW9uczogeyB1cmw6ICcvdG9waWNfY29uZmlndXJhdGlvbnMnLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnc3VtbXVyeUVycm9ySGFuZGxlcicgfSB9LFxuICAgIHRyYWNrX2FjdGl2aXRpZXM6ICcvZ2V0X3RyYWNrX2FjdGl2aXRpZXMnLFxuICAgIHRyYWNrc19saXN0OiAnL3RyYWNrcycsXG4gICAgdHJpZ2dlcl9zeW5jOiAnL3RyaWdnZXJfc3luYycsXG4gICAgdHJpZ2dlcl93ZWxjb21lX2VtYWlsX3VzZXJzOiB7IHVybDogJy9hcGkvdjEvdXNlcnMvc2VuZF93ZWxjb21lX2VtYWlsJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdWlfZ2V0X3NldHRpbmdzOiAnL3NldHRpbmcvdWknLFxuICAgIHVpX3NldF9zZXR0aW5nOiAnL3NldHRpbmcvdWlfdXBkYXRlJyxcbiAgICB1cGRhdGVfYWN0aXZpdHlfc2V0dGluZ3M6ICcvY29uZmlndXJlL2FjdGl2aXR5X3NldHRpbmcnLFxuICAgIHVwZGF0ZV9hbmFseXRpY3NfY29uZmlnczogeyB1cmw6ICcvYW5hbHl0aWNzX2Rhc2hib2FyZC91cGRhdGVfY29uZmlnJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXBkYXRlX2JyaWVmaW5nX3dvcmtmbG93OiAnL2NvbmZpZ3VyZS9icmllZmluZ19zZXR0aW5ncycsXG4gICAgdXBkYXRlX2NhbGVuZGFyX3NldHRpbmdzOiAnL2NvbmZpZ3VyZS9jYWxlbmRhcl9zZXR0aW5ncy97e3V1aWR9fS91cGRhdGUnLFxuICAgIHVwZGF0ZV9jaGVja2luX3N0YXR1czogJy9jaGVja2luL3RvZ2dsZV9jaGVja2luJyxcbiAgICB1cGRhdGVfY29tcGFueV9mb3JtOiAnL2NvbXBhbnkvdXBkYXRlX2NvbXBhbnlfY29uZmlncycsXG4gICAgdXBkYXRlX2NvbmNpZXJnZV9mb3JtOiAnL2NvbmNpZXJnZV9zZXJ2aWNlcy97e3V1aWR9fS91cGRhdGVfY3VzdG9tX2Zvcm0nLFxuICAgIHVwZGF0ZV9jb25jaWVyZ2Vfbm90aWZpY2F0aW9uX3NldHRpbmdzOiAnL2NvbmNpZXJnZV9zZXJ2aWNlcy97e3V1aWR9fS91cGRhdGVfbm90aWZpY2F0aW9uX3NldHRpbmdzJyxcbiAgICB1cGRhdGVfY29uZmlnX2NoYW5nZV9tZWV0aW5nX3R5cGU6ICcvY29uZmlndXJlL2NoYW5nZV9tZWV0aW5nX3R5cGUnLFxuICAgIHVwZGF0ZV9jb25maWc6IHsgdXJsOiAnL2NvbmZpZy91cGRhdGVfY29uZmlnL3t7Y29uZmlnX3R5cGV9fScsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHVwZGF0ZV9jb25maWd1cmF0aW9uOiB7IHVybDogJy91cGRhdGVfY29uZmlndXJhdGlvbicsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdzdW1tdXJ5RXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXBkYXRlX2N1c3RvbV9yZXBvcnRzOiAnL3VzZXJfdGVtcGxhdGUvdXBkYXRlJyxcbiAgICB1cGRhdGVfZG91YmxlX2Jvb2tpbmdfY29uZmlnOiB7IHVybDogJy9jb25maWd1cmUvZG91YmxlX2Jvb2tpbmcnLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInIH0gfSxcbiAgICB1cGRhdGVfZW5kb3JzZW1lbnRfY29uZmlnOiB7IHVybDogJy9jb25maWd1cmUvZW5kb3JzZW1lbnQnLCBlcnJvckNvbmZpZzogeyBoYW5kbGVyOiAnZGV0YWlsZWRFcnJvckhhbmRsZXInIH0gfSxcbiAgICB1cGRhdGVfZXZlbnRfYWNjZXNzOiB7IHVybDogJy9hcGkvdjEvdXBkYXRlX2V2ZW50X2FjY2VzcycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHVwZGF0ZV9ldmVudF92aXNpYmlsaXR5OiAnL3JvbGUve3t1dWlkfX0vZXZlbnRfdmlzaWJpbGl0eScsXG4gICAgdXBkYXRlX2V4dGVybmFsX21lZXRpbmc6ICcvY29uZmlnL2V4dGVybmFsX21lZXRpbmcnLFxuICAgIHVwZGF0ZV9leHRlcm5hbF9yZXF1ZXN0X2Zvcm06ICcvdXBkYXRlX2V4dGVybmFsX3dpZGdldCcsXG4gICAgdXBkYXRlX2N1c3RvbV9mb3JtOiAnL3VwZGF0ZV9jdXN0b21fZm9ybScsXG4gICAgdXBkYXRlX2Zvcm1fc2V0dGluZ3M6ICcvY29uZmlndXJlL2Zvcm1fc2V0dGluZ3Mve3t1dWlkfX0vdXBkYXRlJyxcbiAgICB1cGRhdGVfbG9jYXRpb25fY29uZmlnczogJy9jb25maWcvdXBkYXRlX2xvY2F0aW9uJyxcbiAgICB1cGRhdGVfbWFpbF90ZW1wbGF0ZTogJy9tYWlsX3RlbXBsYXRlL3VwZGF0ZScsXG4gICAgdXBkYXRlX21hbnVhbF9zY2hlZHVsaW5nOiAnL2NvbmZpZy9tYW51YWxfc2NoZWR1bGluZycsXG4gICAgdXBkYXRlX21hcHBpbmdfbW9kdWxlX2NvbmZpZzogJy9tZWV0aW5nX3R5cGUve2FjdGl2aXR5X3V1aWR9L21hcHBpbmdfbW9kdWxlX2NvbmZpZ3MnLFxuICAgIHVwZGF0ZV9tYXBwaW5nX21vZHVsZTogeyB1cmw6ICcvY29uZmlndXJlL21hcHBpbmdfbW9kdWxlJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXBkYXRlX3ZpcnR1YWxfZXZlbnQ6IHsgdXJsOiAnL2V2ZW50L2VuYWJsZV92aXJ0dWFsJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdHJpZ2dlcl92aXJ0dWFsX2V2ZW50X2VtYWlsOiB7IHVybDogJy9ldmVudC90cmlnZ2VyX21haWxfdmlydHVhbF9ldmVudCcsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHVwZGF0ZV9taW5pbXVtX3RpbWVzbG90OiAnL3NldHRpbmcvbWluaW11bV90aW1lc2xvdF91cGRhdGUnLFxuICAgIHVwZGF0ZV9ub3RpZmljYXRpb25fc2V0dGluZ3M6ICcvY29uZmlndXJlL25vdGlmaWNhdGlvbl9zZXR0aW5nJyxcbiAgICB1cGRhdGVfcmV2aWV3OiAnL3Jldmlld2FibGUvcmV2aWV3JyxcbiAgICB1cGRhdGVfc3VydmV5X2Zvcm06ICcvc3VydmV5X3Jlc3BvbnNlL3t1dWlkfScsXG4gICAgdXBkYXRlX3N1cnZleV90ZW1wbGF0ZTogJy9jb25maWd1cmUvY29uc29saWRhdGVkX3N1cnZleV9tYWlsX3NldHRpbmcnLFxuICAgIHVwZGF0ZV90YWdfY29uZmlnczogJy9jb25maWcvdXBkYXRlX3RhZycsXG4gICAgdXBkYXRlX3RyYWNrX2NvbmZpZzogeyB1cmw6ICcvY29uZmlndXJlL3RyYWNrcycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHVwZGF0ZV90cmFja19sYWJlbDogeyB1cmw6ICcvY29uZmlndXJlL3RyYWNrX2xhYmVsJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXBkYXRlX3RyYW5zZmVyYWJsZV9tZWV0aW5nX3R5cGVzOiB7IHVybDogJy9jb25maWd1cmUvY2hhbmdlX21lZXRpbmdfdHlwZV9saW5rcycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHVwZGF0ZV91c2VyX25vdGlmX3NldHRpbmdzOiAnL3VzZXJfc2V0dGluZy9ub3RpZmljYXRpb25fc2V0dGluZycsXG4gICAgdXBkYXRlX3VzZXJfbm90aWZpY2F0aW9uOiAnL3RlZGR5L25vdGlmaWNhdGlvbnMvc2V0dGluZ3MnLFxuICAgIHVwZGF0ZV91c2VyX3Byb2ZpbGU6ICcvdXNlci97e3V1aWR9fScsXG4gICAgdXBkYXRlX3VzZXJfcmVnaXN0cmF0aW9uOiAnL2NvbXBhbnkvdXBkYXRlX3VzZXJfcmVnaXN0ZXJfY29uZmlncycsXG4gICAgdXBsb2FkX2FnZW5kYV9pdGVtX2NzdjogJy9tZWV0aW5nX3JlcXVlc3QvaW1wb3J0JyxcbiAgICB1cGxvYWRfbWFwcGluZ19jc3Y6ICcvc3BlY2lhbF9hcHBvaW50bWVudC9pbXBvcnQnLFxuICAgIHVwbG9hZF9yb29tX2NzdjogJy9yb29tL2ltcG9ydCcsXG4gICAgdXBsb2FkX3VzZXJfdG9waWNfY3N2OiB7IHVybDogJy9hcGkvdjEvdXNlcnMvaW1wb3J0X3VzZXJfdG9waWNfbWFwcGluZycsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHVwbG9hZF9lYV9hdHRlbmRlZV9tYXBwaW5nX2NzdjogeyB1cmw6ICcvdXNlci9idWxrX2ltcG9ydF9lYV9hdHRlbmRlZV9tYXBwaW5nJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXBsb2FkX3VzZXJfY3N2OiB7IHVybDogJy9jb21tb25fdXRpbHMvdXNlcnMvaW1wb3J0JywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXNlcl9ibG9jazogJy9jYWxlbmRhci9ibG9jaycsXG4gICAgdXNlcl9jYWxlbmRhcl9leHBvcnQ6ICcvY2FsZW5kYXIvdXNlcnMvZXhwb3J0JyxcbiAgICB1c2VyX2NyZWF0ZTogJy91c2VyL2NyZWF0ZScsXG4gICAgdXNlcl9jc3ZfdGVtcGxhdGU6ICcvcG9ydGFsL3VzZXIvY3N2X3RlbXBsYXRlJyxcbiAgICBlYV9hdHRlbmRlZV9tYXBwaW5nOiAnL3VzZXIvZWFfYXR0ZW5kZWVfY3N2X3RlbXBsYXRlJyxcbiAgICB1c2VyX2V4cG9ydDogJy9hcGkvdjEvdXNlcnMvZXhwb3J0JyxcbiAgICBlYV9hdHRlbmRlZV9tYXBwaW5nX2V4cG9ydDogJy91c2VyL2VhX2F0dGVuZGVlX21hcHBpbmdfZXhwb3J0JyxcbiAgICB1c2VyX2ZpbHRlcnM6IHsgdXJsOiAnL2NvbW1vbl91dGlscy91c2Vycy9maWx0ZXJzJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXNlcl9oaXN0b3J5OiB7IHVybDogJy91c2VyL3t1dWlkfS9oaXN0b3J5JywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgdXNlcl9tYWtlX2F2YWlsYWJsZTogJy9jYWxlbmRhci9tYWtlX2F2YWlsYWJsZScsXG4gICAgdXNlcl9tYWtlX3VuYXZhaWxhYmxlOiAnL2NhbGVuZGFyL21ha2VfdW5hdmFpbGFibGUnLFxuICAgIHVzZXJfbm90aWZfc2V0dGluZ3M6ICcvdXNlcl9zZXR0aW5nL25vdGlmaWNhdGlvbl9zZXR0aW5ncycsXG4gICAgdXNlcl91bmJsb2NrOiAnL2NhbGVuZGFyL3VuYmxvY2snLFxuICAgIHVzZXJfdXBkYXRlOiAnL3VzZXJzL3t7dXVpZH19L3VwZGF0ZScsXG4gICAgdXNlcnNfZXZlbnRzX2ZpbHRlcnM6ICcvdXNlcnNfZXZlbnRzX2ZpbHRlcnMnLFxuICAgIHVzZXJzX2V2ZW50czogJy91c2Vyc19ldmVudHMnLFxuICAgIHVzZXJzOiB7IHVybDogJy9jb21tb25fdXRpbHMvdXNlcnMvbGlzdCcsIGVycm9yQ29uZmlnOiB7IGhhbmRsZXI6ICdkZXRhaWxlZEVycm9ySGFuZGxlcicgfSB9LFxuICAgIHZhbGlkYXRlX3Jvb21fY2FwYWNpdHk6ICcvcm9vbS92YWxpZGF0ZScsXG4gICAgY29tcGxpYW5jZV9jb25maWd1cmF0aW9uOiB7IHVybDogJy9jb21wbGlhbmNlL2NvbmZpZ3VyYXRpb25zJywgZXJyb3JDb25maWc6IHsgaGFuZGxlcjogJ2RldGFpbGVkRXJyb3JIYW5kbGVyJyB9IH0sXG4gICAgZmV0Y2hfYWNjb3VudDogJy9hcGkvdjEvYWNjb3VudHMnLFxuICAgIGZldGNoX29wcG9ydHVuaXR5OiAnL2FwaS92MS9vcHBvcnR1bml0aWVzJyxcbiAgICBzdXBwb3J0ZWRfYXBpX2RldGFpbDogJy9hZGFwdGVyX3VpL3N1cHBvcnRlZF9hcGlfZGV0YWlscycsXG4gICAgam5faW50ZWdyYXRpb25fZmllbGRzOiAnL2FkYXB0ZXJfdWkvbWFwcGluZ3MnLFxuICAgIHNhdmVfYXV0aF9mb3JtOiAnL2FkYXB0ZXJfdWkvaW50ZWdyYXRpb25zL3NhdmVfYXV0aF9maWVsZHMnLFxuICAgIHVwZGF0ZV9pbnRfY29uZmlnOiAodXVpZCkgPT4gYC9hZGFwdGVyX3VpL2ludGVncmF0aW9uLyR7dXVpZH0vc3RhdHVzYCxcbiAgICByb29tX2Jsb2NrOiAnL2FwaS92MS9yb29tL2ludGVyaW1fYmxvY2snLFxuICAgIHBlbmRvX25wc19jb25zZW50OiAnL2Rhc2hib2FyZC9wZW5kb19ucHMnLFxuICAgIGdldF9nZHByX21lc3NhZ2U6ICcvY29uZmlndXJhdGlvbi9wcml2YWN5X21lc3NhZ2VzJyxcbiAgICBmZXRjaF9yZWdpc3RlcmVkX2ludGVncmF0aW9uOiAnL2FkYXB0ZXJfdWkvZW5hYmxlZF9iYWRnZV9zY2FucycsXG4gICAgZmV0Y2hfaW50ZWdyYXRpb25fYXZhaWxhYmxlX2ZpbGVkczogJy9hZGFwdGVyX3VpL3N1cHBvcnRlZF9hcGlfZGV0YWlscy9wYXJzZV9zY2hlbWEnLFxuICAgIGZldGNoX2F2YWlsYWJsZV9jb25mZXJlbmNlczogJy9oYW5nb3V0L2NvbmZlcmVuY2VzJyxcbiAgICBjcmVhdGVfY29uZmVyZW5jZTogJy9oYW5nb3V0L2NvbmZlcmVuY2VzLydcbiAgfSxcblxuICBBUElfY2FjaGUgOiB7fSxcblxuICBzdW1tdXJ5RXJyb3JIYW5kbGVyOiBmdW5jdGlvbiAodXJsLCByZXNwb25zZSwgZXJyb3JDb25maWdzKSB7XG4gICAgdmFyIGVycm9ySnNvbiA9IHJlc3BvbnNlLnJlc3BvbnNlSlNPTlxuICAgIHZhciBtb2RlbEVsID0gJCgnLm5vdGlmaWNhdGlvbi1tb2RhbCcpXG4gICAgbW9kZWxFbC5ub3RpZmljYXRpb25Nb2RhbCh7XG4gICAgICB0eXBlOiAnbm90aWZpY2F0aW9uJyxcbiAgICAgIHRpdGxlOiBlcnJvckNvbmZpZ3MuY3VzdG9tX3RpdGxlIHx8IGkxOG4udCgnZmFpbHVyZScpLFxuICAgICAgYm9keTogZXJyb3JDb25maWdzLmN1c3RvbV9tZXNzYWdlIHx8IGVycm9ySnNvbi5tZXNzYWdlLFxuICAgICAgY2xhc3M6ICdyZWQnXG4gICAgfSlcbiAgfSxcblxuICBkZXRhaWxlZEVycm9ySGFuZGxlcjogZnVuY3Rpb24gKHVybCwgcmVzcG9uc2UsIGVycm9yQ29uZmlncykge1xuICAgIHZhciBlcnJvckpzb24gPSByZXNwb25zZS5yZXNwb25zZUpTT05cbiAgICB2YXIgZXJyb3JNc2dcbiAgICB0cnkge1xuICAgICAgZXJyb3JNc2cgPSBfLmZsYXR0ZW4oXy52YWx1ZXMoZXJyb3JKc29uLmVycm9ycy5kZXRhaWxzKSkuam9pbignPC9icj4nKVxuICAgIH0gY2F0Y2ggKGVycikge1xuICAgICAgZXJyb3JNc2cgPSAnJ1xuICAgIH1cbiAgICB2YXIgbW9kZWxFbCA9ICQoJy5ub3RpZmljYXRpb24tbW9kYWwnKVxuICAgIG1vZGVsRWwubm90aWZpY2F0aW9uTW9kYWwoe1xuICAgICAgdHlwZTogJ25vdGlmaWNhdGlvbicsXG4gICAgICB0aXRsZTogZXJyb3JDb25maWdzLmN1c3RvbV90aXRsZSB8fCBpMThuLnQoJ2ZhaWx1cmUnKSxcbiAgICAgIGJvZHk6IGVycm9yQ29uZmlncy5jdXN0b21fbWVzc2FnZSB8fCBlcnJvck1zZyxcbiAgICAgIGNsYXNzOiAncmVkJ1xuICAgIH0pXG4gIH0sXG5cbiAgcmVwbGFjZVVybFBhcmFtczogZnVuY3Rpb24gKCkge1xuICAgIHZhciB1cmxFbmRwb2ludCA9IF8uY2xvbmVEZWVwKGFyZ3VtZW50c1swXSlcbiAgICBpZiAodHlwZW9mIHVybEVuZHBvaW50ICE9PSAnb2JqZWN0Jykge1xuICAgICAgdXJsRW5kcG9pbnQgPSB7IHVybDogdXJsRW5kcG9pbnQgfVxuICAgIH1cbiAgICBmb3IgKHZhciBpID0gMTsgaSA8IGFyZ3VtZW50cy5sZW5ndGg7IGkrKykge1xuICAgICAgdXJsRW5kcG9pbnQudXJsID0gdXJsRW5kcG9pbnQudXJsLnJlcGxhY2UoYXJndW1lbnRzW2ldWzBdLCBhcmd1bWVudHNbaV1bMV0pXG4gICAgfVxuICAgIHJldHVybiB1cmxFbmRwb2ludFxuICB9LFxuXG4gIHVwZGF0ZTogZnVuY3Rpb24gKG9wdGlvbnMpIHtcblxuICAgIGlmIChvcHRpb25zLmRhdGEgJiYgb3B0aW9ucy5kYXRhLmNvbnN0cnVjdG9yID09PSBGb3JtRGF0YSkge1xuICAgICAgICBvcHRpb25zLmRhdGEuYXBwZW5kKCdjdXJyZW50X2xvY2F0aW9uX3V1aWQnLCBlbnZEZXRhaWxzLmN1cnJlbnRfbG9jYXRpb25fdXVpZClcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIF8ubWVyZ2Uob3B0aW9ucywgeyBkYXRhOiB7IGN1cnJlbnRfbG9jYXRpb25fdXVpZDogZW52RGV0YWlscy5jdXJyZW50X2xvY2F0aW9uX3V1aWQgfSB9KVxuICAgIH1cblxuICAgIGlmICh0eXBlb2Ygb3B0aW9ucy51cmwgPT09ICdvYmplY3QnKSB7XG4gICAgICB2YXIgZXJyb3JIYW5kbGVyQ29uZmlncyA9IHt9XG4gICAgICB2YXIgZXJyb3JIYW5kbGVyRm5cbiAgICAgIGlmICh0eXBlb2Ygb3B0aW9ucy51cmwuZXJyb3JDb25maWcgPT09ICdvYmplY3QnKSB7XG4gICAgICAgIGVycm9ySGFuZGxlckZuID0gdGhpc1tvcHRpb25zLnVybC5lcnJvckNvbmZpZy5oYW5kbGVyXVxuICAgICAgICBlcnJvckhhbmRsZXJDb25maWdzID0gb3B0aW9ucy51cmwuZXJyb3JDb25maWdcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGVycm9ySGFuZGxlckZuID0gdGhpc1tvcHRpb25zLnVybC5lcnJvckNvbmZpZ11cbiAgICAgIH1cbiAgICAgIG9wdGlvbnMudXJsID0gb3B0aW9ucy51cmwudXJsXG4gICAgfVxuXG4gICAgb3B0aW9ucyA9IF8uYXNzaWduKHtcbiAgICAgIGRhdGFUeXBlOiAnanNvbicsXG4gICAgICB0eXBlOiBvcHRpb25zLm1ldGhvZCB8fCAncG9zdCcsXG4gICAgICB1cmw6ICcvZXZlbnRzJyxcbiAgICAgIGVycm9ySGFuZGxlckZuOiBlcnJvckhhbmRsZXJGbixcbiAgICAgIGVycm9ySGFuZGxlckNvbmZpZ3M6IGVycm9ySGFuZGxlckNvbmZpZ3MsXG4gICAgICBkYXRhOiB7IGV2ZW50OiBudWxsIH0sXG4gICAgICBwcmVmaXg6IGVudkRldGFpbHNbJ3VybFByZWZpeCddXG4gICAgfSwgb3B0aW9ucylcbiAgICBcbiAgICBpZihvcHRpb25zLnJlcV9zdHJpbmdpZnkpIHtcbiAgICAgIG9wdGlvbnMuZGF0YSA9IEpTT04uc3RyaW5naWZ5KG9wdGlvbnMuZGF0YSlcbiAgICB9XG5cbiAgICBpZiAoIS9eaHR0cHM/Ly50ZXN0KG9wdGlvbnNbJ3VybCddKSkge1xuICAgICAgb3B0aW9uc1sndXJsJ10gPSBvcHRpb25zWydwcmVmaXgnXSArIG9wdGlvbnNbJ3VybCddXG4gICAgfVxuICAgIC8vIFRPRE86IE5lZWQgYSBmaXggaGVyZSB0byBjb25zaWRlciBzaG93aW5nIGxvYWRlciBzZWN0aW9uIGxvYWRlciBhbmQgaGFuZGxpbmcgYWJvcnQgd2l0aCBvbmx5IG9uZSBhcmd1bWVudCBjaGVjay5cbiAgICBvcHRpb25zLnNlY3Rpb25Mb2FkZXIgJiYgdGhpcy5zZXRQYWdlTG9hZGVyKG9wdGlvbnMpXG4gICAgdmFyIHByb21pc2UgPSAkLmFqYXgob3B0aW9ucylcbiAgICBpZihvcHRpb25zLmFib3J0U2VxdWVudGlhbENhbGxzKSB7XG4gICAgICB0aGlzLmFkZFJlbW92ZUNhY2hlKG9wdGlvbnNbJ3VybCddLCBwcm9taXNlKVxuICAgICAgcHJvbWlzZS50aGVuKCgpID0+IHtcbiAgICAgICAgdGhpcy5VaUFjdGlvbnNPblVwZGF0ZShvcHRpb25zKVxuICAgICAgfSlcbiAgICB9XG4gICAgcmV0dXJuIHByb21pc2VcbiAgfSxcblxuICBmZXRjaDogZnVuY3Rpb24gKG9wdGlvbnMpIHtcbiAgICBpZiAodHlwZW9mIG9wdGlvbnMudXJsID09PSAnb2JqZWN0Jykge1xuICAgICAgdmFyIGVycm9ySGFuZGxlckNvbmZpZ3MgPSB7fVxuICAgICAgdmFyIGVycm9ySGFuZGxlckZuXG4gICAgICBpZiAodHlwZW9mIG9wdGlvbnMudXJsLmVycm9yQ29uZmlnID09PSAnb2JqZWN0Jykge1xuICAgICAgICBlcnJvckhhbmRsZXJGbiA9IHRoaXNbb3B0aW9ucy51cmwuZXJyb3JDb25maWcuaGFuZGxlcl1cbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGVycm9ySGFuZGxlckZuID0gdGhpc1tvcHRpb25zLnVybC5lcnJvckNvbmZpZ11cbiAgICAgIH1cbiAgICAgIG9wdGlvbnMudXJsID0gb3B0aW9ucy51cmwudXJsXG4gICAgfVxuXG4gICAgb3B0aW9ucyA9IF8uYXNzaWduKHtcbiAgICAgIGRhdGFUeXBlOiAnanNvbicsXG4gICAgICB0eXBlOiAnZ2V0JyxcbiAgICAgIHVybDogJy9ldmVudHMnLFxuICAgICAgZXJyb3JIYW5kbGVyRm46IGVycm9ySGFuZGxlckZuLFxuICAgICAgZXJyb3JIYW5kbGVyQ29uZmlnczogZXJyb3JIYW5kbGVyQ29uZmlncyxcbiAgICAgIHRyaW1TZWFyY2g6IHRydWUsXG4gICAgICBwcmVmaXg6IGVudkRldGFpbHNbJ3VybFByZWZpeCddIHx8ICcnXG4gICAgfSwgXy5tZXJnZShvcHRpb25zLCB7IGRhdGE6IHsgY3VycmVudF9sb2NhdGlvbl91dWlkOiBlbnZEZXRhaWxzLmN1cnJlbnRfbG9jYXRpb25fdXVpZCB9IH0pKVxuXG4gICAgLy8gYnkgZGVmYXVsdCB0cmltIHdoaXRlc3BhY2VzIGZyb20gYmVnaW5uaW5nIGFuZCBlbmQgb2Ygc2VhcmNoIHN0cmluZ1xuXG4gICAgaWYgKG9wdGlvbnMuZGF0YSAmJiAodHlwZW9mIG9wdGlvbnMuZGF0YS5zZWFyY2ggPT09ICdzdHJpbmcnKSAmJiBvcHRpb25zLnRyaW1TZWFyY2gpIHtcbiAgICAgIG9wdGlvbnMuZGF0YS5zZWFyY2ggPSBvcHRpb25zLmRhdGEuc2VhcmNoLnRyaW1TcGFjZXNGb3JTZWFyY2goKVxuICAgIH1cblxuICAgIGlmICghL15odHRwcz8vLnRlc3Qob3B0aW9uc1sndXJsJ10pKSB7XG4gICAgICBvcHRpb25zWyd1cmwnXSA9IG9wdGlvbnNbJ3ByZWZpeCddICsgb3B0aW9uc1sndXJsJ11cbiAgICB9XG4gICAgdmFyIHByb21pc2UgPSAkLmFqYXgob3B0aW9ucylcbiAgICByZXR1cm4gcHJvbWlzZVxuICB9LFxuXG4gIGFkZFJlbW92ZUNhY2hlOiBmdW5jdGlvbiAodXJsLCBwcm9taXNlKSB7XG4gICAgaWYodGhpcy5BUElfY2FjaGVbdXJsXSAmJiB0aGlzLkFQSV9jYWNoZVt1cmxdLnN0YXRlKCkgIT0gJ3Jlc29sdmVkJykge1xuICAgICAgICB0aGlzLkFQSV9jYWNoZVt1cmxdLmFib3J0KClcbiAgICB9XG4gICAgZGVsZXRlIHRoaXMuQVBJX2NhY2hlW3VybF1cbiAgICB0aGlzLkFQSV9jYWNoZVt1cmxdID0gcHJvbWlzZVxuICB9LFxuXG4gIHNldFBhZ2VMb2FkZXI6IGZ1bmN0aW9uICh7dXJsLCBzZWN0aW9uTG9hZGVyLCBidG5zVG9EaXNhYmxlfSkge1xuICAgICAgZW52RGV0YWlscy5zdGFydFBhZ2VMb2FkZXIgPSBmYWxzZVxuICAgICAgaWYoIXRoaXMuQVBJX2NhY2hlW3VybF0pIHtcbiAgICAgICAgdGhpcy50b2dnbGVTZWN0aW9uTG9hZGVyKHNlY3Rpb25Mb2FkZXIpXG4gICAgICAgIHRoaXMuZGlzYWJsZVdoaWxlRmV0Y2hpbmdEYXRhKHRydWUsIGJ0bnNUb0Rpc2FibGUpXG4gICAgICB9XG4gIH0sXG5cbiAgVWlBY3Rpb25zT25VcGRhdGU6IGZ1bmN0aW9uICh7dXJsLCBzZWN0aW9uTG9hZGVyLCBidG5zVG9EaXNhYmxlfSkge1xuICAgIGRlbGV0ZSB0aGlzLkFQSV9jYWNoZVt1cmxdXG4gICAgdGhpcy50b2dnbGVTZWN0aW9uTG9hZGVyKHNlY3Rpb25Mb2FkZXIpXG4gICAgdGhpcy5kaXNhYmxlV2hpbGVGZXRjaGluZ0RhdGEoZmFsc2UsIGJ0bnNUb0Rpc2FibGUpXG4gIH0sXG5cbiAgdG9nZ2xlU2VjdGlvbkxvYWRlcjogZnVuY3Rpb24oc2VjdGlvbkxvYWRlcikge1xuICAgICAgJChzZWN0aW9uTG9hZGVyKS50b2dnbGVDbGFzcygnaGlkZScpXG4gIH0sXG5cbiAgZGlzYWJsZVdoaWxlRmV0Y2hpbmdEYXRhOiBmdW5jdGlvbihzaG91bGREaXNhYmxlLGVsbXMpIHtcbiAgICAgICQoZWxtcykuYXR0cignZGlzYWJsZWQnLCBzaG91bGREaXNhYmxlKVxuICB9XG5cbn1cblxuXG5tb2R1bGUuZXhwb3J0cyA9IEFwaVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuLy8gaXN0YW5idWwgaWdub3JlIG5leHRcblxuZnVuY3Rpb24gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChvYmopIHsgcmV0dXJuIG9iaiAmJiBvYmouX19lc01vZHVsZSA/IG9iaiA6IHsgJ2RlZmF1bHQnOiBvYmogfTsgfVxuXG4vLyBpc3RhbmJ1bCBpZ25vcmUgbmV4dFxuXG5mdW5jdGlvbiBfaW50ZXJvcFJlcXVpcmVXaWxkY2FyZChvYmopIHsgaWYgKG9iaiAmJiBvYmouX19lc01vZHVsZSkgeyByZXR1cm4gb2JqOyB9IGVsc2UgeyB2YXIgbmV3T2JqID0ge307IGlmIChvYmogIT0gbnVsbCkgeyBmb3IgKHZhciBrZXkgaW4gb2JqKSB7IGlmIChPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwob2JqLCBrZXkpKSBuZXdPYmpba2V5XSA9IG9ialtrZXldOyB9IH0gbmV3T2JqWydkZWZhdWx0J10gPSBvYmo7IHJldHVybiBuZXdPYmo7IH0gfVxuXG52YXIgX2hhbmRsZWJhcnNCYXNlID0gcmVxdWlyZSgnLi9oYW5kbGViYXJzL2Jhc2UnKTtcblxudmFyIGJhc2UgPSBfaW50ZXJvcFJlcXVpcmVXaWxkY2FyZChfaGFuZGxlYmFyc0Jhc2UpO1xuXG4vLyBFYWNoIG9mIHRoZXNlIGF1Z21lbnQgdGhlIEhhbmRsZWJhcnMgb2JqZWN0LiBObyBuZWVkIHRvIHNldHVwIGhlcmUuXG4vLyAoVGhpcyBpcyBkb25lIHRvIGVhc2lseSBzaGFyZSBjb2RlIGJldHdlZW4gY29tbW9uanMgYW5kIGJyb3dzZSBlbnZzKVxuXG52YXIgX2hhbmRsZWJhcnNTYWZlU3RyaW5nID0gcmVxdWlyZSgnLi9oYW5kbGViYXJzL3NhZmUtc3RyaW5nJyk7XG5cbnZhciBfaGFuZGxlYmFyc1NhZmVTdHJpbmcyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfaGFuZGxlYmFyc1NhZmVTdHJpbmcpO1xuXG52YXIgX2hhbmRsZWJhcnNFeGNlcHRpb24gPSByZXF1aXJlKCcuL2hhbmRsZWJhcnMvZXhjZXB0aW9uJyk7XG5cbnZhciBfaGFuZGxlYmFyc0V4Y2VwdGlvbjIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9oYW5kbGViYXJzRXhjZXB0aW9uKTtcblxudmFyIF9oYW5kbGViYXJzVXRpbHMgPSByZXF1aXJlKCcuL2hhbmRsZWJhcnMvdXRpbHMnKTtcblxudmFyIFV0aWxzID0gX2ludGVyb3BSZXF1aXJlV2lsZGNhcmQoX2hhbmRsZWJhcnNVdGlscyk7XG5cbnZhciBfaGFuZGxlYmFyc1J1bnRpbWUgPSByZXF1aXJlKCcuL2hhbmRsZWJhcnMvcnVudGltZScpO1xuXG52YXIgcnVudGltZSA9IF9pbnRlcm9wUmVxdWlyZVdpbGRjYXJkKF9oYW5kbGViYXJzUnVudGltZSk7XG5cbnZhciBfaGFuZGxlYmFyc05vQ29uZmxpY3QgPSByZXF1aXJlKCcuL2hhbmRsZWJhcnMvbm8tY29uZmxpY3QnKTtcblxudmFyIF9oYW5kbGViYXJzTm9Db25mbGljdDIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9oYW5kbGViYXJzTm9Db25mbGljdCk7XG5cbi8vIEZvciBjb21wYXRpYmlsaXR5IGFuZCB1c2FnZSBvdXRzaWRlIG9mIG1vZHVsZSBzeXN0ZW1zLCBtYWtlIHRoZSBIYW5kbGViYXJzIG9iamVjdCBhIG5hbWVzcGFjZVxuZnVuY3Rpb24gY3JlYXRlKCkge1xuICB2YXIgaGIgPSBuZXcgYmFzZS5IYW5kbGViYXJzRW52aXJvbm1lbnQoKTtcblxuICBVdGlscy5leHRlbmQoaGIsIGJhc2UpO1xuICBoYi5TYWZlU3RyaW5nID0gX2hhbmRsZWJhcnNTYWZlU3RyaW5nMlsnZGVmYXVsdCddO1xuICBoYi5FeGNlcHRpb24gPSBfaGFuZGxlYmFyc0V4Y2VwdGlvbjJbJ2RlZmF1bHQnXTtcbiAgaGIuVXRpbHMgPSBVdGlscztcbiAgaGIuZXNjYXBlRXhwcmVzc2lvbiA9IFV0aWxzLmVzY2FwZUV4cHJlc3Npb247XG5cbiAgaGIuVk0gPSBydW50aW1lO1xuICBoYi50ZW1wbGF0ZSA9IGZ1bmN0aW9uIChzcGVjKSB7XG4gICAgcmV0dXJuIHJ1bnRpbWUudGVtcGxhdGUoc3BlYywgaGIpO1xuICB9O1xuXG4gIHJldHVybiBoYjtcbn1cblxudmFyIGluc3QgPSBjcmVhdGUoKTtcbmluc3QuY3JlYXRlID0gY3JlYXRlO1xuXG5faGFuZGxlYmFyc05vQ29uZmxpY3QyWydkZWZhdWx0J10oaW5zdCk7XG5cbmluc3RbJ2RlZmF1bHQnXSA9IGluc3Q7XG5cbmV4cG9ydHNbJ2RlZmF1bHQnXSA9IGluc3Q7XG5tb2R1bGUuZXhwb3J0cyA9IGV4cG9ydHNbJ2RlZmF1bHQnXTtcbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1TDJ4cFlpOW9ZVzVrYkdWaVlYSnpMbkoxYm5ScGJXVXVhbk1pWFN3aWJtRnRaWE1pT2x0ZExDSnRZWEJ3YVc1bmN5STZJanM3T3pzN096czdPenM3T0VKQlFYTkNMRzFDUVVGdFFqczdTVUZCTjBJc1NVRkJTVHM3T3pzN2IwTkJTVThzTUVKQlFUQkNPenM3TzIxRFFVTXpRaXgzUWtGQmQwSTdPenM3SzBKQlEzWkNMRzlDUVVGdlFqczdTVUZCTDBJc1MwRkJTenM3YVVOQlExRXNjMEpCUVhOQ096dEpRVUZ1UXl4UFFVRlBPenR2UTBGRlNTd3dRa0ZCTUVJN096czdPMEZCUjJwRUxGTkJRVk1zVFVGQlRTeEhRVUZITzBGQlEyaENMRTFCUVVrc1JVRkJSU3hIUVVGSExFbEJRVWtzU1VGQlNTeERRVUZETEhGQ1FVRnhRaXhGUVVGRkxFTkJRVU03TzBGQlJURkRMRTlCUVVzc1EwRkJReXhOUVVGTkxFTkJRVU1zUlVGQlJTeEZRVUZGTEVsQlFVa3NRMEZCUXl4RFFVRkRPMEZCUTNaQ0xFbEJRVVVzUTBGQlF5eFZRVUZWTEc5RFFVRmhMRU5CUVVNN1FVRkRNMElzU1VGQlJTeERRVUZETEZOQlFWTXNiVU5CUVZrc1EwRkJRenRCUVVONlFpeEpRVUZGTEVOQlFVTXNTMEZCU3l4SFFVRkhMRXRCUVVzc1EwRkJRenRCUVVOcVFpeEpRVUZGTEVOQlFVTXNaMEpCUVdkQ0xFZEJRVWNzUzBGQlN5eERRVUZETEdkQ1FVRm5RaXhEUVVGRE96dEJRVVUzUXl4SlFVRkZMRU5CUVVNc1JVRkJSU3hIUVVGSExFOUJRVThzUTBGQlF6dEJRVU5vUWl4SlFVRkZMRU5CUVVNc1VVRkJVU3hIUVVGSExGVkJRVk1zU1VGQlNTeEZRVUZGTzBGQlF6TkNMRmRCUVU4c1QwRkJUeXhEUVVGRExGRkJRVkVzUTBGQlF5eEpRVUZKTEVWQlFVVXNSVUZCUlN4RFFVRkRMRU5CUVVNN1IwRkRia01zUTBGQlF6czdRVUZGUml4VFFVRlBMRVZCUVVVc1EwRkJRenREUVVOWU96dEJRVVZFTEVsQlFVa3NTVUZCU1N4SFFVRkhMRTFCUVUwc1JVRkJSU3hEUVVGRE8wRkJRM0JDTEVsQlFVa3NRMEZCUXl4TlFVRk5MRWRCUVVjc1RVRkJUU3hEUVVGRE96dEJRVVZ5UWl4clEwRkJWeXhKUVVGSkxFTkJRVU1zUTBGQlF6czdRVUZGYWtJc1NVRkJTU3hEUVVGRExGTkJRVk1zUTBGQlF5eEhRVUZITEVsQlFVa3NRMEZCUXpzN2NVSkJSVklzU1VGQlNTSXNJbVpwYkdVaU9pSm9ZVzVrYkdWaVlYSnpMbkoxYm5ScGJXVXVhbk1pTENKemIzVnlZMlZ6UTI5dWRHVnVkQ0k2V3lKcGJYQnZjblFnS2lCaGN5QmlZWE5sSUdaeWIyMGdKeTR2YUdGdVpHeGxZbUZ5Y3k5aVlYTmxKenRjYmx4dUx5OGdSV0ZqYUNCdlppQjBhR1Z6WlNCaGRXZHRaVzUwSUhSb1pTQklZVzVrYkdWaVlYSnpJRzlpYW1WamRDNGdUbThnYm1WbFpDQjBieUJ6WlhSMWNDQm9aWEpsTGx4dUx5OGdLRlJvYVhNZ2FYTWdaRzl1WlNCMGJ5QmxZWE5wYkhrZ2MyaGhjbVVnWTI5a1pTQmlaWFIzWldWdUlHTnZiVzF2Ym1weklHRnVaQ0JpY205M2MyVWdaVzUyY3lsY2JtbHRjRzl5ZENCVFlXWmxVM1J5YVc1bklHWnliMjBnSnk0dmFHRnVaR3hsWW1GeWN5OXpZV1psTFhOMGNtbHVaeWM3WEc1cGJYQnZjblFnUlhoalpYQjBhVzl1SUdaeWIyMGdKeTR2YUdGdVpHeGxZbUZ5Y3k5bGVHTmxjSFJwYjI0bk8xeHVhVzF3YjNKMElDb2dZWE1nVlhScGJITWdabkp2YlNBbkxpOW9ZVzVrYkdWaVlYSnpMM1YwYVd4ekp6dGNibWx0Y0c5eWRDQXFJR0Z6SUhKMWJuUnBiV1VnWm5KdmJTQW5MaTlvWVc1a2JHVmlZWEp6TDNKMWJuUnBiV1VuTzF4dVhHNXBiWEJ2Y25RZ2JtOURiMjVtYkdsamRDQm1jbTl0SUNjdUwyaGhibVJzWldKaGNuTXZibTh0WTI5dVpteHBZM1FuTzF4dVhHNHZMeUJHYjNJZ1kyOXRjR0YwYVdKcGJHbDBlU0JoYm1RZ2RYTmhaMlVnYjNWMGMybGtaU0J2WmlCdGIyUjFiR1VnYzNsemRHVnRjeXdnYldGclpTQjBhR1VnU0dGdVpHeGxZbUZ5Y3lCdlltcGxZM1FnWVNCdVlXMWxjM0JoWTJWY2JtWjFibU4wYVc5dUlHTnlaV0YwWlNncElIdGNiaUFnYkdWMElHaGlJRDBnYm1WM0lHSmhjMlV1U0dGdVpHeGxZbUZ5YzBWdWRtbHliMjV0Wlc1MEtDazdYRzVjYmlBZ1ZYUnBiSE11WlhoMFpXNWtLR2hpTENCaVlYTmxLVHRjYmlBZ2FHSXVVMkZtWlZOMGNtbHVaeUE5SUZOaFptVlRkSEpwYm1jN1hHNGdJR2hpTGtWNFkyVndkR2x2YmlBOUlFVjRZMlZ3ZEdsdmJqdGNiaUFnYUdJdVZYUnBiSE1nUFNCVmRHbHNjenRjYmlBZ2FHSXVaWE5qWVhCbFJYaHdjbVZ6YzJsdmJpQTlJRlYwYVd4ekxtVnpZMkZ3WlVWNGNISmxjM05wYjI0N1hHNWNiaUFnYUdJdVZrMGdQU0J5ZFc1MGFXMWxPMXh1SUNCb1lpNTBaVzF3YkdGMFpTQTlJR1oxYm1OMGFXOXVLSE53WldNcElIdGNiaUFnSUNCeVpYUjFjbTRnY25WdWRHbHRaUzUwWlcxd2JHRjBaU2h6Y0dWakxDQm9ZaWs3WEc0Z0lIMDdYRzVjYmlBZ2NtVjBkWEp1SUdoaU8xeHVmVnh1WEc1c1pYUWdhVzV6ZENBOUlHTnlaV0YwWlNncE8xeHVhVzV6ZEM1amNtVmhkR1VnUFNCamNtVmhkR1U3WEc1Y2JtNXZRMjl1Wm14cFkzUW9hVzV6ZENrN1hHNWNibWx1YzNSYkoyUmxabUYxYkhRblhTQTlJR2x1YzNRN1hHNWNibVY0Y0c5eWRDQmtaV1poZFd4MElHbHVjM1E3WEc0aVhYMD1cbiIsIid1c2Ugc3RyaWN0JztcblxuZXhwb3J0cy5fX2VzTW9kdWxlID0gdHJ1ZTtcbmV4cG9ydHMuSGFuZGxlYmFyc0Vudmlyb25tZW50ID0gSGFuZGxlYmFyc0Vudmlyb25tZW50O1xuLy8gaXN0YW5idWwgaWdub3JlIG5leHRcblxuZnVuY3Rpb24gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChvYmopIHsgcmV0dXJuIG9iaiAmJiBvYmouX19lc01vZHVsZSA/IG9iaiA6IHsgJ2RlZmF1bHQnOiBvYmogfTsgfVxuXG52YXIgX3V0aWxzID0gcmVxdWlyZSgnLi91dGlscycpO1xuXG52YXIgX2V4Y2VwdGlvbiA9IHJlcXVpcmUoJy4vZXhjZXB0aW9uJyk7XG5cbnZhciBfZXhjZXB0aW9uMiA9IF9pbnRlcm9wUmVxdWlyZURlZmF1bHQoX2V4Y2VwdGlvbik7XG5cbnZhciBfaGVscGVycyA9IHJlcXVpcmUoJy4vaGVscGVycycpO1xuXG52YXIgX2RlY29yYXRvcnMgPSByZXF1aXJlKCcuL2RlY29yYXRvcnMnKTtcblxudmFyIF9sb2dnZXIgPSByZXF1aXJlKCcuL2xvZ2dlcicpO1xuXG52YXIgX2xvZ2dlcjIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9sb2dnZXIpO1xuXG52YXIgVkVSU0lPTiA9ICc0LjEuMic7XG5leHBvcnRzLlZFUlNJT04gPSBWRVJTSU9OO1xudmFyIENPTVBJTEVSX1JFVklTSU9OID0gNztcblxuZXhwb3J0cy5DT01QSUxFUl9SRVZJU0lPTiA9IENPTVBJTEVSX1JFVklTSU9OO1xudmFyIFJFVklTSU9OX0NIQU5HRVMgPSB7XG4gIDE6ICc8PSAxLjAucmMuMicsIC8vIDEuMC5yYy4yIGlzIGFjdHVhbGx5IHJldjIgYnV0IGRvZXNuJ3QgcmVwb3J0IGl0XG4gIDI6ICc9PSAxLjAuMC1yYy4zJyxcbiAgMzogJz09IDEuMC4wLXJjLjQnLFxuICA0OiAnPT0gMS54LngnLFxuICA1OiAnPT0gMi4wLjAtYWxwaGEueCcsXG4gIDY6ICc+PSAyLjAuMC1iZXRhLjEnLFxuICA3OiAnPj0gNC4wLjAnXG59O1xuXG5leHBvcnRzLlJFVklTSU9OX0NIQU5HRVMgPSBSRVZJU0lPTl9DSEFOR0VTO1xudmFyIG9iamVjdFR5cGUgPSAnW29iamVjdCBPYmplY3RdJztcblxuZnVuY3Rpb24gSGFuZGxlYmFyc0Vudmlyb25tZW50KGhlbHBlcnMsIHBhcnRpYWxzLCBkZWNvcmF0b3JzKSB7XG4gIHRoaXMuaGVscGVycyA9IGhlbHBlcnMgfHwge307XG4gIHRoaXMucGFydGlhbHMgPSBwYXJ0aWFscyB8fCB7fTtcbiAgdGhpcy5kZWNvcmF0b3JzID0gZGVjb3JhdG9ycyB8fCB7fTtcblxuICBfaGVscGVycy5yZWdpc3RlckRlZmF1bHRIZWxwZXJzKHRoaXMpO1xuICBfZGVjb3JhdG9ycy5yZWdpc3RlckRlZmF1bHREZWNvcmF0b3JzKHRoaXMpO1xufVxuXG5IYW5kbGViYXJzRW52aXJvbm1lbnQucHJvdG90eXBlID0ge1xuICBjb25zdHJ1Y3RvcjogSGFuZGxlYmFyc0Vudmlyb25tZW50LFxuXG4gIGxvZ2dlcjogX2xvZ2dlcjJbJ2RlZmF1bHQnXSxcbiAgbG9nOiBfbG9nZ2VyMlsnZGVmYXVsdCddLmxvZyxcblxuICByZWdpc3RlckhlbHBlcjogZnVuY3Rpb24gcmVnaXN0ZXJIZWxwZXIobmFtZSwgZm4pIHtcbiAgICBpZiAoX3V0aWxzLnRvU3RyaW5nLmNhbGwobmFtZSkgPT09IG9iamVjdFR5cGUpIHtcbiAgICAgIGlmIChmbikge1xuICAgICAgICB0aHJvdyBuZXcgX2V4Y2VwdGlvbjJbJ2RlZmF1bHQnXSgnQXJnIG5vdCBzdXBwb3J0ZWQgd2l0aCBtdWx0aXBsZSBoZWxwZXJzJyk7XG4gICAgICB9XG4gICAgICBfdXRpbHMuZXh0ZW5kKHRoaXMuaGVscGVycywgbmFtZSk7XG4gICAgfSBlbHNlIHtcbiAgICAgIHRoaXMuaGVscGVyc1tuYW1lXSA9IGZuO1xuICAgIH1cbiAgfSxcbiAgdW5yZWdpc3RlckhlbHBlcjogZnVuY3Rpb24gdW5yZWdpc3RlckhlbHBlcihuYW1lKSB7XG4gICAgZGVsZXRlIHRoaXMuaGVscGVyc1tuYW1lXTtcbiAgfSxcblxuICByZWdpc3RlclBhcnRpYWw6IGZ1bmN0aW9uIHJlZ2lzdGVyUGFydGlhbChuYW1lLCBwYXJ0aWFsKSB7XG4gICAgaWYgKF91dGlscy50b1N0cmluZy5jYWxsKG5hbWUpID09PSBvYmplY3RUeXBlKSB7XG4gICAgICBfdXRpbHMuZXh0ZW5kKHRoaXMucGFydGlhbHMsIG5hbWUpO1xuICAgIH0gZWxzZSB7XG4gICAgICBpZiAodHlwZW9mIHBhcnRpYWwgPT09ICd1bmRlZmluZWQnKSB7XG4gICAgICAgIHRocm93IG5ldyBfZXhjZXB0aW9uMlsnZGVmYXVsdCddKCdBdHRlbXB0aW5nIHRvIHJlZ2lzdGVyIGEgcGFydGlhbCBjYWxsZWQgXCInICsgbmFtZSArICdcIiBhcyB1bmRlZmluZWQnKTtcbiAgICAgIH1cbiAgICAgIHRoaXMucGFydGlhbHNbbmFtZV0gPSBwYXJ0aWFsO1xuICAgIH1cbiAgfSxcbiAgdW5yZWdpc3RlclBhcnRpYWw6IGZ1bmN0aW9uIHVucmVnaXN0ZXJQYXJ0aWFsKG5hbWUpIHtcbiAgICBkZWxldGUgdGhpcy5wYXJ0aWFsc1tuYW1lXTtcbiAgfSxcblxuICByZWdpc3RlckRlY29yYXRvcjogZnVuY3Rpb24gcmVnaXN0ZXJEZWNvcmF0b3IobmFtZSwgZm4pIHtcbiAgICBpZiAoX3V0aWxzLnRvU3RyaW5nLmNhbGwobmFtZSkgPT09IG9iamVjdFR5cGUpIHtcbiAgICAgIGlmIChmbikge1xuICAgICAgICB0aHJvdyBuZXcgX2V4Y2VwdGlvbjJbJ2RlZmF1bHQnXSgnQXJnIG5vdCBzdXBwb3J0ZWQgd2l0aCBtdWx0aXBsZSBkZWNvcmF0b3JzJyk7XG4gICAgICB9XG4gICAgICBfdXRpbHMuZXh0ZW5kKHRoaXMuZGVjb3JhdG9ycywgbmFtZSk7XG4gICAgfSBlbHNlIHtcbiAgICAgIHRoaXMuZGVjb3JhdG9yc1tuYW1lXSA9IGZuO1xuICAgIH1cbiAgfSxcbiAgdW5yZWdpc3RlckRlY29yYXRvcjogZnVuY3Rpb24gdW5yZWdpc3RlckRlY29yYXRvcihuYW1lKSB7XG4gICAgZGVsZXRlIHRoaXMuZGVjb3JhdG9yc1tuYW1lXTtcbiAgfVxufTtcblxudmFyIGxvZyA9IF9sb2dnZXIyWydkZWZhdWx0J10ubG9nO1xuXG5leHBvcnRzLmxvZyA9IGxvZztcbmV4cG9ydHMuY3JlYXRlRnJhbWUgPSBfdXRpbHMuY3JlYXRlRnJhbWU7XG5leHBvcnRzLmxvZ2dlciA9IF9sb2dnZXIyWydkZWZhdWx0J107XG4vLyMgc291cmNlTWFwcGluZ1VSTD1kYXRhOmFwcGxpY2F0aW9uL2pzb247Y2hhcnNldD11dGYtODtiYXNlNjQsZXlKMlpYSnphVzl1SWpvekxDSnpiM1Z5WTJWeklqcGJJaTR1THk0dUx5NHVMMnhwWWk5b1lXNWtiR1ZpWVhKekwySmhjMlV1YW5NaVhTd2libUZ0WlhNaU9sdGRMQ0p0WVhCd2FXNW5jeUk2SWpzN096czdPenM3Y1VKQlFUUkRMRk5CUVZNN08zbENRVU12UWl4aFFVRmhPenM3TzNWQ1FVTkZMRmRCUVZjN096QkNRVU5TTEdOQlFXTTdPM05DUVVOdVF5eFZRVUZWT3pzN08wRkJSWFJDTEVsQlFVMHNUMEZCVHl4SFFVRkhMRTlCUVU4c1EwRkJRenM3UVVGRGVFSXNTVUZCVFN4cFFrRkJhVUlzUjBGQlJ5eERRVUZETEVOQlFVTTdPenRCUVVVMVFpeEpRVUZOTEdkQ1FVRm5RaXhIUVVGSE8wRkJRemxDTEVkQlFVTXNSVUZCUlN4aFFVRmhPMEZCUTJoQ0xFZEJRVU1zUlVGQlJTeGxRVUZsTzBGQlEyeENMRWRCUVVNc1JVRkJSU3hsUVVGbE8wRkJRMnhDTEVkQlFVTXNSVUZCUlN4VlFVRlZPMEZCUTJJc1IwRkJReXhGUVVGRkxHdENRVUZyUWp0QlFVTnlRaXhIUVVGRExFVkJRVVVzYVVKQlFXbENPMEZCUTNCQ0xFZEJRVU1zUlVGQlJTeFZRVUZWTzBOQlEyUXNRMEZCUXpzN08wRkJSVVlzU1VGQlRTeFZRVUZWTEVkQlFVY3NhVUpCUVdsQ0xFTkJRVU03TzBGQlJUbENMRk5CUVZNc2NVSkJRWEZDTEVOQlFVTXNUMEZCVHl4RlFVRkZMRkZCUVZFc1JVRkJSU3hWUVVGVkxFVkJRVVU3UVVGRGJrVXNUVUZCU1N4RFFVRkRMRTlCUVU4c1IwRkJSeXhQUVVGUExFbEJRVWtzUlVGQlJTeERRVUZETzBGQlF6ZENMRTFCUVVrc1EwRkJReXhSUVVGUkxFZEJRVWNzVVVGQlVTeEpRVUZKTEVWQlFVVXNRMEZCUXp0QlFVTXZRaXhOUVVGSkxFTkJRVU1zVlVGQlZTeEhRVUZITEZWQlFWVXNTVUZCU1N4RlFVRkZMRU5CUVVNN08wRkJSVzVETEd0RFFVRjFRaXhKUVVGSkxFTkJRVU1zUTBGQlF6dEJRVU0zUWl4M1EwRkJNRUlzU1VGQlNTeERRVUZETEVOQlFVTTdRMEZEYWtNN08wRkJSVVFzY1VKQlFYRkNMRU5CUVVNc1UwRkJVeXhIUVVGSE8wRkJRMmhETEdGQlFWY3NSVUZCUlN4eFFrRkJjVUk3TzBGQlJXeERMRkZCUVUwc2NVSkJRVkU3UVVGRFpDeExRVUZITEVWQlFVVXNiMEpCUVU4c1IwRkJSenM3UVVGRlppeG5Ra0ZCWXl4RlFVRkZMSGRDUVVGVExFbEJRVWtzUlVGQlJTeEZRVUZGTEVWQlFVVTdRVUZEYWtNc1VVRkJTU3huUWtGQlV5eEpRVUZKTEVOQlFVTXNTVUZCU1N4RFFVRkRMRXRCUVVzc1ZVRkJWU3hGUVVGRk8wRkJRM1JETEZWQlFVa3NSVUZCUlN4RlFVRkZPMEZCUVVVc1kwRkJUU3d5UWtGQll5eDVRMEZCZVVNc1EwRkJReXhEUVVGRE8wOUJRVVU3UVVGRE0wVXNiMEpCUVU4c1NVRkJTU3hEUVVGRExFOUJRVThzUlVGQlJTeEpRVUZKTEVOQlFVTXNRMEZCUXp0TFFVTTFRaXhOUVVGTk8wRkJRMHdzVlVGQlNTeERRVUZETEU5QlFVOHNRMEZCUXl4SlFVRkpMRU5CUVVNc1IwRkJSeXhGUVVGRkxFTkJRVU03UzBGRGVrSTdSMEZEUmp0QlFVTkVMR3RDUVVGblFpeEZRVUZGTERCQ1FVRlRMRWxCUVVrc1JVRkJSVHRCUVVNdlFpeFhRVUZQTEVsQlFVa3NRMEZCUXl4UFFVRlBMRU5CUVVNc1NVRkJTU3hEUVVGRExFTkJRVU03UjBGRE0wSTdPMEZCUlVRc2FVSkJRV1VzUlVGQlJTeDVRa0ZCVXl4SlFVRkpMRVZCUVVVc1QwRkJUeXhGUVVGRk8wRkJRM1pETEZGQlFVa3NaMEpCUVZNc1NVRkJTU3hEUVVGRExFbEJRVWtzUTBGQlF5eExRVUZMTEZWQlFWVXNSVUZCUlR0QlFVTjBReXh2UWtGQlR5eEpRVUZKTEVOQlFVTXNVVUZCVVN4RlFVRkZMRWxCUVVrc1EwRkJReXhEUVVGRE8wdEJRemRDTEUxQlFVMDdRVUZEVEN4VlFVRkpMRTlCUVU4c1QwRkJUeXhMUVVGTExGZEJRVmNzUlVGQlJUdEJRVU5zUXl4alFVRk5MSGxGUVVFd1JDeEpRVUZKTEc5Q1FVRnBRaXhEUVVGRE8wOUJRM1pHTzBGQlEwUXNWVUZCU1N4RFFVRkRMRkZCUVZFc1EwRkJReXhKUVVGSkxFTkJRVU1zUjBGQlJ5eFBRVUZQTEVOQlFVTTdTMEZETDBJN1IwRkRSanRCUVVORUxHMUNRVUZwUWl4RlFVRkZMREpDUVVGVExFbEJRVWtzUlVGQlJUdEJRVU5vUXl4WFFVRlBMRWxCUVVrc1EwRkJReXhSUVVGUkxFTkJRVU1zU1VGQlNTeERRVUZETEVOQlFVTTdSMEZETlVJN08wRkJSVVFzYlVKQlFXbENMRVZCUVVVc01rSkJRVk1zU1VGQlNTeEZRVUZGTEVWQlFVVXNSVUZCUlR0QlFVTndReXhSUVVGSkxHZENRVUZUTEVsQlFVa3NRMEZCUXl4SlFVRkpMRU5CUVVNc1MwRkJTeXhWUVVGVkxFVkJRVVU3UVVGRGRFTXNWVUZCU1N4RlFVRkZMRVZCUVVVN1FVRkJSU3hqUVVGTkxESkNRVUZqTERSRFFVRTBReXhEUVVGRExFTkJRVU03VDBGQlJUdEJRVU01UlN4dlFrRkJUeXhKUVVGSkxFTkJRVU1zVlVGQlZTeEZRVUZGTEVsQlFVa3NRMEZCUXl4RFFVRkRPMHRCUXk5Q0xFMUJRVTA3UVVGRFRDeFZRVUZKTEVOQlFVTXNWVUZCVlN4RFFVRkRMRWxCUVVrc1EwRkJReXhIUVVGSExFVkJRVVVzUTBGQlF6dExRVU0xUWp0SFFVTkdPMEZCUTBRc2NVSkJRVzFDTEVWQlFVVXNOa0pCUVZNc1NVRkJTU3hGUVVGRk8wRkJRMnhETEZkQlFVOHNTVUZCU1N4RFFVRkRMRlZCUVZVc1EwRkJReXhKUVVGSkxFTkJRVU1zUTBGQlF6dEhRVU01UWp0RFFVTkdMRU5CUVVNN08wRkJSVXNzU1VGQlNTeEhRVUZITEVkQlFVY3NiMEpCUVU4c1IwRkJSeXhEUVVGRE96czdVVUZGY0VJc1YwRkJWenRSUVVGRkxFMUJRVTBpTENKbWFXeGxJam9pWW1GelpTNXFjeUlzSW5OdmRYSmpaWE5EYjI1MFpXNTBJanBiSW1sdGNHOXlkQ0I3WTNKbFlYUmxSbkpoYldVc0lHVjRkR1Z1WkN3Z2RHOVRkSEpwYm1kOUlHWnliMjBnSnk0dmRYUnBiSE1uTzF4dWFXMXdiM0owSUVWNFkyVndkR2x2YmlCbWNtOXRJQ2N1TDJWNFkyVndkR2x2YmljN1hHNXBiWEJ2Y25RZ2UzSmxaMmx6ZEdWeVJHVm1ZWFZzZEVobGJIQmxjbk45SUdaeWIyMGdKeTR2YUdWc2NHVnljeWM3WEc1cGJYQnZjblFnZTNKbFoybHpkR1Z5UkdWbVlYVnNkRVJsWTI5eVlYUnZjbk45SUdaeWIyMGdKeTR2WkdWamIzSmhkRzl5Y3ljN1hHNXBiWEJ2Y25RZ2JHOW5aMlZ5SUdaeWIyMGdKeTR2Ykc5bloyVnlKenRjYmx4dVpYaHdiM0owSUdOdmJuTjBJRlpGVWxOSlQwNGdQU0FuTkM0eExqSW5PMXh1Wlhod2IzSjBJR052Ym5OMElFTlBUVkJKVEVWU1gxSkZWa2xUU1U5T0lEMGdOenRjYmx4dVpYaHdiM0owSUdOdmJuTjBJRkpGVmtsVFNVOU9YME5JUVU1SFJWTWdQU0I3WEc0Z0lERTZJQ2M4UFNBeExqQXVjbU11TWljc0lDOHZJREV1TUM1eVl5NHlJR2x6SUdGamRIVmhiR3g1SUhKbGRqSWdZblYwSUdSdlpYTnVKM1FnY21Wd2IzSjBJR2wwWEc0Z0lESTZJQ2M5UFNBeExqQXVNQzF5WXk0ekp5eGNiaUFnTXpvZ0p6MDlJREV1TUM0d0xYSmpMalFuTEZ4dUlDQTBPaUFuUFQwZ01TNTRMbmduTEZ4dUlDQTFPaUFuUFQwZ01pNHdMakF0WVd4d2FHRXVlQ2NzWEc0Z0lEWTZJQ2MrUFNBeUxqQXVNQzFpWlhSaExqRW5MRnh1SUNBM09pQW5QajBnTkM0d0xqQW5YRzU5TzF4dVhHNWpiMjV6ZENCdlltcGxZM1JVZVhCbElEMGdKMXR2WW1wbFkzUWdUMkpxWldOMFhTYzdYRzVjYm1WNGNHOXlkQ0JtZFc1amRHbHZiaUJJWVc1a2JHVmlZWEp6Ulc1MmFYSnZibTFsYm5Rb2FHVnNjR1Z5Y3l3Z2NHRnlkR2xoYkhNc0lHUmxZMjl5WVhSdmNuTXBJSHRjYmlBZ2RHaHBjeTVvWld4d1pYSnpJRDBnYUdWc2NHVnljeUI4ZkNCN2ZUdGNiaUFnZEdocGN5NXdZWEowYVdGc2N5QTlJSEJoY25ScFlXeHpJSHg4SUh0OU8xeHVJQ0IwYUdsekxtUmxZMjl5WVhSdmNuTWdQU0JrWldOdmNtRjBiM0p6SUh4OElIdDlPMXh1WEc0Z0lISmxaMmx6ZEdWeVJHVm1ZWFZzZEVobGJIQmxjbk1vZEdocGN5azdYRzRnSUhKbFoybHpkR1Z5UkdWbVlYVnNkRVJsWTI5eVlYUnZjbk1vZEdocGN5azdYRzU5WEc1Y2JraGhibVJzWldKaGNuTkZiblpwY205dWJXVnVkQzV3Y205MGIzUjVjR1VnUFNCN1hHNGdJR052Ym5OMGNuVmpkRzl5T2lCSVlXNWtiR1ZpWVhKelJXNTJhWEp2Ym0xbGJuUXNYRzVjYmlBZ2JHOW5aMlZ5T2lCc2IyZG5aWElzWEc0Z0lHeHZaem9nYkc5bloyVnlMbXh2Wnl4Y2JseHVJQ0J5WldkcGMzUmxja2hsYkhCbGNqb2dablZ1WTNScGIyNG9ibUZ0WlN3Z1ptNHBJSHRjYmlBZ0lDQnBaaUFvZEc5VGRISnBibWN1WTJGc2JDaHVZVzFsS1NBOVBUMGdiMkpxWldOMFZIbHdaU2tnZTF4dUlDQWdJQ0FnYVdZZ0tHWnVLU0I3SUhSb2NtOTNJRzVsZHlCRmVHTmxjSFJwYjI0b0owRnlaeUJ1YjNRZ2MzVndjRzl5ZEdWa0lIZHBkR2dnYlhWc2RHbHdiR1VnYUdWc2NHVnljeWNwT3lCOVhHNGdJQ0FnSUNCbGVIUmxibVFvZEdocGN5NW9aV3h3WlhKekxDQnVZVzFsS1R0Y2JpQWdJQ0I5SUdWc2MyVWdlMXh1SUNBZ0lDQWdkR2hwY3k1b1pXeHdaWEp6VzI1aGJXVmRJRDBnWm00N1hHNGdJQ0FnZlZ4dUlDQjlMRnh1SUNCMWJuSmxaMmx6ZEdWeVNHVnNjR1Z5T2lCbWRXNWpkR2x2YmlodVlXMWxLU0I3WEc0Z0lDQWdaR1ZzWlhSbElIUm9hWE11YUdWc2NHVnljMXR1WVcxbFhUdGNiaUFnZlN4Y2JseHVJQ0J5WldkcGMzUmxjbEJoY25ScFlXdzZJR1oxYm1OMGFXOXVLRzVoYldVc0lIQmhjblJwWVd3cElIdGNiaUFnSUNCcFppQW9kRzlUZEhKcGJtY3VZMkZzYkNodVlXMWxLU0E5UFQwZ2IySnFaV04wVkhsd1pTa2dlMXh1SUNBZ0lDQWdaWGgwWlc1a0tIUm9hWE11Y0dGeWRHbGhiSE1zSUc1aGJXVXBPMXh1SUNBZ0lIMGdaV3h6WlNCN1hHNGdJQ0FnSUNCcFppQW9kSGx3Wlc5bUlIQmhjblJwWVd3Z1BUMDlJQ2QxYm1SbFptbHVaV1FuS1NCN1hHNGdJQ0FnSUNBZ0lIUm9jbTkzSUc1bGR5QkZlR05sY0hScGIyNG9ZRUYwZEdWdGNIUnBibWNnZEc4Z2NtVm5hWE4wWlhJZ1lTQndZWEowYVdGc0lHTmhiR3hsWkNCY0lpUjdibUZ0WlgxY0lpQmhjeUIxYm1SbFptbHVaV1JnS1R0Y2JpQWdJQ0FnSUgxY2JpQWdJQ0FnSUhSb2FYTXVjR0Z5ZEdsaGJITmJibUZ0WlYwZ1BTQndZWEowYVdGc08xeHVJQ0FnSUgxY2JpQWdmU3hjYmlBZ2RXNXlaV2RwYzNSbGNsQmhjblJwWVd3NklHWjFibU4wYVc5dUtHNWhiV1VwSUh0Y2JpQWdJQ0JrWld4bGRHVWdkR2hwY3k1d1lYSjBhV0ZzYzF0dVlXMWxYVHRjYmlBZ2ZTeGNibHh1SUNCeVpXZHBjM1JsY2tSbFkyOXlZWFJ2Y2pvZ1puVnVZM1JwYjI0b2JtRnRaU3dnWm00cElIdGNiaUFnSUNCcFppQW9kRzlUZEhKcGJtY3VZMkZzYkNodVlXMWxLU0E5UFQwZ2IySnFaV04wVkhsd1pTa2dlMXh1SUNBZ0lDQWdhV1lnS0dadUtTQjdJSFJvY205M0lHNWxkeUJGZUdObGNIUnBiMjRvSjBGeVp5QnViM1FnYzNWd2NHOXlkR1ZrSUhkcGRHZ2diWFZzZEdsd2JHVWdaR1ZqYjNKaGRHOXljeWNwT3lCOVhHNGdJQ0FnSUNCbGVIUmxibVFvZEdocGN5NWtaV052Y21GMGIzSnpMQ0J1WVcxbEtUdGNiaUFnSUNCOUlHVnNjMlVnZTF4dUlDQWdJQ0FnZEdocGN5NWtaV052Y21GMGIzSnpXMjVoYldWZElEMGdabTQ3WEc0Z0lDQWdmVnh1SUNCOUxGeHVJQ0IxYm5KbFoybHpkR1Z5UkdWamIzSmhkRzl5T2lCbWRXNWpkR2x2YmlodVlXMWxLU0I3WEc0Z0lDQWdaR1ZzWlhSbElIUm9hWE11WkdWamIzSmhkRzl5YzF0dVlXMWxYVHRjYmlBZ2ZWeHVmVHRjYmx4dVpYaHdiM0owSUd4bGRDQnNiMmNnUFNCc2IyZG5aWEl1Ykc5bk8xeHVYRzVsZUhCdmNuUWdlMk55WldGMFpVWnlZVzFsTENCc2IyZG5aWEo5TzF4dUlsMTlcbiIsIid1c2Ugc3RyaWN0JztcblxuZXhwb3J0cy5fX2VzTW9kdWxlID0gdHJ1ZTtcbmV4cG9ydHMucmVnaXN0ZXJEZWZhdWx0RGVjb3JhdG9ycyA9IHJlZ2lzdGVyRGVmYXVsdERlY29yYXRvcnM7XG4vLyBpc3RhbmJ1bCBpZ25vcmUgbmV4dFxuXG5mdW5jdGlvbiBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KG9iaikgeyByZXR1cm4gb2JqICYmIG9iai5fX2VzTW9kdWxlID8gb2JqIDogeyAnZGVmYXVsdCc6IG9iaiB9OyB9XG5cbnZhciBfZGVjb3JhdG9yc0lubGluZSA9IHJlcXVpcmUoJy4vZGVjb3JhdG9ycy9pbmxpbmUnKTtcblxudmFyIF9kZWNvcmF0b3JzSW5saW5lMiA9IF9pbnRlcm9wUmVxdWlyZURlZmF1bHQoX2RlY29yYXRvcnNJbmxpbmUpO1xuXG5mdW5jdGlvbiByZWdpc3RlckRlZmF1bHREZWNvcmF0b3JzKGluc3RhbmNlKSB7XG4gIF9kZWNvcmF0b3JzSW5saW5lMlsnZGVmYXVsdCddKGluc3RhbmNlKTtcbn1cbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDJSbFkyOXlZWFJ2Y25NdWFuTWlYU3dpYm1GdFpYTWlPbHRkTENKdFlYQndhVzVuY3lJNklqczdPenM3T3pzN1owTkJRVEpDTEhGQ1FVRnhRanM3T3p0QlFVVjZReXhUUVVGVExIbENRVUY1UWl4RFFVRkRMRkZCUVZFc1JVRkJSVHRCUVVOc1JDeG5RMEZCWlN4UlFVRlJMRU5CUVVNc1EwRkJRenREUVVNeFFpSXNJbVpwYkdVaU9pSmtaV052Y21GMGIzSnpMbXB6SWl3aWMyOTFjbU5sYzBOdmJuUmxiblFpT2xzaWFXMXdiM0owSUhKbFoybHpkR1Z5U1c1c2FXNWxJR1p5YjIwZ0p5NHZaR1ZqYjNKaGRHOXljeTlwYm14cGJtVW5PMXh1WEc1bGVIQnZjblFnWm5WdVkzUnBiMjRnY21WbmFYTjBaWEpFWldaaGRXeDBSR1ZqYjNKaGRHOXljeWhwYm5OMFlXNWpaU2tnZTF4dUlDQnlaV2RwYzNSbGNrbHViR2x1WlNocGJuTjBZVzVqWlNrN1hHNTlYRzVjYmlKZGZRPT1cbiIsIid1c2Ugc3RyaWN0JztcblxuZXhwb3J0cy5fX2VzTW9kdWxlID0gdHJ1ZTtcblxudmFyIF91dGlscyA9IHJlcXVpcmUoJy4uL3V0aWxzJyk7XG5cbmV4cG9ydHNbJ2RlZmF1bHQnXSA9IGZ1bmN0aW9uIChpbnN0YW5jZSkge1xuICBpbnN0YW5jZS5yZWdpc3RlckRlY29yYXRvcignaW5saW5lJywgZnVuY3Rpb24gKGZuLCBwcm9wcywgY29udGFpbmVyLCBvcHRpb25zKSB7XG4gICAgdmFyIHJldCA9IGZuO1xuICAgIGlmICghcHJvcHMucGFydGlhbHMpIHtcbiAgICAgIHByb3BzLnBhcnRpYWxzID0ge307XG4gICAgICByZXQgPSBmdW5jdGlvbiAoY29udGV4dCwgb3B0aW9ucykge1xuICAgICAgICAvLyBDcmVhdGUgYSBuZXcgcGFydGlhbHMgc3RhY2sgZnJhbWUgcHJpb3IgdG8gZXhlYy5cbiAgICAgICAgdmFyIG9yaWdpbmFsID0gY29udGFpbmVyLnBhcnRpYWxzO1xuICAgICAgICBjb250YWluZXIucGFydGlhbHMgPSBfdXRpbHMuZXh0ZW5kKHt9LCBvcmlnaW5hbCwgcHJvcHMucGFydGlhbHMpO1xuICAgICAgICB2YXIgcmV0ID0gZm4oY29udGV4dCwgb3B0aW9ucyk7XG4gICAgICAgIGNvbnRhaW5lci5wYXJ0aWFscyA9IG9yaWdpbmFsO1xuICAgICAgICByZXR1cm4gcmV0O1xuICAgICAgfTtcbiAgICB9XG5cbiAgICBwcm9wcy5wYXJ0aWFsc1tvcHRpb25zLmFyZ3NbMF1dID0gb3B0aW9ucy5mbjtcblxuICAgIHJldHVybiByZXQ7XG4gIH0pO1xufTtcblxubW9kdWxlLmV4cG9ydHMgPSBleHBvcnRzWydkZWZhdWx0J107XG4vLyMgc291cmNlTWFwcGluZ1VSTD1kYXRhOmFwcGxpY2F0aW9uL2pzb247Y2hhcnNldD11dGYtODtiYXNlNjQsZXlKMlpYSnphVzl1SWpvekxDSnpiM1Z5WTJWeklqcGJJaTR1THk0dUx5NHVMeTR1TDJ4cFlpOW9ZVzVrYkdWaVlYSnpMMlJsWTI5eVlYUnZjbk12YVc1c2FXNWxMbXB6SWwwc0ltNWhiV1Z6SWpwYlhTd2liV0Z3Y0dsdVozTWlPaUk3T3pzN2NVSkJRWEZDTEZWQlFWVTdPM0ZDUVVWb1FpeFZRVUZUTEZGQlFWRXNSVUZCUlR0QlFVTm9ReXhWUVVGUkxFTkJRVU1zYVVKQlFXbENMRU5CUVVNc1VVRkJVU3hGUVVGRkxGVkJRVk1zUlVGQlJTeEZRVUZGTEV0QlFVc3NSVUZCUlN4VFFVRlRMRVZCUVVVc1QwRkJUeXhGUVVGRk8wRkJRek5GTEZGQlFVa3NSMEZCUnl4SFFVRkhMRVZCUVVVc1EwRkJRenRCUVVOaUxGRkJRVWtzUTBGQlF5eExRVUZMTEVOQlFVTXNVVUZCVVN4RlFVRkZPMEZCUTI1Q0xGZEJRVXNzUTBGQlF5eFJRVUZSTEVkQlFVY3NSVUZCUlN4RFFVRkRPMEZCUTNCQ0xGTkJRVWNzUjBGQlJ5eFZRVUZUTEU5QlFVOHNSVUZCUlN4UFFVRlBMRVZCUVVVN08wRkJSUzlDTEZsQlFVa3NVVUZCVVN4SFFVRkhMRk5CUVZNc1EwRkJReXhSUVVGUkxFTkJRVU03UVVGRGJFTXNhVUpCUVZNc1EwRkJReXhSUVVGUkxFZEJRVWNzWTBGQlR5eEZRVUZGTEVWQlFVVXNVVUZCVVN4RlFVRkZMRXRCUVVzc1EwRkJReXhSUVVGUkxFTkJRVU1zUTBGQlF6dEJRVU14UkN4WlFVRkpMRWRCUVVjc1IwRkJSeXhGUVVGRkxFTkJRVU1zVDBGQlR5eEZRVUZGTEU5QlFVOHNRMEZCUXl4RFFVRkRPMEZCUXk5Q0xHbENRVUZUTEVOQlFVTXNVVUZCVVN4SFFVRkhMRkZCUVZFc1EwRkJRenRCUVVNNVFpeGxRVUZQTEVkQlFVY3NRMEZCUXp0UFFVTmFMRU5CUVVNN1MwRkRTRHM3UVVGRlJDeFRRVUZMTEVOQlFVTXNVVUZCVVN4RFFVRkRMRTlCUVU4c1EwRkJReXhKUVVGSkxFTkJRVU1zUTBGQlF5eERRVUZETEVOQlFVTXNSMEZCUnl4UFFVRlBMRU5CUVVNc1JVRkJSU3hEUVVGRE96dEJRVVUzUXl4WFFVRlBMRWRCUVVjc1EwRkJRenRIUVVOYUxFTkJRVU1zUTBGQlF6dERRVU5LSWl3aVptbHNaU0k2SW1sdWJHbHVaUzVxY3lJc0luTnZkWEpqWlhORGIyNTBaVzUwSWpwYkltbHRjRzl5ZENCN1pYaDBaVzVrZlNCbWNtOXRJQ2N1TGk5MWRHbHNjeWM3WEc1Y2JtVjRjRzl5ZENCa1pXWmhkV3gwSUdaMWJtTjBhVzl1S0dsdWMzUmhibU5sS1NCN1hHNGdJR2x1YzNSaGJtTmxMbkpsWjJsemRHVnlSR1ZqYjNKaGRHOXlLQ2RwYm14cGJtVW5MQ0JtZFc1amRHbHZiaWhtYml3Z2NISnZjSE1zSUdOdmJuUmhhVzVsY2l3Z2IzQjBhVzl1Y3lrZ2UxeHVJQ0FnSUd4bGRDQnlaWFFnUFNCbWJqdGNiaUFnSUNCcFppQW9JWEJ5YjNCekxuQmhjblJwWVd4ektTQjdYRzRnSUNBZ0lDQndjbTl3Y3k1d1lYSjBhV0ZzY3lBOUlIdDlPMXh1SUNBZ0lDQWdjbVYwSUQwZ1puVnVZM1JwYjI0b1kyOXVkR1Y0ZEN3Z2IzQjBhVzl1Y3lrZ2UxeHVJQ0FnSUNBZ0lDQXZMeUJEY21WaGRHVWdZU0J1WlhjZ2NHRnlkR2xoYkhNZ2MzUmhZMnNnWm5KaGJXVWdjSEpwYjNJZ2RHOGdaWGhsWXk1Y2JpQWdJQ0FnSUNBZ2JHVjBJRzl5YVdkcGJtRnNJRDBnWTI5dWRHRnBibVZ5TG5CaGNuUnBZV3h6TzF4dUlDQWdJQ0FnSUNCamIyNTBZV2x1WlhJdWNHRnlkR2xoYkhNZ1BTQmxlSFJsYm1Rb2UzMHNJRzl5YVdkcGJtRnNMQ0J3Y205d2N5NXdZWEowYVdGc2N5azdYRzRnSUNBZ0lDQWdJR3hsZENCeVpYUWdQU0JtYmloamIyNTBaWGgwTENCdmNIUnBiMjV6S1R0Y2JpQWdJQ0FnSUNBZ1kyOXVkR0ZwYm1WeUxuQmhjblJwWVd4eklEMGdiM0pwWjJsdVlXdzdYRzRnSUNBZ0lDQWdJSEpsZEhWeWJpQnlaWFE3WEc0Z0lDQWdJQ0I5TzF4dUlDQWdJSDFjYmx4dUlDQWdJSEJ5YjNCekxuQmhjblJwWVd4elcyOXdkR2x2Ym5NdVlYSm5jMXN3WFYwZ1BTQnZjSFJwYjI1ekxtWnVPMXh1WEc0Z0lDQWdjbVYwZFhKdUlISmxkRHRjYmlBZ2ZTazdYRzU5WEc0aVhYMD1cbiIsIid1c2Ugc3RyaWN0JztcblxuZXhwb3J0cy5fX2VzTW9kdWxlID0gdHJ1ZTtcblxudmFyIGVycm9yUHJvcHMgPSBbJ2Rlc2NyaXB0aW9uJywgJ2ZpbGVOYW1lJywgJ2xpbmVOdW1iZXInLCAnbWVzc2FnZScsICduYW1lJywgJ251bWJlcicsICdzdGFjayddO1xuXG5mdW5jdGlvbiBFeGNlcHRpb24obWVzc2FnZSwgbm9kZSkge1xuICB2YXIgbG9jID0gbm9kZSAmJiBub2RlLmxvYyxcbiAgICAgIGxpbmUgPSB1bmRlZmluZWQsXG4gICAgICBjb2x1bW4gPSB1bmRlZmluZWQ7XG4gIGlmIChsb2MpIHtcbiAgICBsaW5lID0gbG9jLnN0YXJ0LmxpbmU7XG4gICAgY29sdW1uID0gbG9jLnN0YXJ0LmNvbHVtbjtcblxuICAgIG1lc3NhZ2UgKz0gJyAtICcgKyBsaW5lICsgJzonICsgY29sdW1uO1xuICB9XG5cbiAgdmFyIHRtcCA9IEVycm9yLnByb3RvdHlwZS5jb25zdHJ1Y3Rvci5jYWxsKHRoaXMsIG1lc3NhZ2UpO1xuXG4gIC8vIFVuZm9ydHVuYXRlbHkgZXJyb3JzIGFyZSBub3QgZW51bWVyYWJsZSBpbiBDaHJvbWUgKGF0IGxlYXN0KSwgc28gYGZvciBwcm9wIGluIHRtcGAgZG9lc24ndCB3b3JrLlxuICBmb3IgKHZhciBpZHggPSAwOyBpZHggPCBlcnJvclByb3BzLmxlbmd0aDsgaWR4KyspIHtcbiAgICB0aGlzW2Vycm9yUHJvcHNbaWR4XV0gPSB0bXBbZXJyb3JQcm9wc1tpZHhdXTtcbiAgfVxuXG4gIC8qIGlzdGFuYnVsIGlnbm9yZSBlbHNlICovXG4gIGlmIChFcnJvci5jYXB0dXJlU3RhY2tUcmFjZSkge1xuICAgIEVycm9yLmNhcHR1cmVTdGFja1RyYWNlKHRoaXMsIEV4Y2VwdGlvbik7XG4gIH1cblxuICB0cnkge1xuICAgIGlmIChsb2MpIHtcbiAgICAgIHRoaXMubGluZU51bWJlciA9IGxpbmU7XG5cbiAgICAgIC8vIFdvcmsgYXJvdW5kIGlzc3VlIHVuZGVyIHNhZmFyaSB3aGVyZSB3ZSBjYW4ndCBkaXJlY3RseSBzZXQgdGhlIGNvbHVtbiB2YWx1ZVxuICAgICAgLyogaXN0YW5idWwgaWdub3JlIG5leHQgKi9cbiAgICAgIGlmIChPYmplY3QuZGVmaW5lUHJvcGVydHkpIHtcbiAgICAgICAgT2JqZWN0LmRlZmluZVByb3BlcnR5KHRoaXMsICdjb2x1bW4nLCB7XG4gICAgICAgICAgdmFsdWU6IGNvbHVtbixcbiAgICAgICAgICBlbnVtZXJhYmxlOiB0cnVlXG4gICAgICAgIH0pO1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhpcy5jb2x1bW4gPSBjb2x1bW47XG4gICAgICB9XG4gICAgfVxuICB9IGNhdGNoIChub3ApIHtcbiAgICAvKiBJZ25vcmUgaWYgdGhlIGJyb3dzZXIgaXMgdmVyeSBwYXJ0aWN1bGFyICovXG4gIH1cbn1cblxuRXhjZXB0aW9uLnByb3RvdHlwZSA9IG5ldyBFcnJvcigpO1xuXG5leHBvcnRzWydkZWZhdWx0J10gPSBFeGNlcHRpb247XG5tb2R1bGUuZXhwb3J0cyA9IGV4cG9ydHNbJ2RlZmF1bHQnXTtcbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDJWNFkyVndkR2x2Ymk1cWN5SmRMQ0p1WVcxbGN5STZXMTBzSW0xaGNIQnBibWR6SWpvaU96czdPMEZCUTBFc1NVRkJUU3hWUVVGVkxFZEJRVWNzUTBGQlF5eGhRVUZoTEVWQlFVVXNWVUZCVlN4RlFVRkZMRmxCUVZrc1JVRkJSU3hUUVVGVExFVkJRVVVzVFVGQlRTeEZRVUZGTEZGQlFWRXNSVUZCUlN4UFFVRlBMRU5CUVVNc1EwRkJRenM3UVVGRmJrY3NVMEZCVXl4VFFVRlRMRU5CUVVNc1QwRkJUeXhGUVVGRkxFbEJRVWtzUlVGQlJUdEJRVU5vUXl4TlFVRkpMRWRCUVVjc1IwRkJSeXhKUVVGSkxFbEJRVWtzU1VGQlNTeERRVUZETEVkQlFVYzdUVUZEZEVJc1NVRkJTU3haUVVGQk8wMUJRMG9zVFVGQlRTeFpRVUZCTEVOQlFVTTdRVUZEV0N4TlFVRkpMRWRCUVVjc1JVRkJSVHRCUVVOUUxGRkJRVWtzUjBGQlJ5eEhRVUZITEVOQlFVTXNTMEZCU3l4RFFVRkRMRWxCUVVrc1EwRkJRenRCUVVOMFFpeFZRVUZOTEVkQlFVY3NSMEZCUnl4RFFVRkRMRXRCUVVzc1EwRkJReXhOUVVGTkxFTkJRVU03TzBGQlJURkNMRmRCUVU4c1NVRkJTU3hMUVVGTExFZEJRVWNzU1VGQlNTeEhRVUZITEVkQlFVY3NSMEZCUnl4TlFVRk5MRU5CUVVNN1IwRkRlRU03TzBGQlJVUXNUVUZCU1N4SFFVRkhMRWRCUVVjc1MwRkJTeXhEUVVGRExGTkJRVk1zUTBGQlF5eFhRVUZYTEVOQlFVTXNTVUZCU1N4RFFVRkRMRWxCUVVrc1JVRkJSU3hQUVVGUExFTkJRVU1zUTBGQlF6czdPMEZCUnpGRUxFOUJRVXNzU1VGQlNTeEhRVUZITEVkQlFVY3NRMEZCUXl4RlFVRkZMRWRCUVVjc1IwRkJSeXhWUVVGVkxFTkJRVU1zVFVGQlRTeEZRVUZGTEVkQlFVY3NSVUZCUlN4RlFVRkZPMEZCUTJoRUxGRkJRVWtzUTBGQlF5eFZRVUZWTEVOQlFVTXNSMEZCUnl4RFFVRkRMRU5CUVVNc1IwRkJSeXhIUVVGSExFTkJRVU1zVlVGQlZTeERRVUZETEVkQlFVY3NRMEZCUXl4RFFVRkRMRU5CUVVNN1IwRkRPVU03T3p0QlFVZEVMRTFCUVVrc1MwRkJTeXhEUVVGRExHbENRVUZwUWl4RlFVRkZPMEZCUXpOQ0xGTkJRVXNzUTBGQlF5eHBRa0ZCYVVJc1EwRkJReXhKUVVGSkxFVkJRVVVzVTBGQlV5eERRVUZETEVOQlFVTTdSMEZETVVNN08wRkJSVVFzVFVGQlNUdEJRVU5HTEZGQlFVa3NSMEZCUnl4RlFVRkZPMEZCUTFBc1ZVRkJTU3hEUVVGRExGVkJRVlVzUjBGQlJ5eEpRVUZKTEVOQlFVTTdPenM3UVVGSmRrSXNWVUZCU1N4TlFVRk5MRU5CUVVNc1kwRkJZeXhGUVVGRk8wRkJRM3BDTEdOQlFVMHNRMEZCUXl4alFVRmpMRU5CUVVNc1NVRkJTU3hGUVVGRkxGRkJRVkVzUlVGQlJUdEJRVU53UXl4bFFVRkxMRVZCUVVVc1RVRkJUVHRCUVVOaUxHOUNRVUZWTEVWQlFVVXNTVUZCU1R0VFFVTnFRaXhEUVVGRExFTkJRVU03VDBGRFNpeE5RVUZOTzBGQlEwd3NXVUZCU1N4RFFVRkRMRTFCUVUwc1IwRkJSeXhOUVVGTkxFTkJRVU03VDBGRGRFSTdTMEZEUmp0SFFVTkdMRU5CUVVNc1QwRkJUeXhIUVVGSExFVkJRVVU3TzBkQlJXSTdRMEZEUmpzN1FVRkZSQ3hUUVVGVExFTkJRVU1zVTBGQlV5eEhRVUZITEVsQlFVa3NTMEZCU3l4RlFVRkZMRU5CUVVNN08zRkNRVVZ1UWl4VFFVRlRJaXdpWm1sc1pTSTZJbVY0WTJWd2RHbHZiaTVxY3lJc0luTnZkWEpqWlhORGIyNTBaVzUwSWpwYklseHVZMjl1YzNRZ1pYSnliM0pRY205d2N5QTlJRnNuWkdWelkzSnBjSFJwYjI0bkxDQW5abWxzWlU1aGJXVW5MQ0FuYkdsdVpVNTFiV0psY2ljc0lDZHRaWE56WVdkbEp5d2dKMjVoYldVbkxDQW5iblZ0WW1WeUp5d2dKM04wWVdOckoxMDdYRzVjYm1aMWJtTjBhVzl1SUVWNFkyVndkR2x2YmlodFpYTnpZV2RsTENCdWIyUmxLU0I3WEc0Z0lHeGxkQ0JzYjJNZ1BTQnViMlJsSUNZbUlHNXZaR1V1Ykc5akxGeHVJQ0FnSUNBZ2JHbHVaU3hjYmlBZ0lDQWdJR052YkhWdGJqdGNiaUFnYVdZZ0tHeHZZeWtnZTF4dUlDQWdJR3hwYm1VZ1BTQnNiMk11YzNSaGNuUXViR2x1WlR0Y2JpQWdJQ0JqYjJ4MWJXNGdQU0JzYjJNdWMzUmhjblF1WTI5c2RXMXVPMXh1WEc0Z0lDQWdiV1Z6YzJGblpTQXJQU0FuSUMwZ0p5QXJJR3hwYm1VZ0t5QW5PaWNnS3lCamIyeDFiVzQ3WEc0Z0lIMWNibHh1SUNCc1pYUWdkRzF3SUQwZ1JYSnliM0l1Y0hKdmRHOTBlWEJsTG1OdmJuTjBjblZqZEc5eUxtTmhiR3dvZEdocGN5d2diV1Z6YzJGblpTazdYRzVjYmlBZ0x5OGdWVzVtYjNKMGRXNWhkR1ZzZVNCbGNuSnZjbk1nWVhKbElHNXZkQ0JsYm5WdFpYSmhZbXhsSUdsdUlFTm9jbTl0WlNBb1lYUWdiR1ZoYzNRcExDQnpieUJnWm05eUlIQnliM0FnYVc0Z2RHMXdZQ0JrYjJWemJpZDBJSGR2Y21zdVhHNGdJR1p2Y2lBb2JHVjBJR2xrZUNBOUlEQTdJR2xrZUNBOElHVnljbTl5VUhKdmNITXViR1Z1WjNSb095QnBaSGdyS3lrZ2UxeHVJQ0FnSUhSb2FYTmJaWEp5YjNKUWNtOXdjMXRwWkhoZFhTQTlJSFJ0Y0Z0bGNuSnZjbEJ5YjNCelcybGtlRjFkTzF4dUlDQjlYRzVjYmlBZ0x5b2dhWE4wWVc1aWRXd2dhV2R1YjNKbElHVnNjMlVnS2k5Y2JpQWdhV1lnS0VWeWNtOXlMbU5oY0hSMWNtVlRkR0ZqYTFSeVlXTmxLU0I3WEc0Z0lDQWdSWEp5YjNJdVkyRndkSFZ5WlZOMFlXTnJWSEpoWTJVb2RHaHBjeXdnUlhoalpYQjBhVzl1S1R0Y2JpQWdmVnh1WEc0Z0lIUnllU0I3WEc0Z0lDQWdhV1lnS0d4dll5a2dlMXh1SUNBZ0lDQWdkR2hwY3k1c2FXNWxUblZ0WW1WeUlEMGdiR2x1WlR0Y2JseHVJQ0FnSUNBZ0x5OGdWMjl5YXlCaGNtOTFibVFnYVhOemRXVWdkVzVrWlhJZ2MyRm1ZWEpwSUhkb1pYSmxJSGRsSUdOaGJpZDBJR1JwY21WamRHeDVJSE5sZENCMGFHVWdZMjlzZFcxdUlIWmhiSFZsWEc0Z0lDQWdJQ0F2S2lCcGMzUmhibUoxYkNCcFoyNXZjbVVnYm1WNGRDQXFMMXh1SUNBZ0lDQWdhV1lnS0U5aWFtVmpkQzVrWldacGJtVlFjbTl3WlhKMGVTa2dlMXh1SUNBZ0lDQWdJQ0JQWW1wbFkzUXVaR1ZtYVc1bFVISnZjR1Z5ZEhrb2RHaHBjeXdnSjJOdmJIVnRiaWNzSUh0Y2JpQWdJQ0FnSUNBZ0lDQjJZV3gxWlRvZ1kyOXNkVzF1TEZ4dUlDQWdJQ0FnSUNBZ0lHVnVkVzFsY21GaWJHVTZJSFJ5ZFdWY2JpQWdJQ0FnSUNBZ2ZTazdYRzRnSUNBZ0lDQjlJR1ZzYzJVZ2UxeHVJQ0FnSUNBZ0lDQjBhR2x6TG1OdmJIVnRiaUE5SUdOdmJIVnRianRjYmlBZ0lDQWdJSDFjYmlBZ0lDQjlYRzRnSUgwZ1kyRjBZMmdnS0c1dmNDa2dlMXh1SUNBZ0lDOHFJRWxuYm05eVpTQnBaaUIwYUdVZ1luSnZkM05sY2lCcGN5QjJaWEo1SUhCaGNuUnBZM1ZzWVhJZ0tpOWNiaUFnZlZ4dWZWeHVYRzVGZUdObGNIUnBiMjR1Y0hKdmRHOTBlWEJsSUQwZ2JtVjNJRVZ5Y205eUtDazdYRzVjYm1WNGNHOXlkQ0JrWldaaGRXeDBJRVY0WTJWd2RHbHZianRjYmlKZGZRPT1cbiIsIid1c2Ugc3RyaWN0JztcblxuZXhwb3J0cy5fX2VzTW9kdWxlID0gdHJ1ZTtcbmV4cG9ydHMucmVnaXN0ZXJEZWZhdWx0SGVscGVycyA9IHJlZ2lzdGVyRGVmYXVsdEhlbHBlcnM7XG4vLyBpc3RhbmJ1bCBpZ25vcmUgbmV4dFxuXG5mdW5jdGlvbiBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KG9iaikgeyByZXR1cm4gb2JqICYmIG9iai5fX2VzTW9kdWxlID8gb2JqIDogeyAnZGVmYXVsdCc6IG9iaiB9OyB9XG5cbnZhciBfaGVscGVyc0Jsb2NrSGVscGVyTWlzc2luZyA9IHJlcXVpcmUoJy4vaGVscGVycy9ibG9jay1oZWxwZXItbWlzc2luZycpO1xuXG52YXIgX2hlbHBlcnNCbG9ja0hlbHBlck1pc3NpbmcyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfaGVscGVyc0Jsb2NrSGVscGVyTWlzc2luZyk7XG5cbnZhciBfaGVscGVyc0VhY2ggPSByZXF1aXJlKCcuL2hlbHBlcnMvZWFjaCcpO1xuXG52YXIgX2hlbHBlcnNFYWNoMiA9IF9pbnRlcm9wUmVxdWlyZURlZmF1bHQoX2hlbHBlcnNFYWNoKTtcblxudmFyIF9oZWxwZXJzSGVscGVyTWlzc2luZyA9IHJlcXVpcmUoJy4vaGVscGVycy9oZWxwZXItbWlzc2luZycpO1xuXG52YXIgX2hlbHBlcnNIZWxwZXJNaXNzaW5nMiA9IF9pbnRlcm9wUmVxdWlyZURlZmF1bHQoX2hlbHBlcnNIZWxwZXJNaXNzaW5nKTtcblxudmFyIF9oZWxwZXJzSWYgPSByZXF1aXJlKCcuL2hlbHBlcnMvaWYnKTtcblxudmFyIF9oZWxwZXJzSWYyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfaGVscGVyc0lmKTtcblxudmFyIF9oZWxwZXJzTG9nID0gcmVxdWlyZSgnLi9oZWxwZXJzL2xvZycpO1xuXG52YXIgX2hlbHBlcnNMb2cyID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfaGVscGVyc0xvZyk7XG5cbnZhciBfaGVscGVyc0xvb2t1cCA9IHJlcXVpcmUoJy4vaGVscGVycy9sb29rdXAnKTtcblxudmFyIF9oZWxwZXJzTG9va3VwMiA9IF9pbnRlcm9wUmVxdWlyZURlZmF1bHQoX2hlbHBlcnNMb29rdXApO1xuXG52YXIgX2hlbHBlcnNXaXRoID0gcmVxdWlyZSgnLi9oZWxwZXJzL3dpdGgnKTtcblxudmFyIF9oZWxwZXJzV2l0aDIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9oZWxwZXJzV2l0aCk7XG5cbmZ1bmN0aW9uIHJlZ2lzdGVyRGVmYXVsdEhlbHBlcnMoaW5zdGFuY2UpIHtcbiAgX2hlbHBlcnNCbG9ja0hlbHBlck1pc3NpbmcyWydkZWZhdWx0J10oaW5zdGFuY2UpO1xuICBfaGVscGVyc0VhY2gyWydkZWZhdWx0J10oaW5zdGFuY2UpO1xuICBfaGVscGVyc0hlbHBlck1pc3NpbmcyWydkZWZhdWx0J10oaW5zdGFuY2UpO1xuICBfaGVscGVyc0lmMlsnZGVmYXVsdCddKGluc3RhbmNlKTtcbiAgX2hlbHBlcnNMb2cyWydkZWZhdWx0J10oaW5zdGFuY2UpO1xuICBfaGVscGVyc0xvb2t1cDJbJ2RlZmF1bHQnXShpbnN0YW5jZSk7XG4gIF9oZWxwZXJzV2l0aDJbJ2RlZmF1bHQnXShpbnN0YW5jZSk7XG59XG4vLyMgc291cmNlTWFwcGluZ1VSTD1kYXRhOmFwcGxpY2F0aW9uL2pzb247Y2hhcnNldD11dGYtODtiYXNlNjQsZXlKMlpYSnphVzl1SWpvekxDSnpiM1Z5WTJWeklqcGJJaTR1THk0dUx5NHVMMnhwWWk5b1lXNWtiR1ZpWVhKekwyaGxiSEJsY25NdWFuTWlYU3dpYm1GdFpYTWlPbHRkTENKdFlYQndhVzVuY3lJNklqczdPenM3T3pzN2VVTkJRWFZETEdkRFFVRm5RenM3T3pzeVFrRkRPVU1zWjBKQlFXZENPenM3TzI5RFFVTlFMREJDUVVFd1FqczdPenQ1UWtGRGNrTXNZMEZCWXpzN096c3dRa0ZEWWl4bFFVRmxPenM3T3paQ1FVTmFMR3RDUVVGclFqczdPenN5UWtGRGNFSXNaMEpCUVdkQ096czdPMEZCUld4RExGTkJRVk1zYzBKQlFYTkNMRU5CUVVNc1VVRkJVU3hGUVVGRk8wRkJReTlETEhsRFFVRXlRaXhSUVVGUkxFTkJRVU1zUTBGQlF6dEJRVU55UXl3eVFrRkJZU3hSUVVGUkxFTkJRVU1zUTBGQlF6dEJRVU4yUWl4dlEwRkJjMElzVVVGQlVTeERRVUZETEVOQlFVTTdRVUZEYUVNc2VVSkJRVmNzVVVGQlVTeERRVUZETEVOQlFVTTdRVUZEY2tJc01FSkJRVmtzVVVGQlVTeERRVUZETEVOQlFVTTdRVUZEZEVJc05rSkJRV1VzVVVGQlVTeERRVUZETEVOQlFVTTdRVUZEZWtJc01rSkJRV0VzVVVGQlVTeERRVUZETEVOQlFVTTdRMEZEZUVJaUxDSm1hV3hsSWpvaWFHVnNjR1Z5Y3k1cWN5SXNJbk52ZFhKalpYTkRiMjUwWlc1MElqcGJJbWx0Y0c5eWRDQnlaV2RwYzNSbGNrSnNiMk5yU0dWc2NHVnlUV2x6YzJsdVp5Qm1jbTl0SUNjdUwyaGxiSEJsY25NdllteHZZMnN0YUdWc2NHVnlMVzFwYzNOcGJtY25PMXh1YVcxd2IzSjBJSEpsWjJsemRHVnlSV0ZqYUNCbWNtOXRJQ2N1TDJobGJIQmxjbk12WldGamFDYzdYRzVwYlhCdmNuUWdjbVZuYVhOMFpYSklaV3h3WlhKTmFYTnphVzVuSUdaeWIyMGdKeTR2YUdWc2NHVnljeTlvWld4d1pYSXRiV2x6YzJsdVp5YzdYRzVwYlhCdmNuUWdjbVZuYVhOMFpYSkpaaUJtY205dElDY3VMMmhsYkhCbGNuTXZhV1luTzF4dWFXMXdiM0owSUhKbFoybHpkR1Z5VEc5bklHWnliMjBnSnk0dmFHVnNjR1Z5Y3k5c2IyY25PMXh1YVcxd2IzSjBJSEpsWjJsemRHVnlURzl2YTNWd0lHWnliMjBnSnk0dmFHVnNjR1Z5Y3k5c2IyOXJkWEFuTzF4dWFXMXdiM0owSUhKbFoybHpkR1Z5VjJsMGFDQm1jbTl0SUNjdUwyaGxiSEJsY25NdmQybDBhQ2M3WEc1Y2JtVjRjRzl5ZENCbWRXNWpkR2x2YmlCeVpXZHBjM1JsY2tSbFptRjFiSFJJWld4d1pYSnpLR2x1YzNSaGJtTmxLU0I3WEc0Z0lISmxaMmx6ZEdWeVFteHZZMnRJWld4d1pYSk5hWE56YVc1bktHbHVjM1JoYm1ObEtUdGNiaUFnY21WbmFYTjBaWEpGWVdOb0tHbHVjM1JoYm1ObEtUdGNiaUFnY21WbmFYTjBaWEpJWld4d1pYSk5hWE56YVc1bktHbHVjM1JoYm1ObEtUdGNiaUFnY21WbmFYTjBaWEpKWmlocGJuTjBZVzVqWlNrN1hHNGdJSEpsWjJsemRHVnlURzluS0dsdWMzUmhibU5sS1R0Y2JpQWdjbVZuYVhOMFpYSk1iMjlyZFhBb2FXNXpkR0Z1WTJVcE8xeHVJQ0J5WldkcGMzUmxjbGRwZEdnb2FXNXpkR0Z1WTJVcE8xeHVmVnh1SWwxOVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuXG52YXIgX3V0aWxzID0gcmVxdWlyZSgnLi4vdXRpbHMnKTtcblxuZXhwb3J0c1snZGVmYXVsdCddID0gZnVuY3Rpb24gKGluc3RhbmNlKSB7XG4gIGluc3RhbmNlLnJlZ2lzdGVySGVscGVyKCdibG9ja0hlbHBlck1pc3NpbmcnLCBmdW5jdGlvbiAoY29udGV4dCwgb3B0aW9ucykge1xuICAgIHZhciBpbnZlcnNlID0gb3B0aW9ucy5pbnZlcnNlLFxuICAgICAgICBmbiA9IG9wdGlvbnMuZm47XG5cbiAgICBpZiAoY29udGV4dCA9PT0gdHJ1ZSkge1xuICAgICAgcmV0dXJuIGZuKHRoaXMpO1xuICAgIH0gZWxzZSBpZiAoY29udGV4dCA9PT0gZmFsc2UgfHwgY29udGV4dCA9PSBudWxsKSB7XG4gICAgICByZXR1cm4gaW52ZXJzZSh0aGlzKTtcbiAgICB9IGVsc2UgaWYgKF91dGlscy5pc0FycmF5KGNvbnRleHQpKSB7XG4gICAgICBpZiAoY29udGV4dC5sZW5ndGggPiAwKSB7XG4gICAgICAgIGlmIChvcHRpb25zLmlkcykge1xuICAgICAgICAgIG9wdGlvbnMuaWRzID0gW29wdGlvbnMubmFtZV07XG4gICAgICAgIH1cblxuICAgICAgICByZXR1cm4gaW5zdGFuY2UuaGVscGVycy5lYWNoKGNvbnRleHQsIG9wdGlvbnMpO1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgcmV0dXJuIGludmVyc2UodGhpcyk7XG4gICAgICB9XG4gICAgfSBlbHNlIHtcbiAgICAgIGlmIChvcHRpb25zLmRhdGEgJiYgb3B0aW9ucy5pZHMpIHtcbiAgICAgICAgdmFyIGRhdGEgPSBfdXRpbHMuY3JlYXRlRnJhbWUob3B0aW9ucy5kYXRhKTtcbiAgICAgICAgZGF0YS5jb250ZXh0UGF0aCA9IF91dGlscy5hcHBlbmRDb250ZXh0UGF0aChvcHRpb25zLmRhdGEuY29udGV4dFBhdGgsIG9wdGlvbnMubmFtZSk7XG4gICAgICAgIG9wdGlvbnMgPSB7IGRhdGE6IGRhdGEgfTtcbiAgICAgIH1cblxuICAgICAgcmV0dXJuIGZuKGNvbnRleHQsIG9wdGlvbnMpO1xuICAgIH1cbiAgfSk7XG59O1xuXG5tb2R1bGUuZXhwb3J0cyA9IGV4cG9ydHNbJ2RlZmF1bHQnXTtcbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUx5NHVMMnhwWWk5b1lXNWtiR1ZpWVhKekwyaGxiSEJsY25NdllteHZZMnN0YUdWc2NHVnlMVzFwYzNOcGJtY3Vhbk1pWFN3aWJtRnRaWE1pT2x0ZExDSnRZWEJ3YVc1bmN5STZJanM3T3p0eFFrRkJjMFFzVlVGQlZUczdjVUpCUldwRUxGVkJRVk1zVVVGQlVTeEZRVUZGTzBGQlEyaERMRlZCUVZFc1EwRkJReXhqUVVGakxFTkJRVU1zYjBKQlFXOUNMRVZCUVVVc1ZVRkJVeXhQUVVGUExFVkJRVVVzVDBGQlR5eEZRVUZGTzBGQlEzWkZMRkZCUVVrc1QwRkJUeXhIUVVGSExFOUJRVThzUTBGQlF5eFBRVUZQTzFGQlEzcENMRVZCUVVVc1IwRkJSeXhQUVVGUExFTkJRVU1zUlVGQlJTeERRVUZET3p0QlFVVndRaXhSUVVGSkxFOUJRVThzUzBGQlN5eEpRVUZKTEVWQlFVVTdRVUZEY0VJc1lVRkJUeXhGUVVGRkxFTkJRVU1zU1VGQlNTeERRVUZETEVOQlFVTTdTMEZEYWtJc1RVRkJUU3hKUVVGSkxFOUJRVThzUzBGQlN5eExRVUZMTEVsQlFVa3NUMEZCVHl4SlFVRkpMRWxCUVVrc1JVRkJSVHRCUVVNdlF5eGhRVUZQTEU5QlFVOHNRMEZCUXl4SlFVRkpMRU5CUVVNc1EwRkJRenRMUVVOMFFpeE5RVUZOTEVsQlFVa3NaVUZCVVN4UFFVRlBMRU5CUVVNc1JVRkJSVHRCUVVNelFpeFZRVUZKTEU5QlFVOHNRMEZCUXl4TlFVRk5MRWRCUVVjc1EwRkJReXhGUVVGRk8wRkJRM1JDTEZsQlFVa3NUMEZCVHl4RFFVRkRMRWRCUVVjc1JVRkJSVHRCUVVObUxHbENRVUZQTEVOQlFVTXNSMEZCUnl4SFFVRkhMRU5CUVVNc1QwRkJUeXhEUVVGRExFbEJRVWtzUTBGQlF5eERRVUZETzFOQlF6bENPenRCUVVWRUxHVkJRVThzVVVGQlVTeERRVUZETEU5QlFVOHNRMEZCUXl4SlFVRkpMRU5CUVVNc1QwRkJUeXhGUVVGRkxFOUJRVThzUTBGQlF5eERRVUZETzA5QlEyaEVMRTFCUVUwN1FVRkRUQ3hsUVVGUExFOUJRVThzUTBGQlF5eEpRVUZKTEVOQlFVTXNRMEZCUXp0UFFVTjBRanRMUVVOR0xFMUJRVTA3UVVGRFRDeFZRVUZKTEU5QlFVOHNRMEZCUXl4SlFVRkpMRWxCUVVrc1QwRkJUeXhEUVVGRExFZEJRVWNzUlVGQlJUdEJRVU12UWl4WlFVRkpMRWxCUVVrc1IwRkJSeXh0UWtGQldTeFBRVUZQTEVOQlFVTXNTVUZCU1N4RFFVRkRMRU5CUVVNN1FVRkRja01zV1VGQlNTeERRVUZETEZkQlFWY3NSMEZCUnl4NVFrRkJhMElzVDBGQlR5eERRVUZETEVsQlFVa3NRMEZCUXl4WFFVRlhMRVZCUVVVc1QwRkJUeXhEUVVGRExFbEJRVWtzUTBGQlF5eERRVUZETzBGQlF6ZEZMR1ZCUVU4c1IwRkJSeXhGUVVGRExFbEJRVWtzUlVGQlJTeEpRVUZKTEVWQlFVTXNRMEZCUXp0UFFVTjRRanM3UVVGRlJDeGhRVUZQTEVWQlFVVXNRMEZCUXl4UFFVRlBMRVZCUVVVc1QwRkJUeXhEUVVGRExFTkJRVU03UzBGRE4wSTdSMEZEUml4RFFVRkRMRU5CUVVNN1EwRkRTaUlzSW1acGJHVWlPaUppYkc5amF5MW9aV3h3WlhJdGJXbHpjMmx1Wnk1cWN5SXNJbk52ZFhKalpYTkRiMjUwWlc1MElqcGJJbWx0Y0c5eWRDQjdZWEJ3Wlc1a1EyOXVkR1Y0ZEZCaGRHZ3NJR055WldGMFpVWnlZVzFsTENCcGMwRnljbUY1ZlNCbWNtOXRJQ2N1TGk5MWRHbHNjeWM3WEc1Y2JtVjRjRzl5ZENCa1pXWmhkV3gwSUdaMWJtTjBhVzl1S0dsdWMzUmhibU5sS1NCN1hHNGdJR2x1YzNSaGJtTmxMbkpsWjJsemRHVnlTR1ZzY0dWeUtDZGliRzlqYTBobGJIQmxjazFwYzNOcGJtY25MQ0JtZFc1amRHbHZiaWhqYjI1MFpYaDBMQ0J2Y0hScGIyNXpLU0I3WEc0Z0lDQWdiR1YwSUdsdWRtVnljMlVnUFNCdmNIUnBiMjV6TG1sdWRtVnljMlVzWEc0Z0lDQWdJQ0FnSUdadUlEMGdiM0IwYVc5dWN5NW1ianRjYmx4dUlDQWdJR2xtSUNoamIyNTBaWGgwSUQwOVBTQjBjblZsS1NCN1hHNGdJQ0FnSUNCeVpYUjFjbTRnWm00b2RHaHBjeWs3WEc0Z0lDQWdmU0JsYkhObElHbG1JQ2hqYjI1MFpYaDBJRDA5UFNCbVlXeHpaU0I4ZkNCamIyNTBaWGgwSUQwOUlHNTFiR3dwSUh0Y2JpQWdJQ0FnSUhKbGRIVnliaUJwYm5abGNuTmxLSFJvYVhNcE8xeHVJQ0FnSUgwZ1pXeHpaU0JwWmlBb2FYTkJjbkpoZVNoamIyNTBaWGgwS1NrZ2UxeHVJQ0FnSUNBZ2FXWWdLR052Ym5SbGVIUXViR1Z1WjNSb0lENGdNQ2tnZTF4dUlDQWdJQ0FnSUNCcFppQW9iM0IwYVc5dWN5NXBaSE1wSUh0Y2JpQWdJQ0FnSUNBZ0lDQnZjSFJwYjI1ekxtbGtjeUE5SUZ0dmNIUnBiMjV6TG01aGJXVmRPMXh1SUNBZ0lDQWdJQ0I5WEc1Y2JpQWdJQ0FnSUNBZ2NtVjBkWEp1SUdsdWMzUmhibU5sTG1obGJIQmxjbk11WldGamFDaGpiMjUwWlhoMExDQnZjSFJwYjI1ektUdGNiaUFnSUNBZ0lIMGdaV3h6WlNCN1hHNGdJQ0FnSUNBZ0lISmxkSFZ5YmlCcGJuWmxjbk5sS0hSb2FYTXBPMXh1SUNBZ0lDQWdmVnh1SUNBZ0lIMGdaV3h6WlNCN1hHNGdJQ0FnSUNCcFppQW9iM0IwYVc5dWN5NWtZWFJoSUNZbUlHOXdkR2x2Ym5NdWFXUnpLU0I3WEc0Z0lDQWdJQ0FnSUd4bGRDQmtZWFJoSUQwZ1kzSmxZWFJsUm5KaGJXVW9iM0IwYVc5dWN5NWtZWFJoS1R0Y2JpQWdJQ0FnSUNBZ1pHRjBZUzVqYjI1MFpYaDBVR0YwYUNBOUlHRndjR1Z1WkVOdmJuUmxlSFJRWVhSb0tHOXdkR2x2Ym5NdVpHRjBZUzVqYjI1MFpYaDBVR0YwYUN3Z2IzQjBhVzl1Y3k1dVlXMWxLVHRjYmlBZ0lDQWdJQ0FnYjNCMGFXOXVjeUE5SUh0a1lYUmhPaUJrWVhSaGZUdGNiaUFnSUNBZ0lIMWNibHh1SUNBZ0lDQWdjbVYwZFhKdUlHWnVLR052Ym5SbGVIUXNJRzl3ZEdsdmJuTXBPMXh1SUNBZ0lIMWNiaUFnZlNrN1hHNTlYRzRpWFgwPVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuLy8gaXN0YW5idWwgaWdub3JlIG5leHRcblxuZnVuY3Rpb24gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChvYmopIHsgcmV0dXJuIG9iaiAmJiBvYmouX19lc01vZHVsZSA/IG9iaiA6IHsgJ2RlZmF1bHQnOiBvYmogfTsgfVxuXG52YXIgX3V0aWxzID0gcmVxdWlyZSgnLi4vdXRpbHMnKTtcblxudmFyIF9leGNlcHRpb24gPSByZXF1aXJlKCcuLi9leGNlcHRpb24nKTtcblxudmFyIF9leGNlcHRpb24yID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfZXhjZXB0aW9uKTtcblxuZXhwb3J0c1snZGVmYXVsdCddID0gZnVuY3Rpb24gKGluc3RhbmNlKSB7XG4gIGluc3RhbmNlLnJlZ2lzdGVySGVscGVyKCdlYWNoJywgZnVuY3Rpb24gKGNvbnRleHQsIG9wdGlvbnMpIHtcbiAgICBpZiAoIW9wdGlvbnMpIHtcbiAgICAgIHRocm93IG5ldyBfZXhjZXB0aW9uMlsnZGVmYXVsdCddKCdNdXN0IHBhc3MgaXRlcmF0b3IgdG8gI2VhY2gnKTtcbiAgICB9XG5cbiAgICB2YXIgZm4gPSBvcHRpb25zLmZuLFxuICAgICAgICBpbnZlcnNlID0gb3B0aW9ucy5pbnZlcnNlLFxuICAgICAgICBpID0gMCxcbiAgICAgICAgcmV0ID0gJycsXG4gICAgICAgIGRhdGEgPSB1bmRlZmluZWQsXG4gICAgICAgIGNvbnRleHRQYXRoID0gdW5kZWZpbmVkO1xuXG4gICAgaWYgKG9wdGlvbnMuZGF0YSAmJiBvcHRpb25zLmlkcykge1xuICAgICAgY29udGV4dFBhdGggPSBfdXRpbHMuYXBwZW5kQ29udGV4dFBhdGgob3B0aW9ucy5kYXRhLmNvbnRleHRQYXRoLCBvcHRpb25zLmlkc1swXSkgKyAnLic7XG4gICAgfVxuXG4gICAgaWYgKF91dGlscy5pc0Z1bmN0aW9uKGNvbnRleHQpKSB7XG4gICAgICBjb250ZXh0ID0gY29udGV4dC5jYWxsKHRoaXMpO1xuICAgIH1cblxuICAgIGlmIChvcHRpb25zLmRhdGEpIHtcbiAgICAgIGRhdGEgPSBfdXRpbHMuY3JlYXRlRnJhbWUob3B0aW9ucy5kYXRhKTtcbiAgICB9XG5cbiAgICBmdW5jdGlvbiBleGVjSXRlcmF0aW9uKGZpZWxkLCBpbmRleCwgbGFzdCkge1xuICAgICAgaWYgKGRhdGEpIHtcbiAgICAgICAgZGF0YS5rZXkgPSBmaWVsZDtcbiAgICAgICAgZGF0YS5pbmRleCA9IGluZGV4O1xuICAgICAgICBkYXRhLmZpcnN0ID0gaW5kZXggPT09IDA7XG4gICAgICAgIGRhdGEubGFzdCA9ICEhbGFzdDtcblxuICAgICAgICBpZiAoY29udGV4dFBhdGgpIHtcbiAgICAgICAgICBkYXRhLmNvbnRleHRQYXRoID0gY29udGV4dFBhdGggKyBmaWVsZDtcbiAgICAgICAgfVxuICAgICAgfVxuXG4gICAgICByZXQgPSByZXQgKyBmbihjb250ZXh0W2ZpZWxkXSwge1xuICAgICAgICBkYXRhOiBkYXRhLFxuICAgICAgICBibG9ja1BhcmFtczogX3V0aWxzLmJsb2NrUGFyYW1zKFtjb250ZXh0W2ZpZWxkXSwgZmllbGRdLCBbY29udGV4dFBhdGggKyBmaWVsZCwgbnVsbF0pXG4gICAgICB9KTtcbiAgICB9XG5cbiAgICBpZiAoY29udGV4dCAmJiB0eXBlb2YgY29udGV4dCA9PT0gJ29iamVjdCcpIHtcbiAgICAgIGlmIChfdXRpbHMuaXNBcnJheShjb250ZXh0KSkge1xuICAgICAgICBmb3IgKHZhciBqID0gY29udGV4dC5sZW5ndGg7IGkgPCBqOyBpKyspIHtcbiAgICAgICAgICBpZiAoaSBpbiBjb250ZXh0KSB7XG4gICAgICAgICAgICBleGVjSXRlcmF0aW9uKGksIGksIGkgPT09IGNvbnRleHQubGVuZ3RoIC0gMSk7XG4gICAgICAgICAgfVxuICAgICAgICB9XG4gICAgICB9IGVsc2Uge1xuICAgICAgICB2YXIgcHJpb3JLZXkgPSB1bmRlZmluZWQ7XG5cbiAgICAgICAgZm9yICh2YXIga2V5IGluIGNvbnRleHQpIHtcbiAgICAgICAgICBpZiAoY29udGV4dC5oYXNPd25Qcm9wZXJ0eShrZXkpKSB7XG4gICAgICAgICAgICAvLyBXZSdyZSBydW5uaW5nIHRoZSBpdGVyYXRpb25zIG9uZSBzdGVwIG91dCBvZiBzeW5jIHNvIHdlIGNhbiBkZXRlY3RcbiAgICAgICAgICAgIC8vIHRoZSBsYXN0IGl0ZXJhdGlvbiB3aXRob3V0IGhhdmUgdG8gc2NhbiB0aGUgb2JqZWN0IHR3aWNlIGFuZCBjcmVhdGVcbiAgICAgICAgICAgIC8vIGFuIGl0ZXJtZWRpYXRlIGtleXMgYXJyYXkuXG4gICAgICAgICAgICBpZiAocHJpb3JLZXkgIT09IHVuZGVmaW5lZCkge1xuICAgICAgICAgICAgICBleGVjSXRlcmF0aW9uKHByaW9yS2V5LCBpIC0gMSk7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBwcmlvcktleSA9IGtleTtcbiAgICAgICAgICAgIGkrKztcbiAgICAgICAgICB9XG4gICAgICAgIH1cbiAgICAgICAgaWYgKHByaW9yS2V5ICE9PSB1bmRlZmluZWQpIHtcbiAgICAgICAgICBleGVjSXRlcmF0aW9uKHByaW9yS2V5LCBpIC0gMSwgdHJ1ZSk7XG4gICAgICAgIH1cbiAgICAgIH1cbiAgICB9XG5cbiAgICBpZiAoaSA9PT0gMCkge1xuICAgICAgcmV0ID0gaW52ZXJzZSh0aGlzKTtcbiAgICB9XG5cbiAgICByZXR1cm4gcmV0O1xuICB9KTtcbn07XG5cbm1vZHVsZS5leHBvcnRzID0gZXhwb3J0c1snZGVmYXVsdCddO1xuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDJobGJIQmxjbk12WldGamFDNXFjeUpkTENKdVlXMWxjeUk2VzEwc0ltMWhjSEJwYm1keklqb2lPenM3T3pzN08zRkNRVUVyUlN4VlFVRlZPenQ1UWtGRGJrVXNZMEZCWXpzN096dHhRa0ZGY2tJc1ZVRkJVeXhSUVVGUkxFVkJRVVU3UVVGRGFFTXNWVUZCVVN4RFFVRkRMR05CUVdNc1EwRkJReXhOUVVGTkxFVkJRVVVzVlVGQlV5eFBRVUZQTEVWQlFVVXNUMEZCVHl4RlFVRkZPMEZCUTNwRUxGRkJRVWtzUTBGQlF5eFBRVUZQTEVWQlFVVTdRVUZEV2l4WlFVRk5MREpDUVVGakxEWkNRVUUyUWl4RFFVRkRMRU5CUVVNN1MwRkRjRVE3TzBGQlJVUXNVVUZCU1N4RlFVRkZMRWRCUVVjc1QwRkJUeXhEUVVGRExFVkJRVVU3VVVGRFppeFBRVUZQTEVkQlFVY3NUMEZCVHl4RFFVRkRMRTlCUVU4N1VVRkRla0lzUTBGQlF5eEhRVUZITEVOQlFVTTdVVUZEVEN4SFFVRkhMRWRCUVVjc1JVRkJSVHRSUVVOU0xFbEJRVWtzV1VGQlFUdFJRVU5LTEZkQlFWY3NXVUZCUVN4RFFVRkRPenRCUVVWb1FpeFJRVUZKTEU5QlFVOHNRMEZCUXl4SlFVRkpMRWxCUVVrc1QwRkJUeXhEUVVGRExFZEJRVWNzUlVGQlJUdEJRVU12UWl4cFFrRkJWeXhIUVVGSExIbENRVUZyUWl4UFFVRlBMRU5CUVVNc1NVRkJTU3hEUVVGRExGZEJRVmNzUlVGQlJTeFBRVUZQTEVOQlFVTXNSMEZCUnl4RFFVRkRMRU5CUVVNc1EwRkJReXhEUVVGRExFZEJRVWNzUjBGQlJ5eERRVUZETzB0QlEycEdPenRCUVVWRUxGRkJRVWtzYTBKQlFWY3NUMEZCVHl4RFFVRkRMRVZCUVVVN1FVRkJSU3hoUVVGUExFZEJRVWNzVDBGQlR5eERRVUZETEVsQlFVa3NRMEZCUXl4SlFVRkpMRU5CUVVNc1EwRkJRenRMUVVGRk96dEJRVVV4UkN4UlFVRkpMRTlCUVU4c1EwRkJReXhKUVVGSkxFVkJRVVU3UVVGRGFFSXNWVUZCU1N4SFFVRkhMRzFDUVVGWkxFOUJRVThzUTBGQlF5eEpRVUZKTEVOQlFVTXNRMEZCUXp0TFFVTnNRenM3UVVGRlJDeGhRVUZUTEdGQlFXRXNRMEZCUXl4TFFVRkxMRVZCUVVVc1MwRkJTeXhGUVVGRkxFbEJRVWtzUlVGQlJUdEJRVU42UXl4VlFVRkpMRWxCUVVrc1JVRkJSVHRCUVVOU0xGbEJRVWtzUTBGQlF5eEhRVUZITEVkQlFVY3NTMEZCU3l4RFFVRkRPMEZCUTJwQ0xGbEJRVWtzUTBGQlF5eExRVUZMTEVkQlFVY3NTMEZCU3l4RFFVRkRPMEZCUTI1Q0xGbEJRVWtzUTBGQlF5eExRVUZMTEVkQlFVY3NTMEZCU3l4TFFVRkxMRU5CUVVNc1EwRkJRenRCUVVONlFpeFpRVUZKTEVOQlFVTXNTVUZCU1N4SFFVRkhMRU5CUVVNc1EwRkJReXhKUVVGSkxFTkJRVU03TzBGQlJXNUNMRmxCUVVrc1YwRkJWeXhGUVVGRk8wRkJRMllzWTBGQlNTeERRVUZETEZkQlFWY3NSMEZCUnl4WFFVRlhMRWRCUVVjc1MwRkJTeXhEUVVGRE8xTkJRM2hETzA5QlEwWTdPMEZCUlVRc1UwRkJSeXhIUVVGSExFZEJRVWNzUjBGQlJ5eEZRVUZGTEVOQlFVTXNUMEZCVHl4RFFVRkRMRXRCUVVzc1EwRkJReXhGUVVGRk8wRkJRemRDTEZsQlFVa3NSVUZCUlN4SlFVRkpPMEZCUTFZc2JVSkJRVmNzUlVGQlJTeHRRa0ZCV1N4RFFVRkRMRTlCUVU4c1EwRkJReXhMUVVGTExFTkJRVU1zUlVGQlJTeExRVUZMTEVOQlFVTXNSVUZCUlN4RFFVRkRMRmRCUVZjc1IwRkJSeXhMUVVGTExFVkJRVVVzU1VGQlNTeERRVUZETEVOQlFVTTdUMEZETDBVc1EwRkJReXhEUVVGRE8wdEJRMG83TzBGQlJVUXNVVUZCU1N4UFFVRlBMRWxCUVVrc1QwRkJUeXhQUVVGUExFdEJRVXNzVVVGQlVTeEZRVUZGTzBGQlF6RkRMRlZCUVVrc1pVRkJVU3hQUVVGUExFTkJRVU1zUlVGQlJUdEJRVU53UWl4aFFVRkxMRWxCUVVrc1EwRkJReXhIUVVGSExFOUJRVThzUTBGQlF5eE5RVUZOTEVWQlFVVXNRMEZCUXl4SFFVRkhMRU5CUVVNc1JVRkJSU3hEUVVGRExFVkJRVVVzUlVGQlJUdEJRVU4yUXl4alFVRkpMRU5CUVVNc1NVRkJTU3hQUVVGUExFVkJRVVU3UVVGRGFFSXNlVUpCUVdFc1EwRkJReXhEUVVGRExFVkJRVVVzUTBGQlF5eEZRVUZGTEVOQlFVTXNTMEZCU3l4UFFVRlBMRU5CUVVNc1RVRkJUU3hIUVVGSExFTkJRVU1zUTBGQlF5eERRVUZETzFkQlF5OURPMU5CUTBZN1QwRkRSaXhOUVVGTk8wRkJRMHdzV1VGQlNTeFJRVUZSTEZsQlFVRXNRMEZCUXpzN1FVRkZZaXhoUVVGTExFbEJRVWtzUjBGQlJ5eEpRVUZKTEU5QlFVOHNSVUZCUlR0QlFVTjJRaXhqUVVGSkxFOUJRVThzUTBGQlF5eGpRVUZqTEVOQlFVTXNSMEZCUnl4RFFVRkRMRVZCUVVVN096czdRVUZKTDBJc1owSkJRVWtzVVVGQlVTeExRVUZMTEZOQlFWTXNSVUZCUlR0QlFVTXhRaXd5UWtGQllTeERRVUZETEZGQlFWRXNSVUZCUlN4RFFVRkRMRWRCUVVjc1EwRkJReXhEUVVGRExFTkJRVU03WVVGRGFFTTdRVUZEUkN4dlFrRkJVU3hIUVVGSExFZEJRVWNzUTBGQlF6dEJRVU5tTEdGQlFVTXNSVUZCUlN4RFFVRkRPMWRCUTB3N1UwRkRSanRCUVVORUxGbEJRVWtzVVVGQlVTeExRVUZMTEZOQlFWTXNSVUZCUlR0QlFVTXhRaXgxUWtGQllTeERRVUZETEZGQlFWRXNSVUZCUlN4RFFVRkRMRWRCUVVjc1EwRkJReXhGUVVGRkxFbEJRVWtzUTBGQlF5eERRVUZETzFOQlEzUkRPMDlCUTBZN1MwRkRSanM3UVVGRlJDeFJRVUZKTEVOQlFVTXNTMEZCU3l4RFFVRkRMRVZCUVVVN1FVRkRXQ3hUUVVGSExFZEJRVWNzVDBGQlR5eERRVUZETEVsQlFVa3NRMEZCUXl4RFFVRkRPMHRCUTNKQ096dEJRVVZFTEZkQlFVOHNSMEZCUnl4RFFVRkRPMGRCUTFvc1EwRkJReXhEUVVGRE8wTkJRMG9pTENKbWFXeGxJam9pWldGamFDNXFjeUlzSW5OdmRYSmpaWE5EYjI1MFpXNTBJanBiSW1sdGNHOXlkQ0I3WVhCd1pXNWtRMjl1ZEdWNGRGQmhkR2dzSUdKc2IyTnJVR0Z5WVcxekxDQmpjbVZoZEdWR2NtRnRaU3dnYVhOQmNuSmhlU3dnYVhOR2RXNWpkR2x2Ym4wZ1puSnZiU0FuTGk0dmRYUnBiSE1uTzF4dWFXMXdiM0owSUVWNFkyVndkR2x2YmlCbWNtOXRJQ2N1TGk5bGVHTmxjSFJwYjI0bk8xeHVYRzVsZUhCdmNuUWdaR1ZtWVhWc2RDQm1kVzVqZEdsdmJpaHBibk4wWVc1alpTa2dlMXh1SUNCcGJuTjBZVzVqWlM1eVpXZHBjM1JsY2tobGJIQmxjaWduWldGamFDY3NJR1oxYm1OMGFXOXVLR052Ym5SbGVIUXNJRzl3ZEdsdmJuTXBJSHRjYmlBZ0lDQnBaaUFvSVc5d2RHbHZibk1wSUh0Y2JpQWdJQ0FnSUhSb2NtOTNJRzVsZHlCRmVHTmxjSFJwYjI0b0owMTFjM1FnY0dGemN5QnBkR1Z5WVhSdmNpQjBieUFqWldGamFDY3BPMXh1SUNBZ0lIMWNibHh1SUNBZ0lHeGxkQ0JtYmlBOUlHOXdkR2x2Ym5NdVptNHNYRzRnSUNBZ0lDQWdJR2x1ZG1WeWMyVWdQU0J2Y0hScGIyNXpMbWx1ZG1WeWMyVXNYRzRnSUNBZ0lDQWdJR2tnUFNBd0xGeHVJQ0FnSUNBZ0lDQnlaWFFnUFNBbkp5eGNiaUFnSUNBZ0lDQWdaR0YwWVN4Y2JpQWdJQ0FnSUNBZ1kyOXVkR1Y0ZEZCaGRHZzdYRzVjYmlBZ0lDQnBaaUFvYjNCMGFXOXVjeTVrWVhSaElDWW1JRzl3ZEdsdmJuTXVhV1J6S1NCN1hHNGdJQ0FnSUNCamIyNTBaWGgwVUdGMGFDQTlJR0Z3Y0dWdVpFTnZiblJsZUhSUVlYUm9LRzl3ZEdsdmJuTXVaR0YwWVM1amIyNTBaWGgwVUdGMGFDd2diM0IwYVc5dWN5NXBaSE5iTUYwcElDc2dKeTRuTzF4dUlDQWdJSDFjYmx4dUlDQWdJR2xtSUNocGMwWjFibU4wYVc5dUtHTnZiblJsZUhRcEtTQjdJR052Ym5SbGVIUWdQU0JqYjI1MFpYaDBMbU5oYkd3b2RHaHBjeWs3SUgxY2JseHVJQ0FnSUdsbUlDaHZjSFJwYjI1ekxtUmhkR0VwSUh0Y2JpQWdJQ0FnSUdSaGRHRWdQU0JqY21WaGRHVkdjbUZ0WlNodmNIUnBiMjV6TG1SaGRHRXBPMXh1SUNBZ0lIMWNibHh1SUNBZ0lHWjFibU4wYVc5dUlHVjRaV05KZEdWeVlYUnBiMjRvWm1sbGJHUXNJR2x1WkdWNExDQnNZWE4wS1NCN1hHNGdJQ0FnSUNCcFppQW9aR0YwWVNrZ2UxeHVJQ0FnSUNBZ0lDQmtZWFJoTG10bGVTQTlJR1pwWld4a08xeHVJQ0FnSUNBZ0lDQmtZWFJoTG1sdVpHVjRJRDBnYVc1a1pYZzdYRzRnSUNBZ0lDQWdJR1JoZEdFdVptbHljM1FnUFNCcGJtUmxlQ0E5UFQwZ01EdGNiaUFnSUNBZ0lDQWdaR0YwWVM1c1lYTjBJRDBnSVNGc1lYTjBPMXh1WEc0Z0lDQWdJQ0FnSUdsbUlDaGpiMjUwWlhoMFVHRjBhQ2tnZTF4dUlDQWdJQ0FnSUNBZ0lHUmhkR0V1WTI5dWRHVjRkRkJoZEdnZ1BTQmpiMjUwWlhoMFVHRjBhQ0FySUdacFpXeGtPMXh1SUNBZ0lDQWdJQ0I5WEc0Z0lDQWdJQ0I5WEc1Y2JpQWdJQ0FnSUhKbGRDQTlJSEpsZENBcklHWnVLR052Ym5SbGVIUmJabWxsYkdSZExDQjdYRzRnSUNBZ0lDQWdJR1JoZEdFNklHUmhkR0VzWEc0Z0lDQWdJQ0FnSUdKc2IyTnJVR0Z5WVcxek9pQmliRzlqYTFCaGNtRnRjeWhiWTI5dWRHVjRkRnRtYVdWc1pGMHNJR1pwWld4a1hTd2dXMk52Ym5SbGVIUlFZWFJvSUNzZ1ptbGxiR1FzSUc1MWJHeGRLVnh1SUNBZ0lDQWdmU2s3WEc0Z0lDQWdmVnh1WEc0Z0lDQWdhV1lnS0dOdmJuUmxlSFFnSmlZZ2RIbHdaVzltSUdOdmJuUmxlSFFnUFQwOUlDZHZZbXBsWTNRbktTQjdYRzRnSUNBZ0lDQnBaaUFvYVhOQmNuSmhlU2hqYjI1MFpYaDBLU2tnZTF4dUlDQWdJQ0FnSUNCbWIzSWdLR3hsZENCcUlEMGdZMjl1ZEdWNGRDNXNaVzVuZEdnN0lHa2dQQ0JxT3lCcEt5c3BJSHRjYmlBZ0lDQWdJQ0FnSUNCcFppQW9hU0JwYmlCamIyNTBaWGgwS1NCN1hHNGdJQ0FnSUNBZ0lDQWdJQ0JsZUdWalNYUmxjbUYwYVc5dUtHa3NJR2tzSUdrZ1BUMDlJR052Ym5SbGVIUXViR1Z1WjNSb0lDMGdNU2s3WEc0Z0lDQWdJQ0FnSUNBZ2ZWeHVJQ0FnSUNBZ0lDQjlYRzRnSUNBZ0lDQjlJR1ZzYzJVZ2UxeHVJQ0FnSUNBZ0lDQnNaWFFnY0hKcGIzSkxaWGs3WEc1Y2JpQWdJQ0FnSUNBZ1ptOXlJQ2hzWlhRZ2EyVjVJR2x1SUdOdmJuUmxlSFFwSUh0Y2JpQWdJQ0FnSUNBZ0lDQnBaaUFvWTI5dWRHVjRkQzVvWVhOUGQyNVFjbTl3WlhKMGVTaHJaWGtwS1NCN1hHNGdJQ0FnSUNBZ0lDQWdJQ0F2THlCWFpTZHlaU0J5ZFc1dWFXNW5JSFJvWlNCcGRHVnlZWFJwYjI1eklHOXVaU0J6ZEdWd0lHOTFkQ0J2WmlCemVXNWpJSE52SUhkbElHTmhiaUJrWlhSbFkzUmNiaUFnSUNBZ0lDQWdJQ0FnSUM4dklIUm9aU0JzWVhOMElHbDBaWEpoZEdsdmJpQjNhWFJvYjNWMElHaGhkbVVnZEc4Z2MyTmhiaUIwYUdVZ2IySnFaV04wSUhSM2FXTmxJR0Z1WkNCamNtVmhkR1ZjYmlBZ0lDQWdJQ0FnSUNBZ0lDOHZJR0Z1SUdsMFpYSnRaV1JwWVhSbElHdGxlWE1nWVhKeVlYa3VYRzRnSUNBZ0lDQWdJQ0FnSUNCcFppQW9jSEpwYjNKTFpYa2dJVDA5SUhWdVpHVm1hVzVsWkNrZ2UxeHVJQ0FnSUNBZ0lDQWdJQ0FnSUNCbGVHVmpTWFJsY21GMGFXOXVLSEJ5YVc5eVMyVjVMQ0JwSUMwZ01TazdYRzRnSUNBZ0lDQWdJQ0FnSUNCOVhHNGdJQ0FnSUNBZ0lDQWdJQ0J3Y21sdmNrdGxlU0E5SUd0bGVUdGNiaUFnSUNBZ0lDQWdJQ0FnSUdrckt6dGNiaUFnSUNBZ0lDQWdJQ0I5WEc0Z0lDQWdJQ0FnSUgxY2JpQWdJQ0FnSUNBZ2FXWWdLSEJ5YVc5eVMyVjVJQ0U5UFNCMWJtUmxabWx1WldRcElIdGNiaUFnSUNBZ0lDQWdJQ0JsZUdWalNYUmxjbUYwYVc5dUtIQnlhVzl5UzJWNUxDQnBJQzBnTVN3Z2RISjFaU2s3WEc0Z0lDQWdJQ0FnSUgxY2JpQWdJQ0FnSUgxY2JpQWdJQ0I5WEc1Y2JpQWdJQ0JwWmlBb2FTQTlQVDBnTUNrZ2UxeHVJQ0FnSUNBZ2NtVjBJRDBnYVc1MlpYSnpaU2gwYUdsektUdGNiaUFnSUNCOVhHNWNiaUFnSUNCeVpYUjFjbTRnY21WME8xeHVJQ0I5S1R0Y2JuMWNiaUpkZlE9PVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuLy8gaXN0YW5idWwgaWdub3JlIG5leHRcblxuZnVuY3Rpb24gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChvYmopIHsgcmV0dXJuIG9iaiAmJiBvYmouX19lc01vZHVsZSA/IG9iaiA6IHsgJ2RlZmF1bHQnOiBvYmogfTsgfVxuXG52YXIgX2V4Y2VwdGlvbiA9IHJlcXVpcmUoJy4uL2V4Y2VwdGlvbicpO1xuXG52YXIgX2V4Y2VwdGlvbjIgPSBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KF9leGNlcHRpb24pO1xuXG5leHBvcnRzWydkZWZhdWx0J10gPSBmdW5jdGlvbiAoaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ2hlbHBlck1pc3NpbmcnLCBmdW5jdGlvbiAoKSAvKiBbYXJncywgXW9wdGlvbnMgKi97XG4gICAgaWYgKGFyZ3VtZW50cy5sZW5ndGggPT09IDEpIHtcbiAgICAgIC8vIEEgbWlzc2luZyBmaWVsZCBpbiBhIHt7Zm9vfX0gY29uc3RydWN0LlxuICAgICAgcmV0dXJuIHVuZGVmaW5lZDtcbiAgICB9IGVsc2Uge1xuICAgICAgLy8gU29tZW9uZSBpcyBhY3R1YWxseSB0cnlpbmcgdG8gY2FsbCBzb21ldGhpbmcsIGJsb3cgdXAuXG4gICAgICB0aHJvdyBuZXcgX2V4Y2VwdGlvbjJbJ2RlZmF1bHQnXSgnTWlzc2luZyBoZWxwZXI6IFwiJyArIGFyZ3VtZW50c1thcmd1bWVudHMubGVuZ3RoIC0gMV0ubmFtZSArICdcIicpO1xuICAgIH1cbiAgfSk7XG59O1xuXG5tb2R1bGUuZXhwb3J0cyA9IGV4cG9ydHNbJ2RlZmF1bHQnXTtcbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUx5NHVMMnhwWWk5b1lXNWtiR1ZpWVhKekwyaGxiSEJsY25NdmFHVnNjR1Z5TFcxcGMzTnBibWN1YW5NaVhTd2libUZ0WlhNaU9sdGRMQ0p0WVhCd2FXNW5jeUk2SWpzN096czdPenQ1UWtGQmMwSXNZMEZCWXpzN096dHhRa0ZGY2tJc1ZVRkJVeXhSUVVGUkxFVkJRVVU3UVVGRGFFTXNWVUZCVVN4RFFVRkRMR05CUVdNc1EwRkJReXhsUVVGbExFVkJRVVVzYVVOQlFXZERPMEZCUTNaRkxGRkJRVWtzVTBGQlV5eERRVUZETEUxQlFVMHNTMEZCU3l4RFFVRkRMRVZCUVVVN08wRkJSVEZDTEdGQlFVOHNVMEZCVXl4RFFVRkRPMHRCUTJ4Q0xFMUJRVTA3TzBGQlJVd3NXVUZCVFN3eVFrRkJZeXh0UWtGQmJVSXNSMEZCUnl4VFFVRlRMRU5CUVVNc1UwRkJVeXhEUVVGRExFMUJRVTBzUjBGQlJ5eERRVUZETEVOQlFVTXNRMEZCUXl4SlFVRkpMRWRCUVVjc1IwRkJSeXhEUVVGRExFTkJRVU03UzBGRGRrWTdSMEZEUml4RFFVRkRMRU5CUVVNN1EwRkRTaUlzSW1acGJHVWlPaUpvWld4d1pYSXRiV2x6YzJsdVp5NXFjeUlzSW5OdmRYSmpaWE5EYjI1MFpXNTBJanBiSW1sdGNHOXlkQ0JGZUdObGNIUnBiMjRnWm5KdmJTQW5MaTR2WlhoalpYQjBhVzl1Snp0Y2JseHVaWGh3YjNKMElHUmxabUYxYkhRZ1puVnVZM1JwYjI0b2FXNXpkR0Z1WTJVcElIdGNiaUFnYVc1emRHRnVZMlV1Y21WbmFYTjBaWEpJWld4d1pYSW9KMmhsYkhCbGNrMXBjM05wYm1jbkxDQm1kVzVqZEdsdmJpZ3ZLaUJiWVhKbmN5d2dYVzl3ZEdsdmJuTWdLaThwSUh0Y2JpQWdJQ0JwWmlBb1lYSm5kVzFsYm5SekxteGxibWQwYUNBOVBUMGdNU2tnZTF4dUlDQWdJQ0FnTHk4Z1FTQnRhWE56YVc1bklHWnBaV3hrSUdsdUlHRWdlM3RtYjI5OWZTQmpiMjV6ZEhKMVkzUXVYRzRnSUNBZ0lDQnlaWFIxY200Z2RXNWtaV1pwYm1Wa08xeHVJQ0FnSUgwZ1pXeHpaU0I3WEc0Z0lDQWdJQ0F2THlCVGIyMWxiMjVsSUdseklHRmpkSFZoYkd4NUlIUnllV2x1WnlCMGJ5QmpZV3hzSUhOdmJXVjBhR2x1Wnl3Z1lteHZkeUIxY0M1Y2JpQWdJQ0FnSUhSb2NtOTNJRzVsZHlCRmVHTmxjSFJwYjI0b0owMXBjM05wYm1jZ2FHVnNjR1Z5T2lCY0lpY2dLeUJoY21kMWJXVnVkSE5iWVhKbmRXMWxiblJ6TG14bGJtZDBhQ0F0SURGZExtNWhiV1VnS3lBblhDSW5LVHRjYmlBZ0lDQjlYRzRnSUgwcE8xeHVmVnh1SWwxOVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuXG52YXIgX3V0aWxzID0gcmVxdWlyZSgnLi4vdXRpbHMnKTtcblxuZXhwb3J0c1snZGVmYXVsdCddID0gZnVuY3Rpb24gKGluc3RhbmNlKSB7XG4gIGluc3RhbmNlLnJlZ2lzdGVySGVscGVyKCdpZicsIGZ1bmN0aW9uIChjb25kaXRpb25hbCwgb3B0aW9ucykge1xuICAgIGlmIChfdXRpbHMuaXNGdW5jdGlvbihjb25kaXRpb25hbCkpIHtcbiAgICAgIGNvbmRpdGlvbmFsID0gY29uZGl0aW9uYWwuY2FsbCh0aGlzKTtcbiAgICB9XG5cbiAgICAvLyBEZWZhdWx0IGJlaGF2aW9yIGlzIHRvIHJlbmRlciB0aGUgcG9zaXRpdmUgcGF0aCBpZiB0aGUgdmFsdWUgaXMgdHJ1dGh5IGFuZCBub3QgZW1wdHkuXG4gICAgLy8gVGhlIGBpbmNsdWRlWmVyb2Agb3B0aW9uIG1heSBiZSBzZXQgdG8gdHJlYXQgdGhlIGNvbmR0aW9uYWwgYXMgcHVyZWx5IG5vdCBlbXB0eSBiYXNlZCBvbiB0aGVcbiAgICAvLyBiZWhhdmlvciBvZiBpc0VtcHR5LiBFZmZlY3RpdmVseSB0aGlzIGRldGVybWluZXMgaWYgMCBpcyBoYW5kbGVkIGJ5IHRoZSBwb3NpdGl2ZSBwYXRoIG9yIG5lZ2F0aXZlLlxuICAgIGlmICghb3B0aW9ucy5oYXNoLmluY2x1ZGVaZXJvICYmICFjb25kaXRpb25hbCB8fCBfdXRpbHMuaXNFbXB0eShjb25kaXRpb25hbCkpIHtcbiAgICAgIHJldHVybiBvcHRpb25zLmludmVyc2UodGhpcyk7XG4gICAgfSBlbHNlIHtcbiAgICAgIHJldHVybiBvcHRpb25zLmZuKHRoaXMpO1xuICAgIH1cbiAgfSk7XG5cbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ3VubGVzcycsIGZ1bmN0aW9uIChjb25kaXRpb25hbCwgb3B0aW9ucykge1xuICAgIHJldHVybiBpbnN0YW5jZS5oZWxwZXJzWydpZiddLmNhbGwodGhpcywgY29uZGl0aW9uYWwsIHsgZm46IG9wdGlvbnMuaW52ZXJzZSwgaW52ZXJzZTogb3B0aW9ucy5mbiwgaGFzaDogb3B0aW9ucy5oYXNoIH0pO1xuICB9KTtcbn07XG5cbm1vZHVsZS5leHBvcnRzID0gZXhwb3J0c1snZGVmYXVsdCddO1xuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDJobGJIQmxjbk12YVdZdWFuTWlYU3dpYm1GdFpYTWlPbHRkTENKdFlYQndhVzVuY3lJNklqczdPenR4UWtGQmEwTXNWVUZCVlRzN2NVSkJSVGRDTEZWQlFWTXNVVUZCVVN4RlFVRkZPMEZCUTJoRExGVkJRVkVzUTBGQlF5eGpRVUZqTEVOQlFVTXNTVUZCU1N4RlFVRkZMRlZCUVZNc1YwRkJWeXhGUVVGRkxFOUJRVThzUlVGQlJUdEJRVU16UkN4UlFVRkpMR3RDUVVGWExGZEJRVmNzUTBGQlF5eEZRVUZGTzBGQlFVVXNhVUpCUVZjc1IwRkJSeXhYUVVGWExFTkJRVU1zU1VGQlNTeERRVUZETEVsQlFVa3NRMEZCUXl4RFFVRkRPMHRCUVVVN096czdPMEZCUzNSRkxGRkJRVWtzUVVGQlF5eERRVUZETEU5QlFVOHNRMEZCUXl4SlFVRkpMRU5CUVVNc1YwRkJWeXhKUVVGSkxFTkJRVU1zVjBGQlZ5eEpRVUZMTEdWQlFWRXNWMEZCVnl4RFFVRkRMRVZCUVVVN1FVRkRka1VzWVVGQlR5eFBRVUZQTEVOQlFVTXNUMEZCVHl4RFFVRkRMRWxCUVVrc1EwRkJReXhEUVVGRE8wdEJRemxDTEUxQlFVMDdRVUZEVEN4aFFVRlBMRTlCUVU4c1EwRkJReXhGUVVGRkxFTkJRVU1zU1VGQlNTeERRVUZETEVOQlFVTTdTMEZEZWtJN1IwRkRSaXhEUVVGRExFTkJRVU03TzBGQlJVZ3NWVUZCVVN4RFFVRkRMR05CUVdNc1EwRkJReXhSUVVGUkxFVkJRVVVzVlVGQlV5eFhRVUZYTEVWQlFVVXNUMEZCVHl4RlFVRkZPMEZCUXk5RUxGZEJRVThzVVVGQlVTeERRVUZETEU5QlFVOHNRMEZCUXl4SlFVRkpMRU5CUVVNc1EwRkJReXhKUVVGSkxFTkJRVU1zU1VGQlNTeEZRVUZGTEZkQlFWY3NSVUZCUlN4RlFVRkRMRVZCUVVVc1JVRkJSU3hQUVVGUExFTkJRVU1zVDBGQlR5eEZRVUZGTEU5QlFVOHNSVUZCUlN4UFFVRlBMRU5CUVVNc1JVRkJSU3hGUVVGRkxFbEJRVWtzUlVGQlJTeFBRVUZQTEVOQlFVTXNTVUZCU1N4RlFVRkRMRU5CUVVNc1EwRkJRenRIUVVOMlNDeERRVUZETEVOQlFVTTdRMEZEU2lJc0ltWnBiR1VpT2lKcFppNXFjeUlzSW5OdmRYSmpaWE5EYjI1MFpXNTBJanBiSW1sdGNHOXlkQ0I3YVhORmJYQjBlU3dnYVhOR2RXNWpkR2x2Ym4wZ1puSnZiU0FuTGk0dmRYUnBiSE1uTzF4dVhHNWxlSEJ2Y25RZ1pHVm1ZWFZzZENCbWRXNWpkR2x2YmlocGJuTjBZVzVqWlNrZ2UxeHVJQ0JwYm5OMFlXNWpaUzV5WldkcGMzUmxja2hsYkhCbGNpZ25hV1luTENCbWRXNWpkR2x2YmloamIyNWthWFJwYjI1aGJDd2diM0IwYVc5dWN5a2dlMXh1SUNBZ0lHbG1JQ2hwYzBaMWJtTjBhVzl1S0dOdmJtUnBkR2x2Ym1Gc0tTa2dleUJqYjI1a2FYUnBiMjVoYkNBOUlHTnZibVJwZEdsdmJtRnNMbU5oYkd3b2RHaHBjeWs3SUgxY2JseHVJQ0FnSUM4dklFUmxabUYxYkhRZ1ltVm9ZWFpwYjNJZ2FYTWdkRzhnY21WdVpHVnlJSFJvWlNCd2IzTnBkR2wyWlNCd1lYUm9JR2xtSUhSb1pTQjJZV3gxWlNCcGN5QjBjblYwYUhrZ1lXNWtJRzV2ZENCbGJYQjBlUzVjYmlBZ0lDQXZMeUJVYUdVZ1lHbHVZMngxWkdWYVpYSnZZQ0J2Y0hScGIyNGdiV0Y1SUdKbElITmxkQ0IwYnlCMGNtVmhkQ0IwYUdVZ1kyOXVaSFJwYjI1aGJDQmhjeUJ3ZFhKbGJIa2dibTkwSUdWdGNIUjVJR0poYzJWa0lHOXVJSFJvWlZ4dUlDQWdJQzh2SUdKbGFHRjJhVzl5SUc5bUlHbHpSVzF3ZEhrdUlFVm1abVZqZEdsMlpXeDVJSFJvYVhNZ1pHVjBaWEp0YVc1bGN5QnBaaUF3SUdseklHaGhibVJzWldRZ1lua2dkR2hsSUhCdmMybDBhWFpsSUhCaGRHZ2diM0lnYm1WbllYUnBkbVV1WEc0Z0lDQWdhV1lnS0NnaGIzQjBhVzl1Y3k1b1lYTm9MbWx1WTJ4MVpHVmFaWEp2SUNZbUlDRmpiMjVrYVhScGIyNWhiQ2tnZkh3Z2FYTkZiWEIwZVNoamIyNWthWFJwYjI1aGJDa3BJSHRjYmlBZ0lDQWdJSEpsZEhWeWJpQnZjSFJwYjI1ekxtbHVkbVZ5YzJVb2RHaHBjeWs3WEc0Z0lDQWdmU0JsYkhObElIdGNiaUFnSUNBZ0lISmxkSFZ5YmlCdmNIUnBiMjV6TG1adUtIUm9hWE1wTzF4dUlDQWdJSDFjYmlBZ2ZTazdYRzVjYmlBZ2FXNXpkR0Z1WTJVdWNtVm5hWE4wWlhKSVpXeHdaWElvSjNWdWJHVnpjeWNzSUdaMWJtTjBhVzl1S0dOdmJtUnBkR2x2Ym1Gc0xDQnZjSFJwYjI1ektTQjdYRzRnSUNBZ2NtVjBkWEp1SUdsdWMzUmhibU5sTG1obGJIQmxjbk5iSjJsbUoxMHVZMkZzYkNoMGFHbHpMQ0JqYjI1a2FYUnBiMjVoYkN3Z2UyWnVPaUJ2Y0hScGIyNXpMbWx1ZG1WeWMyVXNJR2x1ZG1WeWMyVTZJRzl3ZEdsdmJuTXVabTRzSUdoaGMyZzZJRzl3ZEdsdmJuTXVhR0Z6YUgwcE8xeHVJQ0I5S1R0Y2JuMWNiaUpkZlE9PVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuXG5leHBvcnRzWydkZWZhdWx0J10gPSBmdW5jdGlvbiAoaW5zdGFuY2UpIHtcbiAgaW5zdGFuY2UucmVnaXN0ZXJIZWxwZXIoJ2xvZycsIGZ1bmN0aW9uICgpIC8qIG1lc3NhZ2UsIG9wdGlvbnMgKi97XG4gICAgdmFyIGFyZ3MgPSBbdW5kZWZpbmVkXSxcbiAgICAgICAgb3B0aW9ucyA9IGFyZ3VtZW50c1thcmd1bWVudHMubGVuZ3RoIC0gMV07XG4gICAgZm9yICh2YXIgaSA9IDA7IGkgPCBhcmd1bWVudHMubGVuZ3RoIC0gMTsgaSsrKSB7XG4gICAgICBhcmdzLnB1c2goYXJndW1lbnRzW2ldKTtcbiAgICB9XG5cbiAgICB2YXIgbGV2ZWwgPSAxO1xuICAgIGlmIChvcHRpb25zLmhhc2gubGV2ZWwgIT0gbnVsbCkge1xuICAgICAgbGV2ZWwgPSBvcHRpb25zLmhhc2gubGV2ZWw7XG4gICAgfSBlbHNlIGlmIChvcHRpb25zLmRhdGEgJiYgb3B0aW9ucy5kYXRhLmxldmVsICE9IG51bGwpIHtcbiAgICAgIGxldmVsID0gb3B0aW9ucy5kYXRhLmxldmVsO1xuICAgIH1cbiAgICBhcmdzWzBdID0gbGV2ZWw7XG5cbiAgICBpbnN0YW5jZS5sb2cuYXBwbHkoaW5zdGFuY2UsIGFyZ3MpO1xuICB9KTtcbn07XG5cbm1vZHVsZS5leHBvcnRzID0gZXhwb3J0c1snZGVmYXVsdCddO1xuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDJobGJIQmxjbk12Ykc5bkxtcHpJbDBzSW01aGJXVnpJanBiWFN3aWJXRndjR2x1WjNNaU9pSTdPenM3Y1VKQlFXVXNWVUZCVXl4UlFVRlJMRVZCUVVVN1FVRkRhRU1zVlVGQlVTeERRVUZETEdOQlFXTXNRMEZCUXl4TFFVRkxMRVZCUVVVc2EwTkJRV2xETzBGQlF6bEVMRkZCUVVrc1NVRkJTU3hIUVVGSExFTkJRVU1zVTBGQlV5eERRVUZETzFGQlEyeENMRTlCUVU4c1IwRkJSeXhUUVVGVExFTkJRVU1zVTBGQlV5eERRVUZETEUxQlFVMHNSMEZCUnl4RFFVRkRMRU5CUVVNc1EwRkJRenRCUVVNNVF5eFRRVUZMTEVsQlFVa3NRMEZCUXl4SFFVRkhMRU5CUVVNc1JVRkJSU3hEUVVGRExFZEJRVWNzVTBGQlV5eERRVUZETEUxQlFVMHNSMEZCUnl4RFFVRkRMRVZCUVVVc1EwRkJReXhGUVVGRkxFVkJRVVU3UVVGRE4wTXNWVUZCU1N4RFFVRkRMRWxCUVVrc1EwRkJReXhUUVVGVExFTkJRVU1zUTBGQlF5eERRVUZETEVOQlFVTXNRMEZCUXp0TFFVTjZRanM3UVVGRlJDeFJRVUZKTEV0QlFVc3NSMEZCUnl4RFFVRkRMRU5CUVVNN1FVRkRaQ3hSUVVGSkxFOUJRVThzUTBGQlF5eEpRVUZKTEVOQlFVTXNTMEZCU3l4SlFVRkpMRWxCUVVrc1JVRkJSVHRCUVVNNVFpeFhRVUZMTEVkQlFVY3NUMEZCVHl4RFFVRkRMRWxCUVVrc1EwRkJReXhMUVVGTExFTkJRVU03UzBGRE5VSXNUVUZCVFN4SlFVRkpMRTlCUVU4c1EwRkJReXhKUVVGSkxFbEJRVWtzVDBGQlR5eERRVUZETEVsQlFVa3NRMEZCUXl4TFFVRkxMRWxCUVVrc1NVRkJTU3hGUVVGRk8wRkJRM0pFTEZkQlFVc3NSMEZCUnl4UFFVRlBMRU5CUVVNc1NVRkJTU3hEUVVGRExFdEJRVXNzUTBGQlF6dExRVU0xUWp0QlFVTkVMRkZCUVVrc1EwRkJReXhEUVVGRExFTkJRVU1zUjBGQlJ5eExRVUZMTEVOQlFVTTdPMEZCUldoQ0xGbEJRVkVzUTBGQlF5eEhRVUZITEUxQlFVRXNRMEZCV2l4UlFVRlJMRVZCUVZNc1NVRkJTU3hEUVVGRExFTkJRVU03UjBGRGVFSXNRMEZCUXl4RFFVRkRPME5CUTBvaUxDSm1hV3hsSWpvaWJHOW5MbXB6SWl3aWMyOTFjbU5sYzBOdmJuUmxiblFpT2xzaVpYaHdiM0owSUdSbFptRjFiSFFnWm5WdVkzUnBiMjRvYVc1emRHRnVZMlVwSUh0Y2JpQWdhVzV6ZEdGdVkyVXVjbVZuYVhOMFpYSklaV3h3WlhJb0oyeHZaeWNzSUdaMWJtTjBhVzl1S0M4cUlHMWxjM05oWjJVc0lHOXdkR2x2Ym5NZ0tpOHBJSHRjYmlBZ0lDQnNaWFFnWVhKbmN5QTlJRnQxYm1SbFptbHVaV1JkTEZ4dUlDQWdJQ0FnSUNCdmNIUnBiMjV6SUQwZ1lYSm5kVzFsYm5SelcyRnlaM1Z0Wlc1MGN5NXNaVzVuZEdnZ0xTQXhYVHRjYmlBZ0lDQm1iM0lnS0d4bGRDQnBJRDBnTURzZ2FTQThJR0Z5WjNWdFpXNTBjeTVzWlc1bmRHZ2dMU0F4T3lCcEt5c3BJSHRjYmlBZ0lDQWdJR0Z5WjNNdWNIVnphQ2hoY21kMWJXVnVkSE5iYVYwcE8xeHVJQ0FnSUgxY2JseHVJQ0FnSUd4bGRDQnNaWFpsYkNBOUlERTdYRzRnSUNBZ2FXWWdLRzl3ZEdsdmJuTXVhR0Z6YUM1c1pYWmxiQ0FoUFNCdWRXeHNLU0I3WEc0Z0lDQWdJQ0JzWlhabGJDQTlJRzl3ZEdsdmJuTXVhR0Z6YUM1c1pYWmxiRHRjYmlBZ0lDQjlJR1ZzYzJVZ2FXWWdLRzl3ZEdsdmJuTXVaR0YwWVNBbUppQnZjSFJwYjI1ekxtUmhkR0V1YkdWMlpXd2dJVDBnYm5Wc2JDa2dlMXh1SUNBZ0lDQWdiR1YyWld3Z1BTQnZjSFJwYjI1ekxtUmhkR0V1YkdWMlpXdzdYRzRnSUNBZ2ZWeHVJQ0FnSUdGeVozTmJNRjBnUFNCc1pYWmxiRHRjYmx4dUlDQWdJR2x1YzNSaGJtTmxMbXh2WnlndUxpNGdZWEpuY3lrN1hHNGdJSDBwTzF4dWZWeHVJbDE5XG4iLCIndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG5cbmV4cG9ydHNbJ2RlZmF1bHQnXSA9IGZ1bmN0aW9uIChpbnN0YW5jZSkge1xuICBpbnN0YW5jZS5yZWdpc3RlckhlbHBlcignbG9va3VwJywgZnVuY3Rpb24gKG9iaiwgZmllbGQpIHtcbiAgICBpZiAoIW9iaikge1xuICAgICAgcmV0dXJuIG9iajtcbiAgICB9XG4gICAgaWYgKGZpZWxkID09PSAnY29uc3RydWN0b3InICYmICFvYmoucHJvcGVydHlJc0VudW1lcmFibGUoZmllbGQpKSB7XG4gICAgICByZXR1cm4gdW5kZWZpbmVkO1xuICAgIH1cbiAgICByZXR1cm4gb2JqW2ZpZWxkXTtcbiAgfSk7XG59O1xuXG5tb2R1bGUuZXhwb3J0cyA9IGV4cG9ydHNbJ2RlZmF1bHQnXTtcbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUx5NHVMMnhwWWk5b1lXNWtiR1ZpWVhKekwyaGxiSEJsY25NdmJHOXZhM1Z3TG1weklsMHNJbTVoYldWeklqcGJYU3dpYldGd2NHbHVaM01pT2lJN096czdjVUpCUVdVc1ZVRkJVeXhSUVVGUkxFVkJRVVU3UVVGRGFFTXNWVUZCVVN4RFFVRkRMR05CUVdNc1EwRkJReXhSUVVGUkxFVkJRVVVzVlVGQlV5eEhRVUZITEVWQlFVVXNTMEZCU3l4RlFVRkZPMEZCUTNKRUxGRkJRVWtzUTBGQlF5eEhRVUZITEVWQlFVVTdRVUZEVWl4aFFVRlBMRWRCUVVjc1EwRkJRenRMUVVOYU8wRkJRMFFzVVVGQlNTeExRVUZMTEV0QlFVc3NZVUZCWVN4SlFVRkpMRU5CUVVNc1IwRkJSeXhEUVVGRExHOUNRVUZ2UWl4RFFVRkRMRXRCUVVzc1EwRkJReXhGUVVGRk8wRkJReTlFTEdGQlFVOHNVMEZCVXl4RFFVRkRPMHRCUTJ4Q08wRkJRMFFzVjBGQlR5eEhRVUZITEVOQlFVTXNTMEZCU3l4RFFVRkRMRU5CUVVNN1IwRkRia0lzUTBGQlF5eERRVUZETzBOQlEwb2lMQ0ptYVd4bElqb2liRzl2YTNWd0xtcHpJaXdpYzI5MWNtTmxjME52Ym5SbGJuUWlPbHNpWlhod2IzSjBJR1JsWm1GMWJIUWdablZ1WTNScGIyNG9hVzV6ZEdGdVkyVXBJSHRjYmlBZ2FXNXpkR0Z1WTJVdWNtVm5hWE4wWlhKSVpXeHdaWElvSjJ4dmIydDFjQ2NzSUdaMWJtTjBhVzl1S0c5aWFpd2dabWxsYkdRcElIdGNiaUFnSUNCcFppQW9JVzlpYWlrZ2UxeHVJQ0FnSUNBZ2NtVjBkWEp1SUc5aWFqdGNiaUFnSUNCOVhHNGdJQ0FnYVdZZ0tHWnBaV3hrSUQwOVBTQW5ZMjl1YzNSeWRXTjBiM0luSUNZbUlDRnZZbW91Y0hKdmNHVnlkSGxKYzBWdWRXMWxjbUZpYkdVb1ptbGxiR1FwS1NCN1hHNGdJQ0FnSUNCeVpYUjFjbTRnZFc1a1pXWnBibVZrTzF4dUlDQWdJSDFjYmlBZ0lDQnlaWFIxY200Z2IySnFXMlpwWld4a1hUdGNiaUFnZlNrN1hHNTlYRzRpWFgwPVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuXG52YXIgX3V0aWxzID0gcmVxdWlyZSgnLi4vdXRpbHMnKTtcblxuZXhwb3J0c1snZGVmYXVsdCddID0gZnVuY3Rpb24gKGluc3RhbmNlKSB7XG4gIGluc3RhbmNlLnJlZ2lzdGVySGVscGVyKCd3aXRoJywgZnVuY3Rpb24gKGNvbnRleHQsIG9wdGlvbnMpIHtcbiAgICBpZiAoX3V0aWxzLmlzRnVuY3Rpb24oY29udGV4dCkpIHtcbiAgICAgIGNvbnRleHQgPSBjb250ZXh0LmNhbGwodGhpcyk7XG4gICAgfVxuXG4gICAgdmFyIGZuID0gb3B0aW9ucy5mbjtcblxuICAgIGlmICghX3V0aWxzLmlzRW1wdHkoY29udGV4dCkpIHtcbiAgICAgIHZhciBkYXRhID0gb3B0aW9ucy5kYXRhO1xuICAgICAgaWYgKG9wdGlvbnMuZGF0YSAmJiBvcHRpb25zLmlkcykge1xuICAgICAgICBkYXRhID0gX3V0aWxzLmNyZWF0ZUZyYW1lKG9wdGlvbnMuZGF0YSk7XG4gICAgICAgIGRhdGEuY29udGV4dFBhdGggPSBfdXRpbHMuYXBwZW5kQ29udGV4dFBhdGgob3B0aW9ucy5kYXRhLmNvbnRleHRQYXRoLCBvcHRpb25zLmlkc1swXSk7XG4gICAgICB9XG5cbiAgICAgIHJldHVybiBmbihjb250ZXh0LCB7XG4gICAgICAgIGRhdGE6IGRhdGEsXG4gICAgICAgIGJsb2NrUGFyYW1zOiBfdXRpbHMuYmxvY2tQYXJhbXMoW2NvbnRleHRdLCBbZGF0YSAmJiBkYXRhLmNvbnRleHRQYXRoXSlcbiAgICAgIH0pO1xuICAgIH0gZWxzZSB7XG4gICAgICByZXR1cm4gb3B0aW9ucy5pbnZlcnNlKHRoaXMpO1xuICAgIH1cbiAgfSk7XG59O1xuXG5tb2R1bGUuZXhwb3J0cyA9IGV4cG9ydHNbJ2RlZmF1bHQnXTtcbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUx5NHVMMnhwWWk5b1lXNWtiR1ZpWVhKekwyaGxiSEJsY25NdmQybDBhQzVxY3lKZExDSnVZVzFsY3lJNlcxMHNJbTFoY0hCcGJtZHpJam9pT3pzN08zRkNRVUVyUlN4VlFVRlZPenR4UWtGRk1VVXNWVUZCVXl4UlFVRlJMRVZCUVVVN1FVRkRhRU1zVlVGQlVTeERRVUZETEdOQlFXTXNRMEZCUXl4TlFVRk5MRVZCUVVVc1ZVRkJVeXhQUVVGUExFVkJRVVVzVDBGQlR5eEZRVUZGTzBGQlEzcEVMRkZCUVVrc2EwSkJRVmNzVDBGQlR5eERRVUZETEVWQlFVVTdRVUZCUlN4aFFVRlBMRWRCUVVjc1QwRkJUeXhEUVVGRExFbEJRVWtzUTBGQlF5eEpRVUZKTEVOQlFVTXNRMEZCUXp0TFFVRkZPenRCUVVVeFJDeFJRVUZKTEVWQlFVVXNSMEZCUnl4UFFVRlBMRU5CUVVNc1JVRkJSU3hEUVVGRE96dEJRVVZ3UWl4UlFVRkpMRU5CUVVNc1pVRkJVU3hQUVVGUExFTkJRVU1zUlVGQlJUdEJRVU55UWl4VlFVRkpMRWxCUVVrc1IwRkJSeXhQUVVGUExFTkJRVU1zU1VGQlNTeERRVUZETzBGQlEzaENMRlZCUVVrc1QwRkJUeXhEUVVGRExFbEJRVWtzU1VGQlNTeFBRVUZQTEVOQlFVTXNSMEZCUnl4RlFVRkZPMEZCUXk5Q0xGbEJRVWtzUjBGQlJ5eHRRa0ZCV1N4UFFVRlBMRU5CUVVNc1NVRkJTU3hEUVVGRExFTkJRVU03UVVGRGFrTXNXVUZCU1N4RFFVRkRMRmRCUVZjc1IwRkJSeXg1UWtGQmEwSXNUMEZCVHl4RFFVRkRMRWxCUVVrc1EwRkJReXhYUVVGWExFVkJRVVVzVDBGQlR5eERRVUZETEVkQlFVY3NRMEZCUXl4RFFVRkRMRU5CUVVNc1EwRkJReXhEUVVGRE8wOUJRMmhHT3p0QlFVVkVMR0ZCUVU4c1JVRkJSU3hEUVVGRExFOUJRVThzUlVGQlJUdEJRVU5xUWl4WlFVRkpMRVZCUVVVc1NVRkJTVHRCUVVOV0xHMUNRVUZYTEVWQlFVVXNiVUpCUVZrc1EwRkJReXhQUVVGUExFTkJRVU1zUlVGQlJTeERRVUZETEVsQlFVa3NTVUZCU1N4SlFVRkpMRU5CUVVNc1YwRkJWeXhEUVVGRExFTkJRVU03VDBGRGFFVXNRMEZCUXl4RFFVRkRPMHRCUTBvc1RVRkJUVHRCUVVOTUxHRkJRVThzVDBGQlR5eERRVUZETEU5QlFVOHNRMEZCUXl4SlFVRkpMRU5CUVVNc1EwRkJRenRMUVVNNVFqdEhRVU5HTEVOQlFVTXNRMEZCUXp0RFFVTktJaXdpWm1sc1pTSTZJbmRwZEdndWFuTWlMQ0p6YjNWeVkyVnpRMjl1ZEdWdWRDSTZXeUpwYlhCdmNuUWdlMkZ3Y0dWdVpFTnZiblJsZUhSUVlYUm9MQ0JpYkc5amExQmhjbUZ0Y3l3Z1kzSmxZWFJsUm5KaGJXVXNJR2x6Ulcxd2RIa3NJR2x6Um5WdVkzUnBiMjU5SUdaeWIyMGdKeTR1TDNWMGFXeHpKenRjYmx4dVpYaHdiM0owSUdSbFptRjFiSFFnWm5WdVkzUnBiMjRvYVc1emRHRnVZMlVwSUh0Y2JpQWdhVzV6ZEdGdVkyVXVjbVZuYVhOMFpYSklaV3h3WlhJb0ozZHBkR2duTENCbWRXNWpkR2x2YmloamIyNTBaWGgwTENCdmNIUnBiMjV6S1NCN1hHNGdJQ0FnYVdZZ0tHbHpSblZ1WTNScGIyNG9ZMjl1ZEdWNGRDa3BJSHNnWTI5dWRHVjRkQ0E5SUdOdmJuUmxlSFF1WTJGc2JDaDBhR2x6S1RzZ2ZWeHVYRzRnSUNBZ2JHVjBJR1p1SUQwZ2IzQjBhVzl1Y3k1bWJqdGNibHh1SUNBZ0lHbG1JQ2doYVhORmJYQjBlU2hqYjI1MFpYaDBLU2tnZTF4dUlDQWdJQ0FnYkdWMElHUmhkR0VnUFNCdmNIUnBiMjV6TG1SaGRHRTdYRzRnSUNBZ0lDQnBaaUFvYjNCMGFXOXVjeTVrWVhSaElDWW1JRzl3ZEdsdmJuTXVhV1J6S1NCN1hHNGdJQ0FnSUNBZ0lHUmhkR0VnUFNCamNtVmhkR1ZHY21GdFpTaHZjSFJwYjI1ekxtUmhkR0VwTzF4dUlDQWdJQ0FnSUNCa1lYUmhMbU52Ym5SbGVIUlFZWFJvSUQwZ1lYQndaVzVrUTI5dWRHVjRkRkJoZEdnb2IzQjBhVzl1Y3k1a1lYUmhMbU52Ym5SbGVIUlFZWFJvTENCdmNIUnBiMjV6TG1sa2Mxc3dYU2s3WEc0Z0lDQWdJQ0I5WEc1Y2JpQWdJQ0FnSUhKbGRIVnliaUJtYmloamIyNTBaWGgwTENCN1hHNGdJQ0FnSUNBZ0lHUmhkR0U2SUdSaGRHRXNYRzRnSUNBZ0lDQWdJR0pzYjJOclVHRnlZVzF6T2lCaWJHOWphMUJoY21GdGN5aGJZMjl1ZEdWNGRGMHNJRnRrWVhSaElDWW1JR1JoZEdFdVkyOXVkR1Y0ZEZCaGRHaGRLVnh1SUNBZ0lDQWdmU2s3WEc0Z0lDQWdmU0JsYkhObElIdGNiaUFnSUNBZ0lISmxkSFZ5YmlCdmNIUnBiMjV6TG1sdWRtVnljMlVvZEdocGN5azdYRzRnSUNBZ2ZWeHVJQ0I5S1R0Y2JuMWNiaUpkZlE9PVxuIiwiJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuXG52YXIgX3V0aWxzID0gcmVxdWlyZSgnLi91dGlscycpO1xuXG52YXIgbG9nZ2VyID0ge1xuICBtZXRob2RNYXA6IFsnZGVidWcnLCAnaW5mbycsICd3YXJuJywgJ2Vycm9yJ10sXG4gIGxldmVsOiAnaW5mbycsXG5cbiAgLy8gTWFwcyBhIGdpdmVuIGxldmVsIHZhbHVlIHRvIHRoZSBgbWV0aG9kTWFwYCBpbmRleGVzIGFib3ZlLlxuICBsb29rdXBMZXZlbDogZnVuY3Rpb24gbG9va3VwTGV2ZWwobGV2ZWwpIHtcbiAgICBpZiAodHlwZW9mIGxldmVsID09PSAnc3RyaW5nJykge1xuICAgICAgdmFyIGxldmVsTWFwID0gX3V0aWxzLmluZGV4T2YobG9nZ2VyLm1ldGhvZE1hcCwgbGV2ZWwudG9Mb3dlckNhc2UoKSk7XG4gICAgICBpZiAobGV2ZWxNYXAgPj0gMCkge1xuICAgICAgICBsZXZlbCA9IGxldmVsTWFwO1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgbGV2ZWwgPSBwYXJzZUludChsZXZlbCwgMTApO1xuICAgICAgfVxuICAgIH1cblxuICAgIHJldHVybiBsZXZlbDtcbiAgfSxcblxuICAvLyBDYW4gYmUgb3ZlcnJpZGRlbiBpbiB0aGUgaG9zdCBlbnZpcm9ubWVudFxuICBsb2c6IGZ1bmN0aW9uIGxvZyhsZXZlbCkge1xuICAgIGxldmVsID0gbG9nZ2VyLmxvb2t1cExldmVsKGxldmVsKTtcblxuICAgIGlmICh0eXBlb2YgY29uc29sZSAhPT0gJ3VuZGVmaW5lZCcgJiYgbG9nZ2VyLmxvb2t1cExldmVsKGxvZ2dlci5sZXZlbCkgPD0gbGV2ZWwpIHtcbiAgICAgIHZhciBtZXRob2QgPSBsb2dnZXIubWV0aG9kTWFwW2xldmVsXTtcbiAgICAgIGlmICghY29uc29sZVttZXRob2RdKSB7XG4gICAgICAgIC8vIGVzbGludC1kaXNhYmxlLWxpbmUgbm8tY29uc29sZVxuICAgICAgICBtZXRob2QgPSAnbG9nJztcbiAgICAgIH1cblxuICAgICAgZm9yICh2YXIgX2xlbiA9IGFyZ3VtZW50cy5sZW5ndGgsIG1lc3NhZ2UgPSBBcnJheShfbGVuID4gMSA/IF9sZW4gLSAxIDogMCksIF9rZXkgPSAxOyBfa2V5IDwgX2xlbjsgX2tleSsrKSB7XG4gICAgICAgIG1lc3NhZ2VbX2tleSAtIDFdID0gYXJndW1lbnRzW19rZXldO1xuICAgICAgfVxuXG4gICAgICBjb25zb2xlW21ldGhvZF0uYXBwbHkoY29uc29sZSwgbWVzc2FnZSk7IC8vIGVzbGludC1kaXNhYmxlLWxpbmUgbm8tY29uc29sZVxuICAgIH1cbiAgfVxufTtcblxuZXhwb3J0c1snZGVmYXVsdCddID0gbG9nZ2VyO1xubW9kdWxlLmV4cG9ydHMgPSBleHBvcnRzWydkZWZhdWx0J107XG4vLyMgc291cmNlTWFwcGluZ1VSTD1kYXRhOmFwcGxpY2F0aW9uL2pzb247Y2hhcnNldD11dGYtODtiYXNlNjQsZXlKMlpYSnphVzl1SWpvekxDSnpiM1Z5WTJWeklqcGJJaTR1THk0dUx5NHVMMnhwWWk5b1lXNWtiR1ZpWVhKekwyeHZaMmRsY2k1cWN5SmRMQ0p1WVcxbGN5STZXMTBzSW0xaGNIQnBibWR6SWpvaU96czdPM0ZDUVVGelFpeFRRVUZUT3p0QlFVVXZRaXhKUVVGSkxFMUJRVTBzUjBGQlJ6dEJRVU5ZTEZkQlFWTXNSVUZCUlN4RFFVRkRMRTlCUVU4c1JVRkJSU3hOUVVGTkxFVkJRVVVzVFVGQlRTeEZRVUZGTEU5QlFVOHNRMEZCUXp0QlFVTTNReXhQUVVGTExFVkJRVVVzVFVGQlRUczdPMEZCUjJJc1lVRkJWeXhGUVVGRkxIRkNRVUZUTEV0QlFVc3NSVUZCUlR0QlFVTXpRaXhSUVVGSkxFOUJRVThzUzBGQlN5eExRVUZMTEZGQlFWRXNSVUZCUlR0QlFVTTNRaXhWUVVGSkxGRkJRVkVzUjBGQlJ5eGxRVUZSTEUxQlFVMHNRMEZCUXl4VFFVRlRMRVZCUVVVc1MwRkJTeXhEUVVGRExGZEJRVmNzUlVGQlJTeERRVUZETEVOQlFVTTdRVUZET1VRc1ZVRkJTU3hSUVVGUkxFbEJRVWtzUTBGQlF5eEZRVUZGTzBGQlEycENMR0ZCUVVzc1IwRkJSeXhSUVVGUkxFTkJRVU03VDBGRGJFSXNUVUZCVFR0QlFVTk1MR0ZCUVVzc1IwRkJSeXhSUVVGUkxFTkJRVU1zUzBGQlN5eEZRVUZGTEVWQlFVVXNRMEZCUXl4RFFVRkRPMDlCUXpkQ08wdEJRMFk3TzBGQlJVUXNWMEZCVHl4TFFVRkxMRU5CUVVNN1IwRkRaRHM3TzBGQlIwUXNTMEZCUnl4RlFVRkZMR0ZCUVZNc1MwRkJTeXhGUVVGak8wRkJReTlDTEZOQlFVc3NSMEZCUnl4TlFVRk5MRU5CUVVNc1YwRkJWeXhEUVVGRExFdEJRVXNzUTBGQlF5eERRVUZET3p0QlFVVnNReXhSUVVGSkxFOUJRVThzVDBGQlR5eExRVUZMTEZkQlFWY3NTVUZCU1N4TlFVRk5MRU5CUVVNc1YwRkJWeXhEUVVGRExFMUJRVTBzUTBGQlF5eExRVUZMTEVOQlFVTXNTVUZCU1N4TFFVRkxMRVZCUVVVN1FVRkRMMFVzVlVGQlNTeE5RVUZOTEVkQlFVY3NUVUZCVFN4RFFVRkRMRk5CUVZNc1EwRkJReXhMUVVGTExFTkJRVU1zUTBGQlF6dEJRVU55UXl4VlFVRkpMRU5CUVVNc1QwRkJUeXhEUVVGRExFMUJRVTBzUTBGQlF5eEZRVUZGT3p0QlFVTndRaXhqUVVGTkxFZEJRVWNzUzBGQlN5eERRVUZETzA5QlEyaENPenQzUTBGUWJVSXNUMEZCVHp0QlFVRlFMR1ZCUVU4N096dEJRVkV6UWl4aFFVRlBMRU5CUVVNc1RVRkJUU3hQUVVGRExFTkJRV1lzVDBGQlR5eEZRVUZaTEU5QlFVOHNRMEZCUXl4RFFVRkRPMHRCUXpkQ08wZEJRMFk3UTBGRFJpeERRVUZET3p0eFFrRkZZU3hOUVVGTklpd2labWxzWlNJNklteHZaMmRsY2k1cWN5SXNJbk52ZFhKalpYTkRiMjUwWlc1MElqcGJJbWx0Y0c5eWRDQjdhVzVrWlhoUFpuMGdabkp2YlNBbkxpOTFkR2xzY3ljN1hHNWNibXhsZENCc2IyZG5aWElnUFNCN1hHNGdJRzFsZEdodlpFMWhjRG9nV3lka1pXSjFaeWNzSUNkcGJtWnZKeXdnSjNkaGNtNG5MQ0FuWlhKeWIzSW5YU3hjYmlBZ2JHVjJaV3c2SUNkcGJtWnZKeXhjYmx4dUlDQXZMeUJOWVhCeklHRWdaMmwyWlc0Z2JHVjJaV3dnZG1Gc2RXVWdkRzhnZEdobElHQnRaWFJvYjJSTllYQmdJR2x1WkdWNFpYTWdZV0p2ZG1VdVhHNGdJR3h2YjJ0MWNFeGxkbVZzT2lCbWRXNWpkR2x2Ymloc1pYWmxiQ2tnZTF4dUlDQWdJR2xtSUNoMGVYQmxiMllnYkdWMlpXd2dQVDA5SUNkemRISnBibWNuS1NCN1hHNGdJQ0FnSUNCc1pYUWdiR1YyWld4TllYQWdQU0JwYm1SbGVFOW1LR3h2WjJkbGNpNXRaWFJvYjJSTllYQXNJR3hsZG1Wc0xuUnZURzkzWlhKRFlYTmxLQ2twTzF4dUlDQWdJQ0FnYVdZZ0tHeGxkbVZzVFdGd0lENDlJREFwSUh0Y2JpQWdJQ0FnSUNBZ2JHVjJaV3dnUFNCc1pYWmxiRTFoY0R0Y2JpQWdJQ0FnSUgwZ1pXeHpaU0I3WEc0Z0lDQWdJQ0FnSUd4bGRtVnNJRDBnY0dGeWMyVkpiblFvYkdWMlpXd3NJREV3S1R0Y2JpQWdJQ0FnSUgxY2JpQWdJQ0I5WEc1Y2JpQWdJQ0J5WlhSMWNtNGdiR1YyWld3N1hHNGdJSDBzWEc1Y2JpQWdMeThnUTJGdUlHSmxJRzkyWlhKeWFXUmtaVzRnYVc0Z2RHaGxJR2h2YzNRZ1pXNTJhWEp2Ym0xbGJuUmNiaUFnYkc5bk9pQm1kVzVqZEdsdmJpaHNaWFpsYkN3Z0xpNHViV1Z6YzJGblpTa2dlMXh1SUNBZ0lHeGxkbVZzSUQwZ2JHOW5aMlZ5TG14dmIydDFjRXhsZG1Wc0tHeGxkbVZzS1R0Y2JseHVJQ0FnSUdsbUlDaDBlWEJsYjJZZ1kyOXVjMjlzWlNBaFBUMGdKM1Z1WkdWbWFXNWxaQ2NnSmlZZ2JHOW5aMlZ5TG14dmIydDFjRXhsZG1Wc0tHeHZaMmRsY2k1c1pYWmxiQ2tnUEQwZ2JHVjJaV3dwSUh0Y2JpQWdJQ0FnSUd4bGRDQnRaWFJvYjJRZ1BTQnNiMmRuWlhJdWJXVjBhRzlrVFdGd1cyeGxkbVZzWFR0Y2JpQWdJQ0FnSUdsbUlDZ2hZMjl1YzI5c1pWdHRaWFJvYjJSZEtTQjdJQzh2SUdWemJHbHVkQzFrYVhOaFlteGxMV3hwYm1VZ2JtOHRZMjl1YzI5c1pWeHVJQ0FnSUNBZ0lDQnRaWFJvYjJRZ1BTQW5iRzluSnp0Y2JpQWdJQ0FnSUgxY2JpQWdJQ0FnSUdOdmJuTnZiR1ZiYldWMGFHOWtYU2d1TGk1dFpYTnpZV2RsS1RzZ0x5OGdaWE5zYVc1MExXUnBjMkZpYkdVdGJHbHVaU0J1YnkxamIyNXpiMnhsWEc0Z0lDQWdmVnh1SUNCOVhHNTlPMXh1WEc1bGVIQnZjblFnWkdWbVlYVnNkQ0JzYjJkblpYSTdYRzRpWFgwPVxuIiwiLyogZ2xvYmFsIHdpbmRvdyAqL1xuJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuXG5leHBvcnRzWydkZWZhdWx0J10gPSBmdW5jdGlvbiAoSGFuZGxlYmFycykge1xuICAvKiBpc3RhbmJ1bCBpZ25vcmUgbmV4dCAqL1xuICB2YXIgcm9vdCA9IHR5cGVvZiBnbG9iYWwgIT09ICd1bmRlZmluZWQnID8gZ2xvYmFsIDogd2luZG93LFxuICAgICAgJEhhbmRsZWJhcnMgPSByb290LkhhbmRsZWJhcnM7XG4gIC8qIGlzdGFuYnVsIGlnbm9yZSBuZXh0ICovXG4gIEhhbmRsZWJhcnMubm9Db25mbGljdCA9IGZ1bmN0aW9uICgpIHtcbiAgICBpZiAocm9vdC5IYW5kbGViYXJzID09PSBIYW5kbGViYXJzKSB7XG4gICAgICByb290LkhhbmRsZWJhcnMgPSAkSGFuZGxlYmFycztcbiAgICB9XG4gICAgcmV0dXJuIEhhbmRsZWJhcnM7XG4gIH07XG59O1xuXG5tb2R1bGUuZXhwb3J0cyA9IGV4cG9ydHNbJ2RlZmF1bHQnXTtcbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDI1dkxXTnZibVpzYVdOMExtcHpJbDBzSW01aGJXVnpJanBiWFN3aWJXRndjR2x1WjNNaU9pSTdPenM3TzNGQ1FVTmxMRlZCUVZNc1ZVRkJWU3hGUVVGRk96dEJRVVZzUXl4TlFVRkpMRWxCUVVrc1IwRkJSeXhQUVVGUExFMUJRVTBzUzBGQlN5eFhRVUZYTEVkQlFVY3NUVUZCVFN4SFFVRkhMRTFCUVUwN1RVRkRkRVFzVjBGQlZ5eEhRVUZITEVsQlFVa3NRMEZCUXl4VlFVRlZMRU5CUVVNN08wRkJSV3hETEZsQlFWVXNRMEZCUXl4VlFVRlZMRWRCUVVjc1dVRkJWenRCUVVOcVF5eFJRVUZKTEVsQlFVa3NRMEZCUXl4VlFVRlZMRXRCUVVzc1ZVRkJWU3hGUVVGRk8wRkJRMnhETEZWQlFVa3NRMEZCUXl4VlFVRlZMRWRCUVVjc1YwRkJWeXhEUVVGRE8wdEJReTlDTzBGQlEwUXNWMEZCVHl4VlFVRlZMRU5CUVVNN1IwRkRia0lzUTBGQlF6dERRVU5JSWl3aVptbHNaU0k2SW01dkxXTnZibVpzYVdOMExtcHpJaXdpYzI5MWNtTmxjME52Ym5SbGJuUWlPbHNpTHlvZ1oyeHZZbUZzSUhkcGJtUnZkeUFxTDF4dVpYaHdiM0owSUdSbFptRjFiSFFnWm5WdVkzUnBiMjRvU0dGdVpHeGxZbUZ5Y3lrZ2UxeHVJQ0F2S2lCcGMzUmhibUoxYkNCcFoyNXZjbVVnYm1WNGRDQXFMMXh1SUNCc1pYUWdjbTl2ZENBOUlIUjVjR1Z2WmlCbmJHOWlZV3dnSVQwOUlDZDFibVJsWm1sdVpXUW5JRDhnWjJ4dlltRnNJRG9nZDJsdVpHOTNMRnh1SUNBZ0lDQWdKRWhoYm1Sc1pXSmhjbk1nUFNCeWIyOTBMa2hoYm1Sc1pXSmhjbk03WEc0Z0lDOHFJR2x6ZEdGdVluVnNJR2xuYm05eVpTQnVaWGgwSUNvdlhHNGdJRWhoYm1Sc1pXSmhjbk11Ym05RGIyNW1iR2xqZENBOUlHWjFibU4wYVc5dUtDa2dlMXh1SUNBZ0lHbG1JQ2h5YjI5MExraGhibVJzWldKaGNuTWdQVDA5SUVoaGJtUnNaV0poY25NcElIdGNiaUFnSUNBZ0lISnZiM1F1U0dGdVpHeGxZbUZ5Y3lBOUlDUklZVzVrYkdWaVlYSnpPMXh1SUNBZ0lIMWNiaUFnSUNCeVpYUjFjbTRnU0dGdVpHeGxZbUZ5Y3p0Y2JpQWdmVHRjYm4xY2JpSmRmUT09XG4iLCIndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG5leHBvcnRzLmNoZWNrUmV2aXNpb24gPSBjaGVja1JldmlzaW9uO1xuZXhwb3J0cy50ZW1wbGF0ZSA9IHRlbXBsYXRlO1xuZXhwb3J0cy53cmFwUHJvZ3JhbSA9IHdyYXBQcm9ncmFtO1xuZXhwb3J0cy5yZXNvbHZlUGFydGlhbCA9IHJlc29sdmVQYXJ0aWFsO1xuZXhwb3J0cy5pbnZva2VQYXJ0aWFsID0gaW52b2tlUGFydGlhbDtcbmV4cG9ydHMubm9vcCA9IG5vb3A7XG4vLyBpc3RhbmJ1bCBpZ25vcmUgbmV4dFxuXG5mdW5jdGlvbiBfaW50ZXJvcFJlcXVpcmVEZWZhdWx0KG9iaikgeyByZXR1cm4gb2JqICYmIG9iai5fX2VzTW9kdWxlID8gb2JqIDogeyAnZGVmYXVsdCc6IG9iaiB9OyB9XG5cbi8vIGlzdGFuYnVsIGlnbm9yZSBuZXh0XG5cbmZ1bmN0aW9uIF9pbnRlcm9wUmVxdWlyZVdpbGRjYXJkKG9iaikgeyBpZiAob2JqICYmIG9iai5fX2VzTW9kdWxlKSB7IHJldHVybiBvYmo7IH0gZWxzZSB7IHZhciBuZXdPYmogPSB7fTsgaWYgKG9iaiAhPSBudWxsKSB7IGZvciAodmFyIGtleSBpbiBvYmopIHsgaWYgKE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbChvYmosIGtleSkpIG5ld09ialtrZXldID0gb2JqW2tleV07IH0gfSBuZXdPYmpbJ2RlZmF1bHQnXSA9IG9iajsgcmV0dXJuIG5ld09iajsgfSB9XG5cbnZhciBfdXRpbHMgPSByZXF1aXJlKCcuL3V0aWxzJyk7XG5cbnZhciBVdGlscyA9IF9pbnRlcm9wUmVxdWlyZVdpbGRjYXJkKF91dGlscyk7XG5cbnZhciBfZXhjZXB0aW9uID0gcmVxdWlyZSgnLi9leGNlcHRpb24nKTtcblxudmFyIF9leGNlcHRpb24yID0gX2ludGVyb3BSZXF1aXJlRGVmYXVsdChfZXhjZXB0aW9uKTtcblxudmFyIF9iYXNlID0gcmVxdWlyZSgnLi9iYXNlJyk7XG5cbmZ1bmN0aW9uIGNoZWNrUmV2aXNpb24oY29tcGlsZXJJbmZvKSB7XG4gIHZhciBjb21waWxlclJldmlzaW9uID0gY29tcGlsZXJJbmZvICYmIGNvbXBpbGVySW5mb1swXSB8fCAxLFxuICAgICAgY3VycmVudFJldmlzaW9uID0gX2Jhc2UuQ09NUElMRVJfUkVWSVNJT047XG5cbiAgaWYgKGNvbXBpbGVyUmV2aXNpb24gIT09IGN1cnJlbnRSZXZpc2lvbikge1xuICAgIGlmIChjb21waWxlclJldmlzaW9uIDwgY3VycmVudFJldmlzaW9uKSB7XG4gICAgICB2YXIgcnVudGltZVZlcnNpb25zID0gX2Jhc2UuUkVWSVNJT05fQ0hBTkdFU1tjdXJyZW50UmV2aXNpb25dLFxuICAgICAgICAgIGNvbXBpbGVyVmVyc2lvbnMgPSBfYmFzZS5SRVZJU0lPTl9DSEFOR0VTW2NvbXBpbGVyUmV2aXNpb25dO1xuICAgICAgdGhyb3cgbmV3IF9leGNlcHRpb24yWydkZWZhdWx0J10oJ1RlbXBsYXRlIHdhcyBwcmVjb21waWxlZCB3aXRoIGFuIG9sZGVyIHZlcnNpb24gb2YgSGFuZGxlYmFycyB0aGFuIHRoZSBjdXJyZW50IHJ1bnRpbWUuICcgKyAnUGxlYXNlIHVwZGF0ZSB5b3VyIHByZWNvbXBpbGVyIHRvIGEgbmV3ZXIgdmVyc2lvbiAoJyArIHJ1bnRpbWVWZXJzaW9ucyArICcpIG9yIGRvd25ncmFkZSB5b3VyIHJ1bnRpbWUgdG8gYW4gb2xkZXIgdmVyc2lvbiAoJyArIGNvbXBpbGVyVmVyc2lvbnMgKyAnKS4nKTtcbiAgICB9IGVsc2Uge1xuICAgICAgLy8gVXNlIHRoZSBlbWJlZGRlZCB2ZXJzaW9uIGluZm8gc2luY2UgdGhlIHJ1bnRpbWUgZG9lc24ndCBrbm93IGFib3V0IHRoaXMgcmV2aXNpb24geWV0XG4gICAgICB0aHJvdyBuZXcgX2V4Y2VwdGlvbjJbJ2RlZmF1bHQnXSgnVGVtcGxhdGUgd2FzIHByZWNvbXBpbGVkIHdpdGggYSBuZXdlciB2ZXJzaW9uIG9mIEhhbmRsZWJhcnMgdGhhbiB0aGUgY3VycmVudCBydW50aW1lLiAnICsgJ1BsZWFzZSB1cGRhdGUgeW91ciBydW50aW1lIHRvIGEgbmV3ZXIgdmVyc2lvbiAoJyArIGNvbXBpbGVySW5mb1sxXSArICcpLicpO1xuICAgIH1cbiAgfVxufVxuXG5mdW5jdGlvbiB0ZW1wbGF0ZSh0ZW1wbGF0ZVNwZWMsIGVudikge1xuICAvKiBpc3RhbmJ1bCBpZ25vcmUgbmV4dCAqL1xuICBpZiAoIWVudikge1xuICAgIHRocm93IG5ldyBfZXhjZXB0aW9uMlsnZGVmYXVsdCddKCdObyBlbnZpcm9ubWVudCBwYXNzZWQgdG8gdGVtcGxhdGUnKTtcbiAgfVxuICBpZiAoIXRlbXBsYXRlU3BlYyB8fCAhdGVtcGxhdGVTcGVjLm1haW4pIHtcbiAgICB0aHJvdyBuZXcgX2V4Y2VwdGlvbjJbJ2RlZmF1bHQnXSgnVW5rbm93biB0ZW1wbGF0ZSBvYmplY3Q6ICcgKyB0eXBlb2YgdGVtcGxhdGVTcGVjKTtcbiAgfVxuXG4gIHRlbXBsYXRlU3BlYy5tYWluLmRlY29yYXRvciA9IHRlbXBsYXRlU3BlYy5tYWluX2Q7XG5cbiAgLy8gTm90ZTogVXNpbmcgZW52LlZNIHJlZmVyZW5jZXMgcmF0aGVyIHRoYW4gbG9jYWwgdmFyIHJlZmVyZW5jZXMgdGhyb3VnaG91dCB0aGlzIHNlY3Rpb24gdG8gYWxsb3dcbiAgLy8gZm9yIGV4dGVybmFsIHVzZXJzIHRvIG92ZXJyaWRlIHRoZXNlIGFzIHBzdWVkby1zdXBwb3J0ZWQgQVBJcy5cbiAgZW52LlZNLmNoZWNrUmV2aXNpb24odGVtcGxhdGVTcGVjLmNvbXBpbGVyKTtcblxuICBmdW5jdGlvbiBpbnZva2VQYXJ0aWFsV3JhcHBlcihwYXJ0aWFsLCBjb250ZXh0LCBvcHRpb25zKSB7XG4gICAgaWYgKG9wdGlvbnMuaGFzaCkge1xuICAgICAgY29udGV4dCA9IFV0aWxzLmV4dGVuZCh7fSwgY29udGV4dCwgb3B0aW9ucy5oYXNoKTtcbiAgICAgIGlmIChvcHRpb25zLmlkcykge1xuICAgICAgICBvcHRpb25zLmlkc1swXSA9IHRydWU7XG4gICAgICB9XG4gICAgfVxuXG4gICAgcGFydGlhbCA9IGVudi5WTS5yZXNvbHZlUGFydGlhbC5jYWxsKHRoaXMsIHBhcnRpYWwsIGNvbnRleHQsIG9wdGlvbnMpO1xuICAgIHZhciByZXN1bHQgPSBlbnYuVk0uaW52b2tlUGFydGlhbC5jYWxsKHRoaXMsIHBhcnRpYWwsIGNvbnRleHQsIG9wdGlvbnMpO1xuXG4gICAgaWYgKHJlc3VsdCA9PSBudWxsICYmIGVudi5jb21waWxlKSB7XG4gICAgICBvcHRpb25zLnBhcnRpYWxzW29wdGlvbnMubmFtZV0gPSBlbnYuY29tcGlsZShwYXJ0aWFsLCB0ZW1wbGF0ZVNwZWMuY29tcGlsZXJPcHRpb25zLCBlbnYpO1xuICAgICAgcmVzdWx0ID0gb3B0aW9ucy5wYXJ0aWFsc1tvcHRpb25zLm5hbWVdKGNvbnRleHQsIG9wdGlvbnMpO1xuICAgIH1cbiAgICBpZiAocmVzdWx0ICE9IG51bGwpIHtcbiAgICAgIGlmIChvcHRpb25zLmluZGVudCkge1xuICAgICAgICB2YXIgbGluZXMgPSByZXN1bHQuc3BsaXQoJ1xcbicpO1xuICAgICAgICBmb3IgKHZhciBpID0gMCwgbCA9IGxpbmVzLmxlbmd0aDsgaSA8IGw7IGkrKykge1xuICAgICAgICAgIGlmICghbGluZXNbaV0gJiYgaSArIDEgPT09IGwpIHtcbiAgICAgICAgICAgIGJyZWFrO1xuICAgICAgICAgIH1cblxuICAgICAgICAgIGxpbmVzW2ldID0gb3B0aW9ucy5pbmRlbnQgKyBsaW5lc1tpXTtcbiAgICAgICAgfVxuICAgICAgICByZXN1bHQgPSBsaW5lcy5qb2luKCdcXG4nKTtcbiAgICAgIH1cbiAgICAgIHJldHVybiByZXN1bHQ7XG4gICAgfSBlbHNlIHtcbiAgICAgIHRocm93IG5ldyBfZXhjZXB0aW9uMlsnZGVmYXVsdCddKCdUaGUgcGFydGlhbCAnICsgb3B0aW9ucy5uYW1lICsgJyBjb3VsZCBub3QgYmUgY29tcGlsZWQgd2hlbiBydW5uaW5nIGluIHJ1bnRpbWUtb25seSBtb2RlJyk7XG4gICAgfVxuICB9XG5cbiAgLy8gSnVzdCBhZGQgd2F0ZXJcbiAgdmFyIGNvbnRhaW5lciA9IHtcbiAgICBzdHJpY3Q6IGZ1bmN0aW9uIHN0cmljdChvYmosIG5hbWUpIHtcbiAgICAgIGlmICghKG5hbWUgaW4gb2JqKSkge1xuICAgICAgICB0aHJvdyBuZXcgX2V4Y2VwdGlvbjJbJ2RlZmF1bHQnXSgnXCInICsgbmFtZSArICdcIiBub3QgZGVmaW5lZCBpbiAnICsgb2JqKTtcbiAgICAgIH1cbiAgICAgIHJldHVybiBvYmpbbmFtZV07XG4gICAgfSxcbiAgICBsb29rdXA6IGZ1bmN0aW9uIGxvb2t1cChkZXB0aHMsIG5hbWUpIHtcbiAgICAgIHZhciBsZW4gPSBkZXB0aHMubGVuZ3RoO1xuICAgICAgZm9yICh2YXIgaSA9IDA7IGkgPCBsZW47IGkrKykge1xuICAgICAgICBpZiAoZGVwdGhzW2ldICYmIGRlcHRoc1tpXVtuYW1lXSAhPSBudWxsKSB7XG4gICAgICAgICAgcmV0dXJuIGRlcHRoc1tpXVtuYW1lXTtcbiAgICAgICAgfVxuICAgICAgfVxuICAgIH0sXG4gICAgbGFtYmRhOiBmdW5jdGlvbiBsYW1iZGEoY3VycmVudCwgY29udGV4dCkge1xuICAgICAgcmV0dXJuIHR5cGVvZiBjdXJyZW50ID09PSAnZnVuY3Rpb24nID8gY3VycmVudC5jYWxsKGNvbnRleHQpIDogY3VycmVudDtcbiAgICB9LFxuXG4gICAgZXNjYXBlRXhwcmVzc2lvbjogVXRpbHMuZXNjYXBlRXhwcmVzc2lvbixcbiAgICBpbnZva2VQYXJ0aWFsOiBpbnZva2VQYXJ0aWFsV3JhcHBlcixcblxuICAgIGZuOiBmdW5jdGlvbiBmbihpKSB7XG4gICAgICB2YXIgcmV0ID0gdGVtcGxhdGVTcGVjW2ldO1xuICAgICAgcmV0LmRlY29yYXRvciA9IHRlbXBsYXRlU3BlY1tpICsgJ19kJ107XG4gICAgICByZXR1cm4gcmV0O1xuICAgIH0sXG5cbiAgICBwcm9ncmFtczogW10sXG4gICAgcHJvZ3JhbTogZnVuY3Rpb24gcHJvZ3JhbShpLCBkYXRhLCBkZWNsYXJlZEJsb2NrUGFyYW1zLCBibG9ja1BhcmFtcywgZGVwdGhzKSB7XG4gICAgICB2YXIgcHJvZ3JhbVdyYXBwZXIgPSB0aGlzLnByb2dyYW1zW2ldLFxuICAgICAgICAgIGZuID0gdGhpcy5mbihpKTtcbiAgICAgIGlmIChkYXRhIHx8IGRlcHRocyB8fCBibG9ja1BhcmFtcyB8fCBkZWNsYXJlZEJsb2NrUGFyYW1zKSB7XG4gICAgICAgIHByb2dyYW1XcmFwcGVyID0gd3JhcFByb2dyYW0odGhpcywgaSwgZm4sIGRhdGEsIGRlY2xhcmVkQmxvY2tQYXJhbXMsIGJsb2NrUGFyYW1zLCBkZXB0aHMpO1xuICAgICAgfSBlbHNlIGlmICghcHJvZ3JhbVdyYXBwZXIpIHtcbiAgICAgICAgcHJvZ3JhbVdyYXBwZXIgPSB0aGlzLnByb2dyYW1zW2ldID0gd3JhcFByb2dyYW0odGhpcywgaSwgZm4pO1xuICAgICAgfVxuICAgICAgcmV0dXJuIHByb2dyYW1XcmFwcGVyO1xuICAgIH0sXG5cbiAgICBkYXRhOiBmdW5jdGlvbiBkYXRhKHZhbHVlLCBkZXB0aCkge1xuICAgICAgd2hpbGUgKHZhbHVlICYmIGRlcHRoLS0pIHtcbiAgICAgICAgdmFsdWUgPSB2YWx1ZS5fcGFyZW50O1xuICAgICAgfVxuICAgICAgcmV0dXJuIHZhbHVlO1xuICAgIH0sXG4gICAgbWVyZ2U6IGZ1bmN0aW9uIG1lcmdlKHBhcmFtLCBjb21tb24pIHtcbiAgICAgIHZhciBvYmogPSBwYXJhbSB8fCBjb21tb247XG5cbiAgICAgIGlmIChwYXJhbSAmJiBjb21tb24gJiYgcGFyYW0gIT09IGNvbW1vbikge1xuICAgICAgICBvYmogPSBVdGlscy5leHRlbmQoe30sIGNvbW1vbiwgcGFyYW0pO1xuICAgICAgfVxuXG4gICAgICByZXR1cm4gb2JqO1xuICAgIH0sXG4gICAgLy8gQW4gZW1wdHkgb2JqZWN0IHRvIHVzZSBhcyByZXBsYWNlbWVudCBmb3IgbnVsbC1jb250ZXh0c1xuICAgIG51bGxDb250ZXh0OiBPYmplY3Quc2VhbCh7fSksXG5cbiAgICBub29wOiBlbnYuVk0ubm9vcCxcbiAgICBjb21waWxlckluZm86IHRlbXBsYXRlU3BlYy5jb21waWxlclxuICB9O1xuXG4gIGZ1bmN0aW9uIHJldChjb250ZXh0KSB7XG4gICAgdmFyIG9wdGlvbnMgPSBhcmd1bWVudHMubGVuZ3RoIDw9IDEgfHwgYXJndW1lbnRzWzFdID09PSB1bmRlZmluZWQgPyB7fSA6IGFyZ3VtZW50c1sxXTtcblxuICAgIHZhciBkYXRhID0gb3B0aW9ucy5kYXRhO1xuXG4gICAgcmV0Ll9zZXR1cChvcHRpb25zKTtcbiAgICBpZiAoIW9wdGlvbnMucGFydGlhbCAmJiB0ZW1wbGF0ZVNwZWMudXNlRGF0YSkge1xuICAgICAgZGF0YSA9IGluaXREYXRhKGNvbnRleHQsIGRhdGEpO1xuICAgIH1cbiAgICB2YXIgZGVwdGhzID0gdW5kZWZpbmVkLFxuICAgICAgICBibG9ja1BhcmFtcyA9IHRlbXBsYXRlU3BlYy51c2VCbG9ja1BhcmFtcyA/IFtdIDogdW5kZWZpbmVkO1xuICAgIGlmICh0ZW1wbGF0ZVNwZWMudXNlRGVwdGhzKSB7XG4gICAgICBpZiAob3B0aW9ucy5kZXB0aHMpIHtcbiAgICAgICAgZGVwdGhzID0gY29udGV4dCAhPSBvcHRpb25zLmRlcHRoc1swXSA/IFtjb250ZXh0XS5jb25jYXQob3B0aW9ucy5kZXB0aHMpIDogb3B0aW9ucy5kZXB0aHM7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICBkZXB0aHMgPSBbY29udGV4dF07XG4gICAgICB9XG4gICAgfVxuXG4gICAgZnVuY3Rpb24gbWFpbihjb250ZXh0IC8qLCBvcHRpb25zKi8pIHtcbiAgICAgIHJldHVybiAnJyArIHRlbXBsYXRlU3BlYy5tYWluKGNvbnRhaW5lciwgY29udGV4dCwgY29udGFpbmVyLmhlbHBlcnMsIGNvbnRhaW5lci5wYXJ0aWFscywgZGF0YSwgYmxvY2tQYXJhbXMsIGRlcHRocyk7XG4gICAgfVxuICAgIG1haW4gPSBleGVjdXRlRGVjb3JhdG9ycyh0ZW1wbGF0ZVNwZWMubWFpbiwgbWFpbiwgY29udGFpbmVyLCBvcHRpb25zLmRlcHRocyB8fCBbXSwgZGF0YSwgYmxvY2tQYXJhbXMpO1xuICAgIHJldHVybiBtYWluKGNvbnRleHQsIG9wdGlvbnMpO1xuICB9XG4gIHJldC5pc1RvcCA9IHRydWU7XG5cbiAgcmV0Ll9zZXR1cCA9IGZ1bmN0aW9uIChvcHRpb25zKSB7XG4gICAgaWYgKCFvcHRpb25zLnBhcnRpYWwpIHtcbiAgICAgIGNvbnRhaW5lci5oZWxwZXJzID0gY29udGFpbmVyLm1lcmdlKG9wdGlvbnMuaGVscGVycywgZW52LmhlbHBlcnMpO1xuXG4gICAgICBpZiAodGVtcGxhdGVTcGVjLnVzZVBhcnRpYWwpIHtcbiAgICAgICAgY29udGFpbmVyLnBhcnRpYWxzID0gY29udGFpbmVyLm1lcmdlKG9wdGlvbnMucGFydGlhbHMsIGVudi5wYXJ0aWFscyk7XG4gICAgICB9XG4gICAgICBpZiAodGVtcGxhdGVTcGVjLnVzZVBhcnRpYWwgfHwgdGVtcGxhdGVTcGVjLnVzZURlY29yYXRvcnMpIHtcbiAgICAgICAgY29udGFpbmVyLmRlY29yYXRvcnMgPSBjb250YWluZXIubWVyZ2Uob3B0aW9ucy5kZWNvcmF0b3JzLCBlbnYuZGVjb3JhdG9ycyk7XG4gICAgICB9XG4gICAgfSBlbHNlIHtcbiAgICAgIGNvbnRhaW5lci5oZWxwZXJzID0gb3B0aW9ucy5oZWxwZXJzO1xuICAgICAgY29udGFpbmVyLnBhcnRpYWxzID0gb3B0aW9ucy5wYXJ0aWFscztcbiAgICAgIGNvbnRhaW5lci5kZWNvcmF0b3JzID0gb3B0aW9ucy5kZWNvcmF0b3JzO1xuICAgIH1cbiAgfTtcblxuICByZXQuX2NoaWxkID0gZnVuY3Rpb24gKGksIGRhdGEsIGJsb2NrUGFyYW1zLCBkZXB0aHMpIHtcbiAgICBpZiAodGVtcGxhdGVTcGVjLnVzZUJsb2NrUGFyYW1zICYmICFibG9ja1BhcmFtcykge1xuICAgICAgdGhyb3cgbmV3IF9leGNlcHRpb24yWydkZWZhdWx0J10oJ211c3QgcGFzcyBibG9jayBwYXJhbXMnKTtcbiAgICB9XG4gICAgaWYgKHRlbXBsYXRlU3BlYy51c2VEZXB0aHMgJiYgIWRlcHRocykge1xuICAgICAgdGhyb3cgbmV3IF9leGNlcHRpb24yWydkZWZhdWx0J10oJ211c3QgcGFzcyBwYXJlbnQgZGVwdGhzJyk7XG4gICAgfVxuXG4gICAgcmV0dXJuIHdyYXBQcm9ncmFtKGNvbnRhaW5lciwgaSwgdGVtcGxhdGVTcGVjW2ldLCBkYXRhLCAwLCBibG9ja1BhcmFtcywgZGVwdGhzKTtcbiAgfTtcbiAgcmV0dXJuIHJldDtcbn1cblxuZnVuY3Rpb24gd3JhcFByb2dyYW0oY29udGFpbmVyLCBpLCBmbiwgZGF0YSwgZGVjbGFyZWRCbG9ja1BhcmFtcywgYmxvY2tQYXJhbXMsIGRlcHRocykge1xuICBmdW5jdGlvbiBwcm9nKGNvbnRleHQpIHtcbiAgICB2YXIgb3B0aW9ucyA9IGFyZ3VtZW50cy5sZW5ndGggPD0gMSB8fCBhcmd1bWVudHNbMV0gPT09IHVuZGVmaW5lZCA/IHt9IDogYXJndW1lbnRzWzFdO1xuXG4gICAgdmFyIGN1cnJlbnREZXB0aHMgPSBkZXB0aHM7XG4gICAgaWYgKGRlcHRocyAmJiBjb250ZXh0ICE9IGRlcHRoc1swXSAmJiAhKGNvbnRleHQgPT09IGNvbnRhaW5lci5udWxsQ29udGV4dCAmJiBkZXB0aHNbMF0gPT09IG51bGwpKSB7XG4gICAgICBjdXJyZW50RGVwdGhzID0gW2NvbnRleHRdLmNvbmNhdChkZXB0aHMpO1xuICAgIH1cblxuICAgIHJldHVybiBmbihjb250YWluZXIsIGNvbnRleHQsIGNvbnRhaW5lci5oZWxwZXJzLCBjb250YWluZXIucGFydGlhbHMsIG9wdGlvbnMuZGF0YSB8fCBkYXRhLCBibG9ja1BhcmFtcyAmJiBbb3B0aW9ucy5ibG9ja1BhcmFtc10uY29uY2F0KGJsb2NrUGFyYW1zKSwgY3VycmVudERlcHRocyk7XG4gIH1cblxuICBwcm9nID0gZXhlY3V0ZURlY29yYXRvcnMoZm4sIHByb2csIGNvbnRhaW5lciwgZGVwdGhzLCBkYXRhLCBibG9ja1BhcmFtcyk7XG5cbiAgcHJvZy5wcm9ncmFtID0gaTtcbiAgcHJvZy5kZXB0aCA9IGRlcHRocyA/IGRlcHRocy5sZW5ndGggOiAwO1xuICBwcm9nLmJsb2NrUGFyYW1zID0gZGVjbGFyZWRCbG9ja1BhcmFtcyB8fCAwO1xuICByZXR1cm4gcHJvZztcbn1cblxuZnVuY3Rpb24gcmVzb2x2ZVBhcnRpYWwocGFydGlhbCwgY29udGV4dCwgb3B0aW9ucykge1xuICBpZiAoIXBhcnRpYWwpIHtcbiAgICBpZiAob3B0aW9ucy5uYW1lID09PSAnQHBhcnRpYWwtYmxvY2snKSB7XG4gICAgICBwYXJ0aWFsID0gb3B0aW9ucy5kYXRhWydwYXJ0aWFsLWJsb2NrJ107XG4gICAgfSBlbHNlIHtcbiAgICAgIHBhcnRpYWwgPSBvcHRpb25zLnBhcnRpYWxzW29wdGlvbnMubmFtZV07XG4gICAgfVxuICB9IGVsc2UgaWYgKCFwYXJ0aWFsLmNhbGwgJiYgIW9wdGlvbnMubmFtZSkge1xuICAgIC8vIFRoaXMgaXMgYSBkeW5hbWljIHBhcnRpYWwgdGhhdCByZXR1cm5lZCBhIHN0cmluZ1xuICAgIG9wdGlvbnMubmFtZSA9IHBhcnRpYWw7XG4gICAgcGFydGlhbCA9IG9wdGlvbnMucGFydGlhbHNbcGFydGlhbF07XG4gIH1cbiAgcmV0dXJuIHBhcnRpYWw7XG59XG5cbmZ1bmN0aW9uIGludm9rZVBhcnRpYWwocGFydGlhbCwgY29udGV4dCwgb3B0aW9ucykge1xuICAvLyBVc2UgdGhlIGN1cnJlbnQgY2xvc3VyZSBjb250ZXh0IHRvIHNhdmUgdGhlIHBhcnRpYWwtYmxvY2sgaWYgdGhpcyBwYXJ0aWFsXG4gIHZhciBjdXJyZW50UGFydGlhbEJsb2NrID0gb3B0aW9ucy5kYXRhICYmIG9wdGlvbnMuZGF0YVsncGFydGlhbC1ibG9jayddO1xuICBvcHRpb25zLnBhcnRpYWwgPSB0cnVlO1xuICBpZiAob3B0aW9ucy5pZHMpIHtcbiAgICBvcHRpb25zLmRhdGEuY29udGV4dFBhdGggPSBvcHRpb25zLmlkc1swXSB8fCBvcHRpb25zLmRhdGEuY29udGV4dFBhdGg7XG4gIH1cblxuICB2YXIgcGFydGlhbEJsb2NrID0gdW5kZWZpbmVkO1xuICBpZiAob3B0aW9ucy5mbiAmJiBvcHRpb25zLmZuICE9PSBub29wKSB7XG4gICAgKGZ1bmN0aW9uICgpIHtcbiAgICAgIG9wdGlvbnMuZGF0YSA9IF9iYXNlLmNyZWF0ZUZyYW1lKG9wdGlvbnMuZGF0YSk7XG4gICAgICAvLyBXcmFwcGVyIGZ1bmN0aW9uIHRvIGdldCBhY2Nlc3MgdG8gY3VycmVudFBhcnRpYWxCbG9jayBmcm9tIHRoZSBjbG9zdXJlXG4gICAgICB2YXIgZm4gPSBvcHRpb25zLmZuO1xuICAgICAgcGFydGlhbEJsb2NrID0gb3B0aW9ucy5kYXRhWydwYXJ0aWFsLWJsb2NrJ10gPSBmdW5jdGlvbiBwYXJ0aWFsQmxvY2tXcmFwcGVyKGNvbnRleHQpIHtcbiAgICAgICAgdmFyIG9wdGlvbnMgPSBhcmd1bWVudHMubGVuZ3RoIDw9IDEgfHwgYXJndW1lbnRzWzFdID09PSB1bmRlZmluZWQgPyB7fSA6IGFyZ3VtZW50c1sxXTtcblxuICAgICAgICAvLyBSZXN0b3JlIHRoZSBwYXJ0aWFsLWJsb2NrIGZyb20gdGhlIGNsb3N1cmUgZm9yIHRoZSBleGVjdXRpb24gb2YgdGhlIGJsb2NrXG4gICAgICAgIC8vIGkuZS4gdGhlIHBhcnQgaW5zaWRlIHRoZSBibG9jayBvZiB0aGUgcGFydGlhbCBjYWxsLlxuICAgICAgICBvcHRpb25zLmRhdGEgPSBfYmFzZS5jcmVhdGVGcmFtZShvcHRpb25zLmRhdGEpO1xuICAgICAgICBvcHRpb25zLmRhdGFbJ3BhcnRpYWwtYmxvY2snXSA9IGN1cnJlbnRQYXJ0aWFsQmxvY2s7XG4gICAgICAgIHJldHVybiBmbihjb250ZXh0LCBvcHRpb25zKTtcbiAgICAgIH07XG4gICAgICBpZiAoZm4ucGFydGlhbHMpIHtcbiAgICAgICAgb3B0aW9ucy5wYXJ0aWFscyA9IFV0aWxzLmV4dGVuZCh7fSwgb3B0aW9ucy5wYXJ0aWFscywgZm4ucGFydGlhbHMpO1xuICAgICAgfVxuICAgIH0pKCk7XG4gIH1cblxuICBpZiAocGFydGlhbCA9PT0gdW5kZWZpbmVkICYmIHBhcnRpYWxCbG9jaykge1xuICAgIHBhcnRpYWwgPSBwYXJ0aWFsQmxvY2s7XG4gIH1cblxuICBpZiAocGFydGlhbCA9PT0gdW5kZWZpbmVkKSB7XG4gICAgdGhyb3cgbmV3IF9leGNlcHRpb24yWydkZWZhdWx0J10oJ1RoZSBwYXJ0aWFsICcgKyBvcHRpb25zLm5hbWUgKyAnIGNvdWxkIG5vdCBiZSBmb3VuZCcpO1xuICB9IGVsc2UgaWYgKHBhcnRpYWwgaW5zdGFuY2VvZiBGdW5jdGlvbikge1xuICAgIHJldHVybiBwYXJ0aWFsKGNvbnRleHQsIG9wdGlvbnMpO1xuICB9XG59XG5cbmZ1bmN0aW9uIG5vb3AoKSB7XG4gIHJldHVybiAnJztcbn1cblxuZnVuY3Rpb24gaW5pdERhdGEoY29udGV4dCwgZGF0YSkge1xuICBpZiAoIWRhdGEgfHwgISgncm9vdCcgaW4gZGF0YSkpIHtcbiAgICBkYXRhID0gZGF0YSA/IF9iYXNlLmNyZWF0ZUZyYW1lKGRhdGEpIDoge307XG4gICAgZGF0YS5yb290ID0gY29udGV4dDtcbiAgfVxuICByZXR1cm4gZGF0YTtcbn1cblxuZnVuY3Rpb24gZXhlY3V0ZURlY29yYXRvcnMoZm4sIHByb2csIGNvbnRhaW5lciwgZGVwdGhzLCBkYXRhLCBibG9ja1BhcmFtcykge1xuICBpZiAoZm4uZGVjb3JhdG9yKSB7XG4gICAgdmFyIHByb3BzID0ge307XG4gICAgcHJvZyA9IGZuLmRlY29yYXRvcihwcm9nLCBwcm9wcywgY29udGFpbmVyLCBkZXB0aHMgJiYgZGVwdGhzWzBdLCBkYXRhLCBibG9ja1BhcmFtcywgZGVwdGhzKTtcbiAgICBVdGlscy5leHRlbmQocHJvZywgcHJvcHMpO1xuICB9XG4gIHJldHVybiBwcm9nO1xufVxuLy8jIHNvdXJjZU1hcHBpbmdVUkw9ZGF0YTphcHBsaWNhdGlvbi9qc29uO2NoYXJzZXQ9dXRmLTg7YmFzZTY0LGV5SjJaWEp6YVc5dUlqb3pMQ0p6YjNWeVkyVnpJanBiSWk0dUx5NHVMeTR1TDJ4cFlpOW9ZVzVrYkdWaVlYSnpMM0oxYm5ScGJXVXVhbk1pWFN3aWJtRnRaWE1pT2x0ZExDSnRZWEJ3YVc1bmN5STZJanM3T3pzN096czdPenM3T3pzN096czdjVUpCUVhWQ0xGTkJRVk03TzBsQlFYQkNMRXRCUVVzN08zbENRVU5MTEdGQlFXRTdPenM3YjBKQlF6aENMRkZCUVZFN08wRkJSV3hGTEZOQlFWTXNZVUZCWVN4RFFVRkRMRmxCUVZrc1JVRkJSVHRCUVVNeFF5eE5RVUZOTEdkQ1FVRm5RaXhIUVVGSExGbEJRVmtzU1VGQlNTeFpRVUZaTEVOQlFVTXNRMEZCUXl4RFFVRkRMRWxCUVVrc1EwRkJRenROUVVOMlJDeGxRVUZsTERCQ1FVRnZRaXhEUVVGRE96dEJRVVV4UXl4TlFVRkpMR2RDUVVGblFpeExRVUZMTEdWQlFXVXNSVUZCUlR0QlFVTjRReXhSUVVGSkxHZENRVUZuUWl4SFFVRkhMR1ZCUVdVc1JVRkJSVHRCUVVOMFF5eFZRVUZOTEdWQlFXVXNSMEZCUnl4MVFrRkJhVUlzWlVGQlpTeERRVUZETzFWQlEyNUVMR2RDUVVGblFpeEhRVUZITEhWQ1FVRnBRaXhuUWtGQlowSXNRMEZCUXl4RFFVRkRPMEZCUXpWRUxGbEJRVTBzTWtKQlFXTXNlVVpCUVhsR0xFZEJRM1pITEhGRVFVRnhSQ3hIUVVGSExHVkJRV1VzUjBGQlJ5eHRSRUZCYlVRc1IwRkJSeXhuUWtGQlowSXNSMEZCUnl4SlFVRkpMRU5CUVVNc1EwRkJRenRMUVVOb1N5eE5RVUZOT3p0QlFVVk1MRmxCUVUwc01rSkJRV01zZDBaQlFYZEdMRWRCUTNSSExHbEVRVUZwUkN4SFFVRkhMRmxCUVZrc1EwRkJReXhEUVVGRExFTkJRVU1zUjBGQlJ5eEpRVUZKTEVOQlFVTXNRMEZCUXp0TFFVTnVSanRIUVVOR08wTkJRMFk3TzBGQlJVMHNVMEZCVXl4UlFVRlJMRU5CUVVNc1dVRkJXU3hGUVVGRkxFZEJRVWNzUlVGQlJUczdRVUZGTVVNc1RVRkJTU3hEUVVGRExFZEJRVWNzUlVGQlJUdEJRVU5TTEZWQlFVMHNNa0pCUVdNc2JVTkJRVzFETEVOQlFVTXNRMEZCUXp0SFFVTXhSRHRCUVVORUxFMUJRVWtzUTBGQlF5eFpRVUZaTEVsQlFVa3NRMEZCUXl4WlFVRlpMRU5CUVVNc1NVRkJTU3hGUVVGRk8wRkJRM1pETEZWQlFVMHNNa0pCUVdNc01rSkJRVEpDTEVkQlFVY3NUMEZCVHl4WlFVRlpMRU5CUVVNc1EwRkJRenRIUVVONFJUczdRVUZGUkN4alFVRlpMRU5CUVVNc1NVRkJTU3hEUVVGRExGTkJRVk1zUjBGQlJ5eFpRVUZaTEVOQlFVTXNUVUZCVFN4RFFVRkRPenM3TzBGQlNXeEVMRXRCUVVjc1EwRkJReXhGUVVGRkxFTkJRVU1zWVVGQllTeERRVUZETEZsQlFWa3NRMEZCUXl4UlFVRlJMRU5CUVVNc1EwRkJRenM3UVVGRk5VTXNWMEZCVXl4dlFrRkJiMElzUTBGQlF5eFBRVUZQTEVWQlFVVXNUMEZCVHl4RlFVRkZMRTlCUVU4c1JVRkJSVHRCUVVOMlJDeFJRVUZKTEU5QlFVOHNRMEZCUXl4SlFVRkpMRVZCUVVVN1FVRkRhRUlzWVVGQlR5eEhRVUZITEV0QlFVc3NRMEZCUXl4TlFVRk5MRU5CUVVNc1JVRkJSU3hGUVVGRkxFOUJRVThzUlVGQlJTeFBRVUZQTEVOQlFVTXNTVUZCU1N4RFFVRkRMRU5CUVVNN1FVRkRiRVFzVlVGQlNTeFBRVUZQTEVOQlFVTXNSMEZCUnl4RlFVRkZPMEZCUTJZc1pVRkJUeXhEUVVGRExFZEJRVWNzUTBGQlF5eERRVUZETEVOQlFVTXNSMEZCUnl4SlFVRkpMRU5CUVVNN1QwRkRka0k3UzBGRFJqczdRVUZGUkN4WFFVRlBMRWRCUVVjc1IwRkJSeXhEUVVGRExFVkJRVVVzUTBGQlF5eGpRVUZqTEVOQlFVTXNTVUZCU1N4RFFVRkRMRWxCUVVrc1JVRkJSU3hQUVVGUExFVkJRVVVzVDBGQlR5eEZRVUZGTEU5QlFVOHNRMEZCUXl4RFFVRkRPMEZCUTNSRkxGRkJRVWtzVFVGQlRTeEhRVUZITEVkQlFVY3NRMEZCUXl4RlFVRkZMRU5CUVVNc1lVRkJZU3hEUVVGRExFbEJRVWtzUTBGQlF5eEpRVUZKTEVWQlFVVXNUMEZCVHl4RlFVRkZMRTlCUVU4c1JVRkJSU3hQUVVGUExFTkJRVU1zUTBGQlF6czdRVUZGZUVVc1VVRkJTU3hOUVVGTkxFbEJRVWtzU1VGQlNTeEpRVUZKTEVkQlFVY3NRMEZCUXl4UFFVRlBMRVZCUVVVN1FVRkRha01zWVVGQlR5eERRVUZETEZGQlFWRXNRMEZCUXl4UFFVRlBMRU5CUVVNc1NVRkJTU3hEUVVGRExFZEJRVWNzUjBGQlJ5eERRVUZETEU5QlFVOHNRMEZCUXl4UFFVRlBMRVZCUVVVc1dVRkJXU3hEUVVGRExHVkJRV1VzUlVGQlJTeEhRVUZITEVOQlFVTXNRMEZCUXp0QlFVTjZSaXhaUVVGTkxFZEJRVWNzVDBGQlR5eERRVUZETEZGQlFWRXNRMEZCUXl4UFFVRlBMRU5CUVVNc1NVRkJTU3hEUVVGRExFTkJRVU1zVDBGQlR5eEZRVUZGTEU5QlFVOHNRMEZCUXl4RFFVRkRPMHRCUXpORU8wRkJRMFFzVVVGQlNTeE5RVUZOTEVsQlFVa3NTVUZCU1N4RlFVRkZPMEZCUTJ4Q0xGVkJRVWtzVDBGQlR5eERRVUZETEUxQlFVMHNSVUZCUlR0QlFVTnNRaXhaUVVGSkxFdEJRVXNzUjBGQlJ5eE5RVUZOTEVOQlFVTXNTMEZCU3l4RFFVRkRMRWxCUVVrc1EwRkJReXhEUVVGRE8wRkJReTlDTEdGQlFVc3NTVUZCU1N4RFFVRkRMRWRCUVVjc1EwRkJReXhGUVVGRkxFTkJRVU1zUjBGQlJ5eExRVUZMTEVOQlFVTXNUVUZCVFN4RlFVRkZMRU5CUVVNc1IwRkJSeXhEUVVGRExFVkJRVVVzUTBGQlF5eEZRVUZGTEVWQlFVVTdRVUZETlVNc1kwRkJTU3hEUVVGRExFdEJRVXNzUTBGQlF5eERRVUZETEVOQlFVTXNTVUZCU1N4RFFVRkRMRWRCUVVjc1EwRkJReXhMUVVGTExFTkJRVU1zUlVGQlJUdEJRVU0xUWl4clFrRkJUVHRYUVVOUU96dEJRVVZFTEdWQlFVc3NRMEZCUXl4RFFVRkRMRU5CUVVNc1IwRkJSeXhQUVVGUExFTkJRVU1zVFVGQlRTeEhRVUZITEV0QlFVc3NRMEZCUXl4RFFVRkRMRU5CUVVNc1EwRkJRenRUUVVOMFF6dEJRVU5FTEdOQlFVMHNSMEZCUnl4TFFVRkxMRU5CUVVNc1NVRkJTU3hEUVVGRExFbEJRVWtzUTBGQlF5eERRVUZETzA5QlF6TkNPMEZCUTBRc1lVRkJUeXhOUVVGTkxFTkJRVU03UzBGRFppeE5RVUZOTzBGQlEwd3NXVUZCVFN3eVFrRkJZeXhqUVVGakxFZEJRVWNzVDBGQlR5eERRVUZETEVsQlFVa3NSMEZCUnl3d1JFRkJNRVFzUTBGQlF5eERRVUZETzB0QlEycElPMGRCUTBZN096dEJRVWRFTEUxQlFVa3NVMEZCVXl4SFFVRkhPMEZCUTJRc1ZVRkJUU3hGUVVGRkxHZENRVUZUTEVkQlFVY3NSVUZCUlN4SlFVRkpMRVZCUVVVN1FVRkRNVUlzVlVGQlNTeEZRVUZGTEVsQlFVa3NTVUZCU1N4SFFVRkhMRU5CUVVFc1FVRkJReXhGUVVGRk8wRkJRMnhDTEdOQlFVMHNNa0pCUVdNc1IwRkJSeXhIUVVGSExFbEJRVWtzUjBGQlJ5eHRRa0ZCYlVJc1IwRkJSeXhIUVVGSExFTkJRVU1zUTBGQlF6dFBRVU0zUkR0QlFVTkVMR0ZCUVU4c1IwRkJSeXhEUVVGRExFbEJRVWtzUTBGQlF5eERRVUZETzB0QlEyeENPMEZCUTBRc1ZVRkJUU3hGUVVGRkxHZENRVUZUTEUxQlFVMHNSVUZCUlN4SlFVRkpMRVZCUVVVN1FVRkROMElzVlVGQlRTeEhRVUZITEVkQlFVY3NUVUZCVFN4RFFVRkRMRTFCUVUwc1EwRkJRenRCUVVNeFFpeFhRVUZMTEVsQlFVa3NRMEZCUXl4SFFVRkhMRU5CUVVNc1JVRkJSU3hEUVVGRExFZEJRVWNzUjBGQlJ5eEZRVUZGTEVOQlFVTXNSVUZCUlN4RlFVRkZPMEZCUXpWQ0xGbEJRVWtzVFVGQlRTeERRVUZETEVOQlFVTXNRMEZCUXl4SlFVRkpMRTFCUVUwc1EwRkJReXhEUVVGRExFTkJRVU1zUTBGQlF5eEpRVUZKTEVOQlFVTXNTVUZCU1N4SlFVRkpMRVZCUVVVN1FVRkRlRU1zYVVKQlFVOHNUVUZCVFN4RFFVRkRMRU5CUVVNc1EwRkJReXhEUVVGRExFbEJRVWtzUTBGQlF5eERRVUZETzFOQlEzaENPMDlCUTBZN1MwRkRSanRCUVVORUxGVkJRVTBzUlVGQlJTeG5Ra0ZCVXl4UFFVRlBMRVZCUVVVc1QwRkJUeXhGUVVGRk8wRkJRMnBETEdGQlFVOHNUMEZCVHl4UFFVRlBMRXRCUVVzc1ZVRkJWU3hIUVVGSExFOUJRVThzUTBGQlF5eEpRVUZKTEVOQlFVTXNUMEZCVHl4RFFVRkRMRWRCUVVjc1QwRkJUeXhEUVVGRE8wdEJRM2hGT3p0QlFVVkVMRzlDUVVGblFpeEZRVUZGTEV0QlFVc3NRMEZCUXl4blFrRkJaMEk3UVVGRGVFTXNhVUpCUVdFc1JVRkJSU3h2UWtGQmIwSTdPMEZCUlc1RExFMUJRVVVzUlVGQlJTeFpRVUZUTEVOQlFVTXNSVUZCUlR0QlFVTmtMRlZCUVVrc1IwRkJSeXhIUVVGSExGbEJRVmtzUTBGQlF5eERRVUZETEVOQlFVTXNRMEZCUXp0QlFVTXhRaXhUUVVGSExFTkJRVU1zVTBGQlV5eEhRVUZITEZsQlFWa3NRMEZCUXl4RFFVRkRMRWRCUVVjc1NVRkJTU3hEUVVGRExFTkJRVU03UVVGRGRrTXNZVUZCVHl4SFFVRkhMRU5CUVVNN1MwRkRXanM3UVVGRlJDeFpRVUZSTEVWQlFVVXNSVUZCUlR0QlFVTmFMRmRCUVU4c1JVRkJSU3hwUWtGQlV5eERRVUZETEVWQlFVVXNTVUZCU1N4RlFVRkZMRzFDUVVGdFFpeEZRVUZGTEZkQlFWY3NSVUZCUlN4TlFVRk5MRVZCUVVVN1FVRkRia1VzVlVGQlNTeGpRVUZqTEVkQlFVY3NTVUZCU1N4RFFVRkRMRkZCUVZFc1EwRkJReXhEUVVGRExFTkJRVU03VlVGRGFrTXNSVUZCUlN4SFFVRkhMRWxCUVVrc1EwRkJReXhGUVVGRkxFTkJRVU1zUTBGQlF5eERRVUZETEVOQlFVTTdRVUZEY0VJc1ZVRkJTU3hKUVVGSkxFbEJRVWtzVFVGQlRTeEpRVUZKTEZkQlFWY3NTVUZCU1N4dFFrRkJiVUlzUlVGQlJUdEJRVU40UkN4elFrRkJZeXhIUVVGSExGZEJRVmNzUTBGQlF5eEpRVUZKTEVWQlFVVXNRMEZCUXl4RlFVRkZMRVZCUVVVc1JVRkJSU3hKUVVGSkxFVkJRVVVzYlVKQlFXMUNMRVZCUVVVc1YwRkJWeXhGUVVGRkxFMUJRVTBzUTBGQlF5eERRVUZETzA5QlF6TkdMRTFCUVUwc1NVRkJTU3hEUVVGRExHTkJRV01zUlVGQlJUdEJRVU14UWl4elFrRkJZeXhIUVVGSExFbEJRVWtzUTBGQlF5eFJRVUZSTEVOQlFVTXNRMEZCUXl4RFFVRkRMRWRCUVVjc1YwRkJWeXhEUVVGRExFbEJRVWtzUlVGQlJTeERRVUZETEVWQlFVVXNSVUZCUlN4RFFVRkRMRU5CUVVNN1QwRkRPVVE3UVVGRFJDeGhRVUZQTEdOQlFXTXNRMEZCUXp0TFFVTjJRanM3UVVGRlJDeFJRVUZKTEVWQlFVVXNZMEZCVXl4TFFVRkxMRVZCUVVVc1MwRkJTeXhGUVVGRk8wRkJRek5DTEdGQlFVOHNTMEZCU3l4SlFVRkpMRXRCUVVzc1JVRkJSU3hGUVVGRk8wRkJRM1pDTEdGQlFVc3NSMEZCUnl4TFFVRkxMRU5CUVVNc1QwRkJUeXhEUVVGRE8wOUJRM1pDTzBGQlEwUXNZVUZCVHl4TFFVRkxMRU5CUVVNN1MwRkRaRHRCUVVORUxGTkJRVXNzUlVGQlJTeGxRVUZUTEV0QlFVc3NSVUZCUlN4TlFVRk5MRVZCUVVVN1FVRkROMElzVlVGQlNTeEhRVUZITEVkQlFVY3NTMEZCU3l4SlFVRkpMRTFCUVUwc1EwRkJRenM3UVVGRk1VSXNWVUZCU1N4TFFVRkxMRWxCUVVrc1RVRkJUU3hKUVVGTExFdEJRVXNzUzBGQlN5eE5RVUZOTEVGQlFVTXNSVUZCUlR0QlFVTjZReXhYUVVGSExFZEJRVWNzUzBGQlN5eERRVUZETEUxQlFVMHNRMEZCUXl4RlFVRkZMRVZCUVVVc1RVRkJUU3hGUVVGRkxFdEJRVXNzUTBGQlF5eERRVUZETzA5QlEzWkRPenRCUVVWRUxHRkJRVThzUjBGQlJ5eERRVUZETzB0QlExbzdPMEZCUlVRc1pVRkJWeXhGUVVGRkxFMUJRVTBzUTBGQlF5eEpRVUZKTEVOQlFVTXNSVUZCUlN4RFFVRkRPenRCUVVVMVFpeFJRVUZKTEVWQlFVVXNSMEZCUnl4RFFVRkRMRVZCUVVVc1EwRkJReXhKUVVGSk8wRkJRMnBDTEdkQ1FVRlpMRVZCUVVVc1dVRkJXU3hEUVVGRExGRkJRVkU3UjBGRGNFTXNRMEZCUXpzN1FVRkZSaXhYUVVGVExFZEJRVWNzUTBGQlF5eFBRVUZQTEVWQlFXZENPMUZCUVdRc1QwRkJUeXg1UkVGQlJ5eEZRVUZGT3p0QlFVTm9ReXhSUVVGSkxFbEJRVWtzUjBGQlJ5eFBRVUZQTEVOQlFVTXNTVUZCU1N4RFFVRkRPenRCUVVWNFFpeFBRVUZITEVOQlFVTXNUVUZCVFN4RFFVRkRMRTlCUVU4c1EwRkJReXhEUVVGRE8wRkJRM0JDTEZGQlFVa3NRMEZCUXl4UFFVRlBMRU5CUVVNc1QwRkJUeXhKUVVGSkxGbEJRVmtzUTBGQlF5eFBRVUZQTEVWQlFVVTdRVUZETlVNc1ZVRkJTU3hIUVVGSExGRkJRVkVzUTBGQlF5eFBRVUZQTEVWQlFVVXNTVUZCU1N4RFFVRkRMRU5CUVVNN1MwRkRhRU03UVVGRFJDeFJRVUZKTEUxQlFVMHNXVUZCUVR0UlFVTk9MRmRCUVZjc1IwRkJSeXhaUVVGWkxFTkJRVU1zWTBGQll5eEhRVUZITEVWQlFVVXNSMEZCUnl4VFFVRlRMRU5CUVVNN1FVRkRMMFFzVVVGQlNTeFpRVUZaTEVOQlFVTXNVMEZCVXl4RlFVRkZPMEZCUXpGQ0xGVkJRVWtzVDBGQlR5eERRVUZETEUxQlFVMHNSVUZCUlR0QlFVTnNRaXhqUVVGTkxFZEJRVWNzVDBGQlR5eEpRVUZKTEU5QlFVOHNRMEZCUXl4TlFVRk5MRU5CUVVNc1EwRkJReXhEUVVGRExFZEJRVWNzUTBGQlF5eFBRVUZQTEVOQlFVTXNRMEZCUXl4TlFVRk5MRU5CUVVNc1QwRkJUeXhEUVVGRExFMUJRVTBzUTBGQlF5eEhRVUZITEU5QlFVOHNRMEZCUXl4TlFVRk5MRU5CUVVNN1QwRkRNMFlzVFVGQlRUdEJRVU5NTEdOQlFVMHNSMEZCUnl4RFFVRkRMRTlCUVU4c1EwRkJReXhEUVVGRE8wOUJRM0JDTzB0QlEwWTdPMEZCUlVRc1lVRkJVeXhKUVVGSkxFTkJRVU1zVDBGQlR5eG5Ra0ZCWlR0QlFVTnNReXhoUVVGUExFVkJRVVVzUjBGQlJ5eFpRVUZaTEVOQlFVTXNTVUZCU1N4RFFVRkRMRk5CUVZNc1JVRkJSU3hQUVVGUExFVkJRVVVzVTBGQlV5eERRVUZETEU5QlFVOHNSVUZCUlN4VFFVRlRMRU5CUVVNc1VVRkJVU3hGUVVGRkxFbEJRVWtzUlVGQlJTeFhRVUZYTEVWQlFVVXNUVUZCVFN4RFFVRkRMRU5CUVVNN1MwRkRja2c3UVVGRFJDeFJRVUZKTEVkQlFVY3NhVUpCUVdsQ0xFTkJRVU1zV1VGQldTeERRVUZETEVsQlFVa3NSVUZCUlN4SlFVRkpMRVZCUVVVc1UwRkJVeXhGUVVGRkxFOUJRVThzUTBGQlF5eE5RVUZOTEVsQlFVa3NSVUZCUlN4RlFVRkZMRWxCUVVrc1JVRkJSU3hYUVVGWExFTkJRVU1zUTBGQlF6dEJRVU4wUnl4WFFVRlBMRWxCUVVrc1EwRkJReXhQUVVGUExFVkJRVVVzVDBGQlR5eERRVUZETEVOQlFVTTdSMEZETDBJN1FVRkRSQ3hMUVVGSExFTkJRVU1zUzBGQlN5eEhRVUZITEVsQlFVa3NRMEZCUXpzN1FVRkZha0lzUzBGQlJ5eERRVUZETEUxQlFVMHNSMEZCUnl4VlFVRlRMRTlCUVU4c1JVRkJSVHRCUVVNM1FpeFJRVUZKTEVOQlFVTXNUMEZCVHl4RFFVRkRMRTlCUVU4c1JVRkJSVHRCUVVOd1FpeGxRVUZUTEVOQlFVTXNUMEZCVHl4SFFVRkhMRk5CUVZNc1EwRkJReXhMUVVGTExFTkJRVU1zVDBGQlR5eERRVUZETEU5QlFVOHNSVUZCUlN4SFFVRkhMRU5CUVVNc1QwRkJUeXhEUVVGRExFTkJRVU03TzBGQlJXeEZMRlZCUVVrc1dVRkJXU3hEUVVGRExGVkJRVlVzUlVGQlJUdEJRVU16UWl4cFFrRkJVeXhEUVVGRExGRkJRVkVzUjBGQlJ5eFRRVUZUTEVOQlFVTXNTMEZCU3l4RFFVRkRMRTlCUVU4c1EwRkJReXhSUVVGUkxFVkJRVVVzUjBGQlJ5eERRVUZETEZGQlFWRXNRMEZCUXl4RFFVRkRPMDlCUTNSRk8wRkJRMFFzVlVGQlNTeFpRVUZaTEVOQlFVTXNWVUZCVlN4SlFVRkpMRmxCUVZrc1EwRkJReXhoUVVGaExFVkJRVVU3UVVGRGVrUXNhVUpCUVZNc1EwRkJReXhWUVVGVkxFZEJRVWNzVTBGQlV5eERRVUZETEV0QlFVc3NRMEZCUXl4UFFVRlBMRU5CUVVNc1ZVRkJWU3hGUVVGRkxFZEJRVWNzUTBGQlF5eFZRVUZWTEVOQlFVTXNRMEZCUXp0UFFVTTFSVHRMUVVOR0xFMUJRVTA3UVVGRFRDeGxRVUZUTEVOQlFVTXNUMEZCVHl4SFFVRkhMRTlCUVU4c1EwRkJReXhQUVVGUExFTkJRVU03UVVGRGNFTXNaVUZCVXl4RFFVRkRMRkZCUVZFc1IwRkJSeXhQUVVGUExFTkJRVU1zVVVGQlVTeERRVUZETzBGQlEzUkRMR1ZCUVZNc1EwRkJReXhWUVVGVkxFZEJRVWNzVDBGQlR5eERRVUZETEZWQlFWVXNRMEZCUXp0TFFVTXpRenRIUVVOR0xFTkJRVU03TzBGQlJVWXNTMEZCUnl4RFFVRkRMRTFCUVUwc1IwRkJSeXhWUVVGVExFTkJRVU1zUlVGQlJTeEpRVUZKTEVWQlFVVXNWMEZCVnl4RlFVRkZMRTFCUVUwc1JVRkJSVHRCUVVOc1JDeFJRVUZKTEZsQlFWa3NRMEZCUXl4alFVRmpMRWxCUVVrc1EwRkJReXhYUVVGWExFVkJRVVU3UVVGREwwTXNXVUZCVFN3eVFrRkJZeXgzUWtGQmQwSXNRMEZCUXl4RFFVRkRPMHRCUXk5RE8wRkJRMFFzVVVGQlNTeFpRVUZaTEVOQlFVTXNVMEZCVXl4SlFVRkpMRU5CUVVNc1RVRkJUU3hGUVVGRk8wRkJRM0pETEZsQlFVMHNNa0pCUVdNc2VVSkJRWGxDTEVOQlFVTXNRMEZCUXp0TFFVTm9SRHM3UVVGRlJDeFhRVUZQTEZkQlFWY3NRMEZCUXl4VFFVRlRMRVZCUVVVc1EwRkJReXhGUVVGRkxGbEJRVmtzUTBGQlF5eERRVUZETEVOQlFVTXNSVUZCUlN4SlFVRkpMRVZCUVVVc1EwRkJReXhGUVVGRkxGZEJRVmNzUlVGQlJTeE5RVUZOTEVOQlFVTXNRMEZCUXp0SFFVTnFSaXhEUVVGRE8wRkJRMFlzVTBGQlR5eEhRVUZITEVOQlFVTTdRMEZEV2pzN1FVRkZUU3hUUVVGVExGZEJRVmNzUTBGQlF5eFRRVUZUTEVWQlFVVXNRMEZCUXl4RlFVRkZMRVZCUVVVc1JVRkJSU3hKUVVGSkxFVkJRVVVzYlVKQlFXMUNMRVZCUVVVc1YwRkJWeXhGUVVGRkxFMUJRVTBzUlVGQlJUdEJRVU0xUml4WFFVRlRMRWxCUVVrc1EwRkJReXhQUVVGUExFVkJRV2RDTzFGQlFXUXNUMEZCVHl4NVJFRkJSeXhGUVVGRk96dEJRVU5xUXl4UlFVRkpMR0ZCUVdFc1IwRkJSeXhOUVVGTkxFTkJRVU03UVVGRE0wSXNVVUZCU1N4TlFVRk5MRWxCUVVrc1QwRkJUeXhKUVVGSkxFMUJRVTBzUTBGQlF5eERRVUZETEVOQlFVTXNTVUZCU1N4RlFVRkZMRTlCUVU4c1MwRkJTeXhUUVVGVExFTkJRVU1zVjBGQlZ5eEpRVUZKTEUxQlFVMHNRMEZCUXl4RFFVRkRMRU5CUVVNc1MwRkJTeXhKUVVGSkxFTkJRVUVzUVVGQlF5eEZRVUZGTzBGQlEyaEhMRzFDUVVGaExFZEJRVWNzUTBGQlF5eFBRVUZQTEVOQlFVTXNRMEZCUXl4TlFVRk5MRU5CUVVNc1RVRkJUU3hEUVVGRExFTkJRVU03UzBGRE1VTTdPMEZCUlVRc1YwRkJUeXhGUVVGRkxFTkJRVU1zVTBGQlV5eEZRVU5tTEU5QlFVOHNSVUZEVUN4VFFVRlRMRU5CUVVNc1QwRkJUeXhGUVVGRkxGTkJRVk1zUTBGQlF5eFJRVUZSTEVWQlEzSkRMRTlCUVU4c1EwRkJReXhKUVVGSkxFbEJRVWtzU1VGQlNTeEZRVU53UWl4WFFVRlhMRWxCUVVrc1EwRkJReXhQUVVGUExFTkJRVU1zVjBGQlZ5eERRVUZETEVOQlFVTXNUVUZCVFN4RFFVRkRMRmRCUVZjc1EwRkJReXhGUVVONFJDeGhRVUZoTEVOQlFVTXNRMEZCUXp0SFFVTndRanM3UVVGRlJDeE5RVUZKTEVkQlFVY3NhVUpCUVdsQ0xFTkJRVU1zUlVGQlJTeEZRVUZGTEVsQlFVa3NSVUZCUlN4VFFVRlRMRVZCUVVVc1RVRkJUU3hGUVVGRkxFbEJRVWtzUlVGQlJTeFhRVUZYTEVOQlFVTXNRMEZCUXpzN1FVRkZla1VzVFVGQlNTeERRVUZETEU5QlFVOHNSMEZCUnl4RFFVRkRMRU5CUVVNN1FVRkRha0lzVFVGQlNTeERRVUZETEV0QlFVc3NSMEZCUnl4TlFVRk5MRWRCUVVjc1RVRkJUU3hEUVVGRExFMUJRVTBzUjBGQlJ5eERRVUZETEVOQlFVTTdRVUZEZUVNc1RVRkJTU3hEUVVGRExGZEJRVmNzUjBGQlJ5eHRRa0ZCYlVJc1NVRkJTU3hEUVVGRExFTkJRVU03UVVGRE5VTXNVMEZCVHl4SlFVRkpMRU5CUVVNN1EwRkRZanM3UVVGRlRTeFRRVUZUTEdOQlFXTXNRMEZCUXl4UFFVRlBMRVZCUVVVc1QwRkJUeXhGUVVGRkxFOUJRVThzUlVGQlJUdEJRVU40UkN4TlFVRkpMRU5CUVVNc1QwRkJUeXhGUVVGRk8wRkJRMW9zVVVGQlNTeFBRVUZQTEVOQlFVTXNTVUZCU1N4TFFVRkxMR2RDUVVGblFpeEZRVUZGTzBGQlEzSkRMR0ZCUVU4c1IwRkJSeXhQUVVGUExFTkJRVU1zU1VGQlNTeERRVUZETEdWQlFXVXNRMEZCUXl4RFFVRkRPMHRCUTNwRExFMUJRVTA3UVVGRFRDeGhRVUZQTEVkQlFVY3NUMEZCVHl4RFFVRkRMRkZCUVZFc1EwRkJReXhQUVVGUExFTkJRVU1zU1VGQlNTeERRVUZETEVOQlFVTTdTMEZETVVNN1IwRkRSaXhOUVVGTkxFbEJRVWtzUTBGQlF5eFBRVUZQTEVOQlFVTXNTVUZCU1N4SlFVRkpMRU5CUVVNc1QwRkJUeXhEUVVGRExFbEJRVWtzUlVGQlJUczdRVUZGZWtNc1YwRkJUeXhEUVVGRExFbEJRVWtzUjBGQlJ5eFBRVUZQTEVOQlFVTTdRVUZEZGtJc1YwRkJUeXhIUVVGSExFOUJRVThzUTBGQlF5eFJRVUZSTEVOQlFVTXNUMEZCVHl4RFFVRkRMRU5CUVVNN1IwRkRja003UVVGRFJDeFRRVUZQTEU5QlFVOHNRMEZCUXp0RFFVTm9RanM3UVVGRlRTeFRRVUZUTEdGQlFXRXNRMEZCUXl4UFFVRlBMRVZCUVVVc1QwRkJUeXhGUVVGRkxFOUJRVThzUlVGQlJUczdRVUZGZGtRc1RVRkJUU3h0UWtGQmJVSXNSMEZCUnl4UFFVRlBMRU5CUVVNc1NVRkJTU3hKUVVGSkxFOUJRVThzUTBGQlF5eEpRVUZKTEVOQlFVTXNaVUZCWlN4RFFVRkRMRU5CUVVNN1FVRkRNVVVzVTBGQlR5eERRVUZETEU5QlFVOHNSMEZCUnl4SlFVRkpMRU5CUVVNN1FVRkRka0lzVFVGQlNTeFBRVUZQTEVOQlFVTXNSMEZCUnl4RlFVRkZPMEZCUTJZc1YwRkJUeXhEUVVGRExFbEJRVWtzUTBGQlF5eFhRVUZYTEVkQlFVY3NUMEZCVHl4RFFVRkRMRWRCUVVjc1EwRkJReXhEUVVGRExFTkJRVU1zU1VGQlNTeFBRVUZQTEVOQlFVTXNTVUZCU1N4RFFVRkRMRmRCUVZjc1EwRkJRenRIUVVOMlJUczdRVUZGUkN4TlFVRkpMRmxCUVZrc1dVRkJRU3hEUVVGRE8wRkJRMnBDTEUxQlFVa3NUMEZCVHl4RFFVRkRMRVZCUVVVc1NVRkJTU3hQUVVGUExFTkJRVU1zUlVGQlJTeExRVUZMTEVsQlFVa3NSVUZCUlRzN1FVRkRja01zWVVGQlR5eERRVUZETEVsQlFVa3NSMEZCUnl4clFrRkJXU3hQUVVGUExFTkJRVU1zU1VGQlNTeERRVUZETEVOQlFVTTdPMEZCUlhwRExGVkJRVWtzUlVGQlJTeEhRVUZITEU5QlFVOHNRMEZCUXl4RlFVRkZMRU5CUVVNN1FVRkRjRUlzYTBKQlFWa3NSMEZCUnl4UFFVRlBMRU5CUVVNc1NVRkJTU3hEUVVGRExHVkJRV1VzUTBGQlF5eEhRVUZITEZOQlFWTXNiVUpCUVcxQ0xFTkJRVU1zVDBGQlR5eEZRVUZuUWp0WlFVRmtMRTlCUVU4c2VVUkJRVWNzUlVGQlJUczdPenRCUVVrdlJpeGxRVUZQTEVOQlFVTXNTVUZCU1N4SFFVRkhMR3RDUVVGWkxFOUJRVThzUTBGQlF5eEpRVUZKTEVOQlFVTXNRMEZCUXp0QlFVTjZReXhsUVVGUExFTkJRVU1zU1VGQlNTeERRVUZETEdWQlFXVXNRMEZCUXl4SFFVRkhMRzFDUVVGdFFpeERRVUZETzBGQlEzQkVMR1ZCUVU4c1JVRkJSU3hEUVVGRExFOUJRVThzUlVGQlJTeFBRVUZQTEVOQlFVTXNRMEZCUXp0UFFVTTNRaXhEUVVGRE8wRkJRMFlzVlVGQlNTeEZRVUZGTEVOQlFVTXNVVUZCVVN4RlFVRkZPMEZCUTJZc1pVRkJUeXhEUVVGRExGRkJRVkVzUjBGQlJ5eExRVUZMTEVOQlFVTXNUVUZCVFN4RFFVRkRMRVZCUVVVc1JVRkJSU3hQUVVGUExFTkJRVU1zVVVGQlVTeEZRVUZGTEVWQlFVVXNRMEZCUXl4UlFVRlJMRU5CUVVNc1EwRkJRenRQUVVOd1JUczdSMEZEUmpzN1FVRkZSQ3hOUVVGSkxFOUJRVThzUzBGQlN5eFRRVUZUTEVsQlFVa3NXVUZCV1N4RlFVRkZPMEZCUTNwRExGZEJRVThzUjBGQlJ5eFpRVUZaTEVOQlFVTTdSMEZEZUVJN08wRkJSVVFzVFVGQlNTeFBRVUZQTEV0QlFVc3NVMEZCVXl4RlFVRkZPMEZCUTNwQ0xGVkJRVTBzTWtKQlFXTXNZMEZCWXl4SFFVRkhMRTlCUVU4c1EwRkJReXhKUVVGSkxFZEJRVWNzY1VKQlFYRkNMRU5CUVVNc1EwRkJRenRIUVVNMVJTeE5RVUZOTEVsQlFVa3NUMEZCVHl4WlFVRlpMRkZCUVZFc1JVRkJSVHRCUVVOMFF5eFhRVUZQTEU5QlFVOHNRMEZCUXl4UFFVRlBMRVZCUVVVc1QwRkJUeXhEUVVGRExFTkJRVU03UjBGRGJFTTdRMEZEUmpzN1FVRkZUU3hUUVVGVExFbEJRVWtzUjBGQlJ6dEJRVUZGTEZOQlFVOHNSVUZCUlN4RFFVRkRPME5CUVVVN08wRkJSWEpETEZOQlFWTXNVVUZCVVN4RFFVRkRMRTlCUVU4c1JVRkJSU3hKUVVGSkxFVkJRVVU3UVVGREwwSXNUVUZCU1N4RFFVRkRMRWxCUVVrc1NVRkJTU3hGUVVGRkxFMUJRVTBzU1VGQlNTeEpRVUZKTEVOQlFVRXNRVUZCUXl4RlFVRkZPMEZCUXpsQ0xGRkJRVWtzUjBGQlJ5eEpRVUZKTEVkQlFVY3NhMEpCUVZrc1NVRkJTU3hEUVVGRExFZEJRVWNzUlVGQlJTeERRVUZETzBGQlEzSkRMRkZCUVVrc1EwRkJReXhKUVVGSkxFZEJRVWNzVDBGQlR5eERRVUZETzBkQlEzSkNPMEZCUTBRc1UwRkJUeXhKUVVGSkxFTkJRVU03UTBGRFlqczdRVUZGUkN4VFFVRlRMR2xDUVVGcFFpeERRVUZETEVWQlFVVXNSVUZCUlN4SlFVRkpMRVZCUVVVc1UwRkJVeXhGUVVGRkxFMUJRVTBzUlVGQlJTeEpRVUZKTEVWQlFVVXNWMEZCVnl4RlFVRkZPMEZCUTNwRkxFMUJRVWtzUlVGQlJTeERRVUZETEZOQlFWTXNSVUZCUlR0QlFVTm9RaXhSUVVGSkxFdEJRVXNzUjBGQlJ5eEZRVUZGTEVOQlFVTTdRVUZEWml4UlFVRkpMRWRCUVVjc1JVRkJSU3hEUVVGRExGTkJRVk1zUTBGQlF5eEpRVUZKTEVWQlFVVXNTMEZCU3l4RlFVRkZMRk5CUVZNc1JVRkJSU3hOUVVGTkxFbEJRVWtzVFVGQlRTeERRVUZETEVOQlFVTXNRMEZCUXl4RlFVRkZMRWxCUVVrc1JVRkJSU3hYUVVGWExFVkJRVVVzVFVGQlRTeERRVUZETEVOQlFVTTdRVUZETlVZc1UwRkJTeXhEUVVGRExFMUJRVTBzUTBGQlF5eEpRVUZKTEVWQlFVVXNTMEZCU3l4RFFVRkRMRU5CUVVNN1IwRkRNMEk3UVVGRFJDeFRRVUZQTEVsQlFVa3NRMEZCUXp0RFFVTmlJaXdpWm1sc1pTSTZJbkoxYm5ScGJXVXVhbk1pTENKemIzVnlZMlZ6UTI5dWRHVnVkQ0k2V3lKcGJYQnZjblFnS2lCaGN5QlZkR2xzY3lCbWNtOXRJQ2N1TDNWMGFXeHpKenRjYm1sdGNHOXlkQ0JGZUdObGNIUnBiMjRnWm5KdmJTQW5MaTlsZUdObGNIUnBiMjRuTzF4dWFXMXdiM0owSUhzZ1EwOU5VRWxNUlZKZlVrVldTVk5KVDA0c0lGSkZWa2xUU1U5T1gwTklRVTVIUlZNc0lHTnlaV0YwWlVaeVlXMWxJSDBnWm5KdmJTQW5MaTlpWVhObEp6dGNibHh1Wlhod2IzSjBJR1oxYm1OMGFXOXVJR05vWldOclVtVjJhWE5wYjI0b1kyOXRjR2xzWlhKSmJtWnZLU0I3WEc0Z0lHTnZibk4wSUdOdmJYQnBiR1Z5VW1WMmFYTnBiMjRnUFNCamIyMXdhV3hsY2tsdVptOGdKaVlnWTI5dGNHbHNaWEpKYm1adld6QmRJSHg4SURFc1hHNGdJQ0FnSUNBZ0lHTjFjbkpsYm5SU1pYWnBjMmx2YmlBOUlFTlBUVkJKVEVWU1gxSkZWa2xUU1U5T08xeHVYRzRnSUdsbUlDaGpiMjF3YVd4bGNsSmxkbWx6YVc5dUlDRTlQU0JqZFhKeVpXNTBVbVYyYVhOcGIyNHBJSHRjYmlBZ0lDQnBaaUFvWTI5dGNHbHNaWEpTWlhacGMybHZiaUE4SUdOMWNuSmxiblJTWlhacGMybHZiaWtnZTF4dUlDQWdJQ0FnWTI5dWMzUWdjblZ1ZEdsdFpWWmxjbk5wYjI1eklEMGdVa1ZXU1ZOSlQwNWZRMGhCVGtkRlUxdGpkWEp5Wlc1MFVtVjJhWE5wYjI1ZExGeHVJQ0FnSUNBZ0lDQWdJQ0FnWTI5dGNHbHNaWEpXWlhKemFXOXVjeUE5SUZKRlZrbFRTVTlPWDBOSVFVNUhSVk5iWTI5dGNHbHNaWEpTWlhacGMybHZibDA3WEc0Z0lDQWdJQ0IwYUhKdmR5QnVaWGNnUlhoalpYQjBhVzl1S0NkVVpXMXdiR0YwWlNCM1lYTWdjSEpsWTI5dGNHbHNaV1FnZDJsMGFDQmhiaUJ2YkdSbGNpQjJaWEp6YVc5dUlHOW1JRWhoYm1Sc1pXSmhjbk1nZEdoaGJpQjBhR1VnWTNWeWNtVnVkQ0J5ZFc1MGFXMWxMaUFuSUN0Y2JpQWdJQ0FnSUNBZ0lDQWdJQ2RRYkdWaGMyVWdkWEJrWVhSbElIbHZkWElnY0hKbFkyOXRjR2xzWlhJZ2RHOGdZU0J1WlhkbGNpQjJaWEp6YVc5dUlDZ25JQ3NnY25WdWRHbHRaVlpsY25OcGIyNXpJQ3NnSnlrZ2IzSWdaRzkzYm1keVlXUmxJSGx2ZFhJZ2NuVnVkR2x0WlNCMGJ5QmhiaUJ2YkdSbGNpQjJaWEp6YVc5dUlDZ25JQ3NnWTI5dGNHbHNaWEpXWlhKemFXOXVjeUFySUNjcExpY3BPMXh1SUNBZ0lIMGdaV3h6WlNCN1hHNGdJQ0FnSUNBdkx5QlZjMlVnZEdobElHVnRZbVZrWkdWa0lIWmxjbk5wYjI0Z2FXNW1ieUJ6YVc1alpTQjBhR1VnY25WdWRHbHRaU0JrYjJWemJpZDBJR3R1YjNjZ1lXSnZkWFFnZEdocGN5QnlaWFpwYzJsdmJpQjVaWFJjYmlBZ0lDQWdJSFJvY205M0lHNWxkeUJGZUdObGNIUnBiMjRvSjFSbGJYQnNZWFJsSUhkaGN5QndjbVZqYjIxd2FXeGxaQ0IzYVhSb0lHRWdibVYzWlhJZ2RtVnljMmx2YmlCdlppQklZVzVrYkdWaVlYSnpJSFJvWVc0Z2RHaGxJR04xY25KbGJuUWdjblZ1ZEdsdFpTNGdKeUFyWEc0Z0lDQWdJQ0FnSUNBZ0lDQW5VR3hsWVhObElIVndaR0YwWlNCNWIzVnlJSEoxYm5ScGJXVWdkRzhnWVNCdVpYZGxjaUIyWlhKemFXOXVJQ2duSUNzZ1kyOXRjR2xzWlhKSmJtWnZXekZkSUNzZ0p5a3VKeWs3WEc0Z0lDQWdmVnh1SUNCOVhHNTlYRzVjYm1WNGNHOXlkQ0JtZFc1amRHbHZiaUIwWlcxd2JHRjBaU2gwWlcxd2JHRjBaVk53WldNc0lHVnVkaWtnZTF4dUlDQXZLaUJwYzNSaGJtSjFiQ0JwWjI1dmNtVWdibVY0ZENBcUwxeHVJQ0JwWmlBb0lXVnVkaWtnZTF4dUlDQWdJSFJvY205M0lHNWxkeUJGZUdObGNIUnBiMjRvSjA1dklHVnVkbWx5YjI1dFpXNTBJSEJoYzNObFpDQjBieUIwWlcxd2JHRjBaU2NwTzF4dUlDQjlYRzRnSUdsbUlDZ2hkR1Z0Y0d4aGRHVlRjR1ZqSUh4OElDRjBaVzF3YkdGMFpWTndaV011YldGcGJpa2dlMXh1SUNBZ0lIUm9jbTkzSUc1bGR5QkZlR05sY0hScGIyNG9KMVZ1YTI1dmQyNGdkR1Z0Y0d4aGRHVWdiMkpxWldOME9pQW5JQ3NnZEhsd1pXOW1JSFJsYlhCc1lYUmxVM0JsWXlrN1hHNGdJSDFjYmx4dUlDQjBaVzF3YkdGMFpWTndaV011YldGcGJpNWtaV052Y21GMGIzSWdQU0IwWlcxd2JHRjBaVk53WldNdWJXRnBibDlrTzF4dVhHNGdJQzh2SUU1dmRHVTZJRlZ6YVc1bklHVnVkaTVXVFNCeVpXWmxjbVZ1WTJWeklISmhkR2hsY2lCMGFHRnVJR3h2WTJGc0lIWmhjaUJ5WldabGNtVnVZMlZ6SUhSb2NtOTFaMmh2ZFhRZ2RHaHBjeUJ6WldOMGFXOXVJSFJ2SUdGc2JHOTNYRzRnSUM4dklHWnZjaUJsZUhSbGNtNWhiQ0IxYzJWeWN5QjBieUJ2ZG1WeWNtbGtaU0IwYUdWelpTQmhjeUJ3YzNWbFpHOHRjM1Z3Y0c5eWRHVmtJRUZRU1hNdVhHNGdJR1Z1ZGk1V1RTNWphR1ZqYTFKbGRtbHphVzl1S0hSbGJYQnNZWFJsVTNCbFl5NWpiMjF3YVd4bGNpazdYRzVjYmlBZ1puVnVZM1JwYjI0Z2FXNTJiMnRsVUdGeWRHbGhiRmR5WVhCd1pYSW9jR0Z5ZEdsaGJDd2dZMjl1ZEdWNGRDd2diM0IwYVc5dWN5a2dlMXh1SUNBZ0lHbG1JQ2h2Y0hScGIyNXpMbWhoYzJncElIdGNiaUFnSUNBZ0lHTnZiblJsZUhRZ1BTQlZkR2xzY3k1bGVIUmxibVFvZTMwc0lHTnZiblJsZUhRc0lHOXdkR2x2Ym5NdWFHRnphQ2s3WEc0Z0lDQWdJQ0JwWmlBb2IzQjBhVzl1Y3k1cFpITXBJSHRjYmlBZ0lDQWdJQ0FnYjNCMGFXOXVjeTVwWkhOYk1GMGdQU0IwY25WbE8xeHVJQ0FnSUNBZ2ZWeHVJQ0FnSUgxY2JseHVJQ0FnSUhCaGNuUnBZV3dnUFNCbGJuWXVWazB1Y21WemIyeDJaVkJoY25ScFlXd3VZMkZzYkNoMGFHbHpMQ0J3WVhKMGFXRnNMQ0JqYjI1MFpYaDBMQ0J2Y0hScGIyNXpLVHRjYmlBZ0lDQnNaWFFnY21WemRXeDBJRDBnWlc1MkxsWk5MbWx1ZG05clpWQmhjblJwWVd3dVkyRnNiQ2gwYUdsekxDQndZWEowYVdGc0xDQmpiMjUwWlhoMExDQnZjSFJwYjI1ektUdGNibHh1SUNBZ0lHbG1JQ2h5WlhOMWJIUWdQVDBnYm5Wc2JDQW1KaUJsYm5ZdVkyOXRjR2xzWlNrZ2UxeHVJQ0FnSUNBZ2IzQjBhVzl1Y3k1d1lYSjBhV0ZzYzF0dmNIUnBiMjV6TG01aGJXVmRJRDBnWlc1MkxtTnZiWEJwYkdVb2NHRnlkR2xoYkN3Z2RHVnRjR3hoZEdWVGNHVmpMbU52YlhCcGJHVnlUM0IwYVc5dWN5d2daVzUyS1R0Y2JpQWdJQ0FnSUhKbGMzVnNkQ0E5SUc5d2RHbHZibk11Y0dGeWRHbGhiSE5iYjNCMGFXOXVjeTV1WVcxbFhTaGpiMjUwWlhoMExDQnZjSFJwYjI1ektUdGNiaUFnSUNCOVhHNGdJQ0FnYVdZZ0tISmxjM1ZzZENBaFBTQnVkV3hzS1NCN1hHNGdJQ0FnSUNCcFppQW9iM0IwYVc5dWN5NXBibVJsYm5RcElIdGNiaUFnSUNBZ0lDQWdiR1YwSUd4cGJtVnpJRDBnY21WemRXeDBMbk53YkdsMEtDZGNYRzRuS1R0Y2JpQWdJQ0FnSUNBZ1ptOXlJQ2hzWlhRZ2FTQTlJREFzSUd3Z1BTQnNhVzVsY3k1c1pXNW5kR2c3SUdrZ1BDQnNPeUJwS3lzcElIdGNiaUFnSUNBZ0lDQWdJQ0JwWmlBb0lXeHBibVZ6VzJsZElDWW1JR2tnS3lBeElEMDlQU0JzS1NCN1hHNGdJQ0FnSUNBZ0lDQWdJQ0JpY21WaGF6dGNiaUFnSUNBZ0lDQWdJQ0I5WEc1Y2JpQWdJQ0FnSUNBZ0lDQnNhVzVsYzF0cFhTQTlJRzl3ZEdsdmJuTXVhVzVrWlc1MElDc2diR2x1WlhOYmFWMDdYRzRnSUNBZ0lDQWdJSDFjYmlBZ0lDQWdJQ0FnY21WemRXeDBJRDBnYkdsdVpYTXVhbTlwYmlnblhGeHVKeWs3WEc0Z0lDQWdJQ0I5WEc0Z0lDQWdJQ0J5WlhSMWNtNGdjbVZ6ZFd4ME8xeHVJQ0FnSUgwZ1pXeHpaU0I3WEc0Z0lDQWdJQ0IwYUhKdmR5QnVaWGNnUlhoalpYQjBhVzl1S0NkVWFHVWdjR0Z5ZEdsaGJDQW5JQ3NnYjNCMGFXOXVjeTV1WVcxbElDc2dKeUJqYjNWc1pDQnViM1FnWW1VZ1kyOXRjR2xzWldRZ2QyaGxiaUJ5ZFc1dWFXNW5JR2x1SUhKMWJuUnBiV1V0YjI1c2VTQnRiMlJsSnlrN1hHNGdJQ0FnZlZ4dUlDQjlYRzVjYmlBZ0x5OGdTblZ6ZENCaFpHUWdkMkYwWlhKY2JpQWdiR1YwSUdOdmJuUmhhVzVsY2lBOUlIdGNiaUFnSUNCemRISnBZM1E2SUdaMWJtTjBhVzl1S0c5aWFpd2dibUZ0WlNrZ2UxeHVJQ0FnSUNBZ2FXWWdLQ0VvYm1GdFpTQnBiaUJ2WW1vcEtTQjdYRzRnSUNBZ0lDQWdJSFJvY205M0lHNWxkeUJGZUdObGNIUnBiMjRvSjF3aUp5QXJJRzVoYldVZ0t5QW5YQ0lnYm05MElHUmxabWx1WldRZ2FXNGdKeUFySUc5aWFpazdYRzRnSUNBZ0lDQjlYRzRnSUNBZ0lDQnlaWFIxY200Z2IySnFXMjVoYldWZE8xeHVJQ0FnSUgwc1hHNGdJQ0FnYkc5dmEzVndPaUJtZFc1amRHbHZiaWhrWlhCMGFITXNJRzVoYldVcElIdGNiaUFnSUNBZ0lHTnZibk4wSUd4bGJpQTlJR1JsY0hSb2N5NXNaVzVuZEdnN1hHNGdJQ0FnSUNCbWIzSWdLR3hsZENCcElEMGdNRHNnYVNBOElHeGxianNnYVNzcktTQjdYRzRnSUNBZ0lDQWdJR2xtSUNoa1pYQjBhSE5iYVYwZ0ppWWdaR1Z3ZEdoelcybGRXMjVoYldWZElDRTlJRzUxYkd3cElIdGNiaUFnSUNBZ0lDQWdJQ0J5WlhSMWNtNGdaR1Z3ZEdoelcybGRXMjVoYldWZE8xeHVJQ0FnSUNBZ0lDQjlYRzRnSUNBZ0lDQjlYRzRnSUNBZ2ZTeGNiaUFnSUNCc1lXMWlaR0U2SUdaMWJtTjBhVzl1S0dOMWNuSmxiblFzSUdOdmJuUmxlSFFwSUh0Y2JpQWdJQ0FnSUhKbGRIVnliaUIwZVhCbGIyWWdZM1Z5Y21WdWRDQTlQVDBnSjJaMWJtTjBhVzl1SnlBL0lHTjFjbkpsYm5RdVkyRnNiQ2hqYjI1MFpYaDBLU0E2SUdOMWNuSmxiblE3WEc0Z0lDQWdmU3hjYmx4dUlDQWdJR1Z6WTJGd1pVVjRjSEpsYzNOcGIyNDZJRlYwYVd4ekxtVnpZMkZ3WlVWNGNISmxjM05wYjI0c1hHNGdJQ0FnYVc1MmIydGxVR0Z5ZEdsaGJEb2dhVzUyYjJ0bFVHRnlkR2xoYkZkeVlYQndaWElzWEc1Y2JpQWdJQ0JtYmpvZ1puVnVZM1JwYjI0b2FTa2dlMXh1SUNBZ0lDQWdiR1YwSUhKbGRDQTlJSFJsYlhCc1lYUmxVM0JsWTF0cFhUdGNiaUFnSUNBZ0lISmxkQzVrWldOdmNtRjBiM0lnUFNCMFpXMXdiR0YwWlZOd1pXTmJhU0FySUNkZlpDZGRPMXh1SUNBZ0lDQWdjbVYwZFhKdUlISmxkRHRjYmlBZ0lDQjlMRnh1WEc0Z0lDQWdjSEp2WjNKaGJYTTZJRnRkTEZ4dUlDQWdJSEJ5YjJkeVlXMDZJR1oxYm1OMGFXOXVLR2tzSUdSaGRHRXNJR1JsWTJ4aGNtVmtRbXh2WTJ0UVlYSmhiWE1zSUdKc2IyTnJVR0Z5WVcxekxDQmtaWEIwYUhNcElIdGNiaUFnSUNBZ0lHeGxkQ0J3Y205bmNtRnRWM0poY0hCbGNpQTlJSFJvYVhNdWNISnZaM0poYlhOYmFWMHNYRzRnSUNBZ0lDQWdJQ0FnWm00Z1BTQjBhR2x6TG1adUtHa3BPMXh1SUNBZ0lDQWdhV1lnS0dSaGRHRWdmSHdnWkdWd2RHaHpJSHg4SUdKc2IyTnJVR0Z5WVcxeklIeDhJR1JsWTJ4aGNtVmtRbXh2WTJ0UVlYSmhiWE1wSUh0Y2JpQWdJQ0FnSUNBZ2NISnZaM0poYlZkeVlYQndaWElnUFNCM2NtRndVSEp2WjNKaGJTaDBhR2x6TENCcExDQm1iaXdnWkdGMFlTd2daR1ZqYkdGeVpXUkNiRzlqYTFCaGNtRnRjeXdnWW14dlkydFFZWEpoYlhNc0lHUmxjSFJvY3lrN1hHNGdJQ0FnSUNCOUlHVnNjMlVnYVdZZ0tDRndjbTluY21GdFYzSmhjSEJsY2lrZ2UxeHVJQ0FnSUNBZ0lDQndjbTluY21GdFYzSmhjSEJsY2lBOUlIUm9hWE11Y0hKdlozSmhiWE5iYVYwZ1BTQjNjbUZ3VUhKdlozSmhiU2gwYUdsekxDQnBMQ0JtYmlrN1hHNGdJQ0FnSUNCOVhHNGdJQ0FnSUNCeVpYUjFjbTRnY0hKdlozSmhiVmR5WVhCd1pYSTdYRzRnSUNBZ2ZTeGNibHh1SUNBZ0lHUmhkR0U2SUdaMWJtTjBhVzl1S0haaGJIVmxMQ0JrWlhCMGFDa2dlMXh1SUNBZ0lDQWdkMmhwYkdVZ0tIWmhiSFZsSUNZbUlHUmxjSFJvTFMwcElIdGNiaUFnSUNBZ0lDQWdkbUZzZFdVZ1BTQjJZV3gxWlM1ZmNHRnlaVzUwTzF4dUlDQWdJQ0FnZlZ4dUlDQWdJQ0FnY21WMGRYSnVJSFpoYkhWbE8xeHVJQ0FnSUgwc1hHNGdJQ0FnYldWeVoyVTZJR1oxYm1OMGFXOXVLSEJoY21GdExDQmpiMjF0YjI0cElIdGNiaUFnSUNBZ0lHeGxkQ0J2WW1vZ1BTQndZWEpoYlNCOGZDQmpiMjF0YjI0N1hHNWNiaUFnSUNBZ0lHbG1JQ2h3WVhKaGJTQW1KaUJqYjIxdGIyNGdKaVlnS0hCaGNtRnRJQ0U5UFNCamIyMXRiMjRwS1NCN1hHNGdJQ0FnSUNBZ0lHOWlhaUE5SUZWMGFXeHpMbVY0ZEdWdVpDaDdmU3dnWTI5dGJXOXVMQ0J3WVhKaGJTazdYRzRnSUNBZ0lDQjlYRzVjYmlBZ0lDQWdJSEpsZEhWeWJpQnZZbW83WEc0Z0lDQWdmU3hjYmlBZ0lDQXZMeUJCYmlCbGJYQjBlU0J2WW1wbFkzUWdkRzhnZFhObElHRnpJSEpsY0d4aFkyVnRaVzUwSUdadmNpQnVkV3hzTFdOdmJuUmxlSFJ6WEc0Z0lDQWdiblZzYkVOdmJuUmxlSFE2SUU5aWFtVmpkQzV6WldGc0tIdDlLU3hjYmx4dUlDQWdJRzV2YjNBNklHVnVkaTVXVFM1dWIyOXdMRnh1SUNBZ0lHTnZiWEJwYkdWeVNXNW1iem9nZEdWdGNHeGhkR1ZUY0dWakxtTnZiWEJwYkdWeVhHNGdJSDA3WEc1Y2JpQWdablZ1WTNScGIyNGdjbVYwS0dOdmJuUmxlSFFzSUc5d2RHbHZibk1nUFNCN2ZTa2dlMXh1SUNBZ0lHeGxkQ0JrWVhSaElEMGdiM0IwYVc5dWN5NWtZWFJoTzF4dVhHNGdJQ0FnY21WMExsOXpaWFIxY0NodmNIUnBiMjV6S1R0Y2JpQWdJQ0JwWmlBb0lXOXdkR2x2Ym5NdWNHRnlkR2xoYkNBbUppQjBaVzF3YkdGMFpWTndaV011ZFhObFJHRjBZU2tnZTF4dUlDQWdJQ0FnWkdGMFlTQTlJR2x1YVhSRVlYUmhLR052Ym5SbGVIUXNJR1JoZEdFcE8xeHVJQ0FnSUgxY2JpQWdJQ0JzWlhRZ1pHVndkR2h6TEZ4dUlDQWdJQ0FnSUNCaWJHOWphMUJoY21GdGN5QTlJSFJsYlhCc1lYUmxVM0JsWXk1MWMyVkNiRzlqYTFCaGNtRnRjeUEvSUZ0ZElEb2dkVzVrWldacGJtVmtPMXh1SUNBZ0lHbG1JQ2gwWlcxd2JHRjBaVk53WldNdWRYTmxSR1Z3ZEdoektTQjdYRzRnSUNBZ0lDQnBaaUFvYjNCMGFXOXVjeTVrWlhCMGFITXBJSHRjYmlBZ0lDQWdJQ0FnWkdWd2RHaHpJRDBnWTI5dWRHVjRkQ0FoUFNCdmNIUnBiMjV6TG1SbGNIUm9jMXN3WFNBL0lGdGpiMjUwWlhoMFhTNWpiMjVqWVhRb2IzQjBhVzl1Y3k1a1pYQjBhSE1wSURvZ2IzQjBhVzl1Y3k1a1pYQjBhSE03WEc0Z0lDQWdJQ0I5SUdWc2MyVWdlMXh1SUNBZ0lDQWdJQ0JrWlhCMGFITWdQU0JiWTI5dWRHVjRkRjA3WEc0Z0lDQWdJQ0I5WEc0Z0lDQWdmVnh1WEc0Z0lDQWdablZ1WTNScGIyNGdiV0ZwYmloamIyNTBaWGgwTHlvc0lHOXdkR2x2Ym5NcUx5a2dlMXh1SUNBZ0lDQWdjbVYwZFhKdUlDY25JQ3NnZEdWdGNHeGhkR1ZUY0dWakxtMWhhVzRvWTI5dWRHRnBibVZ5TENCamIyNTBaWGgwTENCamIyNTBZV2x1WlhJdWFHVnNjR1Z5Y3l3Z1kyOXVkR0ZwYm1WeUxuQmhjblJwWVd4ekxDQmtZWFJoTENCaWJHOWphMUJoY21GdGN5d2daR1Z3ZEdoektUdGNiaUFnSUNCOVhHNGdJQ0FnYldGcGJpQTlJR1Y0WldOMWRHVkVaV052Y21GMGIzSnpLSFJsYlhCc1lYUmxVM0JsWXk1dFlXbHVMQ0J0WVdsdUxDQmpiMjUwWVdsdVpYSXNJRzl3ZEdsdmJuTXVaR1Z3ZEdoeklIeDhJRnRkTENCa1lYUmhMQ0JpYkc5amExQmhjbUZ0Y3lrN1hHNGdJQ0FnY21WMGRYSnVJRzFoYVc0b1kyOXVkR1Y0ZEN3Z2IzQjBhVzl1Y3lrN1hHNGdJSDFjYmlBZ2NtVjBMbWx6Vkc5d0lEMGdkSEoxWlR0Y2JseHVJQ0J5WlhRdVgzTmxkSFZ3SUQwZ1puVnVZM1JwYjI0b2IzQjBhVzl1Y3lrZ2UxeHVJQ0FnSUdsbUlDZ2hiM0IwYVc5dWN5NXdZWEowYVdGc0tTQjdYRzRnSUNBZ0lDQmpiMjUwWVdsdVpYSXVhR1ZzY0dWeWN5QTlJR052Ym5SaGFXNWxjaTV0WlhKblpTaHZjSFJwYjI1ekxtaGxiSEJsY25Nc0lHVnVkaTVvWld4d1pYSnpLVHRjYmx4dUlDQWdJQ0FnYVdZZ0tIUmxiWEJzWVhSbFUzQmxZeTUxYzJWUVlYSjBhV0ZzS1NCN1hHNGdJQ0FnSUNBZ0lHTnZiblJoYVc1bGNpNXdZWEowYVdGc2N5QTlJR052Ym5SaGFXNWxjaTV0WlhKblpTaHZjSFJwYjI1ekxuQmhjblJwWVd4ekxDQmxibll1Y0dGeWRHbGhiSE1wTzF4dUlDQWdJQ0FnZlZ4dUlDQWdJQ0FnYVdZZ0tIUmxiWEJzWVhSbFUzQmxZeTUxYzJWUVlYSjBhV0ZzSUh4OElIUmxiWEJzWVhSbFUzQmxZeTUxYzJWRVpXTnZjbUYwYjNKektTQjdYRzRnSUNBZ0lDQWdJR052Ym5SaGFXNWxjaTVrWldOdmNtRjBiM0p6SUQwZ1kyOXVkR0ZwYm1WeUxtMWxjbWRsS0c5d2RHbHZibk11WkdWamIzSmhkRzl5Y3l3Z1pXNTJMbVJsWTI5eVlYUnZjbk1wTzF4dUlDQWdJQ0FnZlZ4dUlDQWdJSDBnWld4elpTQjdYRzRnSUNBZ0lDQmpiMjUwWVdsdVpYSXVhR1ZzY0dWeWN5QTlJRzl3ZEdsdmJuTXVhR1ZzY0dWeWN6dGNiaUFnSUNBZ0lHTnZiblJoYVc1bGNpNXdZWEowYVdGc2N5QTlJRzl3ZEdsdmJuTXVjR0Z5ZEdsaGJITTdYRzRnSUNBZ0lDQmpiMjUwWVdsdVpYSXVaR1ZqYjNKaGRHOXljeUE5SUc5d2RHbHZibk11WkdWamIzSmhkRzl5Y3p0Y2JpQWdJQ0I5WEc0Z0lIMDdYRzVjYmlBZ2NtVjBMbDlqYUdsc1pDQTlJR1oxYm1OMGFXOXVLR2tzSUdSaGRHRXNJR0pzYjJOclVHRnlZVzF6TENCa1pYQjBhSE1wSUh0Y2JpQWdJQ0JwWmlBb2RHVnRjR3hoZEdWVGNHVmpMblZ6WlVKc2IyTnJVR0Z5WVcxeklDWW1JQ0ZpYkc5amExQmhjbUZ0Y3lrZ2UxeHVJQ0FnSUNBZ2RHaHliM2NnYm1WM0lFVjRZMlZ3ZEdsdmJpZ25iWFZ6ZENCd1lYTnpJR0pzYjJOcklIQmhjbUZ0Y3ljcE8xeHVJQ0FnSUgxY2JpQWdJQ0JwWmlBb2RHVnRjR3hoZEdWVGNHVmpMblZ6WlVSbGNIUm9jeUFtSmlBaFpHVndkR2h6S1NCN1hHNGdJQ0FnSUNCMGFISnZkeUJ1WlhjZ1JYaGpaWEIwYVc5dUtDZHRkWE4wSUhCaGMzTWdjR0Z5Wlc1MElHUmxjSFJvY3ljcE8xeHVJQ0FnSUgxY2JseHVJQ0FnSUhKbGRIVnliaUIzY21Gd1VISnZaM0poYlNoamIyNTBZV2x1WlhJc0lHa3NJSFJsYlhCc1lYUmxVM0JsWTF0cFhTd2daR0YwWVN3Z01Dd2dZbXh2WTJ0UVlYSmhiWE1zSUdSbGNIUm9jeWs3WEc0Z0lIMDdYRzRnSUhKbGRIVnliaUJ5WlhRN1hHNTlYRzVjYm1WNGNHOXlkQ0JtZFc1amRHbHZiaUIzY21Gd1VISnZaM0poYlNoamIyNTBZV2x1WlhJc0lHa3NJR1p1TENCa1lYUmhMQ0JrWldOc1lYSmxaRUpzYjJOclVHRnlZVzF6TENCaWJHOWphMUJoY21GdGN5d2daR1Z3ZEdoektTQjdYRzRnSUdaMWJtTjBhVzl1SUhCeWIyY29ZMjl1ZEdWNGRDd2diM0IwYVc5dWN5QTlJSHQ5S1NCN1hHNGdJQ0FnYkdWMElHTjFjbkpsYm5SRVpYQjBhSE1nUFNCa1pYQjBhSE03WEc0Z0lDQWdhV1lnS0dSbGNIUm9jeUFtSmlCamIyNTBaWGgwSUNFOUlHUmxjSFJvYzFzd1hTQW1KaUFoS0dOdmJuUmxlSFFnUFQwOUlHTnZiblJoYVc1bGNpNXVkV3hzUTI5dWRHVjRkQ0FtSmlCa1pYQjBhSE5iTUYwZ1BUMDlJRzUxYkd3cEtTQjdYRzRnSUNBZ0lDQmpkWEp5Wlc1MFJHVndkR2h6SUQwZ1cyTnZiblJsZUhSZExtTnZibU5oZENoa1pYQjBhSE1wTzF4dUlDQWdJSDFjYmx4dUlDQWdJSEpsZEhWeWJpQm1iaWhqYjI1MFlXbHVaWElzWEc0Z0lDQWdJQ0FnSUdOdmJuUmxlSFFzWEc0Z0lDQWdJQ0FnSUdOdmJuUmhhVzVsY2k1b1pXeHdaWEp6TENCamIyNTBZV2x1WlhJdWNHRnlkR2xoYkhNc1hHNGdJQ0FnSUNBZ0lHOXdkR2x2Ym5NdVpHRjBZU0I4ZkNCa1lYUmhMRnh1SUNBZ0lDQWdJQ0JpYkc5amExQmhjbUZ0Y3lBbUppQmJiM0IwYVc5dWN5NWliRzlqYTFCaGNtRnRjMTB1WTI5dVkyRjBLR0pzYjJOclVHRnlZVzF6S1N4Y2JpQWdJQ0FnSUNBZ1kzVnljbVZ1ZEVSbGNIUm9jeWs3WEc0Z0lIMWNibHh1SUNCd2NtOW5JRDBnWlhobFkzVjBaVVJsWTI5eVlYUnZjbk1vWm00c0lIQnliMmNzSUdOdmJuUmhhVzVsY2l3Z1pHVndkR2h6TENCa1lYUmhMQ0JpYkc5amExQmhjbUZ0Y3lrN1hHNWNiaUFnY0hKdlp5NXdjbTluY21GdElEMGdhVHRjYmlBZ2NISnZaeTVrWlhCMGFDQTlJR1JsY0hSb2N5QS9JR1JsY0hSb2N5NXNaVzVuZEdnZ09pQXdPMXh1SUNCd2NtOW5MbUpzYjJOclVHRnlZVzF6SUQwZ1pHVmpiR0Z5WldSQ2JHOWphMUJoY21GdGN5QjhmQ0F3TzF4dUlDQnlaWFIxY200Z2NISnZaenRjYm4xY2JseHVaWGh3YjNKMElHWjFibU4wYVc5dUlISmxjMjlzZG1WUVlYSjBhV0ZzS0hCaGNuUnBZV3dzSUdOdmJuUmxlSFFzSUc5d2RHbHZibk1wSUh0Y2JpQWdhV1lnS0NGd1lYSjBhV0ZzS1NCN1hHNGdJQ0FnYVdZZ0tHOXdkR2x2Ym5NdWJtRnRaU0E5UFQwZ0owQndZWEowYVdGc0xXSnNiMk5ySnlrZ2UxeHVJQ0FnSUNBZ2NHRnlkR2xoYkNBOUlHOXdkR2x2Ym5NdVpHRjBZVnNuY0dGeWRHbGhiQzFpYkc5amF5ZGRPMXh1SUNBZ0lIMGdaV3h6WlNCN1hHNGdJQ0FnSUNCd1lYSjBhV0ZzSUQwZ2IzQjBhVzl1Y3k1d1lYSjBhV0ZzYzF0dmNIUnBiMjV6TG01aGJXVmRPMXh1SUNBZ0lIMWNiaUFnZlNCbGJITmxJR2xtSUNnaGNHRnlkR2xoYkM1allXeHNJQ1ltSUNGdmNIUnBiMjV6TG01aGJXVXBJSHRjYmlBZ0lDQXZMeUJVYUdseklHbHpJR0VnWkhsdVlXMXBZeUJ3WVhKMGFXRnNJSFJvWVhRZ2NtVjBkWEp1WldRZ1lTQnpkSEpwYm1kY2JpQWdJQ0J2Y0hScGIyNXpMbTVoYldVZ1BTQndZWEowYVdGc08xeHVJQ0FnSUhCaGNuUnBZV3dnUFNCdmNIUnBiMjV6TG5CaGNuUnBZV3h6VzNCaGNuUnBZV3hkTzF4dUlDQjlYRzRnSUhKbGRIVnliaUJ3WVhKMGFXRnNPMXh1ZlZ4dVhHNWxlSEJ2Y25RZ1puVnVZM1JwYjI0Z2FXNTJiMnRsVUdGeWRHbGhiQ2h3WVhKMGFXRnNMQ0JqYjI1MFpYaDBMQ0J2Y0hScGIyNXpLU0I3WEc0Z0lDOHZJRlZ6WlNCMGFHVWdZM1Z5Y21WdWRDQmpiRzl6ZFhKbElHTnZiblJsZUhRZ2RHOGdjMkYyWlNCMGFHVWdjR0Z5ZEdsaGJDMWliRzlqYXlCcFppQjBhR2x6SUhCaGNuUnBZV3hjYmlBZ1kyOXVjM1FnWTNWeWNtVnVkRkJoY25ScFlXeENiRzlqYXlBOUlHOXdkR2x2Ym5NdVpHRjBZU0FtSmlCdmNIUnBiMjV6TG1SaGRHRmJKM0JoY25ScFlXd3RZbXh2WTJzblhUdGNiaUFnYjNCMGFXOXVjeTV3WVhKMGFXRnNJRDBnZEhKMVpUdGNiaUFnYVdZZ0tHOXdkR2x2Ym5NdWFXUnpLU0I3WEc0Z0lDQWdiM0IwYVc5dWN5NWtZWFJoTG1OdmJuUmxlSFJRWVhSb0lEMGdiM0IwYVc5dWN5NXBaSE5iTUYwZ2ZId2diM0IwYVc5dWN5NWtZWFJoTG1OdmJuUmxlSFJRWVhSb08xeHVJQ0I5WEc1Y2JpQWdiR1YwSUhCaGNuUnBZV3hDYkc5amF6dGNiaUFnYVdZZ0tHOXdkR2x2Ym5NdVptNGdKaVlnYjNCMGFXOXVjeTVtYmlBaFBUMGdibTl2Y0NrZ2UxeHVJQ0FnSUc5d2RHbHZibk11WkdGMFlTQTlJR055WldGMFpVWnlZVzFsS0c5d2RHbHZibk11WkdGMFlTazdYRzRnSUNBZ0x5OGdWM0poY0hCbGNpQm1kVzVqZEdsdmJpQjBieUJuWlhRZ1lXTmpaWE56SUhSdklHTjFjbkpsYm5SUVlYSjBhV0ZzUW14dlkyc2dabkp2YlNCMGFHVWdZMnh2YzNWeVpWeHVJQ0FnSUd4bGRDQm1iaUE5SUc5d2RHbHZibk11Wm00N1hHNGdJQ0FnY0dGeWRHbGhiRUpzYjJOcklEMGdiM0IwYVc5dWN5NWtZWFJoV3lkd1lYSjBhV0ZzTFdKc2IyTnJKMTBnUFNCbWRXNWpkR2x2YmlCd1lYSjBhV0ZzUW14dlkydFhjbUZ3Y0dWeUtHTnZiblJsZUhRc0lHOXdkR2x2Ym5NZ1BTQjdmU2tnZTF4dVhHNGdJQ0FnSUNBdkx5QlNaWE4wYjNKbElIUm9aU0J3WVhKMGFXRnNMV0pzYjJOcklHWnliMjBnZEdobElHTnNiM04xY21VZ1ptOXlJSFJvWlNCbGVHVmpkWFJwYjI0Z2IyWWdkR2hsSUdKc2IyTnJYRzRnSUNBZ0lDQXZMeUJwTG1VdUlIUm9aU0J3WVhKMElHbHVjMmxrWlNCMGFHVWdZbXh2WTJzZ2IyWWdkR2hsSUhCaGNuUnBZV3dnWTJGc2JDNWNiaUFnSUNBZ0lHOXdkR2x2Ym5NdVpHRjBZU0E5SUdOeVpXRjBaVVp5WVcxbEtHOXdkR2x2Ym5NdVpHRjBZU2s3WEc0Z0lDQWdJQ0J2Y0hScGIyNXpMbVJoZEdGYkozQmhjblJwWVd3dFlteHZZMnNuWFNBOUlHTjFjbkpsYm5SUVlYSjBhV0ZzUW14dlkyczdYRzRnSUNBZ0lDQnlaWFIxY200Z1ptNG9ZMjl1ZEdWNGRDd2diM0IwYVc5dWN5azdYRzRnSUNBZ2ZUdGNiaUFnSUNCcFppQW9abTR1Y0dGeWRHbGhiSE1wSUh0Y2JpQWdJQ0FnSUc5d2RHbHZibk11Y0dGeWRHbGhiSE1nUFNCVmRHbHNjeTVsZUhSbGJtUW9lMzBzSUc5d2RHbHZibk11Y0dGeWRHbGhiSE1zSUdadUxuQmhjblJwWVd4ektUdGNiaUFnSUNCOVhHNGdJSDFjYmx4dUlDQnBaaUFvY0dGeWRHbGhiQ0E5UFQwZ2RXNWtaV1pwYm1Wa0lDWW1JSEJoY25ScFlXeENiRzlqYXlrZ2UxeHVJQ0FnSUhCaGNuUnBZV3dnUFNCd1lYSjBhV0ZzUW14dlkyczdYRzRnSUgxY2JseHVJQ0JwWmlBb2NHRnlkR2xoYkNBOVBUMGdkVzVrWldacGJtVmtLU0I3WEc0Z0lDQWdkR2h5YjNjZ2JtVjNJRVY0WTJWd2RHbHZiaWduVkdobElIQmhjblJwWVd3Z0p5QXJJRzl3ZEdsdmJuTXVibUZ0WlNBcklDY2dZMjkxYkdRZ2JtOTBJR0psSUdadmRXNWtKeWs3WEc0Z0lIMGdaV3h6WlNCcFppQW9jR0Z5ZEdsaGJDQnBibk4wWVc1alpXOW1JRVoxYm1OMGFXOXVLU0I3WEc0Z0lDQWdjbVYwZFhKdUlIQmhjblJwWVd3b1kyOXVkR1Y0ZEN3Z2IzQjBhVzl1Y3lrN1hHNGdJSDFjYm4xY2JseHVaWGh3YjNKMElHWjFibU4wYVc5dUlHNXZiM0FvS1NCN0lISmxkSFZ5YmlBbkp6c2dmVnh1WEc1bWRXNWpkR2x2YmlCcGJtbDBSR0YwWVNoamIyNTBaWGgwTENCa1lYUmhLU0I3WEc0Z0lHbG1JQ2doWkdGMFlTQjhmQ0FoS0NkeWIyOTBKeUJwYmlCa1lYUmhLU2tnZTF4dUlDQWdJR1JoZEdFZ1BTQmtZWFJoSUQ4Z1kzSmxZWFJsUm5KaGJXVW9aR0YwWVNrZ09pQjdmVHRjYmlBZ0lDQmtZWFJoTG5KdmIzUWdQU0JqYjI1MFpYaDBPMXh1SUNCOVhHNGdJSEpsZEhWeWJpQmtZWFJoTzF4dWZWeHVYRzVtZFc1amRHbHZiaUJsZUdWamRYUmxSR1ZqYjNKaGRHOXljeWhtYml3Z2NISnZaeXdnWTI5dWRHRnBibVZ5TENCa1pYQjBhSE1zSUdSaGRHRXNJR0pzYjJOclVHRnlZVzF6S1NCN1hHNGdJR2xtSUNobWJpNWtaV052Y21GMGIzSXBJSHRjYmlBZ0lDQnNaWFFnY0hKdmNITWdQU0I3ZlR0Y2JpQWdJQ0J3Y205bklEMGdabTR1WkdWamIzSmhkRzl5S0hCeWIyY3NJSEJ5YjNCekxDQmpiMjUwWVdsdVpYSXNJR1JsY0hSb2N5QW1KaUJrWlhCMGFITmJNRjBzSUdSaGRHRXNJR0pzYjJOclVHRnlZVzF6TENCa1pYQjBhSE1wTzF4dUlDQWdJRlYwYVd4ekxtVjRkR1Z1WkNod2NtOW5MQ0J3Y205d2N5azdYRzRnSUgxY2JpQWdjbVYwZFhKdUlIQnliMmM3WEc1OVhHNGlYWDA9XG4iLCIvLyBCdWlsZCBvdXQgb3VyIGJhc2ljIFNhZmVTdHJpbmcgdHlwZVxuJ3VzZSBzdHJpY3QnO1xuXG5leHBvcnRzLl9fZXNNb2R1bGUgPSB0cnVlO1xuZnVuY3Rpb24gU2FmZVN0cmluZyhzdHJpbmcpIHtcbiAgdGhpcy5zdHJpbmcgPSBzdHJpbmc7XG59XG5cblNhZmVTdHJpbmcucHJvdG90eXBlLnRvU3RyaW5nID0gU2FmZVN0cmluZy5wcm90b3R5cGUudG9IVE1MID0gZnVuY3Rpb24gKCkge1xuICByZXR1cm4gJycgKyB0aGlzLnN0cmluZztcbn07XG5cbmV4cG9ydHNbJ2RlZmF1bHQnXSA9IFNhZmVTdHJpbmc7XG5tb2R1bGUuZXhwb3J0cyA9IGV4cG9ydHNbJ2RlZmF1bHQnXTtcbi8vIyBzb3VyY2VNYXBwaW5nVVJMPWRhdGE6YXBwbGljYXRpb24vanNvbjtjaGFyc2V0PXV0Zi04O2Jhc2U2NCxleUoyWlhKemFXOXVJam96TENKemIzVnlZMlZ6SWpwYklpNHVMeTR1THk0dUwyeHBZaTlvWVc1a2JHVmlZWEp6TDNOaFptVXRjM1J5YVc1bkxtcHpJbDBzSW01aGJXVnpJanBiWFN3aWJXRndjR2x1WjNNaU9pSTdPenM3UVVGRFFTeFRRVUZUTEZWQlFWVXNRMEZCUXl4TlFVRk5MRVZCUVVVN1FVRkRNVUlzVFVGQlNTeERRVUZETEUxQlFVMHNSMEZCUnl4TlFVRk5MRU5CUVVNN1EwRkRkRUk3TzBGQlJVUXNWVUZCVlN4RFFVRkRMRk5CUVZNc1EwRkJReXhSUVVGUkxFZEJRVWNzVlVGQlZTeERRVUZETEZOQlFWTXNRMEZCUXl4TlFVRk5MRWRCUVVjc1dVRkJWenRCUVVOMlJTeFRRVUZQTEVWQlFVVXNSMEZCUnl4SlFVRkpMRU5CUVVNc1RVRkJUU3hEUVVGRE8wTkJRM3BDTEVOQlFVTTdPM0ZDUVVWaExGVkJRVlVpTENKbWFXeGxJam9pYzJGbVpTMXpkSEpwYm1jdWFuTWlMQ0p6YjNWeVkyVnpRMjl1ZEdWdWRDSTZXeUl2THlCQ2RXbHNaQ0J2ZFhRZ2IzVnlJR0poYzJsaklGTmhabVZUZEhKcGJtY2dkSGx3WlZ4dVpuVnVZM1JwYjI0Z1UyRm1aVk4wY21sdVp5aHpkSEpwYm1jcElIdGNiaUFnZEdocGN5NXpkSEpwYm1jZ1BTQnpkSEpwYm1jN1hHNTlYRzVjYmxOaFptVlRkSEpwYm1jdWNISnZkRzkwZVhCbExuUnZVM1J5YVc1bklEMGdVMkZtWlZOMGNtbHVaeTV3Y205MGIzUjVjR1V1ZEc5SVZFMU1JRDBnWm5WdVkzUnBiMjRvS1NCN1hHNGdJSEpsZEhWeWJpQW5KeUFySUhSb2FYTXVjM1J5YVc1bk8xeHVmVHRjYmx4dVpYaHdiM0owSUdSbFptRjFiSFFnVTJGbVpWTjBjbWx1Wnp0Y2JpSmRmUT09XG4iLCIndXNlIHN0cmljdCc7XG5cbmV4cG9ydHMuX19lc01vZHVsZSA9IHRydWU7XG5leHBvcnRzLmV4dGVuZCA9IGV4dGVuZDtcbmV4cG9ydHMuaW5kZXhPZiA9IGluZGV4T2Y7XG5leHBvcnRzLmVzY2FwZUV4cHJlc3Npb24gPSBlc2NhcGVFeHByZXNzaW9uO1xuZXhwb3J0cy5pc0VtcHR5ID0gaXNFbXB0eTtcbmV4cG9ydHMuY3JlYXRlRnJhbWUgPSBjcmVhdGVGcmFtZTtcbmV4cG9ydHMuYmxvY2tQYXJhbXMgPSBibG9ja1BhcmFtcztcbmV4cG9ydHMuYXBwZW5kQ29udGV4dFBhdGggPSBhcHBlbmRDb250ZXh0UGF0aDtcbnZhciBlc2NhcGUgPSB7XG4gICcmJzogJyZhbXA7JyxcbiAgJzwnOiAnJmx0OycsXG4gICc+JzogJyZndDsnLFxuICAnXCInOiAnJnF1b3Q7JyxcbiAgXCInXCI6ICcmI3gyNzsnLFxuICAnYCc6ICcmI3g2MDsnLFxuICAnPSc6ICcmI3gzRDsnXG59O1xuXG52YXIgYmFkQ2hhcnMgPSAvWyY8PlwiJ2A9XS9nLFxuICAgIHBvc3NpYmxlID0gL1smPD5cIidgPV0vO1xuXG5mdW5jdGlvbiBlc2NhcGVDaGFyKGNocikge1xuICByZXR1cm4gZXNjYXBlW2Nocl07XG59XG5cbmZ1bmN0aW9uIGV4dGVuZChvYmogLyogLCAuLi5zb3VyY2UgKi8pIHtcbiAgZm9yICh2YXIgaSA9IDE7IGkgPCBhcmd1bWVudHMubGVuZ3RoOyBpKyspIHtcbiAgICBmb3IgKHZhciBrZXkgaW4gYXJndW1lbnRzW2ldKSB7XG4gICAgICBpZiAoT2JqZWN0LnByb3RvdHlwZS5oYXNPd25Qcm9wZXJ0eS5jYWxsKGFyZ3VtZW50c1tpXSwga2V5KSkge1xuICAgICAgICBvYmpba2V5XSA9IGFyZ3VtZW50c1tpXVtrZXldO1xuICAgICAgfVxuICAgIH1cbiAgfVxuXG4gIHJldHVybiBvYmo7XG59XG5cbnZhciB0b1N0cmluZyA9IE9iamVjdC5wcm90b3R5cGUudG9TdHJpbmc7XG5cbmV4cG9ydHMudG9TdHJpbmcgPSB0b1N0cmluZztcbi8vIFNvdXJjZWQgZnJvbSBsb2Rhc2hcbi8vIGh0dHBzOi8vZ2l0aHViLmNvbS9iZXN0aWVqcy9sb2Rhc2gvYmxvYi9tYXN0ZXIvTElDRU5TRS50eHRcbi8qIGVzbGludC1kaXNhYmxlIGZ1bmMtc3R5bGUgKi9cbnZhciBpc0Z1bmN0aW9uID0gZnVuY3Rpb24gaXNGdW5jdGlvbih2YWx1ZSkge1xuICByZXR1cm4gdHlwZW9mIHZhbHVlID09PSAnZnVuY3Rpb24nO1xufTtcbi8vIGZhbGxiYWNrIGZvciBvbGRlciB2ZXJzaW9ucyBvZiBDaHJvbWUgYW5kIFNhZmFyaVxuLyogaXN0YW5idWwgaWdub3JlIG5leHQgKi9cbmlmIChpc0Z1bmN0aW9uKC94LykpIHtcbiAgZXhwb3J0cy5pc0Z1bmN0aW9uID0gaXNGdW5jdGlvbiA9IGZ1bmN0aW9uICh2YWx1ZSkge1xuICAgIHJldHVybiB0eXBlb2YgdmFsdWUgPT09ICdmdW5jdGlvbicgJiYgdG9TdHJpbmcuY2FsbCh2YWx1ZSkgPT09ICdbb2JqZWN0IEZ1bmN0aW9uXSc7XG4gIH07XG59XG5leHBvcnRzLmlzRnVuY3Rpb24gPSBpc0Z1bmN0aW9uO1xuXG4vKiBlc2xpbnQtZW5hYmxlIGZ1bmMtc3R5bGUgKi9cblxuLyogaXN0YW5idWwgaWdub3JlIG5leHQgKi9cbnZhciBpc0FycmF5ID0gQXJyYXkuaXNBcnJheSB8fCBmdW5jdGlvbiAodmFsdWUpIHtcbiAgcmV0dXJuIHZhbHVlICYmIHR5cGVvZiB2YWx1ZSA9PT0gJ29iamVjdCcgPyB0b1N0cmluZy5jYWxsKHZhbHVlKSA9PT0gJ1tvYmplY3QgQXJyYXldJyA6IGZhbHNlO1xufTtcblxuZXhwb3J0cy5pc0FycmF5ID0gaXNBcnJheTtcbi8vIE9sZGVyIElFIHZlcnNpb25zIGRvIG5vdCBkaXJlY3RseSBzdXBwb3J0IGluZGV4T2Ygc28gd2UgbXVzdCBpbXBsZW1lbnQgb3VyIG93biwgc2FkbHkuXG5cbmZ1bmN0aW9uIGluZGV4T2YoYXJyYXksIHZhbHVlKSB7XG4gIGZvciAodmFyIGkgPSAwLCBsZW4gPSBhcnJheS5sZW5ndGg7IGkgPCBsZW47IGkrKykge1xuICAgIGlmIChhcnJheVtpXSA9PT0gdmFsdWUpIHtcbiAgICAgIHJldHVybiBpO1xuICAgIH1cbiAgfVxuICByZXR1cm4gLTE7XG59XG5cbmZ1bmN0aW9uIGVzY2FwZUV4cHJlc3Npb24oc3RyaW5nKSB7XG4gIGlmICh0eXBlb2Ygc3RyaW5nICE9PSAnc3RyaW5nJykge1xuICAgIC8vIGRvbid0IGVzY2FwZSBTYWZlU3RyaW5ncywgc2luY2UgdGhleSdyZSBhbHJlYWR5IHNhZmVcbiAgICBpZiAoc3RyaW5nICYmIHN0cmluZy50b0hUTUwpIHtcbiAgICAgIHJldHVybiBzdHJpbmcudG9IVE1MKCk7XG4gICAgfSBlbHNlIGlmIChzdHJpbmcgPT0gbnVsbCkge1xuICAgICAgcmV0dXJuICcnO1xuICAgIH0gZWxzZSBpZiAoIXN0cmluZykge1xuICAgICAgcmV0dXJuIHN0cmluZyArICcnO1xuICAgIH1cblxuICAgIC8vIEZvcmNlIGEgc3RyaW5nIGNvbnZlcnNpb24gYXMgdGhpcyB3aWxsIGJlIGRvbmUgYnkgdGhlIGFwcGVuZCByZWdhcmRsZXNzIGFuZFxuICAgIC8vIHRoZSByZWdleCB0ZXN0IHdpbGwgZG8gdGhpcyB0cmFuc3BhcmVudGx5IGJlaGluZCB0aGUgc2NlbmVzLCBjYXVzaW5nIGlzc3VlcyBpZlxuICAgIC8vIGFuIG9iamVjdCdzIHRvIHN0cmluZyBoYXMgZXNjYXBlZCBjaGFyYWN0ZXJzIGluIGl0LlxuICAgIHN0cmluZyA9ICcnICsgc3RyaW5nO1xuICB9XG5cbiAgaWYgKCFwb3NzaWJsZS50ZXN0KHN0cmluZykpIHtcbiAgICByZXR1cm4gc3RyaW5nO1xuICB9XG4gIHJldHVybiBzdHJpbmcucmVwbGFjZShiYWRDaGFycywgZXNjYXBlQ2hhcik7XG59XG5cbmZ1bmN0aW9uIGlzRW1wdHkodmFsdWUpIHtcbiAgaWYgKCF2YWx1ZSAmJiB2YWx1ZSAhPT0gMCkge1xuICAgIHJldHVybiB0cnVlO1xuICB9IGVsc2UgaWYgKGlzQXJyYXkodmFsdWUpICYmIHZhbHVlLmxlbmd0aCA9PT0gMCkge1xuICAgIHJldHVybiB0cnVlO1xuICB9IGVsc2Uge1xuICAgIHJldHVybiBmYWxzZTtcbiAgfVxufVxuXG5mdW5jdGlvbiBjcmVhdGVGcmFtZShvYmplY3QpIHtcbiAgdmFyIGZyYW1lID0gZXh0ZW5kKHt9LCBvYmplY3QpO1xuICBmcmFtZS5fcGFyZW50ID0gb2JqZWN0O1xuICByZXR1cm4gZnJhbWU7XG59XG5cbmZ1bmN0aW9uIGJsb2NrUGFyYW1zKHBhcmFtcywgaWRzKSB7XG4gIHBhcmFtcy5wYXRoID0gaWRzO1xuICByZXR1cm4gcGFyYW1zO1xufVxuXG5mdW5jdGlvbiBhcHBlbmRDb250ZXh0UGF0aChjb250ZXh0UGF0aCwgaWQpIHtcbiAgcmV0dXJuIChjb250ZXh0UGF0aCA/IGNvbnRleHRQYXRoICsgJy4nIDogJycpICsgaWQ7XG59XG4vLyMgc291cmNlTWFwcGluZ1VSTD1kYXRhOmFwcGxpY2F0aW9uL2pzb247Y2hhcnNldD11dGYtODtiYXNlNjQsZXlKMlpYSnphVzl1SWpvekxDSnpiM1Z5WTJWeklqcGJJaTR1THk0dUx5NHVMMnhwWWk5b1lXNWtiR1ZpWVhKekwzVjBhV3h6TG1weklsMHNJbTVoYldWeklqcGJYU3dpYldGd2NHbHVaM01pT2lJN096czdPenM3T3pzN1FVRkJRU3hKUVVGTkxFMUJRVTBzUjBGQlJ6dEJRVU5pTEV0QlFVY3NSVUZCUlN4UFFVRlBPMEZCUTFvc1MwRkJSeXhGUVVGRkxFMUJRVTA3UVVGRFdDeExRVUZITEVWQlFVVXNUVUZCVFR0QlFVTllMRXRCUVVjc1JVRkJSU3hSUVVGUk8wRkJRMklzUzBGQlJ5eEZRVUZGTEZGQlFWRTdRVUZEWWl4TFFVRkhMRVZCUVVVc1VVRkJVVHRCUVVOaUxFdEJRVWNzUlVGQlJTeFJRVUZSTzBOQlEyUXNRMEZCUXpzN1FVRkZSaXhKUVVGTkxGRkJRVkVzUjBGQlJ5eFpRVUZaTzBsQlEzWkNMRkZCUVZFc1IwRkJSeXhYUVVGWExFTkJRVU03TzBGQlJUZENMRk5CUVZNc1ZVRkJWU3hEUVVGRExFZEJRVWNzUlVGQlJUdEJRVU4yUWl4VFFVRlBMRTFCUVUwc1EwRkJReXhIUVVGSExFTkJRVU1zUTBGQlF6dERRVU53UWpzN1FVRkZUU3hUUVVGVExFMUJRVTBzUTBGQlF5eEhRVUZITEc5Q1FVRnRRanRCUVVNelF5eFBRVUZMTEVsQlFVa3NRMEZCUXl4SFFVRkhMRU5CUVVNc1JVRkJSU3hEUVVGRExFZEJRVWNzVTBGQlV5eERRVUZETEUxQlFVMHNSVUZCUlN4RFFVRkRMRVZCUVVVc1JVRkJSVHRCUVVONlF5eFRRVUZMTEVsQlFVa3NSMEZCUnl4SlFVRkpMRk5CUVZNc1EwRkJReXhEUVVGRExFTkJRVU1zUlVGQlJUdEJRVU0xUWl4VlFVRkpMRTFCUVUwc1EwRkJReXhUUVVGVExFTkJRVU1zWTBGQll5eERRVUZETEVsQlFVa3NRMEZCUXl4VFFVRlRMRU5CUVVNc1EwRkJReXhEUVVGRExFVkJRVVVzUjBGQlJ5eERRVUZETEVWQlFVVTdRVUZETTBRc1YwRkJSeXhEUVVGRExFZEJRVWNzUTBGQlF5eEhRVUZITEZOQlFWTXNRMEZCUXl4RFFVRkRMRU5CUVVNc1EwRkJReXhIUVVGSExFTkJRVU1zUTBGQlF6dFBRVU01UWp0TFFVTkdPMGRCUTBZN08wRkJSVVFzVTBGQlR5eEhRVUZITEVOQlFVTTdRMEZEV2pzN1FVRkZUU3hKUVVGSkxGRkJRVkVzUjBGQlJ5eE5RVUZOTEVOQlFVTXNVMEZCVXl4RFFVRkRMRkZCUVZFc1EwRkJRenM3T3pzN08wRkJTMmhFTEVsQlFVa3NWVUZCVlN4SFFVRkhMRzlDUVVGVExFdEJRVXNzUlVGQlJUdEJRVU12UWl4VFFVRlBMRTlCUVU4c1MwRkJTeXhMUVVGTExGVkJRVlVzUTBGQlF6dERRVU53UXl4RFFVRkRPenM3UVVGSFJpeEpRVUZKTEZWQlFWVXNRMEZCUXl4SFFVRkhMRU5CUVVNc1JVRkJSVHRCUVVOdVFpeFZRVWxOTEZWQlFWVXNSMEZLYUVJc1ZVRkJWU3hIUVVGSExGVkJRVk1zUzBGQlN5eEZRVUZGTzBGQlF6TkNMRmRCUVU4c1QwRkJUeXhMUVVGTExFdEJRVXNzVlVGQlZTeEpRVUZKTEZGQlFWRXNRMEZCUXl4SlFVRkpMRU5CUVVNc1MwRkJTeXhEUVVGRExFdEJRVXNzYlVKQlFXMUNMRU5CUVVNN1IwRkRjRVlzUTBGQlF6dERRVU5JTzFGQlEwOHNWVUZCVlN4SFFVRldMRlZCUVZVN096czdPMEZCU1Znc1NVRkJUU3hQUVVGUExFZEJRVWNzUzBGQlN5eERRVUZETEU5QlFVOHNTVUZCU1N4VlFVRlRMRXRCUVVzc1JVRkJSVHRCUVVOMFJDeFRRVUZQTEVGQlFVTXNTMEZCU3l4SlFVRkpMRTlCUVU4c1MwRkJTeXhMUVVGTExGRkJRVkVzUjBGQlNTeFJRVUZSTEVOQlFVTXNTVUZCU1N4RFFVRkRMRXRCUVVzc1EwRkJReXhMUVVGTExHZENRVUZuUWl4SFFVRkhMRXRCUVVzc1EwRkJRenREUVVOcVJ5eERRVUZET3pzN096dEJRVWRMTEZOQlFWTXNUMEZCVHl4RFFVRkRMRXRCUVVzc1JVRkJSU3hMUVVGTExFVkJRVVU3UVVGRGNFTXNUMEZCU3l4SlFVRkpMRU5CUVVNc1IwRkJSeXhEUVVGRExFVkJRVVVzUjBGQlJ5eEhRVUZITEV0QlFVc3NRMEZCUXl4TlFVRk5MRVZCUVVVc1EwRkJReXhIUVVGSExFZEJRVWNzUlVGQlJTeERRVUZETEVWQlFVVXNSVUZCUlR0QlFVTm9SQ3hSUVVGSkxFdEJRVXNzUTBGQlF5eERRVUZETEVOQlFVTXNTMEZCU3l4TFFVRkxMRVZCUVVVN1FVRkRkRUlzWVVGQlR5eERRVUZETEVOQlFVTTdTMEZEVmp0SFFVTkdPMEZCUTBRc1UwRkJUeXhEUVVGRExFTkJRVU1zUTBGQlF6dERRVU5ZT3p0QlFVZE5MRk5CUVZNc1owSkJRV2RDTEVOQlFVTXNUVUZCVFN4RlFVRkZPMEZCUTNaRExFMUJRVWtzVDBGQlR5eE5RVUZOTEV0QlFVc3NVVUZCVVN4RlFVRkZPenRCUVVVNVFpeFJRVUZKTEUxQlFVMHNTVUZCU1N4TlFVRk5MRU5CUVVNc1RVRkJUU3hGUVVGRk8wRkJRek5DTEdGQlFVOHNUVUZCVFN4RFFVRkRMRTFCUVUwc1JVRkJSU3hEUVVGRE8wdEJRM2hDTEUxQlFVMHNTVUZCU1N4TlFVRk5MRWxCUVVrc1NVRkJTU3hGUVVGRk8wRkJRM3BDTEdGQlFVOHNSVUZCUlN4RFFVRkRPMHRCUTFnc1RVRkJUU3hKUVVGSkxFTkJRVU1zVFVGQlRTeEZRVUZGTzBGQlEyeENMR0ZCUVU4c1RVRkJUU3hIUVVGSExFVkJRVVVzUTBGQlF6dExRVU53UWpzN096czdRVUZMUkN4VlFVRk5MRWRCUVVjc1JVRkJSU3hIUVVGSExFMUJRVTBzUTBGQlF6dEhRVU4wUWpzN1FVRkZSQ3hOUVVGSkxFTkJRVU1zVVVGQlVTeERRVUZETEVsQlFVa3NRMEZCUXl4TlFVRk5MRU5CUVVNc1JVRkJSVHRCUVVGRkxGZEJRVThzVFVGQlRTeERRVUZETzBkQlFVVTdRVUZET1VNc1UwRkJUeXhOUVVGTkxFTkJRVU1zVDBGQlR5eERRVUZETEZGQlFWRXNSVUZCUlN4VlFVRlZMRU5CUVVNc1EwRkJRenREUVVNM1F6czdRVUZGVFN4VFFVRlRMRTlCUVU4c1EwRkJReXhMUVVGTExFVkJRVVU3UVVGRE4wSXNUVUZCU1N4RFFVRkRMRXRCUVVzc1NVRkJTU3hMUVVGTExFdEJRVXNzUTBGQlF5eEZRVUZGTzBGQlEzcENMRmRCUVU4c1NVRkJTU3hEUVVGRE8wZEJRMklzVFVGQlRTeEpRVUZKTEU5QlFVOHNRMEZCUXl4TFFVRkxMRU5CUVVNc1NVRkJTU3hMUVVGTExFTkJRVU1zVFVGQlRTeExRVUZMTEVOQlFVTXNSVUZCUlR0QlFVTXZReXhYUVVGUExFbEJRVWtzUTBGQlF6dEhRVU5pTEUxQlFVMDdRVUZEVEN4WFFVRlBMRXRCUVVzc1EwRkJRenRIUVVOa08wTkJRMFk3TzBGQlJVMHNVMEZCVXl4WFFVRlhMRU5CUVVNc1RVRkJUU3hGUVVGRk8wRkJRMnhETEUxQlFVa3NTMEZCU3l4SFFVRkhMRTFCUVUwc1EwRkJReXhGUVVGRkxFVkJRVVVzVFVGQlRTeERRVUZETEVOQlFVTTdRVUZETDBJc1QwRkJTeXhEUVVGRExFOUJRVThzUjBGQlJ5eE5RVUZOTEVOQlFVTTdRVUZEZGtJc1UwRkJUeXhMUVVGTExFTkJRVU03UTBGRFpEczdRVUZGVFN4VFFVRlRMRmRCUVZjc1EwRkJReXhOUVVGTkxFVkJRVVVzUjBGQlJ5eEZRVUZGTzBGQlEzWkRMRkZCUVUwc1EwRkJReXhKUVVGSkxFZEJRVWNzUjBGQlJ5eERRVUZETzBGQlEyeENMRk5CUVU4c1RVRkJUU3hEUVVGRE8wTkJRMlk3TzBGQlJVMHNVMEZCVXl4cFFrRkJhVUlzUTBGQlF5eFhRVUZYTEVWQlFVVXNSVUZCUlN4RlFVRkZPMEZCUTJwRUxGTkJRVThzUTBGQlF5eFhRVUZYTEVkQlFVY3NWMEZCVnl4SFFVRkhMRWRCUVVjc1IwRkJSeXhGUVVGRkxFTkJRVUVzUjBGQlNTeEZRVUZGTEVOQlFVTTdRMEZEY0VRaUxDSm1hV3hsSWpvaWRYUnBiSE11YW5NaUxDSnpiM1Z5WTJWelEyOXVkR1Z1ZENJNld5SmpiMjV6ZENCbGMyTmhjR1VnUFNCN1hHNGdJQ2NtSnpvZ0p5WmhiWEE3Snl4Y2JpQWdKenduT2lBbkpteDBPeWNzWEc0Z0lDYytKem9nSnlabmREc25MRnh1SUNBblhDSW5PaUFuSm5GMWIzUTdKeXhjYmlBZ1hDSW5YQ0k2SUNjbUkzZ3lOenNuTEZ4dUlDQW5ZQ2M2SUNjbUkzZzJNRHNuTEZ4dUlDQW5QU2M2SUNjbUkzZ3pSRHNuWEc1OU8xeHVYRzVqYjI1emRDQmlZV1JEYUdGeWN5QTlJQzliSmp3K1hDSW5ZRDFkTDJjc1hHNGdJQ0FnSUNCd2IzTnphV0pzWlNBOUlDOWJKancrWENJbllEMWRMenRjYmx4dVpuVnVZM1JwYjI0Z1pYTmpZWEJsUTJoaGNpaGphSElwSUh0Y2JpQWdjbVYwZFhKdUlHVnpZMkZ3WlZ0amFISmRPMXh1ZlZ4dVhHNWxlSEJ2Y25RZ1puVnVZM1JwYjI0Z1pYaDBaVzVrS0c5aWFpOHFJQ3dnTGk0dWMyOTFjbU5sSUNvdktTQjdYRzRnSUdadmNpQW9iR1YwSUdrZ1BTQXhPeUJwSUR3Z1lYSm5kVzFsYm5SekxteGxibWQwYURzZ2FTc3JLU0I3WEc0Z0lDQWdabTl5SUNoc1pYUWdhMlY1SUdsdUlHRnlaM1Z0Wlc1MGMxdHBYU2tnZTF4dUlDQWdJQ0FnYVdZZ0tFOWlhbVZqZEM1d2NtOTBiM1I1Y0dVdWFHRnpUM2R1VUhKdmNHVnlkSGt1WTJGc2JDaGhjbWQxYldWdWRITmJhVjBzSUd0bGVTa3BJSHRjYmlBZ0lDQWdJQ0FnYjJKcVcydGxlVjBnUFNCaGNtZDFiV1Z1ZEhOYmFWMWJhMlY1WFR0Y2JpQWdJQ0FnSUgxY2JpQWdJQ0I5WEc0Z0lIMWNibHh1SUNCeVpYUjFjbTRnYjJKcU8xeHVmVnh1WEc1bGVIQnZjblFnYkdWMElIUnZVM1J5YVc1bklEMGdUMkpxWldOMExuQnliM1J2ZEhsd1pTNTBiMU4wY21sdVp6dGNibHh1THk4Z1UyOTFjbU5sWkNCbWNtOXRJR3h2WkdGemFGeHVMeThnYUhSMGNITTZMeTluYVhSb2RXSXVZMjl0TDJKbGMzUnBaV3B6TDJ4dlpHRnphQzlpYkc5aUwyMWhjM1JsY2k5TVNVTkZUbE5GTG5SNGRGeHVMeW9nWlhOc2FXNTBMV1JwYzJGaWJHVWdablZ1WXkxemRIbHNaU0FxTDF4dWJHVjBJR2x6Um5WdVkzUnBiMjRnUFNCbWRXNWpkR2x2YmloMllXeDFaU2tnZTF4dUlDQnlaWFIxY200Z2RIbHdaVzltSUhaaGJIVmxJRDA5UFNBblpuVnVZM1JwYjI0bk8xeHVmVHRjYmk4dklHWmhiR3hpWVdOcklHWnZjaUJ2YkdSbGNpQjJaWEp6YVc5dWN5QnZaaUJEYUhKdmJXVWdZVzVrSUZOaFptRnlhVnh1THlvZ2FYTjBZVzVpZFd3Z2FXZHViM0psSUc1bGVIUWdLaTljYm1sbUlDaHBjMFoxYm1OMGFXOXVLQzk0THlrcElIdGNiaUFnYVhOR2RXNWpkR2x2YmlBOUlHWjFibU4wYVc5dUtIWmhiSFZsS1NCN1hHNGdJQ0FnY21WMGRYSnVJSFI1Y0dWdlppQjJZV3gxWlNBOVBUMGdKMloxYm1OMGFXOXVKeUFtSmlCMGIxTjBjbWx1Wnk1allXeHNLSFpoYkhWbEtTQTlQVDBnSjF0dlltcGxZM1FnUm5WdVkzUnBiMjVkSnp0Y2JpQWdmVHRjYm4xY2JtVjRjRzl5ZENCN2FYTkdkVzVqZEdsdmJuMDdYRzR2S2lCbGMyeHBiblF0Wlc1aFlteGxJR1oxYm1NdGMzUjViR1VnS2k5Y2JseHVMeW9nYVhOMFlXNWlkV3dnYVdkdWIzSmxJRzVsZUhRZ0tpOWNibVY0Y0c5eWRDQmpiMjV6ZENCcGMwRnljbUY1SUQwZ1FYSnlZWGt1YVhOQmNuSmhlU0I4ZkNCbWRXNWpkR2x2YmloMllXeDFaU2tnZTF4dUlDQnlaWFIxY200Z0tIWmhiSFZsSUNZbUlIUjVjR1Z2WmlCMllXeDFaU0E5UFQwZ0oyOWlhbVZqZENjcElEOGdkRzlUZEhKcGJtY3VZMkZzYkNoMllXeDFaU2tnUFQwOUlDZGJiMkpxWldOMElFRnljbUY1WFNjZ09pQm1ZV3h6WlR0Y2JuMDdYRzVjYmk4dklFOXNaR1Z5SUVsRklIWmxjbk5wYjI1eklHUnZJRzV2ZENCa2FYSmxZM1JzZVNCemRYQndiM0owSUdsdVpHVjRUMllnYzI4Z2QyVWdiWFZ6ZENCcGJYQnNaVzFsYm5RZ2IzVnlJRzkzYml3Z2MyRmtiSGt1WEc1bGVIQnZjblFnWm5WdVkzUnBiMjRnYVc1a1pYaFBaaWhoY25KaGVTd2dkbUZzZFdVcElIdGNiaUFnWm05eUlDaHNaWFFnYVNBOUlEQXNJR3hsYmlBOUlHRnljbUY1TG14bGJtZDBhRHNnYVNBOElHeGxianNnYVNzcktTQjdYRzRnSUNBZ2FXWWdLR0Z5Y21GNVcybGRJRDA5UFNCMllXeDFaU2tnZTF4dUlDQWdJQ0FnY21WMGRYSnVJR2s3WEc0Z0lDQWdmVnh1SUNCOVhHNGdJSEpsZEhWeWJpQXRNVHRjYm4xY2JseHVYRzVsZUhCdmNuUWdablZ1WTNScGIyNGdaWE5qWVhCbFJYaHdjbVZ6YzJsdmJpaHpkSEpwYm1jcElIdGNiaUFnYVdZZ0tIUjVjR1Z2WmlCemRISnBibWNnSVQwOUlDZHpkSEpwYm1jbktTQjdYRzRnSUNBZ0x5OGdaRzl1SjNRZ1pYTmpZWEJsSUZOaFptVlRkSEpwYm1kekxDQnphVzVqWlNCMGFHVjVKM0psSUdGc2NtVmhaSGtnYzJGbVpWeHVJQ0FnSUdsbUlDaHpkSEpwYm1jZ0ppWWdjM1J5YVc1bkxuUnZTRlJOVENrZ2UxeHVJQ0FnSUNBZ2NtVjBkWEp1SUhOMGNtbHVaeTUwYjBoVVRVd29LVHRjYmlBZ0lDQjlJR1ZzYzJVZ2FXWWdLSE4wY21sdVp5QTlQU0J1ZFd4c0tTQjdYRzRnSUNBZ0lDQnlaWFIxY200Z0p5YzdYRzRnSUNBZ2ZTQmxiSE5sSUdsbUlDZ2hjM1J5YVc1bktTQjdYRzRnSUNBZ0lDQnlaWFIxY200Z2MzUnlhVzVuSUNzZ0p5YzdYRzRnSUNBZ2ZWeHVYRzRnSUNBZ0x5OGdSbTl5WTJVZ1lTQnpkSEpwYm1jZ1kyOXVkbVZ5YzJsdmJpQmhjeUIwYUdseklIZHBiR3dnWW1VZ1pHOXVaU0JpZVNCMGFHVWdZWEJ3Wlc1a0lISmxaMkZ5Wkd4bGMzTWdZVzVrWEc0Z0lDQWdMeThnZEdobElISmxaMlY0SUhSbGMzUWdkMmxzYkNCa2J5QjBhR2x6SUhSeVlXNXpjR0Z5Wlc1MGJIa2dZbVZvYVc1a0lIUm9aU0J6WTJWdVpYTXNJR05oZFhOcGJtY2dhWE56ZFdWeklHbG1YRzRnSUNBZ0x5OGdZVzRnYjJKcVpXTjBKM01nZEc4Z2MzUnlhVzVuSUdoaGN5QmxjMk5oY0dWa0lHTm9ZWEpoWTNSbGNuTWdhVzRnYVhRdVhHNGdJQ0FnYzNSeWFXNW5JRDBnSnljZ0t5QnpkSEpwYm1jN1hHNGdJSDFjYmx4dUlDQnBaaUFvSVhCdmMzTnBZbXhsTG5SbGMzUW9jM1J5YVc1bktTa2dleUJ5WlhSMWNtNGdjM1J5YVc1bk95QjlYRzRnSUhKbGRIVnliaUJ6ZEhKcGJtY3VjbVZ3YkdGalpTaGlZV1JEYUdGeWN5d2daWE5qWVhCbFEyaGhjaWs3WEc1OVhHNWNibVY0Y0c5eWRDQm1kVzVqZEdsdmJpQnBjMFZ0Y0hSNUtIWmhiSFZsS1NCN1hHNGdJR2xtSUNnaGRtRnNkV1VnSmlZZ2RtRnNkV1VnSVQwOUlEQXBJSHRjYmlBZ0lDQnlaWFIxY200Z2RISjFaVHRjYmlBZ2ZTQmxiSE5sSUdsbUlDaHBjMEZ5Y21GNUtIWmhiSFZsS1NBbUppQjJZV3gxWlM1c1pXNW5kR2dnUFQwOUlEQXBJSHRjYmlBZ0lDQnlaWFIxY200Z2RISjFaVHRjYmlBZ2ZTQmxiSE5sSUh0Y2JpQWdJQ0J5WlhSMWNtNGdabUZzYzJVN1hHNGdJSDFjYm4xY2JseHVaWGh3YjNKMElHWjFibU4wYVc5dUlHTnlaV0YwWlVaeVlXMWxLRzlpYW1WamRDa2dlMXh1SUNCc1pYUWdabkpoYldVZ1BTQmxlSFJsYm1Rb2UzMHNJRzlpYW1WamRDazdYRzRnSUdaeVlXMWxMbDl3WVhKbGJuUWdQU0J2WW1wbFkzUTdYRzRnSUhKbGRIVnliaUJtY21GdFpUdGNibjFjYmx4dVpYaHdiM0owSUdaMWJtTjBhVzl1SUdKc2IyTnJVR0Z5WVcxektIQmhjbUZ0Y3l3Z2FXUnpLU0I3WEc0Z0lIQmhjbUZ0Y3k1d1lYUm9JRDBnYVdSek8xeHVJQ0J5WlhSMWNtNGdjR0Z5WVcxek8xeHVmVnh1WEc1bGVIQnZjblFnWm5WdVkzUnBiMjRnWVhCd1pXNWtRMjl1ZEdWNGRGQmhkR2dvWTI5dWRHVjRkRkJoZEdnc0lHbGtLU0I3WEc0Z0lISmxkSFZ5YmlBb1kyOXVkR1Y0ZEZCaGRHZ2dQeUJqYjI1MFpYaDBVR0YwYUNBcklDY3VKeUE2SUNjbktTQXJJR2xrTzF4dWZWeHVJbDE5XG4iLCIvLyBDcmVhdGUgYSBzaW1wbGUgcGF0aCBhbGlhcyB0byBhbGxvdyBicm93c2VyaWZ5IHRvIHJlc29sdmVcbi8vIHRoZSBydW50aW1lIG9uIGEgc3VwcG9ydGVkIHBhdGguXG5tb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJy4vZGlzdC9janMvaGFuZGxlYmFycy5ydW50aW1lJylbJ2RlZmF1bHQnXTtcbiIsInZhciBnO1xuXG4vLyBUaGlzIHdvcmtzIGluIG5vbi1zdHJpY3QgbW9kZVxuZyA9IChmdW5jdGlvbigpIHtcblx0cmV0dXJuIHRoaXM7XG59KSgpO1xuXG50cnkge1xuXHQvLyBUaGlzIHdvcmtzIGlmIGV2YWwgaXMgYWxsb3dlZCAoc2VlIENTUClcblx0ZyA9IGcgfHwgbmV3IEZ1bmN0aW9uKFwicmV0dXJuIHRoaXNcIikoKTtcbn0gY2F0Y2ggKGUpIHtcblx0Ly8gVGhpcyB3b3JrcyBpZiB0aGUgd2luZG93IHJlZmVyZW5jZSBpcyBhdmFpbGFibGVcblx0aWYgKHR5cGVvZiB3aW5kb3cgPT09IFwib2JqZWN0XCIpIGcgPSB3aW5kb3c7XG59XG5cbi8vIGcgY2FuIHN0aWxsIGJlIHVuZGVmaW5lZCwgYnV0IG5vdGhpbmcgdG8gZG8gYWJvdXQgaXQuLi5cbi8vIFdlIHJldHVybiB1bmRlZmluZWQsIGluc3RlYWQgb2Ygbm90aGluZyBoZXJlLCBzbyBpdCdzXG4vLyBlYXNpZXIgdG8gaGFuZGxlIHRoaXMgY2FzZS4gaWYoIWdsb2JhbCkgeyAuLi59XG5cbm1vZHVsZS5leHBvcnRzID0gZztcbiIsIm1vZHVsZS5leHBvcnRzID0gZnVuY3Rpb24oaTE4bl9rZXksIGxhYmVsKSB7XG5cdHZhciByZXN1bHQgPSBpMThuLnQoaTE4bl9rZXksIHtsYWJlbH0pO1xuXHRyZXR1cm4gbmV3IEhhbmRsZWJhcnMuU2FmZVN0cmluZyhyZXN1bHQpO1xufSIsInZhciBIYW5kbGViYXJzID0gcmVxdWlyZShcIi4uLy4uL25vZGVfbW9kdWxlcy9oYW5kbGViYXJzL3J1bnRpbWUuanNcIik7XG5mdW5jdGlvbiBfX2RlZmF1bHQob2JqKSB7IHJldHVybiBvYmogJiYgKG9iai5fX2VzTW9kdWxlID8gb2JqW1wiZGVmYXVsdFwiXSA6IG9iaik7IH1cbm1vZHVsZS5leHBvcnRzID0gKEhhbmRsZWJhcnNbXCJkZWZhdWx0XCJdIHx8IEhhbmRsZWJhcnMpLnRlbXBsYXRlKHtcIjFcIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSxibG9ja1BhcmFtcyxkZXB0aHMpIHtcbiAgICB2YXIgc3RhY2sxLCBoZWxwZXIsIGFsaWFzMT1kZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLCBhbGlhczI9aGVscGVycy5oZWxwZXJNaXNzaW5nLCBhbGlhczM9XCJmdW5jdGlvblwiLCBhbGlhczQ9Y29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb247XG5cbiAgcmV0dXJuIFwiICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZCBtZWV0aW5nLWNhcmQgXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnN0YXR1cyB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuc3RhdHVzIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJzdGF0dXNcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBkYXRhLXV1aWQ9J1wiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIic+XFxuICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWhlYWRlclxcXCI+XFxuICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtaGVhZGVyLWNvbnRlbnRcXFwiPlxcbiAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtc2VsZWN0XFxcIj5cXG4gICAgICAgICAgICAgIDxpbnB1dCB0eXBlPVxcXCJjaGVja2JveFxcXCIgY2xhc3M9XFxcIm1lZXRpbmdfY2FyZFxcXCIgZGF0YS1lZGl0PSdcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuZWRpdCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZWRpdCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiZWRpdFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCInIGRhdGEtc3RhdHVzPVxcXCJcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuc3RhdHVzIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5zdGF0dXMgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcInN0YXR1c1wiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiIGlkPVxcXCJcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMudXVpZCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAudXVpZCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwidXVpZFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiPlxcbiAgICAgICAgICAgICAgPGxhYmVsIGZvcj1cXFwiXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnV1aWQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnV1aWQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcInV1aWRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIj5cXG4gICAgICAgICAgICAgICAgPGRpdj5NPC9kaXY+XFxuICAgICAgICAgICAgICA8L2xhYmVsPlxcbiAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtY2xpY2tcXFwiPlxcblwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnNbXCJpZlwiXS5jYWxsKGFsaWFzMSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAubWVldGluZ193aXRoIDogZGVwdGgwKSx7XCJuYW1lXCI6XCJpZlwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSgyLCBkYXRhLCAwLCBibG9ja1BhcmFtcywgZGVwdGhzKSxcImludmVyc2VcIjpjb250YWluZXIucHJvZ3JhbSg0LCBkYXRhLCAwLCBibG9ja1BhcmFtcywgZGVwdGhzKSxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKVxuICAgICsgXCIgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImZvbnQtbGdcXFwiPlwiXG4gICAgKyBhbGlhczQoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMxLFwiSURcIix7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCIgI1wiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5pZCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuaWQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIjwvZGl2PlxcbiAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgIDwvZGl2PlxcbiAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1jb250ZW50XFxcIj5cXG4gICAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1kZXRhaWwtY29udGVudFxcXCI+XFxuICAgICAgICAgICAgPGRpdiA+XFxuICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWRldGFpbCBpY29uLXNlcFxcXCI+XFxuICAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcInRleHQtY29udGVudFxcXCI+XFxuICAgICAgICAgICAgICAgICAgPHNwYW4gY2xhc3M9XFxcImZvbnQtc2VtaS1ib2xkXFxcIj5cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuc3RhcnRUaW1lIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5zdGFydFRpbWUgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcInN0YXJ0VGltZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCIgLSBcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuZW5kVGltZSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZW5kVGltZSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiZW5kVGltZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCI8L3NwYW4+XFxuICAgICAgICAgICAgICAgICAgPGJyPlxcbiAgICAgICAgICAgICAgICAgIDxzcGFuIGNsYXNzPVxcXCJmb250LXNtXFxcIj5cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMubWVldGluZ0RhdGUgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLm1lZXRpbmdEYXRlIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJtZWV0aW5nRGF0ZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCI8L3NwYW4+XFxuICAgICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJpY29uLWNvbnRlbnQgaGlkZSBqaWYtYmx1ZSB0ZXh0LWNlbnRlciBpY29uLWJveFxcXCI+XFxuICAgICAgICAgICAgICAgICAgPGkgY2xhc3M9XFxcImppZi1jaGVja2luXFxcIj48L2k+XFxuICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiZm9udC04XFxcIj5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImNoZWNraW5cIix7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCI8L2Rpdj5cXG4gICAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtZGV0YWlsIGljb24tc2VwXFxcIj5cXG4gICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwidGV4dC1jb250ZW50XFxcIiB0aXRsZT1cXFwiXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmxvY2F0aW9uIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5sb2NhdGlvbiA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwibG9jYXRpb25cIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIj5cXG4gICAgICAgICAgICAgICAgICBcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMubG9jYXRpb24gfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmxvY2F0aW9uIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJsb2NhdGlvblwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXG4gICAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImljb24tY29udGVudCBoaWRlIGppZi1ibHVlIHRleHQtY2VudGVyIGljb24tYm94XFxcIj5cXG4gICAgICAgICAgICAgICAgICA8aSBjbGFzcz1cXFwiamlmLWxvY2F0aW9uXFxcIj48L2k+XFxuICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiZm9udC04XFxcIj5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImxvY2F0aW9uXCIse1wibmFtZVwiOlwidFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1kZXRhaWwgY291bnQgaGlkZGVuLXhzIGhpZGRlbi1zbVxcXCI+XFxuICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJpdGVtLXNlY3Rpb24gYXR0ZWRlZS1jb3VudHNcXFwiPlxcbiAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJzZWN0aW9uLWNvdW50IGFjY2VwdGVkXFxcIj5cXG4gICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjb3VudFxcXCI+XCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmFjY2VwdGVkQ291bnQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmFjY2VwdGVkQ291bnQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImFjY2VwdGVkQ291bnRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwic3RhdHVzXFxcIj5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImFjY2VwdGVkXCIse1wibmFtZVwiOlwidFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJzZWN0aW9uLWNvdW50IGRlY2xpbmVkXFxcIj5cXG4gICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjb3VudFxcXCI+XCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmRlY2xpbmVkQ291bnQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmRlY2xpbmVkQ291bnQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImRlY2xpbmVkQ291bnRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwic3RhdHVzXFxcIj5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImRlY2xpbmVkXCIse1wibmFtZVwiOlwidFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJzZWN0aW9uLWNvdW50IHBlbmRpbmdcXFwiPlxcbiAgICAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImNvdW50XFxcIj5cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMucGVuZGluZ0NvdW50IHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5wZW5kaW5nQ291bnQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcInBlbmRpbmdDb3VudFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCI8L2Rpdj5cXG4gICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJzdGF0dXNcXFwiPlwiXG4gICAgKyBhbGlhczQoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMxLFwicGVuZGluZ1wiLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIjwvZGl2PlxcbiAgICAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgIDwvZGl2PlxcbiAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1mb290ZXJcXFwiPlxcbiAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1mb290ZXItY29udGVudFxcXCI+XFxuICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwidG9nZ2xlLXN3aXRjaFxcXCI+XFxuICAgICAgICAgICAgICA8aW5wdXQgdHlwZT1cXFwiY2hlY2tib3hcXFwiIFwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnNbXCJpZlwiXS5jYWxsKGFsaWFzMSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuY2hlY2tlZEluIDogZGVwdGgwKSx7XCJuYW1lXCI6XCJpZlwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSg2LCBkYXRhLCAwLCBibG9ja1BhcmFtcywgZGVwdGhzKSxcImludmVyc2VcIjpjb250YWluZXIubm9vcCxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKVxuICAgICsgXCIgY2xhc3M9XFxcImNoZWNraW5fbWVldGluZ1xcXCIgaWQ9XFxcImNoZWNraW5fbWVldGluZ19cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMudXVpZCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAudXVpZCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwidXVpZFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiIC8+XFxuICAgICAgICAgICAgICA8bGFiZWwgZm9yPVxcXCJjaGVja2luX21lZXRpbmdfXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnV1aWQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnV1aWQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcInV1aWRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIj48L2xhYmVsPlxcbiAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgIDxkaXY+XCJcbiAgICArIGFsaWFzNChfX2RlZmF1bHQocmVxdWlyZShcIi4uL2hlbHBlcnMvdC5qc1wiKSkuY2FsbChhbGlhczEsXCJjaGVja2luXCIse1wibmFtZVwiOlwidFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgIDwvZGl2PlxcbiAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1saXN0LWNvbnRlbnRcXFwiPlxcbiAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjaGVja2luLWF0dGVkbmRlZS1saXN0XFxcIj5cXG4gICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJyb3dcXFwiPlxcbiAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiY29sLW1kLTYgY29sLXNtLTZcXFwiPlxcbiAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJpbnRlcm5hbC1hdHRlbmRlZVxcXCI+XFxuICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwibGlzdC10aXRsZVxcXCI+XCJcbiAgICArIGFsaWFzNChfX2RlZmF1bHQocmVxdWlyZShcIi4uL2hlbHBlcnMvdC5qc1wiKSkuY2FsbChhbGlhczEsXCJpbnRlcm5hbF9wYXJ0aWNpcGFudHNcIix7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCI8L2Rpdj5cXG4gICAgICAgICAgICAgICAgICA8ZGl2PlxcblwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnMuZWFjaC5jYWxsKGFsaWFzMSwoKHN0YWNrMSA9IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51c2VycyA6IGRlcHRoMCkpICE9IG51bGwgPyBzdGFjazEuaW50ZXJuYWwgOiBzdGFjazEpLHtcIm5hbWVcIjpcImVhY2hcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oOCwgZGF0YSwgMCwgYmxvY2tQYXJhbXMsIGRlcHRocyksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiICAgICAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjb2wtbWQtNiBjb2wtc20tNlxcXCI+XFxuICAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImV4dGVybmFsLWF0dGVuZGVlXFxcIj5cXG4gICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJsaXN0LXRpdGxlXFxcIj5cIlxuICAgICsgYWxpYXM0KF9fZGVmYXVsdChyZXF1aXJlKFwiLi4vaGVscGVycy90LmpzXCIpKS5jYWxsKGFsaWFzMSxcImV4dGVybmFsX3BhcnRpY2lwYW50c1wiLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIjwvZGl2PlxcbiAgICAgICAgICAgICAgICAgIDxkaXY+XFxuXCJcbiAgICArICgoc3RhY2sxID0gaGVscGVycy5lYWNoLmNhbGwoYWxpYXMxLCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnVzZXJzIDogZGVwdGgwKSkgIT0gbnVsbCA/IHN0YWNrMS5leHRlcm5hbCA6IHN0YWNrMSkse1wibmFtZVwiOlwiZWFjaFwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSgxMCwgZGF0YSwgMCwgYmxvY2tQYXJhbXMsIGRlcHRocyksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiICAgICAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgPC9kaXY+XFxuICAgICAgPC9kaXY+XFxuXCI7XG59LFwiMlwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIGhlbHBlcjtcblxuICByZXR1cm4gXCIgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImZvbnQtbGdcXFwiPlwiXG4gICAgKyBjb250YWluZXIuZXNjYXBlRXhwcmVzc2lvbigoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLm1lZXRpbmdfd2l0aCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAubWVldGluZ193aXRoIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGhlbHBlcnMuaGVscGVyTWlzc2luZyksKHR5cGVvZiBoZWxwZXIgPT09IFwiZnVuY3Rpb25cIiA/IGhlbHBlci5jYWxsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwIDogKGNvbnRhaW5lci5udWxsQ29udGV4dCB8fCB7fSkse1wibmFtZVwiOlwibWVldGluZ193aXRoXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIjwvZGl2PlxcblwiO1xufSxcIjRcIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSkge1xuICAgIHZhciBoZWxwZXI7XG5cbiAgcmV0dXJuIFwiICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJmb250LWxnXFxcIj5cIlxuICAgICsgY29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb24oKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy50b3BpY05hbWUgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnRvcGljTmFtZSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBoZWxwZXJzLmhlbHBlck1pc3NpbmcpLCh0eXBlb2YgaGVscGVyID09PSBcImZ1bmN0aW9uXCIgPyBoZWxwZXIuY2FsbChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLHtcIm5hbWVcIjpcInRvcGljTmFtZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCI8L2Rpdj5cXG5cIjtcbn0sXCI2XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEpIHtcbiAgICByZXR1cm4gXCIgY2hlY2tlZCBcIjtcbn0sXCI4XCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEsYmxvY2tQYXJhbXMsZGVwdGhzKSB7XG4gICAgdmFyIHN0YWNrMSwgaGVscGVyLCBhbGlhczE9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwgYWxpYXMyPWhlbHBlcnMuaGVscGVyTWlzc2luZywgYWxpYXMzPVwiZnVuY3Rpb25cIiwgYWxpYXM0PWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uLCBhbGlhczU9Y29udGFpbmVyLmxhbWJkYTtcblxuICByZXR1cm4gXCIgICAgICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiYXR0ZW5kZWUtaXRlbSBjaGVja2luIFwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5pbnZpdGVfc3RhdHVzIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5pbnZpdGVfc3RhdHVzIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJpbnZpdGVfc3RhdHVzXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCI+XFxuICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiYXR0ZW5kZWUtcGljXFxcIj5cXG4gICAgICAgICAgICAgICAgICAgICAgICAgIDxpIGNsYXNzPVxcXCJqaWYtcGVvcGxlIGppZi1saWdodC1ncmV5IGppZi0xOFxcXCI+PC9pPlxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgPHNwYW4gY2xhc3M9XFxcImljb24tdXNlci1cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuaW52aXRlX3N0YXR1cyB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuaW52aXRlX3N0YXR1cyA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiaW52aXRlX3N0YXR1c1wiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCIgdXNlci1zdGF0dXMgXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmludml0ZV9zdGF0dXMgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmludml0ZV9zdGF0dXMgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImludml0ZV9zdGF0dXNcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIj48L3NwYW4+XFxuICAgICAgICAgICAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiYXR0ZW5kZWUtZGV0YWlsc1xcXCI+XFxuICAgICAgICAgICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJhdHRlbmRlZS1uYW1lXFxcIj5cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuZmlyc3RfbmFtZSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuZmlyc3RfbmFtZSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiZmlyc3RfbmFtZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCIgXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmxhc3RfbmFtZSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAubGFzdF9uYW1lIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJsYXN0X25hbWVcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJhdHRlbmRlZS1kZXNuXFxcIj5cXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgPHNwYW4+XCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnRpdGxlIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC50aXRsZSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwidGl0bGVcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiLCA8L3NwYW4+XFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxzcGFuPlwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5jb21wYW55X25hbWUgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmNvbXBhbnlfbmFtZSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiY29tcGFueV9uYW1lXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIjwvc3Bhbj5cXG4gICAgICAgICAgICAgICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImFjdGlvblxcXCI+XFxuICAgICAgICAgICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJ0b2dnbGUtc3dpdGNoXFxcIj5cXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgPGlucHV0IHR5cGU9XFxcImNoZWNrYm94XFxcIiBcIlxuICAgICsgKChzdGFjazEgPSBoZWxwZXJzW1wiaWZcIl0uY2FsbChhbGlhczEsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmNoZWNrZWRJbiA6IGRlcHRoMCkse1wibmFtZVwiOlwiaWZcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oNiwgZGF0YSwgMCwgYmxvY2tQYXJhbXMsIGRlcHRocyksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiIGNsYXNzPVxcXCJjaGVja2luX3VzZXJcXFwiIGRhdGEtYXR0ZW5kZWVfdHlwZT1cXFwiaW50ZXJuYWxcXFwiIGRhdGEtdXVpZD1cXFwiXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnV1aWQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnV1aWQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcInV1aWRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBpZD1cXFwiXCJcbiAgICArIGFsaWFzNChhbGlhczUoKGRlcHRoc1sxXSAhPSBudWxsID8gZGVwdGhzWzFdLnV1aWQgOiBkZXB0aHNbMV0pLCBkZXB0aDApKVxuICAgICsgXCJfXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnV1aWQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnV1aWQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcInV1aWRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiAvPlxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8bGFiZWwgZm9yPVxcXCJcIlxuICAgICsgYWxpYXM0KGFsaWFzNSgoZGVwdGhzWzFdICE9IG51bGwgPyBkZXB0aHNbMV0udXVpZCA6IGRlcHRoc1sxXSksIGRlcHRoMCkpXG4gICAgKyBcIl9cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMudXVpZCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAudXVpZCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwidXVpZFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiPjwvbGFiZWw+XFxuICAgICAgICAgICAgICAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICAgICAgICAgICAgPC9kaXY+XFxuXCI7XG59LFwiMTBcIjpmdW5jdGlvbihjb250YWluZXIsZGVwdGgwLGhlbHBlcnMscGFydGlhbHMsZGF0YSxibG9ja1BhcmFtcyxkZXB0aHMpIHtcbiAgICB2YXIgc3RhY2sxLCBoZWxwZXIsIGFsaWFzMT1kZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLCBhbGlhczI9aGVscGVycy5oZWxwZXJNaXNzaW5nLCBhbGlhczM9XCJmdW5jdGlvblwiLCBhbGlhczQ9Y29udGFpbmVyLmVzY2FwZUV4cHJlc3Npb24sIGFsaWFzNT1jb250YWluZXIubGFtYmRhO1xuXG4gIHJldHVybiBcIiAgICAgICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJhdHRlbmRlZS1pdGVtIGNoZWNraW4gXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmludml0ZV9zdGF0dXMgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmludml0ZV9zdGF0dXMgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImludml0ZV9zdGF0dXNcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIj5cXG4gICAgICAgICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJhdHRlbmRlZS1waWNcXFwiPlxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgPGkgY2xhc3M9XFxcImppZi1wZW9wbGUgamlmLWxpZ2h0LWdyZXkgamlmLTE4XFxcIj48L2k+XFxuICAgICAgICAgICAgICAgICAgICAgICAgICA8c3BhbiBjbGFzcz1cXFwiaWNvbi11c2VyLVwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5pbnZpdGVfc3RhdHVzIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5pbnZpdGVfc3RhdHVzIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJpbnZpdGVfc3RhdHVzXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIiB1c2VyLXN0YXR1cyBcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMuaW52aXRlX3N0YXR1cyB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuaW52aXRlX3N0YXR1cyA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiaW52aXRlX3N0YXR1c1wiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiPjwvc3Bhbj5cXG4gICAgICAgICAgICAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJhdHRlbmRlZS1kZXRhaWxzXFxcIj5cXG4gICAgICAgICAgICAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImF0dGVuZGVlLW5hbWVcXFwiPlwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5maXJzdF9uYW1lIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5maXJzdF9uYW1lIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJmaXJzdF9uYW1lXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIiBcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMubGFzdF9uYW1lIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5sYXN0X25hbWUgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcImxhc3RfbmFtZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCI8L2Rpdj5cXG4gICAgICAgICAgICAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImF0dGVuZGVlLWRlc25cXFwiPlxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8c3Bhbj5cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMudGl0bGUgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnRpdGxlIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ0aXRsZVwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCIsIDwvc3Bhbj5cXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgPHNwYW4+XCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmNvbXBhbnlfbmFtZSB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuY29tcGFueV9uYW1lIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJjb21wYW55X25hbWVcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9zcGFuPlxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiYWN0aW9uXFxcIj5cXG4gICAgICAgICAgICAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcInRvZ2dsZS1zd2l0Y2hcXFwiPlxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8aW5wdXQgdHlwZT1cXFwiY2hlY2tib3hcXFwiIFwiXG4gICAgKyAoKHN0YWNrMSA9IGhlbHBlcnNbXCJpZlwiXS5jYWxsKGFsaWFzMSwoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuY2hlY2tlZEluIDogZGVwdGgwKSx7XCJuYW1lXCI6XCJpZlwiLFwiaGFzaFwiOnt9LFwiZm5cIjpjb250YWluZXIucHJvZ3JhbSg2LCBkYXRhLCAwLCBibG9ja1BhcmFtcywgZGVwdGhzKSxcImludmVyc2VcIjpjb250YWluZXIubm9vcCxcImRhdGFcIjpkYXRhfSkpICE9IG51bGwgPyBzdGFjazEgOiBcIlwiKVxuICAgICsgXCIgZGF0YS1hdHRlbmRlZV90eXBlPVxcXCJleHRlcm5hbFxcXCIgY2xhc3M9XFxcImNoZWNraW5fdXNlclxcXCIgZGF0YS11dWlkPVxcXCJcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMudXVpZCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAudXVpZCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwidXVpZFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiIGlkPVxcXCJcIlxuICAgICsgYWxpYXM0KGFsaWFzNSgoZGVwdGhzWzFdICE9IG51bGwgPyBkZXB0aHNbMV0udXVpZCA6IGRlcHRoc1sxXSksIGRlcHRoMCkpXG4gICAgKyBcIl9cIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMudXVpZCB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAudXVpZCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwidXVpZFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCJcXFwiIC8+XFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxsYWJlbCBmb3I9XFxcIlwiXG4gICAgKyBhbGlhczQoYWxpYXM1KChkZXB0aHNbMV0gIT0gbnVsbCA/IGRlcHRoc1sxXS51dWlkIDogZGVwdGhzWzFdKSwgZGVwdGgwKSlcbiAgICArIFwiX1wiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCI+PC9sYWJlbD5cXG4gICAgICAgICAgICAgICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgICAgICAgICAgICA8L2Rpdj5cXG5cIjtcbn0sXCJjb21waWxlclwiOls3LFwiPj0gNC4wLjBcIl0sXCJtYWluXCI6ZnVuY3Rpb24oY29udGFpbmVyLGRlcHRoMCxoZWxwZXJzLHBhcnRpYWxzLGRhdGEsYmxvY2tQYXJhbXMsZGVwdGhzKSB7XG4gICAgdmFyIHN0YWNrMTtcblxuICByZXR1cm4gXCI8ZGl2IGNsYXNzPVxcXCJjYXJkLWNvbnRhaW5lciBjaGVja2luLWxpc3QgbWVldGluZy1saXN0IFwiXG4gICAgKyBjb250YWluZXIuZXNjYXBlRXhwcmVzc2lvbihjb250YWluZXIubGFtYmRhKCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnRvZ2dsZV9zdGF0ZSA6IGRlcHRoMCkpICE9IG51bGwgPyBzdGFjazEudmlld1N0eWxlIDogc3RhY2sxKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIj5cXG5cIlxuICAgICsgKChzdGFjazEgPSBoZWxwZXJzLmVhY2guY2FsbChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMCA6IChjb250YWluZXIubnVsbENvbnRleHQgfHwge30pLChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5tZWV0aW5nX2xpc3QgOiBkZXB0aDApLHtcIm5hbWVcIjpcImVhY2hcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMSwgZGF0YSwgMCwgYmxvY2tQYXJhbXMsIGRlcHRocyksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiPC9kaXY+XFxuXCI7XG59LFwidXNlRGF0YVwiOnRydWUsXCJ1c2VEZXB0aHNcIjp0cnVlfSk7IiwidmFyIEhhbmRsZWJhcnMgPSByZXF1aXJlKFwiLi4vLi4vbm9kZV9tb2R1bGVzL2hhbmRsZWJhcnMvcnVudGltZS5qc1wiKTtcbmZ1bmN0aW9uIF9fZGVmYXVsdChvYmopIHsgcmV0dXJuIG9iaiAmJiAob2JqLl9fZXNNb2R1bGUgPyBvYmpbXCJkZWZhdWx0XCJdIDogb2JqKTsgfVxubW9kdWxlLmV4cG9ydHMgPSAoSGFuZGxlYmFyc1tcImRlZmF1bHRcIl0gfHwgSGFuZGxlYmFycykudGVtcGxhdGUoe1wiMVwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMSwgaGVscGVyLCBhbGlhczE9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KSwgYWxpYXMyPWhlbHBlcnMuaGVscGVyTWlzc2luZywgYWxpYXMzPVwiZnVuY3Rpb25cIiwgYWxpYXM0PWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uLCBhbGlhczU9Y29udGFpbmVyLmxhbWJkYTtcblxuICByZXR1cm4gXCIgICAgPGRpdiBjbGFzcz1cXFwiY2FyZCBtZWV0aW5nLWNhcmQgXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnN0YXR1cyB8fCAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuc3RhdHVzIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJzdGF0dXNcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIiBkYXRhLXV1aWQ9J1wiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIicgaWQ9XFxcIlwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCI+XFxuICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1oZWFkZXJcXFwiPlxcbiAgICAgICAgPGRpdiBjbGFzcz1cXFwiY2FyZC1oZWFkZXItY29udGVudFxcXCI+XFxuICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtc2VsZWN0XFxcIj5cXG4gICAgICAgICAgICA8aW5wdXQgdHlwZT1cXFwiY2hlY2tib3hcXFwiIG5hbWU9XFxcIm1lZXRpbmdDYXJkXFxcIiBkYXRhLXV1aWQ9J1wiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIicgaWQ9XFxcIm1lZXRpbmdDYXJkX1wiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIlxcXCI+XFxuICAgICAgICAgICAgPGxhYmVsIGZvcj1cXFwibWVldGluZ0NhcmRfXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnV1aWQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnV1aWQgOiBkZXB0aDApKSAhPSBudWxsID8gaGVscGVyIDogYWxpYXMyKSwodHlwZW9mIGhlbHBlciA9PT0gYWxpYXMzID8gaGVscGVyLmNhbGwoYWxpYXMxLHtcIm5hbWVcIjpcInV1aWRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiXFxcIj5cXG4gICAgICAgICAgICAgIDxkaXY+UzwvZGl2PlxcbiAgICAgICAgICAgIDwvbGFiZWw+XFxuICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWNsaWNrIG1lZXRpbmdSZXZlYWxDbHNcXFwiIGlkPVxcXCJzZXNzaW9uX2NsaWNrXFxcIiBkYXRhLXV1aWQ9J1wiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIic+XFxuICAgICAgICAgICAgPGEgaHJlZj1cXFwiamF2YXNjcmlwdDp2b2lkKDApXFxcIj5cXG4gICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImZvbnQtbGcgbWVldGluZy10aXRsZVxcXCIgdGl0bGU9XFxcIlwiXG4gICAgKyBhbGlhczQoYWxpYXM1KCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnRvcGljIDogZGVwdGgwKSkgIT0gbnVsbCA/IHN0YWNrMS5uYW1lIDogc3RhY2sxKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIj5cIlxuICAgICsgYWxpYXM0KGFsaWFzNSgoKHN0YWNrMSA9IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC50b3BpYyA6IGRlcHRoMCkpICE9IG51bGwgPyBzdGFjazEubmFtZSA6IHN0YWNrMSksIGRlcHRoMCkpXG4gICAgKyBcIjwvZGl2PlxcbiAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiZm9udC1sZ1xcXCI+XCJcbiAgICArIGFsaWFzNChfX2RlZmF1bHQocmVxdWlyZShcIi4uL2hlbHBlcnMvdC5qc1wiKSkuY2FsbChhbGlhczEsXCJJRFwiLHtcIm5hbWVcIjpcInRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkpXG4gICAgKyBcIiAjXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5pZCA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiaWRcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgPC9hPlxcbiAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgIDwvZGl2PlxcbiAgICAgIDwvZGl2PlxcbiAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtY29udGVudCBtZWV0aW5nUmV2ZWFsQ2xzXFxcIiBkYXRhLXV1aWQ9J1wiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy51dWlkIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC51dWlkIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJ1dWlkXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIic+XFxuICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWRldGFpbC1jb250ZW50XFxcIj5cXG4gICAgICAgICAgPGRpdj5cXG4gICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWRldGFpbFxcXCI+XFxuICAgICAgICAgICAgICA8c3BhbiBjbGFzcz1cXFwiZm9udC1zZW1pLWJvbGRcXFwiPlwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5zdGFydFRpbWUgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnN0YXJ0VGltZSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwic3RhcnRUaW1lXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIiAtIFwiXG4gICAgKyBhbGlhczQoKChoZWxwZXIgPSAoaGVscGVyID0gaGVscGVycy5lbmRUaW1lIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5lbmRUaW1lIDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJlbmRUaW1lXCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pIDogaGVscGVyKSkpXG4gICAgKyBcIjwvc3Bhbj5cXG4gICAgICAgICAgICA8c3BhbiBjbGFzcz1cXFwiZm9udC1zbVxcXCI+XCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLnNlc3Npb25EYXRlIHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5zZXNzaW9uRGF0ZSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwic2Vzc2lvbkRhdGVcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9zcGFuPlxcbiAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImNhcmQtZGV0YWlsIGljb24tc2VwXFxcIj5cXG4gICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcInRleHQtY29udGVudCBsb2NhdGlvbi10ZXh0IHR3by1saW5lLWVsbGlwc2lzXFxcIj5cXG4gICAgICAgICAgICAgICAgXCJcbiAgICArIGFsaWFzNChhbGlhczUoKChzdGFjazEgPSAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAucm9vbSA6IGRlcHRoMCkpICE9IG51bGwgPyBzdGFjazEubmFtZSA6IHN0YWNrMSksIGRlcHRoMCkpXG4gICAgKyBcIlxcbiAgICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgICAgPC9kaXY+XFxuICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWRldGFpbCBjb3VudFxcXCI+XFxuICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiaXRlbS1zZWN0aW9uIGF0dGVkZWUtY291bnRzXFxcIj5cXG4gICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwic2VjdGlvbi1jb3VudCBhY2NlcHRlZFxcXCI+XFxuICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiY291bnRcXFwiPlwiXG4gICAgKyBhbGlhczQoYWxpYXM1KCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmludml0ZWVzX3N0YXR1c19jb3VudHMgOiBkZXB0aDApKSAhPSBudWxsID8gc3RhY2sxLmFjY2VwdGVkIDogc3RhY2sxKSwgZGVwdGgwKSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwic3RhdHVzXFxcIj5BY2NlcHRlZDwvZGl2PlxcbiAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwic2VjdGlvbi1jb3VudCBkZWNsaW5lZFxcXCI+XFxuICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiY291bnRcXFwiPlwiXG4gICAgKyBhbGlhczQoYWxpYXM1KCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLmludml0ZWVzX3N0YXR1c19jb3VudHMgOiBkZXB0aDApKSAhPSBudWxsID8gc3RhY2sxLmRlY2xpbmVkIDogc3RhY2sxKSwgZGVwdGgwKSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwic3RhdHVzXFxcIj5EZWNsaW5lZDwvZGl2PlxcbiAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwic2VjdGlvbi1jb3VudCBwZW5kaW5nXFxcIj5cXG4gICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjb3VudFxcXCI+XCJcbiAgICArIGFsaWFzNChhbGlhczUoKChzdGFjazEgPSAoZGVwdGgwICE9IG51bGwgPyBkZXB0aDAuaW52aXRlZXNfc3RhdHVzX2NvdW50cyA6IGRlcHRoMCkpICE9IG51bGwgPyBzdGFjazEucGVuZGluZyA6IHN0YWNrMSksIGRlcHRoMCkpXG4gICAgKyBcIjwvZGl2PlxcbiAgICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcInN0YXR1c1xcXCI+UGVuZGluZzwvZGl2PlxcbiAgICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgPC9kaXY+XFxuICAgICAgICA8L2Rpdj5cXG4gICAgICA8L2Rpdj5cXG4gICAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWZvb3RlclxcXCI+XFxuICAgICAgICA8ZGl2IGNsYXNzPVxcXCJjYXJkLWZvb3Rlci1jb250ZW50IHBhZGRpbmctbGVmdC0xMFxcXCI+XFxuICAgICAgICAgIDxkaXY+U2VhdHMgUmVtYWluaW5nOiBcIlxuICAgICsgYWxpYXM0KCgoaGVscGVyID0gKGhlbHBlciA9IGhlbHBlcnMucmVtYWluaW5nQ291bnQgfHwgKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnJlbWFpbmluZ0NvdW50IDogZGVwdGgwKSkgIT0gbnVsbCA/IGhlbHBlciA6IGFsaWFzMiksKHR5cGVvZiBoZWxwZXIgPT09IGFsaWFzMyA/IGhlbHBlci5jYWxsKGFsaWFzMSx7XCJuYW1lXCI6XCJyZW1haW5pbmdDb3VudFwiLFwiaGFzaFwiOnt9LFwiZGF0YVwiOmRhdGF9KSA6IGhlbHBlcikpKVxuICAgICsgXCIvXCJcbiAgICArIGFsaWFzNCgoKGhlbHBlciA9IChoZWxwZXIgPSBoZWxwZXJzLmNhcGFjaXR5IHx8IChkZXB0aDAgIT0gbnVsbCA/IGRlcHRoMC5jYXBhY2l0eSA6IGRlcHRoMCkpICE9IG51bGwgPyBoZWxwZXIgOiBhbGlhczIpLCh0eXBlb2YgaGVscGVyID09PSBhbGlhczMgPyBoZWxwZXIuY2FsbChhbGlhczEse1wibmFtZVwiOlwiY2FwYWNpdHlcIixcImhhc2hcIjp7fSxcImRhdGFcIjpkYXRhfSkgOiBoZWxwZXIpKSlcbiAgICArIFwiPC9kaXY+XFxuICAgICAgICA8L2Rpdj5cXG4gICAgICA8L2Rpdj5cXG4gICAgPC9kaXY+XFxuXCI7XG59LFwiY29tcGlsZXJcIjpbNyxcIj49IDQuMC4wXCJdLFwibWFpblwiOmZ1bmN0aW9uKGNvbnRhaW5lcixkZXB0aDAsaGVscGVycyxwYXJ0aWFscyxkYXRhKSB7XG4gICAgdmFyIHN0YWNrMSwgYWxpYXMxPWNvbnRhaW5lci5lc2NhcGVFeHByZXNzaW9uLCBhbGlhczI9ZGVwdGgwICE9IG51bGwgPyBkZXB0aDAgOiAoY29udGFpbmVyLm51bGxDb250ZXh0IHx8IHt9KTtcblxuICByZXR1cm4gXCI8ZGl2IGNsYXNzPVxcXCJjYXJkLWNvbnRhaW5lciBtZWV0aW5nLWxpc3QgXCJcbiAgICArIGFsaWFzMShjb250YWluZXIubGFtYmRhKCgoc3RhY2sxID0gKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnRvZ2dsZV9zdGF0ZSA6IGRlcHRoMCkpICE9IG51bGwgPyBzdGFjazEudmlld1N0eWxlIDogc3RhY2sxKSwgZGVwdGgwKSlcbiAgICArIFwiXFxcIj5cXG5cIlxuICAgICsgKChzdGFjazEgPSBoZWxwZXJzLmVhY2guY2FsbChhbGlhczIsKGRlcHRoMCAhPSBudWxsID8gZGVwdGgwLnNlc3Npb25zX2xpc3QgOiBkZXB0aDApLHtcIm5hbWVcIjpcImVhY2hcIixcImhhc2hcIjp7fSxcImZuXCI6Y29udGFpbmVyLnByb2dyYW0oMSwgZGF0YSwgMCksXCJpbnZlcnNlXCI6Y29udGFpbmVyLm5vb3AsXCJkYXRhXCI6ZGF0YX0pKSAhPSBudWxsID8gc3RhY2sxIDogXCJcIilcbiAgICArIFwiPC9kaXY+XFxuXFxuXFxuPCEtLSBNb2RhbCAtLT5cXG48ZGl2IGNsYXNzPVxcXCJtb2RhbCBtb2RhbC1qaWZmbGUgbW9kYWwtbGlzdCBldmVudC1saXN0LW1vZGFsIGJsdWUgZmFkZVxcXCIgaWQ9XFxcImdyb3VwLW5vbWluYXRvaW4tbGlzdFxcXCIgdGFiaW5kZXg9XFxcIi0xXFxcIiByb2xlPVxcXCJkaWFsb2dcXFwiIGFyaWEtbGFiZWxsZWRieT1cXFwibXlNb2RhbExhYmVsXFxcIj5cXG4gIDxkaXYgY2xhc3M9XFxcIm1vZGFsLWRpYWxvZ1xcXCIgcm9sZT1cXFwiZG9jdW1lbnRcXFwiPlxcbiAgICA8ZGl2IGNsYXNzPVxcXCJtb2RhbC1jb250ZW50XFxcIj5cXG4gICAgICA8ZGl2IGNsYXNzPVxcXCJtb2RhbC1oZWFkZXJcXFwiPlxcbiAgICAgICAgPGJ1dHRvbiB0eXBlPVxcXCJidXR0b25cXFwiIGNsYXNzPVxcXCJjbG9zZSBoaWRkZW4tbGcgaGlkZGVuLW1kIGhpZGRlbi1zbVxcXCIgZGF0YS1kaXNtaXNzPVxcXCJtb2RhbFxcXCIgYXJpYS1sYWJlbD1cXFwiQ2xvc2VcXFwiPjxzcGFuIGFyaWEtaGlkZGVuPVxcXCJ0cnVlXFxcIj4mdGltZXM7PC9zcGFuPjwvYnV0dG9uPlxcbiAgICAgICAgPGg0IGNsYXNzPVxcXCJtb2RhbC10aXRsZVxcXCIgaWQ9XFxcIm15TW9kYWxMYWJlbFxcXCIgZGF0YS1pMThuPVxcXCJcXFwiPlwiXG4gICAgKyBhbGlhczEoX19kZWZhdWx0KHJlcXVpcmUoXCIuLi9oZWxwZXJzL3QuanNcIikpLmNhbGwoYWxpYXMyLFwibm9taW5hdGlvbl9oZWFkZXJcIix7XCJuYW1lXCI6XCJ0XCIsXCJoYXNoXCI6e30sXCJkYXRhXCI6ZGF0YX0pKVxuICAgICsgXCI8L2g0PlxcbiAgICAgIDwvZGl2PlxcbiAgICAgIDxkaXYgY2xhc3M9XFxcIm1vZGFsLWJvZHlcXFwiPlxcbiAgICAgICAgPGRpdiBjbGFzcz1cXFwiY29udGFpbmVyLWZsdWlkIG5vLXBhZGRpbmcgZXZlbnQtbGlzdC1jb250ZW50IGNhcmQtY29udGFpbmVyIGxpc3Qtdmlld1xcXCI+XFxuICAgICAgICAgIDxkaXYgY2xhc3M9XFxcInJvd1xcXCI+XFxuICAgICAgICAgICAgPGRpdiBjbGFzcz1cXFwiY29sLW1kLTEyXFxcIj5cXG4gICAgICAgICAgICAgIDxkaXYgY2xhc3M9XFxcImZvbnQtcmVkXFxcIiBpZD1cXFwiZXJyb3JNc2dcXFwiPjwvZGl2PlxcbiAgICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgICA8L2Rpdj5cXG4gICAgICAgICAgPGRpdiBjbGFzcz1cXFwicm93XFxcIiBpZD1cXFwic2Vzc2lvbi1ub21pbmF0aW9uc1xcXCI+XFxuXFxuICAgICAgICAgIDwvZGl2PlxcbiAgICAgICAgPC9kaXY+XFxuICAgICAgPC9kaXY+XFxuICAgIDwvZGl2PlxcbiAgPC9kaXY+XFxuPC9kaXY+XFxuXCI7XG59LFwidXNlRGF0YVwiOnRydWV9KTsiXSwic291cmNlUm9vdCI6IiJ9