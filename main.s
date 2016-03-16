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

.equ PS2_BASE, 0xFF200100

.equ IRQ_PERIPHERAL, 0b10000011 # irq 7, 1, 0
.equ irq0, 0b1
.equ irq1, 0b10
.equ irq7, 0b10000000

.equ PIXEL_BUFFER_BASE, 0x08000000
.equ CHAR_BUFFER_BASE, 0x09000000


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
	
	# priority service
	rdctl et, ipending
	andi et, et, irq7
	bne et, zero, serve_MOUSE	
	
	rdctl et, ipending
	andi et, et, irq0
	bne et, zero, serve_timer
	
	rdctl et, ipending
	andi et, et, irq2
	bne et, zero, serve_g_timer
	
ISR_exit:
	wrctl	status, zero	#disable interrupts while restoring
	ldw	r4, 16(sp)
	ldw	ra, 12(sp)
	ldw	ea, 8(sp)
	ldw	et, 4(sp)
	wrctl	estatus, et
	ldw	et, (sp)
		
	addi	sp, sp, 20
	subi	ea, ea, 4
	eret

# serve interrupts with subroutines
serve_MOUSE:# HIGHEST priority
	call _MOUSE
	br ISR_exit
	
serve_timer: 
	call _TIMER
	br ISR_exit
		
 serve_g_timer:
	# call _GRAPHICS
	br ISR_exit
	
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
	wrctl status, r8 		# PIE
	movui r8, IRQ_PERIPHERAL
	wrctl ienable, r8
	
	# enable push buttons
	movia r8, PUSH_BUTTON_BASE
	movui r9, 0xF 	
	stwio r9, 8(r8) # 1111 all four buttons
	
	
	
	
	
loop:


	br loop


	
	
	##############################################

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
	
_TIMER:
	subi sp, sp, 8
	stw r16, 4(sp)
	stw r17, 0(sp)
	
	movia r16, TIMER_BASE
	stwio zero, 0(r16) # reset timeout
	
	movia r16, LED_BASE
	ldwio r17, 0(r16)
	addi r17, r17, 1
	stwio r17, 0(r16)
	
	
	
	ldw r17, 0(sp)
	ldw r16, 4(sp)
	addi sp, sp, 8
	
	# do something to VGA
	ret
_GRAPHICS:
	
	ret

	



	

# save RA
# call save_registers
# pop RA
#save return address before executing

save_registers:
	# stacking
	ret
	