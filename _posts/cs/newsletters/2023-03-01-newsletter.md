---
title: 'Zpravodaj „Bitcoin Optech” č. 240'
permalink: /cs/newsletters/2023/03/01/
name: 2023-03-22-newsletter-cs
slug: 2023-03-01-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn diskuze o nejrychlejším způsobu ověření bez
použití jakéhokoliv digitálního zařízení, že záloha BIP32 seedu pravděpodobně
nebyla poškozena . Též nechybí naše pravidelné rubriky s oznámeními
o nových vydáních a souhrnem významných změn v populárních bitcoinových
páteřních projektech.

## Novinky

- **Rychlejší kontrolní součet zálohy seedu:** Peter Todd zaslal
  [odpověď][todd codex32] k diskuzi o návrhu BIP pro Codex32 (viz
  [zpravodaj z minulého týdne][news239 codex32]), což je schéma
  pro vytváření, ověřování a používání obnovovacích kódů [BIP32][topic bip32]
  seedů. Největší výhodou Codex32 oproti existujícím schématům je schopnost
  ověřit integritu záloh pouze pomocí tužky, papíru, dokumentace a
  času.

  Codex32 dává velkou jistotu ohledně detekce chyb v zálohách. Peter Todd
  navrhl, že mnohem jednodušší metodou generování obnovovacích kódů by bylo
  sečíst jejich části dohromady. Pokud by bylo možné výsledek tohoto kontrolního
  součtu vydělit beze zbytku známou konstantou, znamenalo by to ověření
  integrity zálohy v rámci parametrů. Peter Todd navrhl používat algoritmus,
  který by poskytl zhruba 99,9% ochranu proti překlepům, což by podle něj
  bylo dostatečně silné, snadné na používání a jednoduché na zapamatování.
  Nebylo by tak potřeba používat dodatečnou dokumentaci.

  Russell O'Connor [odpověděl][o'connor codex32], že obnovovací
  kód by bylo možné zkontrolovat mnohem rychleji než kompletní verifikací,
  pokud by byl uživatel ochotný akceptovat slabší ochranu. Kontrola pouze
  dvou znaků najednou by zaručila detekci všech jednoznakových chyb v
  obnovovacím kódu a poskytla by 99,9% ochranu proti ostatním záměnám.
  Postup by byl podobný generování kontrolního součtu popsaném Peterem
  Toddem, avšak vyžadoval by používání zvláštní, těžko zapamatovatelné
  vyhledávací tabulky. Pokud by byli uživatelé během každého ověřování
  ochotni používat jinou tabulku, každé další ověření by zvýšilo pravděpodobnost
  detekce chyby až do sedmého ověření, které by poskytlo stejnou garanci
  jako plné ověření Codex32. K tomuto by nebyla potřeba žádná změna Codex32,
  pouze dokumentace by musela být doplněna o nové tabulky a pracovní listy.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [HWI 2.2.1][] je údržbovým vydáním této aplikace umožňující softwarovým
  peněženkám přístup k hardwarovým podpisovým zařízením.

- [Core Lightning 23.02rc3][] je kandidátem na vydání nové údržbové verze
  této oblíbené implementace LN.

- [lnd v0.16.0-beta.rc1][] je kandidátem na vydání hlavní verze této oblíbené
  implementace LN.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25943][] přidává parametr RPC volání `sendrawtransaction`,
  který omezuje množství spálených prostředků na výstup. Obsahuje-li
  transakce výstup, jehož skript je vyhodnocen jako neutratitelný (s
  `OP_RETURN`, nevalidním opkódem nebo příliš velkou velikostí) a jehož
  hodnota je větší než `maxburnamount`, nebude do mempoolu přijata.
  Výchozím nastavením je nula, což ochrání uživatele před nechtěným
  spálením prostředků.

- [Bitcoin Core #26595][] přidává do RPC volání [migratewallet][news217
  migratewallet] parametry `wallet_name` a `passphrase`. Umožní
  migraci zašifrovaných zastaralých peněženek a peněženek nepoužívajících
  [deskriptory][topic descriptors].

- [Bitcoin Core #27068][] mění nakládání se vstupem hesla. Dříve byla hesla
  obsahující ASCII nulový znak (0x00) akceptována, avšak pouze část
  řetězce před prvním nulovým znakem byla použita pro dešifrování
  peněženky. To mohlo vést k použití méně bezpečného hesla, než uživatel
  zamýšlel. Po této změně bude pro šifrování i dešifrování použito
  kompletní heslo včetně nulových znaků. Pokud takové heslo při
  dešifrování selže, budou uživateli nabídnuty instrukce k použití
  předchozího chování.

- [LDK #1988][] přidává limity pro počet připojení a kanálů bez prostředků
  pro zabránění útoků odmítnutí služby způsobeného vyčerpáním zdrojů. Nové
  limity jsou:

    - Maximálně 250 spojení bez kanálu s prostředky.

    - Maximálně 50 spojení pokoušející se otevřít kanál.

    - Maximálně 4 kanály bez prostředků na spojení.

- [LDK #1977][] zpřístupňuje struktury pro serializaci a parsování
  [nabídek][topic offers] podle definice v [návrhu BOLT12][bolts #798].
  LDK ještě nepodporuje [zaslepené trasy][topic rv routing], nemůže tedy
  zatím přijímat a odesílat nabídky napřímo, ale tato změna umožní
  vývojářům začít s experimenty.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25943,26595,27068,1988,1977,798" %}
[core lightning 23.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc3
[lnd v0.16.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc1
[hwi 2.2.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.1
[news239 codex32]: /cs/newsletters/2023/02/22/#navrh-bip-pro-kodovani-seedu-codex32
[todd codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021498.html
[o'connor codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021504.html
[news217 migratewallet]: /en/newsletters/2022/09/14/#bitcoin-core-19602
