# A stupid simple swallower 😉.
### (Based on Process hierarchy)


Super easy to config. Written for bspwm (can be ported to other wm easily).

## Features
* Based on process hierarchy (don't care about window focus).
* No loops. (you need to pass the wid externally somehow).
* Just pass in the widow id of the swallower.
* Work on a toggle mode. (swallow if not swollen else vomit).
* Super fast. (Really!) (0.02s)
```
./pidswallow '0x02600002'  0.02s user 0.03s system 95% cpu 0.060 total

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
bspc subscribe node_add node_remove \
        | grep -o --line-buffered '0x[0-9A-F]\+$' | xargs -n1 pidswallow &
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
* no need to blacklist xev (xev will not be swollen because it lacks `_NET_WM_PID`)

## Adding Terminals
* you can chnage the `swallowable` var to add term. (by default $TERMINAL is added).

## Knows Issues
* `sxiv` doesn't support this (as of now). https://github.com/muennich/sxiv/issues/398
* launching a second term from dmenu will not be swallowed. (because it's runs as a zsh subprocess_
  - Solution: `setsid -f kitty` instead of `kitty`. (from dmenu).

## Tricks.
* ### Manual swallow (toggle)

1) Add `pidswallow` to your path.
2) run this and click on the child window (not the term) to swallow.
```
 xwininfo | awk '/Window id:/{print $4}' | tr '[a-f]' '[A-F]' | xargs pidswallow
```
3) or pass the widow-id via keyboard shortcut.
* Launch a program from term wihout being swallowed.
```
setsid -f <command>  # this will not swallow the terminal.
```
