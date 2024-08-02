{% auto_anchor %}
常言道：“模仿是最真诚的恭维。” 在本周的部分，我们快速了解了一些使用 bech32 变体的其他系统。如果你已经需要为另一个项目实现类似 bech32 的东西，那么为 Bitcoin 实现它可能值得你花时间。

- **<!--ln-invoices-->****LN 发票** 使用带有扩展的可读部分 (HRP) 的 bech32 格式，并且没有 bech32 通常的 90 字符限制。详见 [BOLT11][] 的完整规范。示例：
  `lnbc2500u1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypqdq5xysxxatsyp3k7enxv4jsxqzpuaztrnwngzn3kdzw5hydlzf03qdgm2hdq27cqv3agm2awhz5se903vruatfhq77w3ls4evs3ch9zw97j25emudupq63nyw24cg27h2rspfj9srp`

- **<!--bitcoin-cash-new-style-addresses-->****Bitcoin Cash 新型地址** 使用 HRP 为 `bitcoincash` 和分隔符 `:` 的 bech32 格式。与 Bitcoin 中的版本字节编码 segwit 见证版本不同，它表示地址编码的哈希应该用于 P2PKH 还是 P2SH。详见 [spec-cashaddr][] 的完整规范。示例：
  `bitcoincash:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a`

- **<!--backup-seeds-->****备份种子：** 2018 年 6 月，Jonas Schnelli 提出了 Bech32X，一种使用 bech32 进行错误校正来编码 Bitcoin 私钥、扩展私钥 (xprivs) 和扩展公钥 (xpubs) 的方案。详见完整的[草案规范][bech32x]。示例：
  `pk1lmll7u25wppjn5ghyhgm7kndgjwgphae8lez0gra436mj7ygaptggl447a4xh7`

- **<!--elements-based-sidechains-->****基于 Elements 的侧链：** 基于 [ElementsProject.org][] 的侧链，如 [Blockstream Liquid][]，使用 bech32 地址和一种称为 “blech32” 地址的变体。Blech32 地址旨在与该平台的[保密资产][confidential assets]一起使用，并将很快由 Liquid 侧链的 Esplora 块浏览器支持。我们不知道 blech32 的规范文档，但[此代码][blech32 py]被标记为参考实现，并在项目其他地方被引用为 “参见 liquid_addr.py 获取与 bech32 的紧凑差异。” blech32 地址示例：
  `lq1qqf8er278e6nyvuwtgf39e6ewvdcnjupn9a86rzpx655y5lhkt0walu3djf9cklkxd3ryld97hu8h3xepw7sh2rlu7q45dcew5`

- **<!--output-script-descriptors-->****输出脚本描述符：** 尽管与 bech32 的关系不那么直接，但基于 bech32 使用的 Bose-Chaudhuri-Hocquenghem (BCH) 码的校验和已被添加到 Bitcoin Core 支持的[输出脚本描述符][output script descriptors] 中。详见 Pieter Wuille 的[详细评论][descriptors checksum]。示例：
  `wpkh([f6bb4c63/0'/0'/28']02bf9d38386db60191f2f785cbf7ba90d01bed5958efb7b449a552b89da7550177)#efkksxw6`

[descriptors checksum]: https://github.com/bitcoin/bitcoin/blob/fd637be8d21a606e98c037b40b268c4a1fae2244/src/script/descriptor.cpp#L24
[spec-cashaddr]: https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/cashaddr.md
[bech32x]: https://gist.github.com/jonasschnelli/68a2a5a5a5b796dc9992f432e794d719
[elementsproject.org]: https://elementsproject.org/
[blockstream liquid]: https://blockstream.com/liquid/
[confidential assets]: https://elementsproject.org/features/confidential-transactions
[blech32 py]: https://github.com/ElementsProject/elements/commit/9cb2fa051fcbe0fe66f15e6b88d224d1935376f4#diff-265badc7e18059096c32a61b0eada470
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
{% endauto_anchor %}
