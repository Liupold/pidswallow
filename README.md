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
* POSIX compliant shell script.
* Just pass in the window id of the swallower.
* Work on a toggle mode. (swallow if not swallowed else vomit).
* Super fast. (Really!) (28.0ms). (using `dash`).

```sh
Benchmark #1: pidswallow -s 0x02A00003
  Time (mean ± σ):      28.0 ms ±   4.3 ms    [User: 13.8 ms, System: 18.0 ms]
  Range (min … max):    24.1 ms …  48.0 ms    74 runs
```

## Demo

[![Demo](https://yt-embed.herokuapp.com/embed?v=R6A_JHJ7ob8)](https://www.youtube.com/watch?v=R6A_JHJ7ob8 "Demo for pidswallow.")


## How it works

```shell
takes wid as as arg --> gets process tree --> check blacklist --> hide parent.
```
## Dependencies
1) xdo
2) xprop (`--loop` and `--glue`).
3) xev (`--glue`).
4) xdotool (cross-workspace `--glue`, optional).

## Installation

### Using AUR
* stable release. (Currently on 2.0)

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
1) Launch when WM/DE starts (Example: .xinitrc, i3-config, bspwrc)

```bash
pgrep -fl 'pidswallow -gl' || pidswallow -gl
```

2) Add the following to your `bashrc`, `zshrc` or shell init script. This step isn't strictly necessary, but it fixes problems with daemon-based terminals and also improves the performance of pidswallow.
**Note:** You might want to skip this step if you use Alacritty (see [Known Issues](#known-issues)).
**Note:** Your window manager has to focus new terminals as soon as they are spawned for this to work correctly.

```
[ -n "$DISPLAY" ]  && command -v xdo >/dev/null 2>&1 && xdo id > /tmp/term-wid-"$$"
trap "( rm -f /tmp/term-wid-"$$" )" EXIT HUP
```

3) Restart wm and terminals.

## Additional Configuration
Environment variables can be exported to change the behavior of pidswallow.

The following ones accept lists of space separated process names.
* `PIDSWALLOW_SHELL`: your shell(s) (e.g `bash`). Default: Taken from `$SHELL`
* `PIDSWALLOW_TERMINAL`: your terminal(s), as fallback if shell is not used (and if terminal supports it). Default: `$TERMINAL`
* `PIDSWALLOW_BLACKLIST`: parent cannot be swallowed, (if you launch one term from another you might want to add it to blacklist). Default: same as `$PIDSWALLOW_TERMINAL`
* `PIDSWALLOW_GLUE_BLACKLIST`: not touched by `--glue`. Default: empty

The ones following are executed in a subshell (`/bin/sh`) and support the special strings `$pwid` and `$cwid`, holding the parent and child window IDs, respectively.
* `PIDSWALLOW_SWALLOW_COMMAND`: used to swallow (hide) windows. Default: `xdo hide $pwid`
* `PIDSWALLOW_VOMIT_COMMAND`: used to vomit (unhide) windows. Default: `xdo show $pwid`
* `PIDSWALLOW_PREGLUE_HOOK`: executed before swallowing new child window when using `--glue`. Useful for floating windows in tiled WMs. Default: empty

## Tested on
*(If you did please let me know, If it dosent work create a issue).*

* [bspwm](https://github.com/baskerville/bspwm)
* [i3](https://i3wm.org/)
* [gnome](https://www.gnome.org/gnome-3/)
* [openbox](http://openbox.org/wiki/Main_Page)
* [plasma](https://kde.org/announcements/plasma5.0/)
* [Xfce](https://www.xfce.org/)
* [herbstluftwm](https://herbstluftwm.org/) (by [cbf305](https://github.com/cbf305))

## Known Issues
* <b>sxiv</b> doesn't support this (as of now). https://github.com/muennich/sxiv/issues/398
    - Solution: https://github.com/elkowar/sxiv/tree/set_net_wm_pid (use this).
* mpv (window incorrect size)
    - Solution: use `--no-keepaspect-window` flag when launching.
* Alacritty won't work with the shell based approach if your shell init script is sourced too quickly. See [this](https://github.com/alacritty/alacritty/issues/2817) issue.
    - Solution: fall back to terminal based approach, by skipping [Autostart step 2](#autostart)

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

## WM specific recommendations.
### bspwm
Add each set of lines to your `bspwmrc`, right before running pidswallow.
* Let bspwm handle window hiding.

```bash
export PIDSWALLOW_SWALLOW_COMMAND='bspc node $pwid --flag hidden=on'
export PIDSWALLOW_VOMIT_COMMAND='bspc node $pwid --flag hidden=off'
```
This way bspwm will remember window positions and won't lose track of swallowed windows.

* Follow `floating` state of parent (when using `--glue`).

```bash
export PIDSWALLOW_PREGLUE_HOOK='bspc query -N -n $pwid.floating >/dev/null && bspc node $cwid --state floating'
```
Check if parent window state is `floating` and apply the same to the child if that's the case.
This example should work in most cases, but feel free to add more complex hooks to your setup. (e.g. to mimic more properties of the parent).

