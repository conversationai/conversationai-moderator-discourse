# name: moderator
# about: Send your Discourse comments to your installation of OSMod (an open sourced Moderator platform), where you can centralize comment moderation using Jigsaw’s machine learning API.
# version: 1.0.0
# authors: Instrument
require 'net/http'
require 'net/https'
require 'json'
require 'uri'
require 'date'

enabled_site_setting :moderator_enabled
enabled_site_setting :moderator_base_url
enabled_site_setting :moderator_json_web_token

# Load file dependencies
load File.expand_path('../app/models/models.rb', __FILE__)

after_initialize do
  load File.expand_path('../app/jobs/check_post_for_moderation.rb', __FILE__)

  # Post added in Discourse event
  on(:post_created) do |post, params|
    c = Comment.new post.raw
    payload = c.prep_comment_json post, params
    make_publisher_post 'comments', payload
  end

  # Topic created in Discourse event
  on(:topic_created) do |post, params|
    check_category post
    a = Article.new params[:raw]
    payload = a.prep_article_json post, params
    make_publisher_post 'articles', payload
  end
end

# Set http and headers, execute request
def generate_request(url, method, prepped_json = nil)
  uri = URI.parse url
  http = Net::HTTP.new uri.host, uri.port
  
  if uri.instance_of? URI::HTTPS
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  if method == 'post'
    request = Net::HTTP::Post.new uri.request_uri
  else
    request = Net::HTTP::Get.new uri.request_uri
  end

  request.add_field 'Content-Type', 'application/json'
  request.add_field 'Authorization', 'JWT ' + SiteSetting.moderator_json_web_token
  
  if prepped_json
    request.body = prepped_json
  end

  return http.request request
end

# Make POST request to Publisher API
def make_publisher_post(model_type, prepped_json)
  base_url = SiteSetting.moderator_base_url
  url = base_url + '/publisher/' + model_type
  generate_request url, 'post', prepped_json
end

# Check if Category exists in DB
def check_category(post)
  response = make_rest_get 'categories', post.category_id
  if response.code == '404'
    c = TopicCategory.new()
    payload = c.prep_category_json post
    make_rest_post 'categories', payload
  end
end

# Make GET request to REST API
def make_rest_get(model_type, id = nil)
  base_url = SiteSetting.moderator_base_url
  url = base_url + '/rest/' + model_type

  if id
    url << '/' + id.to_s
  end

  request = generate_request url, 'get'
end

# Make POST request to REST API
def make_rest_post model_type, prepped_json
  base_url = SiteSetting.moderator_base_url
  url = base_url + '/rest/' + model_type
  request = generate_request url, 'post', prepped_json
end
