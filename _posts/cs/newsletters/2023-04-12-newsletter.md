---
title: 'Zpravodaj „Bitcoin Optech” č. 246'
permalink: /cs/newsletters/2023/04/12/
name: 2023-04-12-newsletter-cs
slug: 2023-04-12-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis diskuze o LN splicingu a odkazujeme na
návrh BIP pro doporučenou terminologii v rámci transakcí. Též nechybí
naše pravidelné rubriky se souhrnem sezení Bitcoin Core PR Review Club,
oznámeními o vydáních, včetně bezpečnostní aktualizace libsecp256k1,
a popisem významných změn v populárních páteřních bitcoinových
projektech.

## Novinky

- **Diskuze o specifikaci splicingu:** několik vývojářů LN informovalo
  tento týden emailovou skupinu Lightning-Dev o pokračující práci na
  [návrhu specifikace][bolts #863] [splicingu][topic splicing], díky
  kterému je možné utratit část prostředků LN kanálu na blockchainu
  (splice-out) či prostředky z blockchainu přidat do LN kanálu
  (splice-in). Kanál může během čekání na dostatečné množství konfirmací
  splicingové transakce nadále fungovat bez přerušení.

  Na následujícím diagramu jsou šedě označeny potvrzené transakce a
  přerušovanou čarou transakce, které prozatím zůstávají offchain.

  {:.center}
  ![Splicing transaction flow](/img/posts/2023-04-splicing1.dot.png)

  Některé z diskuzí:

  - *Které podpisy commitmentů mají být poslány:* po vytvoření splicu
    bude uzel držet paralelní commitment transakce; jedna utrácí
    původní otvírací výstup a druhá utrácí každý nový otvírací výstup
    všech nevyřízených spliců. Během každé změny stavu kanálu musí
    být aktualizovány také všechny paralelní commitment transakce.
    Jednoduchým způsobem by bylo rozeslat stejnou zprávu – která by
    byla jinak určená samotné commitment transakci – také všem paralelním
    commitment transakcím.

    Původní návrh specifikace splicingu (viz zpravodaje [č. 17][news17 splice]
    a [č. 146][news146 splice], *angl.*) obsahoval právě takové řešení.
    Avšak jak Lisa Neigut tento týden [vysvětlila][neigut splice], vytvoření
    nového splicu vyžaduje podepsání nové odvozené commitment transakce.
    V posledním návrhu specifikace vyžaduje každé odeslání podpisu také
    poslání podpisů všech aktuálních commitment transakcí. To je však
    nadbytečné, neboť podpisy ostatních commitment transakcí již byly
    odeslány dříve. Navíc jelikož v současném LN protokolu potvrzují
    jednotlivé strany obdržené podpisy zasláním dat pro anulování předchozí
    commitment transakce, dochází i zde k opakovanému přenosu stejných dat.
    Tato činnost není škodlivá, avšak vyžaduje více přenosové a výpočetní
    kapacity. Výhodou je, že provádění stejné operace ve všech případech
    zjednodušuje specifikaci a tím i složitost implementace a testování.

    Jinou možností je během vyjednávání o splicu posílat pouze nezbytné minimum
    podpisů a potvrzení přijetí. I přes přidanou složitost se jedná o mnohem
    efektivnější řešení. Je dobré míti na paměti, že LN uzly musí držet
    paralelní commitment transakce pouze do získání dostatečného
    množství konfirmací splicingové transakce.

  - *Relativní částky a splicing bez konfirmací:* Bastien Teinturier
    [zaslal][teinturier splice] příspěvek s několika návrhy změn specifikace.
    Kromě výše uvedené změny podpisů commitmentů též doporučuje, aby
    výzva ke splicingu používala relativní částky, např. „200 000 sat”
    pro přidání částky do kanálu (splice-in) nebo „−50 000 sat” pro
    odeslání z kanálu (splice-out). Teinturier se též bez dalších
    podrobností zmínil o svých obavách souvisejících se splicingem bez konfirmací.

- **Návrh BIPu s terminologií transakcí:** Mark „Murch” Erhardt
  [zaslal][erhardt terms] do emailové skupiny Bitcoin-Dev návrh na
  [informační BIP][terms bip] s doporučenou nomenklaturou součástí transakcí
  a konceptů s nimi spojených. V době psaní tohoto zpravodaje byly všechny
  odpovědi souhlasné.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Nestahuj witnessy pro domněle validní bloky v ořezaném režimu][review club 27050]
je PR od Niklase Göggeho (dergoegge), které zrychluje prvotní stahování bloků tím, že
nebude stahovat witnessy u uzlů nastavených v [ořezaném režimu][docs pruning] a používajících
[assumevalid][docs assume valid] (nastavení, kdy uzel přeskočí validaci některých starých
transakcí). Tato optimalizace byla diskutována v nedávné [otázce na Stack Exchange][se117057].

{% include functions/details-list.md
  q0="Proč musí uzel, který má nastaven assumevalid ale ne ořezávání, stahovat
      witnessy, i když je nebude validovat? Mělo by PR tuto situaci také
      řešit?"
  a0="Data witnessů jsou potřeba, protože spojení si mohou vyžádat i staré
      bloky (uzel nepracuje v ořezaném režimu)."
  a0link="https://bitcoincore.reviews/27050#l-31"

  q1="O kolik může být díky tomuto vylepšení snížen datový přenos? Jinými slovy,
      jaká je celková velikost všech witnessů až po nějaký nedávný blok, řekněme
      781213?"
  a1="110,6 GB, což je zhruba čtvrtina celkového objemu dat. Jeden účastník poznamenal,
      že 110 GB je zhruba 10 % jeho měsíčního limitu. Jedná se tedy o významnou
      redukci. Účastníci předpověděli ještě větší ušetření, vzhledem k rozšířenému
      používání witnessů v poslední době."
  a1link="https://bitcoincore.reviews/27050#l-52"

  q2="Může tato změna snížit množství stahovaných dat všech bloků?"
  a2="Ne, pouze od aktivace segwitu (výška 481824). Předchozí bloky
      neměly witnessy."
  a2link="https://bitcoincore.reviews/27050#l-73"

  q3="Toto PR implementuje dvě hlavní změny: logiky požadavků na bloky
      a validace bloků. V čem tyto změny spočívají?"
  a3="Je-li během validace přeskočeno ověření skriptu, je též přeskočeno ověření
      Merkleova stromu witnessů. V logice požadavků na bloky je vyňat příznak
      `MSG_WITNESS_FLAG`, aby spojení neposílala data witnessů."
  a3link="https://bitcoincore.reviews/27050#l-83"

  q4="Před touto změnou byla validace skriptů (během assumevalid) přeskočena,
      ale ostatní ověření dat witnessů přeskočena nebyla. Jaká ověření
      budou po této změně přeskočena?"
  a4="Merkleův kořen coinbasové transakce, velikost witnessů, maximální
      počet prvků v zásobníku a váha bloku."
  a4link="https://bitcoincore.reviews/27050#l-91"

  q5="Toto PR neobsahuje žádnou změnu kódu pro přeskočení všech nadbytečných
      ověření popsaných v předchozí otázce. Jak to tedy funguje?"
  a5="Tato ověření se přeskočí vždy, když neexistuje žádný witness. Jelikož
      byl segwit soft forkem, dává to smysl. Až do bodu, který považujeme
      za validní, tedy v podstatě předstíráme, že jsme předsegwitový uzel."
  a5link="https://bitcoincore.reviews/27050#l-117"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Libsecp256k1 0.3.1][] je  **bezpečnostním vydáním** opravujícím
  kód, který by měl běžet v konstantním čase, ale neběžel, když byl
  použit Clang 14 nebo vyšší. Tato zranitelnost mohla umožnit druh
  [nepřímého útoku][topic side channels] spojený s časováním operací.
  Autoři doporučují provést aktualizaci.


- [BDK 1.0.0-alpha.0][] je testovacím vydáním velkých změn přicházejících
  do BDK popsaných ve [zpravodaji č. 243][news243 bdk]. Vývojáři
  projektů používajících BDK jsou vyzváni, aby započali s testováním
  integrace.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #6012][] implementuje několik významných vylepšení v
  pythonové knihovně pro psaní pluginů (viz [zpravodaj č, 26][news26 pyln-client],
  *angl.*). Díky změnám mohou pluginy lépe pracovat s úložištěm gossip zpráv
  a umožňují tak snadnější tvorbu analytických nástrojů.

- [Core Lightning #6124][] přidává možnost blokovat runy (autorizační tokeny)
  pluginu [commando][commando plugin] (umožňující spouštět příkazy na straně
  spojení) a udržovat seznam všech run.

- [Eclair #2607][] přidává nové RPC volání `listreceivedpayments`, které vrací
  seznam všech plateb přijatých uzlem.

- [LND #7437][] přidává podporu souborové zálohy jediného kanálu.

- [LND #7069][] umožňuje klientům požádat svou [strážní věž][topic watchtowers]
  („watchtower”) o ukončení sledování. Tím věž přestane monitorovat
  transakce zavírající kanál v neplatném stavu a její nároky na
  úložiště a procesor se sníží.

- [BIPs #1372][] přiřazuje protokolu [MuSig2][topic musig] číslo [BIP327][].
  Protokol lze využít pro vytváření [elektronických podpisů s více
  účastníky][topic multisignature], které mají uplatnění v [taprootu][topic taproot]
  a jiných systémech používajících [Schnorrovy podpisy][topic schnorr signatures]
  dle [BIP340][]. Jak je popsáno v BIPu, mezi výhody patří neinteraktivní
  agregace klíčů a nutnost provést pro podpis pouze dvě kola vzájemné komunikace.
  Je též možné provést neinteraktivní podepisování, mají-li účastníci určité
  nastavení. Protokol nabízí všechny výhody schémat vícenásobných
  podpisů, jako jsou významná redukce datové stopy na blockchainu a vylepšení
  soukromí pro účastníky i ostatní uživatele sítě.

{% include references.md %}
{% include linkers/issues.md v=2 issues="6012,6124,2607,7437,7069,1372,863" %}
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[news243 bdk]: /cs/newsletters/2023/03/22/#bdk-793
[neigut splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003894.html
[teinturier splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003895.html
[erhardt terms]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021550.html
[terms bip]: https://github.com/Xekyo/bips/pull/1
[news26 pyln-client]: /en/newsletters/2018/12/18/#c-lightning-2161
[news17 splice]: /en/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing
[news146 splice]: /en/newsletters/2021/04/28/#draft-specification-for-ln-splicing
[libsecp256k1 0.3.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.1
[review club 27050]: https://bitcoincore.reviews/27050
[docs pruning]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-0.11.0.md#block-file-pruning
[docs assume valid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[se117057]: https://bitcoin.stackexchange.com/questions/117057/why-is-witness-data-downloaded-during-ibd-in-prune-mode
[commando plugin]: /en/newsletters/2022/07/27/#core-lightning-5370
