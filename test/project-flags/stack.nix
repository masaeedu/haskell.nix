{ stdenv, lib, stackProject', recurseIntoAttrs, haskellLib, testSrc }:

with lib;

let
  project = stackProject' {
    src = testSrc "project-flags";
  };
  packages = project.hsPkgs;

in recurseIntoAttrs {
  ifdInputs = {
    inherit (project) stack-nix;
  };
  run = stdenv.mkDerivation {
    name = "callStackToNix-test";

    buildCommand = ''
      exe="${packages.test-project-flags.components.exes.test-project-flags-exe.exePath}"

      printf "checking whether executable runs... " >& 2
      cat ${haskellLib.check packages.test-project-flags.components.exes.test-project-flags-exe}/test-stdout

      touch $out
    '';

    meta.platforms = platforms.all;

    passthru = {
      # Attributes used for debugging with nix repl
      inherit pkgSet packages;
      stack-nix = stack.nix;
    };
  };
}
