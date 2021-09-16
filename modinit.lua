local filepath = require "util/filepath"

local HESH_NAME

local function OnPreLoad()
    Content.AddStringTable("REPLACE_HESH", {
        REPLACE_HESH = {
            HESH = "Hesh",
            ENTER_REPLACEMENT = "Enter Replacement",
            ENTER_REPLACEMENT_DESC = "Enter a replacement string or nothing",
            REPLACEMENT_SET = "Replacement Set!",
            REPLACEMENT_SET_DESC = "Now you will see Hesh a lot.",
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
            -- Screw you if your language translate Hesh to regex
            local replaced = old_str:gsub(HESH_NAME or LOC"REPLACE_HESH.HESH", replace_to)
            return replaced
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

local MOD_OPTIONS =
{
    {
        title = "Set Replacement String",
        button = true,
        key = "set_replacement",
        desc = "Set a replacement string for Hesh(if you already did, it's probably something else now). Leave blank to skip replacement.",
        on_click = function()
            UIHelpers.EditString(
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
    version = "0.0.2",
    alias = "REPLACE_HESH",

    OnPreLoad = OnPreLoad,
    OnLoad = OnLoad,

    mod_options = MOD_OPTIONS,

    title = "Replace Hesh",
    description = "A silly mod for Griftlands that replace all instances of Hesh with whatever you like.\n\nRageLeague is not responsible for whatever the user created.",
}