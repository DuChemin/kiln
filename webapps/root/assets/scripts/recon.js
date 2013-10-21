(function ($) { 

  render = function (d, analyst) {
    $('.lab').hide();

    canvas[0].width = canvas[0].width;

    var MEI = d.getElementsByTagName('score');
    var a = d.getElementsByTagName('analysts');
    a[0].parentNode.removeChild(a[0]);

    MEI2VF.render_notation(MEI, canvas[0], width, height);

    $('.source').show();

    $('.'+analyst).show();

  }

  $('#recons').find('label').click(function(){
    analyst = $(this).find('input').attr('id');
    var dc = /DC\d{4}/g.exec(document.URL)[0];
    url = "/getrecon/"+dc+"/1/5/" + analyst
    $.get(url, function (data) {
      render(data, analyst);
    });

  });

  $('#recons').find('label')[0].click()

  var canvas = $("div#music canvas");
  var width = parseInt(canvas.attr("width") - 50);
  var height = parseInt(canvas.attr("height") - 50);

})(jQuery);
