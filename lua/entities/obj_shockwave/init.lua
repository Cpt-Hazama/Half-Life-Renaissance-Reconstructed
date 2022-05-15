
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	if self:GetRadius() == 0 then self:SetRadius(200) end
	if self:GetDelay() == 0 then self:SetDelay(0.2) end
	if string.len(self:GetNetworkedString("texture")) == 0 then
		self:SetTexture("trails/laser")
	end
	if string.len(self:GetNetworkedString("color")) == 0 then self:SetShockwaveColor(255,255,255,255) end
end

function ENT:SetRadius(flRadius)
	self:SetNetworkedFloat("radius", flRadius)
end

function ENT:GetRadius()
	return self:GetNetworkedFloat("radius")
end

function ENT:SetTexture(sText)
	self:SetNetworkedString("texture", sText)
end

function ENT:GetTexture()
	return self:GetNetworkedString("texture")
end

function ENT:SetDelay(flDelay)
	self:SetNetworkedFloat("delay", flDelay)
	if !self:GetRepeat() then self.flDelay = CurTime() +flDelay end
end

function ENT:GetDelay()
	return self:GetNetworkedFloat("delay")
end

function ENT:SetRepeat(bRepeat)
	self:SetNetworkedBool("repeat", bRepeat)
	if bRepeat == true then self.flDelay = nil
	else self.flDelay = self:GetNetworkedFloat("delay") end
end

function ENT:GetRepeat()
	return self:GetNetworkedBool("repeat")
end

function ENT:SetRepeatDelay(flRepeat)
	self:SetNetworkedFloat("repeatdelay", flRepeat)
end

function ENT:GetRepeatDelay()
	return self:GetNetworkedFloat("repeatdelay")
end

function ENT:SetShockwaveColor(r,g,b,a)
	local color = r .. "," .. g .. "," .. b
	if a then color = color .. "," .. a end
	self:SetNetworkedString("color", color)
end

function ENT:GetShockwaveColor()
	local _color = self:GetNetworkedString("color")
	_color = string.Explode(",", _color)
	local color = Color(_color[1],_color[2],_color[3],_color[4])
	return color
end

function ENT:OnRemove()
end

function ENT:Think()
	if self.flDelay && CurTime() >= self.flDelay then
		self:Remove()
	end
end
