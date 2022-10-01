include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/pedersen.circom";
include "merkleTree.circom";

// computes Pedersen(nullifier + secret)
template CommitmentHasher() {
    // 传入两个参数：nullifier和secret
    // 计算出nullifier的hash和commitment
    // commitment是nullifier+secret的hash
    signal input nullifier;
    signal input secret;
    signal output commitment;
    signal output nullifierHash;

    component commitmentHasher = Pedersen(496);
    component nullifierHasher = Pedersen(248);
    component nullifierBits = Num2Bits(248);
    component secretBits = Num2Bits(248);
    // <==是电路里的赋值符号
    // 这里.in 《== 的意思是把nullifier的值传递给nullifierBits作为input
    // nullifierBits是一个componnet，我理解应该是和其他语言里的函数一个意思？ 赋值.in之后用.out就可以获得输出的结果
    // nullifierBits应该是把一个数以bit为单位拆开处理
    nullifierBits.in <== nullifier;
    secretBits.in <== secret;
    // 一个bit一个bit地处理
    // 把nullifierBits.out的输出值作为nullifierHasher组件的输入，得到nullifierHasher
    // 把nullifierBits.out的输出值作为commitmentHasher前一半输入，secretBits.out的输出值作为另一半输入，两个拼接起来的到commitmentHasher
    for (var i = 0; i < 248; i++) {
        nullifierHasher.in[i] <== nullifierBits.out[i];
        commitmentHasher.in[i] <== nullifierBits.out[i];
        commitmentHasher.in[i + 248] <== secretBits.out[i];
    }

    commitment <== commitmentHasher.out[0];
    nullifierHash <== nullifierHasher.out[0];
}

// Verifies that commitment that corresponds to given secret and nullifier is included in the merkle tree of deposits
// 带有private修饰的参数是不被暴露给外部的
// 这里传入了root、nullifierHash
// root是merkle tree根，是用来和计算出来的root对比，从而证明一个叶子节点是否存在的
// private的参数：nullifier、secret、pathElements[levels]、pathElements[levels]
template Withdraw(levels) {
    signal input root;
    signal input nullifierHash;
    signal input recipient; // not taking part in any computations
    signal input relayer;  // not taking part in any computations
    signal input fee;      // not taking part in any computations
    signal input refund;   // not taking part in any computations
    signal private input nullifier;
    signal private input secret;
    signal private input pathElements[levels];
    signal private input pathElements[levels];

    // 前面定义的函数作为一个component，计算出nullifierHash
    component hasher = CommitmentHasher();
    hasher.nullifier <== nullifier;
    hasher.secret <== secret;
    hasher.nullifierHash === nullifierHash;

    // 调用MerkleTreeChecker函数，传入levels（应该是merkle tree的深度），返回树，等下去看看这个函数定义，在隔壁文件里
    component tree = MerkleTreeChecker(levels);
    // 把用CommitmentHasher计算出来的commitment放到叶子节点
    tree.leaf <== hasher.commitment;
    tree.root <== root;
    // 一层一层地把叶子节点传到tree组件里去
    for (var i = 0; i < levels; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }

    // Add hidden signals to make sure that tampering with recipient or fee will invalidate the snark proof
    // Most likely it is not required, but it's better to stay on the safe side and it only takes 2 constraints
    // Squares are used to prevent optimizer from removing those constraints、
    // 这里是检验recipient or fee的？
    // 还不知道具体啥用
    signal recipientSquare;
    signal feeSquare;
    signal relayerSquare;
    signal refundSquare;
    recipientSquare <== recipient * recipient;
    feeSquare <== fee * fee;
    relayerSquare <== relayer * relayer;
    refundSquare <== refund * refund;
}

component main = Withdraw(20);
