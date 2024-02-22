require("mason").setup()
require("mason-lspconfig").setup {
  -- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
  ensure_installed = {
    "bashls", -- "bash-language-server",
    "cssls", -- "css-lsp",
    "cssmodules_ls", -- "cssmodules-language-server",
    "docker_compose_language_service", -- "docker-compose-language-service",
    "dockerls", -- "dockerfile-language-server",
    "gradle_ls", -- "gradle-language-server",
    "graphql", -- "graphql-language-service-cli",
    "html", -- "html-lsp",
    "jqls", -- "jq-lsp",
    "jsonls", -- "json-lsp",
    "lua_ls", -- "lua-language-server",
    "tsserver", -- "typescript-language-server",
    "yamlls", -- yaml-language-server

  },
}
return {}
