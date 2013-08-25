#!/usr/bin/env ruby

require 'yaml'

home = File.dirname(__FILE__)

ARGV.each do |arg|
  puts (YAML::load_file(arg).to_yaml)
end
