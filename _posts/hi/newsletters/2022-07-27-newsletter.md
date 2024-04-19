---
title: 'Bitcoin Optech Newsletter #210'
permalink: /hi/newsletters/2022/07/27/
name: 2022-07-27-newsletter-hi
slug: 2022-07-27-newsletter-hi
type: newsletter
layout: newsletter
lang: hi
---
इस सप्ताह के समाचार पत्र गैर-विरासत पतों के लिए हस्ताक्षरित संदेश बनाने के लिए प्रस्तावित BIP का वर्णन
करते हैं और सेवा सुरक्षा से इनकार करने के लिए बिटकोइन की छोटी मात्रा को जलाने के बारे में एक
चर्चा का सारांश देते हैं। Bitcoin Stack Exchange के लोकप्रिय प्रश्नों और उत्तरों के साथ हमारे नियमित खंड भी शामिल हैं, नई
रिलीज और रिलीज उम्मीदवारों की घोषणा, और लोकप्रिय Bitcoin Infrastructure Software में उल्लेखनीय परिवर्तनों के सारांश।

## समाचार

- **<!--multiformat-single-sig-message-signing-->मल्टीफॉर्मैट सिंगल-सिग मैसेज साइनिंग:** Bitcoin Core और कई
  अन्य वॉलेट्स में लंबे समय से मनमाने संदेशों पर हस्ताक्षर करने और सत्यापित करने के लिए समर्थन शामिल है, जब उन्हें साइन करने के लिए उपयोग
  की जाने वाली कुंजी P2PKH पते से मेल खाती है। Bitcoin Core किसी भी अन्य प्रकार के पते के लिए मनमाने संदेशों पर हस्ताक्षर करने
  या सत्यापित करने का समर्थन नहीं करता है, जिसमें सिंगल-सिग P2SH-P2WPKH, मूल P2WPKH और P2TR आउटपुट को कवर करने
  वाले पते शामिल हैं। एक पिछला प्रस्ताव, [BIP322][], [पूरी तरह से सामान्य संदेश हस्ताक्षर][topic generic signmessage] प्रदान
  करने के लिए जो किसी भी स्क्रिप्ट के साथ काम कर सकता है अभी तक Bitcoin Core या किसी अन्य लोकप्रिय वॉलेट में
  [मर्ज नहीं किया गया है][bitcoin core #24058] जिसके बारे में हम जानते हैं।

  इस हफ्ते, Ali Sherief [प्रस्तावित][sherief gsm] कि P2WPKH के लिए उपयोग किए जाने वाले
  समान संदेश हस्ताक्षर एल्गोरिथ्म का उपयोग अन्य आउटपुट प्रकारों के लिए भी किया जाएगा। सत्यापन के लिए,
  प्रोग्राम को यह पता लगाना चाहिए कि कुंजी कैसे प्राप्त करें (यदि आवश्यक हो) और पता प्रकार का उपयोग करके
  हस्ताक्षर को सत्यापित करें। उदाहरण के लिए, जब 20 बाइट डेटा तत्व के साथ [bech32][topic bech32]
  पता प्रदान किया जाता है, तो मान लें कि यह P2WPKH आउटपुट के लिए है।

  डेवलपर Peter Gray [नोट किया गया][gray cc] कि ColdCard वॉलेट पहले से ही इस तरह से हस्ताक्षर बनाते हैं और
  डेवलपर Craig Raw [कहा][raw sparrow] Sparrow Wallet है कि वॉलेट [BIP137][] का पालन करने के अलावा
  उन्हें मान्य करने में सक्षम है। सत्यापन नियम और Electrum में लागू किए गए नियमों का थोड़ा अलग सेट।

  Sherief व्यवहार को निर्दिष्ट करते हुए एक BIP लिखने की योजना बना रहा है।

- **<!--proof-of-micro-burn-->माइक्रो-बर्न का सबूत:** कई डेवलपर्स [चर्चा][pomb] ऑन-चेन लेनदेन के
  मामलों और डिजाइनों का उपयोग करते हैं जो संसाधन खपत के प्रमाण के रूप में Bitcoin ("बर्न" Bitcoin)
  को छोटे वेतन वृद्धि में नष्ट कर देते हैं। Ruben Somsen [थ्रेड से][somsen hashcash] द्वारा एक
  उदाहरण के उपयोग के मामले का विस्तार करने के लिए, विचार यह होगा कि 100 उपयोगकर्ताओं को प्रत्येक को
  अपने ईमेल से इस बात का प्रमाण देने की अनुमति दी जाए कि $1 Bitcoin को जला दिया गया था, जो स्पैम-विरोधी प्रकार
  प्रदान करता है। मूल रूप से [hashcash][] के लाभ के रूप में सुरक्षा की कल्पना की गई थी।

  मर्कल ट्री का उपयोग करते हुए कई समाधानों पर चर्चा की गई, हालांकि एक प्रतिवादी ने
  सुझाव दिया कि इसमें शामिल छोटी मात्रा का सुझाव है कि प्रतिभागियों का विश्वास (या आंशिक रूप से
  विश्वास) एक केंद्रीकृत तृतीय पक्ष अनावश्यक जटिलता से बचने का एक उचित तरीका हो
  सकता है।

## Bitcoin Stack Exchange से चयनित प्रश्नोत्तर

*[Bitcoin Stack Exchange][bitcoin.se] उन पहले स्थानों में से एक है जहां Optech
योगदानकर्ता अपने सवालों के जवाब ढूंढते हैं --- या जब हमारे पास जिज्ञासु या भ्रमित उपयोगकर्ताओं की
मदद करने के लिए कुछ खाली क्षण होते हैं। इस मासिक फीचर में, हम अपने पिछले अपडेट के बाद से
पोस्ट किए गए कुछ शीर्ष-मतदान वाले प्रश्नों और उत्तरों को हाइलाइट करते हैं।*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-do-invalid-signatures-in-op-checksigadd-not-push-to-the-stack--> `OP_CHECKSIGADD` में अमान्य हस्ताक्षर Stack पर क्यों नहीं धकेलते?]({{bse}}114446)
  Chris Stewart पूछते हैं कि "यदि कोई अमान्य हस्ताक्षर पाया जाता है, तो दुभाषिया जारी रखने के बजाय
  निष्पादन में विफल रहता है"। Peter Wuille बताते हैं कि यह व्यवहार, जिसे BIP340-342
  में परिभाषित किया गया है, भविष्य में [schnorr हस्ताक्षर][topic schnorr signatures] के बैच सत्यापन का
  समर्थन करने के लिए डिज़ाइन किया गया है। Andrew Chow व्यवहार के लिए एक अतिरिक्त कारण देते हैं, यह देखते हुए
  कि इस दृष्टिकोण से कुछ लचीलापन संबंधी चिंताओं को भी कम किया जाता है।

- [<!--what-are-packages-in-bitcoin-core-and-what-is-their-use-case-->Bitcoin Core में पैकेज क्या हैं और उनका उपयोग मामला क्या है?]({{bse}}114305)
  Antoine Poinsot बताते हैं [पैकेज][bitcoin docs packages] (संबंधित लेनदेन का एक समूह), [पैकेज रिले][topic package relay] से उनका संबंध, और हाल ही में [पैकेज रिले BIP प्रस्ताव][news201 package relay]।

- [<!--how-much-blockspace-would-it-take-to-spend-the-complete-utxo-set-->संपूर्ण UTXO सेट को खर्च करने में कितना ब्लॉकस्पेस लगेगा?]({{bse}}114043)
  Murch सभी मौजूदा UTXO को समेकित करने के एक काल्पनिक परिदृश्य की पड़ताल करता है।
  वह प्रत्येक आउटपुट प्रकार के लिए ब्लॉकस्पेस गणना प्रदान करता है और निष्कर्ष निकालता है कि इस प्रक्रिया में लगभग 11,500 ब्लॉक लगेंगे।

- [<!--does-an-uneconomical-output-need-to-be-kept-in-the-utxo-set-->क्या UTXO सेट में एक गैर-आर्थिक आउटपुट रखने की आवश्यकता है?]({{bse}}114493)
  Stickies-v नोट करता है कि 'OP_RETURN' या अधिकतम स्क्रिप्ट आकार से बड़ी स्क्रिप्ट सहित UTXO को
  UTXO से हटा दिया जाता है। सेट करें, [अनौपचारिक आउटपुट][topic uneconomical outputs] को
  हटाने से समस्याएं हो सकती हैं, जिसमें एक हार्ड फोर्क भी शामिल है, जैसा कि Peter Wuille बताते हैं, अगर उन आउटपुट
  को खर्च किया जाता है।

- [<!--is-there-code-in-libsecp256k1-that-should-be-moved-to-the-bitcoin-core-codebase-->क्या libsecp256k1 में कोड है जिसे Bitcoin Core कोडबेस में ले जाया जाना चाहिए?]({{bse}}114467)
  Bitcoin Core कोडबेस के क्षेत्रों को संशोधित करने के अन्य प्रयासों के समान [libbitcoinkernel][libbitcoinkernel project]
  या [प्रक्रिया पृथक्करण][devwiki process separation], Peter Wuille [libsecp256k1][] परियोजना की जिम्मेदारी का एक
  स्पष्ट क्षेत्र नोट करता है: वह सब कुछ जिसमें निजी या सार्वजनिक कुंजी पर संचालन शामिल है।

- [<!--mining-stale-low-difficulty-blocks-as-a-dos-attack-->एक DoS हमले के रूप में पुराने कम-कठिनाई वाले ब्लॉकों का खनन]({{bse}}114241)
  Andrew Chow बताते हैं कि [assumevalid][assumevalid notes] और हाल ही में [`nMinimumChainWork`][bitcoin core #9053]
  कम-कठिनाई के श्रृंखला हमलो को फ़िल्टर करने में मदद करते हैं ।

## रिलीज और रिलीज उम्मीदवार

*लोकप्रिय Bitcoin इन्फ्रास्ट्रक्चर परियोजनाओं के लिए नए रिलीज और रिलीज उम्मीदवार। कृपया नई रिलीज़ में
अपGrayड करने या रिलीज़ उम्मीदवारों का परीक्षण करने में मदद करने पर विचार करें।*

- [BTCPay Server 1.6.3][] इस लोकप्रिय स्व-होस्ट किए गए भुगतान प्रोसेसर में नई सुविधाएँ, सुधार और बग समाधान जोड़ता है।

- [LDK 0.0.110][] LN-सक्षम अनुप्रयोगों के निर्माण के लिए इस पुस्तकालय में विभिन्न प्रकार की नई सुविधाएँ (कई पिछले
  समाचार पत्रों में शामिल) जोड़ता है।

## उल्लेखनीय कोड और दस्तावेज़ीकरण परिवर्तन

*इस सप्ताह [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][LND Repo] में उल्लेखनीय परिवर्तन। [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][Rust bitcoin repo],
[BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIP)][BIPs repo],
और [Lightning BOLTs][bolts repo]।*

- [Bitcoin Core #25351][] यह सुनिश्चित करता है कि वॉलेट में पतों, चाबियों, या डिस्क्रिप्टरों के आयात के बाद, बाद का पुन: स्कैन न केवल
  ब्लॉकचैन को स्कैन करेगा बल्कि यह भी मूल्यांकन करेगा कि क्या mempool में लेनदेन वॉलेट के लिए प्रासंगिक हैं।

- [Core Lightning #5370][] `commando` plugin को फिर से लागू करता है और इसे CLN का एक अंतर्निहित हिस्सा बनाता है।
  commando नोड को LN संदेशों का उपयोग करके अधिकृत साथियों से आदेश प्राप्त करने की अनुमति देता है। साथियों को *runes* का
  उपयोग करने के लिए अधिकृत किया जाता है, जो कि [macaroons][] के सरलीकृत संस्करण पर आधारित एक कस्टम CLN प्रोटोकॉल है।
  हालांकि commando अब CLN में बनाया गया है, यह केवल तभी संचालित होता है जब कोई उपयोगकर्ता rune प्रमाणीकरण टोकन बनाता है।
  अतिरिक्त जानकारी के लिए, [commando][] और [commando-rune][] के लिए CLN के मैनुअल पेज देखें।

- [BOLTs #1001][] अनुशंसा करता है कि नोड जो अपनी भुगतान अग्रेषण नीतियों में परिवर्तन का विज्ञापन करते हैं, वे
  लगभग 10 मिनट तक पुरानी नीतियों का उपयोग करके प्राप्त भुगतानों को स्वीकार करते रहें। यह भुगतानों
  को केवल इसलिए विफल होने से रोकता है क्योंकि प्रेषक ने हाल के नीति अपडेट के बारे में नहीं सुना है। इस
  तरह के एक नियम को अपनाने वाले कार्यान्वयन के उदाहरण के लिए [न्यूज़लेटर #169][news169 cln4806] देखें।

{% include references.md %}
{% include linkers/issues.md v=2 issues="25351,5370,1001,24058,9053" %}
[BTCPay Server 1.6.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.6.3
[LDK 0.0.110]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.110
[commando]: https://github.com/rustyrussell/lightning/blob/2e13b72f55080be07ea68de77976eb990a043f5d/doc/lightning-commando.7.md
[commando-rune]: https://github.com/rustyrussell/lightning/blob/2e13b72f55080be07ea68de77976eb990a043f5d/doc/lightning-commando-rune.7.md
[news169 cln4806]: /en/newsletters/2021/10/06/#c-lightning-4806
[sherief gsm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020759.html
[gray cc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020762.html
[raw sparrow]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020766.html
[pomb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020745.html
[hashcash]: https://en.wikipedia.org/wiki/Hashcash
[somsen hashcash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020746.html
[macaroons]: https://en.wikipedia.org/wiki/Macaroons_(computer_science)
[bitcoin docs packages]: https://github.com/bitcoin/bitcoin/blob/53b1a2426c58f709b5cc0281ef67c0d29fc78a93/doc/policy/packages.md#definitions
[news201 package relay]: /en/newsletters/2022/05/25/#package-relay-proposal
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[devwiki process separation]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/Process-Separation
[assumevalid notes]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
