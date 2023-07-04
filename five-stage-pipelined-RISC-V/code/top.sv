module riscv_top(
  input clk,
  input rst
);

localparam START_ADDR = 32'h01000000;
//OPTYPES
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

//FETCH STAGE
reg  [31:0] f_pc;
wire [31:0] f_insn;
wire        f_pc_sel;

always @(posedge clk) begin
  if(rst) begin
    f_pc <= START_ADDR;
  end else begin
    if (f_pc_sel) begin
      f_pc <= e_alu_res;
    end else if (!stall) begin
      f_pc <= f_pc + 4;
    end
  end
end

reg [31:0] f_data_in;
imemory imemory_0 (
  .clk        (clk),
  .address    (f_pc),
  .read_write (1'b0),
  .data_in    (f_data_in),
  .data_out   (f_insn)
);

//DECODE STAGE
reg [31:0] d_pc;
reg [31:0] d_insn;

always @(posedge clk) begin
  if(rst) begin
    d_pc    <= '0;
    d_insn  <= '0;
  end else begin
    if (e_br_taken) begin
      // insert nop
      d_pc      <= '0;
      d_insn    <= '0;
    end else if (!stall) begin
      d_pc      <= f_pc;
      d_insn    <= f_insn;
    end
  end
end

wire [6:0]  d_opcode;
wire [4:0]  d_rd;
wire [2:0]  d_funct3;
wire [4:0]  d_rs1;
wire [4:0]  d_rs2;
wire [6:0]  d_funct7;
wire [4:0]  d_shamt;
wire [9:0]  d_optype;

decoder decoder_0 (
  .insn   (d_insn),
  .opcode (d_opcode),
  .rd     (d_rd),
  .funct3 (d_funct3),
  .rs1    (d_rs1),
  .rs2    (d_rs2),
  .funct7 (d_funct7),
  .shamt  (d_shamt),
  .optype (d_optype)
);

//STALL LOGIC
wire stall;

assign stall = (e_optype[I_loads] && ((d_rs1 == e_rd) || ((d_rs2 == e_rd) && (!d_optype[S]))))    // RAW with insn in D and Load in X (except WM bypass case)
            || (w_write_enable    && (w_rd != '0) && ((d_rs1 == w_rd) || (d_rs2 == w_rd)));    // RAW with insn in D and W (WD hazard)

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
  .clk          (clk),
  .write_enable (r_write_enable),
  .addr_rs1     (d_rs1),
  .addr_rs2     (d_rs2),
  .addr_rd      (r_rd),
  .data_rd      (r_data_rd),
  .data_rs1     (r_data_rs1),
  .data_rs2     (r_data_rs2)
);

//EXECUTE STAGE
reg [31:0] e_pc;
reg [9:0]  e_optype;
reg [2:0]  e_funct3;
reg [6:0]  e_funct7;
reg [4:0]  e_rd;
reg [4:0]  e_shamt;
reg [31:0] e_imm;
reg [4:0]  e_rs1;
reg [4:0]  e_rs2;
reg [31:0] e_data_rs1;
reg [31:0] e_data_rs2;

always @ (posedge clk) begin
  if(rst) begin
    e_pc        <= '0;
    e_optype    <= '0;
    e_funct3    <= '0;
    e_funct7    <= '0;
    e_rd        <= '0;
    e_shamt     <= '0;
    e_imm       <= '0;
    e_rs1       <= '0;
    e_rs2       <= '0;
    e_data_rs1  <= '0;
    e_data_rs2  <= '0;
  end else begin
    if (stall || e_br_taken) begin
      // insert nop
      e_pc        <= '0;
      e_optype    <= '0;
      e_funct3    <= '0;
      e_funct7    <= '0;
      e_rd        <= '0;
      e_shamt     <= '0;
      e_imm       <= '0;
      e_rs1       <= '0;
      e_rs2       <= '0;
      e_data_rs1  <= '0;
      e_data_rs2  <= '0;
    end else begin
      e_pc        <= d_pc;
      e_optype    <= d_optype;
      e_funct3    <= d_funct3;
      e_funct7    <= d_funct7;
      e_rd        <= d_rd;
      e_shamt     <= d_shamt;
      e_imm       <= d_imm;
      e_rs1       <= d_rs1;
      e_rs2       <= d_rs2;
      e_data_rs1  <= r_data_rs1;
      e_data_rs2  <= r_data_rs2;
    end
  end
end

wire mx_fwd_rs1;
wire mx_fwd_rs2;
wire wx_fwd_rs1;
wire wx_fwd_rs2;

wire [31:0]  e_data_rs1_fwd;
wire [31:0]  e_data_rs2_fwd;

wire e_A_sel;
wire e_B_sel;

wire [31:0] e_data_A;
wire [31:0] e_data_B;

wire [3:0] e_alu_sel;

assign mx_fwd_rs1 = (e_rs1 == m_rd) && (e_rs1 != 5'b0);
assign mx_fwd_rs2 = (e_rs2 == m_rd) && (e_rs2 != 5'b0);
assign wx_fwd_rs1 = (e_rs1 == w_rd) && (e_rs1 != 5'b0);
assign wx_fwd_rs2 = (e_rs2 == w_rd) && (e_rs2 != 5'b0);

assign e_data_rs1_fwd = (mx_fwd_rs1 ? m_alu_res : (wx_fwd_rs1 ? w_data_rd : e_data_rs1));
assign e_data_rs2_fwd = (mx_fwd_rs2 ? m_alu_res : (wx_fwd_rs2 ? w_data_rd : e_data_rs2));

assign e_A_sel = (e_optype[J_jal] || e_optype[U_auipc] || e_optype[U_lui] || e_optype[B]); //0:Reg, 1:PC
assign e_B_sel = !e_optype[R]; //0:Reg, 1:Imm

assign e_data_A = e_A_sel ? e_pc  : e_data_rs1_fwd;
assign e_data_B = e_B_sel ? e_imm : e_data_rs2_fwd;

assign e_alu_sel =      e_optype[U_auipc] ? 4'd11 :  //auipc
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

wire [31:0] e_alu_res;

alu alu_0 (
  .data_A   (e_data_A),
  .data_B   (e_data_B),
  .shamt    (e_shamt),
  .alu_sel  (e_alu_sel),
  .B_sel    (e_B_sel),
  .alu_out  (e_alu_res)
);

wire e_br_eq, e_br_lt, e_br_un;
wire e_br_taken;
assign e_br_un = e_optype[B] && ((e_funct3 == 3'b110) || (e_funct3 == 3'b111));

branch_comparison branch_comparison_0(
  .data_rs1 (e_data_rs1_fwd),
  .data_rs2 (e_data_rs2_fwd),
  .br_un    (e_br_un),
  .br_eq    (e_br_eq),
  .br_lt    (e_br_lt)
);

assign e_br_taken = e_optype[J_jal] || e_optype[I_jalr] ||
                  (e_optype[B] && 
                      (   ((e_funct3 == 3'b000) &&  e_br_eq) || 
                          ((e_funct3 == 3'b001) && !e_br_eq) || 
                          ((e_funct3 == 3'b100) &&  e_br_lt) || 
                          ((e_funct3 == 3'b101) && !e_br_lt) || 
                          ((e_funct3 == 3'b110) &&  e_br_lt) || 
                          ((e_funct3 == 3'b111) && !e_br_lt)
                      )
                  );
assign f_pc_sel = e_br_taken;

//MEMORY STAGE
reg [31:0] m_pc;
reg [9:0]  m_optype;
reg [2:0]  m_funct3;
reg [4:0]  m_rd;
reg [4:0]  m_rs2;
reg [31:0] m_data_rs2;
reg [31:0] m_alu_res;

always @ (posedge clk) begin
  if(rst) begin
    m_pc        <= '0;
    m_optype    <= '0;
    m_funct3    <= '0;
    m_rd        <= '0;
    m_rs2       <= '0;
    m_data_rs2  <= '0;
    m_alu_res   <= '0;
  end else begin
    m_pc        <= e_pc;
    m_optype    <= e_optype;
    m_funct3    <= e_funct3;
    m_rd        <= e_rd;
    m_rs2       <= e_rs2;
    m_data_rs2  <= e_data_rs2_fwd;
    m_alu_res   <= e_alu_res;
  end
end

wire   wm_fwd;
assign wm_fwd = w_write_enable && (m_rs2 == w_rd) && (m_rs2 != 5'b0);

wire [31:0] m_data_out_dmem;
wire        m_mem_rw;
wire        m_load_un;
wire [1:0]  m_access_size;

assign        m_mem_rw      = m_optype[S]; //0:read, 1:write
assign        m_load_un     = (m_optype[I_loads]) && ( (m_funct3 == 3'h4) || (m_funct3 == 3'h5)); //tells us if we are doing lbu, lhu
assign        m_access_size = (m_optype[I_loads] || m_optype[S]) ? (((m_funct3 == 3'h0) || (m_funct3 == 3'h4)) ? 2'd0 :
                                                                    ((m_funct3 == 3'h1) || (m_funct3 == 3'h5)) ? 2'd1 :
                                                                    ((m_funct3 == 3'h2)) ? 2'd2 : 2'hx) : 2'hx;                                                                  

dmemory dmemory_0 (
  .clk          (clk),
  .address      (m_alu_res),
  .read_write   (m_mem_rw),
  .access_size  (m_access_size),
  .data_in      (wm_fwd ? w_data_rd : m_data_rs2),
  .data_out     (m_data_out_dmem)
);

wire m_sign_extend;
wire [31:0] m_data_mem;

//sign extending data_mem appropriately
assign m_sign_extend  = (m_load_un) ? 1'b0 : ((m_access_size == 2'd0) ? (m_data_out_dmem[7]) : m_data_out_dmem[15]); //to get msb
assign m_data_mem     =   (m_optype == 10'b0)      ? 32'b0 :                                         //nop
                          (m_access_size == 2'd0) ? {{24{m_sign_extend}}, m_data_out_dmem[7:0]} :    //byte
                          (m_access_size == 2'd1) ? { {16{m_sign_extend}}, m_data_out_dmem[15:0]} :  //half
                          (m_access_size == 2'd2) ? m_data_out_dmem :                                //word
                          32'hx;

wire [1:0]  m_wb_sel;
wire [31:0] m_data_rd;

assign  m_wb_sel  = (m_optype[U_auipc] || m_optype[U_lui] || m_optype[R] || m_optype[I_arith]) ? 2'h1 : (m_optype[I_loads] ? 2'h0 : 2'h2); //0:mem, 1:alu, 2:pc+4
assign  m_data_rd = (m_optype == 10'b0) ? 32'b0 : ((m_wb_sel == 0) ? m_data_mem : ( (m_wb_sel == 1) ? m_alu_res : m_pc+4));

//WRITE BACK STAGE
reg [31:0] w_pc;
reg [9:0]  w_optype;
reg [4:0]  w_rd;
reg [31:0] w_data_rd;
wire   w_write_enable;

always @ (posedge clk) begin
  if(rst) begin
    w_pc      <= '0;
    w_optype  <= '0;
    w_rd      <= '0;
    w_data_rd <= '0;
  end else begin
    w_pc      <= m_pc;
    w_optype  <= m_optype;
    w_rd      <= m_rd;
    w_data_rd <= m_data_rd;
  end
  
end

assign w_write_enable = !(w_optype[S] || w_optype[B] || (w_optype == 10'b0));
assign r_write_enable = w_write_enable;
assign r_rd           = w_rd;
assign r_data_rd      = w_data_rd; //write back to register file

endmodule
