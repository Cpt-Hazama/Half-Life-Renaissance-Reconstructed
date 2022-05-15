SWEP.HoldType = "ar2"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 4
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = false
	SWEP.NPCFireRate = 0.14
	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = {"weapons/m4/hks1.wav", "weapons/m4/hks2.wav", "weapons/m4/hks3.wav"}
	SWEP.tblSounds["Secondary"] = {"weapons/m4/glauncher.wav", "weapons/m4/glauncher2.wav"}
	SWEP.tblSounds["ReloadA"] = "weapons/m4/cliprelease1.wav"
	SWEP.tblSounds["ReloadB"] = "weapons/m4/clipinsert1.wav"
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"
SWEP.InWater = false

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_9mmar.mdl"
SWEP.WorldModel = "models/weapons/half-life/w_9mmar.mdl"

SWEP.Primary.Recoil = 0
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.065
SWEP.Primary.Delay = 0.12

SWEP.Primary.Damage = "sk_plr_dmg_45mm"
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9mm"
SWEP.Primary.AmmoSize = 250
SWEP.Primary.AmmoPickup	= 250

SWEP.Secondary.Recoil = -12
SWEP.Secondary.Cone	= 0.065
SWEP.Secondary.ClipSize = 10
SWEP.Secondary.DefaultClip = 10
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "m4grenade"
SWEP.Secondary.AmmoSize = 10
SWEP.Secondary.Delay = 1.1
SWEP.Secondary.AmmoPickup	= 10

SWEP.ReloadDelay = 0.8

function SWEP:SecondaryAttack()
	if self:GetAmmoSecondary() <= 0 then return end
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Secondary.Delay)
	self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:NextIdle(self:SequenceDuration())
	self:PlayThirdPersonAnim()
	if CLIENT then return end
	self:slvPlaySound("Secondary")
	self:AddAmmoSecondary(-1)
	self.Owner:ViewPunch(Angle(self.Secondary.Recoil,0,0))
	
	local ang = self.Owner:GetAimVector():Angle()
	local entGrenade = ents.Create("obj_grenade")
	entGrenade:SetPos(self.Owner:GetShootPos() +ang:Forward() *10 +ang:Right() *5 +ang:Up() *-12)
	entGrenade:SetAngles(ang)
	entGrenade:SetEntityOwner(self.Owner)
	entGrenade:Spawn()
	entGrenade:Activate()
	local phys = entGrenade:GetPhysicsObject()
	if IsValid(phys) then
		phys:ApplyForceCenter(ang:Forward() *550 +ang:Up() *70)
		phys:AddAngleVelocity(Vector(0,600,0))
	end
end