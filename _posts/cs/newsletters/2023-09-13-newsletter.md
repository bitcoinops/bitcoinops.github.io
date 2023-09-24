---
title: 'Zpravodaj „Bitcoin Optech” č. 268'
permalink: /cs/newsletters/2023/09/13/
name: 2023-09-13-newsletter-cs
slug: 2023-09-13-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme odkaz na návrh specifikací spojených s taprootovými
aktivy a souhrn několika alternativních protokolů, které umožní LN začít
používat PTLC. Též nechybí naše pravidelné rubriky se souhrnem sezení
Bitcoin Core PR Review Club, oznámeními o nových softwarových vydáních a
popisem významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Specifikace Taproot Assets:** Olaoluwa Osuntokun zaslal do
  emailových skupin Bitcoin-Dev a Lightning-Dev dva oddělené
  příspěvky o [protokolu validujícím na straně klienta][topic
  client-side validation] _Taproot Assets_. Ve skupině Bitcoin-Dev
  [ohlásil][osuntokun bips] sedm návrhů na BIP (o jeden více než
  při prvním oznámení protokolu, tehdy pod názvem _Taro_; viz.
  [zpravodaj č. 195][news195 taro], *angl.*). Ve skupině Lightning-Dev
  potom [ohlásil][osuntokun blip post] [návrh BLIPu][osuntokun blip]
  pro posílání a přijímání taprootových aktiv přes LN pomocí protokolu
  založeném na experimentálních „jednoduchých taprootových kanálech”
  plánovaných pro LND 0.17.0-beta.

  I přes svůj název nejsou Taproot Assets součástí bitcoinového protokolu
  a žádným způsobem nemění protokol konsenzu. Použitím stávajících
  vlastností poskytuje nové funkce uživatelům, kteří mají zájem.

  Specifikace neobdržely v době psaní žádné komentáře.

- **Změny v LN určené pro PTLC:** s blížícím se vydáním první
  LN implementace s experimentální podporou kanálů používajících [P2TR][topic
  taproot] a [MuSig2][topic musig] zaslal Greg Sanders do emailové
  skupiny Lightning-Dev [příspěvek][sanders post] se [souhrnem][sanders ptlc]
  úprav LN zpráv, které by umožnily zasílání plateb pomocí [PTLC][topic ptlc]
  namísto [HTLC][topic htlc]. Většinou se změny nezdají být příliš rozsáhlé
  či invazivní, poznamenáváme však, že většina implementací bude pravděpodobně
  nadále používat jednu sadu zpráv pro přeposílání obstarožních HTLC a
  jinou sadu pro přeposílání PTLC. Budou tedy obsahovat dvě odlišné cesty,
  které budou muset být udržované až do vyřazení HTLC. Pokud by některá
  z implementací přidala experimentální podporu PTLC ještě před standardizací
  zpráv, musely by – ke škodě všech – implementace podporovat dokonce tři či více různých
  protokolů najednou.

  Sandersův souhrn neobdržel v době psaní žádné komentáře.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Abstrakce přenosu][review club 28165] je PR od Pietera Wuilleho (sipa), které bylo
nedávno začleněno a které přináší abstraktní třídu pro _transport dat_. Konkrétní implementace
této abstraktní třídy přeměňují serializované zprávy z a na přenosový formát.
Můžeme si to představit jako implementaci nižší úrovně serializace a deserializace.
Tyto třídy neprovádí samotné posílání a přijímání.

PR též přináší dvě implementace třídy `Transport`: `V1Transport` (současný stav) a
`V2Transport` (šifrovaný přenos) a je součástí [projektu][v2 p2p tracking pr]
_P2P šifrovaného transportního protokolu verze 2_ dle [BIP324][topic v2 p2p transport].

{% include functions/details-list.md
  q0="Jaký je rozdíl mezi [*net*][net] a [*net_processing*][net_processing]?"
  a0="*Net* je zcela naspodu síťového rozhraní a má na starosti nízkoúrovňovou
       komunikaci mezi spojeními. Nad ním je postaven *net_processing*,
       který zprávy validuje a dále zpracovává."
  a0link="https://bitcoincore.reviews/28165#l-22"

  q1="Jmenujte příklady tříd nebo funkcí, které jsou spojeny s _net_ a _net_processing_."
  a1="*net_processing*: `PeerManager`, `ProcessMessage`.
      *net*: `CNode`, `ReceiveMsgBytes`, `CConnMan`."
  a1link="https://bitcoincore.reviews/28165#l-25"

  q2="Vyžaduje BIP324 změny na *net* vrstvě, *net_processing* vrstvě
      či obou? Má dopad na pravidla či konsenzus?"
  a2="Změny jsou pouze na *net* vrstvě. Nemají žádný dopad na konsenzus."
  a2link="https://bitcoincore.reviews/28165#l-37"

  q3="Jaké jsou příklady implementačních chyb, které by mohly vyústit v nezamýšlenou
      změnu konsenzu?"
  a3="Chyba, která omezuje nejvyšší velikost zprávy na méně než 4 MB, což by
      mělo za následek odmítání bloků validních podle jiných uzlů. Chyba v
      deserializiaci bloku, která by způsobila odmítání validních bloků."
  a3link="https://bitcoincore.reviews/28165#l-45"

  q4="`CNetMsgMaker` i `Transport` “serializují” zprávy.
      Jaký je rozdíl mezi těmi dvěma?"
  a4="`CNetMsgMaker` provádí serializaci datových struktur do bytů.
      `Transport` obdrží tyto byty, přidá (serializuje) hlavičku a odešle."
  a4link="https://bitcoincore.reviews/28165#l-60"

  q5="Co se děje během převodu objektů jako `CTransactionRef` (transakce)
      do bytů či síťových paketů? Do jakých datových struktur jsou
      převáděny?"
  a5="`msgMaker.Make()` serializuje zprávu `CTransactionRef` voláním
      `SerializeTransaction()`, poté `PushMessage()` umístí serializovanou
      zprávu do fronty `vSendMsg`, potom `SocketSendData()` přidá hlavičku
      a kontrolní součet (po tomto PR) a požádá transport o odeslání dalšího
      paketu. Nakonec zavolá `m_sock->Send()`."
  a5link="https://bitcoincore.reviews/28165#l-83"

  q6="Kolik bytů je odesláno po síti zprávou `sendtxrcncl` (berme tuto zprávu
      používanou v [Erlay][topic erlay] jako jednoduchý příklad)?"
  a6="36 bytů: 24 bytů je hlavička (4 pevné byty, příkaz 12 bytů,
      velikost zprávy 4 byty, kontrolní součet 4 byty) a 12 bytů tělo
      (verze 4 bytů, sůl 8 bytů)."
  a6link="https://bitcoincore.reviews/28165#l-86"

  q7="Jsou v době návratu z funkce `PushMessage()` odeslány již byty odpovídající této
      zprávě? Ano/ne/možná? Proč?"
  a7="Možné jsou všechny odpovědi. **Ano**: *net_processing* nemusí činit nic
      dalšího, aby se zpráva odeslala. **Ne**: je velice nepravděpodobné, že by
      příjemce zprávu obdržel ještě před návratem této funkce. **Možná**:
      jsou-li všechny fronty prázdné, byla zpráva již odeslána síťové vrstvě
      jádra; pokud však některé fronty prázdné nejsou, bude odeslání ještě
      čekat na uvolnění."
  a7link="https://bitcoincore.reviews/28165#l-112"

  q8="Která vlákna mají přístup k `CNode::vSendMsg`?"
  a8="`ThreadMessageHandler`, pokud je zpráva odeslána synchronně
      („optimisticky”); `ThreadSocketHandler`, pokud je zařazena do fronty
      a odeslána později."
  a8link="https://bitcoincore.reviews/28165#l-120"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.17.0-beta.rc2][] je kandidátem na vydání příští hlavní verze této
  oblíbené implementace LN uzlu. Velkou novou experimentální funkcí
  plánovanou pro toto vydání, které by prospělo testování, je podpora
  „jednoduchých taprootových kanálů.”

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26567][] mění způsob, jakým peněženka odhaduje váhu podepsaného
  vstupu z [deskriptoru][topic descriptors]. Původní přístup, který prováděl podepsání
  nanečisto, nebyl dostatečný pro některé složitější [miniscriptové][topic miniscript]
  deskriptory.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26567" %}
[LND v0.17.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc2
[net]: https://github.com/bitcoin/bitcoin/blob/master/src/net.h
[net_processing]: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.h
[news195 taro]: /en/newsletters/2022/04/13/#transferable-token-scheme
[osuntokun bips]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021938.html
[osuntokun blip post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004089.html
[osuntokun blip]: https://github.com/lightning/blips/pull/29
[review club 28165]: https://bitcoincore.reviews/28165
[sanders post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004088.html
[sanders ptlc]: https://gist.github.com/instagibbs/1d02d0251640c250ceea1c66665ec163
[v2 p2p tracking pr]: https://github.com/bitcoin/bitcoin/issues/27634
