---
title: 'Bitcoin Optech Newsletter #212'
permalink: /hi/newsletters/2022/08/10/
name: 2022-08-10-newsletter-hi
slug: 2022-08-10-newsletter-hi
type: newsletter
layout: newsletter
lang: hi
---
इस सप्ताह का समाचार पत्र Bitcoin Core और अन्य नोड्स में डिफ़ॉल्ट न्यूनतम लेनदेन रिले शुल्क को कम करने के बारे में
एक चर्चा को सारांशित करता है। Bitcoin Core PR Review Club के सारांश के साथ हमारे नियमित खंड भी शामिल हैं, नई रिलीज और
रिलीज उम्मीदवारों की घोषणा, और लोकप्रिय Bitcoin Infrastructure परियोजनाओं में उल्लेखनीय परिवर्तनों का विवरण।

## समाचार

- **<!--lowering-the-default-minimum-transaction-relay-feerate-->डिफ़ॉल्ट न्यूनतम लेनदेन रिले शुल्क को कम करना:**
  Bitcoin Core केवल व्यक्तिगत अपुष्ट लेनदेन को रिले करता है जो [कम से कम एक Satoshi प्रति vbyte का शुल्क][topic default minimum
  transaction relay feerates] (1 sat/vbyte) का भुगतान करता है। यदि एक नोड का mempool कम से कम
  1 sat/vbyte का भुगतान करने वाले लेनदेन से भर जाता है, तो एक उच्च शुल्क का भुगतान करने की आवश्यकता होगी। कम शुल्क
  का भुगतान करने वाले लेनदेन को अभी भी खनिकों द्वारा ब्लॉक में शामिल किया जा सकता है और उन ब्लॉकों को रिले किया
  जाएगा। अन्य नोड सॉफ़्टवेयर समान नीतियों को लागू करते हैं।

    डिफ़ॉल्ट न्यूनतम शुल्क को कम करने पर अतीत में चर्चा की गई है (देखें [न्यूज़लेटर #3][news3 min]) लेकिन
    [विलय नहीं किया गया है][bitcoin core #13922] Bitcoin Core में। पिछले कुछ हफ्तों में इस topic
    को नए सिरे से देखा गया [चर्चा][chauhan min]:

    - *<!--individual-change-effectiveness-->व्यक्तिगत परिवर्तन प्रभावशीलता:* यह [बहस][todd min] [कई][vjudeu min] लोगों द्वारा
      किया गया था कि व्यक्तिगत नोड ऑपरेटरों के लिए अपनी नीतियों को बदलने के लिए यह कितना प्रभावी था।

    - *<!--past-failures-->पिछली विफलताएं:* यह [उल्लेखित][harding min] था कि डिफ़ॉल्ट शुल्क को कम
      करने के पिछले प्रयास को कम दर से बाधित किया गया था जिससे कई मामूली इनकार-सेवा (DoS) हमलों की लागत भी कम हो गई थी।

    - *<!--alternative-relay-criteria-->वैकल्पिक रिले मानदंड:* यह [सुझाया गया][todd min2] था कि कुछ डिफ़ॉल्ट
      मानदंडों (जैसे कि डिफ़ॉल्ट न्यूनतम शुल्क) का उल्लंघन करने वाले लेनदेन इसके बजाय कुछ अलग मानदंडों को पूरा कर सकते हैं
      जो DoS हमलों को महंगा बनाते हैं --- उदाहरण के लिए, यदि एक मामूली लेन-देन के लिए प्रतिबद्ध कार्य का
      hashcash-शैली प्रमाण की राशि रिले करने के लिए।

    इस लेखन के रूप में चर्चा एक स्पष्ट निष्कर्ष पर नहीं पहुंची।

## Bitcoin Core PR Review Club

*इस मासिक खंड में, हम हाल ही में एक [Bitcoin Core PR Review Club][] बैठक का सारांश प्रस्तुत करते हैं, जिसमें कुछ
महत्वपूर्ण प्रश्नों और उत्तरों पर प्रकाश डाला गया है। मीटिंग के उत्तर का सारांश देखने के लिए नीचे दिए गए प्रश्न पर क्लिक करें।*

[Decouple validation cache initialization from ArgsManager][review club 25527] Carl Dong
की एक PR है जो नोड कॉन्फ़िगरेशन लॉजिक को सिग्नेचर और स्क्रिप्ट कैश के इनिशियलाइज़ेशन से अलग करता है। यह
[libbitcoinkernel प्रोजेक्ट][libbitcoinkernel project] का हिस्सा है।

{% include functions/details-list.md

  q0="<!--what-does-the-argsmanager-do-why-or-why-not-should-it-belong-in-src-kernel-versus-src-node-->
  `ArgsManager` क्या करता है? यह `src/kernel` बनाम `src/node` में क्यों या क्यों नहीं होना चाहिए?"
  a0="ArgsManager कॉन्फ़िगरेशन विकल्पों (`bitcoin.conf` और कमांड लाइन तर्क) को संभालने के लिए एक
  वैश्विक डेटा संरचना है। जबकि सर्वसम्मति इंजन में पैरामीटर योग्य मान (अर्थात्, कैश के आकार) हो सकते हैं, एक
  नोड को इस डेटा संरचना की आवश्यकता नहीं होती है आम सहमति में रहने के लिए। बल्कि, Bitcoin Core-विशिष्ट
  कार्यक्षमता के रूप में, इन कॉन्फ़िगरेशन विकल्पों को संभालने वाला कोड `src/node` में है।"
  a0link="https://bitcoincore.reviews/25527#l-35"

  q1="<!--what-are-the-validation-caches-why-would-they-belong-in-src-kernel-versus-src-node-->
  सत्यापन कैश क्या हैं? वे `src/kernel` बनाम `src/node` में क्यों शामिल होंगे?"
  a1="जब एक नया ब्लॉक आता है, तो सत्यापन का सबसे कम्प्यूटेशनल रूप से महंगा हिस्सा इसके लेनदेन के लिए
  स्क्रिप्ट (अर्थात हस्ताक्षर) सत्यापन है। चूंकि एक mempool रखने वाले नोड्स ने आमतौर पर इन लेनदेन को पहले ही
  देखा और मान्य किया होगा, कैशिंग द्वारा ब्लॉक सत्यापन प्रदर्शन में काफी वृद्धि हुई है (सफल) स्क्रिप्ट और हस्ताक्षर
  सत्यापन। ये कैश तार्किक रूप से सर्वसम्मति इंजन का हिस्सा हैं क्योंकि सर्वसम्मति-महत्वपूर्ण ब्लॉक सत्यापन कोड को उनकी
  आवश्यकता है। जैसे, ये कैश `src/kernel` में हैं।"
  a1link="https://bitcoincore.reviews/25527#l-45"

  q2="<!--what-does-it-mean-for-something-to-be-consensus-critical-if-it-isn-t-a-consensus-rule-does-src-consensus-contain-all-the-consensus-critical-code-->
  किसी चीज़ के सर्वसम्मति-महत्वपूर्ण होने का क्या अर्थ है यदि वह सर्वसम्मति का नियम नहीं है? क्या `src/consensus' में
  सभी सर्वसम्मति-महत्वपूर्ण कोड शामिल हैं?"
  a2="प्रतिभागियों ने सहमति व्यक्त की कि हस्ताक्षर सत्यापन सर्वसम्मति नियमों को लागू करता है, जबकि कैशिंग नहीं करता है।
  हालांकि, यदि कैशिंग कोड में एक बग है जिसके परिणामस्वरूप अमान्य हस्ताक्षर संग्रहीत होते हैं, तो नोड अब आम सहमति
  नियमों को लागू नहीं करेगा। जैसे, हस्ताक्षर कैशिंग है आम सहमति-महत्वपूर्ण माना जाता है। सर्वसम्मति कोड
  वास्तव में अभी तक `src/kernel` या `src/consensus` में नहीं रहता है; सर्वसम्मति के अधिकांश नियम और
  सर्वसम्मति-महत्वपूर्ण कोड `validation.cpp` में रहते हैं।"
  a2link="https://bitcoincore.reviews/25527#l-61"

  q3="<!--what-tools-do-you-use-for-code-archeology-to-understand-the-background-of-why-a-value-exists-->
  “कोड पुरातत्व” के लिए आप कौन से टूल का उपयोग करते हैं, इसकी पृष्ठभूमि को समझने के लिए कि
  कोई मान क्यों मौजूद है?"
  a3="प्रतिभागियों ने `git blame`, `git log` सहित कई कमांड और उपकरण सूचीबद्ध किए, पुल
  अनुरोध पृष्ठ में प्रतिबद्ध हैश दर्ज करना, फाइल देखते समय Github `Blame` बटन का उपयोग करना, और Github खोज
  बार का उपयोग करना।"
  a3link="https://bitcoincore.reviews/25527#l-132"

  q4="<!--this-pr-changes-the-type-of-signature-cache-bytes-and-script-execution-cache-bytes-from-int64-t-to-size-t-what-is-the-difference-between-int64-t-uint64-t-and-size-t-and-why-should-a-size-t-hold-these-values-->
  यह PR `signatures_cache_bytes` और `script_execution_cache_bytes` के प्रकार को `int64_t`
  से `size_t` में बदल देता है। `int64_t`, `uint64_t` और `size_t` में क्या अंतर है, और `size_t` क्यों
  होना चाहिए इन मूल्यों को पकड़ो?"
  a4="`int64_t` और `uint64_t` प्रकार सभी प्लेटफार्मों और कंपाइलरों में 64-बिट्स (क्रमशः हस्ताक्षरित और अहस्ताक्षरित) हैं।
  `size_t` प्रकार एक अहस्ताक्षरित पूर्णांक है जो लंबाई (बाइट्स में) धारण करने में सक्षम होने की गारंटी है। स्मृति में किसी
  भी वस्तु का; इसका आकार सिस्टम पर निर्भर करता है। जैसे, `size_t` कैश आकार को कई बाइट्स के रूप में रखने वाले इन चरों के
  लिए बिल्कुल उपयुक्त है।"
  a4link="https://bitcoincore.reviews/25527#l-163"

%}

## रिलीज और रिलीज उम्मीदवार

*लोकप्रिय Bitcoin इन्फ्रास्ट्रक्चर परियोजनाओं के लिए नए रिलीज और रिलीज उम्मीदवार। कृपया नई रिलीज़ में
अपग्रेड करने या रिलीज़ उम्मीदवारों का परीक्षण करने में मदद करने पर विचार करें।*

- [Core Lightning 0.12.0rc1][] इस लोकप्रिय LN नोड कार्यान्वयन के अगले प्रमुख संस्करण के लिए एक रिलीज उम्मीदवार है।

## उल्लेखनीय कोड और दस्तावेज़ीकरण परिवर्तन

*इस सप्ताह [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][LND Repo] में उल्लेखनीय परिवर्तन। [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][Rust bitcoin repo],
[BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIP)][BIPs repo],
और [Lightning BOLTs][bolts repo]।*

- [Bitcoin Core #25610][] डिफ़ॉल्ट रूप से RPCs और `-walletrbf` से [RBF][topic rbf] में ऑप्ट-इन करता है।
  यह [न्यूज़लेटर #208][news208 core rbf] में उल्लिखित अपडेट का अनुसरण करता है, नोड ऑपरेटरों को अपने नोड के लेनदेन
  प्रतिस्थापन व्यवहार को डिफ़ॉल्ट ऑप्ट-इन RBF (BIP125) से पूर्ण RBF में बदलने में सक्षम बनाता है। डिफ़ॉल्ट रूप से RPC ऑप्ट-इन
  2017 में [Bitcoin Core #9527][] में प्रस्तावित किया गया था जब प्राथमिक आपत्तियां उस समय
  नवीनता थीं, लेनदेन को टक्कर देने में असमर्थता और GUI में RBF को अक्षम करने की कार्यक्षमता नहीं थी --- जिनमें
  से सभी तब से संबोधित किया गया है।

- [Bitcoin Core #24584][] [coin selection][topic coin selection] में संशोधन करता है ताकि एकल आउटपुट प्रकार
  से बने इनपुट सेट को प्राथमिकता दी जा सके। यह उन परिदृश्यों को संबोधित करता है जिनमें मिश्रित-प्रकार के इनपुट सेट पिछले लेनदेन के परिवर्तन
  आउटपुट को प्रकट करते हैं। यह एक संबंधित गोपनीयता सुधार का अनुसरण करता है [हमेशा परिवर्तन प्रकार से मेल खाता है][#23789] एक
  प्राप्तकर्ता आउटपुट के लिए (देखें [Newsletter #181][news181 change matching])।

- [Core Lightning #5071][] एक बुककीपर plugin जोड़ता है जो plugin चलाने वाले नोड द्वारा Bitcoin की गतिविधियों
  का लेखा रिकॉर्ड प्रदान करता है, जिसमें फीस पर खर्च की गई राशि को ट्रैक करने की क्षमता भी शामिल है। मर्ज किए गए PR में कई नए RPC कमांड शामिल हैं।

- [BDK #645][] यह निर्दिष्ट करने का एक तरीका जोड़ता है कि कौन सा [Taproot]​[topic Taproot] ​​हस्ताक्षर करने के लिए
  पथ खर्च करता है। पहले, यदि BDK सक्षम होता तो कीपथ व्यय के लिए हस्ताक्षर करता, साथ ही किसी भी स्क्रिप्टपथ के लिए हस्ताक्षर करता
  जिसके लिए उसके पास कुंजी थी।

- [BOLTs #911][] एक LN नोड के लिए एक DNS होस्टनाम की घोषणा करने की क्षमता जोड़ता है जो उसके आईपी पते
  को हल करता है। इस विचार के बारे में पिछली चर्चा का उल्लेख [न्यूज़लेटर #167][news167 ln dns] में किया गया था।

{% include references.md %}
{% include linkers/issues.md v=2 issues="25610,24584,5071,645,911,13922,9527" %}
[core lightning 0.12.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0rc1
[news208 core RBF]: /hi/newsletters/2022/07/13/#bitcoin-core-25353
[news167 ln dns]: /en/newsletters/2021/09/22/#dns-records-for-ln-nodes
[news181 change matching]: /en/newsletters/2022/01/05/#bitcoin-core-23789
[chauhan min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020784.html
[todd min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020800.html
[vjudeu min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020821.html
[harding min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020808.html
[todd min2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020815.html
[news3 min]: /en/newsletters/2018/07/10/#discussion-min-fee-discussion-about-minimum-relay-fee
[#23789]: https://github.com/bitcoin/bitcoin/issues/23789
[review club 25527]: https://bitcoincore.reviews/25527
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[`ArgsManager`]: https://github.com/bitcoin/bitcoin/blob/5871b5b5ab57a0caf9b7514eb162c491c83281d5/src/util/system.h#L172
