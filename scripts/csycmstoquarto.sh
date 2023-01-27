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

for i in {1..2}; do # for some reason we need to loop as it sometime misses to rename all files
    yq e   '. | keys' hymnals.yaml | while read -r linei ; do     # get all keys(hymnal shortnames)
        hymnal=$(echo $linei |cut -b 3-) # remove the leading dash and whitespace (- blog -> blog)
        hymnal=$(yq e ".$hymnal.link"  hymnals.yaml)
        find "./$hymnal" -type d -wholename "*[^[:alnum:]+._/-]*"  | sort -r | while read -r line ; do 
            echo $line
            reversed=$( echo $line|rev) # use reverse so we can replace the last occurence as the first
            newPath=$( echo $reversed | sed -e 's|[^[:alnum:]+._/-]||g' |rev ) 
            # lastDir=$(echo $newPath|rev |sed -e 's|^[^/]*/||g' |rev ) 
            # echo $lastDir
            # mkdir -p "$lastDir"
            mv "$line" "$newPath"
        done
    done
done

yq e   '. | keys' hymnals.yaml | while read -r linei ; do     # get all keys(hymnal shortnames)
    hymnal=$(echo $linei |cut -b 3-) # remove the leading dash and whitespace (- blog -> blog)
    hymnal=$(yq e ".$hymnal.link"  hymnals.yaml)
    echo $hymnal
    find "./$hymnal"  -wholename "*.md*"| while read -r file ; do 
            echo $file
            sed -i "s/^Navigation:/toc:/gi" $file
            sed -i "s/^title:/pagetitle:/i" $file
    done
    find "./$hymnal"  -wholename "*.qmd*"| while read -r file ; do 
            sed -i "s/^Navigation:/toc:/gi" $file
            sed -i "s/^title:/pagetitle:/i" $file
    done
done

yq e   '. | keys' hymnals.yaml | while read -r line ; do     # get all keys(hymnal shortnames)
    hymnal=$(echo $line |cut -b 3-) # remove the leading dash and whitespace (- blog -> blog)
    hymnal=$(yq e ".$hymnal.link"  hymnals.yaml)

    find "./$hymnal" -wholename "*/[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]-*.qmd" -or -wholename "*/[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]-*.md" | while read -r line ; do 
        newPath=$( echo $line | sed -e 's|/[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]-|/|g' )
        echo $newPath
        mv "$line" "$newPath"
    done

    find "./$hymnal" -wholename "*/[0-9][0-9].*"  | sort -r | while read -r line ; do 
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



    find "./$hymnal" -wholename "*/chapter.md"  | while read -r line ; do 
        newPath=$( echo $line | sed -e 's|/chapter\.md|/index.md|' ) 
        mv "$line" "$newPath"
    done



    find "./$hymnal" -wholename "*/docs.md"  | while read -r line ; do 
        newPath=$( echo $line | sed -e 's|/\([^\]*\)/docs\.md|/\1.md|' ) 
        mv "$line" "$newPath"
    done

    if [ -d "$hymnal/indices" ]; then # if its a hymnal, (with indices dir)
        mv "$hymnal/index.md" "$hymnal/preface.md"
        mv "$hymnal/indices/index.md" "$hymnal/index.md"
        rm -rf "$hymnal/indices"
    fi

    find  "./$hymnal" -type d -empty -delete
   
done

echo "" > toc.txt
## Sort the hymnals by year
yq e   '. | keys' hymnals.yaml | while read -r line ; do     # get all keys(hymnal shortnames)
    hymnal=$(echo $line |cut -b 3-) # remove the leading dash and whitespace (- blog -> blog)
    link=$(yq e ".$hymnal.link"  hymnals.yaml)
    siteName=$(yq e ".$hymnal.siteName"  hymnals.yaml)
    if [ "$siteName" == "null" ]; then
        siteName=$(yq e ".$hymnal.name"  hymnals.yaml)
    fi
    if [ "$siteName" != "null" ]; then
        if [ "$link" != "null" ]; then
            year=$(yq e ".$hymnal.year"  hymnals.yaml)
            type=$(yq e ".$hymnal.type"  hymnals.yaml)
            if [ "$type" == "null" ]; then
                type="hymnal"
            fi
            if [ "$type" == "hymnal" ]; then
                echo "$year$hymnal" >> toc.txt
            fi
        fi
    fi
done

sort -r toc.txt -o toc1.txt && echo "">toc.txt

## remove year from hymnal short names
sed -i 's/^[0-9][0-9][0-9][0-9]//' toc1.txt

for hymnal in $(cat toc1.txt); do
    link=$(yq e ".$hymnal.link"  hymnals.yaml)
    siteName=$(yq e ".$hymnal.siteName"  hymnals.yaml)
    if [ "$siteName" == "null" ]; then
        siteName=$(yq e ".$hymnal.name"  hymnals.yaml)
    fi
    echo "      - href: $link" >> toc.txt
    echo "        text: $siteName" >> toc.txt
done

## remove blank lines
sed -i '/^$/d' toc.txt 
## insert into toc
sed -i '/^format:/e cat toc.txt' _quarto.yml

## do for blogs
echo "" > toc.txt
## Sort the hymnals by year
yq e   '. | keys' hymnals.yaml | while read -r line ; do     # get all keys(hymnal shortnames)
    hymnal=$(echo $line |cut -b 3-) # remove the leading dash and whitespace (- blog -> blog)
    link=$(yq e ".$hymnal.link"  hymnals.yaml)
    siteName=$(yq e ".$hymnal.siteName"  hymnals.yaml)
    if [ "$siteName" == "null" ]; then
        siteName=$(yq e ".$hymnal.name"  hymnals.yaml)
    fi
    if [ "$siteName" != "null" ]; then
        if [ "$link" != "null" ]; then
            year=$(yq e ".$hymnal.year"  hymnals.yaml)
            type=$(yq e ".$hymnal.type"  hymnals.yaml)
            if [ "$type" == "blog" ]; then
                echo "$year$hymnal" >> toc.txt
            fi
        fi
    fi
done

sort -r toc.txt -o toc1.txt && echo "">toc.txt

## remove year from hymnal short names
sed -i 's/^[0-9][0-9][0-9][0-9]//' toc1.txt

for hymnal in $(cat toc1.txt); do
    link=$(yq e ".$hymnal.link"  hymnals.yaml)
    siteName=$(yq e ".$hymnal.siteName"  hymnals.yaml)
    if [ "$siteName" == "null" ]; then
        siteName=$(yq e ".$hymnal.name"  hymnals.yaml)
    fi
    echo "      - href: $link" >> toc.txt
    echo "        text: $siteName" >> toc.txt
done

## remove blank lines
sed -i '/^$/d' toc.txt 
## insert into toc
sed -i '/^format:/e cat toc.txt' _quarto.yml
rm toc.*
