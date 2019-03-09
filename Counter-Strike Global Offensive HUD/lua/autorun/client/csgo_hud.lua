local hide = {
    [ "CHudAmmo" ] = true,
    [ "CHudSecondaryAmmo" ] = true,
    [ "CHudHealth" ] = true,
    [ "CHudBattery" ] = true
--  [ "CHudWeaponSelection" ] = true
}

hook.Add( "HUDShouldDraw", "csgo_hud_disable_defaults", function( type )
    if ( hide[ type ] and GetConVar( "csgo_hud_toggle" ):GetBool() ) then return false end
end )

surface.CreateFont( "CSGOLarge", {
    font = "StratumNo2",
    size = ScrW() * 0.025,
    weight = 600,
    antialiasing = true
} )

surface.CreateFont( "CSGOMedium", {
    font = "StratumNo2",
    size = ScrW() * 0.02,
    weight = 600,
    antialiasing = true
} )

surface.CreateFont( "CSGOSmall", {
    font = "StratumNo2",
    size = ScrW() * 0.015,
    weight = 600,
    antialiasing = true
} )

local lr, lg, lb = GetConVar( "csgo_hud_r" ):GetInt(), GetConVar( "csgo_hud_g" ):GetInt(), GetConVar( "csgo_hud_b" ):GetInt()

local padding, width, halfWidth = 10, 16, 6 
local lastBullet, smoothingIn, smooth, changedBullets, flyingBullets = 5, false, 0, 0, {}
local function DrawBullets( bullets, x, y, red, scale )
    if ( scale ) then
        width = 16 * scale
        halfWidth = 0.375 * width
    end

    if ( not bullets or bullets < 1 ) then return end

    if ( red ) then
        surface.SetDrawColor( 255, 75, 75, 255 )
    end
                
    if ( lastBullet != bullets ) then
        changedBullets = math.min( bullets, 5 - ( lastBullet - bullets ) )
        if ( bullets > lastBullet ) then 
            changedBullets = 4 
        else
            if ( flyingBullets[ 1 ] ) then
                for key, bullet in pairs(flyingBullets) do
                    flyingBullets[ key ] = bullet - 0.05
                end

                table.insert( flyingBullets, 0.25 )
            else
                flyingBullets[ 1 ] = 0.25
            end
        end

        if ( not smoothingIn ) then
            smoothingIn = true
        end 

        lastBullet = bullets
    end

    bullets = math.min( bullets, 5 )
                
    local xpos = x + 30 + padding + 1000
    surface.SetMaterial( Material( "materials/csgo_hud/bullet.png" ) )
                
    if ( smoothingIn ) then
        smooth = math.Approach( smooth, 1, 3 * FrameTime() )
        for i = 1, changedBullets do
            surface.DrawTexturedRect( xpos - ( i + 1 ) * halfWidth + ( smooth * halfWidth ), y, width, width ) 
        end
            
        if ( bullets == 5 ) then
            surface.SetDrawColor( Color( 175, 175, 175, smooth * 255 ) ) 
            surface.DrawTexturedRect( xpos - 48 + ( smooth * 18 ), y, width, width )
        end
                    
        if ( smooth == 1 ) then
            smooth, smoothingIn = 0, false
        end
    else
        for i = 1, bullets do
            surface.DrawTexturedRect( xpos - i * halfWidth, y, width, width ) 
        end
    end
                
    for key, bullet in pairs ( flyingBullets ) do
        flyingBullets[ key ] = bullet - FrameTime()
        if ( bullet < 0 ) then flyingBullets[ key ] = nil continue end
        surface.DrawTexturedRectRotated( xpos + halfWidth * key, y + halfWidth + key * 3, width, width, key * -15 ) 
    end
            
    for i = 5, 1, -1 do
        if ( flyingBullets[ i ] and flyingBullets[ i ] < 0.25 - i * 0.05 ) then
               flyingBullets[ i + 1 ] = flyingBullets[ i ]
               flyingBullets[ i ] = nil
        end
    end
end

local function CsgoBullets()
    local weapon = LocalPlayer():GetActiveWeapon()
    if ( not IsValid( weapon ) ) then return end
    
    local clip = weapon:Clip1() or 0
    local maxammo = LocalPlayer():GetActiveWeapon():Clip1() or 0
    local red = clip <= math.ceil( maxammo * 0.25 )

    surface.SetDrawColor( Color( GetConVar( "csgo_hud_r" ):GetInt(), GetConVar( "csgo_hud_g" ):GetInt(), GetConVar( "csgo_hud_b" ):GetInt(), 255 ) )
    DrawBullets( clip, ScrW() * 0.2156, ScrH() * 0.971, red, 1.0 )
end

hook.Add( "HUDPaint", "CS:GO HUD", function()
    if ( not GetConVar("csgo_hud_toggle"):GetBool() ) then return end

    local r, g, b = GetConVar( "csgo_hud_r" ):GetFloat(), GetConVar( "csgo_hud_g" ):GetFloat(), GetConVar( "csgo_hud_b" ):GetFloat()
    
    local health = LocalPlayer():Health()
    local armor = LocalPlayer():Armor()
    local noAmmo = {
        [ "weapon_bugbait" ] = true,
        [ "weapon_physgun" ] = true,
        [ "weapon_physcannon" ] = true,
        [ "weapon_crowbar" ] = true,
        [ "weapon_stunstick" ] = true,
        [ "weapon_slam" ] = true,
        [ "gmod_tool" ] = true,
        [ "gmod_camera" ] = true
    }

    if ( health <= 20 ) then
        draw.RoundedBox( 0, 0, ScrH() * 0.95655, ScrW() * 0.127, ScrH() * 0.05, Color( 255, 55, 55, 100 ) )
    end

    surface.SetDrawColor( Color( 0, 0, 0, 225 ) )
    surface.SetTexture( surface.GetTextureID( "gui/gradient" ) )
	surface.DrawTexturedRect( 0, ScrH() * 0.956, ScrW() * 0.3, ScrH() * 0.05 )
        
    if ( health > 20 ) then
        surface.SetDrawColor( Color( r, g, b, 150 ) )
    else
        surface.SetDrawColor( Color( 255, 75, 75, 150 ) )
    end

	surface.SetMaterial( Material( "materials/csgo_hud/health.png" ) )
	surface.DrawTexturedRect( ScrW() * 0.005, ScrH() * 0.967, ScrW() * 0.0156, ScrW() * 0.0156 )

    if ( health <= 100 ) then
        draw.SimpleText( health, "CSGOLarge", ScrW() * 0.0415, ScrH() * 0.956, Color( r, g, b, 255 ), TEXT_ALIGN_CENTER )
    elseif ( health > 100 ) then
        draw.SimpleText( "100+", "CSGOLarge", ScrW() * 0.0415, ScrH() * 0.956, Color( r, g, b, 255 ), TEXT_ALIGN_CENTER )
    elseif ( health <= 0 ) then
        draw.SimpleText( "0", "CSGOLarge", ScrW() * 0.0415, ScrH() * 0.956, Color( 255, 75, 75, 255 ), TEXT_ALIGN_CENTER )
    end
            
    if ( not LocalPlayer():GetNWBool( "csgo_hud_hurt" ) and health > 20 ) then
        lr = Lerp( 10 * FrameTime(), lr, r )
        lg = Lerp( 10 * FrameTime(), lg, g )
        lb = Lerp( 10 * FrameTime(), lb, b )
        surface.SetDrawColor( Color( lr, lg, lb, 150 ) )
    else
        lr = Lerp( 10 * FrameTime(), lr, 255 )
        lg = Lerp( 10 * FrameTime(), lg, 25 )
        lb = Lerp( 10 * FrameTime(), lb, 25 )
        surface.SetDrawColor( Color( lr, lg, lb, 150 ) )
    end
    
    surface.DrawOutlinedRect( ScrW() * 0.064, ScrH() * 0.976, ScrW() * 0.0545, ScrH() * 0.016 )
            
    surface.SetDrawColor( Color( 0, 0, 0, 120 ) )
    surface.DrawRect( ScrW() * 0.065, ScrH() * 0.977, ScrW() * 0.0535, ScrH() * 0.015 )

    if ( not LocalPlayer():GetNWBool( "csgo_hud_hurt" ) and health > 20 ) then
        lr = Lerp( 10 * FrameTime(), lr, r )
        lg = Lerp( 10 * FrameTime(), lg, g )
        lb = Lerp( 10 * FrameTime(), lb, b )
        surface.SetDrawColor( Color( lr, lg, lb, 150 ) )
    else
        lr = Lerp( 10 * FrameTime(), lr, 255 )
        lg = Lerp( 10 * FrameTime(), lg, 75 )
        lb = Lerp( 10 * FrameTime(), lb, 75 )
        surface.SetDrawColor( Color( lr, lg, lb, 150 ) )
    end

    surface.DrawRect( ScrW() * 0.0645, ScrH() * 0.977, math.Clamp( health / LocalPlayer():GetMaxHealth() * ScrW() * 0.0535, 0, ScrW() * 0.0535 ), ScrH() * 0.015 )

    surface.SetDrawColor( Color( r, g, b, 150 ) )
	surface.SetMaterial( Material( "materials/csgo_hud/armor.png" ) )
	surface.DrawTexturedRect( ScrW() * 0.13, ScrH() * 0.967, ScrW() * 0.0156, ScrW() * 0.0156 )

    if ( armor <= 100 ) then
        draw.SimpleText( armor, "CSGOLarge", ScrW() * 0.166, ScrH() * 0.956, Color( r, g, b, 255 ), TEXT_ALIGN_CENTER )
    else
        draw.SimpleText( "100+", "CSGOLarge", ScrW() * 0.166, ScrH() * 0.956, Color( r, g, b, 255 ), TEXT_ALIGN_CENTER )
    end

    surface.SetDrawColor( Color( r, g, b, 50 ) )
    surface.DrawOutlinedRect( ScrW() * 0.19, ScrH() * 0.976, ScrW() * 0.0545, ScrH() * 0.016 )
            
    surface.SetDrawColor( Color( 0, 0, 0, 120 ) )
    surface.DrawRect( ScrW() * 0.191, ScrH() * 0.977, ScrW() * 0.0535, ScrH() * 0.015 )

    surface.SetDrawColor( Color( r, g, b, 150 ) )
    surface.DrawRect( ScrW() * 0.191, ScrH() * 0.977, math.Clamp( LocalPlayer():Armor() / 100 * ScrW() * 0.0535, 0, ScrW() * 0.0535 ), ScrH() * 0.015 )

    surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
	surface.SetTexture( surface.GetTextureID( "gui/gradient" ) )
    surface.DrawTexturedRectRotated( ScrW() * 0.925, ScrH() * 0.978, ScrW() * 0.16, ScrW() * 0.025, 180 )
        
    surface.SetDrawColor( Color( r, g, b, 255 ) )
    surface.SetMaterial ( Material( "materials/csgo_hud/bullet.png" ) )

    local weapon = LocalPlayer():GetActiveWeapon()

    if ( IsValid( weapon ) ) then
        local clip = weapon:Clip1() 
        local ammo = LocalPlayer():GetAmmoCount( weapon:GetPrimaryAmmoType() )

        if ( not weapon.DrawAmmo or noAmmo[ weapon:GetClass() ] ) then return end

        if ( clip == -1 or LocalPlayer():InVehicle() ) then
            draw.SimpleText( ammo, "CSGOMedium", ScrW() * 0.935, ScrH() * 0.963, Color( r, g, b, 230 ), TEXT_ALIGN_CENTER )
            
            return
        end

        draw.SimpleText( clip, "CSGOLarge", ScrW() * 0.915, ScrH() * 0.956, Color( r, g, b, 230 ), TEXT_ALIGN_RIGHT )
        draw.SimpleText( "/", "CSGOSmall", ScrW() * 0.925, ScrH() * 0.9675, Color( r, g, b, 230 ), TEXT_ALIGN_RIGHT )
        draw.SimpleText( ammo, "CSGOSmall", ScrW() * 0.927, ScrH() * 0.97, Color( r, g, b, 230 ), TEXT_ALIGN_LEFT )
    
        CsgoBullets()
    end
end )