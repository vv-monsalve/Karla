#!/bin/bash

# This script attempts to fix fails brought by FontBakery on Karla-Italic-VF.ttf
#
# USAGE: 
# Install requirements with `pip install -U -r misc/googlefonts-qa/requirements.txt`

# set -e
# source venv/bin/activate


KarlaRVF=./fonts/variable/Karla-Roman-VF.ttf
KarlaIVF=./fonts/variable/Karla-Italic-VF.ttf


# -------------------------------------------------------------------
# get latest font version -------------------------------------------

# ttx -t head $interUprightVF
# fontVersion=v$(xml sel -t --match "//*/fontRevision" -v "@value" ${interUprightVF/".ttf"/".ttx"})
# rm ${interUprightVF/".ttf"/".ttx"}

# # -------------------------------------------------------------------
# # fix variable font metadata as needed ------------------------------
# # these fixes all address things flagged by fontbakery --------------
# # note: this assumes variable fonts have no hinting -----------------
# # note: these should probably be moved into main build --------------

# build stat tables for proper style linking

gftools fix-vf-meta $KarlaRVF
gftools fix-vf-meta $KarlaIVF

mv "$KarlaRVF.fix" $KarlaRVF
mv "$KarlaIVF.fix" $KarlaIVF

echo "Hopefully this fixes the metadata issue?"

# prevent warnings/issues caused by no hinting tables – this fixes the file in-place

gftools fix-nonhinting $KarlaRVF $KarlaRVF
gftools fix-nonhinting $KarlaIVF $KarlaIVF

rm ${KarlaRVF/".ttf"/"-backup-fonttools-prep-gasp.ttf"}
rm ${KarlaIVF/".ttf"/"-backup-fonttools-prep-gasp.ttf"}

# assert google fonts spec for how fonts should rasterize in different contexts

gftools fix-gasp --autofix $KarlaRVF
gftools fix-gasp --autofix $KarlaIVF

mv ${KarlaRVF/".ttf"/".ttf.fix"} $KarlaRVF
mv ${KarlaIVF/".ttf"/".ttf.fix"} $KarlaIVF

# prevent warnings/issues caused by no digital signature tables

gftools fix-dsig --autofix $KarlaRVF
gftools fix-dsig --autofix $KarlaIVF

echo "all should be well in the land"
# # -------------------------------------------------------------------
# # navigate to google/fonts repo, get latest, then update inter branch

cd $gFontsDir
git checkout master
git pull upstream master
git reset --hard
git checkout -B Karla
git clean -f -d

# # -------------------------------------------------------------------
# # move fonts --------------------------------------------------------

# mkdir -p ofl/inter

# cp $interUprightVF    ofl/inter/Inter-Roman-VF.ttf
# cp $interItalicVF     ofl/inter/Inter-Italic-VF.ttf

# mkdir -p ofl/inter/static
# statics=$(ls $interDir/build/fonts/const-hinted/*.ttf)
# for ttf in $statics
# do
#     cp $ttf ofl/inter/static/$(basename $ttf)
# done

# # -------------------------------------------------------------------
# # make or move basic metadata ---------------------------------------

gftools add-font --update ofl/inter # do this the first time, then edit and copy

cp $interQADir/METADATA.pb ofl/inter/METADATA.pb

cp $interDir/LICENSE.txt ofl/inter/OFL.txt

cp $interQADir/gfonts-description.html ofl/inter/DESCRIPTION.en_us.html

# # -------------------------------------------------------------------
# # run checks, saving to inter/misc/googlefonts-qa/checks ------------

# set +e # otherwise, the script stops after the first fontbakery check output

# mkdir -p $interQADir/checks/static

# cd ofl/inter

# ttfs=$(ls -R */*.ttf && ls *.ttf) # use this to statics and VFs
# # ttfs=$(ls *.ttf) # use this to check only the VFs
# # ttfs=$(ls -R */*.ttf ) # use this to check only statics

# for ttf in $ttfs
# do
#     fontbakery check-googlefonts $ttf --ghmarkdown $interQADir/checks/${ttf/".ttf"/".checks.md"}
# done

# git add .
# git commit -m "inter: $fontVersion added."

# # push to upstream branch (you must manually go to GitHub to make PR from there)
# # this is set to push to my upstream (google/fonts) rather than origin so that TravisCI can run
# git push --force upstream inter