$(document).ready(function() {

  var text_list = function() {
    $.ajax({
      type: "GET",
      url: "/api/v1/cms/text/all",
      success: function(data) {
        var the_list = "";
        for (i=0; i < data.result.length; i++) {
            var item = data.result[i];
            the_list = the_list + "<tr><td>" + item.id +
                "</td><td>" + item.title +
                "</td><td>" + item.content +
                "</td><td>" + item.page +
                "</td><td>" + item.block +
                "</td><td><button onclick='delete_item(\"" + item.id + "\")'>Delete</button></td></tr>";
        }
        $('#text_list').html("<table width='50%' border='0'><tr><th>ID</th><th>Title</th><th>Content</th><th>Page</th><th>Block</th><th>&nbsp;</th></tr>" + the_list + "</table>");
      }
    });
  }
  text_list_function = text_list;

  var post_content = function() {
      $.ajax({
        type: "POST",
        url: "/api/v1/cms/text",
        data: { title: $('#title').val(), content: $('#content').val(), page: $('#page').val(), block: $('#block').val() },
        success: function(data) {
          $('#results').text(data.result);
          text_list();
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
    return(false);
  });

  text_list();
});