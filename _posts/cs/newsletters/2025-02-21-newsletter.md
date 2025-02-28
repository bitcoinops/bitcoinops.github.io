---
title: 'Zpravodaj „Bitcoin Optech” č. 342'
permalink: /cs/newsletters/2025/02/21/
name: 2025-02-21-newsletter-cs
slug: 2025-02-21-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje myšlenku na urovnávání LN kanálů mobilními
peněženkami bez potřeby mít UTXO navíc a shrnuje pokračující diskuzi o
přidání příznaku quality of service pro hledání cest v LN. Též nechybí
naše pravidelné rubriky s popisem nedávných změn ve službách, klientech
a populárním bitcoinovém páteřním software.

## Novinky

- **Možnost mobilních peněženek urovnat kanál bez nutnosti mít UTXO navíc:**
  Bastien Teinturier zaslal do fóra Delving Bitcoin [příspěvek][teinturier
  mobileclose] o volitelné variantě [v3 commitmentů][topic v3 commitments]
  pro LN kanály, která by mobilním peněženkám umožnila pomocí prostředků
  kanálu uzavřít kanály i v případech, kdy je krádež možná, aniž by musely
  mít k dispozici onchain UTXO na zaplacení poplatků.

  Teinturier začíná vyjmenováním čtyř případů, ve kterých musí mobilní
  peněženka zveřejnit transakci:

  1. Protistrana zveřejní revokovanou commitment transakci, např. se pokouší
     ukrást peníze. V tomto případě získává peněženka okamžitě možnost
     utratit všechny prostředky kanálu a použít je na zaplacení poplatků.

  2. Mobilní peněženka odeslala platbu, která ještě nebyla urovnaná.
     V tomto případě je krádež vyloučena, jelikož protistrana by mohla
     platbu nárokovat pouze poskytnutím předobrazu [HTLC][topic htlc]
     (tedy důkazu o platbě konečnému příjemci). Jelikož není krádež
     možná, mobilní peněženka nemusí s hledáním UTXO na zaplacení
     poplatků za uzavření kanálu pospíchat.

  3. Žádné platby na vyrovnání nečekají, ale vzdálená strana nereaguje.
     Ani zde není krádež možná, mobilní peněženka má na zavření kanálu
     čas.

  4. Mobilní peněženka je příjemcem HTLC. V tomto případě může vzdálená
     strana obdržet předobraz HTLC (což jí umožní nárokovat prostředky
     od spojení proti směru toku), ale zůstatek kanálu neaktualizuje
     a HLTC revokuje. V tento okamžik musí mobilní peněženka vynuceně
     kanál uzavřít během relativně nízkého počtu bloků. Zbytek příspěvku
     se zabývá právě tímto případem.

  Teinturier navrhuje, aby vzdálená strana podepsala dvě různé verze
  každého HTLC, které mobilní peněžence platí: verzi s nulovým poplatkem
  dle výchozích pravidel commitmentů s nulovými poplatky a verzi
  platící takový poplatek, který jí aktuálně umožní rychlé potvrzení.
  Poplatky jsou odečteny z hodnoty HTLC platící mobilní peněžence, vzdálenou
  stranu tedy nabízení této možnosti nestojí nic navíc a mobilní peněženka
  má motivaci ji použít jen v nezbytných případech. Teinturier
  [poznamenává][teinturier mobileclose2], že vzdálená strana musí dát
  pozor na výšku poplatků, očekává však snadné řešení.

- **Pokračující diskuze o příznaku quality of service v LN:** Joost
  Jager zaslal do fóra Delving Bitcoin [příspěvek][jager lnqos] navazující
  na diskuzi o přidání QoS příznaku (Quality of Service) do LN protokolu,
  kterým by mohly uzly signalizovat vysokou dostupnost svých kanálů,
  tedy schopnost přeposílat platby do určité výše se 100% spolehlivostí
  (viz též [zpravodaj č. 239][news239 qos]). Pokud si plátce zvolí kanál
  nabízející vysokou dostupnost a jeho platba selže, může plátce
  provozovatele potrestat tím, že jeho kanál již nikdy nepoužije. Nově
  Jager navrhl signalizování na úrovni uzlů, např. jednoduše připojením
  „HA” (high availability) k aliasu uzlu, a dodal, že aktuální chybová
  hlášení nezaručují detekci kanálu, ve kterém platba selhala, proto
  nebude možné vysokou dostupnost signalizovat a používat na zcela libovolném základě
  (tedy bez široké dohody). Signalizování by tedy měl být pro zachování kompatibility
  specifikováno, i když ho nakonec bude používat jen velmi málo uzlů.

  Matt Corallo [odpověděl][corallo lnqos], že hledání tras v LN funguje
  v současnosti dobře a odkázal na [podrobný dokument][ldk path] popisující
  hledání tras v LDK: rozšiřuje způsob původně popsaný René Pickhardtem
  a Stefanem Richterem (viz [zpravodaj č. 163][news163 pr paper], _angl._,
  a [dva body][news270 ldk2547] ve [zpravodaji č. 270][news270 ldk2534]).
  Obává se ale, že QoS příznak bude nabádat budoucí software k implementaci
  méně spolehlivého hledání tras a k používání pouze vysoce dostupných kanálů.
  V takovém případě by mohly velké uzly uzavírat s vlastníky svých velkých
  kanálů dohody o dočasném používání likvidity založeném na důvěře, pokud
  se kanál vyčerpá. Malé uzly závislé na kanálech bez požadavku na důvěru
  budou muset používat drahý [JIT rebalancing][topic jit routing] – jejich
  kanály budou vydělávat méně (pokud náklady pohltí) nebo budou méně žádané
  (pokud náklady přenesou na plátce).

  Jager a Corallo v diskuzi pokračovali bez jasného závěru.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Vydáno Ark Wallet SDK:**
  [Ark Wallet SDK][ark sdk github] je typescriptová knihovna pro budování peněženek
  s podporou onchain bitcoin a [Ark][topic ark] protokolu v [testnetu][topic testnet],
  [signetu][topic signet], [Mutinynetu][new252 mutinynet] a mainnetu (zatím se
  nedoporučuje).

- **Zaprite přidává podporu pro BTCPay Server:**
  Bitcoinový a lightningový platební integrátor [Zaprite][zaprite website] přidává
  BTCPay Server na svůj seznam podporovaných systémů.

- **Vydána desktopová Iris Wallet:**
  [Iris Wallet][iris github] podporuje posílání, přijímání a vydávání aktiv pomocí
  protokolu [RGB][topic client-side validation].

- **Vydán Sparrow 2.1.0:**
  Sparrow [verze 2.1.0][sparrow 2.1.0] kromě jiných změn nahrazuje předchozí [HWI][topic hwi]
  implementaci [Larkem][news333 lark] a přidává podporu pro [PSBTv2][topic psbt].

- **Vydán Scure-btc-signer 1.6.0:**
  Vydání [Scure-btc-signer][scure-btc-signer github] verze [1.6.0][scure-btc-signer 1.6.0]
  přidává podporu pro v3 transakce ([TRUC][topic v3 transaction relay]) a pro
  [pay-to-anchors (P2A)][topic ephemeral anchors]. Scure-btc-signer je součástí sady
  knihoven [scure][scure website].

- **Py-bitcoinkernel alpha:**
  [Py-bitcoinkernel][py-bitcoinkernel github] je pythonová knihovna pro interakci
  s [libbitcoinkernel][Bitcoin Core #27587], knihovnou, která [zapouzdřuje validační
  logiku Bitcoin Core][kernel blog].

- **Rust-bitcoinkernel library:**
  [Rust-bitcoinkernel][rust-bitcoinkernel github] je experimentální knihovnou pro
  používání libbitcoinkernel k načítání a validaci bloků a ověřování výstupů transakcí.

- **BIP32 cbip32 library:**
  Knihovna [cbip32][cbip32 library] implementuje [BIP32][] v C s použitím libsecp256k1
  a libsodium.

- **Lightning Loop přechází na MuSig2:**
  Služba Lightning Loop poskytující atomické výměny nově používá [MuSig2][topic musig],
  jak popisuje [nedávný blogový příspěvek][loop blog].

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #27432][] přidává pythonový skript, který převádí serializovanou
  množinu UTXO vygenerovanou RPC příkazem `dumptxoutset` (navržený pro
  [AssumeUTXO][topic assumeutxo] snapshoty) na SQLite3 databázi. I když byla
  zvažována integrace exportu do SQLite3 přímo do RPC příkazu, nakonec byla
  kvůli zvýšené zátěži na údržbu zavržena. Skript nevyžaduje žádné dodatečné
  závislosti a výsledná databáze má zhruba dvojnásobnou velikost oproti serializaci.

- [Bitcoin Core #30529][] opravuje chování negovaných voleb jako
  `noseednode`, `nobind`, `nowhitebind`, `norpcbind`, `norpcallowip`,
  `norpcwhitelist`, `notest`, `noasmap`, `norpcwallet`, `noonlynet` a
  `noexternalip`. Dříve způsobilo negování těchto voleb zmatečné a nedokumentované
  vedlejší efekty, nyní jednoduše vrací volby na jejich výchozí hodnoty.

- [Bitcoin Core #31384][] řeší problém, kdy 4 000 váhových jednotek (WU) rezervovaných
  na hlavičku bloku, počet transakcí a mincetvornou transakci bylo neúmyslně
  počítáno dvakrát, čímž byla snížena maximální velikost šablony bloku o nadbytečných
  4 000 WU na 3 992 000 WU (viz [zpravodaj č. 336][news336 weightbug]). Kromě
  samotné opravy přináší změna novou volbu `-blockreservedweight`, která
  uživatelům umožní rezervovanou váhu nastavit. Bitcoin Core se nespustí pokud
  není nastavena na hodnotu mezi 2 000 WU and 4 000 000 WU.

- [Core Lightning #8059][] nebude v pluginu `xpay` (viz [zpravodaj č. 330][news330
  xpay]) používat [platbu s více cestami][topic multipath payments] (multipath payment,
  MPP), pokud [BOLT11][] faktura neindikuje její podporu. Stejná logika bude
  rozšířena i na [BOLT12][topic offers] faktury, ale bude muset počkat na příští vydání,
  neboť toto PR také umožňuje předat pluginům funkcionalitu aktivovanou v BOLT12 fakturách
  (např. právě možnost použít MPP pro její placení).

- [Core Lightning #7985][] přidává podporu pro placení [BOLT12][topic offers]
  faktur v pluginu `renepay` (viz [zpravodaj č. 263][news263 renepay]). Umožňuje
  routování [zaslepeným cestami][topic rv routing] a interně nahrazuje používání
  `sendpay` příkazem `sendonion`.

- [Core Lightning #7887][] přidává podporu pro používání nových [BIP353][] polí
  pro překlad čitelných jmen (Human Readable Name resolution, HRN), aby odpovídal
  posledním aktualizacím BOLTů (viz zpravodaje [č. 290][news290 hrn] a [č. 333][news333
  hrn]). PR dále do faktur přidává pole `invreq_bip_353_name`, vynucuje omezení
  v přicházejících BIP353 jmenných polích a umožňuje uživatelům používat
  BIP353 jména v RPC `fetchinvoice`.

- [Eclair #2967][] přidává podporu protokolu `option_simple_close` dle specifikace
  v [BOLTs #1205][]. Tato zjednodušená varianta protokolu vzájemného uzavření kanálu
  je potřebná pro [jednoduché taprootové kanály][topic simple taproot channels].
  Umožňuje uzlům během `shutdown`, `closing_complete` a `closing_sig` bezpečnou výměnu
  noncí, které jsou potřeba pro [MuSig2][topic musig].

- [Eclair #2979][] ověřuje před pokusem o přeposlání [trampolínové platby][topic trampoline
  payments], že následující přímé spojení podporuje probuzení pomocí notifikace
  (viz [zpravodaj č. 319][news319 wakeup]). U standardních plateb není tato
  kontrola nutná, neboť [BOLT11][] i [BOLT12][topic offers] faktury již příznak podpory
  těchto notifikací obsahují.

- [Eclair #3002][] pro navýšení spolehlivosti přidává sekundární mechanismus
  zpracovávání bloků a jejich transakcí, které mohou spustit návazné procesy.
  To je obzvláště důležité v případě utracení kanálu, kdy uzel neviděl příslušnou
  transakci v mempoolu před tím, než ji obdržel v bloku. Běžně to má na starosti
  ZMQ a jeho topic `rawtx`, ale při používání vzdáleného `bitcoind` může být
  nespolehlivé a může tiše zahazovat zprávy. U každého nově nalezeného bloku
  tento sekundární systém vyžádá posledních N bloků (6 ve výchozím nastavení)
  a jeho transakce zpracuje znovu.

- [LDK #3575][] implementuje protokol [peer storage][topic peer storage], který uzlům
  umožňuje ukládat protistranám svých kanálů jejich zálohy. Přináší dva nové typy
  zpráv `PeerStorageMessage` a `PeerStorageRetrievalMessage` a metody pro jejich
  zpracování. Data jsou uložena v `PeerState` v `ChannelManager`u.

- [LDK #3562][] přidává novou funkci hodnocení výkonu (viz [zpravodaj č. 308][news308 scorer]),
  která z externích zdrojů slučuje výkonové testy založené na častém
  [sondování][topic payment probes] skutečných platebních cest. Díky
  tomu mohou lehké uzly, které mají omezený přehled o síti, použít data
  poskytnutá např. poskytovateli lightningových služeb (Lightning Service Provider,
  LSP) a navýšit tím úspěšnost plateb. Data z externích zdrojů mohou být
  s místními sloučena nebo je mohou zcela nahradit.

- [BOLTs #1205][] začleňuje protokol `option_simple_close`, který je zjednodušenou
  variantou protokolu vzájemného uzavření kanálu vyžadovanou pro [jednoduché
  taprootové kanály][topic simple taproot channels]. Změny se týkají
  [BOLT2][] a [BOLT3][].

{% include snippets/recap-ad.md when="2025-02-25 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27432,30529,31384,8059,7985,7887,2967,2979,3002,3575,3562,1205,27587" %}
[news239 qos]: /cs/newsletters/2023/02/22/#priznak-vysoke-dostupnosti-pro-ln
[news163 pr paper]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[news270 ldk2547]: /cs/newsletters/2023/09/27/#ldk-2547
[news270 ldk2534]: /cs/newsletters/2023/09/27/#ldk-2534
[teinturier mobileclose]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453
[teinturier mobileclose2]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453/3
[jager lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438
[corallo lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438/4
[ldk path]: https://lightningdevkit.org/blog/ldk-pathfinding/
[news330 xpay]: /cs/newsletters/2024/11/22/#core-lightning-7799
[news263 renepay]: /cs/newsletters/2023/08/09/#core-lightning-6376
[news290 hrn]: /cs/newsletters/2024/02/21/#citelne-bitcoinove-platebni-instrukce-zalozene-na-dns
[news333 hrn]: /cs/newsletters/2024/12/13/#bolts-1180
[news319 wakeup]: /cs/newsletters/2024/09/06/#eclair-2865
[news308 scorer]: /cs/newsletters/2024/06/21/#ldk-3103
[ark sdk github]: https://github.com/arklabshq/wallet-sdk
[new252 mutinynet]: /cs/newsletters/2023/05/24/#mutinynet-oznamil-novy-signet-pro-testovani
[zaprite website]: https://zaprite.com
[iris github]: https://github.com/RGB-Tools/iris-wallet-desktop
[sparrow 2.1.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.1.0
[news333 lark]: /cs/newsletters/2024/12/13/#vydano-javovske-hwi
[scure-btc-signer github]: https://github.com/paulmillr/scure-btc-signer
[scure-btc-signer 1.6.0]: https://github.com/paulmillr/scure-btc-signer/releases
[scure website]: https://paulmillr.com/noble/#scure
[py-bitcoinkernel github]: https://github.com/stickies-v/py-bitcoinkernel
[rust-bitcoinkernel github]: https://github.com/TheCharlatan/rust-bitcoinkernel
[kernel blog]: https://thecharlatan.ch/Kernel/
[cbip32 library]: https://github.com/jamesob/cbip32
[loop blog]: https://lightning.engineering/posts/2025-02-13-loop-musig2/
[news336 weightbug]: /cs/newsletters/2025/01/10/#zkoumani-nastaveni-tezebnich-poolu-pred-opravenim-chyby-bitcoin-core
