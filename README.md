# My Dotfiles
These are a collection of the dotfiles for all of the programs I regularly use. They're fairly simple,
but feel free to use them in any way you want.

To get started, clone the repository (I personally recommend storing the repo at ~/.dotfiles) and install GNU stow on your machine. 

After cloning and installing stow, it should be as simple as running `stow -v <package>` to stow a specific program's files, or `stow -v *`. I suggest first running these commands with the `--no` flag, e.g. `stow --no -v`, to preview the operation and ensure you don't accidentally overwrite any existing files.