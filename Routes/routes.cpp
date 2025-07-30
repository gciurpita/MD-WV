// 

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <getopt.h>

char        *progname;
unsigned int debug = 0;
unsigned int flag  = 0;


// --------------------------------------------------------------------
#define MAX_TOKS   10
char * toks [MAX_TOKS];
float  vals [MAX_TOKS];

int
tokenize (
    char *s )
{
    int  i = 0;
    for (toks [i] = strtok (s, " "); toks [i]; )  {
        vals [i] = atof (toks [i]);
     // printf ("          %d %6d %s\n", i, vals [i], toks [i]);
        toks [++i] = strtok (NULL, " ");
    }

    return i;
}

// --------------------------------------------------------------------
int       ds64;
int       opSw;
int       bit;
uint8_t   adr;
uint32_t  val;

// ------------------------------------------------
void
decode (
    uint16_t  val )
{
    printf (" %04x", val);

    if (0xE000 != val && 0 != val)  {
        printf (" %04x", val & ~0x217f);

        int to = (((val & 0x100) >> 1) | (val & 0x7f)) + 1;
        printf (" %4d", to);
        printf (" %c",  0x600 == val & 0x0600 ? '*' : ' ');
        printf (" %c",  val & 0x2000 ? 'C' : 'T');
    }

    printf ("\n");
}

// ------------------------------------------------
void
report (
    const char *s )
{
    printf ("%5s", "");
    printf (" %2d  %3d", ds64, adr);
    decode (val & 0xFFFF);

    printf ("%13s", "");
    decode (val >> 16);

 // printf (" - %s", s);
 // printf ("\n");
}

// --------------------------------------------------------------------
void
application (char *filename)  {
    FILE  *fp;
    char   s[BUFSIZ];
    char   cmd;

    printf ("%s: %s\n", progname, filename);

    if ( (fp = fopen (filename, "rb")) == NULL)  {
        perror ("app - fopen input");
        exit (1);
    }

    while (fgets (s, BUFSIZ, fp) != NULL)  {
     // printf ("%s", s);

        if (strstr (s, "accepted"))
            continue;

        else if (strstr (s, "Query"))  {
            cmd = 'q';
            sscanf (s, "DS64 %d Query OpSw%d", & ds64, & opSw);
        }

        else if (strstr (s, "report"))  {
            cmd = 'r';
            if (1 != opSw)  {
                sscanf (s, "LONG_ACK: OpSwitch report - opSwitch is %d",
                                                                & bit);
                val |= bit << (opSw - 33);
                if (0)
                    printf (" %2d  %2d  (%2d %d) %8x\n",
                                ds64, adr, opSw, bit, val);
            }
        }

        else if (strstr (s, "Write"))  {
            cmd = 'w';
            sscanf (s, "DS64 %d Write OpSw%d value=%d",
                                        & ds64, & opSw, & bit);
            adr |= bit << opSw - 25;
        }

        // 46-48, 33-45, 62-64, 49-61
        if (61 == opSw && 'r' == cmd)  {
         // report (s);
            report ("\n");
            adr = val = 0;
        }
    }
    report (s);
}

// --------------------------------------------------------------------
void help (void)  {
    printf (" Usage: %s \n", progname);
}

// --------------------------------------------------------------------
int main (int argc, char **argv)  {
    int   c;

    progname = *argv;

    while ((c = getopt(argc, argv, "D:o")) != -1)  {
        switch (c)  {
        case 'D':
            debug = atoi (optarg);
            break;

        case 'o':
            break;

        default:
            printf ("Error: unknown option '%c'\n", optopt);
                        help();
            break;
        };

    }

    if (optind == argc)
        help();
    else
        for ( ; optind < argc; optind++)
            application (argv[optind]);

    return 0;
}
