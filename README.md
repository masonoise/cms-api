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

Concept stolen initially from [Copycopter](http://github.com/copycopter), and I borrowed some code to
get Grape going from [Dblock.org](http://code.dblock.org/grape-api-mounted-on-rack-w-static-pages).

NOTE: This is all totally new and not usable yet so don't even try. Stay tuned.
Tests are broken right now, will be fixed shortly.
