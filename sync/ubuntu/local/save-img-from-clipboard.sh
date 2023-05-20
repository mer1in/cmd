#!/bin/bash

mntpath=/mnt/c/tmp/clip.png
file='C:\tmp\clip.png'

read -r -d '' PSSCRIPT <<EOF
Add-Type -Assembly PresentationCore;
\$img = [Windows.Clipboard]::GetImage();
if (\$img -eq \$null){
    echo "Do not contain image.";
    Exit 1;
}
\$fcb = new-object Windows.Media.Imaging.FormatConvertedBitmap(\$img, [Windows.Media.PixelFormats]::Rgb24, \$null, 0);
\$stream = [IO.File]::Open("$file", "OpenOrCreate");
\$encoder = New-Object Windows.Media.Imaging.PngBitmapEncoder;
\$encoder.Frames.Add([Windows.Media.Imaging.BitmapFrame]::Create(\$fcb));   
\$encoder.Save(\$stream);\$stream.Dispose();
EOF

powershell.exe -sta $PSSCRIPT || echo exit

mkdir -p img
N=`ls img/ | grep png | sed -e 's/image//' -e 's/.png//' | sort -n | tail -1`
[ -z $N ] && N=0
N=`expr $N + 1`
mv $mntpath img/image$N.png
echo -n "![img$N](img/image$N.png)"
