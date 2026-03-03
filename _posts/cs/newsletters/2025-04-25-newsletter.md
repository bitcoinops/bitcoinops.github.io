---
title: 'Zpravodaj „Bitcoin Optech” č. 351'
permalink: /cs/newsletters/2025/04/25/
name: 2025-04-25-newsletter-cs
slug: 2025-04-25-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje nový protokol pro agregaci podpisů
kompatibilní s secp256k1 a popisuje standardizovaný systém záloh pro
deskriptory peněženek. Též nechybí naše pravidelné rubriky se souhrnem
nedávných otázek a odpovědí z Bitcoin Stack Exchange, oznámeními
nových vydání a popisem významných změn v populárním páteřním bitcoinovém
software.

## Novinky

- **Interaktivní agregované podpisy kompatibilní s secp256k1:** Jonas
  Nick, Tim Ruffing, Yannick Seurin zaslali do emailové skupiny Bitcoin-Dev
  [příspěvek][nrs dahlias] s ohlášením jejich [článku][dahlias paper] o
  64bajtových agregovaných podpisech kompatibilních s již používanými
  kryptografickými primitivy. Agregované podpisy jsou nezbytností
  pro [agregaci podpisů napříč vstup][topic cisa] (cross-input signature
  aggregation, CISA). Tato navrhovaná funkcionalita by mohla snížit
  velikost transakcí s více vstupy, což by snížilo náklady na používání
  mimo jiné i [coinjoinů][topic coinjoin] a [payjoinů][topic payjoin],
  tedy systémů pro navýšení soukromí.

  Kromě schématu na agregaci podpisů, jako je DahLIAS navržený zmíněnými
  autory, by přidání podpory pro CISA do bitcoinu vyžadovalo změnu
  konsenzu. Dále bude potřeba zkoumat i možné interakce mezi agregací
  podpisů a jinými navrženými změnami konsenzu.

- **Standardizované zálohování deskriptorů peněženek:** Salvatore Ingala
  zaslal do fóra Delving Bitcoin [příspěvek][ingala backdes] s popisem
  kompromisů během zálohování [deskriptorů][topic descriptors] peněženek.
  Dále popsal návrh schématu, který by měl být užitečný pro mnoho
  rozličných druhů peněženek včetně těch používajících složité skripty.
  Jeho schéma šifruje deskriptory pomocí deterministicky generovaného
  32bajtového tajného klíče. Pro každý veřejný klíč (nebo rozšířený
  veřejný klíč) v deskriptoru je kopie tajného klíče xorována s určitou
  variantou tohoto veřejného klíče, což vytvoří _n_ 32bajtových
  „šifrovaných” tajných klíčů při _n_ veřejných klíčích. Kdokoliv se znalostí
  jednoho z těchto veřejných klíčů použitých v deskriptorech ho může
  xorovat s 32bajtovým „šifrovaným” tajným klíčem a získat tak 32bajtový
  tajný klíč, který může deskriptor dešifrovat. Toto jednoduché a efektivní
  schéma umožňuje komukoliv uložit množství zašifrovaných kopií deskriptoru
  napříč médii a lokacemi a poté – v případě ztráty dat peněženky –
  vygenerovat pomocí [BIP32 seedu][topic bip32] xpub a deskriptory dešifrovat.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Praktičnost poloagregovaných Schnorrových podpisů?]({{bse}}125982)
  Fjahr diskutuje, proč nejsou nezávislé neagregované podpisy pro validaci
  poloagregovaných podpisů v [agregaci podpisů napříč vstupy][topic cisa]
  (cross-input signature aggregation, CISA) vyžadovány a proč jsou neagregované
  podpisy ve skutečnosti problematické.

- [Jaká je vůbec největší vytvořená OP_RETURN zpráva?]({{bse}}126131)
  Vojtěch Strnad [odkazuje][op_return tx] na transakci [metaprotokolu][topic
  client-side validation] Runes se 79 870 bajty, která obsahuje největší `OP_RETURN`.

- [Vysvětlení pay-to-anchor bez odkazování na LN?]({{bse}}126098)
  Murch popisuje motivace a strukturu [pay-to-anchor (P2A)][topic
  ephemeral anchors] výstupních skriptů.

- [Aktualizované statistiky reorganizací řetězce?]({{bse}}126019)
  0xb10c a Murch odkazují na zdroje dat o reorganizacích včetně repozitáře
  [stale-blocks][stale-blocks github] a stránek [forkmonitor.info][] a [fork.observer][].

- [Jsou ligthningové kanály vždy P2WSH?]({{bse}}125967)
  Polespinasa poznamenává, že probíhá vývoj P2TR [jednoduchých taprootových kanálů][topic
  simple taproot channels], a shrnuje aktuální podporu mezi implementacemi.

- [Child-pays-for-parent jako obrana proti dvojímu utracení?]({{bse}}126056)
  Murch vyjmenovává komplikace s používáním [CPFP][topic cpfp] potomka s vysokým poplatkem
  jako incentivy pro reorganizaci blockchainu ve snaze o nápravu
  již potvrzeného dvojitě utraceného výstupu.

- [Jaké hodnoty hašuje CHECKTEMPLATEVERIFY?]({{bse}}126133)
  Average-gray vypisuje pole, kterým  [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] zavazuje: nVersion, nLockTime, počet vstupů,
  haš sekvencí, počet výstupů, haš výstupů, index vstupu a někdy haš scriptSigu.

- [Proč nemohou lightningové uzly dobrovolně odhalit zůstatky v kanálu pro lepší routování?]({{bse}}125985)
  Rene Pickhardt vysvětluje obavy o neaktuálnosti a důvěryhodnosti těchto dat a
  dopady na soukromí a odkazuje na [podobný návrh][BOLTs #780] z roku 2020.

- [Vyžaduje kvantová odolnost hard fork nebo soft fork?]({{bse}}126122)
  Vojtěch Strnad nastiňuje přístup, kterým by mohlo být [kvantově rezistentní][topic quantum
  resistance] (PQC) schéma podepisování [aktivováno jako soft fork][topic soft
  fork activation], a jak by mohl hard fork nebo soft fork uzamknout kvantově slabé
  mince.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.19.0-beta.rc3][] je kandidátem na vydání tohoto oblíbeného LN uzlu.
  Jedním významným vylepšením, které by si zasloužilo důkladné testování, je
  nové schéma RBF navyšování poplatků během kooperativního zavření kanálu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #31247][] přidává podporu serializace a parsování [MuSig2][topic musig]
  [PSBT][topic psbt] polí dle specifikace v [BIP373][], čímž umožní peněženkám
  podepisovat a utrácet [MuSig2][topic musig] vstupy. Na straně vstupů jsou mezi
  těmito poli veřejné klíče účastníků a pro každého podepisujícího ještě veřejný nonce
  a částečný podpis. Na straně výstupů jsou to veřejné klíče účastníků nového UTXO.

- [LDK #3601][] přidává nový výčtový typ `LocalHTLCFailureReason` reprezentující standardní
  [BOLT4][] chybové kódy a několik dodatečných variant poskytujících uživatelům dodatečné
  informace.

{% include snippets/recap-ad.md when="2025-04-29 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31247,3601,780" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[nrs dahlias]: https://mailing-list.bitcoindevs.xyz/bitcoindev/be3813bf-467d-4880-9383-2a0b0223e7e5@gmail.com/
[dahlias paper]: https://eprint.iacr.org/2025/692.pdf
[ingala backdes]: https://delvingbitcoin.org/t/a-simple-backup-scheme-for-wallet-accounts/1607
[op_return tx]: https://mempool.space/tx/fd3c5762e882489a62da3ba75a04ed283543bfc15737e3d6576042810ab553bc
[stale-blocks github]: https://github.com/bitcoin-data/stale-blocks
[forkmonitor.info]: https://forkmonitor.info/nodes/btc
[fork.observer]: https://fork.observer/
