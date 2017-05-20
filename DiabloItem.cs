using System;

namespace Serpen.Diablo
{

    public enum eItemQuality : byte { normal, magic, unique }
    public enum eItemClass : byte { Unwearable, Sword, Axe, Bow, Club, Shield, LightAmor, Cap, Mail, HeavyArmor, Staff, Gold, Ring, Amulett, invalid = 0xFF };
    public enum eEquipType : byte { none, OneHanded, TowHanded, Chest, Head, Ring, Amulet, Unequipable, Belt }
    public enum eSpell { All=-2, None =-1, Firebolt, healing, light, flash, identify, firewall, TownPortal, stonecurse, infrasion, phasing, manashield, fireball, guardian, chainlightning, flamewave, doomserpents, bloodritual, nova, invisiblity, inferno, golem, bloodboil, teleport, apocalypse, etheralize, itemrepair, staffrechare, trapdisarm, elemental, chargedbolt, holybolt, resurrect, telekinesis, healother, bloodstar, bonespirit }
    public enum eItemCode : byte { None, UseFirst, FullHealing, Healing, Mana = 0x6, FullMana, ElixirStrength = 0xA, ElixirMagic, ElixirDexterity, Elixirvitality, Rejuvenation = 0x12, FullRejuvenation, UseLast, Scroll, ScrollWithTarget, Staff, book, ring, amulet = 0x1a, unique, potionOfHealingSomething, MapOfTheStars = 0x2a, Ear, SpectralExlixir }
    public enum eItemCategory : byte { none, weapon, Armor, JewerlyOrConsumable, Gold, Chest }
	
	[Flags]
	public enum eSpecialEffect : long {
		none=0x0,
		Infrasion=0x1,
		RandomLifestealing=0x2,
		RandomSpeedarrows=0x4,
		FireArrowdamage=0x8,
		FireHitdamage=0x10,
		LightningHitDamage=0x20,
		ConstantlyLoseLife=0x40,
        _Unknown80 = 0x80,
		UserCantHeal_web=0x100,
        _Unknown200 = 0x200,
        _Unknown400 = 0x400,
		KnocksTargetBack=0x800,
		HitMonstersDoesntHeal_web=0x1000,
		HitSteals3PercentMana=0x2000,
		HitSteals5PercentMana=0x4000,
		HitSteals3PercentLife=0x8000,
		HitSteals5PercentLife=0x10000,
		QuickAttack=0x20000,
		FastAttack=0x40000,
		FasterAttack=0x80000,
		FastestAttack=0x100000,
		FastHitRecovery=0x200000,
		FasterHitRecovery=0x400000,
		FastestHitRecovery=0x800000,
		FastBlock=0x1000000,
		LightningArrowDamage=0x2000000,
		AttackerTakes1To3Damage_webthorns=0x4000000,
		UserLosesAllMana=0x8000000,
		AbsorbsHalfOfTrapDamage=0x10000000,
        _Unknown20000000 = 0x20000000,
		P200PercentDamageVsDemons=0x40000000,
		UserLosesAllResistances=0x80000000
	}

    public enum eItemBase {
        GOLD                             =   0,
        SHORT_SWORD                      =   1,
        BUCKLER                          =   2,
        CLUB                             =   3,
        SHORT_BOW                        =   4,
        SHORT_STAFF_OF_CHARGED_BOLT      =   5,
        CLEAVER                          =   6,
        THE_UNDEAD_CROWN                 =   7,
        EMPYREAN_BAND                    =   8,
        MAGIC_ROCK                       =   9,
        OPTIC_AMULET                     =  10,
        RING_OF_TRUTH                    =  11,
        TAVERN_SIGN                      =  12,
        HARLEQUIN_CREST                  =  13,
        VEIL_OF_STEEL                    =  14,
        GOLDEN_ELIXIR                    =  15,
        ANVIL_OF_FURY                    =  16,
        BLACK_MUSHROOM                   =  17,
        BRAIN                            =  18,
        FUNGAL_TOME                      =  19,
        SPECTRAL_ELIXIR                  =  20,
        BLOOD_STONE                      =  21,
        MAP_OF_THE_STARS                 =  22,
        HEART                            =  23,
        POTION_OF_HEALING                =  24,
        POTION_OF_MANA                   =  25,
        SCROLL_OF_IDENTIFY               =  26,
        SCROLL_OF_TOWN_PORTAL            =  27,
        ARKAINES_VALOR                   =  28,
        POTION_OF_FULL_HEALING           =  29,
        POTION_OF_FULL_MANA              =  30,
        GRISWOLDS_EDGE                   =  31,
        LIGHTFORGE                       =  32,
        STAFF_OF_LAZARUS                 =  33,
        SCROLL_OF_RESURRECT              =  34,
        NULL_1                           =  35,
        NULL_2                           =  36,
        NULL_3                           =  37,
        NULL_4                           =  38,
        NULL_5                           =  39,
        NULL_6                           =  40,
        NULL_7                           =  41,
        NULL_8                           =  42,
        NULL_9                           =  43,
        NULL_10                          =  44,
        NULL_11                          =  45,
        NULL_12                          =  46,
        NULL_13                          =  47,
        BASE_CAP                         =  48,
        BASE_SKULL_CAP                   =  49,
        BASE_HELM                        =  50,
        BASE_FULL_HELM                   =  51,
        BASE_CROWN                       =  52,
        BASE_GREAT_HELM                  =  53,
        BASE_CAPE                        =  54,
        BASE_RAGS                        =  55,
        BASE_CLOAK                       =  56,
        BASE_ROBE                        =  57,
        BASE_QUILTED_ARMOR               =  58,
        BASE_LEATHER_ARMOR               =  59,
        BASE_HARD_LEATHER_ARMOR          =  60,
        BASE_STUDDED_LEATHER_ARMOR       =  61,
        BASE_RING_MAIL                   =  62,
        BASE_CHAIN_MAIL                  =  63,
        BASE_SCALE_MAIL                  =  64,
        BASE_BREAST_PLATE                =  65,
        BASE_SPLINT_MAIL                 =  66,
        BASE_PLATE_MAIL                  =  67,
        BASE_FIELD_PLATE                 =  68,
        BASE_GOTHIC_PLATE                =  69,
        BASE_FULL_PLATE_MAIL             =  70,
        BASE_BUCKLER                     =  71,
        BASE_SMALL_SHIELD                =  72,
        BASE_LARGE_SHIELD                =  73,
        BASE_KITE_SHIELD                 =  74,
        BASE_TOWER_SHIELD                =  75,
        BASE_GOTHIC_SHIELD               =  76,
        BASE_POTION_OF_HEALING           =  77,
        BASE_POTION_OF_FULL_HEALING      =  78,
        BASE_POTION_OF_MANA              =  79,
        BASE_POTION_OF_FULL_MANA         =  80,
        BASE_POTION_OF_REJUVENATION      =  81,
        BASE_POTION_OF_FULL_REJUVENATION =  82,
        BASE_ELIXIR_OF_STRENGTH          =  83,
        BASE_ELIXIR_OF_MAGIC             =  84,
        BASE_ELIXIR_OF_DEXTERITY         =  85,
        BASE_ELIXIR_OF_VITALITY          =  86,
        BASE_SCROLL_OF_HEALING           =  87,
        BASE_SCROLL_OF_LIGHTNING         =  88,
        BASE_SCROLL_OF_IDENTIFY          =  89,
        BASE_SCROLL_OF_RESURRECT         =  90,
        BASE_SCROLL_OF_FIRE_WALL         =  91,
        BASE_SCROLL_OF_INFERNO           =  92,
        BASE_SCROLL_OF_TOWN_PORTAL       =  93,
        BASE_SCROLL_OF_FLASH             =  94,
        BASE_SCROLL_OF_INFRAVISION       =  95,
        BASE_SCROLL_OF_PHASING           =  96,
        BASE_SCROLL_OF_MANA_SHIELD       =  97,
        BASE_SCROLL_OF_FLAME_WAVE        =  98,
        BASE_SCROLL_OF_FIREBALL          =  99,
        BASE_SCROLL_OF_STONE_CURSE       = 100,
        BASE_SCROLL_OF_CHAIN_LIGHTNING   = 101,
        BASE_SCROLL_OF_GUARDIAN          = 102,
        BASE_NON_ITEM                    = 103,
        BASE_SCROLL_OF_NOVA              = 104,
        BASE_SCROLL_OF_GOLEM             = 105,
        BASE_SCROLL_OF_NONE              = 106,
        BASE_SCROLL_OF_TELEPORT          = 107,
        BASE_SCROLL_OF_APOCALYPSE        = 108,
        BASE_BOOK_QLVL_2                 = 109,
        BASE_BOOK_QLVL_8                 = 110,
        BASE_BOOK_QLVL_14                = 111,
        BASE_BOOK_QLVL_20                = 112,
        BASE_DAGGER                      = 113,
        BASE_SHORT_SWORD                 = 114,
        BASE_FALCHION                    = 115,
        BASE_SCIMITAR                    = 116,
        BASE_CLAYMORE                    = 117,
        BASE_BLADE                       = 118,
        BASE_SABRE                       = 119,
        BASE_LONG_SWORD                  = 120,
        BASE_BROAD_SWORD                 = 121,
        BASE_BASTARD_SWORD               = 122,
        BASE_TWO_HANDED_SWORD            = 123,
        BASE_GREAT_SWORD                 = 124,
        BASE_SMALL_AXE                   = 125,
        BASE_AXE                         = 126,
        BASE_LARGE_AXE                   = 127,
        BASE_BROAD_AXE                   = 128,
        BASE_BATTLE_AXE                  = 129,
        BASE_GREAT_AXE                   = 130,
        BASE_MACE                        = 131,
        BASE_MORNING_STAR                = 132,
        BASE_WAR_HAMMER                  = 133,
        BASE_SPIKED_CLUB                 = 134,
        BASE_CLUB                        = 135,
        BASE_FLAIL                       = 136,
        BASE_MAUL                        = 137,
        BASE_SHORT_BOW                   = 138,
        BASE_HUNTERS_BOW                 = 139,
        BASE_LONG_BOW                    = 140,
        BASE_COMPOSITE_BOW               = 141,
        BASE_SHORT_BATTLE_BOW            = 142,
        BASE_LONG_BATTLE_BOW             = 143,
        BASE_SHORT_WAR_BOW               = 144,
        BASE_LONG_WAR_BOW                = 145,
        BASE_SHORT_STAFF                 = 146,
        BASE_LONG_STAFF                  = 147,
        BASE_COMPOSITE_STAFF             = 148,
        BASE_QUARTER_STAFF               = 149,
        BASE_WAR_STAFF                   = 150,
        BASE_RING_QLVL_5                 = 151,
        BASE_RING_QLVL_10                = 152,
        BASE_RING_QLVL_15                = 153,
        BASE_AMULET_QLVL_8               = 154,
        BASE_AMULET_QLVL_16              = 155,
        NULL_14                          = 156
    }

    public enum eUniqueItem {
        NONE                   = -1,
        THE_BUTCHERS_CLEAVER   =  0,
        THE_UNDEAD_CROWN       =  1,
        EMPYREAN_BAND          =  2,
        OPTIC_AMULET           =  3,
        RING_OF_TRUTH          =  4,
        HARLEQUIN_CREST        =  5,
        VEIL_OF_STEEL          =  6,
        ARKAINES_VALOR         =  7,
        GRISWOLDS_EDGE         =  8,
        LIGHTFORGE             =  9,
        THE_RIFT_BOW           = 10,
        THE_NEEDLER            = 11,
        THE_CELESTIAL_BOW      = 12,
        DEADLY_HUNTER          = 13,
        BOW_OF_THE_DEAD        = 14,
        THE_BLACKOAK_BOW       = 15,
        FLAMEDART              = 16,
        FLESHSTINGER           = 17,
        WINDFORCE              = 18,
        EAGLEHORN              = 19,
        GONNAGALS_DIRK         = 20,
        THE_DEFENDER           = 21,
        GRYPHONS_CLAW          = 22,
        BLACK_RAZOR            = 23,
        GIBBOUS_MOON           = 24,
        ICE_SHANK              = 25,
        THE_EXECUTIONERS_BLADE = 26,
        THE_BONESAW            = 27,
        SHADOWHAWK             = 28,
        WIZARDSPIKE            = 29,
        LIGHTSABRE             = 30,
        THE_FALCONS_TALON      = 31,
        INFERNO                = 32,
        DOOMBRINGER            = 33,
        THE_GRIZZLY            = 34,
        THE_GRANDFATHER        = 35,
        THE_MANGLER            = 36,
        SHARP_BEAK             = 37,
        BLOODSLAYER            = 38,
        THE_CELESTIAL_AXE      = 39,
        WICKED_AXE             = 40,
        STONECLEAVER           = 41,
        AGUINARAS_HATCHET      = 42,
        HELLSLAYER             = 43,
        MESSERSCHMIDTS_REAVER  = 44,
        CRACKRUST              = 45,
        HAMMER_OF_JHOLM        = 46,
        CIVERBS_CUDGEL         = 47,
        THE_CELESTIAL_STAR     = 48,
        BARANARS_STAR          = 49,
        GNARLED_ROOT           = 50,
        THE_CRANIUM_BASHER     = 51,
        SCHAEFERS_HAMMER       = 52,
        DREAMFLANGE            = 53,
        STAFF_OF_SHADOWS       = 54,
        IMMOLATOR              = 55,
        STORM_SPIRE            = 56,
        GLEAMSONG              = 57,
        THUNDERCALL            = 58,
        THE_PROTECTOR          = 59,
        NAJS_PUZZLER           = 60,
        MINDCRY                = 61,
        ROD_OF_ONAN            = 62,
        HELM_OF_SPIRITS        = 63,
        THINKING_CAP           = 64,
        OVERLORDS_HELM         = 65,
        FOOLS_CREST            = 66,
        GOTTERDAMERUNG         = 67,
        ROYAL_CIRCLET          = 68,
        TORN_FLESH_OF_SOULS    = 69,
        THE_GLADIATORS_BANE    = 70,
        THE_RAINBOW_CLOAK      = 71,
        LEATHER_OF_AUT         = 72,
        WISDOMS_WRAP           = 73,
        SPARKING_MAIL          = 74,
        SCAVENGER_CARAPACE     = 75,
        NIGHTSCAPE             = 76,
        NAJS_LIGHT_PLATE       = 77,
        DEMONSPIKE_COAT        = 78,
        THE_DEFLECTOR          = 79,
        SPLIT_SKULL_SHIELD     = 80,
        DRAGONS_BREACH         = 81,
        BLACKOAK_SHIELD        = 82,
        HOLY_DEFENDER          = 83,
        STORMSHIELD            = 84,
        BRAMBLE                = 85,
        RING_OF_REGHA          = 86,
        THE_BLEEDER            = 87,
        CONSTRICTING_RING      = 88,
        RING_OF_ENGAGEMENT     = 89,
        NULL                   = 90
    }
	
    public class Item
    {
        private const int ITEMSIZE = 0x170;
        private const int ITEMNAMESIZE = 0x40;

        //for debug purpose
        public byte[] buffer = new byte[ITEMSIZE];

        System.Collections.BitArray dirtyFlag = new System.Collections.BitArray(0x170);

        int prefix = 0;

        byte[] preambleItmFormat = { 0x49, 0x54, 0x4d, 0x30, 0x31, 0x2e, 0x49, 0x27, 0x6c, 0x6c, 0x20, 0x67, 0x65, 0x74, 0x20, 0x74, 0x68, 0x61, 0x74, 0x20, 0x61, 0x6c, 0x27, 0x54, 0x68, 0x6f, 0x72, 0x21, 0x0, 0x0, 0x0, 0x0 };

        public Item(String path)
        {
            System.IO.FileStream stream = System.IO.File.OpenRead(path);
            byte[] mbuffer = new byte[stream.Length];
            stream.Read(mbuffer, 0, (int)stream.Length);
            stream.Close();

            int i;

            for (i = 0; i < preambleItmFormat.Length; i++)
            {
                if (preambleItmFormat[i] != mbuffer[i])
                {
                    break;
                }
            }

            if (i == preambleItmFormat.Length)
                Array.Copy(mbuffer, i, buffer, 0, mbuffer.Length - i);
            else
                buffer = mbuffer;

            if (buffer.Length != ITEMSIZE)
            {
                throw new Exception();
            }
        }

        public Item(byte[] pBuffer)
        {
            int i;

            for (i = 0; i < preambleItmFormat.Length; i++)
            {
                if (preambleItmFormat[i] != pBuffer[i])
                {
                    break;
                }
            }
            if (i == preambleItmFormat.Length)
                Array.Copy(pBuffer, i, buffer, 0, pBuffer.Length - i);
            else
                buffer = pBuffer;

            if (buffer.Length != ITEMSIZE)
            {
                throw new Exception();
            }
        }

        private String ConvertDiabloString(int start, int len)
        {
            String erg = System.Text.Encoding.ASCII.GetString(buffer, start, len);
            int pos = erg.IndexOf((char)0);
            if (pos > 0)
                return erg.Substring(0, pos);
            else
                return erg;
        }
		
		public override String ToString() {
			if (ItemClass == eItemClass.Gold) {
				return String.Format("{0} Gold", BasePrice);
			} else {
				return String.Format("{0} ({1})", IdentifiedName, Quality);
			}
		}

        public String UnidentifiedName {
            get {
                return ConvertDiabloString(0x3d + prefix, ITEMNAMESIZE);
            } set {
                if (value.Length+1 > ITEMNAMESIZE)
                    throw new ArgumentOutOfRangeException();
                else {
                    byte[] temp = System.Text.Encoding.ASCII.GetBytes(value + (char)0);
                    Array.Copy(temp, 0, buffer, 0x3D, temp.Length);
                }
            }
        }

        public String IdentifiedName {
            get {
                return ConvertDiabloString(0x7d + prefix, 0x40);
            } set {
                if (value.Length+1 > ITEMNAMESIZE)
                    throw new ArgumentOutOfRangeException();
                else {
                    byte[] temp = System.Text.Encoding.ASCII.GetBytes(value + (char)0);
                    Array.Copy(temp, 0, buffer, 0x3D, temp.Length);
                }
            }
        }

        public uint ID {
            get {
                return System.BitConverter.ToUInt32(buffer, prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0,temp.Length);
            }
        }

        public String Found {
            get {
                UInt16 temp = System.BitConverter.ToUInt16(buffer,0x4+prefix);
                if (temp == (temp | 0x10000)) {
                    return "0x10000 Level ?" + (temp & 63);
                } else if (temp == (temp | 0x8000)) {
                    return "0x8000 Level ?" + (temp & 63);
                } else if (temp == (temp | 0x4000)) {
                    return "0x4000 Level ?" + (temp & 63);
                } else if (temp == (temp | 0x2000)) {
                    return "Adria Level ?" + (temp & 63);
                } else if (temp == (temp | 0x1000)) {
                    return "Wirt Level " + (temp & 63);
                } else if (temp == (temp | 0x800)) {
                    return "Griswold Premium Level " + (temp & 63);
                } else if (temp == (temp | 0x400)) {
                    return "Griswold Basic Level " + (temp & 63);
                } else if (temp == (temp | 0x200)) {
                    return "Single Player Monster Level " + (temp & 63);
                } else if (temp == (temp | 0x100)) {
                    return "Monster Level " + (temp & 63);
                } else if (temp == (temp | 0xc0)) {
                    return "Unique Monster Level " + (temp  & 63);
                } else if (temp == (temp | 0x40)) {
                    return "Dungeon Level " + ((temp & 63) >> 1);
                } else {
                    return "Unknown Level " + (temp & 63);
                } 
            }
        }

        public eItemClass ItemClass {
            get {
                return (eItemClass)buffer[0x8 + prefix];
            } set {
                buffer[0x8 + prefix] = (byte)value;
            }
        }

        public bool Identified {
            get {
                return buffer[0x38 + prefix] == 0 ? false : true;
            } set {
                buffer[0x38 + prefix] = (byte)(value ? 1 : 0);
            }
        }

        public eItemQuality Quality {
            get {
                return (eItemQuality)buffer[0x3c + prefix];
            } set {
                buffer[0x3c + prefix] = (byte)value;
            }
        }

        public eEquipType EquipType {
            get {
                return (eEquipType)buffer[0xBD + prefix];
            } set {
                buffer[0xBD + prefix] = (byte)value;
            }
        }
        
        public eItemCategory Category {
            get {
                return (eItemCategory)buffer[0xBE + prefix];
            } set {
                buffer[0xBE + prefix] = (byte)value;
            }
        }

        public uint Graphics {
            get {
                return System.BitConverter.ToUInt32(buffer, 0xC0 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xC0 + prefix,temp.Length);
            }
        }

        public uint BasePrice {
            get {
                return System.BitConverter.ToUInt32(buffer, 0xC4 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xC4 + prefix,temp.Length);
            }
        }

        public uint IdentifiedPrice {
            get {
                return System.BitConverter.ToUInt32(buffer, 0xC8 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xC8 + prefix,temp.Length);
            }
        }

        public uint DamageBase {
            get {
                return System.BitConverter.ToUInt32(buffer, 0xCC + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xCC + prefix,temp.Length);
            }
        }

        public uint DamageMax {
            get {
                return System.BitConverter.ToUInt32(buffer, 0xD0 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xD0 + prefix,temp.Length);
            }
        }

        public int Amor {
            get {
                return System.BitConverter.ToInt32(buffer, 0xD4 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xD4 + prefix,temp.Length);
            }
        }

        public eSpecialEffect SpecialEffect {
            get {
                return (eSpecialEffect)System.BitConverter.ToUInt32(buffer, 0xD8 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes((uint)value);
                Array.Copy(temp,0,buffer,0xD8 + prefix,temp.Length);
            }
        }

        public eItemCode ItemCode {
            get {
                return (eItemCode) System.BitConverter.ToInt32(buffer, 0xD8 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes((int)value);
                Array.Copy(temp,0,buffer,0xD8 + prefix,temp.Length);
            }
        }

        public eSpell Spell {
            get {
                return (eSpell)System.BitConverter.ToUInt32(buffer, 0xE0 + prefix)-1;
            } set {
                if (value != eSpell.None )
                    buffer[0xE0 + prefix] = (byte)value;
            }
        }

        public int Charges {
            get {
                return System.BitConverter.ToInt32(buffer, 0xE4 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xE4 + prefix,temp.Length);
            }
        }

        public int ChargesMax {
            get {
                return System.BitConverter.ToInt32(buffer, 0xE8 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xE8 + prefix,temp.Length);
            }
        }

        public int Durability {
            get {
                return System.BitConverter.ToInt32(buffer, 0xEC + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xEC + prefix,temp.Length);
            }
        }

        public int DurabilityMax {
            get {
                return System.BitConverter.ToInt32(buffer, 0xF0 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xF0 + prefix,temp.Length);
            }
        }

        public int DamageBonus {
            get {
                return System.BitConverter.ToInt32(buffer, 0xF4 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xF4 + prefix,temp.Length);
            }
        }

        public int ToHitBonus {
            get {
                return System.BitConverter.ToInt32(buffer, 0xF8 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xF8 + prefix,temp.Length);
            }
        }

        public int AmorBonus {
            get {
                return System.BitConverter.ToInt32(buffer, 0xFc + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0xFC + prefix,temp.Length);
            }
        }

        public int StrengthBonus {
            get {
                return System.BitConverter.ToInt32(buffer, 0x100 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x100 + prefix,temp.Length);
            }
        }

        public int MagicBonus {
            get {
                return System.BitConverter.ToInt32(buffer, 0x104 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x104 + prefix,temp.Length);
            }
        }

        public int DexterityBonus {
            get {
                return System.BitConverter.ToInt32(buffer, 0x108 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x108 + prefix,temp.Length);
            }
        }

        public int VitalityBonus {
            get {
                return System.BitConverter.ToInt32(buffer, 0x10c + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x10C + prefix,temp.Length);
            }
        }

        public int ResistFire {
            get {
                return System.BitConverter.ToInt32(buffer, 0x110 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x110 + prefix,temp.Length);
            }
        }
        public int ResistLightning {
            get {
                return System.BitConverter.ToInt32(buffer, 0x114 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x114 + prefix,temp.Length);
            }
        }
        public int ResistMagic {
            get {
                return System.BitConverter.ToInt32(buffer, 0x118 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x118 + prefix,temp.Length);
            }
        }

        public int ManaBonus {
            get {
                return System.BitConverter.ToUInt16(buffer, 0x11c + prefix) >> 6;
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x11C + prefix,temp.Length);
            }
        }
        public int LifeBonus {
            get {
                return System.BitConverter.ToUInt16(buffer, 0x120 + prefix) >> 6;
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x120 + prefix,temp.Length);
            }
        }

        public int ExtraDamage {
            get {
                return System.BitConverter.ToInt32(buffer, 0x124 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x124 + prefix,temp.Length);
            }
        }
        public int DamageModifier {
            get {
                return System.BitConverter.ToInt32(buffer, 0x128 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x128 + prefix,temp.Length);
            }
        }

        public int LightRadius {
            get {
                return System.BitConverter.ToInt32(buffer, 0x12c + prefix)*10;
            } set {
                byte[] temp = System.BitConverter.GetBytes(value/10);
                Array.Copy(temp,0,buffer,0x12C + prefix,temp.Length);
            }
        }

        public byte Spellbonus {
            get {
                return buffer[0x130 + prefix];
            } set {
                buffer[0x130 + prefix] = value;
            }
        }

        public eUniqueItem UniqueId {
            get {
                if (Quality == eItemQuality.unique)
                    return (eUniqueItem)System.BitConverter.ToUInt32(buffer, 0x134 + prefix);
                else
                    return eUniqueItem.NONE;
            } set {
                if (value != eUniqueItem.NONE && Quality != eItemQuality.unique) {
                    byte[] temp = System.BitConverter.GetBytes((uint)value);
                    Array.Copy(temp,0,buffer,0x134 + prefix,temp.Length);
                }
            }
        }

        public uint FireDamageBase {
            get {
                return System.BitConverter.ToUInt32(buffer, 0x138 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x138 + prefix,temp.Length);
            }
        }
        public uint FireDamageMax {
            get {
                return System.BitConverter.ToUInt32(buffer, 0x13c + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x13C + prefix,temp.Length);
            }
        }

        public uint LightningDamageBase {
            get {
                return System.BitConverter.ToUInt32(buffer, 0x140 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x140 + prefix,temp.Length);
            }
        }
        public uint LightningDamageMax {
            get {
                return System.BitConverter.ToUInt32(buffer, 0x144 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x144 + prefix,temp.Length);
            }
        }

        public byte RequireStr {
            get {
                return buffer[0x160 + prefix];
            } set {
                buffer[0x160 + prefix] = value;
            }
        }
        public byte RequireMagic {
            get {
                return buffer[0x161 + prefix];
            } set {
                buffer[0x161 + prefix] = value;
            }
        }
        public byte RequireDex {
            get {
                return buffer[0x162 + prefix];
            } set {
                buffer[0x162 + prefix] = value;
            }
        }
        public byte RequireVit {
            get {
                return buffer[0x163 + prefix];
            } set {
                buffer[0x163 + prefix] = value;
            }
        }

        public bool Equippable {
            get {
                return buffer[0x164 + prefix] == 0 ? true : false;
            } set {
                buffer[0x164 + prefix] = (byte)(value ?  1 :  0);
            }
        }

        public bool HeldInHand {
            get {
                return buffer[0x131 + prefix] == 0 ? true : false;
            } set {
                buffer[0x131 + prefix] = (byte)(value ?  1 :  0);
            }
        }

        public uint inactive {
            get {
                return System.BitConverter.ToUInt32(buffer, 0x2C + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp,0,buffer,0x2C + prefix,temp.Length);
            }
        }

        public eItemBase ItemBase {
            get {
                return (eItemBase)System.BitConverter.ToUInt32(buffer, 0x168 + prefix);
            } set {
                byte[] temp = System.BitConverter.GetBytes((uint)value);
                Array.Copy(temp,0,buffer,0x168 + prefix,temp.Length);
            }
        }

        /*
        public System.Drawing.Point Position {
            get {
                return new System.Drawing.Point(System.BitConverter.ToUInt32(buffer,0x10+prefix),System.BitConverter.ToUInt32(buffer,0xc+prefix));
            } set {
                byte[] temp = System.BitConverter.GetBytes(value.X);
                Array.Copy(temp,0,buffer,0x10 + prefix,temp.Length);

                temp = System.BitConverter.GetBytes(value.Y);
                Array.Copy(temp,0,buffer,0xC + prefix,temp.Length);
            }
        }

        #$properties.Add("Col", [System.BitConverter]::ToUInt32($buffer,0xc+$PREAMBLE)) #0-91

        #$properties.Add("Row", [System.BitConverter]::ToUInt32($buffer,0x10+$PREAMBLE)) #0-92

        #$properties.Add("drop_anim_update", [System.BitConverter]::ToUInt32($buffer,0x14+$PREAMBLE)) #0-1
        #$properties.Add("drop_cel_data", [System.BitConverter]::ToUInt32($buffer,0x18+$PREAMBLE))
        #$properties.Add("drop_frame_count", [System.BitConverter]::ToUInt32($buffer,0x1C+$PREAMBLE))

        #$properties.Add("cur_drop_frame", [System.BitConverter]::ToUInt32($buffer,0x20+$PREAMBLE)) #1-16
        #$properties.Add("drop_width", [System.BitConverter]::ToUInt32($buffer,0x24+$PREAMBLE)) #0,96
        #$properties.Add("drop_x_offset", [System.BitConverter]::ToUInt32($buffer,0x28+$PREAMBLE))

        #$properties.Add("drop_state", $buffer[0x30+$PREAMBLE]) #0/1

        #$properties.Add("draw_quest_item", [bool][System.BitConverter]::ToUInt32($buffer,0x34+$PREAMBLE)) #0/1

        #$properties.Add("prefix_effect_type", $buffer[0x14C+$PREAMBLE])
        #$properties.Add("suffix_effect_type", $buffer[0x14D+$PREAMBLE])

        #$properties.Add("prefix_price", $buffer[0x150+$PREAMBLE])
        #$properties.Add("prefix_price_multiplier", $buffer[0x154+$PREAMBLE])

        #$properties.Add("suffix_price", $buffer[0x158+$PREAMBLE])
        #$properties.Add("suffix_price_multiplier", $buffer[0x15C+$PREAMBLE])
         */
    }
}

/*
Add-Type -Path "d:\SkyDrive\WindowsPowerShell\PS-Diablo1\DiabloItem.cs"
[Serpen.Diablo.Item]::new("T:\Austausch\d1\items\Unique\Griswold's Edge.ITM")
*/