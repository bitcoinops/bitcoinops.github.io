---
title: 'Bitcoin Optech Newsletter #147'
permalink: /ja/newsletters/2021/05/05/
name: 2021-05-05-newsletter-ja
slug: 2021-05-05-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、マイナーにTaprootのシグナリングを開始することを推奨し、
ウォレットシードのみで失われたLNチャネルを閉じることについての継続的な議論を掲載しています。
また、リリースおよびリリース候補の公表や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点などの通常のセクションも含まれています。

## 要処置事項

- **<!--miners-encouraged-to-start-signaling-for-taproot-->マイナーはTaprootのシグナリングを開始することが推奨されます:**
  [Taproot][topic taproot]の新しいコンセンサスルールの適用を期待するマイナーは、シグナリングを開始し、
  [BIP341で定義されている最小アクティベーションブロック](https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#deployment)までに
  Bitcoin Core 0.21.1 (後述) または他の互換性のあるTaproot適用ソフトウェアを実行できるようにすることが推奨されます。

    シグナリングの状況をトラストレスに監視したい人は、Bitcoin Core 0.21.1にアップグレードし、
    `getblockchaininfo` RPCを使用できます。例えば、以下のコマンドラインは、
    現在のリターゲット期間中のブロック数、その内シグナルを出したブロック数、
    そして（再編成がないと仮定して）この期間中にTaprootがアクティベートできるかどうかを表示します:

    ```text
    $ bitcoin-cli getblockchaininfo \
      | jq '.softforks.taproot.bip9.statistics | .elapsed,.count,.possible'
    353
    57
    false
    ```

    マイナーの進捗状況に関する補足情報を含むグラフィカルな表現を好み、
    自身のノードを使用する必要のない場合は、Hampus Sjöbergの[taproot.watch][]をお勧めします。

## ニュース

- **<!--closing-lost-channels-with-only-a-bip32-seed-->BIP32シードのみで失われたチャネルを閉じる:**
  [ニュースレター #128][news128 ln ecdh]に掲載したように、
  Lloyd FournierはBIP32ウォレットシード以外の情報を失ったユーザーが、
  LNネットワークの公開情報だけを使ってピアを再発見できるようにする新しいチャネル作成方法を提案しました。
  ユーザーがピアを発見すると、[BOLT2][] Data Loss Protectionプロトコル（[ニュースレター #31][news31 data_loss]参照）を使用して、
  チャネルを閉じるよう要求できます。提案された方法は完全ではなく、
  ユーザーはバックアップを作成し[^missing-peer]、それを独立したシステムに複製する必要があります。
  しかし、Fournierの提案は、日常的に使用するユーザーにとって有用な追加の冗長性を提供します。

    2週間前、Rusty Russellはこのアイディアを[具体化し][russell ecdh spec]実装しようとした後、
    [スレッド][russell ecdh channels]を再開しました。Fournierとのメーリングリストでの追加の議論と、
    週次のLNプロトコル開発会議でのグループ[会話][lndev deterministic]の後、
    Russellはこのアイディアに傾倒していることを次のように[述べています][russell backups]。
    "暗号化されたバックアップは実装される可能性が高いソリューションだと考えている。なぜなら、
    ピア以外の場所に送信するのに便利で、必要に応じてHTLCの情報を含めることもできるからだ。"
    [HTLC][topic htlc]の情報を含めることができると、その時点で保留中だった支払いを決済できます。
    これはBIP32シードのみに基づくリカバリーの仕組みでは実現できない機能です。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 0.21.1][Bitcoin Core 0.21.1]は、
  提案されている[Taproot][topic taproot]ソフトフォークのアクティベーションロジックを含む
  Bitcoin Coreの新バージョンです。
  Taprootは、[Schnorr 署名][topic schnorr signatures]を使用し、
  [Tapscript][topic tapscript]が使用できるようになります。
  これらはそれぞれBIP [341][BIP341]、[340][BIP340]および[342][BIP342]で定義されています。
  また、[BIP350][]で定義された[bech32m][topic bech32]アドレスへの支払い機能も含まれていますが、
  ビットコインをmainnetでそのようなアドレスに送信するのは、
  そのようなアドレスを使用するTaprootのようなソフトフォークがアクティベーションされるまで安全ではありません。
  このリリースにはバグ修正と小さな改善も追加されています。

    注: Windows版のBitcoin Coreのコード署名証明書を提供する認証局に[問題][wincodesign]があるため、
    Windowsユーザーは追加のプロンプトをクリックしてインストールする必要があります。
    問題が修正されたら、証明書が更新された0.21.1.1がリリースされる予定です。
    アップグレードを計画している場合は、この問題によって0.21.1の使用を遅らせる必要はありません。

- [BTCPay 1.1.0][]は、このセルフホスト型の支払い処理ソフトウェアの最新のメジャーリリースです。
  [Lightning Loop][news53 lightning loop]のサポート、
  二要素認証のオプションとして[WebAuthN/FIDO2][fido2 website]の追加、
  さまざまなUIの改善および、
  今後のバージョン番号の[セマンティックバージョニング][semantic versioning website]への切り替えを行っています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #19160][]は、[マルチプロセスプロジェクト][bitcoin core multiprocess]のPRで、
  `bitcoin-node`プロセスが他のプロセスを起動し、
  [Cap'n Proto][capn proto]を使ってそのプロセスと通信する機能を追加します。
  これらの機能は現在テストにしか使われていませんが、プロジェクトの[次のPR][Bitcoin Core #10102]では、
  `bitcoin-core`プロセスが`bitcoin-wallet`プロセスと`bitcoin-gui`プロセスを別々に起動するマルチプロセスモードで
  Bitcoin Coreを起動できるようになります。

- [Bitcoin Core #19521][]では、
  `gettxoutsetinfo`RPCを劇的に高速化する[コイン統計インデックスプロジェクト][bitcoin core coinstats]がほぼ完了しました。
  これまでは、RPCが呼び出されるたびにデフォルトでUTXOセット全体をスキャンしていたため、
  ユーザーが継続的かつ迅速にコインの供給量を検証したり、異なるノード間でUTXOセットのハッシュを比較したりすることが困難でした。
  ユーザーは、`-coinstatsindex`設定オプションを付けてノードを起動し、
  バックエンドでコイン統計インデックスの構築を開始できるようになりました。
  同期が完了すると、`gettxoutsetinfo`はほぼ瞬時に実行され、統計情報の高さやブロックハッシュを指定できます。
  特定のブロックの統計情報を取得できることは、
  [AssumeUTXO][topic assumeutxo]のchainstateアーカイブをコミュニティが検証する際に役立ちます。

- [Bitcoin Core #21009][]は、（v0.13.0以前の）pre-segwitノードをsegwit適用バージョンに更新する際に発生する
  RewindBlockIndexロジックを削除しました。pre-segwitノードは、
  (segregated) witnessデータが取り除かれたブロックのみを処理していました。
  RewindBlockIndexロジックはそのようなブロックのコピーを破棄し、
  完全な形で再ダウンロードし、segwitルールを使ってそれらを検証していました。
  pre-segwitノードは2018年以降end-of-lifeを迎えたため、このシナリオは一般的ではなくなりました。
  今後のリリースでは、同等の結果を得るために代わりにインデックスを再作成するようユーザーに促すようになります。

- [LND #5159][]は、[以前の作業][news144 lnd ampsendpayment]に基づいて、
  `sendpayment`RPCに支払いパラメータを手動で指定することで、
  Spontaneous Atomic Multipath Payments (AMP)のサポートを追加しました。
  AMPインボイスを使った`sendpayment`の実行は、後続のPRで実装される予定です。

- [Rust-Lightning #893][]は、Payment Secretが含まれている場合にのみ支払いを受け入れることができます。
  Payment Secretは、受信者によって作成され、インボイスに含まれます。
  送信者は、第三者が[マルチパス・ペイメント][topic multipath payments]のプライバシーを低減させようとするのを防ぐために、
  支払いの中にPayment Secretを含めます。今回の変更に加えて、支払いが誤って受理される可能性を減らすために設計された
  いくつかのAPIの変更があります。

- [BIPs #1104][]は、Speedy Trialの提案（[ニュースレター #139][news139 speedy trial]参照）に基づいた
  アクティベーションパラメータで、[Taproot][topic taproot]の[BIP341][]仕様を更新しています。

## 脚注

[^missing-peer]:
    Data Loss Protectionプロトコルや、
    [チャネルクローズの秘密要求][news128 covert]などの他の提案された方法では、
    チャネルピアがオンラインで応答する必要があります。
    もし相手が永久に利用不能な状態になり、あなたがバックアップを持っていない場合、
    あなたの資金は永久に失われます。代わりにバックアップから復元した場合でも、
    古いステートをブロードキャストするとすべての資金を失う可能性がありますが、
    最新のステートをバックアップしていたり、
    相手のピアが古いステートに異議を唱えなかった場合は、資金を回収するチャンスがあります。

{% include references.md %}
{% include linkers/issues.md issues="19160,19521,21009,5159,893,1104,10102" %}
[bitcoin core 0.21.1]: https://bitcoincore.org/bin/bitcoin-core-0.21.1/
[btcpay 1.1.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.1.0
[wincodesign]: https://github.com/bitcoin-core/gui/issues/252#issuecomment-802591628
[russell ecdh channels]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002996.html
[russell ecdh spec]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002998.html
[russell backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/003026.html
[news128 covert]: /en/newsletters/2020/12/16/#covert-request-for-mutual-close
[taproot.watch]: https://taproot.watch/
[news128 ln ecdh]: /en/newsletters/2020/12/16/#fast-recovery-without-backups
[news31 data_loss]: /en/newsletters/2019/01/29/#fn:fn-data-loss-protect
[news139 speedy trial]: /ja/newsletters/2021/03/10/#a-short-duration-attempt-at-miner-activation
[lndev deterministic]: https://lightningd.github.io/meetings/ln_spec_meeting/2021/ln_spec_meeting.2021-04-26-20.17.log.html#l-115
[bitcoin core multiprocess]: https://github.com/bitcoin/bitcoin/projects/10
[capn proto]: https://capnproto.org/
[bitcoin core coinstats]: https://github.com/bitcoin/bitcoin/pull/18000
[news53 lightning loop]: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[semantic versioning website]: https://semver.org/
[fido2 website]: https://fidoalliance.org/fido2/fido2-web-authentication-webauthn/
[news144 lnd ampsendpayment]: /ja/newsletters/2021/04/14/#lnd-5108
