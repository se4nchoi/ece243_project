# file which contains the associated subroutines and set ups
# to update the character/pixel buffer and send enable for 
# the VGA to display on the screen

############################# DEFINES ##############################
.equ PIXEL_BUFFER_BASE, 0x08000000
.equ CHAR_BUFFER_BASE, 0x09000000



###################################################################
#						MAIN SUBROUTINE							  #
###################################################################
.section .text
.global _VGA 		# make this subroutine available for main.s

_VGA:
	


	
	
	ret # return to TIMER interrupt handler (most likely)