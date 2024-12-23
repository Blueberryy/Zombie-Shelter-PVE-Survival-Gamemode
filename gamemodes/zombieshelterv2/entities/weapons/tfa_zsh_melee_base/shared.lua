DEFINE_BASECLASS("tfa_bash_base")
SWEP.IsZShelterMeleeWeapon = true
SWEP.DrawCrosshair = false
SWEP.SlotPos = 72
SWEP.Slot = 0
SWEP.WeaponLength = 8
SWEP.data = {}
SWEP.data.ironsights = 0
SWEP.Primary.Directional = false
SWEP.Primary.Attacks = {}
--[[{
{
["act"] = ACT_VM_HITLEFT, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
["len"] = 8 * 4.5, -- Trace distance
["src"] = Vector(20,10,0), -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
["dir"] = Vector(-40,30,0), -- Trace direction/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
["dmg"] = 60, --Damage
["dmgtype"] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
["delay"] = 0.2, --Delay
["spr"] = true, --Allow attack while sprinting?
["snd"] = "Swing.Sound", -- Sound ID
["viewpunch"] = Angle(1,-10,0), --viewpunch angle
["end"] = 1, --time before next attack
["hull"] = 10, --Hullsize
["direction"] = "L", --Swing direction
["combotime"] = 0.2 --If you hold attack down, attack this much earlier
},
{
["act"] = ACT_VM_HITRIGHT, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
["len"] = 8 * 4.5, -- Trace distance
["src"] = Vector(-10,10,0), -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
["dir"] = Vector(40,30,0), -- Trace direction/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
["dmg"] = 60, --Damage
["dmgtype"] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
["delay"] = 0.2, --Delay
["spr"] = true, --Allow attack while sprinting?
["snd"] = "Swing.Sound", -- Sound ID
["viewpunch"] = Angle(1,10,0), --viewpunch angle
["end"] = 1, --time before next attack
["hull"] = 10, --Hullsize
["direction"] = "R", --Swing direction
["combotime"] = 0.2 --If you hold attack down, attack this much earlier
}
}

SWEP.Secondary.Attacks = {
{
["act"] = ACT_VM_MISSCENTER, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
["src"] = Vector(0,5,0), -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
["dir"] = Vector(0,50,0), -- Trace direction/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
["dmg"] = 60, --Damage
["dmgtype"] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
["delay"] = 0.2, --Delay
["spr"] = true, --Allow attack while sprinting?
["snd"] = "Swing.Sound", -- Sound ID
["viewpunch"] = Angle(5,0,0), --viewpunch angle
["end"] = 1, --time before next attack
["callback"] = function(tbl,wep,tr) end,
["kickback"] = nil--Recoil if u hit something with this activity
}
}
SWEP.AOEDamage = true
SWEP.AOERange = 86
]]
--
SWEP.IsMelee = true
SWEP.Precision = 9 --Traces to use per attack
local l_CT = CurTime
SWEP.Primary.MaxCombo = 3 --Max amount of times you'll attack by simply holding down the mouse; -1 to unlimit
SWEP.Secondary.MaxCombo = 3 --Max amount of times you'll attack by simply holding down the mouse; -1 to unlimit
SWEP.CanBlock = false

SWEP.BlockAnimation = {
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DEPLOY, --Number for act, String/Number for sequence
		["transition"] = true
	},
	--Inward transition
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_IDLE_DEPLOYED, --Number for act, String/Number for sequence
		["is_idle"] = true
	},
	--looping animation
	["hit"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_RELOAD_DEPLOYED, --Number for act, String/Number for sequence
		["is_idle"] = true
	},
	--when you get hit and block it
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_UNDEPLOY, --Number for act, String/Number for sequence
		["transition"] = true
	}
}

--Outward transition
SWEP.BlockDamageTypes = {DMG_SLASH, DMG_CLUB}
SWEP.BlockCone = 135 --Think of the player's view direction as being the middle of a sector, with the sector's angle being this
SWEP.BlockDamageMaximum = 0.1 --Multiply damage by this for a maximumly effective block
SWEP.BlockDamageMinimum = 0.4 --Multiply damage by this for a minimumly effective block
SWEP.BlockTimeWindow = 0.5 --Time to absorb maximum damage
SWEP.BlockTimeFade = 1 --Time for blocking to do minimum damage.  Does not include block window
SWEP.BlockDamageCap = 100
SWEP.BlockSound = ""
SWEP.BlockFadeOut = nil --Override the length of the ["out"] block animation easily
SWEP.BlockFadeOutEnd = 0.2 --In absense of BlockFadeOut, shave this length off of the animation time
SWEP.BlockHoldType = "magic"
SWEP.BlockCanDeflect = true --Can "bounce" bullets off a perfect parry?
SWEP.Secondary.Directional = true
SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = true
SWEP.ImpactDecal = "ManhackCut"
SWEP.Secondary.CanBash = false
SWEP.DefaultComboTime = 0.2
SWEP.AllowSprintAttack = true
--[[ START OF BASE CODE ]]
--
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = ""
SWEP.Seed = 0
SWEP.AttackSoundTime = -1
SWEP.VoxSoundTime = -1

SWEP.Melee2Attack = false
SWEP.BuildSpeed = 45

function SWEP:OnTargetHit(melee2, target) end
function SWEP:PostTargetHit(melee2, target) end
function SWEP:OnComboBreak() end
function SWEP:PreGatheringResource(res) return true end
function SWEP:PostAttack() end
function SWEP:OnMeleeImpact(trace) end

function SWEP:MeleeImpact(trace)
	local ply = self.Owner
	self:OnMeleeImpact(trace)
	if(!ply.Callbacks || !ply.Callbacks.OnMeleeImpact) then return end
	for k,v in pairs(ply.Callbacks.OnMeleeImpact) do
		v(ply, trace, self.Melee2Attack)
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 30, "VP")
	self:NetworkVar("Float", 27, "VPTime")
	self:NetworkVar("Float", 28, "VPPitch")
	self:NetworkVar("Float", 29, "VPYaw")
	self:NetworkVar("Float", 30, "VPRoll")
	self:NetworkVar("Int", 30, "ComboCount")
	self:NetworkVar("Int", 31, "MelAttackID")
	self:SetMelAttackID(1)
	self:SetVP(false)
	self:SetVPPitch(0)
	self:SetVPYaw(0)
	self:SetVPRoll(0)
	self:SetVPTime(-1)
	self:SetComboCount(0)

	return BaseClass.SetupDataTables(self)
end

function SWEP:Deploy()
	self:SetMelAttackID(1)
	self:SetVP(false)
	self:SetVPPitch(0)
	self:SetVPYaw(0)
	self:SetVPRoll(0)
	self:SetVPTime(-1)
	self.up_hat = false
	self:SetComboCount(0)
	self:AddNZAnimations()

	return BaseClass.Deploy(self)
end

function SWEP:AddNZAnimations()
	if self.Primary.Attacks then
		for _, v in pairs(self.Primary.Attacks) do
			if v.act then
				self.DTapActivities[v.act] = true
			end
		end
	end

	if self.Secondary.Attacks then
		for _, v in pairs(self.Secondary.Attacks) do
			if v.act then
				self.DTapActivities[v.act] = true
			end
		end
	end
end

function SWEP:CanInterruptShooting()
	return false
end

local att = {}
local attack
local ind
local tr = {}
local traceres = {}
local pos, ang, mdl, ski, prop
local fwd, eang, scl, dirv
local strikedir = Vector()
local srctbl
SWEP.hpf = false
SWEP.hpw = false
local lim_up_vec = Vector(1, 1, 0.05)

function SWEP:ApplyForce(ent, force, posv)
	if not IsValid(ent) or not ent.GetPhysicsObjectNum then return end

	if ent.GetRagdollEntity and IsValid(ent:GetRagdollEntity()) and ent ~= ent:GetRagdollEntity() then
		ent = ent:GetRagdollEntity()

		timer.Simple(0, function()
			if IsValid(self) and self:OwnerIsValid() and IsValid(ent) then
				self:ApplyForce(ent, force, posv, false)
			end
		end)

		return
	end

	if not IsValid(ent) then return end

	if ent:IsPlayer() or ent:IsNPC() then
		--ent:SetVelocity(force * 0.1 * lim_up_vec)
	end

	if ent:GetPhysicsObjectCount() > 1 then
		for i = 0, ent:GetPhysicsObjectCount() - 1 do
			local phys = ent:GetPhysicsObjectNum(i)

			if IsValid(phys) then
				phys:ApplyForceOffset(force / ent:GetPhysicsObjectCount(), posv)
			end
		end
	else
		local phys = ent:GetPhysicsObjectNum(0)

		if IsValid(phys) then
			phys:ApplyForceOffset(force, posv)
		end
	end
end

function SWEP:ApplyDamage(trace, dmginfo, attk)
	local ent = trace.Entity
	local melee2 = self.Melee2Attack
	local ply = self.Owner
	if(IsValid(ent)) then
		self:MeleeImpact(trace)
		if(ent:GetNWBool("IsResource", false)) then
            if(SERVER) then
            	for i = 1, self.GatheringAmount || 1 do
            		if(!IsValid(ent) || !self:PreGatheringResource(ent)) then continue end
            		ZShelter.GatheringSystem(ply, ent) 
            	end
            end
			return
		end
        if(ent:GetNWBool("IsBuilding", false) && !ent.IsBarricade) then
            if(SERVER) then
                if(melee2) then
                    local dmginfo = DamageInfo()
                        dmginfo:SetAttacker(ply)
                        dmginfo:SetInflictor(self)
                        dmginfo:SetDamage(self.BuildSpeed * 4)
                        dmginfo:SetDamageType(DMG_CLUB)
                    ZShelter.ApplyDamage(ply, ent, dmginfo)
                else
                    ZShelter.BuildSystem(ply, ent, self.BuildSpeed)
                end
            end
            return
        end
	    if(!ent.IsBuilding) then
	    	if(SERVER) then
	    		self:OnTargetHit(melee2, ent, attk)
		    	local force = self.KnockbackForce || 0
		    	local vel = (ent:GetPos() - ply:GetPos()):Angle():Forward() * force
		    	vel.z = 0
		    	if(ent:IsPlayer()) then
		    		vel = vel * 0.2
		    		if(!ent:IsOnGround()) then
		    			vel = vel * 0.1
		    		end
		    	end
		    	if(ent.IsBoss) then
		    		vel = vel * 0.5
		    	end
		    	ent:SetVelocity(vel)
		    	ent:SetLocalVelocity(vel)
		    	self:PostTargetHit(melee2, ent)
	    	end
	    end
	end
    if(ply.Callbacks && ply.Callbacks.OnMeleeDamage) then
        for k,v in pairs(ply.Callbacks.OnMeleeDamage) do
            v(ply, ent, dmginfo, melee2)
        end
    end
	local dam, force = dmginfo:GetBaseDamage(), dmginfo:GetDamageForce()
	dmginfo:SetDamagePosition(trace.HitPos)
	dmginfo:SetReportedPosition(trace.StartPos)
	trace.Entity:DispatchTraceAttack(dmginfo, trace, fwd)
	dmginfo:SetDamage(dam)
	dmginfo:SetDamageForce(force)
	-- dmginfo:SetAttacker( self:GetOwner() )
	self:ApplyForce(trace.Entity, dmginfo:GetDamageForce(), trace.HitPos)
	dmginfo:SetDamage(dam)
	-- dmginfo:SetDamageForce(force)
	-- dmginfo:SetAttacker( self:GetOwner() )
end

function SWEP:SmackEffect(trace, dmg)
	local vSrc = trace.StartPos
	local bFirstTimePredicted = IsFirstTimePredicted()
	local bHitWater = bit.band(util.PointContents(vSrc), MASK_WATER) ~= 0
	local bEndNotWater = bit.band(util.PointContents(trace.HitPos), MASK_WATER) == 0

	local trSplash = bHitWater and bEndNotWater and util.TraceLine({
		start = trace.HitPos,
		endpos = vSrc,
		mask = MASK_WATER
	}) or not (bHitWater or bEndNotWater) and util.TraceLine({
		start = vSrc,
		endpos = trace.HitPos,
		mask = MASK_WATER
	})

	if (trSplash and bFirstTimePredicted) then
		local data = EffectData()
		data:SetOrigin(trSplash.HitPos)
		data:SetScale(1)

		if (bit.band(util.PointContents(trSplash.HitPos), CONTENTS_SLIME) ~= 0) then
			data:SetFlags(1) --FX_WATER_IN_SLIME
		end

		util.Effect("watersplash", data)
	end

	local dam, force, dt = dmg:GetBaseDamage(), dmg:GetDamageForce(), dmg:GetDamageType()

	if (trace.Hit and bFirstTimePredicted and (not trSplash) and self:DoImpactEffect(trace, dt) ~= true) then
		local data = EffectData()
		data:SetOrigin(trace.HitPos)
		data:SetStart(vSrc)
		data:SetSurfaceProp(trace.SurfaceProps)
		data:SetDamageType(dt)
		data:SetHitBox(trace.HitBox)
		data:SetEntity(trace.Entity)
		util.Effect("Impact", data)
	end

	dmg:SetDamage(dam)
	dmg:SetDamageForce(force)
	-- dmg:SetAttacker( self:GetOwner() )
end

function SWEP:MakeDoor(ent, dmginfo)
	pos = ent:GetPos()
	ang = ent:GetAngles()
	mdl = ent:GetModel()
	ski = ent:GetSkin()
	ent:SetNotSolid(true)
	ent:SetNoDraw(true)
	prop = ents.Create("prop_physics")
	prop:SetPos(pos)
	prop:SetAngles(ang)
	prop:SetModel(mdl)
	prop:SetSkin(ski or 0)
	prop:Spawn()
	prop:SetVelocity(dmginfo:GetDamageForce() * 48)
	prop:GetPhysicsObject():ApplyForceOffset(dmginfo:GetDamageForce() * 48, dmginfo:GetDamagePosition())
	if IsValid(dmginfo:GetAttacker()) then
		prop:SetPhysicsAttacker(dmginfo:GetAttacker())
	end
	prop:EmitSound("physics/wood/wood_furniture_break" .. tostring(math.random(1, 2)) .. ".wav", 110, math.random(90, 110))
end

function SWEP:BurstDoor(ent, dmginfo)
	if not ents.Create then return end

	if dmginfo:GetDamage() > 60 and (dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:IsDamageType(DMG_CLUB)) and (ent:GetClass() == "func_door_rotating" or ent:GetClass() == "prop_door_rotating") then
		if dmginfo:GetDamage() > 150 then
			local ply = self:GetOwner()
			self:MakeDoor(ent, dmginfo)
			ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(90, 110))
		else
			local ply = self:GetOwner()
			ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(90, 110))
			ply.oldname = ply:GetName()
			ply:SetName("bashingpl" .. ply:EntIndex())
			ent:SetKeyValue("Speed", "500")
			ent:SetKeyValue("Open Direction", "Both directions")
			ent:SetKeyValue("opendir", "0")
			ent:Fire("unlock", "", .01)
			ent:Fire("openawayfrom", "bashingpl" .. ply:EntIndex(), .01)

			timer.Simple(0.02, function()
				if IsValid(ply) then
					ply:SetName(ply.oldname)
				end
			end)

			timer.Simple(0.3, function()
				if IsValid(ent) then
					ent:SetKeyValue("Speed", "100")
				end
			end)
		end
	end
end

function SWEP:ThinkNPC()
	local ow = self:GetOwner()
	if ow:IsCurrentSchedule(SCHED_CHASE_ENEMY) then return end
	if ow:IsCurrentSchedule(SCHED_MELEE_ATTACK1) then return end
	if not self.Range then
		local t = table.Random( self.Primary.Attacks )
		if t and t.range then
			self.Range = t.src:Length() + t.dir:Length()
		else
			self.Range = 80
		end
	end
	local en = ow:GetEnemy()
	if IsValid(en) and en:GetPos():Distance(self:GetPos()) <= self.Range and CurTime() > self:GetNextPrimaryFire() then
		self:PrimaryAttack()
	else
		self:GetOwner():SetSchedule( SCHED_CHASE_ENEMY )
	end
end

function SWEP:Think2()
	if not self:VMIV() then return end

	if (not self:GetOwner():KeyDown(IN_ATTACK)) and (not self:GetOwner():KeyDown(IN_ATTACK2)) and self:GetComboCount() > 0 then
		self:OnComboBreak()
		self:SetComboCount(0)
	end

	if self:GetVP() and CurTime() > self:GetVPTime() then
		self:SetVP(false)
		self:SetVPTime(-1)
		self:GetOwner():ViewPunch(Angle(self:GetVPPitch(), self:GetVPYaw(), self:GetVPRoll()))
	end

	if self.CanBlock then
		local stat = self:GetStatus()

		if self:GetOwner():TFA_ZoomKeyDown() and TFA.Enum.ReadyStatus[stat] and not self:GetOwner():KeyDown(IN_USE) then
			self:SetStatus(TFA.GetStatus("blocking"))

			if self.BlockAnimation["in"] then
				self:PlayAnimation(self.BlockAnimation["in"])
			elseif self.BlockAnimation["loop"] then
				self:PlayAnimation(self.BlockAnimation["loop"])
			end

			self:SetStatusEnd(math.huge)
			self.BlockStart = CurTime()
		elseif stat == TFA.GetStatus("blocking") and not self:GetOwner():TFA_ZoomKeyDown() then
			local _, tanim
			self:SetStatus(TFA.GetStatus("blocking_end"))

			if self.BlockAnimation["out"] then
				_, tanim = self:PlayAnimation(self.BlockAnimation["out"])
			else
				_, tanim = self:ChooseIdleAnim()
			end

			self:SetStatusEnd(CurTime() + (self.BlockFadeOut or (self:GetActivityLength(tanim) - self.BlockFadeOutEnd)))
		elseif stat == TFA.GetStatus("blocking") and CurTime() > self:GetNextIdleAnim() then
			self:ChooseIdleAnim()
		end
	end

	self:StrikeThink()
	BaseClass.Think2(self)
end

function SWEP:ProcessHoldType(...)
	if self:GetStatus() == TFA.GetStatus("blocking") then
		self:SetHoldType(self.BlockHoldType or "magic")

		return self.BlockHoldType or "magic"
	else
		return BaseClass.ProcessHoldType(self, ...)
	end
end

function SWEP:GetBlockStart()
	return self.BlockStart or -1
end

function SWEP:ChooseBlockAnimation()
	if self.BlockAnimation["hit"] then
		self:PlayAnimation(self.BlockAnimation["hit"])
	elseif self.BlockAnimation["in"] then
		self:PlayAnimation(self.BlockAnimation["in"])
	end
end

function SWEP:ChooseIdleAnim(...)
	if self.CanBlock and self:GetStatus() == TFA.GetStatus("blocking") and self.BlockAnimation["loop"] then
		return self:PlayAnimation(self.BlockAnimation["loop"])
	else
		return BaseClass.ChooseIdleAnim(self, ...)
	end
end

function SWEP:StrikeThink()
	if self:GetSprinting() and not self:GetStat("AllowSprintAttack", false) then
		self:SetComboCount(0)
		--return
	end

	if self:IsSafety() then
		self:SetComboCount(0)

		return
	end

	if not IsFirstTimePredicted() then return end
	if self:GetStatus() ~= TFA.Enum.STATUS_SHOOTING then return end
	if self.up_hat then return end

	if self.AttackSoundTime ~= -1 and CurTime() > self.AttackSoundTime then
		ind = self:GetMelAttackID() or 1
		srctbl = (ind < 0) and self.Secondary.Attacks or self.Primary.Attacks
		attack = srctbl[math.abs(ind)]
		self:EmitSound(attack.snd)

		if self:GetOwner().Vox then
			self:GetOwner():Vox("bash", 4)
		end

		self.AttackSoundTime = -1
	end

	if self:GetOwner().Vox and self.VoxSoundTime ~= -1 and CurTime() > self.VoxSoundTime - self:GetOwner():Ping() * 0.001 then
		if self:GetOwner().Vox then
			self:GetOwner():Vox("bash", 4)
		end

		self.VoxSoundTime = -1
	end

	if CurTime() > self:GetStatusEnd() then
		ind = self:GetMelAttackID() or 1
		srctbl = (ind < 0) and self.Secondary.Attacks or self.Primary.Attacks
		attack = srctbl[math.abs(ind)]
		self.DamageType = attack.dmgtype
		--Just attacked, so don't do it again
		self.up_hat = true
		self:SetStatus(TFA.Enum.STATUS_IDLE)
		self:SetStatusEnd(math.huge)

		if self:GetComboCount() > 0 then
			self:SetNextPrimaryFire(self:GetNextPrimaryFire() - (attack.combotime or 0))
			self:SetNextSecondaryFire(self:GetNextSecondaryFire() - (attack.combotime or 0))
		end

		if(!self.AllowSwitchAttack) then
			self:Strike(attack, self.Precision)
		end
	end
end

local totalResults = {}

local function TraceHitFlesh(b)
	return (b.MatType == MAT_FLESH or b.MatType == MAT_ALIENFLESH or (IsValid(b.Entity) and b.Entity.IsNPC and (b.Entity:IsNPC() or b.Entity:IsPlayer() or b.Entity:IsRagdoll()))) && (IsValid(b.Entity) && !b.Entity:GetNWBool("IsBuilding"))
end

local red = Color(255, 0, 0, 255)

function SWEP:ArccwStyleMelee(attk)
	self.Owner:LagCompensation(true)
	local reach = 32 + attk.len
    local tr = util.TraceLine({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
        filter = self:GetOwner(),
        mask = MASK_SHOT_HULL
    })
    if(!IsValid(tr.Entity)) then
        tr = util.TraceHull({
            start = self:GetOwner():GetShootPos(),
            endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
            filter = self:GetOwner(),
            mins = Vector(-16, -16, -8),
            maxs = Vector(16, 16, 8),
            mask = MASK_SHOT_HULL
        })
    end
	local forcevec = Vector(self:GetOwner():EyeAngles():Forward() * reach)
	local damage = DamageInfo()
	damage:SetAttacker(self:GetOwner())
	damage:SetInflictor(self)
	damage:SetDamage(attk.dmg)
	damage:SetDamageType(attk.dmgtype || DMG_SLASH)
	damage:SetDamageForce(forcevec)
	
	local melee2 = self.Melee2Attack

    if(IsValid(tr.Entity)) then
    	local ent = tr.Entity
    	if(ent:IsPlayer() || ent:IsNPC()) then

    		if(self.AOEDamage) then
				attk.maxhits = attk.maxhits || 3
				local range = self.AOERange_Primary || 8
				if(self.Melee2Attack) then
					range = self.AOERange_Secondary || 16
				end
				local targets = {}
				local c = 0
				local origin = tr.HitPos
				local bounds = Vector(range, range, 86)
				for _, ent in pairs(ents.FindInBox(origin - bounds, origin + bounds)) do
					if(c >= attk.maxhits) then break end
					if(!IsValid(ent) || ent == self.Owner || (!ent:IsPlayer() && !ent:IsNPC() && !ent:IsNextBot()) || targets[ent:EntIndex()]) then continue end
					targets[ent:EntIndex()] = true
					c = c + 1
				end
				targets[tr.Entity:EntIndex()] = nil
				for k,v in pairs(targets) do
					--[[
						trace.StartPos
						trace.Entity
						trace.HitPos
					]]
					local ent = Entity(k)
					if(!IsValid(ent) || ent.IsBuilding) then continue end
					local trace = {
						StartPos = self.Owner:EyePos(),
						Entity = ent,
						HitPos = ent:GetPos() + ent:OBBCenter()
					}
					self:ApplyDamage(trace, damage, attk)
				end
			end
    		if(ent:GetNWBool("IsBuilding")) then
    			self:EmitSoundNet(attk.hitworld)
    		else
    			if(melee2) then
    				self:EmitSoundNet(attk.hitflesh)
    			else
    				self:EmitSoundNet(attk.hitflesh)
    			end
    		end
    	else
    		self:MeleeImpact(tr)
    		self:EmitSoundNet(attk.hitworld)
    	end
    	self:ApplyDamage(tr, damage, attk)
    else
    	if(tr.HitWorld) then
    		self:MeleeImpact(tr)
    		self:EmitSoundNet(attk.hitworld)
    	end
    end
	self.Owner:LagCompensation(false)
end

function SWEP:Strike(attk, precision)
	local ply = self.Owner
	local oldstyle = self.OldStyleHit
    if(ply.Callbacks && ply.Callbacks.OnMeleeStrike) then
        for k,v in pairs(ply.Callbacks.OnMeleeStrike) do
            v(ply, self.Melee2Attack)
        end
    end
	if(oldstyle) then
		self:ArccwStyleMelee(attk)
		self:PostAttack()
		return
	end

	local reach = 32 + attk.len
    local tr = util.TraceLine({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
        filter = self:GetOwner(),
        mask = MASK_SHOT
    })

    if(IsValid(tr.Entity) && !oldstyle) then
    	if(SERVER && (tr.Entity.IsBuilding || tr.Entity.IsResource)) then
    		self:ApplyDamage(tr, damage, attk)
    	end
    	self:EmitSoundNet(attk.hitworld)
    end

	local hitWorld, hitFlesh, needsCB
	local distance, direction, maxhull
	local ow = self:GetOwner()
	if not IsValid(ow) then return end
	distance = attk.len
	direction = attk.dir
	maxhull = attk.hull
	table.Empty(totalResults)
	eang = ow:EyeAngles()
	fwd = ow:EyeAngles():Forward()
	tr.start = ow:GetShootPos()
	scl = direction:Length() / precision / 2
	tr.maxs = Vector(scl, scl, scl)
	tr.mins = -tr.maxs
	tr.mask = MASK_SHOT

	tr.filter = function(ent)
		if ent == ow or ent == self then return false end

		return true
	end

	hitWorld = false
	hitFlesh = false

	if attk.callback then
		needsCB = true
	else
		needsCB = false
	end

	if maxhull then
		tr.maxs.x = math.min(tr.maxs.x, maxhull / 2)
		tr.maxs.y = math.min(tr.maxs.y, maxhull / 2)
		tr.maxs.z = math.min(tr.maxs.z, maxhull / 2)
		tr.mins = -tr.maxs
	end

	strikedir:Zero()
	strikedir:Add(direction.x * eang:Right())
	strikedir:Add(direction.y * eang:Forward())
	strikedir:Add(direction.z * eang:Up())
	local strikedirfull = strikedir * 1
	debugoverlay.Line(tr.start + Vector(0, 0, -1) + fwd * distance / 2 - strikedirfull / 2, tr.start + Vector(0, 0, -1) + fwd * distance / 2 + strikedirfull / 2, 5, red)

	if SERVER and not game.SinglePlayer() then
		ow:LagCompensation(true)
	end

	for i = 1, precision do
		dirv = LerpVector((i - 0.5) / precision, -direction / 2, direction / 2)
		strikedir:Zero()
		strikedir:Add(dirv.x * eang:Right())
		strikedir:Add(dirv.y * eang:Forward())
		strikedir:Add(dirv.z * eang:Up())
		tr.endpos = tr.start + distance * fwd + strikedir
		traceres = util.TraceLine(tr)
		table.insert(totalResults, traceres)
	end

	if SERVER and not game.SinglePlayer() then
		ow:LagCompensation(false)
	end

	local forcevec = strikedirfull:GetNormalized() * (attack.force or attack.dmg / 4) * 128
	local damage = DamageInfo()
	damage:SetAttacker(self:GetOwner())
	damage:SetInflictor(self)
	damage:SetDamage(attk.dmg)
	damage:SetDamageType(attk.dmgtype or DMG_SLASH)
	damage:SetDamageForce(forcevec)
	local fleshHits = 0
	local range = self.AOERange_Primary || 8
	if(self.Melee2Attack) then
		range = self.AOERange_Secondary || 16
	end

	if(oldstyle) then
		totalResults = {}
	end

	--Handle flesh
	local targets = {}
	local c = 0
	for _, v in ipairs(totalResults) do
		if v.Hit and IsValid(v.Entity) and TraceHitFlesh(v) and (not v.Entity.HasMeleeHit) then
			if(!self.AOEDamage) then
				self:ApplyDamage(v, damage, attk)
			end
			targets[v.Entity:EntIndex()] = true
			c = c + 1
			local origin = v.HitPos
			local bounds = Vector(range, range, 86)
			for _, ent in pairs(ents.FindInBox(origin - bounds, origin + bounds)) do
				if(c >= attk.maxhits) then break end
				if(!IsValid(ent) || ent == self.Owner || (!ent:IsPlayer() && !ent:IsNPC() && !ent:IsNextBot()) || targets[ent:EntIndex()]) then continue end
				targets[ent:EntIndex()] = true
				c = c + 1
			end
			self:SmackEffect(v, damage)
			v.Entity.HasMeleeHit = true
			fleshHits = fleshHits + 1
			if attk.hitflesh and not hitFlesh then
				self:EmitSoundNet(attk.hitflesh)
			end
			if fleshHits >= (attk.maxhits or 3) then break end

			if attk.callback and needsCB then
				attk.callback(attack, self, v)
				needsCB = false
			end
			hitFlesh = true
		end
		--debugoverlay.Sphere( v.HitPos, 5, 5, color_white )
	end

	if(self.AOEDamage) then
		for k,v in pairs(targets) do
			--[[
				trace.StartPos
				trace.Entity
				trace.HitPos
			]]
			local ent = Entity(k)
			if(!IsValid(ent) || ent.IsBuilding) then continue end
			local trace = {
				StartPos = self.Owner:EyePos(),
				Entity = ent,
				HitPos = ent:GetPos() + ent:OBBCenter()
			}
			self:ApplyDamage(trace, damage, attk)
		end
	end

	--Handle world
	for _, v in ipairs(totalResults) do

		if v.Hit and (not TraceHitFlesh(v) and !IsValid(v.Entity)) then
			self:ApplyDamage(v, damage)

			if not hitWorld then
				self:MeleeImpact(v)
				self:SmackEffect(v, damage)

				if attk.hitworld and not hitFlesh then
					self:EmitSoundNet(attk.hitworld)
				end

				if attk.callback and needsCB then
					attk.callback(attack, self, v)
					needsCB = false
				end

				self:BurstDoor(v.Entity, damage)
				hitWorld = true
			end
			if(IsValid(v.Entity)) then
				break
			end
		end
	end

	--Handle empty + cleanup
	for _, v in ipairs(totalResults) do
		if needsCB then
			attk.callback(attack, self, v)
			needsCB = false
		end

		if IsValid(v.Entity) then
			v.Entity.HasMeleeHit = false
		end
	end

	self:PostAttack()

	if attack.kickback and (hitFlesh or hitWorld) then
		self:SendViewModelAnim(attack.kickback)
	end
end

function SWEP:PlaySwing(act)
	self:SendViewModelAnim(act)

	return true, act
end

local lvec, ply, targ
lvec = Vector()

function SWEP:ChooseAttack(tblName)
	local attacks = self:GetStatL(tblName .. ".Attacks")
	if not attacks or #attacks <= 0 then return -1 end

	local keys = table.GetKeys(attacks)
	table.RemoveByValue(keys, "BaseClass")
	if #keys <= 0 then return -1 end

	local ply = self:GetOwner()
	local isdir = self:GetStatL(tblName .. ".Directional") and IsValid(ply) and ply:IsPlayer()
	local founddir = false
	local foundkeys = {}

	if isdir then
		lvec.x = 0
		lvec.y = 0

		if ply:KeyDown(IN_MOVERIGHT) then
			lvec.y = lvec.y - 1
		end

		if ply:KeyDown(IN_MOVELEFT) then
			lvec.y = lvec.y + 1
		end

		if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_JUMP) then
			lvec.x = lvec.x + 1
		end

		if ply:KeyDown(IN_BACK) or ply:KeyDown(IN_DUCK) then
			lvec.x = lvec.x - 1
		end

		local targ = ""
		if lvec.y > 0.3 then
			targ = "L"
		elseif lvec.y < -0.3 then
			targ = "R"
		elseif lvec.x > 0.5 then
			targ = "F"
		elseif lvec.x < -0.1 then
			targ = "B"
		end

		for k, v in pairs(attacks) do
			if (not self:GetSprinting() or v.spr) and v.direction and string.find(v.direction, targ) then
				founddir = true

				table.insert(foundkeys, k)
			end
		end
	end

	if not isdir or #foundkeys <= 0 or not founddir then
		for k, v in pairs(attacks) do
			if (not self:GetSprinting() or v.spr) and v.dmg then
				table.insert(foundkeys, k)
			end
		end
	end

	if #foundkeys <= 0 then return 0 end
	local key = foundkeys[self:SharedRandom(1, #foundkeys, tblName .. "Attack")]
	if not key then return 0 end

	return key, attacks[key]
end

function SWEP:ChoosePrimaryAttack()
	return self:ChooseAttack("Primary")
end

function SWEP:ChooseSecondaryAttack()
	return self:ChooseAttack("Secondary")
end

function SWEP:PrePrimaryAttack() return true end

function SWEP:PreSecondaryAttack() return true end

function SWEP:PrimaryAttack()
	local ow = self:GetOwner()
	if IsValid(ow) and ow:IsNPC() then
		local _, attk = self:ChoosePrimaryAttack()
		if not attk then return end
		local owv = self:GetOwner()

		timer.Simple(0.5, function()
			if IsValid(self) and IsValid(owv) and owv:IsCurrentSchedule(SCHED_MELEE_ATTACK1) then
				self:Strike(attk, 5)
			end
		end)

		self:SetNextPrimaryFire(CurTime() + attk["end"] or 1)

		timer.Simple(self:GetNextPrimaryFire() - CurTime(), function()
			if IsValid(owv) then
				owv:ClearSchedule()
			end
		end)

		self:GetOwner():SetSchedule(SCHED_MELEE_ATTACK1)
		return
	end

	if self:GetSprinting() and not self:GetStatL("AllowSprintAttack", false) then return end
	if self:IsSafety() then return end
	if not self:VMIV() then return end
	if CurTime() <= self:GetNextPrimaryFire() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end

	local maxcombo = self:GetStatL("Primary.MaxCombo", 0)
	if maxcombo > 0 and self:GetComboCount() >= maxcombo then return end
	if not self:PrePrimaryAttack() then return end
	self.Melee2Attack = false
	
	local ind, attack = self:ChoosePrimaryAttack()
	if not attack then return end

	--We have attack isolated, begin attack logic
	self:PlaySwing(attack.act)

	if not attack.snd_delay or attack.snd_delay <= 0 then
		if IsFirstTimePredicted() then
			self:EmitSound(attack.snd)

			if self:GetOwner().Vox then
				self:GetOwner():Vox("bash", 4)
			end
		end

		self:GetOwner():ViewPunch(attack.viewpunch)
	elseif attack.snd_delay then
		if IsFirstTimePredicted() then
			self.AttackSoundTime = CurTime() + attack.snd_delay / self:GetAnimationRate(attack.act)
			self.VoxSoundTime = CurTime() + attack.snd_delay / self:GetAnimationRate(attack.act)
		end

		--[[
		timer.Simple(attack.snd_delay, function()
			if IsValid(self) and self:IsValid() and SERVER then
				self:EmitSound(attack.snd)

				if self:OwnerIsValid() and self:GetOwner().Vox then
					self:GetOwner():Vox("bash", 4)
				end
			end
		end)
		]]
		--
		self:SetVP(true)
		self:SetVPPitch(attack.viewpunch.p)
		self:SetVPYaw(attack.viewpunch.y)
		self:SetVPRoll(attack.viewpunch.r)
		self:SetVPTime(CurTime() + attack.snd_delay / self:GetAnimationRate(attack.act))
		self:GetOwner():ViewPunch(-Angle(attack.viewpunch.p / 2, attack.viewpunch.y / 2, attack.viewpunch.r / 2))
	end

	self.up_hat = false
	self:ScheduleStatus(TFA.Enum.STATUS_SHOOTING, attack.delay / self:GetAnimationRate(attack.act))
	self:SetMelAttackID(ind)
	self:SetNextPrimaryFire(CurTime() + attack["end"] / self:GetAnimationRate(attack.act))
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:SetComboCount(self:GetComboCount() + 1)
end

function SWEP:SecondaryAttack()
	if self:GetSprinting() and not self:GetStatL("AllowSprintAttack", false) then return end
	if self:IsSafety() then return end
	if not self:VMIV() then return end
	if CurTime() <= self:GetNextPrimaryFire() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end

	self.Melee2Attack = true
	local maxcombo = self:GetStatL("Secondary.MaxCombo", 0)
	if maxcombo > 0 and self:GetComboCount() >= maxcombo then return end
	if not self:PreSecondaryAttack() then return end

	local ind, attack = self:ChooseSecondaryAttack()
	if attack then
		ind = -ind
	elseif ind < 0 and self:GetStatL("Secondary.PrimaryFallback") then
		ind, attack = self:ChoosePrimaryAttack()
	end
	if not attack then return end

	--We have attack isolated, begin attack logic
	self:PlaySwing(attack.act)

	if not attack.snd_delay or attack.snd_delay <= 0 then
		if IsFirstTimePredicted() then
			self:EmitSound(attack.snd)

			if self:GetOwner().Vox then
				self:GetOwner():Vox("bash", 4)
			end
		end

		self:GetOwner():ViewPunch(attack.viewpunch)
	elseif attack.snd_delay then
		if IsFirstTimePredicted() then
			self.AttackSoundTime = CurTime() + attack.snd_delay / self:GetAnimationRate(attack.act)
			self.VoxSoundTime = CurTime() + attack.snd_delay / self:GetAnimationRate(attack.act)
		end

		--[[
		timer.Simple(attack.snd_delay, function()
			if IsValid(self) and self:IsValid() and SERVER then
				self:EmitSound(attack.snd)

				if self:OwnerIsValid() and self:GetOwner().Vox then
					self:GetOwner():Vox("bash", 4)
				end
			end
		end)
		]]
		--
		self:SetVP(true)
		self:SetVPPitch(attack.viewpunch.p)
		self:SetVPYaw(attack.viewpunch.y)
		self:SetVPRoll(attack.viewpunch.r)
		self:SetVPTime(CurTime() + attack.snd_delay / self:GetAnimationRate(attack.act))
		self:GetOwner():ViewPunch(-Angle(attack.viewpunch.p / 2, attack.viewpunch.y / 2, attack.viewpunch.r / 2))
	end

	self.up_hat = false
	self:ScheduleStatus(TFA.Enum.STATUS_SHOOTING, attack.delay / self:GetAnimationRate(attack.act))
	self:SetMelAttackID(ind)
	self:SetNextPrimaryFire(CurTime() + attack["end"] / self:GetAnimationRate(attack.act))
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:SetComboCount(self:GetComboCount() + 1)
end

function SWEP:AltAttack()
	if self.CanBlock then
		if self.Secondary.CanBash and self.CanBlock and self:GetOwner():KeyDown(IN_USE) then
			BaseClass.AltAttack(self)

			return
		end
	else
		if not self:VMIV() then return end
		if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end
		if not self.Secondary.CanBash then return end
		if self:IsSafety() then return end

		return BaseClass.AltAttack(self)
	end
end

function SWEP:Reload(released, ovr, ...)
	if not self:VMIV() then return end
	if ovr then return BaseClass.Reload(self, released, ...) end

	if (self.SequenceEnabled[ACT_VM_FIDGET] or self.InspectionActions) and self:GetStatus() == TFA.Enum.STATUS_IDLE then
		self:SetStatus(TFA.Enum.STATUS_FIDGET)
		local _, tanim = self:ChooseInspectAnim()
		self:SetStatusEnd(l_CT() + self:GetActivityLength(tanim))
	end
end

function SWEP:CycleSafety()
end

SWEP.DisplayCTime = 0
SWEP.DisplayAlpha = 255
SWEP.DisplayString = "#BuildHints"
function SWEP:DrawHUDBackground()
	--[[
		#Hint_Menu
		#Hint_Game
		#Hint_Config
	]]
    if(self.DisplayCTime < CurTime()) then
        self.DisplayString = "["..string.upper(input.GetKeyName(ZShelter.Keybinds.BuildMenu)).."] "..ZShelter_GetTranslate("#Hint_Menu").." | ["..string.upper(input.GetKeyName(ZShelter.Keybinds.GameUI)).."] "..ZShelter_GetTranslate("#Hint_Game").." | ["..string.upper(input.GetKeyName(ZShelter.Keybinds.ConfigMenu)).."] "..ZShelter_GetTranslate("#Hint_Config")
		
        self.DisplayCTime = CurTime() + 1
    end
    draw.DrawText(self.DisplayString, "ZShelter-HUDWeapon", ScrW() * 0.5, ScrH() * 0.935, color_white, TEXT_ALIGN_CENTER)
end