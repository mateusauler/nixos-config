{ ... }:

num:
let
  num_low = builtins.floor num;
  num_high = builtins.ceil num;
in
if (num - num_low) < 0.5 then num_low else num_high
