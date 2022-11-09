---
title: 'Bitcoin Optech Newsletter #223'
permalink: /hi/newsletters/2022/10/26/
name: 2022-10-26-newsletter-hi
slug: 2022-10-26-newsletter-hi
type: newsletter
layout: newsletter
lang: hi
---
इस सप्ताह का समाचार पत्र पूर्ण RBF को सक्षम करने के बारे में निरंतर चर्चा का सार प्रस्तुत करता है, एक CoreDev.tech
बैठक में चर्चा के कई प्रतिलेखों के लिए अवलोकन प्रदान करता है, और LN जैसे अनुबंध प्रोटोकॉल के लिए
डिज़ाइन किए गए अल्पकालिक एंकर आउटपुट के प्रस्ताव का वर्णन करता है। Bitcoin Stack Exchange के लोकप्रिय प्रश्नों और
उत्तरों के सारांश के साथ हमारे नियमित खंड भी शामिल हैं, नए सॉफ़्टवेयर रिलीज़ और रिलीज़
उम्मीदवारों की सूची, और लोकप्रिय Bitcoin इन्फ्रास्ट्रक्चर सॉफ़्टवेयर में उल्लेखनीय परिवर्तनों का विवरण।

## समाचार

- **पूर्ण RBF के बारे में निरंतर चर्चा:** [पिछले सप्ताह के समाचार पत्र][news222 rbf] में, हमने एक नए `mempoolfullrbf` विकल्प को शामिल करने
  के बारे में Bitcoin-Dev मेलिंग सूची पर एक चर्चा का सारांश दिया, जो कई व्यवसायों के लिए समस्याएं पैदा कर सकता है। जो
  अंतिम भुगतान के रूप में शून्य पुष्टिकरण ("शून्य कॉन्फ़") के साथ लेनदेन स्वीकार करते हैं। इस सप्ताह मेलिंग
  सूची और #bitcoin-core-dev IRC रूम दोनों पर चर्चा जारी रही। चर्चा के कुछ मुख्य अंशों में शामिल हैं:

    - *<!--free-option-problem-->निःशुल्क विकल्प समस्या:* Sergej Kotliar [चेतावनी][kotliar free option] कि उनका मानना ​​है कि किसी भी प्रकार के लेनदेन प्रतिस्थापन के साथ
      सबसे बड़ी समस्या यह है कि यह एक मुफ्त अमेरिकी कॉल विकल्प बनाता है। उदाहरण के लिए,
      ग्राहक Alice व्यापारी Bob से विजेट खरीदने का अनुरोध करता है। Bob Alice को $20,000 USD/BTC की वर्तमान कीमत पर 1 BTC का चालान देता
      है। Alice ने Bob को 1 BTC को कम शुल्क के साथ लेनदेन में भेजा। लेन-देन अपुष्ट रहता है जब विनिमय दर $25,000 USD/BTC में
      बदल जाती है, जिसका अर्थ है कि Alice अब $5,000 अधिक भुगतान कर रही है। इस बिंदु पर, वह काफी
      तर्कसंगत रूप से अपने लेन-देन को बदलने के लिए चुनती है, जो खुद को BTC का भुगतान करती है,
      लेनदेन को प्रभावी ढंग से रद्द कर देती है। हालांकि, अगर इसके बजाय Alice के पक्ष में विनिमय
      दर बदल गई थी (उदाहरण के लिए $15,000 USD/BTC), Bob Alice के भुगतान को रद्द नहीं कर सकता है और इसलिए
      उसके पास समान विकल्प का प्रयोग करने के लिए सामान्य ऑनचेन Bitcoin लेनदेन प्रवाह में कोई रास्ता
      नहीं है, एक असममित Exchange बनाना दर जोखिम। तुलना करके, जब लेन-देन प्रतिस्थापन संभव नहीं
      है, Alice और Bob समान विनिमय दर जोखिम साझा करते हैं।

        Kotliar ने नोट किया कि समस्या आज मौजूद है [BIP125][] ऑप्ट-इन [RBF][topic rbf] उपलब्ध है, लेकिन उनका मानना ​​​​है कि
        पूर्ण-RBF समस्या को और खराब कर देगा।

        Greg Sanders और Jeremy Rubin [अलग][rubin cpfp] ईमेल में [उत्तर दिया][sanders cpfp] कि ध्यान दें कि व्यापारी Bob [CPFP][topic cpfp] का उपयोग करके ग्राहक Alice के मूल
        लेनदेन की पुष्टि करने के लिए minerों को प्रोत्साहित कर सकता है, खासकर अगर
        [पैकेज रिले][topic package relay] सक्षम किया गया था।

        Antoine Riard [नोट किया गया][riard free option] कि LN के साथ भी यही जोखिम मौजूद है, क्योंकि Alice व्यापारी Bob के चालान को समाप्त होने से
        कुछ समय पहले तक भुगतान करने के लिए इंतजार कर सकती थी, जिससे उसे
        विनिमय दर में बदलाव की प्रतीक्षा करने का समय मिल गया। हालांकि उस मामले में,
        अगर Bob ने देखा कि विनिमय दर में काफी बदलाव आया है, तो वह अपने नोड को भुगतान
        स्वीकार नहीं करने का निर्देश दे सकता है, Alice को पैसे वापस कर सकता है।

    - *Bitcoin Core नेटवर्क के प्रभारी नहीं:* Gloria Zhao ने IRC चर्चा में [लिखा][zhao no control] कि, "मुझे लगता है कि हम जो भी विकल्प लेते हैं, उसे
      उपयोगकर्ताओं को बहुतायत से स्पष्ट किया जाना चाहिए कि Core नियंत्रित नहीं करता है कि क्या पूर्ण RBF होता
      है या नहीं। हम [25353][bitcoin core #25353] वापस कर सकते हैं और यह अभी भी हो सकता है। [...]"

        बैठक के बाद, Zhao ने स्थिति का एक विस्तृत [अवलोकन][zhao overview] भी पोस्ट किया।

    - *<!--no-removal-means-the-problem-could-happen-->नो रिमूवल का मतलब है कि समस्या हो सकती है:* IRC चर्चा में,]
      Anthony Towns ने पिछले सप्ताह के अपने बिंदु को [दोहराया][towns uncoordinated],
      "अगर हम 24.0 से `mempoolfullrbf` विकल्प को नहीं हटाने जा रहे हैं, तो हम' एक असंगठित
      तैनाती के लिए फिर से जा रहे हैं।"

        Greg Sanders [संदिग्ध][sanders doubt] थे, "सवाल यह है: क्या 5%+ एक चर सेट करेगा? मुझे संदेह है, नहीं।" Towns [उत्तर
        दिया][towns uasf], "[UASF][topic soft fork activation] `uacomment` ने प्रदर्शित किया कि कुछ ही हफ्तों में एक वैरिएबल सेट करने के लिए ~11% प्राप्त करना
        आसान है"।

    - *<!--should-be-an-option-->एक विकल्प होना चाहिए:* IRC चर्चा में Martin Zumsande [कहा][zumsande option], "मुझे लगता है कि यदि नोड ऑपरेटरों और minerों की
      एक सार्थक संख्या एक विशिष्ट नीति चाहती है, तो यह बताने के लिए डेवलपर्स पर नहीं होना
      चाहिए उन्हें 'अब आपके पास वह नहीं हो सकता'। Dev एक सिफारिश दे सकते हैं और देना चाहिए
      (डिफ़ॉल्ट चुनकर), लेकिन सूचित उपयोगकर्ताओं को विकल्प प्रदान करना कभी भी समस्या नहीं होनी चाहिए।"

    इस लेखन के रूप में, कोई स्पष्ट समाधान नहीं हुआ था। Bitcoin Core 24.0 के आगामी संस्करण के लिए जारी
    उम्मीदवारों में `mempoolfullrbf` विकल्प अभी भी शामिल है और यह Optech की सिफारिश है कि शून्य गोपनीय लेनदेन के
    आधार पर कोई भी सेवा सावधानी से जोखिमों का मूल्यांकन करती है, शायद [पिछले सप्ताह के
    समाचार पत्र][news222 rbf] में लिंक किए गए ईमेल को पढ़कर शुरू करें।

- **CoreDev.tech प्रतिलेख:** Atlanta Bitcoin सम्मेलन (TabConf) से पहले, लगभग 40 डेवलपर्स ने CoreDev.tech इवेंट में भाग लिया था। [प्रतिलेख][coredev xs] घटना से
  लगभग आधी बैठकों के लिए ब्रायन बिशप द्वारा प्रदान किया गया है। उल्लेखनीय चर्चाओं में शामिल हैं:

    - [ट्रांसपोर्ट encryption][p2p encryption]: [संस्करण 2 एन्क्रिप्टेड ट्रांसपोर्ट प्रोटोकॉल][topic v2 p2p transport] प्रस्ताव के हालिया अपडेट के बारे में बातचीत
      (देखें [न्यूज़लेटर #222][news222 bip324])। यह प्रोटोकॉल नेटवर्क छिपकर बात करने वालों के लिए यह जानना कठिन
      बना देगा कि किस IP पते से लेन-देन हुआ है और ईमानदार नोड्स के बीच मैन-इन-द-मिडिल हमलों का
      पता लगाने और उनका विरोध करने की क्षमता में सुधार होगा।

        चर्चा में प्रोटोकॉल डिज़ाइन के कई विचार शामिल हैं और यह किसी के लिए भी
        अनुशंसित पढ़ने के लिए है कि प्रोटोकॉल लेखकों ने कुछ निर्णय क्यों लिए। यह पहले के
        [काउंटरसाइन][topic countersign] प्रमाणीकरण प्रोटोकॉल के संबंध की भी जांच करता है।

    - [<!--fees-->शुल्क][fee chat]: ऐतिहासिक रूप से, वर्तमान में और भविष्य में लेनदेन शुल्क के बारे में व्यापक चर्चा। कुछ topics में
      प्रश्न शामिल थे कि क्यों ब्लॉक लगभग हमेशा लगभग भरे हुए हैं, लेकिन mempool नहीं है, इस बारे में बहस
      करें कि Bitcoin के दीर्घकालिक के बारे में [चिंता][topic fee sniping] से पहले हमारे पास एक महत्वपूर्ण शुल्क बाजार विकसित
      करने के लिए कितना समय है। स्थिरता, और हम कौन से समाधान तैनात कर सकते हैं यदि हमें
      विश्वास है कि कोई समस्या मौजूद है।

    - [FROST][]: FROST थ्रेशोल्ड सिग्नेचर स्कीम के बारे में एक प्रस्तुति। प्रतिलेख डिज़ाइन में क्रिप्टोग्राफ़िक विकल्पों के बारे में कई
      उत्कृष्ट तकनीकी प्रश्नों का दस्तावेज़ है और सामान्य रूप से FROST विशेष रूप से या क्रिप्टोग्राफ़िक प्रोटोकॉल
      डिज़ाइन के बारे में अधिक जानने में रुचि रखने वाले किसी भी व्यक्ति के लिए उपयोगी पठन हो
      सकता है। [ROAST][] के बारे में TabConf ट्रांसक्रिप्ट भी देखें, जो Bitcoin के लिए एक और थ्रेशोल्ड सिग्नेचर स्कीम है।

    - [GitHub][github chat]: Bitcoin Core प्रोजेक्ट की गिट होस्टिंग को GitHub से दूसरे मुद्दे और PR प्रबंधन समाधान पर ले जाने के साथ-साथ GitHub का
      उपयोग जारी रखने के लाभों पर विचार करने के बारे में चर्चा।

    - [BIP में सिद्ध विनिर्देश][hacspec chat]: BIP में [hacspec][] विनिर्देश भाषा का उपयोग करने के बारे में एक चर्चा का हिस्सा जो
      विनिर्देशों को सही साबित करने के लिए प्रदान करता है। TabConf के दौरान संबंधित बातचीत के लिए
      [प्रतिलेख][hacspec preso] भी देखें।

    - [पैकेज और v3 लेनदेन रिले][package relay chat]: [पैकेज लेनदेन रिले][topic package relay] को सक्षम करने के प्रस्तावों के बारे में एक प्रस्तुति की
      प्रतिलिपि और [पिनिंग हमलों][topic transaction pinning] को खत्म करने के लिए नए लेनदेन रिले नियमों का उपयोग करें कुछ मामलों में।

    - [Stratum v2][stratum v2 chat]: एक चर्चा जो Stratum version 2 पूल्ड माइनिंग प्रोटोकॉल को लागू करने वाले एक नए ओपन-सोर्स
      प्रोजेक्ट की घोषणा के साथ शुरू हुई। Stratum v2 द्वारा उपलब्ध कराए गए सुधारों में प्रमाणित कनेक्शन और
      अलग-अलग minerों (स्थानीय खनन उपकरण वाले) के लिए यह चुनने की क्षमता शामिल है कि
      कौन से लेनदेन को मेरा (पूल चुनने वाले लेनदेन के बजाय) चुनना है। कई अन्य लाभों के अलावा,
      चर्चा में यह उल्लेख किया गया था कि व्यक्तिगत minerों को अपने स्वयं के ब्लॉक टेम्पलेट चुनने की
      अनुमति देना उन पूलों के लिए अत्यधिक वांछनीय हो सकता है जो सरकारों के बारे में चिंतित हैं कि
      कौन से लेनदेन का खनन किया जा सकता है, जैसा कि [Tornado Cash][] विवाद। अधिकांश चर्चा स्ट्रेटम v2 के लिए मूल
      समर्थन को सक्षम करने के लिए Bitcoin Core में किए जाने वाले परिवर्तनों पर केंद्रित है। [Braidpool][braidpool chat] के बारे में TabConf
      ट्रांसक्रिप्ट भी देखें, जो एक विकेन्द्रीकृत पूल्ड माइनिंग प्रोटोकॉल है।

    - [Merging][merging chat] Bitcoin Core प्रोजेक्ट में कोड की समीक्षा करने में मदद करने के लिए रणनीतियों के बारे में एक चर्चा है,
      हालांकि कई सुझाव अन्य परियोजनाओं पर भी लागू होते हैं। विचारों में शामिल हैं:

        - बड़े बदलावों को कई छोटे PR में तोड़ें

        - समीक्षकों के लिए अंतिम उद्देश्य को समझना आसान बनाएं। सभी PR के लिए, इसका
          मतलब एक प्रेरक PR विवरण लिखना है। क्रमिक रूप से किए जा रहे परिवर्तनों के लिए,
          ट्रैकिंग मुद्दों, प्रोजेक्ट बोर्डों का उपयोग करें, और PR को खोलकर refactoring को प्रेरित करें जो एक
          वांछनीय लक्ष्य को पूरा करने के लिए उस रिफैक्टेड कोड का उपयोग करेगा।

        - लंबे समय तक चलने वाली परियोजनाओं के लिए उच्च-स्तरीय व्याख्याकार तैयार करें
          जो परियोजना से पहले की स्थिति, वर्तमान प्रगति, परिणाम को पूरा करने के लिए क्या
          करेंगे, और उपयोगकर्ताओं को क्या लाभ प्रदान करेंगे, इसका वर्णन करते हुए

        - उन लोगों के साथ कार्य समूह बनाएं जो समान परियोजनाओं या कोड सबसिस्टम में रुचि
          रखते हैं

- **Ephemeral anchors:** Greg Sanders ने v3 लेन-देन रिले के बारे में पिछली चर्चा का अनुसरण किया (देखें [न्यूज़लेटर #220][news220 ephemeral]) एक [पोस्ट][sanders ephemeral] केph
  साथ Bitcoin-Dev मेलिंग के लिए जिसमें एक प्रस्ताव शामिल था। नए प्रकार का [एंकर आउटपुट][topic anchor outputs]। एक v3 लेन-देन शून्य शुल्क का
  भुगतान कर सकता है, लेकिन इसमें `OP_TRUE` स्क्रिप्ट का भुगतान करने वाला आउटपुट होता है, जिससे कोई भी
  बच्चे के लेन-देन में आम सहमति के नियमों के तहत इसे खर्च कर सकता है। अपुष्ट शून्य-शुल्क मूल
  लेनदेन केवल Bitcoin Core द्वारा रिले और खनन किया जाएगा यदि यह एक लेनदेन पैकेज का हिस्सा था जिसमें OP_TRUE
  आउटपुट खर्च करने वाले बच्चे के लेनदेन भी शामिल थे। यह केवल Bitcoin Core की नीति को प्रभावित करेगा; कोई
  आम सहमति नियम नहीं बदला जाएगा।

    इस प्रस्ताव के वर्णित लाभों में यह शामिल है कि यह [लेन-देन पिनिंग][topic transaction pinning] को रोकने के लिए एक-ब्लॉक
    सापेक्ष टाइमलॉक (जिसे उन्हें सक्षम करने के लिए उपयोग किए गए कोड के बाद `1 OP_CSV` कहा जाता है) का
    उपयोग करने की आवश्यकता को समाप्त करता है और किसी को भी शुल्क को टक्कर देने की
    अनुमति देता है। मूल लेनदेन (पहले [शुल्क प्रायोजन][topic fee sponsorship] सॉफ्ट फोर्क प्रस्ताव के समान)।

    Jeremy Rubin [उत्तर दिया][rubin ephemeral] प्रस्ताव के समर्थन में लेकिन ध्यान दिया कि यह किसी भी अनुबंध के लिए काम नहीं
    करता है जो v3 लेनदेन का उपयोग नहीं कर सकता है। कई अन्य डेवलपर्स ने भी अवधारणा पर
    चर्चा की, वे सभी इस लेखन के रूप में आकर्षक लग रहे थे।

## Bitcoin Stack Exchange से चयनित प्रश्नोत्तर

*[Bitcoin Stack Exchange][bitcoin.se] उन पहले स्थानों में से एक है जहां Optech योगदानकर्ता अपने सवालों के जवाब ढूंढते हैं --- या जब हमारे पास
जिज्ञासु या भ्रमित उपयोगकर्ताओं की मदद करने के लिए कुछ खाली क्षण होते हैं। इस मासिक फीचर में, हम
अपने पिछले अपडेट के बाद से पोस्ट किए गए कुछ शीर्ष-मतदान वाले प्रश्नों और उत्तरों को highlight करते हैं।*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-would-someone-use-a-1-of-1-multisig-->कोई 1-ऑफ़-1 मल्टीसिग का उपयोग क्यों करेगा?]({{bse}}115443)
  Vojtěch Strnad पूछता है कि कोई व्यक्ति P2WPKH पर 1-ऑफ़-1 मल्टीसिग का उपयोग करना क्यों
  पसंद करेगा, क्योंकि P2WPKH सस्ता है और इसमें एक बड़ा anonymity सेट है। Murch विभिन्न प्रकार के संसाधनों को सूचीबद्ध
  करता है, जिसमें दिखाया गया है कि कम से कम एक इकाई ने वर्षों में लाखों 1-ऑफ़-1 UTXO खर्च किए हैं, हालांकि प्रेरणा स्पष्ट
  नहीं है।

- [<!--why-would-a-transaction-have-a-locktime-in-the-year-1987-->वर्ष 1987 में एक लेन-देन का लॉकटाइम क्यों होगा?]({{bse}}115549) 1440000Bytes Christian Decker की एक टिप्पणी की ओर इशारा करते हैं जो बोल्ट 3 Lightning स्पेक से [एक
  खंड][bolt 3 commitment] को संदर्भित करता है जो आवंटित करता है लॉकटाइम फ़ील्ड के रूप में "ऊपरी 8 बिट 0x20 हैं, निचले 24 बिट
  अस्पष्ट प्रतिबद्धता लेनदेन संख्या के निचले 24 बिट हैं"।

- [<!--what-is-the-size-limit-on-the-utxo-set-if-any-->UTXO सेट पर आकार की सीमा क्या है, यदि कोई हो?]({{bse}}115439) Peter Wullie जवाब देते हैं कि UTXO सेट आकार पर कोई आम सहमति सीमा नहीं है
  और UTXO सेट की वृद्धि दर सीमित है ब्लॉक आकार द्वारा जो किसी दिए गए ब्लॉक में बनाए जा सकने वाले UTXO की संख्या को
  सीमित करता है। [संबंधित उत्तर][se murch utxo calcs] में, Murch का अनुमान है कि पृथ्वी पर प्रत्येक व्यक्ति के लिए UTXO बनाने में लगभग 11
  साल लगेंगे।

- [<!--why-is-blockmaxweight-set-to-3996000-by-default-->क्यों `-blockmaxweight` डिफ़ॉल्ट रूप से 399600 पर सेट है?]({{bse}}115499) Vojtěch Strnad बताते हैं कि Bitcoin Core में `-blockmaxweight` के लिए डिफ़ॉल्ट सेटिंग 3,996,000 है जो 4,000,000 की सेगविट सीमा से कम है वजन
  इकाइयों (WU)। Peter Wuille बताते हैं कि अंतर एक miner के लिए ब्लॉक टेम्पलेट द्वारा बनाए गए डिफ़ॉल्ट कॉइनबेस
  लेनदेन से परे अतिरिक्त आउटपुट के साथ एक बड़ा कॉइनबेस लेनदेन जोड़ने के लिए बफर स्पेस
  की अनुमति देता है।

- [<!--can-a-miner-open-a-lightning-channel-with-a-coinbase-output-->क्या एक miner एक कॉइनबेस आउटपुट के साथ एक Lightning चैनल खोल सकता है?]({{bse}}115588) Murch ने अपने कॉइनबेस
  लेनदेन से आउटपुट का उपयोग करके एक Lightning चैनल बनाने वाले miner के साथ चुनौतियों की ओर इशारा
  किया, जिसमें कॉइनबेस दिए गए चैनल को बंद करने में देरी शामिल है। परिपक्वता अवधि के साथ-साथ
  हैशिंग के दौरान खुले चैनल को लगातार फिर से बातचीत करने की आवश्यकता होती है, क्योंकि कॉइनबेस
  लेनदेन के हैश लगातार खनन के दौरान बदलते रहते हैं।

- [<!--what-is-the-history-on-how-previous-soft-forks-were-tested-prior-to-being-considered-for-activation-->सक्रियण के लिए विचार किए जाने से पहले पिछले सॉफ्ट फोर्क्स का परीक्षण कैसे किया गया था, इसका इतिहास क्या है?]({{bse}}115434)
  Michael Folkson ने Anthony Towns से [हालिया मेलिंग सूची पोस्ट][aj soft fork testing] उद्धृत किया जो वर्णन करता है
  P2SH, CLTV, CSV, segwit, [taproot][topic taproot], CTV, और [Drivechain][topic sidechains] प्रस्तावों के आसपास परीक्षण।

## रिलीज और रिलीज उम्मीदवार

*लोकप्रिय Bitcoin इन्फ्रास्ट्रक्चर परियोजनाओं के लिए नए रिलीज और रिलीज उम्मीदवार। कृपया नई रिलीज़ में
अपग्रेड करने या रिलीज़ उम्मीदवारों का परीक्षण करने में मदद करने पर विचार करें।*

- [LDK 0.0.112][] LN-सक्षम अनुप्रयोगों के निर्माण के लिए इस पुस्तकालय की एक रिलीज है।

- [Bitcoin Core 24.0 RC2][] नेटवर्क के सबसे व्यापक रूप से उपयोग किए जाने वाले पूर्ण नोड कार्यान्वयन के अगले संस्करण के लिए
  एक रिलीज उम्मीदवार है। एक [गाइड टू टेस्टिंग][bcc testing] उपलब्ध है।

  **<!--warning-->चेतावनी:** इस रिलीज उम्मीदवार में `mempoolfullrbf` कॉन्फ़िगरेशन विकल्प शामिल है, जो कई प्रोटोकॉल और
  एप्लिकेशन डेवलपर्स का मानना ​​​​है कि इस सप्ताह और पिछले सप्ताह के न्यूज़लेटर्स में वर्णित व्यापारी
  सेवाओं के लिए समस्याएं पैदा कर सकता है। Optech RC का मूल्यांकन करने और सार्वजनिक चर्चा में भाग लेने के
  लिए प्रभावित होने वाली किसी भी सेवा को प्रोत्साहित करता है।

## उल्लेखनीय कोड और दस्तावेज़ीकरण परिवर्तन

*इस सप्ताह [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][LND Repo] में उल्लेखनीय परिवर्तन।
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][Rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIP)][BIPs repo], और
[Lightning BOLTs][bolts repo]।*

- [Bitcoin Core #23443][] एक नया P2P प्रोटोकॉल संदेश जोड़ता है, `sendtxrcncl` (लेनदेन सामंजस्य भेजें), जो एक नोड को एक सहकर्मी को संकेत देने की
  अनुमति देता है कि यह [erlay][topic erlay] का समर्थन करता है। यह PR erlay प्रोटोकॉल के पहले भाग को जोड़ता है --- इसे उपयोग करने से पहले अन्य भागो की आवशकता है।

- [Eclair #2463][] और [#2461][eclair #2461] Eclair के [इंटरैक्टिव और Dual फंडिंग प्रोटोकॉल][topic dual funding] के कार्यान्वयन को अपडेट करने के लिए [RBF][topic rbf] में प्रत्येक
  फंडिंग इनपुट ऑप्ट-इन की आवश्यकता होती है। और पुष्टि भी करें (अर्थात ऐसा आउटपुट खर्च करें जो
  पहले से ही ब्लॉक चेन में हो)। ये परिवर्तन सुनिश्चित करते हैं कि RBF का उपयोग किया जा सकता है और Eclair
  उपयोगकर्ता द्वारा योगदान की गई किसी भी फीस का उपयोग उनके किसी भी सहकर्मी के पिछले लेनदेन की
  पुष्टि करने में मदद के लिए नहीं किया जाएगा।

{% include references.md %}
{% include linkers/issues.md v=2 issues="23443,2463,2461,25353" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[ldk 0.0.112]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.112
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /hi/newsletters/2022/10/19/#transaction-replacement-option
[kotliar free option]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021056.html
[sanders cpfp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021060.html
[rubin cpfp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021059.html
[riard free option]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021067.html
[zhao no control]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-440
[towns uncoordinated]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-488
[sanders doubt]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-490
[towns uasf]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-492
[zumsande option]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-493
[coredev xs]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/
[p2p encryption]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-10-p2p-encryption/
[news222 bip324]: /hi/newsletters/2022/10/19/#bip324
[fee chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-fee-market/
[frost]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-frost/
[roast]: https://diyhpl.us/wiki/transcripts/tabconf/2022/roast/
[github chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-github/
[hacspec chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-hac-spec/
[hacspec]: https://hacspec.github.io/
[hacspec preso]: https://diyhpl.us/wiki/transcripts/tabconf/2022/hac-spec/
[package relay chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-package-relay/
[stratum v2 chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-stratum-v2/
[tornado cash]: https://www.coincenter.org/analysis-what-is-and-what-is-not-a-sanctionable-entity-in-the-tornado-cash-case/
[braidpool chat]: https://diyhpl.us/wiki/transcripts/tabconf/2022/braidpool/
[merging chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-12-merging/
[news220 ephemeral]: /hi/newsletters/2022/10/05/#ephemeral-dust
[sanders ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021036.html
[rubin ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021041.html
[zhao overview]: https://github.com/glozow/bitcoin-notes/blob/full-rbf/full-rbf.md
[bolt 3 commitment]: https://github.com/lightning/bolts/blob/316882fcc5c8b4cf9d798dfc73049075aa89d3e9/03-transactions.md#commitment-transaction
[se murch utxo calcs]: https://bitcoin.stackexchange.com/questions/111234/how-many-useable-utxos-are-possible-with-btc-inside-them/115451#115451
[aj soft fork testing]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020964.html
