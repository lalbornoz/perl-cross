#!/bin/bash

mstart "Trying to guess the kind of doubles used"
if not hinted "doublekind"; then
	# We assume here that double endianess matches that of int.
	# This assumption is *wrong* for soft-float ARMs!
	case "$byteorder" in
		1234*) _endianess="LE" ;;
		4321*) _endianess="BE" ;;
		8765*) _endianess="BE" ;;
		*) _endianess="" ;;
	esac
	case "$_endianess:$doublesize" in
		LE:4) _kind=1 ;;
		BE:4) _kind=2 ;;
		LE:8) _kind=3 ;;
		BE:8) _kind=4 ;;
		# these are not possible in perl-cross yet
		LE:16) _kind=5 ;;
		BE:16) _kind=6 ;;
		# doublekinds 7 and 8 (mixed-endian ARM) can only be hinted
		*) _kind='' ;;
	esac
	if [ -n "$_kind" ]; then
		setvar "doublekind" "$_kind"
		result "$_kind"
	else
		result "unknown"
	fi
fi

msg "Deciding NaN and Inf bytes"
case "$doublekind" in
    1) # IEEE 754 32-bit LE
       _inf='0x00, 0x00, 0xf0, 0x7f'
       _nan='0x00, 0x00, 0xf8, 0x7f'
       ;;
    2) # IEEE 754 32-bit BE
       _inf='0x7f, 0xf0, 0x00, 0x00'
       _nan='0x7f, 0xf8, 0x00, 0x00'
       ;;
    3) # IEEE 754 64-bit LE
       _inf='0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf0, 0x7f'
       _nan='0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0x7f'
       ;;
    4) # IEEE 754 64-bit BE
       _inf='0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00'
       _nan='0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00'
       ;;
    5) # IEEE 754 128-bit LE
       _inf='0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf0, 0x7f'
       _nan='0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0x7f'
       ;;
    6) # IEEE 754 128-bit BE
       _inf='0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00'
       _nan='0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00'
       ;;
    7) # IEEE 754 64-bit mixed: 32-bit LEs in BE
       _inf='0x00, 0x00, 0xf0, 0x7f, 0x00, 0x00, 0x00, 0x00'
       _nan='0x00, 0x00, 0xf8, 0x7f, 0x00, 0x00, 0x00, 0x00'
       ;;
    8) # IEEE 754 64-bit mixed: 32-bit BEs in LE
       _inf='0x00, 0x00, 0x00, 0x00, 0x7f, 0xf0, 0x00, 0x00'
       _nan='0x00, 0x00, 0x00, 0x00, 0x7f, 0xf8, 0x00, 0x00'
       ;;
    *) # No idea.
       _inf=
       _nan=
       ;;
esac

mstart "\tNaN"
if not hinted "doublenanbytes"; then
	setvar 'doublenanbytes' "$_nan"
	result "$_nan"
fi

mstart "\tInf"
if not hinted "doubleinfbytes"; then
	setvar 'doubleinfbytes' "$_inf"
	result "$_inf"
fi

mstart "Guessing how many mantissa bits are there in double"
if not hinted 'doublemantbits'; then
	case "$doublesize" in
		4) _bits=23 ;;
		8) _bits=52 ;;
		*) _bits='' ;;
	esac
	if [ -n "$_bits" ]; then
		setvar "doublemantbits" "$_bits"
		result "$_bits"
	else
		result "unknown"
	fi
fi

mstart "Checking how many mantissa bits your NVs have"
if [ "$usequadmath" == 'define' ]; then
	setvar "nvmantbits" "112"
elif [ "$nvsize" == "$doublesize" ]; then
	setvar "nvmantbits" "$doublemantbits"
elif [ "$nvsize" == "$longdblsize" ]; then
	setvar "nvmantbits" "$longdblmantbits"
else
	setvar "nvmantbits" ''
fi
if [ -n "$nvmantbits" ]; then
	result "$nvmantbits"
else
	result "unknown"
fi
