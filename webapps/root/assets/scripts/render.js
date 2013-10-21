(function ($) { 

  var canvas = $("div#music canvas");
  var width = parseInt(canvas.attr("width") - 50);
  var height = parseInt(canvas.attr("height") - 50);

  var score = $('score').get(0);
  var s = new XMLSerializer();
  var str = s.serializeToString(score);

  // Hack: restore camel case
  str = str.replace(/scoredef/gm, "scoreDef");
  str = str.replace(/staffdef/gm, "staffDef");
  str = str.replace(/staffgrp/gm, "staffGrp");

  var parser = new DOMParser();
  var doc = parser.parseFromString(str, "application/xml");
  
  var MEI = doc.getElementsByTagName('score');

  MEI2VF.render_notation(MEI[0], canvas[0], width, height);

})(jQuery);