{ config, lib, pkgs, ... }:

let
  cfg = config.modules.bat;
  toXmlObj = { obj, indent ? 0 }:
    let
      indentStr = str: lib.fixedWidthString (indent * 2 + (builtins.stringLength str)) "  " str;
      type = builtins.typeOf obj;
    in
    if      type == "string" then "\n" + indentStr "<string>${obj}</string>\n"
    else if type == "set"    then "\n" + indentStr "<dict>\n" + (lib.foldlAttrs (acc: name: value: acc + indentStr "  <key>${name}</key>" + (toXmlObj { obj = value; indent = indent + 1; })) "" obj) + indentStr "</dict>\n"
    else if type == "list"   then "\n" + indentStr "<array>\n" + (builtins.foldl' (acc: value: acc + (toXmlObj { obj = value; indent = indent + 1; })) "" obj) + indentStr "</array>\n"
    else throw "Type ${type} not supported.";
in
{
  options.modules.bat.enable = lib.mkEnableOption "bat";

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config.theme = "bat-theme-${config.colorScheme.slug}";
      themes."bat-theme-${config.colorScheme.slug}" = with config.colorScheme.colors; ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
      '' + toXmlObj {
        obj = {
          name = "Generated base16 theme";
          semanticClass = "theme.base16.${config.colorScheme.slug}";
          colorSpaceName = "sRGB";
          gutterSettings = {
            background          = "#${base01}";
            divider             = "#${base01}";
            foreground          = "#${base03}";
            selectionBackground = "#${base02}";
            selectionForeground = "#${base04}";
          };
          settings = [
            {
              settings = {
                background    = "#${base00}";
                caret         = "#${base05}";
                foreground    = "#${base05}";
                invisibles    = "#${base03}";
                lineHighlight = "#${base03}55";
                selection     = "#${base02}";
              };
            }
            { name = "Text";                    scope = "variable.parameter.function";                                                                                                                                                                   settings.foreground = "#${base05}"; }
            { name = "Comments";                scope = "comment, punctuation.definition.comment";                                                                                                                                                       settings.foreground = "#${base03}"; }
            { name = "Punctuation";             scope = "punctuation.definition.string, punctuation.definition.variable, punctuation.definition.string, punctuation.definition.parameters, punctuation.definition.string, punctuation.definition.array"; settings.foreground = "#${base05}"; }
            { name = "Delimiters";              scope = "none";                                                                                                                                                                                          settings.foreground = "#${base05}"; }
            { name = "Operators";               scope = "keyword.operator";                                                                                                                                                                              settings.foreground = "#${base05}"; }
            { name = "Keywords";                scope = "keyword";                                                                                                                                                                                       settings.foreground = "#${base0E}"; }
            { name = "Variables";               scope = "variable";                                                                                                                                                                                      settings.foreground = "#${base08}"; }
            { name = "Functions";               scope = "entity.name.function, meta.require, support.function.any-method, variable.function, variable.annotation, support.macro";                                                                        settings.foreground = "#${base0D}"; }
            { name = "Labels";                  scope = "entity.name.label";                                                                                                                                                                             settings.foreground = "#${base0F}"; }
            { name = "Classes";                 scope = "support.class, entity.name.class, entity.name.type.class";                                                                                                                                      settings.foreground = "#${base0A}"; }
            { name = "Classes";                 scope = "meta.class";                                                                                                                                                                                    settings.foreground = "#${base07}"; }
            { name = "Methods";                 scope = "keyword.other.special-method";                                                                                                                                                                  settings.foreground = "#${base0D}"; }
            { name = "Storage";                 scope = "storage";                                                                                                                                                                                       settings.foreground = "#${base0E}"; }
            { name = "Support";                 scope = "support.function";                                                                                                                                                                              settings.foreground = "#${base0C}"; }
            { name = "Strings, Inherited Class";scope = "string, constant.other.symbol, entity.other.inherited-class";                                                                                                                                   settings.foreground = "#${base0B}"; }
            { name = "Integers";                scope = "constant.numeric";                                                                                                                                                                              settings.foreground = "#${base09}"; }
            { name = "Floats";                  scope = "none";                                                                                                                                                                                          settings.foreground = "#${base09}"; }
            { name = "Boolean";                 scope = "none";                                                                                                                                                                                          settings.foreground = "#${base09}"; }
            { name = "Constants";               scope = "constant";                                                                                                                                                                                      settings.foreground = "#${base09}"; }
            { name = "Tags";                    scope = "entity.name.tag";                                                                                                                                                                               settings.foreground = "#${base08}"; }
            { name = "Attributes";              scope = "entity.other.attribute-name";                                                                                                                                                                   settings.foreground = "#${base09}"; }
            { name = "Attribute IDs";           scope = "entity.other.attribute-name.id, punctuation.definition.entity";                                                                                                                                 settings.foreground = "#${base0D}"; }
            { name = "Selector";                scope = "meta.selector";                                                                                                                                                                                 settings.foreground = "#${base0E}"; }
            { name = "Values";                  scope = "none";                                                                                                                                                                                          settings.foreground = "#${base09}"; }
            { name = "Headings";                scope = "markup.heading punctuation.definition.heading, entity.name.section";                                                                                                                            settings = { fontStyle = ""; foreground = "#${base0D}"; }; }
            { name = "Units";                   scope = "keyword.other.unit";                                                                                                                                                                            settings.foreground = "#${base09}"; }
            { name = "Bold";                    scope = "markup.bold, punctuation.definition.bold";                                                                                                                                                      settings = { fontStyle = "bold"; foreground = "#${base0A}"; }; }
            { name = "Italic";                  scope = "markup.italic, punctuation.definition.italic";                                                                                                                                                  settings = { fontStyle = "italic"; foreground = "#${base0E}"; }; }
            { name = "Code";                    scope = "markup.raw.inline";                                                                                                                                                                             settings.foreground = "#${base0B}"; }
            { name = "Link Text";               scope = "string.other.link, punctuation.definition.string.end.markdown, punctuation.definition.string.begin.markdown";                                                                                   settings.foreground = "#${base08}"; }
            { name = "Link Url";                scope = "meta.link";                                                                                                                                                                                     settings.foreground = "#${base09}"; }
            { name = "Lists";                   scope = "markup.list";                                                                                                                                                                                   settings.foreground = "#${base08}"; }
            { name = "Quotes";                  scope = "markup.quote";                                                                                                                                                                                  settings.foreground = "#${base09}"; }
            { name = "Separator";               scope = "meta.separator";                                                                                                                                                                                settings = { background = "#${base02}"; foreground = "#${base05}"; }; }
            { name = "Inserted";                scope = "markup.inserted";                                                                                                                                                                               settings.foreground = "#${base0B}"; }
            { name = "Deleted";                 scope = "markup.deleted";                                                                                                                                                                                settings.foreground = "#${base08}"; }
            { name = "Changed";                 scope = "markup.changed";                                                                                                                                                                                settings.foreground = "#${base0E}"; }
            { name = "Colors";                  scope = "constant.other.color";                                                                                                                                                                          settings.foreground = "#${base0C}"; }
            { name = "Regular Expressions";     scope = "string.regexp";                                                                                                                                                                                 settings.foreground = "#${base0C}"; }
            { name = "Escape Characters";       scope = "constant.character.escape";                                                                                                                                                                     settings.foreground = "#${base0C}"; }
            { name = "Embedded";                scope = "punctuation.section.embedded, variable.interpolation";                                                                                                                                          settings.foreground = "#${base0E}"; }
            { name = "Illegal";                 scope = "invalid.illegal";                                                                                                                                                                               settings = { background = "#${base08}"; foreground = "#${base07}"; }; }
            { name = "Broken";                  scope = "invalid.broken";                                                                                                                                                                                settings = { background = "#${base09}"; foreground = "#${base00}"; }; }
            { name = "Deprecated";              scope = "invalid.deprecated";                                                                                                                                                                            settings = { background = "#${base0F}"; foreground = "#${base07}"; }; }
            { name = "Unimplemented";           scope = "invalid.unimplemented";                                                                                                                                                                         settings = { background = "#${base03}"; foreground = "#${base07}"; }; }
          ];
          uuid = "uuid";
        };
      } + "</plist>\n";
    };
  };
}

