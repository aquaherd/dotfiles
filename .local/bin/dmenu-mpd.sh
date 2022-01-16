#!/bin/bash
. ~/.local/lib/dmenu-lib.sh

all_name='[ALL]'
mode=Library

d_artist() {
    mpc list artist | sort -f | ask 'Artist:' $DMENU_DEFAULTS
}

d_album() {
    local artist="$1"
    local albums

    mapfile -t albums < <(mpc list album artist "$artist")
    if (( ${#albums[@]} > 1 )) ; then
        {
            printf '%s\n' "$all_name"
            printf '%s\n' "${albums[@]}" | sort -f
        } | ask 'Album:' $DMENU_DEFAULTS
    else
        # We only have one album, so just use that.
        printf '%s\n' "${albums[0]}"
    fi
}

d_song() {
	mpc list title | sort -f |  ask 'Song:' $DMENU_DEFAULTS 
}

d_playlist() {
	mpc lsplaylists | ask 'Playlist:' $DMENU_DEFAULTS
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
	mpc clear
        mpc load "$(d_playlist)" > /dev/null && mpc play >/dev/null
    ;;
	Song)
		mpc clear
		mpc search title "$(d_song)" | mpc add
		mpc play >/dev/null
	;;
esac
