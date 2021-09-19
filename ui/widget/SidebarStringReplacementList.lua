local MODID = CURRENT_MOD_ID

local SidebarStringReplacementList = class("Widget.SidebarStringReplacementList", Widget.SidebarBlock)

function SidebarStringReplacementList:init( width, override_data )
    SidebarStringReplacementList._base.init(self, width)

    -- self.on_select_fn = on_select_fn

    local mod_data = Content.GetModSetting(MODID, "string_replacement_map") or {}
    self.replacement_data = override_data or mod_data[TheGame:GetLanguage()] or {}
end

function SidebarStringReplacementList:OnAdded()
    self:OnControlModeChange( TheGame:FE():GetControlMode(), TheGame:FE():GetControlDeviceID() )
end

function SidebarStringReplacementList:OnControlModeChange( cm, device_id )
    SidebarStringReplacementList._base.OnControlModeChange( self, cm, device_id )

    if cm == CONTROL_MODE.TOUCH then
        self.info_text = "[L] Long press on an entry to delete it."
    else
        self.info_text = ""
    end
end

function SidebarStringReplacementList:OnDeleteSlot( slot )
    TheGame:FE():PushScreen( Screen.YesNoPopup( "[L] Remove Entry?", "[L] This will delete a replacement map. Are you sure you want to do this?" ) )
        :SetFn( function(v)
            if v == Screen.YesNoPopup.YES then
                local pos = table.findif( self.replacement_data, function(data) return data[1] == slot.old_string end )
                assert(pos)
                table.remove( self.replacement_data, pos )

                slot.enabled = false
                AUDIO:PlayEvent( "event:/ui/save_slot_menu/save_file_deleted" )
                local idx = self.scrolling_contents:IndexOf( slot )
                slot:Reparent( self )
                local pos_x, pos_y = slot:GetPos()
                slot:MoveTo( pos_x-40, pos_y, 0.15, easing.outQuad )
                slot:AlphaTo( 0, 0.15, easing.outQuad,
                    function()
                        slot:Remove()
                        -- Re-layout remaining buttons
                        for k, w in ipairs( self.scrolling_contents.children ) do
                            local p_x, p_y = w:GetPos()
                            w.old_x = p_x
                            w.old_y = p_y
                        end
                        self.scrolling_contents:StackChildren( SPACING.M1 )
                        self.scroll_panel:RefreshView()
                        for k, w in ipairs( self.scrolling_contents.children ) do
                            local p_x, p_y = w:GetPos()
                            w.new_x = p_x
                            w.new_y = p_y
                            w:SetPos( w.old_x, w.old_y )
                            w:MoveTo( w.new_x, w.new_y, 0.08, easing.outQuad )
                        end
                        if idx and TheGame:FE():GetControlMode() == CONTROL_MODE.GAMEPAD then
                            local focus = self.scrolling_contents.children[ idx ] or self.scrolling_contents.children[ idx - 1 ]
                            if focus then
                                focus:SetFocus()
                            end
                        end
                    end )
            end
            end
        )
end

function SidebarStringReplacementList:Refresh()
    -- SidebarStringReplacementList._base.Refresh( self, character_data )

    -- Set text
    self.title:SetText( "[L] Replacements" ):SetGlyphColour( UICOLOURS.SUBTITLE )
    self.subtitle:Hide()--:SetText( character_data:GetLocalizedTitle() ):SetGlyphColour( UICOLOURS.TITLE )
    self.text:Hide()
    self.info:SetText( self.info_text or "" )

    -- Remove old save files
    self.scrolling_contents:DestroyAllChildren()
    -- Add new run options
    -- self.scrolling_contents:AddChild( Widget.Label( "title", FONT_SIZE.BODY_TEXT, LOC"UI.NEW_GAME_SCREEN.SIDEBAR_MAIN_NEW_RUN" ) )
    --     :SetGlyphColour( UICOLOURS.SUBTITLE )
    --     :SetAutoSize( self.sidebar_width )
    --     :SetWordWrap( true )
    --     :Bloom( 0.05 )
    -- for k, act in ipairs( self.character_data.acts ) do

    --     if act.data.game_type ~= GAME_TYPE.DAILY then
    --         local widget = Widget.NewActButton( self.sidebar_width+150, act:GetLocalizedName() )
    --             :SetOnClickFn( function() self.on_select_fn(act, false) end )
    --             :SetFocusDelta( 10 )
    --             :ShowArrow()
    --             :Refresh( self.character_data, act )

    --         self.scrolling_contents:AddChild(widget)
    --         if act.data.story_mode then
    --             local widget = Widget.NewActButton( self.sidebar_width+150, act:GetLocalizedName() )
    --                 :SetOnClickFn( function() self.on_select_fn(act, true) end )
    --                 :SetFocusDelta( 10 )
    --                 :ShowArrow()
    --                 :Refresh( self.character_data, act, true )

    --             self.scrolling_contents:AddChild(widget)
    --         end
    --     end
    -- end

    -- List this act's save files
    if self.replacement_data then
        -- local savefiles_title
        for k, save_data in ipairs( self.replacement_data ) do
            -- Add a title if there isn't one yet
            -- if not savefiles_title then
            --     savefiles_title = self.scrolling_contents:AddChild( Widget.Label( "title", FONT_SIZE.BODY_TEXT, LOC"UI.NEW_GAME_SCREEN.SIDEBAR_MAIN_CONTINUE_RUN" ) )
            --         :SetGlyphColour( UICOLOURS.SUBTITLE )
            --         :SetAutoSize( self.sidebar_width )
            --         :SetWordWrap( true )
            --         :Bloom( 0.05 )
            -- end
            -- Add this savefile
            local slot = self.scrolling_contents:AddChild( Widget.StringReplacementEntry( self.sidebar_width - 24, 70, save_data[1], save_data[2] ) )
                :LayoutBounds( "left", "below" )
                :Offset( 0, -10 )
            slot:SetDeleteFn( function() self:OnDeleteSlot( slot ) end )
        end
    end

    -- Layout
    self:Layout()

    return self
end

function SidebarStringReplacementList:Layout()

    -- Layout the savefiles
    self.scrolling_contents:StackChildren( SPACING.M1 )

    SidebarStringReplacementList._base.Layout( self )

    return self
end

function SidebarStringReplacementList:OnScreenModeChange( sm )
    SidebarStringReplacementList._base.OnScreenModeChange( self, sm )

    return self
end

function SidebarStringReplacementList:GetDefaultFocus()
    return self.scrolling_contents and self.scrolling_contents.children and self.scrolling_contents.children[2]
end

--[[
Test:
t = t:AddChild(Widget.SidebarStringReplacementList(300, {{"Hesh", "Christ"}, {"Admiralty", "Coppers"}})):Show():Refresh():LayoutBounds("center", "center"):Offset( 0, 200 )
t:PrepareAnimateIn()
t:AnimateIn()
]]
