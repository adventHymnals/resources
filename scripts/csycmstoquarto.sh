#!/bin/bash
wget -O hymnals.yaml https://raw.githubusercontent.com/adventHymnals/hymnals/master/hymnals.yaml
sudo wget https://github.com/mikefarah/yq/releases/download/v4.4.1/yq_linux_amd64 -O /usr/bin/yq &&\
sudo chmod +x /usr/bin/yq

yq e   '. | keys' hymnals.yaml | while read -r line ; do     # get all keys(hymnal shortnames)
    hymnal=$(echo $line |cut -b 3-) # remove the leading dash and whitespace (- blog -> blog)
    # check if gtLink is available and clone into $link
    gtLink=$(yq e ".$hymnal.gtLink" hymnals.yaml)
    if [ "$gtLink" != "null" ]; then
        gtLink="https://github.com/$gtLink.git"
        link=$(yq e ".$hymnal.link"  hymnals.yaml)
        rm -rf "$link" && git clone $gtLink $link
    fi
done

find . -name "*.md" | xargs sed -i "s/^Navigation:/toc:/gi"
find . -name "*.qmd" | xargs sed -i "s/^Navigation:/toc:/gi"

find . -wholename "*/[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]-*.qmd" -or -wholename "*/[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]-*.md" | while read -r line ; do 
    newPath=$( echo $line | sed -e 's|/[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]-|/|g' )
    mv "$line" "$newPath"
done

find . -wholename "*/[0-9][0-9].*"  | sort -r | while read -r line ; do 
    reversed=$( echo $line|rev) # use reverse so we can replace the last occurence as the first
    newPath=$( echo $reversed | sed -e 's|\.[0-9][0-9]/|/|g' |rev ) 
    
    #last dir
    lastDir=$(echo $newPath|rev |sed -e 's|^[^/]*/||g' |rev ) 
    echo "mv $line $newPath\n$lastDir" >> lines.txt
    mkdir -p "$lastDir"
    mv "$line" "$newPath"
    # if [ -d "$newPath" ]; then
    #     echo "cp -r $line/* $newPath/" >> lines.txt
    #     cp -r "$line/* $newPath/" && rm -rf "$line"
    # else
    #     mv "$line" "$newPath"
    # fi
done



find . -wholename "*/chapter.md"  | while read -r line ; do 
    newPath=$( echo $line | sed -e 's|/chapter\.md|/index.md|' ) 
    mv "$line" "$newPath"
done



find . -wholename "*/docs.md"  | while read -r line ; do 
    newPath=$( echo $line | sed -e 's|/\([^\]*\)/docs\.md|/\1.md|' ) 
    mv "$line" "$newPath"
done


find . -type d -empty -delete
