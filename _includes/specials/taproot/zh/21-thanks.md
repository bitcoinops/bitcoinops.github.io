Taproot 将在区块 {{site.trb}} 激活，预计于本文发布后数日内完成。作为本系列的终篇，我们谨向众多参与开发与激活 Taproot 的人士致谢——他们即将开始执行这一升级。未提及的诸多贡献者同样值得感谢，我们为所有疏漏致歉。

{:#mailing_list_discussion}
## Bitcoin-Dev 邮件列表讨论

Taproot 的核心构想[萌芽][good morning]于 2019 年 1 月 22 日早晨几位密码学家的会议，并于当日通过邮件列表[发布][maxwell taproot post]。以下人士参与了主题含 "taproot" 的讨论：

<i>
Adam Back、
Andrea Barontini、
Andreas Schildbach、
Andrew Chow、
Andrew Poelstra、
Anthony Towns、
Antoine Riard、
Ariel Lorenzo-Luaces、
Aymeric Vitte、
Ben Carman、
Ben Woosley、
Billy Tetrud、
BitcoinMechanic、
Bryan Bishop、
Carlo Spiller、
Chris Belcher、
Christopher Allen、
Clark Moody、
Claus Ehrenberg、
Craig Raw、
Damian Mee、
Daniel Edgecumbe、
David A. Harding、
DA Williamson、
Elichai Turkel、
Emil Pfeffer、
Eoin McQuinn、
Eric Voskuil、
Erik Aronesty、
Felipe Micaroni Lalli、
Giacomo Caironi、
Gregory Maxwell、
Greg Sanders、
Jay Berg、
Jeremy Rubin、
John Newbery、
Johnson Lau、
Jonas Nick、
Karl-Johan Alm、
Keagan McClelland、
Lloyd Fournier、
Luke Dashjr、
Luke Kenneth Casson Leighton、
Mark Friedenbach、
Martin Schwarz、
Matt Corallo、
Matt Hill、
Michael Folkson、
Natanael、
Oleg Andreev、
Pavol Rusnak、
Pieter Wuille、
Prayank、
R E Broadley、
Riccardo Casatta、
Robert Spigler、
Ruben Somsen、
Russell O'Connor、
Rusty Russell、
Ryan Grant、
Salvatore Ingala、
Samson Mow、
Sjors Provoost、
Steve Lee、
Tamas Blummer、
Thomas Hartman、
Tim Ruffing、
Vincent Truong、
vjudeu、
yancy、
yanmaani——
以及
ZmnSCPxj。
</i>

Taproot 整合的 [schnorr 签名][topic schnorr signatures] 和 [MAST][topic mast] 等概念源起更早，我们同样感谢相关贡献者。

{:#taproot-bip-review}
## Taproot BIP 审查

自 2019 年 11 月起，大量用户和开发者参与了 Taproot 的[系统化审查][news69 review]：

<i>
achow101、
afk11、
aj、
alec、
amiti、
_andrewtoth、
andytoshi、
ariard、
arik、
b10c、
belcher、
bjarnem、
BlueMatt、
bsm1175321、
cdecker、
chm-diederichs、
Chris_Stewart_5、
cle1408、
CubicEarth、
Day、
ddustin、
devrandom、
digi_james、
dr-orlovsky、
dustinwinski、
elichai2、
evoskuil、
fanquake、
felixweis、
fjahr、
ghost43、
ghosthell、
gmaxwell、
harding、
hebasto、
instagibbs、
jeremyrubin、
jnewbery、
jonatack、
justinmoon、
kabaum、
kanzure、
luke-jr、
maaku、
mattleon、
michaelfolkson、
midnight、
mol、
Moller40、
moneyball、
murch、
nickler、
nothingmuch、
orfeas、
pinheadmz、
pizzafrank13、
potatoe_face、
pyskell、
pyskl、
queip、
r251d、
raj_149、
real_or_random、
robert_spigler、
roconnor、
sanket1729、
schmidty、
sipa、
soju、
sosthene、
stortz、
taky、
t-bast、
theStack、
Tibo、
waxwing、
xoyi——
以及
ZmnSCPxj。
</i>

{:#github-prs}
## GitHub 拉取请求

Taproot 在 Bitcoin Core 中的主要实现于 2020 年 1 月通过[两个][bitcoin core #17977]拉取[请求][bitcoin core #19953]提交审查。以下人士参与了代码审查：

<i>
Andrew Chow (achow101)、
Anthony Towns (ajtowns)、
Antoine Riard (ariard)、
Ben Carman (benthecarman)、
Ben Woosley (Empact)、
Bram (brmdbr)、
Cory Fields (theuni)、
Dmitry Petukhov (dgpv)、
Elichai Turkel (elichai)、
Fabian Jahr (fjahr)、
Andreas Flack (flack)、
Gregory Maxwell (gmaxwell)、
Gregory Sanders (instagibbs)、
James O'Beirne (jamesob)、
Janus Troelsen (ysangkok)、
Jeremy Rubin (JeremyRubin)、
João Barbosa (promag)、
John Newbery (jnewbery)、
Jon Atack (jonatack)、
Jonathan Underwood (junderw)、
Kalle Alm (kallewoof)、
Kanon (decryp2kanon)、
kiminuo、
Luke Dashjr (luke-jr)、
Marco Falke (MarcoFalke)、
Martin Habovštiak (Kixunil)、
Matthew Zipkin (pinheadmz)、
Max Hillebrand (MaxHillebrand)、
Michael Folkson (michaelfolkson)、
Michael Ford (fanquake)、
Adam Ficsor (nopara73)、
Pieter Wuille (sipa)、
Sjors Provoost (Sjors)、
Steve Huguenin-Elie (StEvUgnIn)、
Tim Ruffing (real-or-random)、
以及
Yan Pritzker (skwp)。
</i>

{:#taproot-activation-discussion}
## Taproot 激活讨论

社区围绕激活方式展开了数月讨论，主要参与者包括：

<i>
_6102bitcoin、
AaronvanW、
achow101、
aj、
alec、
Alexandre_Chery、
Alistair_Mann、
amiti、
andrewtoth、
andytoshi、
AnthonyRonning、
ariel25、
arturogoosnargh、
AsILayHodling、
averagepleb、
bcman、
belcher、
benthecarman、
Billy、
bitcoinaire、
bitentrepreneur、
bitsharp、
bjarnem、
blk014、
BlueMatt、
bobazY、
brg444、
btcactivator、
btcbb、
cato、
catwith1hat、
cguida、
CodeShark___、
conman、
copumpkin、
Crash78、
criley、
CriptoLuis、
CubicEarth、
darbsllim、
darosior、
Day、
DeanGuss、
DeanWeen、
debit、
Decentralizedb、
devrandom、
DigDug、
dome、
dr_orlovsky、
duringo、
dustinwinski、
eeb77f71f26eee、
eidnrf、
elector、
elichai2、
Emcy、
emzy、
entropy5000、
eoin、
epson121、
erijon、
eris、
evankaloudis、
faketoshi、
fanquake、
fedorafan、
felixweis、
fiach_dubh、
fjahr、
friendly_arthrop、
GeraldineG、
gevs、
gg34、
ghost43、
ghosthell、
giaki3003、
gloved、
gmaxwell、
graeme1、
GreenmanPGI、
gr-g、
GVac、
gwillen、
gwj、
gz12、
gz77、
h4shcash、
harding、
hebasto、
hiro8、
Hotmetal、
hsjoberg、
huesal、
instagibbs、
Ironhelix、
IT4Crypto、
ja、
jaenu、
JanB、
jeremyrubin、
jimmy53、
jnewbery、
jonatack、
jonny100051、
jtimon、
kallewoof、
kanon、
kanzure、
Kappa、
keblek、
ksedgwic、
landeau、
lucasmoten、
luke-jr、
maaku、
Majes、
maybehuman、
mblackmblack、
mcm-mike、
Memesan、
michaelfolkson、
midnight、
MikeMarzig、
mips、
mol、
molz、
moneyball、
mrb07r0、
MrHodl、
murch、
naribia、
newNickName、
nickler、
nikitis、
NoDeal、
norisgOG、
nothingmuch、
occupier、
OP_NOP、
OtahMachi、
p0x、
pinheadmz、
PinkElephant、
pox、
prayank、
prepaid、
proofofkeags、
provoostenator、
prusnak、
qubenix、
queip、
r251d、
rabidus、
Raincloud、
raj、
RamiDz94、
real_or_random、
rgrant、
riclas、
roasbeef、
robert_spigler、
rocket_fuel、
roconnor、
rovdi、
rubikputer、
RusAlex、
rusty、
sanket1729、
satosaurian、
schmidty、
sdaftuar、
setpill、
shesek、
shinobiusmonk、
snash779、
solairis、
somethinsomethin、
stortz、
sturles、
sugarpuff、
taPrOOteD、
TechMiX、
TheDiktator、
thomasb06、
tiagocs、
tomados、
tonysanak、
TristanLamonica、
UltrA1、
V1Technology、
vanity、
viaj3ro、
Victorsueca、
virtu、
walletscrutiny、
wangchun、
warren、
waxwing、
Whatisthis、
whuha、
willcl_ark、
WilliamSantiago、
windsok、
wumpus、
xxxxbtcking、
yanmaani、
yevaud、
ygrtiugf、
Yoghurt11411、
zmnscpxj、
以及
zndtoshi。
</i>

## 矿工信号

我们感谢自区块 681,408 以来所有发出 Taproot 准备就绪信号的矿工。

## 生态项目

Taproot 激活仅是起点，开发者与用户将开始运用其新特性。我们感谢多年筹备 [MuSig][topic musig] 等生态项目的贡献者。

## 全节点运营者

最关键的致谢致予数千名 Bitcoin Core 0.21.1 及以上版本（或兼容软件）的运营者。他们通过升级节点确保从区块 {{site.trb}} 开始仅接受符合 Taproot 规则的交易，为全网的升级安全提供经济保障。

{% include linkers/issues.md issues="17977,19953" %}
[maxwell taproot post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[good morning]: /en/preparing-for-taproot/#a-good-morning
[news69 review]: /zh/newsletters/2019/10/23/#taproot-review
