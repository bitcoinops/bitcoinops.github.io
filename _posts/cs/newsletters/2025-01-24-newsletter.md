---
title: 'Zpravodaj „Bitcoin Optech” č. 338'
permalink: /cs/newsletters/2025/01/24/
name: 2025-01-24-newsletter-cs
slug: 2025-01-24-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden ohlašuje návrh BIPu pro odkazování na neutratitelné
klíče v deskriptorech, zkoumá, jak implementace používají PSBTv2, a
přináší důkladnou korekci našeho popisu nového offchain DLC protokolu
z minulého týdne. Též nechybí naše pravidelné rubriky s popisem změn
ve službách a klientském software, oznámeními nových vydání a souhrnem
nedávných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Návrh BIPu na neutratitelné klíče v deskriptorech:** Andrew Toth
  zaslal do fóra [Delving Bitcoin][toth unspendable delv] a do emailové
  skupiny [Bitcoin-Dev][toth unspendable ml] [návrh BIPu][bips #1746],
  který by umožnil v [deskriptorech][topic descriptors] odkázat na
  prokazatelně neutratitelné klíče. Pro diskuzi předcházející tomuto
  návrh viz [zpravodaj č. 283][news283 unspendable]. Používání
  prokazatelně neutratitelného klíče, též nazývaného NUMS bod (_nothing
  up my sleeve_, nic v rukávu neschovávám), je obzvláště užitečné
  u [taprootových][topic taproot] interních klíčů. Je-li nemožné
  vytvořit utracení klíčem pomocí interního klíče, potom je jedinou možností
  útrata skriptem pomocí taprootového listu (např. pomocí [tapscriptu][topic
  tapscript]).

  V době psaní zpravodaje probíhá diskuze pod [pull requestem][bips #1746]
  návrhu.

- **Integrační test PSBTv2:** Sjors Provoost zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][provoost psbtv2] s dotazem na software, který
  již implementoval podporu [PSBT][topic psbt] verze 2 (viz [zpravodaj
  č. 141][news141 psbtv2], _angl._) a pomohl by otestovat [PR][bitcoin core
  #21283] přidávající stejnou podporu do Bitcoin Core. Aktuální
  seznam software s podporou lze [nalézt][bse psbtv2] na Bitcoin Stack
  Exchange. Dvě odpovědi nás zaujaly:

  - **Merklizované PSBTv2:** Salvatore Ingala [vysvětluje][ingala psbtv2],
    že Ledger Bitcoin App převádí pole PSBTv2 na Merkleův strom a posílá
    do hardwarového zařízení Ledger nejprve pouze kořen. Když potřebuje
    konkrétní pole, jsou do něj odeslána spolu s Merkleovým důkazem.
    To zařízení umožňuje bezpečnou práci nezávisle s každou dílčí informací
    bez nutnosti ukládat v jeho omezené paměti celé PSBT. S PSBTv2
    je to možné, neboť již obsahuje všechny části nepodepsané transakce
    v oddělených polích. U původního PSBT formátu (v0) by to vyžadovalo
    dodatečné zpracování.

  - **Tiché platby a PSBTv2:** [BIP352][], který [tiché platby][topic silent
    payments] specifikuje, explicitně závisí na specifikaci [BIP370][]
    PSBTv2. Andrew Toth [vysvětluje][toth psbtv2], že tiché platby potřebují
    PSBTv2 pole `PSBT_OUT_SCRIPT`, jelikož výstupní skript, který bude
    v tiché platbě použit, nemůže být znám, dokud všichni podepisující
    PSBT nezpracují.

- **Oprava textu o offchain DLC:** v popisu offchain DLC v [předchozím
  zpravodaji][news337 dlc] jsme pomíchali [nové schéma][conduition factories],
  které navrhl vývojář conduition, s již existujícím schématem offchain
  [DLC][topic dlc]. Mezi nimi jsou význačné a zajímavé rozdíly:

  - Protokol _DLC kanálů_ zmíněný ve zpravodajích [č. 174][news174 channels]
    (_angl._) a [č. 260][news260 channels] používá mechanismus podobný
    [LN-Penalty][topic ln-penalty], ve kterém se strany podpisem zavazují
    k novému stavu a poté anulují starý stav odevzdáním tajného kódu,
    který by protistraně umožnil starou verzi stavu kompletně utratit
    v případě zveřejnění onchain. Díky tomu mohou strany DLC interaktivně
    obnovit. Na příklad mohou Alice a Bob učinit následující:

    1. Okamžitě se shodnout na DLC o ceně BTC/USD po uplynutí jednoho měsíce.

    2. O tři týdny později se shodnout na DLC o ceně BTC/USD po uplynutí dvou
       měsíců od dnešního dne a zároveň anulovat předchozí DLC.

  - Nový protokol _DLC továren_ v době nabytí splatnosti kontraktu automaticky oběma
    stranám odebírá možnost zveřejňovat stav onchain. Jako tajný kód
    umožňující kompletně utratit soukromý stav v případě zveřejnění onchain
    lze použít jakoukoliv atestaci od orákula. V důsledku se tím automaticky
    ruší staré stavy, což bez další interakce umožní následná DLC podepsat
    již během vytváření továrny. Na příklad Alice a Bob mohou:

    1. Okamžitě se shodnout na DLC o ceně BTC/USD po uplynutí jednoho měsíce.

    2. Též okamžitě se shodnout na DLC o ceně BTC/USD po uplynutí dvou měsíců od
       dnešního dne s použitím transakce s [časovým zámkem][topic timelocks],
       která nemůže být zveřejněna před uplynutím jednoho měsíce. Pokračovat
       mohou s měsícem tři, čtyři atd.

  V protokolu DLC kanálů nemohou Alice s Bobem vytvořit druhý kontrakt, dokud
  nejsou připraveni anulovat první kontrakt, což si v té době mezi nimi
  vyžádá interakci. V protokolu DLC továren mohou být všechny kontrakty
  vytvořené v době vytvoření továrny a další interakce není vyžadována.
  Každá strana však i nadále může sérii kontraktů přerušit a zveřejnit
  onchain aktuální, správný stav.

  Pokud spolu mohou účastníci továrny po založení kontraktu interagovat,
  mohou kontrakt rozšířit, nemohou se však rozhodnout používat jiný kontrakt
  nebo jiná orákula, dokud všechny dříve podepsané kontrakty nedosáhnou
  splatnosti (nebo nejsou zveřejněny onchain). Ačkoliv je možné tento
  nedostatek odstranit, v současnosti se jedná o zvolený kompromis výměnou za
  nižší interaktivitu v porovnání s DLC kanály, které umožňují kdykoliv libovolně
  změnit kontrakt oboustrannou anulací.

  Děkujeme conduitionovi za upozornění na naši chybu v minulém zpravodaji
  a za trpělivé [odpovědi][conduition reply] na naše dotazy.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Bull Bitcoin Mobile Wallet přidává payjoin:**
  Bull Bitcoin [oznámil][bull bitcoin blog] podporu posílání a přijímání [payjoinem][topic
  payjoin] dle [navrhované][BIPs #1483] specifikace BIP77 Payjoin Version 2: Serverless
  Payjoin.

- **Bitcoin Keeper přidává podporu miniscriptu:**
  Bitcoin Keeper [ohlásil][bitcoin keeper twitter] podporu [miniscriptu][topic
  miniscript] přicházející ve [vydání v1.3.0][bitcoin keeper v1.3.0].

- **Nunchuk přidává funkce pro taproot s MuSig2:**
  Nunchuk [oznámil][nunchuk blog] beta podporu [MuSig2][topic musig] pro [taprootové][topic
  taproot] platby klíčem s [vícenásobným podpisem][topic multisignature] i
  MuSig2 platby skriptem umožňující [prahové][topic threshold signature] platby.

- **Ohlášena podpisová zařízení Jade Plus:**
  Hardwarové podpisové zařízení [Jade Plus][blockstream blog] mimo jiné poskytuje
  podepisování [odolné vůči exfiltraci][topic exfiltration-resistant signing] a
  schopnost fungovat bez připojení.

- **Vydán Coinswap v0.1.0 :**
  [Coinswap v0.1.0][coinswap v0.1.0] je beta software, který staví na formalizované
  [specifikaci][coinswap spec] protokolu pro [coinswap][topic coinswap], podporuje
  [testnet4][topic testnet] a obsahuje program pro příkazovou řádku pro interakci
  s protokolem.

- **Vydán Bitcoin Safe 1.0.0:**
  [Vydání 1.0.0][bitcoin safe 1.0.0] desktopové peněženky [Bitcoin Safe][bitcoin safe
  website] podporuje množství hardwarových podpisových zařízení.

- **Demonstrace pravidel Bitcoin Core 28.0:**
  Super Testnet [ohlásil][zero fee sn] webovou stránku [Zero fee playground][zero fee
  website], která demonstruje [funkce pravidel mempoolu][28.0 guide] přidané
  do vydání Bitcoin Core 28.0.

- **Vydán rust-payjoin 0.21.0:**
  Vydání [rust-payjoin 0.21.0][rust-payjoin 0.21.0] přidává možnost [prořezání
  transakcí][transaction cut-through] (transaction cut-through, viz [podcast č. 282][pod282
  payjoin]).

- **PeerSwap v4.0rc1:**
  Software PeerSwap pro likviditu lightningových kanálů byl vydán ve verzi
  [v4.0rc1][peerswap v4.0rc1], která přináší aktualizace protokolu. [PeerSwap FAQ][peerswap
  faq] ukazuje, jak se PeerSwap liší od [submarine swapů][topic submarine swaps],
  [splicingu][topic splicing] a [inzerátů likvidity][topic liquidity advertisements].

- **Prototyp joinpoolu používající CTV:**
  Ověření konceptu [ctv payment poolu][ctv payment pool github] používá pro vytváření
  [joinpoolu][topic joinpools] navrhovaný opkód [OP_CHECKTEMPLATEVERIFY (CTV)][topic
  op_checktemplateverify].

- **Ohlášena rustová knihovna pro joinstr:**
  Experimentální [rustová knihovna][rust joinstr github] implementuje [coinjoinový][topic
  coinjoin] protokol joinstr.

- **Ohlášen Strata bridge:**
  [Strata bridge][strata blog] je bridge založený na [BitVM2][topic acc] pro
  přesun bitcoinů do a ze [sidechainu][topic sidechains], konkrétně typu
  validity rollup (viz [zpravodaj č. 222][news222 validity rollups], _angl._).

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BTCPay Server 2.0.6][] přináší kromě několika nových funkcí a oprav chyb
  „bezpečnostní opravu pro obchodníky používající systém onchain refundací
  s automatickým zpracováním plateb.”

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #31397][] zlepšuje [řešení sirotků][news333 prclub] sledováním
  a používáním všech potenciálních spojení, která mohou chybějící rodičovské
  transakce poskytnout. Dříve proces řešení spoléhal pouze na spojení,
  které osiřelou transakci poskytlo. Pokud toto spojení neodpovídalo nebo
  vrátilo zprávu `notfound`, pokusy o získání rodičovské transakce se již
  neopakovaly. Nový přístup se pokusí rodičovskou transakci získat od všech
  vhodných spojení. Přitom je zachována efektivita využívání přenosového
  pásma, odolnost vůči cenzuře a vyrovnané rozložení zátěže. Nová metoda
  je obzvláště výhodná pro [přeposílání balíčků][topic package relay]
  s jedním rodičem a jedním potomkem (1p1c) a budoucí přeposílání balíčků
  předků dle [BIP331][].

- [Eclair #2896][] aktivuje ukládání částečných [MuSig2][topic musig] podpisů
  protistrany vedle tradičních 2-ze-2 vícenásobných podpisů. MuSig2 částečné
  podpisy budou používány budoucí implementací [jednoduchých taprootových
  kanálů][topic simple taproot channels]. Jejich ukládání umožní uzlu
  v případě potřeby jednostranně zveřejnit commitment transakce.

- [LDK #3408][] přidává do `ChannelManager` pomocné funkce pro vytváření
  statických faktur a [nabídek][topic offers] pro podporu [asynchronních plateb][topic
  async payments] v [BOLT12][] dle specifikace v [BOLTs #1149][]. Na rozdíl
  od vytváření běžné nabídky, u které musí být příjemce online, aby mohl
  reagovat na žádosti o fakturu, nová funkcionalita je užitečná pro příjemce,
  kteří jsou často offline. Toto PR dále přidává chybějící testy placení
  statických faktur (viz [zpravodaj č. 321][news321 async]) a zajišťuje,
  aby příjemce mohl po opětovném připojení obdržet žádosti o fakturu.

- [LND #9405][] přináší konfigurovatelnost parametru `ProofMatureDelta`, který
  určuje počet konfirmací, které jsou vyžadované pro zpracování [oznámení o
  kanálu][topic channel announcements]. Výchozí hodnota je 6.

{% include snippets/recap-ad.md when="2025-01-28 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1746,21283,31397,2896,3408,9405,1149,1483" %}
[news337 dlc]: /cs/newsletters/2025/01/17/#offchain-dlc
[conduition factories]: https://conduition.io/scriptless/dlc-factory/
[conduition reply]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000193.html
[news174 channels]: /en/newsletters/2021/11/10/#dlcs-over-ln
[news260 channels]: /cs/newsletters/2023/07/19/#penezenka-od-10101-testuje-sdileni-prostredku-mezi-ln-a-dlc
[condution reply]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000193.html
[news283 unspendable]: /cs/newsletters/2024/01/03/#specifikace-neutratitelnych-klicu-v-deskriptorech
[toth unspendable delv]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/31
[toth unspendable ml]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a594150d-fd61-42f5-91cd-51ea32ba2b2cn@googlegroups.com/
[news141 psbtv2]: /en/newsletters/2021/03/24/#bips-1059
[provoost psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/6FDAD97F-7C5F-474B-9EE6-82092C9073C5@sprovoost.nl/
[bse psbtv2]: https://bitcoin.stackexchange.com/a/125393/21052
[ingala psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAMhCMoGONKFok_SuZkic+T=yoWZs5eeVxtwJL6Ei=yysvA8rrg@mail.gmail.com/
[toth psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/30737859-573e-40ea-9619-1d18c2a6b0f4n@googlegroups.com/
[btcpay server 2.0.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.6
[news321 async]: /cs/newsletters/2024/09/20/#ldk-3140
[news333 prclub]: /cs/newsletters/2024/12/13/#bitcoin-core-pr-review-club
[bull bitcoin blog]: https://www.bullbitcoin.com/blog/bull-bitcoin-wallet-payjoin
[bitcoin keeper twitter]: https://x.com/bitcoinKeeper_/status/1866147392892080186
[bitcoin keeper v1.3.0]: https://github.com/bithyve/bitcoin-keeper/releases/tag/v1.3.0
[nunchuk blog]: https://nunchuk.io/blog/taproot-multisig
[blockstream blog]: https://blog.blockstream.com/introducing-the-all-new-blockstream-jade-plus-simple-enough-for-beginners-advanced-enough-for-cypherpunks/
[coinswap v0.1.0]: https://github.com/citadel-tech/coinswap/releases/tag/v0.1.0
[coinswap spec]: https://github.com/citadel-tech/Coinswap-Protocol-Specification
[bitcoin safe website]: https://bitcoin-safe.org/en/
[bitcoin safe 1.0.0]: https://github.com/andreasgriffin/bitcoin-safe
[zero fee sn]: https://stacker.news/items/805544
[zero fee website]: https://supertestnet.github.io/zero_fee_playground/
[28.0 guide]: /cs/bitcoin-core-28-wallet-integration-guide/
[rust-payjoin 0.21.0]: https://github.com/payjoin/rust-payjoin/releases/tag/payjoin-0.21.0
[transaction cut-through]: https://bitcointalk.org/index.php?topic=281848.0
[pod282 payjoin]: /en/podcast/2023/12/21/#payjoin-transcript
[peerswap v4.0rc1]: https://github.com/ElementsProject/peerswap/releases/tag/v4.0rc1
[peerswap faq]: https://github.com/ElementsProject/peerswap?tab=readme-ov-file#faq
[ctv payment pool github]: https://github.com/stutxo/op_ctv_payment_pool
[rust joinstr github]: https://github.com/pythcoiner/joinstr
[strata blog]: https://www.alpenlabs.io/blog/introducing-the-strata-bridge
[news222 validity rollups]: /en/newsletters/2022/10/19/#validity-rollups-research
