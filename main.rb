require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'x'
require 'sequel'

puts "Loading Youtube to Twitter Automator..."

# URL of the Channel RSS feed
url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC9nD_Re0fDb4uXRp_P9uMGQ"

uri = URI(url)
response = Net::HTTP.get_response(uri)

x_credentials = {
 api_key:ENV['X_API_KEY'],
 api_key_secret:ENV['X_API_KEY_SECRET'],
 access_token:ENV['X_ACCESS_TOKEN'],
 access_token_secret:ENV['X_ACCESS_TOKEN_SECRET'],
}
# Helper functions to interact with the database
def already_tweeted?(db, url)
 # Check if URL exists in the database table named xxx (replace with your actual table name)
 dataset = db[:xxx].where(url: url) # Replace xxx with your actual table name
 dataset.any?
end

def save_url_to_database(db, url)
 # Insert the URL into the database table named xxx (replace with your actual table name)
 db[:xxx].insert(url: url) # Replace xxx with your actual table name
end
# Initialize an X API client with your OAuth credentials
x_client = X::Client.new(**x_credentials)

begin
 if response.is_a?(Net::HTTPSuccess)
  puts "Successfully fetched RSS feed!"
  doc = Nokogiri::XML(response.body)

  # Define the namespaces
  namespaces = {
   'atom' => 'http://www.w3.org/2005/Atom',
   'media' => 'http://search.yahoo.com/mrss/'
  }

  # Use the correct namespace prefix for `<entry>` tag
  latest_item = doc.at_xpath('//atom:entry', namespaces) # Selects only the first <entry> element

  if latest_item
   # Extract video title and link
   video_title = latest_item.at_xpath('media:group/media:title', namespaces).text.strip
   video_url = latest_item.at_xpath('atom:link[@rel="alternate"]/@href', namespaces).text.strip

   puts "video_title: #{video_title}"
   puts "video_url: #{video_url}"

   # Database connection and logic here
   database_url = ENV['DATABASE_URL'] # Assuming database URL is stored in an environment variable

   begin
    # Connect to the database
    db = Sequel.connect(database_url)

    # Create the table if it doesn't exist
    db.create_table?(:xxx) do
     primary_key :id
     String :url, unique: true, null: false
    end

    # Check if URL already tweeted
    if already_tweeted?(db, video_url)
     puts "URL already tweeted."
    else
     begin
      # Save video_url to database
      save_url_to_database(db, video_url)
      puts "URL saved to database"

      # Tweet the video title and URL with hashtags
      tweet_text = "#{video_title} | #HashTag1 #Hashtag2 #{video_url}"
      x_client.post("tweets", "{\"text\":\"#{tweet_text}\"}")
      puts "Tweeted: #{tweet_text}"

     rescue StandardError => e
      puts "Error occurred while saving to database or tweeting: #{e.message}"
     end
    end

   rescue Sequel::DatabaseError => e
    puts "Error connecting to database: #{e.message}"
   ensure
    # Close the database connection (optional for this specific use case)
    db.disconnect if db
   end

  else
   puts "Error: Unable to locate a valid 'entry' element in the parsed RSS feed."
  end
 else
  puts "Error fetching RSS feed: #{response.code} - #{response.message}"
 end
rescue StandardError => e
 puts "Error fetching or parsing feed: #{e.message}"
end
