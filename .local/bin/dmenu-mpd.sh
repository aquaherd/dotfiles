#!/bin/bash
. ~/.local/lib/dmenu-lib.sh

all_name='[ALL]'
mode=Library

d_artist() {
    mpc list artist | sort -f | ask 'Artist:'
}

d_album() {
    local artist="$1"
    local albums

    mapfile -t albums < <(mpc list album artist "$artist")
    if (( ${#albums[@]} > 1 )) ; then
        {
            printf '%s\n' "$all_name"
            printf '%s\n' "${albums[@]}" | sort -f
        } | ask 'Album:'
    else
        # We only have one album, so just use that.
        printf '%s\n' "${albums[0]}"
    fi
}

d_song() {
	mpc list title | sort -f | dmenu -i -p Song $DMENU_DEFAULTS 
}

d_playlist() {
    local format="%position% %title%"
    local extra_format="(%artist% - %album%)"
    local track
    local num_extras

    # If all tracks are from the same artist and album, no need to display that
    num_extras=$(mpc playlist -f "$extra_format" | sort | uniq | wc -l)
    (( num_extras == 1 )) || format+=" $extra_format"

    track=$(mpc playlist -f "$format" | ask 'Playlist:' $DMENU_DEFAULTS)
    printf '%s' "${track%% *}"
}

i=2

for arg do
    if [[ $arg == :: ]]; then
        dmenu_args=( "${@:$i}" )
        break
    fi

    case "$arg" in
        -l) mode=Library ;;
        -p) mode=Playlist ;;
		-s) mode=Song ;;
		-a) 
			MODE=$(echo -e "Library\nSong\nPlaylist" | ask 'mpd:' $DMENU_DEFAULTS)
			mode=$MODE ;;
    esac

    let i++
done

case "$mode" in
    Library)
        artist=$(d_artist)
        [[ $artist ]] || exit 1

        album=$(d_album "$artist")
        [[ $album ]] || exit 2

        mpc clear
        if [[ $album == "$all_name" ]]; then
            mpc find artist "$artist" | sort | mpc add
        else
            mpc find artist "$artist" album "$album" | sort | mpc add
        fi

        mpc play >/dev/null
    ;;
	Playlist)
        mpc play "$(d_playlist)" >/dev/null
    ;;
	Song)
		mpc clear
		mpc search title "$(d_song)" | mpc add
		mpc play >/dev/null
	;;
esac
