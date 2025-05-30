---
title: Attributable failures

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BOLTs #1044: attributable failures"
      link: https://github.com/lightning/bolts/pull/1044

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Proposal to authenticate messages about LN payment forwarding delays
    url: /en/newsletters/2019/06/19/#authenticating-messages-about-ln-delays

  - title: Updated proposal for attributing payment forwarding failures and delays
    url: /en/newsletters/2022/11/02/#ln-routing-failure-attribution

  - title: "LDK #3629 improves logging of remote failures that can’t be attributed"
    url: /en/newsletters/2025/03/14/#ldk-3629

  - title: "LDK #2256 and LDK #3709 improve attributable failures"
    url: /en/newsletters/2025/04/11/#ldk-2256

  - title: Discussion about whether attributable failures reduce LN privacy
    url: /en/newsletters/2025/05/30/#do-attributable-failures-reduce-ln-privacy

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
  **Attributable failures** are LN payment forwarding failures or delays
  that can be attributed to a pair of nodes (who may have one or more
  channels between each other), allowing spenders to avoid using slow or
  failure-prone nodes for future payments.  Additional fields in LN
  messages for tracking failures and delays are in the process of being
  standardized as of 2025.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
