---
title: 'Bitcoin Optech Newsletter #50'
permalink: /en/newsletters/2019/06/12/
name: 2019-06-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes meetings from the CoreDev.tech event,
describes a proposed amendment to BIP125 replace-by-fee, links to an
Optech executive briefing video about Schnorr/Taproot, and briefly
celebrates the 50th weekly issue of the Optech Newsletter.  Also
included are our regular sections on bech32 sending support and notable
changes to popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}
{% include specials/2019-exec-briefing/softfork.md %}

## Action items

*None this week.*

## News

- **Bitcoin Core contributor meetings:** many contributors met in person
  for a periodic [CoreDev.tech][] event last week, with real-time
  [transcripts][coredev.tech transcripts] provided by contributor Bryan
  Bishop:

    - June 5th: a session on [code review][xs review] discussed a survey
      sent to active Bitcoin Core contributors and developed several
      suggestions for streamlining reviews.

      Participants discussed changing the [wallet architecture][xs
      wallet arch] to using [output script descriptors][] for generating
      addresses, tracking when they've been paid, and finding or
      deriving the particular private keys necessary for spending.

    - June 6th: discussion of the [consensus cleanup soft fork][xs
      cleanup sf] included its interaction with [bip-taproot][], whether
      parts of it should be dropped, and whether anything should be
      added.  ([More background][bg consensus cleanup])

      The group asked what they could do to make the [maintainers'][xs
      maint] work easier.  Among other considerations, the maintainers
      noted appreciation for the issue and PR management provided by
      long-time contributor Michael Ford.  Meeting participants
      responded to this by granting maintainer status to Ford so that he
      can be even more effective.

      [Potential script changes][xs script change] were discussed.
      Discussion of the [BIP118][] and [bip-anyprevout][] sighashes
      revolved around output tagging (see [Newsletter #34][]) and
      chaperone signatures ([#47][Newsletter #47]).  The renamed
      [bip-coshv][] opcode was reviewed (see [#48][Newsletter #48]) and
      `OP_CHECKSIGFROMSTACK` was considered as a generic alternative.

      A [Taproot][xs taproot] topic included discussion about using a
      merkle tree instead of an accumulator and risks related to fast
      quantum computers.  ([More background][bg taproot])

      A [Q&A session][xs utreexo] about the [Utreexo][] accumulator for the
      UTXO set highlighted some interesting details of this developing
      proposal for minimizing full node storage requirements.

    - June 7th: code for the [assumeutxo][xs assumeutxo] proposal was
      demoed and discussed, including how to make the proposal
      compatible with other ideas. ([More background][bg assumeutxo])

      Contributors discussed getting [hardware wallet][xs hwi] support
      via [HWI][] directly integrated into Bitcoin Core.  A particular
      concern was code separation---ensuring that code for specific
      hardware devices is maintained by the manufacturer and not Bitcoin
      Core.  ([More background][bg hwi])

      The [version 2 P2P transport protocol][xs v2 p2p] and the related
      countersign protocol (see [#27][countersign blurb]) were
      discussed.  Several possible enhancements were mentioned during
      the discussion.  ([More background][bg v2 p2p])

      A review of the [signet][xs signet] idea for a testnet-like chain
      where all blocks are signed by a trusted party focused on the
      various ways to distribute the signatures.  ([More background][bg
      signet])

      Although just announced this week on the Bitcoin-Dev mailing list,
      [blind statechains][xs blind state] were also discussed.

- **Proposal to override some BIP125 RBF conditions:** [BIP125][]
  opt-in Replace-By-Fee (RBF) only allows replacing a transaction with a
  higher-feerate alternative if the replacement increases the total
  amount of transaction fee paid in the entire mempool.
  This stops a cheap
  bandwidth-wasting Denial-of-Service (DoS) attack against full nodes but
  makes possible a fairly cheap [transaction pinning][] DoS attack
  against certain uses of RBF, such as in time-sensitive protocols like
  LN.

    Several developers have previously attempted to solve this dilemma,
    with a proposal late last year from Matt Corallo containing a
    possible solution using CPFP fee bumping ([CPFP carve out][], see
    [Newsletter #24][]) and suggesting an alternative workaround that
    tweaks RBF.  Rusty Russell previously [discussed][russell-corallo
    rbf] this RBF change with Corallo, has further refined it, and now
    [proposed it][rbf rule 6] to the Bitcoin-Dev mailing as the addition
    of a single rule to the BIP125 ruleset.  The new rule allows any
    BIP125 replaceable transaction in the mempool to be fee bumped under
    two conditions:

    1. The version currently in the mempool is below of the top
       1,000,000 most profitable vbytes (the next block area)

    2. The replacement version pays a high enough fee that it will be in
       the next block area

    This would allow any transaction to be fee bumped without
    consideration of any of that transaction's children, eliminating the
    problem with pinning.  However, anyone using this rule could reduce
    the overall amount of fee in the mempool and might be able to use it
    to excessively waste node bandwidth.  Several people replied to the
    proposal asking questions and offering analysis about these risks.

- **Presentation: The Next Softfork:** Bitcoin Optech contributor Steve
  Lee gave a presentation during last month's Optech Executive briefings
  about possible future Bitcoin soft forks.  The [video][next sf vid] is
  now available. {{the-next-softfork}}

- **Optech celebrates Newsletter #50:** in early June of last year, John
  Newbery emailed Dave Harding about some plans he had for the newly
  formed Optech organization---including the single sentence, "We'll
  also produce some written material [such as] weekly or monthly news
  summaries."  Being a bit bored that day, Harding replied back with an
  unsolicited [proof-of-concept newsletter][].  Newbery and other early
  Optech contributors liked it, so a few details were worked out and
  regular weekly publication of this newsletter began.

    Fifty issues later, the newsletter now has over 2,500 email subscribers
    and an unknown number of additional unique subscribers via
    [RSS][newsletter rss], [Twitter][optech twitter], and Max
    Hillebrand's [readings][hillebrand optech].  We've published over
    85,000 words overall---about 250 printed pages <!-- 350 words per
    page --> of content---with draft versions of the newsletters having
    received a total of 948 comments so far from an amazing team of
    reviewers who help ensure technical accuracy and readable prose.
    Announcements of new newsletters have accumulated over 1,300
    retweets <!-- 1,359 --> and 3,000 likes, <!-- 3,087 --> plus many
    upvotes on [Reddit][optech reddit].  Most importantly, we've heard
    directly from many of our readers that they find the newsletter to
    be especially useful.

    We're amazed, gratified, and humbled that a purely technical
    newsletter focused solely on Bitcoin has received such an amazing
    reception in its first year of publication.  We know you all have
    high expectations from us going forward, and we hope that we can
    live up to those aspirations in our next fifty issues.  As always,
    we thank our [founding sponsors][], [member companies][], all the
    people who have contributed to the newsletter, and everyone who has
    contributed to Bitcoin development in general---without you, we'd be
    writing about something much less exciting than the future of money.

## Bech32 sending support

*Week 13 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/13-adoption-speed.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [LND #2802][] allows LND to calculate the probability that a
  particular route will succeed.  It then uses that probability to
  choose the best route in combination with existing calculations of the
  the total fee cost and maximum HTLC timeout for the path.  Several new
  configuration options are added that allow the user to tweak constant
  values used in the probability calculation, such as the "assumed
  success probability of a hop in a route when no other information is
  available."  The author of the PR also discussed [routing success
  probability][] in his talk last weekend at the Breaking Bitcoin
  conference.

- [C-Lightning #2644][] changes how C-Lightning keeps track of which
  channel updates it has gossiped to its peers.  Previously, a map
  was kept for each peer tracking which updates had been sent and which
  were waiting to be sent.  Now, a single ordered list of updates is
  kept by the entire program and each peer connection simply tracks how
  far it is through sending all the entries in that list.  When a
  connection reaches the end of the list, its position is marked so
  that it can send any new entries that are subsequently added to the
  list.  When a later update makes a previous update irrelevant, the
  previous update is removed from the global list and any connections
  that haven't sent that update will never see it.  In testing
  (presumably as part of the [million channels project][]), this reduced
  overall memory usage by 35% (about 150 MB) and sped up sending all
  gossip announcements to all peers by 62% (about 11 seconds).

{% include linkers/issues.md issues="2802,2644" %}
[bech32 series]: /en/bech32-sending-support/
[million channels project]: https://github.com/rustyrussell/million-channels-project
[optech reddit]: https://old.reddit.com/domain/bitcoinops.org/
[coredev.tech transcripts]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/
[xs review]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-05-code-review/
[xs wallet arch]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-05-wallet-architecture/
[xs cleanup sf]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-06-great-consensus-cleanup/
[bg consensus cleanup]: {{news36}}/
[xs maint]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-06-maintainers/
[xs script change]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-06-noinput-etc/
[xs taproot]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-06-taproot/
[bg taproot]: {{news46}}/
[xs utreexo]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-06-utreexo/
[xs assumeutxo]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-07-assumeutxo/
[bg assumeutxo]: {{news41}}/
[xs hwi]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-07-hardware-wallets/
[bg hwi]: {{news34}}/
[xs v2 p2p]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-07-p2p-encryption/
[bg v2 p2p]: {{news39}}/
[xs signet]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-07-signet/
[bg signet]: {{news37}}/
[xs blind state]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-07-statechains/
[coredev.tech]: https://coredev.tech/
[transaction pinning]: https://bitcoin.stackexchange.com/questions/80803/what-is-meant-by-transaction-pinning
[rbf rule 6]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-June/016998.html
[next sf vid]: https://youtu.be/fDJRy6K_3yo
[proof-of-concept newsletter]: /en/newsletters/2018/06/08/
[newsletter rss]: /feed.xml
[optech twitter]: https://www.twitter.com/bitcoinoptech
[founding sponsors]: /about/#founding-sponsors
[member companies]: /#members
[countersign blurb]: {{news27}}#august
[cpfp carve out]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[russell-corallo rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016530.html
[hillebrand optech]: https://www.youtube.com/playlist?list=PLPj3KCksGbSY9pV6EI5zkHcut5UTCs1cp
[routing success probability]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/lightning-network-routing-security/
[utreexo]: https://eprint.iacr.org/2019/611
