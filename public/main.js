$(document).ready(function() {
  var mountPoint = $('html').data().mountPoint;
    $('.school').each(function(index, element) {
      var id = $(this).attr('id')
      var adminContent = $(this).find('div.admin-content');
      var badge = $(this).find('span.badge');
      var glyph = $(this).find('span.glyphicon');

      // Fetch admin data for each school
      $.ajax({ url: mountPoint + '/admins/' + id }).done(function(data) {
        adminContent.html(data);
        var admin_count = adminContent.find('.admin-row').length;
        badge.html('Admins: ' +  (admin_count > 0 ? admin_count : 'None'));
        badge.fadeIn('slow');
        if (admin_count > 0) { glyph.fadeIn('slow'); } else { adminContent.parent().remove(); }

        // Apply style each time to keep alternating colors correct after removing elements
        $('li:nth-child(even)').css('background-color', '#f5f5f5')
        $('li:nth-child(odd)').css('background-color', '#ffffff')

        // Hide load indicator after last item loaded
        if (index >= $('.school').length - 1) {
          $('#loading').fadeTo(1000, 0);
        }
      });
    });

    $('.dropdown').click(function() {
      $(this).siblings('div.admin-content').slideToggle('fast');
      $(this).children('span.glyphicon').toggleClass('glyphicon-chevron-down glyphicon-chevron-up');
    });
});
