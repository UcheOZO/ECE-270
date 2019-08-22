
########## Tcl recorder starts at 04/16/19 17:04:26 ##########

set version "1.7"
set proj_dir "U:/Desktop/LAB13"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:04:26 ###########


########## Tcl recorder starts at 04/16/19 17:05:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:05:53 ###########


########## Tcl recorder starts at 04/16/19 17:05:59 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:05:59 ###########


########## Tcl recorder starts at 04/16/19 17:15:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:15:05 ###########


########## Tcl recorder starts at 04/16/19 17:28:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:28:09 ###########


########## Tcl recorder starts at 04/16/19 17:28:17 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:28:17 ###########


########## Tcl recorder starts at 04/16/19 17:32:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:32:05 ###########


########## Tcl recorder starts at 04/16/19 17:32:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:32:12 ###########


########## Tcl recorder starts at 04/16/19 17:32:24 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:32:24 ###########


########## Tcl recorder starts at 04/16/19 17:36:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:36:25 ###########


########## Tcl recorder starts at 04/16/19 17:36:29 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:36:29 ###########


########## Tcl recorder starts at 04/16/19 17:39:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:39:47 ###########


########## Tcl recorder starts at 04/16/19 17:39:51 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:39:51 ###########


########## Tcl recorder starts at 04/16/19 17:40:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:40:22 ###########


########## Tcl recorder starts at 04/16/19 17:47:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:47:17 ###########


########## Tcl recorder starts at 04/16/19 17:47:23 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:47:23 ###########


########## Tcl recorder starts at 04/16/19 17:57:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 17:57:46 ###########


########## Tcl recorder starts at 04/16/19 18:40:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:40:45 ###########


########## Tcl recorder starts at 04/16/19 18:40:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:40:50 ###########


########## Tcl recorder starts at 04/16/19 18:40:54 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:40:54 ###########


########## Tcl recorder starts at 04/16/19 18:41:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:41:40 ###########


########## Tcl recorder starts at 04/16/19 18:41:44 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:41:44 ###########


########## Tcl recorder starts at 04/16/19 18:43:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:43:04 ###########


########## Tcl recorder starts at 04/16/19 18:43:08 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:43:08 ###########


########## Tcl recorder starts at 04/16/19 18:43:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:43:32 ###########


########## Tcl recorder starts at 04/16/19 18:43:37 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:43:37 ###########


########## Tcl recorder starts at 04/16/19 18:43:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:43:59 ###########


########## Tcl recorder starts at 04/16/19 18:44:03 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:44:03 ###########


########## Tcl recorder starts at 04/16/19 18:47:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:47:53 ###########


########## Tcl recorder starts at 04/16/19 18:48:00 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:48:00 ###########


########## Tcl recorder starts at 04/16/19 18:50:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:50:31 ###########


########## Tcl recorder starts at 04/16/19 18:50:34 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:50:34 ###########


########## Tcl recorder starts at 04/16/19 18:51:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:51:52 ###########


########## Tcl recorder starts at 04/16/19 18:51:56 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:51:56 ###########


########## Tcl recorder starts at 04/16/19 18:53:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:53:51 ###########


########## Tcl recorder starts at 04/16/19 18:53:54 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:53:54 ###########


########## Tcl recorder starts at 04/16/19 18:58:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:58:41 ###########


########## Tcl recorder starts at 04/16/19 18:58:45 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 18:58:46 ###########


########## Tcl recorder starts at 04/16/19 19:00:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:00:50 ###########


########## Tcl recorder starts at 04/16/19 19:00:53 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:00:53 ###########


########## Tcl recorder starts at 04/16/19 19:01:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:01:08 ###########


########## Tcl recorder starts at 04/16/19 19:01:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:01:12 ###########


########## Tcl recorder starts at 04/16/19 19:02:33 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:02:33 ###########


########## Tcl recorder starts at 04/16/19 19:03:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:03:05 ###########


########## Tcl recorder starts at 04/16/19 19:03:08 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:03:08 ###########


########## Tcl recorder starts at 04/16/19 19:05:43 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:05:43 ###########


########## Tcl recorder starts at 04/16/19 19:06:17 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:06:17 ###########


########## Tcl recorder starts at 04/16/19 19:09:18 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:09:18 ###########


########## Tcl recorder starts at 04/16/19 19:09:55 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:09:55 ###########


########## Tcl recorder starts at 04/16/19 19:12:13 ##########

# Commands to make the Process: 
# Optimization Constraint
# - none -
# Application to view the Process: 
# Optimization Constraint
if [catch {open opt_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file opt_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-global -lci lab13.lct -touch lab13.imp
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/optedit\" @opt_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:12:13 ###########


########## Tcl recorder starts at 04/16/19 19:12:34 ##########

# Commands to make the Process: 
# JEDEC File
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:12:34 ###########


########## Tcl recorder starts at 04/16/19 19:33:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:33:48 ###########


########## Tcl recorder starts at 04/16/19 19:34:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:34:37 ###########


########## Tcl recorder starts at 04/16/19 19:57:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:57:46 ###########


########## Tcl recorder starts at 04/16/19 19:58:45 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 19:58:45 ###########


########## Tcl recorder starts at 04/16/19 20:51:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 20:51:00 ###########


########## Tcl recorder starts at 04/16/19 20:51:09 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 20:51:09 ###########


########## Tcl recorder starts at 04/16/19 21:34:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" uozor_lab13.v -p \"$install_dir/ispcpld/generic\" -predefine lab13.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 21:34:03 ###########


########## Tcl recorder starts at 04/16/19 21:34:07 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/16/19 21:34:07 ###########


########## Tcl recorder starts at 04/18/19 06:49:48 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab13_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab13_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab13.sty
PROJECT: lab13_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab13_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab13.h uozor_lab13.v
OUTPUT_FILE_NAME: lab13_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab13_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab13_top.edi -out lab13_top.bl0 -err automake.err -log lab13_top.log -prj lab13 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab13_top.bl1\" -o \"lab13.bl2\" -omod \"lab13\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab13 -lci lab13.lct -log lab13.imp -err automake.err -tti lab13.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -blifopt lab13.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab13.bl2 -sweep -mergefb -err automake.err -o lab13.bl3 @lab13.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -diofft lab13.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab13.bl3 -family AMDMACH -idev van -o lab13.bl4 -oxrf lab13.xrf -err automake.err @lab13.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab13.lct -dev lc4k -prefit lab13.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab13.bl4 -out lab13.bl5 -err automake.err -log lab13.log -mod lab13_top @lab13.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab13.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs1: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -nojed -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab13.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab13.rs2: $rspFile"
} else {
	puts $rspFile "-i lab13.bl5 -lci lab13.lct -d m4e_256_96 -lco lab13.lco -html_rpt -fti lab13.fti -fmt PLA -tto lab13.tt4 -eqn lab13.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab13.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab13.rs1
file delete lab13.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab13.bl5 -o lab13.tda -lci lab13.lct -dev m4e_256_96 -family lc4k -mod lab13_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab13 -if lab13.jed -j2s -log lab13.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/18/19 06:49:48 ###########

