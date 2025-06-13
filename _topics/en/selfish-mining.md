---
title: Selfish mining

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Mining
  - Security Problems

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Mining Cartel Attack (2010)"
      link: https://bitcointalk.org/index.php?topic=2227.msg30083#msg30083

    - title: "Majority is not Enough (2013)"
      link: https://arxiv.org/pdf/1311.0243

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Bitcoin Core #27278 improves logging that could indicate a selfish mining attack or other concerns"
    url: /en/newsletters/2023/03/29/#bitcoin-core-27278

  - title: "Discussion about weak block relay and unintentional selfish mining"
    url: /en/newsletters/2024/04/24/#weak-blocks-proof-of-concept-implementation

  - title: "Selfish mining still possible despite centralized and decentralized block relay improvements"
    url: /en/newsletters/2025/05/30/#is-selfish-mining-still-an-option-with-compact-blocks-and-fibre

  - title: Calculating the selfish mining danger threshold
    url: /en/newsletters/2025/06/13/#calculating-the-selfish-mining-danger-threshold

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Selfish mining** allows a miner (or cartel of miners) controlling
  less than a majority of hashrate to keep more block reward per unit of
  work than the majority of honest miners.  This effectively allows the
  sub-majority to dictate block inclusion policy, including censoring
  transactions.

---
The attack was first publicly [described][bytecoin sm] in 2010.  It
later obtained its name _selfish mining_ from a 2013 [paper][es sm].  In
the form of attack requiring the fewest assumptions, the [math][poinsot
sm] shows that a miner with 1/3 of total network hashrate can obtain
marginally more block reward per unit of work than the other 2/3 of
honest miners.  As the selfish miner increases hashrate towards 1/2 of
the network total, their block reward ratio increases.  If they
consistently obtain more than 1/2 of the network total hashrate, they
can prevent other miners from keeping any blocks on the best chain,
allowing them to obtain all block reward and censor any transaction.

There is no known practical solution to selfish mining for Bitcoin,
beyond attempting to ensure no miner or cartel of miners obtains 1/3 or
more of total hashrate.

It is possible for selfish mining to occur accidentally, such as when
several large hashrate miners have low-latency connections to each other
but high-latency connections to the rest of the network.  There were
indications that such accidental selfish mining occasionally occurred in
2015 when significant Bitcoin mining was located in China and that
country's [firewall][great firewall] contributed significant latency to
block propagation.<!-- citation needed -->  Mitigating this concern, as
well as addressing other problems, inspired the development of
centralized block relay solutions (such as FIBRE and FALCON) and
decentralized block relay improvements (such as [compact block
relay][topic compact block relay]).

{% include references.md %}
{% include linkers/issues.md issues="" %}
[great firewall]: https://en.wikipedia.org/wiki/Great_Firewall
[bytecoin sm]: https://bitcointalk.org/index.php?topic=2227.msg30083#msg30083
[es sm]: https://arxiv.org/pdf/1311.0243
[poinsot sm]: https://delvingbitcoin.org/t/where-does-the-33-33-threshold-for-selfish-mining-come-from/1757
