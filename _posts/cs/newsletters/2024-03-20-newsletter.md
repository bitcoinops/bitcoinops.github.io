---
title: 'Zpravodaj „Bitcoin Optech” č. 294'
permalink: /cs/newsletters/2024/03/20/
name: 2024-03-20-newsletter-cs
slug: 2024-03-20-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje projekt pro vytváření BIP324 proxy
lehkým klientům a shrnuje diskuzi o návrhu jazyka BTC Lisp. Též nechybí
naše pravidelné rubriky s popisem nedávných změn v klientech a službách,
oznámeními nových vydání a souhrnem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **BIP324 proxy pro lehké klienty:** Sebastian Falbesoner
  zaslal do fóra Delving Bitcoin [příspěvek][falbesoner bip324] oznamující
  TCP proxy překládající mezi bitcoinovým P2P protokolem verze 1 (v1) a
  [protokolem v2][topic v2 p2p transport], jak je definován v [BIP324][].
  Cílí zvláště na lehké klienty napsané pro v1, kterým umožní využívat výhod
  šifrované komunikace protokolu v2.

  Lehké klienty obvykle pouze oznamují transakce, které patří jejich peněžence.
  Každý, kdo je schopen odposlouchávat nešifrované spojení v1 tak může snadno
  odvodit, které transakce pochází od související IP adresy. Je-li používáno
  šifrování (v2), pouze plné uzly, které transakci obdrží, budou schopny
  určit IP jejího původce – lehkého klienta – za předpokladu, že se spojení
  lehkého klienta nestalo obětí man-in-the-middle útoku (který je možné
  v některých případech detekovat a proti kterému se mohou [budoucí verze][topic
  countersign] automaticky bránit).

  Falbesonerovo původní dílo používá BIP324 funkce napsané v Pythonu pro
  testovací sadu nástrojů Bitcoin Core. Kvůli tomu je proxy „příšerně pomalá
  a náchylná k útokům postranními kanály [a] nedoporučuji ji používat pro nic
  jiného než testování.” Pracuje již nicméně na přepsání proxy v Rustu.
  Uvažuje, že publikuje některé funkce jako knihovnu pro lehké klienty
  nebo jiný software, který chce v2 P2P protokol nativně podporovat.

- **Přehled BTC Lispu:** Anthony Towns zaslal do fóra Delving Bitcoin
  [příspěvek][towns lisp] popisující své experimenty s tvorbou varianty
  jazyka [Lisp][] nazvaného BTC Lisp během posledních několika let. Předešlé
  diskuze jsme shrnuli ve zpravodajích [č. 293][news293 lisp] a [č. 191][news191
  lisp] (_angl._). Příspěvek zachází do velkých podrobností, zájemcům doporučujeme
  jeho přečtení. Krátce zde uvedeme citace ze sekce _závěr_ a _budoucí práce_:

  „[BTC Lisp] může být na blockchainu trochu dražší, ale zdá se, že s ním
  lze dělat v podstatě cokoliv. […] Nemyslím si, že by implementace lispového
  interpretru nebo opkódů, které by ho musely doprovázet, byla příliš
  náročná, [ale] psát lispový kód bez kompilátoru překládajícího z vysokoúrovňové
  reprezentace do opkódů na úrovni konsenzu je dost otravné, [i když]
  i to by mělo být řešitelné. Mohli bychom to vzít ještě dále, implementovat
  nějaký takový jazyk a nasadit ho na signetu nebo inquisition.“

  Russell O'Connor, vývojář jazyka [Simplicity][topic simplicity], který
  by také mohl být považován za případnou alternativu skriptovacího jazyka
  konsenzu, přinesl ve své [reakci][oconnor lisp] porovnání mezi současným
  bitcoinovým jazykem Script, Simplicity a Chia/BTC Lisp. Usuzuje, že
  „Simplicity i clvm (Chia Lisp Virtual Machine) jsou nízkoúrovňové jazyky,
  které jsou určené pro snadné vykonávání počítačem. Kvůli tomu jsou hůře
  srozumitelné lidem. Mají být kompilovány z nějakých jiných, srozumitelnějších
  nekonsenzuálních jazyků. Simplicity a clvm nabízejí odlišné způsoby vyjádření
  starých dobrých věcí: načítat data z prostředí, kombinovat části dat,
  provádět podmíněné příkazy a kopu dalších primitivních operací. […]
  Jelikož stejně chceme [rozdělení na efektivní nízkoúrovňový konsenzuální
  jazyk a vysokoúrovňový nekonsenzuální srozumitelný jazyk], nejsou detaily
  tohoto nízkoúrovňového jazyka natolik důležité. Tedy po vynaložení nějakého
  úsilí by tvůj vysokoúrovňový BTC Lisp mohl být pravděpodobně přeložen/kompilován
  do Simplicity. […] Bez ohledu na to, kde nakonec skončí design Simphony (vysokoúrovňový
  nekonsenzuální jazyk založený na Simplicity), bude zřejmě moci být
  přeložen/kompilován do tvého nízkoúrovňového BTC Lispu. Každá kombinace
  jazyka a překladače by nabízela odlišnou složitost a možnosti optimalizace.”

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **BitGo přidává podporu pro RBF:**
  V [nedávném blogu][bitgo blog] oznámil BitGo podporu pro navyšování poplatků
  [nahrazením poplatkem (RBF)][topic rbf] ve své peněžence a API.

- **Vydána Phoenix Wallet v2.2.0:**
  Tímto vydáním může Phoenix podporovat [splicing][topic splicing] během provádění LN
  plateb pomocí protokolu quiescence („chvíle ticha,” viz [zpravodaj č. 262][news262
  eclair2680]). Dále Phoenix u funkce swap-in vylepšuje soukromí a poplatky pomocí
  vlastního protokolu [swaproot][swaproot blog].

- **Vydáno hardwarové podpisové zařízení Bitkey:**
  Zařízení [Bitkey][bitkey website] je navrženo pro používání v konfiguraci multisigu
  2-ze-3 s mobilním zařízením a klíčem serveru Bitkey. Zdrojový kód firmware
  a dalších komponent je [dostupný][bitkey github] pod licencí MIT s Commons Clause.

- **Vydán Envoy v1.6.0:**
  [Vydání][envoy blog] přináší funkce pro navyšování poplatků transakcí a rušení
  transakcí. Obě funkce používají RBF (nahrazení poplatkem).

- **Vydán VLS v0.11.0:**
  [Beta vydání][vls beta 3] umožňuje jednomu LN uzlu používat několik podepisujících zařízení.
  Tuto schopnost nazývají [tag team signing][vls blog].

- **Ohlášeno hardwarové podpisové zařízení Portal:**
  [Nedávno ohlášené][portal tweet] zařízení Portal funguje se smartphony pomocí
  NFC. Zdrojové kódy hardwaru i softwaru jsou [dostupné][portal github] na GitHubu.

- **Těžební pool Braiins přidává podporu pro Lightning Network:**
  Těžební pool Braiins [ohlásil][braiins tweet] beta verzi placení odměn pomocí Lightningu.

- **Vydána Ledger Bitcoin App 2.2.0:**
  [Vydání 2.2.0][ledger 2.2.0] přidává podporu [miniscriptu][topic miniscript] pro
  [taproot][topic taproot].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 26.1rc2][] je kandidátem na údržbové vydání této převažující
  implementace plného uzlu.

- [Bitcoin Core 27.0rc1][] je kandidátem na vydání příští hlavní verze
  této převažující implementace plného uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

*Poznámka: commity do Bitcoin Core uvedené níže se vztahují na jeho vývojovou,
master větev. Nebudou tedy pravděpodobně vydány před uplynutím zhruba
šesti měsíců po vydání nadcházející verze 27.*

- [Bitcoin Core #27375][] přidává funkcím  `-proxy` a `-onion` podporu pro
  používání unixových doménových soketů namísto lokálních TCP portů.
  Sokety mohou být rychlejší než TCP a nabízejí odlišné bezpečnostní
  kompromisy.

- [Bitcoin Core #27114][] umožňuje používat v konfiguračním parametru
  `whitelist` „in” a „out”, díky kterým lze přiznat zvláštní přístup
  konkrétním příchozím a odchozím spojením. Ve výchozím nastavení
  obdrží spojení uvedené ve whitelistu zvláštní přístup pouze, pokud
  se připojuje k uživatelovu lokálnímu uzlu (příchozí spojení).
  Zvolením „out” může nyní uživatel určit, že spojení obdrží zvláštní
  přístup, i když se lokální uzel připojuje k němu, například po
  RPC volání `addnode`.

- [Bitcoin Core #29306][] přidává [vylučování sourozenců][topic kindred
  rbf] („sibling eviction”) transakcím vycházejícím z nepotvrzeného [v3
  rodiče][topic v3 transaction relay]. Může poskytnout uspokojivou
  alternativu [CPFP carve-out][topic cpfp carve out], které je v současnosti
  používáno [LN anchor výstupy][topic anchor outputs]. V3 přeposílání
  transakcí včetně vylučování sourozenců není v současnosti na mainnetu
  aktivováno.

- [LND #8310][] umožňuje, aby byly hodnoty parametrů `rpcuser` a `rpcpass`
  (heslo) načteny z proměnných prostředí. Díky tomu může být soubor `lnd.conf`
  například spravován veřejným verzovacím systémem, jelikož nemusí obsahovat
  uživatelské jméno a heslo.

- [Rust Bitcoin #2458][] přidává podporu pro podepisování [PSBT][topic psbt],
  které obsahují taprootové vstupy.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27375,27114,29306,8310,2458" %}
[bitcoin core 26.1rc2]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[lisp]: https://cs.wikipedia.org/wiki/Lisp
[news293 lisp]: /cs/newsletters/2024/03/13/#chia-lisp-pro-bitcoinery
[news191 lisp]: /en/newsletters/2022/03/16/#using-chia-lisp
[falbesoner bip324]: https://delvingbitcoin.org/t/bip324-proxy-easy-integration-of-v2-transport-protocol-for-light-clients-poc/678
[towns lisp]: https://delvingbitcoin.org/t/btc-lisp-as-an-alternative-to-script/682
[oconnor lisp]: https://delvingbitcoin.org/t/btc-lisp-as-an-alternative-to-script/682/7
[bitgo blog]: https://blog.bitgo.com/available-now-for-clients-bitgo-introduces-replace-by-fee-f74e2593b245
[news262 eclair2680]: /cs/newsletters/2023/08/02/#eclair-2680
[swaproot blog]: https://acinq.co/blog/phoenix-swaproot
[bitkey website]: https://bitkey.world/
[bitkey github]: https://github.com/proto-at-block/bitkey
[envoy blog]: https://foundation.xyz/2024/03/envoy-version-1-6-0-is-now-live/
[vls beta 3]: https://gitlab.com/lightning-signer/validating-lightning-signer/-/releases/v0.11.0
[vls blog]: https://vls.tech/posts/tag-team/
[portal tweet]: https://twitter.com/afilini/status/1766085500106920268
[portal github]: https://github.com/TwentyTwoHW
[braiins tweet]: https://twitter.com/BraiinsMining/status/1760319741560856983
[ledger 2.2.0]: https://github.com/LedgerHQ/app-bitcoin-new/releases/tag/2.2.0
