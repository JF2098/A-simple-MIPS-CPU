onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+axi_clock_converter -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.axi_clock_converter xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {axi_clock_converter.udo}

run -all

endsim

quit -force
