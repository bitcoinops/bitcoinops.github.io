---
title: CLTV expiry delta

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
    - title: BOLT2
      link: bolt2

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "BOLTs #1086 specifies 2,016 blocks as the default absolute maximum CLTV expiry"
    url: /en/newsletters/2023/11/01/#bolts-1086

  - title: "LND #2759 lowers the default CLTV delta for all channels from 144 blocks to 40 blocks"
    url: /en/newsletters/2019/04/02/#lnd-2759

  - title: "LN-Symmetry requires longer CLTV expiry deltas than expected"
    url: /en/newsletters/2024/01/10/#expiry-deltas

  - title: "New attack against LN payment atomicity: raising CLTV expiry delta recommended"
    url: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity

  - title: "LND #4488 updates the minimum CLTV expiry delta users may set to 18 blocks"
    url: /en/newsletters/2020/08/05/#lnd-4488

  - title: "BOLTS #785 updates the minimum CLTV expiry delta to 18 blocks"
    url: /en/newsletters/2020/08/26/#bolts-785

  - title: "Rust-Lightning #849 makes `cltv_expiry_delta` configurable and reduces the default from 72 to 36"
    url: /en/newsletters/2021/03/31/#rust-lightning-849

  - title: "Eclair #2468 implements BOLTs #1032, allowing accepting a longer expiry than requested"
    url: /en/newsletters/2022/11/09/#eclair-2468

  - title: "Eclair #2677 raises its `max_cltv` to 2,016 blocks due widespread increases in CLTV expiry deltas"
    url: /en/newsletters/2023/06/14/#eclair-2677

  - title: "LND #7768 implements BOLTs #1032 and #1063, allowing accepting a longer expiry than requested"
    url: /en/newsletters/2023/07/19/#lnd-7768

  - title: "Longer CLTV expiry deltas as a mitigation against replacement cycling attacks"
    url: /en/newsletters/2023/10/25/#longer-cltv-expiry-deltas

  - title: "LND #8491 adds a `cltv_expiry` flag on the lncli RPC commands `addinvoice` and `addholdinvoice`"
    url: /en/newsletters/2024/06/14/#lnd-8491

## Optional.  Same format as "primary_sources" above
see_also:
  - title: HTLCs
    link: topic htlc

  - title: Channel jamming attacks
    link: topic channel jamming attacks

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **CLTV expiry delta** is the number of blocks a node has to settle a
  stalled payment before it could potentially lose money.  The deltas
  apply within a chain of HTLCs and use the `OP_CHECKLOCKTIMEVERIFY`
  (CLTV) opcode.

---
Imagine Alice forwards a payment to Bob who forwards the payment to
Carol.

    Forwarded payments:
        Alice ------> Bob ------> Carol
              (1 BTC)     (1 BTC)

If Carol doesn't claim the payment by releasing the [HTLC][topic
HTLC] preimage, but she also doesn't reject the payment, Bob's funds are
stuck.  Not only that, but he can't resolve the forwarded payment he
received from Alice, so her funds are stuck as well.  To avoid funds
becoming permanently stuck, HTLCs have an expiry after which Bob will
be able to claim a refund.  After Bob receives his refund from Carol, he
can reject the payment from Alice---giving her a refund.  Alternatively,
Alice can wait for her own expiry and reclaim the payment she forwarded
to Bob.  Everyone gets back what they started with, which is a safe
outcome.

    Forwarded payments:
        Alice ------> Bob ------> Carol
              (1 BTC)     (1 BTC)

    Refunds after expiry:
        Alice <------ Bob <------ Carol
              (1 BTC)     (1 BTC)

However, if Alice can claim her refund before Bob receives his refund,
then it's possible for Carol to accept her payment.  In this case, Alice
spends nothing and Carol receives payment with Bob losing the
difference.

    Forwarded payments:
        Alice ------> Bob ------> Carol
              (1 BTC)     (1 BTC)

    Refund after expiry to Alice and payment to Carol:
        Alice <------ Bob ------> Carol
              (1 BTC)     (1 BTC)

The CLTV expiry delta tries to prevent Bob from losing value this way.
When Alice gives Bob an HTLC that allows her to claim a refund after
`x` blocks, Bob gives Carol an HTLC that allows him to claim a refund
after `x - y` blocks.  The _y_ parameter is Bob's CLTV expiry delta:
it's how many blocks he has to claim a refund onchain before he could
potentially lose money if Alice claims her refund.

Higher CLTV expiry deltas provide more safety as they give an LN node more time
to get an HTLC refund transaction confirmed onchain before that node is
at risk of losing funds.  However, higher CLTV expiry deltas magnify the
problems of channel stalling, both accidental stalling (e.g. a node goes
offline suddenly) and malicious stalling (e.g. [channel jamming
attacks][topic channel jamming attacks]).

For example, imagine a payment that will be sent across 20 hops each
with an CLTV expiry delta of 100 blocks.  If that payment stalls, it
could be up to 2,000 blocks (about two weeks) until the spender gets
a refund and can resend the payment again.

There's no universally agreed-upon tradeoff between security and
worst-case payment delivery time, so LN implementations tend to each use
different default CLTV expiry deltas, often change those defaults, and
usually allow users to choose their own setting.

{% include references.md %}
{% include linkers/issues.md issues="" %}
