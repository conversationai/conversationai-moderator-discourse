class CheckCommentsForScores < Jobs::Scheduled
  every 1.minute

  # Check Decisions every minute
  def execute(args)
    decisions = get_recent_comments
    if decisions.code == '200'
      find_rejected_comments JSON.parse decisions.body
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

  # Get decisions from Publisher API
  def get_recent_comments
    url = SiteSetting.moderator_base_url + '/publisher/decisions'
    generate_request url, 'get'
  end

  # Find comments with status = Reject
  def find_rejected_comments(response)
    decision_ids = Array.new
    post_ids = Array.new
    response['data'].each do |item|
      if item['attributes']['status'] == 'Reject'
        # Get sourceId of post from included section of JSON object
        sourceId = response['included'].find {|i| i['id'] == item['attributes']['commentId']}['attributes']['sourceId']
        decision_ids << item['id']
        post_ids << sourceId
      end
    end
    if decision_ids.any?
      confirm_decisions decision_ids
      reject_posts post_ids
    else
      puts 'No new decisions found.'
    end
  end

  # Delete posts in Discourse
  def reject_posts(post_ids)
    post_ids.each do |post|
      post_to_delete = Post.find(post)
      PostDestroyer.new(Discourse.system_user, post_to_delete).destroy
    end
  end

  # Confirm decisions in OSMod
  def confirm_decisions(decision_ids)
    url = SiteSetting.moderator_base_url + '/publisher/decisions/confirm'
    prepped_json = { "data" => decision_ids}.to_json
    generate_request url, 'post', prepped_json
  end
end
