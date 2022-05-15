
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	self:SetMaterial("invis")
	self:SetMoveCollide(3)
	self:DrawShadow(false)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	self:slvSetHealth(1)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(1)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
	end
	
	self.delayRemove = CurTime() +8
	self.nextRandDir = CurTime() +math.Rand(0,0.4)
	if self:GetScale() > 1 then self.deploy = CurTime() +0.2 end
end

function ENT:SetScale(nScale)
	self:SetNetworkedInt("scale", nScale)
end

function ENT:GetScale()
	return self:GetNetworkedInt("scale")
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:OnRemove()
end

function ENT:Think()
	if CurTime() >= self.nextRandDir then
		self.nextRandDir = CurTime() +math.Rand(0,0.4)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			local dir = self:GetVelocity():GetNormal()
			dir = (dir:Angle() +Angle(math.Rand(-2,2), math.Rand(-4,4),0)):Forward()
			phys:ApplyForceCenter(dir *((8 /self:GetScale()) *100 +400))
		end
	end
	if self.deploy && CurTime() >= self.deploy then
		if IsValid(self.entOwner) then
			local pos = self:GetPos()
			for _, ent in pairs(ents.FindInSphere(pos, 600)) do
				if ent:IsNPC() || ent:IsPlayer() then
					local disp = self.entOwner:Disposition(ent)
					if disp == D_HT || disp == D_FR then
						self.deploy = nil
						local angles = {Angle(0,-5,0),Angle(0,0,0),Angle(0,5,0)}
						for _, ang in pairs(angles) do
							local entProjectile = ents.Create("obj_kingpin_projectile_energy")
							entProjectile:SetEntityOwner(self.entOwner)
							entProjectile:SetPos(self:GetPos())
							entProjectile:SetAngles(self:GetAngles())
							entProjectile:NoCollide(self)
							entProjectile:SetScale(self:GetScale() *0.5)
							entProjectile:Spawn()
							entProjectile:Activate()
							local phys = entProjectile:GetPhysicsObject()
							if IsValid(phys) then
								local dir = (self:GetVelocity():Angle() +ang):Forward()
								local angDir = dir:Angle()
								local ang = (ent:GetCenter() -self:GetPos()):Angle() -angDir
								ang.p = math.Clamp(math.NormalizeAngle(ang.p), -10, 10)
								ang.y = math.Clamp(math.NormalizeAngle(ang.y), -10, 10)
								ang = angDir +ang
								dir = ang:Forward()
								phys:ApplyForceCenter(dir *((8 /entProjectile:GetScale()) *100 +400))
							end
						end
						self:Remove()
						break
					end
				end
			end
		end
	end
	if CurTime() < self.delayRemove then return end
	self:Remove()
end

function ENT:PhysicsCollide(data, physobj)
	local ent = data.HitEntity
	if IsValid(ent) && (ent:IsPlayer() || ent:IsNPC()) then
		if !IsValid(self.entOwner) || self.entOwner:Disposition(ent) <= 2 then
			if ent:GetClass() != "npc_turret_floor" then
				local dmg = DamageInfo()
				dmg:SetDamage(self:GetScale() *4)
				dmg:SetDamageType(DMG_GENERIC)
				dmg:SetAttacker(IsValid(self.entOwner) && self.entOwner || self)
				dmg:SetInflictor(self)
				dmg:SetDamagePosition(data.HitPos)
				ent:TakeDamageInfo(dmg)
			elseif !ent.bSelfDestruct then
				ent:GetPhysicsObject():ApplyForceCenter(self:GetVelocity():GetNormal() *10000)
				ent:Fire("selfdestruct", "", 0)
				ent.bSelfDestruct = true
			end
		end
	end
	self:EmitSound("npc/controller/electro4.wav", 75, 100)
	self:Remove()
	return true
end

