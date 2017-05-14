#definitions.ps1

$VersionTable = @(
    @{Version='Debug 92.12.21.1'; VersionOffset=0x4AC150; VersionOffsetString='Version 96.12.21.1'; StartOffset=0x682830; FileHashMD5='EB73513BE5A3AE62E7BFEF63B51FA7FE'}
    
    @{Version='Release 1.00';     VersionOffset=0x499b28; VersionOffsetString='Diablo v1.00'; StartOffset=0x5330E0; FileHashMD5='6F0C02AAF2B29B1C17947AE15F4B82EE'}
    @{Version='Release 1.02';     VersionOffset=0x4A2D38; VersionOffsetString='Diablo v1.02'; StartOffset=0xFE0060; FileHashMD5='040C81EB1666D66BD900351CB01DE10E'}
    @{Version='Release 1.03';     VersionOffset=0x49E020; VersionOffsetString='Diablo v1.03'; StartOffset=0xFE0070; FileHashMD5='378FF4FE861032702520BCE313C1650C'}
    @{Version='Release 1.04';     VersionOffset=0x4a2d20; VersionOffsetString='Diablo v1.04'; StartOffset=0xFD0070; FileHashMD5='907201801202D7A21D47E8BDAB31AC26'}
    @{Version='Release 1.05';     VersionOffset=0x4B05B0; VersionOffsetString='Diablo v1.05'; StartOffset=0x6A8860; FileHashMD5='A353E8EBCED6054B4D25D6DD821BD00F'}
    @{Version='Release 1.07';     VersionOffset=0x48F5C8; VersionOffsetString='Diablo v1.07'; StartOffset=0x6877A0; FileHashMD5='6D86757A5EF2AB91D32C7E01478D4C8F'}
    @{Version='Release 1.08';     VersionOffset=0x49052c; VersionOffsetString='Diablo v1.08'; StartOffset=0x6884C0; FileHashMD5='8C5859E70E16849512C84AF3D76E26EE'}
    @{Version='Release 1.09';     VersionOffset=0x48e58c; VersionOffsetString='Diablo v1.09'; StartOffset=0x686470; FileHashMD5='0D1A2B10F8B7FC1A388109BD8ABF05D1'}
    @{Version='Release 1.09b';    VersionOffset=0x48e58c; VersionOffsetString='Diablo v1.09'; StartOffset=0x686470; FileHashMD5='DA62D5CD8BD71A0B66E6D4EF7A111233'}

    @{Version='Alpha 4.1.8';      VersionOffset=0x4BC150; VersionOffsetString='V4.1.8'; StartOffset=0x6058a7; FileHashMD5='21563BAE0ED8580FC1D4B4A4344EB89A'}
    @{Version='Alpha 4.1.9';      VersionOffset=0x4BC150; VersionOffsetString='V4.1.9'; StartOffset=0x6058a7; FileHashMD5='7101CDDAC45ED22227B53DE2D0F11667'}
    @{Version='Beta 96.11.9.2';   VersionOffset=0x4C55B0; VersionOffsetString='Version 96.11.9.2';  StartOffset=0x62d8B0; FileHashMD5='EC794B3EAF4C3151E13C39014CBA8B29'}
)


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
$MONSTER_ENUM = 'ZOMBIE','GHOUL','ROTTING_CARCASS','BLACK_DEATH','FALLEN_ONE_SPEAR','CARVER_SPEAR','DEVIL_KIN_SPEAR','DARK_ONE_SPEAR','SKELETON_AXE','CORPSE_AXE','BURNING_DEAD_AXE','HORROR_AXE','FALLEN_ONE_SWORD','CARVER_SWORD','DEVIL_KIN_SWORD','DARK_ONE_SWORD','SCAVENGER','PLAGUE_EATER','SHADOW_BEAST','BONE_GASHER','SKELETON_BOW','CORPSE_BOW','BURNING_DEAD_BOW','HORROR_BOW','SKELETON_CAPTAIN','CORPSE_CAPTAIN','BURNING_DEAD_CAPTAIN','HORROR_CAPTAIN','INVISIBLE_LORD','HIDDEN','STALKER','UNSEEN','ILLUSION_WEAVER','LORD_SAYTER','FLESH_CLAN_MACE','STONE_CLAN_MACE','FIRE_CLAN_MACE','NIGHT_CLAN_MACE','FIEND','BLINK','GLOOM','FAMILIAR','FLESH_CLAN_BOW','STONE_CLAN_BOW','FIRE_CLAN_BOW','NIGHT_CLAN_BOW','ACID_BEAST','POISON_SPITTER','PIT_BEAST','LAVA_MAW','SKELETON_KING','THE_BUTCHER','OVERLORD','MUD_MAN','TOAD_DEMON','FLAYED_ONE','WYRM','CAVE_SLUG','DEVIL_WYRM','DEVOURER','MAGMA_DEMON','BLOOD_STONE','HELL_STONE','LAVA_LORD','HORNED_DEMON','MUD_RUNNER','FROST_CHARGER','OBSIDIAN_LORD','BONE_DEMON','RED_DEATH','LITCH_DEMON','UNDEAD_BALROG','INCINERATOR','FLAME_LORD','DOOM_FIRE','HELL_BURNER','RED_STORM','STORM_RIDER','STORM_LORD','MAELSTORM','DEVIL_KIN_BRUTE','WINGED_DEMON','GARGOYLE','BLOOD_CLAW','DEATH_WING','SLAYER','GUARDIAN','VORTEX_LORD','BALROG','CAVE_VIPER','FIRE_DRAKE','GOLD_VIPER','AZURE_DRAKE','BLACK_KNIGHT','DOOM_GUARD','STEEL_LORD','BLOOD_KNIGHT','UNRAVELER','HOLLOW_ONE','PAIN_MASTER','REALITY_WEAVER','SUCCUBUS','SNOW_WITCH','HELL_SPAWN','SOUL_BURNER','COUNSELOR','MAGISTRATE','CABALIST','ADVOCATE','GOLEM','THE_DARK_LORD','THE_ARCH_LITCH_MALIGNUS'
#$MONSTER_TYP_ENUM = '0-Zombie','1-','2-Skeleton','3-','4-Scavenger','5-'.'6-','7-','8','9-Fallen One',10,11,12,13,14,15,16,17,18,19,'20-Dog','21','22-Golem',23
$MONSTER_TYP_ENUM = 0,1,2,3,'4',5,6,7,8,9,10,11,'12-Golem',13,14,15,16,17,18,19,20,211,22,23,24,'25-Dog','26-Doomgaurd',27,'28-Lachdanan',29

$DIFFICULTY_ENUM = 'Normal','Nightmare','Hell'
$QUEST_ENUM = 'THE_MAGIC_ROCK','BLACK_MUSHROOM','GHARBAD_THE_WEAK','ZHAR_THE_MAD','LACHDANAN','DIABLO','THE_BUTCHER','OGDENS_SIGN','HALLS_OF_THE_BLIND','VALOR','ANVIL_OF_FURY','WARLORD_OF_BLOOD','THE_CURSE_OF_KING_LEORIC','POISONED_WATER_SUPPLY','THE_CHAMBER_OF_BONE','ARCHBISHOP_LAZARUS'
$QUEST_STATE= 'inactive','waiting', 'active', 'accomplished'

[String[]]$SPELL_NAMES = 'Firebolt','healing','light','flash','identify','firewall','Town Portal','stone curse','infrasion','phasing','mana shield','fireball','guardian','chain lightning','flame wave','doom serpents','blood ritual','nova','invisiblity','inferno','golem','blood boil','teleport','apocalypse', 'etheralize','item repair','staff rechare','trap disarm','elemental','chargedbolt','holybolt','resurrect','telekinesis','heal other','blood star','bone spirit'
$SPELLBOX_X = 1,1,2,2,0,2,2,2,0,3,3,3,3,3,3,0,0,4,0,1,4,0,4,4,0,1,1,1,3,1,1,2,2,1,4,4
$SPELLBOX_Y = 2,5,4,6,0,2,5,7,0,1,2,4,7,6,5,0,0,1,0,7,2,0,3,4,0,1,1,1,3,3,4,1,3,6,6,5

$MONSTER_TYP_ENUM = '0','1','2','3','4','5','6','7','8','9','10',
    '11','12','13','14','15','16','17','18','19','20',
    '21','22','23','24-shadow beast','25','26-sir gorash','27-Blustweaver','28','29-baron','30-snipeater',
    '31-moonbender','32-zhar/snotspil/unique','33-golem','34-madeye the dead/hellspawnm','35-succu','36-doom guard','37','38-winged demon','39','40',
    '41-magmademon','42-mudman','43-lava maw','44-familiar','45-blink','46-illusion weaver','47-burning dead captain','48-bone gasher','49-shadowbeast','50-horror',
    '51-dark one','52-zombie','53','54','55','56','57','58','59','60',
    '61','62','63','64','65','66','67','68','69','70',
    '71-overlord','72','73','74','75','76','77','78','79','80',
    '81','82','83','84','85','86','87','88','89','90',
    '91','92','93','94','95','96','97','98','99','100',
    '101','102','103','104','105','106','107','108','109','110',
    '111','112','113','114','115','116','117','118','119-bloodstone','120',
    '121','122','123','124','125','126','127','128','129','130',
    '131','132','133-Golem','134-Advocate','135-Hell Spawn/Blood Knight','136','137-Diablo','138','139','140'

$DIR = 'South','South West','West','North West','North','North East','East','South East'
