# A stupid simple swallower 😉.
### (Based on Process hierarchy)

Super easy to config. Uses `xdo` WM/DE independent.

[![PKGBUILD-STATUS](https://github.com/Liupold/pidswallow/workflows/PKBUILD/badge.svg)](https://github.com/Liupold/pidswallow/actions?query=workflow%3A%22PKBUILD%22)
[![SHELLCHECK-STATUS](https://github.com/Liupold/pidswallow/workflows/shellcheck/badge.svg)](https://github.com/Liupold/pidswallow/actions?query=workflow%3A%22shellcheck%22)
[![license](https://img.shields.io/github/license/liupold/pidswallow.svg)](https://github.com/liupold/pidswallow/blob/master/LICENSE)
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
* Super fast. (Really!) (0.04s) (worst case).

```
$ time pidswallow -t 29360131
pidswallow 29360131  0.04s user 0.03s system 115% cpu 0.060 total (swallow)

$ time pidswallow -t 29360131
pidswallow 29360131  0.03s user 0.01s system 83% cpu 0.048 total (vomit)
```

## Demo

[![Demo](https://yt-embed.herokuapp.com/embed?v=R6A_JHJ7ob8)](https://www.youtube.com/watch?v=R6A_JHJ7ob8 "Demo for pidswallow.")


## How it works

```shell
takes wid as as arg --> gets process tree --> check blacklist --> hide parent.
```
## Dependencies
1) xdo (Needed for pid -> window-id conversion).
2) xprop (Needed for window-id -> pid conversion and for --loop).
3) xev (Needed for --glue).
4) windows needed to have `_NET_WM_PID`.
5) xdotool (optional) (Workspace Management).

## Installation

### Using AUR
* stable release. (Currently on 1.0)

```bash
yay -S pidswallow
```

* dev (git)
```bash
yay -S pidswallow-dev-git
```
### Manual
 Add `pidswallow` to your path.

### Autostart

2) Launch when WM/DE starts (Example: .xinitrc, i3-config, bspwrc)

```bash
pgrep -fl 'pidswallow -gl' || pidswallow -gl
```
3) Restart wm.

## Additional Configuration
Environment variables can be exported to change the behavior of pidswallow.

The following ones accept lists of space separated process names.
* `PIDSWALLOW_SWALLOWABLE`: can be swallowed by pidswallow (e.g. your terminal). Default: "alacritty urxvt konsole xfce4-terminal"
* `PIDSWALLOW_BLACKLIST`: parent cannot be swallowed. Default: copy from `$PIDSWALLOW_SWALLOWABLE`
* `PIDSWALLOW_GLUE_BLACKLIST`: not touched by `--glue`. Default: empty

The ones following are executed in a subshell (`/bin/sh`) and support the special strings `{%pwid}` and `{%cwid}`, holding the parent and child window IDs, respectively.
* `PIDSWALLOW_SWALLOW_COMMAND`: used to swallow (hide) windows. Default: `xdo hide {%pwid}`
* `PIDSWALLOW_VOMIT_COMMAND`: used to vomit (unhide) windows. Default: `xdo show {%pwid}`
* `PIDSWALLOW_PREGLUE_HOOK`: executed before gluing (resizing) new child window. Only applies when `--glue` is used. Default: empty

## Tested on
*(If you did please let me know, If it dosent work create a issue).*

* [bspwm](https://github.com/baskerville/bspwm)
* [i3](https://i3wm.org/)
* [gnome](https://www.gnome.org/gnome-3/)
* [openbox](http://openbox.org/wiki/Main_Page)
* [plasma](https://kde.org/announcements/plasma5.0/)
* [Xfce](https://www.xfce.org/)
* [herbstluftwm](https://herbstluftwm.org/) (by [cbf305](https://github.com/cbf305))

## Knows Issues
* <b>sxiv</b> doesn't support this (as of now). https://github.com/muennich/sxiv/issues/398
    - Solution: https://github.com/elkowar/sxiv/tree/set_net_wm_pid (use this).
* By default, every <b>Xfce Terminal</b> is connected to the same D-Bus daemon. This makes it hard for pidswallow to see which terminal should be swallowed, since they all share the same PID.

   -> As a workaround, you can edit the Xfce Terminal launcher to use the `--disable-server` flag:
    - Open Application Finder
    - Search for "Xfce Terminal"
    - Right click the result that has "Terminal Emulator" as its description and click Edit
    - Change the "Command" field to `xfce4-terminal --disable-server`
    - Save

## Tricks
### Manual swallow (toggle)

1) Add `pidswallow` to your path.
2) run this and click on the child window (not the term) to swallow.
```
 xwininfo | awk '/Window id:/{print $4}' | pidswallow -gt
```
3) or pass the window-id via keyboard shortcut. (Eg: sxhkd toggle).

```
super + v
    xdo id | pidswallow -gt
```

### Launch a program from term wihout being swallowed.
```
setsid -f <command>  # this will not swallow the terminal.
```

## WM specific recommendations (Experimental)
### bspwm
Add each set of lines to your `bspwmrc`, right before running pidswallow.
* Let bspwm handle window hiding.

```bash
export PIDSWALLOW_SWALLOW_COMMAND='bspc node {%pwid} --flag hidden=on'
export PIDSWALLOW_VOMIT_COMMAND='bspc node {%pwid} --flag hidden=off'
```
This way bspwm will remember window positions and won't lose track of swallowed windows.

* Follow `floating` state of parent (when using `--glue`).

```bash
export PIDSWALLOW_PREGLUE_HOOK='bspc query -N -n {%pwid}.floating >/dev/null && bspc node {%cwid} --state floating'
```
Check if parent window state is `floating` and apply the same to the child if that's the case.
This example should work in most cases, but feel free to add more complex hooks to your setup. (e.g. to mimic more properties of the parent).

