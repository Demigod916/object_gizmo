Config = {}

-- Colour of the outline drawn around the entity being manipulated.
-- Values are RGBA, each between 0 and 255.
Config.outlineColor = {
	r = 255,
	g = 255,
	b = 255,
	a = 255
}

-- Outline shader used to render the highlight.
-- 0 = default (hard edge), 1 = softer/filled edge.
Config.outlineShader = 0

-- Peds cannot be outlined, so they are made translucent instead.
-- Alpha applied to a ped while the gizmo is active (0 - 255).
Config.pedAlpha = 200

-- Allow scaling mode ([S] key).
-- Note: scaling does not affect collisions and resets once physics are applied.
Config.enableScale = false

-- Enable the debug tooling (the /testGizmo command).
-- Leave this off on a live server: the command lets any player spawn objects.
Config.debug = false
