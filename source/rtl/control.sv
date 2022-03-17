module control(key0,key1,key2,key3,secret_key,decrypted,done);

input wire [23:0] key0, key1, key2, key3;
input wire [3:0] decrypted;
output logic [23:0] secret_key;
output logic done;


always_comb begin : controller
    case(decrypted)
        4'b0001:begin
            done <= 1'b1;
            secret_key <= key0;
        end
        4'b0010:begin
            done <= 1'b1;
            secret_key <= key1;
        end
        4'b0100:begin
            done <= 1'b1;
            secret_key <= key2;
        end
        4'b1000:begin
            done <= 1'b1;
            secret_key <= key3;
        end
        default:begin
            done <= 1'b0;
            secret_key <= 24'b0;
        end
    endcase
end

endmodule
