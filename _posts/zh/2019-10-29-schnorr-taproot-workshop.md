---
title: Bitcoin Optech Schnorr Taproot Workshop
permalink: /zh/schnorr-taproot-workshop/
name: 2019-10-29-schnorr-taproot-workshop-zh
type: posts
layout: post
lang: zh
slug: 2019-10-21-schnorr-taproot-workshop-zh

excerpt: >
  一门自学课程，用于学习 schnorr/taproot 软分叉提案。

auto_id: false
---
{% include references.md %}

2019 年 9 月，Bitcoin Optech 在旧金山和纽约市组织了关于 schnorr/taproot 软分叉提案的实习。实习的目标是：

1. 共享开源社区对这些提案的最新想法，
2. 让工程师有机会通过交互式 jupyter notebooks 实际操作新技术，
3. 帮助工程师参与社区反馈流程。

这篇博客文章包含了所有来自这些实习的视频、幻灯片和 jupyter notebooks，因此在家工作的工程师也可以学习这些令人兴奋的新技术。

实习分为 4 个部分：

1. [准备工作和基础数学](#准备工作和基础数学) - 展示如何设置 jupyter notebook 环境，复习基础椭圆曲线数学，并介绍标签哈希（tagged hashes）。
2. [Schnorr 签名和 MuSig](#schnorr-签名和-musig) - 介绍 bip-schnorr 签名方案，以及如何使用 MuSig 聚合多个公钥和部分签名为单一公钥/签名。
3. [Taproot](#taproot) - 演示如何创建和消费一个 segwit v1 输出，通过密钥路径（提供单个签名）或脚本路径（将一个或多个脚本承诺嵌入公钥并稍后揭示和满足）来进行操作。
4. [案例研究](#案例研究) - 展示 schnorr 和 taproot 新技术的一些实际应用。

所有演示的幻灯片可以在[这里][slides]下载。另外，Bryan Bishop 提供了纽约会议的[会议记录][transcript]。

## 介绍

[![介绍](/img/posts/taproot-workshop/introduction.png)](https://www.youtube.com/watch?v=1gRCVLgkyAE&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC)
{:.center}

John Newbery 概述了为什么 schnorr 和 taproot 是有用的技术，并解释了 Bitcoin Optech 创建这次实习的原因。他随后列出了实习的目标。

## 准备工作和基础数学

本节展示了如何设置 jupyter notebook，复习基础椭圆曲线数学，并介绍了标签哈希。

#### 0.1 测试 Notebook

在开始实习之前，用户应按照仓库 [README][readme] 中的说明操作，克隆[实习仓库][workshop repository]，并运行测试 notebook 以确保环境正确设置。

[→ 在 Google Colab 中运行此 notebook](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/0.1-test-notebook.ipynb)

#### 0.2 椭圆曲线数学

[![椭圆曲线数学](/img/posts/taproot-workshop/elliptic-curve-math.png)](https://www.youtube.com/watch?v=oix8ov9iGgk&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=2)
{:.center}

Elichai Turkel 提供了关于本次实习所需的基础椭圆曲线数学的复习。

[→ 在 Google Colab 中运行此 notebook](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/0.2-elliptic-curve-math.ipynb)

#### 0.3 标签哈希

_(没有视频)_ 本章介绍了 _标签哈希_，这在 bip-schnorr 和 bip-taproot 提案中都有使用。

[→ 在 Google Colab 中运行此 notebook](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/0.3-tagged-hashes.ipynb)

## Schnorr 签名和 MuSig

本节解释了 bip-schnorr 提案，并说明如何使用 MuSig 将多个公钥和部分签名聚合为一个单一的公钥和签名。

#### 1.1 Schnorr 签名

[![Schnorr 签名](/img/posts/taproot-workshop/schnorr.png)](https://www.youtube.com/watch?v=wybiVFdknhg&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=3)
{:.center}

Elichai 解释了 Schnorr 签名背后的数学原理，并说明了 bip-schnorr 提案。

[→ 在 Google Colab 中运行此 notebook](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/1.1-schnorr-signatures.ipynb)

#### 1.2 MuSig

[![MuSig](/img/posts/taproot-workshop/musig.png)](https://www.youtube.com/watch?v=5MbTptrXEC4&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=4)
{:.center}

Elichai 描述了 [MuSig 算法][musig]（由 Gregory Maxwell、Andrew Poelstra、Yannick Seurin 和 Pieter Wuille 编写），并展示了如何将多个公钥和部分签名聚合为一个单一的公钥/签名。

[→ 在 Google Colab 中运行此 notebook](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/1.2-musig.ipynb)

## Taproot

本节解释了 bip-taproot 和 bip-tapscript 提案。它展示了 segwit v1 输出的格式，以及如何在密钥路径或脚本路径中消费该输出。它演示了如何通过修改公钥来承诺一个或多个脚本，以及如何使用这些脚本之一来消费 segwit v1 输出。

#### 2.0 Taproot 介绍

[![Taproot 介绍](/img/posts/taproot-workshop/taproot-intro.png)](https://www.youtube.com/watch?v=KLNH0ttpdFg&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=5)
{:.center}

James Chiang 概述了 bip-taproot 和 bip-tapscript 提案。本 notebook 演示了如何创建交易输出，然后消费它们并验证消费的有效性。

[→ 在 Google Colab 中运行此 notebook](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.0-taproot-introduction.ipynb)

#### 2.1 Segwit V1

[![Segwit V1](/img/posts/taproot-workshop/segwit-version-1.png)](https://www.youtube.com/watch?v=n-jAUaSkcAA&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=6)
{:.center}

James 演示了如何创建 segwit v1 交易输出并使用密钥路径消费它们。

[→ 在 Google Colab 中运行此 notebook](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.1-segwit-version-1.ipynb)

#### 2.2 Taptweak

[![Taptweak](/img/posts/taproot-workshop/taptweak.png)](https://www.youtube.com/watch?v=EkGbPxAExdQ&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=7)
{:.center}

James 解释了什么是密钥修改，以及如何使用修改来承诺任意数据。

[→ 在 Google Colab 中运行此 notebook](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.2-taptweak.ipynb)

#### 2.3 Tapscript

[![Tapscript](/img/posts/taproot-workshop/tapscript.png)](https://www.youtube.com/watch?v=nXGe9_M5pjk&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=8)
{:.center}

James 讨论了如何在 segwit v1 输出中通过 taptweak 来承诺一个 tapscript，以及如何使用 segwit v1 密钥路径消费该输出。他还解释了 tapscript 和传统比特币脚本之间的区别。

[→ 在 Google Colab 中运行此 notebook](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.3-tapscript.ipynb)

#### 2.4 Taptree

[![Taptree](/img/posts/taproot-workshop/taptree.png)](https://www.youtube.com/watch?v=n6R15Eo6J44&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=9)
{:.center}

James 演示了如何构建一个脚本的默克尔树，以及如何使用 taptweak 来承诺该树。他随后解释了如何通过满足其中一个脚本并提供该脚本是承诺树一部分的证明来消费该输出。

[→ 在 Google Colab 中运行此 notebook](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.4-taptree.ipynb)

#### 2.5 霍夫曼构建法

_(没有视频)_ 这章额外内容展示了如何通过将更有可能消费的脚本放置在树的更靠近根的位置来最有效地构建一个脚本树。

[→ 在 Google Colab 中运行此 notebook](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.5-huffman.ipynb)

## 案例研究

本节展示了如何使用 schnorr/taproot 新技术构建先进的比特币服务和产品的演示。

#### 3.1 渐变多签

_(没有视频)_ 本章展示了一个渐变多签钱包。在所有情况下，输出都可以由一部分“活跃”密钥消费，但在某个超时之后，输出可以由“活跃”和“备份”密钥的组合来消费。Taproot 允许承诺多个消费路径，并且只有实际行使的路径会在链上公开。

[→ 在 Google Colab 中运行此 notebook](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/3.1-degrading-multisig-case-study.ipynb)

## 总结

[![总结](/img/posts/taproot-workshop/summary.png)](https://www.youtube.com/watch?v=Q1od076K7IM&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=10)
{:.center}

John 通过解释如何参与这些提案的社区反馈流程来结束实习。

[slides]: /img/posts/taproot-workshop/taproot-workshop.pdf
[transcript]: https://diyhpl.us/wiki/transcripts/bitcoinops/schnorr-taproot-workshop-2019/notes/
[readme]: https://github.com/bitcoinops/taproot-workshop/blob/master/README.md
[workshop repository]: https://github.com/bitcoinops/taproot-workshop/
[musig]: https://eprint.iacr.org/2018/068
