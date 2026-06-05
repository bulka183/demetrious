-- 🗡️ Demetrious Johnson - Knife Arena Game (Lua)
-- Advanced knife fighting game with hitbox and auto punch mechanics

KnifeArena = {}
KnifeArena.__index = KnifeArena

function KnifeArena.new()
    local self = setmetatable({}, KnifeArena)
    
    -- Player properties
    self.player = {
        x = 100,
        y = 200,
        width = 60,
        height = 80,
        health = 100,
        maxHealth = 100,
        color = {0, 1, 0} -- Green
    }
    
    -- Enemy properties
    self.enemy = {
        x = 700,
        y = 200,
        width = 60,
        height = 80,
        health = 100,
        maxHealth = 100,
        color = {1, 0, 0} -- Red
    }
    
    -- Game settings
    self.hitboxSize = 60
    self.maxHitboxSize = 200
    self.minHitboxSize = 20
    self.damagePerPunch = 10
    self.maxDamage = 50
    self.minDamage = 5
    
    -- Game state
    self.totalDamage = 0
    self.isAutoPunching = false
    self.autoPunchTimer = 0
    self.autoPunchInterval = 0.4
    self.showHitbox = false
    self.hitboxTimer = 0
    self.hitboxDisplayDuration = 0.5
    self.floatingTexts = {}
    self.canPunch = true
    self.punchCooldown = 0
    
    -- Mobile support
    self.isMobilePunching = false
    self.mobilePunchTimer = 0
    
    return self
end

-- Increase hitbox size without increasing character size
function KnifeArena:increaseHitbox(amount)
    self.hitboxSize = math.min(self.maxHitboxSize, self.hitboxSize + amount)
end

-- Decrease hitbox size
function KnifeArena:decreaseHitbox(amount)
    self.hitboxSize = math.max(self.minHitboxSize, self.hitboxSize - amount)
end

-- Set hitbox size
function KnifeArena:setHitboxSize(size)
    self.hitboxSize = math.max(self.minHitboxSize, math.min(self.maxHitboxSize, size))
end

-- Set damage per punch
function KnifeArena:setDamage(damage)
    self.damagePerPunch = math.max(self.minDamage, math.min(self.maxDamage, damage))
end

-- Perform a punch attack
function KnifeArena:punch()
    if not self.canPunch then return end
    
    self.canPunch = false
    self.punchCooldown = 0.1
    
    -- Display hitbox
    self.showHitbox = true
    self.hitboxTimer = self.hitboxDisplayDuration
    
    -- Deal damage
    local damage = self.damagePerPunch
    self.enemy.health = math.max(0, self.enemy.health - damage)
    self.totalDamage = self.totalDamage + damage
    
    -- Create floating damage text
    table.insert(self.floatingTexts, {
        x = self.enemy.x + 30,
        y = self.enemy.y - 50,
        text = "-" .. damage .. " HP",
        timer = 1.0,
        duration = 1.0,
        color = {1, 0, 0}
    })
    
    -- Enemy hit animation
    self.enemy.hitTimer = 0.2
end

-- Toggle auto punch on/off
function KnifeArena:toggleAutoPunch()
    self.isAutoPunching = not self.isAutoPunching
    self.autoPunchTimer = 0
    return self.isAutoPunching
end

-- Start auto punch (for mobile hold)
function KnifeArena:startMobilePunch()
    self.isMobilePunching = true
    self.mobilePunchTimer = 0
end

-- Stop auto punch (for mobile release)
function KnifeArena:stopMobilePunch()
    self.isMobilePunching = false
end

-- Update game state
function KnifeArena:update(dt)
    -- Update punch cooldown
    if not self.canPunch then
        self.punchCooldown = self.punchCooldown - dt
        if self.punchCooldown <= 0 then
            self.canPunch = true
        end
    end
    
    -- Auto punch logic
    if self.isAutoPunching and self.enemy.health > 0 then
        self.autoPunchTimer = self.autoPunchTimer - dt
        if self.autoPunchTimer <= 0 then
            self:punch()
            self.autoPunchTimer = self.autoPunchInterval
        end
    end
    
    -- Mobile punch logic (continuous while held)
    if self.isMobilePunching and self.enemy.health > 0 then
        self.mobilePunchTimer = self.mobilePunchTimer - dt
        if self.mobilePunchTimer <= 0 then
            self:punch()
            self.mobilePunchTimer = 0.3
        end
    end
    
    -- Update hitbox display
    if self.showHitbox then
        self.hitboxTimer = self.hitboxTimer - dt
        if self.hitboxTimer <= 0 then
            self.showHitbox = false
        end
    end
    
    -- Update floating damage texts
    for i = #self.floatingTexts, 1, -1 do
        local text = self.floatingTexts[i]
        text.timer = text.timer - dt
        text.y = text.y - 50 * dt
        
        if text.timer <= 0 then
            table.remove(self.floatingTexts, i)
        end
    end
    
    -- Update enemy hit animation
    if self.enemy.hitTimer then
        self.enemy.hitTimer = self.enemy.hitTimer - dt
        if self.enemy.hitTimer <= 0 then
            self.enemy.hitTimer = nil
        end
    end
end

-- Handle mouse/touch input
function KnifeArena:handleInput(key)
    if key == "space" or key == "return" then
        self:punch()
    elseif key == "a" then
        self:toggleAutoPunch()
    elseif key == "r" then
        self:resetGame()
    elseif key == "h" then
        self:fullHeal()
    elseif key == "up" then
        self:increaseHitbox(5)
    elseif key == "down" then
        self:decreaseHitbox(5)
    elseif key == "right" then
        self:setDamage(self.damagePerPunch + 5)
    elseif key == "left" then
        self:setDamage(self.damagePerPunch - 5)
    end
end

-- Reset game
function KnifeArena:resetGame()
    self.enemy.health = self.enemy.maxHealth
    self.totalDamage = 0
    self.isAutoPunching = false
    self.autoPunchTimer = 0
    self.isMobilePunching = false
    self.floatingTexts = {}
end

-- Full heal enemy
function KnifeArena:fullHeal()
    self.enemy.health = self.enemy.maxHealth
end

-- Draw game (for LÖVE 2D framework)
function KnifeArena:draw()
    -- Background
    love.graphics.clear(0.1, 0.1, 0.18)
    
    -- Arena background
    love.graphics.setColor(0.05, 0.05, 0.1)
    love.graphics.rectangle("fill", 50, 100, 800, 400)
    
    -- Arena border
    love.graphics.setColor(1, 0, 0)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", 50, 100, 800, 400)
    
    -- Draw hitbox if visible
    if self.showHitbox then
        love.graphics.setColor(1, 0, 0, 0.3)
        local hitboxOffsetX = (self.hitboxSize - self.enemy.width) / 2
        local hitboxOffsetY = (self.hitboxSize - self.enemy.height) / 2
        love.graphics.rectangle("fill", 
            self.enemy.x - hitboxOffsetX, 
            self.enemy.y - hitboxOffsetY, 
            self.hitboxSize, 
            self.hitboxSize)
        
        love.graphics.setColor(1, 0, 0)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", 
            self.enemy.x - hitboxOffsetX, 
            self.enemy.y - hitboxOffsetY, 
            self.hitboxSize, 
            self.hitboxSize)
    end
    
    -- Draw player
    love.graphics.setColor(self.player.color[1], self.player.color[2], self.player.color[3])
    love.graphics.rectangle("fill", self.player.x, self.player.y, self.player.width, self.player.height)
    love.graphics.setColor(0, 0.8, 0)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.player.x, self.player.y, self.player.width, self.player.height)
    
    -- Draw player icon
    love.graphics.setColor(0, 1, 0)
    love.graphics.printf("🟢", self.player.x + 10, self.player.y + 25, 40, "center")
    
    -- Draw enemy
    love.graphics.setColor(self.enemy.color[1], self.enemy.color[2], self.enemy.color[3])
    love.graphics.rectangle("fill", self.enemy.x, self.enemy.y, self.enemy.width, self.enemy.height)
    
    -- Enemy hit flash
    if self.enemy.hitTimer then
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("fill", self.enemy.x, self.enemy.y, self.enemy.width, self.enemy.height)
    end
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.enemy.x, self.enemy.y, self.enemy.width, self.enemy.height)
    
    -- Draw enemy icon
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("🔴", self.enemy.x + 10, self.enemy.y + 25, 40, "center")
    
    -- Draw floating damage texts
    love.graphics.setFont(love.graphics.newFont(20))
    for _, text in ipairs(self.floatingTexts) do
        local alpha = text.timer / text.duration
        love.graphics.setColor(text.color[1], text.color[2], text.color[3], alpha)
        love.graphics.printf(text.text, text.x - 20, text.y, 40, "center")
    end
    
    -- Draw HUD
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("🗡️ Demetrious Johnson", 50, 20, 800, "center")
    
    -- Health bar
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 100, 550, 700, 30)
    love.graphics.setColor(0, 1, 0)
    local healthPercent = self.enemy.health / self.enemy.maxHealth
    love.graphics.rectangle("fill", 100, 550, 700 * healthPercent, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 100, 550, 700, 30)
    
    -- Stats
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("Enemy Health: " .. self.enemy.health .. "/" .. self.enemy.maxHealth, 50, 600, 400, "left")
    love.graphics.printf("Total Damage: " .. self.totalDamage, 450, 600, 400, "left")
    
    -- Settings info
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Hitbox: " .. self.hitboxSize .. "px | Damage: " .. self.damagePerPunch, 50, 640, 800, "center")
    
    -- Status
    local autoPunchStatus = self.isAutoPunching and "ON" or "OFF"
    love.graphics.setColor(self.isAutoPunching and {1, 0.6, 0} or {0.2, 1, 0.2})
    love.graphics.printf("Auto Punch: " .. autoPunchStatus, 50, 670, 800, "center")
    
    -- Controls
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(0.5, 0.5, 0.5)
    local controlText = "SPACE/ENTER: Punch | A: Toggle Auto | R: Reset | H: Heal | ↑↓: Hitbox | ←→: Damage"
    love.graphics.printf(controlText, 50, 700, 800, "center")
end

-- Console output for non-LÖVE environments
function KnifeArena:printStats()
    print("\n=== 🗡️ Demetrious Johnson - Knife Arena ===")
    print("Enemy Health: " .. self.enemy.health .. "/" .. self.enemy.maxHealth)
    print("Total Damage Dealt: " .. self.totalDamage)
    print("Hitbox Size: " .. self.hitboxSize .. "px")
    print("Damage Per Punch: " .. self.damagePerPunch)
    print("Auto Punch: " .. (self.isAutoPunching and "ON" or "OFF"))
    print("=====================================\n")
end

-- LÖVE 2D Integration Example (uncomment to use)
--[[
function love.load()
    game = KnifeArena.new()
    love.window.setTitle("🗡️ Demetrious Johnson - Knife Arena")
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    game:handleInput(key)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        game:punch()
    end
end
]]

return KnifeArena