---
title: 'Bitcoin Optech Newsletter #206'
permalink: /hi/newsletters/2022/06/29/
name: 2022-06-29-newsletter-hi
slug: 2022-06-29-newsletter-hi
type: newsletter
layout: newsletter
lang: hi
---
इस सप्ताह के समाचार पत्र में Bitcoin Stack Exchange के लोकप्रिय प्रश्नों और उत्तरों को सारांशित
करने वाले हमारे नियमित खंड शामिल हैं, नए सॉफ़्टवेयर रिलीज़ की घोषणा और उम्मीदवारों को जारी
करना, और Bitcoin इन्फ्रास्ट्रक्चर सॉफ़्टवेयर में हाल के परिवर्तनों का वर्णन करना।

## समाचार

*Bitcoin-Dev या Lightning-Dev मेलिंग सूचियों पर इस सप्ताह कोई महत्वपूर्ण समाचार नहीं मिला।*

## Bitcoin Stack Exchange से चयनित प्रश्नोत्तर

*[Bitcoin Stack Exchange][bitcoin.se] उन पहले स्थानों में से एक है जहां Optech योगदानकर्ता अपने सवालों के जवाब
ढूंढते हैं --- या जब हमारे पास जिज्ञासु या भ्रमित उपयोगकर्ताओं की मदद करने के लिए कुछ खाली क्षण होते
हैं। इस मासिक फीचर में, हम अपने पिछले अपडेट के बाद से पोस्ट किए गए कुछ शीर्ष-मतदान वाले प्रश्नों
और उत्तरों को हाइलाइट करते हैं।*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/"%}

- [<!--what-is-the-purpose-of-indexing-the-mempool-by-these-five-criteria-->इन पांच मानदंडों द्वारा mempool को अनुक्रमित करने का उद्देश्य क्या है?]({{bse}}114216)
  Murch और Glozow विभिन्न mempool लेनदेन अनुक्रमित (txid, wtxid, mempool में समय, पूर्वज शुल्क और वंशज शुल्क) की व्याख्या करते हैं।
  Bitcoin Core और साथ ही उनके उपयोग।

- [<!--bip-341-should-key-path-only-p2tr-be-eschewed-altogether-->BIP-341: क्या key-path-only p2tr को पूरी तरह से छोड़ दिया जाना चाहिए?]({{bse}}113989)
  Pieter Wuille ने 4 [Taproot][topic Taproot] keypath खर्च विकल्पों को परिभाषित किया, यह बताता है कि [BIP341 अनुशंसा क्यों करता है][bip41 constructing]
  "noscript" विकल्प, और उन परिदृश्यों को नोट करता है जहां अन्य विकल्पों को प्राथमिकता दी जा सकती है।

- [<!--was-the-addition-of-op-nop-codes-in-bitcoin-0-3-6-a-hard-or-soft-fork-->क्या Bitcoin 0.3.6 में OP_NOP कोड जोड़ना एक हार्ड या सॉफ्ट फोर्क था?]({{bse}}113994)
  Pieter Wuille बताते हैं कि Bitcoin Core 0.3.6 में [`OP_NOP` कोड][wiki reserved words] को जोड़ना एक पिछड़ा असंगत सर्वसम्मति परिवर्तन था
  क्योंकि पुराने सॉफ़्टवेयर संस्करण नए मान्य `OP_NOP` कोड के साथ लेनदेन को अमान्य के रूप में देखेंगे। हालांकि, चूंकि इन `OP_NOP` कोड का उपयोग करने वाले किसी भी लेनदेन का पहले खनन नहीं किया गया था, इसलिए कोई वास्तविक फोर्क नहीं था।

- [<!--what-is-the-largest-multisig-quorum-currently-possible-->वर्तमान में संभव सबसे बड़ा multisig quorum क्या है?]({{bse}}114048)
  Andrew Chow विभिन्न संभावित multisig प्रकारों को सूचीबद्ध करता है (bare स्क्रिप्ट, P2SH, P2WSH, P2TR, P2TR + [MuSig][topic musig]) और प्रत्येक के लिए बहु-हस्ताक्षर quorum प्रतिबंध।

- [<!--what-is-the-difference-between-blocksonly-and-block-relay-only-in-bitcoin-core-->Bitcoin Core में blockonly और block-relay-only के बीच क्या अंतर है?]({{bse}}114081)
  Lightlike block-relay-only कनेक्शन और `-blockonly` मोड में चलने वाले नोड के बीच अंतर को सूचीबद्ध करता है।

- [<!--where-are-bips-40-and-41-->BIP 40 और 41 कहां हैं?]({{bse}}114168) उपयोगकर्ता Andrew पूछते हैं कि Stratum
  वायर प्रोटोकॉल के लिए [असाइन किए गए BIP नंबर][assigned BIP numbers] BIP 40 और Stratum माइनिंग प्रोटोकॉल के लिए BIP 41
  में कोई सामग्री क्यों नहीं है। [अलग उत्तर][se 114179] में, Michael Folkson कुछ कार्य-प्रगति Stratum दस्तावेज़ीकरण लिंक से लिंक करता है।

## रिलीज और रिलीज उम्मीदवार

* लोकप्रिय Bitcoin इन्फ्रास्ट्रक्चर परियोजनाओं के लिए नए रिलीज और रिलीज उम्मीदवार। कृपया नई
रिलीज़ में अपग्रेड करने या रिलीज़ उम्मीदवारों का परीक्षण करने में मदद करने पर विचार करें।*

- [LND 0.15.0-beta][] इस लोकप्रिय LN नोड के अगले प्रमुख संस्करण के लिए एक रिलीज है। यह
  इनवॉइस मेटाडेटा के लिए जोड़ता है जिसका उपयोग [स्टेटलेस इनवॉइस][topic stateless invoices] के लिए अन्य कार्यक्रमों (और
  LND के संभावित भविष्य के संस्करणों) द्वारा किया जा सकता है और [P2TR][topic taproot] में Bitcoin प्राप्त करने
  और खर्च करने के लिए आंतरिक वॉलेट में समर्थन जोड़ता है। प्रायोगिक [MuSig2][topic musig] समर्थन के साथ, keyspend आउटपुट।

- [Core Lightning 0.11.2][] LN नोड का बग फिक्स रिलीज है। Core Lightning डेवलपर्स द्वारा उन्नयन "अत्यधिक अनुशंसित" है।

## उल्लेखनीय कोड और दस्तावेज़ीकरण परिवर्तन

*इस सप्ताह [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][LND Repo] में उल्लेखनीय परिवर्तन। [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][Rust bitcoin repo],
[BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIP)][BIPs repo],
और [Lightning BOLTs][bolts repo]।*

- [Core Lightning #5306][] millisatoshis के लिए लगातार "msat" नाम का उपयोग करने के लिए कई
  API अपडेट करता है और उन क्षेत्रों में JSON मानों को संख्याओं के रूप में भी लौटाता है। अन्य फ़ील्ड
  के साथ संगतता प्रदान करने के लिए कुछ फ़ील्ड का नाम बदल दिया गया है। पुराना व्यवहार बहिष्कृत कर
  दिया गया है और इसलिए अस्थायी रूप से उपलब्ध रहेगा।

- [LDK #1531][] LN फंडिंग लेनदेन के लिए [एंटी फीस स्निपिंग][topic fee sniping] का उपयोग शुरू करता है।

{% include references.md %}
{% include linkers/issues.md v=2 issues="5306,1531" %}
[lnd 0.15.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta
[core lightning 0.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.2
[bip41 constructing]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#user-content-constructing_and_spending_taproot_outputs
[wiki reserved words]: https://en.bitcoin.it/wiki/Script#Reserved_words
[se 114179]: https://bitcoin.stackexchange.com/a/114179/87121
[assigned bip numbers]: https://github.com/bitcoin/bips#readme