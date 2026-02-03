local ok_jdtls, jdtls = pcall(require, "jdtls")
if not ok_jdtls then
  return
end

local ok_setup, jdtls_setup = pcall(require, "jdtls.setup")
if not ok_setup then
  return
end

local function mason_install_root()
  local ok_settings, mason_settings = pcall(require, "mason.settings")
  if ok_settings then
    local current = mason_settings.current or mason_settings
    if current and current.install_root_dir then
      return current.install_root_dir
    end
  end
  return vim.fn.stdpath("data") .. "/mason"
end

local function mason_pkg_path(name)
  return mason_install_root() .. "/packages/" .. name
end

local root_markers = {
  "gradlew",
  "mvnw",
  "pom.xml",
  "build.gradle",
  "build.gradle.kts",
  "settings.gradle",
  "settings.gradle.kts",
  ".git",
}

local root_dir = jdtls_setup.find_root(root_markers)
if not root_dir then
  return
end

local jdtls_path = mason_pkg_path "jdtls"
if vim.fn.isdirectory(jdtls_path) == 0 then
  vim.notify("JDTLS not installed. Run :Mason and install jdtls", vim.log.levels.ERROR)
  return
end

local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
local system = vim.loop.os_uname().sysname
local config_dir = jdtls_path .. "/config_linux"
if system == "Darwin" then
  config_dir = jdtls_path .. "/config_mac"
elseif system == "Windows_NT" then
  config_dir = jdtls_path .. "/config_win"
end
local lombok = jdtls_path .. "/lombok.jar"

if launcher == "" then
  vim.notify("JDTLS launcher not found in Mason install", vim.log.levels.ERROR)
  return
end

if vim.fn.isdirectory(config_dir) == 0 then
  vim.notify("JDTLS config_linux directory not found", vim.log.levels.ERROR)
  return
end

local project_name = vim.fn.fnamemodify(root_dir, ":t")
local workspace_dir = vim.fn.stdpath "cache" .. "/jdtls/workspace/" .. project_name

local bundles = {}

local java_debug_path = mason_pkg_path "java-debug-adapter"
if vim.fn.isdirectory(java_debug_path) == 1 then
  local debug_bundle = vim.fn.glob(
    java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
    true
  )
  vim.list_extend(bundles, vim.split(debug_bundle, "\n", { trimempty = true }))
end

local java_test_path = mason_pkg_path "java-test"
if vim.fn.isdirectory(java_test_path) == 1 then
  local test_bundles = vim.fn.glob(java_test_path .. "/extension/server/*.jar", true)
  vim.list_extend(bundles, vim.split(test_bundles, "\n", { trimempty = true }))
end

local nvchad_lsp = require "nvchad.configs.lspconfig"

local cmd = {
  "java",
  "-Declipse.application=org.eclipse.jdt.ls.core.id1",
  "-Dosgi.bundles.defaultStartLevel=4",
  "-Declipse.product=org.eclipse.jdt.ls.core.product",
  "-Dlog.protocol=true",
  "-Dlog.level=ALL",
  "-Xms1g",
}

if vim.fn.filereadable(lombok) == 1 then
  table.insert(cmd, "-javaagent:" .. lombok)
end

table.insert(cmd, "-jar")
table.insert(cmd, launcher)
table.insert(cmd, "-configuration")
table.insert(cmd, config_dir)
table.insert(cmd, "-data")
table.insert(cmd, workspace_dir)

local config = {
  cmd = cmd,
  root_dir = root_dir,
  capabilities = nvchad_lsp.capabilities,
  on_attach = function(client, bufnr)
    if nvchad_lsp.on_attach then
      nvchad_lsp.on_attach(client, bufnr)
    end
    jdtls.setup_dap { hotcodereplace = "auto" }
    jdtls.setup.add_commands()
  end,
  init_options = {
    bundles = bundles,
  },
  settings = {
    java = {
      inlayHints = {
        parameterNames = { enabled = "all" },
      },
    },
  },
}

jdtls.start_or_attach(config)
