# kurosawa.rb

![Kurosawa Ruby](https://github.com/astrobunny/kurosawa.rb/raw/master/docs/images/kurosawa-ruby.jpg)

A RESTful JSON-based database for eventually-consistent filesystem backends. Uses the REST path to determine object hierarchy.

# THIS DATABASE IS STILL IN ALPHA

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kurosawa'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kurosawa

## Usage

Run the server

```
KUROSAWA_FILESYSTEM=file://fs/db bundle exec kurosawa
```

Send it REST commands! (Here I am using resty)

```
$ GET /
null
$ PUT / '{"a": 7, "b": {"e":[100,200,300]} }'
{"a":"7","b":{"e":["300","200","100"]}}
$ GET /
{"a":"7","b":{"e":["300","200","100"]}}
$ GET /a/b
null
$ GET /a
"7"
$ GET /b
{"e":["300","200","300","140","100","200"]}
$ GET /b/e
["300","200","300","140","100","200"]
$ PATCH / '{"c": "Idols"}'
{"a":"7","b":{"e":["300","200","300","140","100","200"]},"c":"Idols"}
$ GET /c
"Idols"
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/astrobunny/kurosawa.

