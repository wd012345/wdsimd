; file:         ssubv32fp512.asm
;
; Assembly function that subtracts N 32bit floating point array components
; from a 32bit floating point scalar according to
;     w_{111...} = s - v_{111...}
;     w_{211...} = s - v_{211...}
;           .
;           .
;           .
;     w_{kmn...} = s - v_{kmn...}
;
; The AVX512 registers and AVX512 instruction set is used. The function
; processes five loop stages, each processing
;     1. 31 zmm registers * 16 components = 496 components/loop
;     2.  1 zmm register  * 16 components =  16 components/loop
;     3.  1 ymm register  *  8 components =   8 components/loop
;     4.  1 xmm register  *  4 components =   4 components/loop
;     5.  1 xmm register  *  1 component  =   1 component/loop
;
; The 1st stage is looped while
;     N_c = (n_1 + 1) * 496 components <= N
; where n_1 is equal to the number of already processed loops of stage 1.
;
; The 2nd stage is looped while
;     N_c = (n_1 * 496 + (n_2 + 1) * 16) components <= N
; where n_2 is equal to the number of already processed loops of stage 2.
;
; The 3rd stage is looped while
;     N_c = (n_1 * 496 + n_2 * 16 + (n_3 + 1) * 8) components <= N
; where n_3 is equal to the number of already processed loops of stage 3.
;
; The 4th stage is looped while
;     N_c = (n_1 * 496 + n_2 * 16 + n_3 * 8 + (n_4 + 1) * 4) components <= N
; where n_4 is equal to the number of already processed loops of stage 4.
;
; The assembly function returns as soon as N array components are processed, 
; i.e.
;     (n_1 * 496 + n_2 * 16 + n_3 * 8 + n_4 * 4 + n_5) components == N.
; The number N_c(n_1, n_2, n_3, n_4, n_5) of components being processed in the
; next loop is tracked in r9. Stages larger than the number of unprocessed
; components are skipped.
;
; The address offset dA(n_1, n_2, n_3, n_4, n_5) of the components processed
; in the most recent loop is tracked in r8. It is computed with
;     dA = 4N [B] <= 4N_c [B]
; in the case of single precision vectors.
;
; synopsis of the caller D source code:
; extern(C) void ssubv32fp512(ulong N, float s, float* v, float* w);
;
; where
;   N = number of array components        --> rdi
;   s = single precision scalar           --> xmm0
;   v = address to 2nd array operand      --> rsi
;   w = address to result array           --> rdx
;
; ____________________________________________________________________________
;
; author:       Stefan Wittwer, info@wittwer-datatools.ch
;
; known bugs:
; 1. ...
;
; ____________________________________________________________________________


section .text
  global ssubv32fp512
ssubv32fp512:
  enter         32,0
  vbroadcastss  zmm31,xmm0              ; broadcast scalar argument
  xor           r8,r8                   ; dA = 0
  mov           r9,496                  ; N_c = 496 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage2                  ; true => go to stage 2
loop1:
  vsubps        zmm0,zmm31,[rsi+r8]
  vsubps        zmm1,zmm31,[rsi+r8+64]
  vsubps        zmm2,zmm31,[rsi+r8+128]
  vsubps        zmm3,zmm31,[rsi+r8+192]
  vsubps        zmm4,zmm31,[rsi+r8+256]
  vsubps        zmm5,zmm31,[rsi+r8+320]
  vsubps        zmm6,zmm31,[rsi+r8+384]
  vsubps        zmm7,zmm31,[rsi+r8+448]
  vsubps        zmm8,zmm31,[rsi+r8+512]
  vsubps        zmm9,zmm31,[rsi+r8+576]
  vsubps        zmm10,zmm31,[rsi+r8+640]
  vsubps        zmm11,zmm31,[rsi+r8+704]
  vsubps        zmm12,zmm31,[rsi+r8+768]
  vsubps        zmm13,zmm31,[rsi+r8+832]
  vsubps        zmm14,zmm31,[rsi+r8+896]
  vsubps        zmm15,zmm31,[rsi+r8+960]
  vsubps        zmm16,zmm31,[rsi+r8+1024]
  vsubps        zmm17,zmm31,[rsi+r8+1088]
  vsubps        zmm18,zmm31,[rsi+r8+1152]
  vsubps        zmm19,zmm31,[rsi+r8+1216]
  vsubps        zmm20,zmm31,[rsi+r8+1280]
  vsubps        zmm21,zmm31,[rsi+r8+1344]
  vsubps        zmm22,zmm31,[rsi+r8+1408]
  vsubps        zmm23,zmm31,[rsi+r8+1472]
  vsubps        zmm24,zmm31,[rsi+r8+1536]
  vsubps        zmm25,zmm31,[rsi+r8+1600]
  vsubps        zmm26,zmm31,[rsi+r8+1664]
  vsubps        zmm27,zmm31,[rsi+r8+1728]
  vsubps        zmm28,zmm31,[rsi+r8+1792]
  vsubps        zmm29,zmm31,[rsi+r8+1856]
  vsubps        zmm30,zmm31,[rsi+r8+1920]
  vmovaps       [rdx+r8],zmm0
  vmovaps       [rdx+r8+64],zmm1
  vmovaps       [rdx+r8+128],zmm2
  vmovaps       [rdx+r8+192],zmm3
  vmovaps       [rdx+r8+256],zmm4
  vmovaps       [rdx+r8+320],zmm5
  vmovaps       [rdx+r8+384],zmm6
  vmovaps       [rdx+r8+448],zmm7
  vmovaps       [rdx+r8+512],zmm8
  vmovaps       [rdx+r8+576],zmm9
  vmovaps       [rdx+r8+640],zmm10
  vmovaps       [rdx+r8+704],zmm11
  vmovaps       [rdx+r8+768],zmm12
  vmovaps       [rdx+r8+832],zmm13
  vmovaps       [rdx+r8+896],zmm14
  vmovaps       [rdx+r8+960],zmm15
  vmovaps       [rdx+r8+1024],zmm16
  vmovaps       [rdx+r8+1088],zmm17
  vmovaps       [rdx+r8+1152],zmm18
  vmovaps       [rdx+r8+1216],zmm19
  vmovaps       [rdx+r8+1280],zmm20
  vmovaps       [rdx+r8+1344],zmm21
  vmovaps       [rdx+r8+1408],zmm22
  vmovaps       [rdx+r8+1472],zmm23
  vmovaps       [rdx+r8+1536],zmm24
  vmovaps       [rdx+r8+1600],zmm25
  vmovaps       [rdx+r8+1664],zmm26
  vmovaps       [rdx+r8+1728],zmm27
  vmovaps       [rdx+r8+1792],zmm28
  vmovaps       [rdx+r8+1856],zmm29
  vmovaps       [rdx+r8+1920],zmm30
  add           r8,1984                 ; dA += 31 * 16 * 4 byte
  add           r9,496                  ; N_c += 496 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop1                   ; true => loop stage 1
stage2:
  sub           r9,480                  ; N_c = N_c - 496 + 16 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage3                  ; true => go to stage 3
loop2:
  vsubps        zmm0,zmm31,[rsi+r8]     ; process looped stage 1
  vmovaps       [rdx+r8],zmm0           ; write results
  add           r8,64                   ; dA += 1 * 16 * 4 byte
  add           r9,16                   ; N_c += 16 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop2                   ; true => loop stage 2
stage3:
  sub           r9,8                    ; N_c = N_c - 16 + 8 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage4                  ; true => go to stage 4
loop3:
  vsubps        ymm0,ymm31,[rsi+r8]     ; process looped stage 3
  vmovaps       [rdx+r8],ymm0           ; write results
  add           r8,32                   ; dA += 1 * 8 * 4 byte
  add           r9,8                    ; N_c += 8 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop3                   ; true => loop stage 3
stage4:
  sub           r9,4                    ; N_c = N_c - 8 + 4 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage5                  ; true => go to stage 5
loop4:
  vsubps        xmm0,xmm31,[rsi+r8]     ; process looped stage 4
  vmovaps       [rdx+r8],xmm0           ; write results
  add           r8,16                   ; dA += 1 * 4 * 4 byte
  add           r9,4                    ; N_c += 4 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop4                   ; true => loop stage 4
stage5:
  sub           r9,3                    ; N_c = N_c - 4 + 1 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            return                  ; true => go to return
loop5:
  vsubss        xmm0,xmm31,[rsi+r8]     ; process looped stage 5
  movss         [rdx+r8],xmm0           ; write result
  add           r8,4                    ; dA += 1 * 1 * 4 byte
  inc           r9                      ; N_c += 1 component
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop5                   ; true => loop stage 5
return:
  leave
  ret


; end of ssubv32fp512.asm
