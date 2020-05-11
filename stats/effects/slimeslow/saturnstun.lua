function init()
  animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
  animator.setParticleEmitterActive("drips", true)
  effect.setParentDirectives("fade=FFFFFF=0.1")
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = -0.20}
  })
end

function update(dt)
  mcontroller.controlModifiers({
      groundMovementModifier = 0.4,
      speedModifier = 0.65,
      airJumpModifier = 0.80
    })
end

function uninit()

end
