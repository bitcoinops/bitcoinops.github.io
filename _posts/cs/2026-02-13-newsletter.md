---
title: 'Zpravodaj „Bitcoin Optech” č. 392'
permalink: /cs/newsletters/2026/02/13/
name: 2026-02-13-newsletter-cs
slug: 2026-02-13-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje diskuzi o zlepšení situace s nejhorší možnou
efektivitou skenování tichých plateb a popisuje myšlenku na možnost stanovit
mnoho podmínek utrácení v jediném klíči. Též nechybí naše pravidelné rubriky
s oznámeními nových vydání a popisem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Návrh na omezení počtu příjemců tichých plateb ve skupině**: Sebastian
  Falbesoner zaslal do emailové skupiny Bitcoin-Dev [příspěvek][kmax mailing list]
  o objevení a opatření před teoretickým útokem na příjemce [tichých plateb][topic
  silent payments]. Útok nastává, když protivník zkonstruuje transakci s velkým
  počtem taprootových výstupů (dle aktuálních pravidel konsenzu je maximální
  počet výstupů v bloku 23 255), které všechny cílí na stejnou entitu.
  Kdyby neexistovalo žádné omezení na velikost skupiny, trvalo by ji zpracovat
  několik minut namísto desítek sekund.

  To vedlo k přidání nového parametru `K_max`, který omezuje počet příjemců
  na skupinu v rámci jediné transakce. Teoreticky by tato změna nebyla
  zpětně kompatibilní, ale v praxi by žádná peněženka podporující tiché platby
  neměla být ovlivněna pro dostatečně vysoký `K_max`. Falbesoner navrhuje `K_max=1000`.

  Falbesoner žádá o zpětnou vazbu k navrženému omezení. Dále poznamenává,
  že kontaktoval vývojáře většiny peněženek a jsou tedy s problémem seznámeni.

- **BLISK, logika booleovských obvodů integrovaná do jediného klíče**: Oleksandr
  Kurbatov zaslal do fóra Delving Bitcoin [příspěvek][blisk del] o BLISKu,
  protokolu navrženém na vyjádření komplexních autorizačních pravidel pomocí
  booleovské logiky. BLISK (Boolean circuit Logic Integrated into the Single Key)
  má za cíl vyřešit omezení existujících pravidel utrácení. Na příklad protokoly
  jako [MuSig2][topic musig], ač efektivní a zachovávající soukromí, jsou schopné
  vyjádřit kardinalitu (_k_ z _n_), avšak neumí určit, „kdo” může utrácet.

  BLISK vytváří jednoduché AND/OR booleovské obvody a mapuje logická hradla na
  známé kryptografické techniky. Konkrétně: AND hradla vznikají aplikací
  _n_ z _n_ vícenásobného podpisu, kde každý účastník musí přispět validním
  podpisem. Na druhou stranu, OR hradla vznikají použitím protokolu výměny
  klíčů, jako je [ECDH][ecdh wiki], kde kterýkoliv účastník může odvodit
  sdílený tajný kód použitím svého soukromého klíče a veřejného klíče kteréhokoliv
  z ostatních účastníků. Dále také využívá [neinteraktivního dokladu s nulovou
  znalostí][nizk wiki], aby umožnil ověřit výsledek obvodu a tím zabránil podvodům.
  Výsledkem řešení obvodu BLISKu je jediný klíč pro ověřování podpisu. Díky tomu
  je potřeba ověřit jen jeden [Schnorrův][topic schnorr signatures] podpis oproti
  jednomu veřejnému klíči.

  Další výhodou BLISKu oproti jiným přístupům je odstranění nutnosti generovat
  čerstvý klíč, jelikož umožňuje připojit existující klíč ke konkrétní instanci
  podpisu.

  Kurbatov poskytl pro tento protokol [ověřovací implementaci][blisk gh], i když
  uvedl, že zatím nedosáhla produkční kvality.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 29.3][] je údržbovým vydáním předchozí hlavní verze, které
  přináší opravu několika chyb v migrování peněženek (viz [zpravodaj
  č. 387][news387 wallet]), přidává vyrovnávací paměť mezistavu sighashe vstupů
  (snižuje dopady kvadratického algoritmu v zastaralých skriptech, viz
  [zpravodaj č. 367][news367 sighash], _angl._) a odstraňuje systém hodnocení
  špatného chování peer spojení za nevalidní transakce (viz [zpravodaj
  č. 367][news367 discourage], _angl._). [Poznámky k vydání][bcc29.3 rn]
  obsahují další podrobnosti.

- [LDK 0.2.2][] je údržbovým vydáním této knihovny pro budování aplikací
  s podporou LN. Mění příznak podpory splicingu na produkční
  feature bit (63), opravuje chybu, která mohla po restartování způsobit
  zamrznutí databázových asynchronních operací `ChannelMonitorUpdate`,
  což vedlo k vynucenému zavření kanálu, a opravuje chybu debug assertu,
  která se objevila po přijetí nevalidní splicingové zprávy.

- [HWI 3.2.0][] je vydáním tohoto balíčku poskytujícího jednotné rozhraní
  k několika hardwarovým podpisovým zařízením. Nové vydání přidává podporu
  pro zařízení Jade Plus a BitBox02 Nova a podporu pro [MuSig2][topic
  musig] PSBT pole dle specifikace v [BIP373][].

- [Bitcoin Inquisition 29.2][] je vydáním tohoto [signetového][topic signet]
  plného uzlu určeného pro experimentování s návrhy soft forků a jinými
  významnými změnami protokolu. Je založeno na Bitcoin Core 29.3r2, implementuje
  návrh [BIP54][] ([pročištění konsenzu][topic consensus cleanup]) a deaktivuje
  [testnet4][topic testnet].

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #32420][] přestává v Mining IPC rozhraní (viz
  [zpravodaj č. 310][news310 mining]) přidávat do `scriptSig` mincetvorné
  transakce falešný `extraNonce`. Do `CreateNewBlock()` přidává novou volbu
  `include_dummy_extranonce` a IPC ji nastavuje na `false`. Klienty
  [Stratum v2][topic pooled mining] obdrží v `scriptSig` pouze výšku,
  jak konsenzus dle [BIP34][] požaduje, a nemusí tato extra data odstraňovat
  nebo ignorovat.

- [Core Lightning #8772][] odstraňuje podporu zastaralého formátu onion
  plateb. I když CLN přestal staré onion používat v roce 2022 (viz
  [zpravodaj č. 193][news193 legacy], _angl._), přidal ve verzi 24.05
  překladovou vrstvu, která se starala o několik zbývajících zastaralých
  onion zpráv produkovaných staršími LND. Ty nejsou od LND verze
  0.18.3 vytvářeny, podpora již proto není potřebná. Tento zastaralý
  formát byl z BOLT specifikace odstraněn v roce 2022 (viz [zpravodaj
  č. 220][news220 bolts], _angl._).

- [LND #10507][] přidává do odpovědi na RPC volání `GetInfo` příznak `wallet_synced`,
  který určuje, zda peněženka dokončila synchronizaci s aktuálním vrcholem
  řetězce. Na rozdíl od stávajícího příznaku `synced_to_chain` toto nové pole
  nevyžaduje, aby router grafu kanálů (který validuje [oznámení kanálů][topic
  channel announcements]), ani blockbeat dispatcher (podsystém, který koordinuje
  události bloků) synchronizaci již dokončily.

- [LDK #4387][] mění příznak podpory [splicingu][topic splicing] z provizorního
  feature bitu 155 na produkční bit 63. LDK verze 0.2 používala bit 155,
  který používá též Eclair pro vlastní implementaci splicingu ve Phoenixu,
  která předchází současný návrh specifikace a není s ní v souladu.
  Kvůli tomu se Eclair uzly snažily provádět splicing pomocí vlastního
  protokolu, což vedlo s LDK uzly k chybám deserializace a odpojování.

- [LDK #4355][] přidává asynchronní podepisování commitmentů u interaktivně
  otevíraných transakcí. Děje se tak během [splicingu][topic splicing] i
  [oboustranně financovaných][topic dual funding] kanálů. Po obdržení
  `EcdsaChannelSigner::sign_counterparty_commitment` asynchronní podepisující
  objekt okamžitě vrátí a ozve se přes callback `ChannelManager::signer_unblocked`,
  když je podpis hotov. Oboustranně financované kanály vyžadují pro plnou
  podporu asynchronního podepisování další práci.

- [LDK #4354][] mění výchozí hodnotu volby `negotiate_anchors_zero_fee_htlc_tx`
  na `true`, čímž budou standardně vytvářeny kanály s [anchor výstupy][topic
  anchor outputs]. Automatické přijímání kanálů bylo odstraněno,
  všechny příchozí žádosti o kanál tak musí být schválené manuálně.
  To zajistí, že peněženka má v případě vynuceného zavření kanálu dostatek
  onchain prostředků na pokrytí poplatků.

- [LDK #4303][] opravuje dvě chyby, které mohly způsobit dvojité přeposlání
  [HTLC][topic htlc] po restartu `ChannelManager`: poprvé, když bylo odchozí
  HTLC stále v interní frontě, ale nedošlo na něj, a podruhé, když bylo již
  přeposláno, urovnáno a odstraněno z odchozí fronty, ale příchozí
  interní fronta pro něj stále měla urovnání. PR dále odstraní příchozí
  HTLC onion zprávy poté, co jsou definitivně přeposlané.

- [HWI #784][] přidává do [PSBT][topic psbt] podporu pro serializaci a
  deserializaci [MuSig2][topic musig] polí včetně veřejných klíčů
  účastníků, veřejných noncí a částečných podpisů dle specifikace
  v [BIP327][].

- [BIPs #2092][] přiřazuje zprávě
  `feature` jednobajtové ID pro použití s [v2 P2P transport][topic v2 p2p
  transport] protokolem a  [BIP434][]. Do [BIP324][] přidává nový
  soubor zaznamenávající přiřazená ID napříč BIPy, který by měl
  vývojářům pomoci vyvarovat se konfliktů. Soubor též zaznamenává
  navrhovaná přiřazení pro [Utreexo][topic utreexo].

- [BIPs #2004][] přidává [BIP89][] pro Chain Code Delegation (viz
  [zpravodaj č. 364][news364 delegation], _angl._), mechanismus pro společnou
  správu prostředků (collaborative custody), kde delegující nesdělí
  delegovanému [BIP32][] chain code, avšak sdílí s ním pouze informace
  nutné pro podepsání; tyto informace nejsou dostatečné pro sledování
  ostatních adres.

- [BIPs #2017][] přidává [BIP110][], který specifikuje dočasný soft fork
  pro redukci dat (Reduced Data Temporary Softfork, RDTS). Tento návrh
  má za cíl dočasně, na zhruba jeden rok, konsenzem omezit části
  transakcí sloužících pro přenos libovolných dat. Pravidla by
  zneplatnila scriptPubKey překračující 34 bajtů (kromě `OP_RETURN`
  s maximálně 83 bajty), pushdata a položky v zásobníku witnessů
  překračující 256 bajtů, utrácení nedefinovaných witness verzí,
  přílohy [taprootu][topic taproot], kontrolní bloky překračující
  257 bajtů, opkódy `OP_SUCCESS` a `OP_IF`/`OP_NOTIF`
  v [tapscriptech][topic tapscript]. Vstupy utrácející UTXO
  vytvořená před aktivací mají výjimku. Aktivace používá modifikovaný
  [BIP9][] se sníženým 55% prahem signalizace těžařů a povinnou
  fixací zhruba před zářím 2026. Viz též [zpravodaj č. 379][news379 rdts]
  (_angl._), který tento návrh již dříve popisoval.

- [Bitcoin Inquisition #99][] přidává na [signet][topic signet]
  implementaci [BIP54][], soft forku [pročištění konsenzu][topic consensus cleanup].
  Implementuje čtyři opatření: omezuje počet potenciálně spuštěných
  zastaralých operací nad podpisy (sigops) za každou transakci,
  zabraňuje útokům ohýbáním času (timewarp attacks) pomocí dvouhodinového
  přechodného období (společně s nemožností negativních intervalů
  úpravy složitosti), vyžaduje nastavení časového zámku mincetvorné
  transakce na výšku bloku a zneplatňuje 64bajtové transakce.

{% include snippets/recap-ad.md when="2026-02-17 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32420,8772,10507,4387,4355,4354,4303,784,2092,2004,2017,99" %}
[kmax mailing list]: https://groups.google.com/g/bitcoindev/c/tgcAQVqvzVg
[blisk del]: https://delvingbitcoin.org/t/blisk-boolean-circuit-logic-integrated-into-the-single-key/2217
[ecdh wiki]: https://cs.wikipedia.org/wiki/Diffieho%E2%80%93Hellman%C5%AFv_protokol_s_vyu%C5%BEit%C3%ADm_eliptick%C3%BDch_k%C5%99ivek
[nizk wiki]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[blisk gh]: https://github.com/zero-art-rs/blisk
[Bitcoin Core 29.3]: https://bitcoincore.org/bin/bitcoin-core-29.3/
[bcc29.3 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-29.3.md
[Bitcoin Inquisition 29.2]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.2-inq
[HWI 3.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.2.0
[LDK 0.2.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.2
[news387 wallet]: /cs/newsletters/2026/01/09/#chyba-v-migraci-penezenky-v-bitcoin-core
[news367 sighash]: /en/newsletters/2025/08/15/#bitcoin-core-32473
[news367 discourage]: /en/newsletters/2025/08/15/#bitcoin-core-33050
[news310 mining]: /cs/newsletters/2024/07/05/#bitcoin-core-30200
[news193 legacy]: /en/newsletters/2022/03/30/#c-lightning-5058
[news220 bolts]: /en/newsletters/2022/10/05/#bolts-962
[news364 delegation]: /en/newsletters/2025/07/25/#chain-code-withholding-for-multisig-scripts
[news379 rdts]: /en/newsletters/2025/11/07/#temporary-soft-fork-to-reduce-data
[BIP89]: https://github.com/bitcoin/bips/blob/master/bip-0089.mediawiki
