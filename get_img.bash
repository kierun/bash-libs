#!/bin/bash
for url in "$@"
do
    clean_url=$(echo "$url" | sed 's/\?.*//')
    filename=$(basename -- "$clean_url")
    #dst="$HOME/html/www.kierun.org/public/gallery/Wallpapers/$(date +%Y)"
    dst="$HOME/html/www.kierun.org/public/gallery/Wallpapers/Preferred/"
    extension="${filename##*.}"
    filename="${filename%.*}"

    # If there are duplicates, make sure we have a count and the year.
    if [[ -f "$dst/$filename.$extension" ]] ; then
        yr=$(date +%Y)
        filename="$filename-$yr"
        i=0
        while [[ -f "$dst/$filename-$i.$extension" ]] ; do
            (( i++ ))
        done
        filename="$filename-$i"
    fi
    echo "Writing to $filename.$extension"
    curl "$clean_url" --output "$dst/$filename.$extension"

    if [[ $extension == *"webp"* ]]; then
        dwebp "$dst/$filename.$extension" -o "$dst/$filename.jpg"
        rm "$dst/$filename.$extension"
    fi

done
echo ""
echo "cd ~/html/www.kierun.org/public/gallery/Wallpapers/Preferred"
echo "../../../gallery/scripts/polaroid_overlap.sh"
echo "sudo rm ~/html/www.kierun.org/public/gallery/_sfpg_data/*/Wallpapers/Preferred/_image.jpg"
echo ""
