//------------------------------------------------------------------------------
//                       Paul Scherrer Institute (PSI)
//------------------------------------------------------------------------------
// Unit    : tb.v
// Author  : Goran Marinkovic, Section Diagnostic
// Version : $Revision: 1.2 $
//------------------------------------------------------------------------------
// Copyright© PSI, Section Diagnostic
//------------------------------------------------------------------------------
// Comment : This is the testbench for axi bus simulation with BFM.
//------------------------------------------------------------------------------
`timescale 1ns / 1ps
//------------------------------------------------------------------------------
// Local Defines.
//------------------------------------------------------------------------------
// Clock rate
`define PERIOD_100MHz             10
// Burst Type Defines
`define BURST_TYPE_FIXED          2'b00
`define BURST_TYPE_INCR           2'b01
`define BURST_TYPE_WRAP           2'b10
// Burst Size Defines
`define BURST_SIZE_1_BYTE         3'b000
`define BURST_SIZE_2_BYTES        3'b001
`define BURST_SIZE_4_BYTES        3'b010
`define BURST_SIZE_8_BYTES        3'b011
`define BURST_SIZE_16_BYTES       3'b100
`define BURST_SIZE_32_BYTES       3'b101
`define BURST_SIZE_64_BYTES       3'b110
`define BURST_SIZE_128_BYTES      3'b111
// Lock Type Defines
`define LOCK_TYPE_NORMAL          1'b0
`define LOCK_TYPE_EXCLUSIVE       1'b1
// Response Type Defines
`define RESPONSE_OKAY             2'b00
`define RESPONSE_EXOKAY           2'b01
`define RESPONSE_SLVERR           2'b10
`define RESPONSE_DECERR           2'b11
// AMBA AXI 4 Bus Size Constants
`define RESP_WIDTH                2
// AMBA AXI 4 Range Constants
`define MAX_BURST_LENGTH          256
`define MAX_DATA_SIZE             (DATA_WIDTH*`MAX_BURST_LENGTH)/8

module tb;

   //---------------------------------------------------------------------------
   // System parameter
   //---------------------------------------------------------------------------
   parameter MASTER_NAME          = "MASTER_0";
   parameter ADDR_SLAVE_WIDTH     = 17;
   parameter ADDR_MASTER_WIDTH    = 32;
   parameter DATA_WIDTH           = 32;
   parameter ID_WIDTH             = 4;
   parameter AWUSER_WIDTH         = 1;
   parameter ARUSER_WIDTH         = 1;
   parameter RUSER_WIDTH          = 1;
   parameter WUSER_WIDTH          = 1;
   parameter BUSER_WIDTH          = 1;
   parameter READ_ISSUING         = 8;
   parameter WRITE_ISSUING        = 8;
   parameter EXCL_ACCESS_SUPPORT  = 0;
   parameter S_ADDRESS            = 32'h0000_0000;

   parameter DATA_LENGTH          = DATA_WIDTH   * `MAX_BURST_LENGTH;
   parameter AWUSER_LENGTH        = AWUSER_WIDTH * `MAX_BURST_LENGTH;
   parameter ARUSER_LENGTH        = ARUSER_WIDTH * `MAX_BURST_LENGTH;
   parameter RUSER_LENGTH         = RUSER_WIDTH  * `MAX_BURST_LENGTH;
   parameter WUSER_LENGTH         = WUSER_WIDTH  * `MAX_BURST_LENGTH;
   parameter BUSER_LENGTH         = BUSER_WIDTH  * `MAX_BURST_LENGTH;
   parameter RESP_LENGTH          = `RESP_WIDTH;
   parameter RESP_VECT_LENGTH     = `RESP_WIDTH  * `MAX_BURST_LENGTH;
   //---------------------------------------------------------------------------
   // System signals
   //---------------------------------------------------------------------------
   reg  aclk;
   reg  aresetn;
   //---------------------------------------------------------------------------
   // ADC16HL interface
   //---------------------------------------------------------------------------
   // Debug interface
   wire [127:0]                   debug;
   // Interrupt interface
   wire                           interupt;
   //---------------------------------------------------------------------------
   // AXI master stimulus signals
   //---------------------------------------------------------------------------
   integer                        tb_id       = 1;
   reg [ADDR_MASTER_WIDTH-1:0]    tb_addr     = 0;
   integer                        tb_len      = 0;
   reg [2:0]                      tb_size     = `BURST_SIZE_4_BYTES;
   reg [1:0]                      tb_burst    = `BURST_TYPE_INCR;
   reg                            tb_lock     = `LOCK_TYPE_NORMAL;
   integer                        tb_cache    = 0;
   integer                        tb_prot     = 0;
   reg [DATA_LENGTH - 1:0]        tb_data_wr  = 0;
   reg [DATA_LENGTH - 1:0]        tb_data_rd  = 0;
   integer                        tb_datasize = `MAX_DATA_SIZE;
   integer                        tb_region   = 0;
   integer                        tb_qos      = 0;
   reg [AWUSER_LENGTH - 1:0]      tb_awuser   = 0;
   reg [ARUSER_LENGTH - 1:0]      tb_aruser   = 0;
   reg [RUSER_LENGTH - 1:0]       tb_ruser    = 0;
   reg [WUSER_LENGTH - 1:0]       tb_wuser    = 0;
   reg [RESP_LENGTH - 1:0]        tb_response = 0;
   reg [RESP_VECT_LENGTH - 1:0]   tb_response_vector = 0;
   reg [BUSER_LENGTH - 1:0]       tb_buser    = 0;
   //---------------------------------------------------------------------------
   // AXI bus signals
   //---------------------------------------------------------------------------
   // Read address channel
   wire [ID_WIDTH-1:0]            axi_arid;    // Master Read address ID.
   wire [ADDR_MASTER_WIDTH-1:0]   axi_araddr;  // Master Read address.
   wire [7:0]                     axi_arlen;   // Master Burst length.
   wire [2:0]                     axi_arsize;  // Master Burst size.
   wire [1:0]                     axi_arburst; // Master Burst type.
   wire                           axi_arlock;  // Master Lock type.
   wire [3:0]                     axi_arcache; // Master Cache type.
   wire [2:0]                     axi_arprot;  // Master Protection type.
   wire [3:0]                     axi_arqos;   // Master QoS signals.
   wire [3:0]                     axi_arregion;// Master Region signals.
   wire [ARUSER_WIDTH-1:0]        axi_aruser;  // Master User defined signals.
   wire                           axi_arvalid; // Master Read address valid.
   wire                           axi_arready; // Slave Read address ready.
   // Read data channel
   wire [ID_WIDTH-1:0]            axi_rid;     // Slave Read ID tag. 
   wire [DATA_WIDTH-1:0]          axi_rdata;   // Slave Read data.
   wire [1:0]                     axi_rresp;   // Slave Read response.
   wire                           axi_rlast;   // Slave Read last.
   wire [RUSER_WIDTH-1:0]         axi_ruser;   // Slave Read user defined signals.
   wire                           axi_rvalid;  // Slave Read valid.
   wire                           axi_rready;  // Master Read ready.
   // Write address channel
   wire [ID_WIDTH-1:0]            axi_awid;    // Master Write address ID. 
   wire [ADDR_MASTER_WIDTH-1:0]   axi_awaddr;  // Master Write address. 
   wire [7:0]                     axi_awlen;   // Master Burst length.
   wire [2:0]                     axi_awsize;  // Master Burst size.
   wire [1:0]                     axi_awburst; // Master Burst type.
   wire                           axi_awlock;  // Master Lock type.
   wire [3:0]                     axi_awcache; // Master Cache type.
   wire [2:0]                     axi_awprot;  // Master Protection type.
   wire [3:0]                     axi_awqos;   // Master QoS signals.
   wire [3:0]                     axi_awregion;// Master Region signals.
   wire [AWUSER_WIDTH-1:0]        axi_awuser;  // Master User defined signals.
   wire                           axi_awvalid; // Master Write address valid.
   wire                           axi_awready; // Slave Write address ready.
   // Write data channel
   wire [DATA_WIDTH-1:0]          axi_wdata;   // Master Write data.
   wire [(DATA_WIDTH/8)-1:0]      axi_wstrb;   // Master Write strobes.
   wire                           axi_wlast;   // Master Write last.
   wire [WUSER_WIDTH-1:0]         axi_wuser;   // Master Write User defined signals.
   wire                           axi_wvalid;  // Master Write valid.
   wire                           axi_wready;  // Slave Write ready.
   // Write response channel
   wire [ID_WIDTH-1:0]            axi_bid;     // Slave Response ID.
   wire [1:0]                     axi_bresp;   // Slave Write response.
   wire [BUSER_WIDTH-1:0]         axi_buser;   // Slave Write user defined signals.
   wire                           axi_bvalid;  // Slave Write response valid. 
   wire                           axi_bready;  // Master Response ready.

   //---------------------------------------------------------------------------
   // Generate system clock
   //---------------------------------------------------------------------------
   initial
   begin
      aclk = 1'b0;
      forever #(`PERIOD_100MHz / 2) aclk = !aclk;
   end

   //---------------------------------------------------------------------------
   // Safety if something is wrong with simulation
   //---------------------------------------------------------------------------
   initial
   begin
      #8000000;
      $display("TB ERROR : Simulation Running Forever at %0d ns", $time);
      $stop;
   end

   //---------------------------------------------------------------------------
   // Monitor Reset and print info to transcript
   //---------------------------------------------------------------------------
   initial
   begin
      wait(aresetn);
      $display("INFO: Reset released at %0d ns", $time);
   end

   //---------------------------------------------------------------------------
   // Unit Under Test
   //---------------------------------------------------------------------------
   axi_parameter_ram_v1_0
   #(
      .C_S00_AXI_ID_WIDTH         (ID_WIDTH),
      .C_S00_AXI_DATA_WIDTH       (DATA_WIDTH),
      .C_S00_AXI_ADDR_WIDTH       (ADDR_SLAVE_WIDTH),
      .C_S00_AXI_ARUSER_WIDTH     (ARUSER_WIDTH),
      .C_S00_AXI_RUSER_WIDTH      (RUSER_WIDTH),
      .C_S00_AXI_AWUSER_WIDTH     (AWUSER_WIDTH),
      .C_S00_AXI_WUSER_WIDTH      (WUSER_WIDTH),
      .C_S00_AXI_BUSER_WIDTH      (BUSER_WIDTH)
   )
   axi_parameter_ram_v1_0_inst
   (
      //------------------------------------------------------------------------
      // Debug interface
      //------------------------------------------------------------------------
      .debug                      (debug),
      //------------------------------------------------------------------------
      // Interrupt interface
      //------------------------------------------------------------------------
      .o_int                      (interupt),
      //------------------------------------------------------------------------
      // Axi Slave Bus Interface
      //------------------------------------------------------------------------
      // System
      .s00_axi_aclk               (aclk),
      .s00_axi_aresetn            (aresetn),
      // Read address channel
      .s00_axi_arid               (axi_arid),
      .s00_axi_araddr             (axi_araddr[ADDR_SLAVE_WIDTH-1:0]),
      .s00_axi_arlen              (axi_arlen),
      .s00_axi_arsize             (axi_arsize),
      .s00_axi_arburst            (axi_arburst),
      .s00_axi_arlock             (axi_arlock),
      .s00_axi_arcache            (axi_arcache),
      .s00_axi_arprot             (axi_arprot),
      .s00_axi_arqos              (axi_arqos),
      .s00_axi_arregion           (axi_arregion),
      .s00_axi_aruser             (axi_aruser),
      .s00_axi_arvalid            (axi_arvalid),
      .s00_axi_arready            (axi_arready),
      // Read data channel
      .s00_axi_rid                (axi_rid),
      .s00_axi_rdata              (axi_rdata),
      .s00_axi_rresp              (axi_rresp),
      .s00_axi_rlast              (axi_rlast),
      .s00_axi_ruser              (axi_ruser),
      .s00_axi_rvalid             (axi_rvalid),
      .s00_axi_rready             (axi_rready),
      // Write address channel
      .s00_axi_awid               (axi_awid),
      .s00_axi_awaddr             (axi_awaddr[ADDR_SLAVE_WIDTH-1:0]),
      .s00_axi_awlen              (axi_awlen),
      .s00_axi_awsize             (axi_awsize),
      .s00_axi_awburst            (axi_awburst),
      .s00_axi_awlock             (axi_awlock),
      .s00_axi_awcache            (axi_awcache),
      .s00_axi_awprot             (axi_awprot),
      .s00_axi_awqos              (axi_awqos),
      .s00_axi_awregion           (axi_awregion),
      .s00_axi_awuser             (axi_awuser),
      .s00_axi_awvalid            (axi_awvalid),
      .s00_axi_awready            (axi_awready),
      // Write data channel
      .s00_axi_wdata              (axi_wdata),
      .s00_axi_wstrb              (axi_wstrb),
      .s00_axi_wlast              (axi_wlast),
      .s00_axi_wuser              (axi_wuser),
      .s00_axi_wvalid             (axi_wvalid),
      .s00_axi_wready             (axi_wready),
      // Write response channel
      .s00_axi_bid                (axi_bid),
      .s00_axi_bresp              (axi_bresp),
      .s00_axi_buser              (axi_buser),
      .s00_axi_bvalid             (axi_bvalid),
      .s00_axi_bready             (axi_bready)
   );

   //---------------------------------------------------------------------------
   // AXI4 master
   //---------------------------------------------------------------------------
   cdn_axi4_master_bfm
   #(
      .NAME                       (MASTER_NAME),
      .DATA_BUS_WIDTH             (DATA_WIDTH),
      .ADDRESS_BUS_WIDTH          (ADDR_MASTER_WIDTH),
      .ID_BUS_WIDTH               (ID_WIDTH),
      .AWUSER_BUS_WIDTH           (AWUSER_WIDTH),
      .ARUSER_BUS_WIDTH           (ARUSER_WIDTH),
      .RUSER_BUS_WIDTH            (RUSER_WIDTH),
      .WUSER_BUS_WIDTH            (WUSER_WIDTH),
      .BUSER_BUS_WIDTH            (BUSER_WIDTH),
      .MAX_OUTSTANDING_TRANSACTIONS(READ_ISSUING),
      .EXCLUSIVE_ACCESS_SUPPORTED (EXCL_ACCESS_SUPPORT)
   )
   cdn_axi4_master_bfm_inst
   (
      // System
      .ACLK                       (aclk),
      .ARESETn                    (aresetn),
      // Read address channel
      .ARID                       (axi_arid),
      .ARADDR                     (axi_araddr),
      .ARLEN                      (axi_arlen),
      .ARSIZE                     (axi_arsize),
      .ARBURST                    (axi_arburst),
      .ARLOCK                     (axi_arlock),
      .ARCACHE                    (axi_arcache),
      .ARPROT                     (axi_arprot),
      .ARQOS                      (axi_arqos),
      .ARREGION                   (axi_arregion),
      .ARUSER                     (axi_aruser),
      .ARVALID                    (axi_arvalid),
      .ARREADY                    (axi_arready),
      // Read data channel
      .RID                        (axi_rid),
      .RDATA                      (axi_rdata),
      .RRESP                      (axi_rresp),
      .RLAST                      (axi_rlast),
      .RUSER                      (axi_ruser),
      .RVALID                     (axi_rvalid),
      .RREADY                     (axi_rready),
      // Write address channel
      .AWID                       (axi_awid),
      .AWADDR                     (axi_awaddr),
      .AWLEN                      (axi_awlen),
      .AWSIZE                     (axi_awsize),
      .AWBURST                    (axi_awburst),
      .AWLOCK                     (axi_awlock),
      .AWCACHE                    (axi_awcache),
      .AWPROT                     (axi_awprot),
      .AWQOS                      (axi_awqos),
      .AWREGION                   (axi_awregion),
      .AWUSER                     (axi_awuser),
      .AWVALID                    (axi_awvalid),
      .AWREADY                    (axi_awready),
      // Write data channel
      .WDATA                      (axi_wdata),
      .WSTRB                      (axi_wstrb),
      .WLAST                      (axi_wlast),
      .WUSER                      (axi_wuser),
      .WVALID                     (axi_wvalid),
      .WREADY                     (axi_wready),
      // Write response channel
      .BID                        (axi_bid),
      .BRESP                      (axi_bresp),
      .BUSER                      (axi_buser),
      .BVALID                     (axi_bvalid),
      .BREADY                     (axi_bready)
   );

   //---------------------------------------------------------------------------
   // Test bench.
   //---------------------------------------------------------------------------
   initial
   begin
      //------------------------------------------------------------------------
      // Setup
      //------------------------------------------------------------------------
      // Time stamp format for display
      $timeformat(-9, 2, " ns", 10);
      // Enable extra debug info
      cdn_axi4_master_bfm_inst.set_channel_level_info(1);
      //------------------------------------------------------------------------
      // TB Setup
      //------------------------------------------------------------------------
      $write ("\n");
      $display("============================================================");
      $display("== TB Setup ");
      $display("============================================================");
      // Release Reset;
      Reset_Pulse;
      // Wait for inaktive Reset and add 5 clock cycles
      wait(aresetn);
      repeat(5) @(posedge aclk);
      //------------------------------------------------------------------------
      // Test: Read from register
      //------------------------------------------------------------------------
      $write("\n");
      $display("============================================================");
      $display("== Test: Read from register");
      $display("============================================================");
      // Setup data;
      tb_addr = S_ADDRESS + 32'h0000_0000;
      tb_len  = 4;
      // Data is read
      cdn_axi4_master_bfm_inst.READ_BURST
      (
         tb_id,
         tb_addr,
         tb_len-1,
         tb_size,
         tb_burst,
         tb_lock,
         tb_cache,
         tb_prot,
         tb_region,
         tb_qos,
         tb_aruser,
         tb_data_rd,
         tb_response_vector,
         tb_ruser
      );
      // Check read command
      CHECK_RESPONSE_VECTOR_OKAY(tb_response_vector, tb_len);
      $display("tb_response_vector = 0x%h", tb_response_vector);
      Data_Print_Hex(tb_data_rd, tb_len);
      $display("============================================================");
      //------------------------------------------------------------------------
      // Test: Write to memory
      //------------------------------------------------------------------------
      $write("\n");
      $display("============================================================");
      $display("== Test: Write to memory");
      $display("============================================================");
      // Setup data;
      tb_addr = S_ADDRESS + 32'h0000_01C;
      tb_len  = 8;
      tb_data_wr = 512'h00000000_11111111_22222222_33333333_44444444_55555555_66666666_77777777_88888888_99999999_AAAAAAAA_BBBBBBBB_CCCCCCCC_DDDDDDDD_EEEEEEEE_AAAA5555;
      // Data to be written
      Data_Print_Hex(tb_data_wr, tb_len);
      // Data is written
      cdn_axi4_master_bfm_inst.WRITE_BURST
      (
         tb_id,
         tb_addr,
         tb_len - 1,
         tb_size,
         tb_burst,
         tb_lock,
         tb_cache,
         tb_prot,
         tb_data_wr,
         tb_datasize,
         tb_region,
         tb_qos,
         tb_awuser,
         tb_wuser,
         tb_response,
         tb_buser
      );
      // Check write command
      CHECK_RESPONSE_OKAY(tb_response);
      $display("tb_response = 0x%h", tb_response);
      $display("============================================================");
      //------------------------------------------------------------------------
      // Test: Wait for interrupt (FIFO has new data)
      //------------------------------------------------------------------------
      wait(interupt);
      //------------------------------------------------------------------------
      // Test: Read from register
      //------------------------------------------------------------------------
      $write("\n");
      $display("============================================================");
      $display("== Test: Read from register");
      $display("============================================================");
      // Setup data;
      tb_addr = S_ADDRESS + 32'h0000_0000;
      tb_len  = 4;
      // Data is read
      cdn_axi4_master_bfm_inst.READ_BURST
      (
         tb_id,
         tb_addr,
         tb_len-1,
         tb_size,
         tb_burst,
         tb_lock,
         tb_cache,
         tb_prot,
         tb_region,
         tb_qos,
         tb_aruser,
         tb_data_rd,
         tb_response_vector,
         tb_ruser
      );
      // Check read command
      CHECK_RESPONSE_VECTOR_OKAY(tb_response_vector, tb_len);
      $display("tb_response_vector = 0x%h", tb_response_vector);
      Data_Print_Hex(tb_data_rd, tb_len);
      $display("============================================================");
      //------------------------------------------------------------------------
      // Test: Read from memory
      //------------------------------------------------------------------------
      $write("\n");
      $display("============================================================");
      $display("== Test: Read from memory");
      $display("============================================================");
      // Setup data;
      tb_addr = S_ADDRESS + 32'h0000_001C;
      tb_len  = 8;
      // Data is read
      cdn_axi4_master_bfm_inst.READ_BURST
      (
         tb_id,
         tb_addr,
         tb_len-1,
         tb_size,
         tb_burst,
         tb_lock,
         tb_cache,
         tb_prot,
         tb_region,
         tb_qos,
         tb_aruser,
         tb_data_rd,
         tb_response_vector,
         tb_ruser
      );
      // Check read command
      CHECK_RESPONSE_VECTOR_OKAY(tb_response_vector, tb_len);
      $display("tb_response_vector = 0x%h", tb_response_vector);
      Data_Print_Hex(tb_data_rd, tb_len);
      $display("============================================================");
      //------------------------------------------------------------------------
      // Test Done
      //------------------------------------------------------------------------
      $stop;
   end

   //---------------------------------------------------------------------------
   // Reset Pulse task
   //---------------------------------------------------------------------------
   task Reset_Pulse;
   begin
      aresetn = 1'b0;
      // Keep reset for 10 clock cycles.
      repeat (10) @(posedge aclk);
      // Release the reset on the posedge of the clk.
      aresetn = 1'b1;
   end
   endtask

   //---------------------------------------------------------------------------
   // Data Print Hexadecimal task
   //---------------------------------------------------------------------------
   task Data_Print_Hex;
      input [(DATA_WIDTH*(`MAX_BURST_LENGTH + 1)) - 1:0] data;
      input integer                                      burst_length;
      integer                                            index;
      reg [31:0]                                         tempData;
   begin
      $display("DATA:");
      for (index = 0;  index < burst_length ; index = index + 1)
      begin
         tempData = data >> (32 * index);
         $display("   0x%08x", tempData);
      end
   end
   endtask

   //---------------------------------------------------------------------------
   // Data Print Decimal task
   //---------------------------------------------------------------------------
   task Data_Print_Dec;
      input [(DATA_WIDTH*(`MAX_BURST_LENGTH + 1)) - 1:0] data;
      input integer                                      burst_length;
      integer                                            index;
      reg [31:0]                                         tempData;
   begin
      $display("DATA:");
      for (index = 0;  index < burst_length ; index = index + 1)
      begin
         tempData = data >> (32 * index);
         $display("   %8d", tempData);
      end
   end
   endtask

   //---------------------------------------------------------------------------
   // Check tb_response
   //---------------------------------------------------------------------------
   task automatic CHECK_RESPONSE_OKAY;
      input [RESP_LENGTH - 1:0] tb_response;
   begin
      if (tb_response !== `RESPONSE_OKAY)
      begin
         $display("ERROR: CHECK_RESPONSE_OKAY: Fault response!");
         $display("   tb_response = 0x%h", tb_response);
         $stop;
      end
   end
   endtask

   //---------------------------------------------------------------------------
   // Check tb_response in a vector
   //---------------------------------------------------------------------------
   task automatic CHECK_RESPONSE_VECTOR_OKAY;
      input [RESP_VECT_LENGTH - 1:0] tb_response;
      input integer                  burst_length;
      integer                        i;
   begin
      for (i = 0; i < burst_length+1; i = i+1)
      begin
         CHECK_RESPONSE_OKAY(tb_response[i*`RESP_WIDTH +: `RESP_WIDTH]);
      end
   end
   endtask

   //---------------------------------------------------------------------------
   // Compare two sets of data (e.g. written and read back data)
   //---------------------------------------------------------------------------
   task automatic COMPARE_DATA;
      input [DATA_LENGTH - 1:0] data_1;
      input [DATA_LENGTH - 1:0] data_2;
   begin
      if (data_1 === 'hx || data_2 === 'hx)
      begin
         $display("ERROR: COMPARE_DATA: Cannot be performed with a vector that is all 'x'!");
         $stop;
      end
      if (data_1 != data_2) begin
         $display("ERROR: COMPARE_DATA: Data is not equal!");
         $display("   data_1 = 0x%h", data_1);
         $display("   data_2 = 0x%h", data_2);
         $stop;
      end
   end
   endtask

endmodule
