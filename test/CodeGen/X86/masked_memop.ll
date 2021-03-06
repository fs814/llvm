; RUN: llc -mtriple=x86_64-apple-darwin  -mcpu=knl < %s | FileCheck %s -check-prefix=AVX512
; RUN: llc -mtriple=x86_64-apple-darwin  -mcpu=core-avx2 < %s | FileCheck %s -check-prefix=AVX2

; AVX512-LABEL: test1
; AVX512: vmovdqu32       (%rdi), %zmm0 {%k1} {z}

; AVX2-LABEL: test1
; AVX2: vpmaskmovd      32(%rdi)
; AVX2: vpmaskmovd      (%rdi)
; AVX2-NOT: blend

define <16 x i32> @test1(<16 x i32> %trigger, <16 x i32>* %addr) {
  %mask = icmp eq <16 x i32> %trigger, zeroinitializer
  %res = call <16 x i32> @llvm.masked.load.v16i32(<16 x i32>* %addr, i32 4, <16 x i1>%mask, <16 x i32>undef)
  ret <16 x i32> %res
}

; AVX512-LABEL: test2
; AVX512: vmovdqu32       (%rdi), %zmm0 {%k1} {z}

; AVX2-LABEL: test2
; AVX2: vpmaskmovd      {{.*}}(%rdi)
; AVX2: vpmaskmovd      {{.*}}(%rdi)
; AVX2-NOT: blend
define <16 x i32> @test2(<16 x i32> %trigger, <16 x i32>* %addr) {
  %mask = icmp eq <16 x i32> %trigger, zeroinitializer
  %res = call <16 x i32> @llvm.masked.load.v16i32(<16 x i32>* %addr, i32 4, <16 x i1>%mask, <16 x i32>zeroinitializer)
  ret <16 x i32> %res
}

; AVX512-LABEL: test3
; AVX512: vmovdqu32       %zmm1, (%rdi) {%k1}

define void @test3(<16 x i32> %trigger, <16 x i32>* %addr, <16 x i32> %val) {
  %mask = icmp eq <16 x i32> %trigger, zeroinitializer
  call void @llvm.masked.store.v16i32(<16 x i32>%val, <16 x i32>* %addr, i32 4, <16 x i1>%mask)
  ret void
}

; AVX512-LABEL: test4
; AVX512: vmovups       (%rdi), %zmm{{.*{%k[1-7]}}}

; AVX2-LABEL: test4
; AVX2: vmaskmovps      {{.*}}(%rdi)
; AVX2: vmaskmovps      {{.*}}(%rdi)
; AVX2: blend
define <16 x float> @test4(<16 x i32> %trigger, <16 x float>* %addr, <16 x float> %dst) {
  %mask = icmp eq <16 x i32> %trigger, zeroinitializer
  %res = call <16 x float> @llvm.masked.load.v16f32(<16 x float>* %addr, i32 4, <16 x i1>%mask, <16 x float> %dst)
  ret <16 x float> %res
}

; AVX512-LABEL: test5
; AVX512: vmovupd (%rdi), %zmm1 {%k1}

; AVX2-LABEL: test5
; AVX2: vmaskmovpd
; AVX2: vblendvpd
; AVX2: vmaskmovpd  
; AVX2: vblendvpd
define <8 x double> @test5(<8 x i32> %trigger, <8 x double>* %addr, <8 x double> %dst) {
  %mask = icmp eq <8 x i32> %trigger, zeroinitializer
  %res = call <8 x double> @llvm.masked.load.v8f64(<8 x double>* %addr, i32 4, <8 x i1>%mask, <8 x double>%dst)
  ret <8 x double> %res
}

; AVX2-LABEL: test6
; AVX2: vmaskmovpd
; AVX2: vblendvpd
define <2 x double> @test6(<2 x i64> %trigger, <2 x double>* %addr, <2 x double> %dst) {
  %mask = icmp eq <2 x i64> %trigger, zeroinitializer
  %res = call <2 x double> @llvm.masked.load.v2f64(<2 x double>* %addr, i32 4, <2 x i1>%mask, <2 x double>%dst)
  ret <2 x double> %res
}

; AVX2-LABEL: test7
; AVX2: vmaskmovps      {{.*}}(%rdi)
; AVX2: blend
define <4 x float> @test7(<4 x i32> %trigger, <4 x float>* %addr, <4 x float> %dst) {
  %mask = icmp eq <4 x i32> %trigger, zeroinitializer
  %res = call <4 x float> @llvm.masked.load.v4f32(<4 x float>* %addr, i32 4, <4 x i1>%mask, <4 x float>%dst)
  ret <4 x float> %res
}

; AVX2-LABEL: test8
; AVX2: vpmaskmovd      {{.*}}(%rdi)
; AVX2: blend
define <4 x i32> @test8(<4 x i32> %trigger, <4 x i32>* %addr, <4 x i32> %dst) {
  %mask = icmp eq <4 x i32> %trigger, zeroinitializer
  %res = call <4 x i32> @llvm.masked.load.v4i32(<4 x i32>* %addr, i32 4, <4 x i1>%mask, <4 x i32>%dst)
  ret <4 x i32> %res
}

; AVX2-LABEL: test9
; AVX2: vpmaskmovd %xmm
define void @test9(<4 x i32> %trigger, <4 x i32>* %addr, <4 x i32> %val) {
  %mask = icmp eq <4 x i32> %trigger, zeroinitializer
  call void @llvm.masked.store.v4i32(<4 x i32>%val, <4 x i32>* %addr, i32 4, <4 x i1>%mask)
  ret void
}

; AVX2-LABEL: test10
; AVX2: vmaskmovpd    (%rdi), %ymm
; AVX2: blend
define <4 x double> @test10(<4 x i32> %trigger, <4 x double>* %addr, <4 x double> %dst) {
  %mask = icmp eq <4 x i32> %trigger, zeroinitializer
  %res = call <4 x double> @llvm.masked.load.v4f64(<4 x double>* %addr, i32 4, <4 x i1>%mask, <4 x double>%dst)
  ret <4 x double> %res
}

; AVX2-LABEL: test11
; AVX2: vmaskmovps
; AVX2: vblendvps
define <8 x float> @test11(<8 x i32> %trigger, <8 x float>* %addr, <8 x float> %dst) {
  %mask = icmp eq <8 x i32> %trigger, zeroinitializer
  %res = call <8 x float> @llvm.masked.load.v8f32(<8 x float>* %addr, i32 4, <8 x i1>%mask, <8 x float>%dst)
  ret <8 x float> %res
}

; AVX2-LABEL: test12
; AVX2: vpmaskmovd %ymm
define void @test12(<8 x i32> %trigger, <8 x i32>* %addr, <8 x i32> %val) {
  %mask = icmp eq <8 x i32> %trigger, zeroinitializer
  call void @llvm.masked.store.v8i32(<8 x i32>%val, <8 x i32>* %addr, i32 4, <8 x i1>%mask)
  ret void
}

; AVX512-LABEL: test13
; AVX512: vmovups       %zmm1, (%rdi) {%k1}

define void @test13(<16 x i32> %trigger, <16 x float>* %addr, <16 x float> %val) {
  %mask = icmp eq <16 x i32> %trigger, zeroinitializer
  call void @llvm.masked.store.v16f32(<16 x float>%val, <16 x float>* %addr, i32 4, <16 x i1>%mask)
  ret void
}

declare <16 x i32> @llvm.masked.load.v16i32(<16 x i32>*, i32, <16 x i1>, <16 x i32>) 
declare <4 x i32> @llvm.masked.load.v4i32(<4 x i32>*, i32, <4 x i1>, <4 x i32>)
declare void @llvm.masked.store.v16i32(<16 x i32>, <16 x i32>*, i32, <16 x i1>)
declare void @llvm.masked.store.v8i32(<8 x i32>, <8 x i32>*, i32, <8 x i1>)
declare void @llvm.masked.store.v4i32(<4 x i32>, <4 x i32>*, i32, <4 x i1>)
declare void @llvm.masked.store.v16f32(<16 x float>, <16 x float>*, i32, <16 x i1>) 
declare void @llvm.masked.store.v16f32p(<16 x float>*, <16 x float>**, i32, <16 x i1>) 
declare <16 x float> @llvm.masked.load.v16f32(<16 x float>*, i32, <16 x i1>, <16 x float>)
declare <8 x float> @llvm.masked.load.v8f32(<8 x float>*, i32, <8 x i1>, <8 x float>)
declare <4 x float> @llvm.masked.load.v4f32(<4 x float>*, i32, <4 x i1>, <4 x float>)
declare <8 x double> @llvm.masked.load.v8f64(<8 x double>*, i32, <8 x i1>, <8 x double>)
declare <4 x double> @llvm.masked.load.v4f64(<4 x double>*, i32, <4 x i1>, <4 x double>)
declare <2 x double> @llvm.masked.load.v2f64(<2 x double>*, i32, <2 x i1>, <2 x double>)
declare void @llvm.masked.store.v8f64(<8 x double>, <8 x double>*, i32, <8 x i1>)
declare void @llvm.masked.store.v2f64(<2 x double>, <2 x double>*, i32, <2 x i1>)
declare void @llvm.masked.store.v2i64(<2 x i64>, <2 x i64>*, i32, <2 x i1>)

