//---------------------------------------------------------------
//
//  4190.308 Computer Architecture (Fall 2019)
//
//  Project #2: Half-precision Floating Points
//
//  October 1, 2019
//
//  Jin-Soo Kim (jinsoo.kim@snu.ac.kr)
//  Systems Software & Architecture Laboratory
//  Dept. of Computer Science and Engineering
//  Seoul National University
//
//---------------------------------------------------------------

#include <stdio.h>
#include "pa2.h"

union bits{
	float f;
	unsigned int i;
};
//반올림해서 infinity가 아니면 infinity가 아니다
// Convert 32-bit signed integer to 16-bit half-precision floating point
hfp int2hfp (int n)
{
	if(n == 0) return 0;
	short sign;
	short exp;
	hfp frac; 
	hfp result;
	if(n < 0){
		sign = 1;
		n = -n;
	}
	else sign = 0;
	int i = 1;
	for(; i < 17; i++){
		if ((n >> i) == 0) break;
	}
	if(i == 17) return (sign << 15) + (31 << 10);
	exp = 14 + i;

	if (i < 12) frac = (n << (11 - i)) & ((1 << 10) - 1);
	else{	// 11 <= i <= 16
		short guard = (n & (1 << (i - 11))) >> (i - 11);
		short round = (n & (1 << (i - 12))) >> (i - 12);
		short sticky = (n % (1 << (i - 12)) != 0); 
		if (round == 0) frac = (n >> (i - 11)) % (1 << 10);
		else if (guard == 1) {
			frac = ((n >> (i - 11)) % (1 << 10)) + 1;
			if (frac >= (1 << 10)){
				frac = 0;
				exp++;
			}
		}
		else{
			frac = (sticky == 1) ? ((n >> (i - 11)) % (1 << 10)) + 1 : (n >> (i - 11)) % (1 << 10); 
		}
	}
	
	result = frac + (exp << 10) + (sign << 15) ;

	return result;
}


// Convert 16-bit half-precision floating point to 32-bit signed integer
int hfp2int (hfp h)
{
	short sign = h >> 15;
	short exp = (h >> 10) - (sign << 5);
	hfp frac = h % (1 << 10);
	int result;	
	if(exp <= 14) result = 0;
	else if(exp == 0x1f) result = 0x80000000;	
	else if(exp >= 25) {
		result = (1 << (exp - 15)) + (frac << (exp - 25));
		if(sign) result = -result;
	}
	else{ // 15 <= exp <= 24
		result = (1 << (exp - 15)) + (frac >> (25 - exp));
		if(sign) result = -result;
	}
	return result;
}

  
// Convert 32-bit single-precision floating point to 
// 16-bit half-precision floating point
hfp float2hfp (float f)
{
	union bits bit;
	bit.f = f;
	short sign = bit.i >> 31;
	short exp = (bit.i >> 23) - (sign << 8);

	if(exp <= 0x7f + 15 && exp >= 0x7f - 14){	//normalized hfp
	// 0x7f - 14 <= exp <= 0x7f + 15
		unsigned int frac = bit.i % (1 << 23);
		short frac_h = frac >> 12;
		short guard = (frac_h >> 1) % 2;
		short round = frac_h % 2;
		short sticky = (frac % (1 << 12) != 0);
		frac_h >>= 1;
		if(round){
			if(guard || sticky)
				frac_h++;
		}
		return (sign << 15) + ((exp - 0x70) << 10) + frac_h;
	}
	else if(exp < 0x7f - 14 && exp >= 0x7f - 25){	// denormalized hfp : 2^(-15) ~ 2^(-24), 2^(-25)
		//0x7f - 25 <= exp <= 0x7f - 15
		unsigned int frac = bit.i % (1 << 23);
		//short exp_0 = (exp - (0x7f - 24));  //-1 ~ 9
		//short frac_h = (frac >> (23 - exp_0)) + ((1 << (exp_0 + 1)) >> 1); // 2^(-15) ~ 2^(-24) 범위의 frac
		//short guard = frac_h % 2;	// 2^(-24)
		//short round = (frac >> (22 - exp_0)) % 2 + (exp_0 == -1);	// 2^(-25)
		//short sticky = ((frac << (exp_0 + 1)) % (1 << 23) != 0);	// 2^(-26) ~
		
		short frac_h = (frac >> (0x7f - 1 - exp)) + ((1 << (exp - 0x7f + 25)) >> 1); // 2^(-15) ~ 2^(-24) 범위의 frac
		short guard = frac_h % 2;	// 2^(-24)
		short round = (frac >> (0x7f - exp - 2)) % 2 + (exp == 0x7f - 25);	// 2^(-25)
		short sticky = ((frac << (exp - 0x7f + 25)) % (1 << 23) != 0);	// 2^(-26) ~
		
		if(round)
			if(guard || sticky) frac_h++;
		return (sign << 15) + frac_h;
	}
	else if(exp == 0xff && (bit.i % (1 << 23)) > 0){
		return 1 + (0x1f << 10) + (sign << 15);
	}
	else if(exp > 0x7f + 15){	// overflow
		return (0x1f << 10) + (sign << 15);
	}
	else{	// underflow
		return sign << 15;
	}
}


// Convert 16-bit half-precision floating point to 
// 32-bit single-precision floating point
float hfp2float (hfp h)
{
	union bits bit;
	unsigned int sign = h >> 15;
	unsigned int exp = (h >> 10) - (sign << 5);
	unsigned int frac = h % (1 << 10);
	if(exp == 0x1f){
		bit.i = (sign << 31) + (0xff << 23) + frac;
	}
	else if(exp == 0){ // 2^(-15) ... 2^(-24)
		if(frac == 0) {
			bit.i = sign << 31;
			return bit.f;
			}
		int i;
		for(i = 1; i < 10; i++){
			if(frac >> i == 0) break;
		}
		i--;
		frac -= 1 << i;
		exp = 0x7f - 24 + i;
		bit.i = (sign << 31) + (exp << 23) + (frac << (23 - i));
	}
	else {
		exp += 0b1110000;
		bit.i = (sign << 31) + (exp << 23) + (frac << 13);
	}
	return bit.f;
}


