local color_white = Color(255,255,255)

// TABS

-- Friends
local function TabFriends( pnl )
	local main_sp = vgui.Create( 'DScrollPanel', pnl )
	main_sp:Dock( FILL )

	for player_id, player_data in pairs( FatedPlayers ) do
		local panel = vgui.Create( 'DPanel', main_sp )
		panel:Dock( TOP )
		panel:SetTall( 80 )
		panel.PaintOver = function( self, w, h )
			FatedOnline.draw.avatar( player_data.info.avatar, 7, 7, 64, 64 )

			draw.SimpleText( player_data.info.name, 'FatedOnline.big', 82, h * 0.5, color_white, 0, 1 )
		end
	
		FatedOnline.draw.panel( panel )

		local btn_open = vgui.Create( 'DButton', panel )
		btn_open:Dock( RIGHT )
		btn_open:SetWide( 90 )
		btn_open:SetText( '' )
		btn_open.DoClick = function()
			FatedOnline.OpenProfile( player_id )
		end
		btn_open.Paint = function( self, w, h )
			local text_color = self:IsHovered() and FatedOnline.config.colors.theme or color_white

			draw.SimpleText( 'Open', 'FatedOnline.main', w * 0.5, h * 0.5 - 10, text_color, 1, 1 )
			draw.SimpleText( 'profile', 'FatedOnline.main', w * 0.5, h * 0.5 + 10, text_color, 1, 1 )
		end
	end
end

// MENU

local function CreateMenu()
	FatedOnline.menu = vgui.Create( 'DFrame' )
	FatedOnline.menu:SetSize( ScrW() * 0.7, ScrH() * 0.7 )
	FatedOnline.menu:Center()
	FatedOnline.menu:SetTitle( 'Fated Online' )
	FatedOnline.menu:MakePopup()
	FatedOnline.menu:SetKeyBoardInputEnabled( false )

	FatedOnline.menu.main_panel = vgui.Create( 'DPanel', FatedOnline.menu )
	FatedOnline.menu.main_panel:Dock( FILL )
	FatedOnline.menu.main_panel:DockPadding( 6, 6, 6, 6 )
	FatedOnline.menu.main_panel.Paint = function( self, w, h )
		draw.RoundedBox( 6, 0, 0, w, h, FatedOnline.config.colors.main_panel )
	end

	FatedOnline.menu.content = vgui.Create( 'DPanel', FatedOnline.menu.main_panel )
	FatedOnline.menu.content:Dock( FILL )
	FatedOnline.menu.content.Paint = nil

	FatedOnline.menu.LeftMenu = vgui.Create( 'DPanel', FatedOnline.menu.main_panel )
	FatedOnline.menu.LeftMenu:Dock( LEFT )
	FatedOnline.menu.LeftMenu:DockMargin( 0, 0, 6, 0 )
	FatedOnline.menu.LeftMenu:DockPadding( 6, 6, 6, 6 )
	FatedOnline.menu.LeftMenu:SetWide( 170 )
	FatedOnline.menu.LeftMenu.Paint = nil

	local TabsList = {
		{
			name = 'My page',
			icon = 'icon16/accept.png',
			click = function()
				FatedOnline.OpenProfile( LocalPlayer():SteamID64() )
			end
		},
		{
			name = 'List of players',
			icon = 'icon16/emoticon_smile.png',
			click = function()
				TabFriends( FatedOnline.menu.content )
			end
		},
	}

	FatedOnline.menu.LeftMenu.sp = vgui.Create( 'DScrollPanel', FatedOnline.menu.LeftMenu )
	FatedOnline.menu.LeftMenu.sp:Dock( FILL )

	for id = 1, #TabsList do
		local TabElement = TabsList[ id ]

		local Tab = vgui.Create( 'DButton', FatedOnline.menu.LeftMenu.sp )
		Tab:Dock( TOP )
		Tab:SetTall( 32 )
		Tab:SetText( '' )
		Tab.DoClick = function()
			FatedOnline.menu.content:Clear()

			TabElement.click()
		end

		local icon = Material( TabElement.icon )

		Tab.Paint = function( self, w, h )
			if ( self:IsHovered() ) then
				draw.RoundedBox( 6, 0, 0, w, h, FatedOnline.config.colors.tab_hovered )
			end

			draw.SimpleText( TabElement.name, 'FatedOnline.tabs', 40, h * 0.5, FatedOnline.config.colors.light, 0, 1 )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( icon )
			surface.DrawTexturedRect( 4, 4, 24, 24 )
		end
	end

	-- Installing a standard tab
	TabsList[ 1 ].click()
end

concommand.Add( 'fated_online_menu', function()
	if ( IsValid( FatedOnline.menu ) ) then
		FatedOnline.menu:SetVisible( true )
	else
		CreateMenu()
	end
end )

concommand.Add( 'fated_online_reopen', function()
	if ( IsValid( FatedOnline.menu ) ) then
		FatedOnline.menu:Remove()
	end

	RunConsoleCommand( 'fated_online_menu' )
end )
