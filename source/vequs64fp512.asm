; file:         vequs64fp512.asm
;
; Assembly function that assigns a 64bit floating point scalar to
; N 64bit floating point array components according to
;     w_{111...} = s
;     w_{211...} = s
;           .
;           .
;           .
;     w_{kmn...} = s
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
;     N_c = (n_1 * 256+ n_2 * 8 + n_3 * 4 + (n_4 + 1) * 2) components <= N
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
; extern(C) void vequs64fp512(ulong N, double s, double* w);
;
; where
;   N = number of array components        --> rdi
;   s = double precision scalar           --> xmm0
;   w = address to result array           --> rsi
; ____________________________________________________________________________
;
; author:       Stefan Wittwer, info@wittwer-datatools.ch
;
; known bugs:
; 1. ...
;
; ____________________________________________________________________________


section .text
  global vequs64fp512
vequs64fp512:
  enter         32,0
  xor           r8,r8                   ; dA = 0
  mov           r9,256                  ; N_c = 256 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage2                  ; true => go to stage 2
loop1:
  vbroadcastsd  zmm0,xmm0
  vbroadcastsd  zmm1,xmm0
  vbroadcastsd  zmm2,xmm0
  vbroadcastsd  zmm3,xmm0
  vbroadcastsd  zmm4,xmm0
  vbroadcastsd  zmm5,xmm0
  vbroadcastsd  zmm6,xmm0
  vbroadcastsd  zmm7,xmm0
  vbroadcastsd  zmm8,xmm0
  vbroadcastsd  zmm9,xmm0
  vbroadcastsd  zmm10,xmm0
  vbroadcastsd  zmm11,xmm0
  vbroadcastsd  zmm12,xmm0
  vbroadcastsd  zmm13,xmm0
  vbroadcastsd  zmm14,xmm0
  vbroadcastsd  zmm15,xmm0
  vbroadcastsd  zmm16,xmm0
  vbroadcastsd  zmm17,xmm0
  vbroadcastsd  zmm18,xmm0
  vbroadcastsd  zmm19,xmm0
  vbroadcastsd  zmm20,xmm0
  vbroadcastsd  zmm21,xmm0
  vbroadcastsd  zmm22,xmm0
  vbroadcastsd  zmm23,xmm0
  vbroadcastsd  zmm24,xmm0
  vbroadcastsd  zmm25,xmm0
  vbroadcastsd  zmm26,xmm0
  vbroadcastsd  zmm27,xmm0
  vbroadcastsd  zmm28,xmm0
  vbroadcastsd  zmm29,xmm0
  vbroadcastsd  zmm30,xmm0
  vbroadcastsd  zmm31,xmm0
  vmovapd       [rsi+r8],zmm0
  vmovapd       [rsi+r8+64],zmm1
  vmovapd       [rsi+r8+128],zmm2
  vmovapd       [rsi+r8+192],zmm3
  vmovapd       [rsi+r8+256],zmm4
  vmovapd       [rsi+r8+320],zmm5
  vmovapd       [rsi+r8+384],zmm6
  vmovapd       [rsi+r8+448],zmm7
  vmovapd       [rsi+r8+512],zmm8
  vmovapd       [rsi+r8+576],zmm9
  vmovapd       [rsi+r8+640],zmm10
  vmovapd       [rsi+r8+704],zmm11
  vmovapd       [rsi+r8+768],zmm12
  vmovapd       [rsi+r8+832],zmm13
  vmovapd       [rsi+r8+896],zmm14
  vmovapd       [rsi+r8+960],zmm15
  vmovapd       [rsi+r8+1024],zmm16
  vmovapd       [rsi+r8+1088],zmm17
  vmovapd       [rsi+r8+1152],zmm18
  vmovapd       [rsi+r8+1216],zmm19
  vmovapd       [rsi+r8+1280],zmm20
  vmovapd       [rsi+r8+1344],zmm21
  vmovapd       [rsi+r8+1408],zmm22
  vmovapd       [rsi+r8+1472],zmm23
  vmovapd       [rsi+r8+1536],zmm24
  vmovapd       [rsi+r8+1600],zmm25
  vmovapd       [rsi+r8+1664],zmm26
  vmovapd       [rsi+r8+1728],zmm27
  vmovapd       [rsi+r8+1792],zmm28
  vmovapd       [rsi+r8+1856],zmm29
  vmovapd       [rsi+r8+1920],zmm30
  vmovapd       [rsi+r8+1984],zmm30
  add           r8,2048                 ; dA += 32 * 8 * 8 byte
  add           r9,256                  ; N_c += 256 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop1                   ; true => loop stage 1
stage2:
  sub           r9,248                  ; N_c = N_c - 256 + 8 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage3                  ; true => go to stage 3
loop2:
  vbroadcastsd  zmm0,xmm0               ; process looped stage 1
  vmovapd       [rsi+r8],zmm0           ; write results
  add           r8,64                   ; dA += 1 * 8 * 8 byte
  add           r9,8                    ; N_c += 8 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop2                   ; true => loop stage 2
stage3:
  sub           r9,4                    ; N_c = N_c - 8 + 4 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage4                  ; true => go to stage 4
loop3:
  vbroadcastsd  ymm0,xmm0               ; process looped stage 3
  vmovapd       [rsi+r8],ymm0           ; write results
  add           r8,32                   ; dA += 1 * 4 * 8 byte
  add           r9,4                    ; N_c += 4 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop3                   ; true => loop stage 3
stage4:
  sub           r9,2                    ; N_c = N_c - 4 + 2 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage5                  ; true => go to stage 5
loop4:
  vbroadcastsd  ymm0,xmm0               ; process looped stage 4
  vmovapd       [rsi+r8],xmm0           ; write results
  add           r8,16                   ; dA += 1 * 2 * 8 byte
  add           r9,2                    ; N_c += 2 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop4                   ; true => loop stage 4
stage5:
  dec           r9                      ; N_c = N_c - 2 + 1 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            return                  ; true => go to return
loop5:
  movsd         [rsi+r8],xmm0           ; write result
  add           r8,8                    ; dA += 1 * 1 * 8 byte
  inc           r9                      ; N_c += 1 component
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop5                   ; true => loop stage 5
return:
  leave
  ret


; end of vequs64fp512.asm
