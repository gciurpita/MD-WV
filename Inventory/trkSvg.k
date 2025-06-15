# yet another track drawing too
# svg drawing routines

awk '
# ------------------------------------------------
function anno (x, y, text, font)  {
    if (! font)
        font=Font
    printf "  <text x=\"%d\" y=\"%d\"", S*x, S*mapY(y)
    printf " font-family=\"Verdana\""
    printf " font-size=\"%d\"", font
    printf ">%s</text>\n", text
}

# ------------------------------------------------
function annoC (x, y, text, font)  {
    if (! font)
        font = 10
    printf "  <text x=\"%d\" y=\"%d\"", S*x, S*mapY(y)
    printf " font-family=\"Verdana\""
    printf " text-anchor=\"middle\""
    printf " font-size=\"%d\"", font
    printf ">%s</text>\n", text
}

# ------------------------------------------------
function annoR (x, y, text, font)  {
    if (! font)
        font = 10
    printf "  <text x=\"%d\" y=\"%d\"", S*x, S*mapY(y)
    printf " font-family=\"Verdana\""
    printf " text-anchor=\"end\""
    printf " font-size=\"%d\"", font
    printf ">%s</text>\n", text
}

# ------------------------------------------------
function comment (text)  {
    printf " <!-- %s -->\n", text
}

# ------------------------------------------------
#    A rx ry rotate large_arc_flag sweep_flag x y
#    use cw rotations

function arc (x0, y0, a0, a1, rad, col, a, x2, y2, x3, y3)  {
    printf " <!-- arc (%d, %d) a0 %d, a1 %d, rad %.2f -->\n", \
            x0, y0, a0, a1, rad

    if (a1 < a0)  {
        a  = a0
        a0 = a1
        a1 = a
    }

    c = "M"
    printf " <path d=\""
    for (a = a0; a <= a1; a += 5)  {
        w = a * Pi / 180
        printf "%s%d %d ", c, S*(x0+ rad*cos(w)), S*(mapY(y0+ rad*sin(w)))
        c = "L"
    }

    w = a1 * Pi / 180
    printf "%s%d %d ", c, S*(x0+ rad*cos(w)), S*(mapY(y0+ rad*sin(w)))

    printf "\" stroke=\"%s\" stroke-width=\"%d\" fill=\"none\" />\"\n", col, W
}

# ------------------------------------------------
function circle (x0, y0, rad, col, a)  {
    printf " <circle cx=\"%d\" cy=\"%d\" r=\"%d\"", S*x0, S*mapY(y0), S*rad
    printf " stroke=\"black\""
    printf " stroke-width=\"1\""
    printf " fill=\"%s\"", col
    printf "/>\n"
}

# ------------------------------------------------
function line (x0, y0, x1, y1, color)  {
    printf "  <line   x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\"", \
        S*x0, S*mapY(y0), S*x1, S*mapY(y1)
    printf " style=\"stroke:%s;stroke-width:%d\"", color, W
    printf " />\n"
}

# ------------------------------------------------
function lineArrow (x0, y0, x1, y1) {
    printf "<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\"",
        S*x0, S*mapY(y0), S*x1, S*mapY(y1)
    printf "stroke=\"#000\" stroke-width=\"2\""
    printf "marker-end=\"url(#arrowhead)\" />\n"

}

# ------------------------------------------------
function marker () {
  printf "<defs>\n"
  printf "  <marker id=\"arrowhead\" markerWidth=\"10\" markerHeight=\"5\"\n"
  printf "  refX=\"0\" refY=\"2.5\" orient=\"auto\">\n"
  printf "    <polygon points=\"0 0, 10 2.5, 0 5\" />\n"
  printf "  </marker>\n"
  printf "</defs>\n"
}

# --------------------------------------------------------------------
function path (vecY, N, col) {
    printf "<path d=\"M %d %d\n", 0, Ht - vecY [0]
    for (n = 1; n < N; n++) {
        printf "  L %3d %4d\n", n, Ht - vecY [n]
      # printf "  L %3d %8.4f\n", n,      vecY [n]
    }
    printf "\""
    printf " stroke=\"%s\" stroke-width=\"2\" fill=\"none\" />\n", col
}

# ------------------------------------------------
function rect (x0, y0, x1, y1, color, wid, ht)  {
    wid = x1 - x0
    ht  = y1 - y0
    printf " <rect   x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\"", S*x0, S*y0, S*wid, S*ht
    printf " style=\"fill:none;stroke:%s;stroke-width:1\"", color
    printf " />\n"
}


# ------------------------------------------------
function mapY (y)  {
    return Ht - y
}

# ------------------------------------------------
function rotate (x0, y0, ang) {
    c  = cos(ang * Pi / 180)
    s  = sin(ang * Pi / 180)
    dx = c*x0 - s*y0
    dy = s*x0 + c*y0
}

# ------------------------------------------------
function svgBegin (wid, ht, scale)  {
    Wid = wid
    Ht  = ht
    S   = scale
    if (Html)  {
        printf "\n"
        printf "<p>"
        printf "<table border=1 cellspacing=0 bgcolor=lightcyan> <tr> <td>\n"
    }

    printf "<svg version=\"1.1\" baseProfile=\"full\"\n"
    printf "     width=\"%d\" height=\"%d\"\n", S*Wid, S*Ht
    printf "     xmlns=\"http://www.w3.org/2000/svg\">\n"

    bgCol = "beige"
    if (bgCol)
        printf "  <rect width=\"100%%\" height=\"100%%\" fill=\"%s\"/>\n", \
            bgCol
}

# ------------------------------------------------
function svgEnd (text)  {
    if (text)
        annoC(Wid/2, Ht - 14/S, text, 14)
    printf "</svg>\n"

    if (H)
        printf "</table>\n"
    printf "\n"
}

# --------------------------------------------------------------------
# ------------------------------------------------
# standard orientation
function arcDbl (x0, y0, a0, a1, rad, dd, col1, col2, a)  {
    arc(x0, y0, a0, a1, rad-dd, col1)
    arc(x0, y0, a0, a1, rad+dd, col2)
}

# ------------------------------------------------
function lineDbl (x0, y0, x1, y1, dd, col1, col2, ang)  {
    ang = atan2(y1-y0, x1-x0) * 180 / Pi

    rotate(0, dd, ang)
    line(x0+dx, y0+dy, x1+dx, y1+dy, col1)

    rotate(0, -dd, ang)
    line(x0+dx, y0+dy, x1+dx, y1+dy, col2)
}

# ------------------------------------------------
function ladder (x0, y0, ang, rL, N, len, col) {
    printf "# ladder: x0 %6.2f, y0 %6.2f, ang %6.2f, rl %d, N %d, len %d, %s\n", \
                        x0, y0, ang, rL, N, len, col


    for (n = N0; n < N; n++)  {
        if (! col)
            col = "dark-gray"
        to(x0, y0, ang, rL, dir=1, col)

        if (len)  {
            if (! col)
                col = "blue"
            line(x, y, len, y, col)
        }
        x0  = x1
        y0  = y1
    }
}

# ------------------------------------------------
function plug (x0, y0, col) {
    printf "thickness = 3\n"
    
    if (! col)
        col = "red"
    printf "color = %s\n", col

    rect(x0, y0, 4, 3, "red")
    printf "thickness = 1\n"
}

# ------------------------------------------------
function radius (x0, y0, ang0, ang1, rad, col) {
    if (! col)
        col = "cyan"

    c = cos(ang0 * Pi / 180)
    s = sin(ang0 * Pi / 180)

    xC = x0 - ToRad * c
    yC = y0 - ToRad * s

    arc(xC, yC, ang0, ang1, ToRad, col)

    c = cos(ang1 * Pi / 180)
    s = sin(ang1 * Pi / 180)

    x  = xC + ToRad * c
    y  = yC + ToRad * s
}

# ------------------------------------------------
function side (x0, y0, ang, rL, N, len, col) {
    to(x0, y0, ang, rL, len, col)
    if (len)
        line(x0, y0, len, y0, col)

    ladder(x, y, a, ! rL, N, len, col)
}

# ------------------------------------------------
function siding (x0, y0, ang, rL, N, len, col) {
    to(x0, y0, ang, rL, ToRight=1, col)
    x10 = x;  y10 = y           # x,y of diverging rail
    x11 = x1; y11 = y1
    a10 = a

    radius(x, y, 90 + ToAng + ang, 90 + ang, ToRad, col)
    x12 = x;  y12 = y

    if (! col)
        col = "dark-gray"
    to(x0+len, y0, ang, 1-rL, toRight=0, colol = col)
    x20 = x; y20 = y
    line(x11, y11, x1, y1, col)

    if (! col)
        col = "red"
    radius(x20, y20, 90 - ToAng + ang, 90 + ang, ToRad, col)

    if (! col)
        col = "green"
    line(x12, y12, x, y, col)
}

# ------------------------------------------------
function to (x0, y0, ang, rL, toRight, col) {
    if (! col)
        col = "dark-gray"

    c = cos(ang * Pi / 180)
    s = sin(ang * Pi / 180)

    # ----------------------------
    if (1 == toRight)  {
        # locate pts
        xA = x0 + c * ToExt
        yA = y0 + s * ToExt

        # locate frog
        xB = x0 + c * (ToExt + ToLen)
        yB = y0 + s * (ToExt + ToLen)

        # locate end of straight
        x1 = x0 + c * (ToLen + 2 * ToExt)
        y1 = y0 + s * (ToLen + 2 * ToExt)

        line(x0, y0, xA, yA, "yellow")      # col)
        line(xA, yA, xB, yB, col)
        line(xB, yB, x1, y1, "yellow")      # col)

        if (rL)  {
            xC = xA + ToRad * s
            yC = yA - ToRad * c
            a0 = ang + 90
            a1 =  a0 - ToAng
            a  = ang - ToAng
        }
        else {
            xC = xA - ToRad * s
            yC = yA + ToRad * c
            a0 = ang - 90
            a1 =  a0 + ToAng
            a  = ang + ToAng
        }
        arc(xC, yC, a0, a1,ToRad, col)

        # ----------------------------
        c1 = cos(a1 * Pi / 180)
        s1 = sin(a1 * Pi / 180)

        xD = xC + ToRad  * c1
        yD = yC + ToRad  * s1

        # ----------------------------
        # extend end-point of diverging rail
        c  = ToExt * cos(a * Pi/180)
        s  = ToExt * sin(a * Pi/180)
        x  = xD + c
        y  = yD + s
        line(xD, yD, x, y, "yellow")
    }
    else {
        printf "# toLeft %d\n", toLeft

        xA = x0 - c * ToExt
        yA = y0 + s * ToExt

        # locate frog
        xB = x0 - c * (ToExt + ToLen)
        yB = y0 + s * (ToExt + ToLen)

        # locate end of straight
        x1 = x0 - c * (ToLen + 2 * ToExt)
        y1 = y0 + s * (ToLen + 2 * ToExt)

        line(x0, y0, xA, yA, "yellow")
        line(xA, yA, xB, yB, col)
        line(xB, yB, x1, y1, "yellow")

        if (rL)  {
            printf "# rL\n"
            xC = xA + ToRad * s
            yC = yA + ToRad * c
            a0 = 270  + ang
            a1 =  a0 - ToAng
            a  = ang - ToAng
        }
        else {
            printf "# ! rL\n"
            xC = xA + ToRad * s
            yC = yA - ToRad * c
            a0 =  90 - ang 
            a1 =  a0 + ToAng
            a  = ang + ToAng
        }
        arc(xC, yC, a0, a1,ToRad, col)

        # ----------------------------
        c1 = cos(a1 * Pi / 180)
        s1 = sin(a1 * Pi / 180)

        xD = xC + ToRad  * c1
        yD = yC + ToRad  * s1

        # ----------------------------
        # extend end-point of diverging rail
        c  = cos(a * Pi/180)
        s  = sin(a * Pi/180)
        x  = xD - c * ToExt
        y  = yD - s * ToExt
        line(xD, yD, x, y, "yellow")
    }

    printf "# to: Fn %d, ToAng %6.2f, Tolen %6.2f\n",     ToFn, ToAng, ToLen
    printf "# x0 %6.2f, y0 %6.2f, ang %6.2f, rL %d\n",    x0, y0, ang, rL
    printf "# xA %6.2f, yA %6.2f\n",                      xA, yA
    printf "# xC %6.2f, yC %6.2f, a0  %6.2f, a1 %6.2f\n", xC, yC, a0, a1
    printf "# xD %6.2f, yD %6.2f, a   %6.2f\n",           xD, yD, a
    printf "# xB %6.2f, yB %6.2f\n",                      xB, yB
    printf "# x1 %6.2f, y1 %6.2f\n",                      x1, y1

    printf "# c  %6.2f, s  %6.2f, a  %6.2f\n", c,  s,  a
    printf "# x  %6.2f, y  %6.2f\n",           x,  y
    printf "# --------------------\n"
}

# ------------------------------------------------
# determine endpoints for 2 rail turnout
function turnout (x0, y0, ang) {

    line(0, 0,  0, 6, "black")
    printf "thickness = 2\n"

    to(x0, y0+3, ang, rL=1, toRight=1, "dark-gray")

    to(x0, y0+2, ang, rL=1, toRight=0, "dark-gray")
    to(x0, y0+1, ang, rL=0, toRight=0, "dark-gray")

    to(x0, y0,   ang, rL=0, toRight=1, "dark-gray")

    if (1)
        return

    y1 = y0 + G/2
    y2 = y0 - G/2

    col2 = "cyan"
    line(x0, y1, x0+ToLen, y1, col2)
    line(x0, y2, x0+ToLen, y2, col2)

    col3 = "red"
    xC   = x0
    yC   = y0 + ToRad
    a0   = ang -90
    a1   = ang -90 + ToAng
    arc(xC, yC, a0, a1, ToRad - G/2, col3)
    arc(xC, yC, a0, a1, ToRad + G/2, col3)
    printf "# turnout: a0 %6.2f, a1 %6.2f\n", a0, a1

    # ----------------------------
    # 1 in. extension beyond frog
    col4 = "yellow"
    c    = cos(ToAng * Pi/180)
    s    = sin(ToAng * Pi/180)
    x1   = x0 + ToLen
    x3   = x1 + c
    y3   = y1 + s
    line(x1, y1, x3, y3, col4)
    printf "# turnout: x1 %6.3f, y1 %6.3f, x3 %6.3f, y3 %6.3f, s %.4f\n", \
                                        x1, y1, x3, y3, s

    x4  = x3 - s * G/2
    y4  = y3 + c * G/2
    line(x3, y3, x4, y4, col4)

    # ----------------------------
    # another approach
    rad = sqrt(1^2 + (G/2)^2)
    a2  = ToAng + atan2(G/2, 1) * 180/Pi
    c    = cos(a2 * Pi/180)
    s    = sin(a2 * Pi/180)
    x5   = x1 + rad * c
    y5   = y1 + rad * s
    line(x1, y1, x5, y5, col4)
  # printf "title_x: a2 %6.2f, x5 %6.2f\n", a2, x5
}

# ------------------------------------------------
function yard (N, len, col) {
    line(0, 0, 0, 16, "black")
    siding(0,   2, a=0, rL=0, N, len, col)

    ladder(x10, y10, a10, ! rL, N, len, col)

    x = "1-mainline 2-arrival 3-outbound 4-loc-1 5-loc-2 7-locos 8-cabeese"
    F = split(x, text, " ")
    f = 1
    X = 70
    for (y = 2.1; f <= F; y += 1.55)
        printf "anno %d %8.4f %s\n", X, y, text [f++]

    printf "title_x frog# %d\n", ToFn
}

# --------------------------------------------------------------------
BEGIN  {
    Pi    = atan2(0, -1)
    G     = 0.65

    AngSdg = 10
    ColTrk = "orange"
    DD     = 0
    Col1   = "red"
    Col2   = "blue"
    Font   = 12
    W      = 1
}

# ------------------------------------------------
function abs (x) {
    if (0 > x)
        return -x
    return x
}

function sgn (x) {
    if (0 > x)
        return -1
    return 1
}

# ------------------------------------------------
function error (msg)  {
    printf " ** Error: %s - %s\n", msg, $0
    exit
}

# ------------------------------------------------
function xyPairs (thick, col) {
    printf "\n"
    printf "<path d=\""

    if (! col)
        col = ColTrk

    n = 2
    printf "M%d %d",  S*$n, S*(Ht-$(n+1))
    for (n += 2; n < NF; n += 2)
        printf " L%d %d",  S*$n, S*(Ht-$(n+1))

    if ("white" == col)
        col = "black"
    printf "\" stroke=\"%s\" stroke-width=\"%d\" fill=\"none\" />\n", col, W
}

# ------------------------------------------------
filename != FILENAME {
    filename = FILENAME
    printf "<!-- %s -->\n", filename
}

/^ *#/  { next }
! NF    { next }
/quit/  { exit }

/Font/  { Font = $2; next }
/^ *W/  { W = $2; next }


/arc/   { arc($2, $3, $4, $5, $6, $7);      next }
/rect/  { rect($2, $3, $4, $5);             next }

/bench/ { xyPairs(2);                       next }
/color/ { ColTrk = $2; if ($3) W = $3;      next }  
/colDD/ { Col1 = $2; Col2 = $3; if ($4) W = $4;      next }  
/obj/   { xyPairs(2, "");                   next }
/plug/  { plug($2, $3, $4);                 next }
/room/  { xyPairs(2, "blue");               next }
/space/ { svgBegin($2, $3, $4);             next }
/title/ { title = substr($0, index($0, $2)); next }


/text/  {
    if (0 < $4 && $4 < 9999)  {
        font = $4
        anno($2, $3, substr($0, index($0, $5)), font)
    }
    else
        anno($2, $3, substr($0, index($0, $4)), Font)
    next
}

# ------------------------------------------------
/aspect/ {
    printf "set_color %d = (%d, %d, %d)\n", g1=33, 50, 50, 50
    arc($2, $3, 0, 360, $4, g1)
    next
}

# ------------------------------------------------
/curve/ {
    rad  = $2
    dAng = $3
    col  = $4

    if (4 <= NF)  {
        curve(rad, dAng, col)
    }
    else
        curve(rad, dAng, ColTrk)
}

# ------------------------------------------------
function curve (rad, dAng, color) {
    printf "\n"
    printf "# curve: rad %.1f, dAng %.1f, color %s\n", red, dAng, color

    if (0 < dAng)  {
        a0   = dir - 90
        a1   = a0 + dAng
        dir  = (a1 + 90) % 360
        col1 = Col1;   col2 = Col2
    }
    else {
        a0  = dir + 90
        a1  = a0 + dAng
        dir = (a1 - 90) % 360
        col1 = Col2;   col2 = Col1
    }

    c = cos(a0 * Pi / 180)
    s = sin(a0 * Pi / 180)
    xC = xPos - c * rad
    yC = yPos - s * rad


  # if ("" != dbg)
  #     mark(xC, yC, 1, 1, "yellow")

    col = ColTrk
    if ("" != color) {
        col = color
        printf "#   col %s\n", col
    }

    if (DD)  {
        arcDbl(xC, yC, a0, a1, rad, DD, col1, col2)
    }
    else
        arc(xC, yC, a0, a1, rad, col)

    c    = cos(a1 * Pi / 180);   s    = sin(a1 * Pi / 180)
    xPos = xC + c*rad;           yPos = yC + s*rad

    next
}

# --------------------------------------
/grid/ {
    x0 = $2;    y0 = int($3)
    x1 = $4;    y1 = int($5)
    dd = $6

    printf "thickness = 0.7\n"
    printf "set_color %d = (%d, %d, %d)\n", g2=33, 80, 80, 80
    for (x = x0; x <= x1; x += dd)
        line(x, y0, x, y1, g2)

    for (y = y0; y <= y1; y += dd)
        line(x0, y, x1, y, g2)

    next
}

# --------------------------------------
/lbl/ {
    printf "# lbl: %s, xPos %6.2f, yPos %.2f, dir %.2f\n", $2, xPos, yPos, dir
    lblX [$2] = xPos;  lblY [$2] = yPos; lblDir [$2] = dir
    anno(xPos, yPos, $2)
    next
}

# --------------------------------------
/mvto/ {
    lbl = $2
    if ("" == lblX [lbl])  {
        error(sprintf("\"%s\" unknown", lbl))
    }

    xPos = lblX [lbl]; yPos = lblY [lbl]; dir = lblDir [lbl]

    if ("rev" == $3)
        dir = (dir + 180) % 360

    printf "# mvto: xPos %6d, yPos %d, dir %d\n", xPos, yPos, dir
    next
}

# --------------------------------------
/mvtt/ {
    dir  = $2

    xPos = xTt + cos(dir * Pi / 180) * diaTt /2;
    yPos = yTt + sin(dir * Pi / 180) * diaTt /2

    printf "# mvtt: xPos %6d, yPos %d, dir %d\n", xPos, yPos, dir
    next
}

# --------------------------------------
/pos/   { xPos = $2; yPos = $3; dir = $4;
  # mark(xPos, yPos, 1, 1, "red")
    next
}

# --------------------------------------
/sdg/ { 
    len   = $2
    right = $3
    sp    = $4

    spur(len, right, sp)

    dir -= angSdg
    str(lenDiv)

    dir = dirLst
    next
}

# --------------------------------------
/spur/ { spur($2, $3, $4); next }

# ----------------------------
function spur (len, right, sp) {
    angSdg = AngSdg
    if ("right" == right)
        angSdg = -AngSdg

    dirLst = dir
    dir   += angSdg
    lenDiv = sp / sin(abs(angSdg) * Pi / 180)
    printf "# sdg: dirLst %.2f, dir %.2f, angSdg %.2f, lenDiv %.2f\n", \
        dirLst, dir, angSdg, lenDiv

    str(lenDiv)

    printf "# sdg chk 1\n"
    dir = dirLst
    str(len)
}

# --------------------------------------
/str/   {
    if (3 <= NF)
        str($2, $3)
    else
        str($2)
    next
}

# ----------------------------
function str (len, col) {
    printf "\n"
    printf "# str: xPos %6d, yPos %d, dir %d, len %.2f\n", xPos, yPos, dir, len
    x0   = xPos;                  y0   = yPos
    ang  = dir * Pi / 180
    c    = cos(ang);              s    = sin(ang)
    xPos = x0 + c * len;          yPos = y0 + s * len

    if (! col)
        col = ColTrk

    if (! DD)
        line(x0, y0, xPos, yPos, col)
    else if (0 > len)
        lineDbl(x0, y0, xPos, yPos, DD, Col2, Col1)
    else
        lineDbl(x0, y0, xPos, yPos, DD, Col1, Col2)
}

# --------------------------------------
# turntable
/tt/   {
    diaTt = $2

    if (! col)
        col = ColTrk

    xTt  = xPos + cos(dir * Pi / 180) * diaTt /2;
    yTt  = yPos + sin(dir * Pi / 180) * diaTt /2
    arc(xTt, yTt, 0, 360, diaTt /2, col)

    next
}

# ----------------------------
{
    printf "** Error: invalid input - %s\n", $0
    exit
}

# --------------------------------------------------------------------
END {
    svgEnd()
}' $*
