if Screen.LargeEditStringPopup then
    return
end

local EditStringPopup = class("Screen.LargeEditStringPopup", Widget.Screen)

EditStringPopup.CONTROL_MAP =
{
    {
        control = Controls.Digital.MENU_CANCEL,
        fn = function(self)
            TheGame:FE():PopScreen()
            self.on_close()
            return true
        end,
        hint = function(self, left, right)
            table.insert(right, loc.format(LOC"UI.CONTROLS.CANCEL", Controls.Digital.MENU_CANCEL))
        end
    },
}

function EditStringPopup:init( title, subtitle, txt, on_done_fn )
    EditStringPopup._base.init(self)

    self.is_popup = true
    self.on_close = on_done_fn

    -- Get screen dimensions
    local screen_w, screen_h = TheGame:FE():GetScreenDims()
    self.screen_w = math.ceil( screen_w / TheGame:FE():GetBaseWidgetScale() )
    self.screen_h = math.ceil( screen_h / TheGame:FE():GetBaseWidgetScale() )

    self.scrim = self:AddChild( Widget.SolidBox( RES_X, RES_Y, 0x021A18F0 ) )--:BlockMouse()
        :SetSize( self.screen_w, self.screen_h )

    -- Backing panel
    self.panel_bg = self:AddChild( Widget.WidePanel( subtitle and 640 or 600 ) )
        :SetTitles( title, subtitle )

    self.inputbox = self:AddChild( Widget.EditLabel( 28, 640, 10 ) )
        :SetString( txt or "" )
        :LayoutBounds( "center", "below", self.panel_bg:GetTitlesWidget() )
        :Offset( 0, -SPACING.M1 )

    self.button_cancel = self.panel_bg:AddSubButton( LOC"UI.DIALOGS.CANCEL", global_images.cancel, function() TheGame:FE():PopScreen() self.on_close() end )
    self.button_ok = self.panel_bg:AddSubButton( LOC"UI.DIALOGS.OK", global_images.accept, function() TheGame:FE():PopScreen() self.on_close( self.inputbox:GetString() ) end )

    self:SetAnchors("center", "center")

    self:AddRobotOption(self.button_cancel)
end

function EditStringPopup:OnOpen()
    EditStringPopup._base.OnOpen(self)

    self:OnScreenModeChange( TheGame:FE():GetScreenMode() )

    self.inputbox:SetFocus()
end

function EditStringPopup:OnScreenModeChange( sm )
    EditStringPopup._base.OnScreenModeChange( self, sm )

    -- Scale input box
    self.inputbox:SetLayoutScale( LAYOUT_SCALE[sm] )

    -- Calculate panel height
    local titles_w, titles_h = self.panel_bg:GetTitlesWidget():GetScaledSize()
    local input_w, input_h = self.inputbox:GetScaledSize()
    -- Resize panel
    self.panel_bg:SetHeight( titles_h+SPACING.M1+input_h+SPACING.M1*4 )
        -- :LayoutButtons()

    self.inputbox:LayoutBounds( "center", "below", self.panel_bg:GetTitlesWidget() )
        :Offset( 0, -SPACING.M1 )

end
