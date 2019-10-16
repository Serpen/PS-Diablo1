using System;
using System.Runtime.InteropServices;

namespace Serpen.Diablo
{
	public enum eSpell { All=-2, None =-1, Firebolt, healing, light, flash, identify, firewall, TownPortal, stonecurse, infrasion, phasing, manashield, fireball, guardian, chainlightning, flamewave, doomserpents, bloodritual, nova, invisiblity, inferno, golem, bloodboil, teleport, apocalypse, etheralize, itemrepair, staffrechare, trapdisarm, elemental, chargedbolt, holybolt, resurrect, telekinesis, healother, bloodstar, bonespirit }
	public enum eCharClass {Warrior, Rogue, Sorceror}

    public class Spell {
        public eSpell spell { get; set; }
        public byte Index { get; set; }
        public String Spellbook { get; set; }
        public bool Enabled { get; set; }
        public byte Level { get; set; }
    }
    

    public class Character {
        public Character(byte[] buffer) {
            MemStruct = PlayerMemStruct.FromBuffer(buffer);
        }

        PlayerMemStruct MemStruct;

        public String Name {
            get {
                return MemStruct.Name;
            }
        }

        public eCharClass Class {
            get {
                return (eCharClass)MemStruct.Class;
            }
        }

        public override String ToString() {
            return String.Format("{0} [Level {1}]", Name, Level);
        }

        public int StrengthBase {get {return MemStruct.BaseStrength;}}
        public int Strength {get {return MemStruct.Strength;}}

        public int MagicBase {get {return MemStruct.pBaseMag;}}
        public int Magic {get {return MemStruct.pMagic;}}

        public int DexterityBase {get {return MemStruct.pBaseDex;}}
        public int Dexterity {get {return MemStruct.pDexterity;}}

        public int VitalityBase {get {return MemStruct.pBaseVit;}}
        public int Vitality {get {return MemStruct.pVitality;}}

        public int Experience {get {return MemStruct.Experience;}}
        public int ExperienceNext {get {return MemStruct.nextXP;}}

        public int Level {get {return MemStruct.Level;}}

        public int LevelupPoints {get {return MemStruct.pStatPts;}}

        public int Gold {get {return MemStruct.Gold;}}

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi, Pack = 1)]
        public struct PlayerMemStruct
        {
            static public PlayerMemStruct FromBuffer(byte[] buffer) {
                var bufferHandle = GCHandle.Alloc(buffer, GCHandleType.Pinned);

                var memstruct = (PlayerMemStruct)Marshal.PtrToStructure(bufferHandle.AddrOfPinnedObject(), typeof(PlayerMemStruct));
                bufferHandle.Free();
                return memstruct;
            }

            public static int Size() {
                return Marshal.SizeOf(typeof(PlayerMemStruct));
            }

            public int _pmode;
            public byte walkpath01;
            public byte walkpath02;
            public byte walkpath03;
            public byte walkpath04;
            public byte walkpath05;
            public byte walkpath06;
            public byte walkpath07;
            public byte walkpath08;
            public byte walkpath09;
            public byte walkpath10;
            public byte walkpath11;
            public byte walkpath12;
            public byte walkpath13;
            public byte walkpath14;
            public byte walkpath15;
            public byte walkpath16;
            public byte walkpath17;
            public byte walkpath18;
            public byte walkpath19;
            public byte walkpath20;
            public byte walkpath21;
            public byte walkpath22;
            public byte walkpath23;
            public byte walkpath24;
            public byte walkpath25;
            public byte walkpath26;
            public byte walkpath27;
            public byte walkpath28;
            public byte walkpath29;
            public byte walkpath30;
            public byte walkpath31;
            public byte walkpath32;
            public byte walkpath33;
            
            public byte _plractive;

            public int _destAction;
            public int _destParam1;
            public int _destParam2;
            public int _destParam3;
            public int _destParam4;
            public int _plrlevel;
            public int _WorldX;
            public int _WorldY;
            public int _px;
            public int _py;
            public int _ptargx;
            public int _ptargy;
            public int _pownerx;
            public int _pownery;
            public int _poldx;
            public int _poldy;
            public int _pxoff;
            public int _pyoff;
            public int _pxvel;
            public int _pyvel;
            public int _pdir;
            public int _nextdir;
            public int _pgfxnum;
            public int _pAnimData; // unsigned char *
            public int _pAnimDelay;
            public int _pAnimCnt;
            public int _pAnimLen;
            public int _pAnimFrame;
            public int _pAnimWidth;
            public int _pAnimWidth2;
            public int _peflag;
            public int _plid;
            public int _pvid;
            public int _pSpell;

            public byte _pSplType;
            public byte _pSplFrom;

            public int _pTSpell;
            public int _pTSplType;
            public int _pRSpell;
            public int _pRSplType;
            public int _pSBkSpell;

            public byte _pSBkSplType;

            public byte _pSplLvl01;
            public byte _pSplLvl02;
            public byte _pSplLvl03;
            public byte _pSplLvl04;
            public byte _pSplLvl05;
            public byte _pSplLvl06;
            public byte _pSplLvl07;
            public byte _pSplLvl08;
            public byte _pSplLvl09;
            public byte _pSplLvl10;
            public byte _pSplLvl11;
            public byte _pSplLvl12;
            public byte _pSplLvl13;
            public byte _pSplLvl14;
            public byte _pSplLvl15;
            public byte _pSplLvl16;
            public byte _pSplLvl17;
            public byte _pSplLvl18;
            public byte _pSplLvl19;
            public byte _pSplLvl20;
            public byte _pSplLvl21;
            public byte _pSplLvl22;
            public byte _pSplLvl23;
            public byte _pSplLvl24;
            public byte _pSplLvl25;
            public byte _pSplLvl26;
            public byte _pSplLvl27;
            public byte _pSplLvl28;
            public byte _pSplLvl29;
            public byte _pSplLvl30;
            public byte _pSplLvl31;
            public byte _pSplLvl32;
            public byte _pSplLvl33;
            public byte _pSplLvl34;
            public byte _pSplLvl35;
            public byte _pSplLvl36;
            public byte _pSplLvl37;
            public byte _pSplLvl38;
            public byte _pSplLvl39;
            public byte _pSplLvl40;
            public byte _pSplLvl41;
            public byte _pSplLvl42;
            public byte _pSplLvl43;
            public byte _pSplLvl44;
            public byte _pSplLvl45;
            public byte _pSplLvl46;
            public byte _pSplLvl47;
            public byte _pSplLvl48;
            public byte _pSplLvl49;
            public byte _pSplLvl50;
            public byte _pSplLvl51;
            public byte _pSplLvl52;
            public byte _pSplLvl53;
            public byte _pSplLvl54;
            public byte _pSplLvl55;
            public byte _pSplLvl56;
            public byte _pSplLvl57;
            public byte _pSplLvl58;
            public byte _pSplLvl59;
            public byte _pSplLvl60;
            public byte _pSplLvl61;
            public byte _pSplLvl62;
            public byte _pSplLvl63;
            public byte _pSplLvl64;

            public int remove_1;

            // old ->

            int _pMemSpells1;
            int _pMemSpells2; // __declspec(align(8))
            int _pAblSpells1;
            int _pAblSpells2;
            int _pScrlSpells1;
            int _pScrlSpells2;
            int _pSpellFlags;

            public int hotkey01;
            public int hotkey02;
            public int hotkey03;
            public int hotkey04;
            
            public byte hotkey1;
            public byte hotkey2;
            public byte hotkey3;
            public byte hotkey4;

            public int _pwtype;
            public byte _pBlockFlag;
            public byte _pInvincible;
            public byte _pLightRad;
            public byte _pLvlChanging;

            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]public String Name;

            public int Class;
            public int Strength;
            public int BaseStrength;
            public int pMagic;
            public int pBaseMag;
            public int pDexterity;
            public int pBaseDex;
            public int pVitality;
            public int pBaseVit;
            public int pStatPts;
            public int _pDamageMod;
            public int _pBaseToBlk;
            public int _pHPBase;
            public int _pMaxHPBase;
            public int _pHitPoints;
            public int _pMaxHP;
            public int _pHPPer;
            public int _pManaBase;
            public int _pMaxManaBase;
            public int _pMana;
            public int _pMaxMana;
            public int _pManaPer;

            public int Level;

            public int Experience;
            int MaxXP;
            public int nextXP;

            public byte AmorClass;
            public byte MagResist;
            public byte FireResist;
            public byte LightResist;

            public int Gold;
            public int InfraFlag;

            int _pVar1;
            int _pVar2;
            int _pVar3;
            int _pVar4;
            int _pVar5;
            int _pVar6;
            int _pVar7;
            int _pVar8;

            public byte Level01Visit;
            public byte Level02Visit;
            public byte Level03Visit;
            public byte Level04Visit;
            
            public byte Level05Visit;
            public byte Level06Visit;
            public byte Level07Visit;
            public byte Level08Visit;

            public byte Level09Visit;
            public byte Level10Visit;
            public byte Level11Visit;
            public byte Level12Visit;

            public byte Level13Visit;
            public byte Level14Visit;
            public byte Level15Visit;
            public byte Level16Visit;

            public byte Level17Visit;
            public byte SLevel01Visit;
            public byte SLevel02Visit;
            public byte SLevel03Visit;

            public byte SLevel04Visit;
            public byte SLevel05Visit;
            public byte SLevel06Visit;
            public byte SLevel07Visit;

            public byte SLevel08Visit;
            public byte SLevel09Visit;
            public byte SLevel10Visit;
            byte gap1;
        }
    }
    
    
}