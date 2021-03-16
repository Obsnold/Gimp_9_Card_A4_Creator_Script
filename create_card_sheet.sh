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

#the values below are all in pixels at 300ppi
CARD_WIDTH=750
CARD_HEIGHT=1050
CARD_X_OFFSET="+2"
CARD_Y_OFFSET="-12"
PAGE_WIDTH=2480
PAGE_HEIGHT=3508
PIXEL_DENSITY=300

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
montage -border 1 -bordercolor black -tile x3 -geometry "$CARD_WIDTH"x"$CARD_HEIGHT"$CARD_X_OFFSET$CARD_Y_OFFSET  $FRONT_ORDER $TEMP/front.jpg
montage -border 1 -bordercolor black -tile x3 -geometry "$CARD_WIDTH"x"$CARD_HEIGHT"$CARD_X_OFFSET$CARD_Y_OFFSET  $BACK_ORDER $TEMP/back.jpg
convert -extent "$PAGE_WIDTH"x"$PAGE_HEIGHT" -density $PIXEL_DENSITY -gravity center -background white  $TEMP/front.jpg $TEMP/front.pdf
convert -extent "$PAGE_WIDTH"x"$PAGE_HEIGHT" -density $PIXEL_DENSITY -gravity center -background white  $TEMP/back.jpg $TEMP/back.pdf
convert -density $PIXEL_DENSITY $TEMP/front.pdf $TEMP/back.pdf ./out.pdf

