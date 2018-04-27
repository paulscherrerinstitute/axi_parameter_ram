--------------------------------------------------------------------------------
--                       Paul Scherrer Institute (PSI)
--------------------------------------------------------------------------------
-- Unit    : axi_parameter_ram_v1_0.vhd
-- Author  : Goran Marinkovic, Section Diagnostic
-- Version : $Revision: 1.4 $
--------------------------------------------------------------------------------
-- Copyright© PSI, Section Diagnostic
--------------------------------------------------------------------------------
-- Comment : This is the top file for the ADC16HL card interface.
--------------------------------------------------------------------------------
-- Std. library (platform) -----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Work library (platform) -----------------------------------------------------
library unisim;
use unisim.vcomponents.all;

-- Work library (application) --------------------------------------------------
library work;
use work.axi_slave_ipif_package.all;

entity axi_parameter_ram_v1_0 is
   generic
   (
      -- Parameters of Axi Slave Bus Interface
      C_S00_AXI_ID_WIDTH          : integer := 1;                             -- Width of ID for for write address, write data, read address and read data
      C_S00_AXI_DATA_WIDTH        : integer := 32;                            -- Width of S_AXI data bus
      C_S00_AXI_ADDR_WIDTH        : integer := 16;                            -- Width of S_AXI address bus
      C_S00_AXI_ARUSER_WIDTH      : integer := 0;                             -- Width of optional user defined signal in read address channel
      C_S00_AXI_RUSER_WIDTH       : integer := 0;                             -- Width of optional user defined signal in read data channel
      C_S00_AXI_AWUSER_WIDTH      : integer := 0;                             -- Width of optional user defined signal in write address channel
      C_S00_AXI_WUSER_WIDTH       : integer := 0;                             -- Width of optional user defined signal in write data channel
      C_S00_AXI_BUSER_WIDTH       : integer := 0                              -- Width of optional user defined signal in write response channel
   );
   port
   (
      --------------------------------------------------------------------------
      -- Debug interface
      --------------------------------------------------------------------------
      debug                       : out   std_logic_vector(127 downto  0);
      --------------------------------------------------------------------------
      -- Interrupt interface
      --------------------------------------------------------------------------
      o_int                       : out   std_logic;
      --------------------------------------------------------------------------
      -- Axi Slave Bus Interface
      --------------------------------------------------------------------------
      -- System
      s00_axi_aclk                : in    std_logic;                                             -- Global Clock Signal
      s00_axi_aresetn             : in    std_logic;                                             -- Global Reset Signal. This signal is low active.
      -- Read address channel
      s00_axi_arid                : in    std_logic_vector(C_S00_AXI_ID_WIDTH-1   downto 0);     -- Read address ID. This signal is the identification tag for the read address group of signals.
      s00_axi_araddr              : in    std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);     -- Read address. This signal indicates the initial address of a read burst transaction.
      s00_axi_arlen               : in    std_logic_vector(7 downto 0);                          -- Burst length. The burst length gives the exact number of transfers in a burst
      s00_axi_arsize              : in    std_logic_vector(2 downto 0);                          -- Burst size. This signal indicates the size of each transfer in the burst
      s00_axi_arburst             : in    std_logic_vector(1 downto 0);                          -- Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
      s00_axi_arlock              : in    std_logic;                                             -- Lock type. Provides additional information about the atomic characteristics of the transfer.
      s00_axi_arcache             : in    std_logic_vector(3 downto 0);                          -- Memory type. This signal indicates how transactions are required to progress through a system.
      s00_axi_arprot              : in    std_logic_vector(2 downto 0);                          -- Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
      s00_axi_arqos               : in    std_logic_vector(3 downto 0);                          -- Quality of Service, QoS identifier sent for each read transaction.
      s00_axi_arregion            : in    std_logic_vector(3 downto 0);                          -- Region identifier. Permits a single physical interface on a slave to be used for multiple logical interfaces.
      s00_axi_aruser              : in    std_logic_vector(C_S00_AXI_ARUSER_WIDTH-1 downto 0);   -- Optional User-defined signal in the read address channel.
      s00_axi_arvalid             : in    std_logic;                                             -- Write address valid. This signal indicates that the channel is signaling valid read address and control information.
      s00_axi_arready             : out   std_logic;                                             -- Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
      -- Read data channel
      s00_axi_rid                 : out   std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);       -- Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
      s00_axi_rdata               : out   std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);     -- Read Data
      s00_axi_rresp               : out   std_logic_vector(1 downto 0);                          -- Read response. This signal indicates the status of the read transfer.
      s00_axi_rlast               : out   std_logic;                                             -- Read last. This signal indicates the last transfer in a read burst.
      s00_axi_ruser               : out   std_logic_vector(C_S00_AXI_RUSER_WIDTH-1 downto 0);    -- Optional User-defined signal in the read address channel.
      s00_axi_rvalid              : out   std_logic;                                             -- Read valid. This signal indicates that the channel is signaling the required read data.
      s00_axi_rready              : in    std_logic;                                             -- Read ready. This signal indicates that the master can accept the read data and response information.
      -- Write address channel
      s00_axi_awid                : in    std_logic_vector(C_S00_AXI_ID_WIDTH-1   downto 0);     -- Write Address ID
      s00_axi_awaddr              : in    std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);     -- Write address
      s00_axi_awlen               : in    std_logic_vector(7 downto 0);                          -- Burst length. The burst length gives the exact number of transfers in a burst
      s00_axi_awsize              : in    std_logic_vector(2 downto 0);                          -- Burst size. This signal indicates the size of each transfer in the burst
      s00_axi_awburst             : in    std_logic_vector(1 downto 0);                          -- Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
      s00_axi_awlock              : in    std_logic;                                             -- Lock type. Provides additional information about the atomic characteristics of the transfer.
      s00_axi_awcache             : in    std_logic_vector(3 downto 0);                          -- Memory type. This signal indicates how transactions are required to progress through a system.
      s00_axi_awprot              : in    std_logic_vector(2 downto 0);                          -- Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
      s00_axi_awqos               : in    std_logic_vector(3 downto 0);                          -- Quality of Service, QoS identifier sent for each write transaction.
      s00_axi_awregion            : in    std_logic_vector(3 downto 0);                          -- Region identifier. Permits a single physical interface on a slave to be used for multiple logical interfaces.
      s00_axi_awuser              : in    std_logic_vector(C_S00_AXI_AWUSER_WIDTH-1 downto 0);   -- Optional User-defined signal in the write address channel.
      s00_axi_awvalid             : in    std_logic;                                             -- Write address valid. This signal indicates that the channel is signaling valid write address and control information.
      s00_axi_awready             : out   std_logic;                                             -- Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
      -- Write data channel
      s00_axi_wdata               : in    std_logic_vector( C_S00_AXI_DATA_WIDTH-1    downto 0); -- Write Data
      s00_axi_wstrb               : in    std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0); -- Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
      s00_axi_wlast               : in    std_logic;                                             -- Write last. This signal indicates the last transfer in a write burst.
      s00_axi_wuser               : in    std_logic_vector(C_S00_AXI_WUSER_WIDTH-1 downto 0);    -- Optional User-defined signal in the write data channel.
      s00_axi_wvalid              : in    std_logic;                                             -- Write valid. This signal indicates that valid write data and strobes are available.
      s00_axi_wready              : out   std_logic;                                             -- Write ready. This signal indicates that the slave can accept the write data.
      -- Write response channel
      s00_axi_bid                 : out   std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);       -- Response ID tag. This signal is the ID tag of the write response.
      s00_axi_bresp               : out   std_logic_vector(1 downto 0);                          -- Write response. This signal indicates the status of the write transaction.
      s00_axi_buser               : out   std_logic_vector(C_S00_AXI_BUSER_WIDTH-1 downto 0);    -- Optional User-defined signal in the write response channel.
      s00_axi_bvalid              : out   std_logic;                                             -- Write response valid. This signal indicates that the channel is signaling a valid write response.
      s00_axi_bready              : in    std_logic                                              -- Response ready. This signal indicates that the master can accept a write response.
   );
end axi_parameter_ram_v1_0;

architecture arch_imp of axi_parameter_ram_v1_0 is

   -----------------------------------------------------------------------------
   -- System Interface
   -----------------------------------------------------------------------------
   constant LOW                   : std_logic := '0';
   constant LOW4                  : std_logic_vector( 3 downto  0) := (others => '0');
   constant LOW8                  : std_logic_vector( 7 downto  0) := (others => '0');
   constant LOW16                 : std_logic_vector(15 downto  0) := (others => '0');
   constant LOW32                 : std_logic_vector(31 downto  0) := (others => '0');
   constant LOW64                 : std_logic_vector(63 downto  0) := (others => '0');
   constant HIGH                  : std_logic := '1';
   constant HIGH4                 : std_logic_vector( 3 downto  0) := (others => '1');
   constant HIGH8                 : std_logic_vector( 7 downto  0) := (others => '1');
   constant HIGH16                : std_logic_vector(15 downto  0) := (others => '1');
   constant HIGH32                : std_logic_vector(31 downto  0) := (others => '1');
   constant HIGH64                : std_logic_vector(63 downto  0) := (others => '1');
   -----------------------------------------------------------------------------
   -- Register Interface
   -----------------------------------------------------------------------------
   constant C_NUM_REG             : integer := 4; -- only powers of 2 are allowed
   signal   reg_rd                : std_logic_vector(C_NUM_REG-1 downto  0);
   signal   reg_rdata             : slv_reg_type(0 to C_NUM_REG-1);
   signal   reg_wr                : std_logic_vector(C_NUM_REG-1 downto  0);
   signal   reg_wdata             : slv_reg_type(0 to C_NUM_REG-1);
   -----------------------------------------------------------------------------
   -- Memory Interface
   -----------------------------------------------------------------------------
   signal   mem_addr              : std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto  0);
   signal   mem_wr                : std_logic_vector( 3 downto  0);
   signal   mem_wdata             : std_logic_vector(31 downto  0);
   signal   mem_rdata             : std_logic_vector(31 downto  0);
   signal   mem_wr_any            : std_logic;
   -----------------------------------------------------------------------------
   -- FIFO Interface
   -----------------------------------------------------------------------------
   signal   fifo_rst              : std_logic := '1';  
   signal   fifo_wr               : std_logic := '0';  
   signal   fifo_rd_req           : std_logic_vector( 1 downto  0) := (others => '0');
   signal   fifo_rd               : std_logic := '0';  
   signal   fifo_rd_data          : std_logic_vector(9 downto  0) := (others => '0');
   signal   fifo_full             : std_logic := '0';  
   signal   fifo_empty            : std_logic := '0';  
   -----------------------------------------------------------------------------
   -- Interrupt Interface
   -----------------------------------------------------------------------------
   signal   int                   : std_logic := '0';  

begin

   ---------------------------------------------------------------------------
   -- Debug
   ---------------------------------------------------------------------------
   debug(127 downto   0)          <= (others => '0');

   -----------------------------------------------------------------------------
   -- AXI decode instance
   -----------------------------------------------------------------------------
   axi_slave_reg_mem_inst : entity work.axi_slave_ipif_reg_mem
   generic map
   (
      -- Users parameters
      C_NUM_REG                   => C_NUM_REG,
      C_RESET_VAL                 =>
      (
         X"00000000",
         X"00000000",
         X"00000000",
         X"00000000"
      ),
      -- Parameters of Axi Slave Bus Interface
      C_S_AXI_ID_WIDTH            => C_S00_AXI_ID_WIDTH,
      C_S_AXI_DATA_WIDTH          => C_S00_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH          => C_S00_AXI_ADDR_WIDTH,
      C_S_AXI_ARUSER_WIDTH        => C_S00_AXI_ARUSER_WIDTH,
      C_S_AXI_RUSER_WIDTH         => C_S00_AXI_RUSER_WIDTH,
      C_S_AXI_AWUSER_WIDTH        => C_S00_AXI_AWUSER_WIDTH,
      C_S_AXI_WUSER_WIDTH         => C_S00_AXI_WUSER_WIDTH,
      C_S_AXI_BUSER_WIDTH         => C_S00_AXI_BUSER_WIDTH
   )
   port map
   (
      --------------------------------------------------------------------------
      -- Axi Slave Bus Interface
      --------------------------------------------------------------------------
      -- System
      s_axi_aclk                  => s00_axi_aclk,
      s_axi_aresetn               => s00_axi_aresetn,
      -- Read address channel
      s_axi_arid                  => s00_axi_arid,
      s_axi_araddr                => s00_axi_araddr,
      s_axi_arlen                 => s00_axi_arlen,
      s_axi_arsize                => s00_axi_arsize,
      s_axi_arburst               => s00_axi_arburst,
      s_axi_arlock                => s00_axi_arlock,
      s_axi_arcache               => s00_axi_arcache,
      s_axi_arprot                => s00_axi_arprot,
      s_axi_arqos                 => s00_axi_arqos,
      s_axi_arregion              => s00_axi_arregion,
      s_axi_aruser                => s00_axi_aruser,
      s_axi_arvalid               => s00_axi_arvalid,
      s_axi_arready               => s00_axi_arready,
      -- Read data channel
      s_axi_rid                   => s00_axi_rid,
      s_axi_rdata                 => s00_axi_rdata,
      s_axi_rresp                 => s00_axi_rresp,
      s_axi_rlast                 => s00_axi_rlast,
      s_axi_ruser                 => s00_axi_ruser,
      s_axi_rvalid                => s00_axi_rvalid,
      s_axi_rready                => s00_axi_rready,
      -- Write address channel
      s_axi_awid                  => s00_axi_awid,
      s_axi_awaddr                => s00_axi_awaddr,
      s_axi_awlen                 => s00_axi_awlen,
      s_axi_awsize                => s00_axi_awsize,
      s_axi_awburst               => s00_axi_awburst,
      s_axi_awlock                => s00_axi_awlock,
      s_axi_awcache               => s00_axi_awcache,
      s_axi_awprot                => s00_axi_awprot,
      s_axi_awqos                 => s00_axi_awqos,
      s_axi_awregion              => s00_axi_awregion,
      s_axi_awuser                => s00_axi_awuser,
      s_axi_awvalid               => s00_axi_awvalid,
      s_axi_awready               => s00_axi_awready,
      -- Write data channel
      s_axi_wdata                 => s00_axi_wdata,
      s_axi_wstrb                 => s00_axi_wstrb,
      s_axi_wlast                 => s00_axi_wlast,
      s_axi_wuser                 => s00_axi_wuser,
      s_axi_wvalid                => s00_axi_wvalid,
      s_axi_wready                => s00_axi_wready,
      -- Write response channel
      s_axi_bid                   => s00_axi_bid,
      s_axi_bresp                 => s00_axi_bresp,
      s_axi_buser                 => s00_axi_buser,
      s_axi_bvalid                => s00_axi_bvalid,
      s_axi_bready                => s00_axi_bready,
      --------------------------------------------------------------------------
      -- Register Interface
      --------------------------------------------------------------------------
      o_reg_rd                    => reg_rd,
      i_reg_rdata                 => reg_rdata,
      o_reg_wr                    => reg_wr,
      o_reg_wdata                 => reg_wdata,
      --------------------------------------------------------------------------
      -- Memory Interface
      --------------------------------------------------------------------------
      o_mem_addr                  => mem_addr,
      o_mem_wr                    => mem_wr,
      o_mem_wdata                 => mem_wdata,
      i_mem_rdata                 => mem_rdata
   );

   -----------------------------------------------------------------------------
   -- Interrupt message
   -----------------------------------------------------------------------------
   reg_rdata( 0)( 0)             <= fifo_empty;
   reg_rdata( 0)( 1)             <= fifo_full;
   reg_rdata( 0)(31 downto  2)   <= "000000000000000000000000000000";

   ---------------------------------------------------------------------------
   -- FIFO port
   ---------------------------------------------------------------------------
   reg_rdata( 1)                 <= X"00000" & fifo_rd_data(9 downto  0) & "00";

   ---------------------------------------------------------------------------
   -- Interrupt process
   ---------------------------------------------------------------------------
   int_proc: process(s00_axi_aclk) is
   begin
      if rising_edge(s00_axi_aclk) then
         if (s00_axi_aresetn = '0') then
            int                   <= '0';
         else
            if (fifo_empty = '0') then
               int                <= '1';
            else
               int                <= '0';
            end if;
         end if;
      end if;
   end process int_proc;

   o_int                          <= int;

   ---------------------------------------------------------------------------
   -- FIFO read
   ---------------------------------------------------------------------------
   fifo_rd_req_proc: process(s00_axi_aclk) is
   begin
      if rising_edge(s00_axi_aclk) then
         if (s00_axi_aresetn = '0') then
            fifo_rd_req           <= (others => '0');
         else
            fifo_rd_req           <= fifo_rd_req( 0) & reg_rd( 1);
         end if;
      end if;
   end process fifo_rd_req_proc;

   fifo_rd                        <= '1' when (fifo_rd_req( 1 downto  0) = "10") else '0';

   ---------------------------------------------------------------------------
   -- BRAM instance
   ---------------------------------------------------------------------------
   mem_wr_any <= '1' when mem_wr /= "0000" else '0';
   bram_1024x32_inst: entity work.psi_common_sp_ram_be
      generic map (
         Depth_g        => 1024,
         Width_g        => 32
      )
      port map (
         Clk           => s00_axi_aclk,
         Addr          => mem_addr(11 downto 2),
         Wr            => mem_wr_any,
         Be            => mem_wr,
         Din           => mem_wdata,
         Dout          => mem_rdata
      );

   ---------------------------------------------------------------------------
   -- FIFO instance
   ---------------------------------------------------------------------------
   fifo_rst                       <= not s00_axi_aresetn;
   fifo_wr                        <= '1' when ((mem_wr /= "0000") and (mem_addr(12) = '0')) else '0';
   
   fifo_1024x10_inst: entity work.psi_common_sync_fifo
      generic map (
         Width_g        => 10,
         Depth_g        => 1024,
         AlmFullOn_g    => false,
         AlmEmptyOn_g   => false
      )
      port map (
         Clk            => s00_axi_aclk,
         Rst            => fifo_rst,
         InVld          => fifo_wr,
         InData         => mem_addr(11 downto  2),
         OutRdy         => fifo_rd,
         OutData        => fifo_rd_data,
         Full           => fifo_full,
         Empty          => fifo_empty
      );
      
end arch_imp;

--------------------------------------------------------------------------------
-- End of file
--------------------------------------------------------------------------------
