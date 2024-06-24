---
title: 'Zpravodaj „Bitcoin Optech” č. 308'
permalink: /cs/newsletters/2024/06/21/
name: 2024-06-21-newsletter-cs
slug: 2024-06-21-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje odhalení zranitelnosti postihující staré
verze LND a shrnuje pokračující diskuzi o PSBT pro tiché platby. Též nechybí
naše pravidelné rubriky s popisem nedávných změn ve službách a klientech,
s oznámeními nových vydání a souhrnem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Odhalení zranitelnosti postihující staré verze LND:** Matt
  Morehouse zaslal do fóra Delving Bitcoin [příspěvek][morehouse onion]
  s odhalením zranitelnosti postihující verze LND před 0.17.0.
  LN přeposílá platební instrukce a [onion zprávy][topic onion messages]
  pomocí onion-šifrovaných paketů, které obsahují více šifrovaných datových
  balíčků. Každý balíček obsahuje na začátku svou délku, která u plateb může mít
  [od roku 2019][news58 variable onions] až [1 300 bajtů][bolt4]. Onion zprávy,
  které byly představeny později, mohou mít až 32 768 bajtů. Avšak datový typ
  pro velikost dat umožňoval specifikovat velikost až 2<sup>64</sup> bajtů.

  LND akceptoval indikovanou velikost dat až 4 gigabajty a alokoval
  takové množství paměti ještě před dalším zpracováním dat. To bylo dostatečné
  na vyčerpání paměti některých LND uzlů, což způsobilo pád nebo ukončení
  operačním systémem. Postiženy byly i uzly s větším množstvím paměti, neboť
  podobných onion zpráv mohlo být posláno několik najednou. Pokud LN uzel
  spadne, nemůže odeslat časově citlivé transakce důležité pro ochranu
  finančních prostředků, což může potenciálně vést až k jejich krádeži.

  Zranitelnost byla opravena snížením maximální alokace paměti na 65 536 bajtů.

  Každý, kdo provozuje LND uzel, by měl aktualizovat na verzi 0.17.0 nebo novější.
  Upgradování na nejnovější verzi (0.18.0 v době psaní) je vždy doporučované.

- **Pokračuje diskuze o PSBT pro tiché platby:** několik vývojářů diskutuje
  o přidání podpory pro koordinaci posílání [tichých plateb][topic silent payments]
  pomocí [PSBT][topic psbt]. Od našeho [předchozího souhrnu][news304 sp-psbt]
  se diskuze soustředila na používání techniky, kde každý podepisující
  generuje _ECDH sdílený tajný kód_ a kompaktní doklad o jeho správném generování.
  Tyto části jsou přidány do PSBT sekce se vstupy. Po přijetí sdílených tajemství
  od všech podepisujících mohou být zkombinovány se skenovacím klíčem adresáta,
  čímž se získá aktuální klíč do výstupního skriptu (nebo více klíčů pro více
  výstupů v případě více tichých plateb v rámci jedné transakce).

  Poté, co jsou známy výstupní skripty transakce, přidá každý podepisující do PSBT
  svůj podpis. Celý proces podepisování PSBT tedy vyžaduje dvě kola (dodatečně k dalším
  cyklům potřebným pro jiné protokoly jako [MuSig2][topic musig]). Avšak bude-li
  celou transakci podepisovat pouze jedna strana (např. je-li PSBT posíláno do jednoho
  hardwarového podpisového zařízení), celý proces může být dokončen v jednom kole.

  Všichni účastníci diskuze se v době psaní víceméně shodovali na tomto
  přístupu, ačkoliv diskuze o okrajových případech stále probíhají.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Casa přidává podporu pro deskriptory:**
  Poskytovatel multisig služeb Casa ve svém [blogovém příspěvku][casa blog] oznámil podporu pro
  [deskriptory výstupních skriptů][topic descriptors].

- **Vydán Specter-DIY v1.9.0:**
  Vydání [v1.9.0][specter-diy v1.9.0] přidává mimo jiné podporu pro taprootový
  [miniscript][topic miniscript] a [BIP85][].

- **Ohlášen nástroj cargo-checkct pro analýzu konstantního času:**
  [Příspěvek][ledger cargo-checkct blog] v blogu Ledgeru ohlásil [cargo-checkct][cargo-checkct
  github], nástroj vyhodnocující, zda běží rustové kryptografické knihovny v
  konstantním čase, aby se vyhnuly [útokům postranními kanály][topic side channels].

- **Jade přidává podporu pro miniscript:**
  Hardwarové podpisové zařízení Jade [nově podporuje][jade tweet] miniscript.

- **Ohlášena implementace Arku:**
  Ark Labs [oznámil][ark labs blog] několik iniciativ kolem [protokolu Ark][topic
  ark] včetně [implementace][ark github] a [dokumentace pro vývojáře][ark developer hub].

- **Ohlášena beta verze Volt Wallet:**
  [Volt Wallet][volt github] podporuje deskriptory, [taproot][topic taproot],
  [PSBT][topic psbt] a další BIPy a Lightning.

- **Joinstr přidává podporu pro Electrum:**
  [Coinjoinový][topic coinjoin] software [joinstr][news214 joinstr] přidal [plugin][joinstr
  blog] pro Electrum.

- **Vydán Bitkit v1.0.1:**
  Bitkit [ohlásil][bitkit blog], že jejich bitcoinové a lightningové aplikace jsou k dispozici
  v app storech.

- **Ohlášena alfa verze Civkitu:**
  [Civkit][civkit tweet] je P2P obchodní platforma postavená na nostru a Lightning Network.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 26.2rc1][] je kandidátem na vydání údržbové verze Bitcoin Core pro uživatele,
  kteří nemohou upgradovat na poslední [verzi 27.1][bcc 27.1].

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #29325][] přináší ukládání verze transakcí jako bezznaménkového
  celého čísla. Od první verze bitcoinu 0.1 byly verze ukládány jako celé číslo
  se znaménkem. Soft fork [BIP68][] s nimi začal nakládat jako s bezznaménkovými,
  ale minimálně jedna implementace uzlu toto chování nepozměnila, což mohlo vyústit
  v možné selhání konsenzu (viz [zpravodaj č. 286][news286 btcd]). Tím, že Bitcoin
  Core bude vždy ukládat a používat verze transakcí jako bezznaménková celá čísla, se
  snad předejde podobných chybám i v budoucnosti.

- [Eclair #2867][] přidává novou variantu do výčtového typu `EncodedNodeId`, která bude
  v [zaslepených cestách][topic rv routing] přiřazována mobilním peněženkám. Díky tomu
  se může poskytovatel peněženky přizpůsobit situaci, že následující uzel je mobilní
  zařízení.

- [LND #8730][] přináší nový RPC příkaz `lncli wallet estimatefee`, který na základě cíle
  pro potvrzení vrátí [odhad poplatku][topic fee estimation] onchain transakce v sat/kw
  (satoshi za 1000 váhových jednotek) a sat/vbyte.

- [LDK #3098][] aktualizuje Rapid Gossip Sync (RGS) na v2, která rozšiřuje v1 o dodatečné
  položky obsažená v serializované struktuře. Nové položky obsahují bajt indikující počet
  výchozích schopností uzlu, pole schopností uzlu a soketovou adresu. Tato aktualizace
  je odlišná od navrhované aktualizace [BOLT7][] gossip protokolu, která se označuje
  podobně jako gossip v2.

- [LDK #3078][] přidává podporu pro asynchronní platby [BOLT12][topic offers] faktury.
  Pokud je zapnuta volba `manually_handle_bolt12_invoices`, LDK po přijetí faktury
  vygeneruje událost `InvoiceReceived`. Nová metoda `send_payment_for_bolt12_invoice`
  na `ChannelManager` může fakturu zaplatit. Díky tomu může být faktura před platbou
  či odmítnutím prozkoumána.

- [LDK #3082][] přináší podporu pro BOLT12 statické faktury (znovupoužitelné žádosti
  o platbu). Podpora zahrnuje jejich kódování a dekódování a rozhraní pro jejich
  konstrukci.

- [LDK #3103][] počíná v benchmarcích používat hodnocení výkonu na základě častých
  [sond][topic payment probes] skutečných platebních cest. Cílem je mít realističtější
  benchmarky.

- [LDK #3037][] začíná zavírat kanály, pokud by byl jejich jednotkový poplatek příliš nízký.
  LDK neustále monitoruje nejnižší přijatelné poplatky, které [algoritmus odhadu][topic fee
  estimation] vracel během posledního dne. V každém bloku zavře LDK kanál, který platí
  jednotkový poplatek nižší než minimum za uplynulý den. Cílem je „zajistit, aby poplatky
  kanálů byly vždy dostatečné na onchain potvrzování commitment transakcí, pokud bychom
  potřebovali kanál jednostranně uzavřít.”

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2867,8730,3098,3078,3082,3103,3037,29325" %}
[news304 sp-psbt]: /cs/newsletters/2024/05/24/#diskuze-o-psbt-pro-tiche-platby
[news58 variable onions]: /en/newsletters/2019/08/07/#bolts-619
[morehouse onion]: https://delvingbitcoin.org/t/dos-disclosure-lnd-onion-bomb/979
[bcc 27.1]: /cs/newsletters/2024/06/14/#bitcoin-core-27-1
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[news286 btcd]: /cs/newsletters/2024/01/24/#zverejneni-opraveneho-selhani-konsenzu-v-btcd
[casa blog]: https://blog.casa.io/introducing-wallet-descriptors/
[specter-diy v1.9.0]: https://github.com/cryptoadvance/specter-diy/releases/tag/v1.9.0
[cargo-checkct github]: https://github.com/Ledger-Donjon/cargo-checkct
[ledger cargo-checkct blog]: https://www.ledger.com/blog-cargo-checkct-our-home-made-tool-guarding-against-timing-attacks-is-now-open-source
[jade tweet]: https://x.com/BlockstreamJade/status/1790587478287814859
[ark labs blog]: https://blog.arklabs.to/introducing-ark-labs-a-new-venture-to-bring-seamless-and-scalable-payments-to-bitcoin-811388c0001b
[ark github]: https://github.com/ark-network/ark/
[ark developer hub]: https://arkdev.info/docs/
[volt github]: https://github.com/Zero-1729/volt
[news214 joinstr]: /en/newsletters/2022/08/24/#proof-of-concept-coinjoin-implementation-joinstr
[joinstr blog]: https://uncensoredtech.substack.com/p/tutorial-electrum-plugin-for-joinstr
[bitkit blog]: https://blog.bitkit.to/synonym-officially-launches-the-bitkit-wallet-on-app-stores-9de547708d4e
[civkit tweet]: https://x.com/gregory_nico/status/1800818359946154471
