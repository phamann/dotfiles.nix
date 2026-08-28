{ lib }:
let
  inherit (lib)
    foldl'
    mod
    stringToCharacters
    toLower
    ;

  digits = "0123456789abcdef";

  hexDigits = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
  };

  # "1f" -> 31
  hexToInt = s: foldl' (acc: c: acc * 16 + hexDigits.${c}) 0 (stringToCharacters (toLower s));

  # 31 -> "1f". Callers only ever pass 0-255, so no clamping here.
  intToHex = n: builtins.substring (n / 16) 1 digits + builtins.substring (mod n 16) 1 digits;

  # Pull one channel out of a "#rrggbb" string (offsets 1/3/5).
  channel = hex: offset: hexToInt (builtins.substring offset 2 hex);
in
{
  # Linear blend of two "#rrggbb" strings: `mix a b 0` == a, `mix a b 100` == b.
  #
  # base24 has no tinted-background slots, so apps that want e.g. a faintly
  # green "success" panel have to derive one from base01 + base0B rather than
  # look it up. Integer percentages keep this out of Nix float arithmetic.
  mix =
    a: b: pct:
    let
      blend = offset: intToHex ((channel a offset * (100 - pct) + channel b offset * pct) / 100);
    in
    "#${blend 1}${blend 3}${blend 5}";
}
