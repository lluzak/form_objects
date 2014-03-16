require 'bundler/setup'
require 'pry'

Bundler.setup

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'form_objects'
require 'support/examples'
