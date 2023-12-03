let
  lib = import ./lib;

  modsToFun = modules: options: config: input:
    (lib.evalModules {
      modules = [
        modules
        {
          inherit options config;
        }
        { config.input = input; }
      ];
    }).config.output;

  addIntegers = modsToFun ({ lib, config, ... }: {
    options.input = lib.mkOption {
      type = lib.types.int;
    };

    options.output = lib.mkOption {
      type = lib.types.functionTo lib.types.int;
      default = modsToFun ({ lib, config, ... }: let config2 = config; in {
        options.input = lib.mkOption {
          type = lib.types.int;
        };
        options.output = lib.mkOption {
          type = lib.types.int;
          default = config.input + config2.input;
        };
      });
    };
  });

in addIntegers 1 2
