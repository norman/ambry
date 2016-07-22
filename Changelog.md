# Ambry Changelog

## [1.0.0](https://github.com/norman/ambry/tree/1.0.0) - 2016-07-22 ([diff](https://github.com/norman/ambry/compare/0.3.1...1.0.0))

* Make ambry compatible with Rails 5
* Drop `ActiveModel::Serializers::Xml` support

## [0.3.1](https://github.com/norman/ambry/tree/0.3.1) - 2012-06-20 ([diff](https://github.com/norman/ambry/compare/0.3.0...0.3.1))

### [Norman Clarke](https://github.com/norman)

* Remove default :main adapter in Rail initializer.


## [0.3.0](https://github.com/norman/ambry/tree/0.3.0) - 2012-03-15 ([diff](https://github.com/norman/ambry/compare/0.2.4...0.3.0))

### [Norman Clarke](https://github.com/norman)

* Don't raise from finds using hash proxy when a key has a falsy value
* Remove cookie adapter; keep Ambry focused on its core mission.
* Fixed bug which allowed invalid records to be saved with Active Model. Thanks Tute Costa for reporting.

## [0.2.4](https://github.com/norman/ambry/tree/0.2.4) - 2011-10-07 ([diff](https://github.com/norman/ambry/compare/0.2.3...0.2.4))

### [Norman Clarke](https://github.com/norman)

* Add #key? to mappers and models

## [0.2.3](https://github.com/norman/ambry/tree/0.2.3) - 2011-10-07 ([diff](https://github.com/norman/ambry/compare/0.2.2...0.2.3))

### [Norman Clarke](https://github.com/norman)

* Make cookie adapter's cookie name configurable

### [Norman Clarke](https://github.com/norman)

* Allow middleware to accept a Proc
* Add ability to remove an adapter

## [0.2.2](https://github.com/norman/ambry/tree/0.2.2) - 2011-09-21 ([diff](https://github.com/norman/ambry/compare/0.2.1...0.2.2))

### [Norman Clarke](https://github.com/norman)

* Allow middleware to accept a Proc
* Add ability to remove an adapter


## [0.2.1](https://github.com/norman/ambry/tree/0.2.1) - 2011-09-20 ([diff](https://github.com/norman/ambry/compare/0.2.0...0.2.1))

### [Norman Clarke](https://github.com/norman)

* Fix handling of attributes with falsy values


## [0.2.0](https://github.com/norman/ambry/tree/0.2.0) - 2011-09-05 ([diff](https://github.com/norman/ambry/compare/0.1.2...0.2.0))

### [Norman Clarke](https://github.com/norman)

* Always create a default in-memory adapter

## [0.1.2](https://github.com/norman/ambry/tree/0.1.1) - 2011-08-29 ([diff](https://github.com/norman/ambry/compare/0.1.1...0.1.2))

### [Norman Clarke](https://github.com/norman)

* Add read-only option to adapters

### [Luis Lavena](https://github.com/luislavena)

* Load Marshal data as binary


## [0.1.1](https://github.com/norman/ambry/tree/0.1.1) - 2011-08-24 ([diff](https://github.com/norman/ambry/compare/0.1.0...0.1.1))

### [Esad Hajdarevic](https://github.com/esad)

* Allow attribute keys to be strings
* Pass key as attribute when loading database. This allows you to avoid specifying the key twice when manually editing a YAML file.
* Remove use of String#blank? to avoid depending on Active Support

### [Ignacio Carrera](https://github.com/nachokb)

* Added #last and #inspect


## [0.1.0](https://github.com/norman/ambry/tree/0.1.0) - 2011-08-18

Initial release.
