{
  bubblewrap,
  jdk17,
  jdk21,
  jdk8,
  kdePackages,
  makeWrapper,
  prismlauncher,
  runCommandLocal,
  stdenv,

  additionalLibs ? [ ],
  additionalPrograms ? [ ],
  controllerSupport ? stdenv.hostPlatform.isLinux,
  gamemodeSupport ? stdenv.hostPlatform.isLinux,
  jdks ? [
    jdk21
    jdk17
    jdk8
  ],
  msaClientID ? null,
  textToSpeechSupport ? stdenv.hostPlatform.isLinux,
}:
let
  prismlauncher' = prismlauncher.override {
    inherit
      additionalLibs
      additionalPrograms
      controllerSupport
      gamemodeSupport
      jdks
      msaClientID
      textToSpeechSupport
      ;
  };

  prismlauncher-unwrapped' = builtins.head prismlauncher'.paths;

  # Passthrough
  # Ref: https://github.com/NixOS/nixpkgs/blob/5e871d8aa6f57cc8e0dc087d1c5013f6e212b4ce/pkgs/build-support/build-fhsenv-bubblewrap/default.nix#L170
  wrapperPreExec = ''
    args=()
    if [[ "$DISPLAY" == :* ]]; then
        local_socket="/tmp/.X11-unix/X''${DISPLAY#?}"
        args+=(--ro-bind-try "$local_socket" "$local_socket")
    fi
    if [[ -n "$XAUTHORITY" ]]; then
        args+=(--ro-bind-try "$XAUTHORITY" "$XAUTHORITY")
    fi
    if [[ "$WAYLAND_DISPLAY" = /* ]]; then
        args+=(--ro-bind-try "$WAYLAND_DISPLAY" "$WAYLAND_DISPLAY")
    elif [[ -n "$WAYLAND_DISPLAY" ]]; then
        args+=(--ro-bind-try "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" "/tmp/$WAYLAND_DISPLAY")
    fi
  '';

  bwrapArgs = [
    "--unshare-user"
    "--unshare-ipc"
    "--unshare-pid"
    "--unshare-uts"
    "--unshare-cgroup"
    "--die-with-parent"

    "--dev /dev"
    "--proc /proc"
    "--ro-bind /nix /nix"
    "--ro-bind /etc /etc"
    "--ro-bind /var /var" # Required for some symlinks under `/etc`, eg. `/etc/machine-id`.
    "--tmpfs /tmp"

    # Network is required.
    "--share-net"
    "--ro-bind /run/systemd/resolve /run/systemd/resolve"

    # Mesa & OpenGL.
    "--ro-bind /run/opengl-driver /run/opengl-driver"
    "--dev-bind-try /dev/dri /dev/dri"
    "--ro-bind-try /sys/class /sys/class"
    "--ro-bind-try /sys/dev/char /sys/dev/char"
    "--ro-bind-try /sys/devices/pci0000:00 /sys/devices/pci0000:00"
    "--ro-bind-try /sys/devices/system/cpu /sys/devices/system/cpu"

    # Audio.
    "--setenv XDG_RUNTIME_DIR /tmp"
    ''--ro-bind-try "$XDG_RUNTIME_DIR/pulse" /tmp/pulse''
    ''--ro-bind-try "$XDG_RUNTIME_DIR/pipewire-0" /tmp/pipewire-0''

    # Runtime args from `wrapperPreExec`.
    ''"''${args[@]}"''

    # Data storage.
    ''--bind "''${XDG_DATA_HOME:+$HOME/.local/share}/PrismLauncher" $HOME/.local/share/PrismLauncher''
    "--unsetenv XDG_DATA_HOME"

    # Block dangerous D-Bus.
    "--unsetenv DBUS_SESSION_BUS_ADDRESS"

    "--"
    "${prismlauncher-unwrapped'}/bin/prismlauncher"
  ];

in
runCommandLocal "prismlauncher-bwrap-${prismlauncher-unwrapped'.version}"
  {
    nativeBuildInputs = [
      kdePackages.wrapQtAppsHook

      # Force to use the shell wrapper instead of the binary wrapper. We have scripts.
      makeWrapper
    ];

    inherit wrapperPreExec bwrapArgs;
    inherit (prismlauncher') buildInputs qtWrapperArgs;

    inherit (prismlauncher-unwrapped') meta;
  }
  ''
    qtWrapperArgs+=(--run "$wrapperPreExec" --add-flags "$bwrapArgs")
    makeQtWrapper ${bubblewrap}/bin/bwrap $out/bin/prismlauncher
    ln -s ${prismlauncher-unwrapped'}/share $out/share
  ''
