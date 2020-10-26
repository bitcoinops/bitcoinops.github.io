---
title: 'Bitcoin Optech Newsletter #121'
permalink: /en/newsletters/2020/10/28/
name: 2020-10-28-newsletter
slug: 2020-10-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes the disclosure of two vulnerabilities
in LND and includes our regular sections with summaries of popular
questions and answers from the Bitcoin StackExchange, announcements of
releases and release candidates, and descriptions of changes to popular
Bitcoin infrastructure software.

## Action items

- **Ensure LND nodes are upgraded to 0.11+:** as warned in [Newsletter
  #119][news119 lnd], a full disclosure of two vulnerabilities in old
  versions of LND has been made public.  Both vulnerabilities allow funds
  to be stolen from an affected LN node, so it is strongly recommended
  to upgrade immediately to LND 0.11.0-beta or LND 0.11.1-beta.  Other LN
  implementations are not affected by the described vulnerabilities.

## News

- **Full disclosures of recent LND vulnerabilities:** two
  vulnerabilities affecting LND were fully disclosed this week with
  posts to the Lightning-Dev mailing list by both LND co-maintainer
  Conner Fromknecht and vulnerability discoverer Antoine Riard.

    - **[CVE-2020-26895][] acceptance of non-standard signatures:** in
      some cases, LND would accept a transaction signature that Bitcoin
      Core would not relay or mine by default.  When the transaction
      containing the unrelayable signature fails to confirm, a timelock
      eventually expires and the attacker is able to steal funds they
      previously paid to the vulnerable user.

        This is a consequence of the *S* value in Bitcoin ECDSA
        signatures being equally valid on either the high side or low
        side of Bitcoin's elliptical curve (which, like all such curves,
        is symmetric).  Before segwit, inverting an *S*
        value---something anyone can do to any valid
        signature[^invert]---would change a transaction's txid, a
        problem known as *transaction malleability*.  After a major
        Bitcoin exchange lost funds by not properly handling mutated
        txids, [Bitcoin Core 0.11.1][] was released with a policy not to
        relay or mine transactions with *S* values on the high side of
        the curve---requiring anyone who wanted to exploit this form of
        malleability find someone to mine blocks with alternative software.  Even though segwit
        eliminates this type of txid malleability for transactions that
        spend only segwit UTXOs, the policy is still enforced for all
        transactions in order to prevent wasted bandwidth and other
        annoyances.

        During LND's development, two different methods of signature
        handling were implemented.  In most cases, LND properly ensured
        it only sent low-*S* signatures that could be relayed.  However,
        Riard discovered that LND would accept a high-*S* value for a
        successful payment, ultimately allowing an attacker to steal
        back a previously settled payment.

        Because anyone can invert any valid signature, LND was patched
        to allow it to transform any non-relayable high-*S* signature
        into a relayable low-*S* signature.  This means any LND node that
        was attacked but which upgrades before the successful payment
        expires should be able to keep its funds.  [BOLTs #807][]
        proposes to update the LN specification to automatically close
        channels where either party attempts to use a high-*S* signature
        (which no modern Bitcoin software should create), which
        Fromknecht notes LND plans to implement.

        For details, see the emails from [Riard][riard5] and
        [Fromknecht][fromknecht5].

    - **[CVE-2020-26896][] improper preimage revelation**: LND could be
      tricked into revealing an [HTLC][topic htlc] preimage before
      receiving an expected payment, allowing the payment to be stolen
      by one of the nodes that was supposed to route it.

        Imagine Alice wants to pay Bob by routing a payment through
        Mallory:

            Alice → Mallory → Bob
              (planned route)

        Alice starts by giving Mallory an HTLC.  Mallory can't claim
        this money yet because she doesn't know the preimage for its
        hashlock.  However, Mallory does guess that Bob is the intended
        receiver---so he knows the preimage.  Instead of routing
        Alice's payment to Bob, Mallory creates a new minimal payment
        secured by the same hashlock and routes it back to herself
        through Bob and a third-party (Carol).

            Mallory → Bob → Carol → Mallory
                (second payment route)

        Even though Mallory created this second payment, she can't
        complete it because she doesn't know the preimage for the
        hashlock.  Instead, she closes her channel with Bob with the
        second payment still pending.  Because of a bug in LND, Bob will
        use the preimage meant for the payment from Alice to settle the
        payment routed through his node by Mallory.  This earns Bob the
        routing fees Mallory paid, but it also reveals the preimage to
        the pending HTLC Alice tried routing through Mallory.  With the
        preimage, Mallory is able to claim the full amount of that
        payment without routing any part of it to Bob.  Additionally,
        Alice receives cryptographic proof of payment even though
        the payment was actually stolen.

        LND's design tried to prevent this problem by storing payment
        preimages separately from routing preimages, but some code was
        added that queried both databases, creating the bug that Riard
        discovered.

        Both Fromknecht and Riard note that the attack could've been
        prevented if the [payment secrets feature][] added to all LN
        implementations almost a year ago had become mandatory
        for all invoices.  This feature was designed to prevent
        privacy-reducing probing, particularly of [multipath
        payments][topic multipath payments],  by preventing a receiver
        from disclosing a payment preimage unless a payment contained a
        nonce included in the invoice.  If it had been enforced in this
        case, Mallory wouldn't know the payment secret and so couldn't
        have induced Bob to disclose it even with the buggy code.
        Fromknecht notes that, "the upcoming v0.12.0-beta release of lnd
        is likely to make payment secrets required by default.  We would
        welcome other implementations to do the same."

        A second set of emails from [Riard][riard6] and
        [Fromknecht][fromknecht6] describe this issue in detail.

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why is the Bitcoin Core wallet database moving from Berkeley DB to SQLite?]({{bse}}99620)
  Michael Folkson references Andrew Chow's [blog post][achow wallet blog post],
  including pros of SQLite, cons of Berkeley DB, and a bigger picture [proposed
  timeline][wallet proposed timeline] to migrate from legacy to
  [descriptor][topic descriptors] wallets.

- [What are Merklized Alternative Script Trees?]({{bse}}99539)
  Murch and Michael Folkson describe the history of [MAST][topic mast]
  discussions in Bitcoin, the differences between Merklized Abstract Syntax
  Trees and Merklized Alternative Script Trees, and the relation to taproot's
  [BIP341][] proposal.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #20198][] Show name, format and if uses descriptors in bitcoin-wallet tool FIXME:dongcarl

- [C-Lightning #4046][] libplugin: support for sending notifications.  FIXME:moneyball

- [C-Lightning #4139][] updates the `multifundchannel` RPC with a new
  `commitment_feerate` parameter that sets the initial feerate for
  commitment transactions in the channel.  Previously, the same feerate
  was used for both the funding transaction and initial commitment
  transactions.  This new option allows users to pay a higher feerate to
  get a channel open quickly without obliging them to pay the same
  higher feerate for commitment transactions.  This is especially useful
  when using [anchor outputs][topic anchor outputs] that allow
  commitment transactions to pay a low feerate that can be increased if
  necessary using [CPFP][topic cpfp] fee bumping.

- [Eclair #1575][] adds an `override-feerate-tolerance` setting that
  allows specifying how much your node will tolerate specific peers
  creating commitment transactions with feerates that are too low to get
  confirmed onchain quickly or too high to be reasonable.  The PR
  suggests a use for this might be maintaining low-feerate channels with
  peers you trust.

- [BIPs #1003][] updates the [BIP322][] specification of the [generic
  message signing protocol][topic generic signmessage] to drop the use
  of a custom signing protocol and instead use virtual transactions that
  can be signed by many Bitcoin wallets that already accept PSBTs or raw
  Bitcoin transactions.  The virtual transactions are constructed so
  that they can't spend any bitcoins but do commit to the intended
  message.  See [Newsletter #118][news118 signmessage] for a summary of
  this change from when it was proposed.

## Footnotes

[^invert]:
    If a high *S* value is the coordinate (x,y), then the low *S* value
    is (x,-y).  For Bitcoin's secp256k1 curve over a prime field where all
    points are unsigned, you can't simply take the negative, so you
    subtract the *y* coordinate in a high *S* value from the order of
    the curve.  As [BIP146][] describes: "`S' = 0xFFFFFFFF
    FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141 - S`". <!-- skip-duplicate-words-test -->

{% include references.md %}
{% include linkers/issues.md issues="20198,4046,4139,1575,1003,807" %}
[news119 lnd]: /en/newsletters/2020/10/14/#upgrade-lnd-to-0-11-x
[CVE-2020-26895]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26895
[CVE-2020-26896]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26896
[bitcoin core 0.11.1]: https://bitcoin.org/en/release/v0.11.1#test-for-lows-signatures-before-relaying
[riard5]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002859.html
[fromknecht5]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002858.html
[riard6]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002855.html
[fromknecht6]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002857.html
[payment secrets feature]: https://github.com/lightningnetwork/lightning-rfc/commit/5776d2a7
[news118 signmessage]: /en/newsletters/2020/10/07/#alternative-to-bip322-generic-signmessage
[achow wallet blog post]: https://achow101.com/2020/10/0.21-wallets
[wallet proposed timeline]: https://github.com/bitcoin/bitcoin/issues/20160