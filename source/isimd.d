/**
 *
 */
module isimd;


// declarations of AVX2 32bit flolating point assembler functions
extern(C) void sdivv32fp256(ulong, float, float*, float*);
extern(C) void ssubv32fp256(ulong, float, float*, float*);
extern(C) void vadds32fp256(ulong, float*, float, float*);
extern(C) void vaddv32fp256(ulong, float*, float*, float*);
extern(C) void vdivs32fp256(ulong, float*, float, float*);
extern(C) void vdivv32fp256(ulong, float*, float*, float*);
extern(C) void vequs32fp256(ulong, float, float*);
extern(C) void vequv32fp256(ulong, float*, float*);
extern(C) void vmuls32fp256(ulong, float*, float, float*);
extern(C) void vmulv32fp256(ulong, float*, float*, float*);
extern(C) float vsprv32fp256(ulong, float*, float*);
extern(C) void vsubs32fp256(ulong, float*, float, float*);
extern(C) void vsubv32fp256(ulong, float*, float*, float*);


// declarations of AVX2 64bit flolating point assembler functions
extern(C) void sdivv64fp256(ulong, double, double*, double*);
extern(C) void ssubv64fp256(ulong, double, double*, double*);
extern(C) void vadds64fp256(ulong, double*, double, double*);
extern(C) void vaddv64fp256(ulong, double*, double*, double*);
extern(C) void vdivs64fp256(ulong, double*, double, double*);
extern(C) void vdivv64fp256(ulong, double*, double*, double*);
extern(C) void vequs64fp256(ulong, double, double*);
extern(C) void vequv64fp256(ulong, double*, double*);
extern(C) void vmuls64fp256(ulong, double*, double, double*);
extern(C) void vmulv64fp256(ulong, double*, double*, double*);
extern(C) double vsprv64fp256(ulong, double*, double*);
extern(C) void vsubs64fp256(ulong, double*, double, double*);
extern(C) void vsubv64fp256(ulong, double*, double*, double*);


// declarations of AVX2 32bit flolating point assembler functions
extern(C) void sdivv32fp512(ulong, float, float*, float*);
extern(C) void ssubv32fp512(ulong, float, float*, float*);
extern(C) void vadds32fp512(ulong, float*, float, float*);
extern(C) void vaddv32fp512(ulong, float*, float*, float*);
extern(C) void vdivs32fp512(ulong, float*, float, float*);
extern(C) void vdivv32fp512(ulong, float*, float*, float*);
extern(C) void vequs32fp512(ulong, float, float*);
extern(C) void vequv32fp512(ulong, float*, float*);
extern(C) void vmuls32fp512(ulong, float*, float, float*);
extern(C) void vmulv32fp512(ulong, float*, float*, float*);
extern(C) float vsprv32fp512(ulong, float*, float*);
extern(C) void vsubs32fp512(ulong, float*, float, float*);
extern(C) void vsubv32fp512(ulong, float*, float*, float*);


// declarations of AVX2 64bit flolating point assembler functions
extern(C) void sdivv64fp512(ulong, double, double*, double*);
extern(C) void ssubv64fp512(ulong, double, double*, double*);
extern(C) void vadds64fp512(ulong, double*, double, double*);
extern(C) void vaddv64fp512(ulong, double*, double*, double*);
extern(C) void vdivs64fp512(ulong, double*, double, double*);
extern(C) void vdivv64fp512(ulong, double*, double*, double*);
extern(C) void vequs64fp512(ulong, double, double*);
extern(C) void vequv64fp512(ulong, double*, double*);
extern(C) void vmuls64fp512(ulong, double*, double, double*);
extern(C) void vmulv64fp512(ulong, double*, double*, double*);
extern(C) double vsprv64fp512(ulong, double*, double*);
extern(C) void vsubs64fp512(ulong, double*, double, double*);
extern(C) void vsubv64fp512(ulong, double*, double*, double*);


// import modules
import std.format: format;


/**
 *
 */
interface ISIMD(ulong R, T)
if ((R == 256uL || R == 512uL) && (is(T == float) || is(T == double)))
{
	protected
	{
/** protected static methods **/
		/**
		 * Get memory addresses of buffer components. Checks whether memory
		 * alignment of buffer is equal to the current alignment setting  (1st
		 * argument).
		 *
		 * Params:
		 *   data =    buffer memory as array
		 *   address = output array of buffer addresses
		 *
		 * Returns:
		 * `true` if memory alignment matches, false otherwise
		 */
		static nothrow
		bool getBuffer(T[] data, out T*[] address)
		{
			// return false for empty buffer
			if (data == null || data.length == 0uL) return false;
			// assign addresses of buffer components
			address = new T*[](data.length);
			foreach (n; 0uL .. data.length) address[n] = &(data[n]);
			// return if memory alignment of buffer satisfies SIMD requirement
			return (cast(ulong) address[0] % (R / 8uL) == 0uL);
		}
		/**
		 * Allocate aligned buffer to contain auxiliary arrays of tensor
		 * computations. Initialize buffer with zeros, or with the given
		 * component data. The buffer memory is added to the range of the
		 * garbage collector.
		 *
		 * Params:
		 *   N_c =  number of buffer elements of type T
		 *   data = data to initialize buffer
		 *
		 * Returns:
		 *   z =    buffer array of numeric type `T`
		 */
		static
		T[] setBuffer(in ulong N_c, in T[] data = null)
		{
			// return null if number of elements == 0 
			if (N_c > 0uL)
			{
				import core.memory: GC;
				import core.stdc.stdlib: aligned_alloc;
				// compute buffer size [B]
				ulong L__B = N_c * T.sizeof;
				// allocate aligned buffer initialized with 0s
				void* b = aligned_alloc(R / 8uL, L__B);
				// add buffer memory to garbage collector
				GC.addRange(b, L__B);
				// cast type of buffer to T
				T[] z = cast(T[]) b[0uL .. L__B];
				// eventually assign data to buffer and return
				if (data.length == N_c) z[] = data[];
				return z;
			}
			else return null;
		}
	}
/* public methods */
	/**
	 * Wrapping method of assembly function assigning the given value `s` to
	 * all the elements of the array `w`:
	 *   w[c] = s
	 *
	 * `w` must have a length equal to `N_c`, or an assertion error is thrown.
	 *
	 * Params:
	 *     N_c =  number of array components
	 *     s =    real or complex value
	 *     w =    real or complex array
	 *
	 * Throws:
	 * Wrong size of array argument.
	 */
	final
	void vequs(ulong N_c, T s, T[] w)
	in
	{
		assert(w.length == N_c, "Wrong size of array argument.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vequs64fp" ~ format!"%d"(R) ~ "(N_c, s, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vequs32fp" ~ format!"%d"(R) ~ "(N_c, s, w.ptr);");
		}
	}
	/**
	 * Wrapping method of assembly function assigning the given source
	 * array `v` to the target array `w`:
	 *   w[c] = v[c]
	 *
	 * The array arguments `v` and `w` must have exactly `N_c` elements each,
	 * or an assertion error is thrown.
	 *
	 * Params:
	 *     N_c =  number of array components
	 *     v =    source array
	 *     w =    target array
	 *
	 * Throws:
	 * Wrong size of array arguments.
	 */
	final
	void vequv(ulong N_c, T[] v, T[] w)
	in
	{
		assert(v.length == N_c && w.length == N_c,
			"Wrong size of array arguments.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vequv64fp" ~ format!"%d"(R) ~ "(N_c, v.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vequv32fp" ~ format!"%d"(R) ~ "(N_c, v.ptr, w.ptr);");
		}
	}
/* public computing methods */
	/**
	 * Wrapping method for assembly functions to perform fast addition of
	 * array `w` plus scalar `s`:
	 *   w[c] = w[c] + s
	 * or:
	 *   w[c] = u[c] + s
	 * 
	 * Params:
	 *     N_c =  total number of array components
	 *     s =    2nd scalar operand
	 *     w =    1st array operand, result array
	 *
	 * Throws:
	 * Wrong size of array operand(s).
	 */
	final
	void vadds(ulong N_c, T s, T[] w)
	in
	{
		assert(w.length == N_c, "Wrong size of array operand.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vadds64fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, s, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vadds32fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, s, w.ptr);");
		}
	}
	final
	void vadds(ulong N_c, T[] u, T s, T[] w)
	in
	{
		assert(u.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vadds64fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, s, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vadds32fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, s, w.ptr);");
		}
	}
	/**
	 * Wrapping method for assembly functions to perform fast addition of
	 * two arrays `u` and `v`:
	 *   w[c] = w[c] + v[c]
	 * or:
	 *   w[c] = u[c] + v[c]
	 * 
	 * Params:
	 *     N_c =  total number of components
	 *     v =    2nd array operand
	 *     w =    1st array operand, result array
	 *
	 * Throws:
	 * Wrong size of array operands.
	 */
	final
	void vaddv(ulong N_c, T[] v, T[] w)
	in
	{
		assert(v.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vaddv64fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, v.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vaddv32fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, v.ptr, w.ptr);");
		}
	}
	final
	void vaddv(ulong N_c, T[] u, T[] v, T[] w)
	in
	{
		assert(u.length == N_c && v.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vaddv64fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, v.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vaddv32fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, v.ptr, w.ptr);");
		}
	}
	/**
	 * Wrapping method for assembly functions to perform fast division of
	 * scalar `s` divided by array `v`:
	 *   w[c] = s / w[c]
	 * or
	 *   w[c] = s / v[c]
	 * 
	 * Params:
	 *     N_c =  total number of components
	 *     s =    1st scalar operand
	 *     w =    2nd array operand, result array
	 *
	 * Throws:
	 * Wrong size of array operands.
	 */
	final
	void sdivv(ulong N_c, T s, T[] w)
	in
	{
		assert(w.length == N_c, "Wrong size of array operand.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("sdivv64fp" ~ format!"%d"(R) ~ "(N_c, s, w.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("sdivv32fp" ~ format!"%d"(R) ~ "(N_c, s, w.ptr, w.ptr);");
		}
	}
	final
	void sdivv(ulong N_c, T s, T[] v, T[] w)
	in
	{
		assert(v.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("sdivv64fp" ~ format!"%d"(R) ~ "(N_c, s, v.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("sdivv32fp" ~ format!"%d"(R) ~ "(N_c, s, v.ptr, w.ptr);");
		}
	}
	/**
	 * Wrapping method for assembly functions to perform fast division of
	 * array `w` divided by scalar `s`:
	 *   w[c] = w[c] / s
	 * or:
	 *   w[c] = u[c] / s
	 * 
	 * Params:
	 *     N_c =  total number of array components
	 *     s =    2nd scalar operand
	 *     w =    1st array operand, result array
	 *
	 * Throws:
	 * Wrong size of array operand(s).
	 */
	final
	void vdivs(ulong N_c, T s, T[] w)
	in
	{
		assert(w.length == N_c, "Wrong size of array operand.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vdivs64fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, s, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vdivs32fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, s, w.ptr);");
		}
	}
	final
	void vdivs(ulong N_c, T[] u, T s, T[] w)
	in
	{
		assert(u.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vdivs64fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, s, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vdivs32fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, s, w.ptr);");
		}
	}
	/**
	 * Wrapping method for assembly functions to perform fast division of
	 * two arrays `u` and `v`:
	 *   w[c] = w[c] / v[c]
	 * or:
	 *   w[c] = u[c] / v[c]
	 * 
	 * Params:
	 *     N_c =  total number of components
	 *     v =    2nd array operand
	 *     w =    1st array operand, result array
	 *
	 * Throws:
	 * Wrong size of array operands.
	 */
	final
	void vdivv(ulong N_c, T[] v, T[] w)
	in
	{
		assert(v.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vdivv64fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, v.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vdivv32fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, v.ptr, w.ptr);");
		}
	}
	final
	void vdivv(ulong N_c, T[] u, T[] v, T[] w)
	in
	{
		assert(u.length == N_c && v.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vdivv64fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, v.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vdivv32fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, v.ptr, w.ptr);");
		}
	}
	/**
	 * Wrapping method for assembly functions to perform fast multiplication of
	 * array `w` times scalar `s`:
	 *   w[c] = w[c] * s
	 * or:
	 *   w[c] = u[c] * s
	 * 
	 * Params:
	 *     N_c =  total number of array components
	 *     s =    2nd scalar operand
	 *     w =    1st array operand, result array
	 *
	 * Throws:
	 * Wrong size of array operand(s).
	 */
	final
	void vmuls(ulong N_c, T s, T[] w)
	in
	{
		assert(w.length == N_c, "Wrong size of array operand.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vmuls64fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, s, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vmuls32fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, s, w.ptr);");
		}
	}
	final
	void vmuls(ulong N_c, T[] u, T s, T[] w)
	in
	{
		assert(u.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vmuls64fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, s, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vmuls32fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, s, w.ptr);");
		}
	}
	/**
	 * Wrapping method for assembly functions to perform fast multiplication of
	 * two arrays `u` and `v`:
	 *   w[c] = w[c] * v[c]
	 * or:
	 *   w[c] = u[c] * v[c]
	 * 
	 * Params:
	 *     N_c =  total number of components
	 *     v =    2nd array operand
	 *     w =    1st array operand, result array
	 *
	 * Throws:
	 * Wrong size of array operands.
	 */
	final
	void vmulv(ulong N_c, T[] v, T[] w)
	in
	{
		assert(v.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vmulv64fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, v.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vmulv32fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, v.ptr, w.ptr);");
		}
	}
	final
	void vmulv(ulong N_c, T[] u, T[] v, T[] w)
	in
	{
		assert(u.length == N_c && v.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vmulv64fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, v.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vmulv32fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, v.ptr, w.ptr);");
		}
	}
	/**
	 * Wrapping method for assembly functions to perform fast subtraction of
	 * scalar `s` minus array `v`:
	 *   w[c] = s - w[c]
	 * or
	 *   w[c] = s - v[c]
	 * 
	 * Params:
	 *     N_c =  total number of components
	 *     s =    1st scalar operand
	 *     w =    2nd array operand, result array
	 *
	 * Throws:
	 * Wrong size of array operands.
	 */
	final
	void ssubv(ulong N_c, T s, T[] w)
	in
	{
		assert(w.length == N_c, "Wrong size of array operand.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("ssubv64fp" ~ format!"%d"(R) ~ "(N_c, s, w.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("ssubv32fp" ~ format!"%d"(R) ~ "(N_c, s, w.ptr, w.ptr);");
		}
	}
	final
	void ssubv(ulong N_c, T s, T[] v, T[] w)
	in
	{
		assert(v.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("ssubv64fp" ~ format!"%d"(R) ~ "(N_c, s, v.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("ssubv32fp" ~ format!"%d"(R) ~ "(N_c, s, v.ptr, w.ptr);");
		}
	}
	/**
	 *
	 */
	final
	T vsprv(ulong N_c, T[] u, T[] v)
	in
	{
		assert(u.length == N_c && v.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("return vsprv64fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, v.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("return vsprv32fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, v.ptr);");
		}
	}
	/**
	 * Wrapping method for assembly functions to perform fast subtraction of
	 * array `w` plus scalar `s`:
	 *   w[c] = w[c] - s
	 * or:
	 *   w[c] = u[c] - s
	 * 
	 * Params:
	 *     N_c =  total number of array components
	 *     s =    2nd scalar operand
	 *     w =    1st array operand, result array
	 *
	 * Throws:
	 * Wrong size of array operand(s).
	 */
	final
	void vsubs(ulong N_c, T s, T[] w)
	in
	{
		assert(w.length == N_c, "Wrong size of array operand.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vsubs64fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, s, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vsubs32fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, s, w.ptr);");
		}
	}
	final
	void vsubs(ulong N_c, T[] u, T s, T[] w)
	in
	{
		assert(u.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vsubs64fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, s, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vsubs32fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, s, w.ptr);");
		}
	}
	/**
	 * Wrapping method for assembly functions to perform fast subtraction of
	 * two arrays `u` and `v`:
	 *   w[c] = w[c] - v[c]
	 * or:
	 *   w[c] = u[c] - v[c]
	 * 
	 * Params:
	 *     N_c =  total number of components
	 *     v =    2nd array operand
	 *     w =    1st array operand, result array
	 *
	 * Throws:
	 * Wrong size of array operands.
	 */
	final
	void vsubv(ulong N_c, T[] v, T[] w)
	in
	{
		assert(v.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vsubv64fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, v.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vsubv32fp" ~ format!"%d"(R) ~ "(N_c, w.ptr, v.ptr, w.ptr);");
		}
	}
	final
	void vsubv(ulong N_c, T[] u, T[] v, T[] w)
	in
	{
		assert(u.length == N_c && v.length == N_c && w.length == N_c,
			"Wrong size of array operands.");
	}
	do
	{
		static if (is(T == double))
		{
			mixin("vsubv64fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, v.ptr, w.ptr);");
		}
		else static if (is(T == float))
		{
			mixin("vsubv32fp" ~ format!"%d"(R) ~ "(N_c, u.ptr, v.ptr, w.ptr);");
		}
	}
}


// end of module isimd
