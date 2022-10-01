include "../node_modules/circomlib/circuits/mimcsponge.circom";

// Computes MiMC([left, right])
// 传入左边叶子和右边叶子，算两个叶子的父节点
template HashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    // 实例化hash组件
    component hasher = MiMCSponge(2, 1);
    // 把左边叶子和右边叶子的值传到hasher里
    hasher.ins[0] <== left;
    hasher.ins[1] <== right;
    hasher.k <== 0;
    // 得到结果
    hash <== hasher.outs[0];
}

// if s == 0 returns [in[0], in[1]]
// if s == 1 returns [in[1], in[0]]
// 传入in（2个元素的数组）、s
// 输出两个元素的数组
// 这个乍一看不知道在算啥玩意儿？
template DualMux() {
    signal input in[2];
    signal input s;
    signal output out[2];

    s * (1 - s) === 0
    out[0] <== (in[1] - in[0])*s + in[0];
    out[1] <== (in[0] - in[1])*s + in[1];
}

// Verifies that merkle proof is correct for given merkle root and a leaf
// pathIndices input is an array of 0/1 selectors telling whether given pathElement is on the left or right side of merkle path
// 验证函数
// 传入leaf、root、pathElements、pathIndices
// 根据root和提供的pathElements来计算出一个root，和传入的root做对比看是不是一样
// 一样的话就说明该叶子存在在树里
// pathElements是一个长度为levels的列表 因为这个树多深merkle proof就需要多少个叶子
// pathIndices是用来说明这是左边的叶子还是右边的叶子的array，用0和1来表示
template MerkleTreeChecker(levels) {
    signal input leaf;
    signal input root;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    component selectors[levels];
    component hashers[levels];

    //这里就是根据提供的merkle proof来计算根节点的过程
    for (var i = 0; i < levels; i++) {
        selectors[i] = DualMux();
        selectors[i].in[0] <== i == 0 ? leaf : hashers[i - 1].hash;
        selectors[i].in[1] <== pathElements[i];
        selectors[i].s <== pathIndices[i];

        hashers[i] = HashLeftRight();
        hashers[i].left <== selectors[i].out[0];
        hashers[i].right <== selectors[i].out[1];
    }

    // 最终拿传入的root和计算出来的进行比较
    // 相同的话说明该叶子节点存在
    root === hashers[levels - 1].hash;
}
