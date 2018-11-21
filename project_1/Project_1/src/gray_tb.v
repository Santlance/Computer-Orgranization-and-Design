`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:50:47 10/25/2018
// Design Name:   gray
// Module Name:   D:/Computer Orgranization and Design/project_1/Project_1/gray_tb.v
// Project Name:  Project_1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: gray
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module gray_tb;

	// Inputs
	reg Clk;
	reg Reset;
	reg En;

	// Outputs
	wire [2:0] Output;
	wire Overflow;
	wire [2:0] Output_;
	wire Overflow_;
	// Instantiate the Unit Under Test (UUT)
	gray uut (
		.Clk(Clk), 
		.Reset(Reset), 
		.En(En), 
		.Output(Output), 
		.Overflow(Overflow)
	);
	initial begin
		// Initialize Inputs
		Clk <= 0;
		Reset <= 0;
		En <= 0;

		// Wait 100 ns for global reset to finish
//		#100
		// Add stimulus here
	end
	
    always #10 Clk=~Clk;
	always #40 En=~En;
	always #800 Reset=~Reset;
endmodule

