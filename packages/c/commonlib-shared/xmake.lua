package("commonlib-shared")
    set_homepage("https://github.com/libxse/commonlib-shared")
    set_description("shared headers for libxse projects")
    set_license("GPLv3")

    add_urls("https://github.com/libxse/commonlib-shared.git")
    -- add_versions("1.0.0", "")

    add_configs("rex_ini", { description = "enable ini settings support for REX", default = false, type = "boolean" })
    add_configs("rex_json", { description = "enable json settings support for REX", default = false, type = "boolean" })
    add_configs("rex_toml", { description = "enable toml settings support for REX", default = false, type = "boolean" })
    add_configs("xse_xbyak", { description = "enable xbyak support for Trampoline", default = false, type = "boolean" })

    add_deps("rsm-mmio")
    add_deps("spdlog", { configs = { header_only = false, wchar = true, std_format = true } })

    add_syslinks("advapi32", "bcrypt", "d3d11", "d3dcompiler", "dbghelp", "dxgi", "ole32", "shell32", "user32", "version")

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
        if package:config("xse_xbyak") then
            package:add("defines", "XSE_SUPPORT_XBYAK=1")
            package:add("deps", "xbyak")
        end
    end)

    on_install("windows|x64", function(package)
        local configs = {}
        configs.rex_ini = package:config("rex_ini")
        configs.rex_json = package:config("rex_json")
        configs.rex_toml = package:config("rex_toml")
        configs.xse_xbyak = package:config("xse_xbyak")

        import("package.tools.xmake").install(package, configs)
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
