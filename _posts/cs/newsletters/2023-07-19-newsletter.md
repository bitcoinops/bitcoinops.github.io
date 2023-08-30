---
title: 'Zpravodaj „Bitcoin Optech” č. 260'
permalink: /cs/newsletters/2023/07/19/
name: 2023-07-19-newsletter-cs
slug: 2023-07-19-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme poslední díl naší krátké týdenní série o pravidlech
mempoolu. Též nechybí naše pravidelné rubriky popisující významné změny
v klientech, službách a populárním bitcoinovém páteřním software.

## Novinky

_V emailových skupinách Bitcoin-Dev a Lightning-Dev se tento týden neobjevily
žádné významné novinky._

## Čekání na potvrzení 10: zapojte se

_Poslední příspěvek do naší krátké týdenní [série][policy series] o
přeposílání transakcí, začleňování do mempoolu a výběru transakcí k
těžbě včetně vysvětlení, proč má Bitcoin Core přísnější pravidla, než
co je povoleno konsenzem, a jak mohou peněženky využít pravidla co
nejefektivněji._

{% include specials/policy/cs/10-get-involved.md %}

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Peněženka od 10101 testuje sdílení prostředků mezi LN a DLC:**
  10101 oznámili [peněženku][10101 github] postavenou nad LDK a BDK, která uživatelům
  umožňuje obchodovat deriváty nekustodiálním způsobem pomocí [DLC][topic dlc]
  v [offchain kontraktu][10101 blog2], který též může být použit k posílání, přijímání
  a přeposílání LN plateb. DLC závisí na orákulech, která vydávají [atestace][10101 blog1]
  ceny použitím [adaptor podpisů][topic adaptor signatures].

- **Ohlášen LDK Node:**
  Tým LDK [ohlásil][ldk blog] LDK Node [v0.1.0][LDK Node v0.1.0]. LDK Node je rustová
  knihovna lightningového uzlu, která používá knihovny LDK a BDK. Přináší vývojářům
  možnost rychle založit lightningový uzel a zároveň jim nechává vysoký stupeň
  nastavitelnosti.

- **Ohlášeno Payjoin SDK:**
  [Payjoin Dev Kit (PDK)][PDK github] bylo [ohlášeno][PDK blog] jako rustová knihovna,
  která implementuje [BIP78][] pro použití v peněženkách a službách, které si přejí
  integrovat [payjoin][topic payjoin].

- **Ohlášena beta verze Validating Lightning Signer (VLS):**
  VLS umožňuje oddělit lightningový uzel od klíčů, které kontrolují jeho prostředky.
  Namísto používání lokálních klíčů přesměruje uzel běžící s VLS požadavky na podepsání
  vzdálenému podpisovému zařízení. [Beta vydání][VLS gitlab] podporuje CLN a LDK, validační
  pravidla vrstvy 1 i 2, možnost zálohy a obnovy a poskytuje referenční implementaci.
  [Blogový příspěvek][VLS blog] s oznámením dále prosí o testování, funkční požadavky
  a další zpětnou vazbu.

- **BitGo přidává podporu MuSig2:**
  BitGo [oznámilo][bitgo blog] podporu [BIP327][] ([MuSig2][topic musig]) a s ním
  i nižší poplatky a vyšší soukromí v porovnání s ostatními podporovanými druhy adres.

- **Peach přidává podporu RBF:**
  Mobilní aplikace [Peach Bitcoin][peach website] pro peer-to-peer směnu [oznámila][peach tweet]
  podporu pro navýšení poplatků pomocí [Replace-By-Fee (RBF)][topic rbf].

- **Peněženka Phoenix přidává podporu splicingu:**
  ACINQ [oznámil][acinq blog] beta testování následující verze své mobilní lightningové
  peněženky Phoenix. Peněženka podporuje jediný dynamický kanál, který se rebalancuje
  pomocí [splicingu][topic splicing] a mechanismu připomínajícího [swap-in-potentiam][news233 sip].

- **Mining Development Kit žádá o zpětnou vazbu:**
  Tým pracující na Mining Development Kit (MDK) [zveřejnil článek][MDK blog] o průběhu
  vývoje hardware, software a firmware pro systémy pro těžbu bitcoinů. Příspěvek žádá komunitu
  o zpětnou vazbu a připomínky k případům použití, šíři záběru a jejich přístupu.

- **Binance přidává podporu lightningu:**
  Binance [ohlásil][binance blog] podporu posílání (výběrů) a přijímání (vkladů) po
  lightning network.

- **Nunchuk přidává podporu CPFP:**
  Nunchuk [ohlásil][nunchuk blog] podporu pro navyšování poplatků pomocí [Child-Pays-For-Parent
  (CPFP)][topic cpfp], a to na straně odesílatele i příjemce transakce.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27411][] přestane oznamovat své Tor a I2P adresy spojením
  na jiných sítích (jako jsou IPv4 nebo IPv6) a též nebude oznamovat své adresy
  z [neanonymních sítí][topic anonymity networks] spojením na Tor a I2P.
  Zabrání to možnosti párování běžných a anonymizovaných adres. CJDNS se tato
  změna zatím týkat nebude.

- [Core Lightning #6347][] přidává pluginům schopnost odebírat všechny události
  použitím `*`.

- [Core Lightning #6035][] přidává možnost vyžádat [bech32m][topic bech32]
  adresu pro příjem vkladů na [P2TR][topic taproot] výstupy. Drobné z
  transakce budou ve výchozím nastavení také poslány na P2TR výstup.

- [LND #7768][] implementuje BOLTy [#1032][bolts #1032] a [#1063][bolts
  #1063] (viz [zpravodaj č. 225][news225 bolts1032], *angl.*), které umožňují
  konečnému příjemci platby (HTLC) akceptovat vyšší částku a delší expirační dobu,
  než které byly požadované. Dříve se příjemci založení na LND drželi požadavku
  z [BOLT4][], že částka a expirační doba se musí přesně rovnat. Tato
  přesnost však dávala možnost drobnými změnami těchto hodnot odhalit, zda byl
  následující skok konečným příjemcem.

- [Libsecp256k1 #1313][] přináší automatické testování vývojovými verzemi kompilátorů
  GCC a Clang. Testování může odhalit změny způsobující běh některého kódu
  libsecp256k1 v proměnlivém čase, který může vést k [útokům postranními kanály][topic
  side channels]. [Zpravodaj č. 246][news246 secp] poukazuje na jednu příležitost,
  kde se tak mohlo stát, a [zpravodaj č. 251][news251 secp] odkazuje na jinou a na
  oznámení o plánech na podobné testování.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27411,6347,6035,7768,1032,1063,1313" %}
[policy series]: /cs/blog/waiting-for-confirmation/
[news225 bolts1032]: /en/newsletters/2022/11/09/#bolts-1032
[news246 secp]: /cs/newsletters/2023/04/12/#libsecp256k1-0-3-1
[news251 secp]: /cs/newsletters/2023/05/17/#libsecp256k1-0-3-2
[10101 github]: https://github.com/get10101/10101
[10101 blog1]: https://10101.finance/blog/dlc-to-lightning-part-1/
[10101 blog2]: https://10101.finance/blog/dlc-to-lightning-part-2
[LDK Node v0.1.0]: https://github.com/lightningdevkit/ldk-node/releases/tag/v0.1.0
[LDK blog]: https://lightningdevkit.org/blog/announcing-ldk-node
[PDK github]: https://github.com/payjoin/rust-payjoin
[PDK blog]: https://payjoindevkit.org/blog/pdk-an-sdk-for-payjoin-transactions/
[VLS gitlab]: https://gitlab.com/lightning-signer/validating-lightning-signer/-/releases/v0.9.1
[VLS blog]: https://vls.tech/posts/vls-beta/
[bitgo blog]: https://blog.bitgo.com/save-fees-with-musig2-at-bitgo-3248d690f573
[peach website]: https://peachbitcoin.com/
[peach tweet]: https://twitter.com/peachbitcoin/status/1676955956905902081
[acinq blog]: https://acinq.co/blog/phoenix-splicing-update
[news233 sip]: /cs/newsletters/2023/01/11/#neinteraktivni-otvirani-ln-kanalu
[MDK blog]: https://www.mining.build/update-on-the-mining-development-kit/
[binance blog]: https://www.binance.com/en/support/announcement/binance-completes-integration-of-bitcoin-btc-on-lightning-network-opens-deposits-and-withdrawals-eefbfae2c0ae472d9e1e36f1a30bf340
[nunchuk blog]: https://nunchuk.io/blog/cpfp
