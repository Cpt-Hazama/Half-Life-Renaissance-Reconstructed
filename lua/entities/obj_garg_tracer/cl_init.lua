include('shared.lua')

local mat = Material("sprites/glow04_noz")
local color = Color(255, 62, 67, 255)
function ENT:Draw()           
	self:DrawModel()
	local pos = self:GetPos()
	render.SetMaterial(mat) 
	
	local lcolor = render.GetLightColor(pos) *2
	lcolor.x = color.r *math.Clamp(lcolor.x, 0, 1)
	lcolor.y = color.g *math.Clamp(lcolor.y, 0, 1)
	lcolor.z = color.b *math.Clamp(lcolor.z, 0, 1)
	
	for i = 1, 20 do
		local color = Color(lcolor.x, lcolor.y, lcolor.z, 255 /(i /2))
		render.DrawSprite(pos +self:GetVelocity() *(i *-0.04), 45, 45, color)
	end
	render.DrawSprite(pos, 45, 45, lcolor)
end

function ENT:Initialize()
end
 
function ENT:OnRemove()
end
