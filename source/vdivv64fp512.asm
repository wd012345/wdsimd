; file:         vdivv64fp512.asm
;
; Assembly function that divides two 64bit floating point arrays with
; N components according to
;     w_{111...} = u_{111...} / v_{111...}
;     w_{211...} = u_{211...} / v_{211...}
;           .
;           .
;           .
;     w_{kmn...} = u_{kmn...} / v_{kmn...}
;
; The AVX512 registers and AVX512 instruction set is used. The function
; processes five loop stages, each processing
;     1. 32 zmm registers * 8 components = 256 components/loop
;     2.  1 zmm register  * 8 components =   8 components/loop
;     3.  1 ymm register  * 4 components =   4 components/loop
;     4.  1 xmm register  * 2 components =   2 components/loop
;     5.  1 xmm register  * 1 component  =   1 component/loop
;
; The 1st stage is looped while
;     N_c = (n_1 + 1) * 256 components <= N
; where n_1 is equal to the number of already processed loops of stage 1.
;
; The 2nd stage is looped while
;     N_c = (n_1 * 256 + (n_2 + 1) * 8) components <= N
; where n_2 is equal to the number of already processed loops of stage 2.
;
; The 3rd stage is looped while
;     N_c = (n_1 * 256 + n_2 * 8 + (n_3 + 1) * 4) components <= N
; where n_3 is equal to the number of already processed loops of stage 3.
;
; The 4th stage is looped while
;     N_c = (n_1 * 256 + n_2 * 8 + n_3 * 4 + (n_4 + 1) * 2) components <= N
; where n_4 is equal to the number of already processed loops of stage 4.
;
; The assembly function returns as soon as N array components are processed, 
; i.e.
;     (n_1 * 256 + n_2 * 8 + n_3 * 4 + n_4 * 2 + n_5) components == N.
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
; extern(C) void vdivv64fp512(ulong N, double* u, double* v, double* w);
;
; where
;   N = number of array components        --> rdi
;   u = address to 1st array operand      --> rsi
;   v = address to 2nd array operand      --> rdx
;   w = address to result array           --> rcx
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
  global vdivv64fp512
vdivv64fp512:
  enter         32,0
  xor           r8,r8                   ; dA = 0
  mov           r9,256                  ; N_c = 256 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage2                  ; true => go to stage 2
loop1:
  vmovapd       zmm0,[rsi+r8]
  vmovapd       zmm1,[rsi+r8+64]
  vmovapd       zmm2,[rsi+r8+128]
  vmovapd       zmm3,[rsi+r8+192]
  vmovapd       zmm4,[rsi+r8+256]
  vmovapd       zmm5,[rsi+r8+320]
  vmovapd       zmm6,[rsi+r8+384]
  vmovapd       zmm7,[rsi+r8+448]
  vmovapd       zmm8,[rsi+r8+512]
  vmovapd       zmm9,[rsi+r8+576]
  vmovapd       zmm10,[rsi+r8+640]
  vmovapd       zmm11,[rsi+r8+704]
  vmovapd       zmm12,[rsi+r8+768]
  vmovapd       zmm13,[rsi+r8+832]
  vmovapd       zmm14,[rsi+r8+896]
  vmovapd       zmm15,[rsi+r8+960]
  vmovapd       zmm16,[rsi+r8+1024]
  vmovapd       zmm17,[rsi+r8+1088]
  vmovapd       zmm18,[rsi+r8+1152]
  vmovapd       zmm19,[rsi+r8+1216]
  vmovapd       zmm20,[rsi+r8+1280]
  vmovapd       zmm21,[rsi+r8+1344]
  vmovapd       zmm22,[rsi+r8+1408]
  vmovapd       zmm23,[rsi+r8+1472]
  vmovapd       zmm24,[rsi+r8+1536]
  vmovapd       zmm25,[rsi+r8+1600]
  vmovapd       zmm26,[rsi+r8+1664]
  vmovapd       zmm27,[rsi+r8+1728]
  vmovapd       zmm28,[rsi+r8+1792]
  vmovapd       zmm29,[rsi+r8+1856]
  vmovapd       zmm30,[rsi+r8+1920]
  vmovapd       zmm31,[rsi+r8+1984]
  vdivpd        zmm0,zmm0,[rdx+r8]
  vdivpd        zmm1,zmm1,[rdx+r8+64]
  vdivpd        zmm2,zmm2,[rdx+r8+128]
  vdivpd        zmm3,zmm3,[rdx+r8+192]
  vdivpd        zmm4,zmm4,[rdx+r8+256]
  vdivpd        zmm5,zmm5,[rdx+r8+320]
  vdivpd        zmm6,zmm6,[rdx+r8+384]
  vdivpd        zmm7,zmm7,[rdx+r8+448]
  vdivpd        zmm8,zmm8,[rdx+r8+512]
  vdivpd        zmm9,zmm9,[rdx+r8+576]
  vdivpd        zmm10,zmm10,[rdx+r8+640]
  vdivpd        zmm11,zmm11,[rdx+r8+704]
  vdivpd        zmm12,zmm12,[rdx+r8+768]
  vdivpd        zmm13,zmm13,[rdx+r8+832]
  vdivpd        zmm14,zmm14,[rdx+r8+896]
  vdivpd        zmm15,zmm15,[rdx+r8+960]
  vdivpd        zmm16,zmm16,[rdx+r8+1024]
  vdivpd        zmm17,zmm17,[rdx+r8+1088]
  vdivpd        zmm18,zmm18,[rdx+r8+1152]
  vdivpd        zmm19,zmm19,[rdx+r8+1216]
  vdivpd        zmm20,zmm20,[rdx+r8+1280]
  vdivpd        zmm21,zmm21,[rdx+r8+1344]
  vdivpd        zmm22,zmm22,[rdx+r8+1408]
  vdivpd        zmm23,zmm23,[rdx+r8+1472]
  vdivpd        zmm24,zmm24,[rdx+r8+1536]
  vdivpd        zmm25,zmm25,[rdx+r8+1600]
  vdivpd        zmm26,zmm26,[rdx+r8+1664]
  vdivpd        zmm27,zmm27,[rdx+r8+1728]
  vdivpd        zmm28,zmm28,[rdx+r8+1792]
  vdivpd        zmm29,zmm29,[rdx+r8+1856]
  vdivpd        zmm30,zmm30,[rdx+r8+1920]
  vdivpd        zmm31,zmm31,[rdx+r8+1984]
  vmovapd       [rcx+r8],zmm0
  vmovapd       [rcx+r8+64],zmm1
  vmovapd       [rcx+r8+128],zmm2
  vmovapd       [rcx+r8+192],zmm3
  vmovapd       [rcx+r8+256],zmm4
  vmovapd       [rcx+r8+320],zmm5
  vmovapd       [rcx+r8+384],zmm6
  vmovapd       [rcx+r8+448],zmm7
  vmovapd       [rcx+r8+512],zmm8
  vmovapd       [rcx+r8+576],zmm9
  vmovapd       [rcx+r8+640],zmm10
  vmovapd       [rcx+r8+704],zmm11
  vmovapd       [rcx+r8+768],zmm12
  vmovapd       [rcx+r8+832],zmm13
  vmovapd       [rcx+r8+896],zmm14
  vmovapd       [rcx+r8+960],zmm15
  vmovapd       [rcx+r8+1024],zmm16
  vmovapd       [rcx+r8+1088],zmm17
  vmovapd       [rcx+r8+1152],zmm18
  vmovapd       [rcx+r8+1216],zmm19
  vmovapd       [rcx+r8+1280],zmm20
  vmovapd       [rcx+r8+1344],zmm21
  vmovapd       [rcx+r8+1408],zmm22
  vmovapd       [rcx+r8+1472],zmm23
  vmovapd       [rcx+r8+1536],zmm24
  vmovapd       [rcx+r8+1600],zmm25
  vmovapd       [rcx+r8+1664],zmm26
  vmovapd       [rcx+r8+1728],zmm27
  vmovapd       [rcx+r8+1792],zmm28
  vmovapd       [rcx+r8+1856],zmm29
  vmovapd       [rcx+r8+1920],zmm30
  vmovapd       [rcx+r8+1984],zmm31
  add           r8,2048                 ; dA += 32 * 8 * 8 byte
  add           r9,256                  ; N_c += 256 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop1                   ; true => loop stage 1
stage2:
  sub           r9,248                  ; N_c = N_c - 256 + 8 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage3                  ; true => go to stage 3
loop2:
  vmovapd       zmm1,[rsi+r8]           ; load first operands
  vdivpd        zmm0,zmm1,[rdx+r8]      ; process looped stage 1
  vmovapd       [rcx+r8],zmm0           ; write results
  add           r8,64                   ; dA += 1 * 8 * 8 byte
  add           r9,8                    ; N_c += 8 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop2                   ; true => loop stage 2
stage3:
  sub           r9,4                    ; N_c = N_c - 8 + 4 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage4                  ; true => go to stage 4
loop3:
  vmovapd       ymm1,[rsi+r8]           ; load first operands
  vdivpd        ymm0,ymm1,[rsi+r8]      ; process looped stage 3
  vmovapd       [rdx+r8],ymm0           ; write results
  add           r8,32                   ; dA += 1 * 4 * 8 byte
  add           r9,4                    ; N_c += 4 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop3                   ; true => loop stage 3
stage4:
  sub           r9,2                    ; N_c = N_c - 4 + 2 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage5                  ; true => go to stage 5
loop4:
  vmovapd       xmm1,[rsi+r8]           ; load first operands
  vdivpd        xmm0,xmm1,[rdx+r8]      ; process looped stage 4
  vmovapd       [rcx+r8],xmm0           ; write results
  add           r8,16                   ; dA += 1 * 2 * 8 byte
  add           r9,2                    ; N_c += 2 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop4                   ; true => loop stage 4
stage5:
  dec           r9                      ; N_c = N_c - 2 + 1 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            return                  ; true => go to return
loop5:
  movsd         xmm0,[rsi+r8]           ; load first operand
  divsd         xmm0,[rdx+r8]           ; process looped stage 5
  movsd         [rcx+r8],xmm0           ; write result
  add           r8,8                    ; dA += 1 * 1 * 8 byte
  inc           r9                      ; N_c += 1 component
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop5                   ; true => loop stage 5
return:
  leave
  ret


; end of vdivv64fp512.asm
