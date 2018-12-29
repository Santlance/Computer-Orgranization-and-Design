/*
 * name: mips
 * author: btapple
 * description: top module
 */

`ifndef __MIPS_V__
`define __MIPS_V__
`include "./macro.vh"
`include "./core.v"
`include "./bridge.v"
`include "./memory_controller.v"
`include "./utils/TC.v"
`include "./utils/digital_tube.v"
`include "./utils/dipswitch.v"
`include "./utils/led.v"
`include "./utils/userkey.v"
`include "./utils/uart.v"
`timescale 1ns / 1ps

module mips(
    input clk_in,
    // input clk_in_2,
    input sys_rstn,

    input [7:0] dip_switch0,
    input [7:0] dip_switch1,
    input [7:0] dip_switch2,
    input [7:0] dip_switch3,
    input [7:0] dip_switch4,
    input [7:0] dip_switch5,
    input [7:0] dip_switch6,
    input [7:0] dip_switch7,

    input [7:0] user_key,

    output [31:0] led_light,

    output [7:0] digital_tube2,
    output digital_tube_sel2,
    output [7:0] digital_tube1,
    output [3:0] digital_tube_sel1,
    output [7:0] digital_tube0,
    output [3:0] digital_tube_sel0,

    input uart_rxd,
    output uart_txd
);

    wire reset;
    wire clk, clk2;
    // assign clk = clk_in;
    // assign clk2 = clk_in_2;
    wire [`Word] PrRD;
    wire [15:0] PrAddr,Addr;
    wire [`Word] PrWD,WD;
    wire [6:0] PrHIT;
    // wire [`Word] PrPC,PC;
    wire PrWE;
    wire [3:0] PrBE,BE;
    wire [5:0] HWInt;
    wire MEMWE,Dev0WE,Dev1WE,Dev2WE,Dev3WE,Dev4WE,Dev5WE;
    wire Dev1STB;
    wire [`Word] MEMRD,Dev0RD,Dev1RD,Dev2RD,Dev3RD,Dev4RD,Dev5RD;
    wire Dev0Irq;

    // assign uart_txd = uart_rxd;

    Clock _clock(
        .CLK_IN(clk_in),
        .CLK(clk),
        .CLK2(clk2)
    );

    Core _core(
        .clk(clk),
        .clk2(clk2),
        .reset(reset),
        .PrRD(PrRD),
        .HWInt(HWInt),
        .PrAddr(PrAddr),
        .PrWD(PrWD),
        .PrWE(PrWE),
        .PrBE(PrBE),
        .PrHIT(PrHIT)
        // .PrPC(PrPC)
    );

    Bridge _bridge(
        .PrAddr(PrAddr),
        .Addr(Addr),
        .PrHIT(PrHIT),
        .PrWE(PrWE),
        .PrWD(PrWD),
        .WD(WD),
        .PrBE(PrBE),
        .BE(BE),
        .Dev1STB(Dev1STB),
        .MEMWE(MEMWE), .Dev0WE(Dev0WE), .Dev1WE(Dev1WE), .Dev2WE(Dev2WE), .Dev3WE(Dev3WE), .Dev4WE(Dev4WE), .Dev5WE(Dev5WE),
        .MEMRD(MEMRD), .Dev0RD(Dev0RD), .Dev1RD(Dev1RD), .Dev2RD(Dev2RD), .Dev3RD(Dev3RD), .Dev4RD(Dev4RD), .Dev5RD(Dev5RD),
        .PrRD(PrRD),
        .Dev0Irq(Dev0Irq), .Dev1Irq(Dev1Irq),
        .HWInt(HWInt)
        // .PrPC(PrPC),
        // .PC(PC)
    );

    Memory_Controller _memory_controller
    (
        .clk(clk2),
        .reset(reset),
        .we(MEMWE),
        .be(BE),
        .addr(Addr),
        .wd(WD),
        // .PC(PC),
        .rd(MEMRD)
    );

    // Device 0 Timer
    TC #(`DEV0ADDR_BEGIN) _tc
    (
        .clk(clk),
        .reset(reset),
        .addr(Addr),
        .we(Dev0WE),
        .wd(WD),
        .RD(Dev0RD),
        .IRQ(Dev0Irq)
        // .PC(PC)
    );

    // Device 1 UART
    MiniUART _miniuart(
        .CLK_I(clk),
        .DAT_I(WD),
        .DAT_O(Dev1RD),
        .RST_I(reset),
        .ADD_I(Addr[5:2]),
        .STB_I(Dev1STB),
        .WE_I(Dev1WE),
        .RxD(uart_rxd),
        .TxD(uart_txd),
        .IRQ(Dev1Irq)
    );

    // Device 2 Dipswitch
    Dipswitch _dipswitch(
        .reset(reset),
        .Addr(Addr[2]),
        .dip_switch0(~dip_switch0),
        .dip_switch1(~dip_switch1),
        .dip_switch2(~dip_switch2),
        .dip_switch3(~dip_switch3),
        .dip_switch4(~dip_switch4),
        .dip_switch5(~dip_switch5),
        .dip_switch6(~dip_switch6),
        .dip_switch7(~dip_switch7),
        .RD(Dev2RD)
    );

    // Device 3 LED
    LED _led(
        .clk(clk),
        .reset(reset),
        .we(Dev3WE),
        .wd(WD),
        .RD(Dev3RD),
        .led(led_light)
    );

    // Device 4 Digital_Tube
    Digital_Tube _digital_tube(
        .clk(clk),
        .reset(reset),
        .we(Dev4WE),
        .wd(WD),
        .RD(Dev4RD),
        .digital_tube2(digital_tube2),
        .digital_tube_sel2(digital_tube_sel2),
        .digital_tube1(digital_tube1),
        .digital_tube_sel1(digital_tube_sel1),
        .digital_tube0(digital_tube0),
        .digital_tube_sel0(digital_tube_sel0)
    );

    // Device 5 Userkey
    Userkey _userkey(
        .sys_rstn(sys_rstn),
        .user_key(~user_key),
        .reset(reset),
        .RD(Dev5RD)
    );

endmodule // mips
`endif