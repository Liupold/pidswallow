# A stupid simple swallower 😉.
### (Based on Process hierarchy)

Super easy to config. Uses `xdoool` WM/DE independent.


## Features
* Based on process hierarchy (don't care about window focus).
* cli like options. (super easy to use within scripts).
* Window Managers and Desktop Environment Independent.

```shell
pidswallow (pid swallow WM/DE independent)
Hides terminal window automatically, so that you don't have to

pidswallow [OPTION ...]

OPTIONS:
        -h  --help              Show this message
        -s  --swallow <CWID>    Hides parent window of the given child window id.
        -v  --vomit <CWID>      Unhides parent window of the given child window id.
        -t  --toggle <CWID>     toggle between swallow and vomit. (default)
        -g  --glue              treat if parent and child window are same. (recommended)
        -l  --loop              listen and hide / unhide window on launch / remove.
        -V  --verbose           Shows useful information.

bugs/issues: https://github.com/liupold/pidswallow.
```
* Just pass in the window id of the swallower.
* Work on a toggle mode. (swallow if not swallowed else vomit).
* Super fast. (Really!) (0.02s) (faster than before).

```
pidswallow '0x04800003'  0.02s user 0.04s system 107% cpu 0.058 total (swallow)
pidswallow '0x04800003'  0.01s user 0.01s system 71% cpu 0.032 total (vomit)
```

## Demo

[![Demo](https://yt-embed.herokuapp.com/embed?v=R6A_JHJ7ob8)](https://www.youtube.com/watch?v=R6A_JHJ7ob8 "Demo for pidswallow.")


## How it works

```shell
takes wid as as arg --> gets process tree --> check blacklist --> hide parent.
```
## Dependencies
1) xdotool (Needed for pid -> window-id conversion).
2) xprop (Needed for window-id -> pid conversion).
3) windows needed to have `_NET_WM_PID`.

## Installation
1) Add `pidswallow` to your path.
2) Launch when WM/DE starts (Example: .xinitrc, i3-config, bspwrc)

```bash
pgrep -fl 'pidswallow -gl' || pidswallow -gl
```
3) Restart wm.

## Tested on
*(If you did please let me know, If it dosent work create a issue).*

* bspwm
* i3
* gnome
* openbox
* plasma (kde-plasma)

## Blacklisting
If you want to blacklist some program you need to black list their process name. (obtained from top/ps).
To the `blacklist` variable [space separated].

* no need to blacklist xev (xev will not be swallowed because it lacks `_NET_WM_PID`)

## Adding Terminals
* you can change the `swallowable` var to add term. (by default $TERMINAL is added).

## Knows Issues
* `sxiv` doesn't support this (as of now). https://github.com/muennich/sxiv/issues/398
    - Solution: https://github.com/elkowar/sxiv/tree/set_net_wm_pid (use this).

## Tricks.
* ### Manual swallow (toggle)

1) Add `pidswallow` to your path.
2) run this and click on the child window (not the term) to swallow.
```
 xwininfo | awk '/Window id:/{print $4}' | tr '[a-f]' '[A-F]' | pidswallow -t
```
3) or pass the window-id via keyboard shortcut. (Eg: sxhkd toggle).

```
super + v
    pidswallow -t "0x$(echo "ibase=10;obase=16; $(xdotool getwindowfocus)" | bc)"
```

* Launch a program from term wihout being swallowed.
```
setsid -f <command>  # this will not swallow the terminal.
```
