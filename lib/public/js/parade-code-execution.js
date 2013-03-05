window.CodeExecutor = Spine.Class.create({
  init: function() {
    this.visibleCodeBlocks = {};
    this.executeCodeFor = {}

    $.subscribe("code:execute",$.proxy(function(e,code) {
      this.executeCode(code);
    },this));
    $.subscribe("code:execute:visible",$.proxy(function(e,code) {
      this.executeVisibleCode();
    },this));
  },
  registerVisibleCodeBlock: function(language,elements,execution) {
    this.visibleCodeBlocks[language] = elements;
    this.executeCodeFor[language] = execution;
  },
  executeVisibleCode: function() {

    var codeBlocks = this.visibleCodeBlocks();
    var supportedCodeBlockLanguages = Object.keys(codeBlocks);

    for (var i = 0; i < supportedCodeBlockLanguages.length; i++) {
      var lang = supportedCodeBlockLanguages[i];

      if (codeBlocks[lang].length > 0) {
        var code = codeBlocks[lang].text();
        this.executeCode({ lang: lang, code: code });
      }
    }
  },
  executeCode: function(code) {
    var codeExecutor = this.executorForLanguage(code['lang']);
    $.publish('code:execution:started');
    codeExecutor(code['code']);
  },
  executorForLanguage: function(language) {
    return this.executeCodeFor[language];
  }
});

window.CodeViewer = Spine.Class.create({
  init: function() {
    $.subscribe("code:execution:started",$.proxy(function(e) {
      this.printResults("Executing...");
    },this));
    $.subscribe("code:execution:finished",$.proxy(function(e) {
      // When the execution is finished there is nothing that needs
      // to happen at the moment
    },this));
    $.subscribe("code:execution:results",$.proxy(function(e,result) {
      this.printResults(result);
    },this));
    $.subscribe("code:execution:clear",$.proxy(function(e,result) {
      this.removeResults();
    },this));

    this.resultsView = $('.results');
    this.resultsView.live('click',function() {
      $(this).hide();
    });

  },
  toggle: function() {
  },
  printResults: function(result) {
    var formattedResults = $.print(result, {max_string:500});
    this.removeResults();
    this.resultsView.show();
    this.resultsView.html(formattedResults)
  },
  removeResults: function() {
    this.resultsView.html("");
    this.resultsView.hide();
  }
})

$(document).ready(function() {
  codeExecutor = new CodeExecutor;
  codeViewer = new CodeViewer;

  codeExecutor.registerVisibleCodeBlock('js',$('.execute .javascript pre:visible'),function(code) {
    var result = eval(code);
    setTimeout(function() { $.publish('code:execution:finished'); }, 250 );
    if (result != null) { $.publish('code:execution:results',result); }
  });

  $('.execute pre.javascript').live("click", function() {
    var code = $(this).text();
    $.publish('code:execute',{ lang: 'js', code: code, elem: $(this) });
  });

  codeExecutor.registerVisibleCodeBlock('coffee',$('.execute .coffeescript pre:visible'),  function(code) {
    // When Coffeescript completes it's work the final result is encapsulated
    // within it. To get around it, the result of the last evaluation needs to
    // be assigned to the window, which we can then use for the purposes of
    // displaying the results.

    var codeWithAssignmentToResults = code + ';window.result=result;'
    eval(CoffeeScript.compile(codeWithAssignmentToResults));

    setTimeout(function() { $.publish('code:execution:finished'); }, 250 );
    if (result != null) { $.publish('code:execution:results',result); }
  });

  $('.execute pre.coffeescript').live("click", function() {
    var code = $(this).text();
    $.publish('code:execute',{ lang: 'coffee', code: code, elem: $(this) });
  });

});