---
title: 'Zpravodaj „Bitcoin Optech” č. 278'
permalink: /cs/newsletters/2023/11/22/
name: 2023-11-22-newsletter-cs
slug: 2023-11-22-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis návrhu na přijímání LN nabídek pomocí
určité DNS adresy podobné lightningovým adresám. Též nechybí naše pravidelné
rubriky se souhrnem změn ve službách a klientech, oznámeními o nových
vydáních a popisem významných změn v populárním bitcoinovém páteřním
software.

## Novinky

- **LN adresy kompatibilní s nabídkami:** Bastien Teinturier zaslal do
  emailové skupiny Lightning-Dev [příspěvek][teinturier addy] o vytváření
  adres (ve stylu emailových adres) pro uživatele LN. Návrh využívá
  možnosti nabízené protokolem [nabídek][topic offers]. Existující
  populární standard [lightningových adres][lightning address] je založený na [LNURL][],
  který vyžaduje provoz vždy dostupného HTTP serveru překládajícího
  adresy na LN faktury. Teinturier poznamenává, že tento způsob přináší
  několik problémů:

    - _Ztráta soukromí_: provozovatel serveru nejspíše zná IP
      adresy plátce i příjemce.

    - _Hrozba krádeže:_ provozovatel serveru může pomocí man-in-the-middle
      útoku ukrást prostředky.

    - _Infrastruktura a závislosti:_ provozovatel serveru musí nastavit
      DNS a HTTPS hosting a platící software musí být schopen používat
      DNS a HTTPS.

  Teinturier nabízí tři návrhy založené na nabídkách:

    - _Svázání domény a uzlu:_ DNS záznam převádí doménu (např. example.com)
      na identifikátor LN uzlu. Plátce pošle tomuto uzlu [onion zprávu][topic
      onion messages] s žádostí o nabídku konečnému příjemci (např.
      alice@example.com). Uzel domény vrátí nabídku podepsanou svým klíčem,
      což by plátci pomohlo usvědčit uzel o podvodu, pokud by poskytnutá
      nabídka nebyla od Alice. Plátce by nato mohl použít protokol nabídek
      k získání faktury od Alice. Plátce dále může svázat adresu alice@example.com
      s touto nabídkou, nebude tedy muset před budoucími platbami Alici uzel
      znovu kontaktovat. Dle Teinturiera je tento návrh velice jednoduchý.

    - _Certifikáty v oznámeních o uzlu:_ stávající mechanismus, jehož LN uzly
      využívají, aby se celé síti oznámily, může být upraven, aby umožnil
      začlenění řetězce SSL certifikátů. Ten by prokázal (dle certifikační
      autority) tvrzení vlastníka example.com, že je ovládán adresou
      alice@example.com. Teinturier poznamenává, že by si to vyžádalo, aby
      LN software implementoval kryptografii kompatibilní s SSL.

    - _Ukládání nabídek přímo v DNS:_ doména může mít několik DNS záznamů,
      které by přímo obsahovaly nabídky pro určité adresy. Například `TXT`
      záznam pro `alice._lnaddress.domain.com` obsahuje nabídku pro Alici.
      Jiný záznam `bob._lnaddress.domain.com` obsahuje nabídku pro Boba.
      Teinturier poznamenává nutnost vytvořit DNS záznam pro každého
      uživatele (a aktualizovat tento záznam při každé změně nabídky).

  Příspěvek vzbudil živou diskuzi. Jedna reakce navrhla použití
  první a třetí možnosti najednou (svázání uzlu a domény a ukládání nabídek
  přímo v DNS).

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Vydána BitMask Wallet 0.6.3:**
  [BitMask][bitmask website] je peněženka pro web a rozšíření prohlížeče, podporuje
  bitcoin, Lightning Network, RGB a [payjoin][topic payjoin].

- **Oznámena stránka s dokumentací opkódů:**
  Nedávno byla ohlášena webová stránka [https://opcodeexplained.com/], která obsahuje
  vysvětlení mnoha bitcoinových opkódů. Na stránce se dále pracuje, [příspěvky jsou
  vítány][OE github].

- **Athena Bitcoin přidává podporu lightningu:**
  [Provozovatel][athena website] bitcoinových bankomatů nedávno [oznámil][athena tweet]
  podporu pro výběry přes lightningové platby.

- **Vydán Blixt v0.6.9:**
  Vydání [v0.6.9][blixt v0.6.9] obsahuje podporu pro jednoduché taprootové kanály,
  používá [bech32m][topic bech32] adresy ve výchozím nastavení a zlepšuje podporu
  [zero conf kanálů][topic zero-conf channels].

- **Ohlášen článek o Durabitu:**
  [Článek o Durabitu][Durabit whitepaper] nastiňuje protokol používající bitcoinové
  transakce s [časovými zámky][topic timelocks] ve spojení s chaumovskou ražbou mincí,
  který by poskytoval ekonomické podněty pro hostování a sdílení velkých souborů.

- **Ohlášen článek o BitStreamu:**
  [Článek o BitStreamu][BitStream whitepaper] a jeho [raný protyp][bitstream github] představují protokol
  pro hostování a atomickou výměnu digitálního obsahu za mince pomocí časových zámků
  a Merkleových stromů s verifikací a doklady o podvodech. Pro předchozí diskuzi
  o protokolech placeného přenosu dat viz [zpravodaj č. 53][news53 data] (_angl._).

- **Ověření konceptu BitVM:**
  Byla vydána dvě ověření konceptu stavějící na [BitVM][news273 bitvm]. Jedno
  [implementuje][bitvm tweet blake3] hashovací funkci [BLAKE3][], [druhé][bitvm
  techmix poc] potom [implementuje][bitvm sha256] SHA256.

- **Bitkit přidává podporu pro odesílání taprootu:**
  Mobilní bitcoinová a lightningová peněženka [Bitkit][bitkit website] přidává ve
  svém vydání [v1.0.0-beta.86][bitkit v1.0.0-beta.86] podporu pro odesílání
  s [taprootem][topic taproot].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.17.2-beta][] je údržbové vydání, které pouze obsahuje drobnou opravu chyby
  nahlášené v [LND #8186][].

- [Bitcoin Core 26.0rc2][] je kandidátem na vydání příští hlavní verze této
  převládající implementace plného uzlu. K dispozici je [průvodce testováním][26.0
  testing].

- [Core Lightning 23.11rc3][] je kandidátem na vydání příští hlavní verze této
  implementace LN uzlu.

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #6857][] upravuje názvy několika konfiguračních voleb
  používaných pro REST rozhraní, aby nekolidovaly s těmi používanými
  pluginem [c-lightning-rest][].

- [Eclair #2752][] umožňuje, aby údaje v [nabídce][topic offers] odkazovaly
  na uzel buď pomocí jeho veřejného klíče nebo identity některého z jeho
  kanálů. Typicky se pro identifikaci uzlu používá veřejný klíč, ale ten
  používá 33 bytů. Kanál je možné identifikovat pomocí krátkého identifikátoru
  dle [BOLT7][] („short channel identifier”, SCID), který používá pouze osm bytů.
  Jelikož jsou kanály sdíleny dvěma uzly, je před SCID přidán ještě dodatečný bit
  určující jeden z těchto dvou uzlů. Jelikož nabídky jsou často používány
  v prostředích s omezenou velikostí, ušetřené místo může být významné.

{% include snippets/recap-ad.md when="2023-11-22 15:00" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="6857,2752,8186" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc3
[c-lightning-rest]: https://github.com/Ride-The-Lightning/c-lightning-REST
[teinturier addy]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-November/004204.html
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[lightning address]: https://lightningaddress.com/
[lnd v0.17.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.2-beta
[bitmask website]: https://bitmask.app/
[https://opcodeexplained.com/]: https://opcodeexplained.com/opcodes/
[OE tweet]: https://twitter.com/thunderB__/status/1722301073585475712
[OE github]: https://github.com/thunderbiscuit/opcode-explained
[athena website]: https://athenabitcoin.com/
[athena tweet]: https://twitter.com/btc_penguin/status/1722008223777964375
[blixt v0.6.9]: https://github.com/hsjoberg/blixt-wallet/releases/tag/v0.6.9
[Durabit whitepaper]: https://github.com/4de67a207019fd4d855ef0a188b4519c/Durabit/blob/main/Durabit%20-%20A%20Bitcoin-native%20Incentive%20Mechanism%20for%20Data%20Distribution.pdf
[BitStream whitepaper]: https://robinlinus.com/bitstream.pdf
[bitstream github]: https://github.com/robinlinus/bitstream
[news273 bitvm]: /cs/newsletters/2023/10/18/#platby-podminene-libovolnym-vypoctem
[bitvm tweet blake3]: https://twitter.com/robin_linus/status/1721969594686926935
[BLAKE3]: https://cs.wikipedia.org/wiki/BLAKE#BLAKE3
[bitvm techmix poc]: https://techmix.github.io/tapleaf-circuits/
[bitvm sha256]: https://raw.githubusercontent.com/TechMiX/tapleaf-circuits/abc38e880872150ceec08a8b67ac2fddaddd06dc/scripts/circuits/bristol_sha256.js
[bitkit website]: https://bitkit.to/
[bitkit v1.0.0-beta.86]: https://github.com/synonymdev/bitkit/releases/tag/v1.0.0-beta.86
[news53 data]: /en/newsletters/2019/07/03/#standardized-atomic-data-delivery-following-ln-payments
