module alu(
    input      [31:0] data_A,
    input      [31:0] data_B,
    input      [4:0]  shamt,
    input      [3:0]  alu_sel,
    input             B_sel,
    output     [31:0] alu_out
);

assign alu_out =    (alu_sel == 4'd0 ) ? $signed(data_A) + $signed(data_B) :            //add, addi
                    (alu_sel == 4'd1 ) ? $signed(data_A) - $signed(data_B) :            //sub
                    (alu_sel == 4'd2 ) ? data_A ^ data_B :                              //xor, xori
                    (alu_sel == 4'd3 ) ? data_A | data_B :                              //or, ori
                    (alu_sel == 4'd4 ) ? data_A & data_B :                              //and, andi
                    (alu_sel == 4'd5 ) ? (B_sel ? $signed($signed(data_A) << $signed({27'b0, shamt})) : $signed($signed(data_A) << ($signed(data_B[4:0])))) :   //slli : sll
                    (alu_sel == 4'd6 ) ? (B_sel ? ($signed(data_A) >> $signed({27'b0, shamt})) : ($signed(data_A) >> $signed(data_B[4:0]))) :                   //srli : srl
                    (alu_sel == 4'd7 ) ? (B_sel ? $signed($signed(data_A) >>> $signed({27'b0, shamt})) : $signed($signed(data_A) >>> $signed(data_B[4:0]))) :   //srai : sra
                    (alu_sel == 4'd8 ) ? (($signed(data_A) < $signed(data_B)) ? 1:0) :  //slt, slti
                    (alu_sel == 4'd9 ) ? ((data_A < data_B) ? 1:0) :                    //sltu, sltiu
                    (alu_sel == 4'd10) ? data_B:                                        //lui
                    (alu_sel == 4'd11) ? data_A + $signed(data_B):                      //auipc
                    {'X};

endmodule
