#definitions.ps1

$VersionStringMatch = @{
[int]0x499b28 = [Version]'1.0.0.0'
[int]0x4A2D38 = [Version]'1.0.2.0'
[int]0x49E020 = [Version]'1.0.3.0'
[int]0x4a2d20 = [Version]'1.0.4.0'
[int]0x4B05B0 = [Version]'1.0.5.0'
[int]0x48F5C8 = [Version]'1.0.7.0'
[int]0x49052c = [Version]'1.0.8.0'
[int]0x48e58c = [Version]'1.0.9.0'
#[int]0x48e58c = [Version]'1.0.9.1'
[int]0x4A08C0 = [Version]"2.0.1.0"
} #end hash

$start_offsetV100 = 0x5330E0
$start_offsetV102 = 0xFE0070
$start_offsetV103 = 0xFE0070
$start_offsetV104 = 0xFD0070
$start_offsetV105 = 0x6A8860
$start_offsetV107 = 0x6877A0
$start_offsetV108 = 0x6884C0
$start_offsetV109 = 0x686470
$start_offsetV201 = 0x1030070

# OFFSETS OFFSETS OFFSETS OFFSETS OFFSETS OFFSETS OFFSETS OFFSETS OFFSETS OFFSETS 

$PLAYERS_COUNT_OFFSET = -(0xDE44)

$PLAYER_OFFSET = 0x54D8

$PLAYERNAME_OFFSET = 0x118
$PLAYERNAME_LENGTH = 15

$DIFFICULT_OFFSET = -(0xde34)

$POSSIBLE_IS_ALIVE_OFFSET = 0x115

$DUNGENON_OFFSET = 0xC

$TYPE_OFFSET = 0x138

$POS_X_OFFSET = 0x10
$POS_Y_OFFSET = 0x14

$SPELLFLAGS_OFFSET = 0xBD+23+12 # 0xE0
$SPELLS_OFFSET = 0x9A

$STAT_OFFSET = 0x140

$LEVELUP_OFFSET = 0x15C

$LVL_OFFSET = 0x190

$EXP_OFFSET = 0x194

$GOLD_OFFSET = 0x1A4

$WAYPOINT_OFFSET = -(0x5450)

$TP_OFFSET = -(0x10308)

$MONSTER_OFFSET = 0x39788

$ITEM_SIZE = 0x170
$INV_OFFSET = 0x354 # 0xDE0
$INV_BACKPACK_OFFSET = 0xD64

$BELT_OFFSET = 0x4701+15 # 0xDE0

$QUESTS_OFFSET = 0x158c6
$BUTCHER = 0x69BDA2
$TAVERN=   0x69BDBA
$KINGLEOR= 0x69BE32

## item ##
$ITM_IDENTIFIED_OFFSET = 0x38

$ITM_DMG_FROM_OFFSET = 0xCC
$ITM_DMG_TO_OFFSET = 0xD0

$ITM_SPELL_OFFSET = 0xE0

$ITM_CHARGES_FROM_OFFSET = 0xE4
$ITM_CHARGES_TO_OFFSET = 0xE8

$ITM_DUR_FROM_OFFSET = 0xEC
$ITM_DUR_TO_OFFSET = 0xF0

$ITM_RESISTALL_OFFSETS = 0x110,0x114,0x118

$ITM_ALLATTRIB_OFFSETS = 0x100,0x104,0x108,0x10C

$ITM_ARMOR_OFFSET = 0xD4

$ITM_BASEPRICE_OFFSET = 0xC4

#Resources Resources Resources Resources Resources Resources Resources Resources 
$TYPE_ENUM = 'Warrior','Rogue','Sorceror'
$STAT_ENUM = "Strength","Magic","Dextery","Vitality"
$DUNGEONTYPES_ENUM = 'Town','Cathedral','Catacombs','Caves','Hell'
$QUESTREGION_ENUM = 'None','Skeleton King','Bone Chamber','Maze','Poisoned Water Supply','Archbishop Lazarus Lair'
$Monster_ENUM = 'zombie','Ghoul','zombie','zombie','falspear','falspear','Devil Kin','falspear','Skeleton','Corpse Axe','Burning Dead','skelaxe','falsword','Carver','Devil Kin','falsword','scav','scav','scav','scav','Skeleton','Corpse Bow','Burning Dead','Horror','Skeleton King','skelsd','Burning Dead Captain','skelsd','tsneak','sneak','sneak','sneak','sneak','goatlord','Flesh King','goatmace','goatmace','goatmace','Fiend','Blink','bat','bat','goatbow','goatbow','goatbow','goatbow','acid','acid','acid','acid','sking','fatc','Overlord','fat','fat','fat','worm','worm','worm','worm','magma','magma','magma','magma','rhino','rhino','rhino','rhino','demskel','thin','thin','thin','fireman','fireman','fireman','fireman','thin','thin','thin','thin','bigfall','gargoyle','gargoyle','gargoyle','gargoyle','mega','mega','mega','Balrog','Cave Viper','snake','snake','Azure Drake','black','Doom Guard','Steel Lord','black','unrav','unrav','unrav','unrav','Succubus','succ','succ','succ','mage','mage','mage','mage','golem','diablo','darkmage'
$DIFFICULTY_ENUM = 'Normal','Nightmare','Hell'
$QUEST_ENUM = 'THE_MAGIC_ROCK','BLACK_MUSHROOM','GHARBAD_THE_WEAK','ZHAR_THE_MAD','LACHDANAN','DIABLO','THE_BUTCHER','OGDENS_SIGN','HALLS_OF_THE_BLIND','VALOR','ANVIL_OF_FURY','WARLORD_OF_BLOOD','THE_CURSE_OF_KING_LEORIC','POISONED_WATER_SUPPLY','THE_CHAMBER_OF_BONE','ARCHBISHOP_LAZARUS'
$QUEST_STATE= 'inactive','waiting', 'active', 'accomplished'

[String[]]$SPELL_NAMES = 'Firebolt','healing','light','flash','identify','firewall','Town Portal','stone curse','infrasion','phasing','mana shield','fireball','guardian','chain lightning','flame wave','doom serpents','blood ritual','nova','invisiblity','inferno','golem','blood boil','teleport','apocalypse', 'etheralize','item repair','staff rechare','trap disarm','elemental','chargedbolt','holybolt','resurrect','telekinesis','heal other','blood star','bone spirit'
$SPELLBOX_X = 1,1,2,2,0,2,2,2,0,3,3,3,3,3,3,0,0,4,0,1,4,0,4,4,0,1,1,1,3,1,1,2,2,1,4,4
$SPELLBOX_Y = 2,5,4,6,0,2,5,7,0,1,2,4,7,6,5,0,0,1,0,7,2,0,3,4,0,1,1,1,3,3,4,1,3,6,6,5

$SpecialAbility = @{
    0x0='none'
    0x1='Infrasion'
    0x2='random life stealing'
    0x4='random speed arrows'
    0x8='fire arrow damage'
    0x10='fire hit damage'
    0x20='lighning hit damage'
    0x40='constantly lose life'
    0x100='user can''t heal' #web
    0x800='knocks target back'
    0x1000='Hit monsters doesn''t heal' #web
    0x2000='hit steals 3% mana'
    0x4000='hit steals 5% mana'
    0x8000='hit steals 3% life'
    0x10000='hit steals 5% life'
    0x20000="Quick attack"
    0x40000='fast attack'
    0x80000='faster attack'
    0x100000='fastest attack'
    0x200000='fast hit recovery'
    0x400000='faster hit recovery'
    0x800000="Fastest hit recovery"
    0x1000000='fast block'
    0x2000000='lightning arrow damage'
    0x4000000='attacker takes 1-3 damage' #web thorns 
    0x8000000='user loses all mana'
    0x10000000='absorbs half of trap damage'
    0x40000000='+200% Damage vs. demons'
    0x80000000='user loses all resistances'
}

$itemClass = @{
    00 = 'Unwearable'
    01  ='Sword'
    02  ='Axe'
    03  ='Bow'
    04 ='Club'
    05 ='Shield'
    06  = 'Light Amor'
    07  ='Cap'
    08 = 'Mail'
    09 = 'Heavy Armor'
    0xA ='Staff'
    0xB = 'Gold'
    0xc = 'Ring'
    0xd = 'Amulett'
	0xFF = 'invalid'
}

$itemCode = @{
    0x0 = 'none'
    0x1 = 'use first'
    0x2 = 'full healing'
    0x3 = 'healing'
    0x6 = 'mana'
    0x7 = 'full mana'
    0xA = 'elixir strength'
    0xB = 'elixir magic'
    0xC = 'Elixir of Dexterity'
    0xd = 'elixir vitality'
    0x12= 'Rejuvenation'
    0x13= 'Full Rejuvenation'
    0x14 = 'use last'
    0x15 = 'scroll'
    0x16 = 'scroll with target'
    0x17 = 'staff'
    0x18 = 'book'
    0x19 = 'ring'
    0x1a = 'amulet'
    0x1b = 'unique'
    0x1c = 'potion of Healing something'
    0x2a = 'map of the stars'
    0x2b = 'ear'
    0x2c = 'spectral exlixir'
}


$itemType = @{
0 = 'Gold'
1 = 'Short Sword' #hacked?
2 = 'Buckler'  #hacked?
3 = 'Club' #mem
4 = 'Short Bow' #mem
5 = 'Short Bow' #mem
6 = 'Cleaver'
7 = 'The Undead Crown'
8 = 'Empyrean Band'
9 = 'Magic Rock'
10 = 'Optic Amulet'
11 = 'Ring of Truth'
12 = 'Tavern Sign'
13 = 'Harlequin Crest'
14 = 'Veil of Steel'
15 = 'Golden Elixir'
16 = 'Anvil of Fury'
17 = 'Black Mushroom'
18 = 'Brain'
19 = 'Fungal Tome'
20 = 'Spectral Elixir'
21 = 'Blood Stone'
22 = 'Map of the Stars'
23 = 'Ear/Heart'  #hacked?
24 = 'Potion of Healing'
25 = 'Potion of Mana'
26 = 'Scroll of Identify'   #mem
27 = 'Scroll of Town Portal'
28 = 'Arkaine''s Valor'
29 = 'Potion of Full Healing' #Mana
30 = 'Potion of Full Mana'
31 = 'Griswold''s Edge'
32 = 'Lightforge'
33 = 'Staff of Lazarus'
34 = 'Scroll of Ressurect' #hacked
36 = 'Crashed' #hacked
48 = 'Cap'
49 = 'Skull Cap'
50 = 'Helm'
51 = 'Full Helm'
52 = 'Crown'
53 = 'Great Helm'
54 = 'Cape'
55 = 'Rags'
56 = 'Cloak'
57 = 'Robe'
58 = 'Quilted Armor'
#Amor mem
59 = 'Leather Armor'
60 = 'Hard Leather Armor'
61 = 'Studded Leather Armor'
62 = 'Ring Mail'
#Mail
63 = 'Chain Mail'
64 = 'Scale Mail'
65 = 'Breast Plate'
#Plate
66 = 'Splint Mail'
67 = 'Plate Mail'
68 = 'Field Plate'
69 = 'Gothic Plate'
70 = 'Full Plate Mail'
71 = 'Buckler/Shield'
72 = 'Small Shield'
73 = 'Large Shield'
74 = 'Kite Shield'
75 = 'Tower Shield'
76 = 'Gothic Shield'
77 = 'Elixir of Vitality' #hacked
78 = 'Potion of Full Healing'
81 = 'Potion of Rejuvenation'
82 = 'Potion of Full Rejuvenation'
83 = 'Elixir of Strength'
84 = 'Elixir of Magic'
85 = 'Elixir of Dexterity'
86 = 'Elixir of Vitality'
87 = 'Scroll of Healing'
88 = 'Scroll of Lightning'
89 = 'Scroll of Identify'
90 = 'Scroll of Resurrect'
91 = 'Scroll of Fire Wall'
92 = 'Scroll of Inferno'
93 = 'Scroll of Town Portal' #hacked
94 = 'Scroll of Flash'
95 = 'Scroll of Infravision'
96 = 'Scroll of Phasing'
97 = 'Scroll of Mana Shield'
98 = 'Scroll of Flame Wave'
99 = 'Scroll of Fireball'
100 = 'Scroll of Stone Curse'
101 = 'Scroll of Chain Lightning'
102 = 'Scroll of Guardian'
103 = 'Non Item'
104 = 'Scroll of Nova'
105 = 'Scroll of Golem'
107 = 'Scroll of Teleport'
108 = 'Scroll of Apocalypse'
109 = 'Book'
110 = 'Book'
111 = 'Book'
112 = 'Book' #hacked
113 = 'Dagger'
114 = 'Short Sword'
115 = 'Falchion'
116 = 'Scimitar'
117 = 'Claymore'
118 = 'Blade'
119 = 'Sabre'
120 = 'Long Sword'
121 = 'Broad Sword'
122 = 'Bastard Sword'
123 = 'Two-Handed Sword'
124 = 'Great Sword'
125 = 'Small Axe'
126 = 'Axe'
127 = 'Large Axe'
128 = 'Broad Axe'
129 = 'Battle Axe'
130 = 'Great Axe'
131 = 'Mace'
132 = 'Morning Star'
133 = 'War Hammer'
#Hammer
134 = 'Spiked Club'
135 = 'Club'
136 = 'Flail'
137 = 'Maul'
138 = 'Short Bow/Bow'
139 = 'Hunter''s Bow'
140 = 'Long Bow'
141 = 'Composite Bow'
142 = 'Short Battle Bow'
143 = 'Long Battle Bow'
144 = 'Short War Bow'
145 = 'Long War Bow'
146 = 'Short Staff'
#Staff
147 = 'Long Staff'
148 = 'Composite Staff'
149 = 'Quarter Staff'
150 = 'War Staff'
151 = 'Ring'
152 = 'Ring'
153 = 'Ring'
154 = 'Amulet'
155 = 'Amulet'
}

$equip_type = @(
'none',
"One Handed",
"Tow Handed",
"Chest",
"Head",
"Ring",
"Amulet",
"Unequipable",
"Belt"
)

$item_category = @(
"none",
"weapon",
"Armor",
"Jewerly or consumable",
"Gold",
"Chest"
)
