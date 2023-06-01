# frozen_string_literal: true

# Regex pattern to match "{% assign timestamp="xx:xx:xx" %}"
$podcast_reference_mark = /\{%\s*assign\s+timestamp\s*=\s*"([^"]+)"\s*%\}/

# Create the podcast recap references by parsing the referenced newsletter for
# podcast reference marks (timestamps)
class RecapReferencesGenerator < Jekyll::Generator
  priority :high
  def generate(site)
    podcast_pages = site.documents.select { |doc| doc.data["type"] == "podcast"}
    podcast_pages.each do |podcast|
      # podcast episodes have a "reference" field that indicates the related newsletter page 
      unless podcast.data["reference"].nil?
        reference_page = site.documents.detect { |page| page.url == podcast.data["reference"] }
        
        # override the content of the reference page (newsletter) to now include
        # the links to the related podcast items
        reference_page.content,
        # keep all the references in a podcast page variable to use them later 
        # during the podcast page creation
        podcast.data["references"] = get_podcast_references(reference_page.content, podcast.url)
        
        # we use this in `newsletter-references.md` to be easier to identify
        # special sections when iterating through the sections of the newsletter
        podcast.data["special_sections"] = []
        
        podcast.data["references"].each do |reference|
          if reference["title"].nil?
            # the title of a reference derives from the nested list items
            # under a header/section (News, Releases and release candidates, etc.)
            # if there are no list items, we end up with a missing title
            # we use this assumption to identify special sections
            podcast.data["special_sections"] << reference["header"]
            # use the header as the title of the section
            reference["title"] = reference["header"]
            reference["slug"] = generate_slug(reference["header"])
          end
          # Each podcast transcript splits into segements using the paragraph title
          # as the title of the segment. These segment splits must be added manually but
          # we can avoid the need to also manually add their anchors by doing that here,
          # where we effectivily search for the segment splits and prefix them with the anchor
          reference["has_transcript_section"] = 
            podcast.content.sub!(
              /^(_.*?#{Regexp.escape(reference["title"])}.*?_)/,
              "{:#{reference["slug"]}-transcript}\n \\1"
            )
        end
      end
    end
  end

  def find_title(string, in_list=true)
    # this conditional prefix is for the special case of the review club section
    # which is not a list item (no dash (-) at the start of the line)
    prefix = in_list ? / *- / : // 

    # Find shortest match for **bold**, or [markdown][links]
    # note: when we are matching the title in `auto-anchor.rb` we also match *italics*
    # but on the newsletter sections nested bullets have *italics* titles therefore
    # by ignoring *italics* we are able to easier link to the outer title
    title = string.match(/^#{prefix}(?:\*\*(.*?):?\*\*|\[(.*?):?\][(\[])/)&.captures&.compact&.[](0) || ""
    if title.empty?
      {}
    else
      result = {"title"=> title}
      slug = {"slug"=> generate_slug(title)}
      result.merge!(slug)
    end
  end

  # This method searches the content for paragraphs that indicate that they are
  # part of a podcast recap. When a paragraph is part of a recap we:
  # - postfix with a link to the related podcast item 
  # - get the header, title and title slug of the paragraph to create
  #   the references for the podcast
  def get_podcast_references(content, target_page_url)
    # The logic here assumes that:
    # - paragraphs have headers
    # - each block of text (paragraph) is seperated by an empty line 
      
    # Split the content into paragraphs
    paragraphs = content.split(/\n\n+/)
    # Find all the headers in the content
    headers = content.scan(/^#+\s+(.*)$/).flatten

    # Create an array of hashes containing:
    # - the paragraph's title
    # - the paragraph's title slug
    # - the associated header
    # - the timestamp of the podcast in which this paragraph is discussed
    podcast_references = []
    current_header = 0
    current_title = {}
    in_review_club_section = false

    # Iterate over all paragraphs to find those with a podcast reference mark
    paragraphs.each do |p|
      # a title might have multiple paragraphs associated with it
      # the podcast reference mark might be at the end of an isolated
      # paragraph snippet that cannot access the title, therefore
      # we keep this information to be used in the link to the podcast recap
      title = find_title(p, !in_review_club_section)
      if !title.empty?
        # paragraph has title
        current_title = title
      end

      # If the current paragraph contains the podcast reference mark,
      # capture the timestamp, add paragraph to references and replace 
      # the mark with link to the related podcast item
      p.gsub!($podcast_reference_mark) do |match|
        if in_review_club_section
          # the newsletter's review club section is the only section that does
          # not have a list item to use as anchor so we use the header
          current_title["podcast_slug"] = "#pr-review-club" # to avoid duplicate anchor
          current_title["slug"] = "#bitcoin-core-pr-review-club"
        end
        podcast_reference = {"header"=> headers[current_header], "timestamp"=> $1}
        podcast_reference.merge!(current_title)
        podcast_references << podcast_reference

        if current_title.empty?
          # this is needed for the podcast reference mark to link to the header
          # of the special section
          current_title["slug"] = generate_slug(headers[current_header])
        end
        # Replace the whole match with the link
        headphones_link = "[<i class='fa fa-headphones' title='Listen to our discussion of this on the podcast'></i>]"
        replacement_link_to_podcast_item = "#{headphones_link}(#{target_page_url}#{current_title["podcast_slug"] || current_title["slug"]})"
      end

      # update to the next header when parse through it
      if p.sub(/^#+\s*/, "") == headers[(current_header + 1) % headers.length()]
        current_header += 1
        in_review_club_section = headers[current_header] == "Bitcoin Core PR Review Club"
        # reset header-specific variables
        current_title = {}
      end

    end

    # Join the paragraphs back together to return the modified content
    updated_content = paragraphs.join("\n\n")

    [updated_content, podcast_references]
  end
end