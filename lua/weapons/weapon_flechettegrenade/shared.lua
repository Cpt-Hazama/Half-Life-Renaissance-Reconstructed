SWEP.HoldType = "grenade"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 4
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.tblSounds = {}
end

SWEP.Base = "weapon_slv_base"

if ( IsMounted( "ep2" ) ) then
	SWEP.Spawnable = true
	SWEP.AdminSpawanable = true
else 
	SWEP.Spawnable = false
	SWEP.AdminSpawnable = false
end

SWEP.ViewModel = "models/weapons/v_flcnade.mdl"
SWEP.WorldModel = "models/flechette_grenade.mdl"
SWEP.Category		= "SLVBase"

SWEP.Primary.Automatic = false
SWEP.Primary.SingleClip = true
SWEP.Primary.Ammo = "flechetteGrenade"
SWEP.Primary.Delay = 0.8
SWEP.Primary.AmmoSize = 10
SWEP.Primary.AmmoPickup	= 10
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10

SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1

function SWEP:PrimaryAttack()
	if self:GetAmmoPrimary() <= 0 then return end
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
	self:NextIdle(-1)
	self.nextDraw = nil
	self.bInAttack = true
	self.iAttack = 1
	self.attackStart = CurTime() +0.6
end

function SWEP:SecondaryAttack()
	if self:GetAmmoPrimary() <= 0 then return end
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SendWeaponAnim(ACT_VM_PULLBACK_LOW)
	self:NextIdle(-1)
	self.nextDraw = nil
	self.bInAttack = true
	self.iAttack = 2
	self.attackStart = CurTime() +0.6
end

function SWEP:OnHolster()
	self.bInAttack = nil
	self.attackStart = nil
	self.nextDraw = nil
	self.iAttack = nil
end

function SWEP:OnThink()
	if self.nextDraw && CurTime() >= self.nextDraw then
		self.nextDraw = nil
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self:NextIdle(self:SequenceDuration())
	end
	if !self.bInAttack || (self.iAttack == 1 && self.Owner:KeyDown(IN_ATTACK)) || (self.iAttack == 2 && self.Owner:KeyDown(IN_ATTACK2)) || CurTime() < self.attackStart then return end
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	local act
	if self.iAttack == 1 then act = ACT_VM_THROW
	else act = ACT_VM_SECONDARYATTACK end
	self.Weapon:SendWeaponAnim(act)
	self.nextDraw = CurTime() +self:SequenceDuration()
	self.bInAttack = false
	
	self:PlayThirdPersonAnim()
	if CLIENT then
		self.iAttack = nil
		return
	end
	local ang = self.Owner:GetAimVector():Angle()
	local entGrenade = ents.Create("obj_grenade_flechette")
	entGrenade:SetPos(self.Owner:GetShootPos() +ang:Forward() *30 +ang:Right() *10 +ang:Up() *-15)
	entGrenade:SetEntityOwner(self.Owner)
	entGrenade:Spawn()
	entGrenade:Activate()
	
	local phys = entGrenade:GetPhysicsObject()
	if IsValid(phys) then
		local vel
		if self.iAttack == 1 then
			vel = ang:Forward() *1000 +ang:Up() *100
		else
			if !self.Owner:Crouching() then
				vel = ang:Forward() *400 +ang:Up() *200
			else
				vel = ang:Forward() *800 +ang:Up() *50
			end
		end
		phys:ApplyForceCenter(vel)
	end
	self.Weapon:AddAmmoPrimary(-1)
	self.iAttack = nil
end	
