net.Receive( 'FatedOnline.UpdateClientData', function()
	local data = net.ReadTable()

	FatedPlayers = data
end )

net.Receive( 'FatedOnline.Notify', function()
	local NotifyMenu = vgui.Create( 'DPanel' )
	NotifyMenu:SetSize( 210, 150 )
	NotifyMenu:Center()
	NotifyMenu:MakePopup()

	FatedOnline.draw.panel( NotifyMenu )

	local btn_ok = vgui.Create( 'DButton', NotifyMenu )
	btn_ok:Dock( BOTTOM )
	btn_ok:SetTall( 60 )
	btn_ok.DoClick = function()
		NotifyMenu:Remove()
	end
end )

// FUNCTIONS

local color_white = Color(255,255,255)

function FatedOnline.sound( name )
	surface.PlaySound( name or 'UI/buttonclickrelease.wav' )
end

local GenderTable = {
	'Unknown',
	'Guy',
	'Girl',
}

function FatedOnline.GetGender( typ )
	return GenderTable[ typ ]
end

local FamilyTable = {
	'Unknown',
	'Free',
	'In a relationship',
	'Everything is complicated',
	'Search',
	'Engaged',
}

function FatedOnline.GetFamily( typ )
	return FamilyTable[ typ ]
end

FatedOnline.draw = {}

function FatedOnline.draw.panel( element )
	element.Paint = function( self, w, h )
		draw.RoundedBox( 6, 0, 0, w, h, FatedOnline.config.colors.outline )
		draw.RoundedBox( 6, 1, 1, w - 2, h - 2, FatedOnline.config.colors.panel )
	end
end

function FatedOnline.draw.avatar( pl_avatar, x, y, w, h )
	surface.SetDrawColor( color_white )
	surface.SetMaterial( Material( 'fated_online/avatars/' .. pl_avatar .. '.png' ) )
	surface.DrawTexturedRect( x, y, w, h )
end

function FatedOnline.OpenProfile( pl_id )
	FatedOnline.menu.content:Clear()

	local player_data = FatedPlayers[ pl_id ]

	local main_sp = vgui.Create( 'DScrollPanel', FatedOnline.menu.content )
	main_sp:Dock( FILL )

	local BarCmds = {
		{
			name = 'Change... name',
			func = function()
				Derma_StringRequest( '', 'What name do you want to put?', player_data.info.name, function( s )
					local newData = table.Copy( player_data )
					newData.info.name = s

					net.Start( 'FatedOnline.UpdateServerData' )
						net.WriteString( pl_id )
						net.WriteTable( newData )
					net.SendToServer()
				end, function() end, 'Confirm', 'Cancel' )
			end
		},
		{
			name = 'gender',
			func = function()
				local function SelectGender( typ )
					local newData = table.Copy( player_data )
					newData.info.gender = typ

					net.Start( 'FatedOnline.UpdateServerData' )
						net.WriteString( pl_id )
						net.WriteTable( newData )
					net.SendToServer()
				end

				local DM = DermaMenu()

				for genderID = 1, #GenderTable do
					DM:AddOption( GenderTable[ genderID ], function()
						SelectGender( genderID )
					end )
				end

				DM:Open()
			end
		},
		{
			name = 'marital status',
			func = function()
				local function SelectFamily( typ )
					local newData = table.Copy( player_data )
					newData.info.family = typ

					net.Start( 'FatedOnline.UpdateServerData' )
						net.WriteString( pl_id )
						net.WriteTable( newData )
					net.SendToServer()
				end

				local DM = DermaMenu()

				for familyID = 1, #FamilyTable do
					DM:AddOption( FamilyTable[ familyID ], function()
						SelectFamily( familyID )
					end )
				end

				DM:Open()
			end
		},
	}

	if ( pl_id == LocalPlayer():SteamID64() ) then
		local EditBar = vgui.Create( 'DPanel', main_sp )
		EditBar:Dock( TOP )
		EditBar:DockMargin( 0, 0, 0, 6 )
		EditBar:DockPadding( 6, 6, 6, 6 )
		EditBar:SetTall( 40 )

		FatedOnline.draw.panel( EditBar )

		local sp = vgui.Create( 'DHorizontalScroller', EditBar )
		sp:Dock( FILL )

		for cmdID = 1, #BarCmds do
			local cmd = BarCmds[ cmdID ]

			local cmd_btn = vgui.Create( 'DButton', sp )
			cmd_btn:SetText( '' )
			cmd_btn.DoClick = function()
				cmd.func()
			end
			cmd_btn.Paint = function( self, w, h )
				local text_color = self:IsHovered() and FatedOnline.config.colors.theme or color_white

				draw.SimpleText( cmd.name, 'FatedOnline.main', w * 0.5, h * 0.5, text_color, 1, 1 )
			end
			cmd_btn:SetTooltip( 'After applying, reload the page.' )

			surface.SetFont( 'FatedOnline.main' )

			cmd_btn:SetWide( surface.GetTextSize( cmd.name ) + 12 )

			sp:AddPanel( cmd_btn )
		end
	end

	local Banner = vgui.Create( 'DPanel', main_sp )
	Banner:Dock( TOP )
	Banner:SetTall( 240 )
	Banner.Paint = nil

	Banner.Main = vgui.Create( 'DPanel', Banner )
	Banner.Main:Dock( FILL )
	Banner.Main:DockMargin( 0, 0, 6, 0 )

	local gender = FatedOnline.GetGender( player_data.info.gender )
	local family = FatedOnline.GetFamily( player_data.info.family )

	Banner.Main.PaintOver = function( self, w, h )
		-- Information
		draw.SimpleText( 'Information', 'FatedOnline.main', 12, 12, color_white )

		draw.SimpleText( 'Gender:',, 'FatedOnline.main', 12, 44, color_white )
		draw.SimpleText( gender, 'FatedOnline.main', 72, 44, FatedOnline.config.colors.theme )

		draw.SimpleText( 'Marital status:',, 'FatedOnline.main', 12, 76, color_white )
		draw.SimpleText( family, 'FatedOnline.main', 112, 76, FatedOnline.config.colors.theme )
	end

	FatedOnline.draw.panel( Banner.Main )

	Banner.Main.Down = vgui.Create( 'DPanel', Banner.Main )
	Banner.Main.Down:Dock( BOTTOM )
	Banner.Main.Down:SetTall( 94 )
	Banner.Main.Down.PaintOver = function( self, w, h )
		draw.SimpleText( player_data.info.name, 'FatedOnline.big', 94, h * 0.5, color_white, 0, 1 )
	end

	FatedOnline.draw.panel( Banner.Main.Down )

	local AvatarEdit = vgui.Create( 'DButton', Banner.Main )
	AvatarEdit:SetSize( 64, 64 )
	AvatarEdit:SetPos( 15, 161 )
	AvatarEdit:SetText( '' )
	
	local color_blackout = Color(0,0,0,150)

	AvatarEdit.Paint = function( self, w, h )
		FatedOnline.draw.avatar( player_data.info.avatar, 0, 0, w, h )

		if ( self:IsHovered() and pl_id == LocalPlayer():SteamID64() ) then
			draw.RoundedBox( 0, 0, 0, w, h, color_blackout )

			draw.SimpleText( 'Change', 'FatedOnline.main', w * 0.5, h * 0.5, color_white, 1, 1 )
		end
	end
	AvatarEdit.DoClick = function()
		if ( pl_id != LocalPlayer():SteamID64() ) then
			return
		end

		local DM = DermaMenu()

		local function CreateBtnAvatar( name, id )
			DM:AddOption( name, function()
				local newData = table.Copy( player_data )
				newData.info.avatar = id

				net.Start( 'FatedOnline.UpdateServerData' )
				net.WriteString( pl_id )
					net.WriteTable( newData )
				net.SendToServer()
			end )
		end

		CreateBtnAvatar( 'Without an avatar', 'nil' )
		CreateBtnAvatar( 'Gradient 1', 'grad_1' )
		CreateBtnAvatar( 'Gradient 2', 'grad_2' )

		DM:Open()
	end

	Banner.Friends = vgui.Create( 'DPanel', Banner )
	Banner.Friends:Dock( RIGHT )
	Banner.Friends:DockPadding( 12, 44, 12, 12 )
	Banner.Friends:SetWide( 220 )
	Banner.Friends.PaintOver = function( self, w, h )
		draw.SimpleText( 'Friends', 'FatedOnline.main', 12, 12, color_white )

	end

	FatedOnline.draw.panel( Banner.Friends )

	Banner.Friends.box = vgui.Create( 'DPanel', Banner.Friends )
	Banner.Friends.box:Dock( FILL )
end

// FONTS

surface.CreateFont( 'FatedOnline.tabs', {
	font = 'Arial',
	size = 16,
	weight = 200,
	antialias = true,
} )

surface.CreateFont( 'FatedOnline.main', {
	font = 'Arial',
	size = 18,
	weight = 200,
	antialias = true,
} )

surface.CreateFont( 'FatedOnline.big', {
	font = 'Arial',
	size = 21,
	weight = 200,
	antialias = true,
} )
