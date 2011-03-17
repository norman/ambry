# Prequel

Prequel is a database and ORM replacement for small, mostly static models. Use
it to replace database-persisted seed data and ad-hoc structures in your app or
library with plain old Ruby objects that are searchable via a fast, simple
database-like API.

It implements Active Model and has generators to integrate nicely with Rails.

For more info, take a peek at the {Guide}, or read on for some quick samples.

## A quick tour

    # Create a model.
    class Country
      # Turn any Ruby object into a Prequel model by extending this module.
      extend Prequel::Model

      # The first field listed here will be the "primary key."
      field :tld, :name

      # Chainable filters, sort of like Active Record scopes.
      filters do
        def big
          find {|c| c.population > 100_000_000}
        end

        def in_region(region)
          find {|c| c.region == region)
        end
      end

      # Root filter, can be used to setup relations.
      def regions
        Region.find {|r| r.id == region}
      end

    end

    # create some contries
    Country.create :tld => "AR", :name => "Argentina", :region => :america, :population => 40_000_000
    Country.create :tld => "CA", :name => "Canada",    :region => :america, :population => 34_000_000
    Country.create :tld => "JP", :name => "Japan",     :region => :asia,    :population => 127_000_000
    Country.create :tld => "CN", :name => "China",     :region => :asia,    :population => 1_300_000_000

    # Save the database. Prequel is oriented towards reads, so you only write
    # when you want to save the whole database.
    adapter.save_database

    # Do some searches
    big_asian_countries = Country.big.in_region(:asia)
    start_with_c        = Country.find {|c| c.name =~ /^C/}
## Find out more

A guide for Prequel is in the works, but for now you can read the API docs.


## Installation

    gem install prequel

## Compatibility

Prequel has been tested against these current Rubies, and is likely compatible
with others. Note that 1.8.6 is not supported.

* Ruby 1.8.7 - 1.9.2
* Rubinius 1.2.3
* JRuby 1.5.6

## Author

    Norman Clarke (norman@njclarke.com)

## Thanks

Thanks to Adrián Mugnolo for ideas, code review and the idea for the name.
Thanks to the authors of [Sequel](http://sequel.rubyforge.org/) for the
inspiration for this library's name, and the the idea behind how the filters and
relations should work.

## License

Copyright (c) 2011 Norman Clarke

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
