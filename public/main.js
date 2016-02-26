$(document).ready(function() {
  var mountPoint = $('html').data().mountPoint;
    $('.school').each(function(index, element) {
      var id = $(this).attr('id')
      var content = $(this).find('span.content');
      var badge = $(this).find('span.badge');
      var glyph = $(this).find('span.glyphicon');

      // Fetch admin data for each school
      $.ajax({ url: mountPoint + '/admins/' + id }).done(function(data) {
        content.html(data);
        var admin_count = content.children('li').length;
        badge.html('Admins: ' +  (admin_count > 0 ? admin_count : 'None'));
        badge.fadeIn('slow');
        if (admin_count > 0) { glyph.fadeIn('slow'); } else { content.parent().hide(); }

        // Last item loaded - fade load indicator, add user data handler
        if (index == $('.school').length - 1) {
          $('#loading').fadeTo(1000, 0);
          $('.user').click(function(e) {
            var button = $(e.toElement || e.target);
            var span = $('<span></span>');
            button.replaceWith(span);
            span.html('');
            span.addClass('glyphicon glyphicon-refresh');
            $.ajax({ url: mountPoint + '/user/' + $(this).attr('id') }).done(function(data) {
              span.removeClass('glyphicon glyphicon-refresh');
              span.html(data);
            })
          });
        }
      });
    });

    $('.dropdown').click(function() {
      $(this).siblings('span.content').slideToggle('fast');
      $(this).children('span.glyphicon').toggleClass('glyphicon-chevron-down glyphicon-chevron-up');
    });
});
