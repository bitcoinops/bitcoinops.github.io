---
title: 'Zpravodaj „Bitcoin Optech” č. 345'
permalink: /cs/newsletters/2025/03/14/
name: 2025-03-14-newsletter-cs
slug: 2025-03-14-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden nahlíží na analýzu P2P provozu typického plného
uzlu, shrnuje výzkum hledání cest v LN a popisuje nový přístup ve vytváření
pravděpodobnostních plateb. Též nechybí naše pravidelné rubriky se souhrnem
sezení Bitcoin Core PR Review Clubu, oznámeními nových vydání a popisem
významných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Analýza P2P provozu:** vývojář Virtu zaslal do fóra Delving Bitcoin
  [příspěvek][virtu traffic] s analýzou síťového provozu odeslaného a
  přijatého jeho uzlem ve čtyř různých režimech: úvodní stahování bloků
  (initial block download, IBD), bez serveru (pouze odcházející spojení),
  se serverem bez archivování (ořezaný uzel) a se serverem s archivováním.
  Ačkoliv výsledky jediného uzlu nemusí být ve všech případech reprezentativní,
  některá jeho zjištění jsou zajímavá:

  - *Archivující uzel se serverem s vysokým provozem bloků:* Virtuův uzel fungující
    jako neořezaný uzel se serverem odeslal ostatním uzlům každou hodinu několik
    gigabajtů bloků. Velká část byly starší bloky, které si spojení vyžádala
    během jejich IBD.

  - *Nearchivující uzel se serverem s vysokým provozem inv:* kolem 20 % celkového
    provozu byly zprávy `inv` před tím, než aktivoval posílání starších
    bloků. [Erlay][topic erlay] by mohl výrazně snížit tento podíl,
    což představuje zhruba 100 megabajtů za den.

  - *Skupina přicházejících spojení jsou zřejmě slídilové:* „Zajímavé je, že
    jedna skupina příchozích spojení vymění s uzlem pouze 1 MB dat, což je příliš
    málo (když pro srovnání použiju provoz mých odchozích spojení) na to,
    aby to byla pravidelná spojení. Ty uzly jen dokončí P2P handshake a pak
    slušně odpovídají na ping zprávy. Jinak jen hltají naše `inv` zprávy.”

  Virtuův příspěvek obsahuje další podrobnosti a několik grafů ilustrujících
  provoz, kterému byl tento uzel vystaven.

- **Výzkum hledání cest s jedinou částí v LN:** Sindura Saraswathi
  zaslala do fóra Delving Bitcoin [příspěvek][saraswathi path] o
  [výzkumu][sk path], který podnikla spolu s Christianem Kümmerlem.
  Předmětem bylo hledání optimálních cest mezi LN uzly pro posílání
  plateb s jedinou částí. Její příspěvek popisuje strategie, které jsou
  v současnosti používané v Core Lightning, Eclair, LDK a LND. Autoři
  dále použili osm upravených a neupravených LN uzlů v simulované síti
  (založené na snapshotech skutečné sítě) a testovali hledání cest.
  Během experimentu vyhodnocovali kritéria, jako jsou nejvyšší
  míra úspěšných dokončení, nejnižší poměr poplatků (nejnižší náklady),
  nejkratší celkový časový zámek (nejméně špatná doba čekání v nejhorším
  případě) a nejkratší cesta (nejméně pravděpodobně skončí zaseknutím).
  Žádný algoritmus nebyl ve všech případech lepší než ostatní. Saraswathi
  navrhuje, aby implementace nabízely lepší váhové funkce, aby mohli
  uživatelé volit kompromisy, které u různých plateb preferují
  (např. u malých osobních nákupů můžete upřednostnit vysokou úspěšnost,
  ale u větších měsíčních účtů, na jejichž zaplacení máte ještě několik
  týdnů, budete raději volit nízký poplatek). Dále dodává: „i když to
  nebylo předmětem studie, poznamenáváme, že znalosti získané touto
  studií jsou též relevantní pro budoucí vylepšení algoritmů hledání
  cest pro [platby s více částmi][topic multipath payments].”

- **Pravděpodobnostní platby pomocí různých hašovacích funkcí a XOR funkce:**
  Robin Linus přidal svou [reakci][linus pp] do vlákna ve fóru Delving Bitcoin
  o [pravděpodobnostních platbách][topic probabilistic payments]. V ní
  představuje koncepčně jednoduchý skript, který dvěma stranám umožní zavázat
  se libovolnému množství entropie, která může být později odhalena a
  xorována dohromady. Tím vznikne hodnota, pomocí které lze určit, kdo obdrží
  platbu. Uvádíme mírně rozšířený příklad z Linusova příspěvku:

  - Alice tajně vybere hodnoty `1 0 0` a nonce. Bob tajně vybere hodnoty `1 1 0`
    a svůj nonce.

  - Každá strana následně svá nonce zahašuje funkcemi určenými výše uvedenými
    hodnotami. Pokud je hodnota na vrcholu zásobníku `0`, použije opkód
    `HASH160`. Pokud je hodnota `0`, použije `SHA256`. V Alicině případě
    bude provedeno `sha256(hash160(hash160(alice_nonce)))`, v Bobově
    `sha256(sha256(hash160(bob_nonce)))`. Tím každý z nich vyprodukuje
    závazek (commitment), který si spolu vymění (své hodnoty a nonce
    ponechají tajné).

  - Po sdílení závazků vytvoří onchain zakládající transakci se skriptem, který validuje
    vstupy používající `OP_IF` k určení hašovací funkce a který umožní
    jedné ze stran platbu nárokovat. Pokud je například součet jejich dvou
    xorovaných hodnot 0 nebo 1, platba připadne Alici. Pokud je 2 nebo 3,
    peníze obdrží Bob. Kontrakt může dále obsahovat expiraci a větev
    pro prostorově efektivní kooperativní urovnání.

  - Po dostatečném potvrzení zakládající transakce odhalí Alice a Bob navzájem
    své hodnoty a nonce. `1 0 0` XOR `1 1 0` je `0 1 0`, což dává součet `1`.
    Platbu může tedy nárokovat Alice.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Striktnější nakládání s nevalidními bloky][review club 31405] je
PR od vývojáře [mzumsande][gh mzumsande], které vylepšuje správnost dvou
validačních polí, která nejsou kritická pro konsenzus, ale jsou náročná
na výpočet. Tato pole byla dříve aktualizována později z důvodu šetření
zdroji, po začlenění PR budou pole aktualizována hned, jakmile je blok
označen za nevalidní. Změnu je možné nyní provést, neboť díky
[Bitcoin Core #25717][] by útočník potřeboval vynaložit mnohem více úsilí.

Konkrétně toto PR zajistí, aby `m_best_header` v `ChainstateManager` vždy
ukazoval na hlavičku s největší vykonanou prací a neznámou validitou a aby
byl `nStatus` s hodnotou `BLOCK_FAILED_CHILD` vždy správný.

{% include functions/details-list.md
  q0="Jaký účel(y) má `ChainstateManager::m_best_header`?"
  a0="`m_best_header` představuje hlavičku bloku s nejvíce PoW, kterou
  uzel zatím viděl, ale jehož validitu nemůže zaručit. Jeho hlavním
  účelem je posloužit jako cíl, ke kterému může uzel postoupit svůj
  nejlepší řetězec. Dále se používá pro odhad aktuálního času a odhad
  výšky nejlepšího řetězce během stahování chybějících hlaviček od spojení.
  Celistvější přehled lze nalézt v šest let starém pull requestu
  [Bitcoin Core #16974][]."
  a0link="https://bitcoincore.reviews/31405#l-36"

  q1="Která z těchto tvrzení byla pravdivá před tímto PR?
  1) `CBlockIndex` s NEVALIDNÍM předchůdcem má VŽDY `nStatus` s hodnotou
     `BLOCK_FAILED_CHILD`.
  2) `CBlockIndex` s VALIDNÍM předchůdcem nemá NIKDY `nStatus` s hodnotou
     `BLOCK_FAILED_CHILD`."
  a1="Tvrzení 1) je nepravdivé a je přímo adresováno tímto PR. Před tímto PR
  označil `AcceptBlock()` nevalidní blok jako nevalidní, ale z důvodu
  výkonnosti nenastavil jeho potomky jako nevalidní okamžitě. Účastníci
  sezení nemohli přijít s žádným scénářem, ve kterém by 2) bylo nepravdivé."
  a1link="https://bitcoincore.reviews/31405#l-68"

  q2="Jedním z cílů tohoto PR je zajistit, aby byly `m_best_header` a
  `nStatus` následníků nevalidního bloku vždy nastaveny na správnou hodnotu.
  Které funkce jsou přímo zodpovědné za aktualizování těchto hodnot?"
  a2="`SetBlockFailureFlags()` je zodpovědná za aktualizování `nStatus`.
  V normálním provozu je `m_best_header` většinou nastaven pomocí výstupního
  argumentu v `AddToBlockIndex()`, ale může být spočítán i nastaven pomocí
  `RecalculateBestHeader()`."
  a2link="https://bitcoincore.reviews/31405#l-110"

  q3="Většina logiky v commitu `4100495` `validace: v invalidateblock
  počítej m_best_header okamžitě` implementuje hledání nové nejlepší
  hlavičky. Co nám zde brání v prostém volání `RecalculateBestHeader()`?"
  a3="`RecalculateBestHeader()` prochází celý `m_block_index`, což
  je nákladná operace. Commit `4100495` to optimalizuje kešováním
  a procházením množiny kandidátů s vysokým PoW."
  a3link="https://bitcoincore.reviews/31405#l-114"

  q4="Kdybychom byli schopni projít strom bloků směrem vpřed (tedy od
  genesis bloku), potřebovali bychom stále keš `cand_invalid_descendants`?
  Jaké výhody a nevýhody by měl tento přístup oproti tomuto PR?"
  a4="Pokud by objekty `CBlockIndex` držely reference na všechny své potomky,
  nemuseli bychom pro zneplatnění potomků procházet celý `m_block_index`
  a nepotřebovali bychom tedy keš `cand_invalid_descendants`. Tento přístup
  by však měl velké nevýhody. Zaprvé by měl každý objekt `CBlockIndex`
  vyšší paměťové náklady, neboť musí být drženy v paměti pro celý
  `m_block_index`. Zadruhé by logika procházení byla i tak složitá,
  neboť i když má každý `CBlockIndex` právě jednoho předka, může mít
  libovolný počet potomků."
  a4link="https://bitcoincore.reviews/31405#l-136"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Eclair v0.12.0][] je hlavním vydáním tohoto LN uzlu. Vedle jiných vylepšení
  a oprav chyb „přidává podporu pro vytváření a správu [BOLT12][] nabídek a nový
  protokol zavírání podporující [RBF][topic rbf]. Dále přidává podporu pro
  ukládání malého množství dat pro naše spojení” ([peer storage][topic peer
  storage]). Poznámky k vydání zmiňují aktualizace některých hlavních
  závislostí, což si od uživatelů vyžádá provést jejich aktualizaci před nasazením
  nové verze Eclair.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #31407][] přidává podporu pro ověřování macOS balíčků a binárek
  ve skriptu `detached-sig-create.sh`. Skript nově také podepisuje samostatné
  macOS a Windows binárky. Pro tyto úkoly je používán nedávno aktualizovaný nástroj
  [signapple][].

- [Eclair #3027][] přidává při generování [BOLT12][topic offers] faktur hledání
  cest uzly podporujícími pouze [zaslepené cesty][topic rv routing]. Za tímto
  účelem byla přidána nová funkce `routeBlindingPaths`. Zaslepená cesta je poté
  začleněná do faktury.

- [Eclair #3007][] přidává do zprávy `channel_reestablish` nový TLV parametr
  `last_funding_locked`, který vylepší synchronizaci po ztrátě spojení během
  [splicingu][topic splicing]. Opravuje tím souběh, kdy uzel po obdržení
  `channel_reestablish` pošle `channel_update` ještě před `splice_locked`.
  U běžných kanálů to nepředstavuje problém, avšak může způsobit problémy
  u [jednoduchých taprootových kanálů][topic simple taproot channels], které
  vyžadují výměnu noncí mezi spojeními.

- [Eclair #2976][] přidává příkaz `createoffer`, čímž umožní vytvářet
  [nabídky][topic offers] bez potřeby dodatečných pluginů. Příkazu lze
  předat volitelné parametry popisu, částky, doby expirace, vydavatele
  a úvodního uzlu [zaslepené cesty][topic rv routing]. PR dále přidává
  příkazy `disableoffer` a `listoffers` pro správu existujících nabídek.

- [LDK #3608][] mění definici a hodnotu konstanty `CLTV_CLAIM_BUFFER`, nově
  reprezentuje dvojnásobek očekávaného maximálního počtu bloků vyžadovaných
  pro potvrzení transakce. Přizpůsobuje se tím [anchor][topic anchor outputs]
  kanálům, kde transakce nárokující [HTLC][topic htlc] jsou zpožděny pomocí
  `OP_CHECKSEQUENCEVERIFY` (CSV) [časového zámku][topic timelocks] o jeden blok.
  Dříve byla hodnota nastavena na maximální počet konfirmací, což bylo pro
  neanchorové kanály dostatečné. Jako bázová hodnota této konstanty slouží
  nová konstanta `MAX_BLOCKS_FOR_CONF`.

- [LDK #3624][] přináší rotaci zakládajících klíčů po úspěšném [splicu][topic splicing].
  Výpočet klíčů následuje [BOLT3][] specifikaci, avšak používá txid zakládající
  transakce splicu namísto `per_commitment_point` a používá `revocation_basepoint`
  pro omezení derivace klíčů na účastníky kanálu.

- [LDK #3016][] umožňuje externím projektům spouštět funkční testy a přitom nahradit
  komponenty jako podepisování. K tomuto účelu bylo přidáno makro `xtest`,
  globální proměnná `MutGlobal`, abstraktní `DynSigner` a `TestSignerFactory`
  pro jejich vytváření. Testy jsou schovány za příznakem `_externalize_tests`.

- [LDK #3629][] zlepšuje logování vzdálených chyb, které nemohou být nikomu přisouzeny
  nebo interpretovány. PR upravuje `onion_utils.rs` pro logování takových
  chyb a přináší funkci `decrypt_failure_onion_error_packet` pro dešifrování.
  Dále opravuje chybu související s nečitelných chybami, ale validními
  autentizačními kódy (HMAC). Díky tomu bude také možné vyhýbat se uzlům,
  které inzerují [vysokou dostupnost][news342 qos], ale tento slib neplní.

- [BDK #1838][] přináší jasnější implementaci úplného skenování. Do `SyncRequest` a
  `FullScanRequest` přidává povinný parametr `sync_time` a používá ho
  jako `seen_at` u nepotvrzených transakcí. Nekanonické transakce (viz
  [zpravodaj č. 335][news335 noncanonical]) nemusí `seen_at` obsahovat.
  `TxUpdate::seen_ats` je nově `HashSet<(Txid, u64)>`, aby mohla mít jedna transakce
  více časových razítek `seen_at`. `TxUpdate` je nově `#[non_exhaustive]`.

{% include snippets/recap-ad.md when="2025-03-18 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31407,3027,3007,2976,3608,3624,3016,3629,1838,16974,25717" %}
[virtu traffic]: https://delvingbitcoin.org/t/bitcoin-node-p2p-traffic-analysis/1490/
[saraswathi path]: https://delvingbitcoin.org/t/an-exposition-of-pathfinding-strategies-within-lightning-network-clients/1500
[sk path]: https://arxiv.org/pdf/2410.13784
[linus pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409/10
[eclair v0.12.0]: https://github.com/ACINQ/eclair/releases/tag/v0.12.0
[review club 31405]: https://bitcoincore.reviews/31405
[gh mzumsande]: https://github.com/mzumsande
[signapple]: https://github.com/achow101/signapple
[news335 noncanonical]: /cs/newsletters/2025/01/03/#bdk-1670
[news342 qos]: /cs/newsletters/2025/02/21/#pokracujici-diskuze-o-priznaku-quality-of-service-v-ln
