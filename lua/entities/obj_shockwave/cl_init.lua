include('shared.lua')

ENT.nextIncrement = 0
ENT.flRadius = 0

function ENT:Initialize()
	local iIndex = self:EntIndex()
	hook.Add("RenderScreenspaceEffects", "Effect_Shockwave" .. iIndex, function()
		if !IsValid(self) then
			hook.Remove("RenderScreenspaceEffects", "Effect_Shockwave" .. iIndex)
			return
		end
		local mat = self:GetNetworkedString("texture")
		if !self.material || self.material != mat then
			self.material = mat
			self.texture = Material(mat)
		end
		local color = self:GetNetworkedString("color")
		color = string.Explode(",",color)
		color = Color(tonumber(color[1]) || 255,tonumber(color[2]) || 255,tonumber(color[3]) || 255,tonumber(color[4]) || 255)
		local radius = self:GetNetworkedFloat("radius")
		if self.flRadius >= radius then
			local bRepeat = self:GetNetworkedBool("repeat")
			if bRepeat then
				if !self.flNextRepeat then
					self.flNextRepeat = CurTime() +self:GetNetworkedFloat("repeatdelay")
				elseif CurTime() >= self.flNextRepeat then
					self.flNextRepeat = nil
					self.flRadius = 0
				end
			else
				return
			end
		end
		local ang = Angle(0,0,0)
		local posStart = self:GetPos() +ang:Right() *self.flRadius
		local posEnd = posStart
		local amp = 6.282 *self.flRadius
		cam.Start3D(EyePos(), EyeAngles())
			render.SetMaterial(self.texture)
			render.StartBeam(361)
			render.AddBeam(posStart,40,CurTime(),color)
			for i = 1, 360 do
				ang.y = i
				posStart = posEnd
				posEnd = posStart +ang:Forward() *(amp /360)
				render.AddBeam(posEnd,40,CurTime(),color)
			end
			render.EndBeam()
		cam.End3D()
		if CurTime() >= self.nextIncrement then
			local flDelay = self:GetNetworkedFloat("delay")
			self.flRadius = self.flRadius +(radius /flDelay) *0.01
			self.nextIncrement = CurTime() +0.01
		end
	end)
end

function ENT:Draw()
end
