---
title: 'Zpravodaj „Bitcoin Optech” č. 233'
permalink: /cs/newsletters/2023/01/11/
name: 2023-01-11-newsletter-cs
slug: 2023-01-11-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis nápadu umožňujícího offline LN uzlům přijímat
platby na blockchainu, které mohou později být použity i v LN bez dalšího
zdržení. Nechybí také naše pravidelné rubriky se souhrnem nových
softwarových vydání a popisem významných změn v populárních bitcoinových
páteřních projektech.

## Novinky

- **Neinteraktivní otvírání LN kanálů:** vývojáři ZmnSCPxj
  a Jesse Posner [zaslali][zp potentiam] do emailové skupiny Lightning-Dev
  návrh na nový způsob otvírání LN kanálů, který nazývají *swap-in-potentiam*.
  Existující metody vyžadují, aby každý z účastníků
  podepsal refundační transakci ještě před tím, než jsou do kanálu vloženy
  jakékoliv prostředky. Tyto metody vyžadují interakci, neboť pro
  vytvoření refundace musí být známy detaily o vkládaných prostředcích:
  strana, která kanál otvírá, musí protistraně sdělit, jaké prostředky
  se chystá poskytnout; protistrana musí vytvořit a podepsat refundační
  transakci; poté musí otvírající strana podepsat a odeslat otvírací
  transakci.

  Autoři upozorňují, že tento způsob je pro některé peněženky problematický,
  obzvlástě pro mobilní peněženky, které mohou být offline nebo nemusí být
  schopny fungovat nepřetržitě. Bylo by rozumné, aby takové peněženky
  vygenerovaly záložní adresu na blockchainu, kam by mohly být prostředky
  zaslány v případě nedostupného LN uzlu. Při následném připojení by mohla
  peněžka použít tyto prostředky na blockchainu k otevření LN kanálu.
  Avšak nové LN kanály potřebují získat dostatečné množství konfirmací
  (např. šest), aby mohla protistrana bezpečně přeposílat platby
  otvírajícímu uzlu. Znamená to, že by uživatel mobilní peněženky, který
  v offline stavu obdrží platbu, musel po připojení čekat šest bloků,
  než by mohl použít tyto prostředky k posílání nových plateb přes LN.

  Autoři navrhují jinou možnost: uživatelka Alice si předem vybere
  takovou protistranu (Bob), jejíž uzel by měl být stále dostupný
  (např. poskytovatel lightningových služeb, LSP). Alice a Bob spolu
  vytvoří adresu na blockchainu pro skript, který umožní utrácení
  podpisem Alice a buď Bobovým podpisem nebo expirací několikatýdenního
  časového zámku (např. 6 000 bloků). [Příklad][potentiam minsc]:

  ```hack
  pk(A) && (pk(B) || older(6000))
  ```

  Tato adresa může obdržet platbu a nabírat konfirmace, zatímco je Alice
  offline. Dokud platba nedosáhne expiračního počtu konfirmací, musí Bob
  podepsat každý pokus o utracení. Rozhodne-li se Bob podepsat jen jeden
  pokus o utracení, který Alice též podepíše, může si Bob být jist,
  že Alice nemůže prostředky před expirací podruhé utratit (a tím platbu
  zneplatnit). Jediným způsobem zneplatnění Aliciny platby by bylo
  zneplatnění předchozí platby Alici. Obdrží-li platba dostatečné
  množství konfirmací před tím, než se Alice připojí online a zahájí
  utrácení, dvojí utracení by mělo být nepravděpodobné.

  Toto schéma umožňuje Alici obdržet platbu, zatímco je její peněženka offline,
  připojit se po získání nejméně šest konfirmací (ale výrazně
  méně než 6 000) a okamžitě se podílet na otevření LN kanálu podepsáním
  transakce, o které Bob ví, že nemůže být podruhé utracena. Bob může bezpečně
  přeposílat Alici platby ještě před tím, než je otvírací transakce
  potvrzena. Nebo mají-li Alice i Bob již své LN kanály (spolu či s jinými
  uzly), může Bob poslat Alici LN platbu, kterou může Alice uplatnit utracením
  svých onchain postředků Bobovi. Alicina peněženka se také může po připojení
  rozhodnout odeslat platbu běžným způsobem na blockchainu. V takovém případě musí
  Alice jen požádat Bobovu peněženku o podepsání. V nejhorším případě, pokud by Bob
  nespolupracoval, musela by Alice počkat pár týdnů.

  Vedle možnosti přijímat LN platby offline popisují dále autoři, jak by tato
  myšlenka mohla dobře fungovat s [asynchronními platbami][topic async payments].
  LSP by mohly dopředu připravit rebalancování, které by se provedlo bez
  jakéhokoliv zdržení (z pohledu uživatele) v okamžiku připojení se
  offline klienta k síti. Například kdyby Carol poslala asynchronní LN
  platbu Alici s částkou převyšující kapacitu Alicina kanálu, mohl by Bob
  poslat platbu skriptu `pk(B) && (pk(A) || older(6000))`. Tato alternativní
  verze skriptu převrací role Alice a Boba. Obdrží-li Bobova platba
  dostatečné množství konfirmací před následujícím připojením Aliciny
  peněženky, může Alice okamžitě povýšit tuto platbu na nový LN kanál
  a požádat Bob o přesměrování asynchronní platby přes tento nový kanál.
  Obvyklé garance týkající se bezpečnosti a důvěry v LN zůstavají
  zachovány.

  V době psaní tohoto zpravodaje obdržel návrh střední množství reakcí.
  Několik žádalo vysvětlení různých hledisek tohoto nápadu a přinejmenším
  jeden [příspěvek][fournier potentiam] vyjádřil konceptu silnou podporu.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK 0.26.0][] je novým vydáním této knihovny pro tvorbu peněženek.

- [HWI 2.2.0-rc1][] je kandidátem na vydání této aplikace umožňující
  softwarovým peněženkám přístup k podpisovým hardwarovým zařízením.


## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Eclair #2455][] implementuje podporu pro volitelný TLV stream
  („Type-Length-Value“ čili „typ-délka-hodnota”) v onionových
  chybových zprávách [nedávno představených][bolts #1021] v BOLT #4.
  TLV stream umožňuje uzlům přidat dodatečné informace o selháních
  trasování a může být použit i pro navrhovaný systém [fat errors][news224
  fat], který odstraní další nedostatky v přisuzování chyb.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2455,1021" %}
[bdk 0.26.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.26.0
[hwi 2.2.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.0-rc.1
[zp potentiam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003810.html
[potentiam minsc]: https://min.sc/#c=pk%28A%29%20%26%26%20%28pk%28B%29%20%7C%7C%20older%286000%29%29
[fournier potentiam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003813.html
[news224 fat]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
