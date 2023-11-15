---
title: 'Zpravodaj „Bitcoin Optech” č. 275'
permalink: /cs/newsletters/2023/11/01/
name: 2023-11-01-newsletter-cs
slug: 2023-11-01-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme pokračování několika nedávných diskuzí o návrzích
změn bitcoinového skriptovacího jazyka. Též nechybí naše pravidelné rubriky
s oznámeními nových vydání a popisem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Diskuze o změnách ve skriptu pokračují:** do diskuzí v emailové skupině
  Bitcoin-Dev, kterým jsme se věnovali dříve, přibylo několik nových reakcí.

    - *Výzkum kovenantů:* Anthony Towns zaslal [odpověď][towns cov]
      na [příspěvek][russell cov] od Rustyho Russella, který jsme [zmínili][news274
      cov] v minulém čísle. Towns porovnává Russellův přístup s jinými přístupy – zaměřenými
      zvláště na [úschovny][topic vaults] založené na [kovenantech][topic covenants]
      – a považuje ho za neatraktivní. V následující [odpovědi][russell cov2] Russell
      poznamenává, že pro úschovny existují různé návrhy a že jsou úschovny
      v porovnání s jinými druhy transakcí neoptimální. Dále vyvozuje, že
      optimalizace není pro uživatele úschoven kritická. Tvrdí, že návrh úschoven
      dle [BIP345][] je vhodnější jako formát adres spíše než soubor opkódů.
      Podle našeho soudu tento výrok znamená, že BIP345 dává větší smysl jako
      šablona (podobně jako P2WPKH) navržená pro jednu funkci než jako soubor
      opkódů, který je navržen pro tu jednu funkci, ale který má možnost
      spolupracovat se zbytkem skriptu potenciálně nepředpokládanými způsoby.

      Towns rovněž uvažuje nad použitím Russellova přístupu jako způsobu,
      jak obecně umožnit experimentování, a myslí si, že je „sice zajímavější
      […], ale pořád dost kulhá.” Připomíná čtenářům svůj předešlý návrh
      na alternativu bitcoinového Scriptu ve stylu Lispu (viz [zpravodaj č.
      191][news191 lisp], _angl._) a ukazuje, jak by mohl přinést větší
      flexibilitu a možnosti v provádění introspekce transakcí během
      vyhodnocování witnessů. Poskytuje odkazy na svůj testovací kód a
      ukazuje na příklady, které napsal. Russell odpověděl: „Stále
      věřím, že než ho budeme muset nahradit, existuje prostor pro zlepšení.
      Je těžké porovnávat belhající se [S]cript v dnešní podobě s
      alternativami, protože ty nejzajímavější případy jsou nemožné.“

      Towns a Russel též v krátkosti hovořili o [OP_CHECKSIGFROMSTACK][topic
      op_checksigfromstack], jmenovitě o jeho schopnosti umístit autentizovaná
      data od orákulí přímo do zásobníku.

    - *Návrh na OP_CAT:* několik lidí odpovědělo na [příspěvek][heilman cat]
      od Ethana Heilmana oznamující návrh BIPu na [OP_CAT][], který jsme
      minulý týden rovněž [zmínili][news274 cat].

      Po několika reakcích zmiňujících otázku, zda by nebyl `OP_CAT`
      příliš omezovaný 520bytovým limitem na velikost prvků v zásobníku,
      [popsal][todd 520] Peter Todd způsob, kterým lze budoucím soft forkem
      navýšit limit bez použití dodatečných `OP_SUCCESSx` opkódů. Nevýhodou
      je, že všechna použití `OP_CAT` by před navýšením vyžadovala přidání
      několika již dostupných opkódů do skriptu navíc.

      Ještě před odpovědí Anthonyho Townse na Russellův výzkum kovenantů
      zaslal James O'Beirne [příspěvek][o'beirne vault], ve kterém zmiňuje
      důležitá omezení `OP_CAT` pro použití v úschovnách. Konkrétně jmenuje
      několik vlastností, které `OP_CAT`, na rozdíl od BIP345 úschoven, postrádá.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LDK 0.0.118][] je nejnovějším vydáním této knihovny pro budování LN
  aplikací. Obsahuje vedle dalších nových funkcí a oprav chyb i částečnou
  experimentální podporu protokolu [nabídek][topic offers].

- [Rust Bitcoin 0.31.1][] je nejnovějším vydáním této knihovny pro práci
  s bitcoinovými daty. Pro seznam nových funkcí a oprav chyb viz [poznámky
  k vydání][rb rn].

_Poznámka:_ Bitcoin Core 26.0rc1, který jsme zmínili v předešlém čísle,
má ve zdrojovém kódu svůj štítek, avšak binární sestavení nebyla zveřejněna
kvůli změně od Apple, která zabraňuje vytvoření reprodukovatelných binárek
pro macOS. Vývojáři Bitcoin Core pracují na odstranění problému v rámci
druhého kandidáta na vydání.

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28685][] opravuje chybu ve výpočtu hashe množiny UTXO, kterou
  jsme zmínili v [předchozím čísle][news274 hash bug]. Obsahuje nekompatibilní
  změnu v RPC volání `gettxoutsetinfo`, ve kterém nahrazuje pole `hash_serialized_2`
  novým polem `hash_serialized_3` obsahujícím správný hash.

- [Bitcoin Core #28651][] umožňuje [miniscriptu][topic miniscript] přesněji
  odhadovat nejvyšší počet bytů, které bude nutné začlenit do struktury
  witnessu, aby mohl být [taprootový][topic taproot] výstup utracen.
  Zvýšená přesnost pomůže Bitcoin Core zabránit přeplácení na poplatcích.

- [Bitcoin Core #28565][] staví nad [#27511][Bitcoin Core #27511] a přidává
  RPC volání `getaddrmaninfo` zobrazující počet adres spojení, která jsou
  buď „new” (nová) nebo „tried” (vyzkoušená), seskupených dle sítě (IPv4, IPv6,
  Tor, I2P, CJDNS). Pro motivaci, která stojí za tímto členěním, viz [zpravodaj
  č. 237][news237 pr review] a [podcast č. 237][pod237 pr review].

- [LND #7828][] vyžaduje, aby spojení odpovídala na zprávy `ping`
  v rozumné době, jinak budou odpojena. Pomůže to zajistit, aby spojení
  zůstávala aktivní (což sníží pravděpodobnost, že by mrtvé spojení
  pozdrželo platbu a vynutilo si tak nežádoucí zavření kanálu). Existuje
  mnoho dalších výhod posílání pingů a pongů: mohou pomoci zastřít síťovou
  aktivitu, ztížit trasování plateb (jelikož ping, pong i platby jsou šifrované),
  pomáhají častěji obměňovat šifrovací klíče (viz [BOLT1][]) a LND používá
  zprávy `pong` k zabránění [útoků zastíněním][topic eclipse attacks] („eclipse
  attacks”, viz [zpravodaj č. 164][news164 pong], _angl._).

- [LDK #2660][] poskytuje volajícím více flexibility ve výběru jednotkového
  poplatku pro onhcain transakce, včetně nastavení pro absolutní minimum,
  nízký poplatek způsobující i více než den čekání na potvrzení, normální
  prioritu a zvýšenou prioritu.

- [BOLTs #1086][] stanovuje, že uzly by měly odmítnout (refundovat) HTLC a
  vrátit chybu `expiry_too_far`, pokud by instrukce pro vytvoření přeposílaného
  [HTLC][topic htlc] požadovaly, aby místní uzel čekal více než 2 016 bloků,
  než by si mohl nárokovat refundaci. Snížení tohoto nastavení redukuje nejhorší
  možnou ztrátu příjmu uzlu způsobenou [útokem zahlcením kanálu][topic channel
  jamming attacks] („channel jamming attack”) nebo dlouhotrvající [pozdrženou
  fakturou][topic hold invoices] („hold invoice”). Navýšení tohoto nastavení
  umožňuje platbám, aby byly přeposlány více kanály za použití nastavení stejných
  maximálních HTLC delta (nebo stejný počet skoků s vyšším maximálním HTLC delta,
  což může zlepšit obranu proti určitým útokům, jako je replacement cycling
  popsaný v [minulém čísle][news274 cycling]).

{% include references.md %}
{% include linkers/issues.md v=2 issues="28685,28651,28565,7828,2660,1086,27511" %}
[news164 pong]: /en/newsletters/2021/09/01/#lnd-5621
[towns cov]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022099.html
[russell cov]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022031.html
[news274 cov]: /cs/newsletters/2023/10/25/#vyzkum-obecnych-kovenantu-s-minimalnimi-zmenami-scriptu
[russell cov2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022103.html
[news191 lisp]: /en/newsletters/2022/03/16/#using-chia-lisp
[heilman cat]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022049.html
[news274 cat]: /cs/newsletters/2023/10/25/#navrh-bipu-pro-op-cat
[todd 520]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022094.html
[o'beirne vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022092.html
[Bitcoin Core 26.0rc1]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[bitcoin core developer wiki]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[news274 cycling]: /cs/newsletters/2023/10/25/#zranitelnost-replacement-cycling-postihujici-htlc
[ldk 0.0.118]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.118
[rust bitcoin 0.31.1]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.31.0
[rb rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/bitcoin/CHANGELOG.md#0311---2023-10-18
[news274 hash bug]: /cs/newsletters/2023/10/25/#nahrazeni-vypoctu-hashe-mnoziny-bitcoinovych-utxo
[news237 pr review]: /cs/newsletters/2023/02/08/#bitcoin-core-pr-review-club
[pod237 pr review]: /en/podcast/2023/02/09/#bitcoin-core-pr-review-club-transcript
