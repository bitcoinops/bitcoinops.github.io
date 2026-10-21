# frozen_string_literal: true

## Generates numeric aliases for newsletters, so that
## https://bitcoinops.org/en/newsletters/371 resolves to
## https://bitcoinops.org/en/newsletters/2025/09/12/, and likewise in every
## language a newsletter has been translated into, e.g.
## https://bitcoinops.org/zh/newsletters/371.
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
  NUMBER_IN_TITLE = /#(\d+)\b/

  def generate(site)
    newsletters = site.posts.docs.select do |post|
      post.data["type"] == "newsletter" && post.data["lang"]
    end

    ## Issue numbers are read from the English newsletters, which all carry
    ## the number in their title. Translations are matched by publication
    ## date instead: their titles are translated ("Bitcoin Optech 周报 #425")
    ## and Czech spells the number differently ("č. 409"), so the title is
    ## not a reliable source there. Every translation shares the date of the
    ## English issue it translates.
    numbers = {}
    newsletters.each do |post|
      next unless post.data["lang"] == "en"

      number = post.data["title"].to_s[NUMBER_IN_TITLE, 1]
      numbers[post.date.strftime("%Y-%m-%d")] = number if number
    end

    ## Paths already used by other pages, such as "/404.html", which the
    ## aliases must not overwrite.
    taken = site.pages.map(&:url)

    newsletters.each do |post|
      number = numbers[post.date.strftime("%Y-%m-%d")]
      next unless number

      path = "/#{post.data["lang"]}/newsletters/#{number}"
      next if taken.include?("#{path}.html")

      aliases = Array(post.data["redirect_from"])
      post.data["redirect_from"] = (aliases << path).uniq
    end
  end
end
