; file:         vequs32fp512.asm
;
; Assembly function that assigns a 32bit floating point scalar to
; N 32bit floating point array components according to
;     w_{111...} = s
;     w_{211...} = s
;           .
;           .
;           .
;     w_{kmn...} = s
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
; extern(C) void vequs32fp512(ulong N, float s, float* w);
;
; where
;   N = number of array components        --> rdi
;   s = single precision scalar           --> xmm0
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
  global vequs32fp512
vequs32fp512:
  enter         32,0
  xor           r8,r8                   ; dA = 0
  mov           r9,512                  ; N_c = 512 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage2                  ; true => go to stage 2
loop1:
  vbroadcastss  zmm0,xmm0
  vbroadcastss  zmm1,xmm0
  vbroadcastss  zmm2,xmm0
  vbroadcastss  zmm3,xmm0
  vbroadcastss  zmm4,xmm0
  vbroadcastss  zmm5,xmm0
  vbroadcastss  zmm6,xmm0
  vbroadcastss  zmm7,xmm0
  vbroadcastss  zmm8,xmm0
  vbroadcastss  zmm9,xmm0
  vbroadcastss  zmm10,xmm0
  vbroadcastss  zmm11,xmm0
  vbroadcastss  zmm12,xmm0
  vbroadcastss  zmm13,xmm0
  vbroadcastss  zmm14,xmm0
  vbroadcastss  zmm15,xmm0
  vbroadcastss  zmm16,xmm0
  vbroadcastss  zmm17,xmm0
  vbroadcastss  zmm18,xmm0
  vbroadcastss  zmm19,xmm0
  vbroadcastss  zmm20,xmm0
  vbroadcastss  zmm21,xmm0
  vbroadcastss  zmm22,xmm0
  vbroadcastss  zmm23,xmm0
  vbroadcastss  zmm24,xmm0
  vbroadcastss  zmm25,xmm0
  vbroadcastss  zmm26,xmm0
  vbroadcastss  zmm27,xmm0
  vbroadcastss  zmm28,xmm0
  vbroadcastss  zmm29,xmm0
  vbroadcastss  zmm30,xmm0
  vbroadcastss  zmm31,xmm0
  vmovaps       [rsi+r8],zmm0
  vmovaps       [rsi+r8+64],zmm1
  vmovaps       [rsi+r8+128],zmm2
  vmovaps       [rsi+r8+192],zmm3
  vmovaps       [rsi+r8+256],zmm4
  vmovaps       [rsi+r8+320],zmm5
  vmovaps       [rsi+r8+384],zmm6
  vmovaps       [rsi+r8+448],zmm7
  vmovaps       [rsi+r8+512],zmm8
  vmovaps       [rsi+r8+576],zmm9
  vmovaps       [rsi+r8+640],zmm10
  vmovaps       [rsi+r8+704],zmm11
  vmovaps       [rsi+r8+768],zmm12
  vmovaps       [rsi+r8+832],zmm13
  vmovaps       [rsi+r8+896],zmm14
  vmovaps       [rsi+r8+960],zmm15
  vmovaps       [rsi+r8+1024],zmm16
  vmovaps       [rsi+r8+1088],zmm17
  vmovaps       [rsi+r8+1152],zmm18
  vmovaps       [rsi+r8+1216],zmm19
  vmovaps       [rsi+r8+1280],zmm20
  vmovaps       [rsi+r8+1344],zmm21
  vmovaps       [rsi+r8+1408],zmm22
  vmovaps       [rsi+r8+1472],zmm23
  vmovaps       [rsi+r8+1536],zmm24
  vmovaps       [rsi+r8+1600],zmm25
  vmovaps       [rsi+r8+1664],zmm26
  vmovaps       [rsi+r8+1728],zmm27
  vmovaps       [rsi+r8+1792],zmm28
  vmovaps       [rsi+r8+1856],zmm29
  vmovaps       [rsi+r8+1920],zmm30
  vmovaps       [rsi+r8+1984],zmm31
  add           r8,2048                 ; dA += 32 * 16 * 4 byte
  add           r9,512                  ; N_c += 512 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop1                   ; true => loop stage 1
stage2:
  sub           r9,496                  ; N_c = N_c - 512 + 16 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage3                  ; true => go to stage 3
loop2:
  vbroadcastss  zmm0,xmm0               ; process looped stage 1
  vmovaps       [rsi+r8],zmm0           ; write results
  add           r8,64                   ; dA += 1 * 16 * 4 byte
  add           r9,16                   ; N_c += 16 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop2                   ; true => loop stage 2
stage3:
  sub           r9,8                    ; N_c = N_c - 16 + 8 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage4                  ; true => go to stage 4
loop3:
  vbroadcastss  ymm0,xmm0               ; process looped stage 3
  vmovaps       [rsi+r8],ymm0           ; write results
  add           r8,32                   ; dA += 1 * 8 * 4 byte
  add           r9,8                    ; N_c += 8 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop3                   ; true => loop stage 3
stage4:
  sub           r9,4                    ; N_c = N_c - 8 + 4 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage5                  ; true => go to stage 5
loop4:
  vbroadcastss  xmm0,xmm0               ; process looped stage 4
  vmovaps       [rsi+r8],xmm0           ; write results
  add           r8,16                   ; dA += 1 * 4 * 4 byte
  add           r9,4                    ; N_c += 4 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop4                   ; true => loop stage 4
stage5:
  sub           r9,3                    ; N_c = N_c - 4 + 1 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            return                  ; true => go to return
loop5:
  movss         [rsi+r8],xmm0           ; write result
  add           r8,4                    ; dA += 1 * 1 * 4 byte
  inc           r9                      ; N_c += 1 component
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop5                   ; true => loop stage 5
return:
  leave
  ret


; end of vequs32fp512.asm
