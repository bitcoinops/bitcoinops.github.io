---
title: Ark

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Contract Protocols

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Basis Of Ark Technology (BOATs)"
      link: https://github.com/ark-network/boats

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Proposal for a managed joinpool protocol
    url: /en/newsletters/2023/05/31/#proposal-for-a-managed-joinpool-protocol
    feature: true

  - title: Improving LN scalability with covenants in a similar way to Ark
    url: /en/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Joinpools
    link: topic joinpools

  - title: Covenants
    link: topic covenants

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Ark** is a trustless joinpool-style protocol where a large number
  of users share a UTXO by accepting a counterparty as a co-signer on
  all transactions within a certain time period.  This spreads the cost
  of onchain fees from using that UTXO across many users, minimizing
  their individual costs.

---
The users can either unilaterally withdraw their bitcoins onchain
after the expiry of the time period or instantly and trustlessly
transfer them offchain to the counterparty before the end of the time
period.  Normally, a user will simply roll their bitcoins into another
contract with the counterparty, which can be highly fee efficient when
done with many other users at the same time.  Alternatively, the
counterparty may help the user make a payment onchain, through LN, or
through any other protocol supported by the counterparty.  Presumably,
the counterparty would pass along to the user any fees the
counterparty had to pay for using the payment protocol, e.g.
forwarding fees if LN was used.

Ark can be implemented on Bitcoin with no consensus changes required,
but it will support a larger number of users---making it much more fee
efficient---if a [covenant][topic covenants] feature is added to
Bitcoin.

{% include references.md %}
{% include linkers/issues.md issues="" %}
