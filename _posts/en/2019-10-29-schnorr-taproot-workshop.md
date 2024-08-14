---
title: Bitcoin Optech Schnorr Taproot Workshop
permalink: /en/schorr-taproot-workshop/
name: 2019-10-29-schnorr-taproot-workshop
type: posts
layout: post
lang: en
slug: 2019-10-21-schnorr-taproot-workshop

excerpt: >
  A self-study course for learning about the schnorr/taproot softfork proposal.

auto_id: false
---
{% include references.md %}

In September 2019, Bitcoin Optech organized workshops in San Francisco and
New York City on the schnorr/taproot softfork proposals. The aims of the workshops
were to:

1. share current thinking in the open source community about the proposals,
2. give engineers a chance to work with the new technology through interactive
   jupyter notebooks, and
3. help engineers take part in the community feedback process.

This blog post contains all of the videos, slides and jupyter notebooks from
those workshops, so engineers at home can learn about these exciting new
technologies.

The workshops were split into 4 sections:

1. [Preparation and basic math](#preparation-and-basic-math) - shows how to set
  up the jupyter notebook environment, gives a refresher on basic elliptic
  curve math, and introduces tagged hashes.
2. [Schnorr signatures and MuSig](#schnorr-signatures-and-musig) - describes
  the bip-schnorr signature scheme and how to use MuSig to aggregate multiple
  public keys and partial signatures into a single pubkey/signature.
3. [Taproot](#taproot) - demonstrates how to create and then spend a segwit v1 output
  using either the key path (where a single signature is provided) or the
  script path (where a commitment to a single script or multiple scripts is
  embedded in a public key and later revealed and satisfied).
4. [Case studies](#case-studies) - demonstrates some practical applications
  of the new schnorr and taproot technologies.

Slides from all the presentations can be downloaded [here][slides].
Additionally, Bryan Bishop has provided a [transcript][] of the New York
session.

## Introduction

[![Introduction](/img/posts/taproot-workshop/introduction.png)](https://www.youtube.com/watch?v=1gRCVLgkyAE&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC)
{:.center}

John Newbery gives a summary of why schnorr and taproot are useful technologies
and explains why Bitcoin Optech created the workshop. He then outlines the
workshop's aims.

## Preparation and basic math

This section shows how to set up the jupyter notebook, gives a refresher on
basic elliptic curve math and introduces tagged hashes.

#### 0.1 Test Notebook

Before starting the workshops, users should follow the instructions in the
repository [README][readme], clone the [workshop repository][] and run through
the test notebook to ensure that their environment is set up correctly.

[→ Run this notebook in Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/0.1-test-notebook.ipynb)

#### 0.2 Elliptic Curve Math

[![Introduction](/img/posts/taproot-workshop/elliptic-curve-math.png)](https://www.youtube.com/watch?v=oix8ov9iGgk&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=2)
{:.center}

Elichai Turkel provides a refresher on the basic elliptic curve math that will be
required for this workshop.

[→ Run this notebook in Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/0.2-elliptic-curve-math.ipynb)

#### 0.3 Tagged Hashes

_(No video)_ This chapter introduces _Tagged hashes_, which are used in both
the bip-schnorr and bip-taproot proposals.

[→ Run this notebook in Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/0.3-tagged-hashes.ipynb)

## Schnorr signatures and MuSig

This section explains the bip-schnorr proposal and explains how MuSig can be
used to aggregate multiple public keys and partial signatures into a single
pubkey and signature.

#### 1.1 Schnorr Signatures

[![Schnorr Signatures](/img/posts/taproot-workshop/schnorr.png)](https://www.youtube.com/watch?v=wybiVFdknhg&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=3)
{:.center}

Elichai explains the mathematics behind schnorr signatures and explains the
bip-schnorr proposal.

[→ Run this notebook in Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/1.1-schnorr-signatures.ipynb)

#### 1.2 MuSig

[![MuSig](/img/posts/taproot-workshop/musig.png)](https://www.youtube.com/watch?v=5MbTptrXEC4&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=4)
{:.center}

Elichai describes the [MuSig algorithm][musig] (authored by Gregory Maxwell,
Andrew Poelstra, Yannick Seurin and Pieter Wuille), and shows how it can be
used to aggregate multiple public keys and partial signatures into a single
pubkey/signature.

[→ Run this notebook in Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/1.2-musig.ipynb)

## Taproot

This section explains the bip-taproot and bip-tapscript proposals. It shows the
format of a segwit v1 output and how such an output can be spent in a key path
spend or a script path spend. It demonstrates how a tweaked public key can commit to
one or more scripts, and how the segwit v1 output can be spent using one of those
scripts.

#### 2.0 Introduction to Taproot

[![Introduction to Taproot](/img/posts/taproot-workshop/taproot-intro.png)](https://www.youtube.com/watch?v=KLNH0ttpdFg&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=5)
{:.center}

James Chiang gives an overview of the bip-taproot and bip-tapscript proposals. This
notebook demonstrates how we'll create transaction outputs, then spend them and
verify that the spend is valid.

[→ Run this notebook in Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.0-taproot-introduction.ipynb)

#### 2.1 Segwit V1

[![Segwit Version 1](/img/posts/taproot-workshop/segwit-version-1.png)](https://www.youtube.com/watch?v=n-jAUaSkcAA&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=6)
{:.center}

James shows how to create segwit v1 transaction outputs and spend them
using the key path spend.

[→ Run this notebook in Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.1-segwit-version-1.ipynb)

#### 2.2 Taptweak

[![Taptweak](/img/posts/taproot-workshop/taptweak.png)](https://www.youtube.com/watch?v=EkGbPxAExdQ&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=7)
{:.center}

James explains what a key tweak is, and how a tweak can be
used to commit to arbitrary data.

[→ Run this notebook in Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.2-taptweak.ipynb)

#### 2.3 Tapscript

[![Tapscript](/img/posts/taproot-workshop/tapscript.png)](https://www.youtube.com/watch?v=nXGe9_M5pjk&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=8)
{:.center}

James discusses how we can commit a tapscript in a segwit v1 output by using a
taptweak, and how we can spend that output using the segwit v1 key path spend
rules. He also explains the differences between tapscript and legacy bitcoin
script.

[→ Run this notebook in Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.3-tapscript.ipynb)

#### 2.4 Taptree

[![Taptree](/img/posts/taproot-workshop/taptree.png)](https://www.youtube.com/watch?v=n6R15Eo6J44&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=9)
{:.center}

James shows how a merkle tree of scripts can be constructed, and how we can
commit to that tree using a taptweak. He then explains how to spend the output by
satisfying one of those scripts and providing a proof that the script was part
of the committed tree.

[→ Run this notebook in Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.4-taptree.ipynb)

#### 2.5 Huffman Construction

_(No video)_ This bonus chapter shows how to most efficiently construct a tree
of scripts by placing scripts that are more likely to be spent closer to the
root of the tree.

[→ Run this notebook in Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.5-huffman.ipynb)

## Case studies

This section gives demonstrations of how the new schnorr/taproot technologies
can be used to build advanced Bitcoin services and products.

#### 3.1 Degrading Multisig

_(No video)_ This chapter demonstrates a degrading multisig wallet. In all
cases, the output can be spent with a subset of the 'live' keys, but after some
timeout, the output can be spent with a mixture of 'live' and 'backup' keys.
Taproot allows multiple spending paths to be committed to, and only the one
that is exercised is revealed on chain.

[→ Run this notebook in Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/3.1-degrading-multisig-case-study.ipynb)

## Summary

[![Summary](/img/posts/taproot-workshop/summary.png)](https://www.youtube.com/watch?v=Q1od076K7IM&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=10)
{:.center}

 John concludes the workshop by explaining how you can get involved in the
community feedback process for these proposals.

[slides]: /img/posts/taproot-workshop/taproot-workshop.pdf
[transcript]: https://diyhpl.us/wiki/transcripts/bitcoinops/schnorr-taproot-workshop-2019/notes/
[readme]: https://github.com/bitcoinops/taproot-workshop/blob/master/README.md
[workshop repository]: https://github.com/bitcoinops/taproot-workshop/
[musig]: https://eprint.iacr.org/2018/068
