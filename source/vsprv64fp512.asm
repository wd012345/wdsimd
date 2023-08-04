; file:         vsprv64fp512.asm
;
; Assembly function that computes the dot product of two 64 bit floating point
; arrays with N components each according to
;
;                       N
;                     ----,
;                     \
;     w = (u^T, v) =  /      u_n * v_n
;                     ----
;                    n = 1
;
; The AVX512 registers and AVX512 instruction set is used. The function
; processes five loop stages, each processing
;     1. 31 zmm registers * 8 components = 248 components/loop
;     2.  1 zmm register  * 8 components =   8 components/loop
;     3.  1 ymm register  * 4 components =   4 components/loop
;     4.  1 xmm register  * 2 components =   2 components/loop
;     5.  1 xmm register  * 1 component  =   1 component/loop
;
; The 1st stage is looped while
;     N_c = (n_1 + 1) * 248 components <= N
; where n_1 is equal to the number of already processed loops of stage 1.
;
; The 2nd stage is looped while
;     N_c = (n_1 * 248 + (n_2 + 1) * 8) components <= N
; where n_2 is equal to the number of already processed loops of stage 2.
;
; The 3rd stage is looped while
;     N_c = (n_1 * 248 + n_2 * 8 + (n_3 + 1) * 4) components <= N
; where n_3 is equal to the number of already processed loops of stage 3.
;
; The 4th stage is looped while
;     N_c = (n_1 * 248 + n_2 * 8 + n_3 * 4 + (n_4 + 1) * 2) components <= N
; where n_4 is equal to the number of already processed loops of stage 4.
;
; The assembly function returns as soon as N array components are processed, 
; i.e.
;     (n_1 * 248 + n_2 * 8 + n_3 * 4 + n_4 * 2 + n_5) components == N.
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
; extern(C) double vsprv64fp512(ulong N, double* u, double* v);
;
; where
;   N = number of array components        --> rdi
;   u = address to 1st array operand      --> rsi
;   v = address to 2nd array operand      --> rdx
;   return result (double)                --> xmm0 (low 8B)
; ____________________________________________________________________________
;
; author:       Stefan Wittwer, info@wittwer-datatools.ch
;
; known bugs:
; 1. ...
;
; ____________________________________________________________________________


section .text
  global vsprv64fp512
vsprv64fp512:
  enter         32,0
  vxorps        zmm0,zmm0               ; set result to 0
  xor           r8,r8                   ; dA = 0
  mov           r9,248                  ; N_c = 248 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage2                  ; true => go to stage 2
loop1:
  vmovapd       zmm1,[rsi+r8]
  vmovapd       zmm2,[rsi+r8+64]
  vmovapd       zmm3,[rsi+r8+128]
  vmovapd       zmm4,[rsi+r8+192]
  vmovapd       zmm5,[rsi+r8+256]
  vmovapd       zmm6,[rsi+r8+320]
  vmovapd       zmm7,[rsi+r8+384]
  vmovapd       zmm8,[rsi+r8+448]
  vmovapd       zmm9,[rsi+r8+512]
  vmovapd       zmm10,[rsi+r8+576]
  vmovapd       zmm11,[rsi+r8+640]
  vmovapd       zmm12,[rsi+r8+704]
  vmovapd       zmm13,[rsi+r8+768]
  vmovapd       zmm14,[rsi+r8+832]
  vmovapd       zmm15,[rsi+r8+896]
  vmovapd       zmm16,[rsi+r8+960]
  vmovapd       zmm17,[rsi+r8+1024]
  vmovapd       zmm18,[rsi+r8+1088]
  vmovapd       zmm19,[rsi+r8+1152]
  vmovapd       zmm20,[rsi+r8+1216]
  vmovapd       zmm21,[rsi+r8+1280]
  vmovapd       zmm22,[rsi+r8+1344]
  vmovapd       zmm23,[rsi+r8+1408]
  vmovapd       zmm24,[rsi+r8+1472]
  vmovapd       zmm25,[rsi+r8+1536]
  vmovapd       zmm26,[rsi+r8+1600]
  vmovapd       zmm27,[rsi+r8+1664]
  vmovapd       zmm28,[rsi+r8+1728]
  vmovapd       zmm29,[rsi+r8+1792]
  vmovapd       zmm30,[rsi+r8+1856]
  vmovapd       zmm31,[rsi+r8+1920]
  vfmadd231pd   zmm0,zmm0,[rdx+r8]
  vfmadd231pd   zmm0,zmm1,[rdx+r8+64]
  vfmadd231pd   zmm0,zmm2,[rdx+r8+128]
  vfmadd231pd   zmm0,zmm3,[rdx+r8+192]
  vfmadd231pd   zmm0,zmm4,[rdx+r8+256]
  vfmadd231pd   zmm0,zmm5,[rdx+r8+320]
  vfmadd231pd   zmm0,zmm6,[rdx+r8+384]
  vfmadd231pd   zmm0,zmm7,[rdx+r8+448]
  vfmadd231pd   zmm0,zmm8,[rdx+r8+512]
  vfmadd231pd   zmm0,zmm9,[rdx+r8+576]
  vfmadd231pd   zmm0,zmm10,[rdx+r8+640]
  vfmadd231pd   zmm0,zmm11,[rdx+r8+704]
  vfmadd231pd   zmm0,zmm12,[rdx+r8+768]
  vfmadd231pd   zmm0,zmm13,[rdx+r8+832]
  vfmadd231pd   zmm0,zmm14,[rdx+r8+896]
  vfmadd231pd   zmm0,zmm15,[rdx+r8+960]
  vfmadd231pd   zmm0,zmm16,[rdx+r8+1024]
  vfmadd231pd   zmm0,zmm17,[rdx+r8+1088]
  vfmadd231pd   zmm0,zmm18,[rdx+r8+1152]
  vfmadd231pd   zmm0,zmm19,[rdx+r8+1216]
  vfmadd231pd   zmm0,zmm20,[rdx+r8+1280]
  vfmadd231pd   zmm0,zmm21,[rdx+r8+1344]
  vfmadd231pd   zmm0,zmm22,[rdx+r8+1408]
  vfmadd231pd   zmm0,zmm23,[rdx+r8+1472]
  vfmadd231pd   zmm0,zmm24,[rdx+r8+1536]
  vfmadd231pd   zmm0,zmm25,[rdx+r8+1600]
  vfmadd231pd   zmm0,zmm26,[rdx+r8+1664]
  vfmadd231pd   zmm0,zmm27,[rdx+r8+1728]
  vfmadd231pd   zmm0,zmm28,[rdx+r8+1792]
  vfmadd231pd   zmm0,zmm29,[rdx+r8+1856]
  vfmadd231pd   zmm0,zmm30,[rdx+r8+1920]
  add           r8,1984                 ; dA += 31 * 8 * 8 byte
  add           r9,248                  ; N_c += 248 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop1                   ; true => loop stage 1
stage2:
  sub           r9,240                  ; N_c = N_c - 248 + 8 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage3                  ; true => go to stage 3
loop2:
  vmovapd       zmm1,[rsi+r8]           ; load first operands
  vfmadd231pd   zmm0,zmm1,[rdx+r8]      ; process looped stage 1
  vmovapd       [rcx+r8],zmm0           ; write results
  add           r8,64                   ; dA += 1 * 8 * 8 byte
  add           r9,8                    ; N_c += 8 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop2                   ; true => loop stage 2
stage3:
  vextractf64x4 ymm1,zmm0,1             ; sum to ymm0 register
  vaddpd        ymm0,ymm1
  sub           r9,4                    ; N_c = N_c - 8 + 4 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage4                  ; true => go to stage 4
loop3:
  vmovapd       ymm1,[rsi+r8]           ; load first operands
  vfmadd231pd   ymm0,ymm1,[rsi+r8]      ; process looped stage 3
  add           r8,32                   ; dA += 1 * 4 * 8 byte
  add           r9,4                    ; N_c += 4 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop3                   ; true => loop stage 3
stage4:
  vextractf128  xmm1,ymm0,1             ; sum to xmm0 register
  addpd         xmm0,xmm1
  sub           r9,2                    ; N_c = N_c - 4 + 2 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage5                  ; true => go to stage 5
loop4:
  vmovapd       xmm1,[rsi+r8]           ; load first operands
  vfmadd231pd   xmm0,xmm1,[rdx+r8]      ; process looped stage 4
  add           r8,16                   ; dA += 1 * 2 * 8 byte
  add           r9,2                    ; N_c += 2 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop4                   ; true => loop stage 4
stage5:
  dec           r9                      ; N_c = N_c - 2 + 1 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            return                  ; true => go to return
loop5:
  movsd         xmm1,[rsi+r8]           ; load first operand
  mulsd         xmm1,[rdx+r8]           ; process looped stage 5
  addsd         xmm0,xmm1               ; write result
  add           r8,8                    ; dA += 1 * 1 * 8 byte
  inc           r9                      ; N_c += 1 component
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop5                   ; true => loop stage 5
return:
  haddpd        xmm0,xmm0               ; return result
  haddpd        xmm0,xmm0
  leave
  ret


; end of vsprv64fp512.asm
