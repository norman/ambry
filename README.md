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

Prequel loads your dataset from the file and keeps it in memory. It's not a
"NoSQL", it's a "NoDB". There's not only no schema or migrations to set up,
there's also no server or anything else to install since its only dependencies
are Ruby's standard library. Whenever possible, it behaves like the Ruby
standard library as opposed to introducing quirky behavior. It was inspired in
part by [Rubinius's](http://rubini.us/) short but meaningful tagline "Use Ruby."

But just a word of warning - don't even dare think about using it for more than
a couple megabytes of data. For that you need a real database of some sort, like
Postgres, MySQL, Redis, Mongo, etc.

## A Brief Example

### Setup for Rails

Prequel comes with a Rails generator that sets up an initializer and a YAML
database. Simple run:

    rails generate prequel

and it will add the following files:

    # db/prequel.yml (a blank file)

    # config/initializers/prequel.rb:
    require "prequel/adapters/yaml"
    require "prequel/active_model"
    Prequel::Adapters::YAML.new :file => Rails.root.join('db', 'prequel.yml')

Setting up a class with PrequelModel is simple: just extend the module, and
declare your persistable fields with the `field` method. The first field
declared will be behave as the "primary key," and it's up to you to ensure that
it's unique.

    class Country
      extend Prequel::Model
      field :tld, :name
    end


Seed your "database" in a seed script (for Rails this is db/seeds.rb) and then
treat Prequel models as read-only in your application.

    Country.create! :tld => "AR", :name => "Argentina"
    Country.create! :tld => "CA", :name => "Canada"
    Country.create! :tld => "JP", :name => "Japan"
    adapter.save_database


If you're using YAML, you could also just edit the "database" directly, though a
seed script offers more ease of use, and flexibility if you later decide to
convert your models to another ORM.

    ---
    Country:
      AR:
        :name: Argentina
        :tld: AR
      CA:
        :name: Canada
        :tld: CA
      JP:
        :name: Japan
        :tld: JP


### Querying

You can get a model instance by key with the `get` method:

    @country = Person.get("AR")


Searching and sorting are done via blocks. This is very fast for the small
datasets that Prequel is designed for. You can treat the block argument
similarly to an OpenStruct, accessing attributes as symbols, strings or method
names.

    @larry = Person.first {|p| p[:name] =~ /Larry/}
    @curly = Person.first {|p| p.email =~ /curly/ && p.name =~ /Howard/}


Prequel lets you create chainable filters via model class methods:

    class Country
      extend Prequel::Model
      field :tld, :name, :population, :region

      def self.african
        find {|p| p.region == :africa}
      end

      def self.european
        find {|p| p.region == :europe}
      end

      def self.population(op, num)
        find {|p| p.population.send(op, num)}.sort {|a, b| b.population <=> a.population}
      end
    end

    african_countries              = Country.african
    bigger_countries               = Country.population(:>=, 50_000_000)
    smaller_countries              = Country.population(:<=, 5_000_000)
    european_countries             = Country.european
    bigger_african_countries       = Country.african.population(:>=, 50_000_000)

It also lets you do set operations on the key sets themselves:

    bigger_non_african_countries   = bigger_countries  - african_countries
    bigger_or_european_countries   = bigger_countries  | european_countries
    smaller_and_european_countries = smaller_countries + european_countries
    smaller_european_countries     = smaller_countries & european_countries


### Active Model

Prequel implements the [Active
Model](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)
API to make it easy to use with Rails. Simply extend `Prequel::ActiveModel` to
make your model behave like Active Record.

    class Country
      extend Prequel::Model
      extend Prequel::ActiveModel

      field :tld, :name, :population

      validates_presence_of :name
      validates_numericality_of :population
      validates_uniqueness_of :tld, :slug

      before_save :set_slug

      # Use Babosa for slugging - http://github.com/norman/babosa
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
