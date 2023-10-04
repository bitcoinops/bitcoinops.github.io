---
title: 'Zpravodaj „Bitcoin Optech” č. 271'
permalink: /cs/newsletters/2023/10/04/
name: 2023-10-04-newsletter-cs
slug: 2023-10-04-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn návrhu na vzdálené ovládání LN uzlů pomocí
hardwarových podpisových zařízení, popis výzkumu a kódu umožňující LN
uzlům dynamicky dělit platby a pohled na návrh zlepšení LN likvidity
umožněním skupině uzlů sdílet prostředky odděleně od svých běžných
kanálů. Též nechybí naše pravidelné rubriky s oznámeními nových verzí
a popisem významných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Zabezpečené vzdálené ovládání LN uzlů:** Bastien Teinturier
  zaslal do emailové skupiny Lightning-Dev [příspěvek][teinturier remote post]
  o [návrhu BLIPu][blips #28], který by specifikoval možnost uživatelů
  posílat z hardwarových podpisových zařízení podepsané příkazy svým LN
  uzlům nebo jiným peněženkám. Podpisové zařízení by muselo implementovat pouze
  tento BLIP a komunikaci dle [BOLT8][] a LN uzel by musel implementovat
  pouze BLIP. Jedná se o mechanismus podobný Core Lightning pluginu
  _commando_ ([viz zpravodaj č. 210][news210 commando], *angl.*), který
  umožňuje téměř kompletní vzdálené ovládání LN uzlu. Avšak Teinturier vidí
  tuto funkci primárně jako způsob provádění nejcitlivějších úkonů jako
  autorizace platby, tedy úkonů, pro které by byl uživatel ochoten projít
  připojením a odemčením hardwarového zařízení. Mohlo by to koncovým
  uživatelům usnadnit zabezpečení svých prostředků v LN stejným zařízením
  jako zabezpečení onchain prostředků.

- **Dělení a přepínání plateb:** Gijs van Dam zaslal do emailové skupiny
  Lightning-Dev [příspěvek][van dam pss post] o [pluginu][pss plugin], který
  napsal pro Core Lightning, a o souvisejícím [výzkumu][pss research], který
  provedl. Plugin umožňuje přeposílajícím uzlům informovat svá spojení,
  že podporují _dělení a přepínání plateb_ („přepínání” ve smyslu síťových přepínačů,
  tedy switchů; PSS, „payment splitting and switching“). Nechť Alice
  sdílí s Bobem kanál a oba podporují PSS. Když potom Alice obdrží platbu, která
  má být přeposlána Bobovi, může ji plugin rozdělit na dvě či více [částí][topic
  multipath payments]. Jedna z těchto částí může být přeposlána Bobovi běžným
  způsobem, avšak ostatní části mohou následovat alternativní cesty (například
  přes Carol). Bob počká, až obdrží všechny části, a potom platbu dále
  přepošle běžným způsobem.

  Hlavní výhoda tohoto přístupu spočívá ve ztížení provádění _útoků odhalující zůstatky_
  (BDA, „Balance Discovery Attacks”), při kterých mohou třetí strany opakovaně
  [sondovat][topic payment probes] kanál a sledovat jeho zůstatek. Pokud je
  BDA prováděn pravidelně, může sledovat hodnoty plateb procházející kanálem.
  Pokud je prováděn na mnoho kanálů, může sledovat konkrétní platbu napříč
  sítí. Pokud by bylo použito PSS, útočník by musel vedle zůstatku kanálu
  Alice–Bob také sledovat kanály Alice–Carol a Carol–Bob, aby mohl platbu
  sledovat. I kdyby útočník sledoval zůstatek ve všech těchto kanálech,
  výpočetní náročnost sledování platby by se zvyšovala spolu s pravděpodobností,
  že by mohly být platby jiných uživatelů chybně pokládány za části původní,
  sledované platby. Van Damův [výzkum][pss research] ukazuje 62% redukci
  v množství informací, které by útočník mohl po nasazení PSS získat.

  Van Dam zmiňuje dvě další výhody PSS: navýšení propustnosti LN a jeho použití
  jako část opatření proti [útoku zahlcením kanálu][topic channel jamming attacks].
  V době psaní zpravodaje obdržel nápad malé množství reakcí.

- **Sdílená likvidita pro LN:** ZmnSCPxj zaslal do emailové skupiny
  Lightning-Dev [příspěvek][zmnscpxj sidepools1] s návrhem na jím
  zvané _sidepooly_. Ty by umožnily skupinám spolupracujících přeposílajících
  uzlů vložit prostředky do stavového kontraktu, tedy do offchain kontraktu
  (ukotveného onchain podobně jako LN kanál), který by umožnil prostředky
  převádět mezi účastníky aktualizováním jeho offchain stavu. Například
  úvodní stav přiznávající Alici, Bobovi a Carol každému 1 BTC by mohl
  být aktualizován na nový stav, který dává Alici 2 BTC, Bobovi 0 BTC
  a Carol 1 BTC.

  Přeposílající uzly by nadále mohly používat běžné LN kanály mezi páry
  uzlů. Například tito tři uživatelé by mohli mít tři oddělené kanály:
  Alice s Bobem, Bob s Carol a Carol s Alicí. Běžným způsobem by těmito
  kanály přeposílali platby.

  Pokud by se jeden či více z těchto běžných kanálů staly nevyváženými,
  například by příliš mnoho prostředků v kanálu mezi Alicí a Bobem
  náleželo Alici, mohl by tento nepoměr být vyřešen provedením offchain
  [peerswapu][peerswap] ve stavovém kontraktu. Například by mohla Carol
  Alici poskytnout nějaké prostředky ve stavovém kontraktu výměnou za
  stejnou částku zaslanou Alicí Carol přes Boba v běžném LN kanálu.
  Tím by byla v LN kanálu mezi Alicí a Bobem znovu nastolena rovnováha.

  Jednou z výhod tohoto přístupu je, že nikdo kromě účastníků nemusí o
  stavovém kontraktu vědět. Pro všechny běžné uživatele LN a všechny
  ostatní přeposílající uzly bude LN fungovat podle současného protokolu.
  Další výhodou v porovnání s existujícími způsoby rebalancování kanálů
  je umožnění velkému množství přeposílajících uzlů zachovat přímá spojení
  výměnou za malý onchain prostor. To by mohlo odstranit jakékoliv
  onchain rebalanční poplatky mezi těmito spojeními. Díky zachování
  minimálních rebalančních poplatků mohou přeposílající uzly udržovat
  své kanály v rovnováze, což zlepší jejich možnost výdělku a
  učiní posílání plateb LN sítí spolehlivější.

  Nevýhodou přístupu je nutnost udržovat stavový kontrakt s více účastníky,
  což, pokud víme, zatím nebylo v produkčním prostředí implementováno.
  ZmnSCPxj zmiňuje dva protokoly, které mohou sloužit jako základ:
  [LN-Symmetry][topic eltoo] a [duplexní platební kanály][duplex payment
  channels]. LN-Symmetry by vyžadoval změnu konsenzu, což se zřejmě
  v blízké budoucnosti nestane, proto se v [následném příspěvku][zmnscpxj
  sidepools2] ZmnSCPxj soustředí na duplexní platební kanály (které
  ZmnSCPxj nazývá „Decker-Wattenhofer” podle autorů prvního návrhu).
  Nevýhodou duplexních platebních kanálů je, že nemohou zůstat otevřené
  nastálo, i když dle ZmnSCPxjovy analýzy pravděpodobně mohou být
  otevřené dostatečně dlouho a projít dostatečným množstvím změn stavu,
  aby byly jejich náklady efektivně amortizovány.

  V době psaní zpravodaje neobdržel příspěvek žádné veřejné reakce,
  avšak ze soukromé korespondence se ZmnSCPxjem víme, že tuto myšlenku
  dále rozvíjí.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.17.0-beta][] je vydáním příští hlavní verze této oblíbené
  implementace LN uzlu. Hlavní novou experimentální funkcí tohoto
  vydání je podpora „jednoduchých [taprootových][topic taproot] kanálů,”
  které umožňují používat [neveřejné kanály][topic unannounced channels]
  financované onchain pomocí P2TR výstupu. Jedná se o první krok směrem
  k přidání dalších funkcí jako je podpora [Taproot Assets][topic client-side
  validation] a [PTLC][topic ptlc]. Toto vydání také obsahuje významné zlepšení
  výkonu pro uživatele backendu Neutrino, které podporuje [kompaktní filtry
  bloků][topic compact block filters], a vylepšení funkcionality vestavěné
  [strážní věže][topic watchtowers]. Více informací lze nalézt v [poznámkách
  k vydání][lnd rn] a [blogovém příspěvku o vydání][lnd 17 blog].

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Eclair #2756][] přináší monitorování [splicingových][topic splicing] operací.
  Sbírány jsou informace o iniciátorovi operace a typ: splice-in, splice-out či
  splice-cpfp.

- [LDK #2486][] přidává podporu zakládání více kanálů jednou transakcí. Garantuje
  přitom atomicitu, tedy založeny budou buď všechny kanály, nebo žádný.

- [LDK #2609][] umožňuje vyžádat [deskriptory][topic descriptors], které byly
  v minulosti použity pro obdržení platby. Dříve je museli uživatelé ukládat
  sami, aktualizované API umožní z různých uložených dat deskriptory rekonstruovat.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2756,2486,2609,28" %}
[LND v0.17.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta
[teinturier remote post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004084.html
[news210 commando]: /en/newsletters/2022/07/27/#core-lightning-5370
[van dam pss post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004114.html
[pss plugin]: https://github.com/gijswijs/plugins/tree/master/pss
[pss research]: https://eprint.iacr.org/2023/1360
[zmnscpxj sidepools1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004099.html
[peerswap]: https://github.com/ElementsProject/peerswap
[duplex payment channels]: https://www.tik.ee.ethz.ch/file/716b955c130e6c703fac336ea17b1670/duplex-micropayment-channels.pdf
[zmnscpxj sidepools2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004108.html
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.17.0.md
[lnd 17 blog]: https://lightning.engineering/posts/2023-10-03-lnd-0.17-launch/
