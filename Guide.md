# The Prequel Guide

By [Norman Clarke](http://njclarke.com)

## What is Prequel?

Prequel is a database and ORM replacement for small, mostly static models. In
many applications or libraries, you need models for datasets like the 50 US
states, the world's countries with associated TLDs, or a list of phone number
prefixes and their associated state, province or city.

Creating a model with Active Record, DataMapper or another ORM and storing this
data in an RDBMS is usually overkill for small and/or static datasets. On the
other hand, storing the data in ad-hoc strutures can offer little flexibility
when it comes to filtering, or establishing relations with models.

Prequel offers a middle ground: it makes use of Ruby's Enumerable module to
expose a powerful, ORM-like query interface to Ruby's Hash. It can operate
entirely in-memory, or persist data in a file or a compressed, signed string
suitable for passing as a cookie.

## An example

class Country
  field :tld, :name, :region, :population, :area
  filters do
    def african
      find {|c| c.region == :africa}
    end
    
    def large
      find {|c| c.area >= 100_000}
    end
  end
end

## Creating Models

### Setting up a simple model class

### Basic operations on models

#### CRUD

#### Filters

#### Indexes

### Active Model

## Mappers and Adapters

### Bundled adapters

#### Prequel::Adapter

#### Prequel::Adapters::File

#### Prequel::Adapters::YAML

#### Prequel::Adapters::Cookie

## Extending Prequel

### Adding functionality to Prequel::Model

### Creating your own adapter

