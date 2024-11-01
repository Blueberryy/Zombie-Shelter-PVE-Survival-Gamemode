--[[
	EN :
	Zombie Shelter v2.0 by Meiryi / Meika / Shiro / Shigure
	You SHOULD NOT edit / modify / reupload the codes, it includes editing gamemode's name
	If you have any problems, feel free to contact me on steam, thank you for reading this

	ZH-TW :
	夜襲生存戰 v2.0 by Meiryi  / Meika / Shiro / Shigure
	任何的修改是不被允許的 (包括模式的名稱)，有問題請在Steam上聯絡我, 謝謝!
	
	ZH-CN :
	昼夜求生 v2.0 by Meiryi  / Meika / Shiro / Shigure
	任何形式的编辑是不被允许的 (包括模式的名称), 若有问题请在Steam上联络我
]]

util.AddNetworkString("ZShelter-DamageNumber")

function ZShelter.DealNoScaleDamage(attacker, victim, damage)
	local dmginfo = DamageInfo()
		dmginfo:SetDamage(damage)
		dmginfo:SetAttacker(attacker)
		dmginfo:SetInflictor(attacker)
		dmginfo:SetDamageCustom(8)
	victim:TakeDamageInfo(dmginfo)
end

function ZShelter.ApplyDamageMul(ent, id, mul, time, infinite)
	if(!ent.DamageMultipliers) then
		ent.DamageMultipliers = {}
	end
	ent.DamageMultipliers[id] = {
		mul = mul,
		time = CurTime() + time,
		infinite = infinite,
	}
end

function ZShelter.StunEntity(ent, stuntime)
	ent:NextThink(CurTime() + stuntime)
	ent.StunTimer = CurTime() + stuntime
end

function ZShelter.Freeze(ent)
	if(ent.IsBuilding) then return end
	if(ent.LastFreezeTime && ent.LastFreezeTime > CurTime()) then return end
	if(ent.FreezeImmunityTime && ent.FreezeImmunityTime > CurTime()) then return end
	if(!ent.FreezeCount) then
		ent.FreezeCount = 0
	else
		ent.FreezeCount = ent.FreezeCount + 1
		if(ent.FreezeCount > 12) then
			ent:SetColor(Color(0, 0, 255, 255))
			ent:NextThink(CurTime() + 3)
			timer.Simple(3, function()
				if(IsValid(ent)) then
					ent:SetColor(Color(255, 255, 255, 255))
				end
			end)
			ent.FreezeCount = 0
			ent.FreezeImmunityTime = CurTime() + 10
		end
	end
	ent.LastFreezeTime = CurTime() + 0.085 -- So it doesn't stack too much
end

hook.Add("EntityTakeDamage", "ZShelter-DamageHandling", function(target, dmginfo)
	local attacker = dmginfo:GetAttacker()
	local damage = dmginfo:GetDamage()
	if(!IsValid(attacker) || !IsValid(target)) then return false end	

	target.AttackedByTurrets = false
	target.AttackerTurret = nil

	if(target.NoAttackEvent) then
		local phys = target:GetPhysicsObject()
		if(IsValid(phys)) then
			phys:EnableMotion(false)
		end
		return true
	end

	if(attacker.DamageMultipliers) then
		local mul = 1
		for k,v in pairs(attacker.DamageMultipliers) do
			if(v.time < CurTime() && !v.infinite) then
				attacker.DamageMultipliers[k] = nil
				continue
			end
			mul = mul * v.mul
		end
		dmginfo:ScaleDamage(mul)
		damage = dmginfo:GetDamage()
	end

	if(attacker:GetClass() == "entityflame" && dmginfo:IsDamageType(DMG_BURN) && IsValid(target.LastIgniteTarget)) then
		dmginfo:SetDamage(3)
		dmginfo:SetAttacker(target.LastIgniteTarget)
	end

	local addScale = 1

	if(attacker:GetNWFloat("DamageBuffTime", 0) > CurTime()) then
		addScale = attacker:GetNWFloat("DamageBuff", 1)
		dmginfo:SetDamage(damage * addScale)
		damage = dmginfo:GetDamage()
	end

	if(target:GetNWFloat("DefenseNerfTime", 0) > CurTime()) then
		dmginfo:SetDamage(damage * 1.35)
		addScale = 1.35
		damage = dmginfo:GetDamage()
	end

	if(target.IsBarricade) then
		if(attacker:IsPlayer()) then
			local wep = attacker:GetActiveWeapon()
			if(IsValid(wep) && wep.DamageScaling) then
				dmginfo:SetDamage(damage * wep.DamageScaling)
			end
			local dmg = dmginfo:GetDamage() * attacker:GetNWFloat("DamageScale", 1)
			ZShelter.HandleBarricade(target, attacker, dmg)
		end

		local phys = target:GetPhysicsObject()
		if(IsValid(phys)) then
			phys:EnableMotion(false)
		end
		return true
	end

	if(attacker.IsBuilding && target.IsBuilding) then return true end
	if(attacker:IsPlayer() && target.IsBuilding) then return true end
	if(attacker.IsBuilding && target:IsPlayer()) then return true end

	if(attacker:IsNPC() && !attacker.IsBuilding) then
		if(attacker.damage && attacker.damage != -1) then
			dmginfo:SetDamage(attacker.damage)
			damage = dmginfo:GetDamage()
		end
		if(attacker:GetNWFloat("DamageBoostTime", 0) > CurTime()) then
			dmginfo:SetDamage(damage * 1.75)
			damage = dmginfo:GetDamage()
		end
	end

	if(target:IsNPC() && !target.IsBuilding) then
		if(target:GetNWFloat("ResistanceTime", 0) > CurTime()) then
			dmginfo:SetDamage(damage * 0.5)
			damage = dmginfo:GetDamage()
		end
	end

	if(target.IsBoss && !target.Awake) then
		target:NextThink(CurTime())
		target.Awake = true
	end

	-- Player to anything (exlcuding turrets)

	if(attacker:IsPlayer() && !target.IsBuilding) then
		local wep = attacker:GetActiveWeapon()
		if(dmginfo:GetDamageCustom() != 8 && !target.IsBoss && (IsValid(wep) && !ZShelter.IsMeleeWeapon(wep:GetClass()))) then
			if(IsValid(wep) && wep.DamageScaling) then
				dmginfo:SetDamage(damage * wep.DamageScaling)
			end
			local dmgscale = attacker:GetNWFloat("DamageScale", 1)
			dmginfo:ScaleDamage(dmgscale)
			if(attacker.Callbacks.OnDealingDamage) then
				for k,v in pairs(attacker.Callbacks.OnDealingDamage) do
					v(attacker, target, dmginfo)
				end
			end
		end
		if(target:IsPlayer()) then
			local skip = false
			if(target.Callbacks.OnTakingDamage) then
				for k,v in pairs(target.Callbacks.OnTakingDamage) do
					local ret = v(attacker, target, dmginfo)
					if(ret) then
						skip = ret
					end
				end
			end
			local dmgscale = target:GetNWFloat("DamageResistance", 1)
			dmginfo:SetDamage(dmginfo:GetDamage() / dmgscale)
			if(skip) then
				return true
			end
		end
		if(attacker.AttackNerfTime && attacker.AttackNerfTime > CurTime()) then
			if(!IsValid(wep) || !ZShelter.IsMeleeWeapon(wep:GetClass())) then
				if(!attacker.LastNerfTargets || !attacker.LastNerfTargets[target:EntIndex()]) then
					dmginfo:SetDamage(dmginfo:GetDamage() * 0.35)
				end
			end
		end
		return
	end

	-- Anything to player

	if(target:IsPlayer() && !attacker.IsBuilding) then
		local skip = false
		if(target.Callbacks.OnTakingDamage) then
			for k,v in pairs(target.Callbacks.OnTakingDamage) do
				local ret = v(attacker, target, dmginfo, skip)
				if(ret) then
					skip = ret
				end
			end
		end
		local dmgscale = target:GetNWFloat("DamageResistance", 1)
		dmginfo:SetDamage(dmginfo:GetDamage() / dmgscale)
		if(skip) then
			return true
		end
		return
	end

	-- Buildings to NPC

	if(attacker.IsBuilding && !target.IsBuilding && !target:IsPlayer()) then
		if(!IsValid(attacker:GetOwner()) || !attacker:GetOwner():IsPlayer()) then return end
		local damage = dmginfo:GetDamage()
		if(attacker.AttackDamage) then
			damage = attacker.AttackDamage
		end
		if(attacker.DamageNerfTime && attacker.DamageNerfTime > CurTime()) then
			damage = math.max(damage * 0.5, 1)
		end
		if(attacker:GetNWBool("DurabilitySystem", false)) then
			if(!attacker.LastDurabilityCostTime) then
				attacker.LastDurabilityCostTime = 0
			end
			if(attacker.LastDurabilityCostTime < CurTime()) then
				ZShelter.ApplyDamageFast(attacker, attacker.DurabilityCost, false, true)
				attacker.LastDurabilityCostTime = CurTime() + attacker.DurabilityInv
			end
		end
		local player = attacker:GetOwner()
		local dmgscale = player:GetNWFloat("TurretDamageScale", 1)
		if(player.Callbacks && player.Callbacks.OnBuildingDealDamage) then
			for k,v in pairs(player.Callbacks.OnBuildingDealDamage) do
				v(attacker, dmginfo, target)
			end
		end
		if(attacker.IsTrap) then
			dmgscale = player:GetNWFloat("TrapDamageScale", 1)
		end
		dmginfo:SetAttacker(player)
		dmginfo:SetInflictor(player)
		dmginfo:SetDamage(damage * (dmgscale * addScale))
		attacker:SetNWInt("ZShelter_DamageDealt", attacker:GetNWInt("ZShelter_DamageDealt", 0) + dmginfo:GetDamage())
		if(attacker.IsTurret) then
			target.AttackedByTurrets = true
			target.AttackerTurret = attacker
		end
		return
	end

	-- NPC to turret

	if(attacker:IsNPC()) then
		if(attacker.OnDealingDamage) then
			attacker.OnDealingDamage(attacker, target, dmginfo)
		end
	end

	if(!target:GetNWBool("IsBuilding", false)) then return false end
	if(attacker:IsNPC() || attacker:IsNextBot()) then
		if(target.__oda) then
			target.__oda(target, attacker, dmginfo)
		end
		ZShelter.ApplyDamage(attacker, target, dmginfo)
		return true
	end
end)

hook.Add("OnNPCKilled", "ZShelter-EntityKilled", function(npc, attacker, inflictor)
	if(!IsValid(npc)) then return end
	npc:SetCollisionGroup(10)
	npc:SetCollisionBounds(Vector(0, 0, 0), Vector(0, 0, 0)) -- So it doesn't block turret's bullet + melees
	if(npc.IsBoss && !npc.KilledBySystem) then
		ZShelter.SpawnLootboxVec(npc:GetPos())
	end
	if(npc.AttackedByTurrets && IsValid(npc.AttackerTurret)) then
		npc.AttackerTurret:SetNWInt("ZShelter_KillCount", npc.AttackerTurret:GetNWInt("ZShelter_KillCount", 0) + 1)
	end
	if(!attacker:IsPlayer()) then return end
	if(attacker.Callbacks.OnEnemyKilled) then
		for k,v in pairs(attacker.Callbacks.OnEnemyKilled) do
			v(attacker, npc, npc.AttackedByTurrets)
		end
	end
	local score = math.Clamp((npc:GetMaxHealth() / 100), 1, 8)
	if(npc.AttackedByTurrets) then
		score = math.min(math.max(1, score * 0.15), 3)
	end
	attacker:AddFrags(score)
	SetGlobalInt("TKills", GetGlobalInt("TKills", 0) + 1)
	attacker:SetNWInt("TKills", attacker:GetNWInt("TKills", 0) + 1)
end)

function ZShelter.SendDamage(player, eindex, damage, pos)
	net.Start("ZShelter-DamageNumber")
	net.WriteInt(eindex, 32)
	net.WriteInt(damage, 32)
	net.WriteVector(pos)
	net.Send(player)
end

hook.Add("PostEntityTakeDamage", "ZShelter-GetDamage", function(target, dmginfo, took)
	if(!took) then return end
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	if(!IsValid(attacker) || !attacker:IsPlayer()) then return end
	local damage = dmginfo:GetDamage()
	local pos = dmginfo:GetDamagePosition()
	local mins, maxs = target:GetModelBounds()
	mins.z = 0
	maxs.z = 0
	local dst = mins:Distance(maxs) * 1.25
	local p1, p2 = Vector(pos.x, pos.y, 0), inflictor:GetPos()
	p2.z = 0
	if(pos == Vector(0, 0, 0) || (IsValid(inflictor) && p1:Distance(p2) < dst)) then
		pos = target:GetPos() + Vector(0, 0, target:OBBMaxs().z * 0.5)
	end
	ZShelter.SendDamage(attacker, target:EntIndex(), damage, pos)
end)

hook.Add("HandlePlayerArmorReduction", "ZShelter-ArmorHandling", function(ply, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if(attacker:IsPlayer() && attacker != ply && !ZShelter.IsFriendlyFire(attacker, ply)) then dmginfo:SetDamage(0) return end
	if(ply:Armor() <= 0 || bit.band(dmginfo:GetDamageType(), DMG_FALL + DMG_DROWN + DMG_POISON + DMG_RADIATION) != 0) then return end
	if(attacker.IsBuilding) then return end

	local armor = ply:Armor()
	local damage = dmginfo:GetDamage()
	local newdamage = damage
	if(armor >= damage) then
		ply:SetArmor(armor - damage)
		newdamage = 0
	else
		ply:SetArmor(0)
		newdamage = damage - armor
	end

	dmginfo:SetDamage(newdamage)
end)