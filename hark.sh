function installFunc () {
    # ファイル名とオプション
    name=$1
    getopts "denable:" denBool
    getopts "py" pyBool

    # home/hark 上で作業する
    cd ${HOME}/hark

    # コードのダウンロードと作業ディレクトリへの移動
    apt source $name
    echo $( ls | grep -o $name"-.*" )
    cd $( ls | grep -o $name"-.*" )
    
    # ビルドとインストール
    if [ $pyBool"" = "py" ] ; then
        python3 setup.py build
        sudo python3 setup.py install
        return 0
    fi
    if [ $name"" = "libhark-netapi" ] ; then
        echo neko
        cat "hark-netapi.c" | sed s/"#include <sys/io.h>"/"/* #include <sys/io.h> */"/ | tee "hark-netapi.c"
    fi
    mkdir build
    cd build
    if [ $denBool"" = "" ] ; then
        cmake -DENABLE_RASP24=$denBool -DENABLE_WS=$denBool ..
    else
        cmake ..
    fi
    make
    #sudo make install
}


# home 上に harkディレクトリ が既に存在するか確認
cd ${HOME}
if [ -d "hark" ] ; then
    echo "警告:harkディレクトリが存在しています。"
else
    echo "harkディレクトリがないことを確認しました。"
    mkdir hark
fi
cat /etc/apt/sources.list | sed s/"# deb-src"/deb-src/ | sed s/"#deb-src"/deb-src/ | sudo tee "/etc/apt/sources.list"

# apt でインストールできるものを入れ、それ以外のリストを作成
sudo apt install libtool cmake libxml2-dev libzip-dev libasound2-dev libopenblas-dev libgtk2.0-dev libsndfile1-dev libsdl2-dev liblapacke-dev gfortran python3-setuptools python3-dev libpopt-dev python3-daemon python3-paho-mqtt libmosquittopp-dev python3-pkgconfig python3-pybind11 -y
harkList=("hark-base" "libhark-netapi" "libharkio3" "hark-core" "harkmw" "hark-linux" "hark-gtkplot" "harktool5")
optsList=("" "" "" "denable=OFF" "py" "denable=OFF" "" "")

for ((i=0; i<"${#harkList[@]}"; i++)); do
    if [ ${optsList[i]}"" = "py" ] ; then
        installFunc ${harkList[i]} -py
    elif [ ${optsList[i]}"" = "denable.*" ] ; then
        echo [${optsList[i]}##*=]
        installFunc ${harkList[i]} -denable [${optsList[i]}##*=]
    else
        installFunc ${harkList[i]}
    fi
done

