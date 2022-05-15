SWEP.HoldType = "shotgun"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 5
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 3.5
	SWEP.tblSounds = {}
	SWEP.tblSounds["Off"] = "weapons/egon/egon_off1.wav"
	
	local function CreateWorldModel(self)
		local entModel = ents.Create("prop_dynamic_override")
		entModel:SetModel("models/weapons/half-life/w_egon.mdl")
		entModel:SetPos(self:GetPos())
		entModel:SetAngles(self:GetAngles())
		entModel:SetParent(self)
		entModel:Spawn()
		entModel:Activate()
		self.entModel = entModel
	end
	
	function SWEP:PostInit()
		if IsValid(self.Owner) then return end
		CreateWorldModel(self)
		self:SetColor(255,255,255,0)
		self:DrawShadow(false)
	end
	
	function SWEP:OnRemove()
		if IsValid(self.entModel) then
			self.entModel:Remove()
		end
	end
	
	function SWEP:OnEquip()
		if IsValid(self.entModel) then
			self.entModel:Remove()
			self:SetColor(255,255,255,255)
			self:DrawShadow(true)
		end
	end
	
	function SWEP:OnDrop()
		self:Drop()
		CreateWorldModel(self)
	end
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_egon.mdl"
SWEP.WorldModel = "models/weapons/half-life/p_egon.mdl"
SWEP.InWater = false

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = false
SWEP.Primary.SingleClip = true
SWEP.Primary.Ammo = "uranium"
SWEP.Primary.AmmoSize = 100
SWEP.Primary.AmmoPickup	= 100
SWEP.Primary.Delay = 0.2

SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.AmmoSize = -1
SWEP.Secondary.Delay = 1

function SWEP:CustomIdle()
	local act
	if self.bInAttack then act = ACT_VM_PRIMARYATTACK
	else act = ACT_VM_IDLE end
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self:SequenceDuration())
end

function SWEP:EndAttack()
	if !self.bInAttack then return end
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.bInAttack = false
	self:NextIdle(0)
	if CLIENT then return end
	if IsValid(self.entBeam) then self.entBeam:Remove() end
	self:slvPlaySound("Off")
	if self.cspWindup then self.cspWindup:Stop() end
end

function SWEP:OnThink()
	if !self.bInAttack then return end
	if CurTime() < self.nextDrain then return end
	if !IsValid(self.Owner) || (!self.Owner:KeyDown(IN_ATTACK) && !self.Owner:KeyDown(IN_ATTACK2)) || self:GetAmmoPrimary() <= 0 then self:EndAttack(); return end
	self.nextDrain = CurTime() +0.1
	self:PlayThirdPersonAnim()
	if CLIENT then return end
	local tr = util.TraceLine(util.GetPlayerTrace(self.Owner))
	util.BlastDamage(self, self.Owner, tr.HitPos, 80, 14)
	self.Weapon:AddAmmoPrimary(-1)
end

function SWEP:PrimaryAttack()
	if self.bInAttack then self:EndAttack(); return end
	if self:GetAmmoPrimary() <= 0 then return end
	self.bInAttack = true
	self:NextIdle(0)
	self.nextDrain = 0
	if SERVER then
		self.cspWindup = CreateSound(self.Owner,"weapons/egon/egon_run1.wav")
		self.cspWindup:Play()
		self:slvPlaySound("WindUp")
		local entBeam = ents.Create("obj_beam_egon")
		entBeam:SetPos(self.Owner:GetShootPos())
		entBeam:Spawn()
		entBeam:SetParent(self.Owner)
		entBeam:SetOwner(self.Owner)
		self.entBeam = entBeam
	end
end

function SWEP:OnRemove()
	self:EndAttack()
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end

function SWEP:OnHolster()
	self:EndAttack()
end

