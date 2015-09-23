# ActiveConformity
[![Code Climate](https://codeclimate.com/github/dandlezzz/active_conformity/badges/gpa.svg)](https://codeclimate.com/github/dandlezzz/active_conformity)

Your favorite rails validations driven not by code but by your data.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_conformity'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_conformity

## Usage

ActiveConformity comes with a helpful install generator.

	$ rails g active_conformity:install

 This will generate a migration for you that creates the conformables table. The table responsible for storing all of the validation data. Additionally, it will create a module in your lib file where you can write custom validation methods.


 ActiveConformity is for use when validating if objects are of a specific composition.
 For example, lets say you have the following model structure:

 ```
 class Car
 	has_one :engine
 	#attrs :size
 end

 class Engine
 	belongs_to :car
 end
 ```

In this example you have a database full of different engines and wheelsets. Each car model has a link to these things. If you want ensure that the diesel engine is on a car of a size 2000 you have a couple of options.

```
class Car
	has_one :engine
    validate :proper_engine

    def proper_engine
    	return true if size >= 2000 && engine.name == "diesel"
        errors.add("car is too small for diesel engine")
    end
end

```

This works but can become very complex if you have lots of engines and even more complicated conditions. ActiveConformity provides a way to add these conditions to your database, as json.

```
diesel_engine = Engine.find_by(name: "diesel")
diesel_engine.add_conformity_set!( {size: {:numericality => { :greater_than => 2000} } }, conformist_type: "Car")

car1 = Car.create!(size: 2000, engine: diesel_engine)
car1.conforms? # true
car2 = Car.create!(size: 1000, engine: diesel_engine)
car2.conforms? # false
car2.conformity_errors # [{size: "car is too small for diesel engine"}]

```

The add_conformity_set! method saves the json to your database any time  a car has a diesel engine, calling .conforms? will check the car's size to ensure it can accomodate the diesel engine.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/active_conformity/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
