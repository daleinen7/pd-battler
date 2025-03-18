-- Playdate Battler - Smooth Staggered Movement (Fixed)

-- Load Playdate SDK
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx = playdate.graphics

-- Define hero and enemy sprites
heroes = {}
enemies = {}

-- Track hero positions
heroPositions = "back" -- Can be "back" or "front"

-- Function to create and position sprites
function createSprite(x, y)
    local sprite = gfx.sprite.new()
    sprite:setSize(20, 20) -- Placeholder block
    sprite:moveTo(x, y)
    sprite:setImage(gfx.image.new(20, 20, gfx.kColorBlack))
    sprite:add() -- Adds sprite to the Playdate sprite system
    return sprite
end

-- Create three heroes on the left side
for i = 1, 3 do
    local yPos = 50 + (i * 30)
    heroes[i] = createSprite(50, yPos)
end

-- Create three enemies on the right side
for i = 1, 3 do
    local yPos = 50 + (i * 30)
    enemies[i] = createSprite(250, yPos)
end

-- Function to smoothly move a hero to a new position
function animateHero(hero, targetX, delay)
    playdate.timer.performAfterDelay(delay, function()
        local moveTimer = playdate.timer.new(300, hero.x, targetX, playdate.easingFunctions.inOutQuad)
        moveTimer.updateCallback = function(t)
            hero:moveTo(t.value, hero.y)
        end
    end)
end

-- Function to move heroes forward/back with staggered animation
function moveHeroes(direction)
    if direction == "forward" and heroPositions == "back" then
        heroPositions = "front"
        for i, hero in ipairs(heroes) do
            animateHero(hero, 70, (i - 1) * 100) -- Staggered timing
        end
    elseif direction == "back" and heroPositions == "front" then
        heroPositions = "back"
        for i, hero in ipairs(heroes) do
            animateHero(hero, 50, (i - 1) * 100) -- Staggered timing
        end
    end
end

-- Main update loop
function playdate.update()
    gfx.clear()

    -- Ensure sprites update properly
    gfx.sprite.update()

    -- Display text info
    gfx.drawText("Heroes: " .. heroPositions, 10, 10)
    gfx.drawText("Press Left/Right to Move", 10, 30)

    -- Handle Input
    if playdate.buttonJustPressed(playdate.kButtonRight) then
        moveHeroes("forward")
    elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
        moveHeroes("back")
    end

    -- Update timers for smooth animation
    playdate.timer.updateTimers()
end
