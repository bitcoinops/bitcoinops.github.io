---
title: 'Zpravodaj „Bitcoin Optech” č. 234'
permalink: /cs/newsletters/2023/01/18/
name: 2023-01-18-newsletter-cs
slug: 2023-01-18-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden popisujeme návrh na nové opkódy související s úschovnami
a přinášíme naše pravidelné rubriky se souhrnem zajímavých změn
v klientech a službách, oznámeními o nových vydáních a kandidátech
na vydání a popisem významných změn oblíbeného bitcoinového
páteřního software.

## Novinky

- **Návrh na nové opkódy pro úschovny:** James O'Beirne [zaslal][obeirne
  op_vault] do emailové skupiny Bitcoin-Dev [návrh][obeirne paper]
  na soft fork, který by přidal dva nové opkódy: `OP_VAULT` a `OP_UNVAULT`.

  - `OP_VAULT` by vyžadoval tři parametry: commitment vysoce
    důvěryhodného způsobu platby, [dobu čekání][topic timelocks]
    a commitment méně důveryhodného způsobu platby.

  - `OP_UNVAULT` by také vyžadoval tři parametry. V případě použití
    podle O'Beirneových představ by tyto parametry byly: stejný
    commitment vysoce důvěryhodného způsobu platby, stejná doba
    čekání a commitment jednoho nebo více výstupů pro použití
    v pozdější transakci.

  Pro vytvoření [úschovny][topic vaults] („vault”) si Alice zvolí
  vysoce důvěryhodný způsob platby, např. vícenásobný podpis vyžadující
  přístup k několika odděleným podpisovým zařízením nebo studeným
  peněženkám uloženým v různých lokalitách. Též si zvolí méně
  důvěryhodný způsob platby, jako je jednoduchý podpis ze své horké
  peněženky. Nakonec si zvolí dobu čekání ve stejném formátu jako [BIP68][],
  který umožní stanovit dobu od několika minut po zhruba rok. Dále
  Alice vytvoří běžnou bitcoinovou adresu pro přijetí prostředků
  do své úschovny. Tato adresa bude zavázána skriptu používajícímu
  `OP_VAULT`.

  Bude-li chtít Alice utratit prostředky dříve přijaté do své úschovny,
  začne určením výstupů, kterým si v konečném důsledky přála platit
  (např. platba Bobovi a návrat zbytku zpět do úschovny). V obvyklém
  případě by Alice naplnila podmínky svého méně důvěryhodného způsobu
  platby, např. poskytnutím podpisu ze své horké peněženky, k vytvoření
  transakce posílající veškeré uschované prostředky na jediný výstup.
  Tento výstup obsahuje `OP_UNVAULT` se stejnými parametry vysoce
  důvěryhodného způsobu platby a doby čekání. Třetím parametrem je
  commitment výstupům, kterým Alice chce nakonec platit. Alice nyní
  může dokončit konstrukci transakce, včetně stanovení poplatků
  pomocí [sponzorování poplatků][topic fee sponsorship] („fee
  sponsorship”, typ [anchor výstupů][topic anchor outputs]) či jiného
  mechanismu.

  Alice transakci odešle a později je zařazena do bloku. To umožní
  komukoliv povšimnout si, že probíhá proces o otevření úschovny
  („unvault”). Alicin software detekuje utrácení jejích uschovaných
  prostředků a ověří, že třetí parametr `OP_UNVAULT` výstupu
  potvrzené transakce přesně odpovídá commitmentu, který Alice
  předtím vytvořila. Odpovídá-li, počká nyní Alice stanovenou dobu,
  po které může odeslat transakci utrácející z `OP_UNVAULT` UTXO
  na výstupy, které dříve stanovila (např. Bobovi a zbytek platby
  sobě). Toto by bylo úspěšné utracení Aliciných prostředků použitím
  jejího méně důvěryhodného způsobu platby, např. pomocí horké
  peněženky.

  Avšak představte si, že Alicin software spatří potvrzený pokus o
  otevření úschovny a nerozpoznává jej. V takovém případě má software
  možnost zmrazit prostředky během čekací doby. Vytvoří transakci
  utrácející `OP_UNVAULT` výstup na vysoce důvěryhodnou adresu, která
  byla součástí předchozích commitmentů. Pokud se tato transakce
  potvrdí, než vyprší čekací doba, jsou Aliciny prostředky v bezpečí
  před kompromitací jejího méně důvěryhodného způsobu platby. Poté,
  co byly prostředky přesunuty, může je Alice kdykoliv utratit
  splněním podmínek vysoce důvěryhodného způsobu platby (například
  studenou peněženkou).

  Vedle nových opkódů popisuje O'Beirne také motivaci pro úschovny
  a analyzuje i jiné způsoby včetně těch, které již nyní v bitcoinu
  existují (používající dopředu podepsané transakce), i takových,
  které by závisely na navrhovaném soft forku pro přidání [koventantů][topic
  covenants]. Některé z výhod tohoto návrhu:

  - *Menší witnessy:* návrhy flexibilních kovenantů, jako ty používající
    navhovaný [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack],
    by vyžadovaly, aby witnessy pro transakce otevření úschovny
    obsahovaly kopie velkého množství dat z jiných míst transakce.
    Tím by se navyšovala velikost a poplatky za tuto transkaci.
    `OP_VAULT` vyžaduje mnohem menší skripty a witnessy.

  - *Utrácení vyžaduje méně kroků:* dnes dostupné méně flexibilní
    návrhy koventantů a úschoven, které jsou založené na předem
    podepsaných transakcích, vyžadují vybrání prostředků na
    předurčenou adresu před tím, než mohou být odeslány do konečné
    destinace. Tyto návrhy také většinou vyžadují, aby byl každý
    výstup utracen v separátní transakci, což znemožňuje použití
    [skupinových plateb][topic payment batching]. To navyšuje
    počet transakcí, jejich velikost i náklady.

    `OP_VAULT` vyžaduje méně transakcí v typickém případě utrácení
    jediného výstupu a také podporuje skupinové transakce v případě
    utrácení nebo zmrazování více výstupů. Může tedy ušetřit
    velké množství prostoru a umožnit úschovnám obdržet mnohem
    více transakcí před tím, než je potřeba konsolidovat jejich
    výstupy kvůli bezpečnosti.

  V diskuzi o tomto nápadu navrhl Greg Sanders (jak [shrnul O'Beirne][obeirne
  scripthash]) mírně odlišnou konstrukci, která „by například umožnila,
  aby byly všechny výstupy [P2TR][topic taproot], což by skrylo
  operace nad úschovnou – docela dobrá fíčura.”

  Anthony Towns [poznamenává][towns op_vault], že návrh umožňuje
  uživatelům úschoven kdykoliv zmrazit prostředky jejich pouhým
  posláním na vysoce důvěryhodnou adresu, ze které je mohou později
  rozmrazit. To přináší majitelům úschoven velkou výhodu, protože
  k blokaci pokusu o krádež nepotřebují přístup ke svým vysoce
  zabezpečeným klíčům (např. ke studeným peněženkám). Na druhou stranu
  může každá třetí strana, která se adresu dozví, také zmrazit
  uživatelovy prostředky (i když bude muset zaplatit poplatek), což
  uživatelovi přinese nepříjemnosti. Aby mohly odlehčené peněženky
  nalézt své transakce na blockchainu, prozrazuje mnoho z nich
  své adresy třetím stranám. Úschovny postavené na těchto peněženkách
  by tak mohly dát neúmyslně třetím stranám možnost přinést jejich
  uživatelům nepříjemnosti. Towns navrhuje
  alternativní konstrukci podmínek zmrazení tak, aby při iniciaci
  zmrazování vyžadovaly nějakou dodatečnou informaci. To by zachovalo
  všechny výhody tohoto systému a také by snížilo riziko
  nezamýšleného zmrazení. Towns také navrhuje možné vylepšení
  podpory skupinových transakcí a zamýšlí se nad podporou taprootu.

  Několik reakcí též zmínilo, že `OP_UNVAULT` může poskytnout mnoho
  vlastností navrhovaného [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]
  (CTV) včetně výhod pro [DLC][topic dlc] dříve popsané ve [zpravodaji č. 185][news185
  ctv-dlc] (*angl.*), i když s většími náklady na blockchainu.

  V době psaní zpravodaje diskuze stála probíhala.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Kraken oznamuje posílání na taprootové adresy:**
  V nedávném [blogovém příspěvku][kraken bech32m] oznámil Kraken podporu
  pro zasílání prostředků na [bech32m][topic bech32] adresy.

- **Ohlášena rustová klientská knihovna pro Whirlpool coinjoin:**
  [Samourai Whirlpool Client][whirlpool rust client] je rustová knihovna
  pro nakládání s Whirlpool [coinjoinem][topic coinjoin].

- **Podpora miniscriptu v Ledgeru:**
  Jak bylo dříve [ohlášeno][ledger miniscript], bitcoinovým firmwarem
  v2.1.0 přináší Ledger podporu [miniscriptu][topic miniscript] pro svá
  zařízení.

- **Vydána peněženka Liana:**
  Byla [ohlášena][liana blog] první verze peněženky Liana. Podporuje peněženky
  s jednoduchým podpisem a klíčem pro obnovu s [časovým zámkem][topic timelocks].
  Mezi plány do budoucna patří podpora [taprootu][topic taproot], multisig
  peněženky a multisig s časovým úpadkem.

- **Vydán Electrum 4.3.3:**
  [Electrum 4.3.3][electrum 4.3.3] obsahuje vylepšení Lightningu, [PSBT][topic
  psbt], podpory podpisových zařízení a sestavovacího systému.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [HWI 2.2.0][] je vydáním této aplikace umožňující softwarovým peněženkám
  přístup k hardwarovým podpisovým zařízením. Přináší opravy chyb a mimo jiné
  novinky přidává podporu pro [P2TR][topic taproot] platby klíčem podpisovým
  zařízením BitBox02.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Core Lightning #5751][] zavrhuje podporu pro tvorbu nových segwitových P2SH adres.

- [BIPs #1378][] přidává [BIP324][] pro [P2P protokol verze 2][topic v2 p2p transport].

{% include references.md %}
{% include linkers/issues.md v=2 issues="5751,1378" %}
[hwi 2.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.0
[obeirne op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021318.html
[obeirne paper]: https://jameso.be/vaults.pdf
[obeirne scripthash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021329.html
[news185 ctv-dlc]: /en/newsletters/2022/02/02/#improving-dlc-efficiency-by-changing-script
[towns op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021328.html
[kraken bech32m]: https://blog.kraken.com/post/16740/bitcoin-taproot-address-now-supported-on-kraken/
[whirlpool rust client]: https://github.com/straylight-orbit/whirlpool-client-rs
[ledger miniscript]: https://blog.ledger.com/miniscript-is-coming/
[liana blog]: https://wizardsardine.com/blog/liana-announcement/
[electrum 4.3.3]: https://github.com/spesmilo/electrum/blob/4.3.3/RELEASE-NOTES
