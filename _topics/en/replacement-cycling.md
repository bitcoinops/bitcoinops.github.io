---
title: Replacement cycling

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
  - Lightning Network
  - Security Problems
  - Transaction Relay Policy

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Full Disclosure of replacement cycling vulnerabilities
      link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021999.html

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Replacement cycling vulnerability against HTLCs with deployed and proposed mitigations
    url: /en/newsletters/2023/10/25/#replacement-cycling-vulnerability-against-htlcs

  - title: Replacement cycle attack against pay-to-anchor
    url: /en/newsletters/2024/08/09/#replacement-cycle-attack-against-pay-to-anchor

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Transaction replacement
    link: topic rbf

  - title: "Child Pays For Parent (CPFP)"
    link: topic cpfp

  - title: CLTV expiry delta
    link: topic cltv expiry delta

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Replacement cycling** is an attack against CPFP fee bumps and
  transactions using `SIGHASH_SINGLE` that allows an attacker to remove an
  unconfirmed transaction from the mempools of relaying full nodes
  without leaving an alternative transaction in its place.  It mainly
  affects multiparty transactions that depend on CPFP fee bumps, such as
  those used in LN.

---
Mallory and Bob may share funds, as in an LN channel.  Each of them has a
_unilateral exit transaction_ (such as an LN _commitment transaction_)
that they can publish onchain at any time to terminate the fund sharing
arrangement.  To allow either of them to fee bump the transaction, it
contains at least one output each of them can spend in a child
transaction for a [CPFP fee bump][topic cpfp].

If Bob wants to terminate the fund sharing, he can broadcast his
unilateral exit transaction along with a child transaction for the CPFP
fee bump.  Mallory has the
ability to broadcast her own unilateral exit transaction with a
higher-fee child transaction.  Because the two exit transactions spend the same
inputs, they _conflict_, and Bob's lower-fee exit transaction will be
[replaced][topic rbf] in mempools with Mallory's higher-fee alternative.
That's fine for Bob: in the protocol, he doesn't care which exit
transaction gets confirmed---either transaction will end the fund
sharing arrangement.

However, after Mallory's alternative exit transaction has entered
mempools, she can replace her child transaction with another conflicting
transaction---this one with no relationship to either exit transaction.
This replacement removes Mallory's alternative transaction, leaving the
mempool devoid of any transaction that terminates the fund sharing
arrangement.

{:.center}
![Illustration of a replacement cycle attack](/img/posts/2024-08-replacement-cycling.png)

Bob can broadcast his exact same exit transaction and child transaction from
before, but Mallory can repeat the sequence of steps to remove his
transaction from mempools---although she'll need to use a different UTXO
or pay a higher feerate to reuse the same input each time.  The cycle of
Bob rebroadcasting and Mallory re-removing is what presumably gives
replacement cycling its name.

Replacement cycling is especially concerning in protocols that use time
sensitive transactions.  For example, forwarded [HTLCs][topic htlc] in
LN must be resolved within a certain number of blocks.  If Mallory is
able to use replacement cycling to prevent Bob from resolving HTLCs
forwarded to Mallory within a certain amount of time, Mallory can steal
from Bob.

Several mitigations for replacement have been [deployed][news274
deployed mitigations] by LN implementations.  Possibly the most
effective mitigation is a combination of Bob frequently rebroadcasting
and the use of longer timeouts in protocols such as HTLCs (e.g.
increasing the [CLTV expiry delta][topic cltv expiry delta] in LN).
Additional mitigations have been [proposed][news274 proposed
mitigations].

{:.center}
![Effectiveness of rebroadcast and higher CLTV expiry delta](/img/posts/2023-10-cltv-expiry-delta-cycling.png)

Any transaction that can be replaced in the mempool by a counterparty or
third party is potentially vulnerable to replacement cycling if any of
the replacement transactions spend an input under the control of the
attacker.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[news274 deployed mitigations]: /en/newsletters/2023/10/25/#deployed-mitigations-in-ln-nodes-for-replacement-cycling
[news274 proposed mitigations]: /en/newsletters/2023/10/25/#proposed-additional-mitigations-for-replacement-cycling
