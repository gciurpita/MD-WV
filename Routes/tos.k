# read 4 turnout addresses from ds64
#   query OpSw1
#       writes to OpSw25 - 32
#       queries of 46-48, 33-45, 62-64, 49-55, ? 57-61


awk '

# ------------------------------------------------
function error () {
    printf "\nError: %s - NR %d\n", filename, NR
    print
    exit
}

# ------------------------------------------------
filename != FILENAME {
    filename = FILENAME
    if(dbg) printf "\n"
    L = 0
}

# ------------------------------------------------
function bits (val, bit, nBits) {
    return int((val / 2^bit) % 2^nBits)
}

# --------------------------------------------------------------------
function getBits (opSw0, opSw1)  {
    val = 0
    for (n = opSw1; n >= opSw0; n--)
        val = 2*val + bit [n]
    return val
}

# --------------------------------------------------------------------
! NF || /^Req/ || /^Rep/ || /^\t/ { next }

# --------------------------------------
## DS64 20 Write OpSw25 value=0 (Thrown).
## LONG_ACK: OpSwitch operation accepted.

/Write OpSw/ {
    ds64 = $2
    opSw       = int(substr($4, 5))
    bit [opSw] = int(substr($5, 7))

    getline
    while (! /LONG_ACK: OpSwitch operation/)  {
        if (! /Write OpSw/)
            error()
        getline
    }

  # printf "  opSw wr %2d - %d\n", opSw, bit [opSw]
    if (32 == opSw)  {
        adr = getBits(25, 32)
        if (dbg) printf "  %2d: 0x%02x", ds64, adr
    }
    next
}

# --------------------------------------
## DS64 20 Query OpSw1.
## LONG_ACK: OpSwitch report - opSwitch is 1 (Closed).

## DS64 20 Query OpSw46.
## LONG_ACK: OpSwitch report - opSwitch is 1 (Closed).

/Query OpSw/ {
    opSw = int(substr($4, 5))

  # print
    getline
  # print

    while (! /LONG_ACK: OpSwitch report/) {
        if (! /Query OpSw/)
            error()
        getline
    }
    bit [opSw] = int($7)

  # printf "  opSw rd %2d - %d\n", opSw, bit [opSw]

    # 64-61  60-57 | 56-53  52-49 | 48-45  44-41 | 40-37  36-33
    if (61 == opSw)  {
        val = getBits(33, 61)
        decodeTo(int(val % 2^16), 0)
        decodeTo(int(val / 2^16), 1)
        if (dbg) printf "\n"
    }
    next
}

# --------------------------------------
function decodeTo (val, half)  {
    to = 128*(int(val/256) %2) +val%128  +1

    if (0)  {
        printf "  0x%04x", val
        printf " %3x", to
    }
    else if (dbg)
        printf " %4d", to
    else 
        printf "  %4d   DS%d-%d\n", to, ds64, 2*adr + half
}

# --------------------------------------
{
    print
}

# ------------------------------------------------
NF {
  # print
}' $*
