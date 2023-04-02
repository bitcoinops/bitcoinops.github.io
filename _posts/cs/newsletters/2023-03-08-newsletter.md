---
title: 'Zpravodaj „Bitcoin Optech” č. 241'
permalink: /cs/newsletters/2023/03/08/
name: 2023-03-08-newsletter-cs
slug: 2023-03-08-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis návrhu alternativního designu `OP_VAULT` s
několika výhodami a oznamujeme nový týdenní Optech podcast. Též nechybí
naše pravidelné rubriky se souhrnem Bitcoin Core PR Review Club sezení,
oznámeními o nových vydáních a popisem významných změn oblíbených
páteřních bitcoinových projektů.

## Novinky

- **Alternativní návrh OP_VAULT:** Greg Sanders [zaslal][sanders
  vault] do emailové skupiny Bitcoin-Dev alternativní design poskytující
  funkce návrhu `OP_VAULT`/`OP_UNVAULT` (viz [zpravodaj č. 234][news234 vault]).
  Jeho verze by přidala tři opkódy namísto dvou, viz příklad:

    - *Alice zašle prostředky do úschovny* zaplacením [P2TR výstupu][topic
      taproot] se stromem skriptů, který obsahuje alespoň dva [koncové skripty][topic
      tapscript] („leafscript”): jeden pro spuštění procesu otevření úschovny s časovým
      zpožděním a druhý pro okamžité zmrazení prostředků, např.
      `tr(klíč,{spusť,zmraz})`.

      - Skript *spusť* obsahuje její méně důvěryhodný způsob autorizace
        (např. podpis z horké peněženky) a opkód `OP_TRIGGER_FORWARD`.
        V době vytvoření tohoto skriptu poskytne opkódu parametr
        *časového zpoždění*, např. relativní časový zámek 1 000 bloků
        (zhruba jeden týden).

      - Skript *zmraz* obsahuje jakýkoliv Alicin způsob autorizace (nebo žádný)
        a opkód `OP_FORWARD_DESTINATION`. V době vytvoření tohoto skriptu
        si také zvolí důvěryhodnější způsob autorizace (např. vícenásobný
        podpis z několika studených peněženek a podpisových zařízení).
        Opkódu poskytne commitment tohoto způsobu v podobě hashe.

    - *Alice spustí otevírání úschovny* utracením výstupu výše uvedeného
      skriptu (tj. jeho použitím jako vstupu) a zvolením spouštěcího
      skriptu. Zároveň poskytne dva dodatečné parametry opkódu `OP_TRIGGER_FORWARD`:
      index výstupu, který obdrží prostředky tohoto vstupu, a commitment
      (ve formě hashe), který určí, jak bude později moci prostředky utratit.
      Opkód ověří, že uvedený výstup této transakce platí P2TR výstup stromem
      skriptů, který je podobný právě utrácenému s tím rozdílem, že spouštěcí
      skript je nahrazen skriptem obsahujícím  relativní zpoždění (`OP_CHECKSEQUENCEVERIFY`,
      CSV) shodné se zpožděním uvedeným dříve (např. 1 000 bloků). Druhým rozdílem
      je opkód `OP_FORWARD_OUTPUTS` obsahující hash Alicina commitmentu.
      Tento způsob rekonstrukce stromu skriptů připomíná `OP_TAPLEAF_UPDATE_VERIFY`,
      dřívější návrh [kovenantů][topic covenants] (viz [zpravodaj č.
      166][news166 tluv], *angl.*).

    - *Alice dokončí otevření úschovny* vyčkáním na uvolnění časového zámku
      a následným utracením výstupu se zvoleným skriptem obsahujícím opkód
      `OP_FORWARD_OUTPUTS`. Opkód ověří, že hash částky a skriptu výstupu
      odpovídá commitmentu, který Alice učinila v předchozí transakci.
      V tomto případě Alice úspěšně zaslala prostředky do úschovny, započala
      otevření úschovny, musela počkat nejméně 1 000 bloků (aby měl její software
      dostatek času na potvrzení záměru) a nakonec platbu dokončila.

    - V případě problémů *Alice prostředky zmrazí*. Může tak učinit kdykoliv
      počínaje okamžikem vkladu prostředků do úschovny až do dokončení otevírání
      úschovny. Aby mohla prostředky zmrazit, jednoduše zvolí zmrazovací
      skript z výstupu transakce (buď vkladové nebo spouštěcí), neboť Alice
      vložila zmrazovací skript do vkladové transakce a tento skript byl
      automaticky přenesen dále.

  Jednou z výhod, které tento přístup poskytuje oproti původním designu
  `OP_VAULT`, je možnost stanovit v zmrazovacím skriptu jakékoliv podmínky
  autorizace. V návrhu `OP_VAULT` mohl prostředky zmrazit kdokoliv, kdo
  znal parametry zvolené Alicí. Ačkoliv to není problém bezpečnostní,
  může být dosti otravný. V Sandersově návrhu by mohla Alice pro započetí
  zmrazení vyžadovat například podpis nějaké slabě chráněné peněženky. To by
  mohlo být dostatečné pro zabránění většiny otravných útoků, ale nebránilo
  by to Alici v případě potřeby prostředky rychle zmrazit.

  Několik dalších výhod spočívá ve snadnosti porozumění a ověření správnosti
  [protokolu][topic vaults]. Autor původního `OP_VAULT` návrhu James O'Beirne
  se o Sandersově návrhu vyjádřil pozitivně. O'Beirne též přinesl několik
  dodatečných změn, které popíšeme v budoucím čísle zpravodaje.

- **Nový Optech podcast:** týdenní Optech Audio Recap na Twitter Spaces
  je nyní dostupný jako podcast. Každá epizoda bude dostupná na všech
  oblíbených podcastových platformách a přepis bude přístupný na našem webu.
  Náš [blogový příspěvek][podcast post] obsahuje další informace včetně
  vysvětlení, proč podcast považujeme za důležitý krok v naší misi za
  vylepšení technické komunikace v bitcoinu.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Bitcoin-inquisition: Aktivační logika pro testování změn konsenzu][review club bi-16]
je PR od Anthonyho Townse, které přidává způsob aktivace a deaktivace soft forků v projektu
[Bitcoin Inquisition][], navrženém na testování na [signetu][topic signet]. Projekt
byl popsán ve [zpravodaji č. 219][newsletter #219 bi] (*angl.*).

Konkrétně toto PR nahrazuje sémantiku bitů verze bloku podle [BIP9][] takzvaným
[dědičným nasazováním][Heretical Deployments] („Heretical Deployments”). Na rozdíl od změn konsenzu a přeposílání
na mainnetu, které se obtížně a zdlouhavě aktivují a vyžadují pečlivé budování konsenzu
mezi lidmi a spletitý mechanismus [aktivace][topic soft fork activation], mohou být
tyto změny na testnetu nasazovány jednodušeji. PR také implementuje způsob deaktivace
změn, které se ukázaly jako problematická či nežádoucí, což je další rozdíl oproti
mainnetu.

{% include functions/details-list.md
  q0="Proč chceme nasazovat změny konsenzu, které nejsou začleněny do
      Bitcoin Core? Jaké problémy by přineslo začleňování kódu do Bitcoin Core
      a následného otestování na signetu?"
  a0="Bylo probráno několik důvodů. Nemůžeme nutit uživatele mainnetu k upgradu
      jejich verze Bitcoin Core, a tedy i po opravení chyby mohou někteří uživatelé
      stále provozovat chybovou verzi. Spoléhání pouze na regtest ztěžuje integrační
      testování software třetích stran. Začleňování změn konsenzu do odděleného
      repozitáře je mnohem méně riskantní než začleňování do Core: přidávání
      logiky soft forků, byť deaktivované, může přinést chyby ovlivňující stávající chování."
  a0link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-37"

  q1="Dědičné nasazování postupně mění stav podobně jako BIP9
      (`DEFINED`, `STARTED`, `LOCKED_IN`, `ACTIVE` a`FAILED`),
      avšak s jedním dodatečným stavem po  `ACTIVE` nazývaným `DEACTIVATING`
      (po němž následuje konečný stav `ABANDONED`). Jaký je smysl stavu
      `DEACTIVATING`?"
  a1="Dává uživatelům možnost vyzvednout prostředky, které mohou mít
      v soft forku. Po deaktivaci nebo nahrazení forku by nemuseli mít
      k prostředkům přístup, jelikož by transakce byla odmítnuta jako
      nestandardní. Není ani tak důležité vyvarovat se ztrát prostředků
      na signetu, ale snažit se nepřeplňovat množinu UTXO."
  a1link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-92"

  q2="Proč PR odstraňuje `min_activation_height`?"
  a2="V novém modelu nepotřebujeme nastavitelný předaktivační interval.
      S dědičným nasazováním se automaticky aktivuje na počátku následující
      432blokové periody (zhruba tři dny; tato perioda je pevně daná)."
  a2link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-126"

  q3="Proč je v tomto PR taproot trvale usazen?"
  a3="Pokud by nebyl trvale usazen („buried”), musel by být dědičně
      nasazen, což by vyžadovalo trochu kódování. Též by to znamenalo, že
      by jeho časový limit jednou vypršel, což nechceme."
  a3link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-147"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 23.02][] je vydáním nové verze této oblíbené implementace LN.
  Obsahuje experimentální podporu ukládání záloh pro spojení (viz [zpravodaj
  č. 238][news238 peer storage]) a aktualizuje experimentální podporu pro
  [oboustranné vklady][topic dual funding] a [nabídky][topic offers]. Též
  nechybí několik dalších vylepšení a oprav chyb.

- [LDK v0.0.114][] je vydáním nové verze této knihovny pro budování
  peněženek a aplikací s podporou LN. Opravuje několik bezpečnostních
  chyb a obsahuje schopnost parsovat [nabídky][topic offers].

- [BTCPay 1.8.2][] je nejnovějším vydáním tohoto oblíbeného software pro
  zpracování bitcoinových plateb. Poznámky k vydání verze 1.8.0 říkají, že
  „tato verze přináší vlastní platební formuláře, možnosti nastavení
  brandingu, předělaný pohled klávesnice PoS, nové ikony a štítkování adres.”

- [LND v0.16.0-beta.rc2][] je kandidátem na vydání nové hlavní verze této oblíbené
  implementace LN.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [LND #7462][] umožňuje watch-only peněžkám se vzdáleným
  podepisováním spuštění v bezstavovém režimu.

{% include references.md %}
{% include linkers/issues.md v=2 issues="7462" %}
[core lightning 23.02]: https://github.com/ElementsProject/lightning/releases/tag/v23.02
[lnd v0.16.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc2
[LDK v0.0.114]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.114
[BTCPay 1.8.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.8.2
[podcast post]: /cs/podcast-announcement/
[sanders vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-March/021510.html
[news234 vault]: /cs/newsletters/2023/01/18/#navrh-na-nove-opkody-pro-uschovny
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[news238 peer storage]: /cs/newsletters/2023/02/15/#core-lightning-5361
[newsletter #219 bi]: /en/newsletters/2022/09/28/#bitcoin-implementation-designed-for-testing-soft-forks-on-signet
[review club bi-16]: https://bitcoincore.reviews/bitcoin-inquisition-16
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin
[heretical deployments]: https://github.com/bitcoin-inquisition/bitcoin/wiki/Heretical-Deployments
[bip9]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
