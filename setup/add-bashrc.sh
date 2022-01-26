echo -e "

export PATH=~/bin:~/usr/bin:/usr/local/bin
export USE_CCACHE=1
export CCACHE_EXEC=/usr/local/bin/ccache
export CCACHE_MAXSIZE=50G
export CCACHE_DIR=/mnt/e/.ccache
export CCACHE_TEMPDIR=$CCACHE_DIR/tmp
export CCACHE_NOCOMPRESS=1
export CCACHE_NODISABLE=1
export CCACHE_NORECACHE=1
export CCACHE_RUN_SECOND_CPP=false
export CCACHE_LIMIT_MULTIPLE=0.97
export CC=clang
export CXX=clang++
export CCACHE_CC=clang
export CCACHE_CXX=clang++
export CCACHE_SLOPPINESS=file_macro,time_macros,include_file_mtime,include_file_ctime,file_stat_matches
export ANDROID_SDK_ROOT=~/Android/Sdk
export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$JAVA_HOME/bin
export PATH=$HOME/tc/proton/clang-13/bin
export ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF+7 -XX:+TieredCompilation -Xmx8G"

" >> ~/.bashrc