# Prequel

Prequel is a library for storing objects in a persistable in-memory Hash.
Classes that extend Prequel::Model looks like ORM models and can optionally be
used with Active Model. However, because there's no database, there's nothing to
set up and access is extremely fast. It's intended for smallish amounts of
mostly read-only data, such as lists of states and countries; those parts of a
typical MVC application that are too small to be full models but that have their
own logic.

Prequel's hash "database" can be persisted in many different formats: it comes
with adapters for Yaml, Marshal, and signed cookies. This last option allows you
to treat an HTTP cookie as a tiny database for MVC models. This can be very
useful for multistep forms, or for anonymous user models.

## Examples

Setting up a class with PrequelModel is simple: just extend the module,
and declare which field will be used as a key. You need to make sure this
key is unique.

    class Person
      extend Prequel::Model
      attr_accessor :name, :email
      attr_key :email
    end

In your application, create a adapter somewhere at startup. For Rails, this could
go in a `config/initializers/prequel.rb`.

    Prequel::Adapters::File.new("/path/to/my/file.bin")

If you're storing your data in a file (the usual case), then you usually build
your database in a seed script and treat Prequel models as read-only in your
application.

    # Part of a function in a Rake task
    adapter = Prequel::Adapters::File.new("/path/to/my/file.bin")
    Person.create(:name => "Moe Howard", :email => "moe@3stooges.com")
    Person.create(:name => "Larry Fine", :email => "larry@3stooges.com")
    adapter.save_database

Prequel currently comes with two file-based adapters: YAML and Marshal. You can
also easily add your own formats if you want.

Getting a model instance by key is done with the `get` method:

    moe = Person.get("moe@3stooges.com")

Searching is done using methods provided by Ruby's Enumerable module. This is
**very** fast for the small datasets that Prequel is designed for.

    larry = Person.first {|p| p[:name] =~ /Larry/}
    stooges = Person.find {|p| p[:email] =~ /stooge/}

The ActiveModelSupport module makes your models work like Active Record:

    class Person
      extend Prequel::Model
      include Prequel::ActiveModelSupport

      attr_accessor :name, :email, :slug
      attr_id :email

      before_save :set_slug

      validates_presence_of :name
      validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

      def to_param
        slug
      end

      def set_slug
        self.slug = name.to_slug.normalize!(true)
      end
    end

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

## License

Copyright (c) 2010 Norman Clarke

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
