## Clock signal 125 MHz
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];


set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { rst }]; #IO_L19N_T3_VREF_35 Sch=sw[0]


set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { btn[0] }]; #IO_L12N_T1_MRCC_35 Sch=btn[0]
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { btn[1] }]; #IO_L24N_T3_34 Sch=btn[1]
set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports { btn[2] }]; #IO_L10P_T1_AD11P_35 Sch=btn[2]
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { btn[3] }]; #IO_L7P_T1_34 Sch=btn[3]

	
#set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { lrclk }]; #IO_L24P_T3_34 Sch=sw[1]
#set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { sw[2] }]; #IO_L4N_T0_34 Sch=sw[2]
#set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { sw[3] }]; #IO_L9P_T1_DQS_34 Sch=sw[3]


set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { bclk }]; 
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { mclk }]; 
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { sdata }]; 
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { lrclk }]; 
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { mute }]; 



