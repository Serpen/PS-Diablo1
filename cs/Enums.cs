using System;

namespace Serpen.Diablo
{
    public struct FromTo
    {
        public FromTo(int from, int to)
        {
            From = from;
            To = to;
            Seperator = '-';
        }

        public FromTo(int from, int to, char seperator)
        {
            From = from;
            To = to;
            Seperator = seperator;
        }

        internal char Seperator;
        public readonly int From;
        public readonly int To;

        public override string ToString()
        {
            if (From == To)
                return From.ToString();
            else
                return String.Format("{0}{1}{2}", From, Seperator, To);
        }

        public static implicit operator FromTo(int[] vals)
        {
            if (vals.Length != 2)
                throw new ArgumentOutOfRangeException();
            return new FromTo(vals[0], vals[1]);
        }
        public static implicit operator FromTo(int val)
        {
            return new FromTo(val, val);
        }
        public static implicit operator FromTo(Array vals)
        {
            if (vals.Length != 2)
                throw new ArgumentOutOfRangeException();
            try
            {
                return new FromTo(Convert.ToInt32(vals.GetValue(0)), Convert.ToInt32(vals.GetValue(1)));
            }
            catch { throw new ArgumentException(); }
        }

        public static FromTo operator * (FromTo ft, int number) {
            return new FromTo(ft.From * number, ft.To * number);
        }
        public static FromTo operator + (FromTo ft, int number) {
            return new FromTo(ft.From + number, ft.To + number);
        }
    }

    public enum eSpell : sbyte { All = -2, None = 0, Firebolt = 1, Healing, Lightning, Flash, Identify, Firewall, TownPortal, StoneCurse, Infrasion, Phasing, ManaShield, Fireball, Guardian, ChainLightning, FlameWave, DoomSerpents, BloodRitual, Nova, Invisiblity, Inferno, Golem, BloodBoil, Teleport, Apocalypse, Etheralize, ItemRepair, StaffRecharge, TrapDisarm, Elemental, Chargedbolt, Holybolt, Resurrect, Telekinesis, HealOther, BloodStar, BoneSpirit }
    public enum eCharClass : byte { Warrior, Rogue, Sorceror }

    public enum eItemQuality : byte { normal, magic, unique }
    public enum eItemType : sbyte { Misc, Sword, Axe, Bow, Club, Shield, LightAmor, Cap, Mail, HeavyArmor, Staff, Gold, Ring, Amulett, Type_0E, invalid = -1 };
    public enum eEquipType : sbyte { none, OneHanded, TowHanded, Chest, Head, Ring, Amulet, Unequipable, Belt, invalid = -1 }
    public enum eDungenType : byte {Town,Cathedral,Catacombs,Caves,Hell}

    public enum eItemCode : int { None, UseFirst, FullHealing, Healing, OldHeal, DeadHeal, Mana, FullMana, AddXP, RemoveXP, ElixirStrength, ElixirMagic, ElixirDexterity, ElixirVitality, ElixirWeak, ElikirDis, ElixirClum, ElixirSick, Rejuvenation, FullRejuvenation, UseLast, Scroll, ScrollWithTarget, Staff, Book, Ring, Amulet, Unique, PotionOfHealingSomething, MapOfTheStars = 0x2a, Ear, SpectralExlixir }
    public enum eItemCategory : byte { none, weapon, Armor, JewerlyOrConsumable, Gold, Chest }

    public enum eDifficulty : byte { Normal, Nightmare, Hell }
    public enum Direction : byte { South, South_West, West, North_West, North, North_East, East, South_East }

    public enum PLR_MODE { PM_STAND = 0, PM_WALK = 1, PM_WALK2 = 2, PM_WALK3 = 3, PM_ATTACK = 4, PM_RATTACK = 5, PM_BLOCK = 6, PM_GOTHIT = 7, PM_DEATH = 8, PM_SPELL = 9, PM_NEWLVL = 10, PM_QUIT = 11 }

    [System.Flags]
    public enum eSpecialEffect : uint
    {
        none = 0x0,
        Infrasion = 0x1,
        RandomLifestealing = 0x2,
        RandomSpeedarrows = 0x4,
        FireArrowdamage = 0x8,
        FireHitdamage = 0x10,
        LightningHitDamage = 0x20,
        ConstantlyLoseLife = 0x40,
        _Unknown80 = 0x80,
        UserCantHeal_web = 0x100,
        _Unknown200 = 0x200,
        _Unknown400 = 0x400,
        KnocksTargetBack = 0x800,
        HitMonstersDoesntHeal_web = 0x1000,
        HitSteals3PercentMana = 0x2000,
        HitSteals5PercentMana = 0x4000,
        HitSteals3PercentLife = 0x8000,
        HitSteals5PercentLife = 0x10000,
        QuickAttack = 0x20000,
        FastAttack = 0x40000,
        FasterAttack = 0x80000,
        FastestAttack = 0x100000,
        FastHitRecovery = 0x200000,
        FasterHitRecovery = 0x400000,
        FastestHitRecovery = 0x800000,
        FastBlock = 0x1000000,
        LightningArrowDamage = 0x2000000,
        AttackerTakes1To3Damage = 0x4000000,
        UserLosesAllMana = 0x8000000,
        AbsorbsHalfOfTrapDamage = 0x10000000,
        _Unknown20000000 = 0x20000000,
        P200PercentDamageVsDemons = 0x40000000,
        UserLosesAllResistances = 0x80000000
    }

    public enum eItemBase : byte
    {
        GOLD = 0,
        SHORT_SWORD = 1,
        BUCKLER = 2,
        CLUB = 3,
        SHORT_BOW = 4,
        SHORT_STAFF_OF_CHARGED_BOLT = 5,
        CLEAVER = 6,
        THE_UNDEAD_CROWN = 7,
        EMPYREAN_BAND = 8,
        MAGIC_ROCK = 9,
        OPTIC_AMULET = 10,
        RING_OF_TRUTH = 11,
        TAVERN_SIGN = 12,
        HARLEQUIN_CREST = 13,
        VEIL_OF_STEEL = 14,
        GOLDEN_ELIXIR = 15,
        ANVIL_OF_FURY = 16,
        BLACK_MUSHROOM = 17,
        BRAIN = 18,
        FUNGAL_TOME = 19,
        SPECTRAL_ELIXIR = 20,
        BLOOD_STONE = 21,
        MAP_OF_THE_STARS = 22,
        HEART = 23,
        POTION_OF_HEALING = 24,
        POTION_OF_MANA = 25,
        SCROLL_OF_IDENTIFY = 26,
        SCROLL_OF_TOWN_PORTAL = 27,
        ARKAINES_VALOR = 28,
        POTION_OF_FULL_HEALING = 29,
        POTION_OF_FULL_MANA = 30,
        GRISWOLDS_EDGE = 31,
        LIGHTFORGE = 32,
        STAFF_OF_LAZARUS = 33,
        SCROLL_OF_RESURRECT = 34,
        NULL_1 = 35,
        NULL_2 = 36,
        NULL_3 = 37,
        NULL_4 = 38,
        NULL_5 = 39,
        NULL_6 = 40,
        NULL_7 = 41,
        NULL_8 = 42,
        NULL_9 = 43,
        NULL_10 = 44,
        NULL_11 = 45,
        NULL_12 = 46,
        NULL_13 = 47,
        BASE_CAP = 48,
        BASE_SKULL_CAP = 49,
        BASE_HELM = 50,
        BASE_FULL_HELM = 51,
        BASE_CROWN = 52,
        BASE_GREAT_HELM = 53,
        BASE_CAPE = 54,
        BASE_RAGS = 55,
        BASE_CLOAK = 56,
        BASE_ROBE = 57,
        BASE_QUILTED_ARMOR = 58,
        BASE_LEATHER_ARMOR = 59,
        BASE_HARD_LEATHER_ARMOR = 60,
        BASE_STUDDED_LEATHER_ARMOR = 61,
        BASE_RING_MAIL = 62,
        BASE_CHAIN_MAIL = 63,
        BASE_SCALE_MAIL = 64,
        BASE_BREAST_PLATE = 65,
        BASE_SPLINT_MAIL = 66,
        BASE_PLATE_MAIL = 67,
        BASE_FIELD_PLATE = 68,
        BASE_GOTHIC_PLATE = 69,
        BASE_FULL_PLATE_MAIL = 70,
        BASE_BUCKLER = 71,
        BASE_SMALL_SHIELD = 72,
        BASE_LARGE_SHIELD = 73,
        BASE_KITE_SHIELD = 74,
        BASE_TOWER_SHIELD = 75,
        BASE_GOTHIC_SHIELD = 76,
        BASE_POTION_OF_HEALING = 77,
        BASE_POTION_OF_FULL_HEALING = 78,
        BASE_POTION_OF_MANA = 79,
        BASE_POTION_OF_FULL_MANA = 80,
        BASE_POTION_OF_REJUVENATION = 81,
        BASE_POTION_OF_FULL_REJUVENATION = 82,
        BASE_ELIXIR_OF_STRENGTH = 83,
        BASE_ELIXIR_OF_MAGIC = 84,
        BASE_ELIXIR_OF_DEXTERITY = 85,
        BASE_ELIXIR_OF_VITALITY = 86,
        BASE_SCROLL_OF_HEALING = 87,
        BASE_SCROLL_OF_LIGHTNING = 88,
        BASE_SCROLL_OF_IDENTIFY = 89,
        BASE_SCROLL_OF_RESURRECT = 90,
        BASE_SCROLL_OF_FIRE_WALL = 91,
        BASE_SCROLL_OF_INFERNO = 92,
        BASE_SCROLL_OF_TOWN_PORTAL = 93,
        BASE_SCROLL_OF_FLASH = 94,
        BASE_SCROLL_OF_INFRAVISION = 95,
        BASE_SCROLL_OF_PHASING = 96,
        BASE_SCROLL_OF_MANA_SHIELD = 97,
        BASE_SCROLL_OF_FLAME_WAVE = 98,
        BASE_SCROLL_OF_FIREBALL = 99,
        BASE_SCROLL_OF_STONE_CURSE = 100,
        BASE_SCROLL_OF_CHAIN_LIGHTNING = 101,
        BASE_SCROLL_OF_GUARDIAN = 102,
        BASE_NON_ITEM = 103,
        BASE_SCROLL_OF_NOVA = 104,
        BASE_SCROLL_OF_GOLEM = 105,
        BASE_SCROLL_OF_NONE = 106,
        BASE_SCROLL_OF_TELEPORT = 107,
        BASE_SCROLL_OF_APOCALYPSE = 108,
        BASE_BOOK_QLVL_2 = 109,
        BASE_BOOK_QLVL_8 = 110,
        BASE_BOOK_QLVL_14 = 111,
        BASE_BOOK_QLVL_20 = 112,
        BASE_DAGGER = 113,
        BASE_SHORT_SWORD = 114,
        BASE_FALCHION = 115,
        BASE_SCIMITAR = 116,
        BASE_CLAYMORE = 117,
        BASE_BLADE = 118,
        BASE_SABRE = 119,
        BASE_LONG_SWORD = 120,
        BASE_BROAD_SWORD = 121,
        BASE_BASTARD_SWORD = 122,
        BASE_TWO_HANDED_SWORD = 123,
        BASE_GREAT_SWORD = 124,
        BASE_SMALL_AXE = 125,
        BASE_AXE = 126,
        BASE_LARGE_AXE = 127,
        BASE_BROAD_AXE = 128,
        BASE_BATTLE_AXE = 129,
        BASE_GREAT_AXE = 130,
        BASE_MACE = 131,
        BASE_MORNING_STAR = 132,
        BASE_WAR_HAMMER = 133,
        BASE_SPIKED_CLUB = 134,
        BASE_CLUB = 135,
        BASE_FLAIL = 136,
        BASE_MAUL = 137,
        BASE_SHORT_BOW = 138,
        BASE_HUNTERS_BOW = 139,
        BASE_LONG_BOW = 140,
        BASE_COMPOSITE_BOW = 141,
        BASE_SHORT_BATTLE_BOW = 142,
        BASE_LONG_BATTLE_BOW = 143,
        BASE_SHORT_WAR_BOW = 144,
        BASE_LONG_WAR_BOW = 145,
        BASE_SHORT_STAFF = 146,
        BASE_LONG_STAFF = 147,
        BASE_COMPOSITE_STAFF = 148,
        BASE_QUARTER_STAFF = 149,
        BASE_WAR_STAFF = 150,
        BASE_RING_QLVL_5 = 151,
        BASE_RING_QLVL_10 = 152,
        BASE_RING_QLVL_15 = 153,
        BASE_AMULET_QLVL_8 = 154,
        BASE_AMULET_QLVL_16 = 155,
        NULL_14 = 156
    }

    public enum eUniqueItem : int
    {
        NONE = -1,
        THE_BUTCHERS_CLEAVER = 0,
        THE_UNDEAD_CROWN = 1,
        EMPYREAN_BAND = 2,
        OPTIC_AMULET = 3,
        RING_OF_TRUTH = 4,
        HARLEQUIN_CREST = 5,
        VEIL_OF_STEEL = 6,
        ARKAINES_VALOR = 7,
        GRISWOLDS_EDGE = 8,
        LIGHTFORGE = 9,
        THE_RIFT_BOW = 10,
        THE_NEEDLER = 11,
        THE_CELESTIAL_BOW = 12,
        DEADLY_HUNTER = 13,
        BOW_OF_THE_DEAD = 14,
        THE_BLACKOAK_BOW = 15,
        FLAMEDART = 16,
        FLESHSTINGER = 17,
        WINDFORCE = 18,
        EAGLEHORN = 19,
        GONNAGALS_DIRK = 20,
        THE_DEFENDER = 21,
        GRYPHONS_CLAW = 22,
        BLACK_RAZOR = 23,
        GIBBOUS_MOON = 24,
        ICE_SHANK = 25,
        THE_EXECUTIONERS_BLADE = 26,
        THE_BONESAW = 27,
        SHADOWHAWK = 28,
        WIZARDSPIKE = 29,
        LIGHTSABRE = 30,
        THE_FALCONS_TALON = 31,
        INFERNO = 32,
        DOOMBRINGER = 33,
        THE_GRIZZLY = 34,
        THE_GRANDFATHER = 35,
        THE_MANGLER = 36,
        SHARP_BEAK = 37,
        BLOODSLAYER = 38,
        THE_CELESTIAL_AXE = 39,
        WICKED_AXE = 40,
        STONECLEAVER = 41,
        AGUINARAS_HATCHET = 42,
        HELLSLAYER = 43,
        MESSERSCHMIDTS_REAVER = 44,
        CRACKRUST = 45,
        HAMMER_OF_JHOLM = 46,
        CIVERBS_CUDGEL = 47,
        THE_CELESTIAL_STAR = 48,
        BARANARS_STAR = 49,
        GNARLED_ROOT = 50,
        THE_CRANIUM_BASHER = 51,
        SCHAEFERS_HAMMER = 52,
        DREAMFLANGE = 53,
        STAFF_OF_SHADOWS = 54,
        IMMOLATOR = 55,
        STORM_SPIRE = 56,
        GLEAMSONG = 57,
        THUNDERCALL = 58,
        THE_PROTECTOR = 59,
        NAJS_PUZZLER = 60,
        MINDCRY = 61,
        ROD_OF_ONAN = 62,
        HELM_OF_SPIRITS = 63,
        THINKING_CAP = 64,
        OVERLORDS_HELM = 65,
        FOOLS_CREST = 66,
        GOTTERDAMERUNG = 67,
        ROYAL_CIRCLET = 68,
        TORN_FLESH_OF_SOULS = 69,
        THE_GLADIATORS_BANE = 70,
        THE_RAINBOW_CLOAK = 71,
        LEATHER_OF_AUT = 72,
        WISDOMS_WRAP = 73,
        SPARKING_MAIL = 74,
        SCAVENGER_CARAPACE = 75,
        NIGHTSCAPE = 76,
        NAJS_LIGHT_PLATE = 77,
        DEMONSPIKE_COAT = 78,
        THE_DEFLECTOR = 79,
        SPLIT_SKULL_SHIELD = 80,
        DRAGONS_BREACH = 81,
        BLACKOAK_SHIELD = 82,
        HOLY_DEFENDER = 83,
        STORMSHIELD = 84,
        BRAMBLE = 85,
        RING_OF_REGHA = 86,
        THE_BLEEDER = 87,
        CONSTRICTING_RING = 88,
        RING_OF_ENGAGEMENT = 89,
        NULL = 90
    }

    public enum eMonster
    {
        MT_NZOMBIE = 0x0,
        MT_BZOMBIE = 0x1,
        MT_GZOMBIE = 0x2,
        MT_YZOMBIE = 0x3,
        MT_RFALLSP = 0x4,
        MT_DFALLSP = 0x5,
        MT_YFALLSP = 0x6,
        MT_BFALLSP = 0x7,
        MT_WSKELAX = 0x8,
        MT_TSKELAX = 0x9,
        MT_RSKELAX = 0xA,
        MT_XSKELAX = 0xB,
        MT_RFALLSD = 0xC,
        MT_DFALLSD = 0xD,
        MT_YFALLSD = 0xE,
        MT_BFALLSD = 0xF,
        MT_NSCAV = 0x10,
        MT_BSCAV = 0x11,
        MT_WSCAV = 0x12,
        MT_YSCAV = 0x13,
        MT_WSKELBW = 0x14,
        MT_TSKELBW = 0x15,
        MT_RSKELBW = 0x16,
        MT_XSKELBW = 0x17,
        MT_WSKELSD = 0x18,
        MT_TSKELSD = 0x19,
        MT_RSKELSD = 0x1A,
        MT_XSKELSD = 0x1B,
        MT_INVILORD = 0x1C,
        MT_SNEAK = 0x1D,
        MT_STALKER = 0x1E,
        MT_UNSEEN = 0x1F,
        MT_ILLWEAV = 0x20,
        MT_LRDSAYTR = 0x21,
        MT_NGOATMC = 0x22,
        MT_BGOATMC = 0x23,
        MT_RGOATMC = 0x24,
        MT_GGOATMC = 0x25,
        MT_FIEND = 0x26,
        MT_BLINK = 0x27,
        MT_GLOOM = 0x28,
        MT_FAMILIAR = 0x29,
        MT_NGOATBW = 0x2A,
        MT_BGOATBW = 0x2B,
        MT_RGOATBW = 0x2C,
        MT_GGOATBW = 0x2D,
        MT_NACID = 0x2E,
        MT_RACID = 0x2F,
        MT_BACID = 0x30,
        MT_XACID = 0x31,
        MT_SKING = 0x32,
        MT_CLEAVER = 0x33,
        MT_FAT = 0x34,
        MT_MUDMAN = 0x35,
        MT_TOAD = 0x36,
        MT_FLAYED = 0x37,
        MT_WYRM = 0x38,
        MT_CAVSLUG = 0x39,
        MT_DVLWYRM = 0x3A,
        MT_DEVOUR = 0x3B,
        MT_NMAGMA = 0x3C,
        MT_YMAGMA = 0x3D,
        MT_BMAGMA = 0x3E,
        MT_WMAGMA = 0x3F,
        MT_HORNED = 0x40,
        MT_MUDRUN = 0x41,
        MT_FROSTC = 0x42,
        MT_OBLORD = 0x43,
        MT_BONEDMN = 0x44,
        MT_REDDTH = 0x45,
        MT_LTCHDMN = 0x46,
        MT_UDEDBLRG = 0x47,
        MT_INCIN = 0x48,
        MT_FLAMLRD = 0x49,
        MT_DOOMFIRE = 0x4A,
        MT_HELLBURN = 0x4B,
        MT_STORM = 0x4C,
        MT_RSTORM = 0x4D,
        MT_STORML = 0x4E,
        MT_MAEL = 0x4F,
        MT_BIGFALL = 0x50,
        MT_WINGED = 0x51,
        MT_GARGOYLE = 0x52,
        MT_BLOODCLW = 0x53,
        MT_DEATHW = 0x54,
        MT_MEGA = 0x55,
        MT_GUARD = 0x56,
        MT_VTEXLRD = 0x57,
        MT_BALROG = 0x58,
        MT_NSNAKE = 0x59,
        MT_RSNAKE = 0x5A,
        MT_BSNAKE = 0x5B,
        MT_GSNAKE = 0x5C,
        MT_NBLACK = 0x5D,
        MT_RTBLACK = 0x5E,
        MT_BTBLACK = 0x5F,
        MT_RBLACK = 0x60,
        MT_UNRAV = 0x61,
        MT_HOLOWONE = 0x62,
        MT_PAINMSTR = 0x63,
        MT_REALWEAV = 0x64,
        MT_SUCCUBUS = 0x65,
        MT_SNOWWICH = 0x66,
        MT_HLSPWN = 0x67,
        MT_SOLBRNR = 0x68,
        MT_COUNSLR = 0x69,
        MT_MAGISTR = 0x6A,
        MT_CABALIST = 0x6B,
        MT_ADVOCATE = 0x6C,
        MT_GOLEM = 0x6D,
        MT_DIABLO = 0x6E,
        NUM_MTYPES,
    }
}