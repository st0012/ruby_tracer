# ruby_tracer

ruby_tracer is an extraction of [`ruby/debug`](https://github.com/ruby/debug)'s [powerful tracers](https://github.com/ruby/debug/blob/master/lib/debug/tracer.rb), with improved APIs for direct use or library integration.

Its goal is to help users understand their Ruby programss activities by emitting useful trace information, such us:

- How and where is the target object is being used (`ObjectTracer`)
- What exceptions are raised during the execution (`ExceptionTracer`)
- When method calls are being performed (`CallTracer`)
- Line execution (`LineTracer`)

## Installation

```shell
$ bundle add ruby_tracer --group=development,test
```

If bundler is not being used to manage dependencies, install the gem by executing:

```shell
$ gem install ruby_tracer
```

## Usage

### CallTracer

### LineTracer

### ExceptionTracer

### ObjectTracer

```rb
user = User.new
tracer = ObjectTracer.new(user)
tracer.start do
  user.name 
  authorize(user)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test-unit` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ruby-tracer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/ruby-tracer/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ruby::Tracer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ruby-tracer/blob/master/CODE_OF_CONDUCT.md).
