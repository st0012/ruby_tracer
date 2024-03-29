> **Warning**
> This project has been moved to [`ruby/tracer`](https://github.com/ruby/tracer)

# ruby_tracer

ruby_tracer is an extraction of [`ruby/debug`](https://github.com/ruby/debug)'s [powerful tracers](https://github.com/ruby/debug/blob/master/lib/debug/tracer.rb), with user-facing APIs, IRB-integration, and improvements on accuracy.

## Installation

```shell
$ bundle add ruby_tracer --group=development,test
```

If bundler is not being used to manage dependencies, install the gem by executing:

```shell
$ gem install ruby_tracer
```

## Usage

```rb
Tracer.trace(object) { ... } # trace object's activities in the given block
Tracer.trace_call { ... } # trace method calls in the given block
Tracer.trace_exception { ... } # trace exceptions in the given block
```

**Example**

```rb
require "ruby_tracer"

obj = Object.new

def obj.foo
  100
end

def bar(obj)
  obj.foo
end

Tracer.trace(obj) { bar(obj) }
 #depth:1  #<Object:0x000000010903c190> is used as a parameter obj of Object#bar at test.rb:13:in `block in <main>'
 #depth:2  #<Object:0x000000010903c190> receives .foo at test.rb:10:in `bar'
```

### `ruby_tracer/helper`

If you want to avoid the `Tracer` namespace, you can do `require "ruby_tracer/helper"` instead:

```rb
require "ruby_tracer/helper"

trace(object) { ... } # trace object's activities in the given block
trace_call { ... } # trace method calls in the given block
trace_exception { ... } # trace exceptions in the given block
```

### IRB-integration

Once required, `ruby_tracer` registers a few IRB commands to help you trace Ruby expressions:

```
trace              Trace the target object (or self) in the given expression. Usage: `trace [target,] <expression>`
trace_call         Trace method calls in the given expression. Usage: `trace_call <expression>`
trace_exception    Trace exceptions in the given expression. Usage: `trace_exception <expression>`
```

**Example**

```rb
# test.rb
require "ruby_tracer"

obj = Object.new

def obj.foo
  100
end

def bar(obj)
  obj.foo
end

binding.irb
```


```
irb(main):001:0> trace obj, bar(obj)
 #depth:23 #<Object:0x0000000107a86648> is used as a parameter obj of Object#bar at (eval):1:in `<main>'
 #depth:24 #<Object:0x0000000107a86648> receives .foo at test.rb:10:in `bar'
=> 100
irb(main):002:0> trace_call bar(obj)
 #depth:23>                            Object#bar at (eval):1:in `<main>'
 #depth:24>                             #<Object:0x0000000107a86648>.foo at test.rb:10:in `bar'
 #depth:24<                             #<Object:0x0000000107a86648>.foo #=> 100 at test.rb:10:in `bar'
 #depth:23<                            Object#bar #=> 100 at (eval):1:in `<main>'
=> 100
```

### Tracer Classes

If you want to have more control over individual traces, you can use individual tracer classes:

#### ObjectTracer

```rb
class User
  def initialize(name) = (@name = name)

  def name() = @name
end

def authorized?(user)
  user.name == "John"
end

user = User.new("John")
tracer = ObjectTracer.new(user)
tracer.start do
  user.name
  authorized?(user)
end

 #depth:3  #<User:0x000000010696cad8 @name="John"> receives #name (User#name) at test.rb:14:in `block in <main>'
 #depth:3  #<User:0x000000010696cad8 @name="John"> is used as a parameter user of Object#authorized? at test.rb:15:in `block in <main>'
 #depth:4  #<User:0x000000010696cad8 @name="John"> receives #name (User#name) at test.rb:8:in `authorized?'
```

#### ExceptionTracer

```rb
ExceptionTracer.new.start

begin
  raise "boom"
rescue StandardError
  nil
end

 #depth:1  #<RuntimeError: boom> at test.rb:4
```

#### CallTracer

```rb
class User
  def initialize(name) = (@name = name)

  def name() = @name
end

def authorized?(user)
  user.name == "John"
end

user = User.new("John")
tracer = CallTracer.new
tracer.start do
  user.name
  authorized?(user)
end

 #depth:4 >    block at test.rb:13
 #depth:5 >     User#name at test.rb:4
 #depth:5 <     User#name #=> "John" at test.rb:4
 #depth:5 >     Object#authorized? at test.rb:7
 #depth:6 >      User#name at test.rb:4
 #depth:6 <      User#name #=> "John" at test.rb:4
 #depth:6 >      String#== at test.rb:8
 #depth:6 <      String#== #=> true at test.rb:8
 #depth:5 <     Object#authorized? #=> true at test.rb:9
 #depth:4 <    block #=> true at test.rb:16
```

#### LineTracer

```rb
class User
  def initialize(name) = (@name = name)

  def name() = @name
end

def authorized?(user)
  user.name == "John"
end

user = User.new("John")
tracer = LineTracer.new
tracer.start do
  user.name
  authorized?(user)
end

 #depth:4  at test.rb:14
 #depth:4  at test.rb:15
 #depth:5  at test.rb:8
```

## Customization

TBD

## Acknowledgement

[@ko1](https://github.com/ko1) (Koichi Sasada) implemented the majority of [`ruby/debug`](https://github.com/ruby/debug), including its tracers. So this project wouldn't exist without his amazing work there.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test-unit` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/st0012/ruby_tracer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/st0012/ruby_tracer/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ruby::Tracer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/st0012/ruby_tracer/blob/master/CODE_OF_CONDUCT.md).
