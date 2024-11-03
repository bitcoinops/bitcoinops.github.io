---
title: 'Bitcoin Optech Newsletter #215'
permalink: /hi/newsletters/2022/08/31/
name: 2022-08-31-newsletter-hi
slug: 2022-08-31-newsletter-hi
type: newsletter
layout: newsletter
lang: hi
---
इस सप्ताह के समाचार पत्र में एक मानकीकृत वॉलेट लेबल निर्यात प्रारूप के प्रस्ताव
का वर्णन किया गया है और इसमें Bitcoin Stack Exchange के हालिया प्रश्नों
और उत्तरों के सारांश के साथ हमारे नियमित खंड शामिल हैं, नए Software रिलीज और
रिलीज उम्मीदवारों की एक सूची, और लोकप्रिय Bitcoin Infrastructure Software
में उल्लेखनीय परिवर्तनों का विवरण शामिल है।

## समाचार

- **<!--wallet-label-export-format-->वॉलेट लेबल निर्यात प्रारूप:** Bitcoin-Dev मेलिंग सूची में Craig
  Raw [पोस्ट किया गया][raw interchange] उनके पते और लेनदेन के लिए लेबल निर्यात करने के लिए उपयोग किए जाने
  वाले प्रारूप वॉलेट को मानकीकृत करने के लिए एक प्रस्तावित BIP है। एक मानकीकृत निर्यात प्रारूप सैद्धांतिक रूप से वॉलेट
  सॉफ़्टवेयर के दो टुकड़ों की अनुमति दे सकता है जो एक ही [BIP 32][topic bip32] खाता पदानुक्रम का उपयोग एक
  दूसरे के बैकअप खोलने के लिए करते हैं और न केवल धन की वसूली करते हैं बल्कि उपयोगकर्ता द्वारा मैन्युअल रूप से उनके
  लेनदेन के बारे में सभी जानकारी दर्ज करते हैं।

  BIP 32 वॉलेट को एक-दूसरे के साथ संगत बनाने की पिछली चुनौतियों को देखते हुए, शायद अधिक प्राप्त
  करने योग्य उपयोग वॉलेट से लेनदेन इतिहास को निर्यात करना और अन्य कार्यक्रमों में
  इसका उपयोग करना आसान बना देगा, जैसे लेखांकन के लिए।

  डेवलपर्स Clark Moody और Pavol Rusnak [प्रत्येक][moody slip15] ने [संदर्भ][rusnak slip15] से
  [SLIP15][] को उत्तर दिया, जो Trezor ब्रांड वॉलेट के लिए विकसित खुले निर्यात प्रारूप का वर्णन करता है।
  Craig Raw [विख्यात][raw SLIP15] उनके प्रस्तावित प्रारूप को हासिल करने का प्रयास कर रहा
  है और SLIP15 क्या प्रदान करता है, के बीच कई महत्वपूर्ण अंतर हैं। कई अन्य डिजाइन पहलुओं पर भी
  चर्चा की गई, चर्चा चल रही थी क्योंकि यह सारांश लिखा जा रहा था।

## Bitcoin Stack Exchange से चयनित प्रश्नोत्तर

*[Bitcoin Stack Exchange][bitcoin.se] उन पहले स्थानों में से एक है जहां Optech योगदानकर्ता अपने सवालों
के जवाब ढूंढते हैं --- या जब हमारे पास जिज्ञासु या भ्रमित उपयोगकर्ताओं की मदद करने के लिए कुछ खाली क्षण होते हैं। इस
मासिक फीचर में, हम अपने पिछले अपडेट के बाद से पोस्ट किए गए कुछ शीर्ष-मतदान वाले प्रश्नों और उत्तरों को हाइलाइट
करते हैं।*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-isn't-it-possible-to-add-an-op_return-commitment-(or-some-arbitrary-script)-inside-a-taproot-script-path-with-a-descriptor--> एक डिस्क्रिप्टर के साथ एक Taproot स्क्रिप्ट पथ के अंदर OP_RETURN प्रतिबद्धता (या कुछ मनमानी स्क्रिप्ट) जोड़ना संभव क्यों नहीं है?]({{bse}}114948)
  Antoine Poinsot बताते हैं कि [स्क्रिप्ट डिस्क्रिप्टर][topic descriptors] हैं वर्तमान में
  Bitcoin Core में [Miniscript][topic miniscript] का उपयोग करने के लिए विस्तारित
  किया जा रहा है और Bitcoin Core 24.0 रिलीज में अपेक्षित है। जबकि प्रारंभिक Miniscript
  सुविधाओं में केवल segwit v0 समर्थन शामिल होगा, अंततः [tapscript][topic tapscript]
  और [आंशिक वर्णनकर्ता][bitcoin core #24114] के लिए समर्थन केवल `raw()` वर्णनकर्ता का उपयोग किए
  बिना tapscript के अंदर प्रतिबद्धताओं को जोड़ना संभव बना सकता है।

- [<!--why-does-bitcoin-core-rebroadcast-transactions?--> Bitcoin Core लेन-देन का पुन: प्रसारण क्यों करता है?]({{bse}}114973)
  Amir reza Riahi को आश्चर्य होता है कि Bitcoin Core वॉलेट लेनदेन का पुन: प्रसारण क्यों
  करता है और इसमें देरी क्यों होती है। Peter Wuille ने P2P नेटवर्क में लेन-देन के प्रसार की
  गारंटी की कमी को रीब्रॉडकास्टिंग के आवश्यक होने का कारण बताया और वॉलेट से mempool तक
  रीब्रॉडकास्टिंग जिम्मेदारियों को हटाने के लिए किए गए कार्यों को नोट किया। पुन: प्रसारण में रुचि
  रखने वाले पाठक [24 अगस्त 2022][prreview 25768], [07 अप्रैल 2021][prreview 21061],
  और [27 नवंबर 2019][prreview 16698] PR समीक्षा Club की बैठकों की समीक्षा कर सकते हैं।

- [<!--when-did-bitcoin-core-deprecate-the-mining-function?--> Bitcoin Core ने माइनिंग फंक्शन को कब बंद कर दिया?]({{bse}}114687)
  Peter Wullie ने पिछले कुछ वर्षों में Bitcoin Core के भीतर खनन से संबंधित
  सुविधाओं का एक ऐतिहासिक अवलोकन प्रदान किया है।

- [<!--utxo-spendable-by-me-or-deposit-to-exchange-after-5-years?--> UTXO मेरे द्वारा खर्च किया जा सकता है या 5 साल बाद Exchange के लिए जमा किया जा सकता है?]({{bse}}114901)
  Stickies-v Bitcoin स्क्रिप्ट ऑपरेटरों का एक सिंहावलोकन प्रदान करता है, कैसे
  [taproot][topic taproot] ​​[MAST][topic mast] के साथ सक्षम है
  गोपनीयता और शुल्क के नजरिए से खर्च करने की स्थिति में सुधार करता है, और बताता है
  कि स्क्रिप्ट की [वाचाओं][topic covenants] की कमी प्रस्तावित शर्तों को पूरी तरह से स्क्रिप्ट
  में असंभव बना देती है। Vojtěch Strnad बताते हैं कि पूर्व-हस्ताक्षरित लेनदेन प्रस्तावित खर्च की
  शर्तों को पूरा करने में मदद कर सकते हैं।

- [<!--what-was-the-bug-for-the-bitcoin-value-overflow-in-2010?--> 2010 में Bitcoin मूल्य अतिप्रवाह के लिए बग क्या था?]({{bse}}114694)
  Andrew Chow [मूल्य अतिप्रवाह बग][value overflow bug] और इसके कई मुद्रास्फीति प्रभावों को सारांशित
  करता है: बड़े आउटपुट के साथ-साथ गलत गणना लेनदेन शुल्क।

## रिलीज और रिलीज उम्मीदवार

*लोकप्रिय Bitcoin इन्फ्रास्ट्रक्चर परियोजनाओं के लिए नए रिलीज और रिलीज उम्मीदवार। कृपया नई रिलीज़ में
अपग्रेड करने या रिलीज़ उम्मीदवारों का परीक्षण करने में मदद करने पर विचार करें।*

- [LND 0.15.1-beta][] एक रिलीज़ है जिसमें "[शून्य कॉन्फ़ चैनल][topic zero-conf channels],
  SCID [उपनाम][aliases], और हर जगह [taproot][topic taproot] पते इस्तेमाल
  करने के लिए समर्थन शामिल है"।

## उल्लेखनीय कोड और दस्तावेज़ीकरण परिवर्तन

*इस सप्ताह [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][LND Repo] में उल्लेखनीय परिवर्तन।
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][Rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIP)][BIPs repo], और
[Lightning BOLTs][bolts repo]।*

- [Bitcoin Core #23202][] एक [PSBT][topic psbt] बनाने की क्षमता के साथ `psbtbumpfee` RPC
  का विस्तार करता है, जो शुल्क लेन-देन को प्रभावित करता है, भले ही लेन-देन के कुछ या सभी इनपुट वॉलेट संबंधित
  न हों। PSBT को फिर उस वॉलेट के साथ साझा किया जा सकता है जो उस पर हस्ताक्षर कर सकता है।

- [Eclair #2275][] एक [दोहरी वित्त पोषित][topic dual funding] LN सेटअप लेनदेन शुल्क बंपिंग के लिए
  समर्थन जोड़ता है। PR नोट करता है कि, इस PR के साथ, "दोहरी फंडिंग पूरी तरह से Eclair द्वारा समर्थित है!"
  हालांकि यह भी नोट करता है कि डिफ़ॉल्ट रूप से दोहरी फंडिंग अक्षम है और [Core Lightning के साथ क्रॉस संगतता][news143 cln df]
  के लिए परीक्षण भविष्य में जोड़े जाएंगे।

- [Eclair #2387][] [signet][topic signet] के लिए समर्थन जोड़ता है।

- [LDK #1652][] [onion message][topic onion messages] के लिए अद्यतन समर्थन * उत्तर पथ *
  भेजने की क्षमता के साथ, और प्राप्त होने पर उन्हें डीकोड करने की क्षमता के साथ। onion संदेश प्रोटोकॉल को
  एक नोड की आवश्यकता नहीं होती है जो रिले के बाद उस संदेश के बारे में किसी भी जानकारी को ट्रैक करने के
  लिए एक onion संदेश को रिले करता है, इसलिए यह मूल संदेश के पथ के साथ स्वचालित रूप से एक उत्तर
  वापस नहीं भेज सकता है। इसका मतलब है कि एक नोड जो अपने onion संदेश का जवाब चाहता है उसे रिसीवर
  को संकेत देना होगा कि उत्तर भेजने के लिए किस पथ का उपयोग करना है।

- [HWI #627][] [p2tr][topic taproot] के लिए समर्थन जोड़ता है keypath BitBox02 हार्डवेयर साइनिंग
  डिवाइस का उपयोग करके खर्च करता है।

- [BDK #718][] ECDSA और [schnorr][topic schnorr signatures] दोनों हस्ताक्षरों को वॉलेट बनाने के
  तुरंत बाद सत्यापित करना शुरू कर देता है। यह [BIP340][] की एक सिफारिश है (देखें [न्यूज़लेटर #87][news87 verify]),
  [न्यूज़लेटर #83][news83 verify] में चर्चा की गई थी, और इसे पहले Bitcoin Core में लागू किया गया था
  (देखें [न्यूज़लेटर #175][news175 verify])।

- [BDK #705][] और [#722][bdk #722] BDK लाइब्रेरी का उपयोग करके Software को Electrum और Esplora
  सेवाओं से उपलब्ध अतिरिक्त Server-साइड विधियों तक पहुंचने की क्षमता प्रदान करते हैं।

{% include references.md %}
{% include linkers/issues.md v=2 issues="23202,2275,2387,1652,627,718,705,722,24114" %}
[lnd 0.15.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.1-beta
[news175 verify]: /en/newsletters/2021/11/17/#bitcoin-core-22934
[news87 verify]: /en/newsletters/2020/03/04/#bips-886
[news83 verify]: /en/newsletters/2020/02/05/#safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures
[raw interchange]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020887.html
[moody slip15]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020888.html
[rusnak slip15]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020892.html
[raw slip15]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020893.html
[aliases]: /hi/newsletters/2022/07/13/#lnd-5955
[slip15]: https://github.com/satoshilabs/slips/blob/master/slip-0015.md
[news143 cln df]: /en/newsletters/2021/04/07/#c-lightning-0-10-0
[prreview 25768]: https://bitcoincore.reviews/25768
[prreview 21061]: https://bitcoincore.reviews/21061
[prreview 16698]: https://bitcoincore.reviews/16698
[value overflow bug]: /en/topics/soft-fork-activation/#fix-value-overflow-bug-august-2010
