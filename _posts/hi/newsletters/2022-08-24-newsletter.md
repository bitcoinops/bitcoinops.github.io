---
title: 'Bitcoin Optech Newsletter #214'
permalink: /hi/newsletters/2022/08/24/
name: 2022-08-24-newsletter-hi
slug: 2022-08-24-newsletter-hi
type: newsletter
layout: newsletter
lang: hi
---
इस सप्ताह का न्यूज़लेटर चैनल जैमिंग हमलों के बारे में एक गाइड के अवलोकन से जुड़ा
है और Silent Payment के लिए PR के कई अपडेट को सारांशित करता है। लोकप्रिय
सेवाओं और ग्राहकों में परिवर्तन के विवरण के साथ हमारे नियमित खंड भी शामिल हैं, नई रिलीज
और रिलीज उम्मीदवारों की घोषणा, और लोकप्रिय Bitcoin Infrastructure Software में
उल्लेखनीय परिवर्तनों के सारांश।

## समाचार

- **<!--overview-of-channel-jamming-attacks-and-mitigations-->चैनल जैमिंग हमलों और शमन का अवलोकन:**
  Antoine Riard और Gleb Naumenko [घोषित][riard jam] Lightning-Dev मेलिंग सूची में कि उन्होंने
  [प्रकाशित][rn jam] [channel jamming attacks][topic channel jamming attacks] के लिए एक गाइड किया है
  और कई प्रस्तावित समाधान। गाइड यह भी जांचता है कि कैसे कुछ समाधान LN के शीर्ष पर प्रोटोकॉल निर्माण को लाभ
  पहुंचा सकते हैं, जैसे स्वैप प्रोटोकॉल और छोटी अवधि [DLC][topic dlc]।

- **अपडेट किया गया Silent Payment PR:** woltx [पोस्ट किया गया][woltx sp] Bitcoin-Dev
  मेलिंग लिस्ट में कि [Silent Payment][topic silent payments] के लिए Bitcoin Core के PR को
  अपडेट कर दिया गया है। मौन भुगतान एक ऐसा पता प्रदान करते हैं जिसे विभिन्न व्ययकर्ताओं द्वारा पुन: उपयोग किया जा
  सकता है, उन खर्चों के बीच एक लिंक बनाए बिना जो कि चेन पर देखे जा सकते हैं (हालांकि रिसीवर को सावधान रहना होगा कि
  उनके बाद के कार्यों के माध्यम से उस गोपनीयता को कमजोर न करें)। PR में सबसे महत्वपूर्ण परिवर्तन Silent Payment के
  लिए एक नए प्रकार के [आउटपुट स्क्रिप्ट डिस्क्रिप्टर][topic descriptors] को जोड़ना है।

    नए डिस्क्रिप्टर के डिजाइन को PR पर काफी चर्चा मिली। यह नोट किया गया था कि प्रति वॉलेट केवल
    एक Silent Payment विवरणक की अनुमति देना नए लेनदेन की निगरानी के लिए सबसे कुशल होगा, लेकिन यह
    कई मामलों में उपयोगकर्ताओं के लिए एक बुरा अनुभव भी पैदा करेगा। इस मुद्दे को हल
    करने के लिए Silent Payment डिजाइन में एक मामूली बदलाव का प्रस्ताव किया गया था, हालांकि यह ट्रेडऑफ़ के
    साथ भी आया था।

## सेवाओं और क्लाइंट सॉफ़्टवेयर में परिवर्तन

*इस मासिक फीचर में, हम Bitcoin वॉलेट और सेवाओं के दिलचस्प अपडेट को हाइलाइट करते हैं।*

- **Purse.io Lightning सपोर्ट जोड़ता है:** [हालिया ट्वीट][purse ln tweet] में, Purse.io
  ने Lightning नेटवर्क का उपयोग करके जमा करने (प्राप्त करने) और निकालने (भेजने) के लिए समर्थन की घोषणा की।

- **अवधारणा का प्रमाण Coinjoin कार्यान्वयन joinstr:** 1440000Bytes विकसित [joinstr][joinstr github],
  कॉन्सेप्ट का एक प्रमाण [Coinjoin][topic coinjoin] कार्यान्वयन [nostr प्रोटोकॉल][nostr github], एक
  सार्वजनिक कुंजी आधारित रिले का उपयोग करके बिना सेंट्रल Server वाला नेटवर्क।

- **ColdCard फर्मवेयर 5.0.6 जारी:** ColdCard का संस्करण 5.0.6 [BIP85][], `OP_RETURN` स्क्रिप्ट, और
  मल्टीसिग [डिस्क्रिप्टर][topic descriptors] के लिए अधिक समर्थन जोड़ता है।

- **Nunchuk Taproot सपोर्ट जोड़ता है:** [Nunchuk के मोबाइल वॉलेट][nunchuk appstore] के नवीनतम संस्करणों में,
  [Taproot][topic taproot] (single-sig), [Signet][topic signet], और बढ़ाया [PSBT][topic psbt] समर्थन जोड़ा गया।

## रिलीज और रिलीज उम्मीदवार

*लोकप्रिय Bitcoin इन्फ्रास्ट्रक्चर परियोजनाओं के लिए नए रिलीज और रिलीज उम्मीदवार। कृपया नई रिलीज़ में
अपग्रेड करने या रिलीज़ उम्मीदवारों का परीक्षण करने में मदद करने पर विचार करें।*

- [BDK 0.21.0][] वॉलेट बनाने के लिए इस लाइब्रेरी की नवीनतम रिलीज़ है।

- [Core Lightning 0.12.0][] इस लोकप्रिय LN नोड कार्यान्वयन के अगले प्रमुख संस्करण की रिलीज़ है।
  इसमें एक नया `bookkeeper` plugin शामिल है (देखें [न्यूज़लेटर #212][news212 bookkeeper]),
  एक `commando` plugin (देखें [न्यूज़लेटर #210][news210 commando]), [स्टेटिक चैनल बैकअप] के
  लिए समर्थन जोड़ता है। चैनल बैकअप], और स्पष्ट रूप से अनुमत साथियों को आपके नोड में
  [शून्य-कॉन्फ़ चैनल][topic zero-conf channels] खोलने की क्षमता देता है। वे नई सुविधाएं
  कई अन्य अतिरिक्त सुविधाओं और बग फिक्स के अतिरिक्त हैं।

- [LND 0.15.1-beta.rc1][] एक रिलीज उम्मीदवार है जिसमें "[शून्य-कॉन्फ चैनल][topic zero-conf channels],
  [और] SCID [उपनाम][aliases] के लिए समर्थन शामिल है और यह ​हर जगह [Taproot][topic Taproot] पतो का उपयोग
  करने पर स्विच करता है।

## उल्लेखनीय कोड और दस्तावेज़ीकरण परिवर्तन

*इस सप्ताह [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][LND Repo] में उल्लेखनीय परिवर्तन।
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][Rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIP)][BIPs repo], और
[Lightning BOLTs][bolts repo]।*

- [Bitcoin Core #25504][] एक नए क्षेत्र, `parent_descs` में संबंधित वर्णनकर्ताओं को बताने के लिए
  `listsinceblock`, `listtransactions`, और `gettransactions` के जवाबों में संशोधन करता है। इसके
  अतिरिक्त, `listsinceblock` को अब वैकल्पिक पैरामीटर `include_change` के अनुसार परिवर्तन आउटपुट को स्पष्ट रूप से सूचीबद्ध
  करने का निर्देश दिया जा सकता है। आमतौर पर, परिवर्तन आउटपुट को आउटबाउंड भुगतानों के
  निहित उप-उत्पादों के रूप में छोड़ दिया जाता है, लेकिन उन्हें वॉच-ओनली वाले विवरणकों के संदर्भ में
  सूचीबद्ध करना दिलचस्प हो सकता है।

- [Eclair #2234][] इसकी घोषणाओं में एक नोड के साथ एक DNS नाम को जोड़ने के लिए समर्थन जोड़ता है, जैसा कि अब [BOLTs #911][] द्वारा
  अनुमत है (देखें [न्यूज़लेटर #212][news212 bolts911])।

- [LDK #1503][] [BOLTs #759][] द्वारा परिभाषित [onion संदेशों][topic onion messages] के लिए समर्थन जोड़ता है।
  PR इंगित करता है कि यह परिवर्तन बाद में [ऑफ़र्स][topic offers] के लिए समर्थन जोड़ने की तैयारी में है।

- [LND #6596][] एक नया `wallet addresses list` RPC जोड़ता है जो वॉलेट के सभी पतों और उनके वर्तमान बैलेंस को सूचीबद्ध
  करता है।

- [BOLTs #1004][] यह अनुशंसा करना शुरू करता है कि रूटिंग के लिए चैनलों के बारे में जानकारी रखने वाले नोड्स को अपनी
  जानकारी को हटाने से पहले चैनल के बंद होने के बाद कम से कम 12 ब्लॉकों तक प्रतीक्षा करनी चाहिए। यह
  देरी [स्प्लिसेस][topic splicing] का पता लगाने में मदद करेगी जहां एक चैनल वास्तव में बंद नहीं है, बल्कि इसके बजाय एक
  ऑनचैन लेनदेन में इसमें से धन जोड़ा या हटा दिया गया है।

{% include references.md %}
{% include linkers/issues.md v=2 issues="25504,2234,1503,911,759,6596,1004" %}
[core lightning 0.12.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0
[bdk 0.21.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.21.0
[lnd 0.15.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.1-beta.rc1
[news212 bolts911]: /hi/newsletters/2022/08/10/#bolts-911
[aliases]: /hi/newsletters/2022/07/13/#lnd-5955
[woltx sp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020883.html
[riard jam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-August/003673.html
[rn jam]: https://jamming-dev.github.io/book/
[news210 commando]: /hi/newsletters/2022/07/27/#core-lightning-5370
[news212 bookkeeper]: /hi/newsletters/2022/08/10/#core-lightning-5071
[joinstr github]: https://github.com/1440000bytes/joinstr
[nostr github]: https://github.com/nostr-protocol/nostr
[nunchuk appstore]: https://apps.apple.com/us/app/nunchuk-bitcoin-wallet/id1563190073
[purse ln tweet]: https://twitter.com/PurseIO/status/1557495102641246210
