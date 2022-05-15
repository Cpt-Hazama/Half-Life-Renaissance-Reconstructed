
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	self.delayRemove = CurTime() +0.16
	if self:GetScale() == 0 then self:SetScale(1) end
end

function ENT:SetScale(flScale)
	self:SetNetworkedFloat("scale", flScale)
end

function ENT:GetScale()
	return self:GetNetworkedFloat("scale")
end

function ENT:Think()
	if CurTime() < self.delayRemove then self:NextThink(CurTime()); return true end
	self.delayRemove = nil
	self:Remove()
end

function ENT:AddPosition(vecPos)
	local iPos = self:GetNetworkedInt("positions") +1
	self:SetNetworkedInt("positions", iPos)
	self:SetNetworkedVector(iPos, vecPos)
end