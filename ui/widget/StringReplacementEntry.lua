local StringReplacementEntry = class("Widget.StringReplacementEntry", Widget.Clickable)

-- local ICON_W = 56
local TEXT_LEFT_MARGIN = 16
local RIGHT_HITBOX_OVERFLOW = 40 -- So that the contents are still clickable when zoomed in

StringReplacementEntry.CONTROL_MAP =
{
    {
        control = Controls.Digital.GAMEPAD_RT,
        fn = function(self)
            self.delete_fn()
        end,
        hint = function(self, left, right)
            table.insert(left, loc.format("[L] <c img='rt'> Delete save file"))
        end,
    },
}

function StringReplacementEntry:init( w, h, old_string, new_string )
    StringReplacementEntry._base.init( self )

    self.hitbox = self:AddChild( Widget.SolidBox( w+RIGHT_HITBOX_OVERFLOW, h, 0x00FFFF00 ) )
    self.contents = self:AddChild( Widget() )
    -- self.glow = self.contents:AddChild( Widget.Image( engine.asset.Texture("images/glow.tex" ) ) )
    --     :SetTintColour( UICOLOURS.MUTATOR )
    --     :SetTintAlpha( 0.2 )
    --     :SetHiddenBoundingBox( true )
    --     :SetSize( ICON_W*2, ICON_W*2 )
    self.bg_color = UICOLOURS.OBJECTIVE
    self.bg = self.contents:AddChild( Widget.Panel( engine.asset.Texture("UI/mutator_bg_active.tex" ) ) )
        :SetTintColour( self.bg_color )
        :SetBloom(0.1)
    -- self.icon = self.contents:AddChild( Widget.Image( engine.asset.Texture("images/white.tex" ) ) )
    --     :SetSize( ICON_W, ICON_W )
    --     :Bloom( 0.15 )

    self.delete_button = self.contents:AddChild( Widget.ImageButton( engine.asset.Texture("UI/saveslot_delete.tex" ) ) )
        :SetSize( 40, 40 )
        :SetTintAlpha( 0 )
        :Bloom( 0.1 )
        :SetToolTip( "[L] Delete entry" )
        :Hide()

    self.delete_button.OnGainHover = function() self.delete_button._base.OnGainHover( self.delete_button ) self:OnDeleteGainHover() end
    self.delete_button.OnLoseHover = function() self.delete_button._base.OnLoseHover( self.delete_button ) self:OnDeleteLoseHover() end

    self.text_content = self.contents:AddChild( Widget() )
        :SetHiddenBoundingBox( true )
    self.old_string_line = self.text_content:AddChild( Widget.Label( "title", FONT_SIZE.SCREEN_TABS ) )
        :SetText( old_string )
        :LeftAlign()
        :SetAutoSize( w-TEXT_LEFT_MARGIN )
        :SetWordWrap( true )
        :SetGlyphColour( UICOLOURS.OBJECTIVE )
        :Bloom( 0.1 )
    self.new_string_line = self.text_content:AddChild( Widget.Label( "tooltip", FONT_SIZE.ITEM_LABEL ) )
        :SetText( loc.format("[L] Replaced to: {1}", new_string) )
        :LeftAlign()
        :SetAutoSize( w-TEXT_LEFT_MARGIN )
        :SetWordWrap( true )
        :SetGlyphColour( UICOLOURS.OBJECTIVE_LIGHT )
        :Bloom( 0.1 )

    self:SetData(old_string, new_string)
    self:ShowToolTipOnFocus( true )

    self:SetSize( w, h )

    self:SetOnClickFn( function()
        -- Do a thing on click
    end )
end

function StringReplacementEntry:SetData(old_string, new_string)
    self.old_string = old_string
    self.new_string = new_string

    self.old_string_line:SetText( old_string )
    self.new_string_line:SetText( loc.format("> {1}", new_string) )
    self:SetToolTip( loc.format("[L] All instances of \"{1}\" will be replaced by \"{2}\"", old_string, new_string) )
end

function StringReplacementEntry:SetDeleteFn( fn )
    self.delete_fn = fn
    self:OnControlModeChange( TheGame:FE():GetControlMode(), TheGame:FE():GetControlDeviceID() )
    return self
end

function StringReplacementEntry:SetSize( w, h )
    self.old_string_line:SetAutoSize( w-TEXT_LEFT_MARGIN-12 )
    self.new_string_line:SetAutoSize( w-TEXT_LEFT_MARGIN-12 )
    -- self.date:SetAutoSize( w-TEXT_LEFT_MARGIN-12 )
    self.new_string_line:LayoutBounds( "left", "below", self.old_string_line ):Offset( 0, 4 )
    -- self.labels_container:StackChildrenRow(6):LayoutBounds( "left", "below", self.new_string_line ):Offset( 0, -2 )
    -- self.date:LayoutBounds( "left", "below", self.labels_container ):Offset( 0, 1 )
    local text_w, text_h = self.text_content:GetSize()
    text_h = text_h + 20
    self.hitbox:SetSize( w, text_h )
    self.bg:SetSize( w, text_h )
    -- self.icon:LayoutBounds( "left", "center", self.hitbox ):Offset( 6, 0 )
    -- self.glow:LayoutBounds( "center", "center", self.icon ):Offset( 0, 0 )
    self.text_content:LayoutBounds( "left", "center", self.hitbox ):Offset( TEXT_LEFT_MARGIN, 1 )
    self.delete_button:LayoutBounds( "right", "top", self.bg ):Offset( -2, -2 )
    return self
end

function StringReplacementEntry:OnAdded()
    self:OnControlModeChange( TheGame:FE():GetControlMode(), TheGame:FE():GetControlDeviceID() )
end

function StringReplacementEntry:OnControlModeChange( cm, device_id )
    StringReplacementEntry._base.OnControlModeChange( self, cm, device_id )

    if cm == CONTROL_MODE.TOUCH then
        -- Long press to delete
        self.delete_button:Hide():SetEnabled( false ):SetOnClickFn( nil )
        self:SetOnRightClickFn( nil )
        self:SetOnLongClickFn( self.delete_fn )
    end
    if cm == CONTROL_MODE.MOUSE_KEYBOARD then
        -- Click the X button to delete
        self.delete_button:Show():SetEnabled( true ):SetOnClickFn( self.delete_fn )
        self:SetOnRightClickFn( self.delete_fn )
        self:SetOnLongClickFn( nil )
    end
    if cm == CONTROL_MODE.GAMEPAD then
        -- Press controller button to delete
        self.delete_button:Hide():SetEnabled( false ):SetOnClickFn( nil )
        self:SetOnRightClickFn( nil )
        self:SetOnLongClickFn( nil )
    end
end

function StringReplacementEntry:UpdateImage()
    if self.hover or self.focus then
        -- self.glow:ScaleTo( nil, 1.2, 0.1 )
        self.contents:ScaleTo( nil, 1.05, 0.1 )
        self.contents:MoveTo( 20, 0, 0.1 )
        self.bg:Bloom( 0.2 )
        if TheGame:FE():GetControlMode() == CONTROL_MODE.MOUSE_KEYBOARD then
            self.delete_button:SetEnabled( true ):AlphaTo( 1, 0.1 )
        end
    else
        -- self.glow:ScaleTo( nil, 1, 0.1 )
        self.contents:ScaleTo( nil, 1, 0.2 )
        self.contents:MoveTo( 0, 0, 0.2 )
        self.bg:Bloom( 0.1 )
        self:SetSaturation( 1 )
        self.delete_button:SetEnabled( false ):AlphaTo( 0, 0.1 )
    end

    self:SetSaturation( 1 )
end

function StringReplacementEntry:OnGainFocus()
    StringReplacementEntry._base.OnGainFocus(self)
    self:UpdateImage()
end

function StringReplacementEntry:OnLoseFocus()
    StringReplacementEntry._base.OnLoseFocus(self)
    self:UpdateImage()
end

function StringReplacementEntry:OnGainHover()
    StringReplacementEntry._base.OnGainHover(self)
    self:UpdateImage()
end

function StringReplacementEntry:OnLoseHover()
    StringReplacementEntry._base.OnLoseHover(self)
    self:UpdateImage()
end

function StringReplacementEntry:OnDeleteGainHover()
    local r, g, b, a = HexColour( UICOLOURS.PENALTY )
    self.bg:ColourFromCurrentTo( r, g, b, a, 0.2 )
end

function StringReplacementEntry:OnDeleteLoseHover()
    local r, g, b, a = HexColour( self.bg_color )
    self.bg:ColourFromCurrentTo( r, g, b, a, 0.2 )
end

--[[
Test:
t:AddChild(Widget.StringReplacementEntry(300, 80, "Hesh", "Christ")):LayoutBounds("center", "center")
]]
