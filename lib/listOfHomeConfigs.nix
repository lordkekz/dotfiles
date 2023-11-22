{
  pkgs,
  homeConfigs,
}:
with builtins;
with pkgs.lib.generators; rec {
  listNames = filter (n: n != "imports") (attrNames homeConfigs);
  listNamesString = toString listNames;
  listNamesNuon = "[ ${toString (map (n: ''"${n}" '') listNames)}]";
  listNamesNuonEscaped = "[ ${toString (map (n: ''\"${n}\" '') listNames)}]";
}
