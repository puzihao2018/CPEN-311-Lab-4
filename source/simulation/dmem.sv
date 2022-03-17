module d_memory(address, clock, data, wren, q);

input wire clock;
input logic [4:0] address;
input logic [7:0] data;
input wire wren;
output logic [7:0] q;

reg [7:0] mem [32];

always_ff @( posedge clock ) begin : dmem
    if(wren) mem[address] <= data;

    q <= mem[address];
end

endmodule
