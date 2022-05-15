SWEP.HoldType = "grenade"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 3
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 0.8
	SWEP.tblSounds = {}
	SWEP.tblSounds["Deploy"] = {"npc/snark/sqk_hunt1.wav", "npc/snark/sqk_hunt2.wav", "npc/snark/sqk_hunt3.wav"}
	
	function SWEP:OnDeploy()
		self:slvPlaySound("Deploy", nil, true)
	end
	
	local function CreateWorldModel(self)
		local entModel = ents.Create("prop_dynamic_override")
		entModel:SetModel("models/weapons/half-life/w_sqknest.mdl")
		entModel:SetPos(self:GetPos())
		entModel:SetAngles(self:GetAngles())
		entModel:SetParent(self)
		entModel:Spawn()
		entModel:Activate()
		entModel:Fire("SetAnimation", "Idle", 0)
		entModel:Fire("SetDefaultAnimation", "Idle", 0)
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

SWEP.Base = "weapon_slv_base"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_squeak.mdl"
SWEP.WorldModel = "models/weapons/half-life/p_snark.mdl"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Primary.Automatic = false
SWEP.Primary.SingleClip = true
SWEP.Primary.Ammo = "snark"
SWEP.Primary.Delay = 0.3
SWEP.Primary.AmmoSize = 10
SWEP.Primary.AmmoPickup	= 10
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10

SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1

function SWEP:CustomIdle()
	local act
	if self:GetAmmoPrimary() == 0 then act = ACT_VM_IDLE_EMPTY
	elseif self.bThrown then act = ACT_VM_DRAW; self.bThrown = nil
	else act = ACT_VM_IDLE end
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self:SequenceDuration())
end

function SWEP:Deploy()
	if self:GetAmmoPrimary() == 0 then self.Weapon:SendWeaponAnim(ACT_VM_IDLE_EMPTY); self:NextIdle(0); return true end
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self:NextIdle(self:SequenceDuration())
	self.Weapon:SetNextSecondaryFire(self.Weapon.nextIdle)
	self.Weapon:SetNextPrimaryFire(self.Weapon.nextIdle)
	if self.Weapon.OnDeploy then self.Weapon:OnDeploy() end
	return true
end

function SWEP:PrimaryAttack()
	if self:GetAmmoPrimary() <= 0 then return end
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self:NextIdle(self.Primary.Delay)
	self.bThrown = true
	self:PlayThirdPersonAnim()
	if CLIENT then return end
	self:slvPlaySound("Deploy")
	local ang = self.Owner:GetAimVector():Angle()
	local entSnark = ents.Create("monster_alien_snark")
	entSnark:SetAngles(Angle(0,ang.y,0))
	entSnark:SetPos(self.Owner:GetShootPos() +ang:Forward() *30 +ang:Up() *-15)
	entSnark:NoCollide(self.Owner)
	entSnark:SetOwner(self.Owner)
	entSnark:SetEntityOwner(self.Owner)
	entSnark:Spawn()
	entSnark:Activate()
	entSnark:SetVelocity(ang:Forward() *300 +ang:Up() *80)
	timer.Simple(0.2, function() if IsValid(self.Owner) && IsValid(entSnark) then entSnark:Collide(self.Owner) end end)
	self.Weapon:AddAmmoPrimary(-1)
end

function SWEP:OnHolster()
	self.bThrown = nil
end

function SWEP:SecondaryAttack()
end

function SWEP:OnThink()
end	
