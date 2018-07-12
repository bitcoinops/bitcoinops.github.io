---
title: 'Bitcoin Optech Newsletter #1'
permalink: /en/newsletters/2018/06/26/
name: 2018-06-26-newsletter
type: newsletter
layout: newsletter
lang: en
version: 1
---

## Welcome

Welcome to the first Bitcoin Optech Group newsletter! As a member of our new organization, you can expect to see regular newsletters from us covering Bitcoin open source development and protocol news, Optech announcements, and member company’s case studies. We anticipate publishing these newsletter on our web site.

We hope you find this newsletter of value. We’re creating this for you, so please feel comfortable reaching out to us if you have feedback, be it additional things you’d like to see us cover or improvements to what we’re already including.

A reminder to companies that haven’t yet become an official member yet. We ask that you pay a nominal contribution of $5,000 to help fund our expenses.

## First Optech workshop!

Bitcoin Optech Group is organizing the first of a series of workshops to be held on **July 17 in San Francisco**. Square has graciously offered to host the afternoon workshop, and we will have a group dinner afterwards. Participants will be 1-2 engineers from SF Bay area Bitcoin companies. We will have roundtable discussions covering 3 topics:

- Coin selection best practices;
- Fee estimation, RBF, CPFP best practices;
- Optech community and communication - optimizing Optech for business’ needs.

We plan to organize similar workshops in other regions based on Optech member company demand. If this sounds appealing to you, please feel free to reach out to us and let us know what you’d like to see.

## Open Source News

A consistent theme we have heard from our initial outreach to Bitcoin companies is the desire to improve communication with the open source community. To that end, in each newsletter we plan to provide a summary of relevant action items, dashboard items, and news from the broader Bitcoin open source community.

### Action items

- **Pending DoS vulnerability disclosure for Bitcoin Core 0.12.0 and earlier.  Altcoins may be affected.** As [announced][alert announcement] in November 2016, Bitcoin Core developers are planning to release the private key Satoshi Nakamoto created in 2010 to sign network alerts.  This key can be abused to create an out-of-memory (OOM) condition in Bitcoin 0.3.9 through Bitcoin Core 0.12.0 that will result in those nodes crashing (but there are no disclosed money-losing attacks).  Many altcoins have forked from code prior to 0.12.0 and may be vulnerable to the same attacks, but they use different keys and so the attack cannot be exploited unless those keys are also misused.

  Recommend actions are (1) checking your infrastructure for Bitcoin nodes 0.12.0 or below and upgrading them if possible (this includes older versions of Bitcoin XT, Bitcoin Classic, and Bitcoin Unlimited); (2) checking your infrastructure for altcoin nodes based on Bitcoin Core 0.12.0 or below and either upgrading them or putting them behind a proxy that filters out peer-to-peer protocol alert messages.  If you are absolutely reliant upon pre-0.12.0 nodes, please inform a Bitcoin Core developer or your Optech contact immediately.

[alert announcement]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement

- **Bitcoin Core [0.16.1 released][]:** contains a fix for a case that could cause monetary loss for miners in situations expected to be quite rare. Also fixes a DoS attack that mostly affected new nodes and includes a change to relay policy in advance of a possible future soft fork more than a year from now.  Upgrade is recommended for all users and highly recommended for miners.

[0.16.1 released]: https://bitcoincore.org/en/2018/06/15/release-0.16.1/

- **Bitcoin-dev mailing list changing hosts:** if you subscribe to the [public Bitcoin Development mailing list][mailing list], note that an announcement will soon be posted about a change of domain name.  It's not known yet if any user action will be required besides addressing emails to a different domain name, although a change of hosts three years ago required all members re-subscribe.

[mailing list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/

### Dashboard items

- **Transaction fee increase:** a spike in transaction fees seen early last week was believed to have been related to Bithumb hack, both the attacker moving the stolen funds and other people moving their funds in response to rapidly changing exchange rates.  As of this email, low-fee transactions are still confirming within a few blocks, making it a good time for consolidation transactions.

### News

- **New backup and recovery format for private key material:** several developers are working on a new encoding for Bitcoin private keys, HD wallet extended public and private keys, and HD wallet seeds.  The format is loosely based on the bech32 format used for native segwit addresses.  The encoding is being [actively developed][bech32x] on the bitcoin-dev mailing list and participation is encouraged for any company that handles private key material in your own backups (e.g. paper wallet backups) or provides such services to customers (e.g. funds sweeping).

[bech32x]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016065.html

- **Coin selection simulations:** the upcoming 0.17.0 release of Bitcoin Core implements a much more effective coin selection algorithm based on Mark Erhardt's [Branch and Bound algorithm][branch and bound paper]. Contributors are currently running simulations aimed at identifying a suitable fallback strategy for when that ideal strategy doesn't work.  If your organization uses Bitcoin Core to optimize coin selection for minimizing fees, it may be worthwhile to monitor or contribute to Bitcoin Core PR [#13307][pr 13307].

[branch and bound paper]: http://murch.one/wp-content/uploads/2016/11/erhardt2016coinselection.pdf
[pr 13307]: https://github.com/bitcoin/bitcoin/pull/13307

- **[BIP174][] discussion:** mailing list [discussion][bip174 discussion] continues surrounding this proposed BIP for an industry standard to make it easier for wallets to communicate with each other in the case of online/offline (hot/cold) wallets, software/hardware wallets, and multisig wallets.  However, significant changes to the proposal are now being resisted, so finalization may be near.  If your organization produces or makes critical use of one of the aforementioned interoperating wallets, you may wish to evaluate the current proposal ASAP before it is finalized.

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[BIP174 discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016121.html

- **Dynamic wallet loading in Bitcoin Core:** the last PR has been merged for a new set of RPCs in Bitcoin Core designed to allow it to dynamically create new wallets in multiwallet mode, load them, and unload them.  If your organization manages transactions from within Bitcoin Core (or wants to do that), this can make it significantly easier to segment your wallets (e.g. separating customer deposits from company funds, or hot wallet funds from watching-only cold wallet funds).  Pre-production code is available on the Bitcoin Core master git branch using the RPCs `createwallet`, `loadwallet`, and `unloadwallet`.
