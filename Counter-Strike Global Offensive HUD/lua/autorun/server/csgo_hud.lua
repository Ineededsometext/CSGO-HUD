resource.AddFile( "resource/fonts/stratum.ttf" )
resource.AddFile( "materials/csgo_hud/health.png" )
resource.AddFile( "materials/csgo_hud/armor.png" )
resource.AddFile( "materials/csgo_hud/bullet.png" )

CreateClientConVar( "csgo_hud_toggle", "1", true, false, "Disables or enables the CS:GO HUD." )
CreateClientConVar( "csgo_hud_r", "200", true, false, "Sets the red of the CS:GO HUD." )
CreateClientConVar( "csgo_hud_g", "225", true, false, "Sets the green of the CS:GO HUD." )
CreateClientConVar( "csgo_hud_b", "180", true, false, "Sets the blue of the CS:GO HUD." )

hook.Add( "PlayerHurt", "csgo_hud_hurt", function( ply )
    ply:SetNWBool( "csgo_hud_hurt", true )

    if ( not timer.Exists( "csgo_hud_hurt" .. ply:EntIndex() ) ) then
        timer.Create( "csgo_hud_hurt" .. ply:EntIndex(), 0.4, 1, function()
            ply:SetNWBool( "csgo_hud_hurt", false )
        end )
    else
        timer.Adjust( "csgo_hud_hurt" .. ply:EntIndex(), 0.4, 1, function()
            ply:SetNWBool( "csgo_hud_hurt", false )
        end )
    end
end )

concommand.Add( "csgo_hud_reset", function()
    GetConVar( "csgo_hud_toggle" ):SetBool( false )
    GetConVar( "csgo_hud_r" ):SetInt( 200 )
    GetConVar( "csgo_hud_g" ):SetInt( 225 )
    GetConVar( "csgo_hud_b" ):SetInt( 180 )
end )