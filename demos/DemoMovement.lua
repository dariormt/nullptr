--- @class Player : Character
local player = {}

player.shoot_range = 100.0
player.shoot_energy = 5000.0
player.fire_rate = 8.0

function player:begin()
    local controller = self:find("PlayerController")
    if controller ~= nil then
        controller:setMouseLocked(true)
    end
end

--- Movement, look, jump and crouch actions call the Character functions directly
--- @param action InputAction
--- @param event InputActionEvent
function player:onShoot(action, event)
    if event ~= InputEvent.start and event ~= InputEvent.hold then
        return
    end

    local now = Time.uptime()
    local cooldown = 1.0 / self.fire_rate
    if self._last_shot_time ~= nil and (now - self._last_shot_time) < cooldown then
        return
    end
    self._last_shot_time = now

    Physics.shootVoxel(self:eyePosition(), self:viewDirection(), self.shoot_range, self.shoot_energy, 0.2)
end

return player
