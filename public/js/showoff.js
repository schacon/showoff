/* ShowOff JS Logic */

var ShowOff = {};

var preso_started = false
var slidenum = 0
var slideTotal = 0
var slides
var currentSlide
var totalslides = 0
var slidesLoaded = false
var incrSteps = 0
var incrElem
var incrCurr = 0
var incrCode = false
var debugMode = false
var gotoSlidenum = 0
var shiftKeyActive = false

var loadSlidesBool
var loadSlidesPrefix

function setupPreso(load_slides, prefix) {
	if (preso_started)
	{
		alert("already started")
		return
	}
	preso_started = true

	loadSlidesBool = load_slides
	loadSlidesPrefix = prefix
	loadSlides(loadSlidesBool, loadSlidesPrefix)

	doDebugStuff()

	// bind event handlers
	document.onkeydown = keyDown
	document.onkeyup = keyUp
	/* window.onresize	= resized; */
	/* window.onscroll = scrolled; */
	/* window.onunload = unloaded; */

	$('body').addSwipeEvents().
		bind('tap', swipeLeft).         // next
		bind('swipeleft', swipeLeft).   // next
		bind('swiperight', swipeRight); // prev
}

function loadSlides(load_slides, prefix) {
	//load slides offscreen, wait for images and then initialize
	if (load_slides) {
		$("#slides").load(loadSlidesPrefix + "slides", false, function(){
			$("#slides img").batchImageLoad({
			loadingCompleteCallback: initializePresentation(prefix)
		})
		})
	} else {
	$("#slides img").batchImageLoad({
		loadingCompleteCallback: initializePresentation(prefix)
	})
	}
}

function initializePresentation(prefix) {
	// unhide for height to work in static mode
  $("#slides").show();

	//center slides offscreen
	centerSlides($('#slides > .slide'))

	//copy into presentation area
	$("#preso").empty()
	$('#slides > .slide').appendTo($("#preso"))

	//populate vars
	slides = $('#preso > .slide')
	slideTotal = slides.size()

	//setup manual jquery cycle
	$('#preso').cycle({
		timeout: 0
	})

	setupMenu()
	if (slidesLoaded) {
		showSlide()
	} else {
		showFirstSlide();
		slidesLoaded = true
	}
	setupSlideParamsCheck();
	sh_highlightDocument(prefix+'/js/sh_lang/', '.min.js')
	$("#preso").trigger("showoff:loaded");
}

function centerSlides(slides) {
	slides.each(function(s, slide) {
		centerSlide(slide)
	})
}

function centerSlide(slide) {
	var slide_content = $(slide).children(".content").first()
	var height = slide_content.height()
	var mar_top = (0.5 * parseFloat($(slide).height())) - (0.5 * parseFloat(height))
	if (mar_top < 0) {
		mar_top = 0
	}
	slide_content.css('margin-top', mar_top)
}

function setupMenu() {
	$('#navmenu').hide();

	var currSlide = 0
	var menu = new ListMenu()

	slides.each(function(s, elem) {
		content = $(elem).children(".content")
		shortTxt = $(content).text().substr(0, 20)
		path = $(content).attr('ref').split('/')
		currSlide += 1
		menu.addItem(path, shortTxt, currSlide)
	})

	$('#navigation').html(menu.getList())
	$('#navmenu').menu({
		content: $('#navigation').html(),
		flyOut: true
	});
}

function checkSlideParameter() {
	if (slideParam = currentSlideFromParams()) {
		slidenum = slideParam;
	}
}

function currentSlideFromParams() {
	var result;
	if (result = window.location.hash.match(/#([0-9]+)/)) {
		return result[result.length - 1] - 1;
	}
}

function setupSlideParamsCheck() {
	var check = function() {
		var currentSlide = currentSlideFromParams();
		if (slidenum != currentSlide) {
			slidenum = currentSlide;
			showSlide();
		}
		setTimeout(check, 100);
	}
	setTimeout(check, 100);
}

function gotoSlide(slideNum) {
	slidenum = parseInt(slideNum)
	if (!isNaN(slidenum)) {
		showSlide()
	}
}

function showFirstSlide() {
	slidenum = 0
	checkSlideParameter();
	showSlide()
}

function showSlide(back_step) {

	if(slidenum < 0) {
		slidenum = 0
		return
	}

	if(slidenum > (slideTotal - 1)) {
		slidenum = slideTotal - 1
		return
	}

	currentSlide = slides.eq(slidenum)

	var transition = currentSlide.attr('data-transition')
	var fullPage = currentSlide.find(".content").is('.full-page');

	if (back_step || fullPage) {
		transition = 'none'
	}

	$('#preso').cycle(slidenum, transition)

	if (fullPage) {
		$('#preso').css({'width' : '100%', 'overflow' : 'visible'});
		currentSlide.css({'width' : '100%', 'text-align' : 'center', 'overflow' : 'visible'});
	}

	percent = getSlidePercent()
	$("#slideInfo").text((slidenum + 1) + '/' + slideTotal + '	- ' + percent + '%')

	if(!back_step) {
		// determine if there are incremental bullets to show
		// unless we are moving backward
		determineIncremental()
	} else {
		incrCurr = 0
		incrSteps = 0
	}
	location.hash = slidenum + 1;

	removeResults();

  var currentContent = $(currentSlide).find(".content")
	currentContent.trigger("showoff:show");

	return getCurrentNotes()
}

function getSlideProgress()
{
	return (slidenum + 1) + '/' + slideTotal
}

function getCurrentNotes()
{
  var notes = currentSlide.find("p.notes").text()
  $('#notesInfo').text(notes)
	return notes
}

function getSlidePercent()
{
	return Math.ceil(((slidenum + 1) / slideTotal) * 100)
}

function determineIncremental()
{
	incrCurr = 0
	incrCode = false
	incrElem = currentSlide.find(".incremental > ul > li")
	incrSteps = incrElem.size()
	if(incrSteps == 0) {
		// also look for commandline
		incrElem = currentSlide.find(".incremental > pre > code > code")
		incrSteps = incrElem.size()
		incrCode = true
	}
	incrElem.each(function(s, elem) {
		$(elem).css('visibility', 'hidden');
	})
}

function showIncremental(incr)
{
		elem = incrElem.eq(incrCurr)
		if (incrCode && elem.hasClass('command')) {
			incrElem.eq(incrCurr).css('visibility', 'visible').jTypeWriter({duration:1.0})
		} else {
			incrElem.eq(incrCurr).css('visibility', 'visible')
		}
}

function prevStep()
{

	var event = jQuery.Event("showoff:prev");
	$(currentSlide).find(".content").trigger(event);
	if (event.isDefaultPrevented()) {
			return;
	}

	slidenum--
	return showSlide(true) // We show the slide fully loaded
}

function nextStep()
{
	var event = jQuery.Event("showoff:next");
	$(currentSlide).find(".content").trigger(event);
	if (event.isDefaultPrevented()) {
			return;
	}

	if (incrCurr >= incrSteps) {
		slidenum++
		return showSlide()
	} else {
		showIncremental(incrCurr);
		var incrEvent = jQuery.Event("showoff:incr");
		incrEvent.slidenum = slidenum;
		incrEvent.incr = incrCurr;
		$(currentSlide).find(".content").trigger(incrEvent);
		incrCurr++;
	}
}

function doDebugStuff()
{
	if (debugMode) {
		$('#debugInfo').show()
		debug('debug mode on')
	} else {
		$('#debugInfo').hide()
	}
}

var notesMode = false
function toggleNotes()
{
  notesMode = !notesMode
	if (notesMode) {
		$('#notesInfo').show()
		debug('notes mode on')
	} else {
		$('#notesInfo').hide()
	}
}

function executeAnyCode()
{
  var $jsCode = $('.execute .sh_javascript code:visible')
  if ($jsCode.length > 0) {
      executeCode.call($jsCode);
  }
  var $rubyCode = $('.execute .sh_ruby code:visible')
  if ($rubyCode.length > 0) {
      executeRuby.call($rubyCode);
  }
  var $coffeeCode = $('.execute .sh_coffeescript code:visible')
  if ($coffeeCode.length > 0) {
      executeCoffee.call($coffeeCode);
  } 
}

function debug(data)
{
	$('#debugInfo').text(data)
}

//  See e.g. http://www.quirksmode.org/js/keys.html for keycodes
function keyDown(event)
{
	var key = event.keyCode;

	if (event.ctrlKey || event.altKey || event.metaKey)
		return true;

	debug('keyDown: ' + key)

	if (key >= 48 && key <= 57) // 0 - 9
	{
		gotoSlidenum = gotoSlidenum * 10 + (key - 48);
		return true;
	}

	if (key == 13) {
		if (gotoSlidenum > 0) {
			debug('go to ' + gotoSlidenum);
			slidenum = gotoSlidenum - 1;
			showSlide(true);
			gotoSlidenum = 0;
		} else {
			debug('executeCode');
			executeAnyCode();
		}
	}


	if (key == 16) // shift key
	{
		shiftKeyActive = true;
	}

	if (key == 32) // space bar
	{
		if (shiftKeyActive) {
			prevStep()
		} else {
			nextStep()
		}
	}
	else if (key == 68) // 'd' for debug
	{
		debugMode = !debugMode
		doDebugStuff()
	}
	else if (key == 37 || key == 33 || key == 38) // Left arrow, page up, or up arrow
	{
		prevStep()
	}
	else if (key == 39 || key == 34 || key == 40) // Right arrow, page down, or down arrow
	{
		nextStep()
	}
	else if (key == 82) // R for reload
	{
		if (confirm('really reload slides?')) {
			loadSlides(loadSlidesBool, loadSlidesPrefix)
			showSlide()
		}
	}
	else if (key == 84 || key == 67)  // T or C for table of contents
	{
		$('#navmenu').toggle().trigger('click')
	}
	else if (key == 90 || key == 191) // z or ? for help
	{
		$('#help').toggle()
	}
	else if (key == 66 || key == 70) // f for footer (also "b" which is what kensington remote "stop" button sends
	{
		toggleFooter()
	}
	else if (key == 78) // 'n' for notes
	{
		toggleNotes()
	}
	else if (key == 27) // esc
	{
		removeResults();
	}
	else if (key == 80) // 'p' for preshow
	{
		togglePreShow();
	}
	return true
}

function toggleFooter()
{
	$('#footer').toggle()
}

function keyUp(event) {
	var key = event.keyCode;
	debug('keyUp: ' + key);
	if (key == 16) // shift key
	{
		shiftKeyActive = false;
	}
}

function swipeLeft() {
  nextStep();
}

function swipeRight() {
  prevStep();
}

function ListMenu(s)
{
	this.slide = s
	this.typeName = 'ListMenu'
	this.itemLength = 0;
	this.items = new Array();
	this.addItem = function (key, text, slide) {
		if (key.length > 1) {
			thisKey = key.shift()
			if (!this.items[thisKey]) {
				this.items[thisKey] = new ListMenu(slide)
			}
			this.items[thisKey].addItem(key, text, slide)
		} else {
			thisKey = key.shift()
			this.items[thisKey] = new ListMenuItem(text, slide)
		}
	}
	this.getList = function() {
		var newMenu = $("<ul>")
		for(var i in this.items) {
			var item = this.items[i]
			var domItem = $("<li>")
			if (item.typeName == 'ListMenu') {
				choice = $("<a rel=\"" + (item.slide - 1) + "\" href=\"#\">" + i + "</a>")
				domItem.append(choice)
				domItem.append(item.getList())
			}
			if (item.typeName == 'ListMenuItem') {
				choice = $("<a rel=\"" + (item.slide - 1) + "\" href=\"#\">" + item.slide + '. ' + item.textName + "</a>")
				domItem.append(choice)
			}
			newMenu.append(domItem)
		}
		return newMenu
	}
}

function ListMenuItem(t, s)
{
	this.typeName = "ListMenuItem"
	this.slide = s
	this.textName = t
}

var removeResults = function() {
	$('.results').remove();
};

var print = function(text) {
	removeResults();
	var _results = $('<div>').addClass('results').html($.print(text, {max_string:500}));
	$('body').append(_results);
	_results.click(removeResults);
};

function executeCode () {
	result = null;
	var codeDiv = $(this);
	codeDiv.addClass("executing");
	eval(codeDiv.text());
	setTimeout(function() { codeDiv.removeClass("executing");}, 250 );
	if (result != null) print(result);
}
$('.execute .sh_javascript code').live("click", executeCode);

function executeRuby () {
	var codeDiv = $(this);
	codeDiv.addClass("executing");
    $.get('/eval_ruby', {code: codeDiv.text()}, function(result) {
        if (result != null) print(result);
        codeDiv.removeClass("executing");
    });
}
$('.execute .sh_ruby code').live("click", executeRuby);

function executeCoffee() {
	result = null;
	var codeDiv = $(this);
	codeDiv.addClass("executing");
  // Coffeescript encapsulates everything, so result must be attached to window.
  var code = codeDiv.text() + ';window.result=result;'
	eval(CoffeeScript.compile(code));
	setTimeout(function() { codeDiv.removeClass("executing");}, 250 );
	if (result != null) print(result);
}
$('.execute .sh_coffeescript code').live("click", executeCoffee);

/********************
 PreShow Code
 ********************/

var preshow_seconds = 0;
var preshow_secondsLeft = 0;
var preshow_secondsPer = 8;
var preshow_running = false;
var preshow_timerRunning = false;
var preshow_current = 0;
var preshow_images;
var preshow_imagesTotal = 0;
var preshow_des = null;

function togglePreShow() {
	if(preshow_running) {
		stopPreShow()
	} else {
		var minutes = prompt("Minutes from now to start")
		preshow_secondsLeft = parseFloat(minutes) * 60
		toggleFooter()
		$.getJSON("preshow_files", false, function(data) {
			$('#preso').after("<div id='preshow'></div><div id='tips'></div><div id='preshow_timer'></div>")
			$.each(data, function(i, n) {
				if(n == "preshow.json") {
					// has a descriptions file
					$.getJSON("/file/_preshow/preshow.json", false, function(data) {
						preshow_des = data
					})
				} else {
					$('#preshow').append('<img ref="' + n + '" src="/file/_preshow/' + n + '"/>')
				}
			})
			startPreShow()
		})
	}
}

function startPreShow() {
	if (!preshow_running) {
		preshow_running = true
		preshow_seconds = 0
		preshow_images = $('#preshow > img')
		preshow_imagesTotal = preshow_images.size()
		nextPreShowImage()

		if(!preshow_timerRunning) {
			setInterval(function() {
				preshow_timerRunning = true
				if (!preshow_running) { return }
				preshow_seconds++
				preshow_secondsLeft--
		if (preshow_secondsLeft < 0) {
			stopPreShow()
		}
				if (preshow_seconds == preshow_secondsPer) {
					preshow_seconds = 0
					nextPreShowImage()
				}
		addPreShowTips()
			}, 1000)
		}
	}
}

function addPreShowTips() {
	time = secondsToTime(preshow_secondsLeft)
	$('#preshow_timer').text(time + ' to go-time')
	var des = preshow_des && preshow_des[tmpImg.attr("ref")]
	if(des) {
		$('#tips').show()
		$('#tips').text(des)
	} else {
		$('#tips').hide()
	}
}

function secondsToTime(sec) {
	min = Math.floor(sec / 60)
	sec = sec - (min * 60)
	if(sec < 10) {
		sec = "0" + sec
	}
	return min + ":" + sec
}

function stopPreShow() {
	preshow_running = false

	$('#preshow').remove()
	$('#tips').remove()
	$('#preshow_timer').remove()

	toggleFooter()
	loadSlides(loadSlidesBool, loadSlidesPrefix);
}

function nextPreShowImage() {
	preshow_current += 1
	if((preshow_current + 1) > preshow_imagesTotal) {
		preshow_current = 0
	}

	$("#preso").empty()
	tmpImg = preshow_images.eq(preshow_current).clone()
	$(tmpImg).attr('width', '1020')
	$("#preso").html(tmpImg)
}

/********************
 End PreShow Code
 ********************/
