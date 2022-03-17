module message(address, clock, q);

input wire clock;
input logic [4:0] address;

output logic [7:0] q;

//Message 1
/*
always_ff @( posedge clock ) begin : message
    case(address)
	 0 : q<=45;
	 1 : q<=143;
	 2 : q<=122;
	 3 : q<=169;
	 4 : q<=56;
	 5 : q<=115;
	 6 : q<=95;
	 7 : q<=135;
	 8 : q<=69;
	 9 : q<=27;
	 10 : q<=130;
	 11 : q<=134;
	 12 : q<=75;
	 13 : q<=155;
	 14 : q<=127;
	 15 : q<=157;
	 16 : q<=239;
	 17 : q<=13;
	 18 : q<=196;
	 19 : q<=187;
	 20 : q<=249;
	 21 : q<=119;
	 22 : q<=153;
	 23 : q<=117;
	 24 : q<=255;
	 25 : q<=213;
	 26 : q<=96;
	 27 : q<=115;
	 28 : q<=1;
	 29 : q<=248;
	 30 : q<=22;
	 31 : q<=37;
     default: q<=8'bx;
    endcase
end
*/
//message 8
always_ff @( posedge clock ) begin : message
    case(address)
	 0 : q<=204;
	 1 : q<=17;
	 2 : q<=1;
	 3 : q<=253;
	 4 : q<=162;
	 5 : q<=220;
	 6 : q<=106;
	 7 : q<=22;
	 8 : q<=133;
	 9 : q<=65;
	 10 : q<=96;
	 11 : q<=122;
	 12 : q<=113;
	 13 : q<=222;
	 14 : q<=240;
	 15 : q<=33;
	 16 : q<=106;
	 17 : q<=221;
	 18 : q<=47;
	 19 : q<=38;
	 20 : q<=2;
	 21 : q<=224;
	 22 : q<=7;
	 23 : q<=173;
	 24 : q<=10;
	 25 : q<=184;
	 26 : q<=8;
	 27 : q<=149;
	 28 : q<=213;
	 29 : q<=62;
	 30 : q<=145;
	 31 : q<=94;
     default: q<=8'bx;
    endcase
end
endmodule

