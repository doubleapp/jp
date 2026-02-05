-- Clink completion script for jp (directory jumper)
-- Place this file in %LOCALAPPDATA%\clink\ or run: clink installscripts <dir>
-- TAB completes only saved shortcut names. Use 'jp' with no args to see commands.

local function get_jumplist_path()
    local override = os.getenv("JP_JUMPLIST")
    if override and override ~= "" then
        return override
    end
    local home = os.getenv("USERPROFILE")
    if home then
        return home .. "\\.jump_directories"
    end
    return nil
end

local function read_shortcut_names()
    local names = {}
    local path = get_jumplist_path()
    if not path then
        return names
    end
    local f = io.open(path, "r")
    if not f then
        return names
    end
    for line in f:lines() do
        local name = line:match("^(.-)=")
        if name and name ~= "" then
            table.insert(names, name)
        end
    end
    f:close()
    return names
end

local jp_parser = clink.argmatcher("jp")

jp_parser:addarg({
    function ()
        return read_shortcut_names()
    end
})
jp_parser:nofiles()
