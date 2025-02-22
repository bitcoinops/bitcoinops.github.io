[上周专栏][taproot series vaults]中，Antoine Poinsot 描述了 taproot 如何提升[保险库][topic vaults]式资金备份与安全方案的隐私性和手续费效率。本周我们将探讨其他几种可通过迁移至 taproot 获得改进的备份与安全方案。

- **<!--simple-2-of-3-->****简单 2-of-3：** 如[前文][threshold signing]所述，结合[多签][topic multisignature]和脚本路径支出，可轻松创建 2-of-3 支出策略。正常情况下其链上效率与单签支出相当，且比当前 P2SH 和 P2WSH 多签方案更隐私。异常情况下的效率和隐私性也表现良好。这使 taproot 成为从单签钱包升级到多签策略的理想选择。

  我们预计未来的[门限签名][topic threshold signature]技术将进一步优化 2-of-3 及其他 k-of-n 场景。

- **<!--degrading-multisignatures-->****降级多签：** [Optech Taproot 研讨会][taproot workshop]中的练习可体验创建支持以下规则的 taproot 脚本：随时由三个密钥支出；三天后由原密钥中的两个支出；十天后仅需一个原密钥（该练习还涉及备份密钥，我们将在下一点单独讨论）。调整时间参数和密钥设置可构建灵活强大的备份方案。

  例如，假设正常支出需笔记本电脑、手机和硬件签名设备三者协同。若其中一设备不可用，等待一个月后可用剩余两设备支出。若两设备不可用，六个月后仅需一设备即可支出。

  正常三设备协同使用时，链上脚本实现最高效和隐私。其他情况下效率略降但仍保持合理隐私性（脚本及其树深与其他合约相似）。

- **<!--social-recovery-for-backups-and-security-->****社交恢复备份与安全：** 上述示例在设备被盗时提供良好保护，但若两设备同时被盗呢？若钱包使用频繁，设备丢失后需等待一个月才能恢复支出是否合理？

  taproot 可便捷、低成本且隐私地添加社交元素。除上述脚本外，还可允许：两设备加两位亲友签名即时支出；或单一密钥加五位信任者签名即时支出（非社交版本可使用额外设备或备份助记词）。

- **<!--combining-time-and-social-thresholds-for-inheritance-->****时间与社交阈值结合的继承方案：** 综合上述技术，可设置在你突发意外时允许指定个人或群体恢复资金。例如，若比特币六个月未移动，允许律师和五位亲属中的三位支出。若你本就每六个月操作资金，该继承方案在你生前无额外链上成本且对外完全隐私。甚至可让律师和亲属在你生前无法知晓交易详情（只需确保他们能在你离世后获取钱包的扩展公钥 xpub）。

  请注意，继承人具备技术能力支出比特币不等同于合法继承。建议计划比特币继承者阅读 Pamela Morgan 的《加密资产继承规划》（[实体书/DRM 电子书][cip amazon] 或 [DRM-free 电子书][cip aantonop]），并与本地遗产规划专家讨论细节。

- **<!--compromise-detection-->****入侵检测：** taproot 诞生前提出的[树签名][tree signatures]方案建议在所有设备上放置控制少量比特币的密钥作为入侵检测。若金额足够诱人，攻击者可能选择立即盗取而非长期潜伏造成更大损失。

  该方案的挑战在于：需设置足够吸引攻击者的金额，但又不愿在每台设备存放大量比特币（希望仅提供一份高额赏金）。若所有设备使用相同密钥，攻击交易无法定位被入侵设备。taproot 允许为每台设备设置不同密钥和脚本路径。任一密钥均可支出全部资金，同时精确定位被入侵设备。

[taproot series vaults]: /zh/preparing-for-taproot/#使用-taproot-的保险库
[cip amazon]: https://amazon.com/Cryptoasset-Inheritance-Planning-Simple-Owners/dp/1947910116
[cip aantonop]: https://aantonop.com/product/cryptoasset-inheritance-planning-a-simple-guide-for-owners/
[tree signatures]: https://blockstream.com/2015/08/24/en-treesignatures/#h.2lysjsnoo7jd
[threshold signing]: /zh/preparing-for-taproot/#threshold-signing
[taproot workshop]: https://github.com/bitcoinops/taproot-workshop
