SWEP.HoldType = "crossbow"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 4
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 1.6
	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = "weapons/crossbow/xbow_fire1.wav"
	SWEP.tblSounds["ReloadB"] = "weapons/crossbow/xbow_reload1.wav"
	
	function SWEP:OnReload()
		self:UnScope()
	end
		
	function SWEP:Scope()
		if self.bScoped then return end
		self.iFOV = self.Owner:GetFOV()
		self.Owner:SetFOV(20,0)
		self.bScoped = true
		self.Owner:DrawViewModel(false)
	end

	function SWEP:UnScope()
		if !self.bScoped then return end
		self.Owner:SetFOV(self.iFOV || 75,0)
		self.bScoped = false
		self.Owner:DrawViewModel(true)
	end
		
	function SWEP:ToggleScope()
		if self.bScoped then
			self:UnScope()
		else
			self:Scope()
		end
	end
	
	function SWEP:OnHolster()
		self:UnScope()
	end
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"
SWEP.InWater = false

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_crossbow.mdl"
SWEP.WorldModel = "models/weapons/half-life/w_crossbow.mdl"

SWEP.Primary.Recoil = -10
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0
SWEP.Primary.Delay = 0.8

SWEP.Primary.Damage = "sk_plr_dmg_crossbow"
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "XBowBolt"
SWEP.Primary.AmmoSize = 36

SWEP.Secondary.Recoil = 2.5
SWEP.Secondary.Cone	= 0.065
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.AmmoSize = -1
SWEP.Secondary.Delay = 0.5

SWEP.ReloadDelay = 2.2

function SWEP:PrimaryAttack(ShootPos, ShootDir)
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	
	if !self:CanPrimaryAttack() then self:Reload(); return end
	if SERVER then self:slvPlaySound("Primary") end

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:NextIdle(self:SequenceDuration())
	self.Weapon.nextReload = nil
	self:PlayThirdPersonAnim()
	if game.SinglePlayer() || CLIENT then
		self:SetNetworkedFloat("LastShootTime", CurTime())
		if CLIENT then return end
	end
	if self.bScoped then
		local tr = util.TraceLine(util.GetPlayerTrace(self.Owner))
		local effectdata = EffectData()
		effectdata:SetStart(tr.HitPos)
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetScale(1)
		util.Effect("cball_explode", effectdata)
		util.BlastDamage(self, self.Owner, tr.HitPos, 30, 65)
		if tr.Entity:IsNPC() || tr.Entity:IsPlayer() then
			sSound = "weapons/crossbow/xbow_hitbod" .. math.random(1,2) .. ".wav"
		else
			sSound = "weapons/crossbow/xbow_hit1.wav"
			if !IsValid(tr.Entity) || tr.Entity:GetPhysicsObjectCount() <= 1 then
				local entBolt = ents.Create("obj_crossbow_bolt")
				entBolt:SetPos(tr.HitPos -tr.Normal *10)
				if !tr.Entity.HitWorld && IsValid(tr.Entity) then entBolt:SetParentEntity(tr.Entity) end
				entBolt.bHit = true
				entBolt:SetRemoveDelay(60)
				entBolt:Spawn()
				entBolt:Activate()
				entBolt:SetAngles(tr.Normal:Angle())
				entBolt:SetNotSolid(true)
				local phys = entBolt:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
				end
			end
		end
		sound.Play(sSound, tr.HitPos, 100, 100)
	else
		local entBolt = ents.Create("obj_crossbow_bolt")
		entBolt:SetEntityOwner(self.Owner)
		local ang = self.Owner:GetAimVector():Angle()
		local pos = ShootPos || self.Owner:GetShootPos() +ang:Right() *2 +ang:Up() *-3
		entBolt:SetPos(pos)
		entBolt:SetExplosive(true)
		entBolt:SetEntityOwner(self.Owner)
		entBolt:Spawn()
		entBolt:Activate()
		entBolt:SetAngles(ang)
	end
	
	if !self.Owner:IsPlayer() then return end
	self:AddClip1(-1)
	self.Owner:ViewPunch(Angle(-3,0,0))
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +0.1)
	if CLIENT then return end
	self:ToggleScope()
end
