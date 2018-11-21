# Project 1

## CRC设计

| Signal  | Direction | Description           |
| :-----: | :-------: | :-------------------: |
| A[7:0]  | Input     | 8位源数据帧           |
| B[3:0]  | Input     | 4位除数               |
| C[10:0] | Output    | 8位源数据帧+3位校验码 |

### 4位模二除法器

| Signal | Direction | Description  |
| :----: | :-------: | :----------: |
| A[3:0] | Input     | 4位被除数    |
| B[3:0] | Input     | 4位除数      |
| C[2:0] | Output    | 3位余数      |
| D      | Output    | 商(Optional) |

## 4位ALU

| Signal     | Direction | Description        |
| :--------: | :-------: | :----------------: |
| A[3:0]     | Input     | 参与计算的第一个值 |
| B[3:0]     | Input     | 第二个值           |
| ALUOp[1:0] | Input     | 功能选择           |
| C[3:0]     | Output    | 计算结果           |

### 功能选择

| ALUOp | 功能  |
| :---: | :---: |
| 00    | 加法  |
| 01    | 减法  |
| 10    | 与    |
| 11    | 或    |

## General Register Files

| Signal    | Direction | Description                  |
| :-------: | :-------: | :--------------------------: |
| clk       | Input     | 时钟信号                     |
| reset     | Input     | 复位：1清零(上升沿)，0无效   |
| WE        | Input     | 写使能: 1写入(上升沿)，0无效 |
| A1[4:0]   | Input     | 指定一个寄存器，读出至RD1    |
| A2[4:0]   | Input     | 指定一个寄存器，读出至RD2    |
| A3[4:0]   | Input     | 指定一个寄存器，将WD写入     |
| WD[31:0]  | Input     | 32位写入信号                 |
| RD1[31:0] | Output    | 输入A1指定寄存器的数据       |
| RD2[31:0] | Output    | 输入A2指定寄存器的数据       |

## Finite State Machine

| Signal  | Direction | Description                         |
| :-----: | :-------: | :---------------------------------: |
| In[1:0] | Input     | 串行输入字符串，00表a，01表b，10表c |
| CLK     | Input     | 时钟信号                            |
| CLR     | Input     | 复位（同步）                        |
| Z       | Output    | 输出结果                            |

### State

见另一文件