let
  slimbook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5p5CYbupvkUrZsr8aek2s4phPnN2gKklCSkCAGgwbf";
in
{
  "rob-truenas.age".publicKeys = [ slimbook ];
}

