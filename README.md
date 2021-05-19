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

Add `rx` to your Gemfile, and then create a new initializer with this content:

```ruby
Rails.application.config.middleware.insert(Rx::Middleware)
```

### Rack Applications

Coming soon.

### Configuring Dependencies

Now that you're running `rx`, you will need to configure which dependencies it tests in each health check. You can do this by passing `Rx::Check` objects to the middleware. `rx` ships with a number of standard checks:

- Filesystem health
- ActiveRecord
- Redis
- HTTP

In addition to the stock checks, you may create your own by TODO.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rx.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
