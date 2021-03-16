#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "xcf_to_pdf.sh PATH_TO_INPUT"
    echo "$#"
    exit 0
fi

IN_DIR="\"$1*\""
TEMP="temp/"

FRONT_ORDER="$TEMP/front_1.png $TEMP/front_2.png $TEMP/front_3.png $TEMP/front_4.png $TEMP/front_5.png $TEMP/front_6.png $TEMP/front_7.png $TEMP/front_8.png $TEMP/front_9.png"
BACK_ORDER="$TEMP/back_3.png $TEMP/back_2.png $TEMP/back_1.png $TEMP/back_6.png $TEMP/back_5.png $TEMP/back_4.png $TEMP/back_9.png $TEMP/back_8.png $TEMP/back_7.png"

rm -rf $TEMP
mkdir $TEMP

echo "Convert gimp files to png"
gimp -i -b "
(let*
  (
    (file-names-list (cadr (file-glob $IN_DIR 1))) 
    (temp-directory \"./$TEMP/\")
  )
  (map
    (lambda (file-name)
      (let* (
              (image (car (gimp-file-load RUN-NONINTERACTIVE file-name file-name)))
              (layer (car (gimp-image-merge-visible-layers image 1)))
              (image-name (car (gimp-image-get-name image)))
              (base-name (car (strbreakup image-name \".\")))
              (temp-path (string-append temp-directory base-name \".png\"))
            )

            (file-png-save 1 image layer temp-path temp-path FALSE FALSE TRUE FALSE FALSE FALSE TRUE)
            (gimp-image-delete image)
        )
      )
    file-names-list
    )
  )
" -b "(gimp-quit 0)"

echo "use ImageMagick to paste everything together"
montage -border 1 -bordercolor black -tile x3 -geometry 750x1050+2-12  $FRONT_ORDER $TEMP/front.jpg
montage -border 1 -bordercolor black -tile x3 -geometry 750x1050+2-12  $BACK_ORDER $TEMP/back.jpg
convert -extent 2480x3508 -density 300 -gravity center -background white  $TEMP/front.jpg $TEMP/front.pdf
convert -extent 2480x3508 -density 300 -gravity center -background white  $TEMP/back.jpg $TEMP/back.pdf
convert -density 300 $TEMP/front.pdf $TEMP/back.pdf ./out.pdf

