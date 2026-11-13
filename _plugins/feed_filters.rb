# frozen_string_literal: true

## Remove the self-referencing bullets that auto-anchor.rb prepends to list
## items (currently a "●", but the icon is not important here).  Each bullet
## points at a fragment (#some-heading) inside the same newsletter, which is
## not useful once the content is syndicated: the fragment only resolves if
## the reader implements xml:base, and readers such as Liferea do not, so the
## bullets show up as broken links.
## See https://github.com/bitcoinops/bitcoinops.github.io/issues/399
module Jekyll
  module FeedFilters
    ANCHOR_LIST_LINK = %r{<a href="#[^"]*" class="anchor-list-link">[^<]*</a>[ \t]*}

    def strip_anchor_list_links(content)
      content.to_s.gsub(ANCHOR_LIST_LINK, "")
    end
  end
end

Liquid::Template.register_filter(Jekyll::FeedFilters)
