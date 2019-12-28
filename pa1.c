//---------------------------------------------------------------
//
//  4190.308 Computer Architecture (Fall 2019)
//
//  Project #1: 64-bit Integer Arithmetic using 32-bit Operations
//
//  September 9, 2019
//
//  Jin-Soo Kim (jinsoo.kim@snu.ac.kr)
//  Systems Software & Architecture Laboratory
//  Dept. of Computer Science and Engineering
//  Seoul National University
//
//---------------------------------------------------------------

#include <stdio.h>
#include "pa1.h"


// NOTE!!!!!
// You should use only 32-bit integer operations inside Uadd64(), Usub64(), 
// Umul64(), and Udiv64() functions. 


// Uadd64() implements the addition of two 64-bit unsigned integers.
// Assume that A and B are the 64-bit unsigned integer represented by
// a and b, respectively. Uadd64() should return x, where x.hi and x.lo 
// contain the upper and lower 32 bits of (A + B), respectively.

HL64 Uadd64 (HL64 a, HL64 b)
{
	HL64 	x;

	x.lo = a.lo + b.lo;
	x.hi = (a.lo > x.lo) ? a.hi + b.hi + 1: a.hi + b.hi;
	return x;
}

// Usub64() implements the subtraction between two 64-bit unsigned integers.
// Assume that A and B are the 64-bit unsigned integer represented by
// a and b, respectively. Usub64() should return x, where x.hi and x.lo 
// contain the upper and lower 32 bits of (A - B), respectively.


HL64 Usub64 (HL64 a, HL64 b)
{
	HL64 	x;

    x.lo = a.lo - b.lo;
	x.hi = (a.lo < b.lo) ? a.hi - b.hi - 1 : a.hi - b.hi;
	return x;
}


// Umul64() implements the multiplication of two 64-bit unsigned integers.
// Assume that A and B are the 64-bit unsigned integer represented by
// a and b, respectively.  Umul64() should return x, where x.hi and x.lo 
// contain the upper and lower 32 bits of (A * B), respectively.

HL64 Umul64 (HL64 a, HL64 b)
{
	HL64 	x;
	x.lo = 0;
	x.hi = 0;
	for(int i = 0; i < 64; i++){
		if(b.lo & 1){ //x += a
			x.lo += a.lo;
			x.hi = (a.lo > x.lo) ? a.hi + x.hi + 1: a.hi + x.hi;
		}
		// a *= 2
		// carry_a = a.lo >> 31;
		a.hi = (a.lo >> 31) + (a.hi << 1);
		a.lo <<= 1;
		// b /= 2
		// carry_b = (b.hi - ((b.hi >> 1) << 1));
		b.lo = ((b.hi & 1) << 31) + (b.lo >> 1);	
		b.hi >>= 1;
	}
	return x;
}


// Udiv64() implements the division of two 64-bit unsigned integers.
// Assume that A and B are the 64-bit unsigned integer represented by
// a and b, respectively.  Udiv64() should return x, where x.hi and x.lo 
// contain the upper and lower 32 bits of the quotient of (A / B), 
// respectively.

HL64 Udiv64 (HL64 a, HL64 b)
{
	HL64 	x;
	if(b.lo == 0 && b.hi == 0)
		x.hi = x.lo = 0;
	else{
		x.hi = a.hi, x.lo = a.lo;
		HL64 rem;
		rem.hi = rem.lo = 0;
		for(int i = 0; i <= 64; i++){
			int x0 = 0;
			if(rem.hi > b.hi || (rem.hi == b.hi && rem.lo >= b.lo)){	//rem >= q
				//rem = Usub64(rem, b);
				rem.hi = (rem.lo < b.lo) ? rem.hi - b.hi - 1 : rem.hi - b.hi;
				rem.lo -= b.lo;
				x0++;
			}
			//carry_x = x.lo >> 31;
			//carry_rx = x.hi >> 31;
			//carry_r = rem.lo >> 31;
			//rem << 1
			rem.hi = (rem.lo >> 31) + (rem.hi << 1);
			rem.lo = (rem.lo << 1) + (x.hi >> 31); 
			//q << 1 ,q += 1 if rem >= q
			x.hi = (x.lo >> 31) + (x.hi << 1);
			x.lo = (x.lo << 1) + x0;
				
		}
	}
	return x;
}