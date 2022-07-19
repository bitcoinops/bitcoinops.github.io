---
title: 'Bitcoin Optech Newsletter #209'
permalink: /en/newsletters/2022/07/20/
name: 2022-07-20-newsletter
slug: 2022-07-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes several related discussions about providing
a sustainable long term block reward for Bitcoin.  Also included are our
regular sections with descriptions of new features for clients and
services, announcements of new releases and release candidates, and
summaries of notable changes to popular Bitcoin infrastructure software.

## News

- **Long-term block reward ongoing discussion:** continuing the
  discussion about reliably paying for Proof of Work (PoW) as Bitcoin's
  subsidy declines, two new threads were started on the Bitcoin-Dev
  mailing list:

    - [Tail emission is not inflationary][todd tail] starts with an argument by
      Peter Todd that perpetually paying miners with newly created
      bitcoins will not lead to the number of bitcoins in circulation
      increasing forever.  Instead, he believes some bitcoins will be lost
      every year and, eventually, the rate at which bitcoins are lost will
      converge on the rate at which new bitcoins are produced, resulting in
      a roughly stable number of coins in circulation.  He also notes
      that adding a perpetual block subsidy to Bitcoin would be a hard
      fork.  Quite a few people replied to his post and on a [thread
      about it][talk tail] on BitcoinTalk; we will only attempt to summarize a
      few replies we found most notable.

        - *Hard fork not required:* Vjudeu [suggests][vjudeu sf] that a soft fork
          can create new bitcoins by imbuing transaction outputs paying
          zero satoshis with special meaning.  For example, when a node
          opting into the fork sees a zero-sat output, it looks at
          another part of the transaction for the actual value
          transferred.  This creates two classes of bitcoins, but
          presumably the soft fork would provide a mechanism to convert
          legacy-bitcoins to modified-bitcoins.  Vjudeu notes the same
          mechanism could also be used for privacy-enhancing bitcoin
          amount blinding (e.g. using [confidential transactions][]).

        - *No reason to believe perpetual issuance is sufficient*:
          Anthony Towns [posts][towns pi] to the mailing list and Gregory
          Maxwell [posts][maxwell pi] to BitcoinTalk that there's no reason to
          believe that paying miners an amount of coins equal to the
          average rate of lost coins will provide sufficient PoW
          security, and that there are cases where it could overpay for
          PoW security.  If a perpetual issuance can't guarantee security
          and if it has a significant likelihood of producing additional
          problems, it seems preferable to stick with a finite subsidy
          that---while it also can't guarantee security---at least it
          doesn't produce additional problems and is already
          accepted by all Bitcoiners (implicitly or explicitly).

            Maxwell further notes that Bitcoin miners on average collect
            significantly more value through just transaction fees than
            many altcoins pay their miners through the combination of
            subsidies, fees, and other incentives.  Those altcoins are not
            suffering fundamental PoW attacks, implying that it *might*
            be the case that enough value is being paid through
            transaction fees alone to keep Bitcoin secure.  In short,
            Bitcoin may already be past the point where it needs its
            subsidy to obtain sufficient PoW security.  (Though the
            subsidy also provides other benefits at present, as
            discussed in the summary below for Bram Cohen's thread.)

            Towns points out that Peter Todd's results depend on a
            constant average rate of bitcoins being lost each year, but
            this conflicts with what Towns thinks should be a
            system-wide goal to minimize lost bitcoins.  Relatedly,
            Maxwell describes how coin loss could be almost entirely
            eliminated by allowing anyone to automatically opt-in to
            using a script that would donate any of their coins which
            hadn't moved for, say, 120 years---well past the expected
            lifetime of the original owner and their heirs.

        - *Censorship resistance:* developer ZmnSCPxj [expanded][zmnscpxj cr] an
          [argument][voskuil cr] by Eric Voskuil that transaction fees enhance
          Bitcoin's censorship resistance.  For example, if 90% of the
          block reward comes from subsidy and 10% from transaction fees,
          then the most revenue a censoring miner can lose directly is
          10%.  But if 90% comes from fees and 10% from subsidy, the
          miner could directly lose up to 90%---a much stronger
          incentive to avoid censorship.

            Peter Todd [countered][todd cr] with the opinion that a perpetual
            issuance would raise more money for PoW security than
            "piddling transaction fees", and that a higher block reward
            would increase the cost an attacker would have to pay miners
            to censor transactions.

    - [Fee sniping][cohen fs]: Bram Cohen posted about the problem of [fee sniping][topic fee sniping]
      and suggests keeping transaction fees at about 10% of total block
      rewards (the remainder being subsidy) as a possible solution.  He
      briefly mentions some other possible solutions, but others
      provided additional suggestions in more detail.

        - *Paying fees forward:* Russell O'Connor [put forward][oconnor forward fees] an old
          idea that miners could calculate the maximum amount of fees
          they could collect from the top transactions in their mempool
          without incentivizing fee sniping.  They could then offer any
          additional fees they collected as a bribe to the next miner
          for building the next block cooperatively rather than
          competitively.  Discussion participants went through
          [several][oconnor ff2] iterations of [this][towns ff] idea but Peter Todd
          [noted][todd centralizing] that a fundamental concern with this technique is
          that smaller miners would need to pay higher bribes than
          larger miners, creating economies of scale that could further
          centralize Bitcoin mining.

        - *Improving market design:* Anthony Towns [suggests][towns market design] that
          improvements in Bitcoin software and user processes could
          significantly even out fees, making fee sniping less likely.
          But he further notes that it doesn't seem like a major
          priority today just for "refuting some FUD".

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **LNP/BP release Storm beta software:**
  The LNP/BP Standards Association [released][lnpbp tweet] beta software for [Storm][storm
  github], a messaging and storage protocol using LN.

- **Robinhood supports bech32:**
  Exchange Robinhood enables [withdrawal (send) support][robinhood withdrawals]
  for [bech32][topic bech32] addresses.

- **Sphinx announces VLS signing device:**
  The Sphinx team [announced][sphinx vls blog] a hardware signing device
  interfacing with [Validating Lightning Signer (VLS)][vls gitlab].

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 0.20.0][] is the newest release of this library for building
  Bitcoin wallets.  It includes "bug fixes for the `ElectrumBlockchain`
  and descriptor templates, a new transaction building feature to
  discourage fee sniping, and new transaction signing options."

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24148][] adds *watch-only* support for [output script
  descriptors][topic descriptors] written in [miniscript][topic
  miniscript].  For example, a user can import
  `wsh(and_v(v:pk(key_A),pk(key_B)))`
  to begin watching for any bitcoins received to the P2WSH output
  corresponding to that script.  A future PR is expected to add support
  for signing for miniscript-based descriptors.

- [Bitcoin Core GUI #471][] updates the GUI with the ability to restore
  from a wallet backup.  Restoring was previously only possible either
  using the CLI or by copying files into particular directories.

- [LND #6722][] adds support for signing arbitrary messages with
  [BIP340][]-compatible [schnorr signatures][topic schnorr signatures].
  Messages with schnorr signatures may also now be verified.

- [Rust Bitcoin #1084][] adds a method which can be used for sorting a
  list of public keys in the order specified by [BIP383][].

{% include references.md %}
{% include linkers/issues.md v=2 issues="24148,471,6722,6724,1592,1084" %}
[bdk 0.20.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.20.0
[todd tail]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020665.html
[talk tail]: https://bitcointalk.org/index.php?topic=5405755.0
[vjudeu sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020684.html
[confidential transactions]: https://en.bitcoin.it/wiki/Confidential_transactions
[towns pi]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020693.html
[maxwell pi]: https://bitcointalk.org/index.php?topic=5405755.0
[zmnscpxj cr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020678.html
[voskuil cr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020676.html
[todd cr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020688.html
[cohen fs]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020702.html
[oconnor forward fees]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020704.html
[oconnor ff2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020719.html
[towns ff]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020735.html
[todd centralizing]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020705.html
[towns market design]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020716.html
[lnpbp tweet]: https://twitter.com/lnp_bp/status/1545366480593846275
[storm github]: https://github.com/Storm-WG
[robinhood withdrawals]: https://robinhood.com/us/en/support/articles/cryptocurrency-wallets/#Supportedaddressformatsforcryptowithdrawals
[sphinx vls blog]: https://sphinx.chat/2022/06/27/a-lightning-nodes-problem-with-hats/
[vls gitlab]: https://gitlab.com/lightning-signer/docs
