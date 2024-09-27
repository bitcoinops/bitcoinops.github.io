def generate_slug(title)
  ## Remove double-quotes from titles before attempting to slugify
  title.gsub!('"', '')
  ## Use Liquid/Jekyll slugify filter to choose our id
  liquid_string = "\#{{ \"#{title}\" | slugify: 'latin' }}"
  slug = Liquid::Template.parse(liquid_string)
  # An empty context is used here because we only need to parse the liquid
  # string and don't require any additional variables or data.
  slug.render(Liquid::Context.new) 
end