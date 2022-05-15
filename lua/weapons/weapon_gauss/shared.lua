SWEP.HoldType = "crossbow"
if SERVER then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.Weight = 5
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	SWEP.NPCFireRate = 0.35
	SWEP.tblSounds = {}
	SWEP.tblSounds["Primary"] = "weapons/gauss/gauss2.wav"
	SWEP.tblSounds["Discharge"] = {"weapons/gauss/electro4.wav", "weapons/gauss/electro5.wav"}
	
	function SWEP:OnInitialize()
		self.cspSpin = CreateSound(self, "ambience/pulsemachine.wav")
	end
end

if CLIENT then
	SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_slv_base"
SWEP.Category		= "SLVBase - Half-Life Renaissance"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/half-life/v_gauss.mdl"
SWEP.WorldModel = "models/weapons/half-life/w_gauss.mdl"
SWEP.InWater = false

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.SingleClip = true
SWEP.Primary.Ammo = "uranium"
SWEP.Primary.AmmoSize = 100
SWEP.Primary.AmmoPickup	= 100
SWEP.Primary.Delay = 0.2

SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.AmmoSize = -1
SWEP.Secondary.Delay = 0.4

function SWEP:CustomIdle()
	local act
	if self.bInAttack then act = ACT_VM_PULLBACK
	else act = ACT_VM_IDLE end
	self.Weapon:SendWeaponAnim(act)
	self:NextIdle(self:SequenceDuration())
end

function SWEP:OnThink()
	if !self.bInAttack then return end
	if (!self.Owner:KeyDown(IN_ATTACK2) && self.iCharged > 2) || self:GetAmmoPrimary() <= 0 then
		self.Weapon:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
		self.Weapon:SetNextPrimaryFire(CurTime() +self.Secondary.Delay)
		self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		self:NextIdle(self:SequenceDuration())
		if SERVER then
			if self.Owner:IsPlayer() then
				self.Owner:ViewPunch(Angle(math.Rand(-6,-8), 0, 0))
				self.Owner:SetLocalVelocity(self.Owner:GetForward() *-1 *(self.iCharged *82))
			end
			self:CreateBeam(true)
		end
		self.bInAttack = nil
		return
	end
	if CurTime() < self.nextCharge || self.iCharged >= 13 then
		if CurTime() >= self.attackStart +13 then
			self.nextCharge = nil
			self.attackStart = nil
			self.bInAttack = nil
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self:PlayThirdPersonAnim()
			if CLIENT then return end
			self:slvPlaySound("Discharge")
			self.Owner:TakeDamage(50, self, self.Owner)
			self.cspSpin:Stop()
		end
		return
	end
	if SERVER then
		if (self.iCharged % 1) == 0 then
			self.Weapon:AddAmmoPrimary(-1)
		end
		self.cspSpin:ChangePitch(110 +self.iCharged *11.15,0)
	end
	self.iCharged = self.iCharged +0.25
	self.nextCharge = CurTime() +0.1
end

function SWEP:CreateBeam(bCharged, ShootPos, ShootDir)
	if bCharged && !self.bInAttack then return end
	local tr
	if self.Owner:IsPlayer() then tr = util.TraceLine(util.GetPlayerTrace(self.Owner))
	else tr = util.TraceLine({start = ShootPos, endpos = ShootPos +ShootDir *32768, filter = self.Owner}) end
	self:slvPlaySound("Primary")
	local posShoot = self.Owner:GetShootPos()
	local entBeam = ents.Create("obj_beam_gauss")
	if bCharged then entBeam:SetScale(3); self.cspSpin:Stop(); self.nextCharge = nil; self.attackStart = nil end
	entBeam:SetPos(posShoot)
	entBeam:AddPosition(tr.HitPos)
	local iRichochet = 3
	local flDist = posShoot:Distance(tr.HitPos)
	while tr.Normal:Dot(tr.HitNormal) *-1 <= 0.5 && iRichochet > 0 do
		local ang = tr.Normal:Angle()  
		ang:RotateAroundAxis(tr.HitNormal,180)   
		
		local posLast = tr.HitPos
		tr = util.QuickTrace(tr.HitPos, (ang:Forward() *-1) *32768)
		flDist = flDist +posLast:Distance(tr.HitPos)
		if flDist > 5000 then break end
		entBeam:AddPosition(tr.HitPos)
		iRichochet = iRichochet -1
	end
	local iDmg
	if bCharged then iDmg = (200 /12) *self.iCharged
	else iDmg = 20 end
	util.BlastDamage(self, self.Owner, tr.HitPos, 80, iDmg)
	entBeam:Spawn()
	entBeam:SetParent(self.Owner)
	entBeam:SetOwner(self.Owner)
end

function SWEP:PrimaryAttack(ShootPos, ShootDir)
	if self:GetAmmoPrimary() <= 1 || self.bInAttack then return end
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:NextIdle(self:SequenceDuration())
	self:PlayThirdPersonAnim()
	if CLIENT then return end
	self.Weapon:AddAmmoPrimary(-2)
	self.Weapon:CreateBeam(false, ShootPos, ShootDir)
	if self.Owner:IsPlayer() then self.Owner:ViewPunch(Angle(math.Rand(-0.12,-0.6), math.Rand(-0.6,0.6), 0)) end
end

function SWEP:OnRemove()
	if !self.cspSpin then return end
	self.cspSpin:Stop()
end

function SWEP:SecondaryAttack()
	if self:GetAmmoPrimary() <= 1 || self.bInAttack then return end
	self.Weapon:SendWeaponAnim(ACT_VM_PULLBACK_LOW)
	self:NextIdle(self:SequenceDuration() -0.1)
	self.bInAttack = true
	self.nextCharge = CurTime() +0.15
	self.iCharged = 0
	self.attackStart = CurTime()
	if CLIENT then return end
	self.cspSpin:Play()
end

function SWEP:OnHolster()
	if self.cspSpin then
		self.cspSpin:Stop()
		self.nextCharge = nil
		self.attackStart = nil
		self.bInAttack = nil
	end
	//self:FireChargedBeam()
end

