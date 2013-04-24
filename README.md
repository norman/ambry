# Ambry

Ambry is a database and ORM replacement for small, mostly static models. Use
it to replace database-persisted seed data and ad-hoc structures in your app or
library with plain old Ruby objects that are searchable via a fast, simple
database-like API.

It implements Active Model and has generators to integrate nicely with Rails.
You can store your data in either YAML or dump file.

For more info, take a peek at the
[docs](http://rubydoc.info/github/norman/ambry/frames), or read on for some
quick samples.

## A quick tour

```ruby
# Create a model.
class Country
  # Turn any Ruby object into a Ambry model by extending this module.
  extend Ambry::Model

  # The first field listed here will be the "primary key."
  field :tld, :name

  # Chainable filters, sort of like Active Record scopes.
  filters do
    def big
      find {|c| c.population > 100_000_000 }
    end

    def in_region(region)
      find {|c| c.region == region }
    end

    def alphabetical
      sort_by {|c| c.name }
    end
  end

  # Root filter, can be used to setup relations.
  def regions
    Region.find {|r| r.id == region }
  end

end

# create some contries
Country.create :tld => "AR", :name => "Argentina", :region => :america, :population => 40_000_000
Country.create :tld => "CA", :name => "Canada",    :region => :america, :population => 34_000_000
Country.create :tld => "JP", :name => "Japan",     :region => :asia,    :population => 127_000_000
Country.create :tld => "CN", :name => "China",     :region => :asia,    :population => 1_300_000_000
# etc.

# Do some searches
big_asian_countries         = Country.big.in_region(:asia)
countries_that_start_with_c = Country.find {|c| c.name =~ /^C/ }
# #first and #last only make sense if you run Ruby 1.9 (creation order) or explicitly specified an order
first_alphabetical          = Country.alphabetical.first
last_alphabetical           = Country.alphabetical.last
```

## When should I use Ambry?

Ambry can be useful for refactoring code with large hash constants and long case
statements. Sometimes it's hard to figure out where code ends and data begins,
but if your code looks like it could be simplified significantly by putting some
things in a data store, yet it's not enough data to justify something like
SQLite, then Ambry could be a good fit.


## Installation

    gem install ambry

## Compatibility

Ambry has been tested against these current Rubies, and is likely compatible
with others.

* Ruby 1.8.7 - 1.9.3
* Rubinius 1.2.x+
* JRuby 1.5+

## Author

[Norman Clarke](mailto:norman@njclarke.com)

Many thanks to Adrián Mugnolo for initial code review and feedback.

## License

Copyright (c) 2011 Norman Clarke

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
