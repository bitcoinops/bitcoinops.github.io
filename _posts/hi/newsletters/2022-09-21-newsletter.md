---
title: 'Bitcoin Optech Newsletter #218'
permalink: /hi/newsletters/2022/09/21/
name: 2022-09-21-newsletter-hi
slug: 2022-09-21-newsletter-hi
type: newsletter
layout: newsletter
lang: hi
---
इस सप्ताह के न्यूज़लेटर में Drivechain के पहलुओं का अनुकरण करने के लिए `SIGHASH_ANYPREVOUT` का उपयोग करने के बारे में चर्चा
का सारांश दिया गया है। सेवाओं, क्लाइंट सॉफ़्टवेयर और लोकप्रिय Bitcoin इन्फ्रास्ट्रक्चर सॉफ़्टवेयर में हाल के परिवर्तनों
का वर्णन करने वाले हमारे नियमित अनुभाग भी शामिल हैं।

## समाचार

- **APO और एक विश्वसनीय सेटअप के साथ Drivechain बनाना:** Jeremy Rubin [पोस्ट किया गया][rubin apodc] Bitcoin-Dev
  मेलिंग सूची में एक विवरण है कि कैसे एक विश्वसनीय सेटअप प्रक्रिया को प्रस्तावित [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]
  ओपकोड के साथ जोड़ा जा सकता है [Drivechain][topic sidechains] द्वारा प्रस्तावित व्यवहार के समान
  व्यवहार को लागू करने के लिए। Drivechain एक प्रकार का साइडचेन है जहां खनिक आमतौर पर साइडचैन फंड को
  सुरक्षित रखने के लिए जिम्मेदार होते हैं (पूर्ण नोड्स के विपरीत जो Bitcoin के मेनचेन पर फंड हासिल करने के
  लिए जिम्मेदार होते हैं)। ड्राइवचैन फंड चोरी करने का प्रयास करने वाले खनिकों को अपने दुर्भावनापूर्ण
  इरादों को दिन या सप्ताह पहले प्रसारित करना चाहिए, जिससे उपयोगकर्ताओं को साइडचेन के नियमों को
  लागू करने के लिए अपने पूर्ण नोड्स को बदलने का मौका मिलता है। ड्राइवचैन्स को मुख्य रूप से Bitcoin में एक सॉफ्ट
  फोर्क के रूप में शामिल करने के लिए प्रस्तावित किया गया है (देखें BIP [300][bip300] और [301][bip301]),
  लेकिन मेलिंग सूची में एक पिछली पोस्ट (देखें [न्यूज़लेटर #190][news190 dc]) वर्णन किया गया है कि कैसे Bitcoin
  की अनुबंध भाषा में कुछ अन्य लचीले प्रस्तावित परिवर्धन भी Drivechain के कार्यान्वयन की अनुमति दे सकते हैं।

  इस सप्ताह की पोस्ट में, Rubin ने बताया कि Bitcoin की अनुबंधित भाषा में प्रस्तावित जोड़ का उपयोग करके Drivechain को एक
  और तरीके से लागू किया जा सकता है, इस मामले में [BIP118][] में प्रस्तावित `SIGHASH_ANYPREVOUT` (APO) का उपयोग करके।
  वर्णित APO-आधारित Drivechain में BIP 300 की तुलना में कई कमियां हैं, लेकिन शायद ऐसा ही पर्याप्त व्यवहार प्रदान करता है कि APO
  को Drivechain को सक्षम करने के रूप में माना जा सकता है, जिसे कुछ व्यक्ति लाभ पर विचार कर सकते हैं और अन्य
  एक समस्या पर विचार कर सकते हैं।

## सेवाओं और क्लाइंट सॉफ़्टवेयर में परिवर्तन

*इस मासिक फीचर में, हम Bitcoin वॉलेट और सेवाओं के दिलचस्प अपडेट को हाइलाइट करते हैं।*

- **mempool प्रोजेक्ट ने Lightning नेटवर्क एक्सप्लोरर लॉन्च किया:** Mempool का ओपन सोर्स [Lightning डैशबोर्ड][mempool lightning]
  कुल नेटवर्क आंकड़ों के साथ-साथ व्यक्तिगत नोड तरलता और कनेक्टिविटी डेटा दिखाता है।

- **फेडरेशन Software Fedimint Lightning जोड़ता है:** हाल ही में [ब्लॉग पोस्ट][blockstream blog fedimint] में, ब्लॉकस्ट्रीम Lightning
  नेटवर्क समर्थन सहित, [Fedimint][] federated chaumian e-cash project के अपडेट की रूपरेखा तैयार करता है। परियोजना भी
  [घोषणा][fedimint signet tweet] की कि एक सार्वजनिक [Signet][topic signet] और Faucet उपलब्ध हैं।

- **Bitpay वॉलेट RBF समर्थन में सुधार करता है:** Bitpay [बेहतर][bitpay 12051][current][bitpay 11935] समर्थन [RBF][topic rbf]
  भेजने के लिए कई रिसीवरों के साथ लेनदेन के बेहतर संचालन के द्वारा।

- **Mutiny Lightning वॉलेट ने घोषणा की:** Mutiny (पहले pLN), एक गोपनीयता-केंद्रित Lightning वॉलेट, जो प्रत्येक चैनल के लिए अलग-अलग
  नोड्स का उपयोग करता है, [घोषित][mutiny wallet] था।

## उल्लेखनीय कोड और दस्तावेज़ीकरण परिवर्तन

*इस सप्ताह [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][LND Repo] में उल्लेखनीय परिवर्तन।
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][Rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIP)][BIPs repo], और
[Lightning BOLTs][bolts repo]।*

- [Core Lightning #5581][] एक नया ईवेंट सूचना topic "block_added" जोड़ता है। हर बार Bitcoin से एक नया ब्लॉक प्राप्त होने
  पर सदस्यता लेने वाले plugins को सूचित किया जाता है।

- [Eclair #2418][] और [#2408][eclair #2408] [blind roots][topic rv routing] के साथ भेजे गए भुगतान प्राप्त करने के लिए
  समर्थन जोड़ें। ब्लाइंड भुगतान करने वाले खर्च करने वाले को भुगतान प्राप्त करने वाले नोड की पहचान प्रदान नहीं की जाती है। यह गोपनीयता में सुधार कर
  सकता है, खासकर जब [अघोषित चैनल][topic unannounced channels] के साथ उपयोग किया जाता है।

- [Eclair #2416][] [proposed BOLT12][] में परिभाषित [ऑफ़र्स][topic offers] प्रोटोकॉल का उपयोग करके अनुरोधित भुगतान प्राप्त करने के लिए समर्थन
  जोड़ता है। यह blinded भुगतान प्राप्त करने के लिए हाल ही में जोड़े गए समर्थन का उपयोग करता है (Eclair #2418 के लिए पिछली सूची आइटम देखें)।

- [LND #6335][] एक `TrackPayments` API जोड़ता है जो सभी स्थानीय भुगतान प्रयासों की फ़ीड की सदस्यता लेने की अनुमति देता है।
  जैसा कि PR विवरण में वर्णित है, इसका उपयोग भुगतान के बारे में सांख्यिकीय जानकारी एकत्र करने के लिए किया जा सकता है
  ताकि भविष्य में बेहतर भुगतान और मार्ग भुगतान में मदद मिल सके, जैसे नोड प्रदर्शन [Trampoline रूटिंग][topic trampoline payments]।

- [LDK #1706][] पुष्टि किए गए लेनदेन को डाउनलोड करने के लिए [BIP158][] में निर्दिष्ट [कॉम्पैक्ट ब्लॉक फिल्टर][topic compact block filters]
  का उपयोग करने के लिए समर्थन जोड़ता है। जब उपयोग किया जाता है, यदि फ़िल्टर इंगित करता है कि एक ब्लॉक में वॉलेट को
  प्रभावित करने वाले लेनदेन हो सकते हैं, तो 4 मेगाबाइट तक का पूरा ब्लॉक डाउनलोड हो जाता है। यदि यह
  निश्चित है कि ब्लॉक में वॉलेट को प्रभावित करने वाला कोई लेन-देन नहीं है, तो कोई अतिरिक्त डेटा
  डाउनलोड नहीं किया जाता है।

{% include references.md %}
{% include linkers/issues.md v=2 issues="5581,2418,2408,2416,6335,1706" %}
[rubin apodc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020919.html
[news190 dc]: /en/newsletters/2022/03/09/#enablement-of-drivechains
[proposed bolt12]: https://github.com/rustyrussell/lightning-rfc/blob/guilt/offers/12-offer-encoding.md
[mempool lightning]: https://mempool.space/lightning
[blockstream blog fedimint]: https://blog.blockstream.com/fedimint-update/
[bitpay 12051]: https://github.com/bitpay/wallet/pull/12051
[bitpay 11935]: https://github.com/bitpay/wallet/pull/11935
[mutiny wallet]: https://bc1984.com/make-lightning-payments-private-again/
[Fedimint]: https://github.com/fedimint/fedimint
[fedimint signet tweet]: https://twitter.com/EricSirion/status/1572329210727010307
