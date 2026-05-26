---
title: 'Zpravodaj „Bitcoin Optech” č. 398'
permalink: /cs/newsletters/2026/03/27/
name: 2026-03-27-newsletter-cs
slug: 2026-03-27-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden přináší naše pravidelné rubriky s vybranými otázkami a
odpověďmi z Bitcoin Stack Exchange, s oznámeními nových vydání a s popisem významných
změn v populárním bitcoinovém páteřním software.

## Novinky

*V našich [zdrojích][sources] jsme tento týden nenašli žádné významné novinky.*

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Co se myslí tím, že „bitcoin nepoužívá šifrování”?]({{bse}}130576)
  Pieter Wuille rozlišuje mezi šifrováním za účelem skrývání dat před neautorizovanými
  účastníky (což bitcoinové ECDSA neumí) a digitálními podpisy, které bitcoin
  používá pro autentizaci a ověřování.

- [Kdy a proč se Bitcoin Script posunul ke strukturám odhalujícím podmínky utrácení?]({{bse}}130580)
  Uživatel bca-0353f40e vysvětluje přechod z původního přístupu, kdy uživatelé
  platili přímo na veřejné klíče, přes P2PKH a P2SH k [segwitu][topic segwit]
  a [taprootu][topic taproot], kde jsou platební podmínky stanoveny ve výstupu
  a odhaleny jsou pouze během utrácení.

- [Vyzrazuje P2TR-MS (taprootový multisig M-z-N) veřejné klíče?]({{bse}}130574)
  Murch potvrzuje, že taprootové vícenásobné podpisy v podobě taprootového skriptu
  s jedním listem odhalují při placení všechny patřičné veřejné klíče,
  neboť OP_CHECKSIG i OP_CHECKSIGADD vyžadují jejich přítomnost.

- [Umožňuje OP_CHECKSIGFROMSTACK záměrně opakovaně používat podpisy napříč UTXO?]({{bse}}130598)
  Uživatel bca-0353f40e vysvětluje, že [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack] ([BIP348][]) záměrně nesvazuje podpisy s konkrétními
  vstupy, díky čemuž může být CSFS kombinováno s jinými [kovenantovými][topic
  covenants] opkódy. To přinese možnost svazovat podpisy s novými platebními
  podmínkami (rebindable signatures), což je potřebné pro [LN-Symmetry][topic eltoo].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 28.4][] je údržbovým vydáním předchozí hlavní řady této převládající
  implementace plného uzlu. Přináší hlavně opravy migrace peněženek a
  odstraňuje nespolehlivý DNS seed. [Poznámky k vydání][bcc 28.4 rn] obsahují
  další podrobnosti.

- [Core Lightning 26.04rc1][] je kandidátem na vydání příští hlavní verze
  tohoto populárního LN uzlu. Přináší mnoho aktualizací splicingu a
  opravy chyb.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #33259][] přidává do odpovědi na RPC volání `getblockchaininfo`
  pole `backgroundvalidation`, pokud uzel používá [assumeUTXO][topic
  assumeutxo] snapshoty. Nové pole obsahuje výšku snapshotu,
  aktuální výšku a haš bloku pro validaci na pozadí, průměr času, vykonanou
  práci řetězce a postup ověřování. Dříve odpověď pouze ukazovala,
  zda stahování bloků a ověřování bylo již dokončeno.

- [Bitcoin Core #33414][] aktivuje u automaticky vytvořených onion služeb
  Tor s [ochranou pomocí dokladů o provedené práci][tor pow] (proof of work defenses),
  pokud ji připojený démon podporuje. Má-li démon přístupný port pro ovládání a
  je-li nastavení `listenonion` v Bitcoin Core zapnuté (což je výchozí stav),
  je skrytá onion služba vytvořena automaticky. Tato funkce se netýká ručně vytvořených
  onion služeb, ale doporučuje se, aby uživatel ochranu aktivoval
  přidáním `HiddenServicePoWDefensesEnabled 1` do konfigurace.

- [Bitcoin Core #34846][] přidává do C API `libbitcoinkernel` (viz [zpravodaj
  č. 380][news380 kernel], _angl._) funkce `btck_transaction_get_locktime` a
  `btck_transaction_input_get_sequence`, které umožní přístup k polím
  [časových zámků][topic timelocks]: `nLockTime` transakcí a `nSequence` vstupů.
  Díky tomu je možné zkontrolovat pravidla dle [BIP54][] ([pročištění konsenzu][topic
  consensus cleanup]), jako jsou omezení `nLockTime` v mincetvorných transakcích,
  bez nutnosti ručního dekódování celé transakce (jiná pravidla BIP54, jako
  jsou sigops limity, stále vyžadují zvláštní zpracování).

- [Core Lightning #8450][] rozšiřuje [splicingový][topic splicing] skriptovací
  engine v CLN o zpracování splicingu napříč kanály a splicingu s více než třemi
  kanály a o dynamický výpočet poplatků. Hlavním problémem, který tato změna řeší,
  je cyklická závislost v odhadování poplatků: přidání vstupů navyšuje váhu
  transakce a tedy i potřebný poplatek, což může vyžadovat dodatečné vstupy.
  Jedná se o potřebný krok pro vytvoření nových RPC příkazů `splicein` a `spliceout`.

- [Core Lightning #8856][] a [#8857][core lightning #8857] přidávají RPC příkazy
  `splicein` a `spliceout` pro přidání prostředků z interní peněženky do kanálu
  a pro vyjmutí prostředků z kanálu do interní peněženky, na bitcoinovou adresu
  nebo do jiného kanálu (tedy tzv. cross-splice). Nové příkazy po provozovatelích
  nepožadují ruční vytváření [splicingových][topic splicing] transakcí
  pomocí experimentálního RPC `dev-splice`.

- [Eclair #3247][] přidává volitelný systém pro ohodnocování peer spojení, který
  v čase sleduje příjmy za přeposílání a objem plateb. Je-li systém aktivní,
  pravidelně hodnotí peer spojení dle výdělečnosti a může automaticky
  přidat prostředky do nejvíce profitabilních kanálů, automaticky zavřít
  neproduktivní kanály či automaticky upravit poplatky za přeposílání na základě
  objemu plateb. Vše je možné konfigurací omezit. Před zapnutím automatizace
  mohou provozovatelé výsledky systému pozorovat.

- [LDK #4472][] opravuje teoretický scénář vedoucí ke ztrátě prostředků během otevírání
  kanálu a [splicingu][topic splicing], ve kterém mohly být `tx_signatures` odeslány
  ještě před tím, než byl podpis commitmentu protistrany natrvalo uložen. Pokud
  by se tato transakce potvrdila a uzel by spadl, nebyl by schopen vynucovat
  stav svého kanálu. Oprava odkládá odeslání `tx_signatures` do doby, kdy
  je možné zprávu bezpečně odeslat.

- [LND #10602][] přidává do experimentálního subsystému `switchrpc` (viz [zpravodaj
  č. 386][news386 sendonion]) RPC volání `DeleteAttempts`. Tento příkaz umožňuje
  volajícímu z úložiště LND smazat dokončené (úspěšně či neúspěšně) záznamy o pokusech
  o urovnání [HTLC][topic htlc].

- [LND #10481][] přidává do testovacího rámce LND podporu pro těžbu pomocí `bitcoind`.
  Dříve `lntest` vyžadoval těžící backend založený na `btcd`, i když pro operace s řetězcem
  používal `bitcoind`. Tato změna umožňuje testovat chování, které závisí na mempoolu
  a těžbě Bitcoin Core, včetně [přeposílání transakcí verze 3][topic v3 transaction relay]
  a [přeposílání balíčků][topic package relay].

- [BOLTs #1160][] zveřejňuje protokol [splicingu][topic splicing] v rámci lightningové
  specifikace. Nahrazuje tím návrh z [BOLTs #863][] a přidává aktualizované toky operací
  a testovací data pro mezní případy, které za přepisem specifikace stály ([zpravodaj
  č. 246][news246 splicing draft] popisuje diskuzi během práce na návrhu). Splicing
  umožňuje peer spojením přidat nebo odebrat prostředky bez nutnosti zavřít kanál.
  Vyjednávání o splicingu začíná navázáním protokolu chvíle ticha (quiescence, viz
  [BOLTs #869][] a [zpravodaj č. 309][news309 quiescence]). Text, který byl přidán
  do BOLT2, pokrývá interaktivní konstrukci splicingové transakce, provozování
  kanálu během čekání na její potvrzení, navyšování jejího poplatku pomocí [RBF][topic rbf],
  proces opakovaného navázání spojení a uzamykání po dosažení dostatečné hloubky
  (`splice_locked`). Dále aktualizuje [oznamování kanálů][topic channel announcements].

{% include snippets/recap-ad.md when="2026-03-31 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33259,33414,34846,8450,8856,8857,3247,4472,10602,10481,1160,863,869" %}
[sources]: /en/internal/sources/
[Bitcoin Core 28.4]: https://bitcoincore.org/en/2026/03/18/release-28.4/
[bcc 28.4 rn]: https://bitcoincore.org/en/releases/28.4/
[Core Lightning 26.04rc1]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc1
[tor pow]: https://tpo.pages.torproject.net/onion-services/ecosystem/technology/security/pow/
[news380 kernel]: /en/newsletters/2025/11/14/#bitcoin-core-30595
[news386 sendonion]: /cs/newsletters/2026/01/02/#lnd-9489
[news246 splicing draft]: /cs/newsletters/2023/04/12/#diskuze-o-specifikaci-splicingu
[news309 quiescence]: /cs/newsletters/2024/06/28/#bolts-869
