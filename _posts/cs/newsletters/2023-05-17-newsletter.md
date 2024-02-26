---
title: 'Zpravodaj „Bitcoin Optech” č. 251'
permalink: /cs/newsletters/2023/05/17/
name: 2023-05-17-newsletter-cs
slug: 2023-05-17-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis návrhu na započetí testování HTLC atestací,
předáváme žádost o poskytnutí zpětné vazby k návrhu specifikace
poskytovatelů lightningových služeb (LSP), probíráme těžkosti
s otevíráním zero-conf kanálů spolu s dvojím financováním, díváme se
na návrh pokročilých aplikací payjoin protokolu a odkazujeme na
souhrn nedávného osobního setkání vývojářů Bitcoin Core. Dále začleňujeme
první část nové série o pravidlech přeposílání transakcí a začleňování
do mempoolu. Též nechybí naše pravidelné rubriky s oznámeními o nových
vydáních (včetně bezpečnostního vydání libsecp256k1) a popisem významných
změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Testování HTLC atestací:** před několika týdny zaslaly Carla Kirk-Cohen
  a Clara Shikhelman [příspěvek][kcs endorsement] do emailové skupiny
  Lightning-Dev o krocích, které ony spolu s dalšími lidmi plánují
  podniknout ve snaze otestovat myšlenku [HTLC][topic htlc] atestací
  (viz [zpravodaj č. 239][news239 endorsement]) jako součást souboru
  opatření pro zamezení [útoku zahlcením kanálu][topic channel jamming attacks].
  Mimo jiné poskytly [návrh specifikace][bolts #1071], která by mohla být
  nasazena s použitím experimentálního příznaku, což by umožnilo bez potíží
  komunikovat s uzly, které tuto specifikaci neimplementují.

  Po nasazení v rámci experimentálního provozu by mělo být jednodušší
  odpovědět na jednu z [konstruktivních kritik][decker endorsement] této myšlenky:
  kolika přeposílaným platbám by toto schéma ve skutečnosti pomohlo.
  Pokud si uživatelé LN často navzájem posílají platby přes množinu tras
  a pokud systém reputací funguje správně, měla by síť tvořená těmito
  uživateli být schopná ustát útok zahlcením kanálu. Avšak pokud většina
  odesílatelů posílá platby jen zřídka (nebo zřídka posílají nejkritičtější
  typ plateb jako jsou platby s vysokou hodnotou), potom nebudou mít
  dostatečné množství interakcí k vybudování reputace, nebo budou
  reputační data příliš zpožděna (což by dokonce mohlo umožnit zneužívání).

- **Žádost o poskytnutí zpětné vazby k návrhu specifikace LSP:** Severin
  Bühler zaslal do emailové skupiny Lightning-Dev [příspěvek][buhler lsp]
  s žádostí o poskytnutí zpětné vazby ke dvěma specifikacím interoperability
  mezi poskytovateli lightningových služeb (LSP) a jejich klienty (obvykle
  LN uzly, které nepřeposílají platby). První specifikace popisuje API,
  které umožní uživatelům zakoupit od LSP kanál. Druhá popisuje API
  pro nastavení a správu JIT (Just-In-Time) kanálů, což jsou kanály, které
  jsou vytvořeny jako virtuální platební kanály a teprve po první platbě
  na tento kanál uveřejní LSP transakci, která tak po potvrzení ukotví kanál
  v blockchainu a učiní jej běžným kanálem.

  V [odpovědi][zmnscpxj lsp] vyjádřil vývojář ZmnSCPxj souhlas s otevřenou
  specifikací pro LSP. Poznamenal, že díky tomu se mohou klienti připojit
  k více poskytovatelům a tím se vyhnout závislosti na jednom poskytovateli.

- **Potíže s zero-conf kanály a dvojím financováním:** Bastien
  Teinturier zaslal do emailové skupiny Lightning-Dev [příspěvek][teinturier 0conf]
  o výzvách, které přináší vzájemné používání [zero-conf kanálů][topic zero-conf channels]
  a [protokolu dvojího financování][topic dual funding]. Zero-conf kanály
  mohou být používány ještě před potvrzením otevírací transakce, což v některých
  případech nevyžaduje důvěru. Kanály s dvojím financováním jsou takové,
  jejichž otevírací transakce obsahuje vstupy obou účastníků (a jsou tedy
  financované oběma).

  Zero-conf nevyžaduje důvěru pouze v případě, kdy jeden z účastníků kontroluje
  všechny vstupy otevírací transakce. Příklad: Alice vytvoří otevírací
  transakci, poskytne Bobovi nějaké prostředky v kanálu a nato zkusí Bob
  poslat tyto prostředky Carol přes Alici. Alice může platbu bezpečně
  přeposlat, neboť ví, že konfirmace otevírací transakce je pod její
  kontrolou. Pokud však mám Bob také vstup v otevírací transakci, může
  nechat potvrdit konfliktní transakci, která nedovolí potvrzení
  otevírací transakce. To zabrání Alici vymáhat kompenzaci za peníze
  poslané Carol.

  Bylo probráno několik nápadů, jak umožnit otevírání zero-conf kanálů
  s dvojím financováním. V době psaní zpravodaje se žádný z těchto
  nápadů nejeví dostatečně uspokojující.

- **Pokročilé aplikace payjoinu:** Dan Gould zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][gould payjoin] s několika návrhy na pokročilejší
  používání protokolu [payjoin][topic payjoin], než je jen prosté
  odesílání a přijímaní plateb. Dva z těchto návrhů, které nás nejvíce
  zaujaly, byly verze [prořezání transakcí][transaction cut-through]
  („transaction cut-through”), staré myšlenky na zvýšení soukromí a
  škálovatelnosti a snížení nákladů:

    - *Přeposílání plateb:* namísto platby přímo Bobovi může Alice
      zaplatit Bobovýmu prodejci (Carol) a tím snížit dluh, který
      Bob u ní má, nebo si předplatit budoucí útratu.

    - *Dávkové přeposílání plateb:* namísto platby přímo Bobovi může
      Alice zaplatit několika lidem, kterým Bob dluží peníze (nebo si
      u nich chce založit úvěr). Gouldův příklad uvažuje o směnárnách,
      které mají stálý tok vkladů a výběrů; payjoin umožňuje, aby
      výběry byly placeny novými vklady.

    Obě tyto techniky umožňují snížit počet transakcí z minimálně dvou
    na jednu jedinou, což ušetří významné množství prostoru. S použitím
    [dávkování][topic payment batching] může být ušetřeného prostoru
    ještě více. Z pohledu původního příjemce (např. Bob) je navíc výhodné,
    že původní odesílatel (např. Alice) může platit všechny nebo část
    poplatků. Odstraňování transakcí z blockchainu a kombinování
    operací jako příjímání a utrácení též výrazně ztěžuje špehování
    finančních toků.

    V době psaní neobdržel příspěvek v emailové skupině žádné reakce.

- **Souhrn osobních setkání vývojářů Bitcoin Core:** někteří vývojáři
  pracující na Bitcoin Core se nedávno sešli, aby prodiskutovali
  některé aspekty projektu. Byly publikovány poznámky z několika
  diskuzí uskutečněných během setkání. Mezi tématy nechybělo
  [fuzz testování][fuzz testing], [assumeUTXO][], [ASMap][], [tiché
  platby][silent payments], [libbitcoinkernel][], [refaktorování (či
  ne)][refactoring (or not)] a [přeposílání balíčků][package relay].
  Dále byla diskutována dvě další témata, které si podle nás zaslouží
  zvláštní pozornost:

    - [Mempool clustering][] shrnuje návrh na významný redesign ukládání
      transakcí a jejich metadat v mempoolu Bitcoin Core. Poznámky
      popisují množství problémů se současným designem, poskytují přehled
      nového designu a ukazují na některé potíže a kompromisy. Později
      byl uveřejněn [popis][bitcoin core #27677] designu a kopie
      [slajdů][mempool slides] prezentace.

    - [Meta-diskuze o projektu][Project meta discussion] shrnuje pestrou
      diskuzi o cílech projektu a jak jich docílit navzdory mnoha překážkám
      vnitřním i vnějším. Některé z debat vedly již k pokusným změnám
      ve správě projektu, jako je více projektově orientovaný přístup
      pro budoucí vydání následující verzi 25.

## Čekání na potvrzení 1: k čemu je mempool?

_První část krátké týdenní série o přeposílání transakcí, začleňování
do mempoolu a výběru transakcí k těžbě včetně vysvětlení, proč má
Bitcoin Core přísnější pravidla, než co je povoleno konsenzem, a jak
mohou peněženky využít pravidla co nejefektivněji._

{% include specials/policy/cs/01-why-mempool.md %}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Libsecp256k1 0.3.2][] je bezpečnostním vydáním pro aplikace, které
  používají libsecp pro [ECDH][] a které mohou být kompilovány GCC
  verzí 13 a vyšší. Jak bylo autory [popsáno][secp ml], nová verze
  GCC se snaží optimalizovat kód libsecp, který byl navržen tak, aby běžel
  v pevném množství času. Kvůli optimalizaci je možné za určitých podmínek
  spustit [útok postranními kanály][topic side channels]. Patří se poznamenat,
  že Bitcoin Core ECDH nepoužívá. Vývojáři pracují na mechanismu detekce
  podobných problémů v budoucnosti.

- [Core Lightning 23.05rc2][] je kandidátem na vydání příští verze této
  implementace LN.

- [Bitcoin Core 23.2rc1][] je kandidátem na údržbové vydání předešlé
  hlavní verze Bitcoin Core.

- [Bitcoin Core 24.1rc3][] je kandidátem na údržbové vydání současné
  verze Bitcoin Core.

- [Bitcoin Core 25.0rc2][] je kandidátem na vydání příští hlavní verze
  Bitcoin Core.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26076][] aktualizuje RPC metody, které zobrazují derivační
  cesty veřejných klíčů: pro indikaci hardened derivace se namísto jednoduché
  uvozovky `'` bude používat `h`. Tato změna má vliv na kontrolní součet
  deskriptoru. Při nakládání s deskriptory obsahující privátní klíče je
  použit shodný symbol s deskriptory, které byly vygenerovány nebo importovány.
  Pro zastaralé peněženky zůstávají pole `hdkeypath` v `getaddressinfo` a
  serializační formát nezměněny.

- [Bitcoin Core #27608][] bude pokračovat v pokusech o stažení bloku od spojení,
  i když jiné spojení tento blok již poskytlo. Bitcoin Core bude pokračovat
  ve stahování, dokud není jeden z obdržených bloků zapsán na disk.

- [LDK #2286][] umožňuje vytváření a podepisování [PSBT][topic psbt] pro
  výstupy kontrolované lokální peněženkou.

- [LDK #1794][] přináší počátek podpory [dvojího financování][topic dual
  funding]. Prvně byly přidány metody potřebné pro interaktivní protokol financování.

- [Rust Bitcoin #1844][] určuje, že schéma v [BIP21][] adresách bude malými písmeny,
  tedy `bitcoin:`. I když specifikace URI (RFC3986) říká, že schéma nerozlišuje
  malá a velká písmena, testy ukazují, že některé platformy neotevírají aplikace
  přiřazené k URI `bitcoin:`, je-li použito schéma s velkými písmeny `BITCOIN:`.
  Bylo by výhodnější použít velká písmena, neboť to umožňuje efektivnější
  vytváření QR kódů (viz [zpravodaj č. 46][news46 qr], *angl.*).

- [Rust Bitcoin #1837][] přidává funkci pro generování nového privátního klíče.
  Oproti předchozí implementaci došlo ke zjednodušení tvorby privátních klíčů.

- [BOLTs #1075][] upravuje specifikaci tak, aby se uzly již neodpojovaly po obdržení
  varovné zprávy od spojení.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26076,27608,2286,1794,1844,1837,1075,1071,27677" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[bitcoin core 23.2rc1]: https://bitcoincore.org/bin/bitcoin-core-23.2/
[bitcoin core 24.1rc3]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc2]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[news239 endorsement]: /cs/newsletters/2023/02/22/#zadost-o-zpetnou-vazbu-k-hodnoceni-dobrych-sousedu-v-ln
[fuzz testing]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-fuzzing/
[assumeutxo]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-assumeutxo/
[asmap]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-asmap/
[silent payments]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-silent-payments/
[libbitcoinkernel]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-libbitcoin-kernel/
[refactoring (or not)]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-refactors/
[package relay]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-package-relay-primer/
[mempool clustering]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-mempool-clustering/
[project meta discussion]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-meta-discussion/
[kcs endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-April/003918.html
[decker endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003944.html
[buhler lsp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003926.html
[zmnscpxj lsp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003930.html
[teinturier 0conf]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003920.html
[gould payjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021653.html
[transaction cut-through]: https://bitcointalk.org/index.php?topic=281848.0
[news46 qr]: /en/newsletters/2019/05/14/#bech32-sending-support
[mempool slides]: https://github.com/bitcoin/bitcoin/files/11490409/Reinventing.the.Mempool.pdf
[secp ml]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021683.html
[libsecp256k1 0.3.2]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.2
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
