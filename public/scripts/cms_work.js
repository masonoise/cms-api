$(document).ready(function() {

  var show_list = function(version) {
    $.ajax({
      type: "GET",
      url: "/api/v1/cms/all/" + version,
      success: function(data) {
        var the_list = "";
        for (i=0; i < data.result.length; i++) {
            var item = data.result[i];
            the_list = the_list + "<tr>" +
                "<td>" + item.title +
                "</td><td>" + item.content +
                "</td><td>" + item.page +
                "</td><td>" + item.block +
                "</td><td>" + item.type + "</td>";
            if (ver == 'draft') {
                the_list = the_list + "<td><i class='icon-ok' onclick='make_item_live(\"" + item.page + "/" + item.block + "/" + item.version + "\")'></i></td>";
            }
            the_list = the_list + "</td><td><i class='icon-trash' onclick='delete_item(\"" + item.page + "/" + item.block + "/" + item.version + "\")'></i></td></tr>";
        }
        if (ver == 'draft') {
            $('#content_list').html("<table class='table table-striped' width='50%' border='0'><tr><th>Title</th><th>Content</th><th>Page</th><th>Block</th><th>Type</th><th>Make Live</th><th>Delete</th></tr>" + the_list + "</table>");
            $('#live_btn').removeClass('disabled');
            $('#draft_btn').addClass('disabled');
        } else {
            $('#content_list').html("<table class='table table-striped' width='50%' border='0'><tr><th>Title</th><th>Content</th><th>Page</th><th>Block</th><th>Type</th><th>Delete</th></tr>" + the_list + "</table>");
            $('#draft_btn').removeClass('disabled');
            $('#live_btn').addClass('disabled');
        }
      }
    });
  }
  show_list_function = show_list;

  var post_content = function() {
      $.ajax({
        type: "POST",
        url: "/api/v1/cms/",
        data: { title: $('#title').val(),
            content: $('#content').val(),
            page: $('#page').val(),
            block: $('#block').val()
        },
        success: function(data) {
          $('#results').text(data.result);
          window.location('/draft');
//          show_list('draft');
        },
        fail: function(data) {
            $('#results').text(data);
        }
      });
  }

  $("#post_form").submit(function() {
    post_content();
    $('#title').val('');
    $('#content').val('');
    $('#page').val('');
    $('#block').val('');
    return(false);
  });

  show_list(ver);
});