--  Copy the following two statements and paste them before the
--  Entity declaration, unless they already exist.

Library UNISIM;
use UNISIM.vcomponents.all;

--  <-----Cut code below this line and paste into the architecture body---->

   -- PLL_BASE: Phase-Lock Loop Clock Circuit 
   --           Spartan-6
   -- Xilinx HDL Language Template, version 11.4
   
   PLL_BASE_inst : PLL_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- "HIGH", "LOW" or "OPTIMIZED" 
      CLKFBOUT_MULT => 2,        -- Multiplication factor for all output clocks
      CLKFBOUT_PHASE => 0.0,     -- Phase shift (degrees) of all output clocks
      CLKIN_PERIOD => 20.000,     -- Clock period (ns) of input clock on CLKIN
      CLKOUT0_DIVIDE => 1,       -- Division factor for CLKOUT0  (1 to 128)
      CLKOUT0_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT0 (0.01 to 0.99)
      CLKOUT0_PHASE => 0.0,      -- Phase shift (degrees) for CLKOUT0 (0.0 to 360.0)
      CLKOUT1_DIVIDE => 1,       -- Division factor for CLKOUT1 (1 to 128)
      CLKOUT1_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT1 (0.01 to 0.99)
      CLKOUT1_PHASE => 0.0,      -- Phase shift (degrees) for CLKOUT1 (0.0 to 360.0)
      CLKOUT2_DIVIDE => 1,       -- Division factor for CLKOUT2 (1 to 128)
      CLKOUT2_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT2 (0.01 to 0.99)
      CLKOUT2_PHASE => 0.0,      -- Phase shift (degrees) for CLKOUT2 (0.0 to 360.0)
      CLKOUT3_DIVIDE => 1,       -- Division factor for CLKOUT3 (1 to 128)
      CLKOUT3_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT3 (0.01 to 0.99)
      CLKOUT3_PHASE => 0.0,      -- Phase shift (degrees) for CLKOUT3 (0.0 to 360.0)
      CLKOUT4_DIVIDE => 1,       -- Division factor for CLKOUT4 (1 to 128)
      CLKOUT4_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT4 (0.01 to 0.99)
      CLKOUT4_PHASE => 0.0,      -- Phase shift (degrees) for CLKOUT4 (0.0 to 360.0)
      CLKOUT5_DIVIDE => 1,       -- Division factor for CLKOUT5 (1 to 128)
      CLKOUT5_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT5 (0.01 to 0.99)
      CLKOUT5_PHASE => 0.0,      -- Phase shift (degrees) for CLKOUT5 (0.0 to 360.0)
      COMPENSATION => "INTERNAL",  -- "SYSTEM_SYNCHRNOUS", 
                                             -- "SOURCE_SYNCHRNOUS", "INTERNAL", 
                                             -- "EXTERNAL", "DCM2PLL", "PLL2DCM" 
      DIVCLK_DIVIDE => 1,      -- Division factor for all clocks (1 to 52)
      REF_JITTER => 0.100)     -- Input reference jitter (0.000 to 0.999 UI%)
      port map (
      CLKFBOUT => CLKF,      -- General output feedback signal
      CLKOUT0 => CLKOUT,        -- One of six general clock output signals
      CLKOUT1 => open,        -- One of six general clock output signals
      CLKOUT2 => open,        -- One of six general clock output signals
      CLKOUT3 => open,        -- One of six general clock output signals
      CLKOUT4 => open,        -- One of six general clock output signals
      CLKOUT5 => open,        -- One of six general clock output signals
      LOCKED => open,          -- Active high PLL lock signal
      CLKFBIN => CLKF,        -- Clock feedback input
      CLKIN => CLKIN,            -- Clock input
      RST => open                 -- Asynchronous PLL reset
   );

   -- End of PLL_BASE_inst instantiation
