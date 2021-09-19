local filepath = require "util/filepath"

local HESH_NAME

local INPUT_CACHE
local TABLE_CACHE

local function ParseInput(input)
    if input == INPUT_CACHE then
        return TABLE_CACHE
    end
    INPUT_CACHE = input
    TABLE_CACHE = nil

    local t = input:split("\n")
    local result = {}
    if #t > 1 then
        for i, line in ipairs(t) do
            local entry = line:split("=")
            if #entry == 2 then
                table.insert(result, entry)
            end
        end
        TABLE_CACHE = result
        return result
    end
    return nil
end

local function OnPreLoad()
    Content.AddStringTable("REPLACE_HESH", {
        REPLACE_HESH = {
            HESH = "Hesh",
            ENTER_REPLACEMENT = "Enter Replacement",
            ENTER_REPLACEMENT_DESC = "Enter a replacement for Hesh, a list of entries in the form of \"A=B\", or nothing.",
            REPLACEMENT_SET = "Replacement Set!",
            REPLACEMENT_SET_DESC = "Now you will see a lot of weird phrases everywhere.",
            REPLACEMENT_SET_DESC_EMPTY = "Now everything is back to normal.",
        },
    })
    local old_loc = Content.LookupString
    Content.LookupString = function(id)

        local old_str = old_loc(id)
        if not old_str then
            return old_str
        end
        if id == "REPLACE_HESH.HESH" then
            if not HESH_NAME then
                HESH_NAME = old_str
            end
            return old_str
        end
        local replace_to = Content.GetModSetting(mod, "replace_to") or ""
        if replace_to and replace_to ~= "" then
            local t = ParseInput(replace_to)
            if t then
                -- Is actually a json, do the thing.
                for i, data in ipairs(t) do
                    old_str = old_str:gsub(data[1], data[2])
                end
                return old_str
            else
                -- Screw you if your language translate Hesh to regex
                local replaced = old_str:gsub(HESH_NAME or LOC"REPLACE_HESH.HESH", replace_to)
                return replaced
            end
        end
        return old_str
    end
    function CharacterDef:GetLocalizedName( agent )
        if self.name then
            return loc.format( LOC(self:GetLocNameKey()), agent )
        end
    end
end

local function OnLoad( mod )
    rawset(_G, "CURRENT_MOD_ID", mod.id)
    for k, filepath in ipairs( filepath.list_files( "REPLACE_HESH:ui/", "*.lua", true )) do
        local name = filepath:match( "(.+)[.]lua$" )
        -- print(name)
        if name then
            require(name)
        end
    end
end

local function EditString( title, subtitle, initial_value, on_done_fn )
    local screen = Screen.LargeEditStringPopup( title, subtitle, initial_value, on_done_fn )
    TheGame:FE():PushScreen(screen)
end

local MOD_OPTIONS =
{
    {
        title = "Set Replacement String",
        button = true,
        key = "set_replacement",
        desc = "Set a replacement string for Hesh. Leave blank to skip replacement.\nFor advanced string manipulation, add a list of entries in the form \"A=B\", indicating that all instances of \"A\" is replaced by \"B\".\n<#PENALTY>Doing so might cause functional changes to certain strings, so continue at your own risk!</>",
        on_click = function()
            EditString(
                LOC"REPLACE_HESH.ENTER_REPLACEMENT", LOC"REPLACE_HESH.ENTER_REPLACEMENT_DESC",
                Content.GetModSetting(mod, "replace_to") or "",
                function( val )
                    if not val then return end
                    if val ~= "" then
                        Content.SetModSetting(mod, "replace_to", val)
                        UIHelpers.InfoPopup( LOC"REPLACE_HESH.REPLACEMENT_SET", LOC"REPLACE_HESH.REPLACEMENT_SET_DESC" )
                    else
                        Content.SetModSetting(mod, "replace_to", false)
                        UIHelpers.InfoPopup( LOC"REPLACE_HESH.REPLACEMENT_SET", LOC"REPLACE_HESH.REPLACEMENT_SET_DESC_EMPTY" )
                    end
                end )
        end,
    },
}
return {
    version = "1.1.0",
    alias = "REPLACE_HESH",

    OnPreLoad = OnPreLoad,
    OnLoad = OnLoad,

    mod_options = MOD_OPTIONS,

    title = "Replace Hesh",
    description = "A silly mod for Griftlands that replace all instances of Hesh with whatever you like.\n\nRageLeague is not responsible for whatever the user created.",
}
