--- @class Player : DynamicRigidbody
local player = {}

player.move_speed = 5.0
player.look_sensitivity = 0.12
player.min_pitch = -85.0
player.max_pitch = 85.0
player.shoot_range = 100.0
player.shoot_energy = 5000.0
player.fire_rate = 8.0

function player:begin()
    --- @type PlayerController
    local controller = self:find("PlayerController")

    if controller ~= nil then
        controller:setMouseLocked(true)
        print("Controller setMouseLocked set to " .. tostring(controller:isMouseLocked()))
    else
        error("Controller was nil")
    end
end

function player:destroy()
    --- @type PlayerController
    local controller = self:find("PlayerController")

    if controller ~= nil then
        controller:setMouseLocked(false)
        print("Controller setMouseLocked set to " .. tostring(controller:isMouseLocked()))
    end
end

--- @param action InputAction
--- @param event InputActionEvent
function player:onMove(action, event)
    local input = action:value()
    local velocity = player.linear_velocity
    local move = quat.fromEuler(vec3(0, 0, player.yaw or 0.0)) * vec3(input.x * player.move_speed, input.y * player.move_speed, 0)
    player:setLinearVelocity(vec3(move.x, move.y, velocity.z))
end

local function clamp(value, min_value, max_value)
    if value < min_value then
        return min_value
    elseif value > max_value then
        return max_value
    end
    return value
end

--- @param action InputAction
--- @param event InputActionEvent
function player:onAim(action, event)
    local delta = action:value()

    player.yaw = (player.yaw or 0.0) - delta.x * player.look_sensitivity
    player.pitch = clamp((player.pitch or 0.0) - delta.y * player.look_sensitivity, player.min_pitch, player.max_pitch)

    player:setRotation(quat.fromEuler(vec3(0, 0, player.yaw)))

    if player.camera == nil then
        player.camera = self:find("Camera")
    end
    if player.camera ~= nil then
        player.camera.rotation = quat.fromEuler(vec3(player.pitch, 0, 0))
    end
end

--- @param action InputAction
--- @param event InputActionEvent
function player:onShoot(action, event)
    if event ~= InputEvent.start and event ~= InputEvent.hold then
        return
    end

    local now = Time.uptime()
    local cooldown = 1.0 / player.fire_rate
    if player._last_shot_time ~= nil and (now - player._last_shot_time) < cooldown then
        return
    end
    player._last_shot_time = now

    if player.camera == nil then
        player.camera = self:find("Camera")
    end
    if player.camera == nil then
        return
    end

    local origin = player.camera.world_position
    local direction = player.camera.world_rotation * vec3(0, 1, 0)
    Physics.shootVoxel(origin, direction, player.shoot_range, player.shoot_energy, 0.2)
end

return player