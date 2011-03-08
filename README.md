# Prequel

Prequel is a database and ORM replacement for small, mostly static models. In
many applications, you need models for datasets like the 50 US states, the
world's countries with associated TLDs, or categories of products a business
sells.

Creating a model with Active Record, DataMapper or another ORM and storing this
data in an RDBMS is often overkill, especially if you don't need to update the
data frequently. On the other hand, storing that data in a Hash constant offers
little flexibility when it comes to filtering the data, or establishing
relations with models for things like users or invoices that do belong in a
database.

Prequel offers a middle ground: it makes use of Ruby's Enumerable module to
expose a powerful, ORM-like query interface to Ruby's Hash, and allows you to
persist your model data in a file.

Prequel keeps your entire dataset in memory. It's not a "NoSQL", it's a "NoDB".
There's not only no schema or migrations to set up, there also no server or
anything else to install since its only dependencies are Ruby's standard
library. But just a word of warning - don't even dare think about using it for
more than a couple megabytes of data. For that you need a real database, like
Postgres, MySQL, Redis, Mongo, etc.

## A Brief Example

### Setup

Initialize Prequel by instantiating an adapter. For Rails, this could go in a
`config/initializers/prequel.rb`.

    require "prequel/adapters/yaml"
    Prequel::Adapters::YAML.new(Rails.root.join("db", "prequel.yaml")

Setting up a class with PrequelModel is simple: just extend the module, and
declare your persistable fields with `attr_accessor`. The first field declared
will be behave as the "primary key," and it's up to you to ensure that it's
unique. Tell Prequel which adapter to use, which by default is named `:main`.

    class Person
      extend Prequel::Model
      attr_accessor :name, :email
      use :main
    end


Build your "database" in a seed script and treat Prequel models as read-only in
your application.

    Person.create :name => "Moe Howard", :email => "moe@3stooges.com"
    Person.create :name => "Larry Fine", :email => "larry@3stooges.com"
    adapter.save_database

If you're using YAML, you could also just edit the "database" directly, though
a seed script offers more portability if you later decide to conver your models
to another ORM.

    ---
    Person:
      moe@3stooges.com:
          :name: Moe Howard
          :email: moe@3stooges.com
      shemp@3stooges.com:
          :name: Shemp Howard
          :email: shemp@3stooges.com
      curly@3stooges.com:
          :name: Curly Howard
          :email: curly@3stooges.com
      larry@3stooges.com:
          :name: Larry Fine
          :email: larry@3stooges.com
      curlyjoe@3stooges.com:
          :name: Joe DeRita
          :email: curlyjoe@3stooges.com

### Querying

You can get a model instance by key with the `get` method:

    @moe = Person.get "moe@3stooges.com"

Searching is done via simple blocks. This is very fast for the small datasets
that Prequel is designed for. You can treat the block argument similarly to an
OpenStruct, in that it you can access attributes as symbols, strings or method
names. Symbols perform best.

    @larry   = Person.first {|p| p[:name] =~ /Larry/}
    @stooges = Person.find {|p| p["email"] =~ /stooge/}
    @curly   = Person.find {|p| p.email =~ /curly/ && p.name =~ /Howard/}

The results of finds are sets of keys. This makes Prequel fast and lets you
create relations and chainable filters via model class methods:

    class Country
      extend Prequel::Model
      attr_accessor :tld, :name, :population, :region

      def self.african
        find {|p| p.region == :africa}
      end

      def self.with_population(num)
        find {|p| p.population >= num}
      end

      def self.starting_with(letter)
        find {|p| p.name =~ /\A#{letter}/i}
      end

      # One-to-many ("has_many") relation
      def regions
        Region.find {|region| region[:tld] == tld}
      end
    end

    class Region
      extend Prequel::Model
      attr_accessor :tld_plus_name, :tld, :name, :capital

      def tld_plus_name
        "#{tld}:#{name}"
      end

      # Many-to-one ("belongs_to") relation
      def country
        Country.get(tld)
      end
    end

    # Get populous African countries whose names start with "N" and print their
    # name and regions.
    Country.african.with_population(75_000_000).starting_with("N").each do |c|
      puts "#{c.name} has #{c.regions.count} regions"
    end

## Active Model

Prequel has full Active Model support. Simply include `Prequel::ActiveModel` to
make your model behave like Active Record:

    class Country
      extend Prequel::Model
      include Prequel::ActiveModel

      use :main

      attr_accessor :tld, :name, :population

      validates_presence_of :name
      validates_numericality_of :population
      validates_uniqueness_of :tld, :slug

      before_save :set_slug

      # Use Babosa for slugging (http://github.com/norman/babosa)
      def set_slug
        @slug = name.to_slug.normalize.to_s
      end

      alias to_param slug
    end

## Find out more

A guide for Prequel is in the works, but for now you can read the API docs.


## Installation

    gem install prequel

## Compatibility

* Ruby 1.8.7 - 1.9.2
* Rubinius 1.0+
* JRuby 1.5+

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
