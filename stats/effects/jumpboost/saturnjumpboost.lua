function init()
  local bounds = mcontroller.boundBox()
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = 0.15}
  })
end

function update(dt)
  mcontroller.controlModifiers({
      airJumpModifier = 1.15
    })
end

function uninit()
  
end
