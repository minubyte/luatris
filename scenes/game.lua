require "scripts.mino"
require "scripts.board"
require "scripts.utils"

game = {}

function game.load(sceneLoader)
    screenW, screenH = love.graphics.getDimensions()
    love.graphics.setDefaultFilter("nearest", "nearest")

    dotSize = 24
    gravity = 1/64
    gravityTimer = 0

    controls = {
        das = 7,
        arr = 1,
        sdas = 6,
        sarr = 0
    } 
    timers = {
        das = 0,
        arr = 0,
        sdas = 0,
        sarr = 0
    }

    board:set()
    currentMino:set(table.remove(board.next, 1))

    laneFx = {{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}}
    clearFx = 0
    clearFxImg = love.graphics.newImage("data/clearFx.png")

    camOffset = {screenW/2-11*dotSize/2, screenH/2-26*dotSize/2}

    sceneLoader = sceneLoader
end

function game.draw()
    love.graphics.translate(camOffset[1], camOffset[2])
    love.graphics.setBackgroundColor(hexToRGB("#2d333bff"))
    
    for i=1, #laneFx do
        love.graphics.setColor(1, 1, 1, laneFx[i][1]/6)
        love.graphics.rectangle("fill", i*dotSize, 4*dotSize, dotSize, dotSize*(laneFx[i][2]-4))
    end
    if clearFx > 0 then
        love.graphics.setColor(1, 1, 1, clearFx)
        love.graphics.draw(clearFxImg, dotSize, dotSize*4)
    end

    for y=1, 23 do
        for x=1, 10 do
            local dot = board.grid[y][x]
            if dot ~= 0 then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(skinImg, minoImgs[dot], x*dotSize, y*dotSize)
            elseif y > 3 then
                love.graphics.setColor(1, 1, 1, 0.1)
                love.graphics.rectangle("line", x*dotSize, y*dotSize, dotSize, dotSize)
            end
        end
    end
    for i, mino in ipairs(board.next) do
        if i <= 5 then
            local minoShape = minoShapes[mino]
            local offset = {0, 0} 
            if mino == "I" then
                offset = {-0.5, -0.5}
            end 
            if mino == "O" then
                offset = {0.5, 0}
            end
            for y, row in ipairs(minoShape) do
                for x, dot in ipairs(row) do
                    if dot ~= 0 then
                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.draw(skinImg, minoImgs[mino], (x+12+offset[1])*dotSize, (y+i*3+offset[2])*dotSize)
                    end
                end
            end
        end
    end
    if board.hold ~= nil then
        local offset = {0, 0} 
        if board.hold == "I" then
            offset = {-0.5, -0.5}
        end
        if board.hold == "O" then
            offset = {0.5, 0}
        end
        for y, row in ipairs(minoShapes[board.hold]) do
            for x, dot in ipairs(row) do
                if dot ~= 0 then
                    love.graphics.setColor(1, 1, 1, 1)
                    if board.canHold then
                        love.graphics.draw(skinImg, minoImgs[board.hold], (-5+x+offset[1])*dotSize, (3+y+offset[2])*dotSize)
                    else
                        love.graphics.draw(skinImg, minoImgs["X"], (-5+x+offset[1])*dotSize, (3+y+offset[2])*dotSize)
                    end
                end
            end
        end
    end
    local shadowMino = copy(currentMino)
    for i=1, 23 do
        if not shadowMino:move(board, 0, 1) then
            break 
        end
    end 
    for y, row in ipairs(shadowMino.shape) do
        for x, dot in ipairs(row) do
            if dot ~= 0 then
                love.graphics.setColor(1, 1, 1, 0.7)
                love.graphics.draw(skinImg, minoImgs["X"],(x+shadowMino.x)*dotSize, (y+shadowMino.y)*dotSize)
            end
        end
    end 
    if board.height <= 6 then
        for y, row in ipairs(minoShapes[board.next[1]]) do
            for x, dot in ipairs(row) do
                if dot ~= 0 then
                    love.graphics.setColor({1, 0.1, 0.2, 0.5}) 
                    love.graphics.rectangle("fill", (x+math.floor(10/2-#minoShapes[board.next[1]]/2))*dotSize, (y)*dotSize, dotSize, dotSize)
                end
            end
        end
    end
    for y, row in ipairs(currentMino.shape) do
        for x, dot in ipairs(row) do
            if dot ~= 0 then
                -- love.graphics.setColor(hexToRGB(minoColors[currentMino.name])) 
                -- love.graphics.rectangle("fill", (x+currentMino.x)*dotSize, (y+currentMino.y)*dotSize, dotSize, dotSize)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(skinImg, minoImgs[currentMino.name], (x+currentMino.x)*dotSize, (y+currentMino.y)*dotSize)
            end
        end
    end

    -- GUI
    love.graphics.translate(-camOffset[1], -camOffset[2])

    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.setFont(fontN)
    love.graphics.print(tostring(board.targetLines), (screenW+dotSize-fontN:getWidth(tostring(board.targetLines)))/2, dotSize*7)
    love.graphics.setColor(1, 1, 1, 1)
end

function drop()
    clearCount = board:place(currentMino)["clearCount"]
    if clearCount == 0 then
        for y, row in ipairs(currentMino.shape) do
            for x, dot in ipairs(row) do
                if dot ~= 0 then
                    if laneFx[currentMino.x+x][1] ~= 1 then
                        laneFx[currentMino.x+x][1] = 1
                        if laneFx[currentMino.x+x][2] > currentMino.y+y then 
                            laneFx[currentMino.x+x][2] = currentMino.y+y
                        end
                    end
                end
            end
        end
    else
        clearFx = 1
    end
    currentMino:set(board:getNext())
end

function game.update(dt)
    for i=1, #laneFx do
        if laneFx[i][1] > 0 then
            laneFx[i][1] = laneFx[i][1]-dt/10
        else
            laneFx[i][2] = #board.grid
        end
    end
    if clearFx > 0 then
        clearFx = clearFx-dt/20
    end

    gravityTimer = gravityTimer+gravity*dt
    if gravityTimer >= 1 then
        gravityTimer = 0
        currentMino:move(board, 0, 1)
    end

    if currentMino:onGround(board) then
        currentMino.lockDelay = currentMino.lockDelay+dt
        if currentMino.lockDelay >= 60 then
            drop()
        end
    end
    
    if board.topOut then
        board:set()
        currentMino:set(board:getNext())
    end

    local dir = 0
    if love.keyboard.isDown("right") then
        dir = 1
    end
    if love.keyboard.isDown("left") then
        dir = -1
    end
    if dir ~= 0 then
        if timers.das > 0 then
            timers.das = timers.das-dt
        end
        if timers.das <= 0 then
            if controls.arr <= 0 then
                for i=1, 10 do
                    if not currentMino:move(board, dir, 0) then
                        break 
                    end
                end
            else
                timers.arr = timers.arr+dt
                for i=1, 10 do 
                    if timers.arr >= controls.arr then
                        timers.arr = timers.arr-controls.arr
                        currentMino:move(board, dir, 0)
                    end
                end
            end
        end
    end
    if love.keyboard.isDown("down") then
        if timers.sdas > 0 then
            timers.sdas = timers.sdas-dt
        end
        if timers.sdas <= 0 then
            if controls.sarr <= 0 then
                for i=1, 20 do
                    if not currentMino:move(board, 0, 1) then
                        break 
                    end
                end
            else
                timers.sarr = timers.sarr+dt
                for i=1, 10 do 
                    if timers.sarr >= controls.sarr then
                        timers.sarr = timers.sarr-controls.sarr
                        currentMino:move(board, 0, 1)
                    end
                end
            end
        end
    end
end

function game.keypressed(key)
    if key == "right" then
        currentMino:move(board, 1, 0)
        timers.das = controls.das
        timers.arr = 0
    end
    if key == "left" then
        currentMino:move(board, -1, 0)
        timers.das = controls.das
        timers.arr = 0
    end
    if key == "lshift" then
        if board.canHold then
            holdMinoName = board:swapHold(currentMino.name)
            if holdMinoName ~= nil then
                currentMino:set(holdMinoName)
            else
                currentMino:set(board:getNext())
            end
        end
        
    end
    if key == "up" then
        currentMino:rotate(board, 1)
    end
    if key == "lctrl" then
        currentMino:rotate(board, 3)
    end
    if key == "a" then
        currentMino:rotate(board, 2)
    end
    if key == "down" then
        currentMino:move(board, 0, 1)
        timers.sdas = controls.sdas
        timers.sarr = 0
    end
    if key == "space" then
        for i=1, 23 do
            if not currentMino:move(board, 0, 1) then
                break 
            end
        end 
        drop()
    end
    if key == "r" then
        board:set()
        currentMino:set(board:getNext())
    end
end

function game.mousepressed(x, y, button)
    
end