{ runCommand, wallpaper, imagemagick }:
runCommand "wallpaper-blur.jpg" { } ''
  ${imagemagick}/bin/convert -blur 14x5 ${wallpaper} $out
''
