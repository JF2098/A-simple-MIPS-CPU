`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/28 20:15:33
// Design Name: 
// Module Name: axi_interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_interface(
    input wire clk,
    input wire resetn,
    
    //cache port
    input wire[31:0] mem_a,
    input wire mem_access,
    input wire mem_write,
    input wire[1:0] mem_size,
    input wire[3:0] mem_sel,
    output wire mem_ready,
    input wire[31:0] mem_st_data,
    output wire[31:0] mem_data,

    input wire flush,

    // axi port
    //ar
    output wire[3:0] arid,      //read request id, fixed 4'b0
    output wire[31:0] araddr,   //read request address
    output wire[7:0] arlen,     //read request transfer length(beats), fixed 4'b0
    output wire[2:0] arsize,    //read request transfer size(bytes per beats)
    output wire[1:0] arburst,   //transfer type, fixed 2'b01
    output wire[1:0] arlock,    //atomic lock, fixed 2'b0
    output wire[3:0] arcache,   //cache property, fixed 4'b0
    output wire[2:0] arprot,    //protect property, fixed 3'b0
    output wire arvalid,        //read request address valid
    input wire arready,         //slave end ready to receive address transfer
    //r              
    input wire[3:0] rid,        //equal to arid, can be ignored
    input wire[31:0] rdata,     //read data
    input wire[1:0] rresp,      //this read request finished successfully, can be ignored
    input wire rlast,           //the last beat data for this request, can be ignored
    input wire rvalid,          //read data valid
    output wire rready,         //master end ready to receive data transfer
    //aw           
    output wire[3:0] awid,      //write request id, fixed 4'b0
    output wire[31:0] awaddr,   //write request address
    output wire[3:0] awlen,     //write request transfer length(beats), fixed 4'b0
    output wire[2:0] awsize,    //write request transfer size(bytes per beats)
    output wire[1:0] awburst,   //transfer type, fixed 2'b01
    output wire[1:0] awlock,    //atomic lock, fixed 2'b01
    output wire[3:0] awcache,   //cache property, fixed 4'b01
    output wire[2:0] awprot,    //protect property, fixed 3'b01
    output wire awvalid,        //write request address valid
    input wire awready,         //slave end ready to receive address transfer
    //w          
    output wire[3:0] wid,       //equal to awid, fixed 4'b0
    output wire[31:0] wdata,    //write data
    output wire[3:0] wstrb,     //write data strobe select bit
    output wire wlast,          //the last beat data signal, fixed 1'b1
    output wire wvalid,         //write data valid
    input wire wready,          //slave end ready to receive data transfer
    //b              
    input  wire[3:0] bid,       //equal to wid,awid, can be ignored
    input  wire[1:0] bresp,     //this write request finished successfully, can be ignored
    input wire bvalid,          //write data valid
    output wire bready          //master end ready to receive write response

    );
    reg [3:0] write_wen;
    reg  read_req;
	reg  write_req;
	reg  [1:0]  read_size;
	reg  [1:0]  write_size;
	reg  [31:0] read_addr;
	reg  [31:0] write_addr;
	reg  [31:0] write_data;
	reg  read_addr_finish;
	reg  write_addr_finish;
	reg  write_data_finish;
		
	wire read_finish;
	wire write_finish;

    wire read = mem_access && ~mem_write;
    wire write = mem_access && mem_write;

    reg flush_reg;

    always @(posedge clk) begin
        flush_reg <= ~resetn ? 1'b0:
                    flush ? 1'b1:
                    1'b0; 
    end

    always @(posedge clk) begin

        read_req   <= (~resetn) ? 1'b0 :
				 	  (read && ~read_req) ? 1'b1 :
			 		  (read_finish) ? 1'b0 : 
					  read_req;

        read_addr <= (~resetn || read_finish) ? 32'hffffffff : 
	                 (read && ~read_req || flush_reg) ? mem_a :
	                 read_addr;

        read_size  <= (~resetn) ? 2'b00 :
					  (read) ? mem_size :
					  read_size;

        write_req  <= (~resetn) ? 1'b0 :
					  (write && ~write_req) ? 1'b1 :
					  (write_finish) ? 1'b0 : 
					  write_req;

        write_addr <= (~resetn || write_finish) ? 32'hffffffff : 
                      (write && ~write_req) ? mem_a :                     
                      write_addr;

        write_size <= (~resetn) ? 2'b00 :
					  (write) ? mem_size :
					  write_size;

        write_wen <= (~resetn) ? 4'b0000 :
                    (write) ? mem_sel:
                    write_wen;

        write_data <= (~resetn) ? 32'b0 :
                    (write) ? mem_st_data:
                    write_data;
    end

    always @(posedge clk) begin
		read_addr_finish  <= (~resetn) ? 1'b0 :
		                     (read_req && arvalid && arready) ? 1'b1 :
						 	 (read_finish) ? 1'b0 :
					 		 read_addr_finish;
		write_addr_finish <= (~resetn) ? 1'b0 :
							 (write_req && awvalid && awready) ? 1'b1 :
							 (write_finish) ? 1'b0 :
							 write_addr_finish;
		write_data_finish <= (~resetn) ? 1'b0 :
							 (write_req && wvalid && wready) ? 1'b1 :
							 (write_finish) ? 1'b0 :
							 write_data_finish;
	end


    assign mem_ready = read_req && read_finish && ~flush_reg|| write_req && write_finish;
	
	assign mem_data = rdata;	

    assign read_finish = read_addr_finish && rvalid && rready;
	assign write_finish = write_addr_finish && bvalid && bready;
		
	
	assign arid = 4'b0;
	assign araddr = read_addr;
    assign arlen = 8'b0;
	assign arsize = read_size;
    assign arburst = 2'b01;
    assign arlock = 2'b0;
    assign arcache = 4'b0;
    assign arprot = 3'b0;
	assign arvalid = read_req && ~read_addr_finish && ~flush && ~flush_reg;

	assign rready = 1'b1;
	
	assign awid = 4'b0;
	assign awaddr = write_addr;
    assign awlen = 8'b0;
	assign awsize = write_size;
    assign awburst = 2'b01;
    assign awlock = 2'b0;
    assign awcache = 4'b0;
    assign awprot = 3'b0;
	assign awvalid = write_req && ~write_addr_finish;

	assign wid = 4'b0;
	assign wdata = write_data;
	assign wstrb = write_wen;
    assign wlast = 1'b1;
	assign wvalid = write_req && ~write_data_finish;

	assign bready = 1'b1;
    
endmodule
