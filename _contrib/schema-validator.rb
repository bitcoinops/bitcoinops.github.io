#!/usr/bin/env ruby
# This file is licensed under the MIT License (MIT) available on
# http://opensource.org/licenses/MIT.

require 'yaml'
require 'toml'
require 'json-schema'

if ARGV[1].nil?
  puts "Usage: schema-validator.rb <schema-file> <file-to-validate>"
  puts "Schema file must be YAML; the file to validate may end with:"
  puts "  - .yaml (YAML)"
  puts "  - .md (YAML)"
  puts "  - .toml (TOML)"
  exit(255)
end

schema_file = ARGV[0]
to_validate = ARGV[1]

file = File.open(schema_file, 'r')
schema = YAML.load(file)
file.close()

file = File.open(to_validate, 'r')
if to_validate.end_with?(".yaml") or to_validate.end_with?(".md")
  document = YAML.load(file)
elsif to_validate.end_with?(".toml")
  document = TOML.load_file(file)
else
  raise "Unknown file type.  Only .yaml and .toml supported"
end
file.close()

results = JSON::Validator.fully_validate(schema, document)

if results.empty?
  exit(0)
else
  puts ARGV[1]
  puts results
  exit(1)
end
