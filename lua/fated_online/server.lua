resource.AddWorkshop( '2873640907' )

util.AddNetworkString( 'FatedOnline.UpdateClientData' )
util.AddNetworkString( 'FatedOnline.UpdateServerData' )
util.AddNetworkString( 'FatedOnline.Notify' )

net.Receive( 'FatedOnline.UpdateServerData', function( len, pl )
	local player_id = net.ReadString()

	if ( pl:SteamID64() != player_id ) then
		return
	end

	local tabl = net.ReadTable()

	PrintTable( tabl )

	if ( string.len( tabl.info.name ) > 40 ) then
		FatedOnline.msg( pl, 'Слишком длинное имя!' )

		return
	end

	FatedPlayers[ player_id ] = tabl
end )

function FatedOnline.msg( pl, text )
	net.Start( 'FatedOnline.Notify' )
		net.WriteString( text )
	net.Send( pl )
end

// DATA

hook.Add( 'Initialize', 'FatedOnline.Data', function()
	if ( !file.Exists( 'fated_online', 'DATA' ) ) then
		file.CreateDir( 'fated_online' )
		file.CreateDir( 'fated_online/players' )
	end

	FatedPlayers = {}

	local files, _ = file.Find( 'fated_online/players/*.txt', 'DATA' )

	for playerK = 1, #files do
		local pl_file = files[ playerK ]
		local pl_data = util.JSONToTable( file.Read( 'fated_online/players/' .. pl_file, 'DATA' ) )

		FatedPlayers[ pl_data.id ] = pl_data
	end

	timer.Create( 'FatedOnline.DataForClients', 1, 0, function()
		net.Start( 'FatedOnline.UpdateClientData' )
			net.WriteTable( FatedPlayers )
		net.Broadcast()
	end )
end )

hook.Add( 'PlayerInitialSpawn', 'FatedOnline.SetupData', function( pl )
	local steamid64 = tostring( pl:SteamID64() )

	if ( !file.Exists( 'fated_online/players/' .. steamid64 .. '.txt', 'DATA' ) ) then
		local PlayerDataCreate = {
			info = {
				name = pl:Name(),
				gender = 1,
				avatar = 'nil',
				family = 1,
			},
			friends = {},
			id = steamid64,
		}

		file.Write( 'fated_online/players/' .. steamid64 .. '.txt', util.TableToJSON( PlayerDataCreate ) )

		FatedPlayers[ steamid64 ] = PlayerDataCreate
	end
end )
