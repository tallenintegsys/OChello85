/* Copyright 2020 Gregory Davill <greg.davill@gmail.com> */
`default_nettype none

/*
 *  Blink a LED on the OrangeCrab using verilog
 */

module top (
    input clk48,
    output rgb_led0_r,
    output rgb_led0_g,
    output rgb_led0_b,
	output rst_n,
	input usr_btn
);
    // Create a 27 bit register
    logic [26:0] counter = 0;
    //assign rst_n = usr_btn;

    // Every positive edge increment register by 1
    always @(posedge clk48) begin
        counter <= counter + 1;
    end

    // Output inverted values of counter onto LEDs
    assign rgb_led0_r = ~counter[24];
    assign rgb_led0_g = ~counter[25];
    assign rgb_led0_b = ~counter[26];

	// reset module instance
	orangecrab_reset reset(
		.clk(clk48), 
		.do_reset(usr_btn),  
		.nreset_out(rst_n)
	);

endmodule
