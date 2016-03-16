# 
# Main file that encompasses all subroutines and launches the program
#
#
#

############################# DEFINES ##############################
.equ LED_BASE, 0xFF200000 
# data at base
.equ PUSH_BUTTON_BASE, 0xFF200050
# 8 interrupt mask
# 12 edge capture 

.equ TIMER_BASE, 0xFF202000  # status i.e. timeout
# 4 control (interrupt, continue, )
.equ TICKS,	100000000		# 1/60 seconds

.equ PS2_BASE, 0xFF200100 # mouse / keyboard; using MOUSE in this application

.equ IRQ_PERIPHERAL, 0b10000011 # enabling irq 7, 1, 0
.equ irq0, 0b1			#interval timer 1
.equ irq1, 0b10			#buttons
.equ irq7, 0b10000000	#ps2 mouse



###################################################################
#						interrupt exceptions					  #
###################################################################
           .section .exceptions, "ax"
myISR:
	# save registers
	subi	sp, sp, 20
	stw	et, 0(sp)
	rdctl	et, estatus
	stw	et, 4(sp)
	stw	ea, 8(sp)	
	stw	ra, 12(sp)
	stw	r4, 16(sp)
	
	# decipher whose interrupt is asserted in priority order
	rdctl et, ipending
	andi et, et, irq7
	bne et, zero, serve_mouse	
	
	rdctl et, ipending
	andi et, et, irq0
	bne et, zero, serve_timer
	
	rdctl et, ipending
	andi et, et, irq1 	
	bne et, zero, serve_buttons

ISR_exit:
	# restore registers
	wrctl status, zero	#disable interrupts while restoring
	ldw	r4, 16(sp)
	ldw	ra, 12(sp)
	ldw	ea, 8(sp)
	ldw	et, 4(sp)
	wrctl	estatus, et
	ldw	et, (sp)		# restored status
		
	addi	sp, sp, 20
	subi	ea, ea, 4
	eret

# serve interrupts with subroutines
serve_mouse:			# HIGHEST priority
	call _MOUSE
	br ISR_exit
	
serve_timer: 
	call _TIMER
	br ISR_exit
		
serve_buttons:
	call _PUSHBUTTONS
	br ISR_exit

serve_g_timer:
	# call _GRAPHICS
	br ISR_exit
###################################################################


###################################################################
#																  #
#																  #
# 							MAIN								  #
#																  #
#																  #
###################################################################
.section .text
.global _start

_start: # main program

	# initialize stack pointer
	movia sp, 0x03FFFFFC

	# initialize TIMER
	movia	r8, TIMER_BASE
	movui	r9, %lo(TICKS)
	stwio	r9, 8(r8)	# low value
	movui	r9, %hi(TICKS)
	stwio	r9, 12(r8)	# high value
	
	movui r9, 0b111		# enable start, continue, and interrupt
	stwio r9, 4(r8)  	# write to control
	stwio	r0, (r8)	# reset timer
	
	# initialize MOUSE
	movia r8, PS2_BASE
	movi r9, 1
	stwio r9, 4(r8) 	# enable device interrupt
	
	# enable interrupts for external interrupts and PIE
	movui r8, 0x1
	wrctl status, r8 	# PIE
	movui r8, IRQ_PERIPHERAL
	wrctl ienable, r8
	
	# enable push buttons
	movia r8, PUSH_BUTTON_BASE
	movui r9, 0x1 		# just button 0; change to F for all four buttons
	stwio r9, 8(r8) 	# set interrupt masking
	
	
	
	
	
loop:


	br loop
########################## end of main	##############################
######################################################################
	

######################################################################	
################# interrupt service subroutines ######################	

_MOUSE:
	# save register
	subi sp,sp, 4
	stw r8, 0(sp)
	
	# just store the buffer
	# read 
		
	# restore registers
	ldw r8, 0(sp)
	addi sp,sp, 4
	
	ret
######################################################################	
_TIMER:
	# save registers to be used in this subroutine
	subi sp, sp, 8
	stw r16, 4(sp)
	stw r17, 0(sp)
	
	movia r16, TIMER_BASE
	stwio zero, 0(r16) # reset timeout
	
	# a reference to tell if the timer was working
	movia r16, LED_BASE
	ldwio r17, 0(r16)
	addi r17, r17, 1
	stwio r17, 0(r16)
	
	
	# do something to VGA buffers and send signal
	
	
	# restore registers
	ldw r17, 0(sp)
	ldw r16, 4(sp)
	addi sp, sp, 8
	
	
	ret
######################################################################	
	
_PUSHBUTTONS:
	# save registers to be used in this subroutine
	subi sp, sp, 12
	stw r16, 8(sp)
	stw r17, 4(sp)
	stw r18, 0(sp)
	
	movia r16, PUSH_BUTTON_BASE	# make pointer
	ldwio r17, 12(r16) 			# load the edge capture register
	
	andi r18, r17, 0x1 			# check for button 1
	bne r18, r0, button_1

	andi r18, r17, 0x2			# check for button 2
	bne r18, r0, button_2
	
# serve one button at a time
button_1: 		# do stuff
	# for confirmation turn all LED lights ON
	movia r17, LED_BASE
	movui r18, 0x3FF # 11 1111 1111
	stwio r18, 0(r17)
	br button_exit
button_2:		# do stuff
	br button_exit
	
button_exit:
	# deassert interrupt and reset edge capture
	stwio r0, 12(r16) 	# by writing 0 (writing anything should clear off the register)

	# restore registers
	ldw r18, 0(sp)
	ldw r17, 4(sp)
	ldw r16, 8(sp)
	addi sp, sp, 12
	ret
######################################################################


	
_GRAPHICS:
	
	ret

# save RA
# call save_registers
# pop RA
#save return address before executing

save_registers:
	# stacking
	ret
	