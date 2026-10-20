---
title: 'Zpravodaj „Bitcoin Optech” č. 407'
permalink: /cs/newsletters/2026/05/29/
name: 2026-05-29-newsletter-cs
slug: 2026-05-29-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje zodpovědné nahlášení zranitelnosti, která
vzdálenému spojení umožňovala shodit Core Lightning uzly, a odkazuje na
přepisy nedávného setkání vývojářů Bitcoin Core. Též nechybí naše pravidelné
rubriky s oznámeními nových vydání a s popisem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Odhalení DoS zranitelnosti v Core Lightning:** Chandra Pratap zaslal do fóra
  Delving Bitcoin [příspěvek][cln dos delving] s odhalením zranitelnosti
  způsobující odepření služby objevené během Summer of Bitcoin 2025. Zranitelnost
  postihuje uzly Core Lightning, které přijímají příchozí kanály.

  Během úvodní výměny informací pro otevření kanálů posílá protistrana zprávu
  s txid navrhované otevírací transakce. Core Lightning provádí assert kontrolu, zda
  je toto txid nenulové. Pokud uzel obdržel nulové txid, tato kontrola ho shodila.
  Jelikož proces otevírání kanálu může začít kterékoliv peer spojení,
  umožňovalo to vzdálenému útočníkovi spolehlivě shodit kterýkoliv zranitelný
  uzel, který příchozí kanály akceptoval.

  Zranitelnost byla [zodpovědně nahlášena][topic responsible disclosures] a byla
  objevena pomocí fuzz testování. V době nahlášení pracoval Rusty Russell nezávisle
  na jiném problému pádu uzlu a jeho oprava též shodou okolností opravila tuto
  zranitelnost. Opravena byla v [Core Lightning 26.04][news402 cln2604].

- **Přepisy setkání vývojářů Bitcoin Core:** v květnu se osobně setkalo množství
  vývojářů Bitcoin Core. Přepisy ze setkání byly [zveřejněny][coredev 2026-05].
  Diskutovanými tématy byly mimo jiné [SwiftSync][coredev swiftsync], [doba po mempoolu clusterů][coredev post-cluster],
  [nový design Erlay][coredev erlay], [přeposílání balíčků][coredev pkg relay],
  [tiché platby][coredev silent payments], [TCP hole punching][coredev tcp holepunch]
  (viz též [zpravodaj č. 406][news406 tcp holepunch]),
  [soukromé odesílání transakcí][coredev private broadcast], [moderní kryptografická
  knihovna][coredev modern crypto] a [mutační testování][coredev mutation
  testing].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Eclair v0.14.0][] je nejnovějším vydáním této populární implementace LN uzlu.
  Obsahuje finální verze [splicingu][topic splicing], [jednoduchých taprootových
  kanálů][topic simple taproot channels] a [commitmentů s nulovými
  poplatky][topic v3 commitments], odstraňuje podporu kanálů s ne[anchor výstupy][topic
  anchor outputs] a přidává experimentální hodnocení peer spojení pro
  optimalizaci likvidity a trasování.

- [Core Lightning 26.06rc2][] je kandidátem na vydání příští hlavní verze tohoto
  populárního LN uzlu. Obsahuje nová RPC volání `graceful`, `sendamount` a `xkeysend`,
  započíná cyklus zastarání příkazu `pay` ve prospěch `xpay` a přidává podporu
  pro [BOLT12][topic offers] dokladů o platbě.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #33966][] mění způsob nakládání s volbami šablon bloků
  pro těžbu v IPC rozhraní Mining (viz též zpravodaje [č. 310][news310 mining]
  a [č. 323][news323 mining]). Dříve byly volby spuštění jako `blockmaxweight`,
  `blockreservedweight` a `blockmintxfee` zpracovávány odděleně od běhových
  voleb, které byly předány těžebními klienty přes IPC. Nově jsou tyto volby
  přidány do sdíleného objektu `BlockCreateOptions` během vytváření
  nebo změn šablon. Nevalidní kombinace (např. rezervovaná váha bloku
  převyšující maximální váhu) jsou nyní odmítány, místo aby byly v tichosti
  upraveny do validního rozsahu.

- [Bitcoin Core #34917][] přestává v odpovědích na RPC `listtransactions`, `listsinceblock`
  a `gettransaction` vracet zastaralé pole `bip125-replaceable`. Uživatelé
  si však toto pole mohou nadále vyžádat pomocí volby `-deprecatedrpc=bip125`.
  PR dále zastarává volbu spuštění `-walletrbf`, která nově vypíše varování.
  Volba bude odstraněna v příštím vydání. [Zpravodaj č. 403][news403 rbf] (_angl._)
  popisuje jiná, dříve odstraněná pole související s [RBF][topic rbf].

- [Bitcoin Core #35017][] mění proces odesílání [balíčků][topic package relay] tak,
  aby pozdější transakce nezůstaly po neočekávané chybě validace v mempoolu.
  Během odesílání balíčku jsou transakce zpracovávány postupně, což pozdějším
  transakcím umožňuje utrácet dřívější transakce, které již byly přidány
  do mempoolu. Pokud dříve některá z transakcí neprošla pozdější validací
  (např. kontrolou skriptu dle konsenzu), Bitcoin Core z mempoolu odstranil
  pouze tu jednu transakci. Nově též odstraní všechny transakce umístěné
  v balíčku za ní. Tím zabrání, aby v mempoolu zůstávali potomci transakcí,
  jejichž předkové již byli odstraněni.

- [BIPs #1944][] přidává [BIP449][], pracovní verzi návrhu na soft fork
  pro přidání `OP_TWEAKADD`. Jedná se o [tapscriptový][topic tapscript] opkód
  pro počítání tweaknutého veřejného klíče pouze s x-ovou (x-only) souřadnicí
  (viz též [zpravodaj č. 370][news370 tweak], _angl._). Mějme 32bajtový
  veřejný x-only klíč `P` a 32bajtový skalár `t` (tweak), potom opkód přidá do zásobníku
  x-only klíč `P + tG`. To by skriptům umožnilo napřímo vytvářet konstrukce jako
  skripty odhalující tweak, doklady o pořadí podepisování nebo protokoly
  [delegace podepisování][topic signer delegation].

- [BIPs #2108][] přidává [BIP450][] (Formosa), pracovní verzi specifikace
  kódování entropie peněženek v podobě krátkých vět.
  Namísto používání náhodných BIP39 slov používá Formosa seznamy slov
  definované tématem. Pro kódování entropie převede slova na krátké
  strukturované věty. Tyto krátké povídky mohou být dekódovány zpět
  do původní entropie a převedeny na standardní BIP39 frázi. Tím
  zaručuje soulad s [BIP39][].

- [Eclair #3192][] přidává experimentální podporu pro kanály s [commitmenty
  s nulovými poplatky][topic v3 commitments] (zero-fee commitment, 0FC)
  dle specifikace popsané ve [zpravodaji č. 404][news404 0fc]. Funkce je
  ve výchozím nastavení neaktivní, zapnuta může být volbou
  `eclair.features.zero_fee_commitments = optional`.

- [LDK #4584][] přidává `payment_metadata` do [BOLT12][topic offers] zaslepených
  zpráv a do kontextu platebních cest. Jedná se o základ pro přenášení příjemcových
  metadat skrz [zaslepené cesty][topic rv routing] a jejich získání při přijetí
  platby. Koncept je podobný `payment_metadata` v [BOLT11][]. Vytváření faktur
  s metadaty zatím není podporováno. Metadata jsou uložena jako mapa číselných
  klíčů a bajtových polí jako hodnot, čímž může být k jedné platbě připojeno
  více druhů dat.

- [LDK #4628][] začíná šifrovat `payment_metadata` v [BOLT11][]  během vytváření
  příchozích plateb. Tato změna staví na zavazování metadat, které popisuje
  [zpravodaj č. 405][news405 metadata]. Po ověření platby LDK metadata dešifruje,
  čímž plátci dává možnost data napřímo přečíst.

- [LND #10552][] přidává rychlou úvodní synchronizaci pro LND uzly používající
  [Neutrino][topic compact block filters] tím, že umožňuje ze souborů nebo
  HTTP zdrojů importovat předem připravené hlavičky bitcoinových bloků a kompaktní
  filtry. Nové volby `neutrino.blockheaderssource` a `neutrino.filterheaderssource`
  musí být nastavené dohromady. Importované hlavičky jsou lokálně zvalidovány
  a poté Neutrino od peer spojení stáhne všechny hlavičky, které v importu chybí.

- [LND #10820][] znemožňuje LND během otevírání veřejných kanálů automaticky volit
  [jednoduché taprootové kanály][topic simple taproot channels], protože
  taprootová [oznámení o kanálu][topic channel announcements] ještě nejsou
  podporována. Dříve je mohlo LND zvolit, pokud obě strany jejich podporu
  inzerovaly, avšak samotné otevření potom selhalo. Nyní musí být jednoduché
  taprootové kanály výslovně vyžádány (jinak bude zvolen kanál staršího druhu
  se statickým vzdáleným klíčem nebo [anchor][topic anchor outputs] kanál).
  PR dále upravuje  `lncli openchannel --channel_type=taproot`, aby zvolil
  produkční druh jednoduchých taprootových kanálů.

{% include snippets/recap-ad.md when="2026-06-02 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33966,34917,35017,3192,4584,4628,10552,10820,2108,1944" %}
[cln dos delving]: https://delvingbitcoin.org/t/vulnerability-disclosure-assertion-dos-in-core-lightning/2507
[news402 cln2604]: /cs/newsletters/2026/04/24/#core-lightning-26-04
[coredev 2026-05]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05
[coredev swiftsync]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/swiftsync
[coredev post-cluster]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/post-cluster-mempool
[coredev erlay]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/erlay-redesign
[coredev pkg relay]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/package-relay
[coredev silent payments]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/silent-payments
[coredev tcp holepunch]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/tcp-holepunch
[news406 tcp holepunch]: /cs/newsletters/2026/05/22/#tcp-hole-punching-pro-bitcoinove-uzly-za-natem
[coredev private broadcast]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/private-broadcast
[coredev modern crypto]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/modern-crypto-library
[coredev mutation testing]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/mutation-testing
[Eclair v0.14.0]: https://github.com/ACINQ/eclair/releases/tag/v0.14.0
[Core Lightning 26.06rc2]: https://github.com/ElementsProject/lightning/releases/tag/v26.06rc2
[news310 mining]: /cs/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /cs/newsletters/2024/10/04/#bitcoin-core-30510
[news403 rbf]: /en/newsletters/2026/05/01/#bitcoin-core-34911
[news404 0fc]: /cs/newsletters/2026/05/08/#bolts-1228
[news405 metadata]: /cs/newsletters/2026/05/15/#ldk-4528
[news370 tweak]: /en/newsletters/2025/09/05/#draft-bip-for-op-tweakadd
