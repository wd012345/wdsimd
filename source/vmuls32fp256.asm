; file:         vmuls32fp256.asm
;
; Assembly function that multiplies N 32bit floating point array components
; with a 32bit floating point scalar according to
;     w_{111...} = u_{111...} * s
;     w_{211...} = u_{211...} * s
;           .
;           .
;           .
;     w_{kmn...} = u_{kmn...} * s
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
; extern(C) void vmuls32fp256(ulong N, float* u, float s, float* w);
;
; where
;   N = number of array components        --> rdi
;   u = address to 1st array operand      --> rsi
;   s = single precision scalar           --> xmm0
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
  global vmuls32fp256
vmuls32fp256:
  enter         32,0
  vbroadcastss  ymm15,xmm0              ; broadcast scalar argument
; start stage 1
  xor           r8,r8                   ; dA = 0
  mov           r9,120                  ; N_c = 120 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage2                  ; true => go to stage 2
loop1:
  vmulps        ymm0,ymm15,[rsi+r8]
  vmulps        ymm1,ymm15,[rsi+r8+32]
  vmulps        ymm2,ymm15,[rsi+r8+64]
  vmulps        ymm3,ymm15,[rsi+r8+96]
  vmulps        ymm4,ymm15,[rsi+r8+128]
  vmulps        ymm5,ymm15,[rsi+r8+160]
  vmulps        ymm6,ymm15,[rsi+r8+192]
  vmulps        ymm7,ymm15,[rsi+r8+224]
  vmulps        ymm8,ymm15,[rsi+r8+256]
  vmulps        ymm9,ymm15,[rsi+r8+288]
  vmulps        ymm10,ymm15,[rsi+r8+320]
  vmulps        ymm11,ymm15,[rsi+r8+352]
  vmulps        ymm12,ymm15,[rsi+r8+384]
  vmulps        ymm13,ymm15,[rsi+r8+416]
  vmulps        ymm14,ymm15,[rsi+r8+448]
  vmovaps       [rdx+r8],ymm0
  vmovaps       [rdx+r8+32],ymm1
  vmovaps       [rdx+r8+64],ymm2
  vmovaps       [rdx+r8+96],ymm3
  vmovaps       [rdx+r8+128],ymm4
  vmovaps       [rdx+r8+160],ymm5
  vmovaps       [rdx+r8+192],ymm6
  vmovaps       [rdx+r8+224],ymm7
  vmovaps       [rdx+r8+256],ymm8
  vmovaps       [rdx+r8+288],ymm9
  vmovaps       [rdx+r8+320],ymm10
  vmovaps       [rdx+r8+352],ymm11
  vmovaps       [rdx+r8+384],ymm12
  vmovaps       [rdx+r8+416],ymm13
  vmovaps       [rdx+r8+448],ymm14
  add           r8,480                  ; dA += 15 * 8 * 4 byte
  add           r9,120                  ; N_c += 120 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop1                   ; true => loop stage 1
stage2:
  sub           r9,112                  ; N_c = N_c - 120 + 8 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage3                  ; true => go to stage 3
loop2:
  vmulps        ymm0,ymm15,[rsi+r8]     ; process looped stage 2
  vmovaps       [rdx+r8],ymm0           ; write results
  add           r8,32                   ; dA += 1 * 8 * 4 byte
  add           r9,8                    ; N_c += 8 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop2                   ; true => loop stage 2
stage3:
  sub           r9,4                    ; N_c = N_c - 8 + 4 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage4                  ; true => go to stage 4
loop3:
  vmulps        xmm0,xmm15,[rsi+r8]     ; process looped stage 3
  vmovaps       [rdx+r8],xmm0           ; write results
  add           r8,16                   ; dA += 1 * 4 * 4 byte
  add           r9,4                    ; N_c += 4 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop3                   ; true => loop stage 3
stage4:
  sub           r9,3                    ; N_c = N_c - 4 + 1 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            return                  ; true => go to return
loop4:
  vmulss        xmm0,xmm15,[rsi+r8]     ; process looped stage 4
  movss         [rdx+r8],xmm0           ; write result
  add           r8,4                    ; dA += 1 * 1 * 4 byte
  inc           r9                      ; N_c += 1 component
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop4                   ; true => loop stage 4
return:
  leave
  ret


; end of vmuls32fp256.asm
