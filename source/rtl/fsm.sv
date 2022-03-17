module fsm(clk,key,keyin,stop,reset,done);
    /*----------------------*/
    /*    Port Define       */
    /*----------------------*/
    input wire clk;
	 input wire reset;
    input logic stop;
	 input wire [23:0] keyin;
    output [23:0] key;
    output logic done;

    /*---------------------------*/
    /*      Variable Define      */
    /*---------------------------*/
    reg [7:0] i, j, k, tmp_i, tmp_j;
    reg [23:0] key;
    
    reg [7:0] secret_key [3];
    //assign secret_key = key_input;
	assign secret_key[0] = key[23:16];
	assign secret_key[1] = key[15:8];
	assign secret_key[2] = key[7:0];
	 
	 
    /*---------------------------*/
    /*     Parameter Define      */
    /*---------------------------*/
    localparam key_length = 3;
    localparam message_length = 32;

    /*---------------------------*/
    /*     Memory Implement      */
    /*---------------------------*/
    reg [7:0] address, data, q;
    reg wren;
    s_memory s_mem (
    .address ( address ),
    .clock ( clk ),
    .data ( data ),
    .wren ( wren ),
    .q ( q )
    );

    reg [7:0] address_d, data_d, q_d;
    reg wren_d;
    d_memory	d_mem (
	.address ( address_d ),
	.clock ( clk ),
	.data ( data_d ),
	.wren ( wren_d ),
	.q ( q_d )
	);

    reg [7:0] address_m, q_m;
    message	message_inst (
        .address ( address_m ),
        .clock ( clk ),
        .q ( q_m )
        );


    /*---------------------------*/
    /*  Finite State Machine     */
    /*---------------------------*/
    //Need Control: wren
    typedef enum {
        //Task 1 States
        init_data, init, init_fill, write, write_finish,
        //Task 2a States
        swap1_init, swap1_loop, swap1_wait1, swap1_read_i, swap1_accum, swap1_wait2,
        swap1_read_j, swap1_write_j, swap1_wait3, swap1_write_i, swap1_wait4,
        swap1_return, swap1_finish,
        //Task 2b States
        swap2_init, swap2_loop, swap2_inc_i, swap2_wait1, swap2_read_i, swap2_calc_j,
        swap2_wait2, swap2_read_j, swap2_write_j, swap2_wait3, swap2_write_i, swap2_wait4,
        swap2_read_data, swap2_wait5, swap2_write_d, swap2_wait6, swap2_finish,
        //Task 3 States
        task3_check_data,task3_secretkey_inc, idle
        } state_type;
    
    state_type state;


    always_ff @( posedge clk) begin : fsm
        if(stop) state <= idle;
		  else if(reset) state <= init_data;
		  else case(state)
            /*---------------------------*/
            /*      Variable Init        */
            /*---------------------------*/
				init_data: begin
				    key <= keyin;
					state <= init;
				end
            init: begin
                //Clear Variables
                i <= 8'b0;
                j <= 8'b0;
                k <= 8'b0;
                tmp_i <= 8'b0;
                tmp_j <= 8'b0;
                //Clear s_memory control wires
                address <= 8'b0;
                data <= 0;
                wren <= 0;
                //Clear d_memory control wires
                address_d <= 8'b0;
                data_d  <= 8'b0;
                wren_d <= 1'b0;
                //Clear m_memory control wires
                address_m <= 8'b0;
                //Clear flags
                done <= 1'b0;
				state <= init_fill;
            end

            /*---------------------------*/
            /*  Task 1: Memory Filling   */
            /*---------------------------*/
            init_fill:begin
                address <= i;
                data <= i;
                wren <= 1;
                state <= write;
            end

            write: begin
                if(i == 8'hff)
                    state <= write_finish;
                else begin
                    state <= init_fill;
                    i <= i + 1;
                end
            end

            write_finish: begin
                wren <= 1'b0;
                state <= swap1_init;
            end

            /*---------------------------*/
            /*  Task 2a: Swap Memory     */
            /*---------------------------*/

            //Initialize variables needed in task 2a
            swap1_init:begin
                i <= 8'b0;
                j <= 8'b0;
                address <= 0;
                data <= 0;
                wren <= 0;
                done <= 0;
                tmp_i <= 8'b0;
                tmp_j <= 8'b0;
                state <= swap1_loop;
            end

            swap1_loop:begin
                address <= i;
                state <= swap1_wait1;
            end

            swap1_wait1: begin
                state <= swap1_read_i;
            end

            //Read s[i], store to tmp_i
            swap1_read_i: begin
                tmp_i <= q;
                state <= swap1_accum;
            end

            //Accumulate j
            //j = j + s[i] + secret_key[i mod keylength]
            swap1_accum: begin
                address <= j + tmp_i + secret_key[i % key_length];
                j <= j + tmp_i + secret_key[i % key_length];
                state <= swap1_wait2;
            end

            swap1_wait2:begin
                state <= swap1_read_j;
            end

            //Read s[j], store to tmp_j
            swap1_read_j: begin
                tmp_j <= q;
                state <= swap1_write_j;
            end

            //Write s[j] to address i
            swap1_write_j: begin
                address <= i;
                data <= tmp_j;
                wren <= 1'b1;
                state <= swap1_wait3;
            end

            swap1_wait3: begin
                if(q == tmp_j) begin
                    wren <= 1'b0;
                    state <= swap1_write_i;
                end else begin
                    state <= swap1_wait3;
                end
            end

            //Write s[i] to address j
            swap1_write_i: begin
                address <= j;
                data <= tmp_i;
                wren <= 1'b1;
                state <= swap1_wait4;
            end
            
            swap1_wait4: begin
                if( q == tmp_i) begin
                    wren <= 1'b0;
                    state <= swap1_return;
                end else begin
                    state <= swap1_wait4;
                end
            end

            swap1_return: begin
                if(i < 8'hff) begin
                    i <= i + 1'b1;
                    state <= swap1_loop;
                end else begin
                    state <= swap1_finish;
                end
            end

            swap1_finish: begin
                wren <= 1'b0;
                state <= swap2_init;
            end

            /*---------------------------*/
            /*  Task 2b: Decode Memory   */
            /*---------------------------*/

            swap2_init: begin
                //Clear Variables
                i <= 8'b0;
                j <= 8'b0;
                k <= 8'b0;
                tmp_i <= 8'b0;
                tmp_j <= 8'b0;
                //Clear s_memory control wires
                address <= 8'b0;
                data <= 8'b0;
                wren <= 1'b0;
                //Clear d_memory control wires
                address_d <= 8'b0;
                data_d  <= 8'b0;
                wren_d <= 1'b0;
                //Clear m_memory control wires
                address_m <= 8'b0;
                //Clear flags
                done <= 1'b0;
                //Next State
                state <= swap2_inc_i;
            end

            //Increment i, set all address appropiately
            swap2_inc_i: begin
                i <= i + 1;
                address <= i + 1;
                address_m <= k;
                address_d <= k;
                state <= swap2_wait1;
            end

            swap2_wait1: begin
                state <= swap2_read_i;
            end

            //Read s[i]
            swap2_read_i: begin
                tmp_i <= q;
                state <= swap2_calc_j;
            end

            //Calculate j: j = j + s[i]
            swap2_calc_j: begin
                j <= j + tmp_i;
                address <= j + tmp_i;
                state <= swap2_wait2;
            end

            swap2_wait2: begin
                state <= swap2_read_j;
            end

            //Read s[j]            
            swap2_read_j: begin
                tmp_j <= q;
                state <= swap2_write_j;
            end

            //Write s[i] to address j;
            swap2_write_j: begin
                //address <= j;
                data <= tmp_i;
                wren <= 1'b1;
                state <= swap2_wait3;
            end

            swap2_wait3: begin
                if(q == tmp_i) begin
                    wren <= 1'b0;
                    state <= swap2_write_i;
                end else begin
                    state <= swap2_wait3;
                end 
            end

            //Write s[i] to address j
            swap2_write_i: begin
                address <= i;
                data <= tmp_j;
                wren <= 1'b1;
                state <= swap2_wait4;
            end

            swap2_wait4: begin
                if(q == tmp_j) begin
                    wren <= 1'b0;
                    state <= swap2_read_data;
                end else begin
                    state <= swap2_wait4;
                end
            end

            // Go to address s[i] + s[j]
            swap2_read_data:begin
                address <= tmp_i + tmp_j;
                state <= swap2_wait5;
            end

            swap2_wait5: begin
                state <= swap2_write_d;
            end

            //Write decrepted message
            swap2_write_d: begin
                //f = q;
                //encrypted_input[k] = q_m;
                data_d <= q ^ q_m;
                wren_d = 1'b1;
                state <= swap2_wait6;
            end

            swap2_wait6: begin
                if(q_d == data_d) begin
                    wren_d <= 0;
                    state <= task3_check_data;      //Modified for Task 3
                end
                else state <= swap2_wait6;
            end

            
            swap2_loop: begin
                if(k == 31) begin
                    state <= swap2_finish;
                end else begin
                    k <= k + 1;
                    state <= swap2_inc_i;
                end
            end

            swap2_finish: begin
                wren = 1'b0;
                wren_d = 1'b0;
                done = 1'b1;
                state <= idle;
            end
            

            
            /*---------------------------*/
            /*   Task 3: Crack Memory    */
            /*---------------------------*/
            task3_check_data: begin
                //Check if data is valid
                if((data_d >= 8'd97 && data_d <= 8'd122) || data_d == 8'd32)
                    state <= swap2_loop;
                else
                    state <= task3_secretkey_inc;
            end

            //Data not valid, increment secret key
            task3_secretkey_inc: begin
                key <= key + 1;
                state <= init;
            end

            idle: begin
                state <= idle;
            end

            default: state <= init_data;
        endcase

        
    end

endmodule
