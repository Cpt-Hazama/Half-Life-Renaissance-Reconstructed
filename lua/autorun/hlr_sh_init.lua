if(!SLVBase_Fixed) then
	include("slvbase/slvbase.lua")
	if(!SLVBase_Fixed) then return end
end
local addon = "Half[-]Life Renaissance Reconstructed"
if(SLVBase_Fixed.AddonInitialized(addon)) then return end
if(SERVER) then
	AddCSLuaFile("autorun/hlr_sh_init.lua")
	AddCSLuaFile("autorun/slvbase/slvbase.lua")
	AddCSLuaFile("hlb_init/hlb_sh_concommands.lua")
end
SLVBase_Fixed.AddDerivedAddon(addon,{tag = "Half-Life"})
if(SERVER) then
	Add_NPC_Class("CLASS_XENIAN")
	Add_NPC_Class("CLASS_RACEX")
	Add_NPC_Class("CLASS_MILITARY")
	PrecacheSentenceGroup("scripts/sentences_hlr.txt")
end

game.AddParticles("particles/blood_impact_blue.pcf")
game.AddParticles("particles/icesphere.pcf")
game.AddParticles("particles/magic_spells.pcf")
game.AddParticles("particles/magic_spells02.pcf")
game.AddParticles("particles/magic01.pcf")
game.AddParticles("particles/magic04.pcf")
game.AddParticles("particles/kingpin.pcf")
game.AddParticles("particles/kingpin_sphere.pcf")
game.AddParticles("particles/kingpin2.pcf")
game.AddParticles("particles/kingpin3.pcf")
game.AddParticles("particles/mortarsynth.pcf")
game.AddParticles("particles/flame_gargantua.pcf")
game.AddParticles("particles/shocktrooper.pcf")
game.AddParticles("particles/spore1.pcf")
game.AddParticles("particles/vman_explosion.pcf")
game.AddParticles("particles/rpg_firetrail.pcf")
game.AddParticles("particles/mrfriendly.pcf")
game.AddParticles("particles/alien_slave.pcf")
game.AddParticles("particles/tor.pcf")
game.AddParticles("particles/tor_2.pcf")
game.AddParticles("particles/tor_3.pcf")
game.AddParticles("particles/tor_4.pcf")
game.AddParticles("particles/tor_5.pcf")
game.AddParticles("particles/stukabat_acid.pcf")
for _, particle in pairs({
		"blood_impact_blue_01",
		"icesphere_splash_02",
		"icesphere_trail",
		"kingpin_object_charge_large",
		"kingpin_psychic_shield_idle",
		"kingpin_object_charge",
		"mortarsynth_beam_charge",
		"mortarsynth_beam",
		"icesphere_splash_05",
		"icesphere_splash",
		"icesphere_splash_03",
		"magic_spell_fireball",
		"flame_gargantua",
		"dusty_explosion_rockets",
		"shockroach_projectile_trail",
		"spore_trail",
		"spore_splash",
		"rpg_firetrail",
		"rocket_smoke_trail",
		"mrfriendly_vomit",
		"alien_slave_hand_glow",
		"tor_projectile",
		"stukabat_acid_trail"
	}) do
	PrecacheParticleSystem(particle)
end

SLVBase_Fixed.InitLua("hlr_init")

local Category = "Half-Life: Renaissance"
SLVBase_Fixed.AddNPC(Category,"Houndeye","monster_hound_eye")
SLVBase_Fixed.AddNPC(Category,"Bullsquid","monster_bullsquid")
SLVBase_Fixed.AddNPC(Category,"Devilsquid","npc_devilsquid")
SLVBase_Fixed.AddNPC(Category,"Frostsquid","npc_frostsquid")
SLVBase_Fixed.AddNPC(Category,"Poisonsquid","npc_poisonsquid")
SLVBase_Fixed.AddNPC(Category,"Alien Grunt","monster_agrunt")
SLVBase_Fixed.AddNPC(Category,"Alien Slave","monster_alien_slv")
SLVBase_Fixed.AddNPC(Category,"Alien Controller","monster_controller")
SLVBase_Fixed.AddNPC(Category,"Tor","monster_alien_tor")
-- SLVBase_Fixed.AddNPC(Category,"Kingpin","npc_kingpin")

SLVBase_Fixed.AddNPC(Category,"Cockroach","monster_roach")

SLVBase_Fixed.AddNPC(Category,"Zombie Scientist","monster_zombie_scientist")
SLVBase_Fixed.AddNPC(Category,"Zombie Security Officer","monster_zombie_barney")
SLVBase_Fixed.AddNPC(Category,"Zombie Soldier","monster_zombie_soldier")

SLVBase_Fixed.AddNPC(Category,"Gargantua","monster_garg")
SLVBase_Fixed.AddNPC(Category,"Baby Gargantua","monster_babygarg")

SLVBase_Fixed.AddNPC(Category,"Headcrab","monster_head_crab")
SLVBase_Fixed.AddNPC(Category,"Baby Headcrab","monster_babyheadcrab")
SLVBase_Fixed.AddNPC(Category,"Gonarch","monster_gonarch")

SLVBase_Fixed.AddNPC(Category,"Snark","monster_alien_snark")
SLVBase_Fixed.AddNPC(Category,"Chumtoad","npc_chumtoad")

SLVBase_Fixed.AddNPC(Category,"Security Officer","monster_officer")
SLVBase_Fixed.AddNPC(Category,"Government Man","monster_g_man")
SLVBase_Fixed.AddNPC(Category,"Scientist","monster_bm_scientist")
SLVBase_Fixed.AddNPC(Category,"Human Sergeant","monster_hwgrunt")
SLVBase_Fixed.AddNPC(Category,"Human Marine","monster_hecu_marine")

SLVBase_Fixed.AddNPC(Category,"Large Mounted Turret","monster_turret",{},2,false,true)
SLVBase_Fixed.AddNPC(Category,"Small Mounted Turret","monster_miniturret",{},2,true)
SLVBase_Fixed.AddNPC(Category,"Sentry","monster_sentry")
SLVBase_Fixed.AddNPC(Category,"Decay Sentry","monster_sentry_decay")

-- SLVBase_Fixed.AddNPC(Category,"Black Ops Assassin","monster_hassassin") // Problem with event errors

SLVBase_Fixed.AddNPC(Category,"Panthereye","monster_panthereye")
SLVBase_Fixed.AddNPC(Category,"Leech","monster_alien_leech")
SLVBase_Fixed.AddNPC(Category,"Tentacle","monster_alien_tentacle")
SLVBase_Fixed.AddNPC(Category,"Mr Friendly","npc_friendly")
SLVBase_Fixed.AddNPC(Category,"Stukabat","npc_stukabat")
SLVBase_Fixed.AddNPC(Category,"Nihilanth","monster_alien_nihilanth")

SLVBase_Fixed.AddNPC(Category,"Penguin","monster_penguin")
SLVBase_Fixed.AddNPC(Category,"Shock Trooper","monster_shocktrooper")
SLVBase_Fixed.AddNPC(Category,"Shock Roach","monster_shockroach")
SLVBase_Fixed.AddNPC(Category,"Gonome","monster_gonome")
SLVBase_Fixed.AddNPC(Category,"Pit Drone","monster_pitdrone")
SLVBase_Fixed.AddNPC(Category,"Pit Worm","monster_pitworm_up")
SLVBase_Fixed.AddNPC(Category,"Gene Worm","monster_geneworm")
SLVBase_Fixed.AddNPC(Category,"Voltigore","monster_alien_voltigore")
SLVBase_Fixed.AddNPC(Category,"Baby Voltigore","monster_alien_babyvoltigore")
SLVBase_Fixed.AddNPC(Category,"Otis","monster_otis")

SLVBase_Fixed.AddNPC(Category,"Dr Rosenberg","monster_rosenberg")
SLVBase_Fixed.AddNPC(Category,"Dr Keller","monster_wheelchair")

SLVBase_Fixed.AddNPC(Category,"Archer","monster_archer")
SLVBase_Fixed.AddNPC(Category,"Ichthyosaur","monster_icky")

list.Add("NPCUsableWeapons",{class = "weapon_9mmar",title = "MP5 Machine Gun"})
list.Add("NPCUsableWeapons",{class = "weapon_pipewrench",title = "Pipe Wrench"})
list.Add("NPCUsableWeapons",{class = "weapon_9mmhandgun",title = "HL1 Glock 17"})
list.Add("NPCUsableWeapons",{class = "weapon_357_hl",title = "HL1 357 Magnum"})
list.Add("NPCUsableWeapons",{class = "weapon_chumtoad",title = "Chumtoad"})
list.Add("NPCUsableWeapons",{class = "weapon_crossbow_hl",title = "HL1 Crossbow"})
list.Add("NPCUsableWeapons",{class = "weapon_displacer",title = "Displacer Cannon"})
list.Add("NPCUsableWeapons",{class = "weapon_eagle",title = "Desert Eagle"})
list.Add("NPCUsableWeapons",{class = "weapon_egon",title = "Gluon Cannon"})
list.Add("NPCUsableWeapons",{class = "weapon_freezinggun",title = "Freezing Gun"})
list.Add("NPCUsableWeapons",{class = "weapon_gauss",title = "Tau Cannon"})
list.Add("NPCUsableWeapons",{class = "weapon_hornetgun",title = "Hive Hand"})
list.Add("NPCUsableWeapons",{class = "weapon_m249",title = "M249 SAW Machine Gun"})
list.Add("NPCUsableWeapons",{class = "weapon_penguin",title = "Penguin"})
list.Add("NPCUsableWeapons",{class = "weapon_rpg_hl",title = "HL1 RPG"})
list.Add("NPCUsableWeapons",{class = "weapon_shockrifle",title = "Shock Roach"})
list.Add("NPCUsableWeapons",{class = "weapon_shotgun_hl",title = "HL1 SPAS-12"})
list.Add("NPCUsableWeapons",{class = "weapon_snark",title = "Snark"})
list.Add("NPCUsableWeapons",{class = "weapon_sniperrifle",title = "M40A1 Sniper Rifle"})
list.Add("NPCUsableWeapons",{class = "weapon_sporelauncher",title = "Spore Launcher"})