# osmod-discourse
This is the moderator example plugin for Discourse. This plugin captures topics and comments from Discourse and sends them to a public moderator server to be scored for moderation. Once scored, the posts can be rejected and updated in Discourse. 

The plugin requires the following settings in the admin panel to be set up. 
- "Moderator Enabled" has to be checked to be active
- "Moderator Base URL" should include the base route and port for your server. EX: 'https://localhost:8080/api'
- "Moderator JSON Web Token" is the JSON Web Token or JWT that is generated from Moderator for an account. 

A new Category in Discourse creates a new Category in OSMod.  
A new Topic in Discourse creates a new Article in OSMod.  
A new Post in Discouse creates a new Comment in OSMod.  

When a Comment is rejected in OSMod, a new Decision is created.  
A job runs every 5 minutes checking for new Decisions to process.  
You can update this interval in app/jobs/check_post_for_moderation.rb  
