{:.post-meta}
*作者：[Roman Taranchenko][]，[Suredbits][] 工程师*

在第一次使用闪电网络发送支付，尤其是成功接收支付的兴奋过后，如何以安全可靠的方式操作你的节点是一个需要思考的问题。故障几乎总是出乎意料地发生。遇到可能的故障后如何恢复？如何让备份更加可靠？如何将种子保存在一个安全的地方？等等，等等……

在 [Suredbits][]，我们使用 Eclair 作为我们的节点软件。尽管 Eclair 本身已经相当稳健，我们仍采取了一些措施以进一步提高其可靠性——例如使用 PostgreSQL 作为数据库后端（[通过此 PR][db pr]），并使用 [AWS Secrets Manager][] 来存储私钥。

Eclair 内置了在线备份功能，但它需要手动设置和编写脚本来实现自动化，这在大规模操作中并不适用，而且容易出错。使用 AWS RDS 运行 PostgreSQL 使我们能够以一种 DevOps 工程师熟悉的方式来自动化备份和复制，并简化了数据库状态的恢复。

将 PostgreSQL 作为远程数据库后端使得实现节点故障切换更加简单，因为如果节点由于某种原因崩溃，就无需从备份中恢复数据库——你所需要做的只是将一个新的 Eclair 实例指向正确的数据库服务器。以下是一个使用两个 Eclair 实例加上 AWS 的 RDS、ELB 和 NAT Gateway 实现的自动故障切换的[快速演示][failover demo]。

在演示中所描述的故障切换场景中，我们需要一种安全的方式来允许 Eclair 实例之间共享其私钥种子。Eclair 将种子存储在本地文件系统中的一个文件里，这个文件应该被备份到某个地方，并在需要时恢复。目前的 Eclair 实现需要额外的步骤才能实现自动化。我们使用 AWS Secrets Manager——一个专门设计用于安全存储各种秘密信息（包括数据库密码和加密密钥）的加密键值存储。现在，只需在配置文件中将实例指向正确的密钥位置即可共享种子。一旦配置完成，实例就可以存储为 AMI 镜像，可以在无需手动配置的情况下根据需要多次重建。

我们采取的这些措施只是构建企业级闪电网络节点的第一步。仍然有一些问题需要解决。例如，哪些硬件安全模块（HSM）可以用于闪电网络节点，或者如何在多实例环境中实现 Bitcoin Core 节点的故障切换。但我们相信，我们的工作为扩展 Eclair 并使其更加容错奠定了坚实的基础。

有关此主题的更多信息，请参见我们的[演讲][enterprise ln vid]。

*免责声明：由于涉及私钥，在未进行彻底的风险评估前，请勿使用第三方云服务。*

[Roman Taranchenko]: https://github.com/rorp
[Suredbits]: https://suredbits.com
[db pr]: https://github.com/ACINQ/eclair/pull/1249
[AWS Secrets Manager]: https://github.com/rorp/eclair/tree/aws_secretsmanager
[failover demo]: https://youtu.be/L2DtolwS8ew
[enterprise ln vid]: https://www.youtube.com/watch?v=tbwy9mJIrZ