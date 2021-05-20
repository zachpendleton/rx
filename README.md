# Rx

Rx is a Rack middleware that provides tiered health checks to any Rack application, including Rails-based apps.

## Tiered Health Checks

What is a tiered health check? I'm glad you asked! Health checks serve different purposes:

- Some are used by load balancers to ensure that a server is capable of serving traffic
- Some are used by other applications to verify the health of your service as a dependency
- Some are used by customers or status pages to determine uptime

These use cases are all similar, but may require different levels of verification. One may require your service to just return 200, while another may need to check connectivity to the database, cache, or external services.

Rx provides three levels of health checks:

1. `/liveness`: A health check that determines if the server is running.
2. `/readiness`: Readiness checks determine if critical, dependent services are running (think a database or cache)
3. `/deep`: A health check that walks your entire dependency tree, checking other critical and secondary services.

### Rails Applications

Add `rx` to your Gemfile, and then create a new initializer with something like this:

```ruby
Rails.application.config.middleware.insert(
  Rx::Middleware,
  {
    liveness: [Rx::Check::FileSystemCheck.new],
    readiness: [
      Rx::Check::FileSystemCheck.new,
      Rx::Check::ActiveRecordCheck.new,
      Rx::Check::HttpCheck.new("http://example.com"),
      Rx::Check::GenericCheck.new(-> { $redis.ping == "PONG" }, "redis")],
    deep: {
      critical: [Rx::Check::HttpCheck.new("http://criticalservice.com/health")],
      secondary: [Rx::Check::HttpCheck.new("http://otherservice.com/health-check")]
    }
  })
```

### Configuring Dependencies

Now that you're running `rx`, you will need to configure which dependencies it tests in each health check. You can do this by passing `Rx::Check` objects to the middleware. `rx` ships with a number of standard checks:

- Filesystem health
- ActiveRecord
- HTTP
- Generic Check

In addition to the stock checks, you may create your own by copying an existing check
and modifying it (though it's probably simpler to just use GenericCheck).

`RX::Middleware` expects a configuration object in the following format:

```ruby
{
  liveness: [],
  readiness: [],
  deep: {
    critical: [],
    secondary: []
  }
}
```

Each collection must contain 0 or more `Rx::Check` objects. Those checks will be performed when the health check is queried.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zachpendleton/rx.

Some tips for developing the gem locally:

* Tests can be run by calling `rake`
* You can point your Rails app to a local gem by adding a `path` option to your Gemfile, a la `gem "rx", path: "path/to/rx" (though you _will_ need to restart Rails whenever you change the gem).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
