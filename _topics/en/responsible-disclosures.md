---
title: Responsible disclosures

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
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

  - title: "Suhas Daftuar disclosed a bug that could temporarily exclude a Bitcoin Core node from consensus"
    url: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure

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

  - title: "Milk Sad team disclosed CVE-2023-39910 insecure entropy in Libbitcoin `bx` command"
    url: /en/newsletters/2023/08/09/#libbitcoin-bitcoin-explorer-security-disclosure

  - title: "Matt Morehouse disclosed fake channels vulnerability against four major LN node implementations"
    url: /en/newsletters/2023/08/30/#disclosure-of-past-ln-vulnerability-related-to-fake-funding

  - title: "Antoine Riard responsibly discloses replacement cycle attacks affecting all HTLC-using software"
    url: /en/newsletters/2023/10/25/#replacement-cycling-vulnerability-against-htlcs

  - title: "Niklas Gögge responsibly disclosed two vulnerabilities affecting LND"
    url: /en/newsletters/2024/01/03/#disclosure-of-past-lnd-vulnerabilities

  - title: "Matt Morehouse responsibly disclosed vulnerability affecting Core Lightning"
    url: /en/newsletters/2024/01/17/#disclosure-of-past-vulnerability-in-core-lightning

  - title: "Niklas Gögge responsibly disclosed a consensus bug affecting btcd"
    url: /en/newsletters/2024/01/24/#disclosure-of-fixed-consensus-failure-in-btcd

  - title: "Eugene Siegel responsibly disclosed a Bitcoin Core block stalling bug affecting LN"
    url: /en/newsletters/2024/02/07/#public-disclosure-of-a-block-stalling-bug-in-bitcoin-core-affecting-ln

  - title: "Matt Morehouse responsibly disclosed vulnerability affecting LND onion packet parsing"
    url: /en/newsletters/2024/06/21/#disclosure-of-vulnerability-affecting-old-versions-of-lnd

  - title: "Wladimir Van Der Laan responsibly disclosed vulnerability affecting miniupnpc, used by Bitcoin Core"
    url: /en/newsletters/2024/07/05/#remote-code-execution-due-to-bug-in-miniupnpc
    date: 2015-09-15

  - title: "Evil-Knievel responsibly disclosed vulnerability that could be used to crash Bitcoin Core"
    url: /en/newsletters/2024/07/05/#node-crash-dos-from-multiple-peers-with-large-messages
    date: 2015-02-05

  - title: "John Newbery responsibly disclosed tx censorship vulnerability co-discovered by Amiti Uttarwar"
    url: /en/newsletters/2024/07/05/#censorship-of-unconfirmed-transactions
    date: 2020-04-03

  - title: "Practicalswift responsibly disclosed a netsplit vulnerability in Bitcoin Core"
    url: /en/newsletters/2024/07/05/#netsplit-from-excessive-time-adjustment
    date: 2020-10-10

  - title: "Sec.eine responsibly disclosed a node stalling vulnerability in Bitcoin Core"
    url: /en/newsletters/2024/07/05/#cpu-dos-and-node-stalling-from-orphan-handling
    date: 2019-03-19

  - title: "John Newbery responsibly disclosed memory Dos vulnerability in Bitcoin Core"
    url: /en/newsletters/2024/07/05/#memory-dos-from-large-inv-messages
    date: 2020-05-08

  - title: "Cory Fields responsibly disclosed memory DoS vulnerability in Bitcoin Core"
    url: /en/newsletters/2024/07/05/#memory-dos-using-low-difficulty-headers
    date: 2017-08-08

  - title: "John Newbery responsibly disclosed CPU-wasting DoS in Bitcoin Core"
    url: /en/newsletters/2024/07/05/#cpu-wasting-dos-due-to-malformed-requests
    date: 2020-05-08

  - title: "Michael Ford responsibly disclosed a BIP70-related vulnerability in Bitcoin Core"
    url: /en/newsletters/2024/07/05/#memory-related-crash-in-attempts-to-parse-bip72-uris
    date: 2019-08-12

  - title: "Peter Todd responsibly disclosed a free relay attack exploiting RBF policy differences"
    url: /en/newsletters/2024/07/26/#free-relay-attacks

  - title: "Eugene Siegel responsibly disclosed a remote crash vulnerability in Bitcoin Core"
    url: /en/newsletters/2024/08/02/#remote-crash-by-sending-excessive-addr-messages
    date: 2021-06-21

  - title: "Michael Ford disclosed a Bitcoin Core vulnerability based on a discovery by Ronald Huveneers"
    url: /en/newsletters/2024/08/02/#remote-crash-on-local-network-when-upnp-enabled
    date: 2020-10-13

  - title: "Lloyd Fournier, Nick Farrow, and Robin Linus disclosed Dark Skippy fast seed exfiltration attack"
    url: /en/newsletters/2024/08/09/#faster-seed-exfiltration-attack

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Common Vulnerabilities and Exposures (CVEs)"
    link: topic cves

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
