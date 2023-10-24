function installFunc () {
    name=$1
    getopts "denable:" denBool
    getopts "py" pyBool
    cd ${HOME}/hark
    apt source ${name}
    cd $(ls | grep -o $(name)"-*.*.*")
    if [$py = "py"] ; then
        python3 setup.py build
        sudo python3 setup.py install
        return 0
    fi
    ${ $(cat $name".c")//"#include <sys/io.h>"//"/* #include <sys/io.h>*/"} > $name".c"
    mkdir build
    cd build
    if [$denable = "?"] ; then
        cmake ..
    else
        cmake -DENABLE_RASP24=$denBool -DENABLE_WS=$denBool ..
    fi
    make
    sudo make install
}


cd ${HOME}
if [ -d "hark" ] ; then
    echo "エラー：harkディレクトリが存在しています。"
    return 0
else
    echo "harkディレクトリがないことを確認しました。"
    mkdir hark
fi

#sudo apt install libtool cmake libxml2-dev libzip-dev libasound2-dev libopenblas-dev libgtk2.0-dev libsndfile1-dev libsdl2-dev liblapacke-dev gfortran python3-setuptools python3-dev libpopt-dev python3-daemon python3-paho-mqtt libmosquittopp-dev python3-pkgconfig python3-pybind11
harkList=("hark-base" "libhark-netapi" "libharkio3" "hark-core" "harkmw" "hark-linux" "hark-gtkplot" "harktool5")
optsList=("?" "?" "?" "denable=OFF" "py" "denable=OFF" "?" "?")

for ((i=0; i<"${#harkList[@]}"; i++)); do
    if [$optsList[i] = "py"] ; then
        installFunc -py $harkList[i]
    elif [ $(grep -o "denable" $optsList[i])"" = "denable"] ; then
        installFunc -denable [$optsList[i]##*=] $harkList[i]
    else
        installFunc $harkList[i]
    fi
done

