# ActiveConformity

[![Join the chat at https://gitter.im/dandlezzz/active_conformity](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dandlezzz/active_conformity?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
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
 	belongs_to :engine
 	#attrs :size
 end

 class Engine

 end
 ```

In this example you have a database full of different engines. Each car instance has an engine. If you want ensure that the diesel engine is on a car of a size 2000 you have a couple of options.

```
class Car
  belongs_to :engine
  validate :proper_engine

    def proper_engine
    	return true if size >= 2000 && engine.name == "diesel"
        errors.add("car is too small for diesel engine")
    end
end

```

This works but can become very complex if you have lots of engines and each with their own special requirements of the car. ActiveConformity provides a way to add these conditions to your database, as json, and then run the validations from the persisted json, that json is referred to as a conformity_set.

```
diesel_engine = Engine.find_by(name: "diesel")
diesel_engine.add_conformity_set!( {size: {:numericality => { :greater_than => 2000} } }, conformist_type: "Car")

car = Car.create!(size: 2000, engine: diesel_engine)
car.conforms? # true
car2 = Car.create!(size: 1000, engine: diesel_engine)
car2.conforms? # false
car2.conformity_errors # [{size: "car is too small for diesel engine"}]

```

The add_conformity_set! method saves the json to your database any time  a car has a diesel engine, calling .conforms? will check the car's size to ensure it can accomodate the diesel engine.

##

Please note, lack of conformity does not prevent persistence as it does with .valid? in Rails. It is suggested that you implement this in a callback on the model.

##

ActiveConformity refers to the objects that tell other objects what do as conformables and the objects that are being told what to do as conformists. In the example above, the car is the conformist and the engine is the conformable.

There are several methods available to inspect what makes an object on conform. In the previous example if you want to see all of the rules the car most conform to you can do the following.

```
car.aggregate_conformity_set # {:size=> {:numericality => { :greater_than => 2000} } }
```

This shows all of the validations that the model will have to run through when .conforms? is called.

##

In order to debug conformity errors, ActiveConformity provides several methods to query the database in order to get a better understanding of why the object conforms or does not.

```
car.conformable_references #returns [diesel_engine]
```
The conformable references returns a list of all the objects that the car gets a conformity set from. Additionally, for even more fine grained debugging you can call
```
car.conformity_sets_by_reference # {"Engine id: 1" =>{:size=> {:numericality => { :greater_than => 2000} } } }
```
This returns a complex hash that shows the id of all of the objects mapped to their individual conformity_set.

##




## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/active_conformity/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Help and Inspiration
Thanks to [Dan Barrett](https://github.com/thoughtpunch) who has provided guidance and inspiration for this project.
