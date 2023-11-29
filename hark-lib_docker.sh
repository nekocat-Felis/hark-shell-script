# home 上に harkディレクトリ が既に存在するか確認
cd ${HOME}
if [ -d "hark" ] ; then
    echo "harkディレクトリが存在することを確認しました。"
else
    echo "警告:harkディレクトリが存在しません。"
    mkdir hark
fi
cat /etc/apt/sources.list | sed s/"# deb-src"/deb-src/ | sed s/"#deb-src"/deb-src/ | sudo tee /etc/apt/sources.list
apt update

# apt install と pip3 でインストールできるものを入れ、それ以外のリストを作成
apt install cmake-extras build-essential libopenblas-base liblapack-dev libeigen3-dev pybind11-dev python3-dev python3-pybind11 python3-setuptools python3-pkgconfig python3-pip python3-numpy python3-scipy python3-matplotlib python3-kivy libfmt-dev zlib1g-dev wget -y
pip3 install --upgrade pip numpy setuptools pybind11 pkgconfig

cd hark

wget https://hark.jp/networks/hark-lib-1.0.0-20221215.tar.xz
tar -Jxvf hark-lib-1.0.0-20221215.tar.xz


cd hark-lib
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX:STRING=/usr
make
make install

cd ..
cd python
python3 ./setup.py build
python3 ./setup.py install