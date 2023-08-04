; file:         vsprv64fp256.asm
;
; Assembly function that computes the dot product of two 64 bit floating point
; arrays with N components according to
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
;     1. 15 ymm registers * 4 components = 60 components/loop
;     2.  1 ymm register  * 4 components =  4 components/loop
;     3.  1 xmm register  * 2 components =  2 components/loop
;     4.  1 xmm register  * 1 component  =  1 component/loop
;
; The first stage is looped while
;     N_c = (n_1 + 1) * 60 components <= N
; where n_1 is equal to the number of already processed loops of stage 1, and
; n_1 + 1 is equal to the number of already processed loops plus one loop of
; stage 1.
;
; The second stage is looped while
;     N_c = (n_1 * 60 + (n_2 + 1) * 4) components <= N
; where n_2 is equal to the number of already processed loops of stage 2, and
; n_2 + 1 is equal to the number of already processed loops plus one loop of
; stage 2.
;
; The third stage is looped while
;     N_c = (n_1 * 60 + (n_2 + 1) * 4 + (n_3 + 1) * 2) components <= N
; where n_3 is equal to the number of already processed loops of stage 3, and
; n_3 + 1 is equal to the number of already processed loops plus one loop of
; stage 3.
;
; The assembly function returns as soon as N array components are processed, 
; i.e.
;     N_c = (n_1 * 60 + n_2 * 4 + n_3 * 2 + n_4) components == N.
; The number N_c(n_1, n_2, n_3, n_4) of components being processed in the
; next loop is tracked in r9. Stages larger than the number of unprocessed
; components are skipped.
;
; The address offset dA(n_1, n_2, n_3, n_4) of the components processed in
; the most recent loop is tracked in r8. It is computed with
;     dA = 8N_c [B] <= 8N [B]
; in the case of double precision vectors.
;
; synopsis of the caller D source code:
; extern(C) double vsprv64fp256(ulong N, double* u, double* v);
;
; where
;   N = number of vector components      --> rdi
;   u = address of 1st vector operand   --> rsi
;   v = address of 2nd vector operand   --> rdx
;   return result (double)              --> xmm0
; ____________________________________________________________________________
;
; author:       Stefan Wittwer, info@wittwer-datatools.ch
;
; known bugs:
; 1. ...
;
; ____________________________________________________________________________


section .text
  global vsprv64fp256
vsprv64fp256:
  enter         32,0
  vxorpd        ymm0,ymm0                   ; set result to 0
  xor           r8,r8                   ; dA = 0
  mov           r9,60                   ; N_c = 60 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage2                  ; true => go to stage 2
loop1:
  vmovapd       ymm1,[rsi+r8]
  vmovapd       ymm2,[rsi+r8+32]
  vmovapd       ymm3,[rsi+r8+64]
  vmovapd       ymm4,[rsi+r8+96]
  vmovapd       ymm5,[rsi+r8+128]
  vmovapd       ymm6,[rsi+r8+160]
  vmovapd       ymm7,[rsi+r8+192]
  vmovapd       ymm8,[rsi+r8+224]
  vmovapd       ymm9,[rsi+r8+256]
  vmovapd       ymm10,[rsi+r8+288]
  vmovapd       ymm11,[rsi+r8+320]
  vmovapd       ymm12,[rsi+r8+352]
  vmovapd       ymm13,[rsi+r8+384]
  vmovapd       ymm14,[rsi+r8+416]
  vmovapd       ymm15,[rsi+r8+448]
  vfmadd231pd   ymm0,ymm1,[rdx+r8]
  vfmadd231pd   ymm0,ymm2,[rdx+r8+32]
  vfmadd231pd   ymm0,ymm3,[rdx+r8+64]
  vfmadd231pd   ymm0,ymm4,[rdx+r8+96]
  vfmadd231pd   ymm0,ymm5,[rdx+r8+128]
  vfmadd231pd   ymm0,ymm6,[rdx+r8+160]
  vfmadd231pd   ymm0,ymm7,[rdx+r8+192]
  vfmadd231pd   ymm0,ymm8,[rdx+r8+224]
  vfmadd231pd   ymm0,ymm9,[rdx+r8+256]
  vfmadd231pd   ymm0,ymm10,[rdx+r8+288]
  vfmadd231pd   ymm0,ymm11,[rdx+r8+320]
  vfmadd231pd   ymm0,ymm12,[rdx+r8+352]
  vfmadd231pd   ymm0,ymm13,[rdx+r8+384]
  vfmadd231pd   ymm0,ymm14,[rdx+r8+416]
  vfmadd231pd   ymm0,ymm15,[rdx+r8+448]
  add           r8,480                  ; dA += 15 * 4 * 8 byte
  add           r9,60                   ; N_c += 60 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop1                   ; true => loop stage 1
stage2:
  sub           r9,56                   ; N_c = N_c - 60 + 4 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage3                  ; true => go to stage 3
loop2:
  vmovapd       ymm1,[rsi+r8]           ; load first operands
  vfmadd231pd   ymm0,ymm1,[rdx+r8]      ; process looped stage 2
  add           r8,32                   ; dA += 1 * 4 * 8 byte
  add           r9,4                    ; N_c += 4 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop2                   ; true => loop stage 2
stage3:
  vextractf128  xmm1,ymm0,1             ; sum to xmm0 register
  addpd         xmm0,xmm1
  sub           r9,2                    ; N_c = N_c - 4 + 2 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage4                  ; true => go to stage 4
loop3:
  vmovapd       xmm1,[rsi+r8]           ; load first operand
  vfmadd231pd   xmm0,xmm1,[rdx+r8]      ; process looped stage 3
  add           r8,16                   ; dA += 1 * 2 * 8 byte
  add           r9,2                    ; N_f += 2 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop3                   ; true => loop stage 3
stage4:
  dec           r9                      ; N_c = N_c - 2 + 1 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            return                  ; true => go to return
loop4:
  movsd         xmm1,[rsi+r8]           ; load first operand
  mulsd         xmm1,[rdx+r8]           ; process looped stage 4
  addsd         xmm0,xmm1               ; write result
  add           r8,8                    ; dA += 1 * 1 * 8 byte
  inc           r9                      ; N_c += 1 component
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop4                   ; true => loop stage 4
return:
  haddpd        xmm0,xmm0                   ; return result
  leave
  ret


; end of vsprv64fp256.asm
