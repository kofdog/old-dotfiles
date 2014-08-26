/* See LICENSE file for copyright and license details. */



//-------------------------------------
// Header Files
//-------------------------------------

// Multimedia keys
#include <X11/XF86keysym.h>



//-------------------------------------
// Constants
//-------------------------------------

#define MODKEY Mod4Mask



//-------------------------------------
// Appearance
//-------------------------------------

//static const char font[] = "-*-terminus-medium-r-*-*-16-*-*-*-*-*-*-*";
static const char font[] = "Meslo LG S 9";
static const char dfont[] = "Meslo LG S-9";

// Colors for normal windows
static const char normbordercolor[] = "#6a9fb5";
static const char normbgcolor[]     = "#151515";
static const char normfgcolor[]     = "#d0d0d0";

// Colors for focused windows
static const char selbordercolor[] = "#f5f5f5";
static const char selbgcolor[]     = "#151515";
static const char selfgcolor[]     = "#ffffff";

// Border/margin stuff
static const unsigned int borderpx       = 3; /* border width of windows (pixels) */
static const unsigned int gappx          = 5; /* gap width between windows (pixels) */
static const unsigned int snap           = 5; /* snap tolerance (pixels) */
static const unsigned int systrayspacing = 2; /* item spacing (pixels) */

// Bar and system tray
static const Bool showsystray = False; /* False means no systray */
static const Bool showbar     = True;  /* False means no bar */
static const Bool topbar      = True;  /* False means bottom bar */

static const Bool statusmarkup = True; /* True means use pango markup in status message */



//-------------------------------------
// Interface
//-------------------------------------

// Tagging
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,            True,        -1 },
	{ "Firefox",  NULL,       NULL,       1 << 8,       False,       -1 },
};

// Layout
static const float mfact      = 0.55;  /* factor of master area size [0.05..0.95] */
static const int nmaster      = 1;     /* number of clients in master area */
static const Bool resizehints = False; /* True means respect size hints in tiled resizals */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};



//-------------------------------------
// Commands
//-------------------------------------

// Helper for spawning shell commands in the pre dwm-5.0 fashion
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

// Framework for tag-related commands
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

// Applications
static const char *termcmd[]  = { "urxvtc", "-title", "urxvt", NULL };
static const char *dmenucmd[] = { "dmenu_run", "-i", "-fn", dfont, "-nb", normbgcolor, "-nf", normfgcolor, "-sb", selbgcolor, "-sf", selfgcolor, NULL };

// Volume
static const char *volupcmd[]   = { "pactl", "set-sink-volume", "0", "+5%", NULL };
static const char *voldowncmd[] = { "pactl", "set-sink-volume", "0", "--", "-5%", NULL };
static const char *volmutecmd[] = { "pactl", "set-sink-volume", "0", "0%", NULL };

// Multimedia
static const char *musicplaycmd[] = { "ncmpcpp", "toggle", NULL };
static const char *musicnextcmd[] = { "ncmpcpp", "next", NULL };
static const char *musicprevcmd[] = { "ncmpcpp", "prev", NULL };

// Quit
static const char *reallyquitcmd[] = { "killall", "dwm-start", NULL };

// Keyboard shortcuts
static Key keys[] = {
	/* modifier                     key                      function        argument */
	{ MODKEY,                       XK_space,                spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_Return,               spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,                    togglebar,      {0} },
	{ MODKEY,                       XK_j,                    focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,                    focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,                    incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_d,                    incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,                    setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,                    setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_Return,               zoom,           {0} },
	{ MODKEY,                       XK_Tab,                  view,           {0} },
	{ MODKEY|ShiftMask,             XK_c,                    killclient,     {0} },
	{ MODKEY,                       XK_t,                    setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,                    setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,                    setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_p,                    setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_p,                    togglefloating, {0} },
	{ MODKEY,                       XK_0,                    view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,                    tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,                focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period,               focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,                tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period,               tagmon,         {.i = +1 } },
    { 0,                            XF86XK_AudioRaiseVolume, spawn,          {.v = volupcmd } },
    { 0,                            XF86XK_AudioLowerVolume, spawn,          {.v = voldowncmd } },
    { 0,                            XF86XK_AudioMute,        spawn,          {.v = volmutecmd } },
    { 0,                            XF86XK_AudioPlay,        spawn,          {.v = musicplaycmd } },
    { 0,                            XF86XK_AudioNext,        spawn,          {.v = musicnextcmd } },
    { 0,                            XF86XK_AudioPrev,        spawn,          {.v = musicprevcmd } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_r,                    quit,           {0} },
	{ MODKEY|ShiftMask,             XK_q,                    spawn,          {.v = reallyquitcmd } },
};

// Mouse shortcuts
/* click can be ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
