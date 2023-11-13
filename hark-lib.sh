function installFunc () {
    # ファイル名とオプション
    name=$1
    denBool=""
    pyBool=""
    if [ $# -gt 1 ] ; then
        case $2 in
            -d)
            denBool=$3;;
            -p)
            pyBool="py";;
        esac
    fi

    # home/hark 上で作業する
    cd ${HOME}/hark-lib

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
        sed -i 's/#include <sys\/io\.h>/\/\* #include <sys\/io\.h> \*\//g' hark-netapi.c
    fi
    mkdir build
    cd build
    if [ $denBool"" = "" ] ; then
        cmake ..
    else
        cmake -DENABLE_RASP24=$denBool -DENABLE_WS=$denBool ..
    fi
    make
    sudo make install
}


# home 上に harkディレクトリ が既に存在するか確認
cd ${HOME}
if [ -d "hark-lib" ] ; then
    echo "警告:hark-libディレクトリが存在しています。"
else
    echo "hark-libディレクトリがないことを確認しました。"
    mkdir hark-lib
fi
cat /etc/apt/sources.list | sed s/"# deb-src"/deb-src/ | sed s/"#deb-src"/deb-src/ | sudo tee /etc/apt/sources.list
sudo apt update

# apt install と pip3 でインストールできるものを入れ、それ以外のリストを作成
sudo apt install libtool cmake cmake-extras build-essential libopenblas-base libopenblas-dev gfortran liblapack-dev liblapacke-dev libeigen3-dev pybind11-dev python3-dev python3-pybind11 python3-setuptools python3-pkgconfig python3-pip python3-numpy python3-scipy python3-matplotlib python3-kivy libfmt-dev zlib1g-dev libharkio3
pip3 install --upgrade pip numpy setuptools pybind11 pkgconfig
pip3 install soundfile

harkList=("libharkio3" "harktool5")
optsList=("" "")

for ((i=0; i<"${#harkList[@]}"; i++)); do
    if [ ${optsList[i]}"" = "py" ] ; then
        installFunc ${harkList[i]} -p
    elif [[ "${optsList[i]}" =~ "denable" ]] ; then
        installFunc ${harkList[i]} -d ${optsList[i]##*=}
    else
        echo else
        installFunc ${harkList[i]}
    fi
done
