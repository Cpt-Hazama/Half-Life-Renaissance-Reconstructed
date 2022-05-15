include('shared.lua')

language.Add("weapon_gauss", "Gauss Cannon")

SWEP.PrintName = "Tau Cannon"
SWEP.Slot = 3
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 75
SWEP.ViewModelFlip = false

SWEP.WepSelectIcon = surface.GetTextureID("HUD/weapons/weapon_gauss") 
SWEP.BounceWeaponIcon = false 

function SWEP:HUDShouldDraw(element)
	if self.bInAttack && element == "CHudWeaponSelection" then return false end
	return true
end