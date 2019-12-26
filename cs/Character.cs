using System;

namespace Serpen.Diablo
{
    public class Spell
    {
        public eSpell spell { get; set; }
        public byte Index { get; set; }
        public string Spellbook { get; set; }
        public bool Enabled { get; set; }
        public byte Level { get; set; }
    }

    public enum Direction
    {
        South, South_West, West, North_West, North, North_East, East, South_East

    }

    public enum PLR_MODE
    {
        PM_STAND = 0, PM_WALK = 1, PM_WALK2 = 2, PM_WALK3 = 3, PM_ATTACK = 4, PM_RATTACK = 5, PM_BLOCK = 6, PM_GOTHIT = 7, PM_DEATH = 8, PM_SPELL = 9, PM_NEWLVL = 10, PM_QUIT = 11
    }


    public class Character
    {

        public byte[] Buffer;
        public Character(byte[] buffer)
        {
            Buffer = buffer;
        }

        public string Name
        {
            get
            {
                return System.Text.Encoding.ASCII.GetString(Buffer, 321, 32);
            }
        }

        public eCharClass Class
        {
            get
            {
                return (eCharClass)Buffer[353];
            }
        }

        public override string ToString()
        {
            return System.String.Format("{0} [Level {1}]", Name, Level);
        }

        public int StrengthBase { get { return BitConverter.ToInt32(Buffer, 361); } }
        public int Strength { get { return BitConverter.ToInt32(Buffer, 357); } }

        public int MagicBase { get { return BitConverter.ToInt32(Buffer, 369); } }
        public int Magic { get { return BitConverter.ToInt32(Buffer, 365); } }

        public int DexterityBase { get { return BitConverter.ToInt32(Buffer, 377); } }
        public int Dexterity { get { return BitConverter.ToInt32(Buffer, 373); } }

        public int VitalityBase { get { return BitConverter.ToInt32(Buffer, 385); } }
        public int Vitality { get { return BitConverter.ToInt32(Buffer, 381); } }

        public int Experience { get { return BitConverter.ToInt32(Buffer, 445); } }
        public int ExperienceNext { get { return BitConverter.ToInt32(Buffer, 453); } }

        public int LevelupPoints { get { return BitConverter.ToInt32(Buffer, 389); } }
        public int Level { get { return BitConverter.ToInt32(Buffer, 441); } }
        public int Gold { get { return BitConverter.ToInt32(Buffer, 461); } }
        public int LightRadius { get { return Buffer[319]*10; } }
        public int Dungeon { get { return Buffer[0x35]; } }
        public int PosX { get { return Buffer[0x39]; } }
        public int PosY { get { return Buffer[0x3d]; } }
        public int GotoPosX { get { return Buffer[0x59]; } }
        public int GotoPosY { get { return Buffer[0x5d]; } }
        public Direction Dir { get { return (Direction)Buffer[0x71]; } }
        public PLR_MODE Mode { get { return (PLR_MODE)Buffer[0]; } }
    }

}