; file:         vdivv32fp512.asm
;
; Assembly function that divides two 32bit floating point arrays with
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
;     1. 32 zmm registers * 16 components = 512 components/loop
;     2.  1 zmm register  * 16 components =  16 components/loop
;     3.  1 ymm register  *  8 components =   8 components/loop
;     4.  1 xmm register  *  4 components =   4 components/loop
;     5.  1 xmm register  *  1 component  =   1 component/loop
;
; The 1st stage is looped while
;     N_c = (n_1 + 1) * 512 components <= N
; where n_1 is equal to the number of already processed loops of stage 1.
;
; The 2nd stage is looped while
;     N_c = (n_1 * 512 + (n_2 + 1) * 16) components <= N
; where n_2 is equal to the number of already processed loops of stage 2.
;
; The 3rd stage is looped while
;     N_c = (n_1 * 512 + n_2 * 16 + (n_3 + 1) * 8) components <= N
; where n_3 is equal to the number of already processed loops of stage 3.
;
; The 4th stage is looped while
;     N_c = (n_1 * 512 + n_2 * 16 + n_3 * 8 + (n_4 + 1) * 4) components <= N
; where n_4 is equal to the number of already processed loops of stage 4.
;
; The assembly function returns as soon as N array components are processed, 
; i.e.
;     (n_1 * 512 + n_2 * 16 + n_3 * 8 + n_4 * 4 + n_5) components == N.
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
; extern(C) void vdivv32fp512(ulong N, float* u, float* v, float* w);
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
  global vdivv32fp512
vdivv32fp512:
  enter         32,0
  xor           r8,r8                   ; dA = 0
  mov           r9,512                  ; N_c = 512 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage2                  ; true => go to stage 2
loop1:
  vmovaps       zmm0,[rsi+r8]
  vmovaps       zmm1,[rsi+r8+64]
  vmovaps       zmm2,[rsi+r8+128]
  vmovaps       zmm3,[rsi+r8+192]
  vmovaps       zmm4,[rsi+r8+256]
  vmovaps       zmm5,[rsi+r8+320]
  vmovaps       zmm6,[rsi+r8+384]
  vmovaps       zmm7,[rsi+r8+448]
  vmovaps       zmm8,[rsi+r8+512]
  vmovaps       zmm9,[rsi+r8+576]
  vmovaps       zmm10,[rsi+r8+640]
  vmovaps       zmm11,[rsi+r8+704]
  vmovaps       zmm12,[rsi+r8+768]
  vmovaps       zmm13,[rsi+r8+832]
  vmovaps       zmm14,[rsi+r8+896]
  vmovaps       zmm15,[rsi+r8+960]
  vmovaps       zmm16,[rsi+r8+1024]
  vmovaps       zmm17,[rsi+r8+1088]
  vmovaps       zmm18,[rsi+r8+1152]
  vmovaps       zmm19,[rsi+r8+1216]
  vmovaps       zmm20,[rsi+r8+1280]
  vmovaps       zmm21,[rsi+r8+1344]
  vmovaps       zmm22,[rsi+r8+1408]
  vmovaps       zmm23,[rsi+r8+1472]
  vmovaps       zmm24,[rsi+r8+1536]
  vmovaps       zmm25,[rsi+r8+1600]
  vmovaps       zmm26,[rsi+r8+1664]
  vmovaps       zmm27,[rsi+r8+1728]
  vmovaps       zmm28,[rsi+r8+1792]
  vmovaps       zmm29,[rsi+r8+1856]
  vmovaps       zmm30,[rsi+r8+1920]
  vmovaps       zmm31,[rsi+r8+1984]
  vdivps        zmm0,zmm0,[rdx+r8]
  vdivps        zmm1,zmm1,[rdx+r8+64]
  vdivps        zmm2,zmm2,[rdx+r8+128]
  vdivps        zmm3,zmm3,[rdx+r8+192]
  vdivps        zmm4,zmm4,[rdx+r8+256]
  vdivps        zmm5,zmm5,[rdx+r8+320]
  vdivps        zmm6,zmm6,[rdx+r8+384]
  vdivps        zmm7,zmm7,[rdx+r8+448]
  vdivps        zmm8,zmm8,[rdx+r8+512]
  vdivps        zmm9,zmm9,[rdx+r8+576]
  vdivps        zmm10,zmm10,[rdx+r8+640]
  vdivps        zmm11,zmm11,[rdx+r8+704]
  vdivps        zmm12,zmm12,[rdx+r8+768]
  vdivps        zmm13,zmm13,[rdx+r8+832]
  vdivps        zmm14,zmm14,[rdx+r8+896]
  vdivps        zmm15,zmm15,[rdx+r8+960]
  vdivps        zmm16,zmm16,[rdx+r8+1024]
  vdivps        zmm17,zmm17,[rdx+r8+1088]
  vdivps        zmm18,zmm18,[rdx+r8+1152]
  vdivps        zmm19,zmm19,[rdx+r8+1216]
  vdivps        zmm20,zmm20,[rdx+r8+1280]
  vdivps        zmm21,zmm21,[rdx+r8+1344]
  vdivps        zmm22,zmm22,[rdx+r8+1408]
  vdivps        zmm23,zmm23,[rdx+r8+1472]
  vdivps        zmm24,zmm24,[rdx+r8+1536]
  vdivps        zmm25,zmm25,[rdx+r8+1600]
  vdivps        zmm26,zmm26,[rdx+r8+1664]
  vdivps        zmm27,zmm27,[rdx+r8+1728]
  vdivps        zmm28,zmm28,[rdx+r8+1792]
  vdivps        zmm29,zmm29,[rdx+r8+1856]
  vdivps        zmm30,zmm30,[rdx+r8+1920]
  vdivps        zmm31,zmm31,[rdx+r8+1984]
  vmovaps       [rcx+r8],zmm0
  vmovaps       [rcx+r8+64],zmm1
  vmovaps       [rcx+r8+128],zmm2
  vmovaps       [rcx+r8+192],zmm3
  vmovaps       [rcx+r8+256],zmm4
  vmovaps       [rcx+r8+320],zmm5
  vmovaps       [rcx+r8+384],zmm6
  vmovaps       [rcx+r8+448],zmm7
  vmovaps       [rcx+r8+512],zmm8
  vmovaps       [rcx+r8+576],zmm9
  vmovaps       [rcx+r8+640],zmm10
  vmovaps       [rcx+r8+704],zmm11
  vmovaps       [rcx+r8+768],zmm12
  vmovaps       [rcx+r8+832],zmm13
  vmovaps       [rcx+r8+896],zmm14
  vmovaps       [rcx+r8+960],zmm15
  vmovaps       [rcx+r8+1024],zmm16
  vmovaps       [rcx+r8+1088],zmm17
  vmovaps       [rcx+r8+1152],zmm18
  vmovaps       [rcx+r8+1216],zmm19
  vmovaps       [rcx+r8+1280],zmm20
  vmovaps       [rcx+r8+1344],zmm21
  vmovaps       [rcx+r8+1408],zmm22
  vmovaps       [rcx+r8+1472],zmm23
  vmovaps       [rcx+r8+1536],zmm24
  vmovaps       [rcx+r8+1600],zmm25
  vmovaps       [rcx+r8+1664],zmm26
  vmovaps       [rcx+r8+1728],zmm27
  vmovaps       [rcx+r8+1792],zmm28
  vmovaps       [rcx+r8+1856],zmm29
  vmovaps       [rcx+r8+1920],zmm30
  vmovaps       [rcx+r8+1984],zmm31
  add           r8,2048                 ; dA += 32 * 16 * 4 byte
  add           r9,512                  ; N_c += 512 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop1                   ; true => loop stage 1
stage2:
  sub           r9,496                  ; N_c = N_c - 512 + 16 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage3                  ; true => go to stage 3
loop2:
  vmovaps       zmm1,[rsi+r8]           ; load first operands
  vdivps        zmm0,zmm1,[rdx+r8]      ; process looped stage 1
  vmovaps       [rcx+r8],zmm0           ; write results
  add           r8,64                   ; dA += 1 * 16 * 4 byte
  add           r9,16                   ; N_c += 16 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop2                   ; true => loop stage 2
stage3:
  sub           r9,8                    ; N_c = N_c - 16 + 8 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage4                  ; true => go to stage 4
loop3:
  vmovaps       ymm1,[rsi+r8]           ; load first operands
  vdivps        ymm0,ymm1,[rdx+r8]      ; process looped stage 3
  vmovaps       [rcx+r8],ymm0           ; write results
  add           r8,32                   ; dA += 1 * 8 * 4 byte
  add           r9,8                    ; N_c += 8 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop3                   ; true => loop stage 3
stage4:
  sub           r9,4                    ; N_c = N_c - 8 + 4 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage5                  ; true => go to stage 5
loop4:
  vmovaps       xmm1,[rsi+r8]           ; load first operands
  vdivps        xmm0,xmm1,[rdx+r8]      ; process looped stage 4
  vmovaps       [rcx+r8],xmm0           ; write results
  add           r8,16                   ; dA += 1 * 4 * 4 byte
  add           r9,4                    ; N_c += 4 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop4                   ; true => loop stage 4
stage5:
  sub           r9,3                    ; N_c = N_c - 4 + 1 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            return                  ; true => go to return
loop5:
  movss         xmm0,[rsi+r8]           ; load first operand
  divss         xmm0,[rdx+r8]           ; process looped stage 5
  movss         [rcx+r8],xmm0           ; write result
  add           r8,4                    ; dA += 1 * 1 * 4 byte
  inc           r9                      ; N_c += 1 component
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop5                   ; true => loop stage 5
return:
  leave
  ret


; end of vdivv32fp512.asm
