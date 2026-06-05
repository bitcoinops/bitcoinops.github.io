---
title: 'Zpravodaj „Bitcoin Optech” č. 408'
permalink: /cs/newsletters/2026/06/05/
name: 2026-06-05-newsletter-cs
slug: 2026-06-05-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje nápady na kvantové zabezpečení šifrovaného
přenosu dle BIP324 a popisuje návrh na standardizaci podepisování
pomocí QR kódů pro miniscriptové peněženky. Též nechybí naše pravidelné
rubriky se souhrnem návrhů a diskuzí o změnách pravidel bitcoinového
konsenzu, s oznámeními nových vydání a s popisem významných změn
v populárním bitcoinovém páteřním software.

## Novinky

- **Kudy k postkvantovému BIP324**: Olaoluwa Osuntokun zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][pq bip324 ml] s úvahou o možných změnách [BIP324][] pro
  navýšení kvantové bezpečnosti. BIP324 přinesl do P2P protokolu
  [šifrovaný přenos][topic v2 p2p transport], čímž uživatelům během výměny zpráv
  zlepšuje zabezpečení a soukromí. Je navržen tak, aby úvodní navázání spojení
  i celkový provoz vypadaly pro vnější pozorovatele k nerozeznání od náhodných dat.
  Dle Osuntokuna nevyžaduje změna P2P protokolu širokou shodu jako změna konsenzu,
  mohlo by se tedy jednat o snazší první krok na cestě ke kvantově bezpečnému
  bitcoinu.

  Před návrhem formálního BIPu vyzval Osuntokun k diskuzi o dvou hlavních návrhových
  bodech. První z nich se týká výběru [mechanismu zapouzdření klíče][wiki kem]
  (Key-Encapsulation Mechanism, KEM): buď hybridní, nebo čistě postkvantový. Oba
  jsou založené na novém primitivu nazývaném modulový mřížkový KEM
  (Module-Lattice-based KEM, ML-KEM). Druhý návrhový bod řeší otázku, zda
  by mělo být úvodní navázání spojení i nadále nerozeznatelné od náhodných dat.

  K prvnímu bodu autor tvrdí, že hybridní přístup (kombinace současného ECDH
  a ML-KEM) by mohl nabídnout lepší záruky, jelikož by poskytoval
  ochranu i v případě, kdyby byl jeden z těchto dvou algoritmů prolomen.
  I když by ECDH mohl být prolomen budoucím kryptoanalyticky relevantním
  kvantovým počítačem (Cryptographically Relevant Quantum Computer, CRQC),
  kvantově bezpečné algoritmy ještě nejsou osvědčené širokým nasazením a
  mohly by obsahovat matematické slabiny.

  Ke druhému bodu Osuntokun poskytl možné alternativy, pokud bude potřeba
  zachovat nerozlišitelnost navázání spojení od náhodných dat. Prvním přístupem
  by bylo používat současné BIP324 navázání k otevření klasického kanálu,
  kterým by mohly strany vyjednat postkvantový kanál. Druhý přístup
  je založen na principu Outer Encrypts Inner Nested Combiner (OEINC),
  kde vnější KEM by šifroval jiný, vnitřní KEM, čímž by přinesl postkvantový
  kanál v jediném kroku.

- **Diskuze o podepisování QR kódem pro miniscriptové peněženky**: Pyth zaslal
  do fóra Delving Bitcoin [příspěvek][pyth delving qr] s návrhem na standardizaci
  formátu dat vyměňovaných mezi peněženkami a odpojenými podpisovými zařízeními
  pomocí QR kódů, pokud jsou používána [miniscriptová][topic miniscript] pravidla
  utrácení. I když stávající protokoly používající QR kódy zvládnou standardní
  _m_ z _n_ vícenásobné podpisy, pravidla miniscriptu vyžadují schopnosti, které
  současná schémata nenabízí. Jeho návrh definuje druh přenášených dat pro
  získávání xpub, registraci [deskriptoru][topic descriptors], ověřování
  adres a podepisování. Pyth žádá o poskytnutí zpětné vazby od vývojářů
  podpisových zařízení a peněženek.

## Diskuze o změnách konsenzu

_Měsíční rubrika shrnující návrhy a diskuze o změnách pravidel
bitcoinového konsenzu._

- **Ověření konceptu úschovny vyžadující pouze CTV**: Ademan ve fóru Delving Bitcoin
  [ohlásil][ademan delving mccv] vydání verze 0.1.0 jeho projektu [úschoven][topic vaults]
  s [CTV][topic op_checktemplateverify] ([BIP119][]) nazvaného [MCCV][mccv]
  (More Complicated CTV Vault). MCCV implementuje několik přístupů
  budování plnohodnotných úschoven (komplexnějších než [simple-ctv-vault][jamesob ctv vault]
  od Jamese O'Beirna, viz též [zpravodaj č. 191][news191 simple vault], _angl._)
  bez nutnosti složitějších opkódů jako `OP_VAULT` ([BIP345][]) nebo
  [`OP_CHECKCONTRACTVERIFY`][topic matt] ([BIP443][]). Konkrétně MCCV
  používá orientovaný acyklický graf (DAG) CTV transakcí pro vytvoření
  úschovny s jediným UTXO. To může existovat během mnoha interakcí předtím,
  než je ho nakonec možné utratit použitím klíčů pro obnovu (recovery).
  MCCV implementuje řízení četnosti požadavků (rate limiting) pomocí
  [taprootového][topic taproot] stromu všech možných skriptů pro vybrání
  z úschovny, každý s vlastní hodnotou a [časovým zámkem][topic timelocks].
  Ve stromu skriptů jsou též CTV haše pro vkládání, které umožní do úschovny
  přidat dodatečné prostředky o různých hodnotách. MCCV se vyhýbá základním
  problémům kombinování vstupů z úschoven, které BIPy 345 a 443 pomáhají řešit,
  tím, že používá pouze jediné UTXO, které je rozšiřováno nebo zužováno,
  namísto používání více UTXO. Jako u všech návrhů CTV úschoven, i u MCCV
  musí být částky pro výběry i vklady předem přesně určené a vyjmenované během
  vytváření (BIPy 345 a 443 tuto podmínku nemají). Řízení četnosti
  požadavků není zcela možné u úschoven s více UTXO. MCCV může být též
  implementováno s `OP_TEMPLATEHASH` ([BIP446][]).

- **Diskuze o postkvantové Lightning Network**: Olaoluwa Osuntokun (roasbeef) zaslal
  do fóra Delving Bitcoin [příspěvek][oo delving ln lbl] zobrazující, jak by mohla
  [postkvantová][topic quantum resistance] Lightning Network vypadat na
  jednotlivých vrstvách. Osuntokun vyjmenovává dostupné postkvantové kryptosystémy
  a spojuje je s vrstvami Lightning Network a potřebnými kryptografickými
  primitivy. Postkvantová LN by si mohla zachovat svou celkovou strukturu,
  ale zřejmě se bude muset vzdát jediného klíče uzlu, na který v současnosti
  spoléhá. Žádný postkvantový kryptosystém ani klíč by nebyl schopen nabídnout
  všechna požadovaná primitiva. Osuntokun zjistil, že pro určité funkce LN,
  včetně výměny klíčů, se nejlépe hodí kryptografie založená na mřížkách.
  Dále poznamenává, že kvůli velikosti postkvantových kryptografických prvků
  by zřejmě dávalo smysl nadále paralelně používat kryptografii založenou na eliptických
  křivkách pro případ, že by se v postkvantových schématech objevily zranitelnosti.

- **Teorie her kvantového útoku**: Jameson Lopp zaslal do fóra Delving Bitcoin
  [příspěvek][jl qag] o svém [blogovém příspěvku][jl delving qag] popisujícím
  teorii her kvantových útoků. Lopp popisuje potenciální podněty a činy
  různých účastníků trhu v případě zkonstruování kvantového počítače, který
  by mohl z veřejných klíčů odhalit soukromé. Scénáře, které popisuje, jsou
  nepředvídatelné, neboť kvantoví útočníci mohou rychle získat přístup k velkým
  částkám bitcoinu bez nutnosti vynaložit práci a kapitál, s nimiž jsou jiní
  držitelé svázáni.

- **BIP54 a 64bajtové transakce s možnými legitimními důvody používání**: Jeremy
  Rubin zaslal do emailové skupiny Bitcoin-Dev [příspěvek][jr ml 64] o možném
  legitimním důvodu používání 64bajtových transakcí bez započítaných witnessů.
  Návrh [pročištění konsenzu][topic consensus cleanup] ([BIP54][]) přináší
  zneplatnění 64bajtových transakcí bez započítaných witnessů. Tato změna
  má za cíl znemožnit určitou skupinu [zranitelností Merkleova stromu][topic
  merkle tree vulnerabilities] a tím navýšit bezpečnost zjednodušených
  ověření plateb či podobných schémat pro ověřování plateb založených na
  hlavičkách. Jelikož mohou mít 64bajtové transakce nejvýš jeden vstup
  a jeden výstup utratitelný kýmkoliv, považovali je autoři BIP54 za
  nehodné ochrany. Rubin navrhuje několik potenciálních scénářů, kde by
  současné nebo budoucí protokoly mohly takové transakce používat.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 26.06][] je vydání hlavní verze této oblíbené implementace
  LN uzlu. Obsahuje nová RPC volání `graceful`, `sendamount` a `xkeysend`,
  započíná cyklus zastarání příkazu `pay` ve prospěch `xpay` a přidává podporu
  pro [BOLT12][topic offers] dokladů o platbě. [Seznam změn][cln 26.06
  changelog] obsahuje další podrobnosti.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #35269][] opravuje podepisování [PSBT][topic psbt]
  s [MuSig2][topic musig]. Nově přidává do interního identifikátoru sezení
  MuSig2 procesu veřejná nonce každého účastníka. Dříve mohlo volání
  `walletprocesspsbt` více než jednou nad stejným PSBT bez noncí generovat
  nová veřejná nonce se stejným interním identifikátorem sezení, což vyvolalo
  assert kontrolu, která měla opakovanému používání noncí zabránit. Nový
  identifikátor sezení i nadále vyvolá assert kontrolu v případě opakovaného
  použití noncí, čímž napomůže zabránit úniku soukromého klíče.

- [Bitcoin Core #34644][] přidává do IPC rozhraní Mining (viz zpravodaje
  [č. 310][news310 mining] a [č. 323][news323 mining]) metodu `submitBlock`,
  která umožní klientům [Stratum v2][topic pooled mining] odeslat kompletní
  blok pro validaci a další zpracování. Tato metoda je užitečná pro
  případy, kdy Stratum v2 obdrží již vyřešený blok, pro který nemá Bitcoin Core
  odpovídající objekt `BlockTemplate`, a stávající metoda `submitSolution`
  je tudíž nedostatečná (viz též [zpravodaj č. 325][news325 ipc]). Nová metoda
  je podobná RPC volání `submitblock`, avšak vrací booleovskou hodnotu a popis
  případného odmítnutí (duplikovaný, nevalidní či neprůkazný blok). Na rozdíl
  od RPC volání musí být v případě IPC odeslán kompletní blok včetně witnessu
  mincetvorné transakce, pokud je přítomen i commitment witnessů.

- [Bitcoin Core #34198][] opravuje chybu migrace postihující velmi staré
  peněženky vytvořené předtím, než peněženky začaly v roce 2011 ukládat
  záznamy o nejlepším bloku. Nově je možné migrovat peněženky, které tento
  záznam postrádají, na [deskriptorovou][topic descriptors] peněženku,
  avšak pro dokončení migrace je potřeba proskenovat celý řetězec.

- [LND #10813][] odstraňuje podporu pro vytváření [Tor][topic anonymity networks]
  v2 onion služeb, které byly zastarané ve verzi LND 0.20 (viz
  [zpravodaj č. 375][news375 tor], _angl._). Zastaraná volba `tor.v2` je odstraněna,
  avšak v2 adresy jsou v oznámeních zachovány, aby mohly být stávající gossip
  zprávy nadále ověřované a přeposílané. Tor v2 onion služby jsou
  od října 2021 nahrazené Tor v3.

- [Rust Bitcoin #6250][] počíná ověřovat, že vstup mincetvorné transakce rezervuje
  32 bajtů pro witness, pokud transakce také obsahuje commitment witnessů.
  Tím získává validace bloků v rust-bitcoin soulad s [BIP141][]. Dříve
  rust-bitcoin provedl tuto kontrolu jen tehdy, pokud blok obsahoval další
  [segwitové][topic segwit] transakce. Mohl tedy přijmout blok s commitmentem
  witnessů v mincetvorné transakci, avšak bez rezervovaných bajtů pro witness
  mincetvorné transakce.

- [BOLTs #1338][] přidává do [BOLT2][] požadavek, aby uzly čekaly alespoň sto
  bloků před odesláním `channel_ready`, pokud je otevírací transakce kanálu
  mincetvornou transakcí. Tím zabraňuje těžařům v používání nezralých
  výstupů k otevření LN kanálu.

- [BOLTs #1326][] umožňuje v [BOLT4][] i koncovým uzlům, a ne jen přeposílajícím,
  aby vrátily chyby `invalid_onion_version`, `invalid_onion_hmac` nebo
  `invalid_onion_key`. Dříve byly tyto chyby nesprávně umístěny pod pravidlem,
  že je koncové uzly nesmí používat. PR dále objasňuje, že přeposílající uzly nesmí
  zpracovávat již zaplacené platební haše jako koncové uzly.

{% include snippets/recap-ad.md when="2026-06-09 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35269,34644,34198,10813,6250,1338,1326" %}

[ademan delving mccv]: https://delvingbitcoin.org/t/ctv-only-vault-concept-v0-1-0-release/2539
[jamesob ctv vault]: https://github.com/jamesob/simple-ctv-vault
[news191 simple vault]: /en/newsletters/2022/03/16/#continued-ctv-discussion
[mccv]: https://github.com/LNHANCE-Expedition/mccv
[oo delving ln lbl]: https://delvingbitcoin.org/t/post-quantum-lightning-layer-by-layer/2479
[jl qag]: https://delvingbitcoin.org/t/quantum-attack-game-theory/2524
[jl delving qag]: https://blog.lopp.net/quantum-attack-game-theory/
[jr ml 64]: https://groups.google.com/g/bitcoindev/c/iCuq6bFKt5Y/m/MCATyQ4zAAAJ
[pq bip324 ml]: https://groups.google.com/g/bitcoindev/c/n_5WuKVYqwI/m/lBooLis3AQAJ
[wiki kem]: https://en.wikipedia.org/wiki/Key_encapsulation_mechanism
[pyth delving qr]: https://delvingbitcoin.org/t/qr-based-signing-flow-payloads-in-miniscript-context/2464
[Core Lightning 26.06]: https://github.com/ElementsProject/lightning/releases/tag/v26.06
[cln 26.06 changelog]: https://github.com/ElementsProject/lightning/blob/v26.06/CHANGELOG.md
[news310 mining]: /cs/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /cs/newsletters/2024/10/04/#bitcoin-core-30510
[news325 ipc]: /cs/newsletters/2024/10/18/#bitcoin-core-30955
[news375 tor]: /en/newsletters/2025/10/10/#lnd-10254
