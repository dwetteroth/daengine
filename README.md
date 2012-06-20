daengine - Digital Asset File parsing and search for OFI
========================================================

daengine is a rails engine plugin gem that provides access to digital assets, aka
SSC documents/pdfs such as fund documents from the rails applications.  It also
includes the parser code that reads digital-asset metadata produced by the 
Teamsite legacy CMS and ingests it into a MongoDB instance for use by the client
API.

Installation
-----------------------

To install the gem for use as a server process

    $ gem install daengine

To install within a rails app as an engine (for client API use)

    # Use the digital-asset api
    gem "daengine"

daengine Server Process
------------------------

The server process of daengine is packaged as an executable inside the gem called
`process_assets`.  You execute the server portion of the gem on a single-instance
where the Teamsite tuple .xml files are accessible and you must provide a configuration
.yml file to the executable that specifies the location of the tuple files and the 
MongoDB connection settings ala...

    $ cat config_prod.yml
    hosts: [[prod-db1,22785], [prod-db3,22785]]
    database: the_database_where_you_want_stuff_to_go
    assets_path: /tmp/some/teamsite/tuple/file/dir/

You then execute the server process as so:

    $ process_assets config_prod.yml



daengine Client API
----------------------

The data produced by the daengine server process can be consumed by any rails app
that includes the daengine gem and has an existing Mongoid connection to the MongoDB
database that the producer side writes to.  Client access is either directly thru
the *DigitalAssets* model class, or via the engine-provided REST API 
ie *http://localhost:3000/digital_assets.json*

Querying for Digital Assets
----------------------------

Querying assets via the Model Class...

    DigitalAsset.guid_is('/asdfasdflasdfalasdfasdfasdf.asfdasdf.foo')
    DigitalAsset.path_is('/digitalAssets/some-crazy-guid.pdf')
    DigitalAsset.sami_is('FOOBAR.001')

Query via the REST API...

    get 'http://localhost:3000/digital_assets/search?sami=FOOBAR.001'
    get 'http://localhost:3000/digital_assets/search?funds=12345'

