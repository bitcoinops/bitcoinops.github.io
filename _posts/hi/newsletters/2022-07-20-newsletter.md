---
title: 'Bitcoin Optech Newsletter #209'
permalink: /hi/newsletters/2022/07/20/
name: 2022-07-20-newsletter-hi
slug: 2022-07-20-newsletter-hi
type: newsletter
layout: newsletter
lang: hi
---
इस सप्ताह का समाचार पत्र Bitcoin के लिए एक स्थायी दीर्घकालिक ब्लॉक इनाम प्रदान करने के बारे में कई
संबंधित चर्चाओं को सारांशित करता है। ग्राहकों और सेवाओं के लिए नई सुविधाओं के विवरण के साथ
हमारे नियमित खंड भी शामिल हैं, नई रिलीज और रिलीज उम्मीदवारों की घोषणा, और लोकप्रिय Bitcoin इंफ्रास्ट्रक्चर
सॉफ्टवेयर में उल्लेखनीय परिवर्तनों के सारांश।

## समाचार

- **<!--long-term-block-reward-ongoing-discussion-->दीर्घकालिक ब्लॉक इनाम चल रही चर्चा:**
  Bitcoin की सब्सिडी में गिरावट के रूप में Proof of Work (PoW) के लिए मज़बूती से भुगतान
  करने के बारे में चर्चा जारी रखते हुए, Bitcoin-Dev मेलिंग सूची पर दो नए सूत्र शुरू किए गए:

  - [<!--tail-emission-is-not-inflationary-->पूंछ उत्सर्जन मुद्रास्फीति नहीं है][todd tail] Peter Todd
    के एक तर्क के साथ शुरू होता है कि नए बनाए गए Bitcoin के साथ खनिकों
    को स्थायी रूप से भुगतान करने से प्रचलन में Bitcoin की संख्या हमेशा के लिए नहीं बढ़ेगी। इसके बजाय,
    उनका मानना ​​​​है कि हर साल कुछ Bitcoin खो जाएंगे और अंततः, जिस दर पर Bitcoin खो गए हैं, वह उस दर
    पर अभिसरण होगा जिस पर नए Bitcoin का उत्पादन होता है, जिसके परिणामस्वरूप प्रचलन में
    सिक्कों की लगभग स्थिर संख्या होती है। उन्होंने यह भी नोट किया कि Bitcoin के लिए एक सतत ब्लॉक सब्सिडी
    जोड़ना एक हार्ड फोर्क होगा। कुछ लोगों ने उनकी पोस्ट का जवाब दिया और Bitcoin Talk पर
    [इसके बारे में thread][talk tail] हम केवल कुछ उत्तरों को संक्षेप में प्रस्तुत करने का प्रयास करेंगे जो हमें सबसे उल्लेखनीय लगे।

    - *<!--hard-fork-not-required-->हार्ड फोर्क की आवश्यकता नहीं:* Vjudeu [सुझाव देता है][vjudeu sf]
      कि एक सॉफ्ट फोर्क विशेष अर्थ के साथ शून्य satoshi का भुगतान करने वाले लेनदेन आउटपुट को जोड़कर नए
      Bitcoin बना सकता है। उदाहरण के लिए, जब कांटे में प्रवेश करने वाला नोड शून्य-सैट आउटपुट देखता है, तो यह
      वास्तविक हस्तांतरण के लिए लेनदेन के दूसरे हिस्से को देखता है। यह Bitcoin के दो वर्ग बनाता
      है, लेकिन संभवतः नरम कांटा विरासत-Bitcoin को संशोधित-Bitcoin में बदलने के लिए एक तंत्र
      प्रदान करेगा। Vjudeu ने नोट किया कि उसी तंत्र का उपयोग गोपनीयता बढ़ाने वाली Bitcoin राशि को अंधा
      करने के लिए भी किया जा सकता है (उदाहरण के लिए [गोपनीय लेनदेन][confidential transactions] का उपयोग करना)।

    - *<!--no-reason-to-believe-perpetual-issuance-is-sufficient-->सतत जारी होने पर विश्वास करने का
      कोई कारण पर्याप्त नहीं है*: Anthony Towns [पोस्ट्स][towns pi] मेलिंग लिस्ट में और Gregory Maxwell [पोस्ट्स][maxwell pi] Bitcoin Talk को विश्वास करने का कोई कारण नहीं है कि खनिकों को
      सिक्कों की एक राशि का भुगतान करना खोए हुए सिक्कों की औसत दर के बराबर
      पर्याप्त PoW सुरक्षा प्रदान करेगा, और ऐसे मामले हैं जहां यह PoW सुरक्षा के लिए अधिक
      भुगतान कर सकता है। यदि एक स्थायी निर्गम सुरक्षा की गारंटी नहीं दे सकता है और
      यदि इसमें अतिरिक्त समस्याएं पैदा करने की एक महत्वपूर्ण संभावना है, तो एक
      सीमित सब्सिडी के साथ रहना बेहतर लगता है --- जबकि यह सुरक्षा की गारंटी भी नहीं
      दे सकता --- कम से कम यह अतिरिक्त समस्याएं उत्पन्न नहीं करता है और
      पहले से ही सभी Bitcoiners (निहित या स्पष्ट रूप से) द्वारा स्वीकार किया जाता है।

      Maxwell ने आगे नोट किया कि Bitcoin खनिक औसतन केवल लेनदेन शुल्क के माध्यम से काफी
      अधिक मूल्य एकत्र करते हैं, जो कि कई altcoins सब्सिडी, शुल्क और अन्य प्रोत्साहनों के
      संयोजन के माध्यम से अपने खनिकों को भुगतान करते हैं। उन altcoins को मौलिक PoW
      हमलों का सामना नहीं करना पड़ रहा है, जिसका अर्थ है कि यह हो सकता है कि Bitcoin
      को सुरक्षित रखने के लिए अकेले लेनदेन शुल्क के माध्यम से पर्याप्त मूल्य का
      भुगतान किया जा रहा हो। संक्षेप में, Bitcoin पहले से ही उस बिंदु से आगे निकल सकता
      है जहां उसे पर्याप्त PoW सुरक्षा प्राप्त करने के लिए अपनी सब्सिडी की आवश्यकता
      होती है। (हालांकि सब्सिडी वर्तमान में अन्य लाभ भी प्रदान करती है, जैसा कि Bram Cohen के
      thread के लिए नीचे सारांश में चर्चा की गई है।)

      Towns बताते हैं कि Peter Todd के परिणाम प्रत्येक वर्ष खो जाने वाले Bitcoin की एक निरंतर
      औसत दर पर निर्भर करते हैं, लेकिन Towns को लगता है कि यह खोए हुए Bitcoin
      को कम करने के लिए एक सिस्टम-वाइड लक्ष्य होना चाहिए। संबंधित रूप से, Maxwell
      वर्णन करता है कि किसी को भी स्वचालित रूप से एक स्क्रिप्ट का उपयोग करने की
      अनुमति देकर सिक्के के नुकसान को लगभग पूरी तरह से समाप्त किया जा
      सकता है, जो उनके किसी भी सिक्के को दान करेगा, जो कि 120 वर्षों के लिए स्थानांतरित
      नहीं हुआ था --- अच्छी तरह से अपेक्षित जीवनकाल से पहले मूल स्वामी और
      उनके उत्तराधिकारियों की।

    - *<!--censorship-resistance-->सेंसरशिप प्रतिरोध:* डेवलपर ZmnSCPxj [विस्तारित][zmnscpxj cr]
      एक [तर्क][voskuil cr] Eric Voskuil द्वारा कि लेनदेन शुल्क Bitcoin
      के सेंसरशिप प्रतिरोध को बढ़ाता है। उदाहरण के लिए, यदि ब्लॉक इनाम का 90% सब्सिडी से
      आता है और 10% लेनदेन शुल्क से आता है, तो एक सेंसरिंग माइनर को सबसे अधिक राजस्व
      सीधे 10% का नुकसान हो सकता है। लेकिन अगर 90% फीस से और 10% सब्सिडी से आता है, तो खनिक
      सीधे 90% तक खो सकता है --- सेंसरशिप से बचने के लिए एक बहुत मजबूत प्रोत्साहन है।

      Peter Todd [काउंटर][todd cr] इस राय के साथ कि एक सतत जारी करने से PoW सुरक्षा के
      लिए "piddling transaction fees" की तुलना में अधिक धन जुटाया जाएगा, और यह कि
      एक उच्च ब्लॉक इनाम लागत में वृद्धि करेगा जो एक हमलावर को सेंसर लेनदेन के लिए खनिकों को
      भुगतान करना होगा। .

  - [<!--fee-sniping-->फीस स्निपिंग][cohen fs]: Bram Cohen ने [फीस स्निपिंग][topic fee sniping]
    की समस्या के बारे में पोस्ट किया और एक संभावित समाधान के रूप में कुल ब्लॉक पुरस्कारों
    (शेष सब्सिडी) के लगभग 10% पर लेनदेन शुल्क रखने का सुझाव दिया। उन्होंने
    कुछ अन्य संभावित समाधानों का संक्षेप में उल्लेख किया, लेकिन अन्य ने अधिक विस्तार से
    अतिरिक्त सुझाव दिए।

    - *<!--paying-fees-forward-->आगे शुल्क का भुगतान करना:* Russell O'Connor [आगे रखना][oconnor forward fees]
      एक पुराना विचार है कि खनिक फीस काटने को प्रोत्साहित किए बिना अपने mempool में शीर्ष लेनदेन से अधिकतम शुल्क की
      गणना कर सकते हैं। फिर वे अगले खनिक को प्रतिस्पर्धात्मक रूप से बजाय सहकारी रूप से अगले ब्लॉक के
      निर्माण के लिए अगले खनिक को रिश्वत के रूप में एकत्र की गई कोई भी अतिरिक्त फीस
      की पेशकश कर सकते थे। चर्चा प्रतिभागियों ने [इस][towns ff] विचार के [कई][oconnor ff2] पुनरावृत्तियों के
      माध्यम से चला गया लेकिन Peter Todd [नोट किया][todd centralizing] कि इस तकनीक के साथ एक मौलिक चिंता यह है कि
      छोटे खनिकों को बड़े से अधिक रिश्वत देने की आवश्यकता होगी खनिक, पैमाने की
      अर्थव्यवस्थाओं का निर्माण कर रहे हैं जो Bitcoin खनन को और अधिक केंद्रीकृत कर सकते हैं।

    - *<!--improving-market-design-->बाजार डिजाइन में सुधार:* एंथोनी टाउन [सुझाव देता है][towns market design]
      कि Bitcoin सॉफ्टवेयर और उपयोगकर्ता प्रक्रियाओं में सुधार से फीस में काफी कमी आ सकती है, जिससे फीस कम होने
      की संभावना कम हो जाती है। लेकिन उन्होंने आगे कहा कि यह आज "कुछ FUD का खंडन" करने के
      लिए एक प्रमुख प्राथमिकता की तरह नहीं लगता है।

## सेवाओं और क्लाइंट सॉफ़्टवेयर में परिवर्तन

*इस मासिक फीचर में, हम Bitcoin वॉलेट और सेवाओं के दिलचस्प अपडेट को हाइलाइट करते हैं।*

- **LNP/BP रिलीज़ Storm बीटा सॉफ़्टवेयर:** LNP/BP Standars Association [रिलीज़][lnpbp tweet]
  के लिए बीटा सॉफ़्टवेयर [Storm][storm github], LN का उपयोग करने वाला एक मैसेजिंग और स्टोरेज प्रोटोकॉल हैं।

- **Robinhood bech32 का समर्थन करता है:** एक्सचेंज Robinhood [bech32][topic bech32] पतों के
  लिए [निकासी (भेजें) समर्थन][robinhood withdrawals] सक्षम करता है।

- **Sphinx ने VLS साइनिंग डिवाइस की घोषणा की:** Sphinx टीम [घोषणा][sphinx vls blog] एक हार्डवेयर साइनिंग
  डिवाइस [Validating Lightning Signer (VLS)][vls gitlab] के साथ इंटरफेस करती है।

## रिलीज और रिलीज उम्मीदवार

*लोकप्रिय Bitcoin इन्फ्रास्ट्रक्चर परियोजनाओं के लिए नए रिलीज और रिलीज उम्मीदवार। कृपया नई
रिलीज़ में अपग्रेड करने या रिलीज़ उम्मीदवारों का परीक्षण करने में मदद करने पर विचार करें।*

- [BDK 0.20.0][] Bitcoin वॉलेट बनाने के लिए इस लाइब्रेरी की नवीनतम रिलीज़ है। इसमें
  `ElectrumBlockchain` और डिस्क्रिप्टर टेम्प्लेट के लिए बग फिक्स, शुल्क
  काटने को हतोत्साहित करने के लिए एक नई लेनदेन निर्माण सुविधा और नए लेनदेन पर हस्ताक्षर
  करने के विकल्प शामिल हैं।"

## उल्लेखनीय कोड और दस्तावेज़ीकरण परिवर्तन

*इस सप्ताह [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][LND Repo] में उल्लेखनीय परिवर्तन। [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][Rust bitcoin repo],
[BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIP)][BIPs repo],
और [Lightning BOLTs][bolts repo]।*

- [Bitcoin Core #24148][] [miniscript][topic miniscript] में लिखे गए [आउटपुट स्क्रिप्ट डिस्क्रिप्टर][topic descriptors]
  के लिए *वॉच-ओनली* के लिए समर्थन जोड़ता है। उदाहरण के लिए, एक उपयोगकर्ता उस स्क्रिप्ट के अनुरूप P2WSH आउटपुट को प्राप्त किसी भी Bitcoin को देखना शुरू करने के लिए `wsh(and_v(v:pk(key_A),pk(key_B)))` आयात
  कर सकता है। भविष्य के PR से Miniscript-आधारित डिस्क्रिप्टर के लिए हस्ताक्षर करने के लिए समर्थन जोड़ने की उम्मीद है।

- [Bitcoin Core GUI #471][] एक वॉलेट बैकअप से पुनर्स्थापित करने की क्षमता के साथ GUI को अपडेट करता है। पुनर्स्थापित करना
  पहले केवल CLI का उपयोग करके या विशेष निर्देशिकाओं में फ़ाइलों की प्रतिलिपि बनाकर संभव था।

- [LND #6722][] [BIP340][]-संगत [schnorr हस्ताक्षर][topic schnorr signatures] के साथ मनमाने संदेशों पर हस्ताक्षर करने
  के लिए समर्थन जोड़ता है। schnorr हस्ताक्षर वाले संदेशों को भी अब सत्यापित किया जा सकता है।

- [Rust Bitcoin #1084][] एक विधि जोड़ता है जिसका उपयोग [BIP383] द्वारा निर्दिष्ट क्रम में सार्वजनिक कुंजी की सूची
  को छाँटने के लिए किया जा सकता है।

{% include references.md %}
{% include linkers/issues.md v=2 issues="24148,471,6722,6724,1592,1084" %}
[bdk 0.20.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.20.0
[todd tail]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020665.html
[talk tail]: https://bitcointalk.org/index.php?topic=5405755.0
[vjudeu sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020684.html
[confidential transactions]: https://en.bitcoin.it/wiki/Confidential_transactions
[towns pi]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020693.html
[maxwell pi]: https://bitcointalk.org/index.php?topic=5405755.0
[zmnscpxj cr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020678.html
[voskuil cr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020676.html
[todd cr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020688.html
[cohen fs]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020702.html
[oconnor forward fees]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020704.html
[oconnor ff2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020719.html
[towns ff]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020735.html
[todd centralizing]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020705.html
[towns market design]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020716.html
[lnpbp tweet]: https://twitter.com/lnp_bp/status/1545366480593846275
[storm github]: https://github.com/Storm-WG
[robinhood withdrawals]: https://robinhood.com/us/en/support/articles/cryptocurrency-wallets/#Supportedaddressformatsforcryptowithdrawals
[sphinx vls blog]: https://sphinx.chat/2022/06/27/a-lightning-nodes-problem-with-hats/
[vls gitlab]: https://gitlab.com/lightning-signer/docs
