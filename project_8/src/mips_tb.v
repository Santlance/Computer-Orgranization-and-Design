`timescale 1ns / 1ps
module mips_tb;
    reg clk;
    reg reset;
    reg [7:0] dip_switch0;
    reg [7:0] dip_switch1;
    reg [7:0] dip_switch2;
    reg [7:0] dip_switch3;
    reg [7:0] dip_switch4;
    reg [7:0] dip_switch5;
    reg [7:0] dip_switch6;
    reg [7:0] dip_switch7;
    reg [7:0] user_key;
    wire [7:0] digital_tube0;
    mips _mips(
        .clk_in(clk),
        .sys_rstn(~reset),
        .dip_switch0(dip_switch0),
        .dip_switch1(dip_switch1),
        .dip_switch2(dip_switch2),
        .dip_switch3(dip_switch3),
        .dip_switch4(dip_switch4),
        .dip_switch5(dip_switch5),
        .dip_switch6(dip_switch6),
        .dip_switch7(dip_switch7),
        .user_key(user_key),
        .digital_tube0(digital_tube0)
    );
    initial
        begin
            clk=0;
            reset=1;
            dip_switch0 = 5;
            dip_switch1 = 0;
            dip_switch2 = 0;
            dip_switch3 = 0;
            dip_switch4 = 0;
            dip_switch5 = 0;
            dip_switch6 = 0;
            dip_switch7 = 0;
            #200;
            reset<=0;
        end
    always #5 clk=~clk;
    // always #5 $display("%h",digital_tube0);
endmodule // mips_tb
