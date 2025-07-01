# route dump
#   query OpSw1
#       writes to OpSw25 - 32
#       queries of 46-48, 33-45, 62-64, 49-55, ? 57-61


awk '
filename != FILENAME {
    filename = FILENAME
  # printf "%s", filename
    printf "\n"
    L = 0
}

# ------------------------------------------------
function bits (val, bit, nBits) {
    return int((val / 2^bit) % 2^nBits)
}

# ------------------------------------------------
function decode (part) {
  # printf "decode: %04x --", part

    to     = 1+ bits(part, 8, 1) * 2^7 + part % 2^7
    closed = bits(part, 13, 1)

    if (ds64Last != ds64) {
        ds64Last  = ds64
        printf "    %4s %3s %4s %4s %3s\n", \
            "ds64", "idx", "bits", "TO#", "T/C"
    }

    printf "   "
    printf " %4d",  ds64
    printf " %3d",  idx
    printf " %04x", part
    printf " %4d", to
    s = "T"
    if (closed)
        s = "C"
    printf " %3s", s

    s = "    "
    if (3 == bits(part, 9, 2))
        s = "cont"
    printf "  %4s", s
    printf "  %s", filename

    printf "\n"

    L++
}

# ------------------------------------------------
match(filename, "to.txt")  {
    if (0)  {
        printf "    "
        printf " %4s", $0
        printf "\n"
    }

    next
}

# --------------------------------------------------------------------
# DS64 28 Write OpSw25 value=0 (Thrown).
# LONG_ACK: OpSwitch operation accepted.

/Write OpSw/ {
    ds64 = $2
    sw   = int(substr($4, 5))   # OpSw25
    bit  = int(substr($5, 7))   # value=1

    if (25 ==sw)
        idx = 0

    idx  = idx + bit * 2^(sw-25)

    if (0) {
        printf "  %s", $0
        printf ", sw %2d",  sw
        printf ", %s",      bit
        printf " 0x%02x",   idx
        printf "\n"
    }

    next
}

# ------------------------------------------------
# DS64 28 Query OpSw1.
# LONG_ACK: OpSwitch report - opSwitch is 1 (Closed).
#
# DS64 46 Query OpSw1.
# LONG_ACK: OpSwitch report - opSwitch is 1 (Closed).

/Query/  {
    opSw = $4
    sw   = int(substr(opSw, 5))
    next
}

# ------------------------------------------------
# DS64 28 Query OpSw46.
# LONG_ACK: OpSwitch report - opSwitch is 1 (Closed).
#       queries of 46-48, 33-45, 62-64, 49-55, ? 57-61

/OpSwitch report/ && opSw {
    if (1 == sw)
        next

    if (46 == sw)
        val = 0

    bit =$7
    val +=  int(bit) * 2^(sw-33)

  # printf "  %2d %2d %08x %2d %d\n", ds64, idx, val, sw, bit

    if ("OpSw61." == opSw)  {
      # printf "    %2d %2d %08x\n", ds64, idx, val
        decode(int(val % 2^16))
        decode(int(val / 2^16))
    }

    next
}

# ------------------------------------------------
NF {
  # print
}' $*
