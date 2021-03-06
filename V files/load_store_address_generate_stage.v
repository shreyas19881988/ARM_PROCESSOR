`include "load_store_address_generate_stage_define.v"

module load_store_address_GEN_stage(
					input clk_in,
					input reset_in,
					input [`LD_STR_ADDR_GEN_STAGE_CONTROL_WORD-1:0] ld_str_addr_gen_stage_control_word_in,
					output [`LD_STR_ADDR_GEN_RD_ADDR_SIZE-1:0] rd_addr_out,
					output [`LD_STR_ADDR_GEN_RN_ADDR_SIZE-1:0] rn_addr_out,
					output ld_str_multiple_flag_out,
					output [`LD_STR_ADDR_GEN_BASE_ADDR_SIZE-1:0] addr_to_mem_out,
					output [`LD_STR_ADDR_GEN_INSTR_TAG_SIZE-1:0] instr_tag_out,
					output [`LD_STR_ADDR_GEN_IMM_STR_RN_DATA_SIZE-1:0] rn_data_out,
					output [`LD_STR_ADDR_GEN_IMM_CTRL_LD_MUX_SIZE-1:0] ctrl_ld_mux_out,
					output [`LD_STR_ADDR_GEN_IMM_CTRL_STR_MUX_SIZE-1:0] ctrl_str_mux_out,
					output [`LD_STR_ADDR_GEN_IMM_W_EN_SIZE-1:0] w_en_out,
					output instr_exec_confirmed_out,
					output pipe_start_out
					
    );

wire [`LD_STR_ADDR_GEN_INSTR_TAG_SIZE-1:0] instr_tag;
wire [`LD_STR_ADDR_GEN_RD_ADDR_SIZE-1:0] rd_addr;
wire [`LD_STR_ADDR_GEN_RN_ADDR_SIZE-1:0] rn_addr;
wire [`LD_STR_ADDR_GEN_COND_BITS_SIZE-1:0] cond_bits;
wire [`LD_STR_ADDR_GEN_FLAG_REG_SIZE-1:0] flag_reg;
wire [`LD_STR_ADDR_GEN_OPERANDB_SIZE-1:0] operandB,alu_operandB_BS;
wire [`LD_STR_ADDR_GEN_SHIFT_FRM_RS_SIZE-1:0] shift_frm_rs;
wire [`LD_STR_ADDR_GEN_SHIFT_VALUE_SIZE-1:0] shift_value;
wire [`LD_STR_ADDR_GEN_SHIFT_OPCODE_SIZE-1:0] shift_opcode;
wire [`LD_STR_ADDR_GEN_BASE_ADDR_SIZE-1:0] base_addr; 
wire [`LD_STR_ADDR_GEN_IMM_OFFSET_SIZE-1:0] imm_offset; 
wire [`LD_STR_ADDR_GEN_IMM_ADD_CALC_FUNC_SIZE-1:0] add_calc_func; 
wire [`LD_STR_ADDR_GEN_IMM_W_EN_SIZE-1:0] w_en; 
wire [`LD_STR_ADDR_GEN_IMM_STR_RD_DATA_SIZE-1:0] str_rd_data;
wire [`LD_STR_ADDR_GEN_IMM_CTRL_LD_MUX_SIZE-1:0] ctrl_ld_mux;
wire [`LD_STR_ADDR_GEN_IMM_CTRL_STR_MUX_SIZE-1:0] ctrl_str_mux;
wire use_rs_to_shift,ctrl_reg_imm_for_offset,ld_str_multiple_en,pipe_start,instr_exec_confirmed;
wire carry_BS;
wire [`LD_STR_ADDR_GEN_STAGE_FINAL_SHIFT_AMOUNT:0] shift_amount;
wire [`LD_STR_ADDR_GEN_STAGE_OFFSET_FINAL-1:0] offset_final;
wire [`LD_STR_ADDR_GEN_BASE_ADDR_SIZE-1:0] addr_to_mem_frm_mem_addr_calc;
wire ld_str_multiple_flag;
wire [`LD_STR_RN_UPDATE_DATA_SIZE-1:0] rn_data_update;
wire [`LD_STR_ADDR_GEN_STAGE_LDM_STM_DATA_SIZE-1:0] ldm_stm_data;
wire [`LD_STR_ADDR_GEN_RD_ADDR_SIZE-1:0] reg_addr_frm_ldm_stm_gen,reg_addr_final;

/******INSTR_TAG******/
assign instr_tag = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_INSTR_TAG_START:
`LD_STR_ADDR_GEN_STAGE_INSTR_TAG_END];
/******INSTR_TAG******/

/******RD_ADDR******/
assign rd_addr = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_RD_ADDR_START:
`LD_STR_ADDR_GEN_STAGE_RD_ADDR_END];
/******RD_ADDR******/

/******RN_ADDR******/
assign rn_addr = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_RN_ADDR_START:
`LD_STR_ADDR_GEN_STAGE_RN_ADDR_END];
/******RN_ADDR******/

/******COND_BITS******/
assign cond_bits = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_COND_BITS_START:
`LD_STR_ADDR_GEN_STAGE_COND_BITS_END];
/******COND_BITS******/

/******FLAG_REG******/
assign flag_reg = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_FLAG_REG_START:
`LD_STR_ADDR_GEN_STAGE_FLAG_REG_END];
/******FLAG_REG******/

/******OPERANDB******/
assign operandB = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_OPERANDB_START:
`LD_STR_ADDR_GEN_STAGE_OPERANDB_END];
/******OPERANDB******/

/******SHIFT_FRM_RS******/
assign shift_frm_rs = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_SHIFT_FRM_RS_START:
`LD_STR_ADDR_GEN_STAGE_SHIFT_FRM_RS_END];
/******SHIFT_FRM_RS******/

/******SHIFT_VALUE******/
assign shift_value = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_SHIFT_VALUE_START:
`LD_STR_ADDR_GEN_STAGE_SHIFT_VALUE_END];
/******SHIFT_VALUE******/

/******SHIFT_OPCODE******/
assign shift_opcode = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_SHIFT_OPCODE_START:
`LD_STR_ADDR_GEN_STAGE_SHIFT_OPCODE_END];
/******SHIFT_OPCODE******/

/******USE_RS_TO_SHIFT******/
assign use_rs_to_shift = ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_USE_RS_TO_SHIFT];
/******USE_RS_TO_SHIFT******/

/******BASE_ADDR******/
assign base_addr = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_BASE_ADDR_START:
`LD_STR_ADDR_GEN_STAGE_BASE_ADDR_END];
/******BASE_ADDR******/

/******CTRL_REG_IMM_FOR_OFFSET******/
assign ctrl_reg_imm_for_offset = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_CTRL_REG_IMM_FOR_OFFSET];
/******CTRL_REG_IMM_FOR_OFFSET******/

/******IMM_OFFSET******/
assign imm_offset = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_IMM_OFFSET_START:
`LD_STR_ADDR_GEN_STAGE_IMM_OFFSET_END];
/******IMM_OFFSET******/

/******ADD_CALC_FUNC******/
assign add_calc_func = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_ADD_CALC_FUNC_START:
`LD_STR_ADDR_GEN_STAGE_ADD_CALC_FUNC_END];
/******ADD_CALC_FUNC******/

/******W_EN******/
assign w_en = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_W_EN_START:
`LD_STR_ADDR_GEN_STAGE_W_EN_END];
/******W_EN******/

/******STR_RD_DATA******/
assign str_rd_data = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_STR_RD_DATA_START:
`LD_STR_ADDR_GEN_STAGE_STR_RD_DATA_END];
/******STR_RD_DATA******/

/******CTRL_LD_MUX******/
assign ctrl_ld_mux = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_CTRL_LD_MUX_START:
`LD_STR_ADDR_GEN_STAGE_CTRL_LD_MUX_END];
/******CTRL_LD_MUX******/

/******CTRL_STR_MUX******/
assign ctrl_str_mux = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_CTRL_STR_MUX_START:
`LD_STR_ADDR_GEN_STAGE_CTRL_STR_MUX_END];
/******CTRL_STR_MUX******/

/******LD_STR_MULTIPLE_EN******/
assign ld_str_multiple_en = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_LD_STR_MULTIPLE];
/******LD_STR_MULTIPLE_EN******/

/******PIPE_START******/
assign pipe_start = 
ld_str_addr_gen_stage_control_word_in[`LD_STR_ADDR_GEN_STAGE_PIPE_START];
/******PIPE_START******/

/******INSTR_EXEC_CONFIRMED******/
cond_instr_sel conditional_instr_sel (
    .cond_in(cond_bits), 
    .flag_register_in(flag_reg), 
    .instr_exec_out(instr_exec_confirmed)
    );
/******INSTR_EXEC_CONFIRMED******/

/******FINAL_SHIFT_AMOUNT******/
assign shift_amount = use_rs_to_shift ? shift_frm_rs : shift_value;
/******FINAL_SHIFT_AMOUNT******/

/******BARREL_SHIFTER******/
barrel_shifter barr_shifter (
    .data_in(operandB), 
    .shift_amount(shift_amount), 
    .opcode(shift_opcode), 
    .cf_in(flag_reg[1]), 
    .instr_exec_in(instr_exec_confirmed), 
    .cf_out(carry_BS), 
    .data_out(alu_operandB_BS)
    );
/******BARREL_SHIFTER******/

assign offset_final = ctrl_reg_imm_for_offset ? alu_operandB_BS : {{20{1'b0}},imm_offset};

mem_addr_calc address_calculator (
    .clk_in(clk_in),
	 .reset_in(reset_in),
	 .base_addr_in(base_addr), 
    .offset_in(offset_final), 
    .func_in(add_calc_func[2:1]), 
	 .ldm_stm_en_in(ld_str_multiple_flag),
    .ldm_stm_start_in(ld_str_multiple_en & instr_exec_confirmed), 
    .swp_ctrl_S3_in(1'b0), 
	 .addr_to_mem_out(addr_to_mem_frm_mem_addr_calc), 
    .data_to_reg_update_out(rn_data_update)
    );

ldm_stm_reg_addr_generator ldm_stm_addr_calculator (
		.clk_in(clk_in), 
		.reset_in(reset_in), 
		.ldm_stm_start_in(ld_str_multiple_en & instr_exec_confirmed), 
		.data_in(ldm_stm_data), 
		.reg_addr_out(reg_addr_frm_ldm_stm_gen), 
		.ldm_stm_en_out(ld_str_multiple_flag)
	);

assign reg_addr_final = ld_str_multiple_flag ? reg_addr_frm_ldm_stm_gen : rd_addr;

register_with_reset #`LD_STR_ADDR_GEN_RD_ADDR_SIZE reg_rd_addr_out (
		 .data_in(reg_addr_final), 
		 .clk_in(clk_in), 
		 .reset_in(reset_in), 
		 .en_in(1'b1), 
		 .data_out(rd_addr_out)
		 );

register_with_reset #`LD_STR_ADDR_GEN_RN_ADDR_SIZE reg_rn_addr_out (
		 .data_in(rn_addr), 
		 .clk_in(clk_in), 
		 .reset_in(reset_in), 
		 .en_in(1'b1), 
		 .data_out(rn_addr_out)
		 );

register_with_reset #1 reg_ld_str_multiple_flag_out (
		 .data_in(ld_str_multiple_flag), 
		 .clk_in(clk_in), 
		 .reset_in(reset_in), 
		 .en_in(1'b1), 
		 .data_out(ld_str_multiple_flag_out)
		 );

register_with_reset #`LD_STR_ADDR_GEN_BASE_ADDR_SIZE reg_addr_to_mem_out (
		 .data_in(addr_to_mem_frm_mem_addr_calc), 
		 .clk_in(clk_in), 
		 .reset_in(reset_in), 
		 .en_in(1'b1), 
		 .data_out(addr_to_mem_out)
		 );

register_with_reset #`LD_STR_ADDR_GEN_INSTR_TAG_SIZE reg_instr_tag_out (
		 .data_in(instr_tag), 
		 .clk_in(clk_in), 
		 .reset_in(reset_in), 
		 .en_in(1'b1), 
		 .data_out(instr_tag_out)
		 );

register_with_reset #`LD_STR_ADDR_GEN_IMM_STR_RN_DATA_SIZE reg_rn_data_out (
		 .data_in(rn_data_update), 
		 .clk_in(clk_in), 
		 .reset_in(reset_in), 
		 .en_in(1'b1), 
		 .data_out(rn_data_out)
		 );

register_with_reset #`LD_STR_ADDR_GEN_IMM_CTRL_LD_MUX_SIZE reg_ctrl_ld_mux_out (
		 .data_in(ctrl_ld_mux), 
		 .clk_in(clk_in), 
		 .reset_in(reset_in), 
		 .en_in(1'b1), 
		 .data_out(ctrl_ld_mux_out)
		 );

register_with_reset #`LD_STR_ADDR_GEN_IMM_CTRL_STR_MUX_SIZE reg_ctrl_str_mux_out (
		 .data_in(ctrl_str_mux), 
		 .clk_in(clk_in), 
		 .reset_in(reset_in), 
		 .en_in(1'b1), 
		 .data_out(ctrl_str_mux_out)
		 );

register_with_reset #`LD_STR_ADDR_GEN_IMM_W_EN_SIZE reg_w_en_out (
		 .data_in(w_en), 
		 .clk_in(clk_in), 
		 .reset_in(reset_in), 
		 .en_in(1'b1), 
		 .data_out(w_en_out)
		 );

register_with_reset #1 reg_instr_exec_confirmed_out (
		 .data_in(instr_exec_confirmed), 
		 .clk_in(clk_in), 
		 .reset_in(reset_in), 
		 .en_in(1'b1), 
		 .data_out(instr_exec_confirmed_out)
		 );

register_with_reset #1 reg_pipe_start_out (
		 .data_in(pipe_start), 
		 .clk_in(clk_in), 
		 .reset_in(reset_in), 
		 .en_in(1'b1), 
		 .data_out(pipe_start_out)
		 );

endmodule
