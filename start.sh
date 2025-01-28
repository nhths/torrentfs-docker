#! /bin/bash

#Usage:
#  torrentfs [OPTIONS...]
#Options:
#-disableTrackers   (bool)
#-downloadDir       (string)          location to save torrent data
#-listenAddr        (*net.TCPAddr)    Default: :0
#-metainfoDir       (string)          torrent files in this location describe the contents of the mounted filesystem (Default: /root/.config/transmission/torrents)
#-mountDir          (string)          location the torrent contents are made available
#-readaheadBytes    (tagflag.Bytes)   Default: 10 MB
#-testPeer          (*net.TCPAddr)

#set -ex

MOUNT_UID=${MOUNT_UID:-0}
MOUNT_GID=${MOUNT_GID:-0}

DIR_DOWNLOAD=${DIR_DOWNLOAD:-'/torrent-cache'}
DIR_TORRENTS_USERBIND=${DIR_TORRENTS_USERBIND:-'/torrent-files'}
DIR_META=${DIR_META:-'/torrentfs-files'}
DIR_MOUNT=${DIR_MOUNT:-'/torrentfs-mount'}
DIR_TORRENTFS_USERBIND=${DIR_TORRENTFS_USERBIND:-'/torrent-mount'}
READAHEAD=${READAHEAD:-'10M'}

mkdir $DIR_DOWNLOAD $DIR_META $DIR_MOUNT $DIR_TORRENTFS_USERBIND || echo 'target dirs already exist...'

CMD_TORRENTFS="/torrentfs -disableTrackers=false -mountDir=$DIR_MOUNT \
    -metainfoDir=$DIR_META -downloadDir=$DIR_DOWNLOAD -readaheadBytes=$READAHEAD"

bindfs --map=$MOUNT_UID/0:@$MOUNT_GID/@0 $DIR_TORRENTS_USERBIND $DIR_META

bindfs --map=0/$MOUNT_UID:@0/@$MOUNT_GID $DIR_MOUNT $DIR_TORRENTFS_USERBIND $(($CMD_TORRENTFS > /dev/null &) && sleep 2)

unbinding() {
    umount $DIR_TORRENTFS_USERBIND
    kill $(ps ac | grep 'torrentfs' | awk '{print $1}') >> /dev/null
    umount $DIR_TORRENTS_USERBIND
}

trap unbinding SIGINT SIGTERM

sleep inf
