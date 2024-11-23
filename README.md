# Welcome to my personal dotfiles!

In this repo, I manage my dotfiles (program configurations) and such using [nix](https://nixos.org), nix-flakes and [home-manager](https://github.com/nix-community/home-manager).

You can see some things about this flake using these commands:

- `nix flake metadata github:lordkekz/dotfiles` (Shows info and inputs)
- `nix flake show github:lordkekz/dotfiles` (Shows some outputs)
- `nix search github:lordkekz/dotfiles` (Lists provided packages)

## Stylix

`nix run .#legacyPackages.x86_64-linux.homeConfigurations.hypr.activation-script -L -v --override-input stylix-image path:./assets/wallpaper-italy.jpg` to activate Hyprland config with different wallpaper.
`sudo nixos-rebuild switch --flake .#kekswork2404-hypr -L -v --override-input stylix-image path:./assets/wallpaper-italy.jpg` to activate Hyprland config with different wallpaper.

# Sather-K Compiler Halle (nix-based distribution)

I've written a nix package/derivation for the [Sather-K Compiler Halle](https://swt.informatik.uni-halle.de/software/satherkhalle/), which has compatibility issues with modern versions of GCC (>=10) and Mono (>= 5 or 6). You can audit the derivation located in [pkgs/satk.nix](pkgs/satk.nix). It simply downloads the source code zip from the university website, builds it with GCC 4.8 and the GNU Multiple Precision Arithmetic Library (libgmp / GMP), and also adds a wrapper script to define needed environment variables and a workaround to a bug in Mono 4. Mono is automatically loaded as a runtime dependency.

## Installation / Prerequisites

1. Make sure you have a working linux distribution or WSL2 environment set up.
2. Install the Nix package manager. For instructions, see the [official download page](https://nixos.org/download), or try the [determinate systems nix installer](https://determinate.systems/posts/determinate-nix-installer).
3. Make sure that the nix flakes and nix-command features are enabled. The official installer does not do this but the determinate systems installer does enable them. Test it using `nix flake show nixpkgs`.

## Usage

You can either run the sather-k compiler directly from the flake:

- Check the version: `nix run github:lordkekz/dotfiles#satk -L -- --help`
- Compile a file: `nix run github:lordkekz/dotfiles#satk -L -- [satk options] <filename>`
  (if you omit the filename, `satk` will wait for input on stdin, which trick you into thinking it's broken)

Or you can enter a shell which has the `satk` command available:

- `nix shell github:lordkekz/dotfiles#satk -L`
- Then, you can use `satk` normally, e.g.: `satk -o outfile hello_world.sa`

**Note:** In the nix shell environment provided by the `#satk` package, the `mono` command is _not_ available on your $PATH. It is only available thorough the wrapper script knows the location of the `mono` binary.

**Note:** The `<out>.exe` binaries produced with `satk -o <out> <filename>` do not require the Mono Runtime to be present.

**Full example:**

```bash
$ nix shell github:lordkekz/dotfiles#satk -L
...
$ satk-get-examples
The example files are located in:
/nix/store/wli759g7rsyy7jlil48c5bkrqk2idghz-satk-compiler-halle/examples/
/nix/store/wli759g7rsyy7jlil48c5bkrqk2idghz-satk-compiler-halle/examples/hanoi.sa
/nix/store/wli759g7rsyy7jlil48c5bkrqk2idghz-satk-compiler-halle/examples/hello_world.sa
/nix/store/wli759g7rsyy7jlil48c5bkrqk2idghz-satk-compiler-halle/examples/qsort.sa
/nix/store/wli759g7rsyy7jlil48c5bkrqk2idghz-satk-compiler-halle/examples/queens.sa
/nix/store/wli759g7rsyy7jlil48c5bkrqk2idghz-satk-compiler-halle/examples/sieve.sa
/nix/store/wli759g7rsyy7jlil48c5bkrqk2idghz-satk-compiler-halle/examples/simpson.sa
$ satk /nix/store/wli759g7rsyy7jlil48c5bkrqk2idghz-satk-compiler-halle/examples/hello_world.sa
Assembling 'hello_world.il' , no listing file, to exe --> 'hello_world.exe'

Operation completed successfully
$ chmod +x ./hello_world.exe
$ ./hello_world.exe
Hello World
$ exit # Now, we exit the nix shell; the satk and satk-get-examples commands are no longer available
$ ./hello_world.exe # The built program still works!
Hello World
```
