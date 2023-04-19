---
title: 'Zpravodaj „Bitcoin Optech” č. 247'
permalink: /cs/newsletters/2023/04/19/
name: 2023-04-19-newsletter-cs
slug: 2023-04-19-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme novinky o vývoji protokolu RGB a naše pravidelné
rubriky se souhrnem změn v klientech a službách, oznámeními
o nových vydáních a popisem významných změn v populárních páteřních
bitcoinových projektech.

## Novinky

- **Aktualizace RGB:** Maxim Orlovsky zaslal do emailové skupiny Bitcoin-Dev
  [příspěvek][orlovsky rgb] s aktualizací stavu vývoje RGB. RGB je protokol,
  který používá bitcoinové transakce k provádění změn stavu offchainových
  kontraktů. Jednoduchým příkladem je vytváření a přenos tokenů, avšak RGB
  bylo navrženo k širšímu spektru využití, než je transfer tokenů.

  - Alice offchain vytvoří kontrakt, jehož výchozí stav přiřazuje 1 000
    tokenů určitému UTXO, který kontroluje.

  - Bob chce 400 z těchto tokenů. Alice mu dá kopii původního kontraktu
    spolu s transakcí, která utrácí její UTXO na nový výstup. Tento
    výstup obsahuje neveřejný závazek (commitment) nového stavu
    kontraktu. Nový stav kontraktu určuje distribuci prostředků (400
    Bobovi, 600 zpět Alici) a identifikátory dvou výstupů, které budou
    kontrolovat tyto prostředky. Alice transakci zveřejní. Bezpečnost
    tohoto přenosu tokenů proti dvojímu utracení je nyní shodná s bezpečností
    Alicina přenosu bitcoinů, např. má-li její transakce šest konfirmací,
    je přenos tokenů zabezpečený proti forku až šesti bloků.

    Výstupy, které kontrolují prostředky, nemusí být výstupy transakce, která
    obsahuje commitment (ale mohou být). To narušuje schopnost použít
    analýzu transakcí k vystopování přenosů založených na RGB. Tokeny mohly
    být přeneseny na existující UTXO, nebo na jakékoliv UTXO, které bude
    v budoucnosti existovat (např. předem podepsané utracení ze studené
    peněženky, které se ještě roky nemusí na blockchainu objevit). Hodnota
    bitcoinů na těchto výstupech a další jejich vlastnosti jsou pro RGB
    protokol irelevantní, avšak Alice a Bob se budou chtít ujistit o jejich
    snadné utratitelnosti.

  - Později by chtěla Carol koupit 100 tokenů od Boba v rámci atomické
    výměny za použití jediné onchainové transakce. Vygeneruje nepodepsané
    PSBT, které čerpá prostředky z jejích vstupů, posílá Bobovi bitcoin
    v jednom výstupu a vrací jí zbytek ve výstupu druhém. Jeden z těchto
    výstupů také zavazuje k příslušným částkám a identifikátorům UTXO,
    na které Carol obdrží tokeny a Bob zbytek po přenosu.

    Bob Carol poskytne původní kontrakt a závazek, který předtím Alice
    vytvořila, který dokazuje, že Bob vlastní 400 tokenů. Bob nemusí vědět,
    jak Alice naložila se zbývajícími 600 tokeny a Alice se výměny mezi
    Bobem a Carol vůbec neúčastní, což poskytuje soukromí a škálovatelnost.
    Bob přidá do PSBT podpepsaný vstup UTXO, které tokeny kontroluje.

    Carol ověří původní kontrakt a historii předchozích aktualizací stavu.
    Též se ujistí, že vše v PSBT je správné. Podepíše a transakci zveřejní.

  I když každý z uvedených transferů byl učiněn na blokchchainu, je jednoduché
  protokol upravit pro fungování offchain. Carol poskytne Danovi kopii
  kontraktu spolu s historií změn stavu, které ukazují, že obdržela 100 tokenů.
  Ve spolupráci s Danem poté vytvoří výstup, který obdrží 100 tokenů a který
  k utracení vyžaduje podpisy jich obou. Poté si offchain mohou posílat tokeny tam
  a zpět; učiní tak generováním množství rozličných verzí transakce utrácející
  onen výstup s vícenásobným podpisem. Každé offchain utracení se zaváže
  k distribuci tokenů a identifikátorům výstupů, které tyto tokeny obdrží.
  Nakonec jeden z nich zveřejní jednu z utrácejících transakcí, čímž
  potvrdí stav na blockchainu.

  Výstupy, kterým byly tokeny přiřazeny, mohou být zatížené bitcoinovým
  skriptem, který určí, kdo bude nakonec tokeny kontrolovat. Například
  mohou platit [HTLC][topic htlc] skriptu, který dá Carol možnost
  utratit tokeny, kdykoliv poskytne předobraz a podpis. Nebo umožní
  Danovi utratit tokeny po určité době pouhým podpisem. Díky tomu mohou
  být tokeny použity v přeposílaných offchain platbách, například v LN.

  Ve své [odpovědi][tenga rgb] poukázal Federico Tenga na [LN
  uzel][rgb-lightning-sample] založený na RGB a forku [LDK][ldk repo]
  a jeho [příkladu LN uzlu][ldk-sample]. Zkoumáním tohoto projektu jsme
  našli další [užitečné informace][rgb.info ln] o kompatibilitě s LN.
  Více informací o RGB protokolu lze nalézt na [webové stránce][rgb.tech]
  provozované LNP/BP Association.

  Tento týden oznámil Orlovsky [vydání][rgb blog] RGB v0.10. Tato nová
  verze není kompatibilní s kontrakty vytvořenými v předešlých verzích;
  není však známa existence žádných RGB kontraktů na mainnetu. Nový design
  umožní v případě změn upgrade všech nově vytvořených kontraktů. Vydání
  obsahuje množství dalších vylepšení a nastiňuje budoucí vývoj.

  V době psaní tohoto zpravodaje obdrželo oznámení v emailové skupině
  jen malé množství reakcí.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Descriptor wallet library přidává prohlížeč bloků:**
  [Descriptor wallet library][] je rustová knihovna postavená na rust-bitcoin
  pro peněženky založené na deskriptorech. Podporuje [miniscript][topic miniscript],
  [deskriptory][topic descriptors], [PSBT][topic psbt] a díky předchozímu
  [vydání][Descriptor Wallet v0.9.2] též textový [prohlížeč bloků][topic block explorers],
  který zobrazuje informace o taprootových [control blocích][se107154] z witnessů
  a deskriptory a miniscripty odpovídající skriptům v transakci.

- **Aktualizace referenční implementace protokolu Stratum v2:**
  Projekt [zveřejnil detaily][stratum blog] o změnách, mezi které patří
  možnost pro těžaře v poolu zvolit transakce pro kandidáta na blok.
  Autoři vyzývají těžaře, pooly a vývojáře firmware k testování a poskytnutí
  zpětné vazby.

- **Vydána Liana 0.4:**
  Vydání Liany [verze 0.4][liana 0.4] přináší podporu pro obnovu s více možnostmi
  a dodatečné deskriptory umožňující větší kvora.

- **Firmware Coldcardu podporuje další sighash příznaky:**
  [Verze 5.1.2 firmware][coldcard firmware] Coldcardu nyní vedle `SIGHASH_ALL`
  podporuje všechny ostatní [sighashe][wiki sighash], což rozšíří
  možnosti transakcí.

- **Zeus přidává navýšení poplatku:**
  [Zeus v0.7.4][] přidává navýšení poplatku pomocí [RBF][topic rbf] a [CPFP][topic
  cpfp]. Navýšit poplatky lze onchainovým transakcím včetně otevíracích a zavíracích
  transakcí LN kanálů. Navýšení poplatků lze zatím využít jen s LND backendem.

- **Oznámen Electrum Server založený na utreexo:**
   [Floresta][floresta blog] je server kompatibilní s Electrum protokolem,
   který využívá [utreexo][topic utreexo] ke snížení požadavků na zdroje serveru.
   Software v současnosti podporuje testovací síť [signet][topic signet].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK 0.28.0][] je údržbovým vydáním této knihovny pro tvorbu bitcoinových aplikací.

- [Core Lightning 23.02.2][] je údržbovým vydáním tohoto LN uzlu přinášející
  několik oprav chyb.

- [Core Lightning 23.05rc1][] je kandidátem na vydání příští verze tohoto LN uzlu.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #27358][] upravuje skript `verify.py` automatizující
  ověřování souborů vydání Bitcoin Core. Uživatel importuje PGP
  klíče lidí, kterým věří. Skript stáhne seznam souborů vydání spolu
  s jejich kontrolními součty a podpisy lidí, kteří stvrdili tyto kontrolní
  součty. Skript poté ověří minimálně *k* z těchto důvěryhodných lidí
  (uživatel si *k* zvolí sám podle potřeby). Je-li nalezeno dostatečné
  množství validních podpisů, stáhne skript soubory pro instalaci této
  verze Bitcoin Core. [Dokumentace][verify docs] nabízí dodatečné informace.
  Skript není pro používání Bitcoin Core vyžadován a nabízí jen automatizaci
  procesu, který by uživatelé měli sami provádět před každým používáním citlivých
  souborů stažených z internetu.

- [Core Lightning #6120][] vylepšuje logiku [nahrazování transakcí][topic rbf]
  včetně implementace pravidel pro automatické navýšení poplatků transakce
  pomocí RBF a opakované zveřejňování nepotvrzených transakcí (viz
  [zpravodaj č. 243][news243 rebroadcast]).

- [Eclair #2584][] přidává podporu [splicingu][topic splicing]: pro splice-in
  přidávající prostředky na existující kanál i splice-out posílající prostředky
  z kanálu na blockchain. PR poznamenává, že obsahuje několik odlišností
  od aktuálního [návrhu specifikace][bolts #863].

{% include references.md %}
{% include linkers/issues.md v=2 issues="27358,6120,2584,863" %}
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[orlovsky rgb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021554.html
[tenga rgb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021558.html
[rgb-lightning-sample]: https://github.com/RGB-Tools/rgb-lightning-sample
[ldk-sample]: https://github.com/lightningdevkit/ldk-sample
[rgb.tech]: https://rgb.tech/
[rgb.info ln]: https://docs.rgb.info/lightning-network-compatibility
[verify docs]: https://github.com/theuni/bitcoin/blob/754fb6bb8125317575edec7c20b5617ad27a9bdd/contrib/verifybinaries/README.md
[news243 rebroadcast]: /cs/newsletters/2023/03/22/#lnd-7448
[rgb blog]: https://rgb.tech/blog/release-v0-10/
[bdk 0.28.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.28.0
[Core Lightning 23.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02.2
[Core Lightning 23.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc1
[Descriptor wallet library]: https://github.com/BP-WG/descriptor-wallet
[Descriptor Wallet v0.9.2]: https://github.com/BP-WG/descriptor-wallet/releases/tag/v0.9.2
[stratum blog]: https://stratumprotocol.org/blog/stratumv2-jn-announcement/
[liana 0.4]: https://wizardsardine.com/blog/liana-0.4-release/
[coldcard firmware]: https://coldcard.com/docs/upgrade
[wiki sighash]: https://en.bitcoin.it/wiki/Contract#SIGHASH_flags
[zeus v0.7.4]: https://github.com/ZeusLN/zeus/releases/tag/v0.7.4
[floresta blog]: https://medium.com/vinteum-org/introducing-floresta-an-utreexo-powered-electrum-server-implementation-60feba8e179d
[se107154]: https://bitcoin.stackexchange.com/questions/107154/what-is-the-control-block-in-taproot
