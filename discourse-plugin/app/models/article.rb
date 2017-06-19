# Prep JSON to create Article in DB
# Data from Discourse Topic object
class Article
  def initialize(text)
    @text = text
  end

  def prep_article_json(post_content, post_data)
    jsonData = {
      "data":
      [
        {
          "sourceId": post_content.id.to_s,
          "categoryId": post_content.category.name,
          "title": post_content.title,
          "createdAt": post_content.created_at,
          "text": @text,
          "url": post_data[:referrer] + "t/" + post_content.slug
        }
      ]
    }
    return jsonData.to_json
  end
end
