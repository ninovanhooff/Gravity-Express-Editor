PACKAGE_FILE_NAME="GravityExpressEditor.love"

killall love ; clear ;
mkdir ./out
rm -rf ./out/*
cp -R ./Source/* ./out
rm $PACKAGE_FILE_NAME
cd ./out || exit
zip -r $PACKAGE_FILE_NAME ./*
open ./ $PACKAGE_FILE_NAME
