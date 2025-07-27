---
title: 'Zpravodaj „Bitcoin Optech” č. 359'
permalink: /cs/newsletters/2025/06/20/
name: 2025-06-20-newsletter-cs
slug: 2025-06-20-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje návrh na omezení veřejné účasti
v repozitářích Bicoin Core, oznamuje významné zlepšení kontraktů
ve stylu BitVM a shrnuje výzkum rebalancování LN kanálů. Též nechybí
naše pravidelné rubriky se souhrnem nedávných změn ve službách
a klientech, oznámeními nových vydání a popisem významných změn
v populárním bitcoinovém páteřním software.

## Novinky

- **Návrh na zpřísnění přístupu do diskuzí v Bitcoin Core Project:**
  Bryan Bishop zaslal do emailové skupiny Bitcoin-Dev [příspěvek][bishop priv]
  s návrhem, aby Bitcoin Core Project omezil možnost veřejnosti
  účastnit se diskuzí v projektu. Cílem je snížit množství
  narušování pořádku způsobeného nepřispěvateli. Nazval to „privatizací Bitcoin
  Core.” Poukazuje na příklady podobné privatizace, která se děje
  v soukromých kancelářích s více přispěvateli, avšak varuje, že
  privatizace v osobních setkáních vylučuje přispěvatele pracující
  na dálku.

  Bishopův příspěvek navrhuje metodu online privatizace, avšak
  Antoine Poinsot [pochybuje][poinsot priv], zda by jeho metoda dosáhla
  cíle. Poinsot se též domnívá, že mnoho diskuzí se může odehrávat
  v soukromých kancelářích ne ze strachu z veřejné kritiky, ale kvůli
  „přirozeným výhodám diskutování osobně.”

  Někteří reagující se domnívají, že velké změny nejsou teď pravděpodobně
  odůvodněné, ale přísnější moderování komentářů v repozitáři by mohlo
  zmírnit nejčastější druh narušování. Jiné odpovědi však poukázaly
  na obtíže přísnějšího moderování.

  Poinsot, Sebastian „The Charlatan” Kung a Russell Yanofsky – jediní
  výrazně aktivní přispěvatelé do Bitcoin Core, kteří se v době psaní
  zpravodaje debaty účastnili – [naznačili][kung priv], že buď se
  [nedomnívají][yanofsky priv], že jsou velké změny nutné, nebo že by
  jakékoliv změny měly proběhnout postupně.

- **Vylepšení kontraktů ve stylu BitVM:** Robin Linus zaslal do fóra
  Delving Bitcoin [příspěvek][linus bitvm3] s oznámením výrazné redukce
  množství onchain prostoru vyžadovaného kontrakty typu [BitVM][topic acc].
  Nápad je založen na [myšlence][rubin garbled] Jeremyho Rubina,
  která staví na nových kryptografických primitivech. Nový přístup
  „snižuje onchain náklady řešení rozporů více než tisíckrát
  v porovnání s předchozím designem.” Zpochybňující transakce mají
  „pouze 200 bajtů.”

  Linusův článek však poznamenává, že přístup „vyžaduje několikaterabajtovou
  přípravu offchain.” Článek poskytuje příklad SNARKového obvodu pro
  ověřování se zhruba pěti miliardami hradel a dostatečnými bezpečnostními
  parametry, který na úvod vyžaduje pět terabajtů offchain dat, 56kB
  onchain transakci pro oznámení výsledku a minimální onchain transakci
  (kolem 200 bajtů) v případě, kdy některá strana potřebuje doložit,
  že výsledek byl nevalidní.

- **Výzkum rebalancování kanálů:** René Pickhardt zaslal do fóra Delving
  Bitcoin [příspěvek][pickhardt rebalance] s myšlenkou na rebalancování
  kanálů pro maximalizaci počtu úspěšných plateb v celé síti.
  Nápad lze porovnat s podobnými, které nahlížejí pouze na menší
  skupiny kanálů, například [friend-of-a-friend rebalancing][topic jit routing]
  (viz [zpravodaj č. 54][news54 foaf rebalance], _angl._).

  Pickhardt poznamenává, že v případě celé sítě existuje několik
  složitých problémů a klade zájemcům několik otázek, mimo jiné
  zda-li má smysl v tomto přístupu pokračovat či jak řešit některé
  implementační detaily.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Vydán Cove v1.0.0:**
  Nedávné [vydání][cove github] Cove obsahuje podporu výběru mincí a
  dodatečné funkce štítků peněženek dle [BIP329][].

- **Vydána Liana v11.0:**
  Nedávné [vydání][liana github] Liany obsahuje mimo jiné možnost mít několik peněženek,
  dodatečné funkce výběru mincí a podporu více hardwarových podpisových zařízení.

- **Ukázka dokladu Stratum v2 STARK:**
  StarkWare [ukázal][starkware tweet], jak jejich [upravený těžební Stratum
  v2 klient][starkware sv2] používá STARK doklady k prokázání, že poplatky
  z bloku patří validní šabloně bloku, aniž by odhalil jeho transakce.

- **Breez SDK přidává BOLT12 a BIP353:**
  Breez SDK Nodeless [0.9.0][breez github] přidává podporu pro příjem
  pomocí [BOLT12][] a [BIP353][].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 25.05][] je vydáním hlavní verze této oblíbené implementace
  LN uzlu. Snižuje latenci přeposílání a urovnání plateb, zlepšuje správu
  poplatků, poskytuje podporu [splicingu][topic splicing] kompatibilní
  s Eclairem a ve výchozím stavu má aktivovaný [peer storage][topic peer storage].
  Poznámka: [dokumentace k vydání][core lightning 25.05] obsahuje varování
  pro uživatele konfigurační volby `--experimental-splicing`.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Eclair #3110][] prodlužuje čekací dobu, než označí kanál za zavřený po
  utracení zakládajícího výstupu, ze 12 (viz [zpravodaj č. 337][news337 delay])
  na 72 bloků dle specifikace v [BOLTs #1270][]. Tato změna umožní propagaci
  [splicu][topic splicing]. Čekací doba byla navýšena, protože některé implementace
  čekají ve výchozím stavu na osm konfirmací, než odešlou `splice_locked`, a
  umožňují provozovatelům tento práh navýšit. 12 bloků se proto ukázalo jako
  nedostatečných. Čekací doba je pro testovací účely konfigurovatelná
  a umožňuje provozovatelům čekat déle.

- [Eclair #3101][] přináší RPC volání `parseoffer`, které dekóduje pole [BOLT12
  nabídek][topic offers] do čitelného formátu. Tím umožní uživatelům prohlédnout
  částku před tím, než nabídku předají volání `payoffer`. To navíc nově může
  akceptovat částku specifikovanou ve fiat měně.

- [LDK #3817][] stahuje podporu [informací o původci chyb][topic attributable
  failures] (attributable failures, viz [zpravodaj č. 349][news349 attributable])
  a schovává ji za testovací příznak. Tím bude logika penalizací spojení neaktivní
  a příslušné TLV odstraněno z [onion zpráv][topic onion messages]. Uzly, které
  zatím neupgradovaly, byly nesprávně penalizované. Ukázalo se tak, že širší
  osvojení sítí je pro správnou funkci potřebné.

- [LDK #3623][] rozšiřuje [peer storage][topic peer storage] (viz [zpravodaj č. 342][news342
  peer]) o automatické rozesílání šifrovaných záloh. Po každém bloku zabalí
  `ChainMonitor` příslušná data do `OurPeerStorage`. Nato data zašifruje a
  vyvolá událost `SendPeerStorage`, po které se data zprávou `peer_storage`
  rozešlou druhým stranám všech kanálů. `ChannelManager` také nově umí
  zpracovat `peer_storage_retrieval` požadavky.

- [BTCPay Server #6755][] zlepšuje uživatelské rozhraní výběru mincí o nový filtr
  nejmenší a nejvyšší částky a data, přidává filtrům nápovědu, zaškrtávací políčko
  pro výběr všech UTXO a volbu velikosti stránky (100, 200 či 500 UTXO).

- [Rust libsecp256k1 #798][] dokončuje implementaci [MuSig2][topic musig], čímž
  nabízí klientským projektům přístup k robustnímu protokolu [bezskriptových
  vícenásobných podpisů][topic multisignature].

{% include snippets/recap-ad.md when="2025-06-24 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3110,3101,3817,3623,6755,1270" %}
[Core Lightning 25.05]: https://github.com/ElementsProject/lightning/releases/tag/v25.05
[bishop priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CABaSBax-meEsC2013zKYJnC3phFFB_W3cHQLroUJcPDZKsjB8w@mail.gmail.com/
[poinsot priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/4iW61M7NCP-gPHoQZKi8ZrSa2U6oSjziG5JbZt3HKC_Ook_Nwm1PchKguOXZ235xaDlhg35nY8Zn7g1siy3IADHvSHyCcgTHrJorMKcDzZg=@protonmail.com/
[kung priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/58813483-7351-487e-8f7f-82fb18a4c808n@googlegroups.com/
[linus bitvm3]: https://delvingbitcoin.org/t/garbled-circuits-and-bitvm3/1773
[rubin garbled]: https://rubin.io/bitcoin/2025/04/04/delbrag/
[pickhardt rebalance]: https://delvingbitcoin.org/t/research-update-a-geometric-approach-for-optimal-channel-rebalancing/1768
[rust libsecp256k1 #798]: https://github.com/rust-bitcoin/rust-secp256k1/pull/798
[news54 foaf rebalance]: /en/newsletters/2019/07/10/#brainstorming-just-in-time-routing-and-free-channel-rebalancing
[yanofsky priv]: https://github.com/bitcoin-core/meta/issues/19#issuecomment-2961177626
[cove github]: https://github.com/bitcoinppl/cove/releases
[liana github]: https://github.com/wizardsardine/liana/releases
[breez github]: https://github.com/breez/breez-sdk-liquid/releases/tag/0.9.0
[starkware tweet]: https://x.com/dimahledba/status/1935354385795592491
[starkware sv2]: https://github.com/keep-starknet-strange/stratum
[news337 delay]: /cs/newsletters/2025/01/17/#eclair-2936
[news349 attributable]: /cs/newsletters/2025/04/11/#ldk-2256
[news342 peer]:/cs/newsletters/2025/02/21/#ldk-3575
