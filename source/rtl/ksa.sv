module ksa(CLOCK_50,KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
    /*----------------------*/
    /*    Port Define       */
    /*----------------------*/
    input CLOCK_50;
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0;
    output [6:0] HEX1;
    output [6:0] HEX2;
    output [6:0] HEX3;
    output [6:0] HEX4;
    output [6:0] HEX5;

    /*---------------------------*/
    /*    Connection Define      */
    /*---------------------------*/
    wire clk, reset;
    wire [3:0] KEY;
    assign clk = CLOCK_50;
    assign reset = ~KEY[3];

    wire [9:0] LED;
    assign LEDR = LED;

    wire stop;
    wire [23:0] key0, key1, key2, key3, secret_key;
    wire [3:0] decrypted;
    /*------------------------------*/
    /*    Decrypt Core Implement    */
    /*------------------------------*/
    fsm core0(
        .clk(clk),
        .key(key0),
		  .keyin(24'h00_00_00),	//000000 for general decrypted message
        .reset(reset),
        .stop(stop),
        .done(decrypted[0])
    );
    fsm core1(
        .clk(clk),
        .key(key1),
		  .keyin(24'h10_00_00),	//400000 for general decrypted message
        .reset(reset),
        .stop(stop),
        .done(decrypted[1])
    );
    fsm core2(
        .clk(clk),
        .key(key2),
		  .keyin(24'h20_00_00),	//800000 for general decrypted message
        .reset(reset),
        .stop(stop),
        .done(decrypted[2])
    );
    fsm core3(
        .clk(clk),
        .key(key3),
		  .keyin(24'h30_00_00),	//c00000 for general decrypted message
        .reset(reset),
        .stop(stop),
        .done(decrypted[3])
    );

    /*-------------------------------*/
    /*    Control Logic Implement    */
    /*-------------------------------*/
    wire done;
    control controller(key0,key1,key2,key3,secret_key,decrypted,done);
    
    
    /*---------------*/
    /*    Displays   */
    /*---------------*/
    assign stop = reset?0:done;
    assign LED[0] = done;
	 assign LED[9:6] = decrypted;
	 assign LED[5:2] = {key3[14],key2[14],key1[14],key0[14]};

    logic [6:0] HEX0;
    logic [6:0] HEX1;
    logic [6:0] HEX2;
    logic [6:0] HEX3;
    logic [6:0] HEX4;
    logic [6:0] HEX5;

    SevenSegmentDisplayDecoder Digit0(HEX0,secret_key[3:0]);
    SevenSegmentDisplayDecoder Digit1(HEX1,secret_key[7:4]);
    SevenSegmentDisplayDecoder Digit2(HEX2,secret_key[11:8]);
    SevenSegmentDisplayDecoder Digit3(HEX3,secret_key[15:12]);
    SevenSegmentDisplayDecoder Digit4(HEX4,secret_key[19:16]);
    SevenSegmentDisplayDecoder Digit5(HEX5,secret_key[23:20]);

endmodule
