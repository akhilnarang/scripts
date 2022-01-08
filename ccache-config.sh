#!/bin/sh

# This setting should be an absolute path to a directory. ccache then
# rewrites absolute paths into relative paths before computing the hash that
# identifies the compilation, but only for paths under the specified
# directory. If set to the empty string (which is the default), no rewriting
# is done. See also the discussion under COMPILING IN DIFFERENT DIRECTORIES.
# If using GCC or newer versions of Clang, you might want to look into the
# -fdebug-prefix-map=old=new option for relocating debug info to a common
# prefix (mapping prefix with old=new).
export CCACHE_BASEDIR=

# This setting specifies where ccache will keep its cached compiler outputs.
# It will only take effect if set in the system-wide configuration file or
# as an environment variable. The default is $HOME/.ccache.
export CCACHE_DIR=$HOME/.ccache

# This setting allows you to choose the number of directory levels in the
# cache directory. The default is 2. The minimum is 1 and the maximum is 8.
export CCACHE_NLEVELS=2

# This setting can be used to force the name of the compiler to use. If set
# to the empty string (which is the default), ccache works it out from the
# command line.
export CCACHE_CC=

# By default, ccache includes the modification time (“mtime”) and size of
# the compiler in the hash to ensure that results retrieved from the cache
# are accurate. This setting can be used to select another strategy.
export CCACHE_COMPILERCHECK=mtime

# If true, ccache will compress object files and other compiler output it
# puts in the cache. However, this setting has no effect on how files are
# retrieved from the cache; compressed and uncompressed results will still
# be usable regardless of this setting. The default is false.
# export CACHE_COMPRESS
export CCACHE_NOCOMPRESS=1

# This setting determines the level at which ccache will compress object
# files. It only has effect if compression is enabled. The value defaults
# to 6, and must be no lower than 1 (fastest, worst compression) and no
# higher than 9 (slowest, best compression).
export CCACHE_COMPRESSLEVEL=6

# This setting can be used to force a certain extension for the intermediate
# preprocessed file. The default is to automatically determine the extension
# to use for intermediate preprocessor files based on the type of file being
# compiled, but that sometimes doesn’t work. For example, when using the
# “aCC” compiler on HP-UX, set the cpp extension to i.
export CCACHE_EXTENSION=

# If true, the direct mode will be used. The default is true. 
export CCACHE_DIRECT
# export CCACHE_NODIRECT

# When true, ccache will just call the real compiler, bypassing the cache
# completely. The default is false.
#export CCACHE_DISABLE
export CCACHE_NODISABLE=1

# This setting is a list of paths to files that ccache will include in the
# the hash sum that identifies the build. The list separator is semicolon
# on Windows systems and colon on other systems.
export CCACHE_EXTRAFILES=

# If true, ccache will attempt to use hard links from the cache directory
# when creating the compiler output rather than using a file copy. Using
# hard links may be slightly faster in some situations, but can confuse
# programs like “make” that rely on modification times. Another thing to
# keep in mind is that if the resulting object file is modified in any way,
# this corrupts the cached object file as well. Hard links are never made
# for compressed cache files. This means that you should not enable
# compression if you want to use hard links. The default is false.
export CCACHE_HARDLINK=1
# export CCACHE_NOHARDLINK

# If true (which is the default), ccache will include the current working
# directory (CWD) in the hash that is used to distinguish two compilations
# when generating debug info (compiler option -g with variations).
# Exception: The CWD will not be included in the hash if base_dir is set
# (and matches the CWD) and the compiler option -fdebug-prefix-map is used.
# The reason for including the CWD in the hash by default is to prevent a
# problem with the storage of the current working directory in the debug
# info of an object file, which can lead ccache to return a cached object
# file that has the working directory in the debug info set incorrectly.
# You can disable this setting to get cache hits when compiling the same
# source code in different directories if you don’t mind that CWD in the
# debug info might be incorrect.
export CCACHE_HASHDIR=1
# export CCACHE_NOHASHDIR

# This setting is a list of paths to files (or directories with headers)
# that ccache will not include in the manifest list that makes up the direct
# mode. Note that this can cause stale cache hits if those headers do indeed
# change. The list separator is semicolon on Windows systems and colon on
# other systems.
export CCACHE_IGNOREHEADERS=

# If true, ccache will not discard the comments before hashing preprocessor
# output. This can be used to check documentation with -Wdocumentation.
export CCACHE_COMMENTS=1
# export CCACHE_NOCOMMENTS

# Sets the limit when cleaning up. Files are deleted (in LRU order) until
# the levels are below the limit. The default is 0.8 (= 80%).
export CCACHE_LIMIT_MULTIPLE=0.8

# If set to a file path, ccache will write information on what it is doing
# to the specified file. This is useful for tracking down problems.
export CCACHE_LOGFILE=

# This option specifies the maximum number of files to keep in the cache.
# Use 0 for no limit (which is the default).
export CCACHE_MAXFILES=0

# This option specifies the maximum size of the cache. Use 0 for no limit.
# The default value is 5G. Available suffixes: k, M, G, T (decimal) and Ki,
# Mi, Gi, Ti (binary). The default suffix is "G".
export CCACHE_MAXSIZE=10G

# If set, ccache will search directories in this list when looking for the
# real compiler. The list separator is semicolon on Windows systems and
# colon on other systems. If not set, ccache will look for the first
# executable matching the compiler name in the normal PATH that isn’t a
# symbolic link to ccache itself.
export CCACHE_PATH=

# This option adds a list of prefixes (separated by space) to the command
# line that ccache uses when invoking the compiler.
export CCACHE_PREFIX=

# This option adds a list of prefixes (separated by space) to the command
# line that ccache uses when invoking the preprocessor.
export CCACHE_PREFIX_CPP=

# If true, ccache will attempt to use existing cached object files, but it
# will not to try to add anything new to the cache. If you are using this
# because your ccache directory is read-only, then you need to set
# temporary_dir as otherwise ccache will fail to create temporary files.
# export CCACHE_READONLY
export CCACHE_NOREADONLY=1

# Just like read_only except that ccache will only try to retrieve results
# from the cache using the direct mode, not the preprocessor mode. See
# documentation for read_only regarding using a read-only ccache directory.
# export CCACHE_READONLY_DIRECT
export CCACHE_NOREADONLY_DIRECT=1

# If true, ccache will not use any previously stored result. New results
# will still be cached, possibly overwriting any pre-existing results.
# export CCACHE_RECACHE
export CCACHE_NORECACHE=1

# If true, ccache will first run the preprocessor to preprocess the source
# code (see THE PREPROCESSOR MODE) and then on a cache miss run the compiler
# on the source code to get hold of the object file. This is the default.
# If false, ccache will first run preprocessor to preprocess the source code
# and then on a cache miss run the compiler on the preprocessed source code
# instead of the original source code. This makes cache misses slightly
# faster since the source code only has to be preprocessed once. The
# downside is that some compilers won’t produce the same result (for
# instance diagnostics warnings) when compiling preprocessed source code.
export CCACHE_CPP2=1
# export CCACHE_NOCPP2

# By default, ccache tries to give as few false cache hits as possible.
# However, in certain situations it’s possible that you know things that
# ccache can’t take for granted. This setting makes it possible to tell
# ccache to relax some checks in order to increase the hit rate. The value
# should be a comma-separated string with options.
export CCACHE_SLOPPINESS=file_macro,time_macros,include_file_mtime,include_file_ctime,file_stat_matches

# If true, ccache will update the statistics counters on each compilation.
# The default is true.
export CCACHE_STATS=1
# export CCACHE_NOSTATS

# This setting specifies where ccache will put temporary files.
# The default is <cache_dir>/tmp.
export CCACHE_TEMPDIR=$CCACHE_DIR/tmp

# This setting specifies the umask for ccache and all child processes
# (such as the compiler). This is mostly useful when you wish to share your
# cache with other users. Note that this also affects the file permissions
# set on the object files created from your compilations.
export CCACHE_UMASK=002

# If true, ccache will use a C/C++ unifier when hashing the preprocessor
# output if the -g option is not used. The unifier is slower than a normal
# hash, so setting this environment variable loses a little bit of speed,
# but it means that ccache can take advantage of not recompiling when the
# changes to the source code consist of reformatting only. Note that
# enabling the unifier changes the hash, so cached compilations produced
# when the unifier is enabled cannot be reused when the unifier is disabled,
# and vice versa. Enabling the unifier may result in incorrect line number
# information in compiler warning messages and expansions of the __LINE__
# macro. Also note that enabling the unifier implies turning off the
# direct mode.
# export CCACHE_UNIFY
export CCACHE_NOUNIFY=1
