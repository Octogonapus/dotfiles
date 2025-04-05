ENV["JULIA_PKG_SERVER"] = "" # pkg server makes me sad
ENV["JULIA_PKG_USE_CLI_GIT"] = true # needed for WSL2 to work with 1Password SSH agent. CLI Git works but libgit2 always asks for the private key location.
#ENV["PYTHON"] = ""
ENV["JULIA_EDITOR"] = "code --wait"
ENV["JULIA_PKG_PRECOMPILE_AUTO"] = false
ENV["MLDATADEVICES_SILENCE_WARN_NO_GPU"] = true
include("local.jl")
using Revise
