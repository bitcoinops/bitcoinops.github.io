---
title: Bitcoin Optech Schnorr Taproot Workshop
permalink: /ja/schorr-taproot-workshop/
name: 2019-10-29-schnorr-taproot-workshop-ja
type: posts
layout: post
lang: ja
slug: 2019-10-21-schnorr-taproot-workshop-ja

excerpt: >
  schnorr / taproot ソフトフォークの提案について学ぶための自習コース。

auto_id: false
---
{% include references.md %}

2019年9月、ビットコインオプテックはschnorr / taproot ソフトフォークの提案に関するワークショップをサンフランシスコとニューヨークで開催しました。 ワークショップを通じて、

1.提案に関するオープンソースコミュニティでの現在の考え方を共有し、
2.インタラクティブなJupyter Notebookを使用して、エンジニアに新しいテクノロジーを使用する機会を与え、
3.エンジニアがコミュニティのフィードバックプロセスに参加できるようにします。

このブログ投稿には、これらのワークショップのすべてのビデオ、スライド、およびJupyter Notebookが含まれているため、自宅にいながらこれらのエキサイティングな新技術について学ぶことができます。

ワークショップは4つのセクションに分かれています:

1. [事前準備、数学のベーシック](#preparation-and-basic-math)-Jupyter Notebook環境のセットアップ方法、基本的な楕円曲線数学の復習、タグ付きハッシュの導入。
2. [Schnorr署名とMuSig](#schnorr-signatures-and-musig)-bip-schnorr署名スキームと、MuSigを使用して複数の公開鍵 /部分署名を単一のpubkey /署名に集約する方法についての説明。
3. [Taproot](#taproot)-キーパス単一の署名が提供される場合またはスクリプトパス（単一のスクリプトまたは複数のスクリプトへのコミットメントが公開キーに埋め込まれ、後で明らかになる場合）を使用してsegwit v1のoutputの作成、支払いする方法の説明。
4. [ケーススタディ](#case-studies)-新しいschnorrおよびtaprootテクノロジーの実用的なアプリケーションの説明。

すべてのプレゼンテーションのスライドは[こちら][slides].からダウンロードできます。
またブライアン・ビショップが提供してくれたニューヨークのセッションの[transcript][]も存在します。

## Introduction

[![Introduction](/img/posts/taproot-workshop/introduction.png)](https://www.youtube.com/watch?v=1gRCVLgkyAE&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC)
{:.center}

John Newberyは、schnorrとtaprootがなぜ有用な技術であるかを要約し、Bitcoin Optechがワークショップを作成した理由を説明しています。 次に、ワークショップの目的の概要を説明しています。

## Preparation and basic math

このセクションでは、Jupyter Notebookをセットアップする方法を示し、基本的な楕円曲線の数学を復習し、タグ付きハッシュを紹介します。

#### 0.1 Test Notebook

ワークショップを開始する前に、ユーザーはリポジトリ[README][readme]の指示に従い、[workshop repository][]のクローンを作成し、テストノートブックを実行して、環境が正しく設定されていることを確認してください。

[→ このノートブックをGoogle Colabで実行する](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/0.1-test-notebook.ipynb)

#### 0.2 Elliptic Curve Math

[![Introduction](/img/posts/taproot-workshop/elliptic-curve-math.png)](https://www.youtube.com/watch?v=oix8ov9iGgk&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=2)
{:.center}

Elichai Turkelによる、このワークショップに必要となる基本的な楕円曲線の数学の説明です。

[→ このノートブックをGoogle Colabで実行する](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/0.2-elliptic-curve-math.ipynb)

#### 0.3 Tagged Hashes

_（動画なし）_bip-schnorrおよびbip-taprootの両方の提案で使用される_Tagged hashhes_を紹介しています。

[→ このノートブックをGoogle Colabで実行する](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/0.3-tagged-hashes.ipynb)

## Schnorr signatures and MuSig

このセクションでは、bip-schnorrの提案について説明し、MuSigを使用して複数の公開鍵/部分署名を単一の公開鍵/署名に集約する方法を説明します。

#### 1.1 Schnorr Signatures

[![Schnorr Signatures](/img/posts/taproot-workshop/schnorr.png)](https://www.youtube.com/watch?v=wybiVFdknhg&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=3)
{:.center}

Elichaiは、シュノア署名の背後にある数学を説明し、Bip-Schnorrの提案を説明します。

[→ このノートブックをGoogle Colabで実行する](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/1.1-schnorr-signatures.ipynb)

#### 1.2 MuSig

[![MuSig](/img/posts/taproot-workshop/musig.png)](https://www.youtube.com/watch?v=5MbTptrXEC4&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=4)
{:.center}

Elichaiは[MuSigアルゴリズム][musig]（Gregory Maxwell、Andrew Poelstra、Yannick Seurin、Pieter Wuille執筆）について説明し、複数の公開鍵/部分署名を単一の公開鍵/署名に集約する方法を示します。

[→ このノートブックをGoogle Colabで実行する](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/1.2-musig.ipynb)

## Taproot

このセクションでは、bip-taprootおよびbip-tapscriptの提案について説明します。 segwit v1outputの形式と、そのようなoutputがキーパスの支出またはスクリプトパスの支出にどのように費やされるかを示しています。 調整された(tweaked)公開キーが1つ以上のスクリプトにコミットする方法、およびこれらのスクリプトの1つを使用してsegwit v1outputを使用する方法を示します。

#### 2.0 Introduction to Taproot

[![Introduction to Taproot](/img/posts/taproot-workshop/taproot-intro.png)](https://www.youtube.com/watch?v=KLNH0ttpdFg&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=5)
{:.center}

James Chiangは、bip-taprootおよびbip-tapscriptの提案の概要を説明します。 このノートブックは、トランザクションoutputを作成、使用、使用が有効であることを確認する方法を示します。

[→ このノートブックをGoogle Colabで実行する](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.0-taproot-introduction.ipynb)

#### 2.1 Segwit V1

[![Segwit Version 1](/img/posts/taproot-workshop/segwit-version-1.png)](https://www.youtube.com/watch?v=n-jAUaSkcAA&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=6)
{:.center}

Jamesは、segwit v1トランザクションoutputを作成し、キーパス支出を使用してそれらを使用する方法を示します。

[→ このノートブックをGoogle Colabで実行する](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.1-segwit-version-1.ipynb)

#### 2.2 Taptweak

[![Taptweak](/img/posts/taproot-workshop/taptweak.png)](https://www.youtube.com/watch?v=EkGbPxAExdQ&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=7)
{:.center}

Jamesは、鍵の調整(key tweak)とは何か、および調整(tweak)を使用して任意のデータにコミットする方法を説明します。

[→ このノートブックをGoogle Colabで実行する](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.2-taptweak.ipynb)

#### 2.3 Tapscript

[![Tapscript](/img/posts/taproot-workshop/tapscript.png)](https://www.youtube.com/watch?v=nXGe9_M5pjk&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=8)
{:.center}

Jamesは、tapweakを使用してsegwit v1outputでtapscriptをコミットする方法と、segwit v1キーパス支出ルールを使用してそのoutputを使用する方法について説明します。 また、tapscriptとレガシービットコインスクリプトの違いについても説明しています。

[→ このノートブックをGoogle Colabで実行する](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.3-tapscript.ipynb)

#### 2.4 Taptree

[![Taptree](/img/posts/taproot-workshop/taptree.png)](https://www.youtube.com/watch?v=n6R15Eo6J44&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=9)
{:.center}

Jamesは、スクリプトのマークルツリーを構築する方法と、taptweakを使用してそのツリーにコミットする方法を示します。 次に、これらのスクリプトの1つを満たし、そのスクリプトがコミットされたツリーの一部であったことを証明することにより、outputを使用する方法を説明します。

[→ このノートブックをGoogle Colabで実行する](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.4-taptree.ipynb)

#### 2.5 Huffman Construction

_（ビデオなし）_このボーナスの章では、使用される可能性が高いスクリプトをツリーのルートの近くに配置することにより、スクリプトのツリーを最も効率的に構築する方法を示します。

[→ このノートブックをGoogle Colabで実行する](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.5-huffman.ipynb)

## Case studies

このセクションでは、新しいschnorr / taprootテクノロジーを使用して高度なビットコインサービスと製品を構築する方法のデモを提供します。

#### 3.1 Degrading Multisig

_（動画なし）_この章では、劣化するマルチシグウォレットについて説明します。 すべての場合において、outputは「ライブ」キーのサブセットで使用できますが、タイムアウト後の使用には「ライブ」キーと「バックアップ」キーの混合が必要です。
Taprootは、複数の支出パスをコミットすることを許可し、行使されたパスのみがチェーン上で公開されます。

[→ このノートブックをGoogle Colabで実行する](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/3.1-degrading-multisig-case-study.ipynb)

## Summary

[![Summary](/img/posts/taproot-workshop/summary.png)](https://www.youtube.com/watch?v=Q1od076K7IM&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=10)
{:.center}

  Johnは、これらの提案に対するコミュニティフィードバックプロセスに参加する方法を説明し、ワークショップを終了します。

[slides]: /img/posts/taproot-workshop/taproot-workshop.pdf
[transcript]: https://diyhpl.us/wiki/transcripts/bitcoinops/schnorr-taproot-workshop-2019/notes/
[readme]: https://github.com/bitcoinops/taproot-workshop/blob/master/README.md
[workshop repository]: https://github.com/bitcoinops/taproot-workshop/
[musig]: https://eprint.iacr.org/2018/068
