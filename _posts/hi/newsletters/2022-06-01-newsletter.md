---
title: 'Bitcoin Optech Newsletter #202'
permalink: /hi/newsletters/2022/06/01/
name: 2022-06-01-newsletter-hi
slug: 2022-06-01-newsletter-hi
type: newsletter
layout: newsletter
lang: hi
---

इस सप्ताह का न्यूज़लेटर डेवलपर्स द्वारा silent payments पर किये गए प्रयोग का वर्णन करता है
और हमारे नियमित अनुभागों के सारांश के साथ शामिल करता हैं नई रिलीज़ और रिलीज़ उम्मीदवार, साथ ही
लोकप्रिय बिटकॉइन इंफ्रास्ट्रक्चर सॉफ्टवेयर पर किये गए उल्लेखनीय परिवर्तन।

## समाचार

- **Silent payments के साथ प्रयोग:** जैसा कि [Newsletter #194][news194 silent]
  में वर्णित है, *silent payments* लेन-देन का सार्वजनिक रिकॉर्ड बनाए बिना सार्वजनिक पहचानकर्ता
  ("address") को भुगतान करना संभव बनाता है। इस हफ्ते, डेवलपर w0xlt ने Bitcoin-Dev मेलिंग
  सूची में बिटकॉइन कोर के लिए प्रूफ-ऑफ-कॉन्सेप्ट [कार्यान्वयन][bitcoin core #24897] का उपयोग
  करके डिफ़ॉल्ट [signet][topic signet] के लिए silent payment बनाने के लिए एक ट्यूटोरियल
  [पोस्ट][w0xlt post] किया है। कई अन्य डेवलपर्स, जिनमें लोकप्रिय वॉलेट के लेखक भी शामिल हैं,
  प्रस्ताव के अन्य विवरणों पर चर्चा कर रहे हैं, जिसमें silent payments के लिए एक पता प्रारूप बनाना
  भी शामिल है।

## रिलीज़ और रिलीज़ उम्मीदवार

*लोकप्रिय बिटकॉइन इन्फ्रास्ट्रक्चर परियोजनाओं के लिए नई रिलीज़ और रिलीज़ उम्मीदवार। कृपया नई रिलीज़
में अपग्रेड करने या रिलीज़ उम्मीदवारों के परीक्षण में मदद करने पर विचार करे।*

- [HWI 2.1.1][] Ledger और Trezor उपकरणों को प्रभावित करने वाले दो छोटे बग को ठीक करता है
  और Ledger Nano S Plus के लिए समर्थन जोड़ता है।

- [LND 0.15.0-beta.rc3][] इस लोकप्रिय LN नोड के अगले प्रमुख संस्करण के लिए रिलीज़
  उम्मीदवार है।

## उल्लेखनीय कोड और दस्तावेज़ीकरण परिवर्तन

*इस सप्ताह [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], और [Lightning BOLTs][bolts repo] में
उल्लेखनीय परिवर्तन।*

- [BTCPay Server #3772][] उपयोगकर्ताओं को रिलीज़ से पहले लाइव-परीक्षण के लिए प्रयोगात्मक
  सुविधाओं को चालू करने की अनुमति देता है।

- [BTCPay Server #3744][] वॉलेट लेनदेनों को CSV या JSON प्रारूप में निर्यात करने के लिए सुविधा जोड़ता है।

- [BOLTs #968][] बिटकॉइन testnet और signet का उपयोग करके नोड्स के लिए डिफ़ॉल्ट TCP पोर्ट जोड़ता है।

{% include references.md %}
{% include linkers/issues.md v=2 issues="3772,3744,968,24897" %}
[lnd 0.15.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc3
[hwi 2.1.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.1.1
[news194 silent]: /en/newsletters/2022/04/06/#delinked-reusable-addresses
[w0xlt post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020513.html
[sp tutorial]: https://gist.github.com/w0xlt/72390ded95dd797594f80baba5d2e6ee
[sp address]: https://gist.github.com/RubenSomsen/c43b79517e7cb701ebf77eec6dbb46b8?permalink_comment_id=4177027#gistcomment-4177027
