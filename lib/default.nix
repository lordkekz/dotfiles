let
  inherit (builtins) filter attrNames map any elem;

  # subtractList :: list -> list -> list
  #  subtractList A B := B but remove elements which are also in A
  subtractList = A: B: filter (b: !elem b A) B;

  # subtractAttrSet :: set -> set -> set
  #  subtractAttrSet A B := attributes from B for which A has no attribute with same name
  subtractAttrSet = A: B: map (name: B.${name}) (subtractList (attrNames A) (attrNames B));
in {inherit subtractList subtractAttrSet;}
