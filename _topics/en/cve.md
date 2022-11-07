---
title: CVEs (various)

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: cves

## Optional.  An entry will be added to the topics index for each alias
#
## PUT IN NUMERICAL ORDER
aliases:
  - CVE-2012-2459
  - CVE-2013-2292
  - CVE-2017-12842
  - CVE-2017-18350
  - CVE-2018-17145
  - CVE-2020-26895
  - CVE-2020-26896
  - CVE-2021-31876

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Security Problems

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: CVEs - Bitcoin Wiki
      link: https://en.bitcoin.it/wiki/Common_Vulnerabilities_and_Exposures

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "CVE-2020-26896: LND #4752 updates preimage revelation code"
    url: /en/newsletters/2020/12/02/#lnd-4752

  - title: "CVE-2020-26896: BOLTs #808 adds warning about improper preimage revelation"
    url: /en/newsletters/2020/11/18/#bolts-808

  - title: "CVE-2020-26895: BOLTs #807 adds warning about non-standard signatures"
    url: /en/newsletters/2020/11/11/#bolts-807

  - title: "CVE-2020-26895: full disclosure of on-standard signature acceptance"
    url: /en/newsletters/2020/10/28/#cve-2020-26895-acceptance-of-non-standard-signatures

  - title: "CVE-2020-26896: full disclosure of improper preimage revelation"
    url: /en/newsletters/2020/10/28/#cve-2020-26896-improper-preimage-revelation

  - title: "CVE-2018-17145: full disclosure of inv out-of-memory DoS attack"
    url: /en/newsletters/2020/09/16/#inventory-out-of-memory-denial-of-service-attack-invdos

  - title: "CVE-2017-12842: discussion about minimum transaction size"
    url: /en/newsletters/2020/05/27/#minimum-transaction-size-discussion

  - title: "CVE-2017-18350: full disclosure of SOCKS proxy vulnerability"
    url: /en/newsletters/2019/11/13/#cve-2017-18350-socks-proxy-vulnerability

  - title: "CVE-2012-2459: part of motivation for taproot tagged hashes"
    url: /en/newsletters/2019/05/14/#tagged-hashes

  - title: "CVE-2012-2459: related to new Bitcoin Core vulnerability disclosure"
    url: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure

  - title: "CVE-2017-12842: merkle tree fix proposed in consensus cleanup soft fork"
    url:  /en/newsletters/2019/03/05/#merkle-tree-attacks

  - title: "CVE-2013-2292: poor tx verification performance inspires consensus cleanup"
    url: /en/newsletters/2019/03/05/#legacy-transaction-verification

  - title: "CVE-2017-12842: vulnerability in Bitcoin SPV proofs"
    url: /en/newsletters/2018/12/28/#cve-2017-12842

  - title: "CVE-2021-31876: discrepancy between BIP125 and Bitcoin Core implementation"
    url: /en/newsletters/2021/05/12/#cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation

  - title: "CVE-2017-12842: discussion of lowering minimum relayable transaction size"
    url: /en/newsletters/2022/10/19/#minimum-relayable-transaction-size

  - title: "CVE-2017-12842: Bitcoin Core PR Review Club discussion about lowering min relayable tx size"
    url: /en/newsletters/2022/11/09/#bitcoin-core-pr-review-club

## Optional.  Same format as "primary_sources" above
#see_also:

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Common Vulnerabilities and Exposures (CVEs)** are serious
  vulnerabilities that have been cataloged to help developers,
  researchers, and the public efficiently share information about
  potential threats.

extra:
  cves:
    CVE-2020-26896:
      link: /en/newsletters/2020/10/28/#cve-2020-26896-improper-preimage-revelation
      summary: >
        Vulnerability in LND due to improperly revealing local preimages
        in response to foreign routing requests, which could have allowed
        funds to be stolen.  Fixed in LND 0.11.0-beta.

    CVE-2020-26895:
      link: /en/newsletters/2020/10/28/#cve-2020-26895-acceptance-of-non-standard-signatures
      summary: >
        Vulnerability in LND due to accepting non-standard "high-S"
        signatures, which could have prevented channels from closing in a
        timely manner and so allowed funds to be stolen.  Fixed in LND
        0.10.0-beta.

    CVE-2018-17145:
      link: /en/newsletters/2020/09/16/#inventory-out-of-memory-denial-of-service-attack-invdos
      summary: >
        Flooding a node with an excess of `inv` messages could lead to
        the node running out of memory and crashing, increasing the risk
        of [eclipse attacks][topic eclipse attacks] that can steal
        money.  Affected Bitcoin Core, Btcd, Bcoin, and multiple
        altcoin nodes.  Fixed in Bitcoin Core 0.16.2, Btcd 0.21.0-beta,
        and Bcoin 1.0.2.

    CVE-2017-12842:
      link: /en/newsletters/2018/12/28/#cve-2017-12842
      summary: >
        Allows creating an SPV proof for a transaction that doesn’t
        exist by specially crafting a real 64-byte transaction that gets
        confirmed in a block.  Can be used to steal from SPV clients,
        although other known attacks against SPV clients are cheaper.
        Proposed to be fixed in the [consensus cleanup][topic consensus
        cleanup] soft fork.

    CVE-2017-18350:
      link: /en/newsletters/2019/11/13/#cve-2017-18350-socks-proxy-vulnerability
      summary: >
        A vulnerability in Bitcoin Core affecting users of SOCKS
        proxies.  Fixed in Bitcoin Core 0.16.0.

    CVE-2013-2292:
      link: https://bitcointalk.org/?topic=140078
      summary: >
        A vulnerability in Bitcoin Core that it was believed could have
        allowed an attacker to create a block that would take over three
        minutes to verify.  Proposed to be fixed in the [consensus
        cleanup][topic consensus cleanup] soft fork, although the
        suggestion solution encountered controversy.

    CVE-2012-2459:
      link: https://bitcointalk.org/?topic=102395
      summary: >
        It's possible to mutate a valid block into an invalid block that
        commits to the same merkle root.  When vulnerable versions of
        Bitcoin Core saw such an invalid block, they cached its
        rejection and so would later reject the valid version of the
        block, which could easily lead to short-term network partitions
        where users could be tricked into accepting invalid bitcoins.
        Fixed in Bitcoin 0.6.1.

    CVE-2021-31876:
      link: /en/newsletters/2021/05/12/#cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation
      summary: >
        The [BIP125][] specification of opt-in Replace By Fee (RBF) says
        that an unconfirmed parent transaction that signals
        replaceability makes any child transactions that spend the
        parent’s outputs also replaceable through inferred inheritance.
        Bitcoin Core does not implement this behavior; Btcd does
        implement it.

---
### CVEs with their own topic pages

{% for topic in site.topics %}
  {% if topic.title contains "CVE-" %}
    {% capture extra_title %}**{{topic.title}}**{% endcapture %}
  * [{{topic.title}}]({{topic.url}}) {{topic.excerpt | remove_first: extra_title}}
  {%- endif %}
{% endfor %}

### Other CVEs
{% for alias in page.aliases %}
  * {:#{{alias}}} **[{{alias}}]({{page.extra.cves[alias].link | default: "#CVE-LINK-NOT-PROVIDED"}}):** {{page.extra.cves[alias].summary}}

  {%- for mention in page.optech_mentions -%}
    {%- if mention.title contains alias %}
      * [{{mention.title}}]({{mention.url}})
    {%- endif -%}
  {%- endfor -%}<br><br>

{% endfor %}

{% include references.md %}
{% include linkers/issues.md issues="" %}

