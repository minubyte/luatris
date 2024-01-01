require "scripts.utils"

minoShapes = {
    ["I"] = {
        {0, 0, 0, 0},
        {1, 1, 1, 1},
        {0, 0, 0, 0},
        {0, 0, 0, 0}
    },
    ["J"] = {
        {1, 0, 0},
        {1, 1, 1},
        {0, 0, 0}
    },
    ["L"] = {
        {0, 0, 1},
        {1, 1, 1},
        {0, 0, 0}
    },
    ["O"] = {
        {1, 1},
        {1, 1}
    },
    ["S"] = {
        {0, 1, 1},
        {1, 1, 0},
        {0, 0, 0}
    },
    ["T"] = {
        {0, 1, 0},
        {1, 1, 1},
        {0, 0, 0}
    },
    ["Z"] = {
        {1, 1, 0},
        {0, 1, 1},
        {0, 0, 0}
    },
}

minoNames = {"I", "J", "L", "O", "S", "T", "Z"}

minoColors = {
    ["I"] = "#42AFE1ff",
    ["J"] = "#1165B5ff",
    ["L"] = "#F38927ff",
    ["O"] = "#F6D03Cff",
    ["S"] = "#51B84Dff",
    ["T"] = "#B94BC6ff",
    ["Z"] = "#EB4F65ff"
}

currentMino = {}

IKicks = {
    ["01"] = {{0, 0}, {-2, 0}, {1, 0}, {-2,-1}, {1,2}},
    ["10"] = {{0, 0}, {2, 0}, {-1, 0}, {2,1}, {-1,-2}},
    ["12"] = {{0, 0}, {-1, 0}, {2, 0}, {-1,2}, {2,-1}},
    ["21"] = {{0, 0}, {1, 0}, {-2, 0}, {1,-2}, {-2,1}},
    ["23"] = {{0, 0}, {2, 0}, {-1, 0}, {2,1}, {-1,-2}},
    ["32"] = {{0, 0}, {-2, 0}, {1, 0}, {-2,-1}, {1,2}},
    ["30"] = {{0, 0}, {1, 0}, {-2, 0}, {1,-2}, {-2,1}},
    ["03"] = {{0, 0}, {-1, 0}, {2, 0}, {-1,2}, {2,-1}}
}
JLSTZKicks = {
    ["01"] = {{0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}},
    ["10"] = {{0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}},
    ["12"] = {{0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}},
    ["21"] = {{0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}},
    ["23"] = {{0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}},
    ["32"] = {{0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}},
    ["30"] = {{0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}},
    ["03"] = {{0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}}
}

function currentMino:set(name)
    -- math.randomseed(os.clock())
    -- self.name = minoNames[math.random(#minoNames)]
    self.name = name
    self.shape = copy(minoShapes[self.name])
    self.y = 0
    self.x = math.floor(10/2-#self.shape/2)
    self.roatationState = 0
end

function checkCollision(mino, board) 
    for y, row in ipairs(mino.shape) do
        for x, dot in ipairs(row) do
            if dot ~= 0 then
                if mino.y+y > 23 then
                    return true
                else
                    if mino.y+y > 1 then
                        if board[mino.y+y][mino.x+x] ~= 0 then
                            return true
                        end
                    end
                end
                if mino.x+x > 10 or mino.x+x < 1 then
                    return true
                end
            end
        end
    end
    return false
end

function currentMino:move(board, mx, my)
    local tempMino = copy(self)
    tempMino.x = tempMino.x+mx
    tempMino.y = tempMino.y+my
    if checkCollision(tempMino, board) then
        return false
    else
        self.x = self.x+mx
        self.y = self.y+my
        return true
    end
end

function currentMino:rotate(board, dir)
    local tempRotationState = self.roatationState
    local tempWallKick = {}
    
    local wallKick = {}
    
    tempRotationState = tempRotationState+dir
    if tempRotationState >= 4 then
        tempRotationState = tempRotationState-4
    elseif tempRotationState < 0 then
        tempRotationState = tempRotationState+4
    end
    
    if dir == 2 then
        wallKick = {{0, 0}}
    else
        if self.name == "I" then
            wallKick = IKicks[tostring(self.roatationState)..tostring(tempRotationState)]
        elseif self.name == "O" then
            return
        else
            wallKick = JLSTZKicks[tostring(self.roatationState)..tostring(tempRotationState)]
        end
        
        if wallKick == nil then
            return
        end
    end


    for i, kick in ipairs(wallKick) do
        local tempMino = copy(self)
        for i=1, dir do
            tempMino.shape = rotateMatrix(tempMino.shape)
        end
        if tempMino:move(board, kick[1], -kick[2]) then
            self.x = tempMino.x
            self.y = tempMino.y
            self.shape = tempMino.shape
            self.roatationState = tempRotationState
            break
        end
    end
end