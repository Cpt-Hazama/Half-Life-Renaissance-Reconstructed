SWEP.HoldType = "grenade"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 2
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 2
	SWEP.tblSounds = {}
	SWEP.tblSounds["Deploy"] = "npc/chumtoad/toad_deploy1.wav"
	
	function SWEP:OnDrop()
		self:Drop()
		local iSkin
		if IsValid(self.Owner) then iSkin = self.Owner:GetViewModel()
		else iSkin = 0 end
		local ent = ents.Create("npc_chumtoad")
		ent:SetPos(self:GetPos())
		ent:SetAngles(Angle(0,self:GetAngles().y,0))
		ent:SetSkin(iSkin)
		ent:Spawn()
		ent:Activate()
		self:Remove()
	end
	
	function SWEP:PostInit()
		if IsValid(self.Owner) then return end
		self:OnDrop()
	end
	
	function SWEP:OnInitialize()
		self.tblChumtoads = {}
	end
	
	function SWEP:OnDeploy()
		if self.tblChumtoads[1] then self.Owner:GetViewModel():SetSkin(self.tblChumtoads[1]); self:SetSkin(self.tblChumtoads[1]) end
		self:slvPlaySound("Deploy", nil, true)
	end
	
	function SWEP:OnThink()
		if !self.delayChangeSkin || CurTime() < self.delayChangeSkin then return end
		self.delayChangeSkin = nil
		if self.tblChumtoads[1] then self.Owner:GetViewModel():SetSkin(self.tblChumtoads[1]); self:SetSkin(self.tblChumtoads[1]) end
	end
end

SWEP.Base = "weapon_slv_base"

SWEP.ViewModel = "models/weapons/half-life/v_chumtoad.mdl"
SWEP.WorldModel = "models/weapons/half-life/p_chumtoad.mdl"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Primary.Automatic = false
SWEP.Primary.SingleClip = true
SWEP.Primary.Ammo = "chumtoad"
SWEP.Primary.Delay = 0.45
SWEP.Primary.AmmoSize = 5
SWEP.Primary.AmmoPickup	= 5
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5

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
	if self.tblChumtoads[2] then
		self.delayChangeSkin = CurTime() +0.26
	end
	self:slvPlaySound("Deploy")
	local ang = self.Owner:GetAimVector():Angle()
	
	local iSkin = self.tblChumtoads[1] || 0
	local entChumtoad = ents.Create("npc_chumtoad")
	entChumtoad:SetAngles(Angle(0,ang.y,0))
	entChumtoad:SetPos(self.Owner:GetShootPos() +ang:Forward() *30 +ang:Up() *-15)
	entChumtoad:NoCollide(self.Owner)
	entChumtoad:SetOwner(self.Owner)
	entChumtoad:Spawn()
	entChumtoad:Activate()
	entChumtoad:SetSkin(iSkin)
	entChumtoad:SetVelocity(ang:Forward() *300 +ang:Up() *80)
	timer.Simple(0.2, function() if IsValid(self.Owner) && IsValid(entChumtoad) then entChumtoad:Collide(self.Owner) end end)
	self.Weapon:AddAmmoPrimary(-1)
	table.remove(self.tblChumtoads, 1)
end

function SWEP:OnHolster()
	self.bThrown = nil
	if CLIENT then return end
	self.delayChangeSkin = nil
end

function SWEP:SecondaryAttack()
end
