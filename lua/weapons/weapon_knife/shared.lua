SWEP.HoldType = "knife"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 1
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = true
	SWEP.tblSounds = {}
	SWEP.tblSounds["Hit"] = {"weapons/knife/knife_hit_wall1.wav", "weapons/knife/knife_hit_wall2.wav"}
	SWEP.tblSounds["HitBod"] = {"weapons/knife/knife_hit_flesh1.wav", "weapons/knife/knife_hit_flesh2.wav"}
	SWEP.tblSounds["Miss"] = {"weapons/knife/knife1.wav", "weapons/knife/knife2.wav", "weapons/knife/knife3.wav"}
end

SWEP.Base = "weapon_slv_base"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/opfor/v_knife.mdl"
SWEP.WorldModel = "models/weapons/opfor/w_knife.mdl"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.6

SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1

function SWEP:PrimaryAttack()
	local iDelay
	local iDmg = 25
	local iDist = 50
	local iHit, tr = self:DoMeleeDamage(iDist, iDmg)
	local act
	if iHit == 0 then
		act = ACT_VM_MISSCENTER
		if SERVER then self:slvPlaySound("Miss") end
		iDelay = 0.5
	else
		if SERVER then
			if iHit == 1 then
				self:slvPlaySound("HitBod")
			else
				self:CreateDecal(tr)
				self:slvPlaySound("Hit")
			end
		end
		act = ACT_VM_HITCENTER
		iDelay = 0.3
	end
	self.Weapon:SendWeaponAnim(act)
	self.Weapon:SetNextSecondaryFire(CurTime() +iDelay)
	self.Weapon:SetNextPrimaryFire(CurTime() +iDelay)
	self:NextIdle(self.Primary.Delay)
	
	self:PlayThirdPersonAnim()
end

function SWEP:OnInitialize()
	self.Weapon._InternalHoldType = self.HoldType
end

function SWEP:SecondaryAttack()
end

function SWEP:OnThink()
end	
