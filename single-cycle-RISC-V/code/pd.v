module pd(
  input clock,
  input reset
);

//FETCH STAGE
reg  [31:0] f_pc;
wire [31:0] f_insn;
wire        f_pc_sel;

always @(posedge clock) begin
  if(reset) begin
    f_pc <= 32'h01000000;
  end else begin
    f_pc <= (f_pc_sel) ? e_alu_res : f_pc + 4;
  end
end

reg [31:0] f_data_in;
imemory imemory_0 (
  .clock      (clock),
  .address    (f_pc),
  .read_write (0),
  .data_in    (f_data_in),
  .data_out   (f_insn)
);

//DECODE STAGE
reg  [31:0] d_pc    = f_pc;
wire [31:0] d_insn  = f_insn;

wire [6:0]  d_opcode;
wire [4:0]  d_rd;
wire [2:0]  d_funct3;
wire [4:0]  d_rs1;
wire [4:0]  d_rs2;
wire [6:0]  d_funct7;
wire [4:0]  d_shamt;

decoder decoder_0 (
  .insn   (d_insn),
  .opcode (d_opcode),
  .rd     (d_rd),
  .funct3 (d_funct3),
  .rs1    (d_rs1),
  .rs2    (d_rs2),
  .funct7 (d_funct7),
  .shamt  (d_shamt)
);

//OPTYPE
localparam R       = 0;
localparam I_loads = 1;
localparam I_arith = 2;
localparam I_ecall = 3;
localparam I_jalr  = 4;
localparam S       = 5;
localparam B       = 6;
localparam U_auipc = 7;
localparam U_lui   = 8;
localparam J_jal   = 9;

wire [9:0] d_optype;
assign d_optype[R]        = (d_opcode[6:2] == 5'b01100);
assign d_optype[I_loads]  = (d_opcode[6:2] == 5'b00000);
assign d_optype[I_arith]  = (d_opcode[6:2] == 5'b00100);
assign d_optype[I_ecall]  = (d_opcode[6:2] == 5'b11100);
assign d_optype[I_jalr]   = (d_opcode[6:2] == 5'b11001);
assign d_optype[S]        = (d_opcode[6:4] == 3'b010);
assign d_optype[B]        = (d_opcode[6:2] == 5'b11000);
assign d_optype[U_auipc]  = (d_opcode[5:2] == 4'b0101);
assign d_optype[U_lui]    = (d_opcode[5:2] == 4'b1101);
assign d_optype[J_jal]    = (d_opcode[3:2] == 2'b11);  

//IMMEDIATE GENERATION
wire [31:0] d_imm;

immgen immgen_0 (
  .insn   (d_insn),
  .optype (d_optype),
  .imm    (d_imm)
);

//REGISTER FILE
wire        r_write_enable;
wire [4:0]  r_rd;
wire [31:0] r_data_rd;
wire [31:0] r_data_rs1;
wire [31:0] r_data_rs2;

register_file register_file_0 (
  .clock        (clock),
  .write_enable (r_write_enable),
  .addr_rs1     (d_rs1),
  .addr_rs2     (d_rs2),
  .addr_rd      (r_rd),
  .data_rd      (r_data_rd),
  .data_rs1     (r_data_rs1),
  .data_rs2     (r_data_rs2)
);

//EXECUTE STAGE
reg  [31:0] e_pc = d_pc;
wire [9:0]  e_optype = d_optype;
wire [2:0]  e_funct3 = d_funct3;
wire [6:0]  e_funct7 = d_funct7;
wire [4:0]  e_rd = d_rd;
wire [4:0]  e_shamt = d_shamt;
wire [31:0] e_imm = d_imm;
wire [31:0] e_data_rs1 = r_data_rs1;
wire [31:0] e_data_rs2 = r_data_rs2;

wire e_A_sel            = (e_optype[J_jal] || e_optype[U_auipc] || e_optype[U_lui] || e_optype[B]); //0:Reg, 1:PC
wire e_B_sel            = !e_optype[R]; //0:Reg, 1:Imm

wire [31:0] e_alu_res;
wire [31:0] e_data_A = e_A_sel ? e_pc  : e_data_rs1;
wire [31:0] e_data_B = e_B_sel ? e_imm : e_data_rs2;

wire [3:0] e_alu_sel =  e_optype[U_auipc] ? 4'd11 :  //auipc
                        e_optype[U_lui] ? 4'd10 :  //lui
                        e_optype[R] ? (
                            (e_funct3 == 3'b000) ? (e_funct7 == 7'b0) ? 4'd0:4'd1 : //add:sub
                            (e_funct3 == 3'b100) ? 4'd2 :                         //xor
                            (e_funct3 == 3'b110) ? 4'd3 :                         //or
                            (e_funct3 == 3'b111) ? 4'd4 :                         //and
                            (e_funct3 == 3'b001) ? 4'd5 :                         //sll
                            (e_funct3 == 3'b101) ? (e_funct7 == 7'b0) ? 4'd6:4'd7 : //srl:sra
                            (e_funct3 == 3'b010) ? 4'd8 :                         //slt
                            (e_funct3 == 3'b011) ? 4'd9 :                         //sltu
                            4'd0) :
                        e_optype[I_arith] ? (
                            (e_funct3 == 3'b000) ? 4'd0 :                         //addi
                            (e_funct3 == 3'b100) ? 4'd2 :                         //xori
                            (e_funct3 == 3'b110) ? 4'd3 :                         //ori
                            (e_funct3 == 3'b111) ? 4'd4 :                         //andi
                            (e_funct3 == 3'b001) ? 4'd5 :                         //slli
                            (e_funct3 == 3'b101) ? (e_funct7 == 7'b0) ? 4'd6:4'd7 : //srli:srai
                            (e_funct3 == 3'b010) ? 4'd8 :                         //slti
                            (e_funct3 == 3'b011) ? 4'd9 :                         //sltiu
                            4'd0) :
                        4'd0;  

alu alu_0 (
  .data_A   (e_data_A),
  .data_B   (e_data_B),
  .shamt    (e_shamt),
  .alu_sel  (e_alu_sel),
  .B_sel    (e_B_sel),
  .alu_out  (e_alu_res)
);

wire e_br_eq, e_br_lt;
wire e_br_un = e_optype[B] && ((e_funct3 == 3'b110) || (e_funct3 == 3'b111));

branch_comparison branch_comparison_0(
  .data_rs1 (e_data_rs1),
  .data_rs2 (e_data_rs2),
  .br_un    (e_br_un),
  .br_eq    (e_br_eq),
  .br_lt    (e_br_lt)
);

wire e_pc_sel = e_optype[J_jal] || e_optype[I_jalr] ||
                (e_optype[B] && 
                    (   ((e_funct3 == 3'b000) &&  e_br_eq) || 
                        ((e_funct3 == 3'b001) && !e_br_eq) || 
                        ((e_funct3 == 3'b100) &&  e_br_lt) || 
                        ((e_funct3 == 3'b101) && !e_br_lt) || 
                        ((e_funct3 == 3'b110) &&  e_br_lt) || 
                        ((e_funct3 == 3'b111) && !e_br_lt)
                    )
                );
assign f_pc_sel = e_pc_sel;

//MEMORY STAGE
reg  [31:0] m_pc = e_pc;
wire [9:0]  m_optype = e_optype;
wire [2:0]  m_funct3 = e_funct3;
wire [4:0]  m_rd = e_rd;
wire [31:0] m_data_rs2 = e_data_rs2;
wire [31:0] m_alu_res = e_alu_res;

wire [31:0] m_data_out_dmem;
wire        m_mem_rw = m_optype[S]; //0:read, 1:write
wire        m_load_un = (m_optype[I_loads]) && ( (m_funct3 == 3'h4) || (m_funct3 == 3'h5)); //tells us if we are doing an unsigned lw, lh, lb
wire [1:0]  m_access_size      = (e_optype[I_loads] || e_optype[S]) ? ( ((e_funct3 == 3'h0) || (e_funct3 == 3'h4)) ? 2'd0 :
                                                                        ((e_funct3 == 3'h1) || (e_funct3 == 3'h5)) ? 2'd1 :
                                                                        ((e_funct3 == 3'h2)) ? 2'd2 : 2'hx) : 2'hx;

dmemory dmemory_0 (
  .clock        (clock),
  .address      (m_alu_res),
  .read_write   (m_mem_rw),
  .access_size  (m_access_size),
  .data_in      (m_data_rs2),
  .data_out     (m_data_out_dmem)
);
//sign extending data_mem appropriately
wire m_sign_extend = (!m_load_un) ? ((m_access_size == 2'd0) ? (m_data_out_dmem[7]) : m_data_out_dmem[15]) : 1'b0; //to get msb
wire [31:0] m_data_mem =  (m_access_size == 2'd0) ? {{24{m_sign_extend}}, m_data_out_dmem[7:0]} :    //byte
                          (m_access_size == 2'd1) ? { {16{m_sign_extend}}, m_data_out_dmem[15:0]} :  //half
                          (m_access_size == 2'd2) ? m_data_out_dmem :                              //word
                          32'hx;

wire [1:0]  m_wb_sel = (m_optype[U_auipc] || m_optype[U_lui] || m_optype[R] || m_optype[I_arith]) ? 2'h1 : (m_optype[I_loads] ? 2'h0 : 2'h2); //0:mem, 1:alu, 2:pc+4
wire [31:0] m_data_rd = (m_wb_sel == 0) ? m_data_mem : ( (m_wb_sel == 1) ? m_alu_res : f_pc+4); 

//WRITE BACK STAGE
reg  [31:0] w_pc = m_pc;
wire [9:0]  w_optype = m_optype;
wire [4:0]  w_rd = m_rd;
wire [31:0] w_data_rd = m_data_rd;
wire        w_write_enable = !(w_optype[S] || w_optype[B]);

assign r_write_enable = w_write_enable;
assign r_rd = w_rd;
assign r_data_rd = w_data_rd; //write back to register file

endmodule
