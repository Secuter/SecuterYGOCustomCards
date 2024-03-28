SECUTER_CONSTANTS_IMPORTED = true

--[[
if not SECUTER_CONSTANTS_IMPORTED then Duel.LoadScript("secuter_constants.lua") end
]]

-- Constants

CATEGORY_ATTACH_ARMOR   = 0x20000000

SUMMON_TYPE_REUNION	    = 0x40000003
SUMMON_TYPE_IGNITION    = 0x40000005
SUMMON_TYPE_ARMORIZING  = 0x40000006
SUMMON_TYPE_ECHO        = 0x40000007
SUMMON_TYPE_EXCHANGE    = 0x40000009
SUMMON_TYPE_WANDERING   = 0x4000000a

EVENT_ATTACH_ARMOR		= 1300

REASON_REUNION          = 0x20000000
REASON_IGNITION		    = 0x40000000
REASON_ARMORIZING		= 0x80000000
REASON_ECHO			    = 0x100000000
REASON_WANDERING        = 0x200000000

EFFECT_ARMORATK_UPD		= 12349901
EFFECT_ARMORATK_REP		= 12349902
EFFECT_ARMORDEF_UPD		= 12349903
EFFECT_ARMORDEF_REP		= 12349904
EFFECT_ECHO_EQUIPPED    = 12349900
EFFECT_HAND_REUNION     = 601
EFFECT_NO_WANDERING_SUMMON        = 12345790
EFFECT_WANDERING_SUMMON_TWICE     = 12345792
EFFECT_WANDERING_SUMMON_TRICE     = 12345793
EFFECT_WANDERING_SUMMON_UNLIMITED = 12345791
EFFECT_WANDERING_REQ_REDUCED      = 12345799
EFFECT_WANDERING_REQ_REDUCED_TWICE= 12345798

EFFECT_FLAG2_ARMOR		= 0x100000000
EFFECT_FLAG2_RUNIC	    = 0x200000000

HINTMSG_RMATERIAL       = 600
HINTMSG_IMATERIAL       = 601
HINTMSG_AMATERIAL       = 602
HINTMSG_EMATERIAL	    = 603
HINTMSG_REMOVEARMOR     = 604
HINTMSG_REMOVEARMORFROM = 605
HINTMSG_ARMORTARGET     = 606
HINTMSG_ATTACHARMOR     = 607
HINTMSG_EXSUMMON	    = 608

ID_WANDERING_LIMIT      = 12345700

MATERIAL_TOGRAVE	    = 1
MATERIAL_REMOVE	        = 2
MATERIAL_REMOVE_FACEDOWN= 3
MATERIAL_TOHAND	        = 4
MATERIAL_TODECK	        = 5
MATERIAL_DESTROY	    = 6

-- Commonly used card codes

-- Archetype set code constants

SET_EXTERNAL_WORLDS			= 0xD01
SET_EXTERNAL_WORLDS_LORD	= 0x1D01
SET_EXTERNAL_WORLDS_HERO	= 0x2D01
SET_UNDEAD					= 0xD02
SET_UNDEAD_MASTER			= 0x1D02
SET_FLUID					= 0xD04
SET_AIR_FLUID				= 0x1D04
SET_SOLID_FLUID				= 0x2D04
SET_FLUIDSPHERE				= 0x4D04
SET_DARK_KING				= 0xD05
SET_DARK_KING_SERVANT		= 0x1D05
SET_DARK_KING_KNIGHT		= 0x2D05
SET_HYDRA					= 0xD06
SET_FIRE_CORE				= 0xD07
SET_FIRE_CORE_MAGIC			= 0x1D07
SET_ANUAK					= 0xD08
SET_ANUAK_DRAGON			= 0x1D08
SET_MORHAI					= 0xD09
SET_MORHAI_CULTIST			= 0x1D09
SET_MORHAI_SPAWN			= 0x2D09
SET_ZENIT_DRAGON			= 0xD0A
SET_CRACKING				= 0xD0C
SET_AETHEROCK				= 0xD0D
SET_EXOHEART				= 0xD0E
SET_WORLDLESS				= 0xD0F
SET_EAGLE_OVERSEER			= 0xD10
SET_ANCIENT_ORACLE			= 0xD11
SET_GEARTRON				= 0xD12
SET_ELITE_GEARTRON			= 0x1D12
SET_DIVINE_DISCIPLE			= 0xD13
SET_DARK_DIVINE_DISCIPLE	= 0x1D13
SET_ERINYES					= 0xD14
SET_DD_INVADER				= 0xD15
SET_DEMON_RIVAL				= 0xD16
SET_ABYSS_CHALLENGER		= 0xD17
SET_ASURA					= 0xD18
SET_ARMORIZING_DRAGON		= 0xD19
SET_BULWARK_CHAMPION		= 0xD1A
SET_MACHINE_FORCE			= 0xD1B
SET_SAVAGE_BEAST			= 0xD1C
SET_RASCAL_ACE				= 0xD1D
SET_ARCAEONIX				= 0xD1E
SET_YOCCOL					= 0xD1F
SET_WYRMWIND				= 0xD20
SET_ETERNAL_STORM			= 0xD21
SET_MAGIC_TOWER				= 0xD22
SET_MAGIC_TOWER_SPHERE		= 0x1D22
SET_EXCHANGE_DAEMON			= 0xD23
SET_HAILSHIFT				= 0xD24
SET_ABYSMAL					= 0xD25
SET_PYROCLAST				= 0xD26
SET_EMBER_WORM				= 0xD27
SET_BLAZE_DRAGONLADY		= 0xD28
SET_FOG_DRAGON				= 0xD29
SET_SOULBOUND				= 0xD2A
SET_CREARMOR				= 0xD2B
SET_IRRADIANCE				= 0xD2C
SET_PELAGIC					= 0xD2D
SET_AQUARAID				= 0xD2E
SET_AMORPHIEND				= 0xD2F
SET_DARK_SOVEREIGN			= 0xD30
SET_FREEFLAME				= 0xD31
SET_GHOOST					= 0xD32
SET_VOID_WANDERER			= 0xD33
SET_PRIMEVAL_FOREST			= 0xD34
SET_ARMOR_MAGICIAN			= 0x1098