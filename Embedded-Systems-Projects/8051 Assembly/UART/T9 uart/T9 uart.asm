ds1 equ 30h
ds2 equ 31h
ds3 equ 32h
ds4 equ 33h

dcount1 equ 34h
dcount2 equ 35h
dcount3 equ 36h

count equ 37h
scan_no equ 38h
dcount equ 39h
krcount equ 40h
key_code equ 41h

tx_data equ 42h
rx_data equ 43h

top_of_stack equ 60h

sl1 bit p2.0
sl2 bit p2.1
sl3 bit p2.2
sl4 bit p2.3

krl1 bit p2.4
krl2 bit p2.5
krl3 bit p2.6
krl4 bit p2.7

key_ready bit 00h
nkp bit 01h
tb bit 02h
start_buzzer bit 03h


org 0000h
jmp main

org 0003h
reti 

org 000bh
ljmp isr_t0

org 0013h
reti

org 001bh
reti

org 0023h
reti

org 002bh
reti



main:

call init_uart
call clr_screen



mov sp,#top_of_stack
call init
setb ea
//call test_display

//mov ds1,#"9"+2
//mov ds2,#"9"+1
//mov ds3,#"9"+1
//mov ds4,#"9"+1

l1_main:

jnb key_ready,$
mov a,key_code

mov dptr,#ascii_tab
movc a,@a+dptr
mov ds1,a
call key_release

call tx_disp

jmp l1_main

ascii_tab:
db "0123456789ABCDEF"

init:

//call init_display
call init_keypad
call init_timer0
ret

/*init_display:

mov ds1,#"9"+2
mov ds2,#"9"+2
mov ds3,#"9"+2
mov ds4,#"9"+2
ret
*/

init_keypad:

setb krl1
setb krl2
setb krl3
setb krl4
mov scan_no,#00d
mov dcount,#33d
mov krcount,#32d
clr key_ready
clr nkp
clr start_buzzer
ret

init_timer0:

orl tmod,#01h
mov tl0,#66h
mov th0,#0fch
setb tr0
setb et0
ret


isr_t0:

push acc
push psw
push dph
push dpl

call init_timer0
call buzzer
call scanner

out_isr:

pop dpl
pop dph
pop psw
pop acc
reti


scanner:

mov a,scan_no


zero:

cjne a,#00d,one


clr sl1
setb sl2
setb sl3
setb sl4

//call adisp1

mov c,krl1
call k

mov scan_no,#01d
ajmp out_scanner


one:

cjne a,#01d,two

mov c,krl2
call k

mov scan_no,#02d
ajmp out_scanner


two:

cjne a,#02d,three

mov c,krl3
call k

mov scan_no,#03d
ajmp out_scanner


three:

cjne a,#03d,four

//call disp_blank

mov c,krl4
call k

mov scan_no,#04d
ajmp out_scanner


four:

cjne a,#04d,five


setb sl1
clr sl2
setb sl3
setb sl4

//call adisp2

mov c,krl1
call k

mov scan_no,#05d
ajmp out_scanner


five:

cjne a,#05d,six

mov c,krl2
call k

mov scan_no,#06d
ajmp out_scanner


six:

cjne a,#06d,seven

mov c,krl3
call k

mov scan_no,#07d
ajmp out_scanner


seven:

cjne a,#07d,eight

//call disp_blank

mov c,krl4
call k


mov scan_no,#08d
ajmp out_scanner


eight:

cjne a,#08d,nine


setb sl1
setb sl2
clr sl3
setb sl4

//call adisp3

mov c,krl1
call k


mov scan_no,#09d
ajmp out_scanner


nine:

cjne a,#09d,ten

mov c,krl2
call k


mov scan_no,#10d
ajmp out_scanner


ten:

cjne a,#10d,eleven

mov c,krl3
call k


mov scan_no,#11d
ajmp out_scanner


eleven:

cjne a,#11d,twelve

//call disp_blank

mov c,krl4
call k


mov scan_no,#12d
ajmp out_scanner


twelve:

cjne a,#12d,thirteen


setb sl1
setb sl2
setb sl3
clr sl4

//call adisp4

mov c,krl1
call k


mov scan_no,#13d
ajmp out_scanner


thirteen:

cjne a,#13d,fourteen

mov c,krl2
call k


mov scan_no,#14d
ajmp out_scanner


fourteen:

cjne a,#14d,fifteen

mov c,krl3
call k


mov scan_no,#15d
ajmp out_scanner


fifteen:

cjne a,#15d,dummy

//call disp_blank

mov c,krl4
call k



dummy:

mov scan_no,#00d
ajmp out_scanner

out_scanner:

ret

k:

jb key_ready,out_debounce

mov tb,c
mov a,dcount
cjne a,#33d,debounce
mov c,tb
jc out_k

dec dcount
mov key_code,scan_no
jmp out_k

debounce:

djnz dcount,out_k

mov c,tb
jc spurious_key
mov dcount,#33d
setb key_ready
setb start_buzzer
jmp out_k

spurious_key:

mov dcount,#33d
jmp out_k

out_debounce:

jc l1_k
mov krcount,#32d
jmp out_k

l1_k:

djnz krcount,out_k
setb nkp
clr start_buzzer
mov krcount,#32d
jmp out_k


out_k:
ret


wait_1sec:

mov dcount3,#02h
L2: mov dcount2,#0ffh
L1: mov dcount1,#0ffh
djnz dcount1,$
djnz dcount2,L1
djnz dcount3,L2
ret

key_release:
jnb nkp,$
clr key_ready
clr nkp
ret

buzzer:

jnb start_buzzer,out_b
cpl p1.5

out_b:

ret

// Uart

tx_disp:

call home_screen

mov tx_data,ds1
call tx
call uart_delay
 
ret



init_uart:


orl tmod,#20h
mov th1,#0FDh	 
setb tr1
mov scon,#52h

ret

clr_screen:

mov tx_data,#1bh
call tx
call uart_delay

mov tx_data,#"["
call tx
call uart_delay

mov tx_data,#"2"
call tx
call uart_delay

mov tx_data,#"J"
call tx
call uart_delay

ret

home_screen:

mov tx_data,#1bh
call tx
call uart_delay

mov tx_data,#"["
call tx
call uart_delay

mov tx_data,#"H"
call tx
call uart_delay

ret

tx:
jnb ti,$
mov sbuf,tx_data
clr ti
ret


uart_delay:

mov dcount3,#02h
K2: mov dcount2,#3fh
K1: mov dcount1,#0ffh
djnz dcount1,$
djnz dcount2,K1
djnz dcount3,K2
ret




end