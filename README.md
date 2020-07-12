# A stupid simple swallower 😉.
### (Based on Process hierarchy)

Super easy to config. Written for bspwm (can be ported to other wm easily).

*Note: This new update is meant to be dropin replacement.(But it is recomended to update the bspwmrc)*

## Features
* Based on process hierarchy (don't care about window focus).
* cli like options. (super easy to use within scripts).
* Just pass in the window id of the swallower.
* Work on a toggle mode. (swallow if not swallowed else vomit).
* Super fast. (Really!) (0.02s) (faster than before).

```
pidswallow 0x01800003  0.02s user 0.03s system 109% cpu 0.045 total (swallow)
pidswallow 0x01800003  0.01s user 0.00s system 81% cpu 0.017 total (vomit)
```

## [Demo!](https://www.youtube.com/watch?v=R6A_JHJ7ob8&feature=youtu.be)


## How it works

```shell
takes wid as as arg --> gets process tree --> check blacklist --> hide parent.
```
## Dependencies
1) xargs (`find-utils`)
2) xdotool (Needed for pid -> window-id conversion).
3) xprop (Needed for window-id -> pid conversion).
4) windows needed to have `_NET_WM_PID`.


## Using with bspwm.

1) Add `pidswallow` to your path.
2) Add the following script at the end of your bspwmrc. (`~/.config/bspwmrc`)

```bash
TEMP="$(pgrep -f 'pidswallow --loop')"; [ -n "$TEMP" ] && kill $TEMP ; pidswallow --loop &
```
3) Restart wm.

## Other wm
* you need to run this script whenever a new window launches with the window id.
(use some sort of event monitor/subscription)

```shell
pidswallow <window-id>
```

* Need to provide some way to hide the window. (or maybe minimize them).
Look into your window manager manual/docs or use `xdotool`. (ex: you can use xdotool to minimise/hide in gnome).
* Change `#*` lines in the script with your preferred way of hiding windows.

## Blacklisting
If you want to blacklist some program you need to black list their process name. (obtained from top/ps). To the black list variable space separated.
* no need to blacklist xev (xev will not be swallowed because it lacks `_NET_WM_PID`)

## Adding Terminals
* you can change the `swallowable` var to add term. (by default $TERMINAL is added).

## Knows Issues
* `sxiv` doesn't support this (as of now). https://github.com/muennich/sxiv/issues/398

## Tricks.
* ### Manual swallow (toggle)

1) Add `pidswallow` to your path.
2) run this and click on the child window (not the term) to swallow.
```
 xwininfo | awk '/Window id:/{print $4}' | tr '[a-f]' '[A-F]' | xargs pidswallow
```
3) or pass the window-id via keyboard shortcut.
* Launch a program from term wihout being swallowed.
```
setsid -f <command>  # this will not swallow the terminal.
```
