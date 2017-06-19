# Prep JSON to create Category in DB
# Data from Discourse Category object
class TopicCategory
  def prep_category_json(post_content)
    jsonData = {
      "data": {
        "type": "categories",
        "attributes": {
          "label": post_content.category.name
        }
      }
    }
    return jsonData.to_json
  end
end
