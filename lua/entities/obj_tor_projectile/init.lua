
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

AccessorFunc(ENT, "bDepleted", "Depleted", FORCE_BOOL)
function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	self:SetMoveCollide(3)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	self:slvSetHealth(1)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(1)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
	end
	
	self.cspSound = CreateSound( self, "ambient/energy/electric_loop.wav" )
	self.cspSound:Play()
	
	ParticleEffectAttach(!self:GetDepleted() && "tor_projectile" || "tor_projectile_blue", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	
	self.fSpeed = self.fSpeed || 100
	self.delayRemove = CurTime() +8
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:SetSpeed(fSpeed)
	self.fSpeed = fSpeed
end

function ENT:SetEnemy(entEnemy)
	self.entEnemy = entEnemy
end

function ENT:OnRemove()
	self.cspSound:Stop()
end

function ENT:Think()
	if CurTime() >= self.delayRemove then self:Remove(); return end
	if IsValid(self.entEnemy) then
		local pos = self.entEnemy:GetCenter() +self.entEnemy:GetVelocity()
		self:GetPhysicsObject():ApplyForceCenter((pos - self:GetPos()):GetNormal() *self.fSpeed)
	end
end

function ENT:PhysicsCollide(data, physobj)
	local ent = data.HitEntity
	if IsValid(ent) && (ent:IsPlayer() || ent:IsNPC()) then
		if !IsValid(self.entOwner) || self.entOwner:Disposition(ent) <= 2 then
			if ent:GetClass() != "npc_turret_floor" then
				local iDmg = GetConVarNumber("sk_tor_dmg_projectile")
				if self:GetDepleted() then
					iDmg = iDmg *0.5
					if ent:IsPlayer() then
						local ang = ent:GetAimVector():Angle()
						ent:SetEyeAngles(ang +Angle(math.Rand(-10,10), math.Rand(-10,10), 0))
						local rand = math.random(1,3)
						if rand == 2 then rand = 8 end
						ent:EmitSound("debris/zap" .. rand .. ".wav", 75, 100)
					end
				end
				local dmg = DamageInfo()
				dmg:SetDamage(iDmg)
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
			self:EmitSound("npc/tor/tor-staff-discharge.wav", 75, 100)
		end
	end
	local effect = ents.Create("info_particle_system")
	effect:SetKeyValue("effect_name", !self:GetDepleted() && "tor_projectile_vanish" || "tor_projectile_vanish_blue")
	effect:SetKeyValue("start_active", "1")
	effect:SetPos(self:GetPos())
	effect:Spawn()
	effect:Activate()
	timer.Simple(0.5,function() if IsValid(effect) then effect:Remove() end end)
	self:Remove()
	return true
end

