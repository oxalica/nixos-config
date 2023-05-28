# Ref: https://github.com/Admicos/minecraft-wayland/tree/bdc3c0d192097459eb4e72b26c8267f82266e951
{ glfw, fetchFromGitHub, inputs, xorg }:
(glfw.override { waylandSupport = true; }).overrideAttrs (old: {
  name = "glfw-minecraft-wayland";

  src = fetchFromGitHub {
    owner = "glfw";
    repo = "GLFW";
    rev = "62e175ef9fae75335575964c845a302447c012c7";
    sha256 = "sha256-GiY4d7xadR0vN5uCQyWaOpoo2o6uMGl1fCcX4uDGnks=";
  };

  buildInputs = old.buildInputs ++ (with xorg; [
    libX11 libXrandr libXinerama libXcursor libXi libXext
  ]);

  patches = old.patches or [ ] ++ [
    (inputs.glfw-minecraft-wayland + "/0003-Don-t-crash-on-calls-to-focus-or-icon.patch")
    (inputs.glfw-minecraft-wayland + "/0004-wayland-fix-broken-opengl-screenshots-on-mutter.patch")
    (inputs.glfw-minecraft-wayland + "/0005-Add-warning-about-being-an-unofficial-patch.patch")
    (inputs.glfw-minecraft-wayland + "/0007-Platform-Prefer-Wayland-over-X11.patch")
  ];
})
