---
title: 'Zpravodaj „Bitcoin Optech” č. 386'
permalink: /cs/newsletters/2026/01/02/
name: 2026-01-02-newsletter-cs
slug: 2026-01-02-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje schéma podobné úschovnám používající zaslepený MuSig2
a popisuje návrh na možnost bitcoinových klientů oznamovat a vyjednávat o podpoře
nových P2P funkcí. Též nechybí naše pravidelné rubriky s popisem diskuzí
o změnách konsenzu, oznámeními nových vydání a souhrnem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Úschovny používající zaslepené kooperativní podepisování:** Jonathan T. Halseth zaslal
  do fóra Delving Bitcoin [příspěvek][halseth post] o prototypu schématu podobného
  [úschovnám][topic vaults], které používá zaslepené kooperativní podepisování.
  Na rozdíl od tradičního kooperativního podepisování používá jeho schéma
  [zaslepenou verzi][blinded musig] protokolu [MuSig2][topic musig], aby podepisující
  věděli co nejméně o prostředcích zapojených do podepisování. Aby nemuseli
  podepisující slepě podepsat cokoliv, co je jim podstrčeno, přikládá toto schéma
  k požadavku o podepsání navíc doklad s nulovou znalostí, který dokazuje,
  že transakce je validní dle předem určených pravidel (v tomto případě jsou jimi
  [časové zámky][topic timelocks]).

  Halseth na grafu ukázal čtyři transakce, které se podepisují předem:
  počáteční vklad, zotavení (recovery), výběr z úschovny (unvault) a
  zotavení po výběru (unvault recovery). Během výběru z úschovny budou
  podepisující vyžadovat doklad s nulovou znalostí dokazující, že
  má podepisovaná transakce správně nastavený relativní časový zámek.
  To zaručí, že budou mít uživatelé nebo strážní věž dostatek času
  na zotavení v případě neautorizovaného výběru.

  Halseth též poskytl [implementaci][halseth prototype] prototypu dostupnou pro regtest
  a signet.

- **Vyjednávání o schopnostech peer spojení**: Anthony Towns zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][peer neg ml] o návrhu nového [BIPu][towns bip],
  který definuje P2P zprávy umožňující spojením oznamovat a vyjednávat
  o podpoře nových funkcí. Myšlenka je podobná [návrhu][feature negotiation ml]
  z roku 2020. Byla by přínosná pro různé navrhované P2P funkce, včetně
  Townsova vlastního návrhu [sdílení šablon][news366 template].

  Z historických důvodů se změny P2P protokolu spoléhají na navyšování čísla
  verze jako signalizace podpory nových funkcí. Díky tomu mohou uzly začít vyjednávat o
  spojení jen s kompatibilními uzly. Tento přístup však vyžaduje nadbytečnou koordinaci
  mezi implementacemi, obzvláště u funkcí, které nepotřebují široké nasazení.

  Tento BIP navrhuje zobecnit mechanismus z [BIP339][] přidáním jedné opakovaně
  použitelné P2P zprávy pro oznámení a vyjednávání budoucích rozšíření P2P
  protokolu ve fázi před zprávou [verack][verack] (version acknowledgement,
  tedy potvrzení přijetí čísla verze). Snížil by tím potřebu koordinace,
  usnadnil přidávání rozšíření, zamezil tříštění sítě a maximalizoval
  kompatibilitu s různorodými klienty.

## Diskuze o změnách konsenzu

_Měsíční rubrika shrnující návrhy a diskuze o změnách pravidel
bitcoinového konsenzu._

- **Migrace na uint64 kvůli přetečení časových razítek v roce 2106**: Asher Haim zaslal do emailové
  skupiny Bitcoin-Dev [příspěvek][ah ml uint64 ts] se žádostí, aby se bitcoinoví
  vývojáři neprodleně začali připravovat na migraci časových razítek
  bloků z typu uint32 na uint64. Haim objasňuje důvody nutnosti jednat neodkladně
  v souvislosti s dlouhodobými finančními kontrakty, které se mohou již překvapivě brzy
  týkat bitcoinu po roce 2106. Nejedná se zatím o konkrétní návrh v podobě
  BIPu. Vyžadovalo by to vyřešit mnoho dílčích problémů souvisejících s časovými
  zámky a dalšími oblastmi bitcoinového ekosystému. Návrh [BitBlend][bb 2024]
  z ledna 2024 je jedním z možných konkrétních řešení.

- **Zmírnění omezení časových razítek v [BIP54][] pro možný 2106 soft fork**: Josh Doman
  zaslal příspěvek do [emailové skupiny][jd ml bip54 ts] Bitcoin-Dev a fóra
  [Delving Bitcoin][jd delving bip54 ts] s dotazem, zda by stálo za snahu
  upravit návrh [pročištění konsenzu][topic consensus cleanup] tak, aby byl
  shovívavější k neobvyklým časovým razítkům bloku, což by umožnilo
  nasadit řešení problému přetečení časového razítka bloku v roce 2016 pomocí
  případného soft forku. ZmnSCPxj již v roce 2021 podobnou myšlenku
  [představil][zman ml ts2106]. Diskuze v obou fórech se soustředila na otázku,
  zda vyhýbání se hard forku stojí za námahu, když existují pádné inženýrské
  důvody, proč o něj usilovat. Greg Maxwell [napsal][gm delving bip54], že
  riziko neopravení útoků [ohýbáním času][topic time warp], jehož řešení
  si [BIP54][] klade za cíl, představuje dostatečný důvod, proč se o
  zmírnění omezení nepokoušet.

- **Ochrana před CTV pastí**: Chris Stewart zaslal do fóra
  Delving Bitcoin [příspěvek][cs delving ctv] diskutující nebezpečnou past (footgun)
  v [`OP_CHECKTEMPLATEVERIFY` (CTV)][topic op_checktemplateverify]. Pokud je na
  `scriptPubKey`, který bezpodmínečně vyžaduje CTV haš, zaslána částka nižší
  než součet výstupních částek určených v jednovstupovém CTV haši, je výsledný
  výstup natrvalo neutratitelný. Navrhuje, že tomu mohou uživatelé CTV
  zabránit, pokud by všechny jejich CTV haše zavazovaly dvěma nebo více vstupům.
  Tímto způsobem je vždy možné zkonstruovat dodatečný vstup, díky kterému
  lze takové výstupy utratit.

  Greg Sanders ve své odpovědi přednesl některá omezení tohoto přístupu a
  1440000bytes zmínil, že toto je možné pouze, pokud je šablona následné
  transakce bezpodmínečně vynucena. Dle Grega Maxwella bychom se z tohoto
  důvodu měli vyhnout celé třídě [kovenantů][topic covenants] používajících
  šablony transakcí. Brandon Black potvrdil, že používaní CTV na příjmové adresy
  je vskutku rizikové a že jiný opkód, jako [`OP_CHECKCONTRACTVERIFY`][topic matt]
  ([BIP443][]), by v kombinaci s CTV umožnil bezpečnější aplikace.

- **Setkání o aktivaci CTV**: Vývojář 1440000bytes [uspořádal][fd0 ml ctv]
  setkání o [aktivaci][ctv notes1] CTV ([BIP119][]). Účastníci souhlasili,
  že klient aktivující CTV by měl používat [BIP9][] a konzervativní parametry
  (tedy s dlouhými signalizačními a aktivačními fázemi). V době psaní zpravodaje
  se v emailové skupině nevyjádřili žádní jiní vývojáři.

- **`OP_CHECKCONSOLIDATION` umožní levnější konsolidace**: billymcbip
  [navrhl][bmb delving cc] nový opkód určený pro konsolidace.
  `OP_CHECKCONSOLIDATION` (CC) by vrátil `1` pouze, pokud byl spuštěn na vstupu
  se stejným `scriptPubKey` jako předchozí vstup ve stejné transakci. Mnoho
  se diskutovalo o nutnosti používat stejný `scriptPubKey`, což by navádělo
  k opakovanému používání adres a narušování soukromí. Brandon Black navrhl
  podobnou (avšak ne tak prostorově optimální) funkcionalitu použitím
  `OP_CHECKCONTRACTVERIFY` ([BIP443][]). Tento návrh je podobný i [jinému][news379
  civ], který navrhl Tadge Dryja během práce na `OP_CHECKINPUTVERIFY`, avšak je
  výrazně úspornější a méně obecný.

- **Bitcoinové podpisy založené na hašování v postkvantové budoucnosti**: Mikhail Kudinov
  a Jonas Nick zaslali do emailové skupiny Bitcoin-Dev [příspěvek][mk ml hash]
  popisující jejich práci vyhodnocující podpisy založené na hašování
  pro použití v bitcoinu. Nalezli slibné příležitosti pro optimalizaci velikosti
  podpisů v porovnání se současnými standardními přístupy, ale nenalezli
  vhodné alternativy k [BIP32][], [BIP327][] či [FROST][news315 frost].
  Několik vývojářů se zapojilo do diskuze o tomto projektu i o jiných schématech
  [postkvantového podepisování][topic quantum resistance] a o možných směrech
  budoucího vývoje.

  Též se diskutovalo, zda je vhodné porovnávat nové mechanismy ověřování
  podpisů dle počtu procesorových cyklů na bajt nebo na podpis. Používání
  cyklů na bajt se jeví lépe použitelné, pokud by bylo ověřování nových
  podpisů omezeno stávajícími váhovými limity a multiplikátory, a to za cenu nižší
  propustnosti plateb. Cykly na podpis by byly příhodnější, pokud by nové podpisy
  měly i nové limity umožňující propustnost plateb blízkou současné.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BTCPay Server 2.3.0][] je vydáním tohoto oblíbeného platebního procesoru s možností
  vlastního hostování. Do uživatelského rozhraní a API přidává novou funkci Subscriptions
  (viz [zpravodaj č. 379][news379 btcpay], _angl._) a vylepšuje žádosti o platbu.
  Též obsahuje několik dalších novinek a oprav chyb.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._
[BINANAs][binana repo]._

- [Bitcoin Core #33657][] přináší nové RESTové rozhraní
  `/rest/blockpart/<BLOCKHASH>.bin?offset=X&size=Y`, které vrací část bajtů
  bloku. Umožní externím indexům jako Electrs obdržet pouze konkrétní transakce
  namísto stahování celého bloku.

- [Bitcoin Core #32414][] přidává pravidelně se opakující zapsání mezipaměti UTXO
  na disk během opakovaného indexování, stejně jako se již děje během úvodního stahování
  bloků. Dříve došlo k zapsání na disk až po dosažení vrcholu řetězce, což v případě
  pádu aplikace a velké `dbcache` mohlo znamenat zmařenou práci.

- [Bitcoin Core #32545][] nahrazuje dřívější algoritmus linearizace clusterů
  (viz [zpravodaj č. 314][news314 cluster]) algoritmem linearizace koster grafu
  (spanning-forest linearization, SFL) navrženým pro efektivnější zpracování
  náročných clusterů. Testování na historických datech z mempoolů ukazuje,
  že nový algoritmus umí linearizovat všechny nalezené clustery s až 64
  transakcemi v desítkách milisekund. Jedná se o součást projektu
  [mempoolu clusterů][topic cluster mempool].

- [Bitcoin Core #33892][] uvolňuje pravidla přeposílání, aby umožňovala příležitostné
  [přeposílání balíčků][topic package relay] s jedním rodičem a jedním potomkem
  (1p1c), kde rodič platí na poplatcích méně, než je minimum pro přeposílání,
  aniž by tato rodičovská transakce musela být [TRUC][topic v3 transaction relay].
  Jednotkový poplatek balíčku musí přesáhnout výši minimálního poplatku pro přeposílání
  a potomek nesmí mít žádné další potomky s poplatkem pod minimem. Dříve bylo
  toto možné pouze u TRUC transakcemi, aby bylo jednodušší rozhodování o
  ořezávání mempoolu; s [mempoolem clusterů][topic cluster mempool] to však již
  není potřeba.

- [Core Lightning #8784][] přidává do RPC příkazu `xpay` (viz [zpravodaj č.
  330][news330 xpay]) pole `payer_note`, které plátcovi umožní během žádosti o fakturu
  přidat k platbě popisek. Příkaz `fetchinvoice` již podobné pole `payer_note` obsahuje,
  tato změna ho tedy přidává i do `xpay` a tyto dvě hodnoty spojuje dohromady.

- [LND #9489][] a [#10049][lnd #10049] přinášejí experimentální
  gRPC podsystém `switchrpc` s příkazy `BuildOnion`, `SendOnion` a `TrackOnion`, které
  umožní externímu software zajistit hledání cesty a správu životního cyklu plateb,
  zatímco LND se postará o doručování [HTLC][topic htlc]. Funkcionalita je
  ukryta pod příznakem kompilátoru `switchrpc` (ve výchozím nastavení je vypnutý).
  [LND #10049][] konkrétně přidává základy pro sledování externí činnosti a připravuje
  prostor pro budoucí idempotentní verzi. V současnosti je používání bezpečné pouze
  při jediné entitě používající tento podsystém v jeden okamžik, jinak hrozí
  ztráta prostředků.

- [BIPs #2051][] provádí několik změn ve specifikaci [BIP3][]: opět odstraňuje
  nedávno přidané doporučení proti používání LLM (viz [zpravodaj č. 378][news378
  bips2006], _angl._), rozšiřuje formáty referenčních implementací, přidává historii
  změn a několik dalších zlepšení a objasnění.

- [BOLTs #1299][] odstraňuje ze specifikace [BOLT3][] nejasnou poznámku o používání
  `localpubkey` (bod na eliptické křivce, odlišný pro každý commitment) ve
  výstupu, který platí protistraně `to_remote`. S volbou `option_static_remotekey`
  to již není platné, protože `to_remote` výstup by měl používat příjemcův statický
  `payment_basepoint`, aby bylo možné zachránit prostředky bez `localpubkey`.

- [BOLTs #1305][] objasňuje specifikaci [BOLT11][] ohledně pole `n` (33bajtový
  veřejný klíč uzlu příjemce), které není povinné. Dřívější verze nesprávně tvrdila,
  že pole je povinné.

{% include snippets/recap-ad.md when="2026-01-06 17:30" %}
{% include references.md %} {% include linkers/issues.md v=2 issues="33657,32414,32545,33892,8784,9489,10049,2051,1299,1305" %}
[news315 frost]: /cs/newsletters/2024/08/09/#navrh-bipu-na-bezskriptove-prahove-podpisy
[mk ml hash]: https://groups.google.com/g/bitcoindev/c/gOfL5ag_bDU/m/0YuwSQ29CgAJ
[fd0 ml ctv]: https://groups.google.com/d/msgid/bitcoindev/CALiT-Zr9JnLcohdUQRufM42OwROcOh76fA1xjtqUkY5%3Dotqfwg%40mail.gmail.com
[ctv notes1]: https://ctv-activation.github.io/meeting/18dec2025.html
[news379 civ]: /en/newsletters/2025/11/07/#post-quantum-signature-aggregation
[bmb delving cc]: https://delvingbitcoin.org/t/op-cc-a-simple-introspection-opcode-to-enable-cheaper-consolidations/2177
[cs delving ctv]: https://delvingbitcoin.org/t/understanding-and-mitigating-a-op-ctv-footgun-the-unsatisfiable-utxo/1809
[bb 2024]: https://bitblend2106.github.io/bitcoin/BitBlend2106.pdf
[ah ml uint64 ts]: https://groups.google.com/g/bitcoindev/c/PHZEIRb04RY/m/ryatIL5RCwAJ
[jd ml bip54 ts]: https://groups.google.com/g/bitcoindev/c/L4Eu9bA5iBw/m/jo9RzS-HAQAJ
[jd delving bip54 ts]: https://delvingbitcoin.org/t/modifying-bip54-to-support-future-ntime-soft-fork/2163
[zman ml ts2106]: https://gnusha.org/pi/bitcoindev/eAo_By_Oe44ra6anVBlZg2UbfKfzhZ1b1vtaF0NuIjdJcB_niagHBS-SoU2qcLzjDj8Kuo67O_FnBSuIgskAi2_fCsLE6_d4SwWq9skHuQI=@protonmail.com/
[gm delving bip54]: https://delvingbitcoin.org/t/modifying-bip54-to-support-future-ntime-soft-fork/2163/6
[halseth post]: https://delvingbitcoin.org/t/building-a-vault-using-blinded-co-signers/2141
[halseth prototype]: https://github.com/halseth/blind-vault
[blinded musig]: https://github.com/halseth/ephemeral-signing-service/blob/main/doc/general.md
[peer neg ml]: https://groups.google.com/g/bitcoindev/c/DFXtbUdCNZE
[news366 template]: /en/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[feature negotiation ml]: https://gnusha.org/pi/bitcoindev/CAFp6fsE=HPFUMFhyuZkroBO_QJ-dUWNJqCPg9=fMJ3Jqnu1hnw@mail.gmail.com/
[towns bip]: https://github.com/ajtowns/bips/blob/202512-p2p-feature/bip-peer-feature-negotiation.md
[verack]:https://developer.bitcoin.org/reference/p2p_networking.html#verack
[BTCPay Server 2.3.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.0
[news379 btcpay]: /en/newsletters/2025/11/07/#btcpay-server-6922
[news314 cluster]: /cs/newsletters/2024/08/02/#bitcoin-core-30126
[news330 xpay]: /cs/newsletters/2024/11/22/#core-lightning-7799
[lnd #10049]: https://github.com/lightningnetwork/lnd/pull/10049
[news378 bips2006]: /en/newsletters/2025/10/31/#bips-2006
