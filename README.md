# Fork

This project was forked in order to add additional methods.

# Etsy

[![Build Status](https://secure.travis-ci.org/kytrinyx/etsy.png)](http://travis-ci.org/kytrinyx/etsy)
[![Dependency Status](https://gemnasium.com/kytrinyx/etsy.png)](https://gemnasium.com/kytrinyx/etsy)

## Description

The Etsy gem provides a friendly Ruby interface to the Etsy API

## Installation

Installing the latest stable version is simple:

    $ gem install etsy

If you want to be on the bleeding edge, install from GitHub:

    $ git clone git://github.com/kytrinyx/etsy.git
    $ cd etsy
    $ rake install

### Dependencies

The gem has been verified to work with version 1.5.0 of json.
It will likely work with higher versions, but this is unproven.

## Usage

### Public Mode

The Etsy API has two modes: public, and authenticated. Public mode only requires an
API key (available from http://developer.etsy.com ):

    require 'etsy'

    Etsy.api_key = 'foobar'

From there, you can make any non-authenticated calls to the API that you need.

## Authenticated Calls

The Etsy API has support for both retrieval of extended information and write support for authenticated users. Authentication can either be performed from the console or from within a Ruby web application.

### Console

For simple authentication from the console, configure the necessary parameters:

    require 'rubygems'
    require 'etsy'

    Etsy.api_key = 'key'
    Etsy.api_secret = 'secret'

First, generate a request token:

    request = Etsy.request_token

From there, you will need to paste a verification URL into a browser:

    Etsy.verification_url

Once you have allowed access, you can generate an access token by supplying
the verifier displayed on the Etsy site:

    access = Etsy.access_token(request.token, request.secret, 'abc123')

Authenticated calls can now be made by passing an access token and secret:

    Etsy.myself(access.token, access.secret)

### Web Application

The process for authenticating via a web application is similar, but requires the configuration of a callback URL:

    require 'rubygems'
    require 'etsy'

    Etsy.api_key = 'key'
    Etsy.api_secret = 'secret'
    Etsy.callback_url = 'http://localhost:4567/authorize'

In this mode, you'll need to store the request token and secret before redirecting
to the verification URL. A simple example using Sinatra:

    enable :sessions

    get '/' do
      request_token = Etsy.request_token
      session[:request_token]  = request_token.token
      session[:request_secret] = request_token.secret
      redirect Etsy.verification_url
    end

    get '/authorize' do
      access_token = Etsy.access_token(
        session[:request_token],
        session[:request_secret],
        params[:oauth_verifier]
      )
      # access_token.token and access_token.secret can now be saved for future API calls
    end

### Environment

The Etsy API has both a sandbox environment and a production environment.

If nothing is set, the default is :sandbox.

You can set this using:

    Etsy.environment = :production

## DSL

Use the Etsy::Request class to make flexible calls to the API.

To do so, find out which endpoint you wish to connect to and the parameters you wish to pass in.

    >> access = {:access_token => 'token', :access_secret => 'secret'}
    >> Etsy::Request.get('/taxonomy/tags', access.merge(:limit => 5))

or to fetch an associated resource

    >> access = {:access_token => 'token', :access_secret => 'secret'}
    >> Etsy::Request.get('/users/__SELF__', access.merge(:includes => 'Profile'))

or to limit the fields returned

    >> shop_id = 'littletjane'
    >> access = {:access_token => 'token', :access_secret => 'secret'}
    >> Etsy::Request.get('/shops/#{shop_id}', access.merge(:fields => 'is_vacation,is_refusing_alchemy'))

## Convenience Methods

There are some wrappers for resources that typically are needed in a small application.

### Users

If you're starting with a user, the easiest way is to use the Etsy.user method:

    >> user = Etsy.user('littletjane')
    => #<Etsy::User:0x107f82c @result=[{"city"=>"Washington, DC", ... >
    >> user.username
    => "littletjane"
    >> user.id
    => 5327518

For more information about what is available for a user, check out the documentation
for Etsy::User.

### Shops

Each user may optionally have a shop.  If a user is a seller, he / she also has an
associated shop object:

    >> shop = user.shop
    => #<Etsy::Shop:0x102578c @result={"is_vacation"=>"", "announcement"=> ... >
    >> shop.name
    => "littletjane"
    >> shop.title
    => "a cute and crafty mix of handmade goods."

More information about shops can be found in the documentation for Etsy::Shop.

### Listings

Shops contain multiple listings:

    >> shop.listings
    => [#<Etsy::Listing:0x119acac @result={} ...>, ... ]
    >> listing = shop.listings.first
    => #<Etsy::Listing:0x19a981c @result={} ... >
    >> listing.title
    => "hanging with the bad boys matchbox"
    >> listing.description
    => "standard size matchbox, approx. 1.5 x 2 inches ..."
    >> listing.url
    => "http://www.etsy.com/view_listing.php?listing_id=24165902"
    >> listing.view_count
    => 19
    >> listing.created_at
    => Sat Apr 25 11:31:34 -0400 2009

See the documentation for Etsy::Listing for more information.

### Images

Each listing has one or more images available:

    >> listing.images
    => [#<Etsy::Image:0x18f85e4 @result={} ... >,
      #<Etsy::Image:0x18f85d0 @result={} ... >]
    >> listing.images.first.square
    => "http://ny-image0.etsy.com/il_75x75.189111072.jpg"
    >> listing.images.first.full
    => "http://ny-image0.etsy.com/il_fullxfull.189111072.jpg"

Listings also have a primary image:

    >> listing.image
    => #<Etsy::Image:0x18c3060 @result={} ... >
    >> listing.image.full
    => "http://ny-image0.etsy.com/il_fullxfull.189111072.jpg"

More information is available in the documentation for Etsy::Image.

### Associations

Associations on resources can be specified with the 'includes' key.

A single resource can be specified with the name of the resource as a string:

    >> Listing.find(1, {:includes => 'Images'})

Multiple resources can be specified with the name of the resources as a comma-delimited string:

    >> User.find(1, {:includes => ['FeedbackAsBuyer', 'FeedbackAsSeller']})

If you want a more fine-grained response, you can specify the associations as an array of hashes, each of which must contain the name of the resource, and can also include the fields you wish returned, as well as the limit and offset.

    >> association = {:resource => 'Images', :fields => ['red','green','blue'], :limit => 1, :offset => 0}
    >> Listing.find(1, {:includes => [association]})

## Public mode vs authenticated calls

This additional example should make clear the difference between issuing public versus authenticated requests: 

### Public workflow

    >> Etsy.api_key = 'key'
	>> user = Etsy.user('user_id_or_name')
	>> Etsy::Listing.find_all_by_shop_id(user.shop.id, :limit => 5)

### Authenticated workflow

    >> Etsy.api_key = 'key'
	>> Etsy.api_secret = 'secret'
    >> user = Etsy.myself(token, secret)
	>> access = { :access_token => user.token, :access_secret => user.secret }
	>> Etsy::Listing.find_all_by_shop_id(user.shop.id, access.merge(:limit => 5))
	
## Error handling

Next versions of this gem will raise errors when requests are unsuccessful. The current version does not. 
Use either of following workarounds:

### Low-level API

Instead of doing this:

    >> Etsy::Request.get('/users/__SELF__', access).result 

Write this:

    >> Etsy::Request.get('/users/__SELF__', access).to_hash["results"]

### Monkey patch

This is Ruby, reopen the <code>Response</code> class anywhere in your codebase and redefine <code>result</code>:

      class Etsy::Response
        def result
	      if success?
	        results = to_hash['results'] || []
	        count == 1 ? results.first : results
	      else
	       validate!
	      end
        end
      end

### Usage

With the above in place, you can now rescue errors and act upon them:

      begin
        Etsy.myself(access.token, access.secret)		
      rescue Etsy::OAuthTokenRevoked, Etsy::InvalidUserID, Etsy::MissingShopID, Etsy::EtsyJSONInvalid, Etsy::TemporaryIssue => e
        puts e.message
      end 

## Contributing

I have a "commit bit" policy for contributions to this repository. Once I accept
your patch, I will give you full commit access.  To submit patches:

1. Fork this repository
2. Implement the desired feature with tests (and documentation if necessary)
3. Send me a pull request

I ask that you not submit patches that include changes to the version or gemspec.

### Basics steps for contributing using (https://github.com/defunkt/hub)

    # Setup the project
    git clone kytrinyx/etsy
    git fork
    bundle
    rake

    # Normal flow
    git checkout -b your-feature-or-bug
    # Write your tests
    # Make the tests pass
    git add <CHANGES>
    git commit -m "Some useful message"
    git push -u YOUR-GITHUB-USERNAME your-feature-or-bug
    git pull-request

## Contributors

These people have helped make the Etsy gem what it is today:

* [Patrick Reagan](https://github.com/reagent)
* [Katrina Owen](http://github.com/kytrinyx)
* [Mak Nazečić-Andrlon](https://github.com/Muon)
* [Patrick Schless](https://github.com/plainlystated)
* [Matt Fields](https://github.com/mfields106)
* [Jake Boxer](https://github.com/jakeboxer)
* [Trae Robrock](https://github.com/trobrock)
* [Jimmy Tang](https://github.com/jimmytang)
* [Julio Santos](https://github.com/julio)
* [Roger Smith](https://github.com/rogsmith)

### Github Flow

For those of you with commit access, please check out Scott Chacon's blog post about [github flow](http://scottchacon.com/2011/08/31/github-flow.html)

> * Anything in the master branch is deployable
> * To work on something new, create a descriptively named branch off of master (ie: new-oauth2-scopes)
> * Commit to that branch locally and regularly push your work to the same named branch on the server
> * When you need feedback or help, or you think the branch is ready for merging, open a pull request
> * After someone else has reviewed and signed off on the feature, you can merge it into master
> * Once it is merged and pushed to ‘master’, you can and should deploy immediately

## License

The Etsy rubygem is released under the MIT license.
