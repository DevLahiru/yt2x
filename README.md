Youtube to Twitter Automator
## Overview

This Ruby script automatically fetches the latest video from a specified YouTube channel's playlist and posts it to Twitter. It utilizes the channel's RSS feed URL and is designed for deployment on Heroku with Heroku Postgres and Heroku Scheduler.

## Prerequisites

Ruby runtime  
A Heroku account  
A Twitter developer account and app  
## Installation

Clone this repository:  
```
git clone https://github.com/DevLahiru/yt2x.git  
```
Install the required gems:  
```ruby
bundle install
```

## Configuration

Set the following environment variables:

X_API_KEY: Your [x] API key  
X_API_KEY_SECRET: Your [x] API key secret  
X_ACCESS_TOKEN: Your [x] access token  
X_ACCESS_TOKEN_SECRET: Your [x] access token secret  
DATABASE_URL: The database URL provided by Heroku Postgres  
## Finding the YouTube Channel RSS Feed URL:

Go to the YouTube channel you want to monitor.  
Look at the channel URL in the address bar. It should look something like https://www.youtube.com/channel/UC_XEXAMPLECHANNELID.  
The channel ID is the string of characters after UC_.  

Constructing the RSS Feed URL:  
https://www.youtube.com/feeds/videos.xml?channel_id=YOUR_CHANNEL_ID  
Replace YOUR_CHANNEL_ID with the actual channel ID you obtained from the channel URL.  

For example:  

If the YouTube channel URL is https://www.youtube.com/channel/UCgDW8BFHdYrVUvtQvXA8mcg, the channel ID is UCgDW8BFHdYrVUvtQvXA8mcg, and the RSS feed URL would be:  
https://www.youtube.com/feeds/videos.xml?channel_id=UCgDW8BFHdYrVUvtQvXA8mcg  
Update the script main.rb with the constructed RSS feed URL.

Find the line:  
url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCc30sTBdN9LRSxEuHaXV_bQ"  
Replace the entire URL with the constructed RSS feed URL for your desired YouTube channel.

## Deployment to Heroku

Initialize a Git repository in your project directory:
```
git init
```
Add a Procfile with the following content:
```
worker: bundle exec ruby youtube_to_twitter.rb
```
Commit your changes:  
```
git add . && git commit -m "Initial commit"
```

Create a Heroku app:
```
heroku create
```
Push your code to Heroku:
```
git push heroku master
```
Provision a Heroku Postgres database:
```
heroku addons:create heroku-postgresql:hobby-dev
```
Configure Heroku Scheduler to run the script periodically (e.g., 10mins):
```
heroku addons:create scheduler:standard
heroku addons:open scheduler
```
In the scheduler, set a job to run rake worker at your desired frequency.

## or

<a href="https://heroku.com/deploy?template_url=https://github.com/DevLahiru/yt2x/blob/master/app.json">
  <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy">
</a>

## Usage

Once deployed, the script will automatically fetch the latest video from the specified YouTube channel's playlist using the RSS feed and post it to Twitter if it hasn't already been tweeted.
