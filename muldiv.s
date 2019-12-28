#----------------------------------------------------------------
# 
#  4190.308 Computer Architecture (Fall 2019)
#
#  Project #3: RISC-V Assembly Programming
#
#  October 29, 2019
#
#  Jin-Soo Kim (jinsoo.kim@snu.ac.kr)
#  Systems Software & Architecture Laboratory
#  Dept. of Computer Science and Engineering
#  Seoul National University
#
#----------------------------------------------------------------


	.text
	.align	2

#----------------------------------------------------------------
#   int mul(int a, int b)
#----------------------------------------------------------------
    .globl  mul
mul:
	li a5, 1	# a5 = 자릿수
	li a2, 0	# a2 = i = 0
	li a4, 0	# a4 = temporary return value
	li a3, 32
loop:	#inside for loop
	and a3, a1, a5	# a3 = b & (1 << i)
	bne a3, a5, NO_ADDITION	# b & (1 << i) == 0 이면 덧셈 실행하지 않음
	add a4, a4, a0 # x += (a * (1 << i))
NO_ADDITION: 
	slli a5, a5, 1	# 자릿수 한칸 이동
	slli a0, a0, 1	# a <<= 1
	li a3, 32
	addi a2, a2, 1	# i++
	blt a2, a3, loop # if i < 32 goto loop
	#after for loop, return
	mv a0, a4
	ret

#----------------------------------------------------------------
#   int mulh(int a, int b)
#----------------------------------------------------------------
    .globl  mulh
mulh:
	li a3, 0x80000000
	bne a3, a0, not_minA
	bne a3, a1, only_minA
	srli a0, a0, 1
	ret
only_minA:
	sub a0, x0, a1	# a == -2^31일때
	srai a0, a0, 1
	ret
not_minA:
	bne a3, a1, not_minAB
	sub a0, x0, a0	# b == -2^31일때
	srai a0, a0, 1
	ret
not_minAB:
	addi sp, sp, -36
	slti a2, a0, 0	# a2 = (a0 < 0) ? 1 : 0
	slti a3, a1, 0	# a3 = (a1 < 0) ? 1 : 0
	beq a2, x0, posA	
	sub a0, x0, a0	#a를 양수로 
posA:	# a is positive from here
	beq a3, x0, posAB
	sub a1, x0, a1	#b를 양수로
posAB:	# a, b is positive from here
	add a5, a2, a3
	sw a5, 32(sp)
	srli a2, a0, 16 # a2 = a_hi
	slli a4, a2, 16
	sub a4, a0, a4	# a4 = a_lo 
	srli a3, a1, 16  # a3 = b_hi
	slli a5, a3, 16
	sub a5, a1, a5	#a5 = b_lo
	sw a2, 28(sp)
	sw a3, 24(sp)
	sw a4, 20(sp)
	sw a5, 16(sp)
	#mul a0, a2, a3	#x_hihi = a_hi * b_hi
	li a1, 1	# a1 = 자릿수
	li a5, 0	# s5 = i = 0
	li a0, 0	# a0 = return value
loop_hihi:	#inside for loop
	and a4, a3, a1	# s2 = a3 & (1 << i)
	bne a4, a1, NO_ADDITION_hihi	# b & (1 << i) == 0 이면 덧셈 실행하지 않음
	add a0, a0, a2 # x += (a * (1 << i))
NO_ADDITION_hihi: 
	slli a1, a1, 1	# 자릿수 한칸 이동
	slli a2, a2, 1	# a <<= 1
	addi a5, a5, 1	# i++
	li a4, 16
	blt a5, a4, loop_hihi # if i < 16 goto loop
	sw a0, 12(sp)
	#mul a2, a3, a4	#x_hilo
	lw a3, 24(sp)
	lw a4, 20(sp)
	li a1, 1	# a1 = 자릿수
	li a5, 0	# a5 = i = 0
	li a2, 0	# a2 = return value
loop_hilo:	#inside for loop
	and a0, a4, a1	# a0 = a4 & (1 << i)
	bne a0, a1, NO_ADDITION_hilo	# b & (1 << i) == 0 이면 덧셈 실행하지 않음
	add a2, a2, a3 # x += (a * (1 << i))
NO_ADDITION_hilo: 
	slli a1, a1, 1	# 자릿수 한칸 이동
	slli a3, a3, 1	# a <<= 1
	addi a5, a5, 1	# i++
	li a0, 16
	blt a5, a0, loop_hilo # if i < 16 goto loop
	sw a2, 8(sp)
	#mul	a3, a2, a5	#x_lohi
	lw a2, 28(sp)
	lw a5, 16(sp)
	li a1, 1	# a1 = 자릿수
	li a4, 0	# a4 = i = 0
	li a3, 0	# a3 = return value
loop_lohi:	#inside for loop
	and a0, a5, a1	# a0 = a5 & (1 << i)
	bne a0, a1, NO_ADDITION_lohi	# b & (1 << i) == 0 이면 덧셈 실행하지 않음
	add a3, a3, a2 # x += (a * (1 << i))
NO_ADDITION_lohi: 
	slli a1, a1, 1	# 자릿수 한칸 이동
	slli a2, a2, 1	# a <<= 1
	addi a4, a4, 1	# i++
	li a0, 16
	blt a4, a0, loop_lohi	# if i < 16 goto loop
	sw a3, 4(sp)
	#mul a3, a4, a5	#x_lolo
	lw a4, 20(sp)
	lw a5, 16(sp)
	li a1, 1	# a1 = 자릿수
	li a2, 0	# a2 = i = 0
	li a3, 0	# a3 = return value
loop_lolo:	#inside for loop
	and a0, a5, a1	# s6 = a5 & (1 << i)
	bne a0, a1, NO_ADDITION_lolo	# b & (1 << i) == 0 이면 덧셈 실행하지 않음
	add a3, a3, a4 # x += (a * (1 << i))
NO_ADDITION_lolo: 
	slli a1, a1, 1	# 자릿수 한칸 이동
	slli a4, a4, 1	# a <<= 1
	addi a2, a2, 1	# i++
	li a0, 16
	blt a2, a0, loop_lolo # if i < 16 goto loop
	lw a0, 8(sp)	#hilo
	lw a1, 4(sp)	#lohi
	srli a4, a0, 16
	srli a5, a1, 16
	slli a4, a4, 16
	slli a5, a5, 16
	sub a5, a1, a5	# lohi for carry
	sub a4, a0, a4	# hilo for carry
	srli a2, a3, 16
	add a2, a2, a5
	add a2, a2, a4
	srli a4, a2, 16	# a4 = carry
	sub a2, a2, a4	# a2 = lower32bits - (carry << 16)
	lw a3, 12(sp)	#hihi
	srli a0, a0, 16
	srli a1, a1, 16
	add a0, a0, a1
	add a0, a0, a4
	add a0, a0, a3
	lw a5, 32(sp)
	andi a5, a5, 1
	beq a5, x0, pos_case
	sub a0, x0, a0
	beq a2, x0, pos_case
	addi a0, a0, -1
pos_case:
    addi    sp, sp, 36          # restore the stack pointer
	ret

#----------------------------------------------------------------
#   int div(int a, int b)
#----------------------------------------------------------------
    .globl  div
div:
	bne a1, x0, division_by_zero_pass_div
	li a0, -1	#division_by_zero
	ret
division_by_zero_pass_div:
	li a2, 0x80000000
	li a5, 0
	bne a0, a2, overflow_pass_div #if dividend != -2^31, no overflow
	li a3, -1
	bne a1, a3, minA_not_overflow #if divisor != -1, no overflow
	ret
minA_not_overflow:	#minA
	bne a1, a2, not_min_ab_div
	li a0, 1	#minA, minB
	ret
not_min_ab_div:	#minA, not minB
	li a5, 1
	li a0, 0x80000001
overflow_pass_div:	#not minA
	bne a1, a2, min_b_pass_div	
	li a0, 0	# not minA, minB -> div = 0
	ret
min_b_pass_div:	#not minA, not minB
	addi sp, sp, -12
	sw a5, 8(sp)	#dividend = -2^31, not overflow
	slt a4, a0, x0	# a4 = (a0 < 0) ? 1 : 0
	slt a5, a1, x0	# a5 = (a1 < 0) ? 1 : 0
	add a5, a4, a5	# a5 += a4
	andi a5, a5, 1	# a5 = a5 % 1
	sw a5, 4(sp)
	bge a0, x0, posA_div
	sub a0, x0, a0	#positive a
posA_div:
	bge a1, x0, posAB_div
	sub a1, x0, a1	#positive b
posAB_div:
	li a2, 0	#i = 0
	li a3, 33	#총 반복 횟수
	li a4, 0	#r,q: a4/a0
loop_div:
	li a5, 0
	blt a4, a1, after_subtract # if rem >= q, subtraction
	li a5, 1
	sub a4, a4, a1	# r-= d
after_subtract:
	slli a4, a4, 1
	bge a0, x0, q_hi_added_div	#q_hi = msb of a
	addi a4, a4, 1
q_hi_added_div:
	slli a0, a0, 1	#rem, q 한칸씩 왼쪽으로 shift
	add a0, a0, a5
	addi a2, a2, 1	# i++
	blt a2, a3, loop_div
	lw a5, 8(sp)	#minA case
	beq a5, x0, minA_case_done_div
	srai a4, a4, 1
	addi a4, a4, 1	
	bne a1, a4, minA_case_done_div
	addi a0, a0, 1
minA_case_done_div:
	lw a5, 4(sp)
	beq a5, x0, pos_case_div
	sub a0, x0, a0
pos_case_div:
	addi sp, sp, 12
	ret

#----------------------------------------------------------------
#   int rem(int a, int b)
#----------------------------------------------------------------
    .globl  rem
rem:
	bne a1, x0, division_by_zero_pass_rem	#division_by_zero
	ret
division_by_zero_pass_rem:
	li a2, 0x80000000
	li a5, 0
	bne a0, a2, overflow_pass_rem #if dividend != -2^31, no overflow
	li a3, -1
	bne a1, a3, minA_not_overflow_rem #if divisor != -1, no overflow
	li a0, 0
	ret
minA_not_overflow_rem:
	bne a1, a2, not_min_ab_rem
	li a0, 0	#minA, minB
	ret
not_min_ab_rem:	#minA, not minB
	li a0, 0x80000001
	li a5, 1
overflow_pass_rem:	#not minA
	bne a1, a2, min_b_pass_rem
	ret	#if not minA and minB
min_b_pass_rem:
	addi sp, sp, -12
	sw a5, 8(sp)
	slt a4, a0, x0
	sw a4, 4(sp)
	bge a0, x0, posA_rem
	sub a0, x0, a0
posA_rem:
	bge a1, x0, posAB_rem
	sub a1, x0, a1
posAB_rem:
	li a2, 0	#i = 0
	li a3, 33	#총 반복 횟수
	li a4, 0	#r,q: a4/a0
loop_rem:
	li a5, 0
	blt a4, a1, after_subtract_rem # if rem >= q, subtraction
	li a5, 1
	sub a4, a4, a1	# r-= d
after_subtract_rem:
	slli a4, a4, 1
	bge a0, x0, q_hi_added_rem
	addi a4, a4, 1
q_hi_added_rem:
	slli a0, a0, 1	#rem, q 한칸씩 왼쪽으로 shift
	add a0, a0, a5
	addi a2, a2, 1	# i++
	blt a2, a3, loop_rem
	srai a0, a4, 1
	lw a5, 8(sp)	#minA case
	add a0, a0, a5
	bne a0, a1, minA_case_done_rem
	li a0, 0
minA_case_done_rem:
	lw a4, 4(sp)
	beq a4, x0, pos_case_rem
	sub a0, x0, a0
pos_case_rem:
	addi sp, sp, 12
	ret

