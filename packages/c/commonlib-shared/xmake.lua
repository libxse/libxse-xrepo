package("commonlib-shared")
    set_homepage("https://github.com/libxse/commonlib-shared")
    set_description("Shared headers for commonlib projects")
    set_license("GPLv3")

    add_urls("https://github.com/libxse/commonlib-shared.git")

    add_configs("ini", { description = "enable REX::INI settings support", default = false, type = "boolean" })
    add_configs("json", { description = "enable REX::JSON settings support", default = false, type = "boolean" })
    add_configs("toml", { description = "enable REX::TOML settings support", default = false, type = "boolean" })
    add_configs("xbyak", { description = "enable xbyak support for Trampoline", default = false, type = "boolean" })

    add_deps("spdlog", { configs = { header_only = false, wchar = true, std_format = true } })

    add_syslinks("advapi32", "bcrypt", "d3d11", "d3dcompiler", "dbghelp", "dxgi", "ole32", "shell32", "user32", "version", "ws2_32")

    on_load("windows|x64", function(package)
        if package:config("ini") then
            package:add("defines", "COMMONLIB_OPTION_INI=1")
            package:add("deps", "simpleini")
        end
        if package:config("json") then
            package:add("defines", "COMMONLIB_OPTION_JSON=1")
            package:add("deps", "nlohmann_json")
        end
        if package:config("toml") then
            package:add("defines", "COMMONLIB_OPTION_TOML=1")
            package:add("deps", "toml11")
        end
        if package:config("xbyak") then
            package:add("defines", "COMMONLIB_OPTION_XBYAK=1")
            package:add("deps", "xbyak")
        end
    end)

    on_install("windows|x64", function(package)
        import("package.tools.xmake").install(package, {
            commonlib_ini = package:config("ini"),
            commonlib_json = package:config("json"),
            commonlib_toml = package:config("toml"),
            commonlib_xbyak = package:config("xbyak")
        })
    end)

    on_test("windows|x64", function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <REX/REX/LOG.h>

            void test() {
                REX::INFO("Hello World");
            }
        ]]}, { configs = { languages = "c++23" } }))
    end)
