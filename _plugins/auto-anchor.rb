# frozen_string_literal: true

## Automatically add id tags to list items that are formatted like one
## of the following:
# - **<Summary:** Details
# - *<Summary:* Details
# - [Summary][]: Details
# - [Summary](URL): Details

def generate_anchor_list_link(anchor_link)
  # custom clickable bullet linking to an anchor
  "<a href=\"#{anchor_link}\" class=\"anchor-list-link\">●</a>"
end

def auto_anchor(content)
    content.gsub!(/^ *- .*/) do |string|
      ## Find shortest match for **bold**, *italics*, or [markdown][links]
      title = string.match(/\*\*.*?\*\*|\*.*?\*|\[.*?\][(\[]/).to_s

      if title.empty?
        ## No match, pass item through unchanged
        string
      else
        slug = generate_slug(title)
        id_prefix = "- {:#{slug} .anchor-list} #{generate_anchor_list_link(slug)}"
        string.sub!(/-/, id_prefix)
      end
    end
end

## Run automatically on all documents
Jekyll::Hooks.register :documents, :pre_render do |post|
  ## Don't process documents if YAML headers say: "auto_id: false" or
  ## we're formatting for email
  unless post.data["auto_id"] == false || ENV['JEKYLL_ENV'] == 'email'
    auto_anchor(post.content)
  end
end

## Block filter that provides {% auto_anchor %}{% endauto_anchor %} for
## use on {% include %} files
module Jekyll
  class RenderAutoAnchor < Liquid::Block

    def render(context)
      text = super
      text = auto_anchor(text)
      text = Liquid::Template.parse(text)
      text.render(@context)
    end

  end
end

Liquid::Template.register_tag('auto_anchor', Jekyll::RenderAutoAnchor)

module TextFilter
  # This is a custom filter used in `optech-mentions.html`
  # to add anchor links to each backlink snippet
  def link_to_anchor(text, url)
    id_prefix = generate_anchor_list_link(url)
    if text.start_with?("-")
      # snippet is already a list item
      text.sub!(/-/, id_prefix)
    else
      text.prepend("#{id_prefix} ")
    end
    text
  end
end

Liquid::Template.register_filter(TextFilter)
