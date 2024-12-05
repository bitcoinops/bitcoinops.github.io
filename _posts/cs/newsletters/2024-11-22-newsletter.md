---
title: 'Zpravodaj „Bitcoin Optech” č. 330'
permalink: /cs/newsletters/2024/11/22/
name: 2024-11-22-newsletter-cs
slug: 2024-11-22-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje návrh změn LN specifikace umožňující
používání pluginů pro továrny kanálů, odkazuje na zprávu a novou webovou
stránku zkoumající signetové transakce používající navrhované
soft forky, popisuje aktualizaci návrhu soft forku LNHANCE a představuje
článek o kovenantech založených na obrušování namísto změn konsenzu.
Též nechybí naše pravidelné rubriky se souhrnem změn ve službách,
klientském software a populárním bitcoinovém páteřním software.

## Novinky

- **Plugin pro továrny kanálů:** ZmnSCPxj zaslal do fóra Delving
  Bitcoin [příspěvek][zmnscpxj plug] s návrhem na několik změn
  specifikace [BOLT][bolts repo], které by pomocí pluginu umožnily
  existujícímu software spravovat [LN-Penalty][topic ln-penalty] platební
  kanály v rámci [továrny kanálů][topic channel factories]. Díky
  těmto změnám by mohl správce továrny (např. LSP, poskytovatel lightningových
  služeb) posílat LN uzlu zprávy, které by byly předány pluginu továrny.
  Mnoho operací továrny by bylo podobných [splicingovým][topic splicing]
  operacím, díky čemuž by mohl plugin použít významné množství existujícího
  kódu. Operace LN-Penalty kanálu v rámci továrny by byly také podobné
  [0-conf kanálům][topic zero-conf channels], i jejich kód by tedy mohl
  být použit.

  ZmnSCPxjův návrh se soustředí na továrny ve stylu SuperScalar (viz
  [zpravodaj č. 327][news327 superscalar]), avšak byl by pravděpodobně
  použitelný i jinými druhy (a možná i jinými kontraktovými protokoly
  s více stranami). René Pickhardt [se zeptal][pickhardt plug] na další
  změny, které by umožnily [oznamovat][topic channel announcements] kanály
  v rámci továren. ZmnSCPxj [odpověděl][zmnscpxj plug2], že záměrně
  ve svém návrhu oznamování nezvažoval, aby bylo možné změny specifikace
  implementovat co nejrychleji.

- **Zpráva o aktivitě na signetu:** Anthony Towns zaslal do fóra Delving Bitcoin
  [příspěvek][towns signet] se souhrnem aktivity na výchozím [signetu][topic
  signet] ve vztahu k navrhovaným soft forkům dostupným prostřednictvím [Bitcoin
  Inquisition][bitcoin inquisition repo]. Příspěvek nahlíží na používání
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] včetně testování [LN-Symmetry][topic
  eltoo] a emulace [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify].
  Dále zkoumá přímé používání `OP_CHECKTEMPLATEVERIFY` včetně některých
  pravděpodobných konstrukcí [úschoven][topic vaults] a několika transakcí
  šířících data. Nakonec se příspěvek dívá na používání [OP_CAT][topic op_cat]
  pro zdroje mincí založeného na dokladech o provedení práce (proof-of-work
  faucet, viz [zpravodaj č. 306][news306 powfaucet]), pro možné úschovny
  i jiné [kovenanty][topic covenants] a pro ověřování dokladů s nulovou
  znalostí [STARK][].

  Vojtěch Strnad [odpověděl][strnad i.o], že ho Townsův příspěvek inspiroval
  k vytvoření webové stránky, která vypisuje „[každou transakci][inquisition.observer]
  z bitcoinového signetu, která používá některý z nasazených soft forků.”

- **Aktualizace návrhu LNHANCE:** Moonsettler zaslal do fóra Delving Bitcoin
  [příspěvek][moonsettler paircommit delving] (který též [poslal][moonsettler
  paircommit list] do emailové skupiny Bitcoin-Dev) s návrhem na přidání
  nového opkódu `OP_PAIRCOMMIT` do návrhu soft forku LNHANCE, který již
  obsahuje [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] a
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]. Nový opkód umožňuje
  vytvářet závazek k haši dvou prvků. To je podobné možnostem navrhovaného
  opkódu pro spojování prvků [OP_CAT][topic op_cat] nebo opkódům pro
  streamování SHA, které jsou [dostupné][streaming sha] např. v [sidechainech][topic
  sidechains] založených na Elements, avšak záměrně s ním není možné
  vytvářet rekurzivní [kovenanty][topic covenants].

  Moonsettler dále v emailové skupině [diskutoval][moonsettler other lnhance] i jiná
  drobná vylepšení LNHANCE.

- **Kovenanty založené na obrušování místo změn konsenzu:** Ethan Heilman
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][heilman collider] se souhrnem
  [článku][hklp collider], jehož je autorem spolu s Victorem Kolobovem,
  Avihu Levym a Andrew Poelstrou. Článek popisuje, jak by mohly být
  [kovenanty][topic covenants] snadno vytvářené bez změn konsenzu, avšak
  utrácení z nich by vyžadovalo nestandardní transakce a specializovaný hardware
  a elektřinu v hodnotě milionů (či miliard) dolarů. Heilman poznamenává, že jednou
  aplikací této práce je umožnit dnes uživatelům snadno přidat do taprootu záložní
  způsob utracení, který může být bezpečně použit, pokud by byla náhle potřebná
  [kvantová odolnost][topic quantum resistance] a operace s podpisy nad eliptickými
  křivkami by byly v bitcoinu deaktivované.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Ohlášen protokol na druhé vrstvě Spark:**
  [Spark][spark website]  je offchainový protokol ve stylu [statechainů][topic statechains]
  podporující Lightning Network.

- **Ohlášena peněženka Unify:**
  [Unify][unify github] je [payjoinovou][topic payjoin] peněženkou kompatibilní s [BIP78][],
  která používá Bitcoin Core a koordinuje výměnu [PSBT][topic psbt] po nostru.

- **Spuštěn bitcoinutils.dev:**
  Webová stránka [bitcoinutils.dev][] poskytuje rozličné bitcoinové nástroje
  včetně debugování skriptů a různých kódovacích a hašovacích funkcí.

- **Great Restored Script Interpreter je dostupný:**
  [Great Restored Script Interpreter][greatrsi github] je experimentální
  interpreter návrhu [Great Script Restoration][gsr youtube].

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #30666][] přidává funkci `RecalculateBestHeader()`, která
  přepočítá nejlepší hlavičku iterováním nad indexem bloků. Je automaticky
  zavolána při použití RPC příkazů `invalidateblock` a `reconsiderblock`
  nebo pokud jsou validní hlavičky v indexu bloků později během plné validace
  označeny za nevalidní. Odstraňuje tím problém nastavení nesprávných hodnot
  v těchto případech. PR dále označuje hlavičky, které vychází z nevalidního
  bloku, jako `BLOCK_FAILED_CHILD`, díky čemuž nebudou zvažovány pro
  `m_best_header`.

- [Bitcoin Core #30239][] standardizuje výstupy s [dočasným prachem][topic
  ephemeral anchors], což umožní transakcím s nulovým poplatkem a
  [neekonomickým výstupem][topic uneconomical outputs] přijetí do mempoolu za
  podmínky, že jsou v [balíčku][topic package relay] okamžitě utracené.
  Tato změna vylepšuje použitelnost pokročilých konstruktů jako connector
  výstupy nebo anchory s klíči i bez ([P2A][topic ephemeral anchors]). Přinese
  to výhody protokolům, jako jsou [Ark][topic ark], [expirační stromy][topic
  timeout trees], [BitVM2][topic acc] i dalším. Změna staví nad existující
  funkcionalitou jako 1P1C přeposílání, [TRUC][topic v3 transaction
  relay] transakce či [vylučování sourozenců][topic kindred rbf]. Viz též
  [zpravodaj č. 328][news328 ephemeral].

- [Core Lightning #7833][] aktivuje ve výchozím nastavení protokol [nabídek][topic
  offers], čímž odstraňuje předchozí experimentální status. Změna následuje po
  začlenění specifikace do repozitáře BOLTů (viz [zpravodaj č. 323][news323 offers]).

- [Core Lightning #7799][] přináší plugin `xpay` pro konstrukci a posílání
  optimálních [plateb s více cestami][topic multipath payments]. Používá plugin
  `askrene` (viz [zpravodaj č. 316][news316 askrene]) a RPC příkaz `injectpaymentonion`.
  Podporuje placení [BOLT11][] i [BOLT12][topic offers] faktur, nastavení doby
  mezi opakovanými pokusy, nastavení lhůt, přidání routovacích dat a částečné
  platby pro skládání příspěvků více stran v rámci jedné faktury. Plugin je
  jednodušší a pokročilejší než starší plugin `pay`, ale neobsahuje všechny jeho
  vlastnosti.

- [Core Lightning #7800][] přidává nový RPC příkaz `listaddresses`, který vrátí
  seznam všech bitcoinových adres, které uzel vygeneroval. PR dále používá
  [P2TR][topic taproot] jako výchozí skript pro utrácení [anchor výstupů][topic anchor
  outputs] a pro adresu pro drobné při jednostranném zavření kanálu.

- [Core Lightning #7102][] rozšiřuje příkaz `generatehsm` o možnost jej spustit
  v neinteraktivním režimu. Dříve bylo možné generovat tajná data z HSM
  (Hardware Security Module) pouze interaktivně v terminálu. Změna přinese výhody
  pro automatické instalace.

- [Core Lightning #7604][] přidává do účetnického pluginu nové RPC příkazy
  `bkpr-editdescriptionbypaymentid` a `bkpr-editdescriptionbyoutpoint` . Umožní
  nastavit a změnit popisek událostí.

- [Core Lightning #6980][] přidává nový příkaz `splice`, kterému lze předat JSON
  nebo skript definující komplexní [splicingové][topic splicing] akce. Všechny tyto
  operace nad více kanály jsou zkombinovány do jediné transakce. PR dále přidává
  RPC příkazy `addpsbtinput` (pro přímé přidání vstupů do [PSBT][topic psbt]),
  `stfu_channels` (pro pozastavení aktivity v kanálech) a `abort_channels`
  (pro ukončení kanálů za účelem jejich [upgradu][topic channel commitment upgrades]).
  Tyto příkazy jsou pro komplexní splicingové operace nezbytné.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30666,30239,7833,7799,7800,7102,7604,6980,3283" %}
[zmnscpxj plug]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/
[news327 superscalar]: /cs/newsletters/2024/11/01/#tovarny-kanalu-s-expiracnimi-stromy
[pickhardt plug]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/2
[zmnscpxj plug2]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/3
[towns signet]: https://delvingbitcoin.org/t/ctv-apo-cat-activity-on-signet/1257
[news306 powfaucet]: /cs/newsletters/2024/06/07/#skript-s-op-cat-validujici-proof-of-work
[stark]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[moonsettler paircommit delving]: https://delvingbitcoin.org/t/op-paircommit-as-a-candidate-for-addition-to-lnhance/1216
[moonsettler paircommit list]: https://mailing-list.bitcoindevs.xyz/bitcoindev/xyv6XTAFIPmbG1yvB0l2N3c9sWAt6lDTG-xjIbogOZ-lc9RfsFeJ-JPuXuXKzVea8T9TztlCvSrxZOWXKCwogCy9tqa49l3LXjF5K2cLtP4=@protonmail.com/
[streaming sha]: https://github.com/ElementsProject/elements/blob/011feab4c45d6e23985dbd68294e6aeb5a7c0237/doc/tapscript_opcodes.md#new-opcodes-for-additional-functionality
[moonsettler other lnhance]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZzZziZOy4IrTNbNG@console/
[heilman collider]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+W2jyFoJAq9XrE9whQ7EZG4HRST01TucWHJtBhQiRTSNQ@mail.gmail.com/
[hklp collider]: https://eprint.iacr.org/2024/1802
[strnad i.o]: https://delvingbitcoin.org/t/ctv-apo-cat-activity-on-signet/1257/4
[inquisition.observer]: https://inquisition.observer/
[news323 offers]: /cs/newsletters/2024/10/04/#bolts-798
[news316 askrene]: /cs/newsletters/2024/08/16/#core-lightning-7517
[news328 ephemeral]: /cs/newsletters/2024/11/08/#bitcoin-core-pr-review-club
[spark website]: https://www.spark.info/
[unify github]: https://github.com/Fonta1n3/Unify-Wallet
[bitcoinutils.dev]: https://bitcoinutils.dev/
[greatrsi github]: https://github.com/jonasnick/GreatRSI
[gsr youtube]: https://www.youtube.com/watch?v=rSp8918HLnA
