---
title: 'Zpravodaj „Bitcoin Optech” č. 358'
permalink: /cs/newsletters/2025/06/13/
name: 2025-06-13-newsletter-cs
slug: 2025-06-13-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje, jak lze vypočítat práh nebezpečí sobecké
těžby, shrnuje nápad na zabraňování filtrování transakcí s vysokými
poplatky, žádá o zpětnou vazbu k návrhu na změnu `musig()` v BIP390
deskriptorech a ohlašuje novou knihovnu pro šifrování deskriptorů.
Též nechybí naše pravidelné rubriky se souhrnem sezení Bitcoin Core PR
Review Clubu, oznámeními nových vydání a popisem nedávných změn v populárních
bitcoinových páteřních projektech.

## Novinky

- **Výpočet prahu sobecké těžby:** Antoine Poinsot
  zaslal do fóra Delving Bitcoin [příspěvek][poinsot selfish], ve kterém
  rozšiřuje matematický základ z [článku][es selfish] z roku 2013, který
  dal své jméno [útoku sobeckou těžbou][topic selfish mining] (i když
  samotný útok byl [popsán][bytecoin selfish] již v roce 2010). Dále poskytuje
  zjednodušený [simulátor][darosior/miningsimulation] těžby a přeposílání
  bloků, který umožňuje s útokem experimentovat. Soustředí se na zopakování
  jednoho ze závěrů článku: že nepoctivý těžař (nebo kartel propojených
  těžařů) ovládající 33 % celkového hashrate bez dalších výsad může v dlouhodobém
  výhledu vydělávat nepatrně více než těžaři ovládající 67 % hashrate.
  33% menšina toho dosáhne tím, že bude cíleně zpožďovat oznámení některých
  nově nalezených bloků. S hashratem zvyšujícím se nad 33 % se činnost
  stává více a více profitabilní, až přesáhne 50% hashrate a může zabránit
  ostatním účastníkům v připojování jejich bloků.

  Poinsotův příspěvek jsme podrobně neanalyzovali, ale jeho přístup se
  nám jevil rozumný a doporučili bychom ho k přečtení každému se zájmem
  získat lepší porozumění.

- **Synchronizace vrcholu mempoolu pro odolnost vůči cenzuře :**
  Peter Todd zaslal do emailové skupiny Bitcoin-Dev [příspěvek][todd feerec]
  o mechanismu, který by uzlům umožnil zahazovat spojení, která filtrují
  transakce s vysokými poplatky. Tento mechanismus závisí na [mempoolu
  clusterů][topic cluster mempool] a mechanismu synchronizování množin
  (set reconciliation) jako např. v [erlay][topic erlay]. Uzel by pomocí
  mempoolu clusterů vypočítal nejvýhodnější množinu nepotvrzených transakcí,
  které by se mohly vměstnat do (na příklad) 8 000 000 váhových jednotek
  (maximum 8 MB). Každé ze spojení uzlu by též vypočítalo horních
  8 000 000 váhových jednotek nepotvrzených transakcí. Pomocí efektivního
  algoritmu jako [minisketch][topic minisketch] by mohl uzel synchronizovat
  svou množinu transakcí se svými spojeními. Tím by se přesně dozvěděl,
  které transakce mají spojení na vrcholu svých mempoolů. Uzel by
  pravidelně odpojoval spojení, která mají v průměru nejméně profitabilní
  mempool.

  Zbavením se nejméně profitabilních spojení by uzel postupně našel taková
  spojení, která by nejméně pravděpodobně filtrovala transakce s vysokými
  poplatky. Todd doufá, že bude moci po začlenění mempoolu clusterů do
  Bitcoin Core na implementaci pracovat. Nápad přisuzuje Gregorymu Maxwellovi
  a jiným. Optech myšlenku poprvé zmínil ve [zpravodaji č. 9][news9
  reconcile] (_angl._).

- **Opakovaný veřejný klíč v `musig()` v BIP390:**
  Ava Chow zaslala do emailové skupiny Bitcoin-Dev [příspěvek][chow dupsig]
  s dotazem, zda-li by někdo namítal, aby [BIP390][] umožňoval výrazům `musig()`
  v [deskriptorech výstupních skriptů][topic descriptors] obsahovat stejný
  veřejný klíč více než jednou. Vedlo by to k jednodušší implementaci
  a je to explicitně povoleno ve specifikaci [MuSig2][topic musig] v [BIP327][].
  V době psaní zpravodaje námitky nikdo nevyjádřil a Chow tedy otevřela
  pro změnu specifikace BIP390 nový [pull request][bips #1867].

- **Knihovna pro šifrování deskriptorů:** Josh Doman zaslal do fóra Delving
  Bitcoin [příspěvek][doman descrypt] s ohlášením své knihovny, která
  přítomnými veřejnými klíči šifruje citlivé části [deskriptoru výstupních
  skriptů][topic descriptors] nebo [miniscriptu][topic miniscript].
  Popisuje, které informace jsou potřebné k dešifrování:

  > - Pokud tvoje peněženka vyžaduje k utracení 2-ze-3 klíčů, bude potřebovat
  >   přesně 2-ze-3 klíčů k dešifrování.
  >
  > - Pokud tvoje peněženka používá komplexní mininiscriptová pravidla jako
  >   „buď 2 klíče NEBO (časový zámek A jiný klíč),“ šifrování následuje
  >   stejnou strukturu, jako by byly všechny časové zámky uspokojené.

  Tento návrh se liší od schématu záloh diskutovaných ve [zpravodaji
  č. 351][news351 salvacrypt], kde znalost kteréhokoliv veřejného klíče
  z deskriptoru postačovala k jeho dešifrování. Doman tvrdí, že jeho
  schéma poskytuje více soukromí v případech, kdy je šifrovaný
  deskriptor zálohován ve veřejných či poloveřejných zdrojích, jako je
  blockchain.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Vyčleň z validačních funkcí přístup do množiny UTXO][review club 32317]
(„Separate UTXO set access from validation functions”) je PR od [TheCharlatan][gh
thecharlatan], které umožňuje volat validační funkce předáním pouze vyžadovaných
UTXO namísto celé množiny UTXO. Jedná se o součást projektu
[`bitcoinkernel`][Bitcoin Core #27587], která je důležitým krokem na cestě k
použitelnosti knihovny pro implementace plného uzlu, které neimplementují
množinu UTXO, jako jsou [Utreexo][topic utreexo] nebo [SwiftSync][somsen swiftsync]
(viz [zpravodaj č. 349][news349 swiftsync]).

V prvních čtyřech commitech snižuje PR závislost mezi funkcemi provádějícími
validaci transakcí a množinou UTXO. Nově vyžaduje, aby volající funkce
nejprve načetla potřebné objekty `Coin` nebo `CTxOut` a potom je předala
validační funkci (dříve validační funkce sama přímo přistupovala do
množiny UTXO.)

Následné commity závislost `ConnectBlock()` na množině UTXO odstraňují
kompletně. Za tímto účelem extrahují zbývající logiku, která potřebuje
s množinou UTXO pracovat, do metody `SpendBlock()`.

{% include functions/details-list.md
  q0="Proč je v tomto PR oddělení nové funkce `SpendBlock()` z `ConnectBlock()`
  užitečné? Jak byste porovnali smysl těchto dvou funkcí?"
  a0="Funkce `ConnectBlock()` původně prováděla validaci bloku i změny
  množiny UTXO. Tento refaktoring obě zodpovědnosti odděluje:
  `ConnectBlock()` nově obsahuje pouze logiku validace, která množinu UTXO
  nepotřebuje, a nová funkce `SpendBlock()` obstarává veškerou interakci s UTXO
  množinou. Díky tomu je možné provést validaci bloku pomocí `ConnectBlock()`
  bez množiny UTXO."
  a0link="https://bitcoincore.reviews/32317#l-37"

  q1="Jaké další výhody tohoto oddělení vidíte?"
  a1="Vedle možnosti používat jádro v projektech bez množiny UTXO
  usnadňuje toto oddělení testování a údržbu. Jeden účastník
  též poznamenal, že odstranění potřeby přístupu k množině UTXO
  otevírá dveře k paralelní validaci bloků, což je důležitá funkce
  SwiftSyncu."
  a1link="https://bitcoincore.reviews/32317#l-64"

  q2="`SpendBlock()` má parametry `CBlock block`, `CBlockIndex pindex`
  a `uint256 block_hash`, všechny odkazující na utrácený blok. Proč
  k tomu potřebujeme tři parametry?"
  a2="Kód validace je z hlediska výkonnosti kritický, neboť má dopad
  na příklad na rychlost propagace bloků. Počítání haše bloku z
  `CBlock` nebo `CBlockIndex` není zadarmo, protože hodnota se nekešuje.
  Proto se autor rozhodl upřednostnit výkonnost tím, že předává již spočítaný
  haš bloku jako samotný parametr. Podobně by mohl být i `pindex` získán
  z indexu bloku, ale to by znamenalo nadbytečné vyhledání v mapě navíc.
  <br>_Poznámka: autor později přístup [změnil][32317 updated approach]
  a `block_hash`odstranil._"
  a2link="https://bitcoincore.reviews/32317#l-97"

  q3="První commit tohoto PR odstraňuje `CCoinsViewCache` ze signatury
  několika validačních funkcí. Drží `CCoinsViewCache` celou množinu UTXO?
  Proč to je/není problém? Mění PR toto chování?"
  a3="`CCoinsViewCache` nedrží celou množinu UTXO; jedná se o mezipaměť, která
  je umístěna před `CCoinsViewDB`, která ukládá celou množinu UTXO na disk.
  Pokud není požadovaná mince v mezipaměti, musí být načtena z disku.
  Toto PR samotné chování kešování nemění. Odstraněním `CCoinsViewCache` ze
  signatur je závislost na UTXO explicitní, jelikož od volající funkce
  požaduje, aby mince před voláním validační funkce sama načetla."
  a3link="https://bitcoincore.reviews/32317#l-116"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 25.05rc1][] je kandidátem na vydání příští hlavní verze této oblíbené
  implementace LN uzlu.

- [LND 0.19.1-beta][] je kandidátem na vydání údržbové verze této populární
  implementace LN uzlu. [Obahuje][lnd rn] opravy několika chyb.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #32406][]  odstraňuje omezení velikosti `OP_RETURN` výstupu
  (pravidlo standardnosti). Navyšuje výchozí nastavení `-datacarriersize`
  z 83 na 100 000 bajtů (nejvyšší možná velikost transakce). Volby
  `-datacarrier` a `-datacarriersize` zůstávají zachované, jsou však
  označené jako zastaralé a očekává se jejich odstranění v nějakém
  budoucím vydání. Dále toto PR odstraňuje omezení jednoho
  `OP_RETURN` výstupu na transakci a stanovuje omezení velikosti na
  všechny takové výstupy. [Zpravodaj č. 352][news352 opreturn] přináší
  další informace o této změně.

- [LDK #3793][] přidává novou zprávu `start_batch`, která signalizuje spojením,
  aby považovala příštích `n` (`batch_size`) zpráv za jedinou logickou jednotku.
  Dále aktualizuje `PeerManager`, aby používal tuto zprávu pro zprávy
  `commitment_signed` namísto přidávání TLV a `batch_size` do každé jednotlivé
  zprávy. Jedná se o pokus umožnit dávkování i jiným zprávám LN protokolu.

- [LDK #3792][] přináší úvodní podporu (za testovacím příznakem) [v3 commitment
  transakcí][topic v3 commitments] (viz [zpravodaj č. 325][news325 v3]),
  která spoléhá na  [TRUC transakce][topic v3 transaction relay] a [dočasné
  anchory][topic ephemeral anchors]. Uzel bude nově odmítat návrhy
  `open_channel`, které nastavují nenulový jednotkový poplatek, ujistí se,
  že nikdy podobné kanály nebude sám navrhovat a přestane automaticky
  akceptovat v3 kanály, dokud nejprve nezarezervuje UTXO pro pozdější
  navyšování poplatků. PR dále snižuje [HTLC][topic htlc] limit na kanál
  z 483 na 114, protože TRUC transakce musí zůstat pod 10 kvB.

- [LND #9127][] přidává do příkazu `lncli addinvoice` volbu
  `--blinded_path_incoming_channel_list`, která příjemci umožní přidat jeden
  či více preferovaných kanálů, přes které by odesílatel mohl směrovat [zaslepenou
  cestu][topic rv routing].

- [LND #9858][] signalizuje produkční feature bit 61 pro kooperativní zavírání kanálu
  s [RBF][topic rbf] (viz též [zpravodaj č. 347][news347 rbf]). Tím zajistí
  fungování s Eclairem. Zachovává testovací bit 161 pro uzly testující tuto
  funkcionalitu.

- [BOLTs #1243][] mění ve specifikaci [BOLT11][] nakládání s poli faktury. Nově odesílatel
  nesmí platit fakturu, pokud nemají povinná pole jako `p` (platební haš), `h` (haš popisky)
  nebo `s` (tajný kód) správnou délku. Dříve mohl uzel tyto problémy ignorovat.
  Změna dále mezi příklady přidává poznámku vysvětlující, že [podpisy s nižším R][topic
  low-r grinding] nejsou specifikací vynucované, i když šetří jeden bajt.

{% include snippets/recap-ad.md when="2025-06-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32406,3793,3792,9127,1867,9858,1243,27587" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[lnd 0.19.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta
[poinsot selfish]: https://delvingbitcoin.org/t/where-does-the-33-33-threshold-for-selfish-mining-come-from/1757
[bytecoin selfish]: https://bitcointalk.org/index.php?topic=2227.msg30083#msg30083
[darosior/miningsimulation]: https://github.com/darosior/miningsimulation
[todd feerec]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aDWfDI03I-Rakopb@petertodd.org/
[news9 reconcile]: /en/newsletters/2018/08/21/#bandwidth-efficient-set-reconciliation-protocol-for-transactions
[chow dupsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/08dbeffd-64ec-4ade-b297-6d2cbeb5401c@achow101.com/
[doman descrypt]: https://delvingbitcoin.org/t/rust-descriptor-encrypt-encrypt-any-descriptor-such-that-only-authorized-spenders-can-decrypt/1750/
[news351 salvacrypt]: /cs/newsletters/2025/04/25/#standardizovane-zalohovani-deskriptoru-penezenek
[es selfish]: https://arxiv.org/pdf/1311.0243
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/v0.19.1-beta/docs/release-notes/release-notes-0.19.1.md
[news352 opreturn]: /cs/newsletters/2025/05/02/#navyseni-ci-odstraneni-omezeni-velikosti-op-return-v-bitcoin-core
[news325 v3]: /cs/newsletters/2024/10/18/#commitment-transakce-verze-3
[news347 rbf]: /cs/newsletters/2025/03/28/#lnd-8453
[review club 32317]: https://bitcoincore.reviews/32317
[gh thecharlatan]: https://github.com/TheCharlatan
[somsen swiftsync]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[32317 updated approach]: https://github.com/bitcoin/bitcoin/pull/32317#issuecomment-2883841466
[news349 swiftsync]: /cs/newsletters/2025/04/11/#swiftsync-urychlujici-uvodni-stahovani-bloku
