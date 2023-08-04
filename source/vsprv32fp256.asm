; file:         vsprv32fp256.asm
;
; Assembly function that computes the dot product of two 32 bit floating point
; arrays with N components each according to
;
;                       N
;                     ----,
;                     \
;     w = (u^T, v) =  /      u_n * v_n
;                     ----
;                    n = 1
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
; extern(C) float vsprv32fp256(ulong N, float* u, float* v);
;
; where
;   N = number of array components        --> rdi
;   u = address to 1st array operand      --> rsi
;   v = address to 2nd array operand      --> rdx
;   return result (float)                 --> xmm0 (low 4B)
; ____________________________________________________________________________
;
; author:       Stefan Wittwer, info@wittwer-datatools.ch
;
; known bugs:
; 1. ...
;
; ____________________________________________________________________________


section .text
  global vsprv32fp256
vsprv32fp256:
  enter         32,0
  vxorps        ymm0,ymm0               ; set result to 0
  xor           r8,r8                   ; dA = 0
  mov           r9,120                  ; N_c = 120 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage2                  ; true => go to stage 2
loop1:
  vmovaps       ymm1,[rsi+r8]
  vmovaps       ymm2,[rsi+r8+32]
  vmovaps       ymm3,[rsi+r8+64]
  vmovaps       ymm4,[rsi+r8+96]
  vmovaps       ymm5,[rsi+r8+128]
  vmovaps       ymm6,[rsi+r8+160]
  vmovaps       ymm7,[rsi+r8+192]
  vmovaps       ymm8,[rsi+r8+224]
  vmovaps       ymm9,[rsi+r8+256]
  vmovaps       ymm10,[rsi+r8+288]
  vmovaps       ymm11,[rsi+r8+320]
  vmovaps       ymm12,[rsi+r8+352]
  vmovaps       ymm13,[rsi+r8+384]
  vmovaps       ymm14,[rsi+r8+416]
  vmovaps       ymm15,[rsi+r8+448]
  vfmadd231ps   ymm0,ymm1,[rdx+r8]
  vfmadd231ps   ymm0,ymm2,[rdx+r8+32]
  vfmadd231ps   ymm0,ymm3,[rdx+r8+64]
  vfmadd231ps   ymm0,ymm4,[rdx+r8+96]
  vfmadd231ps   ymm0,ymm5,[rdx+r8+128]
  vfmadd231ps   ymm0,ymm6,[rdx+r8+160]
  vfmadd231ps   ymm0,ymm7,[rdx+r8+192]
  vfmadd231ps   ymm0,ymm8,[rdx+r8+224]
  vfmadd231ps   ymm0,ymm9,[rdx+r8+256]
  vfmadd231ps   ymm0,ymm10,[rdx+r8+288]
  vfmadd231ps   ymm0,ymm11,[rdx+r8+320]
  vfmadd231ps   ymm0,ymm12,[rdx+r8+352]
  vfmadd231ps   ymm0,ymm13,[rdx+r8+384]
  vfmadd231ps   ymm0,ymm14,[rdx+r8+416]
  vfmadd231ps   ymm0,ymm15,[rdx+r8+448]
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
  vfmadd231ps   ymm0,ymm1,[rdx+r8]      ; process looped stage 2
  add           r8,32                   ; dA += 1 * 8 * 4 byte
  add           r9,8                    ; N_c += 8 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop2                   ; true => loop stage 2
stage3:
  vextractf128  xmm1,ymm0,1             ; sum to xmm0 register
  addps         xmm0,xmm1
  sub           r9,4                    ; N_c = N_c - 8 + 4 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage4                  ; true => go to stage 4
loop3:
  vmovaps       xmm1,[rsi+r8]           ; load first operands
  vfmadd231ps   xmm0,xmm1,[rdx+r8]      ; process looped stage 3
  add           r8,16                   ; dA += 1 * 4 * 4 byte
  add           r9,4                    ; N_c += 4 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop3                   ; true => loop stage 3
stage4:
  sub           r9,3                    ; N_c = N_c - 4 + 1 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            return                  ; true => go to return
loop4:
  movss         xmm1,[rsi+r8]           ; load first operand
  mulss         xmm1,[rdx+r8]           ; process looped stage 4
  addss         xmm0,xmm1               ; write result
  add           r8,4                    ; dA += 1 * 1 * 4 byte
  inc           r9                      ; N_c += 1 component
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop4                   ; true => loop stage 4
return:
  haddps        xmm0,xmm0               ; return result
  haddps        xmm0,xmm0
  leave
  ret


; end of vsprv32fp256.asm
