---
title: 'Zpravodaj „Bitcoin Optech” č. 388'
permalink: /cs/newsletters/2026/01/16/
name: 2026-01-16-newsletter-cs
slug: 2026-01-16-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden odkazuje na diskuzi o inkrementálním mutačním testování
v Bitcoin Core a ohlašuje nasazení nového procesu přijímání BIPů. Též nechybí
naše pravidelné rubriky s oznámeními nových vydání a s popisem významných
změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Inkrementální mutační testování v Bitcoin Core**: Bruno Garcia
    zaslal do fóra Delving Bitcoin [příspěvek][mutant post] o své práci na zlepšení
    mutačního testování v Bitcoin Core. Mutační testování je technika, která
    vývojářům umožňuje vyhodnotit efektivitu testů tím, že záměrně do kódu přidává
    drobné chyby zvané mutanti (mutants). Pokud test selže, je mutant považován
    za zabitý, čímž signalizuje, že test tuto chybu dokáže odchytit. V opačném
    případě mutant přežije a odhalí tak možnou chybu v testu.

    Mutační testování přineslo významné výsledky, které vedly k otevření pull
    requestů opravujících některé z mutantů. Avšak tento proces je náročný na zdroje;
    dokončit jej na části kódu trvá přes 30 hodin. To je důvod, proč se Garcia
    zabývá inkrementálním mutačním testováním, které aplikuje mutační testování
    postupně na základě změn v kódu od poslední analýzy. Ačkoliv je tento proces
    rychlejší, stále trvá příliš dlouho.

    A proto Garcia pracuje na zefektivnění inkrementálního mutačního testování Bitcoin
    Core na základě studie od Googlu. Tento přístup je založen na následujících
    principech:

    - Vyhýbat se nevhodným mutantům, např. takovým, které nemá smysl opravovat.
    - Sbírat odezvu od vývojářů s cílem upřesnit generování mutantů.
    - Reportovat pouze omezené množství nezabitých mutantů (sedm dle výzkumu
        Googlu).

    Garcia tento přístup otestoval na osmi různých pull requestech, posbíral zpětnou
    odezvu a navrhl změny na řešení mutantů.

    Na závěr Garcia vývojáře požádal, aby mu dali vědět, pokud by chtěli spustit na svých
    PR mutační test a poskytnout zpětnou odezvu.

- **Aktualizace procesu přijímání BIPů**: Po více než [dvou měsících][bip3 motion to activate]
    probíhající [diskuze][bip3 follow-up to motion] v emailové skupině a po dalším kole
    [změn][bips #2051] návrhu bylo tento týden zřejmé, že BIP3 dosáhl hrubého konsenzu.
    BIP3 nasazený ve středu tak nahradil BIP2 jako průvodce procesu přijímání BIPů.
    I když z velké části zůstává podoba procesu zachována, přináší BIP3 několik změn.

    Mimo jiné byl zavržen systém komentování, počet stavů BIPu byl snížen z devíti
    (Draft, Proposed, Active, Final, Rejected, Deferred, Withdrawn, Replaced a Obsolete)
    na čtyři (Draft, Complete, Deployed a Closed), byly změněny hlavičky preambule,
    typ BIPu Standards Track byl nahrazen typem Specification a některá subjektivní
    rozhodnutí byla přeřazena z editorů BIPů na autory či čtenáře.

    [Přehled všech změn][bip2to3] lze nalézt v BIP3.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 30.2][] je údržbovým vydáním opravujícím chybu, která mohla
  způsobit smazání celého adresář `wallets` během migrování nepojmenované
  zastaralé peněženky (viz [zpravodaj č. 387][news387 wallet]). Též obsahuje
  několik dalších vylepšení a oprav (viz [poznámky k vydání][release notes]).

- [BTCPay Server 2.3.3][] je menším vydáním tohoto platebního procesoru s možností
  vlastního hostování. Přináší podporu pro transakce se studenou peněženkou
  pomocí API `Greenfield` (viz níže), odstraňuje zdroje kurzů pocházejících
  od CoinGecko a opravuje několik chyb.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #33819][] přidává do rozhraní `Mining` (viz [zpravodaj č. 310][news310
  mining]) novou metodu `getCoinbaseTx()`, která vrací všechna pole potřebná
  pro konstrukci mincetvorné transakce. Stávající metoda `getCoinbaseTx()`
  (která vracela serializovanou maketu transakce, kterou klient musel načíst a
  upravit) byla přejmenována na `getCoinbaseRawTx` a zastarána spolu s
  `getCoinbaseCommitment()` a `getWitnessCommitmentIndex()`.

- [Bitcoin Core #29415][] přidává do RPC volání `sendrawtransaction` nový booleovský
  příznak `privatebroadcast`, který zveřejní transakci skrz krátkodobé [Tor][topic
  anonymity networks] nebo I2P spojení, popř. skrz Tor proxy k jinému IPv4/IPv6 peer spojení.
  Cílem je ochrana soukromí původce transakce díky utajení jeho IP adresy
  a použití nových spojení pro každou transakci, což pomůže narušit vazby.

- [Core Lightning #8830][] přidává do nástroje `hsmtool` (viz [zpravodaj č. 73][news73
  hsmtool], _angl._) příkaz `getsecret`, který nahrazuje stávající příkaz `getsecretcodex`
  a přidává podporu pro obnovení uzlů vytvořených po změnách z verze 25.12 (viz
  [zpravodaj č. 383][news383 bip39], _angl._). U nových uzlů vypíše tento nový
  příkaz [BIP39][] mnemonickou frázi pro daný soubor `hsm_secret` a u starších uzlů vypíše
  `Codex32` řetězce. Plugin `recover` byl rozšířen o možnost používat mnemonické fráze.

- [Eclair #3233][] počíná používat nakonfigurované výchozí jednotkové poplatky v případě,
  kdy Bitcoin Core nemůže na [testnet3][topic testnet] nebo testnet4 odhadnout poplatky
  kvůli nedostatečným datům. Tyto výchozí poplatky jsou aktualizovány, aby lépe odrážely
  aktuální hodnoty.

- [Eclair #3237][] předělává události životního cyklu kanálů, aby byly v souladu se
  [splicingem][topic splicing] a [zero-conf][topic zero-conf channels] kanály.
  Přidává události `channel-confirmed`, která signalizuje, že otevírací transakce nebo
  splice byly potvrzeny, a `channel-ready`, která signalizuje připravenost kanálu
  pro platby. Odstraněna byla událost `channel-opened`.

- [LDK #4232][] přidává podporu pro experimentální signalizační příznak `accountable`,
  který nahrazuje [HTLC atestace][topic htlc endorsement] dle návrhů [BLIPs #67][]
  a [BOLTs #1280][]. LDK nastaví tento signál odpovědnosti na nulu u vlastních plateb a u
  přeposílaných plateb bez signalizace; u příchozích plateb tuto hodnotu odpovědnosti
  zkopíruje, pokud je přítomná. Podobné změny byly dříve učiněné též v Eclair
  a LND (viz [zpravodaj č. 387][news387 accountable]).

- [LND #10296][] přidává do RPC příkazu `EstimateFee` pole `inputs`, které umožní
  [odhadnout poplatek][topic fee estimation] pro konkrétní vstupy namísto vstupů
  automaticky zvolených peněženkou.

- [BTCPay Server #7068][] přidává podporu pro transakce se studenou peněženkou
  pomocí API `Greenfield`. To umožňuje uživatelům generovat nepodepsaná [PSBT][topic
  psbt] a zveřejňovat externě podepsané transakce. Tato funkcionalita nabízí
  zvýšenou bezpečnost v automatizovaných prostředích a umožňuje sestavy,
  které splňují vysoké požadavky na dodržování právních předpisů.

- [BIPs #1982][] přidává [BIP433][], který specifikuje standardní výstup
  [Pay-to-Anchor (P2A)][topic ephemeral anchors] a označuje utrácení tohoto
  výstupu za standardní.

{% include snippets/recap-ad.md when="2026-01-20 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33819,29415,8830,3233,3237,4232,67,1280,10296,7068,1982,2051" %}
[mutant post]: https://delvingbitcoin.org/t/incremental-mutation-testing-in-the-bitcoin-core/2197
[Bitcoin Core 30.2]: https://bitcoincore.org/bin/bitcoin-core-30.2/
[release notes]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-30.2.md
[BTCPay Server 2.3.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.3
[news387 wallet]: /cs/newsletters/2026/01/09/#bitcoin-core-34156
[news310 mining]: /cs/newsletters/2024/07/05/#bitcoin-core-30200
[news73 hsmtool]: /en/newsletters/2019/11/20/#c-lightning-3186
[news383 bip39]: /en/newsletters/2025/12/05/#core-lightning-v25-12
[news387 accountable]: /cs/newsletters/2026/01/09/#eclair-3217
[bip2to3]: https://github.com/bitcoin/bips/blob/master/bip-0003.md#changes-from-bip2
[bip3 motion to activate]: https://gnusha.org/pi/bitcoindev/205b3532-ccc1-4b2f-964f-264fc6e0e70b@murch.one/
[bip3 follow-up to motion]: https://gnusha.org/pi/bitcoindev/1d76a085-deff-4df2-8a82-f8bd984fac27@murch.one/
