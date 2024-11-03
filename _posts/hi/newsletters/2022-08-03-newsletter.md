---
title: 'Bitcoin Optech Newsletter #211'
permalink: /hi/newsletters/2022/08/03/
name: 2022-08-03-newsletter-hi
slug: 2022-08-03-newsletter-hi
type: newsletter
layout: newsletter
lang: hi
---
इस सप्ताह का समाचार पत्र एक एकल आउटपुट स्क्रिप्ट डिस्क्रिप्टर में कई व्युत्पत्ति पथों की अनुमति देने के
प्रस्ताव का वर्णन करता है और इसमें लोकप्रिय Bitcoin बुनियादी ढांचा परियोजनाओं में उल्लेखनीय परिवर्तनों
के सारांश के साथ हमारा नियमित खंड शामिल है।

## समाचार

- **<!--multiple-derivation-path-descriptors-->एकाधिक व्युत्पत्ति पथ विवरणक:** एक एकल डिस्क्रिप्टर को
  [HD कुंजी पीढ़ी][topic bip32] के लिए दो संबंधित [BIP32][] पथ निर्दिष्ट करने की अनुमति देने के लिए Andrew Chow
  द्वारा एक [प्रस्तावित BIP][bip-multipath-descs] Bitcoin-Dev मेलिंग सूची [पोस्ट किया गया][chow desc]। पहला
  रास्ता उन पतों को सृजित करने के लिए होगा जिन पर आने वाले भुगतान प्राप्त किए जा सकते हैं। दूसरा पता वॉलेट के भीतर आंतरिक
  भुगतान के लिए होगा, अर्थात् UTXO खर्च करने के बाद वॉलेट में परिवर्तन वापस करना।

  जैसा कि [निर्दिष्ट][bip32 wallet layout] BIP32 में है, अधिकांश वॉलेट गोपनीयता बढ़ाने के
  लिए बाहरी बनाम आंतरिक पते उत्पन्न करने के लिए अलग-अलग रास्तों का उपयोग करते हैं। भुगतान प्राप्त
  करने के लिए उपयोग किए जाने वाले बाहरी पथ को कम-विश्वसनीय उपकरणों के साथ साझा किया जा सकता
  है, उदा. भुगतान प्राप्त करने के लिए इसे Webserver पर अपलोड करना। केवल परिवर्तन के लिए
  उपयोग किए जाने वाले आंतरिक पथ की आवश्यकता केवल उस समय हो सकती है जब निजी
  कुंजी की भी आवश्यकता होती है, इसलिए इसे समान सुरक्षा प्राप्त हो सकती है। यदि उदाहरण WebServer
  से छेड़छाड़ की गई थी और बाहरी पते लीक हो गए थे, तो हमलावर को यह पता चल जाएगा कि
  उपयोगकर्ता को हर बार पैसे मिले, उन्हें कितना मिला, और जब उन्होंने शुरू में पैसा खर्च किया ---
  लेकिन वे जरूरी नहीं सीखेंगे कि कितना पैसा है प्रारंभिक खर्च में भेजा गया था, और हो सकता है कि वे
  ऐसे किसी भी खर्च के बारे में न जानें जिसमें पूरी तरह से खर्च में बदलाव शामिल हो।

  [Pavol Rusnak][rusnak desc] और [Craig Raw][raw desc] के जवाबों से
  संकेत मिलता है कि Trezor Wallet और Sparrow Wallet पहले से ही Chow द्वारा प्रस्तावित योजना
  का समर्थन करते हैं। Rusnak ने यह भी पूछा कि क्या एक विवरणक दो से अधिक संबंधित पथों का वर्णन करने
  में सक्षम होना चाहिए। Dmitry Petukhov [नोट किया गया][petukhov desc] कि आज केवल आंतरिक और
  बाहरी रास्तों का व्यापक रूप से उपयोग किया जाता है और किसी भी अतिरिक्त पथ का मौजूदा वॉलेट के लिए स्पष्ट
  अर्थ नहीं होगा। इससे इंटरऑपरेबिलिटी के मुद्दे पैदा हो सकते हैं। उन्होंने सुझाव दिया कि BIP को सिर्फ दो रास्तों
  तक सीमित रखें और किसी को भी अपनी BIP लिखने के लिए अतिरिक्त रास्तों की जरूरत का इंतजार करें।

## उल्लेखनीय कोड और दस्तावेज़ीकरण परिवर्तन

*इस सप्ताह [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][LND Repo] में उल्लेखनीय परिवर्तन।
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][Rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo],
[Bitcoin Improvement Proposals (BIP)][BIPs repo], और [Lightning BOLTs][bolts repo]।*

- [Core Lightning #5441][] CLN के आंतरिक वॉलेट द्वारा उपयोग किए जाने वाले [HD बीज][topic bip32] के विरुद्ध [BIP39][]
  पासफ़्रेज़ की जांच करना आसान बनाने के लिए `hsmtool` को अपडेट करता है।

- [Eclair #2253][] [bolts #765] में निर्दिष्ट [ब्लाइंड पेमेंट्स][topic rv routing] के लिए समर्थन जोड़ता है
  (देखें [न्यूज़लेटर #187][news178 eclair 2061])।

- [LDK #1519][] में हमेशा `चैनल_अपडेट` संदेशों में `htlc_maximum_msat` फ़ील्ड शामिल होता है, जैसा कि
  [BOLTs #996][] LN विनिर्देश में विलय होने पर आवश्यक होगा। परिवर्तन के लिए पुल अनुरोध में दिया गया कारण
  संदेश पार्सिंग को सरल बनाना है।

- [Rust Bitcoin #994][] एक `लॉकटाइम` प्रकार जोड़ता है जिसका उपयोग nLockTime और [BIP65][] `OP_CHECKLOCKTIME`
  फ़ील्ड के साथ किया जा सकता है। Bitcoin में लॉकटाइम फ़ील्ड में या तो एक ब्लॉक ऊंचाई या एक [Unix epoch time][] मान हो सकता है।

- [Rust Bitcoin #1088][] [compact block][topic compact block relay] के लिए आवश्यक संरचनाओं को जोड़ता है जैसा कि
  [BIP152][] में निर्दिष्ट है, साथ ही एक नियमित ब्लॉक से एक कॉम्पैक्ट ब्लॉक बनाने के लिए एक विधि है। कॉम्पैक्ट ब्लॉक एक नोड को अपने
  साथियों को यह बताने की अनुमति देते हैं कि उन लेनदेन की पूरी प्रतियां भेजे बिना एक ब्लॉक में कौन से लेनदेन हैं। यदि किसी सहकर्मी ने
  उन लेन-देनों को पहले प्राप्त किया है और संग्रहीत किया है, जब वे अपुष्ट थे, तो उन्हें फिर से डाउनलोड करने की आवश्यकता
  नहीं है, बैंडविड्थ को बचाने और नए ब्लॉकों के रिले को तेज करने की आवश्यकता नहीं है।

{% include references.md %}
{% include linkers/issues.md v=2 issues="5441,2253,1519,994,1088,996,765" %}
[bip32 wallet layout]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#specification-wallet-structure
[chow desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020791.html
[bip-multipath-descs]: https://github.com/achow101/bips/blob/bip-multipath-descs/bip-multipath-descs.mediawiki
[rusnak desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020792.html
[raw desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020799.html
[petukhov desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020804.html
[unix epoch time]: https://en.wikipedia.org/wiki/Unix_time
[news178 eclair 2061]: /en/newsletters/2021/12/08/#eclair-2061
