// Copyright 2014 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//go:build !plan9

#include "go_asm.h"
#include "textflag.h"
#include "asm_amd64.h"

// See memclrNoHeapPointers Go doc for important implementation constraints.

// func memclrNoHeapPointers(ptr unsafe.Pointer, n uintptr)
// ABIInternal for performance.
TEXT runtime·memclrNoHeapPointers<ABIInternal>(SB), NOSPLIT, $0-16
	// AX = ptr
	// BX = n
	MOVQ	AX, DI	// DI = ptr
	XORQ	AX, AX

	// MOVOU seems always faster than REP STOSQ when Enhanced REP STOSQ is not available.
tail:
	// BSR+branch table make almost all memmove/memclr benchmarks worse. Not worth doing.
	TESTQ	BX, BX
	JEQ	_0
	CMPQ	BX, $2
	JBE	_1or2
	CMPQ	BX, $4
	JBE	_3or4
	CMPQ	BX, $8
	JB	_5through7
	JE	_8
	CMPQ	BX, $16
	JBE	_9through16
	CMPQ	BX, $32
	JBE	_17through32
	CMPQ	BX, $64
	JBE	_33through64
	CMPQ	BX, $128
	JBE	_65through128
	CMPQ	BX, $256
	JBE	_129through256

loop:
	MOVOU	X15, 0(DI)
	MOVOU	X15, 16(DI)
	MOVOU	X15, 32(DI)
	MOVOU	X15, 48(DI)
	MOVOU	X15, 64(DI)
	MOVOU	X15, 80(DI)
	MOVOU	X15, 96(DI)
	MOVOU	X15, 112(DI)
	MOVOU	X15, 128(DI)
	MOVOU	X15, 144(DI)
	MOVOU	X15, 160(DI)
	MOVOU	X15, 176(DI)
	MOVOU	X15, 192(DI)
	MOVOU	X15, 208(DI)
	MOVOU	X15, 224(DI)
	MOVOU	X15, 240(DI)
	SUBQ	$256, BX
	ADDQ	$256, DI
	CMPQ	BX, $256
	JAE	loop
	JMP	tail

_1or2:
	MOVB	AX, (DI)
	MOVB	AX, -1(DI)(BX*1)
	RET
_0:
	RET
_3or4:
	MOVW	AX, (DI)
	MOVW	AX, -2(DI)(BX*1)
	RET
_5through7:
	MOVL	AX, (DI)
	MOVL	AX, -4(DI)(BX*1)
	RET
_8:
	// We need a separate case for 8 to make sure we clear pointers atomically.
	MOVQ	AX, (DI)
	RET
_9through16:
	MOVQ	AX, (DI)
	MOVQ	AX, -8(DI)(BX*1)
	RET
_17through32:
	MOVOU	X15, (DI)
	MOVOU	X15, -16(DI)(BX*1)
	RET
_33through64:
	MOVOU	X15, (DI)
	MOVOU	X15, 16(DI)
	MOVOU	X15, -32(DI)(BX*1)
	MOVOU	X15, -16(DI)(BX*1)
	RET
_65through128:
	MOVOU	X15, (DI)
	MOVOU	X15, 16(DI)
	MOVOU	X15, 32(DI)
	MOVOU	X15, 48(DI)
	MOVOU	X15, -64(DI)(BX*1)
	MOVOU	X15, -48(DI)(BX*1)
	MOVOU	X15, -32(DI)(BX*1)
	MOVOU	X15, -16(DI)(BX*1)
	RET
_129through256:
	MOVOU	X15, (DI)
	MOVOU	X15, 16(DI)
	MOVOU	X15, 32(DI)
	MOVOU	X15, 48(DI)
	MOVOU	X15, 64(DI)
	MOVOU	X15, 80(DI)
	MOVOU	X15, 96(DI)
	MOVOU	X15, 112(DI)
	MOVOU	X15, -128(DI)(BX*1)
	MOVOU	X15, -112(DI)(BX*1)
	MOVOU	X15, -96(DI)(BX*1)
	MOVOU	X15, -80(DI)(BX*1)
	MOVOU	X15, -64(DI)(BX*1)
	MOVOU	X15, -48(DI)(BX*1)
	MOVOU	X15, -32(DI)(BX*1)
	MOVOU	X15, -16(DI)(BX*1)
	RET
