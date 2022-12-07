---
title: 'Zpravodaj „Bitcoin Optech” č. 229'
permalink: /cs/newsletters/2022/12/07/
name: 2022-12-07-newsletter-cs
slug: 2022-12-07-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden popisujeme implementaci dočasných anchor výstupů a přinášíme
naše pravidelné rubriky se souhrnem sezení Bitcoin Core PR Review Club,
oznámeními o nových vydáních a popisem významných změn populárních páteřních
bitcoinových projektů.

## Novinky

- **Implementace dočasných anchor výstupů:** Greg Sanders v emailové skupině
  Bitcoin-Dev [oznámil][sanders ephemeral], že vytvořil implementaci
  svého nápadu na dočasné („ephemeral”) anchor výstupy (viz [zpravodaj č. #223][news223
  anchors], *angl.*). [Anchor výstupy][topic anchor outputs] jsou existující
  technika dostupná díky [CPFP carve out][topic cpfp carve out] a používaná
  v LN protokolu k zajištění, aby obě strany kontraktu mohly pomocí [CPFP][topic
  cpfp] navýšit poplatek transakcí spojených s tímto kontraktem. Anchor výstupy
  mají několik nevýhod; některé principální (viz [zpravodaj č. #224][news224 anchors],
  *angl.*), avšak jiné mohou být řešeny.

  Dočasné anchor výstupy staví na návrhu [přeposílání v3 transakcí][topic
  v3 transaction relay]. Díky němu mohou v3 transakce obsahovat výstup
  s nulovou hodnotou platící skriptu, který je v podstatě jen `OP_TRUE`. Kdokoliv
  s utratitelným UTXO může takové transakci navýšit poplatek pomocí CPFP.
  Potomek transakce, který navýšení provádí, může sám mít poplatek navýšen pomocí
  RBF kýmkoliv jiným s utratitelným UTXO. To by v kombinaci s dalšími částmi návrhu
  přeposílání v3 transakcí mělo odstranit veškeré obavy o [transaction pinning útoky][topic
  transaction pinning], tedy útoky na transakce protokolů chytrých kontraktů citlivých na
  načasování.

  Protože poplatek transakce s dočasným anchor výstupem může být navýšen kýmkoliv,
  mohou být použity na protokoly chytrých kontraktů s více než dvěma účastníky.
  Existující pravidlo carve out v Bitcoin Core funguje spolehlivě pouze pro dva
  účastníky a [předchozí pokusy][bitcoin core #18725] tento počet navýšit vyžadovaly
  stanovení maximálního počtu účastníků.

  Sandersova [implementace][bitcoin core #26403] dočasných anchor výstupů umožňuje
  začít tento nápad testovat spolu s dalšími funkcemi přeposílání v3 transakcí
  dříve implementovanými autorem tohoto návrhu.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Navyš poplatky nepotvrzených rodičů na úroveň cílového poplatku][review club 26152]
je PR autorů Xekyo (Murch) a glozow, který zvyšuje přesnost kalkulace poplatku
v případě, kdy jsou jako vstupy zvoleny nepotvrzená UTXO. Bez této změny dochází
k nastavení příliš nízkého poplatku, je-li některá nepotvrzená transakce použita
jako vstup a je-li její jednotkový poplatek nižší než poplatek právě vytvářené
transakce. PR řeší tento problém přidáním dostatečného poplatku, aby tato
zdrojová transakce s nízkým poplatkem dosáhla stejného cílového jednotkového
poplatku jako nová transakce.

I bez tohoto PR se proces výběru mincí snaží vyvarovat utrácení nepotvrzených
transakcí s nízkým jednotkovým poplatkem. Změna přinese výhody v případech,
kdy není zbytí.

Úprava poplatku na základě těchto rodičovských transakcí se ukázala být podobná
výběru transakcí, které budou začleněny do bloku; proto tato změna přináší novou
třídu nazvanou `MiniMiner`.

Sezení se [událo][review club 26152] během dvou [týdnů][review club
26152-2].

{% include functions/details-list.md
  q0="Jaký problém tento PR řeší?"
  a0="Odhad poplatku peněženkou nebere v potaz potřebu platit také všechny nepotvrzené
      rodičovské transakce, které mají nastavený nižší poplatek, než je cílový."
  a0link="https://bitcoincore.reviews/26152#l-30"

  q1="Z čeho se skládá cluster transakce?"
  a1="Množina transakcí obsahuje samotnou transakci a všechny „připojené”
     transakce. Zahrnují všechny předky i potomky, ale též sourozence a
	 sestřenice, tedy potomky rodičů, kteří nemusí být ani předky, ani potomky
	 dané transakce."
  a1link="https://bitcoincore.reviews/26152#l-72"

  q2="Tento PR přináší `MiniMiner`, který duplikuje některé algoritmy
      skutečné těžby. Nebylo by lepší spojit tyto dvě implementace?"
  a2="Potřebujeme pracovat pouze s clusterem, nikoliv s kompletním mempoolem.
      Též nepotřebujeme provádět žádné kontroly jako `BlockAssembler`.
	  Někdo dokonce navrhl učinit všechny výpočty bez zámku mempoolu.
	  Museli bychom také změnit block assembler, aby spíše sledoval navýšení
	  poplatků než konstrukci šablony bloku. Množství práce potřebné pro
	  refaktorování by bylo stejné jako přepsání."
  a2link="https://bitcoincore.reviews/26152#l-94"

  q3="Proč vyžaduje `MiniMiner` kompletní cluster? Nestačil by jen výčet
      všech předků každé transakce?"
  a3="Někteří předci mohou mít již poplatek navýšený jiným potomkem, a není
      tedy třeba dalšího navyšování. Proto potřebujeme ve výpočtech zahrnout
	  i tyto potomky."
  a3link="https://bitcoincore.reviews/26152#l-129"

  q4="Má-li transakce X vyšší jednotkový poplatek předků než nezávislá transakce
      Y, je možné, že by těžař upřednostnil Y před X (tj. zařadil Y do bloku dříve
	  než X)?"
  a4="Ano. Má-li některý z předků transakce Y, které mají nízké poplatky, i jiné potomky
      s vysokým poplatkem, Y za předky platit nemusí. Množina předků transakce Y
	  je aktualizována, aby byly vyloučeny transakce, které v důsledku navyšují poplatky
	  předků transakce Y."
  a4link="https://bitcoincore.reviews/26152#l-169"

  q5="`CalculateBumpFees()` může nadhodnotit, podhodnotit, obé či ani jedno? O kolik?"
  a5="K nadhodnocení dojde, jsou-li vybrány dva výstupy s překrývajícími se předky,
      neboť každé navýšení bere v potaz své předky nezávisle a neuvažuje se možnost
	  společných předků. Účastníci došli k závěru, že podhodnocení navýšení poplatků
	  možné není."
  a5link="https://bitcoincore.reviews/26152#l-194"

  q6="`MiniMiner`obdrží seznam UTXO (výstupů), které by peněženka chtěla utratit.
      Jakých pěti možných stavů může daný výstup nabývat?"
  a6="Může být (1) potvrzený a neutracený, (2) potvrzený a právě utrácený existující
      transakcí v mempoolu, (3) nepotvrzený (v mempoolu) a neutracený, (4) nepotvrzený,
	  ale již utracený existující transakcí v mempoolu nebo (5) to může být výstup,
	  o kterém jsme nikdy neslyšeli."
  a6link="https://bitcoincore.reviews/26152-2#l-21"

  q7="Jaký přístup zaujímá commit \"Navyš poplatky nepotvrzených rodičů na úroveň cílového
      poplatku\"?"
  a7="Tento commit je hlavní změnou chování tohoto PR. `MiniMiner` provádí výpočet navýšení
      poplatků (tak, aby příslušní předci nabyli cílového jednotkového poplatku) každého
	  UTXO a odečítá je od jejich efektivní hodnoty. Poté následuje běžný výběr mincí."
  a7link="https://bitcoincore.reviews/26152-2#l-100"

  q8="Jak tento PR řeší utrácení nepotvrzených UTXO s překrývajícími se předky?"
  a8="Po výběru mincí spustíme nad jeho výsledkem variantu algoritmu `MiniMiner`u.
      Tím obdržíme přesnou hodnotu navýšení poplatku. Pokud je kvůli společným
	  předkům navýšení příliš velké, můžeme poplatek snížit navýšením zbytku
	  po platbě (pokud existuje) nebo přidáním zbytku (pokud neexistuje)."
  a8link="https://bitcoincore.reviews/26152-2#l-111"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BTCPay Server 1.7.1][] je nejnovějším vydáním nejrozšířenějšího serveru
  pro zpracování bitcoinových plateb.

- [Core Lightning 22.11][] je příští hlavní verzí CLN. Je také první verzí,
  která bude používat nový systém číslování verzí.[^semver] Součástí vydání
  je několik nových funkcí včetně nového správce rozšíření a opravy několika
  chyb.

- [LND 0.15.5-beta][] je údržbové vydání LND. Dle poznámek k vydání obsahuje
  pouze opravy drobných chyb.

- [BDK 0.25.0][] je novým vydáním této knihovny pro tvorbu peněženek.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19762][] upravuje rozhraní RPC (a potažmo i `bitcoin-cli`)
  přidáním možnosti použít poziční i jmenné argumenty dohromady. Tato
  změna usnadňuje použití jmenných parametrů bez nutnosti jmenovat je
  všechny.

- [Core Lightning #5722][] přidává [dokumentaci][grpc doc] o používání rozšíření
  GRPC rozhraní.

- [Eclair #2513][] upravuje způsob používání peněženek Bitcoin Core,
  aby zajistil, že vždy používají [bech32][topic bech32] adresy. Je to
  důsledkem změny [Bitcoin Core #23789][] (viz [zpravodaj č. 181][news181
  bcc23789], *angl.*), ve které byl adresovány obavy o ztrátu soukromí
  uživateli nových typů výstupů (např. [taproot][topic taproot]). Nastavil-li
  uživatel v předchozích verzích ve své peněžence taproot jako výchozí typ
  adresy, byly automaticky nastaveny na taproot také adresy pro zaslání zbytku
  po platbě („drobné”). Poslal-li platbu někomu, kdo taproot nepoužíval,
  mohly třetí strany snadno odhadnout, který výstup byla platba (netaproot)
  a co byly drobné (taproot). Po zmíněné změně se Bitcoin Core snaží použít
  pro zbytek stejný druh výstupu jako pro platbu. Zbytek po platbě na nativní
  segwit adresu by tak byl poslán též na nativní segwit výstup.

  LN protokol však vyžaduje určité druhy výstupů. Například P2PKH výstup nemůže
  být použit na otevření LN kanálu. Z tohoto důvodu musí uživatelé Eclair s
  Bitcoin Core zajistit, aby negenerovali adresy pro zaslání zbytku nekompatibilní
  s LN.

- [Rust Bitcoin #1415][] začíná používat [Kani Rust Verifier][], který umožní
  dokázat některé vlastnosti kódu. Doplňuje tak další testy prováděné v rámci
  průběžné integrace, jako je např. fuzzing.

- [BTCPay Server #4238][] přidává možnost refundovat fakturu pomocí Greenfield API,
  což je novější API odlišné od původního API inspirovaného BitPayem.

## Poznámky

[^semver]:
    Předchozí vydání našeho zpravodaje tvrdila, že Core Lightning používá
	[sémantické verzování][semantic versioning] a že nové verze jej budou
	používat i nadále. Rusty Russell [vysvětlil][rusty semver], proč se nemůže
	CLN zcela držet tohoto systému. Děkujeme Mattovi Whitlockovi za upozornění
	na naši chybu.

{% include references.md %}
{% include linkers/issues.md v=2 issues="19762,5722,2513,1415,4238,18725,26403,23789" %}
[lnd 0.15.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta
[core lightning 22.11]: https://github.com/ElementsProject/lightning/releases/tag/v22.11
[btcpay server 1.7.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.7.1
[bdk 0.25.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.25.0
[semantic versioning]: https://semver.org/lang/cs/spec/v2.0.0.html
[grpc doc]: https://github.com/cdecker/lightning/blob/20bc743840bf5d948efbf62d32a21a00ed233e31/plugins/grpc-plugin/README.md
[news181 bcc23789]: /en/newsletters/2022/01/05/#bitcoin-core-23789
[kani rust verifier]: https://github.com/model-checking/kani
[news223 anchors]: /en/newsletters/2022/10/26/#ephemeral-anchors
[news224 anchors]: /en/newsletters/2022/11/02/#anchor-outputs-workaround
[news220 v3tx]: /en/newsletters/2022/10/05/#proposed-new-transaction-relay-policies-designed-for-ln-penalty
[sanders ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-November/021222.html
[review club 26152]: https://bitcoincore.reviews/26152
[review club 26152-2]: https://bitcoincore.reviews/26152-2
[rusty semver]: https://github.com/ElementsProject/lightning/issues/5716#issuecomment-1322745630
