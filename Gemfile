source 'https://rubygems.org'

## If you update the version here, also update it in .travis.yml, .ruby-version,
## and README.md. Then push your branch and make sure Travis supports that
## version.
ruby '~> 3.4.0'

## If you add a new Gem below, run `bundle install` to install it.
group :development do
  gem 'jekyll'
  gem 'logger'  # Required by Jekyll, will be removed from default gems in Ruby 3.5
  gem "minima", "~> 2.0"  ## Default Jekyll theme
  gem 'jekyll-redirect-from'
end

group :testing do
  gem 'html-proofer'
  gem 'mdl'
  gem 'json-schema'
  gem 'toml'
end
