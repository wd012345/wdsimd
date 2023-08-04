; file:         vequs32fp256.asm
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
; The AVX2 registers and AVX2 instruction set is used. The function
; processes four looped stages, each processing
;     1. 16 ymm registers * 8 components = 128 components/loop
;     2.  1 ymm register  * 8 components =   8 components/loop
;     3.  1 xmm register  * 4 components =   4 components/loop
;     4.  1 xmm register  * 1 component  =   1 component/loop
;
; The first stage is looped while
;     N_c = (n_1 + 1) * 128 components <= N
; where n_1 is equal to the number of already processed loops of stage 1, and
; n_1 + 1 is equal to the number of already processed loops plus one loop of
; stage 1.
;
; The second stage is looped while
;     N_c = (n_1 * 128 + (n_2 + 1) * 8) components <= N
; where n_2 is equal to the number of already processed loops of stage 2, and
; n_2 + 1 is equal to the number of already processed loops plus one loop of
; stage 2.
;
; The third stage is looped while
;     N_c = (n_1 * 128 + (n_2 + 1) * 8 + (n_3 + 1) * 4) components <= N
; where n_3 is equal to the number of already processed loops of stage 3, and
; n_3 + 1 is equal to the number of already processed loops plus one loop of
; stage 3.
;
; The assembly function returns as soon as N array components are processed, 
; i.e.
;     N_c = (n_1 * 128 + n_2 * 8 + n_3 * 4 + n_4) components == N.
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
; extern(C) void vequs32fp256(ulong N, float s, float* w);
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
  global vequs32fp256
vequs32fp256:
  enter         32,0
  xor           r8,r8                   ; dA = 0
  mov           r9,128                  ; N_c = 128 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage2                  ; true => go to stage 2
loop1:
  vbroadcastss  ymm0,xmm0
  vbroadcastss  ymm1,xmm0
  vbroadcastss  ymm2,xmm0
  vbroadcastss  ymm3,xmm0
  vbroadcastss  ymm4,xmm0
  vbroadcastss  ymm5,xmm0
  vbroadcastss  ymm6,xmm0
  vbroadcastss  ymm7,xmm0
  vbroadcastss  ymm8,xmm0
  vbroadcastss  ymm9,xmm0
  vbroadcastss  ymm10,xmm0
  vbroadcastss  ymm11,xmm0
  vbroadcastss  ymm12,xmm0
  vbroadcastss  ymm13,xmm0
  vbroadcastss  ymm14,xmm0
  vbroadcastss  ymm15,xmm0
  vmovaps       [rsi+r8],ymm0
  vmovaps       [rsi+r8+32],ymm1
  vmovaps       [rsi+r8+64],ymm2
  vmovaps       [rsi+r8+96],ymm3
  vmovaps       [rsi+r8+128],ymm4
  vmovaps       [rsi+r8+160],ymm5
  vmovaps       [rsi+r8+192],ymm6
  vmovaps       [rsi+r8+224],ymm7
  vmovaps       [rsi+r8+256],ymm8
  vmovaps       [rsi+r8+288],ymm9
  vmovaps       [rsi+r8+320],ymm10
  vmovaps       [rsi+r8+352],ymm11
  vmovaps       [rsi+r8+384],ymm12
  vmovaps       [rsi+r8+416],ymm13
  vmovaps       [rsi+r8+448],ymm14
  vmovaps       [rsi+r8+480],ymm15
  add           r8,512                  ; dA += 16 * 8 * 4 byte
  add           r9,128                  ; N_c += 128 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop1                   ; true => loop stage 1
stage2:
  sub           r9,120                  ; N_c = N_c - 128 + 8 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage3                  ; true => go to stage 3
loop2:
  vbroadcastss  ymm0,xmm0               ; process looped stage 2
  vmovaps       [rsi+r8],ymm0           ; write results
  add           r8,32                   ; dA += 1 * 8 * 4 byte
  add           r9,8                    ; N_c += 8 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop2                   ; true => loop stage 2
stage3:
  sub           r9,4                    ; N_c = N_c - 8 + 4 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage4                  ; true => go to stage 4
loop3:
  vbroadcastss  xmm0,xmm0               ; process looped stage 3
  vmovaps       [rsi+r8],xmm0           ; write results
  add           r8,16                   ; dA += 1 * 4 * 4 byte
  add           r9,4                    ; N_c += 4 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop3                   ; true => loop stage 3
stage4:
  sub           r9,3                    ; N_c = N_c - 4 + 1 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            return                  ; true => go to return
loop4:
  movss         [rsi+r8],xmm0           ; write result
  add           r8,4                    ; dA += 1 * 1 * 4 byte
  inc           r9                      ; N_c += 1 component
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop4                   ; true => loop stage 4
return:
  leave
  ret


; end of vequs32fp256.asm
