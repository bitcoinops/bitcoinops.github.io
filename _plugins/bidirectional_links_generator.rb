# frozen_string_literal: true
# This file is based on code from https://github.com/maximevaillancourt/digital-garden-jekyll-template
# Generators run after Jekyll has made an inventory of the existing content,
# and before the site is generated.

# Newsletter mentions of a topic were historically manually added to each
# topic's page under `optech_mentions`. This enchances the exisiting logic
# by allowing for automatic mentions using the double-bracket link syntax.
class BidirectionalLinksGenerator < Jekyll::Generator
    def generate(site)
      # This is only supported for english
      lang = "en"
      all_pages = site.documents.select { |doc| doc.url.start_with?("/#{lang}/") }
      # pages that contain the double-bracket link syntax `[[]]` are only a subset
      # of all the pages
      pages_with_link_syntax = all_pages.select { |page| page.content.match(/\[\[.*?\]\]/) }
      # indexed pages are the only pages that newsletters might mention
      indexed_pages = site.collections["topics"].docs + site.collections["people"].docs

      # Convert all Wiki/Roam-style double-bracket link syntax to plain HTML
      # anchor tag elements (<a>)
      pages_with_link_syntax.each do |current_page|
        indexed_pages.each do |page_potentially_linked_to|
          page_title_regexp_pattern = Regexp.escape(
            File.basename(
              page_potentially_linked_to.basename,
              File.extname(page_potentially_linked_to.basename)
            )
          ).gsub('\_', '[ _]').gsub('\-', '[ -]').capitalize
  
          title_from_data = title_from_data_escaped = page_potentially_linked_to.data['title']
          if title_from_data
            title_from_data_escaped = Regexp.escape(title_from_data)
          end

          new_href = "#{site.baseurl}#{page_potentially_linked_to.url}"
          title_anchor_tag = "<a href='#{new_href}'>#{title_from_data}</a>"
          anchor_tag = "<a href='#{new_href}'>\\1</a>"


          # Replace double-bracketed links that use topic's title with the given label
          # [[coin selection|this is a link to coin selection]] => [this is a link to coin selection](/topics/coin-selection)
          current_page.content.gsub!(
            /\[\[#{page_title_regexp_pattern}\|(.+?)(?=\])\]\]/i,
            anchor_tag
          )
  
          # Replace double-bracketed links that use topic's filename with the given label
          # [[coin-seletion|this is a link to coin selection]] => [this is a link to coin selection](/topics/coin-selection)
          current_page.content.gsub!(
            /\[\[#{title_from_data_escaped}\|(.+?)(?=\])\]\]/i,
            anchor_tag
          )
  
          # Replace double-bracketed links that use topic's title
          # [[coin selection]] => [coin selection](/topics/coin-selection)
          # [[Coin selection]] => [Coin selection](/topics/coin-selection)
          current_page.content.gsub!(
            /\[\[(#{title_from_data_escaped})\]\]/i,
            anchor_tag
          )
  
          # Replace double-bracketed links that use topic's filename with topic's title
          # [[bnb]] => [Branch and Bound (BnB)](/topics/bnb)
          current_page.content.gsub!(
            /\[\[(#{page_title_regexp_pattern})\]\]/i,
            title_anchor_tag
          )
        end
  
        # At this point, all remaining double-bracket-wrapped words are
        # pointing to non-existing pages, so let's turn them into disabled
        # links by greying them out and changing the cursor
        current_page.content = current_page.content.gsub(
          /\[\[([^\]]+)\]\]/i, # match on the remaining double-bracket links
          <<~HTML.delete("\n") # replace with this HTML (\\1 is what was inside the brackets)
            <span title='There is no page that matches this link.' class='invalid-link'>
              <span class='invalid-link-brackets'>[[</span>
              \\1
              <span class='invalid-link-brackets'>]]</span></span>
          HTML
        )
      end

      # we need the topic links for manual substitutions of links later on 
      @topics_links = site.collections["topics"].map do |topic|
        ["topic #{topic.data["shortname"] || topic.data["title"]}", topic.url]
      end

      # Newsletter mentions
      # =====================
      newsletter_pages = pages_with_link_syntax.select { |doc| doc.url.start_with?("/#{lang}/newsletters/") }
      # Identify page backlinks and add them to each page
      indexed_pages.each do |current_page|
        target_page_href = "href='#{current_page.url}'"

        # Iterate over all pages to find mentions of the current page
        newsletter_pages.each do |page_in_question|
          # Check if the current page is mentioned in the content of the page in question
          if page_in_question.content.include?(target_page_href)
            # The page_in_question mentions the current page, we now need to 
            # find the specific mentions.
            mentions = get_mentions_of(page_in_question, target_page_href, current_page.collection.label)
            current_page.data["optech_mentions"] ||= []  # Initialize if not already present
            # Add the calculated mentions to `optech_mentions`
            # Note: a page might mentioning another page more than once
            mentions.each do |mention|
              current_page.data["optech_mentions"] << mention
            end
          end
        end
      end

      # Podcast appearances
      # =====================
      podcast_pages = pages_with_link_syntax.select { |doc| doc.url.start_with?("/#{lang}/podcast/") }.reverse
      people_pages = site.collections["people"].docs

      people_pages.each do |person|
        podcast_mentions = []
        # Iterate over podcast pages to find mentions of people
        podcast_pages.each do |podcast|
          podcast_intro = podcast.content.each_line.first.chomp
          if podcast_intro.include?("href='#{person.url}'")
            podcast_mentions << {"title"=> podcast.title, "url"=> podcast.url}
            # the excerpt of pages is calculated by Jekyll before generators run
            # therefore we need to override the excerpt to remove [[]]
            podcast.excerpt.content = podcast_intro
          end
        end
        person.data["podcast_mentions"] = podcast_mentions
      end
    end

    def liquify(content, date)
      context = Liquid::Context.new({}, {}, { site: Jekyll.sites.first })
      context['page'] = { 'date' => date } # needed to identify deprecated_links
      template = Liquid::Template.parse(content)
      content_parsed = template.render(context)
    end

    def get_external_links(page)
      # this assumes that a "{% include {references, linkers/issues}.md %}" line
      # exists at the end of the documents and external links are declared after it

      # get all the references after the {% include _ %} line
      regex_for_first_include = /\{% include (?:references\.md|linkers\/issues\.md).*?%\}/
      references = page.content.split(regex_for_first_include, 2).last.strip
      references.prepend("{% include references.md %}\n")

      # manually trigger the replacement of the {% include %} tags in order to
      # have all the required links ([key]:url) needed for the matching snippets
      references_parsed = liquify(references, page.date)

      # Search for all occurrences of the pattern "[key]: url"
      # and return them in an array
      references_parsed.scan(/\[([^\]]+?)\]\s*:\s*(\S+)/i)
    end

    def find_title(string)
      title = capture_group = ""
      ## Find shortest match for **bold**, *italics*, or [markdown][links]
      title_match = string.match($title_pattern)
      title_match&.named_captures&.compact&.each do |key, value|
        capture_group = key # one of {bold, italics, markdown_link}
        title = value
      end

      if title.empty?
        {}
      else
        {"title"=> title, "capture_group"=> capture_group}
      end
    end

    def sanitize_title(title_hierarchy)
      # This is needed because for this plugin's logic, we use the same 
      # matching pattern for the title as in `auto-anchor.rb` in order to be
      # able to reproduce the slugs/anchors and therefore point to them.
      # This pattern matches the title of the paragraph by finding the shortest
      # match for **bold**, *italics*, or [markdown][links], but the matched
      # **bold** or *italics* might have nested [markdown][links].
      #
      # Note that the nested [markdown][links] actually become part of the slug
      # for example in /en/newsletter/2018-06-08/ the title 
      # "**[BIP174][BIP174] discussion and review ongoing:**" becomes
      # "#bip174-bip174-discussion-and-review-ongoing"
      #
      # In the case of `auto-anchor.rb` this doesn't matter because the title
      # will "markdownify" and transform into a link. But here, we extract the
      # title therefore we need to remove the second part
      #
      # We call unsanitized title, a title that has those nested 
      # [markdown][links]. The logic here, finds the pattern "[text][text]" 
      # or "[text](text)" and remove the second part
      title_hierarchy.each do |title|
        title.gsub!(/\[(.*?)\][(\[].*?[)\]]/, '\1')
      end
    end

    def extract_slug_from_manual_anchor(text)
      # sometimes the liquid anchor syntax is used to create anchors in the document
      # our extracted backlink snippets include those, therefore we need to
      # - remove liquid anchor syntax from the result
      # - extract slug to use it on the generated anchor list link
      # example of this pattern can be seen in `en/newsletter/2019-06-12-newsletter.md`
      match = text.match(/\{:#([\w-]+)\}/)
      if match
        slug = "##{match[1]}" # extract slug
        text.sub!(/#{match[0]}/, "") # Remove the matched {:#slug} syntax
        slug
      else
        nil
      end
    end

    # This method searches the content for paragraphs that link to the
    # the target page and returns these mentions
    def get_mentions_of(page, target_page_url, collection)
      # This is called only when we know that a match exists
      # The logic here assumes that:
      # - paragraphs have headers
      # - each block of text (paragraph) is seperated by an empty line 
      # - primary titles are enclosed in **bold**
      # - secondary (nested) titles are enclosed in *italics*

      content = page.content
      external_links = collection == "people" ? 
        get_external_links(page).reverse + @topics_links : [] # people-index specific

      # Split the content into paragraphs
      paragraphs = content.split(/\n\n+/)
      # Find all the headers in the content
      headers = content.scan(/^#+\s+(.*)$/).flatten

      # Create an array of hashes containing:
      # - the paragraph text
      # - the associated header
      # - the associated url
      # - the associated title (when is not part of the paragraph)
      matching_paragraphs = []
      current_header = 0
      current_title = []

      # Iterate over all paragraphs to find those that match the given url
      paragraphs.each do |p|
        # a title might have multiple paragraphs associated with it
        # an isolated paragraph snippet cannot access the title therefore
        # we keep this information to be used in backlinks
        title = find_title(p)
        if !title.empty?
          # paragraph has title
          if title["capture_group"] == "bold" or title["capture_group"] == "markdown_link"
            # when a new primary title is found, we reset the current_title array
            current_title = [title["title"]]
          elsif title["capture_group"] == "italics"
            # title is a nested title, we assign it as the 2nd element of the array
            # in order to keep the titles' hierarchy
            # [**primary title**, *secondary title*]
            current_title[1] = title["title"]
          end
        else
          # paragraph has no title, switch back to the last primary title
          # this covers the case when you have a nested secondary paragraph
          # but the mention is in a later paragraph (still nested under primary)
          # that has no title, therefore we need to default back to the last 
          # primary title, otherwise the title of the mention would also include
          # the secondary title which might be irrelevant 
          current_title = [current_title[0]]
        end

        # If the current paragraph contains the URL, add it to the matching paragraphs
        if p.include?(target_page_url)
          if collection == "people"
            # Loop through the array of [key]:url_replace matches and replace
            # - the occurrences of "[key][]" with "[key](url_replace)"
            # - the occurrences of "[something][key]" with "[something](url_replace)"
            external_links.each do |match|
              key_pattern = match[0].gsub(/\s/, '\s+') # to work with multiline keys
              p.gsub!(/\[(#{key_pattern})\]\[\]/im, "[\\1](#{match[1]})")
              p.gsub!(/\[(.+?)\]\[(#{key_pattern})\]/im, "[\\1](#{match[1]})")
            end
            # manually replace common liquid variables in paragraph
            p.gsub!(/#{Regexp.escape("{{bse}}")}/,"https://bitcoin.stackexchange.com/a/")
          end

          # generate slug for matching paragraph
          slug = extract_slug_from_manual_anchor(p)
          if slug.nil?
            # no manual anchor has been defined, so generate slug from title
            slug = generate_slug(current_title.last)
            # after generating the title-based slug we must sanitize the title,
            # this must be done after generating the title-based slug because
            # slugs are historically generated based on the unsanitize title
            sanitize_title(current_title)
          end  
          matching_paragraph = {
            # resulting title for the mention is "primary title: secondary title"
            "title"=> current_title.join(": "), 
            "url" => "#{page.url}#{slug}"
          }
          if collection == "people"
            # People index has verbosed mentions
            matching_paragraph.merge!({
              "paragraph"=> p.lstrip,
              "header"=> headers[current_header],
              "newsletter_number" => page.title.sub("Bitcoin Optech Newsletter #", "").to_i,
              "year" => File.basename(page.path)[0, 4]
            })

            if !title.empty?
              # paragraph has title
              # for the verbosed mentions we display the paragraph that contains
              # the mention (see `optech-mentions.html`), therefore we do not
              # need to repeat the title 
              current_title.pop # this way we keep the parent title
              matching_paragraph["title"] = current_title[0]
            end
          end
          matching_paragraphs << matching_paragraph
        end

        # update to the next header when parse through it
        if p.sub(/^#+\s*/, "") == headers[(current_header + 1) % headers.length()]
          current_header += 1
        end
      end
    
      # Return the matching paragraphs
      matching_paragraphs
    end
  end
