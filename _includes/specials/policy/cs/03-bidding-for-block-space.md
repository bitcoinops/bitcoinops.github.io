<!--
  300 to 1000 words
  put title in main newsletter
  put links in this file
  for any subheads use h3 (i.e., ###)
  illustrations welcome (max width 800px)
  if uncertain about anything, just do what seems best and harding will edit
-->

Minulý týden jsme zmínili, že transakce neplatí poplatky dle přenášené
hodnoty, ale za použitý prostor v bloku. Také jsme vysvětlili, že
těžaři vybírají transakce takový způsobem, aby poplatky činily co
největší částku. Vyplývá z toho, že v nově nalezeném bloku jsou potvrzeny
pouze transakce z vrcholu mempoolu. V tomto příspěvku popíšeme strategie
optimalizace poplatků. Předpokládáme, že máme vyhovující zdroj odhadu
výše jednotkového poplatku (příští týden si povíme více o odhadování
jednotkového poplatku).

Během konstrukce transakcí jsou některé její součásti flexibilnější než jiné.
Každá transakce musí mít hlavičku, výstupy (určené jednotlivými platbami) a
výstup pro drobné. Odesílatel i příjemce by měli upřednostňovat takové typy
výstupů, které jsou efektivní z hlediska využitého prostoru, aby snížili
budoucí náklady na utracení svých výstupů. Konečnou podobu a váhu však
dává transakci [výběr vstupů][topic coin selection]. Jelikož transakce
mezi sebou soutěží jednotkovým poplatkem (poplatek / váha), lehčí transakce
vyžadují k dosažení stejného jednotkového poplatku nižší celkový poplatek.

Některé peněženky, například Bitcoin Core, se snaží zkombinovat vstupy
takovým způsobem, aby se zcela vyhnuly nutnosti vytvářet výstup s drobnými.
To vede nejen ke snížení váhy nyní, ale také ke snížení budoucích nákladů
utracení tohoto výstupu. Bohužel takové kombinace vstupů jsou jen zřídka
možné, pokud peněženka nemá k dispozici velké množství UTXO s různorodými
částkami.

Moderní druhy výstupů jsou prostorově efektivnější než starší typy.
Například utracení P2TR vstupu přispěje méně než dvěma pětinami váhy P2PKH
vstupu (viz [kalkulátor velikosti transakce][transaction size calculator]).
Multisig peněženky mohou těžit z nedávno dokončeného schématu [MuSig2][topic
musig] a protokolu FROST, díky kterým mohou být multisig operace kódovány
způsobem, který připomíná běžný vstup s jedním podpisem. Peněženky používající
moderní druhy výstupů mohou obzvláště v době vysoké poptávky po blokovém
prostoru dosáhnout vysokých úspor.

{:.center}
![Přehled vah vstupů a výstupů](/img/posts/specials/input-output-weights.png)

Chytré peněženky mění strategii výběru na základě jednotkového poplatku:
při vyšších jednotkových poplatcích dosahují použitím méně vstupů a moderních
druhů vstupů nejnižší možnou váhu pro danou množinu vstupů. Vybírat pokaždé
nejlehčí množinu vstupů by sice minimalizovalo náklady na tuto aktuální
transakci, ale také by štěpilo zásobu UTXO na malé fragmenty. To by si později
mohlo vynutit transakce s příliš velkou množinou vstupů v době s vysokým
jednotkovým poplatkem. Je tedy prozíravé, aby peněženky v dobách s nízkým
jednotkovým poplatkem také vybíraly více těžších vstupů, aby dosáhly konsolidace
prostředků do menšího množství moderních výstupů a tím se připravily
na pozdější vysokou poptávku po blokovém prostoru.

Vysoce používané peněženky často slučují několik plateb do jediné transakce,
aby dosáhly snížení váhy transakce na platbu. Vyhnou se tak platbě
za hlavičku a výstup pro drobné za každou platbu; namísto toho všechny
platby sdílí tento náklad pouze jednou. Sloučení několika málo plateb
rychle snižuje náklady za platbu:

![Úspory za sloučení plateb v P2WPKH](/img/posts/payment-batching/p2wpkh-batching-cases-combined.png)

I když mnoho peněženek jednotkový poplatek nadsazuje, někdy transakce
čeká na potvrzení déle, než se plánovalo. V takových případech může odesílatel
nebo příjemce změnit transakci prioritu.

Uživatelé mají zpravidla k dispozici dva nástroje, které jim pomohou
navýšit prioritu transakce: CPFP ([child pays for parent][topic cpfp],
potomek platí za předka) a RBF ([replace by fee][topic rbf], nahrazení
poplatkem). V případě CPFP utrácí uživatel svůj výstup, aby tím vytvořil
potomka této transakce, který bude mít vyšší jednotkový poplatek.
V minulém příspěvku jsme si vysvětlili, že je v zájmu těžařů vybrat
rodičovskou transakci do bloku, aby mohl být začleněn i její potomek
s vysokým poplatkem. CPFP je dostupné každému, komu je platba v transakci
směrována, čili buď příjemce nebo odesílatel (pokud vytvořil i výstup
pro drobné).

V případě RBF připraví odesílatel transakci s vyšším jednotkovým poplatkem,
která nahradí transakci původní. Nahrazující transakce musí použít alespoň
jeden vstup shodný s původní transakcí; tento konflikt zaručí, že pouze
jediná z těchto dvou transakcí bude začleněna do blockchainu. Obvykle tato
nahrazující transakce obsahuje platby z původní transakce, ale odesílatel
by též mohl prostředky přesměrovat jinam či zkombinovat platby z více
transakcí do jedné. V minulém příspěvku jsme popsali, že uzly vyloučí
původní transakci z mempoolu, neboť je pro ně výhodnější začlenit nahrazující
transakci.

I když je poptávka i produkce blokového prostoru mimo naši kontrolu,
mají peněženky k dispozici mnoho prostředků, kterými mohou dosáhnout
efektivního využití blokového prostoru. Peněženky mohou ušetřit na
poplatcích vytvářením lehčích transakcí eliminací výstupu pro drobné,
utrácením nativních segwit výstupů a defragmentací svého UTXO setu v době
nízkých poplatků. Peněženky, které podporují CPFP a RBF, mohou také začít
s konzervativnějším jednotkovým poplatkem a bude-li potřeba, mohou
transakci pomocí CPFP nebo RBF navýšit prioritu.

[transaction size calculator]: /en/tools/calc-size
