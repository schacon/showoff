//
// Register all the keyboard inputs for Parade presentation events.
//

$(document).ready(function() {

  KeyboardCreate('MainKeyboard');

  MainKeyboard.on('graveaccent',function(){
    $.publish("console:show");
  });

  MainKeyboard.on('space, right, pagedown, down', function(){
    $.publish("presentation:slide:next");
  });

  MainKeyboard.on('shift + space, left, pageup, up', function(){
    $.publish("presentation:slide:previous");
  });

  MainKeyboard.on('h, ?', function(){
    $.publish("help:toggle");
  });

  MainKeyboard.on('b, f', function(){
    $.publish("presentation:footer:toggle");
  });

  MainKeyboard.on('t, c', function(){
    $.publish("navigation:show");
  });

  MainKeyboard.on('d', function(){
    $.publish("debug:toggle");
  });

  MainKeyboard.on('shift + p', function(){
    $.publish("presentation:pause:toggle");
  });

  MainKeyboard.on('enter', function(){
    $.publish("code:execute:visible")
  });

  MainKeyboard.on('escape', function(){
    $.publish("code:execution:clear");
  });


  KeyboardCreate('ConsoleKeyboard');
  ConsoleKeyboard.disable();

  ConsoleKeyboard.on('graveaccent',function() {
    $.publish("console:hidden");
  });

  $.subscribe("console:show", function() {
    setTimeout(function() { ConsoleKeyboard.enable(); }, 50 );
    MainKeyboard.disable();
  });

  $.subscribe("console:hidden", function() {
    setTimeout(function() { MainKeyboard.enable(); }, 50 );
    ConsoleKeyboard.disable();
  });

  KeyboardCreate('NavigationKeyboard');
  NavigationKeyboard.disable();

  NavigationKeyboard.on('t, c, escape',function() {
    $.publish("navigation:hidden");
  });

  NavigationKeyboard.on('down',function() {
    $.publish("navigation:down");
  });
  NavigationKeyboard.on('up',function() {
    $.publish("navigation:up");
  });
  NavigationKeyboard.on('left',function() {
    $.publish("navigation:left");
  });
  NavigationKeyboard.on('right',function() {
    $.publish("navigation:right")
  });
  NavigationKeyboard.on('enter',function() {
    $.publish("navigation:selection");
  });

  $.subscribe("navigation:show", function() {
    setTimeout(function() { NavigationKeyboard.enable(); }, 50 );
    MainKeyboard.disable();
  });

  $.subscribe("navigation:hidden", function() {
    setTimeout(function() { MainKeyboard.enable(); }, 50 );
    NavigationKeyboard.disable();
  });

});