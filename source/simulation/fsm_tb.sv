module fsm_tb;

    logic clk, stop, reset, done;
    logic [23:0] key, keyin;

    fsm DUT(
        .clk(clk),
        .key(key),
        .keyin(keyin),
        .stop(stop),
        .reset(reset),
        .done(done)
    );

    always #5 clk = ~clk;

    always @(*) begin
        if(done) begin
            #100 $stop;
        end
    end

    initial begin
        #0 clk = 0; reset = 0; stop = 0; keyin <= 0;
    end

endmodule
