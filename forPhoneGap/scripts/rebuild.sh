
function syncWWW()
{
    SYNC_FROM="$1"
    shift
    SYNC_TO="$1"
    shift

    # Create any directories that exist in the source, but not in the target.
    find "$SYNC_FROM" -not -path '*/plugins/*' -type d \
        -exec test '!' -d "$SYNC_TO/"{} \; \
        -exec mkdir "$SYNC_TO/"{} \; \
        -print

    # Copy any files that are newer than the root. The calling code has to set
    # the modification time of the root so that there is no wasteful copying.
    find "$SYNC_FROM" -not -path '*/plugins/*' -type f \
        '(' -newer "$SYNC_FROM" -or -exec test '!' -f "$SYNC_TO/"{} \; ')' \
        -exec cp {} "$SYNC_TO/"{} \; \
        -print
}

echo "Synchronising asset files for Android"
syncWWW www platforms/android/assets
echo "Synchronising asset files for iOS"
syncWWW www platforms/ios
