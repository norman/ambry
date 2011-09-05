require "rubygems"
require "bundler/setup"
require "benchmark"
require "ffaker"
require "ambry"

N = 500

class Person
  extend Ambry::Model
  field :email, :name, :age

  def self.younger_than(age)
    with_index("younger_than_#{age}") do
      find {|person| person[:age] < age}
    end
  end

  filters do
    def older_than(age)
      find {|person| person[:age] > age}
    end

    def email_matches(regexp)
      find {|person| person[:email] =~ regexp}
    end

  end
end

until Person.count == 1000 do
  Person.create \
    :name  => Faker::Name.name,
    :email => Faker::Internet.email,
    :age   => rand(100)
end

keys = Person.all.keys.sort do |a, b|
  rand(100) <=> rand(100)
end[0,10]

Benchmark.bmbm do |x|

  puts "Benchmarking #{N} times:\n\n"

  x.report("Count records") do
    N.times do
      Person.count {|p| p[:email] =~ /\.com/}
    end
  end

  x.report("Count scoped records") do
    N.times do
      Person.older_than(50).count
    end
  end

  x.report("Get 10 random keys") do
    N.times do
      keys.each {|k| Person.get(k)}
    end
  end

  x.report("Find records iterating on values") do
    N.times do
      Person.find {|p| p[:email] =~ /\.com/}
    end
  end

  x.report("Find records using proxy method") do
    N.times do
      Person.find {|p| p.email =~ /\.com/}
    end
  end

  x.report("Find records iterating on keys") do
    N.times do
      Person.find_by_key {|k| k =~ /\.com/}
    end
  end

  x.report("Find scoped people without index") do
    N.times do
      Person.find {|p| p[:age] < 50 && p[:email] =~ /\.com/}
    end
  end

  x.report("Find scoped people with index") do
    N.times do
      Person.younger_than(50).find {|p| p[:email] =~ /\.com/}
    end
  end

  x.report("Find with chained filters") do
    N.times do
      Person.older_than(50).email_matches(/\.com/)
    end
  end

  x.report("Find records iterating on keys and using scope") do
    N.times do
      Person.find_by_key {|k| k =~ /\.com/}.older_than(50)
    end
  end
end
