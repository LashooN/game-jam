class_name Consts

const TRAJECTORY_DT = 1.0 / 30.0

const GM = 1200000.0
const BULLET_COST = 0

enum MeteorType {
	CHONDRITE,
	IRON,
	COMET
}

const METEOR_DATA = {
	MeteorType.CHONDRITE: {
		"type": MeteorType.CHONDRITE,
		"chance": 0.6,
		"health": 50,
		"damage": 75,
		"can_split": true,
		"color": Color(0.288, 0.244, 0.194, 1.0),       # brownish grey
		"rx_mean": 1.0,
		"rx_std": 0.2,
		"ry_mean": 1.0,
		"ry_std": 0.2,
		"perturbation_std": 0.1,
		"num_points_range": [8, 12],
		"mass_range": [8, 12],
		"radius_range": [12, 14],
		"debris_value_range": [200, 600],      # common rock, low value
		
		"shader": {
			"scale": 18.0,
			"roughness": 0.75,
			"crack_intensity": 0.25,
			"crater_scale": 2.8,
			"glow_strength": 0.15
		},
	},
	MeteorType.IRON: {
		"type": MeteorType.IRON,
		"chance": 0.3,
		"health": 50,
		"damage": 100,
		"can_split": false,
		"color": Color(0.396, 0.416, 0.498, 1.0),       # dark metallic blue-grey
		"rx_mean": 1.0,
		"rx_std": 0.1,                        # rounder, denser
		"ry_mean": 1.0,
		"ry_std": 0.1,
		"perturbation_std": 0.05,             # smoother surface
		"num_points_range": [6, 8],           # fewer points, cleaner shape
		"mass_range": [20, 30],               # heavier
		"radius_range": [16, 18],             # large but fragile
		"debris_value_range": [1000, 2000],    # industrial metal, solid value
		
		"shader": {
			"scale": 22.0,
			"roughness": 0.25,
			"crack_intensity": 0.12,
			"crater_scale": 1.2,
			"glow_strength": 0.0
		}
	},
	MeteorType.COMET: {
		"type": MeteorType.COMET,
		"chance": 0.1,
		"health": 25,
		"damage": 50,
		"can_split": false,
		"color": Color(0.75, 0.88, 1.00),       # icy blue-white
		"rx_mean": 1.4,
		"rx_std": 0.2,                        # elongated
		"ry_mean": 0.6,
		"ry_std": 0.1,
		"perturbation_std": 0.25,             # jagged, irregular
		"num_points_range": [7, 10],
		"mass_range": [4, 8],                 # light
		"radius_range": [12, 16],             # large but fragile
		"debris_value_range": [0, 0],
		
		"shader": {
			"scale": 12.0,
			"roughness": 0.9,
			"crack_intensity": 0.35,
			"crater_scale": 0.8,
			"glow_strength": 0.6
		}
	},
}

const UPGRADES = {
	"magazine_capacity": {
		"title": "Magazine Capacity",
		"description": "More ammo, but slower reload",
		"costs": [3000, 6000, 10000, 20000],
		"values": [1, 2, 3, 4, 5],
		"unit": ""
	},
	"fire_rate": {
		"title": "Reload Speed",
		"description": "Base reload time per 1 ammo",
		"costs": [2000, 4000, 10000, 20000],
		"values": [3.0, 2.5, 2.0, 1.5, 1.0],
		"unit": "s"
	},
	"bullet_speed": {
		"title": "Bullet Velocity",
		"description": "Higher muzzle velocity, flatter trajectory (switch with scroll wheel)",
		"costs": [2000, 5000, 12000, 30000],
		"values": [100, 130, 160, 190, 230],
		"unit": ""
	},
	"engine_speed": {
		"title": "Engine Power",
		"description": "Faster movement, better maneuverability",
		"costs": [1000, 3000, 6000, 10000],
		"values": [10, 20, 30, 40, 50],
		"unit": ""
	},
	"prediction_time": {
		"title": "Trajectory Preview",
		"description": "See further into the future",
		"costs": [1500, 4000, 10000, 15000],
		"values": [3.0, 4.0, 5.0, 6.0, 7.0],  # seconds of prediction
		"unit": "s"
	},
}

static func format_money(number: int) -> String:
	var num_str: String = str(number).lstrip("-")
	var result: String = ""
	var count: int = 0

	for i in range(num_str.length() - 1, -1, -1):
		result = num_str[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result

	if number < 0:
		result = "-" + result

	return "$" + result
