---
title: 'Bitcoin Optech Newsletter #217'
permalink: /hi/newsletters/2022/09/14/
name: 2022-09-14-newsletter-hi
slug: 2022-09-14-newsletter-hi
type: newsletter
layout: newsletter
lang: hi
---
इस सप्ताह के न्यूजलेटर में Bitcoin Core PR Review Club मीटिंग के सारांश के साथ हमारा नियमित खंड, नए Software रिलीज और रिलीज
उम्मीदवारों की सूची, और लोकप्रिय Bitcoin Infrastructure परियोजनाओं में उल्लेखनीय परिवर्तनों के सारांश शामिल हैं।

## समाचार

*इस सप्ताह कोई महत्वपूर्ण समाचार नहीं।*

## Bitcoin Core PR Review Club

*इस मासिक खंड में, हम हाल ही में एक [Bitcoin Core PR Review Club][] बैठक का सारांश प्रस्तुत करते हैं,
जिसमें कुछ महत्वपूर्ण प्रश्नों और उत्तरों पर प्रकाश डाला गया है। मीटिंग के उत्तर का सारांश देखने के लिए नीचे दिए गए प्रश्न पर क्लिक करें।*

[ब्लॉक मिलने पर प्रारंभिक header Sync के दौरान बैंडविड्थ कम करें][review club 25720] Suhas Daftuar द्वारा एक PR है
जो Initial Block Download (IBD) के दौरान, साथियों के साथ ब्लॉकचेन को
Synchronize करते समय एक नोड की नेटवर्क बैंडविड्थ आवश्यकताओं को कम करता है। Bitcoin लोकाचार का एक
महत्वपूर्ण हिस्सा अधिक उपयोगकर्ताओं को पूर्ण नोड्स चलाने के लिए प्रोत्साहित करने के लिए नेटवर्किंग
संसाधनों सहित पूरी तरह से मान्य नोड चलाने की संसाधन मांगों को कम करना है। समन्वयन समय को
तेज करना इस लक्ष्य को भी आगे बढ़ाता है।

ब्लॉकचैन तुल्यकालन दो चरणों में होता है: पहला, नोड साथियों से ब्लॉक header प्राप्त करता है; ये शीर्षलेख (संभावित)
सर्वोत्तम श्रृंखला (सबसे अधिक काम करने वाला) निर्धारित करने के लिए पर्याप्त हैं। दूसरा, नोड संबंधित
पूर्ण ब्लॉक का अनुरोध करने और डाउनलोड करने के लिए header की इस सर्वश्रेष्ठ श्रृंखला का उपयोग करता
है। यह PR केवल पहले चरण (header डाउनलोड) को प्रभावित करता है।

{% include functions/details-list.md
  q0="<!--why-do-nodes-mostly-receive-inv-block-announcements-while-they-are-doing-initial-headers-sync-even-though-they-indicated-preference-for-headers-announcements-bip-130-->
  नोड्स (ज्यादातर) को प्रारंभिक header Sync करते समय `inv` ब्लॉक घोषणाएं क्यों प्राप्त होती हैं, भले
  ही उन्होंने header घोषणाओं ([BIP 130][]) के लिए वरीयता का संकेत दिया हो?"
  a0="एक नोड एक शीर्षलेख संदेश का उपयोग करते हुए एक सहकर्मी को एक नए ब्लॉक की घोषणा नहीं
  करेगा यदि सहकर्मी ने पहले एक शीर्षलेख नहीं भेजा
  है जिससे नया शीर्षलेख कनेक्ट होता है, और समन्वयन नोड्स शीर्षलेख नहीं भेजते हैं।"
  a0link="https://bitcoincore.reviews/25720#l-30"

  q1="<!--why-is-bandwidth-wasted-during-initial-headers-sync-by-adding-all-peers-that-announce-a-block-to-us-via-an-inv-as-headers-sync-peers-->
  header Sync पीयर्स के रूप में एक `inv` के माध्यम से हमारे लिए ब्लॉक की घोषणा करने वाले सभी साथियों को जोड़कर
  बैंडविड्थ (प्रारंभिक header Sync के दौरान) क्यों बर्बाद होता है?"
  a1="इनमें से प्रत्येक सहकर्मी तब हमें header की एक ही स्ट्रीम
  भेजना शुरू कर देगा: `inv` एक ही पीयर के लिए एक `getheaders` को ट्रिगर करता है, और इसका `header` उत्तर ब्लॉक की
  तुरंत निम्नलिखित रेंज के लिए एक और `getheaders` को ट्रिगर करता है header। अतिरिक्त बैंडविड्थ को छोड़कर
  डुप्लिकेट header प्राप्त करना हानिरहित है।"
  a1link="https://bitcoincore.reviews/25720#l-62"

  q2="<!--what-would-be-your-estimate-lower-upper-bound-of-how-much-bandwidth-is-wasted-->आपका अनुमान (निचला/ऊपरी बाउंड) कितना बैंडविड्थ बर्बाद हुआ है?"
  a2="अपर बाउंड (बाइट्स में): `(number_peers - 1) * number_blocks * 81`;
  निचला बाउंड: शून्य (यदि header Sync के दौरान कोई नया ब्लॉक नहीं आता है; यदि Syncing पीयर और नेटवर्क तेज है, तो
  सभी 700k+ header डाउनलोड करना केवल कुछ मिनट लगते हैं)"
  a2link="https://bitcoincore.reviews/25720#l-79"

  q3="<!--what-s-the-purpose-of-cnodestate-s-members-fsyncstarted-and-m-headers-sync-timeout-and-peermanagerimpl-nsyncstarted-if-we-start-syncing-headers-with-peers-that-announce-a-block-to-us-via-an-inv-why-do-we-not-increase-nsyncstarted-and-set-fsyncstarted-true-and-update-m-headers-sync-timeout-->
  CNodeState के सदस्यों `fSyncStarted` और `m_headers_sync_timeout`, और `PeerManagerImpl::nSyncStarted`
  का उद्देश्य क्या है? यदि हम header को साथियों के साथ समन्वयित करना शुरू करते हैं जो एक `inv` के माध्यम से हमें ब्लॉक की घोषणा
  करते हैं, तो हम `nSyncStarted` में वृद्धि क्यों नहीं करते हैं और `fSyncStarted = true` सेट करें और `m_headers_sync_timeout`
  अपडेट करें?"
  a3="`nSyncStarted` उन साथियों की संख्या की गणना करता है, जिनका `fSyncStarted` सत्य है, और यह
  संख्या 1 से अधिक नहीं हो सकती जब तक कि नोड के header वर्तमान समय के करीब (एक दिन के भीतर) न हों।
  यह (मनमाना) सहकर्मी हमारा प्रारंभिक header-Sync पीयर होगा। यदि यह पीयर धीमा है, तो नोड इसे टाइम आउट करता है
  (`m_headers_sync_timeout`) और पीयर को Sync करने वाला एक और 'प्रारंभिक' header ढूंढता है। लेकिन अगर,
  header Sync के दौरान, एक नोड एक `inv` संदेश भेजता है जो ब्लॉक की घोषणा करता है, फिर इस PR के बिना,
  नोड इस सहकर्मी से भी header का अनुरोध करना शुरू कर देगा, _बिना_ अपने `fSyncStarted` ध्वज को सेट करना।
  यह अनावश्यक header संदेशों का स्रोत है, और शायद इसका इरादा नहीं था, लेकिन
  इसका लाभ है header Sync को आगे बढ़ने की अनुमति देता है, भले ही प्रारंभिक header-Sync पीयर दुर्भावनापूर्ण, टूटा हुआ या
  बहुत धीमा हो। इस PR के साथ, नोड केवल _one_ अतिरिक्त पीयर (नए ब्लॉक की घोषणा करने वाले सभी साथियों
  के बजाय) से header का अनुरोध करता है।"
  a3link="https://bitcoincore.reviews/25720#l-102"

  q4="<!--an-alternative-to-the-approach-taken-in-the-pr-would-be-to-add-an-additional-headers-sync-peer-after-a-timeout-fixed-or-random-what-is-the-benefit-of-the-approach-taken-in-the-pr-over-this-alternative-->
  PR में लिए गए दृष्टिकोण का एक विकल्प यह होगा कि एक टाइमआउट (निश्चित या यादृच्छिक) के बाद एक
  अतिरिक्त header Sync पीयर को जोड़ा जाए। इस विकल्प पर PR में लिए गए दृष्टिकोण का क्या लाभ है?"
  a4="एक लाभ यह है कि सहकर्मी जो हमारे लिए `inv` की घोषणा करते हैं, उनके उत्तरदायी होने की
  संभावना अधिक होती है। दूसरा यह है कि एक सहकर्मी जो हमें पहले ब्लॉक `inv` भेजने का प्रबंधन करता है,
  वह अक्सर बहुत तेज़ सहकर्मी होता है। इसलिए हम 'अगर किसी कारण से हमारा शुरुआती साथी धीमा है तो
  दूसरा धीमा सहकर्मी नहीं चुनेंगे।"
  a4link="https://bitcoincore.reviews/25720#l-135"
%}
## रिलीज और रिलीज उम्मीदवार

*लोकप्रिय Bitcoin इन्फ्रास्ट्रक्चर परियोजनाओं के लिए नए रिलीज और रिलीज उम्मीदवार। कृपया नई रिलीज़ में
अपग्रेड करने या रिलीज़ उम्मीदवारों का परीक्षण करने में मदद करने पर विचार करें।*

- [LDK 0.0.111][] कई अन्य नई सुविधाओं और बग फिक्स के बीच [onion संदेश][topic onion messages]
  बनाने, प्राप्त करने और रिले करने के लिए समर्थन जोड़ता है।

## उल्लेखनीय कोड और दस्तावेज़ीकरण परिवर्तन

*इस सप्ताह [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][LND Repo] में उल्लेखनीय परिवर्तन।
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][Rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIP)][BIPs repo], और
[Lightning BOLTs][bolts repo]।*


- [Bitcoin Core #25614][][bitcoin core #24464][] पर निर्मित होता है, जो addrdb, addrman, banman, i2p, mempool,
  netbase, net, net_processing, timedata, और टोरकंट्रोल में विशिष्ट गंभीरता स्तरों के साथ लॉग जोड़ने और ट्रेस करने की क्षमता देता है।

- [Bitcoin Core #25768][] एक बग को ठीक करता है जहां वॉलेट हमेशा अपुष्ट लेनदेन के बाल लेनदेन का पुन:
  प्रसारण नहीं करेगा। Bitcoin Core का बिल्ट-इन वॉलेट समय-समय पर इसके किसी भी लेनदेन को प्रसारित करने का
  प्रयास करता है जिसकी अभी तक पुष्टि नहीं हुई है। उनमें से कुछ लेनदेन अन्य अपुष्ट लेनदेन से आउटपुट खर्च कर सकते हैं।
  Bitcoin Core एक अलग Bitcoin Core सबसिस्टम को भेजने से पहले लेनदेन के क्रम को यादृच्छिक बना रहा था,
  जो कि बच्चे के लेनदेन से पहले अपुष्ट मूल लेनदेन प्राप्त करने की उम्मीद करता था (या, आमतौर पर, किसी भी वंशज
  से पहले सभी अपुष्ट पूर्वजों)। जब कोई चाइल्ड ट्रांजैक्शन उसके पैरेंट के सामने प्राप्त हुआ था, तो उसे
  रीब्रॉडकास्ट करने के बजाय आंतरिक रूप से अस्वीकार कर दिया गया था।

- [Bitcoin Core #19602][] एक `migratewallet` RPC जोड़ता है जो [डिस्क्रिप्टर][topic descriptors] का उपयोग करके वॉलेट को मूल रूप
  से बदल देगा। यह pre-HD वॉलेट के लिए काम करता है (जो पहले [BIP32][] अस्तित्व में थे या Bitcoin Core द्वारा अपनाया गया था), HD वॉलेट
  और निजी कुंजी के बिना वॉच-ओनली वाले वॉलेट के लिए काम करता है। इस फ़ंक्शन को कॉल करने से पहले, [दस्तावेज़ीकरण][managing wallets] पढ़ें
  और जागरूक रहें कि गैर-डिस्क्रिप्टर वॉलेट और मूल रूप से डिस्क्रिप्टर का समर्थन करने वाले के बीच कुछ API अंतर हैं।

<!-- TODO:harding to separate dual funding from interactive funding -->

- [Eclair #2406][] प्रयोगात्मक [इंटरैक्टिव फंडिंग प्रोटोकॉल][topic dual funding] कार्यान्वयन को कॉन्फ़िगर
  करने के लिए एक विकल्प जोड़ता है ताकि चैनल के खुले लेनदेन में केवल *पुष्टि किए गए इनपुट* शामिल हों --- इनपुट जो
  आउटपुट खर्च करते हैं जो इसका एक हिस्सा हैं एक पुष्टि लेनदेन। यदि सक्षम किया जाता है, तो यह एक आरंभकर्ता को कम
  शुल्क के साथ एक बड़े अपुष्ट लेनदेन के आधार पर एक चैनल खोलने में देरी करने से रोक सकता है।

- [Eclair #2190][] मूल फिक्स्ड-लेंथ onion डेटा प्रारूप के लिए समर्थन को हटा देता है, जिसे [BOLTs #962][] में
  LN विनिर्देश से हटाने का भी प्रस्ताव है। उन्नत चर-लंबाई प्रारूप [विनिर्देश में जोड़ा गया][bolts #619] तीन साल से अधिक
  समय पहले और BOLTs #962 PR में उल्लिखित नेटवर्क स्कैनिंग परिणामों से संकेत मिलता है कि यह 17,000 से अधिक सार्वजनिक
  रूप से विज्ञापित नोड्स में से 5 द्वारा समर्थित है। Core Lightning ने भी इस साल की शुरुआत में समर्थन हटा दिया
  (देखें [न्यूज़लेटर #193][news193 cln5058])।

- [Rust Bitcoin #1196][] पहले से जोड़े गए `LockTime` प्रकार को संशोधित करता है (देखें [न्यूज़लेटर #211][news211 rb994])
  एक `absolute::LockTime` होने के लिए और एक नया `relative::LockTime` जोड़ता है [BIP68][] और [BIP112][] के साथ उपयोग
  किए जाने वाले LockTime का प्रतिनिधित्व करते हैं।

{% include references.md %}
{% include linkers/issues.md v=2 issues="25614,24464,25768,19602,2406,2190,962,619,1196" %}
[managing wallets]: https://github.com/bitcoin/bitcoin/blob/master/doc/managing-wallets.md
[news193 cln5058]: /en/newsletters/2022/03/30/#c-lightning-5058
[news211 rb994]: /hi/newsletters/2022/08/03/#rust-bitcoin-994
[ldk 0.0.111]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.111
[review club 25720]: https://bitcoincore.reviews/25720
[BIP 130]: https://github.com/bitcoin/bips/blob/master/bip-0130.mediawiki
