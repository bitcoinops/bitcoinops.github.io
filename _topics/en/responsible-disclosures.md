---
title: Responsible disclosures

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Security Problems

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Cory Fields disclosed a consensus failure vulnerability Bitcoin ABC (Bitcoin Cash)"
    url: /en/newsletters/2018/08/14/#how-to-help-security-researchers

  - title: "Awemany disclosed CVE-2018-17144 as a DoS vulnerability in Bitcoin Core"
    url: /en/newsletters/2018/09/25/#cve-2018-17144

  - title: "Bitcoin Core developers quietly fix bug allowing invalid bitcoins after DoS report from Awemany"
    url: /en/newsletters/2018/09/25/#upgrade-to-bitcoin-core-0-16-3-to-fix-cve-2018-17144

  - title: "Trezor team disclosed a bug in the C-language bech32 specification affecting multiple wallets"
    url: /en/newsletters/2018/11/06/#overflow-bug-in-reference-c-language-bech32-implementation

  - title: "Braydon Fuller and Javed Khan report CVE-2018-17145 DoS vulnerability to devs of full nodes"
    url: /en/newsletters/2020/09/16/#inventory-out-of-memory-denial-of-service-attack-invdos

  - title: "Antoine Riard disclosed CVE-2020-26895 and CVE-2020-26896 allowing funds theft from LND"
    url: /en/newsletters/2020/10/28/#full-disclosures-of-recent-lnd-vulnerabilities

  - title: "Ajmal Aboobacker and Abdul Muhaimin disclose cross-site scripting vulnerabilities in BTCPay Server"
    url: /en/newsletters/2021/09/15/#btcpay-server-1-2-3

  - title: "Bastien Teinturier disclosed issue allowing funds loss from Core Lightning and LND"
    url: /en/newsletters/2022/05/04/#ln-anchor-outputs-security-issue

  - title: "Antoine Riard disclosed CVE-2021-31876 enhanced pinning against LN due to BIP125 discrepancy"
    url: /en/newsletters/2021/05/12/#cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation

  - title: "Anthony Towns disclosed a DoS and potential funds loss bug in BTCD and LND"
    url: /en/newsletters/2022/11/09/#block-parsing-bug-affecting-multiple-software

  - title: "Sergio Demian Lerner disclosed CVE-2017-12842 which allows stealing from SPV wallets"
    url: /en/newsletters/2018/12/28/#cve-2017-12842

  - title: "Saleem Rashid disclosed to Trezor an issue previously identified by Greg Sanders"
    url: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions

  - title: "René Pickhardt disclosed fee ransom attack affecting multiple LN implementations"
    url: /en/newsletters/2020/06/24/#ln-fee-ransom-attack

  - title: "MilkSad team disclosed CVE-2023-39910 insecure entropy in Libbitcoin `bx` command"
    url: /en/newsletters/2023/08/09/#libbitcoin-bitcoin-explorer-security-disclosure

  - title: "Matt Morehouse disclosed fake channels vulnerability against four major LN node implementations"
    url: /en/newsletters/2023/08/30/#disclosure-of-past-ln-vulnerability-related-to-fake-funding

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
  **Responsible disclosures** were occasions when someone discovered a
  vulnerability in Bitcoin-related software and reported it to
  developers, affected users, and the public in a way that helped
  minimize harm.

---
This page lists occasions when Optech reported on a responsible
disclosure and makes a best-effort attempt to cite the names of the
people who made the disclosure.  There are many other responsible
disclosures not listed here, including those which have not been
publicized yet.

{% include references.md %}
{% include linkers/issues.md issues="" %}
