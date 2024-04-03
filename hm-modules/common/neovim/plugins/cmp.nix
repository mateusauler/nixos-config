{ config, lib, nixpkgs-channel, pkgs, ... }:

let
  # TODO: Configure individual sources
  sources = [
    { name = "buffer"; }
    { name = "calc"; }
    { name = "fish"; }
    { name = "latex-symbols"; }
    { name = "luasnip"; }
    { name = "nvim_lsp"; }
    { name = "nvim_lsp-document-symbol"; }
    { name = "nvim_lsp-signature-help"; }
    { name = "path"; }
    { name = "treesitter"; }
  ];

  mapping = {
    "<CR>" = /* lua */ "cmp.mapping.confirm({ select = true })";
    "<Tab>" = /* lua */ ''
      cmp.mapping(
        function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip ~= nil and luasnip.expandable() then
            luasnip.expand()
          elseif luasnip ~= nil and luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end,
        { 'i', 's' })
    '';
    "<S-Tab>" = /* lua */ ''cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip ~= nil and luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' })'';
  };
in
{
  programs.nixvim.plugins =
    if nixpkgs-channel == "stable" then {
      nvim-cmp = {
        enable = true;
        inherit sources mapping;
        snippet.expand = "luasnip";
      };
    } else {
      cmp = {
        enable = true;
        settings = {
          inherit sources mapping;
          snippet.expand = /* lua */ "function(args) if luasnip ~= nil then luasnip.lsp_expand(args.body) end end";
        };
      };
    };
}
