
.macro  adr_load reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
.endm

.macro  adr_blrl reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtlr \reg
blrl
.endm

.macro  word_load reg1, reg2, address
lis \reg2, \address @ha
lwz \reg1,\address @l (\reg2)
.endm

.macro  word_store reg1, reg2, address
lis \reg2, \address @ha
stw \reg1,\address @l (\reg2)
.endm

.macro  byte_store reg1, reg2, address
lis \reg2, \address @ha
stb \reg1,\address @l (\reg2)
.endm

.set Buttons.HeldAll, 0x80479cf4
.set HSD_PadReset, 0x804C1FA3
.set MemoryCard.Insertion, 0x80433320

.set MnSlChr.20XXDefaults, 0x3e2010	# location in MnSlChr.usd
.set MnSlChr.RAMoffset, 0x80bec720
.set MnSlChr.20XXDefaults_RAM, MnSlChr.20XXDefaults + MnSlChr.RAMoffset


.set Defaults.DebugMenu_start, 0x370	# start of debug menu within the flags (ignore this)
.set DebugMenu.Length, 0x35c # includes a little extra
.set Defaults.TotalFlagLength, 0x1aec

.set Defaults.FlagsFirstSet, Defaults.DebugMenu_start
.set Defaults.FlagsSecondSet, Defaults.TotalFlagLength - Defaults.DebugMenu_start - DebugMenu.Length
.set Defaults.FlagsSecondSetStart, MnSlChr.20XXDefaults_RAM + Defaults.DebugMenu_start + DebugMenu.Length

.set RAM.20XXFlags, 0x803fa174
.set RAM.20XXFlagsSecond, RAM.20XXFlags + Defaults.DebugMenu_start + DebugMenu.Length

.set memcpy, 0x800031f4

START:
bl COUNTER
mflr r4
lwz r5,0(r4)	# load counter
word_load r3,r3,Buttons.HeldAll
andi. r3,r3,0x500	# X+A
cmpwi r3,0x500
bne- ZERO
addi r5,r5,1
b COUNTER_STORE
ZERO:
li r5,0
COUNTER_STORE:
stw r5,0(r4)

RESET_20XX:
cmpwi r5,180	# 3 seconds
blt- RESET_20XX_END
li r5,0
stw r5,0(r4)	# reset counter
li r5,1	# reset the game
byte_store r5,r4,HSD_PadReset
li r5,4	# disable memory card saving
word_store r5,r4,MemoryCard.Insertion

# restore 20XX default flag values, located in MnSlChr.usd
# first set of flags
adr_load r3, RAM.20XXFlags # target?
adr_load r4, MnSlChr.20XXDefaults_RAM # source?
li r5,Defaults.DebugMenu_start	# amount? copy bytes up to Debug Menu start
adr_blrl r12,memcpy

# second set of flags
adr_load r3, RAM.20XXFlagsSecond
adr_load r4, Defaults.FlagsSecondSetStart
li r5,Defaults.FlagsSecondSet	# copy rest of bytes
adr_blrl r12,memcpy

RESET_20XX_END:
b END
COUNTER:	# portable counter
blrl
.long 0x00000000

END:
lwz r0,0x1c(sp)