We hope this series has given readers a better idea of what’s going on
while they are waiting for confirmation. We started with a discussion
about how some of the ideological values of Bitcoin
[translate][policy01] to its structure and design goals. The
distributed structure of the peer-to-peer network offers increased
censorship resistance and privacy over a typical centralized model. An
open transaction relay network helps everybody learn about
transactions in blocks prior to confirmation, which improves [block
relay efficiency][policy01], makes joining as a new miner more
accessible, and creates a [public auction for block space][policy02].
As the ideal network consists of many independent, anonymous entities
running nodes, node software must be designed to [protect against
DoS][policy05] and generally minimize operational costs.

Fees play an important role in the Bitcoin network as the "fair" way
to resolve competition for block space. Mempools with transaction
replacement and package-aware selection and eviction algorithms use
[incentive compatibility][policy02] to measure the utility of storing
a transaction, and enable [RBF][topic rbf] and [CPFP][topic
cpfp] as fee-bumping mechanisms for users.  The combination of these
mempool policies, wallets that [construct transactions
economically][policy03], and good [feerate estimation][policy04]
create an efficient market for block space that benefits everybody.

Individual nodes also enforce _transaction relay policy_ to [protect
themselves against resource exhaustion][policy05] and [express
personal preference][policy06]. At a [network-wide level][policy07],
standardness rules and other policies protect resources that are
critical to scaling, accessibility of running a node, and ability to
update consensus rules. As the vast majority of the network enforces
these policies, they are an important part of the [interface][policy08]
that Bitcoin applications and L2 protocols build upon. They also aren't
perfect.  We described several [policy-related proposals][policy09]
that address broad limitations and specific use cases such as [pinning
attacks on L2 settlement transactions][policy08].

We also highlighted that the ongoing evolution of network
policies requires collaboration between developers working on
protocols, applications, and wallets. As the Bitcoin ecosystem grows
with respect to software, use cases, and users, a decentralized
decision-making process becomes more necessary but also more
challenging. Even as Bitcoin adoption grows, the system emerges from
the concerns and efforts of its stakeholders – there is no company in
charge of gathering customer feedback and hiring engineers to build
new protocol features or remove unused features. Stakeholders who wish to be part of the rough
consensus of the network have different avenues of participating:
informing themselves, surfacing questions and issues, involving
themselves in the design of the network, or even contributing to the
implementation of improvements. Next time your transaction is taking
too long to confirm, you know what to do!

[policy01]: /en/newsletters/2023/05/17/#waiting-for-confirmation-1-why-do-we-have-a-mempool
[policy02]: /en/newsletters/2023/05/24/#waiting-for-confirmation-2-incentives
[policy03]: /en/newsletters/2023/05/31/#waiting-for-confirmation-3-bidding-for-block-space
[policy04]: /en/newsletters/2023/06/07/#waiting-for-confirmation-4-feerate-estimation
[policy05]: /en/newsletters/2023/06/14/#waiting-for-confirmation-5-policy-for-protection-of-node-resources
[policy06]: /en/newsletters/2023/06/21/#waiting-for-confirmation-6-policy-consistency
[policy07]: /en/newsletters/2023/06/28/#waiting-for-confirmation-7-network-resources
[policy08]: /en/newsletters/2023/07/05/#waiting-for-confirmation-8-policy-as-an-interface
[policy09]: /en/newsletters/2023/07/12/#waiting-for-confirmation-9-policy-proposals
