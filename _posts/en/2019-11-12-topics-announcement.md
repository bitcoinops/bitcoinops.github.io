---
title: "New Website Feature: Topics Index"
permalink: /en/topics-announcement/
name: 2019-11-12-topics-announcement
type: posts
layout: post
lang: en
slug: 2019-11-12-topics-announcement

excerpt: >
  Announcement of a new index of topics frequently mentioned on the
  Optech website with an initial set of 40 topics and a plan to expand
  that over the next year to 100 topics.
---
{% include references.md %}

{% comment %}<!-- $ find _posts/en/ _includes/specials/ -name '*.md' | xargs cat | wc -w
     122823

     Assume 350 words per page, that's 350.92 pages -->{% endcomment %}

Over the past 18 months, <!-- June 2018 to November 2019 --> Optech
has published the equivalent of about 350 printed pages worth of
Bitcoin news and documentation.  In an effort to make that material more
accessible, we're pleased to announce a new [topics index][] with an
initial set of 40 topics.

![Main topics index page](/img/posts/2019-11-topics-index.png)

We indexed our existing content in three different ways: by [topic
name][topics index] (or alias), by each noteworthy event affecting the
topic (in [date order][topics date]), and by [categorizing][topics
categories] topics based on what parts of the Bitcoin system they
affect.  Clicking the name of a topic or an event will bring you to the
topic's page with a brief description of the topic, a list of primary
sources that best define the topic, a date-sorted list of mentions on
the Optech website, and links to any additional resources about the
topic that we think might be useful.

![Example of a topic page: Taproot](/img/posts/2019-11-topics-page.png)

We plan to make monthly updates to the topic index with links to any new
information about each topic.  As part of those updates, we also plan to
add new topics at a modest rate of one new topic per week.  This should
bring us to about 100 indexed topics by the end of 2020.

Like almost everything on the Optech website, content in the topic index
is [freely licensed][mit] and we welcome contributions.  Suggesting
edits or reporting issues can be done using links provided at the bottom
of each topic page.  We also welcome suggestions for new topics to index,
but note that because this is an index to the Optech website (and not a
guide to the Bitcoin system in general), we currently have a policy that
a topic should be mentioned in at least three separate Optech
newsletters or blog posts before we create a topic page for it.

As always, we extend our most sincere thanks to the developers and other
contributors actively working on the topics that we've had the pleasure
of writing about.  Without your dedication to improving the Bitcoin
system, our work would be impossible and Bitcoin wouldn't be nearly as
wonderful as it is.

[topics index]: /en/topics/
[topics date]: /en/topic-dates/
[topics categories]:  /en/topic-categories/
[mit]: https://github.com/bitcoinops/bitcoinops.github.io/blob/master/LICENSE.txt
