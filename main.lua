require "scenes.game"
require "scenes.menu"


function love.load()
    sceneLoader = {}
    function sceneLoader:setScene(name)
        if scenes[name] ~= nil then
            currentScene = scenes[name]
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
end

function love.update(dt)
    currentScene.update(dt*60) 
end

function love.keypressed(key)
    currentScene.keypressed(key) 
end

function love.mousepressed(x, y, button)
    currentScene.mousepressed(x, y, button)
end
