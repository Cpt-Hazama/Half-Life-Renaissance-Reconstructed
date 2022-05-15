SWEP.HoldType = "ar2"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 4
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = false
	SWEP.NPCFireRate = 0.3
	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = {"weapons/hornetgun/ag_fire1.wav", "weapons/hornetgun/ag_fire2.wav", "weapons/hornetgun/ag_fire3.wav"}
	SWEP.nextRecharge = 0
	
	function SWEP:OnThink()
		if self:GetAmmoPrimary() < 8 && CurTime() >= self.nextRecharge then
			self.nextRecharge = CurTime() +0.5
			self:AddAmmoPrimary(1)
		end
	end
	
	function SWEP:OnDeploy()
		self.nextRecharge = CurTime() +1
	end
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_hgun.mdl"
SWEP.WorldModel = "models/weapons/half-life/w_hgun.mdl"

SWEP.Primary.Recoil = 2.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.08
SWEP.Primary.Delay = 0.22

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = true
SWEP.Primary.SingleClip = true
SWEP.Primary.Ammo = "hornet"
SWEP.Primary.AmmoSize = 8
SWEP.Primary.AmmoPickup	= 8

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.Secondary.Delay = 0.1

function SWEP:PrimaryAttack(ShootPos, ShootDir)
	self:Attack(ShootPos, ShootDir, true)
end

function SWEP:Attack(ShootPos, ShootDir, bHoming)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	if self:GetAmmoPrimary() <= 0 then return end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	if self.Owner:IsPlayer() then
		self:NextIdle(self.Primary.Delay)
	end
	self:PlayThirdPersonAnim()
	if CLIENT then return end
	self:AddAmmoPrimary(-1)
	self:slvPlaySound("Primary")
	
	local ang = self.Owner:GetAimVector():Angle()
	local entHornet = ents.Create("monster_hornet")
	entHornet:SetPos(ShootPos || self.Owner:GetShootPos() +ang:Forward() *-5 +ang:Right() *3 +ang:Up() *-5)
	entHornet:SetAngles(self.Owner:GetAimVector():Angle())
	entHornet:SetSpeed(1000)
	entHornet:SetEntityOwner(self.Owner)
	entHornet:SetHoming(bHoming)
	entHornet:SetPhysicsAttacker(self.Owner)
	entHornet:Spawn()
	entHornet:Activate()
	
	local phys = entHornet:GetPhysicsObject()
	if IsValid(phys) then
		phys:ApplyForceCenter((ShootDir || ang:Forward()) *1000)
	end
	if !self.Owner:IsPlayer() then return end
	self.nextRecharge = CurTime() +1
end

function SWEP:SecondaryAttack(ShootPos, ShootDir)
	self:Attack(ShootPos, ShootDir, false)
end

