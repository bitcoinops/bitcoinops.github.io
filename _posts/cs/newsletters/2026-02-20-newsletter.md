---
title: 'Zpravodaj „Bitcoin Optech” č. 393'
permalink: /cs/newsletters/2026/02/20/
name: 2026-02-20-newsletter-cs
slug: 2026-02-20-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje diskuzi o využívání OP_RETURN výstupů v síti
a popisuje protokol pro vynucování podmínek utrácení podobných kovenantům
bez změn konsenzu. Též nechybí naše pravidelné rubriky s popisem nedávných
změn ve službách a klientském software, oznámeními nových vydání a
souhrnem nedávných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Statistika nedávných OP_RETURN výstupů**: Anthony Towns zaslal do fóra Delving
  Bitcoin [příspěvek][post op_return stats] o statistice OP_RETURN výstupů
  od vydání Bitcoin Core v30.0 10. října, které změnilo limity pravidel mempoolu
  pro OP_RETURN výstupy: umožňuje více OP_RETURN výstupů s až 100 kB dat.
  Rozsah zkoumaných bloků byl mezi výškami 915 800 a 936 000 s následujícími
  výsledky:

  - 24 362 310 transakcí s OP_RETURN výstupy

  - 61 transakcí s více OP_RETURN výstupy

  - 396 transakcí s celkovou velikostí OP_RETURN výstupních skriptů přesahující 83 bajtů

  - Celková velikost OP_RETURN výstupních skriptů byla 473 815 552 bajtů (z nichž velké
    OP_RETURN zaujímaly  0,44 %)

  - Bylo spáleno 1 463 488 sat v OP_RETURN výstupech v 34 283 transakcí

  - Bylo 949 003 transakcí s OP_RETURN daty mezi 43 a 83 bajty a
    23 412 911 transakcí s OP_RETURN daty s velikostí 42 bajtů nebo méně

  Towns dále připojil graf ukazující četnost velikostí mezi 396 transakcemi
  s velkými OP_RETURN výstupy. 50 % těchto transakcí mělo méně než 210 bajtů
  OP_RETURN dat. 10 % mělo méně než 10 kB OP_RETURN dat.

  Později dodal, že Murch nato zveřejnil na X [podobnou analýzu][murch twitter]
  a [dashboard][murch dashboard] OP_RETURN statistik a orangesurf zveřejnil
  [zprávu][orangesurf report] o OP_RETURN pro mempool research.

- **Bitcoin PIPEs V2**: Misha Komarov zaslal do fóra Delving Bitcoin
  [příspěvek][pipes del] o Bitcoin PIPEs. Jedná se o protokol, který umožňuje
  vynutit podmínky utrácení bez nutnosti změn konsenzu nebo mechanismu
  optimistické výzvy (optimistic challenge).

  Bitcoinový protokol je založen na modelu minimální validace transakcí. Validace
  ověřuje, že utrácení UTXO je autorizováno řádným digitálním podpisem. Bitcoin PIPEs
  nespoléhá na schopnost bitcoinového skriptu vyjadřovat podmínky utrácení,
  namísto toho přidává vstupní podmínky pro vytvoření validního podpisu.
  Jinými slovy, soukromý klíč je kryptograficky uzamčen za předem stanovenými
  podmínkami. Soukromý klíč pro vytvoření platného podpisu je odhalen pouze tehdy,
  pokud jsou tyto podmínky splněné. Veškerá logika těchto podmínek je zpracována
  offchain, bitcoinový protokol musí validovat pouze jediný [Schnorrův podpis][topic
  schnorr signatures].

  Na formální úrovni obsahuje Bitcoin PIPEs dvě hlavní fáze:

  - **Příprava**: Je vygenerován standardní pár bitcoinových klíčů `(sk, pk)`.
    `sk` je potom pomocí witness encryption zašifrován za podmínkou utrácení.

  - **Podepsání**: Pro výrok je poskytnut witness (svědek) `w`. Je-li `w` validní, odhalí
    se `sk` a může být vytvořen Schnorrův podpis. Vypočítání `sk` je jinak složité.

  Dle Komarova může být Bitcoin PIPEs použit k napodobení kovenantů. Konkrétně se
  [Bitcoin PIPEs V2][pipes v2 paper] soustředí na omezený rozsah podmínek utrácení,
  jimiž vynucuje binární kovenanty. Tento model přirozeně zachycuje širokou škálu
  užitečných podmínek, jejichž výstup je binární, např. poskytnutí validního
  dokladu s nulovou znalostí, uspokojení výstupní podmínky nebo existence dokladu
  o podvodu. Vše se v podstatě točí kolem jediné otázky: „Je podmínka splněna, nebo ne?”

  Nakonec Komarov poskytl reálné příklady, jak by mohl být PIPEs využit namísto nových
  opkódů a jak by mohl být použit k vylepšení procesu optimistické verifikace
  v protokolu [BitVM][topic acc].

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Second vydal arkový software založený na hArk:**
  Do knihoven pro [Ark][topic ark] od Second byla ve verzi
  [0.1.0-beta.6][second 0.1.0 beta6] přidána podpora pro hArk (hash-lock Ark).
  Nový protokol eliminuje potřebu synchronní interaktivity mezi účastníky
  kol. Vydání přineslo další aktualizace, včetně zpětně nekompatibilních změn.

- **Amboss ohlašuje RailsX:**
  [Ohlášení RailsX][amboss blog] popisuje platformu používající LN a
  [Taproot Assets][topic client-side validation] pro swaps a jiné finanční služby.

- **Nunchuk podporuje tiché platby:**
  Nunchuk [ohlásil][nunchuk post] podporu pro posílání na adresy [tichých
  plateb][topic silent payments].

- **Electrum přidává submarine swap:**
  [Electrum 4.7.0][electrum release notes] umožňuje uživatelům platit onchain pomocí
  jejich lightningové peněženky (viz [submarine swaps][topic submarine swaps]). Vydání
  obsahuje i další novinky a opravy chyb.

- **Ohlášen Sigbash v2:**
  [Sigbash v2][sigbash post] nyní používá pro zvýšení soukromí během kooperativního
  podepisování [MuSig2][topic musig], WebAssembly
  (WASM) a doklady s nulovou znalostí. Naše [dřívější zmínka][news298 sigbash]
  obsahuje více informací.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BTCPay Server 2.3.5][] je menším vydáním tohoto platebního procesoru
  s možností vlastního hostování. Přidává widgety zobrazující zůstatky
  v peněženkách různých kryptoměn, nastavitelné textové pole při platbě,
  nové poskytovatele směnných kurzů a opravy několika chyb.

- [LND 0.20.1-beta][] je údržbovým vydáním této populární implementace LN uzlu.
  Přidává zotavení po panice během zpracování gossip zpráv, zlepšuje ochranu
  před reorganizacemi, implementuje heuristiku detekce LSP a opravuje
  několik chyb a souběhů.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #33965][] opravuje chybu, kdy volba `-blockreservedweight`
  předaná při spouštění (viz [zpravodaj č. 342][news342 weight]) mohla tiše
  přebít hodnotu `block_reserved_weight` nastavenou Mining IPC klienty
  (viz [zpravodaj č. 310][news310 mining]). Nově bude mít nastavení
  od IPC klientů přednost. Pro RPC klienty, které nikdy tuto hodnotu
  nenastavují, je vždy používána hodnota z `-blockreservedweight`.
  Tato změna také pro IPC klienty vynucuje `MINIMUM_BLOCK_RESERVED_WEIGHT`,
  čímž jim brání nastavit hodnotu pod tento práh.

- [Eclair #3248][] upřednostňuje během přeposílání [HTLCs][topic htlc]
  soukromé kanály před veřejnými v případě, že jsou dostupné obě možnosti.
  Tím zachovává více likvidity ve veřejných, viditelných kanálech.
  Pokud mají dva kanály shodnou viditelnost, Eclair upřednostní kanál
  s nižším zůstatkem.

- [Eclair #3246][] přidává nová pole několika interním událostem:
  `TransactionPublished` rozděluje pole `miningFee` na
  `localMiningFee` a `remoteMiningFee`, přidává vypočítaný `feerate`
  a volitelný `LiquidityAds.PurchaseBasicInfo` spojující transakci
  s [nákupem likvidity][topic liquidity advertisements]. Události
  životního cyklu kanálů nově obsahují `commitmentFormat` popisující
  druh kanálu. `PaymentRelayed` přidává pole `relayFee`.

- [LDK #4335][] přidává úvodní podporu pro platby fiktivním uzlům
  (phantom node payments, viz [zpravodaj č. 188][news188 phantom], _angl._)
  pomocí [BOLT12 nabídek][topic offers]. Ve verzi pro [BOLT11][] obsahují
  faktury návrhy tras ukazující na neexistující (phantom) uzel, kde
  poslední skok každé cesty je skutečným uzlem, který umí přijmout
  [bezstavové faktury][topic stateless invoices]. S [BOLT12][]
  nabídka jednoduše obsahuje více [zaslepených cest][topic rv routing],
  které končí v dotyčných uzlech. Současná implementace umožňuje
  více uzlům odpovědět na žádost o fakturu, i když výsledná faktura
  je splatná pouze uzlu, který odpověděl.

- [LDK #4318][] odstraňuje ze struktury `ChannelHandshakeLimits` pole
  `max_funding_satoshis`, čímž odstraňuje omezení výchozí velikosti kanálu
  z doby před [velkými (wumbo) kanály][topic large channels]. LDK
  ve výchozím nastavení podporu pro velké kanály již oznamovalo
  v příznaku `option_support_large_channels`, který mohl být v konfliktu
  s předchozím nastavením. Uživatelé, kteří chtějí omezit riziko, mohou
  kanály akceptovat manuálně.

- [LND #10542][] rozšiřuje grafovou databázi o podporu gossip protokolu
  v1.75 (viz zpravodaje [č. 261][news261 gossip] a [č. 326][news326 gossip]).
  LND nyní umožňuje ukládat a načítat [oznámení][topic channel announcements]
  pro [jednoduché taprootové kanály][topic simple taproot channels].
  Gossip v1.75 zůstává na síti deaktivovaný, dokud nebudou dokončeny subsystémy
  zpracovávající nové gossip zprávy.

- [BIPs #1670][] zveřejňuje [BIP360][], který specifikuje Pay-to-Merkle-Root
  (P2MR). Tento nový typ výstupu funguje jako [P2TR][topic taproot],
  ale neumožňuje platbu klíčem. P2MR výstupy jsou odolné vůči útokům
  kryptoanalyticky relevantními kvantovými počítači (CRQC) při dlouhodobé
  expozici (tedy v blockchainu), protože zavazují přímo Merkleovu kořenu
  stromu skriptů (SHA256 haši) a ne veřejnému klíči. Avšak ochrana proti
  útokům při krátkodobé expozici (např. získání soukromého klíče z nepotvrzené
  transakce) vyžaduje návrh na postkvantové podepisování. [Zpravodaj č. 344][news344
  p2qrh] návrh popisoval již dříve.

- [BOLTs #1236][] upravuje specifikaci [oboustranného financování][topic dual funding]
  (dual funding). Nově umožní kterémukoliv uzlu během zakládání kanálu
  zaslat zprávu `tx_init_rbf`, čímž umožní oběma stranám [navyšovat
  poplatky][topic rbf] otevírací transakce. Dříve tak mohla činit pouze
  strana, která otevření iniciovala. Tato změna je v souladu se [splicingem][topic
  splicing], kde mohla RBF zahájit kterákoliv strana. PR dále přidává
  požadavek, aby odesílatelé `tx_init_rbf` a `tx_ack_rbf` použili alespoň
  jeden vstup z dřívějšího pokusu, čímž zajistí, že transakce provede
  dvojí utracení všech předchozích pokusů.

- [BOLTs #1289][] mění způsob přeposílání `commitment_signed` během opakovaného
  připojování v protokolu interaktivních transakcí používaném v [oboustranném
  financování][topic dual funding] a [splicingu][topic splicing].
  Dříve byla zpráva `commitment_signed` vždy opakovaně odeslána po nově
  navázaném spojení, i pokud ji druhá strana již dříve obdržela.
  Nově obsahuje zpráva `channel_reestablish` bitové pole, které umožní uzlu
  vyžádat `commitment_signed`, pokud je potřeba. Díky tomu je možné
  vyvarovat se zbytečnému opakovanému posílání, což je obzvláště důležité
  pro budoucí [taprootové kanály][topic simple taproot channels], kde by opakované
  odeslání vyžadovalo kompletní kolo [MuSig2][topic musig] podepisování
  kvůli změně noncí.

{% include snippets/recap-ad.md when="2026-02-24 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33965,3248,3246,4335,4318,10542,1670,1236,1289" %}

[post op_return stats]: https://delvingbitcoin.org/t/recent-op-return-output-statistics/2248
[pipes del]: https://delvingbitcoin.org/t/bitcoin-pipes-v2/2249
[pipes v2 paper]: https://eprint.iacr.org/2026/186
[second 0.1.0 beta6]: https://docs.second.tech/changelog/changelog/#010-beta6
[amboss blog]: https://amboss.tech/blog/railsx-first-lightning-native-dex
[nunchuk post]: https://x.com/nunchuk_io/status/2021588854969414119
[electrum release notes]: https://github.com/spesmilo/electrum/blob/master/RELEASE-NOTES
[news298 sigbash]: /cs/newsletters/2024/04/17/#spusten-spravce-klicu-sigbash
[sigbash post]: https://x.com/arbedout/status/2020885323778044259
[BTCPay Server 2.3.5]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.5
[LND 0.20.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.1-beta
[news342 weight]: /cs/newsletters/2025/02/21/#bitcoin-core-31384
[news310 mining]: /cs/newsletters/2024/07/05/#bitcoin-core-30200
[news188 phantom]: /en/newsletters/2022/02/23/#ldk-1199
[news261 gossip]: /cs/newsletters/2023/07/26/#aktualizovana-oznameni-o-kanalech
[news326 gossip]: /cs/newsletters/2024/10/25/#aktualizace-navrhu-oznamovani-kanalu-verze-1-75
[news344 p2qrh]: /cs/newsletters/2025/03/07/#aktualizace-bip360-pay-to-quantum-resistant-hash-p2qrh
[murch dashboard]: https://dune.com/murchandamus/opreturn-counts
[murch twitter]: https://x.com/murchandamus/status/2022930707820269670
[orangesurf report]: https://research.mempool.space/opreturn-report/
