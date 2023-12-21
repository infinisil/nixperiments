rec {

  lib = import <nixpkgs/lib>;

  create = get: set:
    fmap: f: s: fmap
      (value: set value s)
      (f (get s));

  attr = name: create
    (attrs: attrs.${name})
    (value: attrs: attrs // { ${name} = value; });

  elem = index: create
    (list: lib.elemAt list index)
    (value: list: lib.take index list ++ [ value ] ++ lib.drop (index + 1) list);

  get = lens:
    lens (f: v: v) (v: v);

  modify = lens: g:
    lens (f: v: f v) (v: g v);

  set = lens: new:
    lens (f: v: f v) (v: new);

  compose = lens1: lens2:
    fmap: f: lens1 fmap (lens2 fmap f);

  id = create
    (value: value)
    (new: value: new);

  composeMany = lensList:
    lib.foldl' compose id lensList;

  example = {
    foo = 10;
    bar.baz = 20;
    qux = [
      {
        foo.bar = 0;
      }
    ];
  };

  testLens = compose
    (attr "bar")
    (attr "baz");

  testLens2 = composeMany [
    (attr "qux")
    (elem 0)
    (attr "foo")
    (attr "bar")
  ];

  test = get testLens2 example;
  test2 = modify testLens2 (old: old + 1) example;
  test3 = set testLens2 40 example;
}
