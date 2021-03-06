CMS via API
=================

Combination of a simple CMS application using Sinatra with an API using [Grape](http://github.com/intridea/grape),
mounted together on RACK to keep things really simple.

The Sinatra app provides the UI for managing the content, while the API layer provides the interaction to
store, update, and fetch content. The content is versioned, with just two versions to keep it simple: live
and draft. Two types of content are managed: text and files. Files are uploaded to Amazon S3 so that an
application using this content can fetch directly from S3 after getting the proper URL from the CMS.

The idea is to keep things very simple, so that content can be managed via the Sinatra application and the
content can be fetched from an external application.

The initial concept came from [Copycopter](http://github.com/copycopter), and I borrowed some code to
get Grape going from [Dblock.org](http://code.dblock.org/grape-api-mounted-on-rack-w-static-pages).

BIG HAIRY NOTE: This is all extremely new, unstable, and not usable yet so I don't recommend that you even
try. Stay tuned. Tests are pretty much nonexistent right now, but will be fixed shortly once things settle a bit.

To use this, you will need to:

1. bundle install
2. Create config/aws_credentials.rb with your access key and secret. This is not checked into git for obvious reasons (.gitignore specifically includes it).
 The file should look like this:
    module AwsCredentials
      ACCESS_KEY_ID = 'YOUR_ACCESS_KEY_ID'
      SECRET_ACCESS_KEY = 'YOUR_SECRET_ACCESS_KEY'
    end
3. Download and install MongoDB

- Start mongod; on OS X I use: mongod --dbpath /usr/local/var/mongodb/
- bundle exec rackup - will start the app
- bundle exec rspec spec - will run the tests, once there are some

CONTENT STATES

Content can have copies in Draft, Live, and Retired states (aka "versions"), with the following transitions:

- Newly-created items are automatically placed in Draft
- Draft items can be made live (aka "published"), which removes the draft copy
- Draft items can be edited and remain in Draft
- Live items, when edited, create a new copy in Draft state; existing copy remains Live
- When a Draft item is made live, if there is an existing Live copy it will be made Retired
- When a Live item is Retired, any existing Retired copy is replaced (i.e. there is only one Retired copy of an item)
- When deleting, only a single copy is deleted (not all versions)
- Live items can be "Rolled back", which swaps the live copy with the Retired copy (if there is one)

TO DO LIST:

- Authentication and saving of Author's name with changes
- Paginate the index page list of content
- Add search to index page content list to be able to find content for a page or search within content text
- File support is still in the works: need to finish file upload, add S3 push, and add file fetching
- When fetching a file, need to be able to ask for either the URL or the file itself

- When a new item is posted to the get API, it should save it as a new draft, with default text as passed in (this is a nice to have feature)
