# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  SimpleCov.add_filter "test/"
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rx"

require "minitest/autorun"
require "minitest/mock"
