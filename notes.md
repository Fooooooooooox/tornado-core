tornado的电路非常简单，可能这是理解+上手zk最简单的例子

# 隐私交易？同质化和非同质化
tornado是利用zk来混淆同质化token转账的来源，从而使得一笔交易的来源无法追踪
在使用tornado的时候你会发现只可以存储固定金额的token，比如0.1， 1， 10
同质化/非同质化
隐私交易只能用在同质化的token上，因为非同质化的token本身就带有信息，你没有办法转移这个token同时不暴露来源。
非同质化的token的隐私要怎么做呢？（可以参考sismos的zk badge：笔记：https://brassy-raincoat-323.notion.site/sismos-1b95c737fcd74e95a6764d3c3043df19
涉及到隐私，非同质化的token只能转移信息，而不能转移资产本身
（sismos使用的原理和tornado一样，但是本质区别在于同质化和非同质化）

# 使用tornado的流程
1. 在tornado的contract中存入一定数额的eth，并且提供一个commitment存储到合约上（merkle tree里）
2. 一段时间后，用另一个账户取出钱，取钱的时候需要提供nullifier + zero-knowledge proof
3. 因为这个合约内有其他用户的钱存在，并且存取钱的过程使用了零知识证明，所以没有人能把新账户和存钱的人联系起来

剩下的细节：
搞清楚commitment、nullifier、zero-knowledge proof怎么生成的

# nullifier

The nullifier is a unique ID that is in connection with the commitment and the ZKP proves the connection, but nobody knows which nullifier is assigned to which commitment (except the owner of the depositor/withdrawal account).

# commitment
We can prove that one of the commitments is assigned to our nullifier, without revealing our commitment.


取钱的时候，提供两个证明：
一个证明你拥有这笔钱，一个证明这笔钱只能被取一次
1. The first proves that the Merkle tree contains your commitment. This proof is a zero-knowledge proof of a Merkle proof. 
2. provide a nullifier that is unique for the commitment. The contract stores this nullifier, this ensures that you don’t be able to withdraw the deposited money more than one time.

commitment在生成的时候用到了nullifier，不一样的nullifier生成不一样的commitment，所以commitment和nullifier是一一对应的
commitment = hash(secret, nullifier)

ref：
https://betterprogramming.pub/understanding-zero-knowledge-proofs-through-the-source-code-of-tornado-cash-41d335c5475f