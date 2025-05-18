package("commonlib-shared")
    set_homepage("https://github.com/libxse/commonlib-shared")
    set_description("Shared headers for commonlib projects")
    set_license("GPLv3")

    add_urls("https://github.com/libxse/commonlib-shared.git")

    add_configs("rex_ini", { description = "enable REX::INI settings support", default = false, type = "boolean" })
    add_configs("rex_json", { description = "enable REX::JSON settings support", default = false, type = "boolean" })
    add_configs("rex_toml", { description = "enable REX::TOML settings support", default = false, type = "boolean" })
    add_configs("xse_mmio", { description = "enable mmio based Address Library support", default = false, type = "boolean" })
    add_configs("xse_xbyak", { description = "enable xbyak support for Trampoline", default = false, type = "boolean" })

    add_deps("spdlog", { configs = { header_only = false, wchar = true, std_format = true } })

    add_syslinks("advapi32", "bcrypt", "d3d11", "d3dcompiler", "dbghelp", "dxgi", "ole32", "shell32", "user32", "version", "ws2_32")

    on_load("windows|x64", function(package)
        if package:config("rex_ini") then
            package:add("defines", "REX_OPTION_INI=1")
            package:add("deps", "simpleini")
        end
        if package:config("rex_json") then
            package:add("defines", "REX_OPTION_JSON=1")
            package:add("deps", "nlohmann_json")
        end
        if package:config("rex_toml") then
            package:add("defines", "REX_OPTION_TOML=1")
            package:add("deps", "toml11")
        end
        if package:config("xse_mmio") then
            package:add("defines", "XSE_MMIO_ADDRESSLIB=1")
            package:add("deps", "rsm-mmio")
        end
        if package:config("xse_xbyak") then
            package:add("defines", "XSE_SUPPORT_XBYAK=1")
            package:add("deps", "xbyak")
        end
    end)

    on_install("windows|x64", function(package)
        import("package.tools.xmake").install(package, {
            rex_ini = package:config("rex_ini"),
            rex_json = package:config("rex_json"),
            rex_toml = package:config("rex_toml"),
            xse_mmio = package:config("xse_mmio"),
            xse_xbyak = package:config("xse_xbyak")
        })
    end)

    on_test("windows|x64", function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <format>
            #include <source_location>
            #include <string_view>

            #include <REX/REX/LOG.h>

            void test() {
                REX::INFO("Hello World");
            }
        ]]}, { configs = { languages = "c++23" } }))
    end)
