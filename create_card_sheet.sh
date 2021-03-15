#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "xcf_to_pdf.sh PATH_TO_INPUT"
    echo "$#"
    exit 0
fi

FRONT_ORDER="out/front_1.png out/front_2.png out/front_3.png out/front_4.png out/front_5.png out/front_6.png out/front_7.png out/front_8.png out/front_9.png"
BACK_ORDER="out/back_3.png out/back_2.png out/back_1.png out/back_6.png out/back_5.png out/back_4.png out/back_9.png out/back_8.png out/back_7.png"

IN_DIR="\"$1*\""

rm -rf ./out
mkdir ./out

echo "Convert gimp files to png"
gimp -i -b "
(let*
  (
    (file-names-list (cadr (file-glob $IN_DIR 1))) 
    (out-directory \"./out/\")
  )
  (map
    (lambda (file-name)
      (let* (
              (image (car (gimp-file-load RUN-NONINTERACTIVE file-name file-name)))
              (layer (car (gimp-image-merge-visible-layers image 1)))
              (image-name (car (gimp-image-get-name image)))
              (base-name (car (strbreakup image-name \".\")))
              (out-path (string-append out-directory base-name \".png\"))
            )

            (file-png-save 1 image layer out-path out-path FALSE FALSE TRUE FALSE FALSE FALSE TRUE)
            (gimp-image-delete image)
        )
      )
    file-names-list
    )
  )
" -b "(gimp-quit 0)"

echo "use ImageMagick to paste everything together"
montage -border 1 -bordercolor black -tile x3 -geometry 750x1050+2-12  $FRONT_ORDER out/front.jpg
montage -border 1 -bordercolor black -tile x3 -geometry 750x1050+2-12  $BACK_ORDER out/back.jpg
convert -extent 2480x3508 -density 300 -gravity center -background white  out/front.jpg out/front.pdf
convert -extent 2480x3508 -density 300 -gravity center -background white  out/back.jpg out/back.pdf
convert -density 300 out/front.pdf out/back.pdf ./out.pdf

rm -rf ./out
