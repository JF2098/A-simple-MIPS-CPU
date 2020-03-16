// defines used in div module
`define DivFree            2'b00  
`define DivZero            2'b01  
`define DivOn              2'b10  
`define DivEnd             2'b11  
 
 
module divnew(
    input wire                      clk,
    input wire                      rst,
     
    input wire                      signed_div,  // signed div(high) unsigned div(low)
    input wire[`RegWidth-1:0]       div_opdata1, // dividend
    input wire[`RegWidth-1:0]       div_opdata2, // divider
    input wire                      div_start,   // start division (high active)
    input wire                      div_cancel,  // cancel division (high active)
     
    output reg[`DoubleRegWidth-1:0] div_res,     // division result
    output reg                      div_done     // division done (high active)
);
    // variable width attention
    wire[`RegWidth:0]       div_temp;  // attention the width(33)
    reg [`DoubleRegWidth:0] dividend;  // attention the width(65)
 
    reg [`RegWidth-1:0]       divisor;     
    reg [`RegWidth-1:0]       opdata1_tmp;
    reg [`RegWidth-1:0]       opdata2_tmp;
    reg [1:0]                 state;
    reg [5:0]                 cnt;      // div operation cycle count
     
    assign div_temp = {
1'b0,dividend[63:32]
} - {
1'b0,divisor
};
 
    always @ (posedge clk)
    begin
        if (rst == `RstEnable)
        begin
            state <= `DivFree;
            div_done <= 1'b0;
            div_res <= {
`DoubleRegWidth{
1'b0
}
};
        end
        else
        begin
          case (state)
              `DivFree:
              begin
                  if(div_start == 1'b1 && div_cancel == 1'b0)
                  begin
                      if(div_opdata2 == {
`RegWidth{
1'b0
}
})
                      begin
                          state <= `DivZero;
                      end
                      else
                      begin
                          state <= `DivOn;
                          cnt <= 6'b000000;
 
                          if(signed_div == 1'b1 && div_opdata1[31] == 1'b1 ) begin
                              opdata1_tmp = ~div_opdata1 + 1;
                          end else begin
                              opdata1_tmp = div_opdata1;
                          end
 
                          if(signed_div == 1'b1 && div_opdata2[31] == 1'b1 ) begin
                              opdata2_tmp = ~div_opdata2 + 1;
                          end else begin
                              opdata2_tmp = div_opdata2;
                          end
 
                          dividend       <= {
`DoubleRegWidth{
1'b0
}
};
                          dividend[32:1] <= opdata1_tmp;
                          divisor        <= opdata2_tmp;
                      end
                  end
                  else
                  begin
                      div_done <= 1'b0;
                      div_res  <= {
`DoubleRegWidth{
1'b0
}
};
                  end              
              end
 
              `DivZero:
              begin
                  dividend <= {
`DoubleRegWidth{
1'b0
}
};
                  state    <= `DivEnd;                 
              end
 
              `DivOn:
              begin
                  if(div_cancel == 1'b0)
                  begin
                      if(cnt != 6'b100000)
                      begin
                          if(div_temp[32] == 1'b1)
                          begin
                             dividend <= {
dividend[63:0] , 1'b0
};
                          end
                          else
                          begin
                             dividend <= {
div_temp[31:0] , dividend[31:0] , 1'b1
};
                          end
                          cnt <= cnt + 1;
                      end
                      else
                      begin
                          if((signed_div == 1'b1) && ((div_opdata1[31] ^ div_opdata2[31]) == 1'b1))
                          begin
                              dividend[31:0] <= (~dividend[31:0] + 1);
                          end
                          if((signed_div == 1'b1) && ((div_opdata1[31] ^ dividend[64]) == 1'b1))
                          begin              
                              dividend[64:33] <= (~dividend[64:33] + 1);
                          end
                          state <= `DivEnd;
                          cnt   <= 6'b000000;                
                      end
                  end
                  else
                  begin
                      state <= `DivFree;
                  end    
              end
 
              `DivEnd:
              begin
                  div_res  <= {
dividend[64:33], dividend[31:0]
};  
                  div_done <= 1'b1;
                  if(div_start == 1'b0)
                  begin
                      state    <= `DivFree;
                      div_done <= 1'b0;
                      div_res  <= {
`DoubleRegWidth{
1'b0
}
};           
                  end              
              end
          endcase
        end
    end
 
endmodule