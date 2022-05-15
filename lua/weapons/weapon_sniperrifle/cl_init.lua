include('shared.lua')

language.Add("weapon_sniperrifle", "M40A1")

SWEP.PrintName = "M40A1 Sniper Rifle"
SWEP.Slot = 5
SWEP.SlotPos = 3
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false

SWEP.WepSelectIcon = surface.GetTextureID("HUD/weapons/weapon_sniperrifle") 
SWEP.BounceWeaponIcon = false 

local crosshairScoped = surface.GetTextureID("HUD/crosshairs/m40a1_crosshair")
function SWEP:DrawHUD()
	if !self:GetNetworkedBool("scoped") then return end
	surface.SetDrawColor(255,255,255,255)
	surface.SetTexture(crosshairScoped)
	local sizeX = ScrW() *0.16
	local sizeY = ScrH() *0.2133
	surface.DrawTexturedRect(ScrW() *0.5 -sizeX *0.5, ScrH() *0.5 -sizeY *0.5, sizeX, sizeY)
end	