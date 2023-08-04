# `wdsimd`
# A Library for Fast Vector Computing with Intel(R) SIMD

## Description
The `wdsimd` library package provides functions for fast vector computing on Intel(R) processors with SIMD (single instruction, multiple data) technology implemented. The assembly source to the library implements functions using AVX2 and AVX512 instructions.

Please check whether AVX2 or AVX512 is present on your Intel(R) processors before using the library.

## Purpose
The functions of the `wdsimd` library can be used for various computational applications, e.g.

* Linear Algebra / FEM
* Big Data
* Computer Vision
* DSP
* Machine Learning / AI
* Real Time Applications


## Download and Installation
The [`wdsimd` repository](https://github.com/wd012345/wdsimd "wdsimd repository") offers the following libraries for download:

* `wdsimd.a`: release build of library for 64 bit Linux
* `wdsimd.dbg.a`: debug build of library for 64 bit Linux

Download the library of your choice. As super user, move it to a directory on your library path.


## Source Build and Function Naming
The `source/*.asm` and `source/*.d` files in the repository contain the library source code. Download the  entire [`wdsimd` repository](https://github.com/wd012345/wdsimd "wdsimd repository")` to a directory of your choice. Execute

```
$ dub build
```

at the command line of the directory to build the library package. You will need current versions of the `dub` package manager, as well as the `nasm` and `dmd` compilers to successfully build the library.

The assembly source files in the `source/` subfolder contain the operations on array elements. Their naming follows the format

```
[s|v]op[v|s][32|64]fp[256|512].asm
```

where

* s stands for a single value (scalar),
* v stands for a vector,
* op stands for one of the operations `add` (addition), `div` (division), `equ` (assignment), `mul` (multiplication), `spr` (inner or dot product), `sub` (subtraction),
* 32fp or 64fp stands for the single precision (`float`) and the double precision (`double`) types of the scalar or vector operands, respectively,
* 256 or 512 refers to the corresponding AVX technology.

The functions currently implemented in the `wdavx256.a` and `wdavx512.a` libraries are:

* `sdivv32fp[256|512].asm` : divides number by array (type `float`)
* `sdivv64fp[256|512].asm` : divides number by array (type `double`)
* `ssubv32fp[256|512].asm` : subtracts array from number (type `float`)
* `ssubv64fp[256|512].asm` : subtracts array from number (type `double`)
* `vadds32fp[256|512].asm` : adds number to array (type `float`)
* `vadds64fp[256|512].asm` : adds number to array (type `double`)
* `vaddv32fp[256|512].asm` : adds two arrays (type `float`)
* `vaddv64fp[256|512].asm` : adds two arrays (type `double`)
* `vdivs32fp[256|512].asm` : divides array by number (type `float`)
* `vdivs64fp[256|512].asm` : divides array by number (type `double`)
* `vdivv32fp[256|512].asm` : divides 1st array by 2nd array (type `float`)
* `vdivv64fp[256|512].asm` : divides 1st array by 2nd array` (type `double`)
* `vequs32fp[256|512].asm` : assigns number to array (type `float`)
* `vequs64fp[256|512].asm` : assigns number to array (type `double`)
* `vequv32fp[256|512].asm` : assigns array to array (type `float`)
* `vequv64fp[256|512].asm` : assigns array to array (type `double`)
* `vmuls32fp[256|512].asm` : multiplies array with number (type `float`)
* `vmuls64fp[256|512].asm` : multiplies array with number (type `double`)
* `vmulv32fp[256|512].asm` : multiplies two arrays (type `float`)
* `vmulv64fp[256|512].asm` : multiplies two arrays (type `double`)
* `vsprv32fp[256|512].asm` : computes dot product of two arrays (type `float`)
* `vsprv64fp[256|512].asm` : computes dot product of two arrays (type `double`)
* `vsubs32fp[256|512].asm` : subtracts number from array (type `float`)
* `vsubs64fp[256|512].asm` : subtracts number from array (type `double`)
* `vsubv32fp[256|512].asm` : subtracts 2nd array from 1st array (type `float`)
* `vsubv64fp[256|512].asm` : subtracts 2nd array from 1st array (type `double`)


## Usage
The D code of the interface file `isimd.di` implements the template interface

```
interface ISIMD(ulong R, T)
if ((R == 256uL || R == 512uL) && (is(T == float) || is(T == double)))
{ ... }
```

The template parameters `R` and `T` stand for the register width of the AVX technology (256 bit or 512 bit ), and for the numeric type (`float` or `double`), respectively. The interface wraps the appropriate assembly functions as final interface methods. The `ISIMD` interface is implemented in the `source/isimd.d` source file.

Derive your D class from this interface with
```
class MyComputingClass(ulong R, T) : ISIMD!(R, T)
{
    // your code using the interface methods here ...
}
```
to use the assembly functions through the interface methods.

The use of AVX2 and AVX512 operations require the data memory to be aligned at 32 and 64 Byte addresses, respectively. Use the `setBuffer()` and `getBuffer()` methods of the `ISIMD` interface when allocating arrays. Detailed information is obtained in the `source/isimd.d` comments.

The listing below shows how to compute the sum `w_n = u_n + v_n` of the `n = 0, 1, ..., N_c - 1uL` components of the arrays `u` and `v`. In this example `u`, `v` and `w` are double precision floating point arrays (`double`) residing in previously allocated and aligned memory.

```
unittest
{
    import std.stdio: writefln;
	// constructing your computing class object: T = double
    auto mcc = new MyComputingClass(256uL, double);
    ...
    // compute operation of array u and v elements
    this.vaddv(N_c, u, v, w);
    ...
}
```

## History
#### Aug 01 2023: v0.3 (beta)
* added AVX512 functionality
* expanded stage 1 to max possible AVX2 registers in several assembly functions (to raise speed of execution)
* added dub packaging functionality (see [Link](https://dub.pm/ "DUB Package Manager"))
* fixed bugs
* removed "Return error code" from the Bugs section

#### Mar 28 2023: v0.2 (beta)
* renamed assembly functions to consistent names
* modified aligned memory management in `wdasm.d`
* modified library name from `libasm.a` to `libavx256.a`
* modified library name from `libasm.dbg.a` to `libavx256.dbg.a`
* updated source comments

#### Feb 1 2023: v0.1 (alpha)
* implemented D source code to allocate aligned memory
* fixed several segmentation faults
* added assembly functions for `dot` multiplying arrays (inner product of vectors)
* updated comments and documentation
* versioned repository to 0.1alpha


## Bugs
The following bugs and to do items are known:

* Provide information on processor and performance
* Extend to AVX512

Send bug reports to [info@wittwer-datatools.ch](mailto:info@wittwer-datatools.ch).