  transcript off
  vcom spi_master7.vhd
  vcom spi_master7_tb.vhd
  
  vsim spi_master7_tb
  add wave sim:/spi_master7_tb/uut/*
  
  run 40000 ns