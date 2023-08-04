; file:         vequv64fp256.asm
;
; Assembly function that assigns N 64bit floating point array
; components to N 64bit floating point array components according to
;     w_{111...} = u_{111...}
;     w_{211...} = u_{211...}
;           .
;           .
;           .
;     w_{kmn...} = u_{kmn...}
;
; The AVX2 registers and AVX2 instruction set is used. The function
; processes four looped stages, each processing
;     1. 16 ymm registers * 4 components = 64 components/loop
;     2.  1 ymm register  * 4 components =  4 components/loop
;     3.  1 xmm register  * 2 components =  2 components/loop
;     4.  1 xmm register  * 1 component  =  1 component/loop
;
; The first stage is looped while
;     N_c = (n_1 + 1) * 64 components <= N
; where n_1 is equal to the number of already processed loops of stage 1, and
; n_1 + 1 is equal to the number of already processed loops plus one loop of
; stage 1.
;
; The second stage is looped while
;     N_c = (n_1 * 64 + (n_2 + 1) * 4) components <= N
; where n_2 is equal to the number of already processed loops of stage 2, and
; n_2 + 1 is equal to the number of already processed loops plus one loop of
; stage 2.
;
; The third stage is looped while
;     N_c = (n_1 * 64 + (n_2 + 1) * 4 + (n_3 + 1) * 2) components <= N
; where n_3 is equal to the number of already processed loops of stage 3, and
; n_3 + 1 is equal to the number of already processed loops plus one loop of
; stage 3.
;
; The assembly function returns as soon as N array components are processed, 
; i.e.
;     N_c = (n_1 * 64 + n_2 * 4 + n_3 * 2 + n_4) components == N.
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
; extern(C) void vequv64fp256(ulong N, double* u, double* w);
;
; where
;   N = number of array components        --> rdi
;   u = address to 1st array operand      --> rsi
;   w = address to result array           --> rdx
; ____________________________________________________________________________
;
; author:       Stefan Wittwer, info@wittwer-datatools.ch
;
; known bugs:
; 1. ...
;
; ____________________________________________________________________________


section .text
  global vequv64fp256
vequv64fp256:
  enter         32,0
  xor           r8,r8                   ; dA = 0
  mov           r9,64                   ; N_c = 64 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage2                  ; true => go to stage 2
loop1:
  vmovapd       ymm0,[rsi+r8]
  vmovapd       ymm1,[rsi+r8+32]
  vmovapd       ymm2,[rsi+r8+64]
  vmovapd       ymm3,[rsi+r8+96]
  vmovapd       ymm4,[rsi+r8+128]
  vmovapd       ymm5,[rsi+r8+160]
  vmovapd       ymm6,[rsi+r8+192]
  vmovapd       ymm7,[rsi+r8+224]
  vmovapd       ymm8,[rsi+r8+256]
  vmovapd       ymm9,[rsi+r8+288]
  vmovapd       ymm10,[rsi+r8+320]
  vmovapd       ymm11,[rsi+r8+352]
  vmovapd       ymm12,[rsi+r8+384]
  vmovapd       ymm13,[rsi+r8+416]
  vmovapd       ymm14,[rsi+r8+448]
  vmovapd       ymm15,[rsi+r8+480]
  vmovapd       [rdx+r8],ymm0
  vmovapd       [rdx+r8+32],ymm1
  vmovapd       [rdx+r8+64],ymm2
  vmovapd       [rdx+r8+96],ymm3
  vmovapd       [rdx+r8+128],ymm4
  vmovapd       [rdx+r8+160],ymm5
  vmovapd       [rdx+r8+192],ymm6
  vmovapd       [rdx+r8+224],ymm7
  vmovapd       [rdx+r8+256],ymm8
  vmovapd       [rdx+r8+288],ymm9
  vmovapd       [rdx+r8+320],ymm10
  vmovapd       [rdx+r8+352],ymm11
  vmovapd       [rdx+r8+384],ymm12
  vmovapd       [rdx+r8+416],ymm13
  vmovapd       [rdx+r8+448],ymm14
  vmovapd       [rdx+r8+480],ymm15
  add           r8,512                  ; dA += 16 * 4 * 8 byte
  add           r9,64                   ; N_c += 64 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop1                   ; true => loop stage 1
stage2:
  sub           r9,60                   ; N_c = N_c - 64 + 4 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage3                  ; true => go to stage 3
loop2:
  vmovapd       ymm0,[rsi+r8]           ; process looped stage 2
  vmovapd       [rdx+r8],ymm0           ; write results
  add           r8,32                   ; dA += 1 * 4 * 8 byte
  add           r9,4                    ; N_c += 4 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop2                   ; true => loop stage 2
stage3:
  sub           r9,2                    ; N_c = N_c - 4 + 2 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            stage4                  ; true => go to stage 4
loop3:
  vmovapd       xmm0,[rsi+r8]           ; process looped stage 3
  vmovapd       [rdx+r8],xmm0           ; write results
  add           r8,16                   ; dA += 1 * 2 * 8 byte
  add           r9,2                    ; N_f += 2 components
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop3                   ; true => loop stage 3
stage4:
  dec           r9                      ; N_c = N_c - 2 + 1 components
  cmp           rdi,r9                  ; N < N_c ?
  jl            return                  ; true => go to return
loop4:
  movsd         xmm0,[rsi+r8]           ; process looped stage 4
  movsd         [rdx+r8],xmm0           ; write result
  add           r8,8                    ; dA += 1 * 1 * 8 byte
  inc           r9                      ; N_c += 1 component
  cmp           rdi,r9                  ; N >= N_c ?
  jge           loop4                   ; true => loop stage 4
return:
  leave
  ret


; end of vequv64fp256.asm
