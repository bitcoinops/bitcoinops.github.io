---
title: 'Zpravodaj „Bitcoin Optech” č. 328'
permalink: /cs/newsletters/2024/11/08/
name: 2024-11-08-newsletter-cs
slug: 2024-11-08-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje zranitelnost postihující staré verze
Bitcoin Core a připojuje pravidelné rubriky se souhrnem sezení
Bitcoin Core PR Review Clubu, s oznámeními nových vydání a s popisem
významných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Odhalení zranitelnosti postihující Bitcoin Core před verzí 25.1:**
  Antoine Poinsot [ohlásil][poinsot stall] v emailové skupině Bitcoin-Dev
  poslední odhalení zranitelnosti, které předchází vznik nových pravidel
  odhalování v Bitcoin Core (viz [zpravodaj č. 306][news306 disclosure]).
  [Podrobná zpráva][stall vuln] poznamenává, že ve verzích Bitcoin Core 25.0
  a starších bylo možné nevhodnou odpovědí v P2P protokolu zpozdit vyžádání
  bloku uzlem až o 10 minut. Řešením bylo umožnit, aby byly bloky „vyžadovány
  zároveň od maximálně tří vysokorychlostních spojení nabízejících kompaktní
  bloky, z nichž jedno musí být odchozí.” Oprava je obsažena ve verzi 25.1
  a novějších.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Dočasný prach][review club 30239] (Ephemeral Dust) je PR od uživatele
[instagibbs][gh instagibbs], které standardizuje transakce s dočasným prachem
a tím zlepšuje použitelnost anchorů s klíčem i bez něj ([P2A][topic
ephemeral anchors]). To je užitečné pro několik schémat offchain kontraktů včetně
Lightning Network, [Arku][topic ark], expiračních stromů a dalších konstruktů
s vysokým počtem předem podepsaných transakcí nebo chytrých kontraktů s vysokým
počtem účastníků.

Se změnou pravidel pro dočasný prach je možné do mempoolu připustit transakce s nulovým
poplatkem a [neekonomickým výstupem][topic uneconomical outputs] (prachem), pokud
je znám nějaký validní [potomek platící poplatek][topic cpfp] (CPFP), který okamžitě
tento prach utrácí.

{% include functions/details-list.md
  q0="Je prach omezován konsenzem, pravidly nebo oběma?"
  a0="Výstupy s prachem jsou omezovány pouze pravidly, konsenzus se jich netýká."
  a0link="https://bitcoincore.reviews/30239#l-27"

  q1="Jaké problémy může prach způsobovat?"
  a1="Neekonomické výstupy (tj. výstupy s prachem) mají hodnotu nižší, než
  kolik je za jejich utracení potřeba zaplatit na poplatcích. Jelikož je možné
  je utratit, nemohou být odstraněny z množiny UTXO. Jelikož je jejich
  utracení neekonomické, často zůstávají neutracené a navyšují tak velikost
  množiny UTXO. Vetší množina UTXO zvyšuje uzlu požadavky na jeho zdroje.
  Tato UTXO však i nadále utracena být mohou z důvodů jiných, než je jejich
  nominální hodnota, jako je na příklad v případě [anchor výstupů][topic anchor
  outputs]."
  a1link="https://bitcoincore.reviews/30239#l-40"

  q2="Proč je přívlastek ‚dočasný’ důležitý? Jaká pravidla jsou pro dočasný
  prach navrhována?"
  a2="Přívlastek ‚dočasný’ znamená, že výstup s prachem by měl být utracen
  rychle. Pravidla pro dočasný prach vyžadují, aby rodičovská transakce měla
  nulový poplatek a měla jediného potomka, který tento prach utrácí."
  a2link="https://bitcoincore.reviews/30239#l-50"

  q3="Proč je důležité stanovit tento požadavek na poplatek?"
  a3="Cílem je zabránit výstupům s prachem, aby po potvrzení zůstaly
  neutracené. Díky požadavku na nulový poplatek rodičovské transakce
  nebudou mít těžaři zájem na vytěžení rodiče bez jeho potomka. Jelikož
  je dočasný prach pravidlo a není součást konsenzu, ekonomické podněty
  hrají zásadní roli."
  a3link="https://bitcoincore.reviews/30239#l-56"

  q4="Jak s dočasným prachem souvisí 1P1C přeposílání a TRUC transakce?"
  a4="Jelikož musí mít transakce s dočasným prachem nulový poplatek,
  nemůže být přeposlána samotná. Proto je mechanismus [1 rodič, 1 potomek (1P1C)][28.0
  integration guide] zásadní. TRUC (v3) transakce jsou omezené na jediného
  nepotvrzeného rodiče, což je v souladu na požadavky dočasného prachu.
  TRUC je v současnosti jediným způsobem, jak umožnit šíření transakcí
  s jednotkovým poplatkem pod [`minrelaytxfee`][topic default minimum transaction
  relay feerates]."
  a4link="https://bitcoincore.reviews/30239#l-59"

%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 27.2][] je údržbovou aktualizací předchozí série, které přináší
  opravy chyb. Pokud neplánujete brzký upgrade na poslední verzi [28.0][], měli
  byste zvážit aktualizaci přinejmenším na toto údržbové vydání.

- [Libsecp256k1 0.6.0][] je vydáním této knihovny bitcoinových kryptografických
  funkcí. „Vydání přidává modul [MuSig2][topic musig], přidává výrazně robustnější
  způsob odstraňování tajných dat ze zásobníku a odstraňuje nepoužívané funkce
  `secp256k1_scratch_space`.”

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [LDK #3360][] přidává opakované šíření zpráv `channel_announcement`
  každých šest bloků po dobu jednoho týdne po potvrzení veřejného kanálu.
  Přestává tak spoléhat na svá spojení, že zprávu budou šířit. Též tím
  zajistí, že kanály budou vždy viditelné v síti.

- [LDK #3207][] přináší připojování požadavků na fakturu do [onion zprávy][topic
  onion messages] [asynchronních plateb][topic async payments], pokud odesílatel,
  který je vždy online, platí statické [BOLT12][topic offers] faktury. Tato schopnost
  chyběla v PR popsaném ve [zpravodaji č. 321][news321 invreq], týká se též opakovaných
  pokusů (viz [zpravodaj č. 321][news321 retry]).

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3360,3207" %}
[news306 disclosure]: /cs/newsletters/2024/06/07/#nadchazejici-odhaleni-zranitelnosti-postihujicich-stare-verze-bitcoin-core
[stall vuln]: https://bitcoincore.org/en/2024/11/05/cb-stall-hindering-propagation/
[poinsot stall]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uJpfg8UeMOfVUATG4YRiGmyz5MALtZq68FCBXA6PT-BNstodivpqQfDxD1JAv5Qny_vuNr-A1m8jIDNHQLhAQt8hj8Ee9OT6ZFE5Z16O97A=@protonmail.com/
[bitcoin core 27.2]: https://bitcoincore.org/en/2024/11/04/release-27.2/
[28.0]: https://bitcoincore.org/en/2024/10/02/release-28.0/
[libsecp256k1 0.6.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.6.0
[news321 invreq]: /cs/newsletters/2024/09/20/#ldk-3140
[news321 retry]: /cs/newsletters/2024/09/20/#ldk-3010
[review club 30239]: https://bitcoincore.reviews/30239
[gh instagibbs]: https://github.com/instagibbs
[28.0 integration guide]: /cs/bitcoin-core-28-wallet-integration-guide/
