; file:         vaddv32fp256.asm
;
; Assembly function that adds N 32 bit floating point components of two
; arrays according to
;     w_1 = u_1 + v_1
;     w_2 = u_2 + v_2
;           .
;           .
;           .
;     w_N = u_N + v_N
;
; The AVX2 registers and AVX2 instruction set is used. The function
; processes four looped stages, each processing
;     1. 15 ymm registers * 8 components = 120 components/loop
;     2.  1 ymm register  * 8 components =   8 components/loop
;     3.  1 xmm register  * 4 components =   4 components/loop
;     4.  1 xmm register  * 1 component  =   1 component/loop
;
; The first stage is looped while
;     N_c = (n_1 + 1) * 120 components <= N
; where n_1 is equal to the number of already processed loops of stage 1, and
; n_1 + 1 is equal to the number of already processed loops plus one loop of
; stage 1.
;
; The second stage is looped while
;     N_c = (n_1 * 120 + (n_2 + 1) * 8) components <= N
; where n_2 is equal to the number of already processed loops of stage 2, and
; n_2 + 1 is equal to the number of already processed loops plus one loop of
; stage 2.
;
; The third stage is looped while
;     N_c = (n_1 * 120 + (n_2 + 1) * 8 + (n_3 + 1) * 4) components <= N
; where n_3 is equal to the number of already processed loops of stage 3, and
; n_3 + 1 is equal to the number of already processed loops plus one loop of
; stage 3.
;
; The assembly function returns as soon as N array components are processed, 
; i.e.
;     N_c = (n_1 * 120 + n_2 * 8 + n_3 * 4 + n_4) components == N.
; The number N_c(n_1, n_2, n_3, n_4) of components being processed in the
; next loop is tracked in r9. Stages larger than the number of unprocessed
; components are skipped.
;
; The address offset dA(n_1, n_2, n_3, n_4) of the components processed in
; the most recent loop is tracked in r8. It is computed with
;     dA = 4N_c [B] <= 4N [B]
; in the case of single precision vectors.
;
; synopsis of the caller D source code:
; extern(C) void vaddv32fp256(ulong N, float* u, float* v, float* w);
;
; where
;   N = number of array components        --> rdi
;   u = address to 1st array operand      --> rsi
;   v = address to 2nd array operand      --> rdx
;   w = address to result array           --> rcx
; ____________________________________________________________________________
;
; author:       Stefan Wittwer, info@wittwer-datatools.ch
;
; known bugs:
; 1. ...
;
; ____________________________________________________________________________


section .text
  global vaddv32fp256
vaddv32fp256:
  enter         32,0
  xor           r8,r8                   ; dA = 0
  mov           r9,120                  ; N_c = 120 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage2                  ; true => go to stage 2
loop1:
  vmovaps       ymm0,[rsi+r8]
  vmovaps       ymm1,[rsi+r8+32]
  vmovaps       ymm2,[rsi+r8+64]
  vmovaps       ymm3,[rsi+r8+96]
  vmovaps       ymm4,[rsi+r8+128]
  vmovaps       ymm5,[rsi+r8+160]
  vmovaps       ymm6,[rsi+r8+192]
  vmovaps       ymm7,[rsi+r8+224]
  vmovaps       ymm8,[rsi+r8+256]
  vmovaps       ymm9,[rsi+r8+288]
  vmovaps       ymm10,[rsi+r8+320]
  vmovaps       ymm11,[rsi+r8+352]
  vmovaps       ymm12,[rsi+r8+384]
  vmovaps       ymm13,[rsi+r8+416]
  vmovaps       ymm14,[rsi+r8+448]
  vaddps        ymm0,ymm0,[rdx+r8]
  vaddps        ymm1,ymm1,[rdx+r8+32]
  vaddps        ymm2,ymm2,[rdx+r8+64]
  vaddps        ymm3,ymm3,[rdx+r8+96]
  vaddps        ymm4,ymm4,[rdx+r8+128]
  vaddps        ymm5,ymm5,[rdx+r8+160]
  vaddps        ymm6,ymm6,[rdx+r8+192]
  vaddps        ymm7,ymm7,[rdx+r8+224]
  vaddps        ymm8,ymm8,[rdx+r8+256]
  vaddps        ymm9,ymm9,[rdx+r8+288]
  vaddps        ymm10,ymm10,[rdx+r8+320]
  vaddps        ymm11,ymm11,[rdx+r8+352]
  vaddps        ymm12,ymm12,[rdx+r8+384]
  vaddps        ymm13,ymm13,[rdx+r8+416]
  vaddps        ymm14,ymm14,[rdx+r8+448]
  vmovaps       [rcx+r8],ymm0
  vmovaps       [rcx+r8+32],ymm1
  vmovaps       [rcx+r8+64],ymm2
  vmovaps       [rcx+r8+96],ymm3
  vmovaps       [rcx+r8+128],ymm4
  vmovaps       [rcx+r8+160],ymm5
  vmovaps       [rcx+r8+192],ymm6
  vmovaps       [rcx+r8+224],ymm7
  vmovaps       [rcx+r8+256],ymm8
  vmovaps       [rcx+r8+288],ymm9
  vmovaps       [rcx+r8+320],ymm10
  vmovaps       [rcx+r8+352],ymm11
  vmovaps       [rcx+r8+384],ymm12
  vmovaps       [rcx+r8+416],ymm13
  vmovaps       [rcx+r8+448],ymm14
  add           r8,480                  ; dA += 15 * 8 * 4 byte
  add           r9,120                  ; N_c += 120 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop1                   ; true => loop stage 1
stage2:
  sub           r9,112                  ; N_c = N_c - 120 + 8 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage3                  ; true => go to stage 3
loop2:
  vmovaps       ymm1,[rsi+r8]           ; load first operands
  vaddps        ymm0,ymm1,[rdx+r8]      ; process looped stage 2
  vmovaps       [rcx+r8],ymm0           ; write results
  add           r8,32                   ; dA += 1 * 8 * 4 byte
  add           r9,8                    ; N_c += 8 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop2                   ; true => loop stage 2
stage3:
  sub           r9,4                    ; N_c = N_c - 8 + 4 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage4                  ; true => go to stage 4
loop3:
  vmovaps       xmm1,[rsi+r8]           ; load first operands
  vaddps        xmm0,xmm1,[rdx+r8]      ; process looped stage 3
  vmovaps       [rcx+r8],xmm0           ; write results
  add           r8,16                   ; dA += 1 * 4 * 4 byte
  add           r9,4                    ; N_c += 4 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop3                   ; true => loop stage 3
stage4:
  sub           r9,3                    ; N_c = N_c - 4 + 1 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            return                  ; true => go to return
loop4:
  movss         xmm0,[rsi+r8]           ; load first operand
  addss         xmm0,[rdx+r8]           ; process looped stage 4
  movss         [rcx+r8],xmm0           ; write result
  add           r8,4                    ; dA += 1 * 1 * 4 byte
  inc           r9                      ; N_c += 1 component
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop4                   ; true => loop stage 4
return:
  leave
  ret


; end of vaddv32fp256.asm
