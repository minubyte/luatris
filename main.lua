require "scenes.game"
require "scenes.menu"
require "scripts.utils"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    sceneLoader = {
        animation = 0,
        animationTime = 15,
        animationTimer = 0,
        animationType = "off",
        targetScene = ""
    }
    function sceneLoader:setScene(name)
        self.animation = 0
        self.animationTimer = 0
        self.animationType = "in"
        self.targetScene = name
    end
    function sceneLoader:changeScene()
        if scenes[self.targetScene] ~= nil then
            currentScene = scenes[self.targetScene]
            currentScene.load(self)
        end
    end
    
    scenes = {
        ["game"] = game,
        ["menu"] = menu
    }

    currentScene = scenes["menu"]
    currentScene.load(sceneLoader)
end

function love.draw()
    currentScene.draw()
    love.graphics.setColor(0, 0, 0, 1)
    if sceneLoader.animationType == "in" then
        love.graphics.rectangle("fill", 0, 0, sceneLoader.animation, screenH)
    elseif sceneLoader.animationType == "out" then
        love.graphics.rectangle("fill", screenW-sceneLoader.animation, 0, screenW, screenH)
    end
end

function love.update(dt)
    dt = dt*60
    if sceneLoader.animationType == "in" then
        sceneLoader.animationTimer = sceneLoader.animationTimer+dt
        -- sceneLoader.animation = sceneLoader.animation+(screenW-sceneLoader.animation)/5*dt
        sceneLoader.animation = easeOutExpo(sceneLoader.animationTimer/sceneLoader.animationTime)*screenW
        if sceneLoader.animationTimer >= sceneLoader.animationTime then
            sceneLoader.animationType = "out"
            sceneLoader:changeScene()
        end
    elseif sceneLoader.animationType == "out" then
        -- sceneLoader.animation = sceneLoader.animation-sceneLoader.animation/5*dt
        sceneLoader.animationTimer = sceneLoader.animationTimer-dt
        sceneLoader.animation = easeOutExpo(sceneLoader.animationTimer/sceneLoader.animationTime)*screenW
    end
    currentScene.update(dt)
end

function love.keypressed(key)
    currentScene.keypressed(key)
end

function love.mousepressed(x, y, button)
    if sceneLoader.animationType == "off" then
        currentScene.mousepressed(x, y, button)
    end
end