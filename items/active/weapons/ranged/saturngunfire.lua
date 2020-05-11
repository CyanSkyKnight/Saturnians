require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"
require "/items/active/weapons/weapon.lua"

-- Base gun fire ability but with stances spliced in from the melee ability. Also makes shooting into a wall make a boop noise.
SaturnGunFire = WeaponAbility:new()

function SaturnGunFire:init()
  self.weapon:setStance(self.stances.idle)

  self.cooldownTimer = self.fireTime
  self.chargeTimer = (self.stances.windup.duration + self.stances.windup2.duration + self.stances.windup3.duration + self.stances.aimcorrect.duration)
  activeItem.setCursor("/cursors/reticle0.cursor")
  animator.setParticleEmitterActive("charge", false)
  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function SaturnGunFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if animator.animationState("firing") ~= "fire" then
    animator.setLightActive("muzzleFlash", false)
  end

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy") then

    if self.fireType == "auto" and status.overConsumeResource("energy", self:energyPerShot()) then
      self:setState(self.windupa)
    elseif self.fireType == "burst" then
      self:setState(self.windupb)
    end
  end
end



function SaturnGunFire:windupa()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()
  self:chargeFlash()
  animator.setAnimationState("charging", "charging")
  animator.setParticleEmitterActive("charge", true)
  animator.playSound("charge")
  activeItem.setCursor("/cursors/charge2.cursor")

  util.wait(self.stances.windup.duration, function(dt)
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end)

  self:setState(self.windup2a)
end

function SaturnGunFire:windup2a()
  self.weapon:setStance(self.stances.windup2)
  self.weapon:updateAim()
  animator.playSound("charge2")

  util.wait(self.stances.windup2.duration, function(dt)
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end)

  self:setState(self.windup3a)
end

function SaturnGunFire:windup3a()
  self.weapon:setStance(self.stances.windup3)
  self.weapon:updateAim()
  animator.playSound("charge3")

  util.wait(self.stances.windup3.duration, function(dt)
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end)

  self:setState(self.windupaca)
end

function SaturnGunFire:windupaca()
  self.weapon:setStance(self.stances.aimcorrect)
  self.weapon:updateAim()

  util.wait(self.stances.aimcorrect.duration, function(dt)
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end)
  activeItem.setCursor("/cursors/reticle0.cursor")

  self:setState(self.auto)
end

function SaturnGunFire:auto()
  self.weapon:setStance(self.stances.fire)
  
if not world.lineTileCollision(mcontroller.position(), self:firePosition()) then
	self:fireProjectile()
  else
	animator.playSound("boop")
	animator.setParticleEmitterActive("charge", false)
  end
	self:muzzleFlash()
  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration, function(dt)
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end)
  end

  self.cooldownTimer = self.fireTime
  self:setState(self.cooldown)
end



function SaturnGunFire:windupb()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()
  self:chargeFlash()
  animator.setAnimationState("charging", "charging")
  animator.setParticleEmitterActive("charge", true)
  animator.playSound("charge")
  activeItem.setCursor("/cursors/charge2.cursor")

  util.wait(self.stances.windup.duration, function(dt)
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end)

  self:setState(self.windup2b)
end

function SaturnGunFire:windup2b()
  self.weapon:setStance(self.stances.windup2)
  self.weapon:updateAim()
  animator.playSound("charge2")

  util.wait(self.stances.windup2.duration, function(dt)
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end)

  self:setState(self.windup3b)
end

function SaturnGunFire:windup3b()
  self.weapon:setStance(self.stances.windup3)
  self.weapon:updateAim()
  animator.playSound("charge3")

  util.wait(self.stances.windup3.duration, function(dt)
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end)

  self:setState(self.windupacb)
end

function SaturnGunFire:windupacb()
  self.weapon:setStance(self.stances.aimcorrect)
  self.weapon:updateAim()

  util.wait(self.stances.aimcorrect.duration, function(dt)
    status.setResourcePercentage("energyRegenBlock", 1.0)
  end)
  activeItem.setCursor("/cursors/reticle0.cursor")

  self:setState(self.burst)
end

function SaturnGunFire:burst()
  self.weapon:setStance(self.stances.fire)
  animator.setParticleEmitterActive("charge", false)

  local shots = self.burstCount
  while shots > 0 and status.overConsumeResource("energy", self:energyPerShot()) do
	if not world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    self:fireProjectile()
    self:muzzleFlash()
	else
		animator.playSound("boop")
	end
    shots = shots - 1

    util.wait(self.burstTime)
  end

  self.cooldownTimer = (self.fireTime - self.burstTime) * self.burstCount
end

function SaturnGunFire:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()

  local progress = 0
  util.wait(self.stances.cooldown.duration, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / self.stances.cooldown.duration))
  end)
end

function SaturnGunFire:chargeFlash()
  animator.setPartTag("chargeFlash", "variant", math.random(1, 3))
  animator.setAnimationState("charging", "charging")
  animator.burstParticleEmitter("muzzleFlash")
end

function SaturnGunFire:muzzleFlash()
  animator.setPartTag("muzzleFlash", "variant", math.random(1, 3))
  animator.setAnimationState("firing", "fire")
  animator.burstParticleEmitter("muzzleFlash")
  animator.setParticleEmitterActive("charge", false)
  animator.playSound("fire")

  animator.setLightActive("muzzleFlash", true)
end



function SaturnGunFire:fireProjectile(projectileType, projectileParams, inaccuracy, firePosition, projectileCount)
  local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})
  params.power = self:damagePerShot()
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.speed = util.randomInRange(params.speed)

  if not projectileType then
    projectileType = self.projectileType
  end
  if type(projectileType) == "table" then
    projectileType = projectileType[math.random(#projectileType)]
  end

  local projectileId = 0
  for i = 1, (projectileCount or self.projectileCount) do
    if params.timeToLive then
      params.timeToLive = util.randomInRange(params.timeToLive)
    end

    projectileId = world.spawnProjectile(
        projectileType,
        firePosition or self:firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(inaccuracy or self.inaccuracy),
        false,
        params
      )
  end
  return projectileId
end

function SaturnGunFire:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function SaturnGunFire:aimVector(inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function SaturnGunFire:energyPerShot()
  return self.energyUsage * (self.fireTime) * (self.energyUsageMultiplier or 1.0)
end

function SaturnGunFire:damagePerShot()
  return (self.baseDamage or (self.baseDps * (self.fireTime))) * (self.baseDamageMultiplier or 1.0) * config.getParameter("damageLevelMultiplier") / self.projectileCount
end

function SaturnGunFire:uninit()
end
