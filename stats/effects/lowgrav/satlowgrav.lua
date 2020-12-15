function init()
  self.fallSpeedLimit = config.getParameter("fallSpeedLimit")
  effect.addStatModifierGroup({{stat = "fallDamageMultiplier", effectiveMultiplier = 0}})

  activateVisualEffects()
end

function activateVisualEffects()
  animator.setParticleEmitterOffsetRegion("embers", mcontroller.boundBox())
  animator.setParticleEmitterActive("embers", true)
end

function update(dt)

  --Limit fall speed
  local velocity = mcontroller.velocity()
  if velocity[2] < self.fallSpeedLimit then
    mcontroller.setYVelocity(self.fallSpeedLimit)
  end
end

function uninit()

end

