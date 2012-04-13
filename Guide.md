# The Ambry Guide

By [Norman Clarke](http://njclarke.com)

## What is Ambry?

Ambry is a database and ORM alternative for small, mostly static models. Use
it to replace database-persisted seed data and ad-hoc structures in your app or
library with plain old Ruby objects that are searchable via a fast, simple
database-like API.

Many applications and libraries need models for datasets like the 50 US states,
the world's countries indexed by top level domain, or a list of phone number
prefixes and their associated state, province or city.

Creating a model with Active Record, DataMapper or another ORM and storing this
data in an RDBMS introduces dependencies and is usually overkill for small
and/or static datasets. On the other hand, keeping it in ad-hoc strutures can
offer little flexibility when it comes to filtering, or establishing searchable
relations with other models.

Ambry offers a middle ground: it loads your dataset from a script or file,
keeps it in memory as a hash, and makes use of Ruby's Enumerable module to
expose a powerful, ORM-like query interface to your data.

But just one word of warning: Ambry is not like Redis or Membase. It's not a
real database of any kind - SQL or NoSQL. Think of it as a "NoDB." Don't use it
for more than a few megabytes of data: for that you'll want something like
SQLite, Redis, Postgres, or whatever kind of database makes sense for your
needs.

## Creating Models

Almost any Ruby class can be stored as a Ambry Model, simply by extending
the {#Ambry::Model} module, and specifying which fields you want to store:

    class Person
      extend Ambry::Model
      field :email, :name
    end

You can also extend the {Ambry::ActiveModel} module to add an Active
Record/Rails compatible API. This will be discussed in more detail later.

### Setting up a simple model class

As shown above, simply extend (**not** include) `Ambry::Model` to create a
model class. In your class, you can add persistable/searchable fields using the
{Ambry::Model::ClassMethods#field field} method. This adds accessor methods,
similar to those created by `attr_accessor`, but marks them for internal use by
Ambry.

    class Person
      extend Ambry::Model
      field :email, :name, :birthday, :favorite_color
    end

All AmbryModels require at least one unique field to use as a hash key. By
convention, the first field you add will be used as the key; `:email` in the
example above. You can also use the {Ambry::Model::ClassMethods#id_field
id\_field} method to specify which field to use as the key.

### Basic operations on models

New instances of Ambry Models can be
{Ambry::Model::InstanceMethods#initialize initialized} with an optional hash
of attributes, or a block.

    person = Person.new :name => "Moe"

    person = Person.new
    person.name = "Moe"

    person = Person.new do |p|
      p.name = "moe"
    end

When initializing with both a hash and a block, the block is called last, so
accessor calls in the block take precedence:

    person = Person.new(:name => "Larry") do |p|
      p.name = "Moe"
    end
    p.name #=> "Moe"

Ambry exposes methods for model creation and storage which should look quite
familiar to anyone acquantied with ORM's, but the searching, indexing and
filtering methods are a little different.

#### CRUD

{Ambry::Model::ClassMethods#create Create},
{Ambry::AbstractKeySet#find Read},
{Ambry::Model::InstanceMethods#update Update},
{Ambry::Model::InstanceMethods#delete Delete}
methods are fairly standard:

    # create
    Person.create :name => "Moe Howard", :email => "moe@3stooges.com"

    # read
    moe = Person.get "moe@3stooges.com" # or...
    moe = Person.find "moe@3stooges"

    # update
    moe.name = "Mo' Howard"
    moe.save # or...
    moe.update :name => "Mo' Howard" # or...

    # delete
    moe.delete # or...
    Person.delete "moe@3stooges.com"

#### Searching

Finds in Ambry are performed using the `find` class method. If a single
argument is passed, that is treated as a key and Ambry looks for the matching
record:

    Person.find "moe@3stooges" # returns instance of Person
    Person.find "cdsafdfds"    # raises Ambry::NotFoundError

If a block is passed, then Ambry looks for records that return true for the
conditions in the block, and returns an iterator that you can use to step
through the results:

    people = Person.find {|p| p.city =~ /Seattle|Portland|London/}
    people.each do |person|
      puts "#{person.name} probably wishes it was sunny right now."
    end

There are two important things to note here. First, in the `find` block, it
appears that an instance of person is yielded. However, this is actually an
instance of {Ambry::HashProxy}, which allows you to invoke model attributes
either as symbols, strings, or methods. You could also have written the example
these two ways:

    people = Person.find {|p| p[:city] =~ /Seattle|Portland|London/}
    people = Person.find {|p| p["city"] =~ /Seattle|Portland|London/}

Second, the result of the find is not an array, but rather an enumerator that
allows you to iterate over results while instantiating only the model objects
that you use, in order to improve performance. This enumerator will be an
instance of an anonymous subclass of {Ambry::AbstractKeySet}.

Models' `find` methods are actually implemented directly on key sets: when you
do `Person.find` you're performing a find on a key set that includes all keys
for the Person class. This is important because it allows finds to be refined:

    londoners = Person.find {|p| p.city == "London"}

    londoners.find {|p| p.country == "CA"}.each do |person|
      puts "#{person.name} lives in Ontario"
    end

    londoners.find {|p| p.country == "GB"}.each do |person|
      puts "#{person.name} lives in England"
    end

Key sets can also be manipulated with set arithmetic functions:

    european                      = Country.find {|c| c.continent == "Europe"}
    spanish_speaking              = Country.find {|c| c.language == :es}
    portuguese_speaking           = Country.find {|c| c.language == :pt}
    speak_an_iberian_language     = spanish_speaking + portuguese_speaking
    non_european_iberian_speaking = speak_an_iberian_language - european

An important implementation detail is that the return value of `Person.find` is
actually an instance of a subclass of {Ambry::AbstractKeySet}. When you
{Ambry::Model.extended extend Ambry::Model}, Ambry creates
{Ambry::Model::ClassMethods#key_class an anonymous subclass} of
Ambry::AbstractKeySet, which facilitates customized finders on a per-model
basis, such as the filters described below.

#### Filters

Filters in Ambry are saved finds that can be chained together, conceptually
similar to [Active Record
scopes](http://api.rubyonrails.org/classes/ActiveRecord/NamedScope/ClassMethods.html#method-i-scope).

You define them with the {Ambry::Model::ClassMethods#filters filters} class
method:

    class Person
      extend Ambry::Model
      field :email, :gender, :city, :age

      filters do
        def men
          find {|p| p.gender == "male"}
        end

        def who_live_in(city)
          find {|p| p.city == city}
        end

        def between_ages(min, max)
          find {|p| p.age >= min && p.age <= max}
        end
      end
    end

The filters are then available both as class methods on Person, and instance
methods on key sets resulting from `Person.find`. This allows them to be
chained:

    Person.men.who_live_in("Seattle").between_ages(35, 40)

#### Relations

Ambry doesn't include any special methods for creating relations as in Active
Record, because this can easily be accomplished by defining an instance method
in your model:

    class Book
      extend Ambry::Model
      field :isbn, :title, :author_id, :genre, :year

      def author
        Author.get(author_id)
      end

      filters
        def by_genre(genre)
          find {|b| b.genre == genre}
        end

        def from_year(year)
          find {|b| b.year == year}
        end
      end
    end

    class Author
      extend Ambry::Model
      field :email, :name

      def books
        Book.find {|b| b.author_id == email}
      end
    end

Assuming for a moment that books can only have one author, the above example
demonstrates how simple it is to set up `has_many` / `belongs_to` relationships
in Ambry. Since the results of these finds are key sets, you can also chain
any filters you want with them too:

    Author.get("stevenking@writers.com").books.by_genre("horror").from_year(1975)


#### Indexes

If your dataset is on the larger side of what's suitable for Ambry (a few
thousand records or so) then you can use wrap your search with the
{Ambry::Model::ClassMethods#with_index} method to memoize the results and
improve the performance of frequently accessed queries:

    class Book
      extend Ambry::Model
      field :isbn, :title, :author_id, :genre, :year

      def self.horror
        with_index do
          find {|b| b.genre == "horror"}
        end
      end
    end

The argument to `with_index` is simply a name for the index, which needs to be
unique to the model. You can optionally pass a name to `with_index`, which is
a good idea when indexing methods that take arguments:

    def self.by_genre(genre)
      with_index("genre_#{genre}") do
        find {|b| b.genre == genre}
      end
    end

### Active Model

Ambry implements Active Model: read more about it
[here](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/).

TODO: write me

## Mappers and Adapters

TODO: write me

### Bundled adapters

TODO: write me

#### Ambry::Adapter

TODO: write me

#### Ambry::Adapters::File

TODO: write me

#### Ambry::Adapters::YAML

TODO: write me

#### Ambry::Adapters::SignedString

TODO: write me

## Extending Ambry

TODO: write me

### Adding functionality to Ambry::Model

TODO: write me

### Creating your own adapter

TODO: write me