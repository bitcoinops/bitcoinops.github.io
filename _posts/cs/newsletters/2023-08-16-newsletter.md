---
title: 'Zpravodaj „Bitcoin Optech” č. 264'
permalink: /cs/newsletters/2023/08/16/
name: 2023-08-16-newsletter-cs
slug: 2023-08-16-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn diskuze o přidání data expirace do adres tichých
plateb a poskytujeme přehled návrhu BIP pro bezserverový payjoin. Příspěvek v
podobě terénní zprávy popisuje implementaci a nasazení peněženky založené na
MuSig2 pro scriptless vícenásobné elektronické podpisy. Též nechybí naše
pravidelné rubriky s oznámeními o nových vydáních a popisem významných změn
v populárních bitcoinových páteřních projektech.

## Novinky

- **Přidání expirace do adres tichých plateb:** Peter Todd
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][todd expire] s
  doporučením přidat do adres [tichých plateb][topic silent payments]
  uživatelem zvolené datum expirace. Na rozdíl od běžných bitcoinových
  adres, které v případě použití k obdržení více plateb odhalují [vazby mezi
  výstupy][topic output linking], vedou adresy tichých plateb při každém
  správném použití k jedinečnému výstupnímu skriptu. To může výrazně zvýšit
  soukromí v případech, kdy je nemožné či nepraktické poskytnout plátci pro
  každou platbu novou běžnou adresu.

  Peter Todd poznamenává, že by bylo žádoucí, aby měly všechny adresy datum
  expirace, neboť dříve nebo později většina uživatelů přestane peněženku
  používat. Expirace není u předpokládaného jediného použití běžné adresy natolik
  důležitá, avšak pro tiché platby, u kterých se očekává opakované použití,
  je začlenění doby expirace mnohem důležitější. Navrhuje v adresách zahrnout
  buď dvoubytový čas, který by mohl zaujmout dobu expirace až 180 let,
  nebo tříbytový čas, který by obsáhl zhruba 45 000 let.

  Doporučení obdrželo v emailové skupině průměrné množství reakcí, avšak
  v době psaní zpravodaje žádné jasné rozuzlení.

- **Bezserverový payjoin:** Dan Gould zaslal do emailové skupiny Bitcoin-Dev
  [příspěvek][gould spj] s [návrhem BIPu][spj bip] pro _bezserverový payjoin_
  (viz [zpravodaj č. 236][news236 spj]). Podle [BIP78][] specifikace [payjoinu][topic
  payjoin] se očekává, že příjemce bude provozovat server pro bezpečné přijetí
  [PSBT][topic psbt] od odesílatele platby. Gould navrhuje asynchronní model s
  prostředníky, na jehož počátku by příjemce použil [BIP21][] URI k oznámení
  prostředníka a klíče symetrického šifrování, které by byly použity pro
  příjem payjoinové platby. Odesílatel by zašifroval PSBT a předal
  jej prostředníkovi zvolenému příjemcem. Příjemce by toto PSBT stáhl,
  rozšifroval, přidal do něj podepsaný vstup, zašifroval a odeslal zpět
  prostředníkovi. Odesílatel upravené PSBT stáhne, rozšifruje, ujistí se o jeho
  správnosti, podepíše a zveřejní v síti.

  V [odpovědi][gibson spj] Adam Gibson varoval před nebezpečím začlenění šifrovacího
  klíče v BIP21 adrese a před rizikem ohrožení soukromí prostředníkem, který
  by byl schopný vytvořit spojení mezi IP adresami příjemce a odesílatele a
  množinou transakcí zveřejněných v rámci časového okna kolem dokončení jejich
  sezení. Gould nato návrh [revidoval][gould spj2] ve snaze adresovat Gibsonovy
  obavy o šifrovacím klíči.

  Očekáváme, že diskuze o tomto protokolu bude pokračovat.

## Terénní zpráva o implementaci MuSig2

{% include articles/cs/bitgo-musig2.md extrah="#" %}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 23.08rc2][] je kandidátem na vydání příští hlavní verze této
  oblíbené implementace LN uzlu.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27213][] pomáhá Bitcoin Core otevírat a udržovat spojení
  v různorodější množině sítí, což v některých situacích sníží hrozbu
  [útoku zastíněním][topic eclipse attacks]. Tento druh útoku se objevuje,
  když se uzel nemůže připojit ani k jednomu čestnému uzlu. Je tak připojen
  pouze k nepoctivým uzlům, které mu mohou podsunout jiné bloky než zbytku
  sítě. To může být zneužito k přesvědčení uzlu, že některé transakce byly
  potvrzeny, i když s tím zbytek sítě nesouhlasí. Potenciálně by tím mohl
  provozovatel uzlu přijmout bitcoiny, které nebude moci utratit. Navýšení
  rozmanitosti spojení může též napomoci v předcházení náhodného štěpení sítě,
  kdy jsou spojení v rámci malé sítě izolována od hlavní sítě a nejsou schopna
  obdržet čerstvé bloky.

  Přijaté PR se snaží otevřít alespoň jedno spojení v každé dosažitelné síti
  a zabrání automatickému vyloučení, pokud se jedná o jediné spojení v síti.

- [Bitcoin Core #28008][] přidává šifrovací a dešifrovací funkce připravené k
  použití v implementaci [transportního protokolu verze 2][topic v2 P2P transport]
  podle specifikace v [BIP324][]. Byly přidány následující šifry a třídy
  (citováno z PR):

  - „ChaCha20Poly1305 AEAD z RFC8439, sekce 2.8”

  - „Proudová šifra FSChaCha20 (forward secrecy) podle specifikace v
    BIP324 (rekeying wrapper okolo ChaCha20)”

  - „FSChaCha20Poly1305 AEAD podle specifikace BIP324 (rekeying
    wrapper okolo ChaCha20Poly1305)”

  - „Třída BIP324Cipher, která zapouzdřuje vyjednávání o klíči, odvozování
    klíčů a proudové šifry a AEAD pro kódování paketů dle BIP324”

- [LDK #2308][] umožňuje plátci ve svých platbách začlenit vlastní TLV
  (Tag-Length-Value) položky, které budou moci příjemci používající LDK či kompatibilní
  implementace z platby extrahovat. Díky tomu bude snadnější v rámci platby
  poslat vlastní data a metadata.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27213,28008,2308" %}
[todd expire]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021849.html
[gould spj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021868.html
[spj bip]: https://github.com/bitcoin/bips/pull/1483
[gibson spj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021872.html
[gould spj2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021880.html
[news236 spj]: /cs/newsletters/2023/02/01/#navrh-na-bezserverovy-payjoin
[core lightning 23.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.08rc2
