-- Playdate Battler - Adding Projectiles

-- Load Playdate SDK
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx = playdate.graphics

-- Define hero and enemy sprites
heroes = {}
enemies = {}
projectiles = {} -- Track active projectiles

-- Track hero positions
heroPositions = "back" -- Can be "back" or "front"
heroStance = {} -- Tracks whether each hero is standing or kneeling
heroBaseY = {} -- Stores original Y positions
heroImages = { -- Stores the images for different stances
  standing = gfx.image.new(20, 40, gfx.kColorBlack),
  kneeling = gfx.image.new(20, 20, gfx.kColorBlack)
}

-- Function to create and position sprites
function createSprite(x, y)
  local sprite = gfx.sprite.new()
  sprite:setImage(heroImages.kneeling) -- Default to kneeling
  sprite:moveTo(x, y)
  sprite:add() -- Adds sprite to the Playdate sprite system
  return sprite
end

-- Create three heroes on the left side
for i = 1, 3 do
  local yPos = 50 + (i * 50)
  heroes[i] = createSprite(50, yPos)
  heroStance[i] = "kneeling" -- Default to kneeling
  heroBaseY[i] = yPos -- Store base Y position
end

-- Create three enemies on the right side
for i = 1, 3 do
  local yPos = 50 + (i * 50)
  enemies[i] = createSprite(250, yPos)
end

-- Function to create a projectile
function createProjectile(startX, startY, targetX, targetY)
  local projectile = gfx.sprite.new()
  projectile:setSize(5, 5)
  projectile:moveTo(startX, startY)
  projectile:setImage(gfx.image.new(5, 5, gfx.kColorBlack))
  projectile:add()

  -- Animate projectile movement
  local moveTimer = playdate.timer.new(500, startX, targetX, playdate.easingFunctions.linear)
  moveTimer.updateCallback = function(t)
    local progress = (t.value - startX) / (targetX - startX) -- Normalize progress
    local newY = startY + (targetY - startY) * progress -- Interpolate Y
    projectile:moveTo(t.value, newY)
  end

  -- Remove projectile when it reaches target
  moveTimer.timerEndedCallback = function()
    projectile:remove()
  end

  table.insert(projectiles, projectile)
end

-- Function to fire projectiles from heroes
function fireProjectiles()
  for i, hero in ipairs(heroes) do
    local targetEnemy = enemies[i] -- Simple targeting (1-to-1 matchup)
    if targetEnemy then
      createProjectile(hero.x + 15, hero.y, targetEnemy.x - 15, targetEnemy.y)
    end
  end
end

-- Function to move heroes forward/back with stagger
function moveHeroes(direction)
  local targetX = (direction == "forward") and 70 or 50
  if direction == "forward" and heroPositions == "back" then
    heroPositions = "front"
  elseif direction == "back" and heroPositions == "front" then
    heroPositions = "back"
  else
    return -- No movement needed
  end

  for i, hero in ipairs(heroes) do
    local yOffset = (heroStance[i] == "standing") and -10 or 0 -- Adjust based on stance
    playdate.timer.performAfterDelay((i - 1) * 100, function()
      hero:moveTo(targetX, heroBaseY[i] + yOffset)
    end)
  end
end

-- Function to toggle stance (stand/kneel)
function toggleStance()
  for i, hero in ipairs(heroes) do
    if heroStance[i] == "kneeling" then
      heroStance[i] = "standing"
      hero:setImage(heroImages.standing) -- Change sprite image
      hero:moveTo(hero.x, heroBaseY[i] - 10) -- Move up slightly to reflect stance
    else
      heroStance[i] = "kneeling"
      hero:setImage(heroImages.kneeling) -- Change sprite image
      hero:moveTo(hero.x, heroBaseY[i]) -- Reset to base Y
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
  gfx.drawText("Press Left/Right to Move, Up/Down to Stand/Kneel", 10, 30)
  gfx.drawText("Press A to Fire", 10, 50)

  -- Handle Input
  if playdate.buttonJustPressed(playdate.kButtonRight) then
    moveHeroes("forward")
  elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
    moveHeroes("back")
  elseif playdate.buttonJustPressed(playdate.kButtonUp) or playdate.buttonJustPressed(playdate.kButtonDown) then
    toggleStance()
  elseif playdate.buttonJustPressed(playdate.kButtonA) then
    fireProjectiles()
  end

  -- Update timers for smooth animations
  playdate.timer.updateTimers()
end
