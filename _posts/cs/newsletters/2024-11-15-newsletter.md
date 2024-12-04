---
title: 'Zpravodaj „Bitcoin Optech” č. 329'
permalink: /cs/newsletters/2024/11/15/
name: 2024-11-15-newsletter-cs
slug: 2024-11-15-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje nový protokol offchain vyrovnávání plateb
a odkazuje na články o možném sledování a cenzurování LN plateb na úrovni
IP. Též nechybí naše pravidelné rubriky s oznámeními nových vydání (včetně
oprav kritických bezpečnostních chyb v BTCPay Server) a popisem významných
změn v populárním bitcoinovém páteřním software.

## Novinky

- **Protokol pro offchain vyrovnávání plateb založený na MAD:** John Law
  zaslal do fóra Delving Bitcoin [příspěvek][law opr] s popisem mikroplatebního
  protokolu, který od obou účastníků vyžaduje přispět do finančního závazku,
  který může být kterýmkoliv účastníkem snadno zničen. Tím je v zájmu
  obou si navzájem vycházet vstříc, neboť by jinak riskovali vzájemně
  zaručené zničení (mutually assured destruction, MAD) závazku.

  Toto schéma se liší od ideálního _protokolu bez požadavku na důvěru_, kde
  v případě porušení protokolu přichází o prostředky pouze škodící strana.
  Avšak v praxi tyto protokoly vyžadují od poškozené strany zaplatit
  poplatek za onchain transakci, aby mohla své prostředky získat zpět.
  Law na základě této skutečnosti prezentuje některé výhody protokolu
  založeného na MAD:

  - V případě zničení prostředků je použito výrazně méně prostoru na
    blockchainu, což zvyšuje škálovatelnost.

  - Jelikož není tento protokol založen na globálním konsenzu, může
    vynucovat expirace trvající i zlomky sekundy oproti minimálně
    několika blokům. Law poskytuje příklad zaručeného dokončení
    platby (úspěchem či selháním) za méně než deset sekund v porovnání
    s LN, která v současnosti potřebuje na vyrovnání platby v nejhorším
    případě až dva týdny.

  - V případě dlouhé odmlky v komunikaci mezi stranami nevyžaduje MAD
    protokol po žádné z nich odeslání dat na blockchain (je v zájmu
    obou stran tak nečinit, neboť by jinak ztratili svou část finančního
    závazku). V protokolu typu [LN-Penalty][topic ln-penalty] musí
    být v případě selhání komunikace nevyřízená [HTLC][topic htlc]
    poslána na blockchain.

    Law zdůrazňuje, že díky tomu může být offchain vyrovnávání plateb
    uvnitř [továrny kanálů][topic channel factories], [expiračního
    stromu][topic timeout trees] či jiné vnořené struktury, která by
    ideálně držela vnořenou část offchain, mnohem efektivnější.

  Matt Morehouse [odpověděl][morehouse opr], že snaha vycházet vstříc
  může logicky vést k pomalé krádeži. Na příklad Mallory tvrdí, že Bob
  neprovedl úspěšně operaci, která měla hodnotu pěti procent finančního
  závazku. Bob si není jist, ale zaplatit Mallorymu pět procent je lepší,
  než ztratit 50 % závazku, proto vyhoví. Mallory proces opakuje. Tento
  problém je umocněn neschopností prokázat v obvyklých komunikačních
  sítích vinu: pokud Mallory a Bob ztratí kontakt na dostatečně dlouhou
  dobu, že dojde k selhání, mohou se obviňovat navzájem až do vzájemného
  zničení. Morehouse dále poznamenává, že tento protokol vyžaduje vyčlenění
  většího množství prostředků na finanční závazek, což může mít negativní
  dopad na UX. Uživatele i dnes mate _rezerva kanálu_ dle [BOLT2][], která
  jim zabraňuje utratit více než 99 % zůstatku v kanálu.

  Diskuze v době psaní zpravodaje nadále pokračovala.

- **Články o cenzuře LN plateb na IP vrstvě:** Charmaine Ndolo
  zaslal do fóra Delving Bitcoin [příspěvek][ndolo censor] se souhrnem
  [dvou][atv revelio] nedávných [článků][nt censor] o narušeném soukromí
  LN plateb a možnosti je cenzurovat. Články poznamenávají, že metadata
  TCP/IP paketů obsahujících zprávy LN protokolu, jako je počet paketů
  a celkové množství dat, napomáhají k odhadování druhu těchto zpráv
  (např. nové [HTLC][topic htlc]). Útočník, který má kontrolu nad sítí
  používanou několika uzly, může odpozorovat přeposílání zpráv mezi uzly.
  Pokud útočník zároveň ovládá jeden z těchto uzlů, dozví se některé
  informace o přeposílaných zprávách (např. hodnoty plateb nebo že se jedná
  o [onion zprávu][topic onion messages]). To může být použito k selektivnímu
  zabraňování úspěšného vyrovnání plateb či k zabraňování rychlého selhání,
  čímž by hrozilo onchain vynucené zavření kanálu.

  V době psaní neobdržel příspěvek žádnou reakci.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BTCPay Server 2.0.3][] a [1.13.7][btcpay server 1.13.7] jsou údržbová vydání,
  která obsahují kritické bezpečností opravy pro uživatele určitých pluginů
  a funkcí. Pro podrobnosti prosíme navštivte poznámky k vydání.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #30592][] odstraňuje konfigurační volbu `mempoolfullrbf`, která
  uživatelům umožňuje deaktivovat [full RBF][topic rbf] a vrátit se k volitelnému
  RBF. Jelikož je dnes full RBF široce používáno, nepřináší jeho deaktivace žádné
  výhody. Proto byla volba odstraněna. Full RBF bylo nedávno aktivováno ve výchozím
  nastavení (viz [zpravodaj č. 315][news315 fullrbf]).

- [Bitcoin Core #30930][] přidává do výstupu příkazu `netinfo` sloupec se službami
  a do nastavení jeho filtrů volbu `outonly` pro zobrazování pouze odchozích spojení.
  Nový sloupec služeb zobrazuje služby podporované jednotlivými spojeními:
  kompletní data blockchainu (n), [bloom filtry][topic transaction bloom filtering] (b),
  [segwit][topic segwit] (w), [kompaktní filtry][topic compact block filters]
  (c), omezená data blockchainu na posledních až 288 bloků (l), [P2P transportní protokol
  verze 2][topic v2 p2p transport] (2). Dále byly učiněny úpravy některých textů
  nápovědy.

- [LDK #3283][] implementuje [BIP353][]. Přidává podporu pro platby zaslané na základě
  čitelných instrukcí z DNS, které jsou přeloženy na [BOLT12][] [nabídky][topic offers]
  dle specifikace v [BLIP32][]. Do `ChannelManager` je přidána nová metoda
  `pay_for_offer_from_human_readable_name`, která uživatelům umožní zahájit platbu
  přímo na čitelný identifikátor. PR dále přidává nový stav `AwaitingOffer` a nový
  balíček `lightning-dns-resolver` pro [BLIP32][] dotazy. [Zpravodaj č. 324][news324
  blip32] popisuje související PR.

- [LND #7762][] mění výsledek několika RPC příkazů volaných s `lncli`. Nově budou
  namísto prázdných odpovědí vracet stavové zprávy, aby bylo zřejmé, že byl příkaz
  vykonán úspěšně. Změna se týká těchto příkazů: `wallet releaseoutput`,
  `wallet accounts import-pubkey`, `wallet labeltx`, `sendcustom`, `connect`,
  `disconnect`, `stop`, `deletepayments`, `abandonchannel`, `restorechanbackup`
  a `verifychanbackup`.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30592,30930,3283,7762" %}
[law opr]: https://delvingbitcoin.org/t/a-fast-scalable-protocol-for-resolving-lightning-payments/1233
[morehouse opr]: https://delvingbitcoin.org/t/a-fast-scalable-protocol-for-resolving-lightning-payments/1233/2
[ndolo censor]: https://delvingbitcoin.org/t/research-paper-on-ln-payment-censorship/1248
[atv revelio]: https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=10190502
[nt censor]: https://drops.dagstuhl.de/storage/00lipics/lipics-vol316-aft2024/LIPIcs.AFT.2024.12/LIPIcs.AFT.2024.12.pdf
[btcpay server 2.0.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.3
[btcpay server 1.13.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.13.7
[news315 fullrbf]: /cs/newsletters/2024/08/09/#bitcoin-core-30493
[news324 blip32]: /cs/newsletters/2024/10/11/#ldk-3179
