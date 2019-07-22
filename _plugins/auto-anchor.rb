# frozen_string_literal: true

## Automatically add id tags to list items that are formatted like one
## of the following:
# - **<Summary:** Details
# - *<Summary:* Details
# - [Summary][]: Details
# - [Summary](URL): Details

Jekyll::Hooks.register :documents, :pre_render do |post|
  ## Don't process documents if YAML headers say: "auto_id: false"
  if post.data["auto_id"] != false
    post.content.gsub!(/^ *- .*/) do |string|
      ## List items surrounded in bold
      title = string.match(/\*\*.*\*\*/).to_s
      ## List items surrounded in italics
      title.empty? && title = string.match(/\*.*\*/).to_s
      ## List items that are hyperlinks
      title.empty? && title = string.match(/\[.*\][(\[]/).to_s

      if title.empty?
        ## No match, pass item through unchanged
        string
      else
        ## Remove double-quotes from titles before attempting to slugify
        title.gsub!('"', '')
        ## Use Liquid/Jekyll slugify filter to choose our id
        id_prefix = '- {:#{{ "' + title + '" | slugify }}} '
        string.sub!(/-/, id_prefix)
      end
    end
  end
end
