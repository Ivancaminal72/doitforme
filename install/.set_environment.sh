# Set local environment (add to ~/.bashrc)
# if ! [[ "$TERM" =~ "screen".* ]]; then
#     source ~/workspace/doitforme/install/.set_environment.sh
# fi

setEV() {
    if [[ -d $2 ]]; then
        export $1="$2:${!1}"
    fi
}

environment() {
    setEV "CMAKE_PREFIX_PATH"   "$HOME/local/${1}_${2}"
    setEV "PATH"                "$HOME/local/${1}_${2}/bin"
    setEV "CMAKE_INCLUDE_PATH"  "$HOME/local/${1}_${2}/include"
    setEV "CPATH"               "$HOME/local/${1}_${2}/include"
    setEV "LIBRARY_PATH"        "$HOME/local/${1}_${2}/lib"
    setEV "LD_LIBRARY_PATH"     "$HOME/local/${1}_${2}/lib"
    setEV "CMAKE_LIBRARY_PATH"  "$HOME/local/${1}_${2}/lib"
    setEV "CMAKE_MODULE_PATH"   "$HOME/local/${1}_${2}/lib/cmake"
    setEV "PKG_CONFIG_PATH"     "$HOME/local/${1}_${2}/lib/pkgconfig"
    setEV "PYTHONPATH"          "$HOME/local/${1}_${2}/lib/python2.7/dist-packages"
    setEV "PYTHONPATH"          "$HOME/local/${1}_${2}/lib/python3.4/dist-packages"
    setEV "PYTHONPATH"          "$HOME/local/${1}_${2}/lib/python3.6/dist-packages"
    setEV "MANPATH"             "$HOME/local/${1}_${2}/share/man"
}

# environment "rtabmap-release_kinetic" "0.17.1-0"
# environment "rtabmap-release_melodic" "0.17.1-0"
# environment "rtabmap-release_melodic" "0.19.3-2"
environment "rtabmap-release_noetic" "0.20.10-1"
# environment "opencv" "3.2.0"
environment "opencv" "4.2.0"
