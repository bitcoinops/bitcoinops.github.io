---
title: 'Zpravodaj „Bitcoin Optech” č. 230'
permalink: /cs/newsletters/2022/12/14/
name: 2022-12-14-newsletter-cs
slug: 2022-12-14-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn návrhu na změnu protokolu LN, která může
zlepšit kompatibilitu s továrnami kanálů, popisujeme program na zamezení
některých důsledků útoků zahlcení kanálu bez nutnosti měnit LN protokol
a nabízíme odkaz na webovou stránku monitorující nahrazené transakce
bez signalizace. Též nechybí naše pravidelné rubriky s oznámeními o vydání
software, souhrnem oblíbených otázek a odpovědí Bitcoin Stack Exchange a
popisem významných změn populárních páteřních bitcoinových projektů.

## Novinky

- **Návrh na LN protokol pro továrny:** John Law [zaslal][law factory]
  do emailové skupiny Lightning-Dev popis protokolu optimalizovaného
  na vytváření [továren kanálů][topic channel factories] („channel
  factory”). Továrny kanálů umožňují více uživatelům mezi sebou otevřít
  (bez nutnosti navzájem si důvěřovat) množství kanálů v rámci
  jediné transakce. Například 20 uživatelů může dohromady vytvořit
  jedinou transakci, která sice bude desektrát větší než obvyklá otevírací
  transakce, ale která otevře dohromady 190 kanálů.

  Law poznamenává, že existující protokol LN kanálů (obecně zvaný
  LN–penalty) přináší kanálům otevřeným v rámci továrny dva problémy:

    - *Požadavek na dlouhé expirace HTLC:* možnost provést akci bez nutnosti
      důvěry vyžaduje, aby byl kterýkoliv účastník továrny schopen odstoupit
      a obdržet zpět své prostředky. Aby toho dosáhli, musí účastníci
      publikovat aktuální bilanci na blockchainu. Je však potřeba zajistit,
      aby nikdo nepublikoval dřívější stav, např. takový, za kterého
      měli na své straně více peněz. Původní návrh na továrny k tomu
	  využívá transakce s časovým zámkem, které zajistí, že novější stav
	  je potvrzen rychleji než starší.

      Důsledkem tohoto mechanismu, jak popisuje Law, je, že jakákoliv
	  LN platba (tj. [HTLC][topic htlc]), která je směrována kanálem
	  z továrny, musí poskytnout dostatečně dlouhý čas na expiraci časového
	  zámku posledního stavu, aby mohla být továrna jednostranně zavřena.
	  Ještě horší je, že toto platí pro každou továrnu, přes kterou
	  je platba směrována. Například je-li platba směrována přes deset
	  továren, kde má každá z nich jednodenní expiraci, může se stát, že bude
	  tato platba [pozdržena][topic channel jamming attacks], úmyslně
	  či ne, na deset dní (nebo déle v závislosti na nastavení HTLC).

    - *Všichni, nebo nic:* aby mohly továrny dosáhnout maximální
	  efektivnosti, musí všechny její kanály být též uzavřeny v jediné
	  transakci. Spolupráce na uzavření není možná, je-li některý
	  z původních účastníků nedostupný; se zvyšujícím se počtem
	  účastníků se šance na jednoho nedostupného blíží 100 % a možnost
	  efektivních továren tak klesá.

	  Law se odkazuje na předchozí práci – např. návhy
	  `OP_TAPLEAF_UPDATE_VERIFY` a `OP_EVICT` (viz zpravodaj
	  [č. 166][news166 tluv] a [č. 189][news189 evict], *angl.*), ve které
	  mohla továrna zůstat funkční, i když ji jeden z účastníků chtěl opustit
	  nebo zůstal nedostupný.

    Law představuje tři návrhy protokolu, které tyto problémy řeší. Všechny
	jsou založené na jeho předchozím návrhu na *nastavitelné pokuty*,
	o kterém [informoval][law tp] v říjnu. Ten nabízí možnost oddělit
	mechanismus vynucování (pokuty) od správy ostatních prostředků. Tento
	předchozí návrh ještě neobdržel  komentáře. V době psaní tohoto článku
	nebyla otevřena diskuze ani pod jeho novým návrhem. Budou-li návrhy
	přesvědčivé, měly by na rozdíl od jiných výhodu v možnosti použít
	stávající pravidla bitcoinového konsenzu.

- **Lokální zahlcení k zamezení vzdáleného zahlcení:** Joost Jager
  [zaslal][jager jam] do emailové skupiny Lightning-Dev odkaz a vysvětlení
  svého projektu [CircuitBreaker][]. Tento program, navržený tak, aby byl
  kompatibilní s LND, hlídá maximální počet nevyřízených plateb ([HTLC][topic
  htlc]), které uzel přeposílá jménem svých spojení. Uvažme například
  nejhorší možných scénář útoku zahlcením HTLC:

  ![Ilustrace dvou různých utoků zahlcením](/img/posts/2020-12-ln-jamming-attacks.png)

  V současném LN protokolu má Alice principiální omezení [483 nevyřízených HTLC][483
  pending htlcs], které může současně přeposílat. Pokud by však používala
  CircuitBreaker k omezení kanálu s Mallorym na 10 současných nevyřízených HTLC,
  její kanál s Bobem (není na obrázku) a všechny další kanály v tomto okruhu
  by byly chráněny před všemi kromě prvních deseti HTLC, které Mallory udržuje
  v nevyřízeném stavu. To by významně snížilo efektivitu Malloryho útoku,
  protože by to po něm vyžadovalo otevření mnohem většího počtu kanálů (a tedy
  zvýšení nákladů), aby zasáhl stejný počet HTLC slotů.

  I když byl původně CircuitBreaker navržen tak, aby jednoduše odmítl
  přijmout HTLC nad rámec svého omezení, Jager poznamenal, že nedávno
  přidal volitelnou možnost přidání jakéhokoliv HTLC do fronty namísto
  okamžitého odmítnutí nebo přeposlání. Jakmile spadne počet nevyřízených
  HTLC v kanálu pod jeho limit, CircuitBreaker přepošle nejstarší
  neexpirovaný HTLC ve frontě. Jager popisuje dvě výhody tohoto
  přístupu:

    - *Backpressure:* odmítne-li uzel uprostřed okruhu HTLC, všechny uzly
	  v okruhu (ne jen ty následující) mohou použít tento HTLC slot a
	  prostředky na přeposlání další platby. To znamená, že motivace
	  Alice odmítnout více než 10 HTLC od Malloryho je omezená: může
	  jednoduše doufat, že jiný uzel dále v okruhu používá CircuitBreaker
	  či podobný software.

      Pokud však následující uzel (řekněme Bob) používá CircuiBreaker
	  k uložení přebytečných HTLC do fronty, mohl by Mallory i tak
	  vyčerpat sloty a prostředky Alice, i když by si Bob a následující
	  uzly zachovaly stejné výhody jako nyní (s výjimkou možného
	  navýšení nákladů na uzavření kanálu v určitých případech; pro více
	  podrobností viz Jagerův email nebo dokumentace CircuitBreakeru).
	  To vyvíjí drobný tlak na Alici, aby CircuitBreaker nebo podobný
	  program používala.

    - *Původce selhání:* současný LN protokol dává v mnoha případech
	  odesílateli možnost identifikovat kanál, který odmítl přeposlat
	  platbu. Některé implementace se snaží takovému kanálu v budoucnu
	  vyhnout. V případě odmítnutí HTLC od zlomyslníků jako Mallory to
	  ze zřejmých důvodů nevadí, odmítne-li však uzel s CircuitBreakerem
	  HTLC od čestných plátců, mohlo by to snížit jejich výdělek nejen z
	  odmítnuté platby, ale i z plateb následujících.

      LN protokol však v současnosti nemá široce používaný způsob
	  určení, který kanál zpozdil HTLC. Zpoždění HTLC tak nese
	  méně vážné důsledky než prosté odmítnutí. Jager poznamenává, že
	  tato výhoda může brzy zmizet, neboť mnoho LN implementací pracuje
	  na podpoře podrobnějších chybových zpráv (viz [zpravodaj č. 224][news224
	  fat], *angl.*).

    Jager nazývá CircuitBreaker „jednoduchý, ale nedokonalý nástroj na
	ochranu před zahlcením kanálu a spamem.” Práce pokračují na nalezení
	a nasazení změn na úrovni protokolu, které by lépe zamezovaly těmto
	útokům, ale CircuitBreaker se vyjímá jako slušné řešení, které je
	kompatibilní se současným LN protokolem a které může kterýkoliv
	uživatel LND hned nasadit. CircuitBreaker je licencovaný pod MIT
	a je konceptuálně jednoduchý, mělo by tedy být možné jej přizpůsobit
	či portovat i na jiné LN implementace.

- **Monitorování full-RBF nahrazování:** vývojář 0xB10C [oznámil][0xb10c rbf]
  v emailové skupině Bitcoin-Dev, že začal poskytovat [veřejně přístupný][rbf mpo]
  monitoring nahrazených transakcí bez signalizace BIP125 v mempoolu jeho uzlu.
  Jeho uzel umožňuje full-RBF nahrazování pomocí konfigurační volby `mempoolfullrbf`
  (viz [zpravodaj č. 208][news208 rbf], *angl.*).

  Uživatelé a služby mohou používat stránku jako indikátor, nakolik
  velcí těžaři potvrzují nahrazené transakce bez signalizace. Připomínáme
  však čtenářům, že nepotvrzené transakce jsou zcela bez záruky, i když
  těžaři, zdá se, zatím nahrazené transakce bez signalizace netěží.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Lily Wallet přidává výběr mincí:**
  Lily Wallet [v1.2.0][lily v1.2.0] přidává algoritmy [výběru mincí][topic coin selection].

- **Vortex vytváří LN kanály z coinjoinu:**
  Uživatelé [Vortexu][vortex github] [otevřeli LN kanály][vortex tweet] na bitcoinovém mainnetu
  za pomoci [taprootu][topic taproot] a [coinjoinových][topic coinjoin] transakcí.

- **Mutiny předvádí možnost LN uzlu v prohlížeči:**
  Vývojáři [předvedli][mutiny tweet] [ukázku][mutiny github] implementace LN uzlu
  běžícího v mobilním prohlížeči pomocí WASM a LDK.

- **Coinkite spouští BinaryWatch.org:**
  Webová stránka [BinaryWatch.org][] ověřuje binárky bitcoinových projektů a
  monitoruje jejich změny. Společnost též provozuje [bitcoinbinary.org][], službu,
  která archivuje [reprodukovatelná sestavení][topic reproducible builds] bitcoinových
  projektů.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Proč je připojení k bitcoinové síti výhradně přes Tor považováno za špatnou praxi?]({{bse}}116146)
  Několik odpovědí vysvětluje, že kvůli nižším nákladům na vytváření Tor adres v porovnání
  s IPv4 nebo IPv6 adresami může být uzel používající pouze Tor snadněji vystaven
  [eclipse útokům][topic eclipse attacks] než uzel vystavený pouze clearnetu nebo kombinaci
  [anonymizačních sítí][topic anonymity networks].

- [Proč dnes nejsou realisticky možné LN kanály s třemi či více účastníky?]({{bse}}116257)
  Murch vysvětluje, že jelikož LN kanály v současnosti používají systém penalizací,
  který v případě nedodržení pravidel pošle *všechny* prostředky poškozené straně,
  bylo by příliš komplikované rozšířit tento systém trestů na více účastníků. Také
  objasňuje fungování [eltoo][topic eltoo] a jeho možnost nakládání s kanály s více
  účastníky.

- [Bude Bitcoin Core moci podepisovat zprávy i se zastaralými peněženkami?]({{bse}}116187)
  Pieter Wuille rozlišuje mezi [odstraněním zastaralých peněženek][news125 legacy
  descriptor wallets] v Bitcoin Core a pokračující podporou pro starší typy adres
  jako P2PKH i v nových peněženkách založených na  [deskriptorech][topic descriptors].
  I když je v současnosti podepisování zpráv možné pouze pro P2PKH adresy, práce na
  [BIP322][topic generic signmessage] by měla umožnit podepisování i jinými typy adres.

- [Jak nastavím multisig s časovým úpadkem?]({{bse}}116035)
  Uživatel Yoda se ptá, jak lze nastavit vícenásobný podpis s časovým úpadkem, tedy
  UTXO, které je během času utratitelné s nižším počtem podpisů. Michael Folkson
  poskytuje příklad s použitím [pravidel][news74 policy miniscript] a [miniscriptu][topic
  miniscript], odkazuje na relevantní zdroje a upozorňuje na chybějící jednoduché
  nástroje.

- [Kdy je miniscriptové řešení poddajné?]({{bse}}116275)
  Antoine Poinsot definuje, co poddajnost („malleability”) znamená v kontextu
  miniscriptu, popisuje statickou analýzu poddajnosti v miniscriptu a prochází
  krok za krokem příkladem z původní otázky.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 24.0.1][] je hlavním vydáním nejpoužívanější implementace
  plného uzlu. Přináší volbu pro konfiguraci RBF ([Replace-By-Fee][topic rbf])
  pravidel uzlu, nové RPC volání `sendall` pro snadné utracení všech prostředků
  v peněžence v jediné transakci (nebo pro vytváření transakcí bez zbytku),
  volání `simulaterawtransaction`, které ověří efekty transakce na peněženku (např.
  se lze ujistit, že coinjoinová transakce pouze sníží celkovou hodnotu peněženky
  o poplatky), možnost vytvářet [deskriptory][topic descriptors] pouze pro sledování,
  které obsahují [miniscriptové][topic miniscript] výrazy s vylepšenou kompatibilitou
  s jiným software, a automatickou aplikaci změn některých nastavení RPC volání
  provedených v GUI. Viz [poznámky k vydání][bcc rn] s úplným výčtem novinek a oprav
  chyb.

  Poznámka: verze 24.0 byla označena a binárky byly vydané, avšak správci projektu
  nikdy tuto verzi neoznámili. Namísto toho pracovali s ostatními přispěvateli
  na řešení [nenadálých chyb][bcc milestone 24.0.1]. Verze 24.0.1 tak byla první
  oznámenou verzí větve 24.x.

- [libsecp256k1 0.2.0][] je prvním tagovaným vydáním této široce používané
  knihovny pro bitcoinové kryptografické operace. [Oznámení][libsecp256k1
  announce] o vydání uvádí: „Po dlouhou dobu probíhal vývoj libsecp256k1
  pouze v master větvi, což vytvářelo nejistotu ohledně kompatibility API
  a stability. Od této doby budeme vytvářet tagovaná vydání po vzoru sémantického
  verzování, kdykoliv budou začleněna relevantní zlepšení. […] Přeskakujeme
  verzi 0.1.0, protože toto číslo bylo po léta nastaveno v našich skriptech
  a nepoukazuje na žádnou jedinečnou množinu zdrojových kódů. Nebudeme vytvářet
  binární vydání, ale budeme v poznámkách o vydání a číslech verzí zohledňovat
  očekávané problémy s kompatibilitou ABI.”

- [Core Lightning 22.11.1][] je menší vydání, které dle požadavku vývojářů dočasně
  vrací některé funkce odstraněné ve verzi 22.11.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25934][] přidává do RPC volání `listsinceblock` volitelný argument `label`.
  Je-li specifikován, volání vrátí pouze transakce odpovídající tomuto štítku.

- [LND #7159][] upravuje RPC volání `ListInvoiceRequest` a `ListPaymentsRequest` přidáním
  parametrů `creation_date_start` a `creation_date_end`, které umožňují filtrovat faktury
  a platby podle data a času.

- [LDK #1835][] přidává zachyceným HTLC jmenný prostor falešných krátkých identifikátorů
  kanálu („short channel identifier”, SCID), což umožní poskytovatelům lightningových služeb
  („lightning service providers”, LSP) vytvářet koncovým uživatelům [just-in-time][topic jit
  routing] (JIT) kanály pro přijímání lightningových plateb. To lze učinit přidáním falešných
  doporučených tras do faktury, které LDK rozpozná podobně jako [phantom platby][LDK phantom
  payments] (viz [zpravodaj č.188][news188 phantom], *angl.*). LDK poté generuje událost,
  která dává LSP možnost otevřít JIT kanál. LSP potom může přeposlat platbu přes právě otevřený
  kanál či ji stornovat.

- [BOLTs #1021][] umožňuje chybovým zprávám routování připojit [TLV][] stream, který
  může v budoucích verzích obsahovat dodatečné informace o chybě. Jedná se o první
  krok v cestě za [detailními chybovými hláškami][news224 fat] podle návrhu [BOLTs #1044][].

## Krásné svátky!

Toto je letošní poslední pravidelné číslo našeho zpravodaje. Ve středu 21.
prosince uveřejníme páté vydání roku ve zkratce. Pravidelná vydání
budou pokračovat ve středu 4. ledna.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25934,7159,1835,1021,1044" %}
[bitcoin core 24.0.1]: https://bitcoincore.org/bin/bitcoin-core-24.0.1/
[bcc rn]: https://bitcoincore.org/en/releases/24.0.1/
[bcc milestone 24.0.1]: https://github.com/bitcoin/bitcoin/milestone/59?closed=1
[libsecp256k1 0.2.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.2.0
[libsecp256k1 announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021271.html
[core lightning 22.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v22.11.1
[news224 fat]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
[law factory]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-December/003782.html
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[news189 evict]: /en/newsletters/2022/03/02/#proposed-opcode-to-simplify-shared-utxo-ownership
[law tp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003732.html
[jager jam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-December/003781.html
[circuitbreaker]: https://github.com/lightningequipment/circuitbreaker
[0xb10c rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021258.html
[rbf mpo]: https://fullrbf.mempool.observer/
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[tlv]: https://github.com/lightning/bolts/blob/master/01-messaging.md#type-length-value-format
[483 pending htlcs]: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md#rationale-7
[news188 phantom]: /en/newsletters/2022/02/23/#ldk-1199
[LDK phantom payments]: https://lightningdevkit.org/blog/introducing-phantom-node-payments/
[news125 legacy descriptor wallets]: /en/newsletters/2020/11/25/#how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work
[news74 policy miniscript]: /en/newsletters/2019/11/27/#what-is-the-difference-between-bitcoin-policy-language-and-miniscript
[lily v1.2.0]: https://github.com/Lily-Technologies/lily-wallet/releases/tag/v1.2.0
[vortex tweet]: https://twitter.com/benthecarman/status/1590886577940889600
[vortex github]: https://github.com/ln-vortex/ln-vortex
[mutiny tweet]: https://twitter.com/benthecarman/status/1595395624010190850
[mutiny github]: https://github.com/BitcoinDevShop/mutiny-web-poc
[BinaryWatch.org]: https://binarywatch.org/
[bitcoinbinary.org]: https://bitcoinbinary.org/
