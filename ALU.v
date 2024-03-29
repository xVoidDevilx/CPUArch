`timescale 1ns/1ps

/*
    Name: Silas Rodriguez
    R-Number: R-11679913
    Assignment: Project 6
*/
/**

    * ALU.v
    * This module is responsible for performing the arithmetic and logic operations
    * Inputs:
    *  clk - Clock signal
    *  a - Data from register A
    *  b - Data from register B
    *  op - Operation to be performed

    * Outputs:
    *  out - Result of operation
    *  zflag - Zero flag
    *  nflag - Negative flag
    *  cflag - Carry flag
    *  vflag - Two's compliment overflow flag
    *  sflag - Sign flag
    *  hflag - Half carry flag
*/
module ALU(
    input [31:0] a,    //input a data bus
    input [31:0] b,    //input b data bus
    input [4:0] op,    //operation to be performed
    input zin,
    input cin,
    input vin,
    input hin,
    input nin,
    input sin,

    output reg [31:0] out,
    output reg zflag,      //zero flag
    output reg nflag,      //negative flag
    output reg cflag,       //carry flag
    output reg vflag,       //two's compliment overflow flag
    output wire sflag,       //sign flag
    output reg hflag,       //half carry flag
    output reg branch       //if a branch is supposed to be taken
);
    //I want this flag to update when the status register changes
    assign sflag = nflag ^ vflag;
    
    always @(*) begin
        branch = 0; //assume no branch
        case (op)
            //LD -> flags should remain what they were before
            5'h01: begin
                out = b;    // my design uses b as a passthrough
            end
            //ST -> flags should remain what they were before
            5'h02: begin
                out = a;    // my design uses a as a passthrough
            end
            //add
            5'h03: begin
                out = a + b;
                cflag = (out < a);
                vflag = (out[31] && ~a[31] && ~b[31])||(~out[31] && a[31] && b[31]);
                //out neg, a pos, b pos, pos+pos = neg   //out pos, a neg, b neg, neg+neg = pos
                hflag = ((a[15:0] + b[15:0]) < a[15:0]);    //add the lower words, then comare if lower than either word
                zflag = (out == 0);
                nflag = (out[31]);
            end
            //sub
            5'h04: begin
                out = a - b;
                cflag = (out > a);
                hflag = ((a[15:0] + b[15:0]) > a[15:0]);    //add the lower words, then comare if lower than either word
                zflag = (out == 0);
                nflag = (out[31]);
                vflag = (~out[31] && a[31] && ~b[31]) || (out[31] && ~a[31] && b[31]);
                        //out pos, a neg, b pos neg-pos = pos   //out neg, a pos, b neg pos-neg = neg
            end
            //and
            5'h05: begin 
                out = a & b;
                cflag = 0;
                hflag = 0;
                zflag = (out == 0);
                nflag = (out[31]);
                vflag = 0;   //based on msp430 manual
            end
            //or
            5'h06: begin
                out = a | b;
                cflag = 0;
                hflag = 0;
                zflag = (out == 0);
                nflag = (out[31]);
                vflag = 0;   //based on msp430 manual
            end
            //xor
            5'h07: begin
                out = a ^ b;
                cflag = 0;
                hflag = 0;
                zflag = (out == 0);
                nflag = (out[31]);
                vflag = (out[31] && a[31]==0 && b[31]==0)||(~out[31] && a[31] && b[31]);;   //based on msp430 manual
            end
            //not
            5'h08: begin 
                out = ~a;
                cflag = 0;
                hflag = 0;
                zflag = (out == 0);
                nflag = (out[31]);
                vflag = 0;   //based on msp430 manual
            end
            //SL
            5'h09: begin
                out = a << (b-1);
                cflag = out[31];
                hflag = out[15];    //get the bit below the upper word
                out = out << 1;
                zflag = (out == 0);
                nflag = (out[31]);
                vflag = (out[31] && a[31]==0 && b[31]==0)||(~out[31] && a[31] && b[31]);;   //based on msp430 manual
            end
            //SR
            5'h0A: begin
                out = a >> (b-1);
                cflag = out[0];
                hflag = out[16];    //get the bit above the lower word
                out = out >> 1;
                zflag = (out == 0);
                nflag = (out[31]);
                vflag = (out[31] && a[31]==0 && b[31]==0)||(~out[31] && a[31] && b[31]);;   //based on msp430 manual
            end

            /////////////// This is branching section-> out mux must be set to program counter //////////////
            //BZ
            5'h10: begin
                if (zin == 1) begin
                    out = b;    // the address to jump to is in b (litsrc)
                    branch = 1; //confirm branch is taken
                end
            end
            //BNZ
            5'h11: begin
                if (zin == 0) begin
                    out = b;    // the address to jump to is in b (litsrc)
                    branch = 1; //confirm branch is taken
                end
            end
            //BRA
            5'h12: begin
                out = b;    // the address to jump to is in b (litsrc)
                branch = 1; //confirm branch is takens
            end
        endcase
    end

endmodule