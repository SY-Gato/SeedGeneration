--[[

THIS SCRIPT INTENDED FOR ROBLOX

Copyright SY-Gato, 2024.
Licensed under MIT.

]]

local chunks = {}

local seed = math.random()
local xScale = 20
local zScale = 20
local baseHeight = 20
local chunkScale = 10

function chunkExists(x, z)
	if not chunks[x] then chunks[x] = {} end
	return chunks[x][z]
end

local function mountLayer(x: number,y: number, z: number, material: Enum.Material)
	local beginY = -baseHeight
	local endY = y
	local cframe = CFrame.new(x*4+2, (beginY+endY)*4/2, z*4+2)
	--local size = Vector3.new(4, (endY-beginY)*4, 4)
	local size = Vector3.new(4, math.abs((endY-beginY)*4), 4)
	--[[print(typeof(cframe))
	print(typeof(size))
	print(size.X)
	print(size.Y)
	print(size.Z)
	print(cframe.X)
	print(cframe.Y)
	print(cframe.Z)]]
	workspace.Terrain:FillBlock(cframe, size, Enum.Material.Grass)
end

local function makeChunk(chunkX: number, chunkZ: number)
	local rootPos = Vector3.new(chunkX*chunkScale, 0, chunkZ*chunkScale)
	chunks[chunkX][chunkZ] = true
	for x = 0, chunkScale-1 do
		for z = 0, chunkScale-1 do
			local cx = (chunkX*chunkScale)+x
			local cz = (chunkZ*chunkScale)+z
			local noise = math.noise(seed, cx / xScale, cz / zScale)
			local cy = noise * baseHeight
			mountLayer(cx, cy, cz, Enum.Material.Grass)
		end
	end
end

local function checkSurroundings(location: Vector3)
	local chunkX = math.floor(location.X / 4 / chunkScale)
	local chunkZ = math.floor(location.Z / 4 / chunkScale)
	local range = math.max(1, 50 / chunkScale)
	for x = -range, range do
		for z = -range, range do
			local cx = chunkX + x
			local cz = chunkZ + z
			if not chunkExists(cx, cz) then
				makeChunk(cx, cz)
			end
			wait()
		end
	end
end


for i=0, 20 do
	for _, p in pairs(game.Players:GetPlayers()) do
		if p.Character then
			local part = p.Character:FindFirstChild("HumanoidRootPart")
			if part then
				checkSurroundings(part.Position)
			end
		end
	end
	wait(1)
end
