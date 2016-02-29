# Resolvable

Resolve your successful and failed actions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resolvable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resolvable

## Usage

```ruby
class SendDelicateMessage
  include Resolvable

  def perform_the_delicate_send!
    begin
      perform_the_delicate_send
      success!
    rescue => e
      failure!
    end
  end
end

delicate_sender = SendDelicateMessage.new
delicate_sender.perform_the_delicate_send!

if delicate_sender.success?
  # yay
else
  # boo
end
```

### Coming soon: OpenStructShim

Maybe you have a lot of open structs hanging around in your codebase, and you want to start to migrate those:

```ruby
class DelicateResult < Resolvable::OpenStructShim; end

begin
  perform_the_delicate_send
  return DelicateResult.new(:success? => true)
rescue => e
  return DelicateResult.new(:success? => false, :important_context => "It failed")
end
```

Or maybe you already subclassed OpenStruct in a weird and interesting way, and you want to migrate those, too:

```ruby
class Success < Resolvable::OpenStructShim
  automatic :success!
end

class Failure < Resolvable::OpenStructShim
  automatic :failure!
end

begin
  perform_the_delicate_send
  return Success.new(:important_context => "It worked")
rescue => e
  return Failure.new(:important_context => "It failed")
end

```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xionon/resolvable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

