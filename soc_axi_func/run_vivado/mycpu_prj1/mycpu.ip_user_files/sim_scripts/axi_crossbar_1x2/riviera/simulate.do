onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+axi_crossbar_1x2 -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.axi_crossbar_1x2 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {axi_crossbar_1x2.udo}

run -all

endsim

quit -force
