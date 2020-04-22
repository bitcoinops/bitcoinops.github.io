# frozen_string_literal: true

## Automatically add id tags to list items that are formatted like one
## of the following:
# - **<Summary:** Details
# - *<Summary:* Details
# - [Summary][]: Details
# - [Summary](URL): Details

Jekyll::Hooks.register :documents, :pre_render do |post|
  ## Don't process documents if YAML headers say: "auto_id: false" or
  ## we're formatting for email
  unless post.data["auto_id"] == false || ENV['JEKYLL_ENV'] == 'email'
    post.content.gsub!(/^ *- .*/) do |string|
      ## Find shortest match for **bold**, *italics*, or [markdown][links]
      title = string.match(/\*\*.*?\*\*|\*.*?\*|\[.*?\][(\[]/).to_s

      if title.empty?
        ## No match, pass item through unchanged
        string
      else
        ## Remove double-quotes from titles before attempting to slugify
        title.gsub!('"', '')
        ## Use Liquid/Jekyll slugify filter to choose our id
        slug = "\#{{ \"#{title}\" | slugify: 'latin' }}"
        id_prefix = "- {:#{slug} .anchor-list} <a href=\"#{slug}\" class=\"anchor-list-link\">●</a>"
        string.sub!(/-/, id_prefix)
      end
    end
  end
end
