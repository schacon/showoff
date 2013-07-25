$(document).ready(function() {

  var publishCommand = function(notificationName) {
    return function(tokens) { $.publish(notificationName); };
  }

  window.TerminalCommands = {
    next : publishCommand('presentation:slide:next'),
    previous : publishCommand('presentation:slide:previous'),
    goto : function(tokens) {

      var gotoSlideNumber = undefined;

      if ( parseInt(tokens[0]) > 0 && parseInt(tokens[0]) < presentation.slideTotal()) {
        gotoSlideNumber = parseInt(tokens[0]) - 1;
      } else if (tokens[0] == 'start') {
        gotoSlideNumber = 0;
      } else if (tokens[0] == 'end') {
        gotoSlideNumber = presentation.slideTotal() - 1;
      } else {
        gotoSlideNumber = presentation.slides.findClosestToQuery(presentation.currentSlide.sequence,tokens[0]) - 1;
      }

      $.publish('presentation:slide:location:change',gotoSlideNumber);
    },
    print: function() {
      window.location.href = "/print"
    }
   };

});