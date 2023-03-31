import "stringUtil"
import "listUtil"

landscape = file.loadImage("morning-mood-autumn-morning-g830d5e964_1280.jpg")
windowFrame = file.loadImage("window-gaf5aae649_1280.png")
fogMask = file.loadImage("fogmask.png")

svgPaths = [
"M39.212,64.654L34.225,65.776L33.152,68.593L33.878,69.83L32.792,71.373L33.556,72.855L34.705,74.403L33.033,76.999L31.638,82.924L30.66,92.038L31.783,96.501L34.771,97.61L37.263,96.361L38.907,89.868L38.374,84.86L37.656,83.445L37.249,76.827L36.746,74.241L39.388,68.565L39.212,64.654Z",
"M50.666,83.594L52.197,83.462L52.923,85.98L52.866,88.872L54.18,91.762L56.12,97.347L53.665,98.402L51.756,100.62L47.825,99.946L47.261,94.392L48.853,89.376L48.853,87.647L49.327,85.825L50.666,83.594Z",
"M50.436,67.54L52.868,68.685L52.692,70.305L52.037,70.712L51.797,72.701L50.442,73.663L49.137,72.976L49.109,70.701L50.436,67.54Z",
"M59.631,65.927L64.052,62.15L65.647,64.314L66.392,66.786L64.888,68.544L63.904,69.809L60.894,69.669L59.631,65.927Z",
"M65.442,69.426L66.006,70.85L65.473,74.653L66.059,76.076L67.203,80.265L66.773,81.687L67.454,82.439L68.066,89.213L67.299,93.145L61.964,94.89L59.486,93.339L59.412,90.329L59.923,86.87L61.895,79.088L62.193,75.561L62.834,74.114L62.834,71.963L65.442,69.426Z",
"M17.791,33.029L14.047,31.597L11.921,31.676L6.283,36.367L2.526,44.032L4.078,47.122L6.793,49.634L10.595,49.042L13.128,45.594L13.974,41.846L15.611,38.36L15.862,36.099L17.871,34.185L17.791,33.029Z",
"M42.357,4.749L46.646,9.972L49.851,13.279L52.025,14.522L49.675,16.789L48.912,19.897L46.642,24.912L43.655,27.306L42.2,31.371L40.82,34.178L31.041,35.651L26.873,32.436L27.089,29.927L21.79,27.472L19.746,23.835L20.335,20.613L24.244,14.143L27.484,10.976L34.38,6.804L34.914,5.548L38.881,4.327L42.357,4.749Z",
"M57.69,4.637L61,3.007L64.646,3.873L67.59,7.106L70.649,12.829L70.357,16.556L70.783,18.515L72.394,22.278L74.974,33.143L75.269,40.62L72.738,47.02L68.307,48.732L66.686,50.525L65.211,51.969L62.397,52.215L58.981,54.887L58.275,53.712L56.302,57.082L47.356,57.714L46.451,56.309L42.783,59.204L37.153,58.26L34.288,52.026L35.156,45.391L35.689,43.629L43.712,39.726L49.679,40.825L52.091,40.857L57.728,39.599L59.553,38.072L60.638,34.697L62.726,32.286L62.563,31.102L61.851,28.137L63.405,27.319L61.563,26.934L59.767,26.432L57.848,22.418L57.442,18.861L57.47,15.651L56.715,12.708L57.075,9.077L57.69,4.637Z",
"M76.002,66.152L75.184,62.889L75.208,59.402L76.852,58.749L78.281,56.704L78.571,59.131L79.492,58.468L80.613,59.585L79.952,61.242L81.073,61.427L81.073,62.782L82.139,63.927L82.139,66.689L83.24,66.587L84.519,72.92L84.117,75.695L82.088,78.17L80.273,78.335L75.886,75.457L75.992,72.766L75.416,70.632L75.392,68.331L76.002,66.152Z",
""]

// Define hand object

hand = {}
hand.pointList = []
hand.allPoints = []
hand.width = 0
hand.height = 0

hand.init = function(svgPaths,scale=1)
	
	// Given a path "line", parse it and return a list of points
	parsePath = function(pathLine,scale)
		// Split by "L"(line) commands
		rawParts = pathLine.split("L")
		points = []
		for p in rawParts
			rawPoint = ""
			if p.startsWith("M") then
				// Skip the initial (M)ove
				rawPoint = p[1:]
			else if p.endsWith("Z") then
				// Skip the final "Z"
				rawPoint = p[:-1]
			else
				rawPoint = p
			end if
			coordsStr = rawPoint.split(",")
			x = parseNumber(coordsStr[0])*scale
			y = parseNumber(coordsStr[1])*scale
			points.push [x,y]
		end for
		return points
	end function
	
	self.pointsList = []
	// min/max values will be used to compute width/height
	minX = 0
	minY = 0
	maxX = 0
	maxY = 0
	for pathLine in svgPaths
		if pathLine == "" then break
		points = parsePath(pathLine,scale)
		self.pointsList.push points
		// Compute min/max coordinates
		// Store into allPoints
		for p in points
			x = p[0]
			y = p[1]
			if x > maxX then maxX = x
			if y > maxY then maxY = y
			if minX == null or x < minX then minX = x
			if minY == null or y < minY then minY = y
			self.allPoints.push [x,y]
		end for
	end for	
	// Compute width / height
	self.width = maxX - minX
	self.height = maxY - minY
	
end function

hand.drawCentered = function(x,y,aColor=null)
	if aColor == null then aColor = color.white
	for pathPoints in self.pointsList
		translatedPoints = []
		for pair in pathPoints
			tx = pair[0] + x - self.width / 2
			ty = pair[1] + y - self.height / 2
			translatedPoints.push [tx,ty]
		end for
		gfx.fillPoly translatedPoints,aColor
	end for	
end function

hand.addDrops = function(x,y)
	randomPoints = []
	amount = 4 + rnd * 4
	for i in range(0,amount)
		p = self.allPoints.any
		px = p[0] + x - self.width / 2
		py = p[1] + y - self.height / 2
		randomPoints.push [px,py]
		Drops.addDrop px,py
	end for
end function

// Define drops

Drops = {}
Drops.drops = []

Drops.addDrop = function(x,y)
	drop = new Drop
	drop.init x,y
	self.drops.push drop
end function

Drops.update = function()
	activeDrops = []
	for d in self.drops
		d.update
		if not d.isDone then activeDrops.push d
	end for
	self.drops = activeDrops
end function

Drop = {}
Drop.x = 0
Drop.startY = 0
Drop.startTs = 0
Drop.endY = 0
Drop.endTs = 0
Drop.pixelsPerSecond = 5
Drop.length = 40
Drop.width = 1

Drop.addDrop = function(x,y)
	
end function

Drop.init = function(x,y)
	self.x = x
	self.startY = y
	self.width = 1 + rnd * 3
	self.startTs = time
	self.length = 30 + rnd * 100
	self.pixelsPerSecond = 3 + rnd * 10
	self.endTs = self.startTs + self.length / self.pixelsPerSecond
end function

Drop.update = function()
	deltaTs = time - self.startTs
	
	targetY = self.startY - self.pixelsPerSecond * deltaTs
	
	gfx.line self.x,self.startY,self.x,targetY,color.clear,self.width
	
end function

Drop.isDone = function()
	return time >= self.endTs
end function

// Helper functions

// Parse a string like "N.X", return N as number, discard ".X"
parseNumber = function(floatStr)
	parts = floatStr.split(".")
	// Return integer part
	intPart = parts[0]
	return val(intPart)
end function

// Setup displays

display(4).mode = displayMode.pixel
frameDsp = display(4)

// gfx is display(5), which is pixel already

display(6).mode = displayMode.pixel
landscapeDsp = display(6)

// Main program

text.clear
frameDsp.clear color.clear
landscapeDsp.clear color.clear
gfx.clear color.clear

landscapeDsp.drawImage landscape,0,0,960,640

//gfx.clear color.clear
gfx.drawImage fogMask,0,0

frameDsp.clear color.clear
frameDsp.drawImage windowFrame,0,0,960,640

hand.init svgPaths, 1.5

handColor = color.clear

clicked = 0
wasClicked = 0
while true
	
	// Handle click
	clicked = mouse.button
	if clicked and not wasClicked then
		hand.addDrops(mouse.x,mouse.y)
		prevPos = [-1,-1]
		// Process dragging
		while mouse.button
			pos = [mouse.x,mouse.y]
			if pos == prevPos then continue
			hand.drawCentered(mouse.x,mouse.y,handColor)
			prevPos = pos
			// Animate drops
			Drops.update
			yield
		end while
		hand.addDrops(mouse.x,mouse.y)
	end if
	wasClicked = clicked
	
	// Animate drops
	Drops.update
	
	yield	
end while


