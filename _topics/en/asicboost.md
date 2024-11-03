---
title: ASICBoost

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - Overt ASICBoost
  - Covert ASICBoost

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Mining

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: AsicBoost---A Speedup for Bitcoin Mining
      link: https://arxiv.org/abs/1604.00575

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Overt ASICBoost support for S9 miners
    url: /en/newsletters/2018/10/30/#overt-asicboost-support-for-s9-miners

  - title: "Bitcoin Core #15471 removes warning falsely triggered by use of overt ASICBoost"
    url: /en/newsletters/2019/03/05/#bitcoin-core-15471

  - title: "Question about block templates versus actual blocks: ASICBoost explains one difference"
    url: /en/newsletters/2021/04/28/#why-does-the-mined-block-differ-so-much-from-the-block-template

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "BIP320: nVersion bits for general purpose use"
    link: BIP320

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **ASICBoost** is a technique for specially constructing a Bitcoin
  block header in order to reduce by about 15% the number of operations
  necessary to find a certain amount of proof of work.

---
ASICBoost can be implemented in two forms:

- **Overt ASICBoost** requires manipulating the nVersion field of a
  block header.  This is clearly visible on the block chain.  Miners
  wishing to use overt ASICBoost are recommended to use the version bits
  reserved for general purpose use by [BIP320][].

- **Covert ASICBoost** requires manipulating part of the merkle root
  field of a block header.  This can be done undetectably, although
  naive implementations often leave clues.

  Covert ASICBoost is not compatible with blocks that contain
  secondary commitments to their transactions, as is the case with any
  block that contains a segwit transaction.  This produced
  [controversy][segwit asicboost] when it was discovered that a mining
  hardware manufacturer who strongly objected to segwit had secretly
  designed features into their ASICs to use covert ASICBoost.

[segwit asicboost]: /en/topics/soft-fork-activation/#2016-7-bip9-bip148-and-bip91-the-bip141143-segwit-activation

{% include references.md %}
{% include linkers/issues.md issues="" %}
