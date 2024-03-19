local function random1(seedInp: number)
	-- Linear Congruential Generator parameters
	local m = 2^32
	local a = 1664525
	local c = 1013904223

	-- Initial seed
	local seed = seedInp or os.time() -- You can set your own seed here

	-- Function to generate random numbers
	seed = (a * seed + c) % m
	return seed / m

end

-- Simple hash function
local function hash(value)
	local h = 5381
	for i = 1, #value do
		h = (33 * h + string.byte(value, i)) % (2^32)
	end
	return h
end

local function random2(seed: number)
	local currentSeed = seed or os.time() -- Use current time as seed if not provided
	return (hash(tostring(currentSeed)) % 1000) / 1000 -- Generate a number between 0 and 1
end

local function ts(a: number) return tostring(a) end

function GetWhiteNoise(x: number, y: number, z: number)
	--[[local noise = {}
	for y2=1,y do
		noise[y] = {}
		for x2=1,x do
			
		end
	end]]


	--random2() -- Using random2

	local randomX = hash(ts(x))
	local randomY = hash(ts(y))
	local randomZ = hash(ts(z))
	return ((randomX + randomY + randomZ) % 1000) / 1000
end
















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
	local position = Vector3.new(x*4+2, (beginY+endY)*4/2, z*4+2)
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
	--workspace.Terrain:FillBlock(cframe, size, Enum.Material.Grass)
	local part = Instance.new("Part")
	part.Size = size
	part.CFrame = cframe
	part.Material = Enum.Material.Plastic
	part.Anchored = true
	part.Parent = workspace
end

local function makeChunk(chunkX: number, chunkZ: number)
	local rootPos = Vector3.new(chunkX*chunkScale, 0, chunkZ*chunkScale)
	chunks[chunkX][chunkZ] = true
	for x = 0, chunkScale-1 do
		for z = 0, chunkScale-1 do
			local cx = (chunkX*chunkScale)+x
			local cz = (chunkZ*chunkScale)+z
			--local noise = math.noise(seed, cx / xScale, cz / zScale)
			local noise = GetWhiteNoise(seed, cx / xScale, cz / zScale)
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


game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Wait()
	local c = plr.Character
	local part2 = plr.Character:FindFirstChild("HumanoidRootPart")
	if part2 then
		part2.Anchored = true
		workspace.Terrain:Clear()
		checkSurroundings(part2.Position)
		wait(3)
		part2.Anchored = false
	end
	while true do
		for _, p in pairs(game.Players:GetPlayers()) do
			if p.Character then
				local part = p.Character:FindFirstChild("HumanoidRootPart")
				if part then
					checkSurroundings(part.Position)
				end
			end
		end
		wait(0.3)
	end
end)
