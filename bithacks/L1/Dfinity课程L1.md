# Dfinity开发课程L1

- [dfinity开发学习第二课笔记](https://blog.csdn.net/fuckthatcode/article/details/123139609)
- [子理notion链接](https://www.notion.so/ICP-Motoko-Basics-e35b40358854426daf33da4d6be35fe4)
- [motoko官方文档](https://smartcontracts.org/docs/language-guide/motoko.html)
- [开发者免费领取Cycles并部署canister到I.C.主网](https://qiuyedx.com/?p=744)

## 一、安装与起步

### 1.安装dfx

```shell
# 运行下载与安装脚本
sh -ci "$(curl -fsSL https://smartcontracts.org/install.sh)"

# 配置环境
export PATH=/path/to/bin:$PATH

# 查询是否安装成功
dfx --version

# 查询命令帮助
dfx --help

# 查询命令使用
dfx wallet -h
```

### 2.dfx获取 Cycles 钱包

- [获取地址]([https://faucet.dfinity.org](https://faucet.dfinity.org/))

```shell
# 查看身份 Principal ID
dfx identity get-principal

# 绑定身份
dfx identity --network=ic set-wallet <THAT CANISTER_ID>
```

![](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203262035031.jpg)

```shell
# 查看身份 Principal ID
dfx identity get-principal
gxjsc-vtj65-dj6zd-lcevc-pw4gm-hdzcu-urnfk-huihg-opvee-rpqae-fqe
# 绑定身份
dfx identity --network=ic set-wallet xxkvp-6aaaa-aaaai-ab7xa-cai
```

### 3.开发环境搭建

- 准备一下vs code插件

    > 语法和高亮辅助，安装后需要在setting中配置编译器的位置。

![](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203262041380.jpg)

## 二、使用dfx

### 1.创建项目

```shell
# new一个项目，带前端
dfx new <Project_Name>

# new一个项目，不带前端
dfx new <Project_Name> --no-frontend
```

### 2.编写Actor

```c
import Nat "mo:base/Nat";

actor {
	func fib(n: Nat): Nat {
		if (n < 2) {
			1
		} else {
			fib(n-2) + fib (n-1)
		}
	};
    public func fibonacci(x: Nat): async Nat {
    	fib(x)
    }
}
```

### 3.本地部署

```shell
# 启动本地IC网络
dfx start

# 在后台启动本地IC网络
dfx start --background

# 部署
dfx deploy

# 关闭本地计算机运行的本地容器执行环境进程
dfx stop
```

### 4.使用moc调试程序

```shell
# 添加编译器依赖到环境 
# 每次都需要配置
export PATH=$(dfx cache show):$PATH 

# 查看是否成功
which moc

# 调试
moc -r path/to/your/code.mo

# 添加库依赖
moc --package base $(dfx cache show)/base -r path/to/your/code.mo
```



### 5.执行调用

- 命令行调用canister方法

```shell
dfx canister call [option] canister_name method_name [argument] [flag]
```

```shell
dfx canister call mysite fibonacci '(10)'
```

- 通过Canister UI调用canister方法

![](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203262106093.jpg)

- 在项目目录下`.dfx/local/canister_ids.json`中找到`Candid_UI`

- 在浏览器运行：`r7inp-6aaaa-aaaaa-aaabq-cai.localhost:8000`

![](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203262111621.jpg)

- 输入`newsite.local`，为canister ID（`rrkah-fqaaa-aaaaa-aaaaq-cai`）

![](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203262112338.jpg)

- 在 Candid UI进行测试

### 6.网络部署

- 部署命令

```shell
# 部署到IC网络
dfx deploy --network ic

# 指定数额的部署
dfx deploy --network ic --with-cycles=400000000000
```

### 7.其他命令

```shell
# 检查Internet Computer网络的当前状态和是否能链接
dfx ping ic

# 查询开发者身份的名字
dfx identity whoami

# 查询当前身份链接的负责人的文本标识符
dfx identity get-principal

# 查询开发人员身份的账户标识符
dfx ledger account-id

# 现实账户余额
dfx ledger --network ic balance
```

## 三、作业

> 用motoko 实现一个快排函数

```c
import Array "mo:base/Array";
import Int "mo:base/Int";
import Nat "mo:base/Nat";

actor {
    // quickSort
    func qSort(arr : [var Int], l : Nat, r : Nat){
        if (l >= r) return;
        var q = arr[l]; var i = l; var j = r;
        while(i < j){
            while (i < j and arr[j] >= q) j -= 1;
            arr[i] := arr[j];
            while (i < j and arr[i] <= q) i += 1;
            arr[j] := arr[i];
        };
        arr[j] := q;
        if(i >= 1) qSort(arr, l, i - 1);
        qSort(arr, i + 1, r);
    };

    public func quickSort(arr : [Int]) : async [Int] {
        if(arr.size() <= 0) {
            return arr;
        };
        var newArr : [var Int] = Array.thaw(arr);
        qSort(newArr, 0, newArr.size() - 1);
        Array.freeze(newArr)
    };
};

```

