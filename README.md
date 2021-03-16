# GIMP 9 Card A4 Creator Script
This scipt was created for the BoardGameGeek annual 9 card competion.
It can take a folder containing individual xcf card files and convert them into an easily printable pdf.

It requires gimp and ImageMagick to use.
Only tested on  Ubuntu 20-04.

To use jsut run the script and supply it with the folder you want:
./create_card_sheet.sh example_cards

This will produce an out.pdf

To change the order of the cards you will need to change the FRONT_ORDER and BACK_ORDER variables in the script.
At the moment the image files used to make the pdf will be stored in ./temp/ the files will be named the same as your .xcf files but with .png instead

You can also reuse the same image in the list so if you want all the cards to have the same back just repeat that image 9 times in the list.

example cards were taken from:
https://www.fairway3games.com/free-poker-sized-card-templates/
