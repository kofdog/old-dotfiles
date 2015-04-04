#!/bin/bash

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}
monitor=${1:-0}
geometry=( $(herbstclient monitor_rect "$monitor") )
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi
# geometry has the format W H X Y
x=${geometry[0]}
y=${geometry[1]}
panel_width=${geometry[2]}
panel_height=40
font=$FONT_XFT
bgcolor=$BACKGROUND
selbg=$ACCENT
selfg=$BACKGROUND
dullfg=$LIGHT_GRAY
dullestfg=$DARKER_GRAY
num_hearts=10
icon_font="FontAwesome:style=Regular:size=10"
heart_icon=""

####
# Try to find textwidth binary.
# In e.g. Ubuntu, this is named dzen2-textwidth.
#if which textwidth &> /dev/null ; then
#    textwidth="textwidth";
#elif which dzen2-textwidth &> /dev/null ; then
#    textwidth="dzen2-textwidth";
#else
#    echo "This script requires the textwidth tool of the dzen2 project."
#    exit 1
#fi
textwidth=xftwidth
####
# true if we are using the svn version of dzen2
# depending on version/distribution, this seems to have version strings like
# "dzen-" or "dzen-x.x.x-svn"
if dzen2 -v 2>&1 | head -n 1 | grep -q '^dzen-\([^,]*-svn\|\),'; then
    dzen2_svn="true"
else
    dzen2_svn=""
fi

if awk -Wv 2>/dev/null | head -1 | grep -q '^mawk'; then
    # mawk needs "-W interactive" to line-buffer stdout correctly
    # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=593504
    uniq_linebuffered() {
      awk -W interactive '$0 != l { print ; l=$0 ; fflush(); }' "$@"
    }
else
    # other awk versions (e.g. gawk) issue a warning with "-W interactive", so
    # we don't want to use it there.
    uniq_linebuffered() {
      awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
    }
fi

hc pad $monitor $panel_height

{
    ### Event generator ###
    # based on different input data (mpc, date, hlwm hooks, ...) this generates events, formed like this:
    #   <eventname>\t<data> [...]
    # e.g.
    #   date    ^fg(#efefef)18:33^fg(#909090), 2013-10-^fg(#efefef)29

    while true ; do
		if ! mpc status >/dev/null; then
			sleep 5
		else
			echo "player $(mpc current)"
			mpc idleloop player
		fi
	done &

    while true ; do
        # "date" output is checked once a second, but an event is only
        # generated if the output changed compared to the previous run.
        date +$'date\t^fg(#d3d0c8)%H:%M^fg(#a09f93), %Y-%m-^fg(#d3d0c8)%d'
        sleep 1 || break
    done > >(uniq_linebuffered) &
    childpid=$!
    hc --idle
    kill $childpid
} 2> /dev/null | {
    IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
    visible=true
    date=""
    windowtitle=""
    while true ; do

        ### Output ###
        # This part prints dzen data based on the _previous_ data handling run,
        # and then waits for the next event to happen.

        bordercolor="#26221C"
        separator="^bg()^fg($selbg)|"
        # draw tags
        for i in "${tags[@]}" ; do
            case ${i:0:1} in
                '#')
                    echo -n "^bg($selbg)^fg($selfg)"
                    ;;
                '+')
                    echo -n "^bg($GREEN)^fg($selfg)"
                    ;;
                ':')
                    echo -n "^bg()^fg($WHITE)"
                    ;;
                '!')
                    echo -n "^bg($RED)^fg($selfg)"
                    ;;
                *)
                    echo -n "^bg()^fg($dullfg)"
                    ;;
            esac
            if [ ! -z "$dzen2_svn" ] ; then
                # clickable tags if using SVN dzen
                echo -n "^ca(1,\"${herbstclient_command[@]:-herbstclient}\" "
                echo -n "focus_monitor \"$monitor\" && "
                echo -n "\"${herbstclient_command[@]:-herbstclient}\" "
                echo -n "use \"${i:1}\") ${i:1} ^ca()"
            else
                # non-clickable tags if using older dzen
                echo -n " ${i:1} "
            fi
        done
        echo -n "$separator"
        echo -n "^bg()^fg($FOREGROUND) ${windowtitle//^/^^}"

		# Current track
        mpd=$(pidof mpd)

        # Battery
		battery=$(expr $(expr $(cat /sys/class/power_supply/BAT*/energy_now) \* 100) / $(cat /sys/class/power_supply/BAT*/energy_full))
		num=$(expr $battery \* $num_hearts)
		num=$((num / 100))
		hearts=""
		empty=""
		for i in $(seq 1 $num); do
			hearts="${hearts}^fg($RED)${heart_icon}"
		done
		for i in $(seq $((num + 1)) $num_hearts); do
			empty="${empty}^fg($dullestfg)${heart_icon}"
		done
		bat="^fn($icon_font)${hearts}${empty}^fn($font)"

		right="$separator^fg($FOREGROUND)"
		if [ "$mpd" != "" ] ;then
			right="$right $song $separator^fg($FOREGROUND)"
		fi
		if [ "$battery" != "/" ] ;then
			right="$right $bat $separator^fg($FOREGROUND)"
		fi
        right="$right $date $separator"
        right_text_only=$(echo -n "$right" | sed 's.\^[^(]*([^)]*)..g')
        # get width of right aligned text.. and add some space..
        width=$($textwidth "$font" "$right_text_only")
        # TODO: Make this work dynamically
		echo -n "^pa($(($panel_width - $width + 4 * $($textwidth $font $bat))))$right"
        echo

        ### Data handling ###
        # This part handles the events generated in the event loop, and sets
        # internal variables based on them. The event and its arguments are
        # read into the array cmd, then action is taken depending on the event
        # name.
        # "Special" events (quit_panel/togglehidepanel/reload) are also handled
        # here.

        # wait for next event
        IFS=$'\t' read -ra cmd || break
        # find out event origin
        case "${cmd[0]}" in
            tag*)
                #echo "resetting tags" >&2
                IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
                ;;
            date)
                #echo "resetting date" >&2
                date="${cmd[@]:1}"
                ;;
            quit_panel)
                exit
                ;;
            togglehidepanel)
                currentmonidx=$(hc list_monitors | sed -n '/\[FOCUS\]$/s/:.*//p')
                if [ "${cmd[1]}" -ne "$monitor" ] ; then
                    continue
                fi
                if [ "${cmd[1]}" = "current" ] && [ "$currentmonidx" -ne "$monitor" ] ; then
                    continue
                fi
                echo "^togglehide()"
                if $visible ; then
                    visible=false
                    hc pad $monitor 0
                else
                    visible=true
                    hc pad $monitor $panel_height
                fi
                ;;
            reload)
                exit
                ;;
            focus_changed|window_title_changed)
                windowtitle="${cmd[@]:2}"
                ;;
            player)
				song=$(mpc current)
                ;;
        esac
    done

    ### dzen2 ###
    # After the data is gathered and processed, the output of the previous block
    # gets piped to dzen2.

} 2> /dev/null | dzen2 -w $panel_width -x $x -y $y -fn "$font" -h $panel_height \
    -e 'button3=;button4=exec:herbstclient use_index -1;button5=exec:herbstclient use_index +1' \
    -ta l
#} 2> /dev/null | dzen2 -w $panel_width -x $x -y $y -fn "$font" -h $panel_height \
#    -e 'button3=;button4=exec:herbstclient use_index -1;button5=exec:herbstclient use_index +1' \
#    -ta l -bg "$bgcolor" -fg '#efefef'
