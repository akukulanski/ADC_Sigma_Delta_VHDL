-- Para instanciar en el Top_Level

library UNISIM;
use UNISIM.vcomponents.all;

--  <-----Cut code below this line and paste into the architecture body---->

-- IBUFDS: Differential Input Buffer
--         Spartan-6
-- Xilinx HDL Language Template, version 11.4

IBUFDS_inst : IBUFDS
   generic map (
      DIFF_TERM => FALSE, -- Differential Termination 
      IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD => "DEFAULT")
   port map (
      O => O,  -- Buffer output
      I => I,  -- Diff_p buffer input (connect directly to top-level port)
      IB => IB -- Diff_n buffer input (connect directly to top-level port)
   );

-- End of IBUFDS_inst instantiation