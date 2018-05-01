------------------------------------------------------------------------------
-- Libraries
------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
library work;
	use work.psi_tb_txt_util.all;
	use work.psi_tb_axi_pkg.all;
	use work.psi_common_math_pkg.all;

entity axi_parameter_ram_tb is
end entity axi_parameter_ram_tb;

architecture sim of axi_parameter_ram_tb is

	-------------------------------------------------------------------------
	-- AXI Definition
	-------------------------------------------------------------------------
	constant ID_WIDTH 		: integer 	:= 1;
	constant ADDR_WIDTH 	: integer	:= 14;
	constant USER_WIDTH		: integer	:= 1;
	constant DATA_WIDTH		: integer	:= 32;
	constant BYTE_WIDTH		: integer	:= DATA_WIDTH/8;
	
	subtype ID_RANGE is natural range ID_WIDTH-1 downto 0;
	subtype ADDR_RANGE is natural range ADDR_WIDTH-1 downto 0;
	subtype USER_RANGE is natural range USER_WIDTH-1 downto 0;
	subtype DATA_RANGE is natural range DATA_WIDTH-1 downto 0;
	subtype BYTE_RANGE is natural range BYTE_WIDTH-1 downto 0;
	
	signal axi_ms : axi_ms_r (	arid(ID_RANGE), awid(ID_RANGE),
								araddr(ADDR_RANGE), awaddr(ADDR_RANGE),
								aruser(USER_RANGE), awuser(USER_RANGE), wuser(USER_RANGE),
								wdata(DATA_RANGE),
								wstrb(BYTE_RANGE));
	
	signal axi_sm : axi_sm_r (	rid(ID_RANGE), bid(ID_RANGE),
								ruser(USER_RANGE), buser(USER_RANGE),
								rdata(DATA_RANGE));

	-------------------------------------------------------------------------
	-- TB Defnitions
	-------------------------------------------------------------------------
	constant AclkFreq_c		: integer		:= 125_000_000;	
	constant AclkPeriod_c	: time		:= (1 sec)/AclkFreq_c;	
	signal TbRunning		: boolean		:= true;   	
	
	-------------------------------------------------------------------------
	-- Interface Signals
	-------------------------------------------------------------------------
	signal Irq				: std_logic		:= '0';
	signal aclk				: std_logic		:= '0';
	signal aresetn			: std_logic		:= '0';
	
	-------------------------------------------------------------------------
	-- Constants
	-------------------------------------------------------------------------	
	constant MemOffset_c		: integer		:= 16#0010#;
	constant NoIrqOffset_c		: integer		:= 16#1000#;
	
	constant TestAddrA_c		: integer		:= 16#0000#;
	constant TestAddrB_c		: integer		:= 16#012C#;
	
	constant AddrStatus_c		: integer		:= 16#0000#;
	constant MskStatus_Empty	: integer		:= 2**0;
	constant MskStatus_Full		: integer		:= 2**1;
	constant AddrAddr_c			: integer		:= 16#0004#;
	

begin

	-- ************************************************
	-- *** DUT
	-- ************************************************
	i_dut : entity work.axi_parameter_ram_v1_0
		generic map (
			-- Parameters of Axi Slave Bus Interface
			C_S00_AXI_ID_WIDTH     	 	=> ID_WIDTH,
			C_S00_AXI_DATA_WIDTH      	=> DATA_WIDTH,
			C_S00_AXI_ADDR_WIDTH      	=> ADDR_WIDTH,
			C_S00_AXI_ARUSER_WIDTH    	=> USER_WIDTH,
			C_S00_AXI_RUSER_WIDTH     	=> USER_WIDTH,
			C_S00_AXI_AWUSER_WIDTH    	=> USER_WIDTH,
			C_S00_AXI_WUSER_WIDTH     	=> USER_WIDTH,
			C_S00_AXI_BUSER_WIDTH     	=> USER_WIDTH	
		)
		port map
		(
			-- Interrupt interface
			o_int					=> Irq,
			-- Axi Slave Bus Interface
			s00_axi_aclk    	=> aclk,
			s00_axi_aresetn  	=> aresetn,
			s00_axi_arid        => axi_ms.arid,
			s00_axi_araddr      => axi_ms.araddr,
			s00_axi_arlen       => axi_ms.arlen,
			s00_axi_arsize      => axi_ms.arsize,
			s00_axi_arburst     => axi_ms.arburst,
			s00_axi_arlock      => axi_ms.arlock,
			s00_axi_arcache     => axi_ms.arcache,
			s00_axi_arprot      => axi_ms.arprot,
			s00_axi_arqos       => axi_ms.arqos,
			s00_axi_arregion    => axi_ms.arregion,
			s00_axi_aruser      => axi_ms.aruser,
			s00_axi_arvalid     => axi_ms.arvalid,
			s00_axi_arready     => axi_sm.arready,
			s00_axi_rid         => axi_sm.rid,
			s00_axi_rdata       => axi_sm.rdata,
			s00_axi_rresp       => axi_sm.rresp,
			s00_axi_rlast       => axi_sm.rlast,
			s00_axi_ruser       => axi_sm.ruser,
			s00_axi_rvalid      => axi_sm.rvalid,
			s00_axi_rready      => axi_ms.rready,
			s00_axi_awid    	=> axi_ms.awid,    
			s00_axi_awaddr      => axi_ms.awaddr,
			s00_axi_awlen       => axi_ms.awlen,
			s00_axi_awsize      => axi_ms.awsize,
			s00_axi_awburst     => axi_ms.awburst,
			s00_axi_awlock      => axi_ms.awlock,
			s00_axi_awcache     => axi_ms.awcache,
			s00_axi_awprot      => axi_ms.awprot,
			s00_axi_awqos       => axi_ms.awqos,
			s00_axi_awregion    => axi_ms.awregion,
			s00_axi_awuser      => axi_ms.awuser,
			s00_axi_awvalid     => axi_ms.awvalid,
			s00_axi_awready     => axi_sm.awready,
			s00_axi_wdata       => axi_ms.wdata,
			s00_axi_wstrb       => axi_ms.wstrb,
			s00_axi_wlast       => axi_ms.wlast,
			s00_axi_wuser       => axi_ms.wuser,
			s00_axi_wvalid      => axi_ms.wvalid,
			s00_axi_wready      => axi_sm.wready,
			s00_axi_bid         => axi_sm.bid,
			s00_axi_bresp       => axi_sm.bresp,
			s00_axi_buser       => axi_sm.buser,
			s00_axi_bvalid      => axi_sm.bvalid,
			s00_axi_bready      => axi_ms.bready
		);
		
	p_aclk : process
	begin
		while TbRunning loop
			wait for AclkPeriod_c/2;
			aclk <= not aclk;
		end loop;
		wait;
	end process;
	
	p_stimuli : process
	begin
		-- Reset
		aresetn <= '0';
		wait for 1 us;
		wait until rising_edge(aclk);
		aresetn <= '1';
		wait until rising_edge(aclk);
		
		-- *** Idle check ***
		assert Irq = '0' report "###ERROR###: IRQ was high after reset" severity error;
		axi_single_expect(AddrStatus_c, MskStatus_Empty, axi_ms, axi_sm, aclk, "Status was not empty after reset");
		
		-- *** Write and readback (with IRQ) ***		
		-- Write data and read it back
		axi_single_write(TestAddrA_c+MemOffset_c, 123, axi_ms, axi_sm, aclk);
		axi_single_expect(TestAddrA_c+MemOffset_c, 123, axi_ms, axi_sm, aclk, "Readback A");
		wait for 100 ns;
		assert Irq = '1' report "###ERROR###: IRQ was not fired after first write" severity error;
		-- Check if addresses do not interfer
		axi_single_write(TestAddrB_c+MemOffset_c, 987, axi_ms, axi_sm, aclk);
		axi_single_expect(TestAddrB_c+MemOffset_c, 987, axi_ms, axi_sm, aclk, "Readback B");	
		axi_single_expect(TestAddrA_c+MemOffset_c, 123, axi_ms, axi_sm, aclk, "Readback A after write to B");		
		-- Check IRQ processing
		assert Irq = '1' report "###ERROR###: IRQ not hold until processing" severity error;
		axi_single_expect(AddrStatus_c, 0, axi_ms, axi_sm, aclk, "Status wrong before IRQ processing [0]");
		axi_single_expect(AddrAddr_c, TestAddrA_c, axi_ms, axi_sm, aclk, "Wrong access address [0]");
		assert Irq = '1' report "###ERROR###: IRQ deasserted before both accesses are processed" severity error;
		axi_single_expect(AddrStatus_c, 0, axi_ms, axi_sm, aclk, "Status wrong before IRQ processing [1]");
		axi_single_expect(AddrAddr_c, TestAddrB_c, axi_ms, axi_sm, aclk, "Wrong access address [1]");
		wait for 100 ns;
		assert Irq = '0' report "###ERROR###: IRQ not deasserted after both accesses are processed" severity error;
		axi_single_expect(AddrStatus_c, MskStatus_Empty, axi_ms, axi_sm, aclk, "Status was not empty after IRQs are processed");
		
		-- *** Write without IRQ ***
		axi_single_write(TestAddrA_c+MemOffset_c+NoIrqOffset_c, 555, axi_ms, axi_sm, aclk);
		axi_single_expect(TestAddrA_c+MemOffset_c+NoIrqOffset_c, 555, axi_ms, axi_sm, aclk, "Readback A (No IRQ)");
		wait for 100 ns;
		assert Irq = '0' report "###ERROR###: IRQ was fired in no-irq case" severity error;		
		axi_single_expect(AddrStatus_c, MskStatus_Empty, axi_ms, axi_sm, aclk, "Status was not empty after no-irq access");
		
		-- *** Single byte access ***
		-- preset register
		axi_single_write(TestAddrA_c+MemOffset_c+NoIrqOffset_c, 16#12345678#, axi_ms, axi_sm, aclk);
		wait for 200 ns;
		assert Irq = '0' report "###ERROR###: IRQ was fired wrongly before signle byte access" severity error;	
		
		-- > Single byte write must be done manually (no library function available)
		wait until rising_edge(aclk);
		-- Signal write
		axi_ms.awaddr  		<= std_logic_vector(to_unsigned(TestAddrA_c+MemOffset_c, axi_ms.awaddr'length));
		axi_ms.awlen   		<= (others => '0');
		axi_ms.awsize  		<= std_logic_vector(to_unsigned(log2(axi_ms.wdata'length/8), axi_ms.awsize'length));
		axi_ms.awburst 		<= "01";
		axi_ms.awvalid 		<= '1';
		-- wait for address accepted
		wait until rising_edge(aclk) and axi_sm.awready = '1';
		axi_ms.awvalid 		<= '0';
		axi_ms.wdata		<= X"ABCDEF12";
		axi_ms.wstrb		<= "0100";
		axi_ms.wlast		<= '1';
		axi_ms.wvalid		<= '1';
		-- wait for data accepted
		wait until rising_edge(aclk) and axi_sm.wready = '1';
		axi_ms.wlast		<= '0';
		axi_ms.wvalid		<= '0';
		axi_ms.bready       <= '1';  
		-- wait for response
		wait until rising_edge(aclk) and axi_sm.bvalid = '1';
		axi_ms.bready       <= '0';  
		assert axi_sm.bresp = "00" report "###ERROR###: single byte writereceived negative response!" severity error;
		
		-- check
		axi_single_expect(TestAddrA_c+MemOffset_c, 16#12CD5678#, axi_ms, axi_sm, aclk, "Readback after single write");
		wait for 100 ns;
		assert Irq = '1' report "###ERROR###: IRQ was not fired after first write" severity error;
		axi_single_expect(AddrStatus_c, 0, axi_ms, axi_sm, aclk, "Status wrong before IRQ processing of single byte");
		axi_single_expect(AddrAddr_c, TestAddrA_c, axi_ms, axi_sm, aclk, "Wrong access address for single byte access");
		wait for 100 ns;
		assert Irq = '0' report "###ERROR###: IRQ not deasserted after single byte IRQ processed" severity error;
		axi_single_expect(AddrStatus_c, MskStatus_Empty, axi_ms, axi_sm, aclk, "Status was not empty after single byte IRQ processed");
		
		
		-- Finish
		wait for 1 us;
		TbRunning <= false;
		wait;
	end process;
   
end sim;
