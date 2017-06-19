# Prep JSON to create Comment in DB
# Data from Discourse Post object
class Comment
  def initialize(text)
    @text = text
  end

  def prep_comment_json(post_content, post_params)
    jsonData = {
      "data": [{
        "articleId": post_content.topic_id.to_s,
        "sourceId": post_content.id.to_s,
        # "replyToSourceId": "0",
        "authorSourceId": post_content.last_editor_id.to_s,
        "text": @text,
        "author": {
          "name": post_content.user.username,
          "email": post_content.user.email,
          # "avatar": "https://example.com/avatar.png",
        },
          "createdAt": post_content.created_at
        }]
    }
    return jsonData.to_json
  end
end
