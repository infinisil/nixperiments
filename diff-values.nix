let
  lib = import ./.;
  diffValues = depth: path: a: b:
    let
      typeA = builtins.typeOf a;
      typeB = builtins.typeOf b;

      onComparable =
        if a == b then
          null
        else
          throw "Non-equal ${typeA} on path ${pathString}";

      pathString = lib.concatStringsSep "." path;
    in
    if depth < 0 then
      null
    else if typeA == typeB then
      {
        lambda = builtins.trace "Not comparing lambda on path ${pathString}" null;
        null = onComparable;
int = onComparable;
        path = onComparable;
        bool = onComparable;
        string = onComparable;
        list =
          let
            countA = builtins.length a;
            countB = builtins.length b;
          in
          if countA == countB then
            lib.foldl' (acc: index:
              diffValues (depth - 1) (path ++ [ (toString index) ])
                (lib.elemAt a index)
                (lib.elemAt b index)
            ) null (lib.range 0 (countA - 1))
          else
            builtins.trace "Different list lengths on path ${pathString}: left is ${toString countA}, right is ${toString countB}" null;
        set =
          let
            namesA = builtins.attrNames a;
            namesB = builtins.attrNames b;
            onlyLeft = lib.lists.subtractLists namesA namesB;
            onlyRight = lib.lists.subtractLists namesB namesA;
          in
          if namesA == namesB then
            lib.foldl' (acc: name:
              diffValues (depth - 1) (path ++ [ name ]) a.${name} b.${name}
            ) null namesA
          else
            builtins.trace "Different attributes names on path ${pathString}: Only on the left ${toString onlyLeft}, only on the right: ${toString onlyRight}" null;
      }.${typeA} or (throw "Don't know how to diff type ${typeA}")
    else
    builtins.trace "Different types on path ${pathString}: left is ${typeA}, right is ${typeB}";
in diffValues
