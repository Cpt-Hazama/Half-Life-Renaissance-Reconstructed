SWEP.HoldType = "shotgun"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 2
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 0.8
	SWEP.tblSounds = {}
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase"
SWEP.InWater = false

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_fire_extinguisher.mdl"
SWEP.WorldModel = "models/weapons/w_fire_extinguisher.mdl"

SWEP.Primary.Recoil = 0
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.01
SWEP.Primary.Delay = 0.6

SWEP.Primary.SingleClip = true
SWEP.Primary.Damage = 0
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "exting_agent"
SWEP.Primary.AmmoSize = 100

SWEP.Secondary.Recoil = 2.5
SWEP.Secondary.Cone	= 0.065
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.AmmoSize = -1
SWEP.Secondary.Delay = 0.5

SWEP.ReloadDelay = 1.2

function SWEP:CustomIdle()
	local act
	if self.bInAttack then act = ACT_VM_RECOIL1
	else act = ACT_VM_IDLE end
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self:SequenceDuration())
end

function SWEP:EndAttack()
	if !self.bInAttack then return end
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.bInAttack = false
	self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:NextIdle(self:SequenceDuration())
	if CLIENT then return end
	self.Owner:EmitSound("weapons/extinguisher/release1.wav", 75, 100)
	local rp = RecipientFilter()
	rp:AddAllPlayers()
	umsg.Start("fireextinguisher_effectstop", rp)
		umsg.Entity(self.Owner)
	umsg.End()
	if self.cspLoop then self.cspLoop:Stop() end
end

function SWEP:OnOwnerDeath()
	self:EndAttack()
end

function SWEP:OnReload()
	self:EndAttack()
	self:NextIdle(self:SequenceDuration())
	self.Weapon:SetNextSecondaryFire(self.Weapon.nextIdle)
	self.Weapon:SetNextPrimaryFire(self.Weapon.nextIdle)
end

function SWEP:OnThink()
	if !self.bInAttack then return end
	if CurTime() < self.nextDrain then return end
	if !IsValid(self.Owner) || (!self.Owner:KeyDown(IN_ATTACK) && !self.Owner:KeyDown(IN_ATTACK2)) || self:GetAmmoPrimary() <= 0 then self:EndAttack(); return end
	self.nextDrain = CurTime() +0.125
	self:PlayThirdPersonAnim()
	if CLIENT then return end
	self.Weapon:AddAmmoPrimary(-1)
	if self.Owner:WaterLevel() == 3 then return end
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector():Angle()
	
	
	for k, v in pairs(ents.FindInSphere(pos, 400)) do
		if v != self.Owner && !util.TraceLine({start = pos, endpos = v:GetPos() +v:OBBCenter(), mask = MASK_NPCWORLDSTATIC}).Hit && (!v:IsPlayer() || !v:SLVIsPossessing()) then
			local posTgt = v:NearestPoint(pos)
			if v:slvIsOnFire() then v:slvExtinguish()
			elseif v:GetClass() == "env_fire" then v:Fire("slvExtinguish", "0", 0) end
		end
	end
end

function SWEP:PrimaryAttack()
	if self.bInAttack then self:EndAttack(); return end
	if !self:CanPrimaryAttack() || self:GetAmmoPrimary() <= 0 then return end
	self.bInAttack = true
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:NextIdle(self:SequenceDuration())
	self.nextDrain = 0
	if SERVER then
		self.cspLoop = CreateSound(self.Owner,"weapons/extinguisher/fire1.wav")
		self.cspLoop:Play()
		
		local rp = RecipientFilter()
		rp:AddAllPlayers()
		umsg.Start("fireextinguisher_effectstart", rp)
			umsg.Entity(self)
		umsg.End()
	end
end

function SWEP:OnRemove()
	self:EndAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:OnHolster()
	self:EndAttack()
end

