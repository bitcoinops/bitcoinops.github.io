---
title: 'Zpravodaj „Bitcoin Optech” č. 245'
permalink: /cs/newsletters/2023/04/05/
name: 2023-04-05-newsletter-cs
slug: 2023-04-05-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis nápadu na nakládání se zodpovědností strážních
věží a připojujeme naše pravidelné rubriky s oznámeními o vydání nových verzí a
popisem významných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Zodpovědnost strážních věží:** Sergi Delgado Segura
  [zaslal][segura watchtowers post] minulý týden do emailové skupiny
  Lightning-Dev příspěvek o způsobech, kterými by [strážní věže][topic watchtowers]
  („watchtowers”) nesly zodpovědnost za selhání zabránit pokusům
  o narušení protokolu. Příklad: Alice poskytne strážní věži data pro
  detekci a zabránění potvrzení neplatného stavu LN kanálu. Později
  je tento neplatný stav potvrzen, ale strážní věž nereaguje. Alice
  by chtěla, aby měla možnost toto selhání veřejně prokázat a tím vedla
  strážní věž k zodpovědnosti.

  Nejjednodušším řešením by bylo, aby měla strážní věž všeobecně známý veřejný
  klíč, jehož soukromý klíč by generoval podpisy akceptovaných podkladů pro
  detekci narušení. V případě selhání strážní věže zabránit narušení protokolu
  by mohla Alice tato data a podpis zveřejnit. Avšak, jak Delgato poznamenává,
  má toto řešení svá úskalí:

    - *Požadavky na úložiště*: tento mechanismus by po Alici vyžadoval
      ukládání dodatečného podpisu za každý požadavek strážní věži, což
      by u aktivních LN kanálů bylo celkem často.

    - *Nemožnost mazání*: tento způsob by zřejmě vyžadoval, aby strážní
      věže nikdy nemazaly podklady pro detekci narušení. Avšak to může
      být v rozporu s jejich potřebami, např. pokud jsou jejich služby
      účtovány za určité období.

  Delgato navrhuje použití kryptografických akumulátorů, které by poskytly
  praktické řešení obou problémů. Akumulátory umožňují v kompaktní formě
  prokázat, že určitý prvek je součástí velké množiny prvků a nevyžadují
  po každém vložení nového prvku přepočítání celé datové struktury. Některé
  akumulátory umožňují i smazání prvků bez přepočítání. Delgato v [gistu][segura
  watchtowers gist] nastiňuje konstrukci několika možných akumulátorů.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.16.0-beta][] je beta verzí nové hlavní verze této populární
  implementace LN. [Poznámky k vydání][lnd rn] zmiňují množství nových
  funkcí, oprav chyb a zlepšení výkonu.

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

- [Core Lightning #5967][] přidává RPC volání `listclosedchannels`, které poskytuje
  data o uzavřených kanálech včetně důvodu zavření. Informace o dřívějších
  spojeních se nyní též ukládají.

- [Eclair #2566][] přidává podporu pro přijímání nabídek. Nabídky musí
  být registrovány pluginem, který poskytuje handler reagující na
  žádosti o faktury spojené s těmito nabídkami a přijímající platby.
  Eclair zajišťuje, že požadavky a platby jsou v souladu s protokolem,
  handler musí jen rozhodnout, zda produkty či služby mohou být poskytnuty.
  Díky tomu může být odbavování nabídek libovolně komplexní, aniž
  by mělo dopad na vnitřní logiku Eclairu.

- [LDK #2062][] implementuje [BOLT #1031][bolts #1031] (viz [zpravodaj
  č. 226][news226 bolts1031], *angl.*), [#1032][bolts #1032] (viz
  [zpravodaj č. 225][news225 bolts1032], *angl.*) a [#1040][bolts #1040],
  které umožňují konečnému příjemci platby ([HTLC][topic htlc]) akceptovat
  větší částku a delší expirační lhůtu, než které byly požadovány. Snižuje
  to schopnost přeposílajícího uzlu určit použitím drobných úprav parametrů,
  zda je následující uzel v trase konečným příjemcem. Díky této změně může také
  plátce zaslat příjemci mírně vyšší částku v případě používání [zjednodušených
  plateb s více cestami][topic multipath payments]. To může být nutné v případech,
  kdy zvolená trasa využívá kanály požadující minimální částku. Příklad: Alice
  chce rozdělit platbu ve výši 900 sat na dvě části, ale obě jí zvolené cesty
  požadují pro přeposlání minimálně 500 sat. Po této změně specifikace může
  odeslat dvě 500sat platby, a tedy přeplatit 100 sat za možnost použít jí
  preferovanou trasu.

- [LDK #2125][] přidává pomocné funkce pro určení času zbývajícího do
  expirace faktury.

- [BTCPay Server #4826][] umožňuje, aby service hooks mohly vytvářet a
  přijímat [LNURL][] faktury. Důvodem změny bylo přidání podpory pro
  NIP-57 „zap” do BTCPay Server.

- [BTCPay Server #4782][] přidává na účtenku [důkaz][topic proof of payment]
  o proběhlé platbě. Pro onchain platby je důkazem ID transakce,
  pro LN platby předobraz [HTLC][topic htlc].

- [BTCPay Server #4799][] přidává možnost exportovat [štítky][topic
  wallet labels] transakcí ve formátu specifikovaném v [BIP329][]. Budoucí
  PR může přidat podporu pro export i jiných druhů štítků, např. adres.

- [BOLTs #765][] přidává do LN specifikace [zaslepení tras][topic rv routing],
  které bylo poprvé popsáno ve [zpravodaji č. 85][news85 blinding] (*angl.*).
  Umožňuje uzlu přijmout platbu nebo [onion zprávu][topic onion messages]
  bez nutnosti odhalit odesílateli či plátci svůj identifikátor či jakoukoliv
  jinou informaci vedoucí k jeho identifikaci. Zaslepená trasa umožňuje
  příjemci zvolit si několik posledních uzlů, přes které bude platba nebo
  zpráva směrována. Ty jsou zašifrované stejným způsobem jako běžné trasovací
  informace. Zaslepená trasa je poskytnuta plátci nebo odesílateli, který odešle
  platbu na její první uzel. Ten data odšifruje a pokračuje v přeposílání směrem
  k příjemci. Během procesu se odesílatel nedozví informace o cílovém uzlu.

{% include references.md %}
{% include linkers/issues.md v=2 issues="5967,2566,2062,1031,1032,1040,2125,4826,4782,4799,765" %}
[lnd v0.16.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[segura watchtowers post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003892.html
[segura watchtowers gist]: https://gist.github.com/sr-gi/f91f007fc8d871ea96ead9b27feec3d5
[news85 blinding]: /en/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[news226 bolts1031]: /en/newsletters/2022/11/16/#bolts-1031
[news225 bolts1032]: /en/newsletters/2022/11/09/#bolts-1032
[news243 bdk]: /cs/newsletters/2023/03/22/#bdk-793
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.16.0.md
[lnurl]: https://github.com/lnurl/luds
