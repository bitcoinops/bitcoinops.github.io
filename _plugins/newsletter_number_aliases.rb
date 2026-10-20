# frozen_string_literal: true

## Generates numeric aliases for newsletters, so that both
## https://bitcoinops.org/en/newsletters/371 and https://bitcoinops.org/371
## resolve to https://bitcoinops.org/en/newsletters/2025/09/12/.
##
## The aliases are added to each newsletter's "redirect_from" front matter,
## which jekyll-redirect-from turns into small redirect pages.
##
## See https://github.com/bitcoinops/bitcoinops.github.io/issues/2723
class NewsletterNumberAliases < Jekyll::Generator
  ## Run before jekyll-redirect-from, which reads "redirect_from" to create
  ## the redirect pages for each newsletter.
  priority :high

  ## Newsletter titles are of the form "Bitcoin Optech Newsletter #427" or,
  ## for special editions, "Bitcoin Optech Newsletter #385: 2025
  ## Year-in-Review Special"
  NUMBER_IN_TITLE = /Newsletter #(\d+)\b/

  def generate(site)
    ## Paths already used by other pages, such as "/404.html", which the
    ## aliases must not overwrite.
    taken = site.pages.map(&:url)

    site.posts.docs.each do |post|
      next unless post.data["type"] == "newsletter" && post.data["lang"] == "en"

      number = post.data["title"].to_s[NUMBER_IN_TITLE, 1]
      next unless number

      aliases = Array(post.data["redirect_from"])
      ["/en/newsletters/#{number}", "/#{number}"].each do |path|
        aliases << path unless taken.include?("#{path}.html")
      end
      post.data["redirect_from"] = aliases.uniq
    end
  end
end
