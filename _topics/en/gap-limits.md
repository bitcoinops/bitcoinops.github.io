---
title: Gap limits

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Backup and Recovery
  - Wallet Collaboration Tools

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP32

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "How can I mitigate concerns around the gap limit?"
    url: /en/newsletters/2019/06/26/#how-can-i-mitigate-concerns-around-the-gap-limit

  - title: "Proposed BIP for BIP32 path templates, with maximum derivation limit"
    url: /en/newsletters/2020/07/08/#proposed-bip-for-bip32-path-templates

  - title: "BIPs #1025 assigns BIP88 to the standardized format for BIP32 path templates"
    url: /en/newsletters/2021/05/26/#bips-1025

  - title: "BDK #1351 makes several changes to how BDK interprets the stop_gap parameter"
    url: /en/newsletters/2024/04/03/#bdk-1351

## Optional.  Same format as "primary_sources" above
see_also:
  - title: HD wallets
    link: topic bip32

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Gap limits** are the limits wallets set for how many addresses
  they'll derive from an HD wallet without seeing any transactions
  related to those addresses.

---
For example, each time Alice requests a payment, her wallet generates a
new address, which she gives to the spender.  Later, she may need to
recover her wallet from its extended public key (xpub) or from her seed.
Her wallet derives an address and checks to see if it was paid by any
transactions on the blockchain.  If it was, her wallet derives the next
address in the sequence and checks for transactions paying it.  If an
address hasn't received a payment, it counts that towards the wallet's
gap limit, derives the next address, and continues scanning for
transactions.  If it finds a transaction for that new address, it resets
its counter, otherwise it continues incrementing it for each new address
derived without a corresponding transaction being found.

Eventually, the wallet derives a consecutive series of addresses equal
to the gap limit that have not been paid by any transaction.  At that
point, the wallet stops deriving new addresses for scanning.

Because far more addresses can be derived from an HD wallet than a
user could ever receive, some limit (like the gap limit) is needed to
ensure a wallet doesn't spend forever deriving new addresses and
scanning the blockchain.  However, it's also the case that a receiver wants
to give out a different address to each spender for privacy, but
spenders may change their mind and not send payment, so wallets need to
accommodate some gap between addresses.  The gap limit provides a simple
parameter for choosing between the extremes of generating an unlimited
number of addresses and allowing some addresses to be skipped.

However, the gap limit forces other tradeoffs on the software that uses
it, so it is an occasional source of discussion among developers.

{% include references.md %}
{% include linkers/issues.md issues="" %}
