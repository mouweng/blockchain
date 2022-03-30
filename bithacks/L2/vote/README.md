# Vote Docs

## 创建投票

- 创建投票

```shell
dfx canister call vote createProposal '("Vote1", 0, 60)'
```

![创建投票](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301559649.jpg)

- 错误处理：重复创建投票

```shell
dfx canister call vote createProposal '("Vote1", 0, 60)'
dfx canister call vote createProposal '("Vote1", 0, 60)'
```

![错误处理：重复创建投票](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301600903.jpg)

- 错误处理：`startTime < 0`

```shell
dfx canister call vote createProposal '("Vote1", -1, 60)'
```

![错误处理：startTime < 0](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301600223.jpg)

- 错误处理：`startTime >= endTime`

```shell
dfx canister call vote createProposal '("Vote1", 61, 60)'
```

![错误处理：startTime >= endTime](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301600161.jpg)

## 获取投票信息

- 获取投票信息

```shell
dfx canister call vote getProposal '("Vote1")'
```

![获取投票信息](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301604730.jpg)

- 错误处理：获取不存在的投票

```shell
dfx canister call vote getProposal '("Vote-notExist")'
```

![错误处理：获取不存在的投票](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301603504.jpg)

## 投票

- 投票

```shell
dfx canister call vote createProposal '("Vote2", 20, 60)'
# wait 20 second 
dfx canister call vote vote '("Vote2", variant {Support})'
dfx canister call vote getProposal '("Vote2")'
```

![投票](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301618405.jpg)

- 错误处理：投票ID不存在

```shell
dfx canister call vote vote '("Vote-notExist", variant {Support})'
```

![错误处理：投票ID不存在](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301618278.jpg)

- 错误处理：投票未开始

```shell
dfx canister call vote createProposal '("Vote3", 20, 60)'
# before 20 second 
dfx canister call vote vote '("Vote3", variant {Support})'
```

![错误处理：投票未开始](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301617390.jpg)

- 错误处理：投票已结束

```shell
# after 60 second 
dfx canister call vote vote '("Vote3", variant {Support})'
```

![错误处理：投票已结束](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301617332.jpg)

- 错误处理：重复投票

```shell
dfx canister call vote createProposal '("Vote4", 20, 60)'
# wait 20 second 
dfx canister call vote vote '("Vote4", variant {Support})'
dfx canister call vote vote '("Vote4", variant {Support})'
```

![错误处理：重复投票](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301620427.jpg)

## 返回投票结果

- 返回投票结果

  - Draw：平票

    ```shell
    dfx canister call vote proposalResult '("Vote1")'         
    ```

    ![Draw：平票](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301623024.jpg)

  - Approved：同意

    ```shell
    dfx canister call vote proposalResult '("Vote2")'
    ```

    ![Approved：同意](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301623097.jpg)

  - Rejected：拒绝

    ```shell
    dfx canister call vote proposalResult '("Vote5")'
    ```

    ![Rejected：拒绝](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301625104.jpg)

    

- 错误处理：投票ID不存在

  ```shell
  dfx canister call vote proposalResult '("Vote-notExist")'
  ```

  ![错误处理：投票ID不存在](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301624960.jpg)

- 错误处理：投票未结束

  ```shell
  dfx canister call vote proposalResult '("Vote5")'
  ```

  ![错误处理：投票未结束](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301625104.jpg)

## 升级测试

```shell
# 重新deploy
dfx deploy
# 查看数据是否存在
dfx canister call vote proposalResult '("Vote5")'
dfx canister call vote getProposal '("Vote2")' 
```

![升级测试](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301629091.jpg)

## 部署主网

- 部署主网

```
dfx deploy --network ic
```

![部署主网](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301637180.jpg)

- 测试

```shell
dfx canister --network ic call aiw53-oaaaa-aaaai-acaoq-cai createProposal '("Vote-Ic", 0, 200)'
dfx canister --network ic call aiw53-oaaaa-aaaai-acaoq-cai vote '("Vote-Ic", variant {Support})'
```

![](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301642472.jpg)

```shell
dfx canister --network ic call aiw53-oaaaa-aaaai-acaoq-cai getProposal '("Vote-Ic")'
dfx canister --network ic call aiw53-oaaaa-aaaai-acaoq-cai proposalResult '("Vote-Ic")'
```

![](https://cdn.jsdelivr.net/gh/mouweng/FigureBed/img/202203301643428.jpg)