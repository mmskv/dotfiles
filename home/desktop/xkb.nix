{...}: {
  xdg.configFile = {
    "xkb/symbols/uscustom".text = ''
      default partial alphanumeric_keys
      xkb_symbols "uscustom" {
          include "us(basic)"

          name[Group1] = "English (US)";

          key <AE13> {
              type = "TWO_LEVEL",
              symbols[Group1]= [ question ]
          };
          key <HKTG> {
              type = "TWO_LEVEL",
              symbols[Group1] = [ colon, semicolon ]
          };
      };
    '';
    "xkb/symbols/rucustom".text = ''
      default partial alphanumeric_keys
      xkb_symbols "rucustom" {
          include "ru(common)"

          name[Group1] = "Russian";

          key <AB10> {[ period, comma ]};
          key <AE13> {
              type = "TWO_LEVEL",
              symbols[Group1] = [ question ]
          };
          key <HKTG> {
              type = "TWO_LEVEL",
              symbols[Group1] = [ colon, semicolon ]
          };
      };
    '';
  };
}
