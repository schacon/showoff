$(document).ready(function() {

  window.ToggleView = Spine.Class.create({
    init: function () {

      this.element = $(arguments[0])

      var eventPrefix = arguments[1]

      $.subscribe( eventPrefix + ":show",$.proxy(function() {
        this.show()
      },this));

      $.subscribe( eventPrefix + ":hide",$.proxy(function() {
        this.hide()
      },this));

      $.subscribe( eventPrefix + ":toggle",$.proxy(function() {
        this.toggle()
      },this));

    },
    show: function() {
      this.element.show()
    },
    hide: function() {
      this.element.hide()
    },
    toggle: function() {
      this.element.toggle()
    }
  });

  window.Footer = ToggleView.sub({
    init: function() {
      this.constructor.__super__.init.apply(this, arguments);

      this.progressView = $("#slideInfo")
      $.subscribe("presentation:slide:didChange",$.proxy(this.updateProgress,this));
    },
    progressPercentage: function (slideIndex,slideCount) {
      return Math.ceil(((slideIndex + 1) / slideCount) * 100)
    },
    updateProgress: function(event,slideIndex,slideCount) {
      percent = this.progressPercentage(slideIndex,slideCount);
      this.progressView.text((slideIndex + 1) + '/' + slideCount + '  - ' + percent + '%')
    }
  });

  window.HelpMenu = ToggleView.sub();

  window.PauseScreen = ToggleView.sub();

  window.DebugView = ToggleView.sub({
    log: function(text) {
      this.element.text(text);
    }
  });


  window.Slide = Spine.Class.create({
    index: 0,
    maxSlides: 0,
    init: function() {
      this.htmlContent = arguments[0];
      this.index = arguments[1];
      this.maxSlides = arguments[2];

      this.transition = this.htmlContent.attr('data-transition');
      this.sequence = parseInt(this.htmlContent.attr('data-sequence'));
      this.title = this.htmlContent.attr('data-title');

      if (this.title === undefined) {
        this.title = this.htmlContent.text().trim().split("\n")[0];

        if (this.title.length > 20) {
          this.title = this.title.substr(0,15) + "...";
        }

      }

      this.sections = [];

      if (this.htmlContent.attr('data-sections') != undefined) {
        this.sections = this.htmlContent.attr('data-sections').split(',');
      }

      this.increments = this.htmlContent.find(".incremental > ul > li");
      this.currentIncrement = 0;

      if (this.increments.size() == 0) {
        this.increments = this.htmlContent.find(".incremental pre pre")
        this.codeIncremental = true;
      }

      this.increments.each(function(index, increment) {
        $(increment).css('visibility', 'hidden');
      });

    },
    currentIncrement: 0,
    increment: function(incrementIndex) {
      var increment = this.increments.eq(incrementIndex);

      if (this.codeIncremental && increment.hasClass('command')) {

        var typeInputOverDuration = increment.find('.input').text().length / 24;

        increment.find('.prompt').css('visibility', 'visible');
        increment.find('.input').css('visibility', 'visible').jTypeWriter({duration:typeInputOverDuration});
      } else {
        increment.css('visibility', 'visible');
      }

    },
    nextIncrement: function() {
      this.increment(this.currentIncrement);
      this.trigger("parade:incr");
      this.currentIncrement ++;
    },
    hasIncrement: function() {
      return (this.currentIncrement < this.increments.size());
    },
    showAllIncrements: function() {
      this.increments.each(function(index, increment) {
        $(increment).css('visibility', 'visible');
      });
      this.currentIncrement = this.increments.size();
    },
    notes: function() {
      return this.htmlContent.find("p.notes").text();
    },
    trigger: function(eventName) {
      var event = jQuery.Event(eventName);
      this.htmlContent.find(".content").trigger(event,this);
      return event;
    }
  });

  window.Slides = Spine.Class.create({
    init: function() {
      this.element = $("#slides");
      this.load(arguments[0],arguments[1]);
      this
    },
    show: function() {
      this.element.show()
    },
    hide: function() {
      this.element.hide()
    },
    load: function(options,afterLoad) {

      var slidesURL = options.urlPrefix + "/slides?height=" + options.height + "&width=" + options.width;

      $("#slides").load(slidesURL,$.proxy(function() {
        this.slides = $("#slides > .slide");
        afterLoad();
      },this));

    },
    size: function() {
      return this.slides.size();
    },
    at: function(index) {
      return new Slide($(this.slides.eq(index)),index,this.size());
    },
    find: function(query) {
      var regexQuery = new RegExp(query,"i");
      var matchedSlideNumbers = [];
      for (var index = 0; index < this.size(); index++) {
        var slide = this.at(index);
        // console.log(slide.title + " " + regexQuery);
        if (regexQuery.exec(slide.title)) { matchedSlideNumbers.push(slide.sequence); }
      }
      console.log("Found: " + matchedSlideNumbers);
      return matchedSlideNumbers;
    },
    findClosestToQuery: function(position,query) {
      console.log('Finding the query `' + query + '` next to position ' + position);
      var matchingSlides = this.find(query);

      var closestPosition = matchingSlides[0];
      console.log('Defaulting to ' + closestPosition);

      for (var mI = 0; mI < matchingSlides.length; mI++) {
        if (matchingSlides[mI] > position) {
          console.log('Setting movement to ' + matchingSlides[mI]);
          closestPosition = matchingSlides[mI];
          break;
        }
      }

      return closestPosition;
    }
  });

  window.NavigationMenu = ToggleView.sub({
    init: function() {
      this.constructor.__super__.init.apply(this,arguments);
      this.menuView = $("#navigation");
    },
    populate: function(slides) {

      var menu = new ListMenu();

      for (var i = 0; i < slides.size(); i++) {
        var slide = slides.at(i);
        var sectionsMinusRoot = slide.sections.slice(1,slide.sections.length);
        sectionsMinusRoot.push(slide.sequence);
        menu.addItem(sectionsMinusRoot, slide.title, slide.sequence);
      }

      this.menuView.html(menu.getList());

      this.element.menu({
        content: this.menuView.html(),
        flyOut: true,
        width: 200
      });

    },
    toggle: function() {
      this.constructor.__super__.toggle.apply(this,arguments);
      this.open();
    },
    show: function() {
      this.constructor.__super__.show.apply(this,arguments);
      this.open();
    },
    open: function() {
      this.element.trigger('click');
    },
    createMenu: function(slide) {
      console.log(this);
      function menu(slide) {
        console.log(this);
      }
    }
  });

  function ListMenu(slide) {
    this.slide = slide
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
      var newMenu = $("<ul>");
      for(var i in this.items) {
        var item = this.items[i];
        var domItem = $("<li>");
        if (item.typeName == 'ListMenu') {
          choice = $("<a rel=\"" + (item.slide - 1) + "\" href=\"#\">" + i + "</a>");
          domItem.append(choice);
          domItem.append(item.getList());
        }
        if (item.typeName == 'ListMenuItem') {
          choice = $("<a rel=\"" + (item.slide - 1) + "\" href=\"#\">" + item.slide + '. ' + item.textName + "</a>");
          domItem.append(choice);
        }
        newMenu.append(domItem);
      }
      return newMenu;
    }

  }

  function ListMenuItem(t, s) {
    this.typeName = "ListMenuItem"
    this.slide = s
    this.textName = t
  }

  window.Presentation = Spine.Class.create({
    slidenum: 0,
    presentationFrame: $("#preso"),

    footer: new Footer("#footer","presentation:footer"),
    helpMenu: new HelpMenu("#help","help"),
    pauseScreen: new PauseScreen("#pauseScreen","presentation:pause"),
    debugView: new DebugView("#debugInfo","debug"),
    navigationMenu: new NavigationMenu("#navmenu","presentation:navigation"),

    init: function() {

      var options = { height: this.presentationFrame.height(),
      width: this.presentationFrame.width(),
      urlPrefix: arguments[0] };

      this.slides = new Slides(options,$.proxy(function() {
        this.start();
      },this));
    },
    start: function() {
      console.log("Initializing Presentation");
      this.slides.show();

      this.centerSlides();

      // Copy the slides into the presentation area
      this.presentationFrame.empty();
      this.slides.slides.appendTo(this.presentationFrame);

      // Create the jquery cycle in the presentation frame
      this.presentationFrame.cycle({
        timeout: 0
      });

      this.navigationMenu.hide();

      this.navigationMenu.populate(this.slides);

      $.subscribe("presentation:slide:location:change",$.proxy(function(event,slideIndex) {
        this.gotoSlide(slideIndex);
      },this));

      this.showFirstSlide();

      this.presentationFrame.trigger("parade:loaded");

      $.subscribe("presentation:slide:next",$.proxy(function() {
        this.nextStep();
      },this));

      $.subscribe("presentation:slide:previous",$.proxy(function() {
        this.prevStep();
      },this));

      $.subscribe("presentation:reload",$.proxy(function() {
        // this.loadSlides(loadSlidesBool, loadSlidesPrefix)
        this.loadSlides()

        // FIXME: currently the reload is making the slides appear lower
        //   then where they are originally.
        this.slidenum = 0
        this.showSlide()
      },this));

    },
    centerSlides: function() {
      var presentation = this;
      this.slides.slides.each(function(s,slide) {
        presentation.centerSlide(slide);
      });
    },
    centerSlide: function(slide) {
      var slideObject = $(slide);
      var slideContent = slideObject.children(".content.vertical-center").first();

      if (slideContent) {
        var height = slideContent.height();
        var marginTop = (0.5 * parseFloat(slideObject.height())) - (0.5 * parseFloat(height));
        if (marginTop < 0) {
          marginTop = 0;
        }
        slideContent.css('margin-top', marginTop);
      }

    },
    showFirstSlide: function() {
      this.slidenum = WindowToSlideLocation.location();
      this.updateSlide();
      this.showSlide()
    },
    gotoSlide: function(slideNum) {
     this.slidenum = parseInt(slideNum)
     if (!isNaN(this.slidenum)) {
       this.showSlide()
     }
    },
    slideTotal: function() {
      return this.slides.size();
    },
    nextSlide: function() {
      this.slidenum ++;
      this.updateSlide();
      this.showSlide();
    },
    previousSlide: function() {
      this.slidenum --;
      this.updateSlide();
      this.currentSlide.transition = "none";
      this.currentSlide.showAllIncrements();
      this.showSlide();
    },
    updateSlide: function() {
      this.currentSlide = this.slides.at(this.slidenum);
    },
    showSlide: function() {

      if(this.slidenum < 0) {
        this.slidenum = 0;
        return;
      }

      var maxSlides = this.slideTotal();

      if(this.slidenum > (maxSlides - 1)) {
        this.slidenum = maxSlides - 1;
        return;
      }

      var currentSlide = this.currentSlide;
      var futureSlide = this.slides.at(this.slidenum);

      var transition = futureSlide.transition;

      // currentSlide.trigger("parade:willDisappear");
      // futureSlide.trigger("parade:willAppear");

      $.publish('code:execution:clear');
      $.publish("presentation:slide:willChange",[ this.slidenum, maxSlides ]);
      this.presentationFrame.cycle(this.slidenum, transition);
      this.currentSlide = futureSlide;
      $.publish("presentation:slide:didChange",[ this.slidenum, maxSlides ]);

      currentSlide.trigger("parade:didDisappear");

      this.presentationFrame.css({'width' : '', 'overflow' : ''});

      WindowToSlideLocation.updateLocation(this.slidenum + 1);

      // futureSlide.trigger("parade:didAppear");
      futureSlide.trigger("parade:show");

      return futureSlide.notes();
    },
    nextStep: function() {

      var triggeredEvent = this.currentSlide.trigger("parade:next");

      if (triggeredEvent.isDefaultPrevented()) {
        return;
      }

      if (this.currentSlide.hasIncrement()) {
        this.currentSlide.nextIncrement();
      } else {
        this.nextSlide();
      }
    },
    prevStep: function() {

     var triggeredEvent = this.currentSlide.trigger("parade:prev");

     if (triggeredEvent.isDefaultPrevented()) {
         return;
     }

     this.previousSlide();
    },
    debug: function(text) {
      this.debugView.log(text);
    }
  });

  window.WindowToSlideLocation = Spine.Class.sub();
  WindowToSlideLocation.location = function() {
    var result;
    if (result = window.location.hash.match(/#([0-9]+)/)) {
      return result[result.length - 1] - 1;
    } else {
      return 0;
    }
  }
  WindowToSlideLocation.updateLocation = function(newLocation) {
    window.location.hash = newLocation;
  }

  window.LocationWatcher =  Spine.Class.create({
    init: function() {
      var presentation = this;
      this.watchEnabled = false;
      this.lastResult = this.windowLocation();

      $.subscribe("presentation:slide:didChange",$.proxy(function(event,slideCount,maxSlides) {
        this.lastResult = slideCount;
      },this));

    },
    start: function() {
      if (this.watchEnabled === false) {
        this.watchEnabled = true;
        this.perform();
      }
    },
    stop: function() {
      this.watchEnabled = false;
    },
    perform: function() {
      var currentResult = this.windowLocation();
      if (this.lastResult != currentResult) {
        $.publish("presentation:slide:location:change",currentResult);
      }

      this.lastResult = currentResult;

      if (this.watchEnabled) {
        setTimeout($.proxy(this.perform,this), 200);
      }
    },
    windowLocation: function() {
      return WindowToSlideLocation.location();
    }
  });


});