SpreePuntopagos
================

Easily integrates Puntopagos payments into a Spree store. It works as a wrapper
of the awesome puntopagos-ruby gem which contains all basic API calls for Puntopagos payment
services.


Dependencies
------------
You need to make sure to use Postgres as database engine.

Also need to install the extension for Postgres `hstore`:

```shell
sudo apt-get install postgresql-contrib
```


Installation
------------

Add spree_puntopagos to your Gemfile:

```ruby
gem 'spree_puntopagos', github: 'acidlabs/spree_puntopagos'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_puntopagos:install
```

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
DB=postgres bundle exec rake test_app
bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_puntopagos/factories'
```

Copyright (c) 2014 Acidlabs, released under the New BSD License


Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
