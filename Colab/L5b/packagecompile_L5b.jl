# load packages -
using Pkg, PackageCompiler
Pkg.add(path="https://github.com/varnerlab/VLQuantitativeFinancePackage.jl.git")

# setup path -
const _COLAB_DIR = dirname(dirname(@__FILE__));

# generate the sysimage -
create_sysimage(nothing;
    sysimage_path=joinpath(_COLAB_DIR, "L5b/L5bSysimage.so"),
    precompile_execution_file=joinpath(_COLAB_DIR, "L5b/precompile_L5b.jl"))